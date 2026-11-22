# Qualified scalar native compilation checkpoint

This is partial compilation evidence, **not a successful focused run or complete
source correspondence**. Managed run `20261122T153143-329df2e65bd8` compiled
the qualified scalar model, algebra, typed expressions, denotations and array
attribute scope. Its remaining reference-helper target failed on proof-tactic
normalization, so the run did not reach a complete axiom audit. The later
reference-helper repairs and recursive array/source consumers remain pending.

The scalar source certificates were successfully compiled in the earlier failed
batch `20261122T151052-8ba9fe2e1980` and reused unchanged. The manifest records
the exact current source bytes and retained objects for the compiled subset;
these hashes support reuse, not replacement of the required fresh audit.
Both runs used Linux x86_64 with two managed workers and two Lean threads under
the shared eight-CPU allocation. The unchanged native scalar-expression unit
has canonical final-policy evidence in `../native-contract-controls/`.
