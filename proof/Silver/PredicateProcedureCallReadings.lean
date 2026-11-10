module

public import Silver.PredicateFunctionCallReadings
public import Silver.PredicateProcedureCallProperties
public import Silver.ProcedureMetadataSemantics
public import Silver.ScalarProcedureSyntax

@[expose] public section

/-! Source readings keep the two actual passes distinct. Value actuals use the
existing expression/condition derivations and one incoming flow; writable
actuals keep the exact bare-name lookup and the executable alias traversal. -/
namespace Silver.Predicate
open Compose

def procedureInputFormal (parameter : ProcedureBindings.Formal) : FunctionBindings.Formal :=
  ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds⟩

def procedureTargetIdentity (context : ParseContext) (target : ProcedureActualResult) :
    ScalarFunctions.Target :=
  if target.scalar = 0 then .boolean target.flag
  else .integer target.scalar (ScalarExpression.binding context.scalarNames target.scalar).declaredBounds

theorem procedureTargetActual_after_bound (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) :
    (procedureTargetActual text context position facts parameter).after ≤ text.length + 1 := by
  have bound := Compose.Expressions.model_name_valid text (skipAt text position)
  dsimp only [procedureTargetActual]
  split
  · exact Nat.zero_le _
  · split
    · split
      · exact Nat.zero_le _
      · exact bound
    · split
      · exact Nat.zero_le _
      · exact bound

inductive ProcedureActualAt (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) : ScalarProcedures.Actual → Nat → Prop
  | input {actual after} : parameter.mode = .input →
      ActualAt text context position facts (procedureInputFormal parameter) actual after →
      ProcedureActualAt text context position facts parameter (.value actual) after
  | target : parameter.mode ≠ .input →
      (procedureTargetActual text context position facts parameter).after ≠ 0 →
      ProcedureActualAt text context position facts parameter
        (.target (procedureTargetIdentity context (procedureTargetActual text context position facts parameter)))
        (procedureTargetActual text context position facts parameter).after

theorem ProcedureActualAt.equation {text context position facts parameter actual after}
    (parsed : ProcedureActualAt text context position facts parameter actual after) :
    procedureActualAfter text context position facts parameter = after := by
  cases parsed with
  | input mode payload => simpa only [procedureActualAfter, mode, ↓reduceIte, procedureInputFormal] using payload.equation
  | target mode _ => simp only [procedureActualAfter, mode, ↓reduceIte]

theorem ProcedureActualAt.positive {text context position facts parameter actual after}
    (parsed : ProcedureActualAt text context position facts parameter actual after) : after ≠ 0 := by
  cases parsed with
  | input _ payload => exact payload.positive
  | target _ positive => exact positive

theorem ProcedureActualAt.bounded {text context position facts parameter actual after}
    (parsed : ProcedureActualAt text context position facts parameter actual after) : after ≤ text.length + 1 := by
  cases parsed with
  | input _ payload => exact payload.bounded
  | target => exact procedureTargetActual_after_bound ..

theorem procedureActual_sound {text context position facts parameter}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : procedureActualAfter text context position facts parameter ≠ 0) :
    ∃ actual, ProcedureActualAt text context position facts parameter actual
      (procedureActualAfter text context position facts parameter) := by
  by_cases input : parameter.mode = .input
  · simp only [procedureActualAfter, input, ↓reduceIte] at accepted ⊢
    obtain ⟨actual, parsed⟩ := actual_sound tv nv bounded accepted
    exact ⟨.value actual, .input input parsed⟩
  · simp only [procedureActualAfter, input, ↓reduceIte] at accepted ⊢
    exact ⟨_, .target input accepted⟩

theorem procedureActual_unique {text context position facts parameter left right leftAfter rightAfter}
    (one : ProcedureActualAt text context position facts parameter left leftAfter)
    (two : ProcedureActualAt text context position facts parameter right rightAfter) :
    left = right ∧ leftAfter = rightAfter := by
  refine ⟨?_, one.equation.symm.trans two.equation⟩
  cases one with
  | input mode value =>
      cases two with
      | input _ other => exact congrArg ScalarProcedures.Actual.value (actual_unique value other).1
      | target notInput _ => exact False.elim (notInput mode)
  | target notInput _ =>
      cases two with
      | input mode _ => exact False.elim (notInput mode)
      | target => rfl

