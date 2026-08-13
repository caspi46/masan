#!/usr/bin/env python3

import os
import platform
import subprocess
import sys

# 1. Resolve Binary Paths (Fallback to target/debug if release isn't built)
PASS = (
    "./target/release/masan_pass"
    if os.path.exists("./target/release/masan_pass")
    else "./target/debug/masan_pass"
)
RT = (
    "./target/release/libmasan_rt.a"
    if os.path.exists("./target/release/libmasan_rt.a")
    and os.path.exists("./target/debug/libmasan_rt.a")
    and os.path.getmtime("./target/release/libmasan_rt.a")
    > os.path.getmtime("./target/debug/libmasan_rt.a")
    else (
        "./target/debug/libmasan_rt.a"
        if os.path.exists("./target/debug/libmasan_rt.a")
        else "./target/release/libmasan_rt.a"
    )
)

TMP_IR_RAW = "/tmp/masan_raw.ll"
TMP_IR_INST = "/tmp/masan_instrumented.ll"
TMP = "/tmp/masan_test"

pass_count = 0
fail_count = 0


def get_link_flags():
    """Returns platform-specific linker flags to force load static archive."""
    if platform.system() == "Darwin":
        return ["-Wl,-force_load", RT]
    else:
        # Linux / ELF linker flags
        return ["-Wl,--whole-archive", RT, "-Wl,--no-whole-archive"]


def run_test(file: str, should_trigger: bool):
    global pass_count, fail_count

    name = os.path.basename(file)

    # Check if test file exists before trying to run
    if not os.path.exists(file):
        print(f"⚠️  SKIP: {file} (file not found)")
        return

    # 1. Compile C code to raw LLVM IR
    clang_ir_cmd = [
        "clang",
        "-S",
        "-emit-llvm",
        "-O1",
        "-Xclang",
        "-disable-llvm-passes",
        "-g",
        "-fno-discard-value-names",
        file,
        "-o",
        TMP_IR_RAW,
    ]
    res1 = subprocess.run(clang_ir_cmd, capture_output=True, text=True)
    if res1.returncode != 0:
        print(f"✗ COMPILE ERROR (Clang IR): {name}")
        print(res1.stderr)
        fail_count += 1
        return

    # 2. Run Masan Pass CLI tool
    pass_cmd = [PASS, TMP_IR_RAW, "-o", TMP_IR_INST]
    res2 = subprocess.run(pass_cmd, capture_output=True, text=True)
    if res2.returncode != 0:
        print(f"✗ COMPILE ERROR (Masan Pass): {name}")
        print(res2.stderr)
        fail_count += 1
        return

    # 3. Link instrumented IR with runtime library
    link_cmd = (
        ["clang", TMP_IR_INST]
        + get_link_flags()
        + ["-lpthread", "-ldl", "-o", TMP]
    )
    res3 = subprocess.run(link_cmd, capture_output=True, text=True)
    if res3.returncode != 0:
        print(f"✗ COMPILE ERROR (Linking): {name}")
        print(res3.stderr)
        fail_count += 1
        return

    # 4. Run the sanitized test binary
    run_result = subprocess.run([TMP], capture_output=True, text=True)
    triggered = run_result.returncode != 0

    if should_trigger:
        if triggered:
            print(f"✓ PASS: {name} (detected correctly)")
            pass_count += 1
        else:
            print(f"✗ FAIL: {name} (should have triggered, but passed)")
            fail_count += 1
    else:
        if not triggered:
            print(f"✓ PASS: {name} (no false positive)")
            pass_count += 1
        else:
            print(f"✗ FAIL: {name} (false positive trigger)")
            if run_result.stderr:
                print(run_result.stderr)
            fail_count += 1


def main():
    print(f"[*] Using Pass Binary:    {PASS}")
    print(f"[*] Using Runtime Library: {RT}\n")

    # Verify binaries exist
    if not os.path.exists(PASS):
        print(f"ERROR: Pass executable not found at '{PASS}'")
        print("Run: cargo build")
        sys.exit(1)

    if not os.path.exists(RT):
        print(f"ERROR: Runtime library not found at '{RT}'")
        print("Run: cargo build")
        sys.exit(1)

    print("=== Stack Overflow Tests ===")
    run_test("tests/stack_overflow/basic.c", should_trigger=True)
    run_test("tests/stack_overflow/underflow.c", should_trigger=True)
    run_test("tests/stack_overflow/int_var.c", should_trigger=True)

    print("\n=== Use-After-Scope Tests ===")
    run_test("tests/use_after_scope/basic.c", should_trigger=True)
    run_test("tests/use_after_scope/nested.c", should_trigger=True)
    run_test("tests/use_after_scope/loop.c", should_trigger=True)

    print("\n=== Valid Access Tests ===")
    run_test("tests/valid/basic.c", should_trigger=False)
    run_test("tests/valid/partial.c", should_trigger=False)

    print("\n================================")
    print(f"Results: {pass_count} passed, {fail_count} failed")
    print("================================")

    sys.exit(0 if fail_count == 0 else 1)


if __name__ == "__main__":
    main()