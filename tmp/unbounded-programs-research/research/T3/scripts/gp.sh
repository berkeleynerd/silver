#!/bin/bash
# usage: gp.sh DIR MODE [extra gnatprove args]   (DIR/main.adb must exist)
S=/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T3
G=/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/bin
B=/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gprbuild_26.0.1_e3f27f25/bin
P=/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/image-tools/bin
D=$1; M=$2; shift 2
cp $S/rt/* $D/; cp /home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/program-jjR2SY/program.gpr $D/
mkdir -p $D/obj $D/bin
cd $D
env -u GPR_PROJECT_PATH -u ADA_PROJECT_PATH -u GPR_CONFIG PATH=$P:$G:$B:/usr/bin:/bin python3 $S/scripts/run.py $D/gp_$M.txt $P/gnatprove -P $D/program.gpr -U --mode=$M --report=all --warnings=continue --checks-as-errors=on --level=2 --prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000 -j0 --no-loop-unrolling "$@"
