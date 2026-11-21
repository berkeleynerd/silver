module

public import Silver.PredicateCallAdmission
public import Silver.PredicateFunctionCallTypes
public import Silver.PredicateAssociationBounds
public import Silver.PredicateBodyScanner
public import Silver.PredicateConditionSound
public import Silver.PredicateConditionUnique
public import Silver.ScalarCallChecking

@[expose] public section

namespace Silver.Predicate
open Compose

/-- The payload preserves the existing independent expression reading. The
formal domain only checks containment after the expression has been read. -/
inductive ActualPayload (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (formal : FunctionBindings.Formal) : ScalarFunctions.Actual → Prop
  | integer {expression} : formal.kind = .integer →
      ScalarExpression.At (elaborating := context.elaborating) (arrays := context.arrayNames)
        text (context.readingNames facts) position expression (readScalarInFlow text context position facts) →
      (readScalarInFlow text context position facts).bounds.isEmpty = false →
      (readScalarInFlow text context position facts).bounds.included formal.bounds = true →
      ActualPayload text context position facts formal (.integer expression)
  | boolean {condition} : formal.kind = .boolean →
      ConditionAt text context position facts condition (readCondition text context position facts) →
      ActualPayload text context position facts formal (.boolean condition)

structure ActualAt (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (formal : FunctionBindings.Formal) (actual : ScalarFunctions.Actual)
    (after : Nat) : Prop where
  equation : actualAfter text context position facts formal = after
  positive : after ≠ 0
  bounded : after ≤ text.length + 1
  payload : ActualPayload text context position facts formal actual

theorem actual_sound {text context position facts formal}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : actualAfter text context position facts formal ≠ 0) :
    ∃ actual, ActualAt text context position facts formal actual
      (actualAfter text context position facts formal) := by
  by_cases boolean : formal.kind = .boolean
  · have positive : (readCondition text context position facts).after ≠ 0 := by
      simpa only [actualAfter, boolean, ↓reduceIte] using accepted
    obtain ⟨⟨condition, parsed⟩, bound⟩ := condition_sound text context position facts tv nv bounded positive
    exact ⟨.boolean condition, ⟨rfl, accepted,
      by simpa only [actualAfter, boolean, ↓reduceIte] using bound, .boolean boolean parsed⟩⟩
  · have integer : formal.kind = .integer := by cases kind : formal.kind <;> simp_all
    simp only [actualAfter, boolean, ↓reduceIte] at accepted ⊢
    split at accepted
    · contradiction
    · rename_i allowed
      have good : (readScalarInFlow text context position facts).after ≠ 0 ∧
          (readScalarInFlow text context position facts).bounds.isEmpty = false ∧
          (readScalarInFlow text context position facts).bounds.included formal.bounds = true := by
        refine ⟨fun failed => allowed (Or.inl failed),
          Bool.of_not_eq_true (fun empty => allowed (Or.inr (Or.inl empty))), ?_⟩
        apply Bool.of_not_eq_false
        intro excluded
        exact allowed (Or.inr (Or.inr (by simp only [excluded, Bool.not_false])))
      obtain ⟨expression, parsed⟩ := ScalarExpression.read_sound bounded good.1
      refine ⟨.integer expression, ?_⟩
      simp only [allowed, ↓reduceIte]
      exact ⟨by simp only [actualAfter, boolean, allowed, ↓reduceIte], good.1,
        parsed.cursorBounds.2.2, .integer integer parsed good.2.1 good.2.2⟩

theorem actual_unique {text context position facts formal left right leftAfter rightAfter}
    (first : ActualAt text context position facts formal left leftAfter)
    (second : ActualAt text context position facts formal right rightAfter) :
    left = right ∧ leftAfter = rightAfter := by
  refine ⟨?_, first.equation.symm.trans second.equation⟩
  cases first.payload with
  | integer kind parsed _ _ =>
      cases second.payload with
      | integer _ other _ _ => exact congrArg ScalarFunctions.Actual.integer (ScalarExpression.at_unique parsed other).1
      | boolean other _ => simp [kind] at other
  | boolean kind parsed =>
      cases second.payload with
      | integer other _ _ _ => simp [kind] at other
      | boolean _ other => exact congrArg ScalarFunctions.Actual.boolean (condition_unique parsed other)

/-- The trace is in written order, while its keys retain the selected formal.
Every payload is read under the same incoming flow. -/
inductive ActualsTailAt (text : Source) (context : ParseContext) (facts : ActiveFlow)
    (catalog : FunctionBindings.Metadata) (first last : Nat) :
    Nat → Nat → Bool → FormalSet → List (ScalarAssociations.Entry ScalarFunctions.Actual) → Nat → Prop
  | last {position named seen actual after} :
      (functionAssociation text position catalog first last last named).formal ≠ 0 →
      seen (functionAssociation text position catalog first last last named).formal = false →
      ActualAt text context (functionAssociation text position catalog first last last named).payloadFirst
        facts (FunctionBindings.parameter catalog
          (functionAssociation text position catalog first last last named).formal) actual after →
      fixedAfter text after ")" false ≠ 0 →
      ActualsTailAt text context facts catalog first last position last named seen
        [((functionAssociation text position catalog first last last named).formal, actual)]
        (fixedAfter text after ")" false)
  | next {position ordinal named seen actual after rest result} : ordinal < last →
      (functionAssociation text position catalog first last ordinal named).formal ≠ 0 →
      seen (functionAssociation text position catalog first last ordinal named).formal = false →
      ActualAt text context (functionAssociation text position catalog first last ordinal named).payloadFirst
        facts (FunctionBindings.parameter catalog
          (functionAssociation text position catalog first last ordinal named).formal) actual after →
      fixedAfter text after "," false ≠ 0 →
      ActualsTailAt text context facts catalog first last (fixedAfter text after "," false)
        (ordinal + 1) (functionAssociation text position catalog first last ordinal named).named
        (markFormal seen (functionAssociation text position catalog first last ordinal named).formal) rest result →
      ActualsTailAt text context facts catalog first last position ordinal named seen
        (((functionAssociation text position catalog first last ordinal named).formal, actual) :: rest) result

theorem actualsTail_sound {text context facts catalog position first last ordinal named seen}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : functionActualsTailModel text context position facts catalog first last ordinal named seen ≠ 0) :
    ∃ entries, ActualsTailAt text context facts catalog first last position ordinal named seen entries
      (functionActualsTailModel text context position facts catalog first last ordinal named seen) := by
  rw [functionActualsTailModel] at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i selection
    have nonzero : (functionAssociation text position catalog first last ordinal named).formal ≠ 0 :=
      fun zero => selection (Or.inl zero)
    have fresh : seen (functionAssociation text position catalog first last ordinal named).formal = false :=
      Bool.of_not_eq_true (fun duplicate => selection (Or.inr duplicate))
    simp only [selection, ↓reduceIte]
    split at accepted
    · contradiction
    · rename_i positive
      obtain ⟨actual, parsed⟩ := actual_sound tv nv
        (functionAssociation_payload_bound text position catalog first last ordinal named bounded) positive
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
            obtain ⟨rest, following⟩ := actualsTail_sound tv nv
              (Compose.Expressions.model_fixed_valid text _ "," false parsed.bounded) accepted
            exact ⟨_, .next within nonzero fresh parsed comma following⟩
          · contradiction
