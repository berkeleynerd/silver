# Independent review: selected LRA recognition lifetime and counters

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Frozen implementation: `b341b7f33a6ce3e4f5c05683f0dcfe06596e09f4`;
implementation base: `36af6a0fa26f7af07f348de2aac29aac3fab0180`.

**Accept the named conditional recognition lifetime and retained-counter
argument; no material findings.** Creation, reuse, invalidation, recreation,
final renumbering and draining preserve the existing recognition owner.
The rounded retained-slot counters follow from inherited arithmetic premises
without a new source guard. This accepts the source theorem and fixed Hello
reconciliation, not an actual-source adapter or complete LRA capacity.

## Inputs and method

Reviewed the [source note](../research/retained-literal-lra-recognition.md)
and complete [seven-file packet](../evidence/retained-literal-lra-recognition-20261019/README.md):
both Python sources, manifest, result, check record, README and round record.
Inspected the relevant GCC API implementations, callers, counter writers,
pool operations, argument arrays and alternative handling at
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, using
`/tmp/silver-backend-compose-20261018/full-source`. Source coordinates below
count literal LF characters, including GCC form feeds.

Accepted dependencies remain the helper attachment
`71624df23244a680b3da379c655691df1d77312c`, reviewed at
`ac4694d0f7e4d53f98d304ce59db2c18ebf40004`, and helper source
`b795c8f7459d648d7e595aca414629c1eec232bd`, reviewed at
`4d7100e7fbb2e39e6fdae2cf63b6d7b657cacb71`. Their numeric335,
source/configuration and selected-route premises remain necessary. The
accepted direct layouts, four-code envelope, live peaks and shared-pool
lemma were reused without repeating those proofs or their successful runs.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned. Runtime model
and effort confirmation, token usage and monetary cost are unavailable.
Inspection/check interval: **13:25:40–13:28:11 UTC**, **151 seconds** at
one-second resolution, excluding report preparation and commit. This is
elapsed clock time, not measured model compute time. Host: Linux 7.0.14
x86_64, glibc 2.43. Review worktree:
`tmp/lra-recognition-review-b341b7f33a`.

## Lifetime and reference invariant

The map starts empty. Expansion preserves old cells and nulls new cells;
the inherited UID/tripling/capacity/byte guards cover the growth arithmetic.
The only source call to `lra_set_insn_recog_data` is the miss branch of
`lra_get_insn_recog_data`, so creation cannot overwrite a live map owner.
A negative incoming instruction-code cache sentinel is recognized before
the selected nonnegative-code branch; it is not confused with admitting
asm or special negative recognized codes.

`lra_update_insn_recog_data` removes the old register contributions and
record before recreating a changed-code record. The unchanged-code branch
copies operand locations into the code-fixed lengths. Register rebuilding
invalidates the whole old list before constructing a new one. Under the
accepted whole-DI/no-subreg shape, bitmap insertion admits one list member
per UID/register pair; repeated compatible occurrences merge. The branch
that creates incompatible duplicate register records is excluded by those
source premises. Static nonoperand lists remain empty, and the two hard
argument USEs do not enter the MEM-only extra reference traversal.

Thus each stored pseudo UID set is a subset of its two accepted instruction
occurrences. `nrefs` is its size and `freq` its stable frequency sum, including
the processed subsets during removal/setup. Stable block membership and
profile configuration are explicit premises. The pinned frequency expression
and accepted numeric argument give 1..1000 per instruction and at most
10,000,000 for its multiplication intermediate. Consequently nrefs<=2 and
freq<=2000 cover repeated rebuilds without counting historical API calls.
The separate signed 10000C hard-register usage condition remains unchanged.

The important final-phase case is handled correctly. At
`lra-spills.cc:777–782`, `SET_REGNO` changes shared RTL operands, while the
integer keys in `lra_insn_reg` remain snapshots. Subsequent full invalidation
subtracts using those stored keys at `lra.cc:1615–1622`. Self-move deletion
therefore removes the original pseudo contributions even after its operands
have become hard registers. No selected post-renumber rebuild substitutes
new hard-register keys into the old lists.

At teardown, `finish_reg_info` precedes `finish_insn_recog_data`.
The latter's list-free path does not read register metadata. Each owned list
and record is returned once; the following duplicate instruction-pool
release sees empty block state. The finished-phase rule correctly permits
dead map pointer values and forbids later use until the next initialization.
It does not assert that teardown nulls the freed map.

