#!/bin/bash
S=/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T3
G=/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/bin
D=$1; M=${2:--gnatc}; shift 2
cp $S/rt/* $D/ 2>/dev/null
cd $D
PATH=$G:$PATH python3 $S/scripts/run.py $D/out.txt $G/gcc -c $M -gnat2022 -gnata -gnato "$@" main.adb
