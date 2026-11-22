module

public import Silver.ApplicationInterfaces

@[expose] public section

/-! Translation preserves callable identity, even when distinct routines have
identical signatures. No identity is reconstructed from a signature equality. -/
namespace Silver.Packages

theorem originalIndex_projectedIndex {select : α → Option β} {earlier : List α}
    {identity : Nat} {routine : α} {signature : β}
    (found : lookupRoutine earlier identity = some routine) (selected : select routine = some signature) :
    originalIndex select earlier (projectedIndex select earlier identity) = identity := by
  induction earlier generalizing identity with
  | nil => simp [lookupRoutine] at found
  | cons first rest ih =>
      cases identity with
      | zero => simp [lookupRoutine] at found
      | succ index =>
          cases index with
          | zero =>
              have same : first = routine := by simpa [lookupRoutine] using found
              subst first
              simp [projectedIndex, originalIndex, selected]
          | succ index =>
              have tail : lookupRoutine rest (index + 1) = some routine := by
                simpa [lookupRoutine] using found
              have exactIndex := ih tail
              cases head : select first with
              | none =>
                  simpa [projectedIndex, originalIndex, head] using congrArg Nat.succ exactIndex
              | some value =>
                  simpa [projectedIndex, originalIndex, head, Nat.add_assoc] using congrArg Nat.succ exactIndex

theorem lookupRoutine_concat_right (first : List α) {second : List α} {identity : Nat} {value : α}
    (found : lookupRoutine second identity = some value) :
    lookupRoutine (first ++ second) (first.length + identity) = some value := by
  have positive := (lookupRoutine_before found).1
  simp only [lookupRoutine, show identity ≠ 0 by omega,
    show first.length + identity ≠ 0 by omega, ↓reduceIte] at found ⊢
  rw [List.getElem?_append_right (by omega)]
  have arithmetic : first.length + identity - 1 - first.length = identity - 1 := by omega
  rw [arithmetic]
  exact found

end Silver.Packages

namespace Silver.Applications
open Packages
open ScalarFunctions (Frame Value)

def Environment.packageFunctionId (environment : Environment) (identity : Nat) : Nat :=
  environment.localFunctions.signatures.length + functionIndex environment.packages.signatures identity

def Environment.packageProcedureId (environment : Environment) (identity : Nat) : Nat :=
  environment.localProcedures.signatures.length + procedureIndex environment.packages.signatures identity

theorem Environment.packageFunction_lookup {environment : Environment} {identity : Nat}
    {signature : ScalarFunctions.Signature}
    (found : lookupRoutine environment.packages.signatures identity = some (.function signature)) :
    ScalarFunctions.lookup environment.functionSignatures (environment.packageFunctionId identity) = some signature :=
  lookupRoutine_concat_right _ (functionSignatures_lookup found)

theorem Environment.packageProcedure_lookup {environment : Environment} {identity : Nat}
    {signature : ScalarProcedures.Signature}
    (found : lookupRoutine environment.packages.signatures identity = some (.procedure signature)) :
    ScalarProcedures.lookup environment.procedureSignatures (environment.packageProcedureId identity) = some signature :=
  lookupRoutine_concat_right _ (procedureSignatures_lookup found)

theorem Environment.packageFunction_value {environment : Environment} {identity : Nat}
    {signature : ScalarFunctions.Signature}
    (found : lookupRoutine environment.packages.signatures identity = some (.function signature))
    (globals : Frame) (inputs : List Value) :
    (environment.functionsAt globals).values (environment.packageFunctionId identity) inputs =
      environment.packages.functions identity globals inputs := by
  have positive := (lookupRoutine_before (functionSignatures_lookup found)).1
  have original := originalIndex_projectedIndex found (rfl : RoutineSignature.functionSignature (.function signature) = some signature)
  simp only [functionsAt, packageFunctionId,
    show ¬environment.localFunctions.signatures.length + functionIndex environment.packages.signatures identity ≤
      environment.localFunctions.signatures.length by omega, ↓reduceIte, Nat.add_sub_cancel_left]
  rw [functionIndex, original]

theorem Environment.packageProcedure_value {environment : Environment} {identity : Nat}
    {signature : ScalarProcedures.Signature}
    (found : lookupRoutine environment.packages.signatures identity = some (.procedure signature))
    (globals : Frame) (inputs : List Value) :
    environment.invokeProcedure globals (environment.packageProcedureId identity) inputs =
      environment.packages.procedures identity globals inputs := by
  have positive := (lookupRoutine_before (procedureSignatures_lookup found)).1
  have original := originalIndex_projectedIndex found (rfl : RoutineSignature.procedureSignature (.procedure signature) = some signature)
  simp only [invokeProcedure, packageProcedureId,
    show ¬environment.localProcedures.signatures.length + procedureIndex environment.packages.signatures identity ≤
      environment.localProcedures.signatures.length by omega, ↓reduceIte, Nat.add_sub_cancel_left]
  rw [procedureIndex, original]

end Silver.Applications
