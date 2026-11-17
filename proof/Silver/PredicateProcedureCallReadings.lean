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

structure ProcedureActualSource where
  position : Nat
  after : Nat
  actual : ScalarProcedures.Actual

/-- The trace is in written order, while its keys retain the selected formal.
Every payload is read under the same incoming flow. -/
inductive ProcedureActualsTailAt (text : Source) (context : ParseContext) (facts : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) (first last : Nat) :
    Nat → Nat → Bool → FormalSet → List (ScalarAssociations.Entry ProcedureActualSource) → Nat → Prop
  | last {position named seen actual after} :
      (procedureAssociation text position catalog first last last named).formal ≠ 0 →
      seen (procedureAssociation text position catalog first last last named).formal = false →
      ProcedureActualAt text context (procedureAssociation text position catalog first last last named).payloadFirst
        facts (ProcedureBindings.parameter catalog
          (procedureAssociation text position catalog first last last named).formal) actual after →
      fixedAfter text after ")" false ≠ 0 →
      ProcedureActualsTailAt text context facts catalog first last position last named seen
        [((procedureAssociation text position catalog first last last named).formal,
          ⟨(procedureAssociation text position catalog first last last named).payloadFirst, after, actual⟩)]
        (fixedAfter text after ")" false)
  | next {position ordinal named seen actual after rest result} : ordinal < last →
      (procedureAssociation text position catalog first last ordinal named).formal ≠ 0 →
      seen (procedureAssociation text position catalog first last ordinal named).formal = false →
      ProcedureActualAt text context (procedureAssociation text position catalog first last ordinal named).payloadFirst
        facts (ProcedureBindings.parameter catalog
          (procedureAssociation text position catalog first last ordinal named).formal) actual after →
      fixedAfter text after "," false ≠ 0 →
      ProcedureActualsTailAt text context facts catalog first last (fixedAfter text after "," false)
        (ordinal + 1) (procedureAssociation text position catalog first last ordinal named).named
        (markFormal seen (procedureAssociation text position catalog first last ordinal named).formal) rest result →
      ProcedureActualsTailAt text context facts catalog first last position ordinal named seen
        (((procedureAssociation text position catalog first last ordinal named).formal,
          ⟨(procedureAssociation text position catalog first last ordinal named).payloadFirst, after, actual⟩) :: rest) result

theorem procedureActualsTail_sound {text context facts catalog position first last ordinal named seen}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : procedureActualsTailModel text context position facts catalog first last ordinal named seen ≠ 0) :
    ∃ entries, ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries
      (procedureActualsTailModel text context position facts catalog first last ordinal named seen) := by
  rw [procedureActualsTailModel] at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i selection
    have nonzero : (procedureAssociation text position catalog first last ordinal named).formal ≠ 0 :=
      fun zero => selection (Or.inl zero)
    have fresh : seen (procedureAssociation text position catalog first last ordinal named).formal = false :=
      Bool.of_not_eq_true (fun duplicate => selection (Or.inr duplicate))
    simp only [selection, ↓reduceIte]
    split at accepted
    · contradiction
    · rename_i positive
      obtain ⟨actual, parsed⟩ := procedureActual_sound tv nv
        (procedureAssociation_payload_bound text position catalog first last ordinal named bounded) positive
      simp only [positive, ↓reduceIte]
      split at accepted
      · rename_i same
        subst ordinal
        simp only [↓reduceIte] at accepted ⊢
        exact ⟨_, .last nonzero fresh parsed accepted⟩
      · rename_i different
        simp only [different, ↓reduceIte]
        split at accepted
        · contradiction
        · rename_i comma
          simp only [comma, ↓reduceIte]
          split at accepted
          · rename_i within
            simp only [within, ↓reduceDIte]
            obtain ⟨rest, following⟩ := procedureActualsTail_sound tv nv
              (Compose.Expressions.model_fixed_valid text _ "," false parsed.bounded) accepted
            exact ⟨_, .next within nonzero fresh parsed comma following⟩
          · contradiction
termination_by last - ordinal

