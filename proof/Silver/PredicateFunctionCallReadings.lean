module

public import Silver.PredicateCallAdmission
public import Silver.PredicateBodyScanner
public import Silver.PredicateConditionSound
public import Silver.PredicateConditionUnique
public import Silver.ScalarCallChecking

@[expose] public section

namespace Silver.Predicate
open Compose

def formalType (formal : FunctionBindings.Formal) : ScalarFunctions.ScalarType :=
  match formal.kind with
  | .integer => .integer formal.bounds
  | .boolean => .boolean

def resultType (entry : FunctionBindings.Signature) : ScalarFunctions.ScalarType :=
  match entry.resultKind with
  | .integer => .integer entry.resultBounds
  | .boolean => .boolean

def formalTypes (catalog : FunctionBindings.Metadata) (first : Nat) : Nat → List ScalarFunctions.ScalarType
  | 0 => []
  | count + 1 => formalType (FunctionBindings.parameter catalog first) :: formalTypes catalog (first + 1) count

def signatureModel (catalog : FunctionBindings.Metadata) (entry : FunctionBindings.Signature) :
    ScalarFunctions.Signature :=
  ⟨formalTypes catalog entry.formalFirst entry.count, resultType entry⟩

def catalogSignatures (catalog : FunctionBindings.Metadata) : ScalarFunctions.Signatures :=
  catalog.items.map (signatureModel catalog)

theorem catalogSignatures_lookup {catalog : FunctionBindings.Metadata} {index : Nat}
    (positive : 0 < index) (bounded : index ≤ catalog.items.length) :
    ScalarFunctions.lookup (catalogSignatures catalog) index =
      some (signatureModel catalog (FunctionBindings.signature catalog index)) := by
  have inside : index - 1 < catalog.items.length := by omega
  simp [ScalarFunctions.lookup, catalogSignatures, FunctionBindings.signature,
    Nat.ne_of_gt positive, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside]

theorem formalTypes_append_parameters (catalog : FunctionBindings.Metadata)
    (more : List FunctionBindings.Formal) (first count : Nat)
    (positive : 0 < first) (bounded : first + count - 1 ≤ catalog.parameters.length) :
    formalTypes {catalog with parameters := catalog.parameters ++ more} first count =
      formalTypes catalog first count := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalTypes]
      rw [FunctionBindings.parameter_prefix catalog more first positive (by omega),
        ih (first + 1) (by omega) (by omega)]

theorem signatureModel_append_parameters {text : Source} (catalog : FunctionBindings.Metadata)
    (more : List FunctionBindings.Formal) (entry : FunctionBindings.Signature)
    (valid : FunctionBindings.ValidSignature text catalog entry) :
    signatureModel {catalog with parameters := catalog.parameters ++ more} entry =
      signatureModel catalog entry := by
  unfold signatureModel
  rw [formalTypes_append_parameters catalog more entry.formalFirst entry.count valid.2.2.1 (by
    have first := valid.2.2.1
    have bounded := valid.2.2.2.1
    have count := valid.2.2.2.2.1
    omega)]

theorem catalogSignatures_append_parameters {text : Source} (catalog : FunctionBindings.Metadata)
    (more : List FunctionBindings.Formal) (valid : FunctionBindings.ValidMetadata text catalog) :
    catalogSignatures {catalog with parameters := catalog.parameters ++ more} =
      catalogSignatures catalog := by
  apply List.map_congr_left
  intro entry present
  exact signatureModel_append_parameters catalog more entry (valid.2.2.2 entry present)

theorem formalTypes_append (catalog : FunctionBindings.Metadata) (entry : FunctionBindings.Signature)
    (first count : Nat) :
    formalTypes (FunctionBindings.append catalog entry) first count = formalTypes catalog first count := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalTypes]
      exact congrArg (formalType (FunctionBindings.parameter catalog first) :: ·) (ih (first + 1))

