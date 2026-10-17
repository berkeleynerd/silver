S=/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T3; cd $S
run() { k=$1; n=$2; m=$3; d=$S/p/g2_${k}_${n}_$m; sz=$(python3 scripts/gen_nest.py $k $n $d); r=$(timeout 3600 scripts/gp.sh $d $m | cut -c1-60); e=$(grep -i 'bug\|overflow\|error\|Storage' $d/gp_$m.txt | head -2 | tr '\n' '|' | cut -c1-200); echo "$k n=$n size=$sz $m: $r :: $e" >> $S/batch2.log; }
for m in check flow; do
 for n in 8000 32000 128000; do run stmts $n $m; done
 for n in 2000 8000 32000; do run puts $n $m; done
 for n in 2400 9000; do run elsif $n $m; done
 for n in 3000 12000; do run if $n $m; done
 for n in 2000 8000; do run loop $n $m; done
 for n in 3000 12000; do run decls $n $m; done
done
echo DONE >> $S/batch2.log
