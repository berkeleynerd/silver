module

public import Silver.PathNativeEquations
public import Silver.PathNativePrecedence
public import Silver.PathFactsSpecCertificate
public import Silver.PathFactsSourceShape
public import Silver.SourceDeclarations
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.PathFacts.SourceBridge
open Native Silver.SourceBridge Silver.Lexical.SourceBridge

theorem actual_reviewed_shape : Source.pathFactsSpecTokens = SourceShape.spec := by decide +kernel

theorem body_00 : Source.expressionBody "compare" Source.pathFactsSpecTokens = some compareBody.renderBody := by
  simp only [compareBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_01 : Source.expressionBody "complement" Source.pathFactsSpecTokens = some complementBody.renderBody := by
  simp only [complementBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_02 : Source.expressionBody "swap" Source.pathFactsSpecTokens = some swapBody.renderBody := by
  simp only [swapBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_03 : Source.expressionBody "initial" Source.pathFactsSpecTokens = some initialBody.renderBody := by
  simp only [initialBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_04 : Source.expressionBody "ceiling" Source.pathFactsSpecTokens = some ceilingBody.renderBody := by
  simp only [ceilingBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_05 : Source.expressionBody "assume_valid" Source.pathFactsSpecTokens = some assumeValidBody.renderBody := by
  simp only [assumeValidBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_06 : Source.expressionBody "assume_invalid" Source.pathFactsSpecTokens = some assumeInvalidBody.renderBody := by
  simp only [assumeInvalidBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_07 : Source.expressionBody "rejected" Source.pathFactsSpecTokens = some rejectedBody.renderBody := by
  simp only [rejectedBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_08 : Source.expressionBody "completed" Source.pathFactsSpecTokens = some completedBody.renderBody := by
  simp only [completedBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_09 : Source.expressionBody "keep_if" Source.pathFactsSpecTokens = some keepIfBody.renderBody := by
  simp only [keepIfBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_10 : Source.expressionBody "intersect" Source.pathFactsSpecTokens = some intersectBody.renderBody := by
  simp only [intersectBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_11 : Source.expressionBody "join" Source.pathFactsSpecTokens = some joinBody.renderBody := by
  simp only [joinBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_12 : Source.expressionBody "below" Source.pathFactsSpecTokens = some belowBody.renderBody := by
  simp only [belowBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_13 : Source.expressionBody "above" Source.pathFactsSpecTokens = some aboveBody.renderBody := by
  simp only [aboveBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_14 : Source.expressionBody "refine_input_true" Source.pathFactsSpecTokens = some refineInputTrueBody.renderBody := by
  simp only [refineInputTrueBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_15 : Source.expressionBody "refine_input" Source.pathFactsSpecTokens = some refineInputBody.renderBody := by
  simp only [refineInputBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_16 : Source.expressionBody "refine_bounds" Source.pathFactsSpecTokens = some refineBoundsBody.renderBody := by
  simp only [refineBoundsBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_17 : Source.expressionBody "length_at" Source.pathFactsSpecTokens = some lengthAtBody.renderBody := by
  simp only [lengthAtBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_18 : Source.expressionBody "fits" Source.pathFactsSpecTokens = some fitsBody.renderBody := by
  simp only [fitsBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_19 : Source.expressionBody "same_length" Source.pathFactsSpecTokens = some sameLengthBody.renderBody := by
  simp only [sameLengthBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_20 : Source.expressionBody "equal_increasing" Source.pathFactsSpecTokens = some equalIncreasingBody.renderBody := by
  simp only [equalIncreasingBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem body_21 : Source.expressionBody "refine_equal" Source.pathFactsSpecTokens = some refineEqualBody.renderBody := by
  simp only [refineEqualBody, Expr.renderBody, Expr.render]
  decide +kernel

theorem declaration_max : Source.declaration "max_length" Source.pathFactsSpecTokens =
    some (expectedTokens "constant := 4_096") := by decide +kernel

theorem declaration_length : subtypeDeclaration "length_value" Source.pathFactsSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Length") := by decide +kernel

theorem declaration_operand : subtypeDeclaration "operand_count" Source.pathFactsSpecTokens =
    some (expectedTokens "Natural range 0 .. 64") := by decide +kernel

theorem declaration_expression : subtypeDeclaration "expression_length" Source.pathFactsSpecTokens =
    some (expectedTokens "Natural range 0 .. 65 * Max_Length") := by decide +kernel

theorem declaration_comparison : typeDeclaration "comparison" Source.pathFactsSpecTokens =
    some (expectedTokens "(Equal, Unequal, Less, Less_Equal, Greater, Greater_Equal)") := by decide +kernel

theorem declaration_context : recordDeclaration "context" Source.pathFactsSpecTokens =
    some (expectedTokens "record Lower, Upper : Length_Value; Valid_Reachable, Invalid_Reachable, Invalid_Rejected : Boolean; end record") := by decide +kernel

theorem declaration_bound : recordDeclaration "bound" Source.pathFactsSpecTokens =
    some (expectedTokens "record Static_Length : Length_Value; Dynamic : Boolean; end record") := by decide +kernel

theorem declaration_summary : recordDeclaration "summary" Source.pathFactsSpecTokens =
    some (expectedTokens "record Static_Length : Length_Value; Dynamic_Count : Operand_Count; end record") := by decide +kernel

theorem declaration_empty : Source.declaration "empty_context" Source.pathFactsSpecTokens =
    some (expectedTokens "constant Context := (0, 0, False, False, True)") := by decide +kernel

theorem header_00 : functionHeader "compare" "is" Source.pathFactsSpecTokens =
    some ["(", "operator", ":", "comparison", ";", "left", ",", "right", ":", "expression_length", ")", "return", "boolean"] := by decide +kernel

theorem header_01 : functionHeader "complement" "is" Source.pathFactsSpecTokens =
    some ["(", "operator", ":", "comparison", ")", "return", "comparison"] := by decide +kernel

theorem header_02 : functionHeader "swap" "is" Source.pathFactsSpecTokens =
    some ["(", "operator", ":", "comparison", ")", "return", "comparison"] := by decide +kernel

theorem header_03 : functionHeader "initial" "is" Source.pathFactsSpecTokens =
    some ["(", "arguments", ":", "boolean", ")", "return", "context"] := by decide +kernel

theorem header_04 : functionHeader "ceiling" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ")", "return", "length_value"] := by decide +kernel

theorem header_05 : functionHeader "assume_valid" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ")", "return", "context"] := by decide +kernel

theorem header_06 : functionHeader "assume_invalid" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ")", "return", "context"] := by decide +kernel

theorem header_07 : functionHeader "rejected" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ")", "return", "context"] := by decide +kernel

theorem header_08 : functionHeader "completed" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ")", "return", "boolean"] := by decide +kernel

theorem header_09 : functionHeader "keep_if" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "condition", ":", "boolean", ")", "return", "context"] := by decide +kernel

theorem header_10 : functionHeader "intersect" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "lower", ",", "upper", ":", "natural", ")", "return", "context"] := by decide +kernel

theorem header_11 : functionHeader "join" "is" Source.pathFactsSpecTokens =
    some ["(", "left", ",", "right", ":", "context", ")", "return", "context"] := by decide +kernel

theorem header_12 : functionHeader "below" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "threshold", ":", "length_value", ")", "return", "context"] := by decide +kernel

theorem header_13 : functionHeader "above" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "threshold", ":", "length_value", ")", "return", "context"] := by decide +kernel

theorem header_14 : functionHeader "refine_input_true" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "operator", ":", "comparison", ";", "threshold", ":", "length_value", ")", "return", "context"] := by decide +kernel

theorem header_15 : functionHeader "refine_input" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "operator", ":", "comparison", ";", "threshold", ":", "length_value", ";", "truth", ":", "boolean", ")", "return", "context"] := by decide +kernel

theorem header_16 : functionHeader "refine_bounds" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "operator", ":", "comparison", ";", "left", ",", "right", ":", "bound", ";", "truth", ":", "boolean", ")", "return", "context"] := by decide +kernel

theorem header_17 : functionHeader "length_at" "is" Source.pathFactsSpecTokens =
    some ["(", "value", ":", "summary", ";", "input_length", ":", "length_value", ")", "return", "expression_length"] := by decide +kernel

theorem header_18 : functionHeader "fits" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "value", ":", "summary", ")", "return", "boolean"] := by decide +kernel

theorem header_19 : functionHeader "same_length" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "boolean"] := by decide +kernel

theorem header_20 : functionHeader "equal_increasing" ";" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "context", "with", "pre", "=>", "left", ".", "dynamic_count", ">", "right", ".", "dynamic_count"] := by decide +kernel

theorem header_21 : functionHeader "equal_increasing" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "context"] := by decide +kernel

theorem header_22 : functionHeader "refine_equal" "is" Source.pathFactsSpecTokens =
    some ["(", "facts", ":", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "context"] := by decide +kernel

end Silver.PathFacts.SourceBridge
