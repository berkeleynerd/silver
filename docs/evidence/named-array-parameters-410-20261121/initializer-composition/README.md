# Bounds-query initializer composition

Managed run `20261121T203944-26f0b795d617` passed the end-to-end test added at
`078b1ca9ba`, including exact source admission, compilation, complete application
report audit and executable output. The invoking shell was set to a 16 MiB
stack; the managed run reserved two CPUs and the application prover used one.
The test covers visible type bounds in Main Boolean initializers, Boolean array
aggregates and local Boolean initializers in both functions and procedures,
plus String/Character initialization from a named array. Callable bodies query
their array formals after entry. The retained complete native audit
remains applicable: no compiler source changed.

The first draft at `22577605c8` queried incoming formal `Data` in callable local
initializers. Those formals are installed only at body entry under the current
language rules. Its failed admission is preserved in `initializer-composition-test.log`;
the diagnostic split `20261121T203903-e251444a3ecb` isolated the two invalid
headers. The correction uses the visible type `T` there and retains `Data`
queries inside bodies. This was a fixture repair, not a compiler or language
change. Existing feature tests already reject formal reads before entry.

`inputs.json` records the identical test bytes used in the native worktree and
committed integration tree. The additional method raises the provisional full
inventory from 784 to 785 test identities; this focused pass does not replace
the final full-suite checkpoint.
