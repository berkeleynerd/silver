# Selected literal RTL caches and fixed controls

2026-10-19, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). This source join
closes the selected post-prefix `CONST_INT` and `reg_attrs` hash lifetimes,
including their incoming histories and non-lookup mutation paths. It also
closes five additional fixed RTL control registrations. It builds on the
accepted [named later transfer](retained-literal-later-shared-storage.md);
the full scalar-finalizer endpoint still requires the separate type/alias
family described below. No admission or aggregate implementation is changed.

For a completely recognized source with C>=1 literal calls and N>=0 nulls:

| Family | Historical insertion ceiling | New shared GGC backbones | Registrations added here |
| --- | ---: | ---: | ---: |
| CONST_INT | `39257+120+C` | `C` | 0 |
| reg_attrs | `39257+3C` | `3C` | 0 |
| Dummy/Main RTL pools, temporary-address table, frame tables | Separate fixed states below | 0 | 5 |

These are RTL caches; the original tree INTEGER_CST/type tables remain
separate owners. The **new disjoint GGC backing allowance is 4C**. The first target setup's
121 integer-cache backbones remain inside its existing 437-event envelope.
The 120 setup CONST_INT candidates, C operation candidates and 3C register
attribute records also retain their existing direct-object owners. None is
added again. This packet supplies individual cache request ceilings; it does
not sum RAM or complete the compiler's total-event ledger.

## Scope and incoming history

Use the retained Linux x86-64 SysV generic-target O0 literal compile class,
with the reviewed native `-fsplit-wide-types` option, no debug/instrumentation,
plugin, PCH, LTO, function-specific target/optimization overrides, altered
ABI/argument accumulation, or reinitialized target context. The complete
source recognizer and current ASCII/HT/CR/LF spelling rule apply. The existing
signed String-length premise remains explicit. These are source/installed-
behavior premises, not a claim that production already selects this proposal.

The accepted pre-Main witness starts the GGC allocation counter at zero and
retains **39,257 positive events**, no negative event, wrap or reset. Its
fixed-prefix source projection is already established by the original shared
argument. Every new hash entry in either cache needs a positive GGC object
allocation (`emit-rtl.cc:424–443,525–542`), so complete historical insertions
before the variable program are bounded by 39,257, including removed entries.
This includes startup before gigi; no empty incoming cache is assumed.

Both cache controls are created in `init_emit_once` with request37, selecting
prime61 (`emit-rtl.cc:6355–6367`). That call and the initial `init_emit_regs`
belong to `backend_init` before the retained prefix cut
(`toplev.cc:1830–1851`). New original Main/String/helper trees, filename and
location metadata, GIMPLE/SSA and graph objects do not supply a hidden RTL
cache entry: their accepted constructor routes produce trees/tuples/metadata.
Tree-pool SYMBOL_REF/MEM creation uses existing declarations and attributes,
not reg_attrs or integer RTL constants (`varasm.cc:3720–3786`). Integer output
from the bounds initializer is included in the C operation term regardless
of whether a particular pool is emitted before or after Main expansion.

The first `initialize_rtl` occurs after that prefix. Its separate accepted
source projection supplies 120 possible non-saved integer values and at most
121 hash backbones; its 437 events must not be used as an empty-cache seed.
Adding all 120 candidates and the complete C operation demand to the prefix
gives the first row above. The 120 and 121 are retained source bounds, not the
310-event setup witness or its sampled table sizes.

## CONST_INT: complete selected consumers

`gen_rtx_CONST_INT` returns directly from the saved `[-64,64]` array before
the insertion-capable hash lookup (`emit-rtl.cc:525–542`). The selected
single-coefficient target does not allocate a polynomial-integer cache.

The fixed cost probes create only the accepted union of powers `2^7..2^63`
and shift amounts65..127: 120 candidate entries. There is no collection
inside that setup. A possible first compaction/growth plus at most one
further growth per new entry gives the already-owned 121-backbone bound.
Repeated hits in the fixed mode loops do not each allocate: after expansion
the table is below its growth threshold, and no collection restores tombstones
inside that interval. The source/layout and witness arguments are retained in
the existing first-RTL packet; they are not rerun here.

