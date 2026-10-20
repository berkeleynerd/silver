# Independent review: fixed atoms and conditional shape bounds

2026-10-20 UTC, owner-authorized #119 / #153 research.

**Accept atom target `0ec7f4b5082830501f51764bfd4652d157c31104` and
shape target `c95c01d054447b903803413b43758b72f3ce36e3` for their finite
input projection and conditional J/L transfer. Two low-severity interface
findings were repaired; no unresolved finding blocks this bounded acceptance.**
This does not complete save, counter, process or language-wide capacity.

## Exact targets, reviewer and authority

The atom target adds the [research note](../research/retained-why-fixed-session-atoms.md)
and its [packet](../evidence/retained-why-fixed-session-atoms-20261020/README.md),
14 files against `b1c0d89f7b652a1c12e957caa986887be890786e`.
The initial shape target was `79d48aa4dfe243578d09b58ef8c5d65aa571f75f`;
repair `c95c01d054447b903803413b43758b72f3ce36e3` adds explicit input checks
and explanation readiness to the ten-file
[shape result](../research/retained-why-session-shape-transfer.md).
Both streams have the same base. All 24 final target files matched their exact
Git bytes. The repair delta was inspected separately from the initial argument.

Selected independent reviewer: **GPT-6 Astra / Extra High**, as assigned by
the lead; serving-runtime model/effort confirmation is unavailable. This
reviewer authored neither input packet nor the shape argument. The isolated
review worktree is `tmp/review-fixed-shape-inputs-20261020`, branch
`review/fixed-shape-inputs-20261020`, created at the atom target. Shape inputs
were read from the author's clean worktree and checked against the final
freeze. Only this report and its review-evidence directory were authored here.

The lead supplied the owner's resumed #119 / #153 scope and active parent
harness status. The child harness returned no local goal; no status action
was taken. AGENTS, relevant Oracle requirements and review bookkeeping were
read. In particular, complete representations/source correspondence are required,
and finite retained inputs do not establish every admitted program's assurance.
No subdelegation, GitHub write, Oracle/tool/pin/admission change or CLI-memory
update occurred.

## Finite atom projection

The imported `Atoms` class and new `TypedAtoms` layer match the retained typed
layouts for term constructors, variables/symbols, patterns, lists, maps,
constants, attributes and deferred substitutions. Tlet/Teps/Tcase/Tquant
bindings include `bv_subst` values; quantifiers include triggers. All saved
proposition formulas are roots, and every proposition's identifier is added.
Types and locations do not add shape-output identifiers on the reviewed path.
Object deduplication applies to atom coverage; the copied occurrence certificate
retains formula/task/APn multiplicity and detachment flags.

The independent flat-edge check establishes exact root reachability for the
five frozen domains, with **22,477 / 17,790 / 7,744 / 1,337 / 1,545** terms.
It checks **396 / 317 / 44 / 0 / 4** deferred-value edges across distinct bind
records, and exact identifier/constant/attribute coverage. This is a stored
edge check, not another logical-opening or binder-count interpretation. Every
copied certificate equals its accepted original. No pattern or Tcase occurs
in these inputs; generic pattern handling was inspected at source level.

Immediate integers use signed tagged-word decoding. The six heap components
across Put_Line/Put retain the custom header, operations pointer, sign/size,
used limbs and unused allocation words. Each forest has values 2^62, 2^63 and
2^64; its maximum decimal length is twenty bytes. The other forests have
immediate constants with maximum decimal length four. Independent checks
reconstruct values and summary fields from the complete payloads. The retained
Zarith/OCaml layout and numeric behavior are source-family premises; matching
layout does not identify the historical installed source or prove GMP internals.
The 133/16 and 69/8 native buffer/limb-copy argument bounds have that same scope.

Attribute memberships and bytes agree with raw blocks. The union includes all
reachable term attributes, including deferred values, and all proposition-name
attributes. This supports `t_attr_copy`'s unions during opening. Per-node maxima
alone would not support that argument. Freshly cloned identifiers preserve their
original strings. Actual mutable explanation prefixes remain unknown.

The four registration forests and prior Input_Is_Valid first-inline forest keep
their distinct phases. Their accepted logical-preservation interface is reused;
addresses, auxiliary states and counters are not identified across phases.

## Conditional J/L source argument

`t_bound_shape_task` creates a fresh private printer/counter/map and selects an
ordered subset of the saved proposition list. Under the accepted interrupted-save
catch ledger, each selected proposition has at most one insertion continuation,
followed by one explanation insertion. A miss or partially committed dictionary
write does not retry that caller. All five certificates have non-detached visits.
Their total J is **32,231** across **161** APn visits, a separate domain from the
153 registered-task scheduler envelope.

The fully opened occurrence certificate bounds the term walk, including triggers
and repeated propositions. Each term/pattern output node contributes at most one
tag and one atom. Opening preserves the needed constant/name/pattern structures.
The generic Q=T*W, P=T+Q and A=B+Q allowances are conservative; actual W is zero.
ShapeTooLong and the accepted receiving catches shorten the relevant walk rather
than restart it. The bound includes complete constant output before the check.

