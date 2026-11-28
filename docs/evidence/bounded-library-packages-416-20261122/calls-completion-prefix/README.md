# Completion-prefix package-call resolution — 2026-11-22

Linux x86-64 focused run `20261122T180018-aaa053590a61` passed a fresh audit of
24,034 declarations, with only `propext`, `Classical.choice` and `Quot.sound`.
It used two managed workers and two Lean threads per process; evidence elapsed
time was 17.923 seconds. Logs and exact input evidence are retained.

`ApplicationPackageCallsSemantics` derives the successful callee's concrete
completion-prefix lookup and semantic routine signature. Its effect environment
maps `info.routines.take info.completed`, retaining native callee identity.
Metadata typing and executable validity establish the signature's validity;
callee safety or a final completed routine table is not a source premise.

The imported routine lookup's model equality remains explicit. Full native
interpretation, actual-expression readings, checker equality and source effect
correspondence are still required. This focused result does not close those
remaining links or establish full package assurance.
