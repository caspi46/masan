#!/usr/bin/env python3

import os
import re
import subprocess
import sys

# -----------------------------------------------------------------------------
# 1. Resolve Pass & Runtime paths dynamically based on modification time
# -----------------------------------------------------------------------------
rel_pass = "./target/release/masan_pass"
dbg_pass = "./target/debug/masan_pass"

if os.path.exists(rel_pass) and os.path.exists(dbg_pass):
    PASS = (
        rel_pass
        if os.path.getmtime(rel_pass) > os.path.getmtime(dbg_pass)
        else dbg_pass
    )
elif os.path.exists(rel_pass):
    PASS = rel_pass
elif os.path.exists(dbg_pass):
    PASS = dbg_pass
else:
    print("[-] Error: No masan_pass binary found. Run 'cargo build' first.")
    sys.exit(1)

rel_rt = "./target/release/libmasan_rt.a"
dbg_rt = "./target/debug/libmasan_rt.a"
RT = (
    rel_rt
    if os.path.exists(rel_rt)
    and os.path.exists(dbg_rt)
    and os.path.getmtime(rel_rt) > os.path.getmtime(dbg_rt)
    else (dbg_rt if os.path.exists(dbg_rt) else rel_rt)
)

OUT_DIR = "debug_ir"


def run_cmd(cmd):
    print("[*] Running:")
    print(" ".join(cmd))
    print()

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(result.stderr)
        sys.exit(1)


def print_lifetime(ll_file):
    print("\n" + "=" * 60)
    print(f"Lifetime intrinsics: {os.path.basename(ll_file)}")
    print("=" * 60)

    with open(ll_file) as f:
        lines = f.readlines()

    found = False

    for line in lines:
        if "llvm.lifetime.start" in line or "llvm.lifetime.end" in line:
            print(line.rstrip())
            found = True

    if not found:
        print("No lifetime intrinsics found")


def print_functions_with_instrumentation(ll_file):
    with open(ll_file) as f:
        content = f.read()

    functions = re.findall(r"(define\s+[\s\S]*?^\})", content, re.MULTILINE)

    found = False

    for fn in functions:
        if (
            "__check_memory_access" in fn
            or "__poison_memory" in fn
            or "__unpoison_memory" in fn
        ):
            print("\n" + "=" * 60)
            print(fn.strip())
            print("=" * 60)
            found = True

    if not found:
        print("No MASAN instrumentation found")


def inspect_file(c_file):
    if not os.path.exists(c_file):
        print(f"[-] Error: File '{c_file}' does not exist.")
        sys.exit(1)

    os.makedirs(OUT_DIR, exist_ok=True)

    name = os.path.splitext(os.path.basename(c_file))[0]

    raw_ll = f"{OUT_DIR}/{name}_raw.ll"
    asan_ll = f"{OUT_DIR}/{name}_instrumented.ll"

    print(f"[*] Using pass binary: {PASS}")

    # -------------------------------------------------------------------------
    # Generate LLVM IR with lifetime emission flags (-O0 -disable-O0-optnone)
    # -------------------------------------------------------------------------
    clang_cmd = [
        "clang",
        "-S",
        "-emit-llvm",
        "-O0",
        "-Xclang",
        "-disable-O0-optnone",
        "-fsanitize-address-use-after-scope",
        "-g",
        "-fno-discard-value-names",
        c_file,
        "-o",
        raw_ll,
    ]

    run_cmd(clang_cmd)

    print(f"[+] Generated raw IR: {raw_ll}")

    # Inspect raw lifetime
    print_lifetime(raw_ll)

    # -------------------------------------------------------------------------
    # Run MASAN Pass
    # -------------------------------------------------------------------------
    pass_cmd = [PASS, raw_ll, "-o", asan_ll]

    run_cmd(pass_cmd)

    print(f"[+] Generated instrumented IR: {asan_ll}")

    # Inspect result
    print("\nLLVM IR AFTER MASAN PASS")
    print_lifetime(asan_ll)
    print_functions_with_instrumentation(asan_ll)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 inspect_test.py <file.c>")
        sys.exit(1)

    inspect_file(sys.argv[1])