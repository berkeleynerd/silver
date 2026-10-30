module

public import Silver.PredicateOuterReadiness
public import Silver.ComposeModel

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
    have bounded := Compose.Expressions.model_ranges.stringDeclaration text tv state arguments sv.1
    exact ⟨⟨bounded.1, OuterReadiness.stringDeclaration_ready text state arguments sv.2⟩, bounded.2⟩
  subtypeDeclaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.subtypeDeclaration text tv state arguments sv.1
    exact ⟨⟨bounded.1, OuterReadiness.subtypeDeclaration_ready text state arguments sv.2⟩, bounded.2⟩
  scalarType text tv state position sv pv :=
    Compose.Expressions.model_ranges.scalarType text tv state position sv.1 pv
  scalarDeclaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.scalarDeclaration text tv state arguments sv.1
    exact ⟨⟨bounded.1, OuterReadiness.scalarDeclaration_ready text state arguments sv.2⟩, bounded.2⟩
  arrayDeclaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.arrayDeclaration text tv state arguments sv.1
    exact ⟨⟨bounded.1, OuterReadiness.arrayDeclaration_ready text state arguments sv.2⟩, bounded.2⟩
  declaration text tv state arguments sv := by
    have bounded := Compose.Expressions.model_ranges.declaration text tv state arguments sv.1
    exact ⟨⟨bounded.1, OuterReadiness.declaration_ready text state arguments sv.2⟩, bounded.2⟩
  argument text tv state sv :=
    ⟨Compose.Expressions.model_ranges.argument text tv state sv.1,
      OuterReadiness.argument_ready text state sv.2⟩
  declarations text tv state arguments sv :=
    ⟨Compose.Expressions.model_ranges.declarations text tv state arguments sv.1,
      OuterReadiness.declarations_ready text state arguments sv.2⟩

private theorem base_definitions : HelperEquations Compose.Expressions.modelCalls Compose.Expressions.modelCalls :=
  (Compose.Expressions.model_definitions Compose.Expressions.model_ranges).toHelperEquations

private theorem base_array_domain {text source result position length parsed}
    (valid : ArrayValuesDomain text source result position length parsed OuterReadiness.domain) :
    ArrayValuesDomain text source result position length parsed :=
  ⟨valid.sourceContext.1, valid.resultContext.1, valid.positionValid,
    valid.parsedBound, valid.capacity, valid.used⟩

