#!/usr/bin/env python3

import subprocess
import os
import sys
import re

# Adjust binary paths if needed
PASS = "./target/release/masan_pass" if os.path.exists("./target/release/masan_pass") else "./target/debug/masan_pass"
RT   = "./target/release/libmasan_rt.a" if os.path.exists("./target/release/libmasan_rt.a") else "./target/debug/libmasan_rt.a"
OUT_DIR = "debug_ir"

def print_instrumented_functions(ll_file_path: str):
    """Parses .ll file and prints full function definitions containing __poison or __check calls."""
    if not os.path.exists(ll_file_path):
        return

    with open(ll_file_path, "r") as f:
        content = f.read()

    # Split into function blocks
    functions = re.findall(r"(define\s+[\s\S]*?^\})", content, re.MULTILINE)

    printed_any = False
    for fn in functions:
        if any(marker in fn for marker in ["__check_memory_access", "__poison_memory", "__unpoison_memory"]):
            print("\n" + "="*60)
            # Print function header and body
            print(fn.strip())
            print("="*60)
            printed_any = True

    if not printed_any:
        print("  ⚠️ NO MASAN INSTRUMENTATION FOUND IN ANY FUNCTION!")

def inspect_file(c_file_path: str):
    if not os.path.exists(c_file_path):
        print(f"Error: File '{c_file_path}' does not exist.")
        sys.exit(1)

    os.makedirs(OUT_DIR, exist_ok=True)
    base_name = os.path.splitext(os.path.basename(c_file_path))[0]
    
    raw_ll = os.path.join(OUT_DIR, f"{base_name}_raw.ll")
    inst_ll = os.path.join(OUT_DIR, f"{base_name}_instrumented.ll")
    bin_path = os.path.join(OUT_DIR, f"{base_name}_bin")

    print(f"[*] Debugging: {c_file_path}")

    # 1. Generate Raw IR (-O0 + use-after-scope flag to force llvm.lifetime.end emission)
    clang_ir_cmd = [
        "clang", "-S", "-emit-llvm", "-O0", 
        "-Xclang", "-disable-O0-optnone", 
        "-fsanitize-address-use-after-scope",
        "-g", "-fno-discard-value-names",
        c_file_path, "-o", raw_ll
    ]
    res_clang = subprocess.run(clang_ir_cmd, capture_output=True, text=True)
    if res_clang.returncode != 0:
        print(f"  [-] Clang IR emission failed:\n{res_clang.stderr}")
        sys.exit(1)
    print(f"  [+] Raw IR written to:          {raw_ll}")

    # 2. Run Masan Pass CLI tool
    if not os.path.exists(PASS):
        print(f"  [-] Pass binary not found at '{PASS}'. Run 'cargo build' first.")
        sys.exit(1)

    pass_cmd = [PASS, raw_ll, "-o", inst_ll]
    res_pass = subprocess.run(pass_cmd, capture_output=True, text=True)
    if res_pass.returncode != 0:
        print(f"  [-] Masan pass failed with error:\n{res_pass.stderr}")
        sys.exit(1)
    print(f"  [+] Instrumented IR written to:   {inst_ll}")

    # 3. Print complete IR function definitions
    print("\n--- FULL INSTRUMENTED LLVM IR FUNCTIONS ---")
    print_instrumented_functions(inst_ll)

    # 4. Link & test run
    if os.path.exists(RT):
        link_cmd = [
            "clang", inst_ll,
            "-Wl,-force_load", RT,
            "-lpthread", "-ldl",
            "-o", bin_path
        ]
        subprocess.run(link_cmd, capture_output=True)
        print(f"\n  [+] Compiled binary ready at: {bin_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/inspect_test.py <path_to_c_file>")
        sys.exit(1)

    inspect_file(sys.argv[1])