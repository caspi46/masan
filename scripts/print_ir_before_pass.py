import subprocess
import tempfile
import os

def run_pass_on_c(input_c, pass_so, pass_name):
    with tempfile.NamedTemporaryFile(suffix=".ll", delete=False) as tmp:
        ll_file = tmp.name

    try:
        # Step 1: compile C → LLVM IR
        compile_cmd = [
            "clang",
            "-O0",
            "-S",
            "-emit-llvm",
            input_c,
            "-o",
            ll_file,
        ]
        subprocess.run(compile_cmd, check=True)

        # Step 2: run opt with print-before
        opt_cmd = [
            "opt",
            f"-load-pass-plugin={pass_so}",
            f"-passes={pass_name}",
            f"-print-before={pass_name}",
            "-disable-output",
            ll_file,
        ]

        result = subprocess.run(opt_cmd, capture_output=True, text=True)

        print("=== IR before pass ===")
        print(result.stderr)

    finally:
        os.remove(ll_file)


if __name__ == "__main__":
    run_pass_on_c("input.c", "./your_pass.so", "your-pass")