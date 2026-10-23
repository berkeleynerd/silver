# R62: selected printer demand joins shared capacity accounting

2026-10-23 UTC, Linux x86_64. This continues the owner-authorized #119/#153
work from R61. The [printer argument](../../research/retained-why-printer-demand.md)
is accepted by the [independent review](../../reviews/review-printer-demand-20261023.md)
at the exact freezes in [inputs.json](inputs.json). It bounds the six shared
owners from `Driver.print_task_prepared` entry through return or propagation
of an exception, for the retained prepared family and selected SMTv2 drivers.

The process Ident charge is `E*H*(2P+3A+2)`; the other five owners have zero
requests at this cut. The selected syntax/origin argument accounts for the
two repeated-argument rotation templates. Review found the reachable V26Par
definition guard opens formals a second time. The amended source argument
counts both openings: with F formal slots and B body slots, `2F+2B <= 2P`.
The existing numeric bound remains sufficient. This is reviewed source
reasoning, not machine-checked OCaml semantics or a whole printer theorem.

[compose.py](compose.py) joins the already episode-weighted printer vector
with R61's retained preparation vector and the unchanged R60 shared-owner API.
The new composition passed in 0.246281 seconds. All five known operand guards
fit. Two residual categories remain explicit: library constructors and other
callbacks/shutdown. Other mutable owners, private printer tables, attributes,
formatted bytes and native operands are also outside this six-owner interface;
actual whole-process headroom and whole-pipeline capacity remain false.
The process-global e<=2, two save-entering callbacks and three saves are reused
once, with no new allowance or second episode multiplier.

The independent audit passed once in 0.809270 seconds. The author's original
check and changed-source repair check remain separate in its round record.
[check.py](check.py) checks frozen identities and new-vector attachment without
replaying component checks. No native compiler, solver, capture, broad proof
audit or successful predecessor run was repeated. The unchanged Oracle,
tools/pins and current admission retain their existing scope.

Library-constructor work and the new callback/shutdown source lane continue
separately. Full current-grammar compiler/producer/required-consumer/fixed-
dependency coverage, remaining output/startup/failure interfaces, checked
whole-rule composition/correspondence, useful-domain comparison and final
independent review remain required. #119/#153 stay open and In progress;
the harness still displays paused pending its separate system/UI control.
Production #88–#94 is unstarted; PR #121 stays draft/unmerged. Estimate remains
80–85%, low confidence, not an ETA.

Research/review subthreads selected Astra / Extra High. Root live model/effort,
runtime confirmation and isolated token/cost measurements are unavailable.
See [round.json](round.json) for measured check scopes and rework. CLI memory
is unavailable and was not updated.
