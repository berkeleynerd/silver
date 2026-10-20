# Round 48: supported quiet route and required output consumers

The [configuration route](../../research/retained-cvc5-quiet-route.md) and
[consumer refinement](../../research/retained-solver-output-relevance.md) are
[independently accepted](../../reviews/review-quiet-output-20261020.md) at their
exact conditional scopes. A controlled base configuration retains built-in
prover identities and drivers, adds 123 command bytes, silences CVC5 warnings
and omits statistics without disabling a proof-check option. Production has
not adopted it; stock GNATprove regenerates that base file.

Why3 still eagerly captures complete files. A prospectively established clean
ordinary pair needs at most 84 raw bytes and 64 formatted-answer bytes, with no
consecutive-answer warning. The refined JSON formula charges exceptional
occurrences separately. No actual attempts are yet assigned to the clean class;
complete q/O and the full capacity rule remain open. Historical process states
are not claimed identical under the changed command.

`inputs.json` pins both authors and their independent review. The integration
check verifies **28 frozen files, 47 retained inputs and 94 unchanged native
pins**, parses four Python files and checks 20 local links. It passed in
0.381776103 seconds without replaying component or native work:

```sh
python3 -B docs/evidence/retained-quiet-output-round48-20261020/check.py
```

The [round ledger](../retained-tool-rounds.md#round-48--quiet-route-and-output-consumer-refinement)
records review feedback, selected models and measured costs. Next work attaches
the fixed typed tasks to correct syntax templates and transfers the changed
command's prefix resource requirements. Preserve the whole-#119 requirement
matrix and global two-callback/three-save/e<=2 allowance. #119/#153 remain In
progress; production #88–#94 stays unstarted and PR #121 draft/unmerged.
