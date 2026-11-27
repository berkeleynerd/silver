# Package Basic checking and hidden global ranges — 2026-11-27

Focused run `20261127T223929-74f4967777b9` checked
`ApplicationPackageBasicChecking` and `ApplicationPackageHiddenSource`, including
all five new helper modules, and freshly audited 37,615 imported declarations.
Native platform: Linux x86-64. Actual allocation: two Lake workers, two Lean
threads and 8192 MiB per process on guest CPUs 0–1 under the shared eight-CPU
ceiling. Selected proof role: GPT-6 Astra Max; live model/effort and whole-agent
token/cost measurements are unavailable.

The package Basic consumer derives original source syntax, the complete package
statement checker, exact returned flow and all statement obligations. Its
inherited leaves are null/scalar assignments by the existing pure/no-argument
reader guards and empty local callable tables. Package function/procedure calls
use their original source readings, completion-order identities and existing
source-derived global layout/reset proofs. The present Basic entry theorem uses
GlobalRowsClear; it is not yet the recursive package-body theorem.

The recursive boundary is real: a caller may use `for Counter in 1 .. 2 loop
Change; end loop;` while Change writes the private package variable Counter.
Ada still changes the private state when the loop binder hides its spelling.
The native reset selects visible rows, while the fixed semantic layout must
retain the actual hidden global identity. This packet proves that omitted resets
are identities when those hidden ranges already equal their declarations. Loop
entry supplies that widening. Original condition/scalar readings cannot mention
a hidden row; all conditional outcomes, including short-circuit joins, preserve
its nonempty declared range. Both empty and nonempty loop exits preserve that
range. No source restriction, altered state identity, native edit, new semantic
certificate, or safety/checker premise in SourceMeaning was introduced.

The complete recursive invariant still needs preservation through original
assignments and calls, loop context extension, then every recursive package
statement/tail. Effects, routine/library aggregation and the final source/tool
endpoint also remain outstanding. These are focused lemmas, not complete package
assurance or feature delivery.

All 1,653 captured local input hashes were checked. The retained primary
comparison is against `51303910bac8318a1b833c1871977cc68295e7dc`; six captured
files differ there, all outside this target's imported module closure. Every
existing imported module matches; only the five delivered new modules were
absent in primary. The two preceding local failures are retained in managed
history: a function-valued match required explicit result cases, a multiline
case alternative had invalid syntax, and an already-closing simp was followed
by an extra tactic. No semantic statement or declared input domain changed.
