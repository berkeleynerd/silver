# Bounded mutable Integer producer and capacity review

Source review on Linux x86_64, 2026-10-17, for
[assurance package #69](https://github.com/berkeleynerd/silver/issues/69).
The [selected scope](bounded-mutable-integers.md) is authorized for implementation.
The initial planning review at `0685a58fd0` was read-only and left frontend,
metadata, flow and Image applicability obligations open. The implementation-lane
closure below resolves those source-review obligations and records separate
native corroboration. Under the inherited producer/tool premises and the selected
admission grammar, the retained Main envelope is **15,292,416 bytes**, within the
existing 16,777,216-byte buffer. Source correspondence and complete native/Lean
discharge remain separate delivery obligations; neither this sizing argument nor
passing examples establishes them.

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

Below, **P** is the producer's `src/` directory and **F** is the retained GCC
frontend directory. All cited routes belong to
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
| Static constraint bounds | `gnat2why-expr.adb:3707–3731` returns `Void` when an OK static range lies in the OK static base subtype. Its scalar type-declaration branch at `22870–22888` invokes range checking only for nonstatic range/base cases. Nonstatic fallback at `3790–3814` adds a range VC and may transform bounds in executable mode. The native Ada-staticness rule, including the rejection of constants copied from mutable values as static bounds, is therefore material. The actual frontend route is closed below: these static constraints add no root records. |
| Arithmetic | The overflow wrapper at `25511–25575` registers at most one overflow check for an executable operator. The repaired shared lexical budget charges operators in initializers, constraints and assignments as source occurrences. Ordinary scalar operands use mathematical Integer; mutation does not itself multiply a source arithmetic occurrence by iteration count. |
| Mutable advisories | `P/flow/flow-analysis.adb:1989–2055` selects mutually exclusive unused-assignment, mutable-initialization and ineffective-statement messages. Mutable initialization can now produce `initialization of & has no effect`; local constants skip it. The existing initializer-name allowance applies to unique declared names. `Emit_Info_Message_Local` at `2763–2794` suppresses positive initialization messages for variables with explicit initializers. The exact existing acceptance paths and flow charge are reviewed below. |
| Image traversal | `gnat2why-expr.adb:20256–20296` transforms the Image argument once and appends its fixed warning. `P/why/gnat2why-driver.adb:1538–1549` only attempts constant-value translation for nonmutable entities, and `gnat2why-decls.adb:207–238` requires `Can_Be_Translated_As_Value`. Mutable initializers do not acquire an additional constant defining axiom. The frontend closure below preserves the inherited upper allowance of two traversals per textual Image. |

The selected source still spells `Integer'Image`, rather than an object's or
custom subtype's Image. The producer chooses the Image function and maximum
size from the prefix type at `gnat2why-expr.adb:20268–20289`; mutation changes
the argument value, not that prefix. This supports retaining the selected
signed-32-bit size-12 premise, but does not prove that every resulting mutable
model/VC satisfies the adapter's selected schemas. Keep the
[producer/consumer boundary](trusted-boundary.md#image-proof-adapter-boundary)
and native model observations separate from traversal counting.

## Static constraints and generated subtype actions

`F/sem_ch3.adb:19080–19220`, `Find_Type_Of_Object`, handles an ordinary
object's subtype indication by creating an explicit subtype declaration before
the object. The selected grammar has no component/access declarations or
specification expressions. Its route at `19170–19174` relocates the original
subtype indication; it does not copy the initializer. `Process_Subtype` at
`22885` onward uses that declaration's defining identifier. The Integer branch
calls `Constrain_Integer` (`15481–15501`), which stores and resolves the range
through `Set_Scalar_Range_For_Subtype` (`23676–23707`).

`Process_Range_Expr_In_Decl` (`22588–22820`) resolves both bounds against the
base type. Its `Force_Evaluation` calls cannot turn the selected static,
side-effect-free endpoints into additional executable initializer copies:
`F/exp_util.adb:7221–7244` enables side-effect checking and
`12718–12722` returns for side-effect-free expressions. The producer sees an
explicit static signed Integer subtype, so its scalar declaration branch above
adds no constraint VC. The producer's generic `N_Itype_Reference` re-entry at
`gnat2why-expr.adb:23131–23141` is not this ordinary object-local route.

The native binding records distinguish exact initializer value from Ada
staticness. A constant copied from a mutable object is an immutable exact
snapshot, but is not static and cannot supply a constraint endpoint. Earlier
constants whose initializers are Ada-static remain valid endpoints. This
distinction is necessary for the static-source premise; exact singleton
intervals alone would not establish it.

## Metadata, flow and Image closure

Generated subtype names do not extend the retained metadata ledger:

- `P/why/gnat2why-types.adb:1108–1141`, `Generate_VCs_For_Type`, returns
  before opening a theory or calling `Register_VC_Entity` when its special
  default/private, access-subprogram, iterable, nonstandard equality, aggregate
  and ownership triggers are absent. They are all absent for the selected
  Integer subtype. Therefore it adds neither a type VC nor a vacuous type
  proof claim: the no-VC claim loop uses only registered entities
  (`gnat2why-error_messages.adb:475–483,1370–1375`).
- Although `Type_Kind` is eligible for `Do_Generate_VCs`, that procedure's
  `gnat2why.vc_generation` timing insertion is inside its subprogram branch
  (`gnat2why-driver.adb:507–611`, especially `565–568`). The type branch
  returns without registered VCs, so its subsequent count gate also skips
  `Print_GNAT_Json_File` and `Run_Gnatwhy3` (`597–605`). It adds no per-type
  timing map.
- `P/spark/spark_definition.adb:2313–2389`, `Get_SPARK_JSON`, excludes scalar
  types from its ordinary entity branch. The type branch requires the same
  special triggers. `Generate_Assumptions` excludes scalar types and only
  registers dependencies on generated calls (`gnat2why-driver.adb:1086–1116`).
  Integer operations add no Ada calls. `Entity_Table` serializes referenced
  interned report entities, not the frontend's entire entity list
  (`P/common/assumption_types.adb:78–88,266–315`). No new successful-report
  route references these generated subtype names.

The inherited eight-entity, five-coverage, ten-claim and five-owned-timing-map
ceilings and field widths therefore remain applicable, including their
65,536-byte fixed allowance. The unchanged selected runtime adds no records.

The existing `2*S` flow allowance covers the union of String and scalar
declarations/assignments. At a source vertex, unused assignment, initialization
and ineffective-statement messages are mutually exclusive; unreachable code
has its separate allowance and excludes path-copy vertices. The inherited
source-position/message/severity deduplication applies across choices and loops.
Generated static subtype declarations introduce no initialized object or new
call advisories. Explicit mutable initializers and frontend internal objects
skip positive initialization-info messages. Unique object declarations bound
the aggregate name text in initialization warnings by source bytes; the
existing extra `2*S` bytes still overcount that payload. Native
`silver_library_reports.adb` retains its exact `INEFFECTIVE` initializer
prefix/suffix and fixed-message checks in executable, ghost and raw policies;
no diagnostic category is broadened for this construct.

The inherited Image-copy argument also survives mutation. New scalar
constraints and scalar initializer expressions cannot contain Image.
String declaration snapshots continue through
`F/sem_ch3.adb:5138–5143`, but `Expand_Subtype_From_Expr` returns immediately
in GNATprove mode for their nonstatic Image initializer
(`F/exp_util.adb:5884–5892`; `sem_attr.adb:9719–9745`). This blocks an
Image-bearing implicit String subtype copy even when the argument is mutable.
The generated scalar subtype action above relocates only a constraint.
The inherited ordinary assignment, output, expression, loop and generated
temporary routes each reuse or transform an existing expression once. A constant
defining axiom may add one traversal; mutation cannot add a third. Thus the
two-warning-per-textual-Image allowance remains sufficient. Prefix selection
still uses predefined `Integer`, independently of the argument's constrained
subtype or current value. Exact decimal adaptation and complete discharge
remain the [separate assurance boundary](trusted-boundary.md#image-proof-adapter-boundary).

## Combined retained-data calculation

Replace the immutable declaration minimum by the mutable minimum and retain
the other inherited charges:

```text
13,064,192
  + (63 + floor(4096/13) + 2*floor(4096/18))*2048
  + 2*floor(4096/16)*1024
= 15,292,416 bytes
```

This is 264,192 bytes above the immutable 15,028,224-byte derivation and leaves
**1,484,800 bytes** within the current 16,777,216-byte buffer. The existing
assignment charge covers String and scalar assignments jointly; adding a second
whole assignment bucket would double-charge that union. The source routes and
exclusions above justify the count, together with the repaired shared operator
budget. The maximal fixed proof/flow/Image schemas and runtime envelopes are
unchanged. `tests/test_capacity.py` checks this formula, its storage limit and a
4,096-byte admitted source with more than 100 static object-local constraints.

## Native corroboration and delivery boundary

Managed run `20261017T005429-cfeb5626a484` executed two genuine compiles and
their resulting executables on Linux x86_64. Their sources, original reports,
models and Image-adapter workspaces are retained under
`tmp/bounded-mutable-integers-native/.silver/linux-x86_64/`; the
[inspection inventory](evidence/bounded-mutable-integers/producer-capacity-source-review.json)
records the identities and record inventory. These observations corroborate the
routes; the envelope is derived from source above.

| Probe | Observed Main report and output |
| --- | --- |
| Declaration/snapshot/reassignment | `program-mhQWXJ`: 13,471 raw bytes; one length and three range records; no flow messages; five Image warnings; exact output ` 7 7 8 99\n`. The String and constant Integer snapshots retain the initializer value while mutable Image reads reflect later writes. |
| Driver/frozen loop bounds | `program-oce3ja`: 11,276 raw bytes; two range records; four output-ghost advisories, one ineffective-statement and one unreachable-statement advisory; four Image warnings; exact output ` 501\n 3 1 7\n`. Changing the upper-bound variable inside the loop preserves the entry iteration range. |

Both reports contain only `Main` and `Silver_IO.Put_Line` entities, one Main
coverage entry and Main/global timing maps. Twelve retained Image workspaces
record the adapter inputs for the two compiles. These initial probes used native
implementation `264c7edbd0`, before the cursor-contract repair and final catalogue
edit; the inventory labels their selected-file hashes as historical probe inputs,
not a complete delivered-input manifest.

The dense probe in run `20261017T012122-06823c6de905` used the repaired native
implementation `04240f5df6`, before the final catalogue edit. Exactly one compile
proved all 66 compiler checks and the executable printed ` 9\n`. Its 4,096-byte
source contains 118 static constrained declarations. The retained Main report
is 93,326 bytes, with no proof records, 118 initializer advisories, 117 unused
assignment advisories and one Image warning. It has only a Main entity and
coverage entry, and Main/global timing owners; five Image workspaces are retained.

The original dense unittest failed after compilation and execution because its
last assertion required an unused `Silver_IO.Put_Line` entity. The corrected
assertion requires Main and permits only the known Main/Put_Line entity set.
Run `20261017T012339-51d50bdb031b` passed that corrected test against the identical
retained source, report and executable, replacing only the compile step with a
source-identity check. No compiler or prover was rerun. The original failure,
corrected test and a preceding retained-run wrapper path error remain recorded
separately. The three focused capacity tests passed in
`20261017T011935-74d26ccf3eca`; the two affected constraint-admission tests passed
in `20261017T011920-99e729df1f6c`.
No clean rebuild, independent kernel replay or native macOS validation is
claimed. Delivery package #70 must link complete integrated assurance to the
actual delivered inputs before marking the capability complete.