theorem signatureModel_append (catalog : FunctionBindings.Metadata) (entry value : FunctionBindings.Signature) :
    signatureModel (FunctionBindings.append catalog entry) value = signatureModel catalog value := by
  simp only [signatureModel, formalTypes_append]

theorem catalogSignatures_append (catalog : FunctionBindings.Metadata) (entry : FunctionBindings.Signature) :
    catalogSignatures (FunctionBindings.append catalog entry) =
      catalogSignatures catalog ++ [signatureModel catalog entry] := by
  simp only [catalogSignatures, FunctionBindings.append, List.map_append, List.map_cons, List.map_nil]
  congr 1
  · apply List.map_congr_left
    intro value _
    exact signatureModel_append catalog entry value
  · exact congrArg (fun value => [value]) (signatureModel_append catalog entry entry)

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

/-- Every argument keeps the same incoming flow. Delimiters, order and exact
arity are retained independently from the call scanner's result. -/
inductive ActualsAt (text : Source) (context : ParseContext) (facts : ActiveFlow)
    (catalog : FunctionBindings.Metadata) : Nat → Nat → Nat → List ScalarFunctions.Actual → Nat → Prop
  | last {position first actual after} :
      ActualAt text context position facts (FunctionBindings.parameter catalog first) actual after →
      fixedAfter text after ")" false ≠ 0 →
      ActualsAt text context facts catalog position first first [actual] (fixedAfter text after ")" false)
  | next {position first last actual after rest result} : first < last →
      ActualAt text context position facts (FunctionBindings.parameter catalog first) actual after →
      ActualsAt text context facts catalog (fixedAfter text after "," false) (first + 1) last rest result →
      ActualsAt text context facts catalog position first last (actual :: rest) result

theorem actuals_sound {text context facts catalog position first last}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : position ≤ text.length + 1)
    (accepted : actualsAfter text context position facts catalog first last ≠ 0) :
    ∃ actuals, ActualsAt text context facts catalog position first last actuals
      (actualsAfter text context position facts catalog first last) := by
  rw [actualsAfter] at accepted ⊢
  try dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i positive
    obtain ⟨actual, parsed⟩ := actual_sound tv nv bounded positive
    simp only [positive, ↓reduceIte]
    split at accepted
    · rename_i same
      subst last
      simp only [↓reduceIte] at accepted ⊢
      exact ⟨[actual], .last parsed accepted⟩
    · rename_i different
      simp only [different, ↓reduceIte] at accepted ⊢
      split at accepted
      · rename_i within
        simp only [within, ↓reduceDIte]
        obtain ⟨rest, following⟩ := actuals_sound tv nv
          (Compose.Expressions.model_fixed_valid text _ "," false parsed.bounded) accepted
        exact ⟨actual :: rest, .next within parsed following⟩
      · contradiction
termination_by last - first

theorem actuals_unique {text context facts catalog position first last left right leftAfter rightAfter}
    (one : ActualsAt text context facts catalog position first last left leftAfter)
    (two : ActualsAt text context facts catalog position first last right rightAfter) :
    left = right := by
  induction one generalizing right rightAfter with
  | last parsed _ =>
      cases two with
      | last other _ => simp [(actual_unique parsed other).1]
      | next within _ _ => omega
  | next within parsed rest ih =>
      cases two with
      | last => omega
      | next _ other following =>
          obtain ⟨same, afterSame⟩ := actual_unique parsed other
          cases afterSame
          simp [same, ih following]

theorem actuals_positive {text context facts catalog position first last actuals after}
    (parsed : ActualsAt text context facts catalog position first last actuals after) : after ≠ 0 := by
  induction parsed with
  | last _ positive => exact positive
  | next _ _ _ ih => exact ih

theorem actuals_bounded {text context facts catalog position first last actuals after}
    (parsed : ActualsAt text context facts catalog position first last actuals after) :
    after ≤ text.length + 1 := by
  induction parsed with
  | last source _ => exact Compose.Expressions.model_fixed_valid text _ ")" false source.bounded
  | next _ _ _ ih => exact ih

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
