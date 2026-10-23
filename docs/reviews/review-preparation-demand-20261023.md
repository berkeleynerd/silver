# Preparation and shared-demand review, 2026-10-23

Independent bounded review for #119 / #153. **The split companion and partial
six-owner join are accepted within their stated interfaces; the printer packet
remains pending.** Research base:
`65ade88b396f456ef451d51ee3f3b9dd3dae1ae0`. Selected reviewer: GPT-6 Astra /
Extra High. Live setting confirmation and token/cost telemetry are unavailable.
The [review evidence](../evidence/retained-preparation-demand-review-20261023/)
records the exact inputs and elapsed observations. No native process, solver,
proof run, or successful predecessor checker was repeated.

## Input registration-state prereview

The historical Input_Is_Valid post-CE snapshot can supply conservative
registration-state upper bounds under the retained constructor-prefix
relation, but no-GC by itself does not prove backing monotonicity. The source
argument must include the following points.

1. Use the direct PID 97103 archive in
   `retained-why-session-save-state-20261019`, whose accepted result records
   `private_counter_and_auxiliary_values_replayed=true`. The older
   identifier-state packet is PID 74171; it must not be relabeled as 97103.
   Direct inspection confirms 97103's protected interval begins at the first
   Why3 module and remains protected through `inline_trivial_entry`, with no
   guard hits, failures or new threads. The intervening snapshots have one
   minor collection, zero completed major collections, and phase **mark=0**.
   Re's explicit startup collection precedes the protected interval.
2. `Hashcons.Make` hides the table and exports hashcons, unique, iter and
   stats. It exposes no removal, clear or reset. In the protected interval,
   neither the collector nor an API caller can delete one of its entries.
   Counter monotonicity additionally retains the accepted no-wrap prefix
   result; a positive endpoint alone would not prove no earlier wrap.
3. Each weak table starts with 5,003 outer slots and ends with 5,003. Its only
   outer-table replacement grows strictly, so no outer rebuild occurred.
   This matters: redistribution could otherwise reduce an individual bucket
   despite no loss of entries.
4. Bucket shrink tests still run without GC. Nevertheless, a first successful
   shrink is impossible here. A full bucket of size `n` grows to
   `m = min(floor(3n/2)+3, cap)` and installs an additional live entry, leaving
   at least `n+1` occupants. Its shrink threshold is
   `prev_sz(m)=((m-3)*2+2)/3`, with OCaml integer division. For the unclamped
   size, parity gives exactly `n`; clamping can only lower the threshold.
   Before the supposed first shrink, no deletion reduces occupancy. Thus
   `live > prev_sz(m)`. Empty initial buckets also fail the shrink test:
   `prev_sz(0)=-1` under truncation toward zero. Allocated weak slots and the
   maximum bucket length therefore cannot decrease along this history.
5. Rover is modular, so it is **not** monotone. Use its valid range, or the
   existing general transfer which already covers inherited oversize and
   rover state. Do not substitute the later rover as an earlier upper bound.
   Likewise, distinguish exact historical fields from the claimed earlier
   envelope; no registration observation is fabricated by subtraction.
6. `Task.Stdecl.Hcpt` is the private Ephemeron-backed owner, distinct from
   `Theory.Stdecl`. Its table uses only find and add. Find does not remove
   dead keys; cleanup occurs inside resizing, and without collection there
   are no dead entries to clean. Stored size therefore increases with add.
   Its backing begins and ends at 8,192, and has no shrink/reset caller.
   The retained stored-entry count, rather than merely live-key count, is the
   input to `ephemeron_transfer`.

R55's projected representative relation alone is insufficient to transport
these mutable fields. Its stronger source constructor-prefix relation and
R56's combined quiet/timeless/J12/logging relation must be named at the join.
For Input they transfer the registration prefix; the source lemma above then
permits the later old snapshot as an upper envelope. This does not equate
the prospective registration heap with the old post-CE heap.

The prerequisite source argument has no outstanding blocker. Acceptance of
the callable composition, its demand accounting, and remaining preparation
still awaits frozen inputs. The global allowance remains at most two
save-entering callbacks and three saves, with `e <= 2` once per process.
The complete #119 goal and production #88–#94 remain unfinished; Oracle,
tool pins and current admission are unchanged.

## Right-only split companion

**Accepted with stated premises** at
`d551c0c33ea767057fa732904faf2e1325dfe07c`, following review of initial freeze
`7993808480f46377516b6de2469ed25a6ca9f66d`. Exact packet identities appear in
`split-probe-result.json`; supplementary source sections include the
`trivial`/selection closures and quantifier branch omitted from the displayed
author excerpts. The manifest pins the complete source members.

The count proof survives constants, stop attributes and introduction
boundaries. Unit annihilation is essential in bimap; Zero counts as one
result. The ordinary right-only selection forces one factor of each reached
product to have at most one element. For disjunction the original second
positive family is the guard operand, which conservatively bounds its
selected family. Under `no_csp`, descendant case attributes write false
flags, so iff/if conditions cannot recover a hidden product. Side remains
Unit, and its exceptional Zero repair is unreachable. These facts support
both families' bounds for every prefix, including discarded intermediate
families; final positive output alone would be insufficient.

The semantic mass/slot argument accounts for each contributing input
subtree at most once in an individual result, including the extra negations
in negative iff and if alternatives. Let values and quantifier triggers
remain charged in the input semantic mass/slots even where core recursion
does not visit them. Direct opening and each complete `drop_byso` walk give
the stated `(M+1)P` registration allowance. The count of `drop_byso` calls is
per core entry, while its traversal can visit complete semantic subtrees.

