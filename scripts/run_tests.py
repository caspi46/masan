#!/usr/bin/env python3

import subprocess
import os
import sys

# Paths - Point to the standalone masan_pass binary executable
PASS = "./target/release/masan_pass"
RT   = "./target/release/libmasan_rt.a"
TMP_IR_RAW = "/tmp/masan_raw.ll"
TMP_IR_INST = "/tmp/masan_instrumented.ll"
TMP  = "/tmp/masan_test"

pass_count = 0
fail_count = 0

def run_test(file: str, should_trigger: bool):
    global pass_count, fail_count

    name = os.path.basename(file)

    # 1. Compile C code to raw LLVM IR (-O0 preserves alloca/load/store)
    clang_ir_cmd = [
        "clang", "-S", "-emit-llvm", "-O0", "-Xclang", "-disable-O0-optnone", "-g",
        "-fno-discard-value-names",
        file, "-o", TMP_IR_RAW
    ]
    res1 = subprocess.run(clang_ir_cmd, capture_output=True)
    if res1.returncode != 0:
        print(f"✗ COMPILE ERROR (Clang IR): {name}")
        print(res1.stderr.decode())
        fail_count += 1
        return

    # 2. Run Masan Pass CLI tool to inject redzones & access checks
    pass_cmd = [PASS, TMP_IR_RAW, "-o", TMP_IR_INST]
    res2 = subprocess.run(pass_cmd, capture_output=True)
    if res2.returncode != 0:
        print(f"✗ COMPILE ERROR (Masan Pass): {name}")
        print(res2.stderr.decode())
        fail_count += 1
        return

    # 3. Link instrumented IR with libmasan_rt.a
    link_cmd = [
        "clang", TMP_IR_INST,
        "-Wl,-force_load", RT,
        "-lpthread", "-ldl",
        "-o", TMP
    ]
    res3 = subprocess.run(link_cmd, capture_output=True)
    if res3.returncode != 0:
        print(f"✗ COMPILE ERROR (Linking): {name}")
        print(res3.stderr.decode())
        fail_count += 1
        return

    # 4. Run the sanitized test binary
    run_result = subprocess.run([TMP], capture_output=True)
    triggered = run_result.returncode != 0

    if should_trigger:
        if triggered:
            print(f"✓ PASS: {name} (detected correctly)")
            pass_count += 1
        else:
            print(f"✗ FAIL: {name} (should have triggered)")
            fail_count += 1
    else:
        if not triggered:
            print(f"✓ PASS: {name} (no false positive)")
            pass_count += 1
        else:
            print(f"✗ FAIL: {name} (false positive)")
            print(run_result.stderr.decode())
            fail_count += 1


def main():
    # Check binaries exist
    if not os.path.exists(PASS):
        print(f"ERROR: pass executable not found at {PASS}")
        print("Run: cargo build --release -p masan-pass")
        sys.exit(1)

    if not os.path.exists(RT):
        print(f"ERROR: runtime not found at {RT}")
        print("Run: cargo build --release -p masan-rt")
        sys.exit(1)

    print("=== Stack Overflow Tests ===")
    run_test("tests/stack_overflow/basic.c",     should_trigger=True)
    run_test("tests/stack_overflow/underflow.c", should_trigger=True)
    run_test("tests/stack_overflow/int_var.c",   should_trigger=True)

    print("\n=== Use-After-Scope Tests ===")
    run_test("tests/use_after_scope/basic.c",    should_trigger=True)
    run_test("tests/use_after_scope/nested.c",   should_trigger=True)
    run_test("tests/use_after_scope/loop.c",     should_trigger=True)

    print("\n=== Valid Access Tests ===")
    run_test("tests/valid/basic.c",              should_trigger=False)
    run_test("tests/valid/partial.c",            should_trigger=False)

    print("\n================================")
    print(f"Results: {pass_count} passed, {fail_count} failed")
    print("================================")

    sys.exit(0 if fail_count == 0 else 1)


if __name__ == "__main__":
    main()