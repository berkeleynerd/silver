module

public import Silver.PathFactsSourceChecks

@[expose] public section

namespace Silver.PathFacts.SourceBridge
open Native Predicate Bindings Silver.SourceBridge Silver.Lexical.SourceBridge

/-- Exact authoritative bytes, all function bodies, declared ranges/records and
all headers, including the nonzero-divisor precondition. -/
structure ActualSource : Prop where
  source : Source.lex Source.pathFactsSpec = some Source.pathFactsSpecTokens
  actual_reviewed_shape : Source.pathFactsSpecTokens = SourceShape.spec
  body_00 : Source.expressionBody "compare" Source.pathFactsSpecTokens = some compareBody.renderBody
  body_01 : Source.expressionBody "complement" Source.pathFactsSpecTokens = some complementBody.renderBody
  body_02 : Source.expressionBody "swap" Source.pathFactsSpecTokens = some swapBody.renderBody
  body_03 : Source.expressionBody "initial" Source.pathFactsSpecTokens = some initialBody.renderBody
  body_04 : Source.expressionBody "ceiling" Source.pathFactsSpecTokens = some ceilingBody.renderBody
  body_05 : Source.expressionBody "assume_valid" Source.pathFactsSpecTokens = some assumeValidBody.renderBody
  body_06 : Source.expressionBody "assume_invalid" Source.pathFactsSpecTokens = some assumeInvalidBody.renderBody
  body_07 : Source.expressionBody "rejected" Source.pathFactsSpecTokens = some rejectedBody.renderBody
  body_08 : Source.expressionBody "completed" Source.pathFactsSpecTokens = some completedBody.renderBody
  body_09 : Source.expressionBody "keep_if" Source.pathFactsSpecTokens = some keepIfBody.renderBody
  body_10 : Source.expressionBody "intersect" Source.pathFactsSpecTokens = some intersectBody.renderBody
  body_11 : Source.expressionBody "join" Source.pathFactsSpecTokens = some joinBody.renderBody
  body_12 : Source.expressionBody "below" Source.pathFactsSpecTokens = some belowBody.renderBody
  body_13 : Source.expressionBody "above" Source.pathFactsSpecTokens = some aboveBody.renderBody
  body_14 : Source.expressionBody "refine_input_true" Source.pathFactsSpecTokens = some refineInputTrueBody.renderBody
  body_15 : Source.expressionBody "refine_input" Source.pathFactsSpecTokens = some refineInputBody.renderBody
  body_16 : Source.expressionBody "refine_bounds" Source.pathFactsSpecTokens = some refineBoundsBody.renderBody
  body_17 : Source.expressionBody "length_at" Source.pathFactsSpecTokens = some lengthAtBody.renderBody
  body_18 : Source.expressionBody "fits" Source.pathFactsSpecTokens = some fitsBody.renderBody
  body_19 : Source.expressionBody "same_length" Source.pathFactsSpecTokens = some sameLengthBody.renderBody
  body_20 : Source.expressionBody "equal_increasing" Source.pathFactsSpecTokens = some equalIncreasingBody.renderBody
  body_21 : Source.expressionBody "refine_equal" Source.pathFactsSpecTokens = some refineEqualBody.renderBody
  declaration_max : Source.declaration "max_length" Source.pathFactsSpecTokens =
        some (expectedTokens "constant := 4_096")
  declaration_length : subtypeDeclaration "length_value" Source.pathFactsSpecTokens =
        some (expectedTokens "Natural range 0 .. Max_Length")
  declaration_operand : subtypeDeclaration "operand_count" Source.pathFactsSpecTokens =
        some (expectedTokens "Natural range 0 .. 16")
  declaration_expression : subtypeDeclaration "expression_length" Source.pathFactsSpecTokens =
        some (expectedTokens "Natural range 0 .. 17 * Max_Length")
  declaration_comparison : typeDeclaration "comparison" Source.pathFactsSpecTokens =
        some (expectedTokens "(Equal, Unequal, Less, Less_Equal, Greater, Greater_Equal)")
  declaration_context : recordDeclaration "context" Source.pathFactsSpecTokens =
        some (expectedTokens "record Lower, Upper : Length_Value; Valid_Reachable, Invalid_Reachable, Invalid_Rejected : Boolean; end record")
  declaration_bound : recordDeclaration "bound" Source.pathFactsSpecTokens =
        some (expectedTokens "record Static_Length : Length_Value; Dynamic : Boolean; end record")
  declaration_summary : recordDeclaration "summary" Source.pathFactsSpecTokens =
        some (expectedTokens "record Static_Length : Length_Value; Dynamic_Count : Operand_Count; end record")
  declaration_empty : Source.declaration "empty_context" Source.pathFactsSpecTokens =
        some (expectedTokens "constant Context := (0, 0, False, False, True)")
  header_00 : functionHeader "compare" "is" Source.pathFactsSpecTokens =
        some ["(", "operator", ":", "comparison", ";", "left", ",", "right", ":", "expression_length", ")", "return", "boolean"]
  header_01 : functionHeader "complement" "is" Source.pathFactsSpecTokens =
        some ["(", "operator", ":", "comparison", ")", "return", "comparison"]
  header_02 : functionHeader "swap" "is" Source.pathFactsSpecTokens =
        some ["(", "operator", ":", "comparison", ")", "return", "comparison"]
  header_03 : functionHeader "initial" "is" Source.pathFactsSpecTokens =
        some ["(", "arguments", ":", "boolean", ")", "return", "context"]
  header_04 : functionHeader "ceiling" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ")", "return", "length_value"]
  header_05 : functionHeader "assume_valid" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ")", "return", "context"]
  header_06 : functionHeader "assume_invalid" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ")", "return", "context"]
  header_07 : functionHeader "rejected" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ")", "return", "context"]
  header_08 : functionHeader "completed" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ")", "return", "boolean"]
  header_09 : functionHeader "keep_if" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "condition", ":", "boolean", ")", "return", "context"]
  header_10 : functionHeader "intersect" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "lower", ",", "upper", ":", "natural", ")", "return", "context"]
  header_11 : functionHeader "join" "is" Source.pathFactsSpecTokens =
        some ["(", "left", ",", "right", ":", "context", ")", "return", "context"]
  header_12 : functionHeader "below" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "threshold", ":", "length_value", ")", "return", "context"]
  header_13 : functionHeader "above" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "threshold", ":", "length_value", ")", "return", "context"]
  header_14 : functionHeader "refine_input_true" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "operator", ":", "comparison", ";", "threshold", ":", "length_value", ")", "return", "context"]
  header_15 : functionHeader "refine_input" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "operator", ":", "comparison", ";", "threshold", ":", "length_value", ";", "truth", ":", "boolean", ")", "return", "context"]
  header_16 : functionHeader "refine_bounds" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "operator", ":", "comparison", ";", "left", ",", "right", ":", "bound", ";", "truth", ":", "boolean", ")", "return", "context"]
  header_17 : functionHeader "length_at" "is" Source.pathFactsSpecTokens =
        some ["(", "value", ":", "summary", ";", "input_length", ":", "length_value", ")", "return", "expression_length"]
  header_18 : functionHeader "fits" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "value", ":", "summary", ")", "return", "boolean"]
  header_19 : functionHeader "same_length" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "boolean"]
  header_20 : functionHeader "equal_increasing" ";" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "context", "with", "pre", "=>", "left", ".", "dynamic_count", ">", "right", ".", "dynamic_count"]
  header_21 : functionHeader "equal_increasing" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "context"]
  header_22 : functionHeader "refine_equal" "is" Source.pathFactsSpecTokens =
        some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "context"]

