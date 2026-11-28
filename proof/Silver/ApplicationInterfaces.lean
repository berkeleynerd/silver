module

public import Silver.PackageLibrarySafety

@[expose] public section

/-! Main-local callables keep their original identities. Package callables use
disjoint suffixes in the ordinary function/procedure signature tables; each
suffix position resolves back to the one completion-order package identity.
Snapshot environments expose the existing whole-language call interface while
the application evaluator separately threads persistent package state. -/
namespace Silver.Packages

def originalIndex (select : α → Option β) : List α → Nat → Nat
  | [], _ => 0
  | _ :: _, 0 => 0
  | first :: rest, index + 1 =>
      match select first with
      | none => originalIndex select rest (index + 1) + 1
      | some _ => if index = 0 then 1 else originalIndex select rest index + 1

theorem lookupRoutine_cons_positive (first : α) (rest : List α) {identity : Nat}
    (positive : 0 < identity) :
    lookupRoutine (first :: rest) (identity + 1) = lookupRoutine rest identity := by
  cases identity with
  | zero => omega
  | succ index => simp [lookupRoutine]

theorem lookupRoutine_originalIndex {select : α → Option β} {earlier : List α}
    {identity : Nat} {signature : β}
    (found : lookupRoutine (earlier.filterMap select) identity = some signature) :
    ∃ routine, lookupRoutine earlier (originalIndex select earlier identity) = some routine ∧
      select routine = some signature := by
  induction earlier generalizing identity with
  | nil => simp [lookupRoutine] at found
  | cons first rest ih =>
      cases identity with
      | zero => simp [lookupRoutine] at found
      | succ index =>
          cases selected : select first with
          | none =>
              have tail : lookupRoutine (rest.filterMap select) (index + 1) = some signature := by
                simpa only [List.filterMap_cons, selected] using found
              obtain ⟨routine, known, projects⟩ := ih tail
              have positive := lookupRoutine_before known
              refine ⟨routine, ?_, projects⟩
              simpa only [originalIndex, selected] using
                (lookupRoutine_cons_positive first rest positive.1).trans known
          | some value =>
              cases index with
              | zero =>
                  have equal : value = signature := by simpa [lookupRoutine, selected] using found
                  subst signature
                  exact ⟨first, by simp [originalIndex, selected, lookupRoutine], selected⟩
              | succ index =>
                  have tail : lookupRoutine (rest.filterMap select) (index + 1) = some signature := by
                    simpa [lookupRoutine, selected] using found
                  obtain ⟨routine, known, projects⟩ := ih tail
                  have positive := lookupRoutine_before known
                  refine ⟨routine, ?_, projects⟩
                  simpa only [originalIndex, selected, Nat.add_eq_zero_iff,
                    Nat.one_ne_zero, and_false, ↓reduceIte] using
                    (lookupRoutine_cons_positive first rest positive.1).trans known

theorem lookupRoutine_concat {first second : List α} {identity : Nat} {value : α}
    (found : lookupRoutine (first ++ second) identity = some value) :
    (identity ≤ first.length ∧ lookupRoutine first identity = some value) ∨
      (first.length < identity ∧ lookupRoutine second (identity - first.length) = some value) := by
  have positive := (lookupRoutine_before found).1
  by_cases left : identity ≤ first.length
  · left
    refine ⟨left, ?_⟩
    simp only [lookupRoutine, show identity ≠ 0 by omega, ↓reduceIte] at found ⊢
    rw [List.getElem?_append_left (by omega)] at found
    exact found
  · right
    refine ⟨by omega, ?_⟩
    simp only [lookupRoutine, show identity ≠ 0 by omega, show identity - first.length ≠ 0 by omega,
      ↓reduceIte] at found ⊢
    rw [List.getElem?_append_right (by omega)] at found
    have arithmetic : identity - first.length - 1 = identity - 1 - first.length := by omega
    rw [arithmetic]
    exact found

end Silver.Packages

namespace Silver.Applications
open ScalarFunctions (Frame Value ArgumentsFit)
open Packages

structure Environment where
  localFunctions : ScalarFunctions.Environment
  localProcedures : ScalarProcedures.Environment
  packages : SharedEnvironment

def Environment.functionSignatures (environment : Environment) : ScalarFunctions.Signatures :=
  environment.localFunctions.signatures ++ Packages.functionSignatures environment.packages.signatures

