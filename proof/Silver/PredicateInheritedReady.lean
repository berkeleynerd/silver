module

public import Silver.PredicateOuterReadiness
public import Silver.ComposeModel
public import Silver.ComposeSourceBridge
public import Silver.FunctionDeclarationModelSource

@[expose] public section

namespace Silver.Predicate.InheritedReady
open Compose
open Compose.Expressions

/-- Concrete preservation supplies every strengthened native helper range.
Only the independent mathematical witness uses the wider base-domain model. -/
theorem model_ranges : HelperRanges Compose.Expressions.modelCalls OuterReadiness.domain where
  skip := Compose.Expressions.model_ranges.skip
  name := Compose.Expressions.model_ranges.name
  token := Compose.Expressions.model_ranges.token
  lookup := Compose.Expressions.model_ranges.lookup
  literal := Compose.Expressions.model_ranges.literal
  image := Compose.Expressions.model_ranges.image
  value := Compose.Expressions.model_ranges.value
  expressionStep := Compose.Expressions.model_ranges.expressionStep
  expression := Compose.Expressions.model_ranges.expression
  stringDeclaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.stringDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
    exact ⟨⟨⟨bounded.1.base, OuterReadiness.stringDeclaration_ready text state arguments sv.base.ready,
      bounded.1.bounds⟩, bounded.1.bounds⟩, bounded.2⟩
  subtypeDeclaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.subtypeDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
    exact ⟨⟨⟨bounded.1.base, OuterReadiness.subtypeDeclaration_ready text state arguments sv.base.ready,
      bounded.1.bounds⟩, bounded.1.bounds⟩, bounded.2⟩
  scalarType text tv state position sv pv :=
    Compose.Expressions.model_ranges.scalarType text tv state position ⟨sv.valid, sv.bounds⟩ pv
  scalarDeclaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.scalarDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
    exact ⟨⟨⟨bounded.1.base, OuterReadiness.scalarDeclaration_ready text state arguments sv.base.ready,
      bounded.1.bounds⟩, bounded.1.bounds⟩, bounded.2⟩
  arrayDeclaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.arrayDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
    exact ⟨⟨⟨bounded.1.base, OuterReadiness.arrayDeclaration_ready text state arguments sv.base.ready,
      bounded.1.bounds⟩, bounded.1.bounds⟩, bounded.2⟩
  declaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.declaration text tv state arguments ⟨sv.valid, sv.bounds⟩
    exact ⟨⟨⟨bounded.1.base, OuterReadiness.declaration_ready text state arguments sv.base.ready,
      bounded.1.bounds⟩, bounded.1.bounds⟩, bounded.2⟩
  argument text tv state sv := by
    have bounded := Compose.Expressions.model_ranges.argument text tv state ⟨sv.valid, sv.bounds⟩
    exact ⟨⟨bounded.base, OuterReadiness.argument_ready text state sv.base.ready, bounded.bounds⟩,
      bounded.bounds⟩
  declarations text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.declarations text tv state arguments ⟨sv.valid, sv.bounds⟩
    exact ⟨⟨bounded.base, OuterReadiness.declarations_ready text state arguments sv.base.ready, bounded.bounds⟩,
      bounded.bounds⟩

private theorem base_definitions : HelperEquations Compose.Expressions.modelCalls Compose.Expressions.modelCalls :=
  (Compose.Expressions.model_definitions Compose.Expressions.model_ranges).toHelperEquations

private theorem base_array_domain {text source result position length parsed}
    (valid : ArrayValuesDomain text source result position length parsed OuterReadiness.domain) :
    ArrayValuesDomain text source result position length parsed :=
  ⟨⟨valid.sourceContext.valid, valid.sourceContext.bounds⟩,
    ⟨valid.resultContext.valid, valid.resultContext.bounds⟩, valid.positionValid,
    valid.parsedBound, valid.capacity, valid.used⟩