theorem actual_source : ActualSource where
  source := Source.pathFactsSpecTokens_correct
  actual_reviewed_shape := actual_reviewed_shape
  body_00 := body_00
  body_01 := body_01
  body_02 := body_02
  body_03 := body_03
  body_04 := body_04
  body_05 := body_05
  body_06 := body_06
  body_07 := body_07
  body_08 := body_08
  body_09 := body_09
  body_10 := body_10
  body_11 := body_11
  body_12 := body_12
  body_13 := body_13
  body_14 := body_14
  body_15 := body_15
  body_16 := body_16
  body_17 := body_17
  body_18 := body_18
  body_19 := body_19
  body_20 := body_20
  body_21 := body_21
  declaration_max := declaration_max
  declaration_length := declaration_length
  declaration_operand := declaration_operand
  declaration_expression := declaration_expression
  declaration_comparison := declaration_comparison
  declaration_context := declaration_context
  declaration_bound := declaration_bound
  declaration_summary := declaration_summary
  declaration_empty := declaration_empty
  header_00 := header_00
  header_01 := header_01
  header_02 := header_02
  header_03 := header_03
  header_04 := header_04
  header_05 := header_05
  header_06 := header_06
  header_07 := header_07
  header_08 := header_08
  header_09 := header_09
  header_10 := header_10
  header_11 := header_11
  header_12 := header_12
  header_13 := header_13
  header_14 := header_14
  header_15 := header_15
  header_16 := header_16
  header_17 := header_17
  header_18 := header_18
  header_19 := header_19
  header_20 := header_20
  header_21 := header_21
  header_22 := header_22