def Environment.procedureSignatures (environment : Environment) : ScalarProcedures.Signatures :=
  environment.localProcedures.signatures ++ Packages.procedureSignatures environment.packages.signatures

def Environment.functionsAt (environment : Environment) (globals : Frame) : ScalarFunctions.Environment :=
  ⟨environment.functionSignatures, fun identity inputs =>
    if identity ≤ environment.localFunctions.signatures.length
    then environment.localFunctions.values identity inputs
    else environment.packages.functions
      (originalIndex RoutineSignature.functionSignature environment.packages.signatures
        (identity - environment.localFunctions.signatures.length)) globals inputs⟩

def Environment.invokeProcedure (environment : Environment) (globals : Frame)
    (identity : Nat) (inputs : List Value) : Frame × List Value :=
  if identity ≤ environment.localProcedures.signatures.length
  then (globals, environment.localProcedures.values identity inputs)
  else environment.packages.procedures
    (originalIndex RoutineSignature.procedureSignature environment.packages.signatures
      (identity - environment.localProcedures.signatures.length)) globals inputs

def Environment.proceduresAt (environment : Environment) (globals : Frame) : ScalarProcedures.Environment :=
  ⟨environment.procedureSignatures, fun identity inputs => (environment.invokeProcedure globals identity inputs).2⟩

structure Environment.Valid (schema : StateSchema) (environment : Environment) : Prop where
  functions : environment.localFunctions.Valid
  procedures : environment.localProcedures.Valid
  packages : environment.packages.Typed schema

theorem Environment.functionsAt_valid {schema : StateSchema} {environment : Environment} {globals : Frame}
    (valid : environment.Valid schema) (fitting : schema.Fits globals) :
    (environment.functionsAt globals).Valid := by
  intro identity signature found inputs inputsFit
  rcases lookupRoutine_concat found with ⟨left, known⟩ | ⟨right, known⟩
  · simpa only [functionsAt, left, ↓reduceIte] using valid.functions identity signature known inputs inputsFit
  · obtain ⟨routine, original, selected⟩ := lookupRoutine_originalIndex known
    have kind : routine = .function signature := by
      cases routine <;> simp_all [RoutineSignature.functionSignature]
    subst routine
    have returned := valid.packages.functions _ signature original globals fitting inputs inputsFit
    simpa only [functionsAt, show ¬identity ≤ environment.localFunctions.signatures.length by omega,
      ↓reduceIte] using returned

theorem Environment.invokeProcedure_valid {schema : StateSchema} {environment : Environment} {globals : Frame}
    {identity : Nat} {signature : ScalarProcedures.Signature} {inputs : List Value}
    (valid : environment.Valid schema) (fitting : schema.Fits globals)
    (found : ScalarProcedures.lookup environment.procedureSignatures identity = some signature)
    (inputsFit : ArgumentsFit (ScalarProcedures.inputTypes signature.formals) inputs) :
    schema.Fits (environment.invokeProcedure globals identity inputs).1 ∧
      ArgumentsFit (ScalarProcedures.outputTypes signature.formals)
        (environment.invokeProcedure globals identity inputs).2 := by
  rcases lookupRoutine_concat found with ⟨left, known⟩ | ⟨right, known⟩
  · simpa only [invokeProcedure, left, ↓reduceIte] using
      And.intro fitting (valid.procedures identity signature known inputs inputsFit)
  · obtain ⟨routine, original, selected⟩ := lookupRoutine_originalIndex known
    have kind : routine = .procedure signature := by
      cases routine <;> simp_all [RoutineSignature.procedureSignature]
    subst routine
    have returned := valid.packages.procedures _ signature original globals fitting inputs inputsFit
    simpa only [invokeProcedure, show ¬identity ≤ environment.localProcedures.signatures.length by omega,
      ↓reduceIte] using returned

theorem Environment.proceduresAt_valid {schema : StateSchema} {environment : Environment} {globals : Frame}
    (valid : environment.Valid schema) (fitting : schema.Fits globals) :
    (environment.proceduresAt globals).Valid := by
  intro identity signature found inputs inputsFit
  exact (environment.invokeProcedure_valid valid fitting found inputsFit).2

end Silver.Applications
