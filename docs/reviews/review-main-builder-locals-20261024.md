# Main contract-builder local representation review

**Accepted within the declared source partition.** Author
`0d64f5f7d18b77632146174f1777be238cc43f60` closes the new fixed local-request,
header and finite-traversal obligation for the accepted flat contract builders,
saturated closed snapshot applications, ordinary Unit replacement and their
declared failed prefixes. No material finding remains from this review.
This does not close #202/#119 or the shared-service and later-construction
obligations listed below.

The reviewed changes are the new `builder-locals/` packet and appended local
representation argument in
[retained-main-construction-demand.md](../research/retained-main-construction-demand.md).
The [receipt](../evidence/review-main-builder-locals-20261024/receipt.json)
binds all eighteen author inputs, provider/source identities and the retained
native evidence. The accepted R1 builder packet is unchanged from
`93fdabb2232e0fc7fe2fd7c39f167c1985991f5a`; its exact independent acceptance
`ed10f9ba6201024b5053a84b6595bc770b2bcfeb` is reused. Earlier bridge, kernel,
clone-caller and contract-builder arguments were not broadly rereviewed or
replayed.

## Source and native correspondence

The independent native phase reproduced all **332 complete labelled bodies**
from the existing disassembly, checked contiguous byte chunks and compared
each complete body with an executable ELF segment. This covers 212 local
helper/closure bodies and 120 fixed-arity adapters, totalling **38,376 bytes**.
It checks that the retained excerpts have not silently omitted instructions;
matching isolated instruction lines alone would be weaker evidence.

The checked bodies have only fixed immediate local heap reservations, whose
maximum is **104 bytes**, and no variable local stack reservation or direct
size-scaled allocation primitive. This bounds each constituent block by
12 payload words, well below the 64-bit header limit. The 180 inspected
literal stores at ordinary header positions have at most nine payload words;
that corroborating scan is not substituted for the conservative reservation
bound. All 24 recorded static closure tags, headers, exact extents and code
targets agree with retained ELF data. The 104-byte `reg_match` reservation is
a group of fixed objects; it is not one unaccounted variable-sized block.

Every external direct code reference has the recorded service or exclusion
disposition. Source-selected callback arguments, rather than the direct
reference list alone, supply the indirect joins. The reviewed source cuts
include finite List/Extmap callbacks for type/free-variable/effect traversal,
stored types, application prefixes and specification lists. Empty oldies and
saturation exclude pvsymbol/oldie reconstruction; same-type successful
application excludes `eff_inst` and type-changing substitution; pure closed
written fields return before recursive instantiation. Scalar masks and Unit's
empty mask list exclude nontrivial mask equality callbacks. Tuple/Wvs/table
and hashcons operations retain their explicit shared-service boundary.

The source/compiler/runtime correspondence remains the stated trusted premise,
corroborated by exact bytes. This review does not claim a machine-checked
compiler refinement or a complete generic indirect-call graph.

## Length operands and finite traversal

The independent audit found nine retained native callers, with fourteen
direct calls to `List.length_aux`. Their operands must be distinguished:

| Retained helper | Source operand and disposition |
| --- | --- |
| `Ity.its_check_args` | Type-symbol parameter list and actual type arguments; the selected Unit construction uses zero. The general concrete type frontier is at most two. |
| `Ity.its_match_args` | Actual type list, measured only on `Invalid_argument`; valid flat region/type records exclude that arity failure. |
| `Ity.its_match_regs` | Actual region list, measured only on `Invalid_argument`; flat reference records have no nested region arguments. |
| `Ity.ity_tuple` | Tuple type arguments; ordinary Unit has zero. |
| `Ity.mask_check` | Tuple type and mask lists; the non-scalar mask branch is excluded in selected `create_cty` calls. |
| `Term.ls_arg_inst` | **Logical term actuals**, measured on the `BadArity` branch. The selected construction uses the fixed two-argument equality or zero-argument tuple with matching signatures, so that failure branch is excluded. This operand is not bounded by inspecting type arguments. |
| `Term.t_tuple` | Logical tuple actuals; ordinary Unit has zero. |
| `Ty.ty_app` | Type-symbol parameters and actual type arguments; normalized selected types have arity at most two. |
| `Ty.ty_tuple` | Tuple type arguments; ordinary Unit has zero. |