inductive ProcedureActualsAt (text : Source) (context : ParseContext) (facts : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) : Nat → Nat → Nat → List ScalarProcedures.Actual → Nat → Prop
  | last {position first actual after} :
      ProcedureActualAt text context position facts (ProcedureBindings.parameter catalog first) actual after →
      fixedAfter text after ")" false ≠ 0 →
      ProcedureActualsAt text context facts catalog position first first [actual] (fixedAfter text after ")" false)
  | next {position first last actual after rest result} : first < last →
      ProcedureActualAt text context position facts (ProcedureBindings.parameter catalog first) actual after →
      fixedAfter text after "," false ≠ 0 →
      ProcedureActualsAt text context facts catalog (fixedAfter text after "," false) (first + 1) last rest result →
      ProcedureActualsAt text context facts catalog position first last (actual :: rest) result

theorem procedureActuals_sound {text context facts catalog position first last}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : procedureActualsAfter text context position facts catalog first last ≠ 0) :
    ∃ actuals, ProcedureActualsAt text context facts catalog position first last actuals
      (procedureActualsAfter text context position facts catalog first last) := by
  rw [procedureActualsAfter] at accepted ⊢
  try dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i positive
    obtain ⟨actual, parsed⟩ := procedureActual_sound tv nv bounded positive
    simp only [positive, ↓reduceIte]
    split at accepted
    · rename_i same
      subst last
      simp only [↓reduceIte] at accepted ⊢
      exact ⟨[actual], .last parsed accepted⟩
    · rename_i different
      simp only [different, ↓reduceIte]
      split at accepted
      · contradiction
      · rename_i comma
        simp only [comma, ↓reduceIte]
        split at accepted
        · rename_i within
          simp only [within, ↓reduceDIte]
          obtain ⟨rest, following⟩ := procedureActuals_sound tv nv
            (Compose.Expressions.model_fixed_valid text _ "," false parsed.bounded) accepted
          exact ⟨actual :: rest, .next within parsed comma following⟩
        · contradiction
termination_by last - first

theorem procedureActuals_unique {text context facts catalog position first last left right leftAfter rightAfter}
    (one : ProcedureActualsAt text context facts catalog position first last left leftAfter)
    (two : ProcedureActualsAt text context facts catalog position first last right rightAfter) : left = right := by
  induction one generalizing right rightAfter with
  | last parsed _ =>
      cases two with
      | last other _ => simp [(procedureActual_unique parsed other).1]
      | next within _ _ _ => omega
  | next within parsed _ rest ih =>
      cases two with
      | last => omega
      | next _ other _ following =>
          obtain ⟨same, afterSame⟩ := procedureActual_unique parsed other
          cases afterSame
          simp [same, ih following]

theorem ProcedureActualsAt.bounded {text context facts catalog position first last actuals after}
    (parsed : ProcedureActualsAt text context facts catalog position first last actuals after) :
    after ≤ text.length + 1 := by
  induction parsed with
  | last source _ => exact Compose.Expressions.model_fixed_valid text _ ")" false source.bounded
  | next _ _ _ _ ih => exact ih

def procedureWritableUpdate (scan : BodyScan) (parameter : ProcedureBindings.Formal)
    (target : ProcedureActualResult) : BodyScan :=
  if target.scalar = 0 then {scan with position := target.after, assigned := true}
  else {scan with
    position := target.after
    assigned := true
    facts := scan.facts.replace target.scalar parameter.bounds}

/-- Each writable update keeps both accepted lexical traversals. They are
source evidence to be interpreted against other actuals, not an assumed
semantic nonaliasing law. -/
inductive ProcedureUpdateAt (text : Source) (context : ParseContext) (incoming : ActiveFlow)
    (parameter : ProcedureBindings.Formal) (callFirst callAfter : Nat) :
    BodyScan → ScalarProcedures.Actual → BodyScan → Prop
  | input {scan actual after} : parameter.mode = .input →
      ActualAt text context scan.position incoming (procedureInputFormal parameter) actual after →
      scan.position < after →
      ProcedureUpdateAt text context incoming parameter callFirst callAfter scan (.value actual)
        {scan with position := after}
  | writable {scan} : parameter.mode ≠ .input →
      (procedureTargetActual text context scan.position incoming parameter).after ≠ 0 →
      callFirst ≤ (procedureTargetActual text context scan.position incoming parameter).first →
      (procedureTargetActual text context scan.position incoming parameter).after ≤ callAfter →
      ActualNameFreeTrace text
        (procedureTargetActual text context scan.position incoming parameter).first
        (procedureTargetActual text context scan.position incoming parameter).first
        (procedureTargetActual text context scan.position incoming parameter).after callFirst →
      ActualNameFreeTrace text callAfter
        (procedureTargetActual text context scan.position incoming parameter).first
        (procedureTargetActual text context scan.position incoming parameter).after
        (procedureTargetActual text context scan.position incoming parameter).after →
      ProcedureUpdateAt text context incoming parameter callFirst callAfter scan
        (.target (procedureTargetIdentity context (procedureTargetActual text context scan.position incoming parameter)))
        (procedureWritableUpdate scan parameter (procedureTargetActual text context scan.position incoming parameter))