theorem model_definitions :
    HelperEquations Compose.Expressions.modelCalls Compose.Expressions.modelCalls OuterReadiness.domain where
  ranges := model_ranges
  names := base_definitions.names
  functionLookup := base_definitions.functionLookup
  procedureLookup := base_definitions.procedureLookup
  formalHides text tv state first after sv fv av :=
    base_definitions.formalHides text tv state first after ⟨sv.valid, sv.bounds⟩ fv av
  functionDeclaration text tv state arguments sv :=
    base_definitions.functionDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  fixedBounds := base_definitions.fixedBounds
  characterLiteral := base_definitions.characterLiteral
  guardedAt := base_definitions.guardedAt
  indexed := base_definitions.indexed
  characterValue := base_definitions.characterValue
  concatenatedFirst := base_definitions.concatenatedFirst
  concatenatedLast := base_definitions.concatenatedLast
  addBindingWithCharacter text tv state first after value mutable following characterObject sv fv av vv followingValid room fixed :=
    base_definitions.addBindingWithCharacter text tv state first after value mutable following characterObject
      ⟨sv.valid, sv.bounds⟩ fv av vv followingValid room fixed
  characterDeclaration text tv state arguments sv :=
    base_definitions.characterDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  scalarLookup := base_definitions.scalarLookup
  scalarRead := base_definitions.scalarRead
  arrayLookup := base_definitions.arrayLookup
  booleanLookup := base_definitions.booleanLookup
  booleanHidesInteger := base_definitions.booleanHidesInteger
  booleanDeclaration text tv state arguments sv := base_definitions.booleanDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  booleanInitializer text tv state position first after sv bounded mask :=
    base_definitions.booleanInitializer text tv state position first after ⟨sv.valid, sv.bounds⟩ bounded mask
  scalarLiteral := base_definitions.scalarLiteral
  scalarAppend := base_definitions.scalarAppend
  scalarEmpty := base_definitions.scalarEmpty
  imageMinimum := base_definitions.imageMinimum
  imageMaximum := base_definitions.imageMaximum
  nameIs := base_definitions.nameIs
  callAfter := base_definitions.callAfter
  skip := base_definitions.skip
  name := base_definitions.name
  fixed := base_definitions.fixed
  take := base_definitions.take
  lookupFrom := base_definitions.lookupFrom
  lookup := base_definitions.lookup
  literal := base_definitions.literal
  workTail := base_definitions.workTail
  workBudget := base_definitions.workBudget
  image := base_definitions.image
  value := base_definitions.value
  newName text tv state first after arguments sv fv av :=
    base_definitions.newName text tv state first after arguments ⟨sv.valid, sv.bounds⟩ fv av
  addBinding text tv state first after value mutable following sv fv av vv followingValid room :=
    base_definitions.addBinding text tv state first after value mutable following ⟨sv.valid, sv.bounds⟩ fv av vv followingValid room
  stringDeclaration text tv state arguments sv :=
    base_definitions.stringDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  scalarConstraint := base_definitions.scalarConstraint
  subtypeLookupModel := base_definitions.subtypeLookupModel
  subtypeLookup := base_definitions.subtypeLookup
  scalarType text tv state position sv pv :=
    base_definitions.scalarType text tv state position ⟨sv.valid, sv.bounds⟩ pv
  subtypeDeclaration text tv state arguments sv :=
    base_definitions.subtypeDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  scalarDeclaration text tv state arguments sv :=
    base_definitions.scalarDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  arrayPut := base_definitions.arrayPut
  arrayAdd text tv state first after bounds offset length mutable following componentBounds isBoolean sv nv bv room extent ordered cursor :=
    base_definitions.arrayAdd text tv state first after bounds offset length mutable following componentBounds isBoolean
      ⟨sv.valid, sv.bounds⟩ nv bv room extent ordered cursor
  arrayValuesModel text tv source result position length parsed componentBounds bounded valid :=
    base_definitions.arrayValuesModel text tv source result position length parsed componentBounds bounded (base_array_domain valid)
  arrayValues text tv source result position length parsed componentBounds bounded valid :=
    base_definitions.arrayValues text tv source result position length parsed componentBounds bounded (base_array_domain valid)
  booleanArrayValuesModel text tv source result position length parsed first after mask valid :=
    base_definitions.booleanArrayValuesModel text tv source result position length parsed first after mask (base_array_domain valid)
  booleanArrayValues text tv source result position length parsed first after mask valid :=
    base_definitions.booleanArrayValues text tv source result position length parsed first after mask (base_array_domain valid)
  arrayDeclaration text tv state arguments sv :=
    base_definitions.arrayDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  declaration text tv state arguments sv :=
    base_definitions.declaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  argument text tv state sv :=
    base_definitions.argument text tv state ⟨sv.valid, sv.bounds⟩
  declarations text tv state arguments sv :=
    base_definitions.declarations text tv state arguments ⟨sv.valid, sv.bounds⟩
  expressionStep := base_definitions.expressionStep
  tail := base_definitions.tail
  fits := base_definitions.fits
  comparison text tv state sv :=
    base_definitions.comparison text tv state ⟨sv.valid, sv.bounds⟩
  expression := base_definitions.expression
  target text tv state sameTarget sv :=
    base_definitions.target text tv state sameTarget ⟨sv.valid, sv.bounds⟩
  dynamic text tv state sv :=
    base_definitions.dynamic text tv state ⟨sv.valid, sv.bounds⟩
  assignmentValue text tv state sv :=
    base_definitions.assignmentValue text tv state ⟨sv.valid, sv.bounds⟩
  output text tv state sv :=
    base_definitions.output text tv state ⟨sv.valid, sv.bounds⟩
  capacity text tv state sv :=
    base_definitions.capacity text tv state ⟨sv.valid, sv.bounds⟩
  readDeclarations text tv state arguments sv :=
    base_definitions.readDeclarations text tv state arguments ⟨sv.valid, sv.bounds⟩

