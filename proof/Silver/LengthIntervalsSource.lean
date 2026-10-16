module

public import Silver.LengthIntervalPrecedence
public import Silver.LengthIntervalsCapture
public import Silver.PathFactsSourceBridge
public import Silver.SourceDeclarations
import all Init.Data.Repr

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.LengthIntervals.SourceBridge
open Native Silver.SourceBridge Silver.Lexical.SourceBridge

def valueHeader (result : List String) : List String :=
  ["(", "value", ":", "summary", ")", "return"] ++ result

def fitsHeader : List String :=
  ["(", "facts", ":", "paths", ".", "context", ";", "value", ":", "summary", ")", "return", "boolean"]

def binaryHeader (result : List String) : List String :=
  ["(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return"] ++ result

def reviewedSpec : List String :=
  ["with", "silver_path_facts", ";", "package", "silver_length_intervals", "with", "spark_mode", "=>", "on", "is",
   "package", "paths", "renames", "silver_path_facts", ";",
   "type", "summary", "is", "record",
   "minimum_length", ",", "static_length", ":", "paths", ".", "length_value", ";",
   "dynamic_count", ":", "paths", ".", "operand_count", ";",
   "empty_value", ":", "boolean", ":=", "false", ";", "end", "record", ";",
   "empty_summary", ":", "constant", "summary", ":=", "(", "0", ",", "0", ",", "0", ",", "true", ")", ";",
   "function", "is_empty"] ++ valueHeader ["boolean"] ++ ["is", "("] ++ isEmptyBody.render ++ [")", ";",
   "function", "lower"] ++ valueHeader ["paths", ".", "summary"] ++ ["is", "("] ++ lowerBody.render ++ [")", ";",
   "function", "upper"] ++ valueHeader ["paths", ".", "summary"] ++ ["is", "("] ++ upperBody.render ++ [")", ";",
   "function", "fits"] ++ fitsHeader ++ ["with", "global", "=>", "null", ";",
   "function", "same_length"] ++ binaryHeader ["boolean"] ++ ["with", "global", "=>", "null", ";",
   "function", "refine_equal"] ++ binaryHeader ["paths", ".", "context"] ++ ["with", "global", "=>", "null", ";",
   "end", "silver_length_intervals", ";"]

def reviewedBody : List String :=
  ["package", "body", "silver_length_intervals", "with", "spark_mode", "=>", "on", "is",
   "function", "fits"] ++ fitsHeader ++ ["is", "("] ++ fitsBody.render ++ [")", ";",
   "function", "same_length"] ++ binaryHeader ["boolean"] ++ ["is", "("] ++ sameLengthBody.render ++ [")", ";",
   "function", "equal_increasing"] ++ binaryHeader ["paths", ".", "context"] ++
     ["with", "global", "=>", "null", ",", "pre", "=>", "left", ".", "dynamic_count", ">", "right", ".", "dynamic_count", ";",
   "function", "equal_increasing"] ++ binaryHeader ["paths", ".", "context"] ++ ["is", "("] ++ increasingBody.render ++ [")", ";",
   "function", "refine_equal"] ++ binaryHeader ["paths", ".", "context"] ++ ["is", "("] ++ refineEqualBody.render ++ [")", ";",
   "end", "silver_length_intervals", ";"]

theorem spec_checked : Source.lex Source.lengthIntervalsSpec = some reviewedSpec := by
  rw [Source.lengthIntervalsSpecTokens_correct]
  simp only [reviewedSpec, valueHeader, fitsHeader, binaryHeader, isEmptyBody, lowerBody, upperBody,
    Expr.render, Field.name]
  decide +kernel

theorem body_checked : Source.lex Source.lengthIntervalsBody = some reviewedBody := by
  rw [Source.lengthIntervalsBodyTokens_correct]
  simp only [reviewedBody, fitsHeader, binaryHeader, fitsBody, sameLengthBody, increasingBody, refineEqualBody,
    Expr.render, Field.name, call]
  decide +kernel

abbrev Bodies : Prop :=
  Source.expressionBody "is_empty" reviewedSpec = some isEmptyBody.render ∧
  qualifiedExpressionBody "lower" reviewedSpec = some lowerBody.render ∧
  qualifiedExpressionBody "upper" reviewedSpec = some upperBody.render ∧
  Source.expressionBody "fits" reviewedBody = some fitsBody.render ∧
  Source.expressionBody "same_length" reviewedBody = some sameLengthBody.render ∧
  qualifiedExpressionBody "equal_increasing" reviewedBody = some increasingBody.render ∧
  qualifiedExpressionBody "refine_equal" reviewedBody = some refineEqualBody.render

theorem bodies_checked : Bodies := by decide +kernel

structure ActualSource : Prop where
  spec : Source.lex Source.lengthIntervalsSpec = some reviewedSpec
  body : Source.lex Source.lengthIntervalsBody = some reviewedBody
  bodies : Bodies
  precedence : WellFormedTrees
  scope : ScopedTrees
  paths : PathFacts.SourceBridge.ActualSource

 theorem actual_source : ActualSource :=
  ⟨spec_checked, body_checked, bodies_checked, checked_precedence, checked_scope,
    PathFacts.SourceBridge.actual_source⟩

/-- The checked native interval records are interpreted at the exact declared
field types. GNATprove separately discharges machine arithmetic, including the
positive Difference precondition and construction of intermediate Naturals. -/
structure BodyInterpretation : Prop where
  empty : ∀ value, isEmptyBody.eval ({value} : Inputs).locals = value.empty
  lower : ∀ value, lowerBody.eval ({value} : Inputs).locals = value.lower
  upper : ∀ value, upperBody.eval ({value} : Inputs).locals = value.upper
  fits : ∀ facts value, fitsBody.eval ({facts, value} : Inputs).locals = Predicate.fitsLengthSummary facts.model value
  same : ∀ facts left right, sameLengthBody.eval ({facts, left, right} : Inputs).locals =
    Predicate.equalLengthIntervals facts.model left right
  increasing : ∀ facts left right, (increasingBody.eval ({facts, left, right} : Inputs).locals).model =
    Predicate.increasingLengthOverlap facts.model left right
  refine : ∀ facts left right, (refineEqualBody.eval ({facts, left, right} : Inputs).locals).model =
    Predicate.refineLengthOverlap facts.model left right

theorem body_interpretation : BodyInterpretation where
  empty := isEmptyBody_eval
  lower := lowerBody_eval
  upper := upperBody_eval
  fits facts value := by rw [fitsBody_eval, fits_model]
  same facts left right := by rw [sameLengthBody_eval, sameLength_model]
  increasing facts left right := by rw [increasingBody_eval, equalIncreasing_model]
  refine facts left right := by rw [refineEqualBody_eval, refineEqual_model]

theorem actual_interval_library : ActualSource ∧ BodyInterpretation ∧ PathFacts.SourceBridge.BodyInterpretation :=
  ⟨actual_source, body_interpretation, PathFacts.SourceBridge.actual_body_interpretation⟩

end Silver.LengthIntervals.SourceBridge