theorem ProcedureUpdateAt.actual {text context incoming parameter callFirst callAfter scan actual result}
    (parsed : ProcedureUpdateAt text context incoming parameter callFirst callAfter scan actual result) :
    ProcedureActualAt text context scan.position incoming parameter actual result.position := by
  cases parsed with
  | input mode payload _ => exact .input mode payload
  | writable mode positive _ _ _ _ =>
      dsimp only [procedureWritableUpdate]
      split <;> exact .target mode positive

theorem procedureUpdateStep_reading {text context incoming parameter callFirst callAfter scan}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1)
    (accepted : (procedureUpdateStep text context incoming scan parameter callFirst callAfter).position ≠ 0) :
    ∃ actual, ProcedureUpdateAt text context incoming parameter callFirst callAfter scan actual
      (procedureUpdateStep text context incoming scan parameter callFirst callAfter) := by
  unfold procedureUpdateStep at accepted ⊢
  split at accepted
  · rename_i input
    simp only [input, ↓reduceIte]
    dsimp only at accepted
    split at accepted
    · contradiction
    · rename_i advanced
      simp only [advanced, ↓reduceIte]
      have nonzero : procedureActualAfter text context scan.position incoming parameter ≠ 0 := by omega
      simp only [procedureActualAfter, input, ↓reduceIte] at nonzero ⊢
      obtain ⟨actual, source⟩ := actual_sound tv nv bounded nonzero
      exact ⟨.value actual, .input input source (by
        simpa only [procedureActualAfter, input, ↓reduceIte] using Nat.lt_of_not_ge advanced)⟩
  · rename_i output
    simp only [output, ↓reduceIte]
    dsimp only at accepted
    split at accepted
    · contradiction
    · rename_i good
      simp only [good, ↓reduceIte]
      have beforeFree : actualNameFree text callFirst
          (procedureTargetActual text context scan.position incoming parameter).first
          (procedureTargetActual text context scan.position incoming parameter).first
          (procedureTargetActual text context scan.position incoming parameter).after = true := by
        apply Bool.of_not_eq_false
        intro failed
        apply good
        simp only [failed, Bool.not_false, or_true, true_or]
      have afterFree : actualNameFree text
          (procedureTargetActual text context scan.position incoming parameter).after callAfter
          (procedureTargetActual text context scan.position incoming parameter).first
          (procedureTargetActual text context scan.position incoming parameter).after = true := by
        apply Bool.of_not_eq_false
        intro failed
        apply good
        simp only [failed, Bool.not_false, or_true]
      refine ⟨_, ProcedureUpdateAt.writable output ?_ ?_ ?_
        (actualNameFree_sound beforeFree) (actualNameFree_sound afterFree)⟩
      · intro zero
        exact good (Or.inl zero)
      · exact Nat.le_of_not_gt (fun low => good (Or.inr (Or.inl low)))
      · exact Nat.le_of_not_gt (fun high => good (Or.inr (Or.inr (Or.inl high))))

inductive ProcedureUpdatesAt (text : Source) (context : ParseContext) (incoming : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) (callFirst callAfter : Nat) :
    BodyScan → Nat → Nat → List ScalarProcedures.Actual → BodyScan → Prop
  | last {scan first actual next} :
      ProcedureUpdateAt text context incoming (ProcedureBindings.parameter catalog first)
        callFirst callAfter scan actual next →
      fixedAfter text next.position ")" false ≠ 0 →
      ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first first [actual]
        (bodyToken text next (.symbol ")"))
  | next {scan first last actual next rest result} : first < last →
      ProcedureUpdateAt text context incoming (ProcedureBindings.parameter catalog first)
        callFirst callAfter scan actual next →
      fixedAfter text next.position "," false ≠ 0 →
      ProcedureUpdatesAt text context incoming catalog callFirst callAfter
        (bodyToken text next (.symbol ",")) (first + 1) last rest result →
      ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last (actual :: rest) result

