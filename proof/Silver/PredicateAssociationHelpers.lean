module

public import Silver.PredicateAssociationEquations
public import Silver.FunctionBindingsNativeEquations
public import Silver.ProcedureBindingsNativeEquations
public import Silver.ComposeContracts

@[expose] public section

namespace Silver.Predicate.AssociationNative
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- Mark_Formal has no Pre; its index subtype is the complete input restriction. -/
def MarkDomain (formal : Nat) : Prop :=
  0 < formal ∧ formal ≤ FunctionBindings.maxFormals

def CursorDomain (text : Source) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position

def EqualDomain (text : Source) (first after otherFirst otherAfter : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidName text first after ∧ Expressions.ValidName text otherFirst otherAfter

def FunctionFormalDomain (text : Source) (catalog : FunctionBindings.Metadata)
    (first last nameFirst nameAfter : Nat) : Prop :=
  Expressions.ValidText text ∧ FunctionBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ last ∧ last ≤ catalog.parameters.length ∧
    Expressions.ValidCursor text nameFirst ∧ Expressions.ValidCursor text nameAfter

def ProcedureFormalDomain (text : Source) (catalog : ProcedureBindings.Metadata)
    (first last nameFirst nameAfter : Nat) : Prop :=
  Expressions.ValidText text ∧ ProcedureBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ last ∧ last ≤ catalog.parameters.length ∧
    Expressions.ValidCursor text nameFirst ∧ Expressions.ValidCursor text nameAfter

def FunctionAssociationDomain (text : Source) (position : Nat) (catalog : FunctionBindings.Metadata)
    (first last ordinal : Nat) : Prop :=
  CursorDomain text position ∧ FunctionBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ ordinal ∧ ordinal ≤ last ∧ last ≤ catalog.parameters.length

def ProcedureAssociationDomain (text : Source) (position : Nat) (catalog : ProcedureBindings.Metadata)
    (first last ordinal : Nat) : Prop :=
  CursorDomain text position ∧ ProcedureBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ ordinal ∧ ordinal ≤ last ∧ last ≤ catalog.parameters.length

/-- These domains are the complete native preconditions, including zero
cursors, invalid query spans and arbitrary valid metadata. The total extension
does not assert uniqueness of formal spellings or successful resolution. -/
noncomputable def totalizeCalls (calls : Calls) : Calls := by
  classical
  exact fun
    | .markFormal => fun seen formal =>
        if MarkDomain formal then calls .markFormal seen formal else modelCalls .markFormal seen formal
    | .skip => fun text position =>
        if CursorDomain text position then calls .skip text position else modelCalls .skip text position
    | .nameAfter => fun text position =>
        if CursorDomain text position then calls .nameAfter text position else modelCalls .nameAfter text position
    | .equalName => fun text first after otherFirst otherAfter =>
        if EqualDomain text first after otherFirst otherAfter then
          calls .equalName text first after otherFirst otherAfter else modelCalls .equalName text first after otherFirst otherAfter
    | .token => fun text position token =>
        if CursorDomain text position ∧ token = .symbol "=>" then
          calls .token text position token else modelCalls .token text position token
    | .functionFormalModel => fun text catalog first last nameFirst nameAfter =>
        if FunctionFormalDomain text catalog first last nameFirst nameAfter then
          calls .functionFormalModel text catalog first last nameFirst nameAfter
        else modelCalls .functionFormalModel text catalog first last nameFirst nameAfter
    | .functionFormalAt => fun text catalog first last nameFirst nameAfter =>
        if FunctionFormalDomain text catalog first last nameFirst nameAfter then
          calls .functionFormalAt text catalog first last nameFirst nameAfter
        else modelCalls .functionFormalAt text catalog first last nameFirst nameAfter
    | .procedureFormalModel => fun text catalog first last nameFirst nameAfter =>
        if ProcedureFormalDomain text catalog first last nameFirst nameAfter then
          calls .procedureFormalModel text catalog first last nameFirst nameAfter
        else modelCalls .procedureFormalModel text catalog first last nameFirst nameAfter
    | .procedureFormalAt => fun text catalog first last nameFirst nameAfter =>
        if ProcedureFormalDomain text catalog first last nameFirst nameAfter then
          calls .procedureFormalAt text catalog first last nameFirst nameAfter
        else modelCalls .procedureFormalAt text catalog first last nameFirst nameAfter
    | .functionAssociation => fun text position catalog first last ordinal named =>
        if FunctionAssociationDomain text position catalog first last ordinal then
          calls .functionAssociation text position catalog first last ordinal named
        else modelCalls .functionAssociation text position catalog first last ordinal named
    | .procedureAssociation => fun text position catalog first last ordinal named =>
        if ProcedureAssociationDomain text position catalog first last ordinal then
          calls .procedureAssociation text position catalog first last ordinal named
        else modelCalls .procedureAssociation text position catalog first last ordinal named

structure ImportsMeaning (calls : Calls) : Prop where
  skip : totalizeCalls calls .skip = modelCalls .skip
  nameAfter : totalizeCalls calls .nameAfter = modelCalls .nameAfter
  equalName : totalizeCalls calls .equalName = modelCalls .equalName
  token : totalizeCalls calls .token = modelCalls .token

structure DefinitionEquations (calls : Calls) : Prop where
  markFormal : ∀ seen formal, MarkDomain formal →
    calls .markFormal seen formal = markFormalBody.eval (totalizeCalls calls) ({seen,formal} : Frame).locals
  functionFormalModel : ∀ text catalog first last nameFirst nameAfter,
    FunctionFormalDomain text catalog first last nameFirst nameAfter →
    calls .functionFormalModel text catalog first last nameFirst nameAfter =
      functionFormalBody.eval (totalizeCalls calls) ({text,functions := catalog,first,last,nameFirst,nameAfter} : Frame).locals
  functionFormalAt : ∀ text catalog first last nameFirst nameAfter,
    FunctionFormalDomain text catalog first last nameFirst nameAfter →
    calls .functionFormalAt text catalog first last nameFirst nameAfter =
      calls .functionFormalModel text catalog first last nameFirst nameAfter
  procedureFormalModel : ∀ text catalog first last nameFirst nameAfter,
    ProcedureFormalDomain text catalog first last nameFirst nameAfter →
    calls .procedureFormalModel text catalog first last nameFirst nameAfter =
      procedureFormalBody.eval (totalizeCalls calls) ({text,procedures := catalog,first,last,nameFirst,nameAfter} : Frame).locals
  procedureFormalAt : ∀ text catalog first last nameFirst nameAfter,
    ProcedureFormalDomain text catalog first last nameFirst nameAfter →
    calls .procedureFormalAt text catalog first last nameFirst nameAfter =
      calls .procedureFormalModel text catalog first last nameFirst nameAfter
  functionAssociation : ∀ text position catalog first last ordinal named,
    FunctionAssociationDomain text position catalog first last ordinal →
    calls .functionAssociation text position catalog first last ordinal named =
      functionAssociationBody.eval (totalizeCalls calls) ({text,position,functions := catalog,first,last,ordinal,named} : Frame).locals
  procedureAssociation : ∀ text position catalog first last ordinal named,
    ProcedureAssociationDomain text position catalog first last ordinal →
    calls .procedureAssociation text position catalog first last ordinal named =
      procedureAssociationBody.eval (totalizeCalls calls) ({text,position,procedures := catalog,first,last,ordinal,named} : Frame).locals

variable {calls : Calls}

theorem normalized_markFormal (defs : DefinitionEquations calls) :
    totalizeCalls calls .markFormal = modelCalls .markFormal := by
  classical
  funext seen formal
  change (if MarkDomain formal then _ else _) = _
  split
  · rename_i valid
    rw [defs.markFormal seen formal valid]
    simp [markFormalBody, Expr.eval, Frame.locals, Locals.set, modelCalls]
  · rfl

theorem normalized_functionFormalModel_at (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (catalog : FunctionBindings.Metadata) (first last nameFirst nameAfter : Nat) :
    totalizeCalls calls .functionFormalModel text catalog first last nameFirst nameAfter =
      modelCalls .functionFormalModel text catalog first last nameFirst nameAfter := by
  classical
  change (if FunctionFormalDomain text catalog first last nameFirst nameAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.functionFormalModel text catalog first last nameFirst nameAfter valid]
    dsimp +instances only [List.foldr, functionFormalBody, Expr.eval, Frame.locals, Locals.set, Field.get, apply2, apply3, apply5, apply6]
    simp only [meaning.equalName, modelCalls, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
    change (if decide (nameFirst = 0) || decide (nameAfter ≤ nameFirst) then _ else _) =
      functionFormalModel text catalog first last nameFirst nameAfter
    rw [functionFormalModel]
    simp only [decide_eq_true_eq, Bool.or_eq_true]
    by_cases bad : nameFirst = 0 ∨ nameAfter ≤ nameFirst
    · simp only [bad, ↓reduceIte]
    · simp only [bad, ↓reduceIte]
      split
      · rfl
      · by_cases final : first = last
        · simp only [final, ↓reduceIte]
        · have advancing : first < last := by have ordered := valid.2.2.2.1; omega
          simp only [final, advancing, ↓reduceIte, ↓reduceDIte]
          exact normalized_functionFormalModel_at meaning defs text catalog (first + 1) last nameFirst nameAfter
  · rfl
termination_by last - first
decreasing_by omega

theorem normalized_procedureFormalModel_at (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (catalog : ProcedureBindings.Metadata) (first last nameFirst nameAfter : Nat) :
    totalizeCalls calls .procedureFormalModel text catalog first last nameFirst nameAfter =
      modelCalls .procedureFormalModel text catalog first last nameFirst nameAfter := by
  classical
  change (if ProcedureFormalDomain text catalog first last nameFirst nameAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.procedureFormalModel text catalog first last nameFirst nameAfter valid]
    dsimp +instances only [List.foldr, procedureFormalBody, Expr.eval, Frame.locals, Locals.set, Field.get, apply2, apply3, apply5, apply6]
    simp only [meaning.equalName, modelCalls, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
    change (if decide (nameFirst = 0) || decide (nameAfter ≤ nameFirst) then _ else _) =
      procedureFormalModel text catalog first last nameFirst nameAfter
    rw [procedureFormalModel]
    simp only [decide_eq_true_eq, Bool.or_eq_true]
    by_cases bad : nameFirst = 0 ∨ nameAfter ≤ nameFirst
    · simp only [bad, ↓reduceIte]
    · simp only [bad, ↓reduceIte]
      split
      · rfl
      · by_cases final : first = last
        · simp only [final, ↓reduceIte]
        · have advancing : first < last := by have ordered := valid.2.2.2.1; omega
          simp only [final, advancing, ↓reduceIte, ↓reduceDIte]
          exact normalized_procedureFormalModel_at meaning defs text catalog (first + 1) last nameFirst nameAfter
  · rfl
termination_by last - first
decreasing_by omega

theorem normalized_functionFormalModel (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .functionFormalModel = modelCalls .functionFormalModel := by
  funext text catalog first last nameFirst nameAfter
  exact normalized_functionFormalModel_at meaning defs text catalog first last nameFirst nameAfter

theorem normalized_procedureFormalModel (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .procedureFormalModel = modelCalls .procedureFormalModel := by
  funext text catalog first last nameFirst nameAfter
  exact normalized_procedureFormalModel_at meaning defs text catalog first last nameFirst nameAfter

theorem normalized_functionFormalAt (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .functionFormalAt = modelCalls .functionFormalAt := by
  classical
  funext text catalog first last nameFirst nameAfter
  change (if FunctionFormalDomain text catalog first last nameFirst nameAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.functionFormalAt text catalog first last nameFirst nameAfter valid]
    have result := normalized_functionFormalModel_at meaning defs text catalog first last nameFirst nameAfter
    simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result
  · rfl

theorem normalized_procedureFormalAt (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .procedureFormalAt = modelCalls .procedureFormalAt := by
  classical
  funext text catalog first last nameFirst nameAfter
  change (if ProcedureFormalDomain text catalog first last nameFirst nameAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.procedureFormalAt text catalog first last nameFirst nameAfter valid]
    have result := normalized_procedureFormalModel_at meaning defs text catalog first last nameFirst nameAfter
    simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result
  · rfl

theorem normalized_functionAssociation (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .functionAssociation = modelCalls .functionAssociation := by
  classical
  funext text position catalog first last ordinal named
  change (if FunctionAssociationDomain text position catalog first last ordinal then _ else _) = _
  split
  · rename_i valid
    rw [defs.functionAssociation text position catalog first last ordinal named valid]
    calc
      _ = functionAssociationBody.eval modelCalls
          ({text,position,functions := catalog,first,last,ordinal,named} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, functionAssociationBody, Expr.eval,
          Frame.locals, Locals.set, Field.get, apply2, apply3, apply5, apply6]
        simp only [meaning.skip, meaning.nameAfter, meaning.token, normalized_functionFormalAt meaning defs]
      _ = _ := functionAssociation_model ..
  · rfl

theorem normalized_procedureAssociation (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .procedureAssociation = modelCalls .procedureAssociation := by
  classical
  funext text position catalog first last ordinal named
  change (if ProcedureAssociationDomain text position catalog first last ordinal then _ else _) = _
  split
  · rename_i valid
    rw [defs.procedureAssociation text position catalog first last ordinal named valid]
    calc
      _ = procedureAssociationBody.eval modelCalls
          ({text,position,procedures := catalog,first,last,ordinal,named} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, procedureAssociationBody, Expr.eval,
          Frame.locals, Locals.set, Field.get, apply2, apply3, apply5, apply6]
        simp only [meaning.skip, meaning.nameAfter, meaning.token, normalized_procedureFormalAt meaning defs]
      _ = _ := procedureAssociation_model ..
  · rfl

theorem totalize_model : totalizeCalls modelCalls = modelCalls := by
  funext fn
  cases fn <;> dsimp only [totalizeCalls] <;>
    funext <;> split <;> rfl

theorem model_imports_meaning : ImportsMeaning modelCalls := by
  constructor <;> rw [totalize_model]

theorem model_definitions : DefinitionEquations modelCalls where
  markFormal seen formal _ := by
    rw [totalize_model]
    exact (markFormal_model seen formal).symm
  functionFormalModel text catalog first last nameFirst nameAfter valid := by
    rw [totalize_model]
    exact (functionFormal_model text catalog first last nameFirst nameAfter valid.2.2.2.1).symm
  functionFormalAt := by intros; rfl
  procedureFormalModel text catalog first last nameFirst nameAfter valid := by
    rw [totalize_model]
    exact (procedureFormal_model text catalog first last nameFirst nameAfter valid.2.2.2.1).symm
  procedureFormalAt := by intros; rfl
  functionAssociation text position catalog first last ordinal named _ := by
    rw [totalize_model]
    exact (functionAssociation_model text position catalog first last ordinal named).symm
  procedureAssociation text position catalog first last ordinal named _ := by
    rw [totalize_model]
    exact (procedureAssociation_model text position catalog first last ordinal named).symm

end Silver.Predicate.AssociationNative
