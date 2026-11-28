# Native-summary phased library safety — 2026-11-28

The focused SummaryLibrarySafety target passed with a fresh imported-declaration
axiom audit of 24,431 declarations. The index retains the exact run and verified
captured inputs. Linux x86-64 used automatic two-worker/two-thread allocation
inside CPU affinity 0–1 and 8192 MiB per process, under the shared eight-CPU ceiling.
This is partial validation, not complete source assurance or kernel replay.

`SummaryRoutineEntry` pairs the original phased routine with its native effect
summary. Its executable checker establishes complete phased initialization,
body and result checking, performs effect inference, and checks membership
inclusion of inferred reads/writes in that summary. The completion-prefix fold
constructs the same executable environment in declaration order and retains
exactly the supplied native summary table. No ordered-list equality with the
inferred summary is assumed. Duplicates and conservative extra capture cells
are supported by the checked generic extension proofs from sibling89ec90b158.

`checkSummaryLibrary_sound` derives final typing and locality, safety of every
routine over full domains, complete phased obligation discharge, the exact
native effect table, and equality with the explicit executable library fold.
This additive consumer preserves the ordinary and earlier phased consumers.
Its first focused check passed. Source-history construction of the entries,
source-effect inclusion, Main integration and final assurance remain separate
outstanding work. Selected proof role: GPT-6 Astra Max; live model/effort and
whole-agent token/cost unavailable.