/-- Every checked typed body evaluates to its named scalar operation. -/
structure BodyInterpretation : Prop where
  compareBody_eval : ∀ locals : Locals, compareBody.eval locals = (locals .comparison "operator").evaluate (locals .number "left") (locals .number "right")
  complementBody_eval : ∀ locals : Locals, complementBody.eval locals = (locals .comparison "operator").complement
  swapBody_eval : ∀ locals : Locals, swapBody.eval locals = (locals .comparison "operator").swap
  initialBody_eval : ∀ locals : Locals, initialBody.eval locals = initial (locals .truth "arguments")
  ceilingBody_eval : ∀ locals : Locals, ceilingBody.eval locals = ceiling (locals .context "facts")
  assumeValidBody_eval : ∀ locals : Locals, assumeValidBody.eval locals = assumeValid (locals .context "facts")
  assumeInvalidBody_eval : ∀ locals : Locals, assumeInvalidBody.eval locals = assumeInvalid (locals .context "facts")
  rejectedBody_eval : ∀ locals : Locals, rejectedBody.eval locals = rejected (locals .context "facts")
  completedBody_eval : ∀ locals : Locals, completedBody.eval locals = completed (locals .context "facts")
  keepIfBody_eval : ∀ locals : Locals, keepIfBody.eval locals = keepIf (locals .context "facts") (locals .truth "condition")
  intersectBody_eval : ∀ locals : Locals, intersectBody.eval locals = intersect (locals .context "facts") (locals .number "lower") (locals .number "upper")
  joinBody_eval : ∀ locals : Locals, joinBody.eval locals = join (locals .context "left") (locals .context "right")
  belowBody_eval : ∀ locals : Locals, belowBody.eval locals = below (locals .context "facts") (locals .number "threshold")
  aboveBody_eval : ∀ locals : Locals, aboveBody.eval locals = above (locals .context "facts") (locals .number "threshold")
  refineInputTrueBody_eval : ∀ locals : Locals, refineInputTrueBody.eval locals = refineInputTrue (locals .context "facts") (locals .comparison "operator") (locals .number "threshold")
  refineInputBody_eval : ∀ locals : Locals, refineInputBody.eval locals = refineInput (locals .context "facts") (locals .comparison "operator") (locals .number "threshold") (locals .truth "truth")
  refineBoundsBody_eval : ∀ locals : Locals, refineBoundsBody.eval locals = refineBounds (locals .context "facts") (locals .comparison "operator") (locals .bound "left") (locals .bound "right") (locals .truth "truth")
  lengthAtBody_eval : ∀ locals : Locals, lengthAtBody.eval locals = lengthAt (locals .summary "value") (locals .number "input_length")
  fitsBody_eval : ∀ locals : Locals, fitsBody.eval locals = fits (locals .context "facts") (locals .summary "value")
  sameLengthBody_eval : ∀ locals : Locals, sameLengthBody.eval locals = sameLength (locals .context "facts") (locals .summary "left") (locals .summary "right")
  equalIncreasingBody_eval : ∀ locals : Locals, equalIncreasingBody.eval locals = equalIncreasing (locals .context "facts") (locals .summary "left") (locals .summary "right")
  refineEqualBody_eval : ∀ locals : Locals, refineEqualBody.eval locals = refineEqual (locals .context "facts") (locals .summary "left") (locals .summary "right")

theorem actual_body_interpretation : BodyInterpretation where
  compareBody_eval := Native.compareBody_eval
  complementBody_eval := Native.complementBody_eval
  swapBody_eval := Native.swapBody_eval
  initialBody_eval := Native.initialBody_eval
  ceilingBody_eval := Native.ceilingBody_eval
  assumeValidBody_eval := Native.assumeValidBody_eval
  assumeInvalidBody_eval := Native.assumeInvalidBody_eval
  rejectedBody_eval := Native.rejectedBody_eval
  completedBody_eval := Native.completedBody_eval
  keepIfBody_eval := Native.keepIfBody_eval
  intersectBody_eval := Native.intersectBody_eval
  joinBody_eval := Native.joinBody_eval
  belowBody_eval := Native.belowBody_eval
  aboveBody_eval := Native.aboveBody_eval
  refineInputTrueBody_eval := Native.refineInputTrueBody_eval
  refineInputBody_eval := Native.refineInputBody_eval
  refineBoundsBody_eval := Native.refineBoundsBody_eval
  lengthAtBody_eval := Native.lengthAtBody_eval
  fitsBody_eval := Native.fitsBody_eval
  sameLengthBody_eval := Native.sameLengthBody_eval
  equalIncreasingBody_eval := Native.equalIncreasingBody_eval
  refineEqualBody_eval := Native.refineEqualBody_eval

