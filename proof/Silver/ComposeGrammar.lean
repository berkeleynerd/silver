module

public import Silver.ComposeMain

@[expose] public section

/-! Source payloads are read from the same ordered declaration region and token
positions as the recognizer. Their semantic constraints are proved separately
from the scanner's Boolean acceptance. -/

namespace Silver.Compose
open Bindings

inductive Event
  | declarations (values : List Declaration) (names : BindingEnvironment)
  | argument (fallback : Source)
  | assignment (update : Bindings.Assignment)
  | literal (bytes : Source)
  | capacity (bound : Nat)
  | output (expression : Expression)
  | comparison (left right : Expression)
  deriving DecidableEq, Repr

inductive EventKind | declarations | argument | assignment | literal | capacity | output | comparison
  deriving DecidableEq, Repr

def Event.kind : Event → EventKind
  | .declarations .. => .declarations
  | .argument .. => .argument
  | .assignment .. => .assignment
  | .literal .. => .literal
  | .capacity .. => .capacity
  | .output .. => .output
  | .comparison .. => .comparison

def ShellToken.eventKind : ShellToken → Option EventKind
  | .declarations => some .declarations
  | .argumentDeclaration => some .argument
  | .assignmentValue => some .assignment
  | .literal => some .literal
  | .capacity => some .capacity
  | .outputExpression => some .output
  | .comparisonExpression => some .comparison
  | _ => none

def PayloadAt (text : Source) (form : Form) (token : ShellToken)
    (state next : ParserState) (event : Option Event) : Prop :=
  match token with
  | .declarations => ∃ values, DeclarationsAt text form.hasArguments state values next ∧
      event = some (.declarations values next.names)
  | .argumentDeclaration => ∃ fallback, ArgumentAt text state fallback next ∧ event = some (.argument fallback)
  | .assignmentValue => ∃ value, ExpressionAt (scalarNames := state.scalarNames) text state.names state.position value (expressionAt text state.position state.names state.scalarNames) ∧
      event = some (.assignment ⟨state.target, value.freezeImages (frozenIntegers state.scalarNames)⟩)
  | .literal => ∃ bytes, LiteralReading text (skipAt text state.position) bytes (literalAt text (skipAt text state.position)) ∧
      event = some (.literal bytes)
  | .capacity => event = some (.capacity next.capacity)
  | .outputExpression => ∃ expression,
      ExpressionAt (scalarNames := state.scalarNames) text state.names state.position expression (expressionAt text state.position state.names state.scalarNames) ∧
      event = some (.output (expression.freezeImages (frozenIntegers state.scalarNames)))
  | .comparisonExpression => ∃ left right,
      ExpressionAt (scalarNames := state.scalarNames) text state.names state.position left (expressionAt text state.position state.names state.scalarNames) ∧
      ExpressionAt (scalarNames := state.scalarNames) text state.names (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false)
        right (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames) ∧
      event = some (.comparison (left.freezeImages (frozenIntegers state.scalarNames))
        (right.freezeImages (frozenIntegers state.scalarNames)))
  | _ => event = none

/-- An assignment target denotes the declared mutable cell whose source name
matches the actual identifier; a repeated branch target denotes that same cell. -/
def TargetReading (text : Source) (state next : ParserState) (sameTarget : Bool) : Prop :=
  ∃ name info, Named.IdentifierAt text (skipAt text state.position) name next.position ∧
    state.names.get next.target = some info ∧
    Named.equalName text info.first info.after (skipAt text state.position) next.position = true ∧
    info.mutable = true ∧ (sameTarget = true → next.target = state.target) ∧
    ScalarExpression.lookup text state.scalarNames (skipAt text state.position) next.position = 0

/-- Capacity guards name the original immutable argv declaration, whose
span was recorded during declaration elaboration. -/
def DynamicReading (text : Source) (state next : ParserState) : Prop :=
  ∃ name, Named.IdentifierAt text (skipAt text state.position) name next.position ∧
    state.dynamicFirst ≠ 0 ∧
    Named.equalName text state.dynamicFirst state.dynamicAfter (skipAt text state.position) next.position = true

def ReferenceReading (text : Source) (token : ShellToken) (state next : ParserState) : Prop :=
  match token with
  | .assignmentTarget => TargetReading text state next false
  | .targetReference => TargetReading text state next true
  | .dynamicReference => DynamicReading text state next
  | _ => True