The suffix argument covers interrupted mixfix decoding, which can choose SNword
outside `id_unique` and a quote-producing notation inside `find_unique`. In a
fresh private printer, each call can introduce at most two source keys. Positive
decimal/quote candidates at different indices are distinct; advancing crosses
at most the existing occupied keys, while retreat decreases its index. The
recurrence I_k <= I_(k-1)+2*k therefore gives I=P*(P+1), including a partially
committed base-index update. This uses the stated container/native representation
contract and private-printer frame; it assumes no arbitrary memory corruption.

Signed decimal constants, real `.p`/`e` punctuation and at-most-four-byte string
escaping agree with the SV6 formatter arms. The fresh text-only formatter adds
no newline or break/indent output. Actual captures contain integers only. With
the stated formatter/native contracts, L_t=P_t*(1+H_t) charges all append events,
including discarded output, and visit aggregation retains multiplicity:

| Forest | J per save | L, untruncated Shape-buffer bytes |
| --- | ---: | ---: |
| Put_Line | 15,925 | 3,201,881,878,432 |
| Put | 13,230 | 2,479,444,040,182 |
| First_Or_Default | 2,541 | 175,587,716,265 |
| Is_Message | 220 | 5,940,181,716 |
| Input_Is_Valid | 315 | 9,657,138,162 |

These are mathematical upper bounds, not measurements. All exported task scalar,
individual-string and 3*L arithmetic guards pass. The no-return-to-interrupted-
Buffer result and at-most-two signal-save protocol remain inherited premises for
that 3*L composition; their later-entry joins are not proved by these numbers.

SV6 inserts explanations directly into the dictionary. Their bytes therefore
belong to the separate E(p) interface, while J includes their insertion calls.
`search_attrs` returns one successful attribute list or empty, and the goal
fallback selects a proposition-name list. The complete union with u members
and s bytes supports E_one(p)=max(11,p*(s+2*u)+1). Actual p and E remain null.

## Findings and repair disposition

1. **Low, fixed — finite visit precondition was implicit.** The original
   `derive` summed all visits for J while atom J omitted detached visits. Every
   frozen visit is non-detached, so no current number was wrong; a future
   detached input could fail an incidental equality assertion. Repair
   `c95c01d054` explicitly requires non-detached visits with saved task keys,
   documents the finite-loader scope, and tests rejection of a detached visit.

2. **Low, fixed — incomplete attributes could yield numeric E(p).** In the
   original executable interface, supplying p could return numeric E from a
   partial union even when `typed_graph_complete` was false. The source claim
   already required a complete union, the join flag was false, and no complete
   capacity flag was true; all five actual inputs were complete with p unknown.
   The repair gates E on complete typed coverage with no coverage failures,
   exposes `typed_attribute_closure_established`, and adds a negative regression
   proving E remains null for incomplete coverage even with p supplied.

The repair changes no five-forest arithmetic. Exact JSON comparison establishes
that every original bound-record field is unchanged except the newly added true
attribute-readiness field. Both findings were independently confirmed and fixed
before this acceptance; neither is deferred or promoted to a medium blocker.

## Evidence, measurements and remaining scope

The [review evidence](../evidence/review-fixed-shape-inputs-20261020/README.md)
retains focused checkers and results. Atom byte/source/certificate checking took
**4.764888033 seconds**; its combined independent edge/summary verification took
**8.624755663 seconds**. The final shape source/input check took
**1.426269774 seconds** and covered 23 source ranges and 19 input identities.
Six interface regressions passed, including both repaired cases. Combined final
shape/Git/arithmetic/regression verification took **1.752185742 seconds**.
The atom check ran once; the successful opening/capture/binder/alpha analyses
were not repeated. No native target, debugger, compiler, prover, Lean, solver,
public evaluator or source fetch ran.

Inspection began at **08:09:48 UTC**; the evidence checkpoint completed at
**08:17:50 UTC**, **482 seconds**, excluding final report authoring and commit.
Actual host: Linux x86_64, kernel 7.0.14, glibc 2.43; `scripts/dev.py paths`
confirmed the isolated host-specific workspace. Token/monetary measurements
and serving-runtime model confirmation are unavailable. The selected Astra
Extra High round achieved the intended finite-input and source-bound review;
rework was confined to the two executable-interface clarifications above.

Acceptance preserves the existing relevant-source behavior relation, faithful
numeric behavior, finite valid representation, opening/freshness, native frame,
private printer/formatter, no-retry, one-worker and selected scheduling/signal
premises. Required later-entry configuration joins, entry Buffer state, remaining
formatter/container/allocation/serialization capacities, explanation prefixes,
saved-artifact invariants, diagnostic/counter owners and successor work remain
unresolved. No whole-save, whole-identifier-counter, deterministic future-forest,
whole-pipeline or current-language universal assurance follows. #119 and #153
remain incomplete.
