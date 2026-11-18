# Independent native recurrence diagnosis — #392

2026-11-17, Linux aarch64. Separate read-only diagnosis after the completed
semantic review. Selected setting: GPT-6 Astra / Max; runtime confirmation,
elapsed review time, token usage and cost are unavailable. No implementation,
proof-cache, index, branch or GitHub changes, and no proof/test runs. This
scratch report is the only file written for this diagnosis.

## Recommendation

Use one executable, pure `Mark_Formal` expression function in the recursive
models, recurrence lemma and executable visited-set assignments. This is the
smallest well-motivated next repair. Check it under the unchanged canonical
native policy before treating it as successful. Remove the two ineffective
caller-local `Hide_Info` annotations in that first repair check; they did not
address the identified equality problem.

Keep the existing `Logical_Equal` pattern as a fallback for a concrete
remaining return/copy equality obligation, after inspecting the changed task.
No domain restriction, fresh-name/fresh-slot premise, unproved assumption,
obligation suppression or proof-budget increase is justified.

## Exact evidence and diagnosis

Inspected `tmp/named-native-392/src/silver_output_profile.adb` at SHA256
`ab1327dbb71d67448518ff965642c157062e3e12378ccb80f9911f3159297ba0`,
which independently matches the source archived for failed complete-lemma run
`20261117T025551-c79f975d17c7`. The retained generated task is 14,393,064 bytes,
SHA256 `0845d7a1ec0a7bbd4606ad1fd3d984aa8ef96951dc6c81bf2de05989ba8b7d23`;
I independently recomputed that archive hash too. The task and its four-theory
extract are retained under
`docs/evidence/named-scalar-arguments-392-20261117/native/`.

The model's delta at line 5130 becomes
`temp_____aggregate_def_20197`; the identical-looking delta in the lemma's
postcondition at line 5173 becomes `temp_____aggregate_def_20357`. Both
definitions provide well-formedness and element equations for indices within
the fixed `Formal_Index` bounds. Their quantified element equations trigger on
`Array__Int__Bool.get`. Consequently the recurrence's two recursive calls do
not start with syntactically identical map arguments, despite their identical
Ada meaning.

The pinned `share/spark/theories/_gnatprove_standard.mlw:1873` represents an
array as an abstract map. Its `eq_ext_def` and `extensionality` axioms at lines
1896–1905 trigger on `eq_ext`, not on the element `get` terms. In the sibling
`ada__model.mlw:2282` constrained-array theory, `well_formed` supplies the
fixed bounds, Ada equality is `bool_eq`, and `logic_eq` introduces the required
`eq_ext` term. Thus bounded element equality has a sound route to logical map
identity, but the duplicate-delta equation does not itself request the trigger
for that route. This independently corroborates the author's diagnosis. It is
a proof-encoding/instantiation problem, not evidence that the recurrence is
false or that the declared input domain needs narrowing.

The two hidden reader definitions removed only two theories and left this
array-equality mismatch intact. I inspected the source author's full-domain
`ActualsAdvance.model_advance` and `FormalStorage.read_mark`; they support the
semantic equation but do not discharge the native helper's contract.

## Bounded repair and check

The proposed helper shape is:

```ada
function Mark_Formal
  (Seen : Formal_Set; Formal : Functions.Formal_Index) return Formal_Set
with Global => null,
  Post => (for all Index in Functions.Formal_Index =>
    Mark_Formal'Result (Index) =
      (if Index = Formal then True else Seen (Index)));

function Mark_Formal
  (Seen : Formal_Set; Formal : Functions.Formal_Index) return Formal_Set is
  (Seen with delta Formal => True);
```

The contract covers every slot, including unused slots, every valid index and
arbitrary Boolean contents. It intentionally permits setting an already-true
slot. Both function and procedure formal-index subtypes have the same existing
source-derived bounds. Avoid another delta occurrence in the postcondition;
the pointwise contract specifies the update without creating the same duplicate
aggregate problem there.

Use `Mark_Formal (Seen, Association.Formal)` in all three recursive models,
the advancement postcondition, and `Seen := Mark_Formal (...)` in the matching
executable walkers. A helper used only in the lemma would leave the model's
different update symbol; leaving the imperative element assignment unchanged
could leave a separate congruence problem at the loop invariant.

The next discriminating sequence is complete native checks of `Mark_Formal`,
the changed function tail model, and the standalone advancement lemma, then
its actual caller once the lemma succeeds. Inspect the generated map terms
if any of those fail. Fixed identical array bounds avoid sliding, and one
expression body should give one update symbol, but whether GNATprove introduces
a separate return-copy equality obligation remains untested. Do not infer
success from this diagnosis. The other changed models/walkers still need their
complete focused contracts before the integrated checkpoint.

A fallback `Same_Formals` would use the existing verified fixed-array
`Logical_Equal` pattern: matching bounds and pointwise equality over the entire
array, with its visible implementation and every annotation obligation proved.
Equality of only the active formal slice is insufficient for a whole-array
`Logical_Equal` annotation. The bridge must be instantiated on the actual two
map values at the failed comparison; merely declaring it is not a fix. This
adds equality transport and source-proof work, so it is less direct than
preventing duplicate update symbols in the first place.

## Correspondence and evidence implications

`Mark_Formal` is new executable Silver-owned SPARK code and must pass Bronze
and Silver checks. The source proof must check its exact declaration, complete
pointwise contract and expression body, then connect each actual callee to the
existing finite-storage mark interpretation. `FormalStorage.read_mark` already
provides the semantic finite-storage bridge; its existence alone does not
certify the new Ada helper. Update the affected function/procedure native trees,
helper/callee interfaces, source candidates and complete source certificate.
Update the ghost lemma's exact token/body checks when removing `Hide_Info`, and
remove only the corresponding newly added policy allowance/tests if unused.

The full-array expression may change internal copying/stack behavior versus
the former element assignment. It adds no association-count limit; account for
its actual compiled behavior in the existing native/boundary validation rather
than assuming optimization. Preserve all failed evidence. Retained successes
remain scoped to their original inputs; the full integrated native/source and
behavioral checkpoint is still required on the repaired inputs.
