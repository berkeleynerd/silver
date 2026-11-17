module

public import Silver.PredicateAssociationNative

@[expose] public section

namespace Silver.Predicate.AssociationNative
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- Every native Formal_Set cell is retained. The zero/outside extension is
only a total mathematical read and supplies no additional accepted index. -/
abbrev FormalStorage := Fin FunctionBindings.maxFormals → Bool

def FormalStorage.read (storage : FormalStorage) (index : Nat) : Bool :=
  if bound : 0 < index ∧ index ≤ FunctionBindings.maxFormals then
    storage ⟨index - 1, by omega⟩
  else false

def FormalStorage.empty : FormalStorage := fun _ => false

def FormalStorage.mark (storage : FormalStorage) (index : Nat) : FormalStorage :=
  fun cell => if cell.val + 1 = index then true else storage cell

theorem FormalStorage.read_empty : FormalStorage.empty.read = noFormals := by
  funext index
  simp [FormalStorage.read, FormalStorage.empty, noFormals, ScalarAssociations.noFormals]

theorem FormalStorage.read_mark (storage : FormalStorage) (index : Nat)
    (bound : 0 < index ∧ index ≤ FunctionBindings.maxFormals) :
    (storage.mark index).read = markFormal storage.read index := by
  funext selected
  by_cases inside : 0 < selected ∧ selected ≤ FunctionBindings.maxFormals
  · have positive := inside.1
    simp only [FormalStorage.read, inside, FormalStorage.mark,
      markFormal, ScalarAssociations.markFormal]
    have restore : selected - 1 + 1 = selected := by omega
    simp [restore]
  · have different : selected ≠ index := by intro equal; subst selected; exact inside bound
    simp [FormalStorage.read, inside, markFormal,
      ScalarAssociations.markFormal, different]

theorem functionFormal_model (text : Source) (catalog : FunctionBindings.Metadata)
    (first last nameFirst nameAfter : Nat) (ordered : first ≤ last) :
    functionFormalBody.eval modelCalls ({text,functions := catalog,first,last,nameFirst,nameAfter} : Frame).locals =
      functionFormalModel text catalog first last nameFirst nameAfter := by
  rw [functionFormalModel]
  dsimp +instances only [List.foldr, functionFormalBody, Expr.eval, modelCalls, Frame.locals,
    Locals.set, Field.get, apply2, apply3, apply5, apply6]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true]
  by_cases final : first = last
  · simp only [final, ↓reduceIte]
  · have advancing : first < last := by omega
    simp only [final, advancing, ↓reduceIte, ↓reduceDIte]

theorem procedureFormal_model (text : Source) (catalog : ProcedureBindings.Metadata)
    (first last nameFirst nameAfter : Nat) (ordered : first ≤ last) :
    procedureFormalBody.eval modelCalls ({text,procedures := catalog,first,last,nameFirst,nameAfter} : Frame).locals =
      procedureFormalModel text catalog first last nameFirst nameAfter := by
  rw [procedureFormalModel]
  dsimp +instances only [List.foldr, procedureFormalBody, Expr.eval, modelCalls, Frame.locals,
    Locals.set, Field.get, apply2, apply3, apply5, apply6]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true]
  by_cases final : first = last
  · simp only [final, ↓reduceIte]
  · have advancing : first < last := by omega
    simp only [final, advancing, ↓reduceIte, ↓reduceDIte]

theorem functionAssociation_model (text : Source) (position : Nat) (catalog : FunctionBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) :
    functionAssociationBody.eval modelCalls ({text,position,functions := catalog,first,last,ordinal,named} : Frame).locals =
      functionAssociation text position catalog first last ordinal named := by
  dsimp +instances only [List.foldr, Token.shell, functionAssociationBody, Expr.eval, modelCalls,
    Frame.locals, Locals.set, Field.get, apply2, apply3, apply5, apply6, functionAssociation,
    tokenAfter, ShellToken.symbol]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]

theorem procedureAssociation_model (text : Source) (position : Nat) (catalog : ProcedureBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) :
    procedureAssociationBody.eval modelCalls ({text,position,procedures := catalog,first,last,ordinal,named} : Frame).locals =
      procedureAssociation text position catalog first last ordinal named := by
  dsimp +instances only [List.foldr, Token.shell, procedureAssociationBody, Expr.eval, modelCalls,
    Frame.locals, Locals.set, Field.get, apply2, apply3, apply5, apply6, procedureAssociation,
    tokenAfter, ShellToken.symbol]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]

end Silver.Predicate.AssociationNative
