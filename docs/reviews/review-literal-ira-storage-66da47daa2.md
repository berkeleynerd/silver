# Selected literal IRA storage review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept the conditional named-storage subset at
`66da47daa2c433a0872e8bbc626e0bb18850426e`; no material findings.**
There is a nonblocking source-excerpt erratum below. Acceptance covers the
named IRA graph, object, preference, cost-class, traversal, fast-color and
emit-setup storage under the stated route and inherited requirements. It
does not close numeric cost/pressure arithmetic, outer IRA helpers, remaining
LRA helpers, actual-source integration or complete native capacity.

## Exact inputs and review record

The exact inputs are the frozen
[source note](../research/retained-literal-ira-lra-ordinary.md) and complete
[seven-file evidence packet](../evidence/retained-literal-ira-lra-ordinary-20261019/README.md):
`README.md`, `derive.py`, `check.py`, `inputs.json`, `result.json`,
`check-results.json` and `round.json`. The base is
`d8e9c70e373de172280b87a1459ece88114c2eaf`. I inspected the arithmetic and
checker source, retained records, allocation-site inventory, relevant GCC
callers and imported literal-shape/bitmap/pool/GGC ownership arguments.

All **45 GCC and 19 repository** byte identities and **35 excerpt texts**
matched. Retained GCC revision is `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`,
read from `/tmp/silver-backend-compose-20261018/full-source`.
The accepted [GGC review](review-literal-native-ggc-ledger-ca4ef8d20f.md)
and [bitmap/finalizer/MEM-SSA review](review-literal-bitmap-finalizer-mem-ssa-e28fef05f2.md)
remain dependencies, not claims newly established by this packet.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned. Runtime model
confirmation, token usage and monetary cost are unavailable. Inspection ran
from **12:00:09 to 12:06:18 UTC**, **369 seconds** at one-second resolution,
excluding report preparation and commit. Host: Linux 7.0.14 x86_64.
Review worktree: `tmp/review-119-literal-ira-storage-66da47daa2`.
Only this report is committed. The lead owns integration, issue records and
publication. The live harness goal was null; CLI memory was not updated.

## Storage, callers and route exclusions

The imported extents are consistently used:
`A=4C`, `K=99+5C`, `B=2N+10`, `M=7C+5N+20`, `U=M+2`,
`P=2M+B`, with `C>=1`, `N>=0`. One root region gives at most one allocno
per referenced pseudo and one object per whole DI allocno. No selected caps,
regional propagation, shuffle or copy-construction path increases that count.
The inherited call-group shape supplies actual referenced pseudos; positivity
of an upper bound alone would not justify the sparse-set caller's nonzero
domain.

The exact allocno/object reserves evaluate signed `2*max_reg_num()` and retain
31-bit vector capacities. The packet checks both and covers the A insertions.
Preference/copy vectors reserve U; preferences can be nonempty at O0. The
single final cost pass offers one singleton preference creation per allocno,
and `ira_add_allocno_pref` deduplicates. Conflict and regional copy paths are
excluded. The four pool transfers distinguish the unknown allocno stride
from exact strides 88, 32 and 40. For allocnos, `q>=255` bounds blocks while
`q<=8191` bounds retained slots by `A+8190`; substituting 255 as the exact
packing would not be justified. Source fields fit the stated 256-byte stride
ceiling. Pool counters are size_t; no checking-ID bytes or statistics-owned
allocations are selected.

The cost-class map has the important narrower caller at
`ira-costs.cc:204`: `int size = sizeof(cost_classes_t)*max_reg_num()`.
Thus **8K<=INT_MAX** is required independently of size_t and PTRDIFF guards.
The 140-byte cost-record bound and 644-byte class record follow their actual
fields. O0 performs one cost pass. Nonnull register slots take the mode path;
null slots take the class cache and skip mode restriction. At most H=K−92
insertion-capable queries suffice, including hash expansion before a cache
hit. The prime, unsigned load/probe and individual backing guards are retained.

Target move matrices are arrays of **unsigned short**, not int:
`ira-int.h:71`, `ira.cc:1599–1601`. Each of the three matrices for an
initialized mode is at most **34*34*2=2312 bytes**. The 62 persistent cost
buffers and these matrices keep their target-setup owner. Mode aliasing does
not create another initialization charge.

No hard-cost-vector backing is selected. Detailed/hard-move construction is
optimization-gated; call-crossing and multiword tuning do not apply. The
separate live-scan allocator requires a singleton operand class. The actual
`*movdi_internal` constraints at `config/i386/i386.md:2594–2598` include the
enabled broad r/rem alternatives, for which `single_reg_class` returns
NO_REGS. Fixed RDI/RSI operands are hard registers. The conflict-cost updater
requires both cost vectors already nonnull (`ira-build.cc:3455–3457`), so it
cannot seed this storage. Empty pool wrappers still exist and are counted.
Whole-register operands exclude valid-mode obstack payload records, while
the initial chunk and K-pointer map remain counted.