theorem target_reading (text : Source) (state : ParserState) (sameTarget : Bool)
    (accepted : (targetAt text state sameTarget).position ≠ 0) :
    TargetReading text state (targetAt text state sameTarget) sameTarget := by
  dsimp only [targetAt] at accepted ⊢
  split
  · rename_i failed
    rw [ite_eq_left failed] at accepted
    exact False.elim (accepted rfl)
  · rename_i allowed
    have nonzero : lookupName text state.names (skipAt text state.position) (nameAfter text (skipAt text state.position)) ≠ 0 := by omega
    obtain ⟨first, advanced, info, found, equal⟩ := lookupName_found nonzero
    have endNonzero : Named.identifierEnd text (skipAt text state.position) ≠ 0 := by
      have after : nameAfter text (skipAt text state.position) ≠ 0 := by omega
      simpa only [nameAfter, first, ↓reduceIte] using after
    obtain ⟨name, identifier⟩ := Named.identifierEnd_sound text _ endNonzero
    have notfalse : info.mutable ≠ false := by
      intro isfalse
      exact allowed (Or.inr (Or.inr (Or.inl (by simpa only [found, Option.getD_some] using isfalse))))
    have mutable : info.mutable = true := by cases h : info.mutable <;> simp_all only
    refine ⟨name, info, ?_, found, equal, mutable, ?_, ?_⟩
    · simpa only [nameAfter, first, ↓reduceIte] using identifier
    · intro same
      by_cases selected : lookupName text state.names (skipAt text state.position) (nameAfter text (skipAt text state.position)) = state.target
      · exact selected
      · exact False.elim (allowed (Or.inr (Or.inr (Or.inr ⟨same, selected⟩))))
    · by_cases clear : ScalarExpression.lookup text state.scalarNames (skipAt text state.position)
          (nameAfter text (skipAt text state.position)) = 0
      · exact clear
      · exact False.elim (allowed (Or.inr (Or.inl clear)))

theorem dynamic_reading (text : Source) (state : ParserState)
    (accepted : (dynamicAt text state).position ≠ 0) : DynamicReading text state (dynamicAt text state) := by
  dsimp only [dynamicAt] at accepted ⊢
  split
  · rename_i failed
    rw [ite_eq_left failed] at accepted
    exact False.elim (accepted rfl)
  · rename_i allowed
    have first : skipAt text state.position ≠ 0 := by omega
    have after : nameAfter text (skipAt text state.position) ≠ 0 := by omega
    have endNonzero : Named.identifierEnd text (skipAt text state.position) ≠ 0 := by
      simpa only [nameAfter, first, ↓reduceIte] using after
    obtain ⟨name, identifier⟩ := Named.identifierEnd_sound text _ endNonzero
    refine ⟨name, ?_, by omega, ?_⟩
    · simpa only [nameAfter, first, ↓reduceIte] using identifier
    · have notfalse : Named.equalName text state.dynamicFirst state.dynamicAfter
          (skipAt text state.position) (nameAfter text (skipAt text state.position)) ≠ false :=
        fun isfalse => allowed (Or.inr (Or.inr (Or.inr isfalse)))
      cases h : Named.equalName text state.dynamicFirst state.dynamicAfter
          (skipAt text state.position) (nameAfter text (skipAt text state.position)) <;> simp_all only

theorem step_references (text : Source) (form : Form) (token : ShellToken) (state : ParserState)
    (positive : state.position ≠ 0) (accepted : (step text form token state).position ≠ 0) :
    ReferenceReading text token state (step text form token state) := by
  cases token <;> simp only [ReferenceReading]
  all_goals try trivial
  case assignmentTarget =>
    simpa only [step, positive, ↓reduceIte] using target_reading text state false (by simpa only [step, positive, ↓reduceIte] using accepted)
  case targetReference =>
    simpa only [step, positive, ↓reduceIte] using target_reading text state true (by simpa only [step, positive, ↓reduceIte] using accepted)
  case dynamicReference =>
    simpa only [step, positive, ↓reduceIte] using dynamic_reading text state (by simpa only [step, positive, ↓reduceIte] using accepted)

structure StepAt (text : Source) (form : Form) (token : ShellToken)
    (state next : ParserState) (event : Option Event) : Prop where
  positive : state.position ≠ 0
  following : next.position ≠ 0
  scanned : step text form token state = next
  payload : PayloadAt text form token state next event
  references : ReferenceReading text token state next

