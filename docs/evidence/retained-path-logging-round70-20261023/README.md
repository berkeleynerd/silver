# R70: library-probe paths and logging capacity

2026-10-23 UTC, Linux x86_64; #119 / #153. The
[independent review](../../reviews/review-library-probe-logging-20261023.md)
accepts the complete selected raw library-probe path provider and the selected
J12 logging formatter/channel interface. Exact author and reviewer freezes
are retained in [inputs.json](inputs.json); [check.py](check.py) binds those
bytes and their accepted providers without running a predecessor checker.

The raw-path result covers four directories and all five registered extensions,
including sexp: at most 20 candidates per lookup, each at most 167 bytes.
Routine-owned direct managed allocation is at most 870 words per lookup;
native C copies request at most 168 bytes individually and 3,188 summed bytes.
These are local representation bounds. Whole-process lookup multiplicity,
FileTags counters/tables and runtime/GC internals are not inferred from them.
The earlier diagnostic-path theorem remains unchanged.

The logging result derives at most H=Q²+4Q calls from scheduling, failure,
result-publication and physical queue traversal ownership. Each call uses a
fresh formatter; its persistent channel receives at most 1281H bytes across
the entire selected suffix. All five numeric applications fit, with maximum
31,570,245 offered bytes. The source does not flush the private formatter;
complete JSON-line delivery is not claimed. The positive-write, descriptor
lifetime and clock-service conditions are explicit required interfaces.

Review clarified exact generated-datadir attachment, callback occurrence counts
after partial mutation, and the local allocation scope before author freeze.
No unresolved material finding remains. The independent audit passed 7,508
checks in 2.819383 seconds, once. Root integration passed once in 0.226365
seconds over 33 frozen files and 94 unchanged native source pins. The installed
Why identity remains unchanged. The path author retained 12 target-free
disassembler outputs plus one exploratory invocation; integration and review
did not repeat those acquisitions. No target/compiler/solver/proof/capture
execution or successful component-checker replay occurred in integration.

Next close FileTags representation and canonical answer-file reader/parser
storage. Complete raw backend output, startup/failure, full current-grammar
coverage, checked whole-rule accounting/correspondence, useful-domain comparison
and final independent review remain #119 obligations. Accepted component
results do not establish whole-process capacity or unlock production #88–#94.

#119/#153 remain open and In progress; PR #121 remains draft/unmerged. The
harness still displays paused under the owner's separate continuation. Oracle,
tools/pins, current admission and the one global e<=2/two-callback/three-save
allowance are unchanged. Physical memory/stack/I/O sufficiency remains trusted.
Estimate remains approximately 85%, low confidence, without an ETA. Selected
author/reviewer settings and available costs are in [round.json](round.json).
CLI memory is unavailable.
