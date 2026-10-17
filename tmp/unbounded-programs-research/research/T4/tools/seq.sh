#!/bin/bash
# usage: seq.sh name:src:steps:mem:cap[:need_gb] ...   (absolute paths so cmdlines contain the scratch dir)
S=/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T4
cd $S
for spec in "$@"; do
  IFS=: read name src steps mem cap need <<< "$spec"
  need=${need:-14}
  for i in $(seq 1 15); do
    avail=$(awk '/MemAvailable/{print int($2/1048576)}' /proc/meminfo)
    # foreign heavy: proof-mode gnatprove (--mode=all) or any proof/Lean process over 3 GiB RSS, not under my scratch dir
    fp=$(ps -eo pid,rss,comm,args --no-headers | grep -E 'gnatprove|gnat2why|gnatwhy3|why3server|cvc5|z3|alt-ergo|lean|lake' | grep -v grep | grep -v "$S" | awk '($2>3145728) || /--mode=all/' | wc -l)
    lite=$(ps -eo pid,rss,comm,args --no-headers | grep -E 'gnatprove|gnat2why|gnatwhy3|why3server|cvc5|z3|alt-ergo|lean|lake' | grep -v grep | grep -v "$S" | awk '{printf "%s:%s:%dMB ", $1,$3,$2/1024}')
    echo "$(date +%T) precheck $name avail=${avail}G need=${need}G foreign_heavy=$fp foreign_all=[$lite]" >> $S/precheck.log
    if [ "$avail" -ge "$need" ] && [ "$fp" -eq 0 ]; then break; fi
    sleep 120
  done
  python3 -I $S/tools/run.py "$name" "$S/$src" "$steps" "$mem" "$cap"
done