termination_by last - ordinal

theorem ActualsTailAt.unique {text context facts catalog position first last ordinal named seen left right leftAfter rightAfter}
    (one : ActualsTailAt text context facts catalog first last position ordinal named seen left leftAfter)
    (two : ActualsTailAt text context facts catalog first last position ordinal named seen right rightAfter) :
    left = right := by
  induction one generalizing right rightAfter with
  | last _ _ parsed _ =>
      cases two with
      | last _ _ other _ => simp [(actual_unique parsed other).1]
      | next within => omega
  | next within _ _ parsed _ rest ih =>
      cases two with
      | last => omega
      | next _ _ _ other _ following =>
          obtain ⟨same, afterSame⟩ := actual_unique parsed other
          cases afterSame
          simp [same, ih following]

theorem ActualsTailAt.positive {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position ordinal named seen entries after) : after ≠ 0 := by
  induction parsed with
  | last _ _ _ positive => exact positive
  | next _ _ _ _ _ _ ih => exact ih

theorem ActualsTailAt.bounded {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    after ≤ text.length + 1 := by
  induction parsed with
  | last _ _ source _ => exact Compose.Expressions.model_fixed_valid text _ ")" false source.bounded
  | next _ _ _ _ _ _ ih => exact ih

theorem ActualsTailAt.ordinal_bound {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    ordinal ≤ last := by
  cases parsed with
  | last => exact Nat.le_refl _
  | next within => exact Nat.le_of_lt within

theorem ActualsTailAt.length {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    entries.length = last - ordinal + 1 := by
  induction parsed with
  | last => simp
  | next within _ _ _ _ _ ih => simp only [List.length_cons]; omega

theorem ActualsTailAt.fresh {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    ScalarAssociations.FreshSelections seen (entries.map Prod.fst) := by
  induction parsed with
  | last _ fresh _ _ => exact .cons fresh .nil
  | next _ _ fresh _ _ _ ih => exact .cons fresh ih

theorem ActualsTailAt.inside {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    (lower : first ≤ ordinal) :
    ∀ formal ∈ entries.map Prod.fst, first ≤ formal ∧ formal ≤ last := by
  induction parsed with
  | last selected _ _ _ =>
      intro formal present
      have same := List.mem_singleton.mp present
      subst formal
      exact functionAssociation_formal ⟨lower, Nat.le_refl _⟩ selected
  | next within selected _ _ _ rest ih =>
      intro formal present
      rcases List.mem_cons.mp present with same | later
      · subst formal
        exact functionAssociation_formal ⟨lower, Nat.le_of_lt within⟩ selected
      · exact ih (by omega) formal later

def defaultFunctionActual : ScalarFunctions.Actual := .integer (.literal 0)

def arrangeFunctionActuals (entries : List (ScalarAssociations.Entry ScalarFunctions.Actual))
    (first last : Nat) : List ScalarFunctions.Actual :=
  (ScalarAssociations.arrange defaultFunctionActual entries first (last - first + 1)).map Prod.snd

theorem ActualsTailAt.complete {text context facts catalog position first last named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position first named seen entries after) :
    (entries.map Prod.fst).Perm (List.range' first (last - first + 1)) := by
  apply ScalarAssociations.selections_complete parsed.fresh.nodup
  · simpa only [List.length_map] using parsed.length
  · intro formal present
    have inside := parsed.inside (Nat.le_refl _) formal present
    have ordered := parsed.ordinal_bound
    omega

theorem ActualsTailAt.forall_payloads {text context facts catalog position first last ordinal named seen entries after}
    (parsed : ActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    {property : Nat → ScalarFunctions.Actual → Prop}
    (one : ∀ position formal actual after,
      ActualAt text context position facts (FunctionBindings.parameter catalog formal) actual after →
      property formal actual) : ∀ entry ∈ entries, property entry.1 entry.2 := by
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
inductive ActualsAt (text : Source) (context : ParseContext) (facts : ActiveFlow)
    (catalog : FunctionBindings.Metadata) : Nat → Nat → Nat → List ScalarFunctions.Actual → Nat → Prop
  | actuals {position first last entries after} :
      ActualsTailAt text context facts catalog first last position first false noFormals entries after →
      ActualsAt text context facts catalog position first last (arrangeFunctionActuals entries first last) after

theorem actuals_sound {text context facts catalog position first last}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : actualsAfter text context position facts catalog first last ≠ 0) :
    ∃ actuals, ActualsAt text context facts catalog position first last actuals
      (actualsAfter text context position facts catalog first last) := by
  obtain ⟨entries, parsed⟩ := actualsTail_sound tv nv bounded accepted
  exact ⟨arrangeFunctionActuals entries first last, .actuals parsed⟩

theorem actuals_unique {text context facts catalog position first last left right leftAfter rightAfter}
    (one : ActualsAt text context facts catalog position first last left leftAfter)
    (two : ActualsAt text context facts catalog position first last right rightAfter) : left = right := by
  cases one with
  | actuals source =>
      cases two with
      | actuals other => rw [source.unique other]

theorem ActualsAt.forall_payloads {text context facts catalog position first last actuals after}
    (parsed : ActualsAt text context facts catalog position first last actuals after)
    {property : ScalarFunctions.Actual → Prop}
    (one : ∀ position formal actual after,
      ActualAt text context position facts (FunctionBindings.parameter catalog formal) actual after → property actual) :
    ∀ actual ∈ actuals, property actual := by
  cases parsed with
  | actuals source =>
      have original := source.forall_payloads one
      have arranged := ScalarAssociations.arrange_all defaultFunctionActual source.fresh.nodup source.complete original
      intro actual present
      obtain ⟨entry, member, same⟩ := List.mem_map.mp present
      subst actual
      exact arranged entry member

theorem actuals_positive {text context facts catalog position first last actuals after}
    (parsed : ActualsAt text context facts catalog position first last actuals after) : after ≠ 0 := by
  cases parsed with
  | actuals source => exact source.positive

theorem actuals_bounded {text context facts catalog position first last actuals after}
    (parsed : ActualsAt text context facts catalog position first last actuals after) :
    after ≤ text.length + 1 := by
  cases parsed with
  | actuals source => exact source.bounded

structure CallAt (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata) (call : ScalarFunctions.Call)
    (result : CallResult) : Prop where
  callee : call.callee = calleeAt text context position catalog
  positive : call.callee ≠ 0
  actuals : ActualsAt text context facts catalog
    (fixedAfter text (nameAfter text (skipAt text position)) "(" false)
    (FunctionBindings.signature catalog call.callee).formalFirst
    ((FunctionBindings.signature catalog call.callee).formalFirst +
      (FunctionBindings.signature catalog call.callee).count - 1) call.actuals result.after
  equation : readCall text context position facts catalog = result

theorem call_sound {text context position facts catalog}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (accepted : (readCall text context position facts catalog).after ≠ 0) :
    ∃ call, CallAt text context position facts catalog call (readCall text context position facts catalog) := by
  unfold readCall at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i positive
    simp only [positive, ↓reduceIte]
    split at accepted
    · contradiction
    · rename_i advanced
      simp only [advanced, ↓reduceIte]
      have nonzero : actualsAfter text context
          (fixedAfter text (nameAfter text (skipAt text position)) "(" false) facts catalog
          (FunctionBindings.signature catalog (calleeAt text context position catalog)).formalFirst
          ((FunctionBindings.signature catalog (calleeAt text context position catalog)).formalFirst +
            (FunctionBindings.signature catalog (calleeAt text context position catalog)).count - 1) ≠ 0 := by omega
      obtain ⟨actuals, parsed⟩ := actuals_sound tv nv
        (Compose.Expressions.model_fixed_valid text _ "(" false (Compose.Expressions.model_name_valid text _)) nonzero
      exact ⟨⟨calleeAt text context position catalog, actuals⟩,
        ⟨rfl, positive, parsed, by simp only [readCall, positive, advanced, ↓reduceIte]⟩⟩

theorem call_unique {text context position facts catalog left right leftResult rightResult}
    (first : CallAt text context position facts catalog left leftResult)
    (second : CallAt text context position facts catalog right rightResult) : left = right := by
  have same := first.callee.trans second.callee.symm
  cases left with
  | mk leftIdentity leftActuals =>
    cases right with
    | mk rightIdentity rightActuals =>
      dsimp only at same
      subst rightIdentity
      have actuals := actuals_unique first.actuals second.actuals
      cases actuals
      rfl

theorem call_result_fields {text context position facts catalog call result}
    (parsed : CallAt text context position facts catalog call result) :
    result.kind = (FunctionBindings.signature catalog call.callee).resultKind ∧
    result.bounds = (FunctionBindings.signature catalog call.callee).resultBounds := by
  have positive := actuals_positive parsed.actuals
  have equation := parsed.equation
  unfold readCall at equation
  dsimp only at equation
  rw [← parsed.callee] at equation
  simp only [parsed.positive, ↓reduceIte] at equation
  split at equation
  · have failed := congrArg CallResult.after equation
    exact False.elim (positive failed.symm)
  · cases equation
    exact ⟨rfl, rfl⟩

def functionAssignmentTarget (text : Source) (context : ParseContext) (scan : BodyScan) :
    ScalarFunctions.Target :=
  if scalarTarget text context scan.position ≠ 0 then
    .integer (scalarTarget text context scan.position)
      (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds
  else .boolean (booleanTarget text context scan.position)

structure FunctionAssignmentAt (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata) (update : ScalarFunctions.Assignment) : Prop where
  call : CallAt text context (scalarAssignmentStart text scan) scan.facts catalog update.call
    (readCall text context (scalarAssignmentStart text scan) scan.facts catalog)
  target : update.target = functionAssignmentTarget text context scan
  positive : (callAssignmentBody text context scan catalog).position ≠ 0

theorem functionAssignment_sound {text context scan catalog}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (positive : (callAssignmentBody text context scan catalog).position ≠ 0) :
    ∃ update, FunctionAssignmentAt text context scan catalog update := by
  have accepted : (readCall text context (scalarAssignmentStart text scan) scan.facts catalog).after ≠ 0 := by
    unfold callAssignmentBody callAssignmentResult at positive
    split at positive
    · contradiction
    · rename_i advanced
      omega
  obtain ⟨call, parsed⟩ := call_sound tv nv accepted
  exact ⟨⟨functionAssignmentTarget text context scan, call⟩, ⟨parsed, rfl, positive⟩⟩

theorem functionAssignment_unique {text context scan catalog left right}
    (first : FunctionAssignmentAt text context scan catalog left)
    (second : FunctionAssignmentAt text context scan catalog right) : left = right := by
  have calls := call_unique first.call second.call
  have targets := first.target.trans second.target.symm
  cases left
  cases right
  cases calls
  cases targets
  rfl

end Silver.Predicate