In particular, the contract formal/actual lists consumed by `cty_apply` are
not type-argument lists. That source recursion consumes pairs without a
`List.length` accumulator. A seven-formal/seven-actual diagram remains closed
by the local wrapper with observed type arity zero and exactly the accepted
builder's request and owner vector. This is a partition diagram, not evidence
that a particular whole-Main input emits that contract.

For finite source records, the new recursive helpers consume proper type,
term and pattern children, list cells or finite map domains. Stored saved
images are included, including dead or shared images; their acyclic
construction-history premise is necessary. The reviewed case/quantifier
diagram retains two occurrences of one shared saved image, nested patterns,
three trigger groups including two empty groups, and an unused quantified
variable's type. Empty groups consume outer list cells even when they cause
no term visit. Free-variable cache traversal and read-only type traversal
remain distinct. The latter does not open or freshen binders.

The shape totals are mathematical witnesses, not native scalar counters and
not a claim that a failed call visits all its inputs. Structural finiteness,
fixed request sizes and the existing physical RAM/stack premise suffice here.
**Cumulative local frame/closure byte pricing is not an unfinished obligation.**
The historical `complete_native_bytes=false` flag does not change that
disposition, and no aggregate memory or stack gate is required by this review.

The export's local closure depends on the header/length predicates, the
source type-arity frontier and supported-partition flag. Independent controls
covered excessive type arity, a type variable, a partial call, promotion,
reference application and a tuple mask; none exported local closure. Tiny
predicate controls also confirmed that false header or `List.length`
representability predicates prevent closure. These controls do not create
new source admission conditions or claim giant source/ELF realizations.

## Validation, limitation and handoff

One new [independent audit](../evidence/review-main-builder-locals-20261024/audit.py)
was developed for these obligations. The initial run completed its frozen
input, source identity and native checks, then stopped on a **reviewer fixture
arithmetic error**: its expected 19 type occurrences omitted the separately
counted contract result, giving the correct total 20. The
[exact initial script](../evidence/review-main-builder-locals-20261024/audit-initial.py)
and [diagnostic](../evidence/review-main-builder-locals-20261024/initial-audit-failure.txt)
are retained. The initial command's reported wall time was 3.735351912 seconds;
the native phase was not timed separately. A focused diagnostic confirmed
the omitted occurrence, then the corrected **fixture-only run passed 28
assertions in 0.087171820 seconds** on Linux x86_64. Its
[result](../evidence/review-main-builder-locals-20261024/fixture-result.json)
records the exact corrected script. The successful source/native phase was
not rerun. No combined all-green audit invocation or initial assertion total
is claimed.

Only the new local wrapper and its unchanged builder/bridge/kernel
implementation dependencies were imported. No author/predecessor checker,
extractor, target, disassembler, compiler, prover or Lean run occurred. The
author's retained 1,466-check and later 16-check successes remain distinct
from this independent evidence.

Selected reviewer setting: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation, tokens and cost are unavailable. The captured interval was
2026-10-24 06:51:21–06:59:37 UTC, **496 seconds**, covering setup, inspection,
audit and fixture correction; subsequent report/commit work is excluded.
This is reviewer time, not whole-team time. The live harness goal was null.

The required remaining work is the actual shared Hsty/Hsity owner endpoints,
backing request sizes and hash/equality callbacks; Wvs and strong memo/lookup
services; source-derived caller/candidate multiplicities; remaining builder
families and surrounding symbol/proxy/clone construction; and later
kode/SP/WP, printing and failure continuation. These representation
obligations are not relabelled physical-resource assumptions. The complete
source-to-VC result remains open. Parent owns issue updates, integration,
publication and selection of the next bounded obligation.

There were no production, Oracle, admission or tool changes, GitHub writes,
goal writes, CLI-memory updates or merge. One global `e <= 2`, two
save-entering callbacks and three saves remain unchanged.

| Round | Selected setting | Intended outcome | Achieved result / rework | Available evidence |
| --- | --- | --- | --- | --- |
| Local-helper representation review | GPT-6 Astra / Extra High; runtime unconfirmed | Challenge call cuts, fixed request/header bounds, lengths and finite descent | Accepted; reviewer fixture total corrected from 19 to 20; native successes retained | 496 s captured interval; initial command 3.735351912 s; corrected 28-check fixture run 0.087171820 s; tokens/cost unavailable |