The live scan offers at most two live-range creator calls per referenced
pseudo. Its repeated use loop explicitly skips pseudos, and the inherited
shape excludes pseudo live-outs, partial definitions and exceptional operand
routes. There are two point increments per scanned instruction and one per
block (`ira-lives.cc:1515,1545,1604`), supporting P. Compression only reduces
the extent; finish successors and inclusive loops retain the P+1 guard.
Sparse-set arithmetic correctly covers the unsigned pre-sizeof multiplication
and narrowed request, and dense bitmap arithmetic covers rounding and stored
bytes. The separate `C+B+1` call-sequence bound includes the stored successor.

Preorder growth, exact reverse-order/DFS reserves and optional root-region
vectors fit the stated B bounds. Reverse traversal marks before pushing,
which is the necessary argument for each block entering once. The fast
branch at `ira-color.cc:5388–5391` owns its three arrays. Emit setup owns the
24A array and empty 50-pointer reserve; `ira_emit(false)` returns before
regional move storage. `ira_destroy` releases the graph before `lra`
(`ira.cc:6074,6076`). Cached ordinary pool blocks need not have been returned
to the OS for this lifetime claim to hold.

## Ownership, evidence and excerpt erratum

Independent retained-record checks matched the four MEM/SSA extents and five
shared-pool extents, the complete source-count record and Hello's byte
identity. Hello remains `A=4,K=104,B=10,M=27,U=29,P=64,H=12`, with **47,054**
positive GGC requests owned by the earlier ledger. New GGC/scalar/array
registrations and recharged shared bitmap/ET blocks are zero. Four root
bitmap heads, 34 dead-point heads and the equivalence bitmap use their
existing generic backing owner with K/P keys. Zero new events does not mean
called DF/target/query functions have no existing owned events.

The 25 local booleans, 29 request rows, four pools, three recorded checker
input hashes and false/null broad-completion fields are consistent. Independent
integer calculations confirm the exact safe/failing pairs for the signed
8K caller, P+1 successor and unsigned sparse request:

| Guard, other count fixed | Last safe | First failing |
| --- | ---: | ---: |
| 8K signed byte caller, N=0 | C=53,687,071 | C=53,687,072 |
| P+1 signed successor, C=1 | N=178,956,965 | N=178,956,966 |
| 32+8A unsigned request, N=0 | C=134,217,726 | C=134,217,727 |

The independent hash/record/arithmetic checks took **0.019549113989342004
seconds**. One preceding scratch-script invocation failed at Python parsing;
after correcting that local syntax error, the check passed. Neither packet
code nor predecessor evaluators/checkers were executed. The author's retained
**192 checks**, 15 count cases, 4096 vector lengths, 288 pool cases and 60
prime boundaries in **0.030164259995217435 seconds** are reused.

**Nonblocking erratum:** 23 of 35 excerpt coordinate pairs do not match their
text's literal-LF positions, consistent with form-feed-sensitive line
splitting. Some snippets consequently omit the operative lines despite
their descriptive name. Full-file byte pins are correct, and independent
inspection of those pinned files supports the claims. In particular use:

| Claim | Operative literal-LF source |
| --- | --- |
| General movdi constraints | `config/i386/i386.md:2594–2598` |
| Three target matrix allocations | `ira.cc:1599–1601` |
| Fast allocation's three arrays | `ira-color.cc:5281–5290` |
| Nonnull conflict-cost update gate | `ira-build.cc:3455–3457` |
| Graph destruction | `ira-build.cc:3567–3577` |
| Destruction before LRA | `ira.cc:6063–6076` |
| Dense bitmap allocation arithmetic | `sbitmap.cc:41–54` |

The last snippet is an additional selection error: the retained
`sbitmap.cc:85–105` text concerns resize bookkeeping, not the named allocator.
Correcting excerpt selection/coordinates would improve the packet's audit
usability; this report supplies the missing source correspondence. The
retained excerpt-presence checks must not be described as checking the
semantic coverage or correctness of their line metadata.

No compiler/build/capture, solver/prover, disassembler, native census,
predecessor Context/evaluator/checker, aggregate suite or corpus replay ran.
`git diff --cached --check` passed for the report. The frozen target is unchanged.
The source reachability argument remains handwritten. Numeric cost,
frequency, preference, priority and excess-pressure arithmetic, outer IRA
equivalence/initial-value/reginfo/regstat lifetimes, remaining LRA storage,
actual-source adapter and universal correspondence remain explicit residuals.
The local conjunction alone does not establish any of those obligations.
