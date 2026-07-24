#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
from pathlib import Path

LLVM_BIN = Path("/opt/homebrew/opt/llvm@22/bin")
CLANG_PATH = LLVM_BIN / "clang"

def run_cmd(cmd, description):
    print(f"[*] {description}...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"[-] Error during: {description}\n", file=sys.stderr)
        print("=== STDOUT ===", file=sys.stderr)
        print(result.stdout, file=sys.stderr)
        print("=== STDERR ===", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        sys.exit(1)
    return result

def main():
    parser = argparse.ArgumentParser(description="Masan Sanitizer Driver")
    parser.add_argument("input_file", help="Path to the C/C++ source file")
    parser.add_argument("-o", "--output", default="my_sanitized_app", help="Output binary name")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parent.parent
    input_path = Path(args.input_file).resolve()
    base_name = input_path.stem
    ir_file = f"{base_name}.ll"
    instrumented_ir = f"{base_name}_instrumented.ll"

    # 1. Compile C code to LLVM IR without optimizing away stack allocations
    clang_to_ir = [
        str(CLANG_PATH), "-S", "-emit-llvm", "-O0", "-Xclang", "-disable-O0-optnone", "-g",
        "-fno-discard-value-names",
        "-isysroot", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",
        str(input_path), "-o", ir_file
    ]
    run_cmd(clang_to_ir, f"Compiling {input_path.name} to raw LLVM IR")

    # 2. Build the Rust workspace (masan-pass binary + masan-rt static library)
    cargo_build = ["cargo", "build"]
    run_cmd(cargo_build, "Building Masan Pass & Runtime Library")

    target_dir = project_root / "target" / "debug"
    pass_bin = target_dir / "masan_pass"
    rt_lib = target_dir / "libmasan_rt.a"

    if not pass_bin.exists():
        print(f"[-] Error: Could not find pass binary at {pass_bin}", file=sys.stderr)
        sys.exit(1)

    if not rt_lib.exists():
        print(f"[-] Error: Could not find runtime library at {rt_lib}", file=sys.stderr)
        sys.exit(1)

    # 3. Run the LLVM instrumentation pass
    pass_cmd = [str(pass_bin), ir_file, "-o", instrumented_ir]
    run_cmd(pass_cmd, "Injecting Redzones and Access Checks via Masan Pass")

    # 4. Link instrumented IR with the Rust runtime
    link_cmd = [
        str(CLANG_PATH), instrumented_ir,
        "-Wl,-force_load", str(rt_lib),
        "-isysroot", "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",
        "-lpthread", "-ldl",
        "-o", args.output
    ]
    run_cmd(link_cmd, f"Linking instrumented IR with {rt_lib.name}")

    print(f"\n[+] Success! Executable generated: ./{args.output}")

if __name__ == "__main__":
    main()