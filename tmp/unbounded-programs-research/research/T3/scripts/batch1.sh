S=/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T3; cd $S
for k in parens if loop elsif decls stmts concat plus; do
 ( n=100000; d=$S/p/n_${k}_$n; sz=$(python3 scripts/gen_nest.py $k $n $d); echo "$k $n size=$sz gnatc: $(timeout 1800 scripts/probe.sh $d -gnatc | cut -c1-300)" >> $S/batch1.log ) &
done
wait
echo DONE >> $S/batch1.log
