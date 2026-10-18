# Numeric values serialized by the retained producer

**2026-10-18, #119.** This closes the ordinary Main contribution to `d` in
the [serializer weight](retained-producer-storage.md#from-the-schema-to-a-serialized-byte-weight).
It concerns the magnitude of emitted numeric values, not the number of Uint
allocations or the possibly much larger temporary powers used by the scanner.
The producer source premise and grammar/configuration closure are the same as
in the [producer derivation](retained-producer-capacity.md).

## Ordinary Main invariant

For the proposed removal of resource limits while retaining the current
Integer/String grammar and semantic rules, every ordinary Main numeric
primitive serialized by the producer has a signed decimal image of at most
**eleven characters**. In particular, the numeric spelling of `0E<exponent>`
does not appear in the Why output: the emitted value is zero. Its retained
frontend power and conversion work still need their separate capacity charge.

The invariant uses these semantic premises already required independently of
resource admission:

- Integer declarations, assignment values, expression intermediates and loop
  bounds have the specified 32-bit Integer meaning. The special unsigned
  spelling of the negative minimum is at most `2147483648`.
- String uses predefined Character and the Integer-based Positive index.
  Valid String endpoints fit that index base; a null String can have upper
  endpoint zero. Each decoded or folded literal and each selected value has
  its separately checked admissible length. This is not permission to let
  String index arithmetic overflow when removing the old 4096-byte limits.
- The light frontend's generated Main closure contains bound captures,
  ordinary scalar and String subtypes, checks and the previously inventoried
  declarations/actions. It introduces no numeric type, representation clause,
  floating/fixed/modular value, record, aggregate or unchecked conversion.
  Native expansion's extra nodes are in another process and do not become
  inputs to this producer.

The reachable numeric construction families preserve those premises:

| Producer route | Value placed in the numeric field |
| --- | --- |
| Known discrete expression | `Expr_Value` of the expression, passed unchanged through `New_Discrete_Constant` (`gnat2why-expr.adb:23704–23711`, `why-gen-expr.adb:4488–4500`). Known Boolean/Character values are smaller. |
| Ordinary Integer subtype | Its two semantic endpoints, through `New_Range_Type_Definition` and `Num_Constant` (`why-gen-scalars.adb:850–857,1122–1132,1546–1555`). Dynamic endpoints are translated expressions, not newly computed large integers. |
| Conversion of an integer constant to a Why range constant | The existing `Get_Value` is copied, without arithmetic (`why-gen-expr.adb:3005–3030`). The two term/program `New_Discrete_Constant` overloads likewise only forward (`why-gen-expr.ads:367–375`). |
| String literal characters and indexes | Character code, index `low + (i-1)`, offset `i-1`, low bound, or length minus one (`gnat2why-expr.adb:30325–30362,30377–30400,30539–30582`). These values describe existing String positions; the addition is Uint arithmetic, but its emitted result fits the semantic index domain. |
| String subtype attributes | Low/high endpoints and static length; the literal high formula is `low + length - 1` (`why-gen-arrays.adb:2533–2639,2813–2845`; `why-gen-expr.adb:3664–3689`). Empty literals produce the null endpoint or offset minus one, not an arbitrary negative length. |
| Array length, concatenation, conversion and comparison support | Constants zero and one. Other arithmetic is represented by Why calls and child expressions; it does not evaluate a new Uint during serialization (`why-gen-arrays.adb:551–576,1709–1732,3872–3873`; `why-gen-expr.adb:1286,2716`; `gnat2why-expr.adb:18619,22026,22063,22308`). |
| Integer Image support | `Max_Size_Of_Img_Attr(Integer)`; with size 32 its calculation gives 12, which needs two decimal characters (`gnat2why-expr.adb:20286–20288`; `spark_atree-entities.adb:593–611`). This conservative producer parameter is distinct from the actual maximum Integer image length. |
| Loop update and ordinary wrappers | Zero/one, including the loop step (`gnat2why-expr-loops.adb:1481–1487`; `gnat2why-util.adb:800`; `gnat2why-subprograms.adb:5988`). The selected no-unrolling option excludes the repeated-value constructor in `Unroll_Loop` (`:1812–1814,2091–2093`). |

Thus every newly emitted Main Uint is either a preserved admitted scalar or
index value, a Character value, or a small fixed constant. All have magnitude
at most `2^31`, and the negative endpoint `-2147483648` sets the eleven-character
envelope. Source arithmetic inside a null loop still needs the existing
legality/admission rules; unreachable runtime execution does not excuse an
invalid static expression. No Main route emits a Ureal.

## Coverage and fixed work

The [numeric inventory](../evidence/retained-producer-storage-20261018/numerics.py)
checks the complete archived producer source and records all 190 constructor
calls in handwritten Why bodies, plus the two forwarding calls in the spec.
It includes the `New_Discrete_Constant` wrapper, not just direct numeric-node
builders. Its function/caller grouping is a lexical inspection aid, not an
automatic reachability proof. The remaining constructor families have these
separate dispositions:

- Aggregate and container-annotation translation, record/tag translation,
  unchecked conversion, modular arithmetic, shifts/rotates and hardcoded
  big-number/real-time APIs require excluded Main constructs.
- Size, alignment, object overlays, address clauses, array logical operations,
  user variants and real/fixed literal branches require absent Main syntax or
  annotations. The generated light-mode closure above does not introduce them.
- Scalar fixed-point theories, modular attributes and enumeration representation
  conversion can occur in fixed Standard/dependency setup. They are fixed work,
  not an extra Main-dependent numeric family. The same distinction applies to
  contract bodies, fixed runtime types and predefined priority references.
- Numeric constructors in contract-case and default-check helpers use zero/one.
  The exception identity counter is `Int`; Main adds no declared exceptions.
  These routes cannot introduce an unbounded numeric magnitude into Main.

Numeric Why nodes are immutable: the schema's mutable families are effects,
statement sequences and theories. Constructor values are therefore not later
replaced by a mutation that escapes this inventory. Import, label and printing
plan traversal can repeat a numeric node, affecting occurrences but preserving
its value.

Fixed Standard includes wider Integer and real types, so **eleven is not a
bound for every fixed node**. Let `d_fixed` bound the numeric primitives in the
complete fixed Standard/imported closure, including raw Ureal numerator and
denominator, and any independently compiled fixed library file. Then the
whole-file parameter is

```text
d = max(11, d_fixed).
```

The fixed-state reduction is the same one used for
[isolated-root contributions](retained-producer-capacity.md#additive-isolated-root-envelope):
Main cannot change a fixed type, signature, contract, numeric value or cached
fixed expression. Taking the maximum over the completed Standard state and
all five isolated API closures is sufficient despite order and overlapping
work. Import growth adds module references and does not synthesize numeric
values. Fixed library outputs additionally cover their own body VCs. The
five retained library JSON files have observed `d=11`; that observation alone
does not bound unprinted Standard nodes. The fixed-state numeric evidence
must supply the remaining parameter before whole-rule adoption.

The Ureal serializer emits its stored numerator, stored denominator, radix
and sign (`why-atree-to_json.adb-tmpl:32–43`). It does not expand a radix power
into a rational numerator. A measurement or bound must use those actual fields.
None of these magnitude results pays for decimal-conversion scratch, producer
node counts or output-column growth; those remain separate components.
