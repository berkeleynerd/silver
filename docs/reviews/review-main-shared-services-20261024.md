# Main shared-service representation review

**Accepted as a conditional service transfer.** Exact author
`22cdc0d78c850525c78f8c3bda05424462324f84` attaches Hsty/Hsity owners,
per-request backing bounds and callbacks, plus the selected Wvs and strong
memo reads, to the previously accepted Main builder partition. No material
finding or required repair was identified. This does not complete #202/#119,
the complete Main builder classification or source-to-initial-VC capacity.

The review target is the new `shared-services/` packet and appended argument
in [retained-main-construction-demand.md](../research/retained-main-construction-demand.md).
Local author `0d64f5f7d18b77632146174f1777be238cc43f60` and independent
acceptance `9e876592a9e1a78b124294c72ab8848423c54625` are reused. All twelve
named providers remain byte-identical to that accepted author; the research
prefix is preserved. The [source/ELF receipt](../evidence/review-main-shared-services-20261024/source-elf-result.json)
binds all 21 author packet files to the exact review target. Earlier accepted
results were read as dependencies, without replaying their checkers.

## Request and state attachment

`shared.Demand` inherits the accepted ledger, and `create_cty`/`c_app` are the
same local wrappers. `shared_export` obtains all new owner requests from
`local_export`'s unchanged accepted vector, including kernel Ident requests.
It adds no arbitrary demand-vector or certification argument. Counter
endpoints agree with that vector; the old vector and its prior obligations
remain visible. The new closure flag is about these shared-service predicates,
not automatic discharge of every earlier or later builder obligation.

Both Weak envelopes use `(outer_length, bucket_max, allocated_slots)` at the
same original cut as the incoming owner values. `allocated_slots` includes
empty and dead slots. Continuing one ledger charges all subsequent requests;
neither discarded contracts nor cache hits refund requests. The unchanged
counter and Weak functions are extracted by AST without executing their old
compose/check entrypoints. Each owner remains distinct.

For `N=S+q`, the reused bounds are
`A=max(L,floor(3L/2)+3,3N+3)` and `K=max(B,floor(3N/2)+3)`.
The inspected guards retain nonwrapping owner endpoints, pre-saturation
growth/shrink/index arithmetic, ordinary-array headers, the strict Weak
payload limit and native byte-size representability. The requested byte
bounds `8(A+1)`, `8(K+1)` and `8(K+3)` have the correct respective ordinary
array, hash-array and Weak two-extra-field overheads. They are individual
requests, not physical backing totals.

The independent mixed diagram uses two five-node type projections, five Unit
replacements, a failure on the second argument pair, and a non-tuple
constructor-membership lookup. It retains 20 Hsty, 5 Hsity and 5 Ident requests,
the distinct incoming owner values, all six constructor-membership reads and
both possible failed-prefix map additions. The failed current pair remains
charged under the accepted R1 evaluation-order envelope. Independent formula
controls cover backing guards and exact owner-limit acceptance/rejection;
missing states, malformed state values and excessive type arity do not close
the relevant interface. These are mathematical controls, not Main observations.

## Callbacks and excluded branches

The source/native callback joins hold under the stated valid immutable-record
and registered-tag premises:

- Hsty hashes direct child tags, at most two in this partition. Its equality
  receives the old shallow copy first, compares physical type-symbol identity
  before paired child identity, and therefore never traverses an arbitrary
  old type graph. A valid old record with the same symbol has the same arity.
  Different heads or constructors return false before paired-list traversal.
- Hsity receives only `Ityapp(its_unit,[],[])`. Both hash lists, both equality
  lists and purity traversals are empty. A successful old representative has
  the same Unit head, empty lists and valid purity. Non-Unit candidate and
  variable/region candidate branches are outside this selected partition.
- Tagging precedes merge and allocates fresh two/three-field records, 24/32
  bytes including headers. Physical candidate return permits at most one
  counter increment. `unique` is not selected. Hash multiplication retains
  intentional modular semantics; it is not an owner counter.
- `Weak.get_copy` copies the top-level record, not descendants. The review's
  [supplemental source excerpts](../evidence/review-main-shared-services-20261024/source-supplements.json)
  retain `runtime/weak.c:399–485`: copy size comes from that record and
  field copying preserves referenced children. Allocation retry does not
  change the immutable type record's size or introduce a client hash callback.
- Weak resize passes cached integer hashes into `add_aux` and blits entries.
  It does not hash, compare, retag or recursively rebuild inherited types.
  Bucket scanning, shrinking and rehashing use finite represented table
  dimensions under the accepted Weak invariants. The strict growth guards
  exclude full-bucket saturation and arithmetic overflow. Valid source arity
  excludes `List.for_all2`'s mismatched-list error; valid table indices and
  loop/blit bounds exclude the recorded offset/array-error branches.
- Wvs dispatches through `Term.Wvs`/`Weakhtbl.Make` to `Ephemeron.K1.Make`.
  Key comparison and hashing read existing `vs_name.id_tag`. `find` traverses
  finite chains, including dead entries, without changing table size, resizing
  or creating bucket nodes. Runtime weak clearing remains permitted; read-only
  here does not prohibit the collector's ephemeron maintenance. K1 key/data
  reads return references in fixed option wrappers. An existing `Not_found`
  outcome adds no growth request and receives no new exception allowance.