theorem step_payload (text : Source) (form : Form) (token : ShellToken) (state : ParserState)
    (positive : state.position ≠ 0) (accepted : (step text form token state).position ≠ 0) :
    ∃ event, PayloadAt text form token state (step text form token state) event := by
  cases token with
  | contextClauses | fixed spelling word => exact ⟨none, rfl⟩
  | dynamicReference => exact ⟨none, rfl⟩
  | assignmentTarget => exact ⟨none, rfl⟩
  | targetReference => exact ⟨none, rfl⟩
  | declarations =>
      have success : (declarationsAt text state form.hasArguments).position ≠ 0 := by simpa [step, positive] using accepted
      obtain ⟨values, parsed⟩ := declarations_sound text state form.hasArguments success
      exact ⟨some (.declarations values (declarationsAt text state form.hasArguments).names), values,
        by simpa only [step, positive, ↓reduceIte] using parsed, by simp [step, positive]⟩
  | argumentDeclaration =>
      have success : (argumentAt text state).position ≠ 0 := by simpa [step, positive] using accepted
      obtain ⟨fallback, parsed⟩ := argument_sound text state success
      exact ⟨some (.argument fallback), fallback, by simpa only [step, positive, ↓reduceIte] using parsed, rfl⟩
  | literal =>
      have success : (literalAt text (skipAt text state.position)).after ≠ 0 := by simpa [step, positive] using accepted
      obtain ⟨bytes, parsed⟩ := literalReading_sound text _ success
      exact ⟨some (.literal bytes), bytes, parsed, rfl⟩
  | capacity => exact ⟨some (.capacity (step text form .capacity state).capacity), rfl⟩
  | assignmentValue =>
      have success : (expressionAt text state.position state.names state.scalarNames).after ≠ 0 := by
        by_cases failed : (expressionAt text state.position state.names state.scalarNames).after = 0
        · simp [step, positive, assignmentAt, fits, failed, invalidState] at accepted
        · exact failed
      obtain ⟨value, parsed⟩ := expressionAt_sound (scalarNames := state.scalarNames) text state.names state.position success
      exact ⟨some (.assignment ⟨state.target, value.freezeImages (frozenIntegers state.scalarNames)⟩), value, parsed, rfl⟩
  | outputExpression =>
      have success : (expressionAt text state.position state.names state.scalarNames).after ≠ 0 := by
        by_cases failed : (expressionAt text state.position state.names state.scalarNames).after = 0
        · simp [step, positive, outputAt, fits, failed, invalidState] at accepted
        · exact failed
      obtain ⟨expression, parsed⟩ := expressionAt_sound (scalarNames := state.scalarNames) text state.names state.position success
      exact ⟨some (.output (expression.freezeImages (frozenIntegers state.scalarNames))), expression, parsed, rfl⟩
  | comparisonExpression =>
      have leftSuccess : (expressionAt text state.position state.names state.scalarNames).after ≠ 0 := by
        by_cases failed : (expressionAt text state.position state.names state.scalarNames).after = 0
        · simp [step, positive, comparisonAt, fits, failed, invalidState] at accepted
        · exact failed
      have rightSuccess : (expressionAt text (fixedAfter text
          (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames).after ≠ 0 := by
        by_cases failed : (expressionAt text (fixedAfter text
            (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames).after = 0
        · simp [step, positive, comparisonAt, fits, failed, invalidState] at accepted
        · exact failed
      obtain ⟨left, first⟩ := expressionAt_sound (scalarNames := state.scalarNames) text state.names state.position leftSuccess
      obtain ⟨right, second⟩ := expressionAt_sound (scalarNames := state.scalarNames) text state.names _ rightSuccess
      exact ⟨some (.comparison (left.freezeImages (frozenIntegers state.scalarNames))
        (right.freezeImages (frozenIntegers state.scalarNames))), left, right, first, second, rfl⟩

theorem step_sound (text : Source) (form : Form) (token : ShellToken) (state : ParserState)
    (positive : state.position ≠ 0) (accepted : (step text form token state).position ≠ 0) :
    ∃ event, StepAt text form token state (step text form token state) event := by
  obtain ⟨event, payload⟩ := step_payload text form token state positive accepted
  exact ⟨event, positive, accepted, rfl, payload, step_references text form token state positive accepted⟩

theorem step_unique {text : Source} {form : Form} {token : ShellToken}
    {state left right : ParserState} {firstEvent secondEvent : Option Event}
    (first : StepAt text form token state left firstEvent)
    (second : StepAt text form token state right secondEvent) : left = right ∧ firstEvent = secondEvent := by
  have same := first.scanned.symm.trans second.scanned
  subst right
  refine ⟨rfl, ?_⟩
  have firstPayload := first.payload
  have secondPayload := second.payload
  cases token <;> simp only [PayloadAt] at firstPayload secondPayload
  all_goals try exact firstPayload.trans secondPayload.symm
  case declarations =>
    obtain ⟨a, parsed, rfl⟩ := firstPayload
    obtain ⟨b, other, rfl⟩ := secondPayload
    rw [(declarations_unique parsed other).1]
  case argumentDeclaration =>
    obtain ⟨a, parsed, rfl⟩ := firstPayload
    obtain ⟨b, other, rfl⟩ := secondPayload
    rw [(argument_unique parsed other).1]
  case assignmentValue =>
    obtain ⟨a, parsed, rfl⟩ := firstPayload
    obtain ⟨b, other, rfl⟩ := secondPayload
    rw [(expressionTail_unique parsed other).1]
  case literal =>
    obtain ⟨a, parsed, rfl⟩ := firstPayload
    obtain ⟨b, other, rfl⟩ := secondPayload
    rw [literalReading_unique parsed other]
  case outputExpression =>
    obtain ⟨a, parsed, rfl⟩ := firstPayload
    obtain ⟨b, other, rfl⟩ := secondPayload
    rw [(expressionTail_unique parsed other).1]
  case comparisonExpression =>
    obtain ⟨left, right, leftParsed, rightParsed, rfl⟩ := firstPayload
    obtain ⟨otherLeft, otherRight, otherFirst, otherSecond, rfl⟩ := secondPayload
    rw [(expressionTail_unique leftParsed otherFirst).1, (expressionTail_unique rightParsed otherSecond).1]

theorem step_kind {text : Source} {form : Form} {token : ShellToken}
    {state next : ParserState} {event : Option Event} (parsed : StepAt text form token state next event) :
    event.map Event.kind = token.eventKind := by
  have payload := parsed.payload
  cases token <;> simp only [PayloadAt] at payload
  all_goals first
    | obtain ⟨_, _, rfl⟩ := payload; rfl
    | obtain ⟨_, _, _, _, rfl⟩ := payload; rfl
    | rw [payload]; rfl


def TargetValid (state : ParserState) : Prop :=
  state.target = 0 ∨ ∃ bound, state.names.shape state.target = some ⟨bound, true⟩

def StateValid (state : ParserState) : Prop :=
  NamesNormal state.names ∧ state.capacity ≤ maxSourceLength ∧ TargetValid state ∧
    ScalarExpression.StaticEnvironment state.scalarNames

def StreamValid (shape : Shape) (capacity : Nat) : List Event → Prop
  | [] => True
  | .declarations values names :: rest => DeclarationsValid shape values names.shape ∧ StreamValid names.shape capacity rest
  | .argument fallback :: rest => Printable fallback ∧ fallback.length ≤ maxSourceLength ∧
      StreamValid argumentShape capacity rest
  | .assignment update :: rest => update.Valid shape ∧ SafeExpression update.value shape capacity ∧ StreamValid shape capacity rest
  | .literal bytes :: rest => Printable bytes ∧ StreamValid shape capacity rest
  | .capacity bound :: rest => bound ≤ maxSourceLength ∧ StreamValid shape bound rest
  | .output expression :: rest => SafeExpression expression shape capacity ∧ StreamValid shape capacity rest
  | .comparison left right :: rest => SafeExpression left shape capacity ∧ SafeExpression right shape capacity ∧
      StreamValid shape capacity rest

def EventValid (state next : ParserState) (event : Option Event) : Prop :=
  ∀ rest, StreamValid next.names.shape next.capacity rest →
    StreamValid state.names.shape state.capacity (event.toList ++ rest)

theorem initial_valid : StateValid initialState := by
  refine ⟨?_, Nat.le_refl _, Or.inl rfl, ScalarExpression.static_empty⟩
  intro index info present
  simp [initialState, BindingEnvironment.get] at present

theorem assignment_safe {text : Source} {state : ParserState} {value : Expression}
    (normal : NamesNormal state.names) (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (valid : TargetValid state)
    (parsed : ExpressionAt (scalarNames := state.scalarNames) text state.names state.position value (expressionAt text state.position state.names state.scalarNames))
    (accepted : (assignmentAt text state).position ≠ 0) :
    (Bindings.Assignment.mk state.target (value.freezeImages (frozenIntegers state.scalarNames))).Valid state.names.shape ∧
      SafeExpression (value.freezeImages (frozenIntegers state.scalarNames)) state.names.shape state.capacity ∧
      (assignmentAt text state).names = state.names ∧ (assignmentAt text state).capacity = state.capacity ∧
      (assignmentAt text state).target = state.target := by
  generalize valueEq : expressionAt text state.position state.names state.scalarNames = result at *
  generalize infoEq : (state.names.get state.target).getD {} = info
  have observed : assignmentAt text state =
      if !fits result state.capacity || result.emptyValue || decide (result.minimumLength ≠ result.staticLength ∨ state.target = 0 ∨ result.staticLength ≠ info.staticLength ∨
          result.dynamicCount ≠ (if info.dynamic then 1 else 0)) then invalidState
      else {state with position := result.after} := by simp only [assignmentAt, valueEq, infoEq]
  have bounded : fits result state.capacity = true := by
    by_cases good : fits result state.capacity = true
    · exact good
    · simp [observed, good, invalidState] at accepted
  have correct : ¬(result.minimumLength ≠ result.staticLength ∨ state.target = 0 ∨ result.staticLength ≠ info.staticLength ∨
      result.dynamicCount ≠ (if info.dynamic then 1 else 0)) := by
    intro bad
    simp [observed, bad, invalidState] at accepted
  have nonempty : result.emptyValue = false := by
    cases empty : result.emptyValue with
    | false => rfl
    | true => simp [observed, empty, invalidState] at accepted
  have nonzero : state.target ≠ 0 := by omega
  obtain zero | ⟨bound, present⟩ := valid
  · exact False.elim (nonzero zero)
  · have lookup := present
    simp only [BindingEnvironment.shape, Option.map_eq_some_iff] at lookup
    obtain ⟨actual, found, cellEq⟩ := lookup
    have actualEq : actual = info := by simpa [found] using infoEq
    subst actual
    have boundEq : info.bound = bound := congrArg CellInfo.bound cellEq
    have exact : result.minimumLength = result.staticLength := by omega
    have summary := expressionAt_frozen_summary normal static parsed exact
    have safe := expressionAt_safe normal static parsed bounded
    have same : (value.freezeImages (frozenIntegers state.scalarNames)).summary state.names.shape = bound.summary := by
      rw [summary, ← boundEq]
      have lengthEq : result.staticLength = info.staticLength := by omega
      have countEq : result.dynamicCount = if info.dynamic then 1 else 0 := by omega
      have zero := normal _ _ found
      cases dynamic : info.dynamic
      · simp [BindingInfo.bound, Bindings.Bound.summary, lengthEq, countEq, dynamic]
      · simp [BindingInfo.bound, Bindings.Bound.summary, lengthEq, countEq, dynamic, zero dynamic]
    refine ⟨⟨bound, present, Expression.infer_iff.mpr ⟨safe.1, same⟩, safe.2.1⟩, safe, ?_⟩
    simp [observed, bounded, correct, nonempty]

theorem output_safe {text : Source} {state : ParserState} {expression : Expression}
    (normal : NamesNormal state.names) (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ExpressionAt (scalarNames := state.scalarNames) text state.names state.position expression (expressionAt text state.position state.names state.scalarNames))
    (accepted : (outputAt text state).position ≠ 0) :
    SafeExpression (expression.freezeImages (frozenIntegers state.scalarNames)) state.names.shape state.capacity ∧ outputAt text state =
      {state with position := (expressionAt text state.position state.names state.scalarNames).after} := by
  have bounded : fits (expressionAt text state.position state.names state.scalarNames) state.capacity = true := by
    by_cases good : fits (expressionAt text state.position state.names state.scalarNames) state.capacity = true
    · exact good
    · simp [outputAt, good, invalidState] at accepted
  exact ⟨expressionAt_safe normal static parsed bounded, by simp [outputAt, bounded]⟩

theorem comparison_safe {text : Source} {state : ParserState} {left right : Expression}
    (normal : NamesNormal state.names) (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (first : ExpressionAt (scalarNames := state.scalarNames) text state.names state.position left (expressionAt text state.position state.names state.scalarNames))
    (second : ExpressionAt (scalarNames := state.scalarNames) text state.names (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false)
      right (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames))
    (accepted : (comparisonAt text state).position ≠ 0) :
    SafeExpression (left.freezeImages (frozenIntegers state.scalarNames)) state.names.shape state.capacity ∧
      SafeExpression (right.freezeImages (frozenIntegers state.scalarNames)) state.names.shape state.capacity ∧
    comparisonAt text state = {state with position := (expressionAt text
      (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames).after} := by
  dsimp only [comparisonAt] at accepted ⊢
  split at accepted
  · rename_i good
    rw [ite_eq_left good]
    simp only [Bool.and_eq_true] at good
    obtain ⟨⟨leftBound, rightBound⟩, _⟩ := good
    exact ⟨expressionAt_safe normal static first leftBound,
      expressionAt_safe normal static second rightBound, rfl⟩
  · exact False.elim (accepted rfl)

/-- Equality has a resolved String object on at least one side. Literal-only
Ada equality would be overload-ambiguous even though its byte meaning is clear. -/
theorem comparison_anchor {text : Source} {state : ParserState} {left right : Expression}
    (first : ExpressionAt (scalarNames := state.scalarNames) text state.names state.position left (expressionAt text state.position state.names state.scalarNames))
    (second : ExpressionAt (scalarNames := state.scalarNames) text state.names (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false)
      right (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames).after "=" false) state.names state.scalarNames))
    (accepted : (comparisonAt text state).position ≠ 0) : (left.hasName || right.hasName) = true := by
  dsimp only [comparisonAt] at accepted
  split at accepted
  · rename_i good
    simp only [Bool.and_eq_true] at good
    simpa only [expressionAt_named first, expressionAt_named second] using good.2
  · exact False.elim (accepted rfl)

theorem step_valid {text : Source} {form : Form} {token : ShellToken}
    {state next : ParserState} {event : Option Event}
    (domain : text.length ≤ maxSourceLength) (valid : StateValid state)
    (parsed : StepAt text form token state next event) : StateValid next ∧ EventValid state next event := by
  obtain ⟨positive, following, scanned, payload, _⟩ := parsed
  cases token with
  | declarations =>
      obtain ⟨values, source, rfl⟩ := payload
      obtain ⟨capacity, target, _, _⟩ := declarations_fields source
      refine ⟨⟨declarations_normal source valid.1, capacity ▸ valid.2.1, ?_, declarations_static source valid.2.2.2⟩, ?_⟩
      · rcases valid.2.2.1 with zero | ⟨bound, present⟩
        · exact Or.inl (target.trans zero)
        · exact Or.inr ⟨bound, target ▸ declarations_extend (declarations_shape valid.1 valid.2.2.2 source) present⟩
      · intro rest remaining
        exact ⟨declarations_shape valid.1 valid.2.2.2 source, capacity ▸ remaining⟩
  | argumentDeclaration =>
      obtain ⟨fallback, source, rfl⟩ := payload
      obtain ⟨empty, names, _⟩ := argument_shape source
      obtain ⟨capacity, target⟩ := argument_fields source
      have targetZero : state.target = 0 := by
        rcases valid.2.2.1 with zero | ⟨bound, present⟩
        · exact zero
        · rw [empty] at present; cases present
      have static : ScalarExpression.StaticEnvironment next.scalarNames := by
        cases source
        exact valid.2.2.2
      refine ⟨⟨argument_normal source, capacity ▸ valid.2.1, Or.inl (target.trans targetZero), static⟩, ?_⟩
      have fallbackDomain : Printable fallback ∧ fallback.length ≤ maxSourceLength := by
        cases source with
        | argument _ _ _ _ literal =>
            have bounds := literalReading_domain literal
            exact ⟨bounds.2, Nat.le_trans bounds.1 domain⟩
      intro rest remaining
      exact ⟨fallbackDomain.1, fallbackDomain.2, names ▸ capacity ▸ remaining⟩
  | contextClauses | fixed spelling word =>
      simp only [PayloadAt] at payload
      subst event
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      exact ⟨valid, fun _ remaining => remaining⟩
  | literal =>
      obtain ⟨bytes, source, rfl⟩ := payload
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      exact ⟨valid, fun _ remaining => ⟨(literalReading_domain source).2, remaining⟩⟩
  | assignmentValue =>
      obtain ⟨value, source, rfl⟩ := payload
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      obtain ⟨safe, rhsSafe, names, capacity, target⟩ := assignment_safe valid.1 valid.2.2.2 valid.2.2.1 source following
      have scalarNames : (assignmentAt text state).scalarNames = state.scalarNames := by
        dsimp only [assignmentAt] at following ⊢
        split <;> (try split) <;> simp_all [invalidState]
      refine ⟨?_, ?_⟩
      · simpa only [StateValid, TargetValid, names, capacity, target, scalarNames] using valid
      · intro rest remaining
        change _ ∧ _ ∧ StreamValid state.names.shape state.capacity rest
        exact ⟨safe, rhsSafe, by simpa only [names, capacity] using remaining⟩
  | outputExpression =>
      obtain ⟨expression, source, rfl⟩ := payload
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      obtain ⟨safe, same⟩ := output_safe valid.1 valid.2.2.2 source following
      rw [same]
      exact ⟨valid, fun _ remaining => ⟨safe, remaining⟩⟩
  | comparisonExpression =>
      obtain ⟨left, right, first, second, rfl⟩ := payload
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      obtain ⟨leftSafe, rightSafe, same⟩ := comparison_safe valid.1 valid.2.2.2 first second following
      rw [same]
      exact ⟨valid, fun _ remaining => ⟨leftSafe, rightSafe, remaining⟩⟩
  | capacity =>
      simp only [PayloadAt] at payload
      subst event
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      generalize resultEq : Guarded.decimalAt text (skipAt text state.position) = result at *
      have observed : capacityAt text state =
          if skipAt text state.position = 0 ∨ result.after = 0 then invalidState
          else {state with position := result.after, capacity := result.value} := by simp only [capacityAt, resultEq]
      by_cases failed : skipAt text state.position = 0 ∨ result.after = 0
      · simp [observed, failed, invalidState] at following
      · have nonzero : (Guarded.decimalAt text (skipAt text state.position)).after ≠ 0 := by rw [resultEq]; omega
        have bounds := Guarded.decimalAt_bounds (Guarded.decimalAt_sound text _ nonzero)
        rw [resultEq] at bounds
        have same : capacityAt text state = {state with position := result.after, capacity := result.value} := by simp [observed, failed]
        rw [same]
        exact ⟨⟨valid.1, bounds.2.2, valid.2.2.1, valid.2.2.2⟩, fun _ remaining => ⟨bounds.2.2, remaining⟩⟩
  | dynamicReference =>
      simp only [PayloadAt] at payload
      subst event
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      dsimp only [dynamicAt] at following ⊢
      split
      · rename_i failed
        rw [ite_eq_left failed] at following
        exact False.elim (following rfl)
      · exact ⟨valid, fun _ remaining => remaining⟩
  | assignmentTarget | targetReference =>
      simp only [PayloadAt] at payload
      subst event
      simp only [step, positive, ↓reduceIte] at scanned
      subst next
      dsimp only [targetAt] at following ⊢
      split
      · rename_i failed
        rw [ite_eq_left failed] at following
        exact False.elim (following rfl)
      · rename_i accepted
        have nonzero : lookupName text state.names (skipAt text state.position) (nameAfter text (skipAt text state.position)) ≠ 0 := by omega
        obtain ⟨_, _, info, found, _⟩ := lookupName_found nonzero
        have notfalse : info.mutable ≠ false := by
          intro isfalse
          exact accepted (Or.inr (Or.inr (Or.inl (by simpa only [found, Option.getD_some] using isfalse))))
        have mutable : info.mutable = true := by cases h : info.mutable <;> simp_all only [Bool.false_eq_true]
        refine ⟨⟨valid.1, valid.2.1, Or.inr ⟨info.bound, ?_⟩, valid.2.2.2⟩, fun _ remaining => remaining⟩
        simp [BindingEnvironment.shape, found, BindingInfo.cell, mutable]

inductive Parsed (text : Source) (form : Form) : List ShellToken → ParserState → List Event → Prop
  | done {state : ParserState} : state.position ≠ 0 → Cursor.triviaPosition text state.position = text.length + 1 →
      Parsed text form [] state []
  | next {token : ShellToken} {tokens : List ShellToken} {state following : ParserState}
      {event : Option Event} {rest : List Event} :
      StepAt text form token state following event → Parsed text form tokens following rest →
      Parsed text form (token :: tokens) state (event.toList ++ rest)

theorem parsed_positive {text : Source} {form : Form} {tokens : List ShellToken}
    {state : ParserState} {events : List Event} (parsed : Parsed text form tokens state events) : state.position ≠ 0 := by
  cases parsed with
  | done positive _ => exact positive
  | next first _ => exact first.positive

theorem parsed_complete {text : Source} {form : Form} {tokens : List ShellToken}
    {state : ParserState} {events : List Event} (parsed : Parsed text form tokens state events) :
    suffixMatches text form tokens state = true := by
  induction parsed with
  | done positive finish => simp [suffixMatches, positive, finish]
  | next first rest ih => simp only [suffixMatches, first.positive, ↓reduceIte, first.scanned]; exact ih

theorem suffix_positive {text : Source} {form : Form} {tokens : List ShellToken} {state : ParserState}
    (accepted : suffixMatches text form tokens state = true) : state.position ≠ 0 := by
  cases tokens with
  | nil => simp only [suffixMatches, decide_eq_true_eq] at accepted; exact accepted.1
  | cons token tokens =>
      by_cases zero : state.position = 0
      · simp [suffixMatches, zero] at accepted
      · exact zero

theorem parsed_sound (text : Source) (form : Form) (tokens : List ShellToken) (state : ParserState)
    (accepted : suffixMatches text form tokens state = true) : ∃ events, Parsed text form tokens state events := by
  induction tokens generalizing state with
  | nil =>
      simp only [suffixMatches, decide_eq_true_eq] at accepted
      exact ⟨[], .done accepted.1 accepted.2⟩
  | cons token tokens ih =>
      have positive := suffix_positive accepted
      have remaining : suffixMatches text form tokens (step text form token state) = true := by
        simpa only [suffixMatches, positive, ↓reduceIte] using accepted
      obtain ⟨event, first⟩ := step_sound text form token state positive (suffix_positive remaining)
      obtain ⟨rest, parsed⟩ := ih _ remaining
      exact ⟨event.toList ++ rest, .next first parsed⟩

theorem parsed_unique {text : Source} {form : Form} {tokens : List ShellToken}
    {state : ParserState} {left right : List Event} (first : Parsed text form tokens state left)
    (second : Parsed text form tokens state right) : left = right := by
  induction first generalizing right with
  | done => cases second; rfl
  | next head rest ih =>
      cases second with
      | next other tail =>
          obtain ⟨rfl, rfl⟩ := step_unique head other
          rw [ih tail]

theorem parsed_kinds {text : Source} {form : Form} {tokens : List ShellToken}
    {state : ParserState} {events : List Event} (parsed : Parsed text form tokens state events) :
    events.map Event.kind = tokens.filterMap ShellToken.eventKind := by
  induction parsed with
  | done => rfl
  | @next token tokens state following event rest head tail ih =>
      have kind := step_kind head
      simp only [List.map_append, ih, List.filterMap_cons]
      cases event <;> simp only [Option.map, Option.toList] at kind ⊢
      · rw [← kind]; rfl
      · rw [← kind]; rfl

theorem parsed_valid {text : Source} {form : Form} {tokens : List ShellToken}
    {state : ParserState} {events : List Event} (domain : text.length ≤ maxSourceLength)
    (parsed : Parsed text form tokens state events) (valid : StateValid state) :
    StreamValid state.names.shape state.capacity events := by
  induction parsed with
  | done => trivial
  | next head tail ih =>
      obtain ⟨nextValid, eventValid⟩ := step_valid domain valid head
      exact eventValid _ (ih nextValid)

def FormMember (source : Source) (form : Form) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧ source.all allowedCharacter = true ∧
    withinWorkBudget source = true ∧ ∃ events, Parsed source form form.tokens initialState events

def Member (source : Source) : Prop := ∃ form, FormMember source form

def SourceMeaning (source : Source) (form : Form) (events : List Event) : Prop :=
  FormMember source form ∧ selectedForm source = some form ∧ Parsed source form form.tokens initialState events

theorem formAccepts_iff (source : Source) (form : Form) : formAccepts source form = true ↔ FormMember source form := by
  simp only [formAccepts, Bool.and_eq_true, decide_eq_true_eq, FormMember]
  constructor
  · rintro ⟨⟨⟨⟨positive, bounded⟩, characters⟩, workBudget⟩, accepted⟩
    exact ⟨positive, bounded, characters, workBudget, parsed_sound source form form.tokens initialState accepted⟩
  · rintro ⟨positive, bounded, characters, workBudget, events, parsed⟩
    exact ⟨⟨⟨⟨positive, bounded⟩, characters⟩, workBudget⟩, parsed_complete parsed⟩

theorem all_forms (form : Form) : form ∈ allForms := by cases form <;> simp [allForms]

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp only [accepts, selectedForm, List.find?_isSome]
  constructor
  · rintro ⟨form, _, accepted⟩
    exact ⟨form, (formAccepts_iff source form).mp accepted⟩
  · rintro ⟨form, member⟩
    exact ⟨form, all_forms form, (formAccepts_iff source form).mpr member⟩

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ form events, SourceMeaning source form events := by
  have accepted := (accepts_iff_member source).mpr member
  simp only [accepts, Option.isSome_iff_exists] at accepted
  obtain ⟨form, selected⟩ := accepted
  have found : formAccepts source form = true := List.find?_some selected
  have sourceMember := (formAccepts_iff source form).mp found
  obtain ⟨events, parsed⟩ := sourceMember.2.2.2.2
  exact ⟨form, events, sourceMember, selected, parsed⟩

theorem meaning_unique {source : Source} {left right : Form} {first second : List Event}
    (a : SourceMeaning source left first) (b : SourceMeaning source right second) : left = right ∧ first = second := by
  have same : left = right := Option.some.inj (a.2.1.symm.trans b.2.1)
  subst right
  exact ⟨rfl, parsed_unique a.2.2 b.2.2⟩

theorem meaning_eventKinds {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : events.map Event.kind = form.tokens.filterMap ShellToken.eventKind :=
  parsed_kinds meaning.2.2

theorem meaning_stream_valid {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : StreamValid emptyShape maxSourceLength events := by
  have valid := parsed_valid meaning.1.2.1 meaning.2.2 initial_valid
  simpa only [initialState, empty_names_shape] using valid

end Silver.Compose