/-- The native representation commutes with the universally proved path rules.
Inactive fields are erased by projection; no reachability assumption is added. -/
structure ModelProjection : Prop where
  initial : ∀ arguments, (Native.initial arguments).model =
    if arguments then PathFacts.Context.initial maxSourceLength else (PathFacts.Context.initial 0).assumeValid
  empty : Native.empty.model = PathFacts.Context.empty
  ceiling : ∀ facts, Native.ceiling facts = Predicate.ceiling facts.model
  valid : ∀ facts, (Native.assumeValid facts).model = facts.model.assumeValid
  invalid : ∀ facts, (Native.assumeInvalid facts).model = facts.model.assumeInvalid
  rejected : ∀ facts, (Native.rejected facts).model = facts.model.reject
  completed : ∀ facts, Native.completed facts = (!facts.model.invalidReachable || facts.model.invalidRejected)
  keep : ∀ facts condition, (Native.keepIf facts condition).model = Predicate.keepIf facts.model condition
  intersect : ∀ facts lower upper, (Native.intersect facts lower upper).model = facts.model.intersect ⟨lower, upper⟩
  join : ∀ left right, (Native.join left right).model = left.model.join right.model
  below : ∀ facts threshold, (Native.below facts threshold).model = Predicate.below facts.model threshold
  above : ∀ facts threshold, (Native.above facts threshold).model = Predicate.above facts.model threshold
  refineInputTrue : ∀ facts operator threshold,
    (Native.refineInputTrue facts operator threshold).model = Predicate.refineInputTrue facts.model operator threshold
  refineInput : ∀ facts operator threshold truth,
    (Native.refineInput facts operator threshold truth).model = Predicate.refineInput facts.model operator threshold truth
  refineBounds : ∀ facts operator left right truth,
    (Native.refineBounds facts operator left right truth).model =
      Predicate.refineBounds facts.model operator left.model right.model truth
  lengthAt : ∀ value inputLength, Native.lengthAt value inputLength = value.length inputLength
  fits : ∀ facts value, Native.fits facts value = Predicate.fitsSummary facts.model value
  equalIncreasing : ∀ facts left right,
    (Native.equalIncreasing facts left right).model = Predicate.equalIncreasing facts.model left right
  refineEqual : ∀ facts left right,
    (Native.refineEqual facts left right).model = Predicate.refineAffineEqual facts.model left right
  sameLength : ∀ {facts : Native.Context} {left right : Native.Summary} {valid rejected : Bool} {length : Nat},
    facts.model.Allows valid length rejected → Native.sameLength facts left right = true →
      left.length length = right.length length

theorem actual_model_projection : ModelProjection where
  initial := Native.initial_model
  empty := Native.empty_model
  ceiling := Native.ceiling_model
  valid := Native.assumeValid_model
  invalid := Native.assumeInvalid_model
  rejected := Native.rejected_model
  completed := Native.completed_model
  keep := Native.keepIf_model
  intersect := Native.intersect_model
  join := Native.join_model
  below := Native.below_model
  above := Native.above_model
  refineInputTrue := Native.refineInputTrue_model
  refineInput := Native.refineInput_model
  refineBounds := Native.refineBounds_model
  lengthAt := Native.lengthAt_model
  fits := Native.fits_model
  equalIncreasing := Native.equalIncreasing_model
  refineEqual := Native.refineEqual_model
  sameLength := Native.sameLength_sound

/-- Complete source correspondence for the nonrecursive path-fact library.
Native scalar arithmetic safety is additionally discharged by GNATprove under
the checked declared subtypes and Equal_Increasing precondition. -/
theorem actual_path_library : ActualSource ∧ BodyInterpretation ∧ ModelProjection :=
  ⟨actual_source, actual_body_interpretation, actual_model_projection⟩

end Silver.PathFacts.SourceBridge
