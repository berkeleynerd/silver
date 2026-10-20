# Round 47: solver-output gap and reviewed research stop

The [whole-#119 stop](../../research/retained-tool-capacity-stop.md) audits the
original goal and preserves the accepted native and conditional pipeline results.
The [independent review](../../reviews/review-cvc5-output-closure-20261020.md)
accepts its exact frozen input and the parser/options, diagnostic and terminal
packets. This is completion of the allowed research-stop deliverable, not a
complete capacity rule or satisfaction of the production prerequisite.

`inputs.json` names the author and review freezes. `integration-result.json`
records **29 matching frozen files, 37 retained inputs, 14 historical review
inputs at their recorded commits, 94 unchanged native pins, five Python parses
and 42 local links**. Reconciliation passed in **0.263213802 seconds**. It does
not replay component checks, native runs, solvers, compilers or proof suites.

```sh
python3 -B docs/evidence/retained-cvc5-stop-round47-20261020/check.py
```

The first integration attempt correctly found that the current capacity index
had advanced beyond the review's historical context. The checker now verifies
all historical context at its recorded commit, while requiring current author
files and native pins to match exactly. No reviewed input or pin was rewritten
to conceal the difference. The status/index and ledger updates are separate
publication records, not additional reviewed technical content.

The complete solver-output q and weighted O remain null. The recurring warning
has the conditional interface `81*K_ar(N)+L_ar(N)+D_ar(N)` with all three
prospective functions unproved; an exclusion invariant is also unproved. The
conditional six-entry terminal count does not bound its missing payload/state
terms. The stock quiet alternative is unadopted. The source evidence establishes
neither actual selected-input failure nor impossibility.

The [round ledger](../retained-tool-rounds.md#round-47--solver-output-gap-and-reviewed-research-stop)
records model selection, cost evidence, repairs and tracking. Oracle, installed
tools/pins and current admission remain unchanged. #153 stays technically open;
production #88–#94 remains unstarted; PR #121 remains draft/unmerged.
