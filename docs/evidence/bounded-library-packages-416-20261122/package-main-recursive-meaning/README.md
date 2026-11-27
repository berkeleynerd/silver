# Original Main recursive syntax and semantic checker — 2026-11-27

Focused managed run `20261127T222621-4da75140ec94` passed
`Silver.ApplicationPackageMainRecursiveMeaning` and freshly audited 37,632
imported declarations on native Linux x86-64. Actual resources were two Lake
workers, two Lean threads,8192MiB per process, guest CPUs0–1, under the shared
eight-CPU allocation. Selected proof role Astra Max; actual live model/effort
and whole-agent token/cost measurements are not exposed.

`main_recursive_meaning` now derives source-only StatementCodeAt/TailCodeAt
syntax and MainChecked for accepted original Statement/Tail readers. The
simultaneous induction uses remaining original cursor, establishing Statement
before Tail at each cursor. Every IF/ELSIF/ELSE child and every counted/array
loop body is decoded, including unreachable branches and empty ranges. Original
TailExecution determines sequential composition. Native return contracts derive
all subsequent invocation domains. No recursive decoder/checker/safety callback
remains in the final theorem.

The constructed checker uses exact combined local/package function/procedure
signatures and the native returned abstract flow. Scalar-loop binder separation
comes from native capacity guards and recursive syntax, covering nested array
loops. MainChecked.obligations derives discharge of the complete statement-list
obligation inventory. StatementCodeAt/TailCodeAt retain no semantic checker,
valid-program, effect-coverage, safety or discharge fields.

The theorem's MainScope is a local induction invariant: original name normality,
body mode, native metadata storage, declared formal modes, completed function
write masks, name source origins, private-state-before-Main ordering, original
cursor and exact callable table identities. It is preserved through original
loop-scope entry and sequential scanning. The final source endpoint must derive
these entry facts from original declaration histories. MainScope is not a new
field in SourceMeaning or an admitted-program certificate. sourceReaders keeps
the original recursive callbacks and supplies canonical primitive meanings;
its binding to actual imported native-source libraries remains the lead's
separate source-correspondence work.

All 1,648 captured local input hashes were checked. Every pre-existing captured
input matched primary3bba9b7ad19c57acf0a7184b9d9efc80d1e4a8a5; only the eight
new delivered modules were absent there. Prior baseline synchronizations are
private copies, not implementation edits. Separate retained successful domain
and checker-fold runs remain under package-main-recursive-domain and
package-main-recursive-checking. The failed local attempts are retained in the
managed history: they required explicit dictionary/record normalization,
existential-pair construction, an omitted IH argument, and recursive-definition
simplification. None changed a declared domain or native implementation.

Remaining: package-routine recursive checking and effects, initializer/routine
library and Main aggregation, original-source imported dictionary binding,
complete native/Lean assurance, regression/Rosetta reconciliation and independent
closing review. No complete capability assurance, feature completion or merge
is claimed by this focused packet.
