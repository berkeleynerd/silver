module

public import Silver.ComposeArrayEquations

@[expose] public section

namespace Silver.Compose.Expressions
open Named

variable {domain : StateDomain}

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read scalarConstraintAt

private theorem state_array_metadata {text : Source} {state : ParserState}
    (valid : ValidState text state) : ArrayBindings.ValidMetadata text state.arrayNames.names :=
  valid.2.2.2.2.2.2.1.1

private theorem state_array_initials {text : Source} {state : ParserState}
    (valid : ValidState text state) : ArrayBindings.ValidInitials state.arrayNames.values :=
  valid.2.2.2.2.2.2.1.2.2.1

@[simp] theorem interpreted_declaration (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : domain.holds text state) :
    calls.function .declaration text state arguments = declarationAt text state arguments := by
  rw [equations.declaration text valid state arguments stateValid]
  dsimp +instances only [declarationBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, interpreted_subtypeDeclaration calls equations text valid state arguments stateValid, interpreted_scalarDeclaration calls equations text valid state arguments stateValid, interpreted_stringDeclaration calls equations text valid state arguments stateValid, interpreted_arrayDeclaration calls equations text valid state arguments stateValid, decide_eq_true_eq]
  rfl

set_option backward.dsimp.instances true in
@[simp] theorem interpreted_argument (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : domain.holds text state) :
    calls.function .argument text state = argumentAt text state := by
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  have bfirst : ValidCursor text first := equations.ranges.skip text valid _ (domain.valid text state stateValid).1
  have bafter : ValidCursor text after := equations.ranges.name text valid _ bfirst
  have efirst : first = skipAt text state.position := interpreted_skip calls equations text valid _ (domain.valid text state stateValid).1
  have eafter : after = nameAfter text first := interpreted_name calls equations text valid _ bfirst
  let p0 := calls.function .takeToken text after (.symbol ":")
  have bp0 : ValidCursor text p0 := equations.ranges.token text valid _ _ bafter (by unfold ValidToken; decide)
  have ep0 : p0 = fixedAfter text after ":" false :=
    interpreted_take calls equations text valid _ _ bafter (by unfold ValidToken; decide)
  let p1 := calls.function .takeToken text p0 (.word "constant")
  have bp1 : ValidCursor text p1 := equations.ranges.token text valid _ _ bp0 (by unfold ValidToken; decide)
  have ep1 : p1 = fixedAfter text p0 "constant" true :=
    interpreted_take calls equations text valid _ _ bp0 (by unfold ValidToken; decide)
  let p2 := calls.function .takeToken text p1 (.word "string")
  have bp2 : ValidCursor text p2 := equations.ranges.token text valid _ _ bp1 (by unfold ValidToken; decide)
  have ep2 : p2 = fixedAfter text p1 "string" true :=
    interpreted_take calls equations text valid _ _ bp1 (by unfold ValidToken; decide)
  let p3 := calls.function .takeToken text p2 (.symbol ":=")
  have bp3 : ValidCursor text p3 := equations.ranges.token text valid _ _ bp2 (by unfold ValidToken; decide)
  have ep3 : p3 = fixedAfter text p2 ":=" false :=
    interpreted_take calls equations text valid _ _ bp2 (by unfold ValidToken; decide)
  let nameCheck := calls.function .takeToken text first (.word "first_or_default")
  have echeck : nameCheck = fixedAfter text first "first_or_default" true :=
    interpreted_take calls equations text valid _ _ bfirst (by unfold ValidToken; decide)
  let hidden := (decide (first ≠ 0) && decide (after > first)) && decide (nameCheck = after)
  let p4 := calls.names.operationAfter text p3 .argument hidden
  have ep4 : p4 = Names.operationAfter text p3 .argument hidden :=
    Names.interpreted_operation calls.names equations.names text valid p3 .argument hidden bp3
  have bp4 : ValidCursor text p4 := by
    rw [ep4]
    exact Names.operationAfter_bound text p3 .argument hidden bp3
  let p5 := calls.function .takeToken text p4 (.symbol "(")
  have bp5 : ValidCursor text p5 := equations.ranges.token text valid _ _ bp4 (by unfold ValidToken; decide)
  have ep5 : p5 = fixedAfter text p4 "(" false :=
    interpreted_take calls equations text valid _ _ bp4 (by unfold ValidToken; decide)
  let p6 := calls.names.associationAfter text p5 true
  have ep6 : p6 = Names.associationAfter text p5 true :=
    Names.interpreted_association calls.names equations.names text valid p5 true bp5
  have bp6 : ValidCursor text p6 := by
    rw [ep6]
    exact Names.associationAfter_bound text p5 true bp5
  let defaultPosition := calls.function .skip text p6
  let fallback := calls.function .literal text defaultPosition
  let close := calls.function .takeToken text fallback.after (.symbol ")")
  let following := calls.function .takeToken text close (.symbol ";")
  have bdefault : ValidCursor text defaultPosition := equations.ranges.skip text valid _ bp6
  have bfallback : ValidValue text fallback := equations.ranges.literal text valid _ bdefault
  have bclose : ValidCursor text close := equations.ranges.token text valid _ _ bfallback.1 (by unfold ValidToken; decide)
  have bfollowing : ValidCursor text following := equations.ranges.token text valid _ _ bclose (by unfold ValidToken; decide)
  have edefault : defaultPosition = skipAt text p6 := interpreted_skip calls equations text valid _ bp6
  have efallback : fallback = literalAt text defaultPosition := interpreted_literal calls equations text valid _ bdefault
  have eclose : close = fixedAfter text fallback.after ")" false := interpreted_take calls equations text valid _ _ bfallback.1 (by unfold ValidToken; decide)
  have efollowing : following = fixedAfter text close ";" false := interpreted_take calls equations text valid _ _ bclose (by unfold ValidToken; decide)
  have ename := interpreted_newName calls equations text valid state first after true stateValid bfirst bafter
  rw [equations.argument text valid state stateValid]
  dsimp +instances only [argumentBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  change (if !calls.function .newName text state first after true || decide (following = 0) ||
    decide (state.names.length ≠ 0) then invalidState
    else {calls.function .addBinding state first after ⟨following, 0, 0, 0, true, true, false, 0⟩ false following with
      dynamicFirst := first, dynamicAfter := after}) = _
  by_cases empty : state.names.length = 0
  · have room : state.names.length < maxBindings := by simp [empty, maxBindings, maxSourceLength]
    have bvalue : ValidValue text ⟨following, 0, 0, 0, true, true, false, 0⟩ := ⟨bfollowing, Nat.zero_le _, Nat.zero_le _, Nat.zero_le _, Nat.zero_le _⟩
    rw [interpreted_addBinding calls equations text valid state first after _ false following
      stateValid bfirst bafter bvalue bfollowing room, ename]
    simp only [efollowing, eclose, efallback, edefault, ep6, ep5, ep4, ep3, ep2, ep1, ep0, hidden, echeck, eafter, efirst]
    dsimp +instances only [argumentAt, argumentParts, argumentFirst, argumentAfter, argumentDefaultPosition,
      tokenAfter, ShellToken.word, ShellToken.symbol]
    simp [empty]
  · simp [empty, argumentAt]

@[simp] theorem interpreted_declarations (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : domain.holds text state) :
    calls.function .declarations text state arguments = declarationsAt text state arguments := by
  have etoken := interpreted_take calls equations text valid state.position (.word "begin") (domain.valid text state stateValid).1
    (by unfold ValidToken; decide)
  simp only [ShellToken.word, spelling, isWord] at etoken
  have edeclaration := interpreted_declaration calls equations text valid state arguments stateValid
  have nextValid : domain.holds text (declarationAt text state arguments) := by
    rw [← edeclaration]
    exact (equations.ranges.declaration text valid state arguments stateValid).1
  rw [equations.declarations text valid state arguments stateValid]
  dsimp +instances only [declarationsBody, Expr.eval, Context.locals, lexical, Calls.get, Field.get]
  simp only [decide_eq_true_eq]
  simp only [etoken, edeclaration]
  rw [declarationsAt_equation text state arguments (by
    have strings := (domain.valid text state stateValid).2.1.1
    have scalars := (domain.valid text state stateValid).2.2.2.2.2.1.1
    have arrays := (state_array_metadata (domain.valid text state stateValid)).1
    have subtypes := (domain.valid text state stateValid).2.2.2.2.2.2.2.1
    omega)]
  split
  · rfl
  · split
    · rfl
    · split
      · rfl
      · exact interpreted_declarations calls equations text valid (declarationAt text state arguments)
          arguments nextValid
termination_by
  (maxBindings + ScalarExpression.maxBindings + ArrayBindings.maxBindings + IntegerSubtypes.maxBindings) + 1 -
    (state.names.length + state.scalarNames.length + state.arrayNames.names.length + state.subtypeNames.items.length)
decreasing_by
  have count := declarationAt_count (text := text) (state := state) (arguments := arguments) (by assumption)
  have _bounded := (domain.valid text state stateValid).2.1.1
  have nextBound := (domain.valid text (declarationAt text state arguments) nextValid).2.1.1
  have nextScalarBound := (domain.valid text (declarationAt text state arguments) nextValid).2.2.2.2.2.1.1
  have nextArrayBound := (state_array_metadata (domain.valid text (declarationAt text state arguments) nextValid)).1
  have nextSubtypeBound := (domain.valid text (declarationAt text state arguments) nextValid).2.2.2.2.2.2.2.1
  omega

@[simp] theorem interpreted_output (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : domain.holds text state) :
    calls.function .output text state = outputAt text state := by
  have resultValid := equations.ranges.expression text valid state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true (domain.valid text state stateValid).1 (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have evalue := interpreted_expression (integerHidden := false) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) calls equations text valid state.position state.names (domain.valid text state stateValid).1 (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have efits := interpreted_fits calls equations text valid _ state.capacity resultValid (domain.valid text state stateValid).2.2.2.2.1
  rw [equations.output text valid state stateValid]
  dsimp +instances only [outputBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte]
  rw [efits, evalue]
  cases h : fits (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true) state.capacity <;> simp [outputAt, h]

@[simp] theorem interpreted_comparison (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : domain.holds text state) :
    calls.function .comparison text state = comparisonAt text state := by
  let lhs := calls.function .expression text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true
  let after := calls.function .takeToken text lhs.after (.symbol "=")
  let rhs := calls.function .expression text after state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true
  have blhs : ValidResult text lhs := equations.ranges.expression text valid _ _ state.scalarNames false state.arrayNames.names state.arrayNames.values true (domain.valid text state stateValid).1 (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have bafter : ValidCursor text after := equations.ranges.token text valid _ _ blhs.1 (by unfold ValidToken; decide)
  have brhs : ValidResult text rhs := equations.ranges.expression text valid _ _ state.scalarNames false state.arrayNames.names state.arrayNames.values true bafter (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have elhs : lhs = expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true :=
    interpreted_expression (integerHidden := false) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) calls equations text valid _ _ (domain.valid text state stateValid).1 (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have eafter : after = fixedAfter text lhs.after "=" false :=
    interpreted_take calls equations text valid _ _ blhs.1 (by unfold ValidToken; decide)
  have erhs : rhs = expressionAt text after state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true :=
    interpreted_expression (integerHidden := false) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) calls equations text valid _ _ bafter (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have flhs := interpreted_fits calls equations text valid lhs state.capacity blhs (domain.valid text state stateValid).2.2.2.2.1
  have frhs := interpreted_fits calls equations text valid rhs state.capacity brhs (domain.valid text state stateValid).2.2.2.2.1
  rw [equations.comparison text valid state stateValid]
  dsimp +instances only [comparisonBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  change (if (!calls.function .fits lhs state.capacity || !calls.function .fits rhs state.capacity) ||
    !(lhs.namedSeen || rhs.namedSeen) then invalidState else {state with position := rhs.after}) = _
  rw [flhs, frhs, erhs, eafter, elhs]
  dsimp only [comparisonAt]
  generalize fits (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true) state.capacity = a
  generalize fits (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).after "=" false) state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true) state.capacity = b
  generalize (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).namedSeen = c
  generalize (expressionAt text (fixedAfter text (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).after "=" false) state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).namedSeen = d
  cases a <;> cases b <;> cases c <;> cases d <;> rfl

@[simp] theorem interpreted_target (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (sameTarget : Bool)
    (stateValid : domain.holds text state) :
    calls.function .target text state sameTarget = targetAt text state sameTarget := by
  have skipBound := equations.ranges.skip text valid state.position (domain.valid text state stateValid).1
  have nameBound := equations.ranges.name text valid _ skipBound
  have skipEq := interpreted_skip calls equations text valid state.position (domain.valid text state stateValid).1
  have nameEq := interpreted_name calls equations text valid _ skipBound
  have lookupEq := interpreted_lookup calls equations text valid state.names _ _ (domain.valid text state stateValid).2.1 skipBound nameBound
  rw [equations.target text valid state sameTarget stateValid]
  dsimp +instances only [targetBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [lookupEq, equations.scalarLookup text valid state.scalarNames _ _ (domain.valid text state stateValid).2.2.2.2.2.1 skipBound nameBound, nameEq, skipEq]
  simp [targetAt, Bool.or_eq_true, Bool.and_eq_true, or_assoc]

@[simp] theorem interpreted_dynamic (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : domain.holds text state) :
    calls.function .dynamic text state = dynamicAt text state := by
  have skipBound := equations.ranges.skip text valid state.position (domain.valid text state stateValid).1
  have skipEq := interpreted_skip calls equations text valid state.position (domain.valid text state stateValid).1
  have nameEq := interpreted_name calls equations text valid _ skipBound
  rw [equations.dynamic text valid state stateValid]
  dsimp +instances only [dynamicBody, Expr.eval, Context.locals, Locals.set, lexical, modelPrimitives, Calls.get, Field.get]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
  rw [nameEq, skipEq]
  simp [dynamicAt, Bool.or_eq_true, or_assoc]

@[simp] theorem interpreted_assignmentValue (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : domain.holds text state) :
    calls.function .assignmentValue text state = assignmentAt text state := by
  have resultValid := equations.ranges.expression text valid state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true (domain.valid text state stateValid).1 (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have evalue := interpreted_expression (integerHidden := false) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) calls equations text valid state.position state.names (domain.valid text state stateValid).1 (domain.valid text state stateValid).2.1 (domain.valid text state stateValid).2.2.2.2.2.1 (state_array_metadata (domain.valid text state stateValid)) (state_array_initials (domain.valid text state stateValid))
  have efits := interpreted_fits calls equations text valid _ state.capacity resultValid (domain.valid text state stateValid).2.2.2.2.1
  rw [equations.assignmentValue text valid state stateValid]
  dsimp +instances only [assignmentBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte]
  rw [efits, evalue]
  simp only [assignmentAt, Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]
  have reorder (a b c d e f : Prop) :
      (a ∨ b ∨ c ∨ d ∨ e ∨ f) ↔ (a ∨ c ∨ d ∨ b ∨ e ∨ f) := by
    simp only [or_left_comm]
  congr 1
  exact propext (reorder _ _ _ _ _ _)

@[simp] theorem interpreted_capacity (calls : Calls) (equations : HelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : domain.holds text state) :
    calls.function .capacity text state = capacityAt text state := by
  rw [equations.capacity text valid state stateValid]
  dsimp +instances only [capacityBody, Expr.eval, Context.locals, lexical, modelPrimitives, Field.get, capacityAt, skipAt]
  simp only [decide_eq_true_eq]
  by_cases zero : state.position = 0
  · simp [zero]
  · have positive : Cursor.triviaPosition text state.position ≠ 0 := by
      have lower := (Cursor.triviaPosition_bounds text state.position (by omega) (domain.valid text state stateValid).1).1
      omega
    simp [zero, positive]

end Silver.Compose.Expressions
