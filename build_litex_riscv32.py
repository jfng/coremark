#!/bin/env python3
import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--toolchain",      type=str, default="vivado")
parser.add_argument("--output-dir",     type=str, default="build")
parser.add_argument("--cpu-type",       type=str, default="vexriscv")
parser.add_argument("--cpu-variant",    type=str, default="standard")
parser.add_argument("--target",         type=str, default="digilent_arty")
parser.add_argument("--litex-src-path", type=str, required=True)
parser.add_argument("--frequency",      type=float, default=125e6)
parser.add_argument("--iterations",     type=int, default=3000)
parser.add_argument("--no-build-soc",   action="store_true", default=False)
parser.add_argument("--no-build-bench", action="store_true", default=False)
parser.add_argument("--no-program",     action="store_true", default=False)
args = parser.parse_args()

litex_build = f"python -m litex_boards.targets.{args.target} \
--toolchain={args.toolchain} \
--sys-clk-freq={args.frequency} \
--cpu-type={args.cpu_type} \
--cpu-variant={args.cpu_variant} \
--output-dir={args.output_dir}/{args.target}"

if not args.no_build_soc:
    cmd = f"{litex_build} --build"
    print(cmd)
    subprocess.run(cmd, shell=True, check=True)

if not args.no_build_bench:
    cmd = f"""make \
PORT_DIR=litex_riscv32 \
BUILD_DIR=build/coremark/ \
LITEX_GEN_DIR=build/{args.target}/software/include \
LITEX_CPU_DIR={args.litex_src_path}/litex/soc/cores/cpu/{args.cpu_type} \
LITEX_INC_DIR={args.litex_src_path}/litex/soc/software/include \
XCFLAGS="-DCLOCKS_PER_SEC={args.frequency}" \
ITERATIONS={args.iterations} \
MULDIV=yes \
REBUILD=1 \
clean link port_postbuild"""
    print(cmd)
    subprocess.run(cmd, shell=True, check=True)

if not args.no_program:
    cmd = f"{litex_build} --no-compile-software --no-compile-gateware --load"
    print(cmd)
    subprocess.run(cmd, shell=True, check=True)

    print("\nDone. Execute the benchmark by running:")
    print("litex_term --serial-boot --kernel=build/coremark/coremark.bin --kernel-adr=0x40000000 <TTY device>")
