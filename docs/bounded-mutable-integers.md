# Bounded mutable integers

**Scope proposal, 2026-10-17; not an admitted capability.** The owner authorized
scoping after the completed For loops and integers review remediation.
[Session memory](session-memory.md) records the authorization.
[Milestone 4](https://github.com/berkeleynerd/silver/milestone/4) tracks this
proposal as a narrow increment of [stage #11](https://github.com/berkeleynerd/silver/issues/11).
Only [scope work #67](https://github.com/berkeleynerd/silver/issues/67) is
authorized. Implementation, assurance development and delivery remain Backlog.
The completed For loops and integers harness goal remains complete.

The proposed capability lets a program retain and update an Integer result
inside a statically declared range. It builds on the existing Integer
expressions, finite loops, String composition and standard Integer Image.
[language.md](../language.md) continues to describe current support; the
[Oracle](../oracle.md) and [development workflow](../development.md) govern
the proposed extension.

## Motivating program

[Find square difference](../rosetta/f/find-square-difference/silver.md) needs
one mutable result, an object-local range constraint and the existing loop,
arithmetic, condition and Image forms:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Answer : Integer range 0 .. 1000 := 0;
begin
   for N in 1 .. 1000 loop
      if Answer = 0 and then
        ((N * N) - ((N - 1) * (N - 1))) > 1000
      then
         Answer := N;
      end if;
   end loop;
   Silver_IO.Put_Line (Integer'Image (Answer));
end Main;
```

The intended output is ` 501` followed by LF, preserving Ada's leading space.
The square difference is `2*N - 1`; the first satisfying index is 501.
All arithmetic fits Integer using the loop-index interval alone, and every
assignment lies in `0 .. 1000`. The comparison with Answer selects the first
result; it supplies no range fact needed for safety. This is proposed source,
not a compiled sample or proof result.

## Recommended admission rules

Extend the ordered declaration region with the following object declarations
and allow scalar assignment wherever an ordinary assignment is allowed:

```text
integer_declaration ::= name ":" [ "constant" ] "Integer"
                        [ "range" static_scalar_expression ".."
                          static_scalar_expression ]
                        ":=" scalar_expression ";"
integer_assignment  ::= mutable_integer_name ":=" scalar_expression ";"
```

An object-local range constraint creates no new named type or subtype. A plain
Integer object has the pinned range -2147483648 through 2147483647. Explicit
endpoints must be in that range and ordered `L <= U`. A null range contains no
value for the required initializer. One initialized name per declaration,
existing expression grouping and literal spelling, and the common String/scalar
namespace remain in force.

Static range expressions use the existing scalar operators and literals plus
earlier Ada-static Integer constants. Staticness is recursive: the constant's
subtype and initializer must be static under
[Ada RM 4.9](../references/ada/2022/RM-4-9.html). Merely knowing a value during
admission does not make its source expression static. Mutable names, loop
indexes and constants initialized from mutable objects cannot supply a static
range endpoint. All intermediate operations in a bound expression must satisfy
the existing Integer safety rules.

Declarations still precede all executable statements. Every scalar initializer
reads only earlier initialized scalars, with no numeric external input or
intervening assignment. Admission can therefore calculate its exact initial
value in declaration order. It must establish that value lies in the declared
range. Record separately:

- the exact initial value, used for subsequent declaration snapshots;
- the object's immutable or mutable status and declared range;
- whether a constant is Ada-static and may appear in a later range bound.

For example, after `A : Integer range 0 .. 99 := 7`, a later
`K : constant Integer := A` captures 7, while a later
`S : String := Integer'Image (A)` captures the two bytes ` 7`. Writes to A
change neither K nor S. K is immutable but its initializer is not Ada-static,
so it cannot define a static range bound. This declaration treatment needs
native and Lean correspondence and actual producer evidence; it is a proposed
rule, not an existing guarantee for mutable scalars.

At every executable-body read, a mutable scalar contributes its **entire
declared range**. Immutable scalar snapshots retain their exact values;
loop indexes retain their checked iteration intervals. An assignment is admitted
only when every intermediate RHS operation fits Integer and the complete RHS
interval is included in the target's declared range. Evaluate the RHS using
the pre-assignment store, then update exactly the target. Self-reading assignments
are allowed when that same rule succeeds. Constants and loop indexes cannot be
assignment targets, and String/scalar assignments remain type-distinct.

Assignments and scalar comparisons do not narrow mutable ranges. In particular,
`X : Integer range 0 .. 9 := 0` does not permit `X := (X + 1)`, even after a
reset or under `X < 9`: its body interval is `[0,9]`, giving `[1,10]` for the RHS.
Conversely, `X := (9 - X)` fits `[0,9]` and needs no information from an earlier
iteration. These are explicit limits of this first admission analysis; Ada
permits more programs. General accumulation needs a separately justified
value-flow or guard-refinement rule.

Even in an empty loop, target type/mutability, visibility and static expression
legality must be checked. Index-dependent empty intervals retain the existing
vacuous safety treatment; they do not admit assignment to an immutable index
or a hidden outer object.

Existing visibility rules extend across mutable objects and constants. Names
must be distinct in the outer declaration region, and forward/self-initializer
references are excluded. The Integer type mark must remain visible, including
inside its own object declaration. Loop indexes may hide mutable objects but
remain immutable themselves. Qualified library operations remain available
when an object hides an unqualified operation.

## Composition requirements

Both output-capable shells admit the proposed declarations after their existing
prefix; the argument shell still starts with its sole immutable argument
binding. Scalar values may appear in all existing scalar-expression positions:
initializers, range bounds subject to staticness, comparisons, loop bounds and
Integer Image. Scalar assignments compose with String assignments, all choices,
nested forward/reverse loops, null, Put, Put_Line and returning Reject.

Execution must carry the scalar store through statement sequences, branch
selection and every loop iteration. Each initialized mutable object stays in
its declared range. Branch joins and loop back edges need no stronger scalar
facts. Existing input validity/length facts and sticky rejection/output behavior
retain their meaning; a scalar assignment cannot create input facts or erase
an earlier failure.

Evaluate both loop bounds once in the entry scalar store. Later writes to an
object mentioned in a bound do not alter that iteration sequence. A nested loop
evaluates its own bounds when it is entered. Empty loops preserve both stores;
nonempty loops preserve writes to outer mutable objects. Restore only the
index's lexical scope on exit. Do not restore the entire scalar store and lose
body assignments. The current empty/definite/uncertain treatment of String/input
facts still applies, with scalar range preservation proved alongside it.

String initialization retains its existing exact-length requirement. Exact
declaration snapshots support Image initializers without making a String's
fixed bounds depend on later scalar writes. In the executable body, Image
length is derived afresh from the current expression's abstract interval, using
the existing decimal length rule. For a mutable object that interval is its
declared range. A range `10 .. 99` always yields length 3; `0 .. 1000` yields
lengths 2 through 5. The former can support a matching fixed-length String
assignment; the latter cannot assign its Image to a fixed-length target merely
because the most recent scalar assignment selected one length.

The existing capacity, input-validity and exact assignment-length rules apply
in every String-expression position, including Image in comparisons and
concatenations. Repeated Image calls observe the actual value at each call;
captured String values remain snapshots. No fact about equality to an earlier
Image may be reused as a fact about the mutable scalar after a write.
Facts already derived about immutable input length or fixed String lengths
remain valid. This distinction needs no general dependency graph when body
analysis always uses the declared scalar ranges.

## Assurance work required before admission

The implementation needs coordinated changes across these existing boundaries:

| Boundary | Required extension |
| --- | --- |
| [Scalar expression environment](../src/silver_scalar_expressions.ads) and [native output profile](../src/silver_output_profile.adb) | Distinguish exact declaration values, Ada-staticness, mutability and declared ranges; recognize constrained objects and typed scalar assignments; establish native contracts and body-state rules. |
| [Integer declarations](../proof/Silver/IntegerDeclarations.lean), [composition declarations](../proof/Silver/ComposeScalarDeclarations.lean) and [frozen semantics](../proof/Silver/ComposeFrozenSemantics.lean) | Specify initialization, snapshots, range inclusion, mutability and name resolution; prove the declaration-to-body abstraction preserves concrete values. Replace the all-static premise with an elaboration-store relation. Preserve stable scalar identities when separating static constants from mutable or nonstatic bindings. |
| [Predicate execution](../proof/Silver/PredicateExecution.lean) and its checking/composition modules | Return and thread mutable scalar state through checked and ordinary execution; prove assignment safety, range preservation, finite-loop composition and agreement. The current evaluator carries a fixed scalar store and cannot simply be reused. |
| Native equations, source certificates and whole-source bridges | Match every changed SPARK body to its semantic equations, extend declaration/statement decoding and correspondence, and review regenerated pins with those changes. |
| [Image producer and consumer boundary](trusted-boundary.md#image-proof-adapter-boundary) | Re-establish applicability for mutable reads, declaration snapshots and constrained objects; verify the unchanged Image meaning, selected schemas and size-12 Main translation, or repair the owned connection if required. |
| [Report capacity](report-capacity.md#for-loops-and-integers-extension) and report policy | Derive all new declaration/assignment/range-check and advisory charges from source/producer routes; cover every selected report and required obligation. |

The model must establish automatic-discharge schemas as well as safety and
execution meaning. Native application evidence must use the actual submitted
Ada source with the pinned proof configuration and no loop unrolling. Existing
[tool-contract premises](trusted-boundary.md) remain explicit; neither the
scope argument nor passing samples proves solver completeness for the extension.

Retain the 4096-byte source/value bounds, 64 leaves per expression and repaired
shared 63-operator budget. Arithmetic in range constraints also spends that
budget. Recheck source-derived binding and statement bounds. The current
15,028,224-byte report derivation uses constant-only declaration lengths and
does **not** establish capacity for the proposed fragment: mutable declarations
are shorter, assignments can add root range checks without arithmetic operators,
and constraints may affect translation or advisories. Derive the combined
envelope, including dense assignments and declarations, before admission.
Any necessary storage adjustment belongs to this capability's implementation
and assurance; a passing dense specimen alone cannot justify the bound.

## Evidence plan and unresolved technical checks

These are implementation tasks, not claims established by this scoping pass:

1. Confirm declaration snapshots and staticness through the selected frontend:
   a mutable initializer, a constant copying it, a captured String Image, and
   a later scalar write. Check static-bound acceptance/rejection separately.
2. Inspect genuine reports and generated Image models for the driver and a
   small combined interaction case: constrained assignment, branch, nested
   loop, a bound object written inside its loop, and output after the loop.
   Confirm both execution and applicable producer schemas.
3. Exercise constant-width versus varying-width Image assignment and rejection
   of overflowing/out-of-range scalar assignments, including endpoint values
   and guarded cases that the non-refining analysis deliberately excludes.
4. Review the producer's extra checks/advisories and source-derived envelope,
   then use a dense legal specimen to corroborate it. Map any new diagnostic
   to its exact semantic rule rather than broadening accepted warnings.

Use the managed [proof-iteration workflow](proof-iteration.md). Share applicable
evidence between native and assurance packages. Start with the smallest probe
that resolves a stated uncertainty; preserve its actual inputs and report before
changing them. A recurring failure needs a diagnostic checkpoint and new
hypothesis. Do not repeat an unchanged successful broad audit for bookkeeping.
Complete native and Lean validation belongs at the integrated implementation
checkpoint, with focused checks during development and independent review
proportionate to the changed boundaries.

No new Oracle policy decision is identified. The recommended declaration/body
distinction, producer applicability and extended report envelope remain
technical obligations to establish during implementation. A feasibility failure
requires an explicit design correction and synchronized scope; it cannot silently
remove a promised composition or weaken a guarantee.

## Work packages and completion

| Order | Package | Completion criterion |
| --- | --- | --- |
| 1 | [#67 Scope and automatic-proof design](https://github.com/berkeleynerd/silver/issues/67) | Record the driver, exact proposed rules, composition, exclusions, assurance boundaries, evidence plan and ordered issues; review and publish the scope. This is the presently authorized work. |
| 2 | [#68 Native admission and regressions](https://github.com/berkeleynerd/silver/issues/68) | Resolve focused frontend/producer questions, implement verified SPARK declaration and assignment rules, preserve existing behavior, and retain boundary/composition regressions and genuine reports. |
| 3 | [#69 Universal and actual-source assurance](https://github.com/berkeleynerd/silver/issues/69) | Establish mutable-store semantics, range preservation, complete safety/discharge composition, actual-source correspondence, Image applicability and the extended report envelope; validate every affected endpoint. Coordinate with #68. |
| 4 | [#70 Validation, review and delivery](https://github.com/berkeleynerd/silver/issues/70) | Complete stable Linux validation and independent review of the integrated inputs, resolve findings, and synchronize language, catalogue, samples, capability, roadmap and Rosetta records before claiming support. |

The proposed milestone completes only when all four packages complete. Closing
the scope package leaves the capability unsupported and the other packages in
Backlog until the owner authorizes implementation. Native macOS validation
remains independent and nonblocking; hosted CI remains disabled.

## Exclusions and stage mapping

Named subtype/type declarations and explicit conversions remain in #11: this
increment uses object-local constraints of the existing Integer type. Dynamic
range constraints require a separate elaboration/bound-lifetime argument.
Scalar guard refinement and stronger loop-carried value analysis need additional
proof rules. Division, other scalar types/images, additional loop forms,
procedures and arrays remain outside this capability. Existing exclusions on
uninitialized objects, multiple declared names and inner declaration regions
continue to apply.

The Find square difference assessment currently uses broad construct identifiers.
Delivery must record the precise supported fragment and adjust that assessment
and the rendered progression together. It must not mark all of `integers`,
`ranged-subtypes`, `for-loops` or `scalar-image` supported on this one driver's
evidence. Stage #11 remains open for the unimplemented forms; procedures and
arrays retain their later roadmap positions. Existing-language Rosetta sample
work on #9 is independent of this milestone.

## Scoping validation

This proposal is based on read-only review of the current specification,
implementation and assurance boundaries at `a6cc65112b`, with focused semantic
and assurance reviews. No compiler, prover or application execution is claimed
for the proposed source. The scoping change affects documentation and planning
only; final link, whitespace and tracking checks are recorded in its handoff.
