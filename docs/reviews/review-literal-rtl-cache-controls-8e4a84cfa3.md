# Selected literal RTL cache/control review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Changes requested: one material source-correspondence finding, R1
([#141](https://github.com/berkeleynerd/silver/issues/141), medium).** The
selected descriptor route performs two adjacent register-attribute lookups,
while the packet counts one. Its exported `3C` total lookup ceiling is false.
A paired-call argument can preserve the proposed `3C` record/backbone and
`4C` combined-backbone bounds; that argument must replace the invalid inference
before this frozen packet is accepted.

## Frozen inputs and review record

Target `8e4a84cfa3b513b6a0d4e02ede7e910ab12697ad`, base
`ab12e2db3756e5871467bbcb423459291a7d76bd`. The eight-file diff adds the
[source argument](../research/retained-literal-rtl-cache-controls.md) and its
[seven-file evidence packet](../evidence/retained-literal-rtl-cache-controls-20261019/README.md).
This reviewer owns only this new report, in a separate sparse worktree under
repository `tmp`. Compiler inputs are the retained full GCC source at revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime confirmation of
model/effort and token/cost measurements are unavailable. Inspection and the
completed evidence checkpoint ran **00:23:54–00:28:26 UTC**, **272 seconds**
at one-second resolution, excluding report preparation and commit. This is
reviewer wall time, not native runtime or whole-team cost. The actual host is
Linux x86-64. The subthread's live harness goal was null; the bounded lead task
provided authorization. Governing inputs were `AGENTS.md`, the unchanged
Oracle, development review bookkeeping and agent-reporting guidance, with
the lead's full-current-grammar #119 scope and the accepted selected-route,
native-operation, collector and named later-shared arguments.

All **37 compiler-source and 18 repository input identities** match the
manifest and frozen target. The retained check's three implementation identities
also match:

| Input | Bytes | SHA-256 |
| --- | ---: | --- |
| `derive.py` | 8,970 | `2128578f877cbf72830705c82bc6d43cc506f5db734890c21e46efea58f4e354` |
| `check.py` | 9,042 | `b15a6c6db272098ff68eb3cc691e2a9df1f40af788c78abdc4ed894b220b014e` |
| Source argument | 16,393 | `94be00b53714d2082cedddbda8739adfc5e6d7980ed708ba50e309bfb85b649b` |

Two additional source reads outside that manifest establish macro and flag
definitions: `gcc/tree.h`, 281,689 bytes, SHA-256
`65c8b4d692804d7cc2d5883f7f919eb027c739c35ca48b984c239c8926f80b6c`;
and `gcc/cfgloop.h`, 28,358 bytes, SHA-256
`c3d43490b4a32e3ab1534fcc9da1fcdead1007db5ae54305315019e38a6e4b17`.

No compiler, debugger, native witness, prover, Lean, aggregate Context, broad
or predecessor suite, corpus inventory, GitHub write or delegation ran in this
review. CLI memory was not updated. The lead separately filed #141.

## R1: descriptor setup makes two lookup calls

Affected source argument: lines 130–153. Affected executable transfer:
`derive.py:86–90`, especially `insertion_capable_lookups_upper=3*c`.
The retained check's "register lookup composition" assertion reproduces that
incorrect multiplicity and therefore does not independently establish it.

For each fresh non-SSA TI descriptor, `expand_one_register_var` constructs the
REG and calls `set_rtl` (`cfgexpand.cc:1930–1937`). Its initially null
`REG_EXPR` and `leader_merge(null,t)` select the declaration. The first branch
calls `set_reg_attrs_for_decl_rtl(t,x)` at line264. The non-SSA tail then executes
`SET_DECL_RTL(t,x)` at line305. `tree.h:3121` maps that macro to `set_decl_rtl`,
whose body calls `set_reg_attrs_for_decl_rtl` again
(`emit-rtl.cc:1463–1469`). Both non-null-declaration calls reach the
insertion-capable lookup in `get_reg_attrs`.

Thus descriptor setup contributes **2C actual lookups**, followed by the
accepted **2C** wide-part lookups, for **4C**. The first pair uses identical
declaration/offset keys, with no intervening collection or other cache mutation,
so it introduces at most one record. This does not by itself prove that its
second lookup allocates no backbone: `find_slot_with_hash` checks the load
threshold before checking whether the key exists (`hash-table.h:1039`).
For example, a prime 61 table with 45 live/occupied entries admits a new key
without expansion; the immediate repeated hit sees 46 occupied entries and
expands before returning the same record. This is a diagnostic table state,
not a claimed retained native observation.

The existing numeric backbone bound can be recovered without increasing the
direct record charge. If the first lookup expands, the new table has no
tombstones and live count L satisfying `2L <= slots`, with prime `slots >= 7`.
After at most one new entry,
`4(L+1) <= 2*slots+4 < 3*slots`; hence the second lookup cannot expand. If
the first does not expand, only the second can. Each adjacent descriptor pair
therefore costs at most one backbone, and the two wide-part calls cost at most
two more. This permits **3C records, 3C backbones and prefix+3C historical
insertions**, while exporting the correct **4C lookup count**. The
`CONST_INT` C backbones can then still give **4C combined new backbones**.

Required correction: follow this source route in the note, distinguish calls
from records/backbone groups in the transfer, establish same-key/no-interposed-
collection pairing and the pre-hit growth argument, refresh pinned inputs and
results, and replace the inaccurate check with targeted paired-growth cases.
Merely calling the second lookup a cache hit is insufficient. No observed
counterexample to the proposed `4C` combined-backbone ceiling was found; the
finding is an incorrect exported lookup ceiling and its missing proof step.

## Other reviewed claims

The unchanged prefix witness starts at zero and retains 39,257 positive GGC
events without reset or negative event. Each historical cache insertion needs
a positive object allocation. The `CONST_INT` history therefore correctly
retains prefix+120+C, including the accepted fixed-setup candidates and C bounds
initializers. The 121 setup backbones remain inside 437 existing events; setup
and operation records are not charged again. Saved small constants, direct
string serialization, ADDRESS alias identifiers and the selected no-spill,
no-reload RTL/frame shape support the bounded integer-consumer exclusions.

The cache pointers' explicit lifetimes support zero later non-lookup growth.
`reg_attrs_htab::empty` belongs to fixed-prefix `init_emit_regs`; default
unchanged target options do not select the later target-reinitialization route.
Weak-cache cleanup clears slots and does not use resizing traversal. Later
attribute-propagating `reg_scan` belongs to excluded CSE; selected IRA/LRA
copies preserve attribute pointers. These findings do not repair R1's missing
descriptor call.

The prime ceiling `P(max(61,2H))` accounts for retained historical capacity,
including deleted entries. Probe/product/individual-request/rounding guards
remain explicit and fail closed. The five additional scalar controls have
distinct retained lifetimes: dummy and real RTL pools, one rooted temporary-
address table, and two frame tables. Their already-owned wrapper/backbone
requests are not added again. The selected pools and temporary-slot lists stay
empty; each frame table has two entries below its prime 31 threshold. The
recorded-loop-exit exclusion uses the actual flag gates and default
`IRA_REGION_ONE`, rather than assuming an empty loop needs no table. Selected
DF structures supply no typed-GGC scalar controls.

The source note correctly leaves the type/alias family open, including the
alias-child map at `alias.cc:1219`. Five new fixed registrations are not the
complete residual. Full scalar-finalizer, type/alias, global-counter,
collector and native claims remain false; total GGC is null. No aggregate,
production admission, Oracle or trusted-tool change is present.

## Evidence and disposition

The exact retained **39 checks in 0.050183576000563335 seconds** are reused,
not rerun. Their identity and arithmetic successes remain useful, but the
incorrect lookup-composition assertion is not accepted source evidence.

A narrow independent diagnostic verified the 55 manifest identities and three
implementation identities, and checked **41,585 paired-lookup arithmetic
states**, including tombstones, first-call growth and second-hit growth, in
**0.18286494300264167 seconds**. It exercised only the local leaf transfer,
without constructing any Context. The finite arithmetic checks corroborate
the paired-call argument; they do not establish selected source completeness.
Scratch script `tmp/review-cache-controls.py`, SHA-256
`bc8f0abee6a08cc4d007d93ef4acbfa24d5266e4859fd38ca2184619dcb4a583`,
and its result remain in the isolated review worktree and are not committed
project tooling.

**Disposition: request correction of R1/#141 before acceptance.** Review of a
subsequent repair is a separate frozen-input checkpoint. This report leaves
full-current-grammar capacity #119 active and production #88–#94 unstarted.
