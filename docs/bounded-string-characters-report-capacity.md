# Bounded String and Character producer account

Feature-local account for [#296](https://github.com/berkeleynerd/silver/issues/296),
2026-10-31. The [independent capacity review](reviews/string-character-capacity-20261031.md)
found no blocking issue under the retained assumptions. Complete feature
implementation and independent delivery review remain in progress.
This extends the [named-subtype envelope](named-integer-subtypes-report-capacity.md)
and [Boolean producer account](evidence/boolean-objects-20261030/producer-review.md)
under the unchanged 4,096-byte source, 63-operator and 64-leaf budgets. It does
not start deferred capacity work or replace universal/source assurance.

## Retained inputs and selected routes

The producer remains SPARK `42554fc241fcd1fdf08d3a2feccb3f86912acbc0` with the
frontend and trust qualifications in the
[fixed-array account](fixed-integer-arrays-report-capacity.md#inputs-and-source-routes).
The following retained inputs were read and their SHA-256 hashes rechecked:

| Input | SHA-256 |
| --- | --- |
| `src/why/gnat2why-expr.adb` | `750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14` |
| `src/why/why-gen-expr.adb` | `9891d54331f76713685fce8f21501d549485a46c35593ac68ba572c9f0f5a432` |
| `src/flow/flow-control_flow_graph.adb` | `d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7` |

`gnat2why-expr.adb:23980–23982` translates a Character literal directly to an
integer constant. Predefined Character reads and comparisons take the existing
identifier/comparison routes immediately below it. They introduce no user-defined
type, predicate, callee, annotation or type-proof entity. Character initializer
and assignment roots retain ordinary scalar conversion accounting. The shortest
Character declaration is longer than the existing seven-byte named-Integer
object allowance; a Character write is no shorter than the existing assignment
minimum. Complete Character literal tokens are skipped by Silver's arithmetic
and xor scanners, including embedded quote and operator bytes.

Indexed String reads use the same one-dimensional indexed-component route as
Integer-array reads at `14042–14089`: transform the subscript once and insert at
most one index check. Indexed writes at `14287–14349` similarly transform one
subscript, insert at most one index check, and store the RHS through a simple
component conversion. Their Character RHS retains its ordinary assignment-root
conversion allowance. The prefix is a visible String name; there is no indexed
String-valued prefix, nested String array or implicit user call.

`Transform_Slice` at `29364–29515` transforms each endpoint once. In executable
mode it emits one `VC_RANGE_CHECK` assertion: a nonnull requested interval implies
both endpoints lie within the prefix bounds. Its later extra scalar-range check
requires a subtype indication, which the admitted explicit `L .. U` slice syntax
excludes. Nonstatic bounds use an unconstrained array representation; they add
no separate assertion there. The admission rule's all-null or in-bounds cases
establish this precise conditional check. The frontend creates a slice subtype with
the original array's base type as parent (`sem_res.adb:13165–13174`), and
conversion to that parent requires no additional check
(`spark_util-types.adb:493–510`). In GNATprove mode, nonstatic initializer subtype
expansion returns before copying the expression (`exp_util.adb:5884–5892`).
The static-slice path freezes the endpoint values using the slice index subtype.
The review records these retained frontend/producer inputs and their hashes. Endpoint arithmetic has its ordinary
shared-budget checks. Slice assignment targets are excluded and therefore do
not enter the separate update route beginning at `14349`.

`Transform_Concatenation` at `21976–22351` still evaluates each operand once,
selects inherited lower bounds, and inserts at most one final index-subtype range
check when reconstruction is needed. A null left operand returns the right
operand, statically or under the generated conditional. The new actual-bound
invariant supplies the semantic premise for this existing check; the report
site remains charged to its textual concatenation operator. Character operands
of concatenation remain excluded. Whole-String assignment retains the existing
length-check and sliding route. New slices or bounds do not introduce extra
library calls or Image traversals.

## Combined source charge

Extend the existing disjoint two-byte site reservation to each slice occurrence:
its own opening and closing parentheses pay for its single root range check.
A nested Integer-array read in an endpoint or String subscript has its own
parentheses and its own index-check charge. Assignment/declaration roots use
`:=`, comparisons and aggregate components retain their existing reservations,
and arithmetic/concatenation use the independent shared operator bucket. These
sites do not reuse each other's reserved bytes.

The existing nested-loop advisory account applies to String indexed writes as
well as Integer-array writes: each indexed assignment is visited at most once
per enclosing loop analysis, the same exact advisory withholds an initialization
fact, and all Strings are explicitly initialized before the body. String writes
are no shorter than the existing eight-byte indexed-write allowance. The shortest
admitted loop syntax remains the constant-array iteration account's 24-byte
allowance. Slices are reads and add no loop initialization warning route.

No new diagnostic class or report allocation is needed. Keep the existing
conservative independent counts, including their overlaps:

```text
checks = floor(S/2) + 3*63 + floor(S/7) + 3*floor(S/15) + floor(S/2)
Main = checks*2048 + (2*S + 2*floor(S/16))*1024 + 2*S + 65536
       + floor(S*S / (4*24*8))*512

S = 4096: checks = 5,689
Main = 31,822,336 bytes < 33,554,432 bytes
```

The retained report projection and Boolean check-identity grouping assumptions
remain unchanged. Native report acceptance still requires every emitted safety
check to be proved with the exact required provenance. A supported diagnostic
class never excuses a failed obligation.

## Corroborating observations and their limits

The [capability record](bounded-string-characters.md#retained-focused-evidence)
identifies native stress run `20261031T165409-9c2dd4f813bc` at implementation
`9c4afd3c5b`. Its eight exact cases passed admission, application/runtime proof,
both report audits, build, execution and source identity. The dense 4,096-byte
comparison/write case retained a 51,467-byte Main report. Discovery run
`20261031T162539-96d0ba9159be` covers all 95 printable Character literals,
noncanonical and extreme null bounds, and expected frontend rejections.
These finite observations corroborate the selected routes; they establish no
universal solver-time, stack or report guarantee by themselves.

The retained 4,096-byte admission probe has 1,992 Character parentheses. It
passed with 8, 4 and 2 MiB stack limits and failed with `STORAGE_ERROR` at 1 MiB.
This is a measured Linux input-specific result, not a new minimum environment
contract or a language nesting restriction. The implementation keeps the existing
complete-source bound and operational resource assumptions.

Selected author setting: GPT-6 Astra / Extra High for integration; live setting
and whole-agent elapsed time/token/cost are unavailable. The native stress worker
selected GPT-6.1 Sol / Extra High. The independent capacity review is complete; independent delivery review and
complete feature assurance remain separate outstanding obligations.
