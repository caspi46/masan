#!/usr/bin/env python3

import argparse
import subprocess
from pathlib import Path
import sys


def compile_to_ir(c_file: Path, output: Path):
    cmd = [
        "clang",
        "-S",
        "-emit-llvm",
        "-O1",
        "-g",
        "-Xclang",
        "-disable-llvm-passes",
        str(c_file),
        "-o",
        str(output),
    ]

    print("[*] Running:")
    print(" ".join(cmd))

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    if result.returncode != 0:
        print(result.stderr)
        sys.exit(1)

    print(f"[+] Generated LLVM IR: {output}")


def main():
    parser = argparse.ArgumentParser(
        description="Compile C file into LLVM IR and inspect lifetime intrinsics"
    )

    parser.add_argument(
        "file",
        help="C source file"
    )

    parser.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output .ll file"
    )

    args = parser.parse_args()

    c_file = Path(args.file)

    if not c_file.exists():
        print(f"Error: {c_file} does not exist")
        sys.exit(1)

    if args.output:
        output = Path(args.output)
    else:
        output = Path(
            "debug_ir",
            c_file.stem + ".ll"
        )

    output.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    compile_to_ir(c_file, output)

    print("\n" + "=" * 60)
    print("LLVM IR")
    print("=" * 60)

    with open(output, "r") as f:
        print(f.read())


if __name__ == "__main__":
    main()