theorem model_legal : LegalHelpers Compose.Expressions.modelCalls OuterReadiness.domain where
  callAfter := Compose.Expressions.model_legal.callAfter
  skip := Compose.Expressions.model_legal.skip
  name := Compose.Expressions.model_legal.name
  fixed := Compose.Expressions.model_legal.fixed
  take := Compose.Expressions.model_legal.take
  lookupFrom := Compose.Expressions.model_legal.lookupFrom
  lookup := Compose.Expressions.model_legal.lookup
  literal := Compose.Expressions.model_legal.literal
  image := Compose.Expressions.model_legal.image
  value := Compose.Expressions.model_legal.value
  newName text tv state first after arguments sv fv av :=
    Compose.Expressions.model_legal.newName text tv state first after arguments ⟨sv.valid, sv.bounds⟩ fv av
  addBinding text tv state first after value mutable following sv fv av vv followingValid room :=
    Compose.Expressions.model_legal.addBinding text tv state first after value mutable following ⟨sv.valid, sv.bounds⟩ fv av vv followingValid room
  stringDeclaration text tv state arguments sv :=
    Compose.Expressions.model_legal.stringDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  scalarConstraint := Compose.Expressions.model_legal.scalarConstraint
  subtypeLookupModel := Compose.Expressions.model_legal.subtypeLookupModel
  scalarType text tv state position sv pv :=
    Compose.Expressions.model_legal.scalarType text tv state position ⟨sv.valid, sv.bounds⟩ pv
  subtypeDeclaration text tv state arguments sv :=
    Compose.Expressions.model_legal.subtypeDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  scalarDeclaration text tv state arguments sv :=
    Compose.Expressions.model_legal.scalarDeclaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  declaration text tv state arguments sv :=
    Compose.Expressions.model_legal.declaration text tv state arguments ⟨sv.valid, sv.bounds⟩
  argument text tv state sv :=
    Compose.Expressions.model_legal.argument text tv state ⟨sv.valid, sv.bounds⟩
  declarations text tv state arguments sv :=
    Compose.Expressions.model_legal.declarations text tv state arguments ⟨sv.valid, sv.bounds⟩
  expressionStep := Compose.Expressions.model_legal.expressionStep
  tail := Compose.Expressions.model_legal.tail
  fits := Compose.Expressions.model_legal.fits
  comparison text tv state sv :=
    Compose.Expressions.model_legal.comparison text tv state ⟨sv.valid, sv.bounds⟩
  expression := Compose.Expressions.model_legal.expression
  target text tv state sameTarget sv :=
    Compose.Expressions.model_legal.target text tv state sameTarget ⟨sv.valid, sv.bounds⟩
  dynamic text tv state sv :=
    Compose.Expressions.model_legal.dynamic text tv state ⟨sv.valid, sv.bounds⟩
  assignmentValue text tv state sv :=
    Compose.Expressions.model_legal.assignmentValue text tv state ⟨sv.valid, sv.bounds⟩
  output text tv state sv :=
    Compose.Expressions.model_legal.output text tv state ⟨sv.valid, sv.bounds⟩
  capacity text tv state sv :=
    Compose.Expressions.model_legal.capacity text tv state ⟨sv.valid, sv.bounds⟩
  workTail := Compose.Expressions.model_legal.workTail
  workBudget := Compose.Expressions.model_legal.workBudget