theorem ProcedureUpdatesAt.actuals {text context incoming catalog callFirst callAfter scan first last actuals result}
    (parsed : ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals result) :
    ProcedureActualsAt text context incoming catalog scan.position first last actuals result.position := by
  induction parsed with
  | last step closed => exact .last step.actual closed
  | next within step comma following ih => exact .next within step.actual comma ih

theorem procedureUpdates_reading {text context incoming scan catalog first last callFirst callAfter}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1)
    (accepted : (procedureUpdatesModel text context incoming scan catalog first last callFirst callAfter).position ≠ 0) :
    ∃ actuals, ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals
      (procedureUpdatesModel text context incoming scan catalog first last callFirst callAfter) := by
  rw [procedureUpdatesModel] at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i nextPositive
    simp only [nextPositive, ↓reduceIte]
    obtain ⟨actual, source⟩ := procedureUpdateStep_reading tv nv bounded nextPositive
    split at accepted
    · rename_i same
      subst last
      simp only [↓reduceIte] at accepted ⊢
      exact ⟨[actual], .last source accepted⟩
    · rename_i different
      simp only [different, ↓reduceIte]
      split at accepted
      · contradiction
      · rename_i comma
        simp only [comma, ↓reduceIte]
        split at accepted
        · rename_i within
          simp only [within, ↓reduceDIte]
          obtain ⟨rest, following⟩ := procedureUpdates_reading
            (scan := bodyToken text
              (procedureUpdateStep text context incoming scan (ProcedureBindings.parameter catalog first) callFirst callAfter)
              (.symbol ",")) tv nv
            (Compose.Expressions.model_fixed_valid text _ "," false source.actual.bounded) accepted
          exact ⟨actual :: rest, .next within source comma following⟩
        · contradiction
termination_by last - first

structure ProcedureCallAt (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) (call : ScalarProcedures.Call) (result : BodyScan) : Prop where
  callee : call.callee = procedureCalleeAt text context scan.position catalog
  positive : call.callee ≠ 0
  updates : ProcedureUpdatesAt text context scan.facts catalog
    (fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false)
    (procedureActualsAfter text context (fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false)
      scan.facts catalog (ProcedureBindings.signature catalog call.callee).formalFirst
      ((ProcedureBindings.signature catalog call.callee).formalFirst +
        (ProcedureBindings.signature catalog call.callee).count - 1))
    {scan with position := fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false}
    (ProcedureBindings.signature catalog call.callee).formalFirst
    ((ProcedureBindings.signature catalog call.callee).formalFirst +
      (ProcedureBindings.signature catalog call.callee).count - 1) call.actuals result
  equation : procedureCallBody text context scan catalog = result

theorem procedureCall_sound {text context scan catalog}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (accepted : (procedureCallBody text context scan catalog).position ≠ 0) :
    ∃ call, ProcedureCallAt text context scan catalog call (procedureCallBody text context scan catalog) := by
  unfold procedureCallBody at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i calleePositive
    simp only [calleePositive, ↓reduceIte]
    split at accepted
    · contradiction
    · rename_i active
      simp only [active, ↓reduceIte]
      obtain ⟨actuals, updates⟩ := procedureUpdates_reading
        (scan := {scan with position := fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false}) tv nv
        (Compose.Expressions.model_fixed_valid text _ "(" false (Compose.Expressions.model_name_valid text _)) accepted
      refine ⟨⟨procedureCalleeAt text context scan.position catalog, actuals⟩, ?_⟩
      exact ⟨rfl, calleePositive, updates, by simp only [procedureCallBody, calleePositive, active, ↓reduceIte]⟩

theorem procedureCall_unique {text context scan catalog left right leftResult rightResult}
    (one : ProcedureCallAt text context scan catalog left leftResult)
    (two : ProcedureCallAt text context scan catalog right rightResult) : left = right := by
  have same := one.callee.trans two.callee.symm
  cases left with
  | mk leftIdentity leftActuals =>
    cases right with
    | mk rightIdentity rightActuals =>
      dsimp only at same
      subst rightIdentity
      have actuals := procedureActuals_unique one.updates.actuals two.updates.actuals
      cases actuals
      rfl

theorem procedureCallBody_bound (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata)
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names) :
    (procedureCallBody text context scan catalog).position ≤ text.length + 1 := by
  by_cases positive : (procedureCallBody text context scan catalog).position ≠ 0
  · obtain ⟨call, source⟩ := procedureCall_sound tv nv positive
    exact source.updates.actuals.bounded
  · have zero : (procedureCallBody text context scan catalog).position = 0 := by simpa using positive
    rw [zero]
    exact Nat.zero_le _

end Silver.Predicate
