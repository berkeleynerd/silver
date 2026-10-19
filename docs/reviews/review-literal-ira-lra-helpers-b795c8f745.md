# Independent review: named outer IRA and LRA helpers

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Frozen implementation: `b795c8f7459d648d7e595aca414629c1eec232bd`;
base: `8af6e536d8917d432182dcb6e45e33f8d3056b7e`.

**Accept the named conditional outer IRA and selected LRA helper storage
and index argument; no material findings.** The 18 individual request
families and 31 local guards have the stated source support. The optional
inheritance path is included, and the assignment live-length bound is
correctly per pseudo. This packet supplies pure C/N arithmetic and a frozen
successful-Hello reconciliation, not an actual-source adapter or whole-pass
capacity result.

## Exact inputs and method

Reviewed the [source note](../research/retained-literal-ira-lra-helpers.md)
and complete [seven-file packet](../evidence/retained-literal-ira-lra-helpers-20261019/README.md),
including both Python sources, the manifest, retained result/check records
and round. Inspected the relevant pinned GCC callers, layouts, allocation
sites, counter operations and range creators. GCC remains
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, read from
`/tmp/silver-backend-compose-20261018/full-source`.

Accepted dependencies include the ordinary305 adapter
`aa838b8fc9f8fe038d7f3dff7044d1365687fc44`, reviewed by
`df0859818d8222b52cf7f59018bd69c69b99f463`, and IRA storage
`66da47daa2c433a0872e8bbc626e0bb18850426e`, reviewed by
`3d00f8af990f45a537f7854e8c898d5c222ee394`. The accepted shared-bitmap,
live-pool and core backing arguments remain dependencies. Their successful
evidence is reused; predecessor evaluators and suites were not replayed.
The independent IRA numeric packet is not an input to this theorem. Its
separate subsequent acceptance does not alter this target's dependency set.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned. Runtime model
and effort confirmation, token usage and monetary cost are unavailable.
Inspection interval: **12:49:55–12:53:01 UTC**, **186 seconds** at one-second
resolution, excluding report preparation and commit. This is elapsed clock
time, not measured model compute time. Host: Linux 7.0.14 x86_64,
glibc 2.43. Review worktree: `tmp/review-literal-ira-lra-helpers-b795c8f745`.

## Source route, storage and counters

The unchanged source domain supplies four distinct whole-DI pseudos per
call, one definition and one use per pseudo, no pseudo live-outs or
cross-call lifetimes, and no reload, spill, scratch, debug, copy or secondary
live-range route. These premises come from the accepted selected source
argument. They do not follow merely from `-O0` or from equal C/N values.
The extents A/K/B/M/U/P and `R=floor(3K/2)+1` agree with their prior owners.

The ordinary IRA equivalence array, temporary equivalence, common reginfo
and regstat allocations have the stated distinct lifetimes. Both max-register
recompute gates are false on this route. The null initial-value hook is
specific to the selected i386 target: the default and absence of an override
support excluding its body and allocations. With no incoming REG_EQUIV
notes, the pre-optimization list creator does not execute; the later `!optimize`
gate excludes new discovery. Empty initializer lists leave the equivalence
fields null. No selected SCRATCH reaches its record creator; the U-sized
pointer reserve remains allocated and empty.

The signed `3*k` growth intermediate is guarded before division, independently
of R and request-byte limits. For actual pre-LRA k>=2, the existing IRA
reserve exceeds k+1 and covers the single unused LRA pseudo. LRA creates
that pseudo before initializing its own register information and before
setting the new-pseudo boundary. It has no later register growth here.
Its value counter initializes every capacity slot, so R, rather than the
number of referenced pseudos, is the correct counter ceiling. The old
regstat arrays have no access for the later unused pseudo; LRA frees them
at teardown. The selected class/renumber ranges fit char/short.

The LP64 field layouts support 40-byte IRA equivalences, 32-byte temporary
equivalences, 3-byte preferences, 8/16-byte regstat records, 144-byte LRA
register records, 72-byte block records, 24-byte inheritance usage records,
12-byte assignment threads and 48-byte elimination records. The selected
one-coefficient poly-int layout and STACK_REGS field are included. The six
assignment integer arrays each have a 4K request ceiling; they are not
mistaken for one combined request. The four-entry elimination table is
process-persistent and allocated only on its cold null-pointer branch.

The pointer-equivalence hash is constructed even though it remains empty.
The primary insertion requires a changed equivalence; other insertion
sites require an existing hit. Thus its 13 slots do not grow. The selected
no-checking/no-statistics wrapper is 48 bytes, and backing is 104 bytes.
Its unsigned diagnostic lookup counters do not become new capacity owners.

Regstat's current definition/use objects are distinct members of the
accepted DF creation ceiling `D=17690C+368N+19076`. D therefore bounds their
sum as well as the individual narrowings; this is not a two-reference bound
misapplied to hard registers. The prior 600C note owner bounds death increments,
and C bounds call crossings. The local frequency argument keeps a maximum
10,000,000 multiplication intermediate and a 2,000 pre-saturation addition,
then stores at most 1,000. It leaves the separate accepted signed 10000C
LRA hard-register usage requirement intact.

