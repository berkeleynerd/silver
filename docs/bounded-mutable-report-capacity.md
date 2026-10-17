# Bounded mutable Integer producer and capacity design review

Read-only source review on Linux x86_64, 2026-10-17, for
[assurance package #69](https://github.com/berkeleynerd/silver/issues/69).
The [selected scope](bounded-mutable-integers.md) is authorized for implementation
but not admitted. This record identifies the changed producer routes and a
conditional sizing calculation. It establishes neither a complete retained-report
bound nor automatic discharge for the new fragment. No compiler, prover or
application was run for this review.

## Inputs and inherited baseline

The [immutable Integer/loop source review](for-loops-report-capacity.md) and
[current capacity record](report-capacity.md#for-loops-and-integers-extension)
provide the baseline. The retained upstream sources use `spark2014` fsf-16
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`, recipe
`0334dd54a2c479faa3dfad47a911373581b11739` and GCC 16.1.0 frontend
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
The [inspection inventory](evidence/bounded-mutable-integers/producer-capacity-source-review.json)
records retained paths and current file hashes. This is source inspection under
the existing recipe/tool assumptions, not installed-binary attestation.

Below, **P** is the producer's `src/` directory. All cited routes belong to
those pinned source inputs. The existing `13,064,192`-byte String baseline
already charges `floor(S/5)` assignment/declaration roots, `floor(S/3)`
comparisons, the shared concatenation allowance, flow/identifier payload and
fixed metadata. The immutable Integer extension deliberately adds a separate
conservative declaration charge as well as arithmetic, loop-root and Image
charges. Those overlapping allowances must not be mistaken for disjoint source
partitions.

## Changed routes

| Construct | Reviewed route and consequence |
| --- | --- |
| Mutable or constant scalar initializer | `P/why/gnat2why-expr.adb:1384–1450` transforms the explicit initializer once to the object's Why type. The regular mutable-object branch at `1756–1782` stores that result; immutable objects use an assumption. The initializer has at most one checked scalar conversion on this route. The shortest unconstrained mutable declaration `A:Integer:=0;` occupies 13 bytes, replacing the old conservative 22-byte minimum `A:constant Integer:=0;`. |
| Scalar assignment root | `gnat2why-expr.adb:19043–19105` transforms the RHS once to the LHS type. Its final checked conversion is at `25636–25664`. The subsequent conversion at `19249–19281` is in `EW_Pterm`, and direct identifier assignment at `12286–12425` bypasses component/index traversal and uses an unchecked simple conversion plus store. Thus the root belongs in the existing `floor(S/5)` assignment bucket (`A:=B;`), jointly with String assignments; it is not charged to the 63-operator bucket and does not require another whole scalar-assignment bucket. |
| Conversion multiplicity | `P/why/why-gen-expr.adb:2754–2825` uses `Range_Check_Applied` to avoid adding a second scalar range check in successive conversion stages. Array, discriminant, tag, access, ownership and predicate routes are excluded by this selected Integer syntax. |
| Static constraint bounds | `gnat2why-expr.adb:3707–3731` returns `Void` when an OK static range lies in the OK static base subtype. Its scalar type-declaration branch at `22870–22888` invokes range checking only for nonstatic range/base cases. Nonstatic fallback at `3790–3814` adds a range VC and may transform bounds in executable mode. The native Ada-staticness rule, including the rejection of constants copied from mutable values as static bounds, is therefore material. The actual frontend/anonymous-IType route must still be checked before relying on zero constraint-root records. |
| Arithmetic | The overflow wrapper at `25511–25575` registers at most one overflow check for an executable operator. The repaired shared lexical budget charges operators in initializers, constraints and assignments as source occurrences. Ordinary scalar operands use mathematical Integer; mutation does not itself multiply a source arithmetic occurrence by iteration count. |
| Mutable advisories | `P/flow/flow-analysis.adb:1989–2055` selects mutually exclusive unused-assignment, mutable-initialization and ineffective-statement messages. Mutable initialization can now produce `initialization of & has no effect`; local constants skip it. The existing initializer-name allowance applies to unique declared names. `Emit_Info_Message_Local` at `2763–2794` suppresses positive initialization messages for variables with explicit initializers. Confirm genuine reports and the exact native acceptance path; an unrecognized diagnostic must not be silently admitted. |
| Image traversal | `gnat2why-expr.adb:20256–20296` transforms the Image argument once and appends its fixed warning. `P/why/gnat2why-driver.adb:1538–1549` only attempts constant-value translation for nonmutable entities, and `gnat2why-decls.adb:207–238` requires `Can_Be_Translated_As_Value`. Mutable initializers do not acquire an additional constant defining axiom. The inherited upper allowance of two traversals per textual Image remains the candidate; declaration snapshots with variable inputs, anonymous types and generated actions must preserve that traversal argument. |

The proposed source still spells `Integer'Image`, rather than an object's or
custom subtype's Image. The producer chooses the Image function and maximum
size from the prefix type at `gnat2why-expr.adb:20268–20289`; mutation changes
the argument value, not that prefix. This supports retaining the selected
signed-32-bit size-12 premise, but does not prove that every resulting mutable
model/VC satisfies the adapter's selected schemas. Keep the
[producer/consumer boundary](trusted-boundary.md#image-proof-adapter-boundary)
and native model observations separate from traversal counting.

## Conditional calculation

If all route, frontend, flow, metadata and adapter conditions below close,
replacing the immutable declaration minimum gives the candidate:

```text
13,064,192
  + (63 + floor(4096/13) + 2*floor(4096/18))*2048
  + 2*floor(4096/16)*1024
= 15,292,416 bytes
```

This is 264,192 bytes above the old 15,028,224-byte derivation and would leave
1,484,800 bytes within the current 16,777,216-byte buffer. Arithmetic alone
does not establish that this expression covers every retained record. In
particular, the existing assignment charge covers the union of String and
scalar assignments only after the one-root route and its exclusions hold;
zero constraint roots depends on the actual static frontend route.

## Required closure before admission

1. Check actual object-local constraints and earlier-static-constant bounds in
   the selected frontend, including anonymous scalar subtype/IType actions.
   `gnat2why-expr.adb:23131–23141` can re-enter an associated node for an
   IType reference; document why the selected static syntax adds neither
   duplicated executable initialization nor extra bound checks. Distinguish
   a constant snapshot from an Ada-static constant.
2. Retain genuine driver, declaration-snapshot, reassignment and loop-bound
   snapshot reports/models. Identify each root range/overflow check and exact
   advisory, and match the current Image template schemas. Samples corroborate
   source routes; they do not establish a universal count or discharge theorem.
3. Confirm the existing source-based `2*S` flow and `2*S` initializer-name
   allowances still cover mutable declarations/assignments and every admitted
   loop/choice composition. Preserve exact rejection of unrelated diagnostics.
4. Review implicit scalar subtype entity/dependency/timing cardinalities and
   field widths. `P/why/gnat2why-types.adb:1108–1141` has no standalone type-VC
   work without its listed special triggers, but timing eligibility includes
   `Type_Kind` (`gnat2why-driver.adb:1343–1350`); do not infer unchanged metadata
   solely from object exclusion. The existing fixed metadata allowance needs
   an explicit applicability argument for generated subtypes.
5. Close the frontend Image-copy/generated-action paths for mutable declaration
   snapshots, then combine the exact record inventory, proven native lexical
   budget/source correspondence and producer premises. Review a dense legal
   specimen only as corroboration. Update the final capacity record and its
   meaningful fixtures when the complete argument is established.

Native and assurance owners share these obligations with delivery package #70.
The planning lane runs no native validation and introduces no source/proof
changes. Do not mark the candidate formula as the current supported envelope
until the outstanding applicability work and required assurance are complete.
