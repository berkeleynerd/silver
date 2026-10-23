# Fixed printer syntax review evidence

Bounded syntax/origin and SMTv2 recursion review for #119 / #153. See the
[report](../../reviews/review-printer-syntax-20261023.md). This is not acceptance
of the complete forthcoming printer-demand packet.

`census.py` independently reads the fourteen driver files, existing R49 module
origins, R54 metadata pointer connections, and complete R51 raw/seed/CE term
graphs. It does not import a producer model or predecessor checker.
`census-result.json` records 319 active syntax directives, 23 non-affine
directives, two attachable BV64 templates, and their only four application
records across the five processes. The single pass took 2.405027 seconds.

`source-witnesses.json` pins five complete Why3 source members and the exact
reviewed sections. `round.json` records selected settings, actual elapsed
observations, findings and unavailable telemetry.

Recorded invocation:

```
python3 -B docs/evidence/retained-printer-syntax-review-20261023/census.py \
  /home/canto/src/github.com/berkeleynerd/silver/tmp/retained-tool-capacity \
  8ab048af2bcb654ee2ead354d8737c7279b76856
```

The input checkout must contain the exact frozen files. The script checks
them against Git, without replaying their generating programs. Repetition of
this successful check is unnecessary unless an input changes or a specific
unresolved concern requires it. R60/R61 evidence is unchanged.
