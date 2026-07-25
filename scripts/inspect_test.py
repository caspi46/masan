#!/usr/bin/env python3

import subprocess
import os
import sys

PASS = "./target/release/masan_pass"
RT   = "./target/release/libmasan_rt.a"
OUT_DIR = "debug_ir"

def inspect_file(c_file_path: str):
    if not os.path.exists(c_file_path):
        print(f"Error: File {c_file_path} does not exist.")
        sys.exit(1)

    os.makedirs(OUT_DIR, exist_ok=True)
    base_name = os.path.splitext(os.path.basename(c_file_path))[0]
    
    raw_ll = os.path.join(OUT_DIR, f"{base_name}_raw.ll")
    inst_ll = os.path.join(OUT_DIR, f"{base_name}_instrumented.ll")
    bin_path = os.path.join(OUT_DIR, f"{base_name}_bin")

    print(f"[*] Debugging: {c_file_path}")

    # 1. Generate Raw IR (-O0 to preserve memory ops)
    clang_ir_cmd = [
        "clang", "-S", "-emit-llvm", "-O0", "-Xclang", "-disable-O0-optnone", "-g",
        "-fno-discard-value-names",
        c_file_path, "-o", raw_ll
    ]
    subprocess.run(clang_ir_cmd, check=True)
    print(f"  [+] Raw IR written to:          {raw_ll}")

    # 2. Run Masan Pass
    pass_cmd = [PASS, raw_ll, "-o", inst_ll]
    res = subprocess.run(pass_cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"  [-] Pass failed with error:\n{res.stderr}")
        sys.exit(1)
    print(f"  [+] Instrumented IR written to:   {inst_ll}")

    # 3. Link Binary
    link_cmd = [
        "clang", inst_ll,
        "-Wl,-force_load", RT,
        "-lpthread", "-ldl",
        "-o", bin_path
    ]
    subprocess.run(link_cmd, check=True)
    print(f"  [+] Instrumented Binary built at: {bin_path}")

    # 4. Quick Diff Summary
    print("\n" + "="*50)
    print("=== MASAN CALLS FOUND IN INSTRUMENTED IR ===")
    print("="*50)
    grep_res = subprocess.run(
        ["grep", "-E", "call.*(__check_memory_access|__poison_memory|__unpoison_memory)", inst_ll],
        capture_output=True, text=True
    )
    if grep_res.stdout.strip():
        print(grep_res.stdout.strip())
    else:
        print("  ⚠️ NO MASAN CALLS FOUND IN INSTRUMENTED IR!")
    print("="*50 + "\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/inspect_test.py <path_to_failing_c_file>")
        print("Example: python3 scripts/inspect_test.py tests/stack_overflow/basic.c")
        sys.exit(1)

    inspect_file(sys.argv[1])