/-- A simultaneous inhabitant of the exact native ready-domain interface.
The final arbitrary-callee endpoint uses this domain directly, and does not
assume equations for native calls outside their preconditions. -/
theorem model_interpreted :
    Compose.SourceBridge.InterpretedSource Compose.Expressions.modelCalls where
  imageLengths := by
    refine ⟨Integer.Image.Native.modelCalls, Integer.Native.Function.eval,
      Integer.Image.NativeSource.model_interpreted, ?_⟩
    intro bounds bounded
    have minimum := Integer.Image.Native.minimumLength_eq bounds bounded
    have maximum := Integer.Image.Native.maximumLength_eq bounds bounded
    change (LengthSummary.ofImage bounds).minimumLength = Integer.Image.Native.minimumLength bounds ∧
      (LengthSummary.ofImage bounds).staticLength = Integer.Image.Native.maximumLength bounds
    rw [minimum, maximum]
    unfold LengthSummary.ofImage
    split <;> exact ⟨rfl, rfl⟩
  lexical := ⟨Guarded.Expressions.modelCalls, fixedAt, rfl, Lexical.model_interpreted⟩
  definitions := fun _ => model_definitions.toRawHelperEquations
  booleanDeclaration := by
    refine { source := ?_ }
    refine ⟨Compose.BooleanDeclarationNative.modelImports, Native.modelCalls,
      Native.model_helper_meaning, Native.model_definition_equations, Native.model_contracts,
      Compose.BooleanDeclarationNative.Libraries.model_links, ?_⟩
    intro text valid state arguments ready
    exact (Compose.BooleanDeclarationNative.model_meaning text state arguments).symm
  booleanInitializer := by
    refine { source := ?_ }
    refine ⟨Compose.BooleanInitializerNative.modelImports, Native.modelCalls,
      Native.model_helper_meaning, Native.model_definition_equations, Native.model_contracts,
      Compose.BooleanInitializerNative.Libraries.model_links, ?_⟩
    intro text valid state position first after ready bounded mask
    exact (Compose.BooleanInitializerNative.model_meaning ⟨text, state, position, first, after⟩).symm
  functionDeclaration := by
    let inherited : Compose.FunctionDeclarationNative.InheritedEquations
        Compose.Expressions.modelCalls OuterReadiness.domain :=
      { toRawHelperEquations := model_definitions.toRawHelperEquations
        booleanDeclaration := model_definitions.booleanDeclaration }
    let exactDomain : Compose.FunctionDeclarationNative.ExactDomain OuterReadiness.domain :=
      { state := fun _ _ =>
          ⟨fun valid => ⟨valid.base, valid.ready, valid.bounds⟩,
           fun valid => ⟨valid.base, valid.ready, valid.bounds⟩⟩ }
    exact ⟨⟨Compose.FunctionDeclarationNative.modelCalls,
      Compose.FunctionDeclarationNative.model_interpreted OuterReadiness.domain inherited exactDomain,
      rfl, rfl, rfl, rfl⟩⟩
  legal := model_legal
  step text tv form token state _ tokenValid sv :=
    (Compose.Expressions.model_definitions Compose.Expressions.model_ranges).step
      text tv form token state tokenValid sv.1
  stepLegal text tv form token state _ tokenValid sv :=
    Compose.Expressions.model_legal.step text tv form token state tokenValid sv.1

end Silver.Predicate.InheritedReady