theorem ProcedureActualsTailAt.unique {text context facts catalog position first last ordinal named seen left right leftAfter rightAfter}
    (one : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen left leftAfter)
    (two : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen right rightAfter) :
    left = right := by
  induction one generalizing right rightAfter with
  | last _ _ parsed _ =>
      cases two with
      | last _ _ other _ =>
          obtain ⟨same, afterSame⟩ := procedureActual_unique parsed other
          cases same
          cases afterSame
          rfl
      | next within => omega
  | next within _ _ parsed _ rest ih =>
      cases two with
      | last => omega
      | next _ _ _ other _ following =>
          obtain ⟨same, afterSame⟩ := procedureActual_unique parsed other
          cases afterSame
          simp [same, ih following]

theorem ProcedureActualsTailAt.positive {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after) : after ≠ 0 := by
  induction parsed with
  | last _ _ _ positive => exact positive
  | next _ _ _ _ _ _ ih => exact ih

theorem ProcedureActualsTailAt.bounded {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    after ≤ text.length + 1 := by
  induction parsed with
  | last _ _ source _ => exact Compose.Expressions.model_fixed_valid text _ ")" false source.bounded
  | next _ _ _ _ _ _ ih => exact ih

theorem ProcedureActualsTailAt.ordinal_bound {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    ordinal ≤ last := by
  cases parsed with
  | last => exact Nat.le_refl _
  | next within => exact Nat.le_of_lt within

theorem ProcedureActualsTailAt.length {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    entries.length = last - ordinal + 1 := by
  induction parsed with
  | last => simp
  | next within _ _ _ _ _ ih => simp only [List.length_cons]; omega

theorem ProcedureActualsTailAt.fresh {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    ScalarAssociations.FreshSelections seen (entries.map Prod.fst) := by
  induction parsed with
  | last _ fresh _ _ => exact .cons fresh .nil
  | next _ _ fresh _ _ _ ih => exact .cons fresh ih

theorem ProcedureActualsTailAt.inside {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    (lower : first ≤ ordinal) :
    ∀ formal ∈ entries.map Prod.fst, first ≤ formal ∧ formal ≤ last := by
  induction parsed with
  | last selected _ _ _ =>
      intro formal present
      have same := List.mem_singleton.mp present
      subst formal
      exact procedureAssociation_formal ⟨lower, Nat.le_refl _⟩ selected
  | next within selected _ _ _ rest ih =>
      intro formal present
      rcases List.mem_cons.mp present with same | later
      · subst formal
        exact procedureAssociation_formal ⟨lower, Nat.le_of_lt within⟩ selected
      · exact ih (by omega) formal later

theorem ProcedureActualsTailAt.payloads {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    ∀ entry ∈ entries, ProcedureActualAt text context entry.2.position facts
      (ProcedureBindings.parameter catalog entry.1) entry.2.actual entry.2.after := by
  induction parsed with
  | last _ _ source _ =>
      intro entry present
      have same := List.mem_singleton.mp present
      subst entry
      exact source
  | next _ _ _ source _ rest ih =>
      intro entry present
      rcases List.mem_cons.mp present with same | later
      · subst entry
        exact source
      · exact ih entry later

def defaultProcedureActual : ProcedureActualSource := ⟨0, 0, .value defaultFunctionActual⟩

def arrangeProcedureActuals (entries : List (ScalarAssociations.Entry ProcedureActualSource))
    (first last : Nat) : List ScalarProcedures.Actual :=
  (ScalarAssociations.arrange defaultProcedureActual entries first (last - first + 1)).map (fun entry => entry.2.actual)

theorem ProcedureActualsTailAt.complete {text context facts catalog position first last named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position first named seen entries after) :
    (entries.map Prod.fst).Perm (List.range' first (last - first + 1)) := by
  apply ScalarAssociations.selections_complete parsed.fresh.nodup
  · simpa only [List.length_map] using parsed.length
  · intro formal present
    have inside := parsed.inside (Nat.le_refl _) formal present
    have ordered := parsed.ordinal_bound
    omega

theorem ProcedureActualsTailAt.forall_payloads {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    {property : Nat → ScalarProcedures.Actual → Prop}
    (one : ∀ position formal actual after,
      ProcedureActualAt text context position facts (ProcedureBindings.parameter catalog formal) actual after →
      property formal actual) : ∀ entry ∈ entries, property entry.1 entry.2.actual := by
  induction parsed with
  | last _ _ source _ =>
      intro entry present
      have same := List.mem_singleton.mp present
      subst entry
      exact one _ _ _ _ source
  | next _ _ _ source _ rest ih =>
      intro entry present
      rcases List.mem_cons.mp present with same | later
      · subst entry
        exact one _ _ _ _ source
      · exact ih entry later

/-- The external call meaning stays in formal order; the source trace separately
records arbitrary named order and the positional-prefix/named-suffix state. -/
inductive ProcedureActualsAt (text : Source) (context : ParseContext) (facts : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) : Nat → Nat → Nat → List ScalarProcedures.Actual → Nat → Prop
  | actuals {position first last entries after} :
      ProcedureActualsTailAt text context facts catalog first last position first false noFormals entries after →
      ProcedureActualsAt text context facts catalog position first last (arrangeProcedureActuals entries first last) after

theorem procedureActuals_sound {text context facts catalog position first last}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : procedureActualsAfter text context position facts catalog first last ≠ 0) :
    ∃ actuals, ProcedureActualsAt text context facts catalog position first last actuals
      (procedureActualsAfter text context position facts catalog first last) := by
  obtain ⟨entries, parsed⟩ := procedureActualsTail_sound tv nv bounded accepted
  exact ⟨arrangeProcedureActuals entries first last, .actuals parsed⟩

theorem procedureActuals_unique {text context facts catalog position first last left right leftAfter rightAfter}
    (one : ProcedureActualsAt text context facts catalog position first last left leftAfter)
    (two : ProcedureActualsAt text context facts catalog position first last right rightAfter) : left = right := by
  cases one with
  | actuals source =>
      cases two with
      | actuals other => rw [source.unique other]

theorem ProcedureActualsAt.forall_payloads {text context facts catalog position first last actuals after}
    (parsed : ProcedureActualsAt text context facts catalog position first last actuals after)
    {property : ScalarProcedures.Actual → Prop}
    (one : ∀ position formal actual after,
      ProcedureActualAt text context position facts (ProcedureBindings.parameter catalog formal) actual after → property actual) :
    ∀ actual ∈ actuals, property actual := by
  cases parsed with
  | actuals source =>
      have original := source.forall_payloads one
      have arranged := ScalarAssociations.arrange_all defaultProcedureActual source.fresh.nodup source.complete original
      intro actual present
      obtain ⟨entry, member, same⟩ := List.mem_map.mp present
      subst actual
      exact arranged entry member

theorem ProcedureActualsAt.positive {text context facts catalog position first last actuals after}
    (parsed : ProcedureActualsAt text context facts catalog position first last actuals after) : after ≠ 0 := by
  cases parsed with
  | actuals source => exact source.positive

theorem ProcedureActualsAt.bounded {text context facts catalog position first last actuals after}
    (parsed : ProcedureActualsAt text context facts catalog position first last actuals after) :
    after ≤ text.length + 1 := by
  cases parsed with
  | actuals source => exact source.bounded

def procedureWritableUpdate (scan : BodyScan) (parameter : ProcedureBindings.Formal)
    (target : ProcedureActualResult) : BodyScan :=
  if target.scalar = 0 then {scan with position := target.after, assigned := true}
  else {scan with
    position := target.after
    assigned := true
    facts := scan.facts.replace target.scalar parameter.bounds}

/-- The replay follows associations from the original call start and invokes
the existing lexical scanner only on payloads. Selector labels are never reads. -/
inductive ProcedureUpdateAt (text : Source) (context : ParseContext) (incoming : ActiveFlow)
    (parameter : ProcedureBindings.Formal) (catalog : ProcedureBindings.Metadata)
    (first last callFirst callAfter : Nat) : BodyScan → ScalarProcedures.Actual → BodyScan → Prop
  | input {scan actual after} : parameter.mode = .input →
      ActualAt text context scan.position incoming (procedureInputFormal parameter) actual after →
      scan.position < after →
      ProcedureUpdateAt text context incoming parameter catalog first last callFirst callAfter scan (.value actual)
        {scan with position := after}
  | writable {scan} : parameter.mode ≠ .input →
      (procedureTargetActual text context scan.position incoming parameter).after ≠ 0 →
      callFirst ≤ (procedureTargetActual text context scan.position incoming parameter).first →
      (procedureTargetActual text context scan.position incoming parameter).after ≤ callAfter →
      procedurePayloadsFree text context callFirst incoming catalog first last callAfter
        (procedureTargetActual text context scan.position incoming parameter).first
        (procedureTargetActual text context scan.position incoming parameter).after = true →
      ProcedureUpdateAt text context incoming parameter catalog first last callFirst callAfter scan
        (.target (procedureTargetIdentity context (procedureTargetActual text context scan.position incoming parameter)))
        (procedureWritableUpdate scan parameter (procedureTargetActual text context scan.position incoming parameter))

theorem ProcedureUpdateAt.actual {text context incoming parameter catalog first last callFirst callAfter scan actual result}
    (parsed : ProcedureUpdateAt text context incoming parameter catalog first last callFirst callAfter scan actual result) :
    ProcedureActualAt text context scan.position incoming parameter actual result.position := by
  cases parsed with
  | input mode payload _ => exact .input mode payload
  | writable mode positive _ _ _ =>
      dsimp only [procedureWritableUpdate]
      split <;> exact .target mode positive

theorem procedureUpdateStep_reading {text context incoming parameter catalog first last callFirst callAfter scan}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1)
    (accepted : (procedureUpdateStep text context incoming scan parameter catalog first last callFirst callAfter).position ≠ 0) :
    ∃ actual, ProcedureUpdateAt text context incoming parameter catalog first last callFirst callAfter scan actual
      (procedureUpdateStep text context incoming scan parameter catalog first last callFirst callAfter) := by
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
      have free : procedurePayloadsFree text context callFirst incoming catalog first last callAfter
          (procedureTargetActual text context scan.position incoming parameter).first
          (procedureTargetActual text context scan.position incoming parameter).after = true := by
        apply Bool.of_not_eq_false
        intro failed
        apply good
        simp only [failed, Bool.not_false, or_true]
      refine ⟨_, ProcedureUpdateAt.writable output ?_ ?_ ?_ free⟩
      · intro zero
        exact good (Or.inl zero)
      · exact Nat.le_of_not_gt (fun low => good (Or.inr (Or.inl low)))
      · exact Nat.le_of_not_gt (fun high => good (Or.inr (Or.inr (Or.inl high))))

inductive ProcedureUpdatesTailAt (text : Source) (context : ParseContext) (incoming : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) :
    BodyScan → Nat → Bool → FormalSet → List (ScalarAssociations.Entry ProcedureActualSource) → BodyScan → Prop
  | last {scan named seen actual next} :
      (procedureAssociation text scan.position catalog first last last named).formal ≠ 0 →
      seen (procedureAssociation text scan.position catalog first last last named).formal = false →
      ProcedureUpdateAt text context incoming
        (ProcedureBindings.parameter catalog (procedureAssociation text scan.position catalog first last last named).formal)
        catalog first last callFirst callAfter
        {scan with position := (procedureAssociation text scan.position catalog first last last named).payloadFirst} actual next →
      fixedAfter text next.position ")" false ≠ 0 →
      ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan last named seen
        [((procedureAssociation text scan.position catalog first last last named).formal,
          ⟨(procedureAssociation text scan.position catalog first last last named).payloadFirst, next.position, actual⟩)]
        (bodyToken text next (.symbol ")"))
  | next {scan ordinal named seen actual next rest result} : ordinal < last →
      (procedureAssociation text scan.position catalog first last ordinal named).formal ≠ 0 →
      seen (procedureAssociation text scan.position catalog first last ordinal named).formal = false →
      ProcedureUpdateAt text context incoming
        (ProcedureBindings.parameter catalog (procedureAssociation text scan.position catalog first last ordinal named).formal)
        catalog first last callFirst callAfter
        {scan with position := (procedureAssociation text scan.position catalog first last ordinal named).payloadFirst} actual next →
      fixedAfter text next.position "," false ≠ 0 →
      ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter
        (bodyToken text next (.symbol ",")) (ordinal + 1)
        (procedureAssociation text scan.position catalog first last ordinal named).named
        (markFormal seen (procedureAssociation text scan.position catalog first last ordinal named).formal) rest result →
      ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan ordinal named seen
        (((procedureAssociation text scan.position catalog first last ordinal named).formal,
          ⟨(procedureAssociation text scan.position catalog first last ordinal named).payloadFirst, next.position, actual⟩) :: rest) result

theorem ProcedureUpdatesTailAt.actuals {text context incoming catalog first last callFirst callAfter scan ordinal named seen entries result}
    (parsed : ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan ordinal named seen entries result) :
    ProcedureActualsTailAt text context incoming catalog first last scan.position ordinal named seen entries result.position := by
  induction parsed with
  | last selected fresh step closed => exact .last selected fresh step.actual closed
  | next within selected fresh step comma following ih => exact .next within selected fresh step.actual comma ih

theorem procedureUpdatesTail_reading {text context incoming scan catalog first last ordinal named seen callFirst callAfter}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1)
    (accepted : (procedureUpdatesTailModel text context incoming scan catalog first last ordinal named seen callFirst callAfter).position ≠ 0) :
    ∃ entries, ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan ordinal named seen entries
      (procedureUpdatesTailModel text context incoming scan catalog first last ordinal named seen callFirst callAfter) := by
  rw [procedureUpdatesTailModel] at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i selection
    have nonzero : (procedureAssociation text scan.position catalog first last ordinal named).formal ≠ 0 :=
      fun zero => selection (Or.inl zero)
    have fresh : seen (procedureAssociation text scan.position catalog first last ordinal named).formal = false :=
      Bool.of_not_eq_true (fun duplicate => selection (Or.inr duplicate))
    simp only [selection, ↓reduceIte]
    split at accepted
    · contradiction
    · rename_i nextPositive
      simp only [nextPositive, ↓reduceIte]
      obtain ⟨actual, source⟩ := procedureUpdateStep_reading tv nv
        (procedureAssociation_payload_bound text scan.position catalog first last ordinal named bounded) nextPositive
      split at accepted
      · rename_i same
        subst ordinal
        simp only [↓reduceIte] at accepted ⊢
        exact ⟨_, .last nonzero fresh source accepted⟩
      · rename_i different
        simp only [different, ↓reduceIte]
        split at accepted
        · contradiction
        · rename_i comma
          simp only [comma, ↓reduceIte]
          split at accepted
          · rename_i within
            simp only [within, ↓reduceDIte]
            obtain ⟨rest, following⟩ := procedureUpdatesTail_reading
              (scan := bodyToken text
                (procedureUpdateStep text context incoming
                  {scan with position := (procedureAssociation text scan.position catalog first last ordinal named).payloadFirst}
                  (ProcedureBindings.parameter catalog (procedureAssociation text scan.position catalog first last ordinal named).formal)
                  catalog first last callFirst callAfter) (.symbol ",")) tv nv
              (Compose.Expressions.model_fixed_valid text _ "," false source.actual.bounded) accepted
            exact ⟨_, .next within nonzero fresh source comma following⟩
          · contradiction
termination_by last - ordinal

inductive ProcedureUpdatesAt (text : Source) (context : ParseContext) (incoming : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) (callFirst callAfter : Nat) :
    BodyScan → Nat → Nat → List ScalarProcedures.Actual → BodyScan → Prop
  | updates {scan first last entries result} :
      ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan first false noFormals entries result →
      ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last
        (arrangeProcedureActuals entries first last) result

theorem ProcedureUpdatesAt.actuals {text context incoming catalog callFirst callAfter scan first last actuals result}
    (parsed : ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals result) :
    ProcedureActualsAt text context incoming catalog scan.position first last actuals result.position := by
  cases parsed with
  | updates source => exact .actuals source.actuals

theorem procedureUpdates_reading {text context incoming scan catalog first last callFirst callAfter}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1)
    (accepted : (procedureUpdatesModel text context incoming scan catalog first last callFirst callAfter).position ≠ 0) :
    ∃ actuals, ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals
      (procedureUpdatesModel text context incoming scan catalog first last callFirst callAfter) := by
  obtain ⟨entries, source⟩ := procedureUpdatesTail_reading tv nv bounded accepted
  exact ⟨arrangeProcedureActuals entries first last, .updates source⟩

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
