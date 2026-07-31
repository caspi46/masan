#!/usr/bin/env python3

import os
import sys
import glob
import subprocess

# Paths
PASS = "./target/release/masan_pass" if os.path.exists("./target/release/masan_pass") else "./target/debug/masan_pass"
RT   = "./target/release/libmasan_rt.a" if os.path.exists("./target/release/libmasan_rt.a") else "./target/debug/libmasan_rt.a"
TESTS_DIR = "tests"
OUT_DIR = "test_lls"

def compile_test(c_file: str):
    # Determine output subdirectory structure inside test_lls/
    rel_path = os.path.relpath(c_file, TESTS_DIR)
    base_name = os.path.splitext(rel_path)[0]
    
    target_dir = os.path.join(OUT_DIR, os.path.dirname(base_name))
    os.makedirs(target_dir, exist_ok=True)

    raw_ll = os.path.join(OUT_DIR, f"{base_name}_raw.ll")
    inst_ll = os.path.join(OUT_DIR, f"{base_name}_instrumented.ll")
    bin_path = os.path.join(OUT_DIR, f"{base_name}_bin")

    print(f"[*] Processing: {c_file}")

    # 1. Generate Raw IR with preserved lifetime markers (-O1 + disable passes)
    clang_ir_cmd = [
        "clang", "-S", "-emit-llvm", "-O1",
        "-Xclang", "-disable-llvm-passes",
        "-fsanitize-address-use-after-scope",
        "-g", "-fno-discard-value-names",
        c_file, "-o", raw_ll
    ]
    res1 = subprocess.run(clang_ir_cmd, capture_output=True, text=True)
    if res1.returncode != 0:
        print(f"  ❌ Clang IR generation failed:\n{res1.stderr}")
        return False
    print(f"  ├── Raw IR:          {raw_ll}")

    # 2. Run Masan Pass CLI Tool
    pass_cmd = [PASS, raw_ll, "-o", inst_ll]
    res2 = subprocess.run(pass_cmd, capture_output=True, text=True)
    if res2.returncode != 0:
        print(f"  ❌ Masan Pass failed:\n{res2.stderr}")
        return False
    print(f"  ├── Instrumented IR: {inst_ll}")

    # 3. Link Instrumented IR with Runtime
    if os.path.exists(RT):
        link_cmd = [
            "clang", inst_ll,
            "-Wl,-force_load", RT,
            "-lpthread", "-ldl",
            "-o", bin_path
        ]
        res3 = subprocess.run(link_cmd, capture_output=True, text=True)
        if res3.returncode == 0:
            print(f"  └── Binary Built:    {bin_path}")
        else:
            print(f"  ⚠️  Linking failed:\n{res3.stderr}")

    return True

def main():
    if not os.path.exists(PASS):
        print(f"Error: Masan pass binary not found at '{PASS}'.")
        print("Run 'cargo build' or 'cargo build --release' first.")
        sys.exit(1)

    c_files = glob.glob(f"{TESTS_DIR}/**/*.c", recursive=True)
    if not c_files:
        print(f"No .c files found under '{TESTS_DIR}/'")
        sys.exit(1)

    print(f"Found {len(c_files)} test files in '{TESTS_DIR}/'\n" + "="*50)

    success = 0
    failed = 0

    for c_file in sorted(c_files):
        if compile_test(c_file):
            success += 1
        else:
            failed += 1
        print("-" * 50)

    print(f"\nFinished! All IR files saved in: ./{OUT_DIR}/")
    print(f"Successful: {success}, Failed: {failed}")

if __name__ == "__main__":
    main()