The accepted [operation constructor argument](retained-native-expansion.md#literal-output-selected-rtl-constructor-lifetimes)
has one possible non-saved upper-bound constant per output call. Each emitted
bounds initializer has lower bound1 and its literal length as upper bound
(`varasm.cc:5535–5549`). Charge C insertion-capable lookups even when literals
are short, repeated, or share a pool entry. The String bytes use direct string
serialization, so character count does not introduce per-character CONST_INTs.
The operation's other integers are saved small values, including0,8 and-1.

The reviewed [complete selected RTL shape](retained-output-rtl.md) closes the
remaining routes:

- Wide splitting substitutes two existing-width DI parts and creates no shift,
  legalization or extra move. Its offsets are0 and8. Virtual instantiation
  has no local/argument payload to rewrite; both instruction splitters have
  no selected match. No arithmetic expression is expanded.
- Alias analysis is reached. Its unique base identifier is stored directly
  in an `ADDRESS(Pmode,id)` operand, not a CONST_INT
  (`alias.cc:1389–1394,1598,3280–3315`). The selected symbol and register moves
  propagate existing bases; they do not synthesize arbitrary integer RTL
  values. This statement does not exclude the separate tree-type/alias-set
  construction routes.
- IRA/LRA operate on whole-DI symbol/register moves and direct calls. The
  reviewed assignment has no spill, reload instruction, address legalization,
  register-mode change, inheritance or call-save split. The LRA scaled-address
  constructor sites (`lra-constraints.cc:677,3656`) have no selected scaled
  address. Register/CFG/DF indexes are scalar fields, not CONST_INT entries.
- The frame has push RBP, move RSP to RBP, pop RBP and simple return, with
  fixed8/16-byte offsets. Its seven pattern and three note/data objects use
  saved constants; the prior frame result explicitly exports zero new
  CONST_INT/SIMPLE_RETURN objects. Nonleaf status adds no local payload.
  CFI uses scalar register/offset records. The CONST_INT constructors in
  `dwarf2cfi.cc:249–317` belong to unselected builtin expansion, not ordinary
  CFI emission. No final template splits the selected patterns.
- Unit bounds output is already the C row; string output, direct symbol
  relocation and final byte/offset formatting add no integer RTL object.
  No source body for either output routine is compiled in this invocation.

The cache pointer is private to `emit-rtl.cc`. Its complete explicit references
are declaration, initialization and the one lookup. There is no selected
`empty`, resizing `traverse`, reserve/resize or replacement call. PCH restoration
and target reinitialization are excluded by the selected configuration. Thus
post-prefix non-lookup backbone demand is **zero**. Collection can remove a
cached value; each subsequent selected lookup is already charged, so no warm
cache assumption is needed outside the fixed setup.

## reg_attrs: calls, copies and mutation lifetime

`get_reg_attrs` returns null for the default `(decl=null,offset=0)` before its
lookup. Every other invocation makes one insertion-capable lookup and at most
one16-byte record (`emit-rtl.cc:424–443`). There are two selected consumers:

1. `set_decl_rtl` assigns each of C descriptor declarations one TI REG. Its
   declaration setter invokes `get_reg_attrs` once. Function and pool RTL are
   MEMs, not REG/CONCAT/PARALLEL values; their assignment takes no attribute
   lookup (`emit-rtl.cc:1412–1470`). Main has no formal or result parameter.
2. `decompose_register` calls `gen_reg_rtx_offset` for two DI parts of each
   descriptor (`lower-subreg.cc:618–645`; `emit-rtl.cc:1277–1311`), adding2C
   calls. Both offsets are bounded by8. Even an offset-zero hit is charged.

The other APIs are excluded by actual selected routes. Argument extraction
uses raw pseudo construction rather than the attribute-copy helper; the
accepted operation inventory leaves those extraction/hard-argument attributes
unset. The later register scan that propagates attributes is called from CSE,
whose gate is false; its setter is at `reginfo.cc:1127–1128`, not a DF scan.
Combine/GCSE/store-motion/loop-invariant callers are gated out, and other-target
callers are absent. Incoming/debug parameter routes are absent. All SUBREGs
are resolved before allocation, so `simplify_subreg`/final `alter_subreg` cannot
create a late hard-register attribute copy. The reviewed LRA route adds no
replacement instruction or pseudo except its unused attribute-free fixed
scratch REG. IRA/LRA copy assignments, if reached, copy the existing
`REG_ATTRS` pointer (`ira-emit.cc:344`, `lra.cc:205`); they do not intern a record.
No mode-adjustment caller is selected.

This exhausts the entry API at **3C lookup calls**, hence at most3C new records
and3C backbones. Fixed target probes use raw REG objects without declarations;
they add no register-attribute lookup. The static table's only explicit
non-lookup mutation is `init_emit_regs::empty` (`emit-rtl.cc:6256`), which occurs
in the fixed prefix. The unchanged target/options prevent a later invocation.
There is no other resizing traversal/reset. The full later non-lookup demand
is therefore zero, not an unspecified input to a generic hash helper.

For both weak caches, generated marking and `gt_cleare_cache` only walk entries,
mark them or `clear_slot`; they do not call resizing `traverse`
(`hash-table.h:1240–1260,1304–1321`). The accepted collector effect argument
also covers their removal/destruction. Tombstones and reinsertion are included
in the complete historical demand above.

## Capacities and fixed controls

Let `P(x)` be the first retained GCC hash prime >=x. For each historical bound H,
the allocated-slot ceiling is `P(max(61,2H))`. Initial prime61 and every later
expansion/compaction satisfy this bound; retaining all past insertions keeps it
valid after removals. Check the occupied/probe region, 64-bit load products,
unsigned probe addition and pointer-array/collector-rounding products. Each
backbone requests `8*slots` caller bytes, conservatively rounded to the next
power of two. A failed local guard remains false; no missing prime is silently
replaced. These are per-object bounds.

For Hello, both caches have slots<=131071, caller bytes<=1048568 and rounded
bytes<=1048576. CONST_INT history<=39378, reg_attrs history<=39260. The new
GGC backing allowance is four, separate from the existing setup121.

The remaining fixed controls have complete selected lifetimes:

| Control | New registrations | Existing direct owner | Entries / replacement backbones |
| --- | ---: | --- | --- |
| Dummy RTL pool hash | 1 | Dummy11 inside setup437 | 0 / 0 |
| Rooted temporary-address hash | 1 | Dummy11 inside setup437 | 0 / 0 |
| Main RTL pool hash | 1 | Real Main preparation4 | 0 / 0 |
| Prologue and epilogue hashes | 2 | Existing frame4 wrapper/backbone events | Two each / 0 |

The shared RTL pool made by `init_varasm_once` is already prefix-owned
(`varasm.cc:6965`). The dummy and real constructors each make a new pool
(`:4150–4167`). The selected cost probes and Main moves never force a constant
into the RTL pool: the payload constants belong to the distinct tree pool.
No optimized constant-pool rewrite is selected, and an empty output iteration
adds no entry, callback or replacement.

The temporary-address table is created once in dummy setup and remains rooted
(`function.cc:612,1239–1253`). Neither the probes nor Main allocate a temporary
stack slot. Calls may grow the separately owned level-pointer vector, but its
lists stay empty. `free_temp_slots` only invokes address cleanup when a slot was
made available (`:1197–1217`), so resizing cleanup traversal is not selected.
Real startup and final clean-state `empty()` see zero elements and return
without allocating. The retained wrapper48/backbone488 are reused.

Frame recording creates each table at most once, even if a recorded chain is
empty (`function.cc:5734–5747`). Here each has two machine entries in prime31;
neither reaches the3/4 threshold. The selected split/cleanup routes do not copy
frame instructions. Dummy teardown clears initially null table pointers; Main
teardown clears them only after the single emission (`:208–211`). There is no
later recorded function. Wrapper48/backbone248 each remain existing owners.

Loop-recording needs a control even for no exits, so the empty-loop argument
alone is insufficient. The first IRA equivalence loop setup uses precisely
`AVOID_CFG_MODIFICATIONS`, without the recorded-exits bit (`ira.cc:5827`).
`flag_ira_region` defaults to `IRA_REGION_ONE` (`common.opt:2253`) with no
selected override; optional setup at `ira.cc:5891` is therefore skipped.
O0 also makes `ira_conflicts_p=false`, excluding the reconstruction at5962.
The false RTL loop2 gate finalizes existing loops without creating an exit
hash; selected GIMPLE initial root setup does not request recorded exits.
Thus this configuration adds **zero recorded-loop-exit controls**. Existing
conservative direct loop envelopes are not reduced or recharged here.

DF's core/problem/scan structures, dense/sparse bitmaps, pools and worklists
use ordinary allocation. Their selected methods do not call typed GGC control
constructors; bitmap/loop/CFG records have the already-established trivial
destructors. Thus **zero DF scalar registrations** are added. This does not
remove any ordinary DF capacity or pool-counter obligation.

## Endpoint not yet closed: tree types and alias child maps

These fixed controls contribute five registrations beyond both the original
five and the named later six. They add at most five ordinary finalizer-vector
growth requests, but cannot yet be substituted as the entire residual.
`get_alias_set` continues constructing type representations at
`-fno-strict-aliasing` and may canonicalize pointer/reference types
(`alias.cc:873–880,1094–1134`). `record_alias_subset` can create a GGC child
map (`:1219`), which has its own scalar finalizer. It is not part of the
five controls above, and neither O0 nor zero user locals excludes it.

The exact next family is the selected reachable type/alias graph: establish
which canonical scalar, descriptor, bounds, pointer/reference and pool types
have known alias sets; price any pointer-cache miss and `new_alias_set` push,
alias record and child-map lifetime. That closes the missing type/alias
increments and child-control demand before a full finalizer endpoint is
claimed. No unchanged generic null-input transfer is exported by this packet:
the two cache histories and their non-lookup demands are source-derived finite
values, while these separate global endpoints remain explicitly open.

## Evidence

The [packet](../evidence/retained-literal-rtl-cache-controls-20261019/README.md)
pins the exact relevant compiler sources and accepted source/shape/effect
arguments. It uses the complete recognizer and retained fixed evidence without
replaying a native witness, aggregate, accepted component suite or corpus
checker. Focused checks cover ownership, changed-input rejection, actual-source
variants, prime boundaries, retained history and hit/removal/reinsertion
histories. They exercise the arithmetic; the source argument establishes the
selected multiplicities and exclusions.

Selected worker: GPT-6 Astra / Extra High. Runtime confirmation and token/cost
measurements are unavailable. Base `ab12e2db3756e5871467bbcb423459291a7d76bd`.
Independent frozen-commit review and aggregate attachment belong to the parent.
CLI memory was not updated. Whole native/global-counter/collector claims remain
false and total GGC events remain null.