One review finding required a small correction: a changed binding in
`drop_byso -> t_map` can invoke the mapper, closing wrapper and attribute
copy. The original two-entry explanation was too small. The revised text
uses four per visited node, keeps closing internals excluded, and retains
the conservative `64M^2` export. No semantic or caller-capacity claim was
expanded by that repair.

The conditional `K+4PL` argument retains a necessary separation: `L` bounds
live free-variable keys, including those exposed by dequantification; it
cannot automatically be replaced by remaining bound slots. With binder-free
saved images, a surviving binding has an input origin rather than arising
inside an imported image. Core descent and a retained drop walk bound its
ancestral opening path. An outer fallback takes the original input and
discards a previously transformed result, so it does not concatenate every
drop traversal onto that lineage. Closing empties the new enclosing saved
map. Each restricted substitution adds at most `L` keys. This justifies the
conditional allowance; it supplies no missing image bound and does not
transport it across a subsequent old hashcons return.

One new independent finite interface probe passed 7,022 cases, covering
Unit/Zero/Comb, flags, stop/introduction boundaries, both families, visible
temporary masses/slots and opening charges. Removing right-only selection
gave 400 positive results for an input of mass 79, confirming guard
sensitivity. These finite cases are regression evidence, not the universal
argument. An initial probe attempt was stopped because its uncached shape
metadata recomputed exponentially on a deep syntax tree; caching metadata
fixed the probe, which then completed in 0.190 seconds. No predecessor
checker, target or solver was run.

## Partial six-owner shared-demand join

**Accepted as a partial conditional arithmetic interface** at
`7171f5cd4b61c4440f69e965b8018df8e22372a3`, following initial freeze
`0526d648f47d0e8030e2ac9aadbe989b65a9a5b8`. The exact packet files, dependency
identities, source excerpts and recorded arithmetic were independently
audited in `shared-audit-result.json`: 360 focused checks passed in 5.222
seconds. The author checker and all predecessor checkers were not rerun.

The four exact historical registration rows now use the stronger source
constructor relation from initialization. Equal requests, preserved scalar
hashes and sharing, and absence of clearing preserve outcomes and backing
transitions for all six owners; final task-graph equality alone would not.
Input uses the direct PID 97103 projection and the separately reviewed
upper-envelope lemma. Its displayed rover remains an endpoint observation;
the transfer consumes only justified counter, outer, bucket and slot bounds.

The initial no-wrap claim was challenged owner by owner. Every possible
increment of Hsty, Hsdecl, Hstdecl or Hstask is preceded by its actual fresh
small tag-copy record; Hcpt leaf/branch construction precedes its miss
increment. The generic hashcons physical-equality test alone would be
insufficient for an arbitrary client. Under the protected interval's retained
native/source relation, these allocations consume minor words without a
collection or pointer reset. Abandoned candidates still consume words.
`c0 + increments <= c0 + B < 2^62` therefore applies, including `c0=1`
for Hcpt. Its first signed wrap would occur after `2^62-1` increments,
which is explicitly distinguished from the zero-based owners. Ident retains
its separate accepted increment-before-allocation argument.

The new source charges distinguish constructor calls from traversals. The
metadata type charge uses the complete two-MAty **event** inventory, both
one-node ground types, rather than the number of distinct output types.
Each task-add reaches at most one Hcpt singleton/add through new_meta or
new_clone. Patricia insertion over 63-bit keys requests one leaf and at
most 63 branch nodes, including a possible fresh discrimination position.
Logical add requests do not require that insertion, so 64 per task-add is
conservative. `add_tdecl` does not execute `use_export` flattening. Unique
goal construction advances Hsdecl but does not submit a Weak.merge request.
R57 traversal counts are correctly excluded from fresh-identity counts.

Registered-root attachment uses 51/42/22/2/1 roots and three selected drivers,
with a single process-wide `e <= 2`. Adding each stage's maximum with that
same e is conservative; it does not grant extra interruptions. The accepted
three-save binder bound is imported once, and the existing 206 save/session
table applications remain a separate owner-specific result. Input charges
the complete future update/CE allowance because its initial state is only a
registration upper bound; no unmeasured post-CE delta is subtracted.

Review found one missing native-limit attachment in the initial freeze:
the source header has both profiling and ordinary Max_wosize branches.
Selecting `2^54-1` required the installed choice. The revision binds an
already accepted runtime-limit witness to PID 97103's full mapped ELF
identity and decodes the retained straight-line return at `0x9d5540`.
The tagged immediate `0x7fffffffffffff` gives `2^54-1`, selecting the branch
without a new native run or disassembler invocation. The Sys/Obj source
definitions then supply the associated array and ephemeron limits.

This acceptance does **not** establish actual state bounds through R58.
Transformation lookup may parse and clone libraries before the first named
body; `lookup_library_constructors` is therefore an earlier missing demand,
not a later suffix. All four missing vectors remain explicit, including
later preparation, request printers and other callbacks/shutdown. A supplied
vector is a caller hypothesis. Supplying all numerical vectors can make only
the six-owner conditional arithmetic flag true; whole-process headroom stays
false because their provenance and other mutable owners/native operands are
not discharged. Publication counts do not replace parser/clone constructor
counts. These boundaries are present in both the callable API and frozen
result, so the partial acceptance does not close #119.
