module

public import Silver.ApplicationInterfaces
public import Silver.PredicateStatements

@[expose] public section

namespace Silver.Applications
open Predicate Packages

private theorem lookup_prefix {earlierRows : List α} {identity : Nat} {item : α}
    (found : Packages.lookupRoutine earlierRows identity = some item) (suffix : List α) :
    Packages.lookupRoutine (earlierRows ++ suffix) identity = some item := by
  have bound := Packages.lookupRoutine_before found
  simp only [Packages.lookupRoutine, show identity ≠ 0 by omega, ↓reduceIte] at found ⊢
  rw [List.getElem?_append_left (by omega)]
  exact found

private theorem lookup_suffix (earlierRows : List α) {suffix : List α} {identity : Nat} {item : α}
    (found : Packages.lookupRoutine suffix identity = some item) :
    Packages.lookupRoutine (earlierRows ++ suffix) (earlierRows.length + identity) = some item := by
  have bound := Packages.lookupRoutine_before found
  simp only [Packages.lookupRoutine, show identity ≠ 0 by omega, show earlierRows.length + identity ≠ 0 by omega,
    ↓reduceIte] at found ⊢
  rw [List.getElem?_append_right (by omega), show earlierRows.length + identity - 1 - earlierRows.length = identity - 1 by omega]
  exact found

/-- A package callee uses its completion-order identity while checking its body.
Main's inherited scalar function and procedure tables are separate prefixes. -/
theorem function_lookup_in_main (locals : ScalarFunctions.Signatures) {earlier : List RoutineSignature}
    {identity : Nat} {signature : ScalarFunctions.Signature}
    (found : Packages.lookupRoutine earlier identity = some (.function signature)) :
    ScalarFunctions.lookup (locals ++ functionSignatures earlier) (locals.length + functionIndex earlier identity) =
      some signature :=
  lookup_suffix locals (functionSignatures_lookup found)

theorem procedure_lookup_in_main (locals : ScalarProcedures.Signatures) {earlier : List RoutineSignature}
    {identity : Nat} {signature : ScalarProcedures.Signature}
    (found : Packages.lookupRoutine earlier identity = some (.procedure signature)) :
    ScalarProcedures.lookup (locals ++ procedureSignatures earlier) (locals.length + procedureIndex earlier identity) =
      some signature :=
  lookup_suffix locals (procedureSignatures_lookup found)

theorem local_function_check (extra : ScalarFunctions.Signatures) {functions : ScalarFunctions.Signatures}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Flow} {bools : Boolean.Analysis}
    {update : ScalarFunctions.Assignment} (checked : update.check functions shape analysis flow bools = true) :
    update.check (functions ++ extra) shape analysis flow bools = true ∧
      update.after (functions ++ extra) flow = update.after functions flow := by
  obtain ⟨result, call, write⟩ := update.check_success checked
  obtain ⟨signature, found, inputs, rfl⟩ := update.call.check_success call
  have extended : ScalarFunctions.lookup (functions ++ extra) update.call.callee = some signature :=
    lookup_prefix found extra
  have extendedCall : update.call.check (functions ++ extra) shape analysis flow bools = some signature.result := by
    simp only [ScalarFunctions.Call.check, extended, Option.bind_some, inputs, ↓reduceIte]
  exact ⟨by simpa only [ScalarFunctions.Assignment.check, extendedCall] using write,
    (update.after_checked extendedCall).trans (update.after_checked call).symm⟩

theorem local_procedure_check (extra : ScalarProcedures.Signatures) {procedures : ScalarProcedures.Signatures}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Flow} {bools : Boolean.Analysis}
    {call : ScalarProcedures.Call} (checked : call.check procedures shape analysis flow bools = true) :
    call.check (procedures ++ extra) shape analysis flow bools = true ∧
      call.after (procedures ++ extra) flow = call.after procedures flow := by
  obtain ⟨resolved, known, _⟩ := call.check_success checked
  obtain ⟨found, actuals⟩ := call.resolve_success known
  have extended : ScalarProcedures.lookup (procedures ++ extra) call.callee = some resolved.signature :=
    lookup_prefix found extra
  have linked : call.resolve (procedures ++ extra) = some resolved := by
    simp only [ScalarProcedures.Call.resolve, extended, Option.bind_some, actuals, Option.map_some]
  exact ⟨by simpa only [ScalarProcedures.Call.check, linked, known] using checked,
    by simp only [ScalarProcedures.Call.after, linked, known]⟩

end Silver.Applications
