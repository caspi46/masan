#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parent.parent


PASS = (
    ROOT_DIR / "target/release/masan_pass"
    if (ROOT_DIR / "target/release/masan_pass").exists()
    else ROOT_DIR / "target/debug/masan_pass"
)

RUNTIME = (
    ROOT_DIR / "target/release/libmasan_rt.a"
    if (ROOT_DIR / "target/release/libmasan_rt.a").exists()
    else ROOT_DIR / "target/debug/libmasan_rt.a"
)


def run(cmd):
    print("[*] Running:")
    print(" ".join(map(str, cmd)))

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    print(result.stdout)

    if result.returncode != 0:
        print("[!] Command failed")
        sys.exit(1)

    return result.stdout


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <test.c>")
        sys.exit(1)

    c_file = Path(sys.argv[1])

    debug_dir = ROOT_DIR / "debug_ir"
    debug_dir.mkdir(exist_ok=True)

    name = c_file.stem

    raw_ir = debug_dir / f"{name}_raw.ll"
    asan_ir = debug_dir / f"{name}_asan.ll"


    # C -> LLVM IR
    run([
        "clang",
        "-S",
        "-emit-llvm",
        "-O1",
        "-g",
        "-Xclang",
        "-disable-llvm-passes",
        str(c_file),
        "-o",
        str(raw_ir),
    ])

    print(f"[+] Generated LLVM IR: {raw_ir}")


    # Run masan pass
    run([
        str(PASS),
        str(raw_ir),
        str(asan_ir),
    ])

    print(f"[+] Generated instrumented IR: {asan_ir}")


    print("\n" + "=" * 60)
    print("LLVM IR AFTER MASAN PASS")
    print("=" * 60)

    print(asan_ir.read_text())


if __name__ == "__main__":
    main()