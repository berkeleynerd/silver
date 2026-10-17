S=/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T3; cd $S
full() { k=$1; n=$2; d=$S/p/g3_${k}_$n; sz=$(python3 scripts/gen_nest.py $k $n $d); echo "$k n=$n size=$sz full-O0: $(timeout 3600 scripts/probe.sh $d -O0 | cut -c1-250)" >> $S/batch3.log; }
full stmts 32000
full puts 8000
full puts 32000
full stmts 128000
full decls 100000
full puts 128000
echo DONE >> $S/batch3.log