- `ts_tuple`, `its_tuple` and `fs_tuple` key zero are populated by Ity/Expr
  initialization. Their private strong memo tables expose no clearing route,
  so the selected reads cannot reach the cold constructor/`Hashtbl.add` arm.
  `fs_tuple_ids.mem` also handles non-tuple `ls_constr=1` symbols; either result
  is a finite lookup without a constructor callback or stored-size write.

Weak outer initializers are weak buckets or ordinary arrays; hash-bucket
initializers are immediate integers. Float-array specialization is not
selected. Registered child/symbol tags exclude the dummy-tag assertion arm.
No omitted branch requires an extra process owner, table-size parameter or
exception/save budget within this partition.

## Native scope and independent validation

The new [audit](../evidence/review-main-shared-services-20261024/audit.py) reads
ELF data directly. All 65 retained bodies start at their declared ELF symbols,
cover each symbol's full declared extent, have contiguous bytes, and match
the executable. The 8,576 retained bytes comprise 8,126 symbol-extent bytes
and 450 alignment bytes. It independently decodes 190 direct rel32 targets,
checks dispositions for all 25 external direct code references, and checks
the purity closure's header, extent and code pointer. Own heap reservations
are fixed and at most 152 bytes, giving the conservative 18-payload-word
ceiling for a constituent block. Tag copies are exactly 24/32 bytes.

Array/runtime interfaces, fixed adapters and allocation/collector/exception
services retain their declared boundaries. Indirect arguments are selected
by source, not inferred from a direct-edge census alone. The trusted
source/compiler/runtime correspondence remains necessary; this is neither a
compiler-refinement theorem nor a generic indirect-call-graph proof.
Finite fixed local allocations under sufficient ordinary RAM/stack discharge
this local requirement. No cumulative local byte price, aggregate resource
gate or new allocator audit is required.

The independent source/ELF phase passed **555 assertions in 2.195048 seconds**;
the subsequent [math phase](../evidence/review-main-shared-services-20261024/math-result.json)
passed **40 assertions in 0.083902 seconds** on Linux x86_64. Both passed on
their first run. The latter imports only the mathematical API and unchanged
implementation dependencies. No author/predecessor checker, extractor, native
target/service, compiler, prover, Lean or disassembler ran. The source/ELF
success was not repeated for the math phase.

The author's history remains distinct: its initial source/native phase
completed, then the diagram selector `apply_vsb_add` failed; the only checker
repair was to select the existing `formal_actual_add`. The corrected
diagram-only receipt records 20 checks in 0.050557646 seconds. The final
11 metadata/scope checks have a separate 0.815257130-second receipt, with the
earlier successful receipt retained. Neither the author nor this review
claims an initial all-green combined author invocation or an unavailable
initial assertion total.

## Precise continuation and handoff

The public operands are sufficient for this conditional partition. The actual
Main attachment must preserve the accepted populated pre-JSON provider
`e45ee72a42d6cc669e95b80c2c991cbc65fe4e73` at its own cut, then transport
Ident/Hsty/Hsity owners and allocated Weak backing through **all** intervening
`add_file`, parser, typing, proxy, overload-candidate and builder requests.
Source initialization at `(counter=0,L=5003,B=0,S=0)` is valid history, not a
replacement for the populated pre-JSON state or a new capture requirement.
No unrelated fixed-library six-owner observation is needed to fill this gap.

Reuse accepted R77 source/typed construction `ebe36e4b9c9a12cc6a5ad4fd4269f2faafeec58c`
(receipt `7ab729be0bfaf393f462f070d9a09af614c87567`, review
`6031a189e04b710a2858823b9e38165838a37079`) and R79 composition
`59e4ff13433b6c3ee3b1dc3888896db416682b1d` (review
`23fd53e56981653755565eccaa5ef2e8f1e431c5`) as source-profile providers.
Their mathematical typed occurrences and names are not native tag histories
or failed-candidate construction counts. The next attachment must supply
those native construction multiplicities and each actual incoming cut;
the present `source-joins.json` names those precise boundaries and leaves
both actual Main attachment flags false. These accepted providers were not
rereviewed or replayed here.

Other builder families, surrounding pvsymbol/clone/cold-tuple construction,
kode/SP/WP and later continuation remain open. Wvs/strong populations remain
with their source constructors; their read-only interface does not certify
those earlier populations. Production #88–#94 remains unstarted and PR #121
remains draft/unmerged. Root owns integration, publication, issues and memory.

Selected reviewer setting: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation, tokens and cost are unavailable. The observation interval
2026-10-24 07:24:45–07:31:24 UTC is **399 seconds**, covering setup,
inspection, source/ELF and mathematical checks; subsequent report/commit work
is excluded. This is reviewer time, not whole-team time. Harness goal was
null. No GitHub, goal or CLI-memory write occurred. Oracle, admission, pins,
one global `e <= 2`, two save-entering callbacks and three saves are unchanged.

| Round | Selected setting | Intended result | Achieved result/rework | Available evidence |
| --- | --- | --- | --- | --- |
| Shared-service independent review | GPT-6 Astra / Extra High; runtime unconfirmed | Challenge callback cuts, owner/backing transfer and source/provider correspondence | Conditional transfer accepted; no material finding or rework | 399 s observation; 555-check source/ELF phase 2.195048 s; 40-check math phase 0.083902 s; tokens/cost unavailable |