theorem model_definitions :
    HelperEquations Compose.Expressions.modelCalls Compose.Expressions.modelCalls OuterReadiness.domain where
  ranges := model_ranges
  names := base_definitions.names
  scalarLookup := base_definitions.scalarLookup
  scalarRead := base_definitions.scalarRead
  arrayLookup := base_definitions.arrayLookup
  booleanLookup := base_definitions.booleanLookup
  booleanHidesInteger := base_definitions.booleanHidesInteger
  booleanDeclaration text tv state arguments sv := base_definitions.booleanDeclaration text tv state arguments sv.1
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
    base_definitions.newName text tv state first after arguments sv.1 fv av
  addBinding text tv state first after value mutable following sv fv av vv followingValid room :=
    base_definitions.addBinding text tv state first after value mutable following sv.1 fv av vv followingValid room
  stringDeclaration text tv state arguments sv :=
    base_definitions.stringDeclaration text tv state arguments sv.1
  scalarConstraint := base_definitions.scalarConstraint
  subtypeLookupModel := base_definitions.subtypeLookupModel
  subtypeLookup := base_definitions.subtypeLookup
  scalarType text tv state position sv pv :=
    base_definitions.scalarType text tv state position sv.1 pv
  subtypeDeclaration text tv state arguments sv :=
    base_definitions.subtypeDeclaration text tv state arguments sv.1
  scalarDeclaration text tv state arguments sv :=
    base_definitions.scalarDeclaration text tv state arguments sv.1
  arrayPut := base_definitions.arrayPut
  arrayAdd text tv state first after bounds offset length mutable following componentBounds sv nv bv room extent ordered cursor :=
    base_definitions.arrayAdd text tv state first after bounds offset length mutable following componentBounds
      sv.1 nv bv room extent ordered cursor
  arrayValuesModel text tv source result position length parsed componentBounds bounded valid :=
    base_definitions.arrayValuesModel text tv source result position length parsed componentBounds bounded (base_array_domain valid)
  arrayValues text tv source result position length parsed componentBounds bounded valid :=
    base_definitions.arrayValues text tv source result position length parsed componentBounds bounded (base_array_domain valid)
  arrayDeclaration text tv state arguments sv :=
    base_definitions.arrayDeclaration text tv state arguments sv.1
  declaration text tv state arguments sv :=
    base_definitions.declaration text tv state arguments sv.1
  argument text tv state sv :=
    base_definitions.argument text tv state sv.1
  declarations text tv state arguments sv :=
    base_definitions.declarations text tv state arguments sv.1
  expressionStep := base_definitions.expressionStep
  tail := base_definitions.tail
  fits := base_definitions.fits
  comparison text tv state sv :=
    base_definitions.comparison text tv state sv.1
  expression := base_definitions.expression
  target text tv state sameTarget sv :=
    base_definitions.target text tv state sameTarget sv.1
  dynamic text tv state sv :=
    base_definitions.dynamic text tv state sv.1
  assignmentValue text tv state sv :=
    base_definitions.assignmentValue text tv state sv.1
  output text tv state sv :=
    base_definitions.output text tv state sv.1
  capacity text tv state sv :=
    base_definitions.capacity text tv state sv.1
  readDeclarations text tv state arguments sv :=
    base_definitions.readDeclarations text tv state arguments sv.1

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
    Compose.Expressions.model_legal.newName text tv state first after arguments sv.1 fv av
  addBinding text tv state first after value mutable following sv fv av vv followingValid room :=
    Compose.Expressions.model_legal.addBinding text tv state first after value mutable following sv.1 fv av vv followingValid room
  stringDeclaration text tv state arguments sv :=
    Compose.Expressions.model_legal.stringDeclaration text tv state arguments sv.1
  scalarConstraint := Compose.Expressions.model_legal.scalarConstraint
  subtypeLookupModel := Compose.Expressions.model_legal.subtypeLookupModel
  scalarType text tv state position sv pv :=
    Compose.Expressions.model_legal.scalarType text tv state position sv.1 pv
  subtypeDeclaration text tv state arguments sv :=
    Compose.Expressions.model_legal.subtypeDeclaration text tv state arguments sv.1
  scalarDeclaration text tv state arguments sv :=
    Compose.Expressions.model_legal.scalarDeclaration text tv state arguments sv.1
  declaration text tv state arguments sv :=
    Compose.Expressions.model_legal.declaration text tv state arguments sv.1
  argument text tv state sv :=
    Compose.Expressions.model_legal.argument text tv state sv.1
  declarations text tv state arguments sv :=
    Compose.Expressions.model_legal.declarations text tv state arguments sv.1
  expressionStep := Compose.Expressions.model_legal.expressionStep
  tail := Compose.Expressions.model_legal.tail
  fits := Compose.Expressions.model_legal.fits
  comparison text tv state sv :=
    Compose.Expressions.model_legal.comparison text tv state sv.1
  expression := Compose.Expressions.model_legal.expression
  target text tv state sameTarget sv :=
    Compose.Expressions.model_legal.target text tv state sameTarget sv.1
  dynamic text tv state sv :=
    Compose.Expressions.model_legal.dynamic text tv state sv.1
  assignmentValue text tv state sv :=
    Compose.Expressions.model_legal.assignmentValue text tv state sv.1
  output text tv state sv :=
    Compose.Expressions.model_legal.output text tv state sv.1
  capacity text tv state sv :=
    Compose.Expressions.model_legal.capacity text tv state sv.1
  workTail := Compose.Expressions.model_legal.workTail
  workBudget := Compose.Expressions.model_legal.workBudget

/-- A simultaneous inhabitant of the exact native ready-domain interface.
The final arbitrary-callee endpoint uses this domain directly, and does not
assume equations for native calls outside their preconditions. -/
theorem model_interpreted :
    Compose.SourceBridge.InterpretedSource Compose.Expressions.modelCalls OuterReadiness.domain where
  imageLengths := Compose.SourceBridge.model_interpreted.imageLengths
  lexical := Compose.SourceBridge.model_interpreted.lexical
  definitions := model_definitions
  legal := model_legal
  step text tv form token state native tokenValid sv :=
    Compose.SourceBridge.model_interpreted.step text tv form token state native tokenValid sv.1
  stepLegal text tv form token state native tokenValid sv :=
    Compose.SourceBridge.model_interpreted.stepLegal text tv form token state native tokenValid sv.1

end Silver.Predicate.InheritedReady