`lra_simple_p` is size-dependent at `ira.cc:5746–5752`. The non-simple
selected branch can run inheritance once, so its 24K usage array and EBB,
UID and call counters are necessary and included. EBBs are disjoint groups
of the block traversal, giving at most B epochs. Negative UID markers are
safe under U<=INT_MAX. Calls start at zero per EBB and are bounded by C;
reload increments require the empty new-pseudo interval. No debug instruction
creates a usage INSN_LIST. In contrast, `has_nonexceptional_receiver` returns
at `!optimize` before allocating its worklist, independently of the simple
branch. The draft inheritance misreading is absent from the frozen argument.

## Per-pseudo assignment length and existing ownership

`lra-assigns.cc:1643–1651` sums one pseudo's range list, even when the reload
assignment interval is empty. `setup_insn_reg_info` counts current
instruction-register records in nrefs (`lra.cc:1646–1650`); its invalidation
counterpart removes those records. The accepted core owner retains nrefs<=2
for every referenced pseudo.

The complete live scan has one USE_POINT opportunity for each non-OP_IN
record at `lra-lives.cc:870–875`, or one for each OP_IN record at
`:954–960`. These cases are disjoint, including OP_INOUT. The DEF_POINT
calls only update an existing finish. `update_pseudo_point` creates at most
one range per USE_POINT, the block-boundary creator requires an excluded
pseudo live-out, and the other creator is the excluded range-copy path.
The accepted single scan therefore creates at most two ranges per pseudo.
Compression cannot increase that number or the point extent.

Each nonnegative inclusive range length is at most P+1. Hence
**2(P+1)<=INT_MAX** covers every addition and partial sum in the assignment
loop. No disjointness or guessed within-group timestamp span is needed.
The global 10C live-pool count remains a separate accepted owner. At C=5000,
N=0 the new ceiling is **140102**, and the retained author check confirms
all local helper guards pass. This removes the draft's unnecessary quadratic
restriction without weakening the per-register argument.

Point-index arrays use P; block-indexed records use B rather than merely
the number of live blocks. P+1 also covers the inclusive successors and
preference denominator. The selected shift parameter is 30. Accepted sparse
sets, both point-header arrays, bitmap elements and initial chunks retain
their existing ownership. Empty copy/reload/split/inheritance sets exclude
thread merging and spill/preference-update loops; the executed first-iteration
correctness scan still relies on the accepted whole-DI allocation argument.

The fixed reconciliation reads the exact frozen predecessor result. Both
305-entry maps must already be entirely true; this is an appropriate check
for that fixed successful fixture, not a general false/null-preserving
adapter. Complete source identity/counts, extents, LRA register/recognition
owner, DF counts, shared pool/header owners and schedule agree. The result
preserves the complete existing LRA backing record, including its still-open
scope. All 50 GGC owners remain distinct and sum to **47054**; the 56-byte
reload-equivalence owner retains capacities 146 and 292. None is recharged
or replaced. Those Hello constants are not a transfer theorem for other
source files.

## Evidence and disposition

Independent read/hash/record/arithmetic checks passed in
**0.2558266400010325 seconds**. They verified all eight target Git records,
25 accepted/base repository records, seven final artifact identities, two
Python syntax trees and four JSON records. All **36 GCC / 25 repository**
pins, **72 literal-LF coordinate/text/operative excerpts** and the retained
generated mode header matched. The i386 source tree also contained no
initial-value-hook override. Overlapping inventories are not added as a
unique-file count. Exact text presence is not itself a semantic coverage proof.

The checks independently reconciled all 18 request ceilings, the 31 local
guards, retained owners/schedule, both true305 maps, the 50-row GGC partition,
zero new charges and explicit false/null broad-scope fields. Independent
integer last-safe/first-failing calculations confirmed signed tripling,
per-pseudo length in both C and N, and the DF count in both C and N.

Reused the inspected author run: **116 focused checks in
0.1171619369997643 seconds**, covering count domains, named boundaries,
growth and one-unused-pseudo capacity, request limits, source/owner mutations
and the 5000-call comparison. Neither packet module nor a predecessor
Context/evaluator/checker was executed by this reviewer. No compiler, native
tool, build, capture, prover/solver/Lean, aggregate suite or corpus replay ran.
Finite arithmetic/interface checks do not mechanize the source theorem.

Minor locator correction: the note's regstat use-plus-set reference should
point directly to `regstat.cc:75–76`; its retained `:45–93` excerpt already
contains those operative statements. This does not affect the bound or
require implementation rework.

Full dynamic LRA recognition lifetime joins, other outer IRA/imported helpers,
remaining LRA arithmetic and automatic storage, an actual-source successor,
and whole native/producer/proof/parent capacity remain open. There is no
aggregate ordinary-memory or RAM gate, source/binary correspondence claim,
Oracle change, admission change or toolchain change. #119 remains unfinished;
production #88–#94 remains unstarted.

Only this report is committed. The live subthread harness goal was null.
No issue, root index, session memory or CLI memory was changed; the lead owns
integration and publication. `git diff --cached --check` passed before commit.
