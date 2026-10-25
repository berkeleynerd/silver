# Near-term Rosetta assessment reconciliation

Date: 2026-10-25. Work: [#225](https://github.com/berkeleynerd/silver/issues/225).
Review base: `e1f6f9a53b4268fc1181526540c30759e382eb44`, the repaired head of
[PR #221](https://github.com/berkeleynerd/silver/pull/221). This reconciles the
three excluded #9 assessments and ten previously stage-2 assessments following
the [external review](../docs/reviews/review-pr221-6a70c241db.md). It is a targeted
planning correction, not a corpus-wide reassessment or sample delivery.
Original task revisions and assessor attribution remain in `coverage.json`;
the new `review` fields identify this pass separately.

## Selection and authorization

Select the five finite current-language regressions in
[#226](https://github.com/berkeleynerd/silver/issues/226) as the next proposed
delivery: Compile-time calculation, Loops/N plus one half, Enforced immutability,
Literals/Integer, and Minimum number of cells after, before, above and below NxN
squares. They give useful combinations of existing constants, loops, arithmetic,
assignment and output with modest, exactly specified execution results. All five
fit the current 4,096-byte source bound without a language or assurance-rule
change. The selected sources and independently derived expected bytes are
retained in [candidate evidence](../docs/evidence/rosetta-assessment-20261025/candidates.json).

The owner's current instruction authorizes this assessment and selection pass.
The live board has no unstarted, unconditionally authorized implementation item:
#9 is In review, and the remaining construct stages are Backlog. Thus #226 is a
concrete selection for the next implementation decision, not a claim of new
authorization. #9's original 31-task scope remains fixed. Its PR remains open;
neither this pass nor the review's merge recommendation merges it. The
[dated decision](../docs/session-memory.md#2026-10-25--rosetta-assessment-reconciliation-and-next-increment-selection)
records the owner's exact instruction and this boundary.

| Alternative | Benefit and cost relevant to selection | Decision |
| --- | --- | --- |
| Five finite existing-language samples | Faithful reviewed approaches, small exact outputs, no new admission/composition rule; still requires complete sample-delivery validation. | Select #226 next. |
| Integer sequence | Existing language expresses the task-permitted Integer limit, but a complete run emits over 24 GB. | Keep language eligibility; exclude from this batch. |
| Named Integer subtypes | Reusable constraints are useful, but do not create a distinct type; one possible task analogue does not by itself justify the next assurance investment. | Retain as a future scope candidate. |
| Distinct static Integer types | Directly matches Define a primitive data type; requires nominal typing and base-range/first-subtype assurance. | Concrete future alternative, not authorized. |
| Scalar guard refinement or integer division | Broader numerical value; refinement enables safe self-updates without requiring conversions, while division needs zero and signed-overflow rules. | Compare with concrete drivers in a later construct-scoping decision. |

Old broad construct occurrence counts are not a dependable cost/yield estimate.
This pass introduces narrow unsupported identifiers only for the reviewed
approaches; it does not split all other broad corpus assessments. The greedy
renderer therefore places several small new features late. Those stage numbers
are a generated mapping, not an implementation priority or authorization.

## Dispositions

The five existing `supported` identifiers are unchanged. Six assessed approaches
move to stage 1; this means language eligibility, not delivered regressions.
The stage now contains 38 assessments after removing the three disputed entries.

| Task and retained revision | Reconciled disposition |
| --- | --- |
| [Compile-time calculation](c/compile-time-calculation/task.wiki), 403674 | Current immutable Integer arithmetic and Image; Ada-static grouped 10! product, with compile-time limitations explained. |
| [Integer sequence](i/integer-sequence/task.wiki), 404486 | Current Integer range loop and Image, using the full `1 .. 2147483647` implementation limit. Execution disposition below. |
| [Loops/N plus one half](l/loops/n-plus-one-half/task.wiki), 411531 | Current counted loop, comparison, Put and Image; the last iteration emits its number and skips its comma. |
| [Enforced immutability](e/enforced-immutability/task.wiki), 414182 | Current String/Integer constants, immutable loop index and independent mutable copy. Commented invalid writes are explanatory, not executed negative tests. |
| [Literals/Integer](l/literals/integer/task.wiki), 412883 | Current numeral syntax covers bases 2–16, both delimiters, separators, nonnegative exponents and signed endpoints. `7#1#E3` is 343, not 727. |
| [Minimum cells](m/minimum-number-of-cells-after-before-above-and-below-nxn-squares/task.wiki), 406018 | Compute all 100 minima with two loops and a mutable `0 .. 9` object. Every RHS independently fits that range; no scalar guard refinement is assumed. |
| [Here document](h/here-document/task.wiki), 411758 | Native heredoc syntax conflicts with the unchanged fixed-edition language. Multiline output is possible, but is a different feature. |
| [String interpolation](s/string-interpolation-included/task.wiki), 413061 | Future `fixed-string-replacement` candidate under the captured primary Ada answer's library interpretation; no claim that concatenation supplies interpolation. |
| [Rubik's Magic Simulation](r/rubiks-magic-simulation/task.wiki), 415559 | Design pending, with no stage. Neither a required construct set nor an Oracle conflict is established. |
| [Unicode variable names](u/unicode-variable-names/task.wiki), 413955 | Future Unicode identifiers and scalar guard refinement; current ASCII exclusion is not an Ada/SPARK prohibition. |
| [Topic variable](t/topic-variable/task.wiki), 405498 | Future assignment target name `@`, with its limited assignment-local meaning explained. An ordinary object named `It` supplies no special topic semantics. |
| [Variable size/Set](v/variable-size/set/task.wiki), 413114 | Future confirming Integer object Size clause; the task accepts a variable or type, so no new type, conversion or Size read is necessary. |
| [Define a primitive data type](d/define-a-primitive-data-type/task.wiki), 412738 | Future distinct static integer type with initialized same-type objects. Conversions, loops and Image are unnecessary for this selected driver. |

### Task fidelity and inherited meanings

**Heredocs.** The [captured Ada answer](h/here-document/ada.wiki) calls its
alternative a workaround. [Ada RM 2.6](../references/ada/2022/RM-2-6.html)
prohibits line endings within string literals. Adding native heredoc authoring
syntax would violate the Oracle's subtractive-source rule under its fixed
editions. The exclusion does not prohibit equivalent output.

**Interpolation.** The [primary Ada answer](s/string-interpolation-included/ada.wiki)
uses `Fixed.Index` and `Fixed.Replace_Slice`. We explicitly adopt its reading
that a standard library replacement can perform the substitution without an
application-written interpolation routine. The fixed template puts the marker
at positions 12–15, so `Replace_Slice` alone suffices for this example.
[RM A.4.3](../references/ada/2022/RM-A-4-3.html) defines that operation.
This is a qualified library candidate, not native interpolation syntax or an
admitted operation. Its contract, bounds, library implementation and source
correspondence still need complete assurance before admission.

**Rubik's Magic.** The draft task has only a one-line requirement. Its
[captured FreeBASIC answer](r/rubiks-magic-simulation/freebasic.wiki) computes
panel coordinates for five presentation states; it does not establish a
mechanical hinge/string/ring transition model. Scaled integers may reproduce
the coordinate calculations, so arrays, floating point and graphics cannot be
declared necessary from this evidence. A finite discrete simulation is a
possible design, but its faithful scope and transitions remain unresolved.
The optional curated `assessment_status: "design-pending"` prevents an empty,
unknown surface from appearing as a solved stage-1 approach. No size estimate
or simulation implementation is claimed.

**Unicode and topic names.** [RM 2.3](../references/ada/2022/RM-2-3.html) and
the [SPARK lexical chapter](../references/spark/16.1/docs/lrm/source/lexical-elements.rst)
permit Unicode identifiers. A guarded increment of an object in `1 .. 2` also
needs scalar refinement beyond today's rules. Separately,
[RM 5.2.1](../references/ada/2022/RM-5-2-1.html) defines `@` as a constant view
of the current assignment target on its RHS. The
[SPARK statements chapter](../references/spark/16.1/docs/lrm/source/statements.rst)
adds no assignment restriction. This is a prospective explicit admission under
Silver's Ada 2022 inheritance; the selected symmetric-range negation example
avoids unrelated refinement. Its limited current-target semantics are stated,
without claiming a persistent implicit topic variable.

**Types and representation.** [RM 13.3](../references/ada/2022/RM-13-3.html)
permits Size clauses on stand-alone objects. A confirming 32-bit Integer object
clause directly answers the selected size task, subject to future pinned-target
and representation assurance. A distinct signed type with first subtype `1 .. 10`
directly follows the [primitive-type Ada answer](d/define-a-primitive-data-type/ada.wiki).
[RM 3.5.4](../references/ada/2022/RM-3-5-4.html) distinguishes its base range
from its first subtype; a [subtype declaration](../references/ada/2022/RM-3-2-2.html)
names a subtype of an existing type. A named Integer subtype remains a possible
narrower analogue, but these two capabilities are not interchangeable.

### Integer sequence and exact-output limits

The full prototype is 177 ASCII bytes. Successful complete LF output contains
2,147,483,647 lines and 24,658,692,663 bytes: one space, the decimal digits and
one LF per value. These totals are derived arithmetically, without generating
the stream. The task expressly permits an implementation limit; the Integer
maximum is that limit. An arbitrary smaller cap is not substituted.

This program passed admission but was not proved, built or executed in this
planning pass. It is outside #226 because the ordinary manifest checks run to
completion with exact stored stdout and a short timeout. A separate faithful
execution/validation disposition would be needed before claiming its delivery.
Prefix output would not be full execution evidence.

## Rendered mapping and validation

Stage #9 remains stage 1 and retains its original issue scope. The historical
ten-task #11 group has split: six tasks are stage-1 candidates, and the four
remaining approaches now have narrow future identifiers. The current generated
stage 2 introduces the broad `for-loops`, `integers`, `procedures`,
`ranged-subtypes` and `scalar-image` set, driven by Law of cosines - triples,
with Named parameters and Return multiple values. #11 records this mapping;
it does not authorize that bundle. Arrays #12 moves from stage 4 to stage 3.
All later ordering changes are renderer output, not additional reassessments.

Six retained prototypes passed read-only `silver check` calls against the
existing compiler from implementation `247cc5c205`; their source and executable
hashes, commands and results are in the candidate evidence. Only the literals
prototype's comments were corrected; executable expressions were preserved.
All sources are ASCII and between 177 and 1,498 bytes. Expected output is an
independent static derivation, not observed runtime output. Candidate sources
live under evidence, outside the regression manifest.

`python3 rosetta/refresh.py --render` regenerated the corpus. Managed run
`20261025T121118-ac711f0d1ec2` passed all three focused Rosetta tests, including
two-seed corpus determinism and a pending-design fixture that cannot gain a
stage or an Oracle-conflict label. The final
[validation record](../docs/evidence/rosetta-assessment-20261025/validation.json)
binds the inputs and retained log. No native proof, build, Lean or broad-suite
rerun was required for these planning changes. PR #221's successful delivery
evidence remains applicable at its recorded inputs and scope.

A bounded mechanical integration review of commit
`715f7f050d1fb844a687f80fd2f6f47672adf660` against `e1f6f9a53b` found no material
issue. It verified the intended assessment-only scope, preserved attribution,
unsupported future identifiers, pending-design rendering, committed evidence
hashes and commands, stage mappings and authorization wording. The earlier
ordinary-task semantic assessment was reused; this was not a second review of
those same semantics. PR [#227](https://github.com/berkeleynerd/silver/pull/227)
publishes this planning change, stacked on #221. Stage issues #10–#12 identify
the proposed PR mapping explicitly; #9's original task list is preserved.

## Round record

| Work | Settings and exact input | Resolved obligations and remaining limits | Measurements |
| --- | --- | --- | --- |
| Six ordinary task checks | Selected GPT-6.1 Sol, Extra High; base `e1f6f9a53b`, six retained tasks, current language and hashed prototypes. Runtime settings not independently exposed. | Six precise current-language mappings; five exact finite outputs; sequence separated from run completion; literals explanation corrected. | Reviewer-reported elapsed 445 seconds; token/cost data unavailable. |
| Seven disputed classifications | Selected GPT-6 Astra, Extra High; same base, seven captured tasks/answers and the cited fixed specifications. Runtime settings not independently confirmed. | Permanent conflicts separated from current exclusions; minimal future surfaces; Magic design left explicitly unresolved. | Observed review interval 11:58:42–12:09:15 UTC, 633 seconds; token/cost data unavailable. |
| Lead integration and checks | Live lead model/effort not independently exposed; no setting change claimed. Integrated diff, exact evidence inputs and one managed test worker. | Preserved supported identifiers and historical attribution; rendered mappings, admission evidence and focused tests; no implementation or deferred work resumed. | Admission checks 0.138094 seconds; focused unittest time 3.546 seconds. Whole-team tokens/cost and complete elapsed time unavailable. |
| Mechanical integration review | Selected GPT-6.1 Sol, Extra High; exact `715f7f050d` commit against `e1f6f9a53b`. Runtime settings not independently exposed. | No material findings; evidence and generated mapping agree with the record. No native or test rerun. | Reviewer-reported elapsed 128 seconds; token/cost data unavailable. |

CLI memory was unavailable and was not updated. The checked-in record and issue
handoffs are the continuation pointers. The live local harness has no active
goal; the earlier capacity harness remains paused and is not reactivated.
