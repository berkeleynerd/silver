# Integer Image automatic-discharge diagnostic

This record belongs to [scope #13](https://github.com/berkeleynerd/silver/issues/13)
and [assurance #15](https://github.com/berkeleynerd/silver/issues/15) of
[For loops and integers](for-loops-integers.md). The owner resumed that existing
goal on 2026-10-16 with the standard Integer `'Image` scope settled in
[decision #34](https://github.com/berkeleynerd/silver/issues/34). The selected
scope includes String initialization, concatenation, predicates and equal-length
assignment. The finding below is an automatic-discharge gap to repair, not a
reason to narrow that scope or accept an unproved check. No Oracle amendment,
new admission or completed remedy is recorded here.

## Focused native evidence

The exploratory lane uses `feat/integer-image-native` at integration baseline
`d333d67047`, in `tmp/integer-image-native`. It bootstrapped its own native
Linux x86_64 context using the pinned GNATprove 16.1.0 toolchain. All three
ordinary application sources import `Silver_IO` and have the same shell:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- declarations below
begin
   -- statements below
end Main;
```

The exact program contents and complete native reports are retained under
`tmp/integer-image-native/tmp/image-probes/`. `probe.py` preserves each source,
project, copied runtime, command, log and parsed Main report. The three cases
contain these declarations and statements:

```ada
-- output/main.adb
   Step : constant Integer := 2;
begin
   Silver_IO.Put_Line (Integer'Image (-2147483648));
   for I in 1 .. 5 loop
      Silver_IO.Put_Line (Integer'Image ((I * Step)));
   end loop;
```

```ada
-- assignment/main.adb
   S : String := "xx";
begin
   for I in 1 .. 9 loop
      S := Integer'Image (I);
      Silver_IO.Put_Line (S);
   end loop;
```

```ada
-- constant_assignment/main.adb
   N : constant Integer := 5;
   S : String := "xx";
begin
   S := Integer'Image (N);
   Silver_IO.Put_Line (S);
```

Each managed `dev.py tool` run reserved four workers and passed
`--subdirs=explore -U --mode=all --report=all --warnings=continue
--checks-as-errors=on --level=2 --prover=cvc5,z3,altergo --steps=100000
--memlimit=0 --no-loop-unrolling -j4` to GNATprove. Project switches were
`-gnat2022`, `-gnata` and `-gnato`. This is exploratory proof evidence for these
exact sources; it is not an execution test, complete compiler proof or universal
capability result.

| Case | Managed run | Result | Managed duration |
| --- | --- | --- | ---: |
| Image output | `20261016T135144-bc6133bfe6fb` | Exit 0; no Main safety checks; two Image warnings | 8.586 s |
| Loop assignment | `20261016T135153-b13ea7870afe` | Exit 1; unproved `VC_LENGTH_CHECK`, `main.adb:7:15` | 21.201 s |
| Constant assignment | `20261016T135214-1fb198382e49` | Exit 1; unproved `VC_LENGTH_CHECK`, `main.adb:7:14` | 21.144 s |

Both assignments have a two-character result by Ada's Image definition. The
constant failure shows this is independent of loop inference or unrolling.
The two cases are separate diagnostic inputs, not repeated attempts at an
unchanged failing VC. No solver repeat was performed. The managed diagnostic
and checkpoint identify the next semantic investigation.

Each Image occurrence produced a `warn_error` record with positive source
line/column, `file:"main.adb"`, `rule:"imprecise-image"`, `severity:"warning"`,
`how_proved:"trivial"`, `check_tree:{}`, `suppressed:""`,
`unproved_status:{"status":"unknown"}`, and no entity field. Its exact text is:

> references to the "Image" attribute are handled in an imprecise way, so nothing will be known about the evaluation of the attribute reference apart from a bound on its length [imprecise-image]

Any eventual report-policy extension must classify this exact advisory,
maintain all required checks and reject unrelated diagnostics. An empty
`suppressed` field in this producer advisory is not evidence that the failed
assignment check was suppressed. Neither warnings nor failed checks were
removed from these reports.

## Exact generated model

`model-dump/main.gnat-json` preserves a byte copy of the loop assignment's
generated native input. A separate managed diagnostic command,
`20261016T135615-d09530c8cf77`, ran native
`gnatwhy3 --entity 1 --proof no_wp --debug main.gnat-json` on that copy. It
produced readable `model-dump/main.mlw`, with no VC generation or solver run.

`Standard_String__Img` at line 284 declares an uninterpreted `to_string`
function. Its three generated axioms establish only:

```text
first (to_string x s) = 1
s >= 0 -> length (to_string x s) <= s
well_formed (to_string x s)
```

At line 1094 the application evaluates:

```text
to_string (Standard__integer.attr__ATTRIBUTE_IMAGE i) 12
```

The native upper bound is **12**, while the actual signed 32-bit decimal Image
maximum is **11**. The upstream bound computes the image length of `2**Size`
as an unsigned 64-bit value and adds another character. It is a deliberate
overapproximation, not the exact decimal-length semantics needed for assignment.
The loop-index facts `1 <= i <= 9` are present at line 1082. The assertion at
line 1113 requires equality of the RHS `last-first` and the fixed two-character
target's `last-first`, with the separate empty-array branch.

A concrete countermodel explains why more solver effort cannot repair this:
interpret `to_string x s` as the empty String with first index 1 and last index
0 for every `x` and `s`. It satisfies all three generated axioms, including
the length upper bound whenever `s >= 0`. The abstract scalar Image function
can return an arbitrary value of its opaque image type. The assignment to
the nonempty target then fails. Thus the exact-length obligation does not
follow from the native model's premises, despite being true of Ada execution.

The missing semantic connection is:

```text
length (Integer'Image v) = 1 + decimal_digits (abs v)
decimal_digits 0 = 1
```

Ada's [Image definition](../references/ada/2022/RM-4-10.html#p11) requires a
single leading space or minus sign, decimal digits, and no leading zeros,
underscores, exponent or trailing spaces. Negation of Integer'First must use a
wider magnitude in compiler reasoning. The native bridge must connect this
definition to the actual generated `to_string(...,12)` term, as well as the
authoritative source and compiled predefined operation.

## Extension hooks and remaining implementation work

The retained producer source inspected for the report-capacity repair is under
`tmp/review-capacity-343c2f8/tmp/producer-source/`, at the upstream revision
identified in [report-capacity.md](report-capacity.md). Relevant definitions are:

| Source | Role |
| --- | --- |
| `src/why/gnat2why-expr.adb:20256` | Translates Image to the abstract attribute function and `to_string`, then emits the warning |
| `src/why/why-gen-arrays.adb:1631` | Generates the local String Image functions and three weak axioms |
| `src/why/spark_atree-entities.adb:593` | Computes the conservative type-wide Image bound |
| `why3/src/gnat/gnat_util.ml:117` | Prepends `Proof_Dir/_theories` to the shared theory search path |
| `why3/src/gnat/gnat_config.ml:354` | Loads additional configured provers/editors through `--why3-conf` |
| `src/spark/spark_definition-annotate.adb:6940` | Ignores `External_Axiomatization`; the diagnostic says it is no longer supported |

The source inspection is not a binary-source attestation. The installed
generated model above is the direct evidence of the missing relation.

Overriding the external `ada__model.mlw` theory alone cannot define the local
generated `Standard_String__Img.to_string` relation. `--why3-conf` does not
itself add the missing semantics to that module. No existing configuration-only
remedy was established.

A candidate route is a reviewed proof-IR refinement of this predefined
primitive, backed by a machine-checked decimal Image theorem and actual-source
correspondence. This is an implementation direction, not a completed remedy.
Before accepting its results, the implementation must establish all of the
following:

- The stronger Image interpretation agrees with Ada's predefined Integer Image
  for every signed 32-bit value, including the exact bytes and length.
- The refined term corresponds to the actual source occurrence and native
  generated symbols/types; a source hash or theorem name alone is insufficient.
- Every original obligation, source location and required selected library
  check remains present and receives a valid discharge. Native reports are
  not relabelled and unsuccessful results remain failures.
- Application source bytes remain identical through admission, proof and
  compilation. No hidden annotated application replacement is introduced.
- Any Silver-owned compiler adapter is implemented and verified under the
  existing SPARK requirement, with its semantic transformation proved in Lean.
  Imported facts must have checked proofs, not new unproved project axioms.
- The actual proof configuration, report policy/capacity and provenance include
  the refinement and its verified inputs. The complete native and Lean
  checkpoint still applies.

After a sound discharge route is established, native admission can carry lower
and upper static String-length contributions alongside the existing `K*d`
input contribution. Constant initializers remain exact; variable loop images
need interval lengths. Concatenation uses the upper bound for capacity,
assignment establishes equality using both endpoints, and predicate refinement
uses overlapping possible lengths rather than treating an upper bound as an
exact length. Type-name hiding, Integer extrema, digit boundaries, empty loops,
leaf/operator budgets and compositions with existing input guards also require
matching native and universal/source proofs.

No admission, proof backend, selected source, installed toolchain, Oracle or
language specification was changed by this diagnostic lane.

## Review of the native extension point

A read-only review on 2026-10-16 found that driver rules for
`main.Standard__integer` and `main.Standard_String__Img` do not provide a simple
configuration hook for the actual generated symbols. In the retained producer
source, `why3/src/gnat/gnat_checks.ml:396` creates the controller before line 399
adds the generated input file. `why3/src/session/controller_itp.ml:114–135`
loads prover drivers during controller creation, and
`why3/src/driver/driver.ml:239–241` immediately resolves driver theory names
through `Env.read_theory`. The application's local modules have not been parsed
at that point.

There is also a symbol-identity distinction. `why3/src/core/env.ml:162–164`
stores the current parsed file under the empty library path, while
`Env.read_theory` at lines 219–222 resolves a named library path or the builtin
`why3` path. Placing a copy of `main.gnat-json` in `_theories` would load a
separate library with separately created symbols; its driver rules would not
thereby bind to the symbols in the actual application task. At the later SMT
stage the captured task erases module qualification:
`Standard__integer.attr__ATTRIBUTE_IMAGE` becomes `attr__ATTRIBUTE_IMAGE`, and
the String conversion becomes `to_string`. Bare names and compatible SMT types
are insufficient evidence of the primitive's origin.

The more direct candidate is a verified SPARK adapter before the original
`gnatwhy3` parser, refining the typed JSON while exact module and type identity
are still available. An isolated tool overlay could select that adapter without
changing the installed toolchain. This remains a design finding, not an
implemented or validated remedy. The adapter must retain all original
declarations, obligations and source labels, establish the recognized native
schema's correspondence, and bind the refinement and original input to the
resulting evidence. Its theorem strengthens the model to match Ada semantics;
it is not derivable from the existing weaker axioms alone.

The length refinement must specifically cover the generated size argument
`12`, or carry an appropriate sufficient-size guard. An unconditional exact
length assertion for every `s` would contradict the existing
`to_string__length` axiom at `s = 0`, making the proof context inconsistent.
The intended fact is guarded by the signed 32-bit range and concerns
`length (to_string (Standard__integer.attr__ATTRIBUTE_IMAGE v) 12)`.

## Isolated typed-clone experiment

The owner confirmed continuing after the custom adapter was explained. The
2026-10-16 experiment now establishes a working native hook, while production
implementation and its correspondence remain unfinished.

An isolated copy of the vendor `gnatprove` executable selects a diagnostic
Python wrapper for `gnatwhy3`; other vendor files remain unchanged. Before
calling the original `gnatwhy3`, the wrapper preserves the original typed JSON
and adds only an include of `Standard__integer` and this clone to
`Standard_String__Img`:

```text
clone import silver_image.Integer_Image_Length as Silver_Image with
  axiom .,
  type image = Main.__image,
  type text = Standard__string.string__,
  function scalar_image = Standard__integer.attr__ATTRIBUTE_IMAGE,
  function string_image = to_string,
  function length = Standard__string.length
```

The external theorem fixes the size to `12`, guards the signed 32-bit range,
and expands decimal length into nine signed threshold comparisons. The checked
`IntegerImage`, `IntegerImageLength` and `IntegerImageRefinement` modules supply
its mathematical basis and a model consistent with the original weak axioms.
A separate actual-source rendering proof is being developed; a theorem file
with matching words alone does not establish that connection.

The prototype verifies structural preservation by deleting its two additions
and comparing the entire parsed input with the original. Its JSON reserialization
is only experimental. Production will preserve the original bytes by inserting
at two validated array boundaries, validate the exact module/clone identities,
and provide the corresponding SPARK and Lean proofs. No application source is
rewritten, no original native check is removed or relabelled, and the Image
warning remains in each native report.

| Experiment | Managed run | Native result | Managed duration |
| --- | --- | --- | ---: |
| Parse typed clone and dump model | `20261016T143741-f6d78e108ea6` | Accepted; no proof attempted | 3.371 s |
| Original constant assignment | `20261016T143823-f10ba4fd7c2e` | Original `VC_LENGTH_CHECK` proved | 3.601 s |
| Original loop assignment | `20261016T143843-9111ba920619` | Original `VC_LENGTH_CHECK` proved | 3.578 s |
| Three-character target for two-character Image | `20261016T143949-e4b328968f1b` | Original length check remains unproved; exit 1 | 17.836 s |

The positive checks were discharged by CVC5/Z3; cancelled or unsuccessful
individual prover attempts remain in the reports. The negative case is an
intentional control, not an unresolved valid-program obligation. It does not
by itself prove consistency or soundness; those remain mathematical and
correspondence requirements. Initial parser launches encountered path,
configuration-file and session-directory setup errors before the successful
model dump; those logs are retained separately and are not proof attempts.

The retained scripts, original/refined JSON, external theory, readable model,
commands and reports are under `tmp/integer-image-native/tmp/image-probes/`:
`refine_model.py`, `refinement_probe.py`, `refined-dump/`, and each case's
`obj/explore/image-refinement/gnatprove/`. These Python files are diagnostics,
not production compiler code. The planned production adapter is Silver-owned
SPARK and must establish both native verification and semantic correspondence
before this path can be used to claim supported admission.

### Checked theorem rendering and typed-model core

The fixed-size (12), signed-32-bit guarded theorem now has a typed Lean
rendering and exact correspondence to `src/silver_image_theory.ads`.
Focused native Linux run `20261016T150831-ea146f445bd2` is identified by the
managed ledger under `#15-image-theorem-rendering`; the successful check started
at 15:08:35 UTC, built the module in 13 seconds and freshly audited 381
declarations. This is the theorem constant's source correspondence, not yet a
complete adapter or capability certificate.

The preceding rendering diagnosis found two distinct issues: the imported
`Nat.ofDigitChars` implementation needed an explicit implementation import for
kernel reduction, and decoding the entire source literal into characters during
closed equality checking consumed excessive memory. The retained run
`20261016T150026-4fdacb90d927` was interrupted after 194 seconds of build time
at approximately 22 GB RSS. A subsequent bounded attempt failed at the exact
source-equality proof with a 2 GiB limit. Character-list construction and the
existing kernel-checked reconstruction-witness mechanism replaced that reduction;
no kernel bypass, additional axiom or weakened source equality was introduced.

The streaming typed-model core is integrated from `09fa3f12bc`, with its native
211-check result, focused 23-check warning repair and 22 positive/negative
byte-preservation fixtures retained in its worktree and managed evidence.
`6744087d39` proves insertion erasure, byte ordering and fresh IDs. Complete
scanner-to-schema and wrapper-I/O correspondence remain outstanding.