The 65 retained mutation-API occurrences include declarations and definitions,
not 65 distinct mutations. Their caller families preserve the invariant or
require the explicitly excluded reload/spill/asm/debug/equivalence routes.
Optional inheritance is included. Broader identifier and field searches
also checked list assignments, counter writes, pool uses and `recog_init`
callers; they exposed no selected bypass. The 26 writer-pattern matches
include two comparisons, which are harmless extra inventory entries. These
lexical inventories support the inspected source argument; they are not a
mechanized C++ call graph.

## Retained counters and small arrays

The new counters correctly count retained slots, including the unused tail:

```
recognition allocated <= 819 * ceil(M / 819)
insn-register allocated <= 2730 * ceil(10C / 2730)
0 <= free <= allocated; allocated - free = live
```

A new block requires both returned and virgin free slots to be exhausted.
All preceding slots are then live, so the accepted simultaneous-live bound
limits retained blocks even across arbitrarily many finite rebuilds. Returns
cannot increase the block count. The source stores these counters as size_t
and clears them, their lists and the block count on release.

Inherited U=M+2<=INT_MAX gives retained recognition slots<=INT_MAX+816.
Inherited 3K<=INT_MAX, K=99+5C, gives 15C+297<=INT_MAX and therefore
10C+2729<2^32. The rounded counters and their increment intermediates fit
size_t64. The selected 80/24-byte removal temporary fits int, block-local
pointer advances remain inside the accepted allocation, and the existing
no-checking/no-statistics assumptions retain their stated role. No ordinary
lifetime request total or aggregate RAM conclusion follows from this lemma.

The nonnegative-code static records and target/code alternative tables retain
their original ownership through dynamic record replacement. The selected
fixed target interval has no intervening `recog_init` cache reset. The
accepted nop<=2, ndup=0 and nalt<=35 envelope bounds static fields and all
selected location copies. Alternative setup shifts a uint64_t mask only by
0..34 and advances through at most 70 entries. Constraint scratch uses two
pointers. The two one-register hard argument USEs plus sentinel use indices
0, 1 and 2 of the 92-int buffer and a three-int heap array. These are the
named recognition operations, not all helper recursion or automatic storage.

## Evidence and disposition

Independent read/hash/record/arithmetic checks passed in
**0.33892058600031305 seconds**. They verified all eight target Git records,
17 GCC pins, 26 complete current/accepted-Git repository pins, 72 literal-LF
excerpts and operative fragments, three retained generated headers, seven
round artifact identities, both API inventories, two Python syntax trees
and four JSON records. The source/count identity and complete existing
recognition owner match the accepted fixture, whose two 367-key maps remain
entirely true.

Independent integer checks covered eight boundary cases and 16 rounding
cases. They confirmed the 819/820 recognition and 2730/2740 instruction-list
boundaries, last-safe/first-failing C values 143165556/143165557, and
last-safe/first-failing N values 286331147/286331148 at C=1. Inspection of
the pure function confirms that a false consumed premise leaves `derived`
null. Its source/configuration-join requirement remains explicit; the fixed
successful-Hello reconciliation must not be used as a general adapter.

Reused the inspected author evidence: **62 checks in
3.371710624996922 seconds**. These finite pool/state illustrations cover
repeated replacement, final renumbering, draining and deliberate mutations;
they do not mechanize the universal C++ theorem. No packet or predecessor
module, Context, evaluator or checker was executed in this review. No native
compiler/tool, target execution, build/capture, prover/solver/Lean, broad
suite, aggregate or corpus replay ran. No implementation rework is required.

No new allocation owner, source guard, GGC event, bitmap/pool charge or
finalizer is introduced. All-LRA, complete-native and whole-pipeline results
remain false; ordinary lifetime requests and aggregate RAM remain uncomputed.
An actual-source successor still needs the complete 367-guard joins and
false/null preservation. Other outer IRA interfaces, remaining LRA arithmetic,
elimination offsets and automatic storage, and production correspondence
remain open. #119 is unfinished; Oracle, admission, pins and production
#88–#94 are unchanged.

Only this report is committed. The live subthread harness goal was null.
No GitHub, root-index, session-memory or CLI-memory write was made. The lead
owns integration and the owner-requested pause; no successor work was started.
`git diff --cached --check` passed before the report commit.
