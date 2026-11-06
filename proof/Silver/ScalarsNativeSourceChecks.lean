module

public import Silver.ScalarsNativeEquations
public import Silver.ScalarsSpecCertificate
public import Silver.SourceDeclarations
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Integer.NativeSourceChecks
open Silver.SourceBridge Silver.Lexical.SourceBridge

def reviewedSpec : List String := ["package", "silver_scalars", "with", "spark_mode", "=>", "on", "is", "subtype", "value", "is", "integer", "range", "-", "2_147_483_648", "..", "2_147_483_647", ";", "subtype", "wide", "is", "long_long_integer", ";", "minimum", ":", "constant", "wide", ":=", "-", "2_147_483_648", ";", "maximum", ":", "constant", "wide", ":=", "2_147_483_647", ";", "type", "interval", "is", "record", "lower", ",", "upper", ":", "value", ";", "end", "record", ";", "empty", ":", "constant", "interval", ":=", "(", "1", ",", "0", ")", ";", "full", ":", "constant", "interval", ":=", "(", "value", "'", "first", ",", "value", "'", "last", ")", ";", "function", "is_empty", "(", "bounds", ":", "interval", ")", "return", "boolean", "is", "(", "bounds", ".", "lower", ">", "bounds", ".", "upper", ")", ";", "function", "contains", "(", "bounds", ":", "interval", ";", "item", ":", "value", ")", "return", "boolean", "is", "(", "item", ">=", "bounds", ".", "lower", "and", "then", "item", "<=", "bounds", ".", "upper", ")", ";", "function", "singleton", "(", "item", ":", "value", ")", "return", "interval", "is", "(", "(", "item", ",", "item", ")", ")", ";", "function", "normalize", "(", "bounds", ":", "interval", ")", "return", "interval", "is", "(", "if", "is_empty", "(", "bounds", ")", "then", "empty", "else", "bounds", ")", ";", "function", "join", "(", "left", ",", "right", ":", "interval", ")", "return", "interval", "is", "(", "if", "is_empty", "(", "left", ")", "then", "normalize", "(", "right", ")", "elsif", "is_empty", "(", "right", ")", "then", "left", "else", "(", "value", "'", "min", "(", "left", ".", "lower", ",", "right", ".", "lower", ")", ",", "value", "'", "max", "(", "left", ".", "upper", ",", "right", ".", "upper", ")", ")", ")", ";", "function", "intersect", "(", "left", ",", "right", ":", "interval", ")", "return", "interval", "is", "(", "normalize", "(", "(", "value", "'", "max", "(", "left", ".", "lower", ",", "right", ".", "lower", ")", ",", "value", "'", "min", "(", "left", ".", "upper", ",", "right", ".", "upper", ")", ")", ")", ")", ";", "type", "comparison", "is", "(", "equal", ",", "unequal", ",", "less", ",", "less_equal", ",", "greater", ",", "greater_equal", ")", ";", "function", "compare", "(", "operator", ":", "comparison", ";", "left", ",", "right", ":", "value", ")", "return", "boolean", "is", "(", "case", "operator", "is", "when", "equal", "=>", "left", "=", "right", ",", "when", "unequal", "=>", "left", "/=", "right", ",", "when", "less", "=>", "left", "<", "right", ",", "when", "less_equal", "=>", "left", "<=", "right", ",", "when", "greater", "=>", "left", ">", "right", ",", "when", "greater_equal", "=>", "left", ">=", "right", ")", ";", "function", "complement", "(", "operator", ":", "comparison", ")", "return", "comparison", "is", "(", "case", "operator", "is", "when", "equal", "=>", "unequal", ",", "when", "unequal", "=>", "equal", ",", "when", "less", "=>", "greater_equal", ",", "when", "less_equal", "=>", "greater", ",", "when", "greater", "=>", "less_equal", ",", "when", "greater_equal", "=>", "less", ")", ";", "function", "swap", "(", "operator", ":", "comparison", ")", "return", "comparison", "is", "(", "case", "operator", "is", "when", "equal", "=>", "equal", ",", "when", "unequal", "=>", "unequal", ",", "when", "less", "=>", "greater", ",", "when", "less_equal", "=>", "greater_equal", ",", "when", "greater", "=>", "less", ",", "when", "greater_equal", "=>", "less_equal", ")", ";", "function", "below", "(", "bounds", ":", "interval", ";", "threshold", ":", "value", ")", "return", "interval", "is", "(", "if", "threshold", "=", "value", "'", "first", "then", "empty", "else", "intersect", "(", "bounds", ",", "(", "value", "'", "first", ",", "threshold", "-", "1", ")", ")", ")", ";", "function", "above", "(", "bounds", ":", "interval", ";", "threshold", ":", "value", ")", "return", "interval", "is", "(", "if", "threshold", "=", "value", "'", "last", "then", "empty", "else", "intersect", "(", "bounds", ",", "(", "threshold", "+", "1", ",", "value", "'", "last", ")", ")", ")", ";", "function", "refine_true", "(", "bounds", ":", "interval", ";", "operator", ":", "comparison", ";", "threshold", ":", "value", ")", "return", "interval", "is", "(", "case", "operator", "is", "when", "equal", "=>", "intersect", "(", "bounds", ",", "singleton", "(", "threshold", ")", ")", ",", "when", "unequal", "=>", "join", "(", "below", "(", "bounds", ",", "threshold", ")", ",", "above", "(", "bounds", ",", "threshold", ")", ")", ",", "when", "less", "=>", "below", "(", "bounds", ",", "threshold", ")", ",", "when", "less_equal", "=>", "intersect", "(", "bounds", ",", "(", "value", "'", "first", ",", "threshold", ")", ")", ",", "when", "greater", "=>", "above", "(", "bounds", ",", "threshold", ")", ",", "when", "greater_equal", "=>", "intersect", "(", "bounds", ",", "(", "threshold", ",", "value", "'", "last", ")", ")", ")", ";", "function", "refine", "(", "bounds", ":", "interval", ";", "operator", ":", "comparison", ";", "threshold", ":", "value", ";", "truth", ":", "boolean", ")", "return", "interval", "is", "(", "refine_true", "(", "bounds", ",", "(", "if", "truth", "then", "operator", "else", "complement", "(", "operator", ")", ")", ",", "threshold", ")", ")", ";", "type", "check_result", "is", "record", "safe", ":", "boolean", ";", "bounds", ":", "interval", ";", "end", "record", ";", "invalid", ":", "constant", "check_result", ":=", "(", "false", ",", "empty", ")", ";", "unreachable", ":", "constant", "check_result", ":=", "(", "true", ",", "empty", ")", ";", "function", "in_range", "(", "item", ":", "wide", ")", "return", "boolean", "is", "(", "item", ">=", "minimum", "and", "then", "item", "<=", "maximum", ")", ";", "function", "checked", "(", "lower", ",", "upper", ":", "wide", ")", "return", "check_result", "is", "(", "if", "lower", ">", "upper", "then", "unreachable", "elsif", "in_range", "(", "lower", ")", "and", "then", "in_range", "(", "upper", ")", "then", "(", "true", ",", "(", "value", "(", "lower", ")", ",", "value", "(", "upper", ")", ")", ")", "else", "invalid", ")", ";", "function", "add", "(", "left", ",", "right", ":", "interval", ")", "return", "check_result", "is", "(", "if", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "unreachable", "else", "checked", "(", "wide", "(", "left", ".", "lower", ")", "+", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "upper", ")", "+", "wide", "(", "right", ".", "upper", ")", ")", ")", ";", "function", "subtract", "(", "left", ",", "right", ":", "interval", ")", "return", "check_result", "is", "(", "if", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "unreachable", "else", "checked", "(", "wide", "(", "left", ".", "lower", ")", "-", "wide", "(", "right", ".", "upper", ")", ",", "wide", "(", "left", ".", "upper", ")", "-", "wide", "(", "right", ".", "lower", ")", ")", ")", ";", "function", "negate", "(", "operand", ":", "interval", ")", "return", "check_result", "is", "(", "if", "is_empty", "(", "operand", ")", "then", "unreachable", "else", "checked", "(", "-", "wide", "(", "operand", ".", "upper", ")", ",", "-", "wide", "(", "operand", ".", "lower", ")", ")", ")", ";", "function", "product_minimum", "(", "left", ",", "right", ":", "interval", ")", "return", "wide", "is", "(", "wide", "'", "min", "(", "wide", "'", "min", "(", "wide", "(", "left", ".", "lower", ")", "*", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "lower", ")", "*", "wide", "(", "right", ".", "upper", ")", ")", ",", "wide", "'", "min", "(", "wide", "(", "left", ".", "upper", ")", "*", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "upper", ")", "*", "wide", "(", "right", ".", "upper", ")", ")", ")", ")", ";", "function", "product_maximum", "(", "left", ",", "right", ":", "interval", ")", "return", "wide", "is", "(", "wide", "'", "max", "(", "wide", "'", "max", "(", "wide", "(", "left", ".", "lower", ")", "*", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "lower", ")", "*", "wide", "(", "right", ".", "upper", ")", ")", ",", "wide", "'", "max", "(", "wide", "(", "left", ".", "upper", ")", "*", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "upper", ")", "*", "wide", "(", "right", ".", "upper", ")", ")", ")", ")", ";", "function", "multiply", "(", "left", ",", "right", ":", "interval", ")", "return", "check_result", "is", "(", "if", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "(", "if", "contains", "(", "left", ",", "0", ")", "or", "else", "contains", "(", "right", ",", "0", ")", "then", "invalid", "else", "unreachable", ")", "else", "checked", "(", "product_minimum", "(", "left", ",", "right", ")", ",", "product_maximum", "(", "left", ",", "right", ")", ")", ")", ";", "function", "quotient_minimum", "(", "left", ",", "right", ":", "interval", ")", "return", "wide", "is", "(", "if", "right", ".", "lower", "=", "0", "or", "else", "right", ".", "upper", "=", "0", "then", "0", "else", "wide", "'", "min", "(", "wide", "'", "min", "(", "wide", "(", "left", ".", "lower", ")", "/", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "lower", ")", "/", "wide", "(", "right", ".", "upper", ")", ")", ",", "wide", "'", "min", "(", "wide", "(", "left", ".", "upper", ")", "/", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "upper", ")", "/", "wide", "(", "right", ".", "upper", ")", ")", ")", ")", ";", "function", "quotient_maximum", "(", "left", ",", "right", ":", "interval", ")", "return", "wide", "is", "(", "if", "right", ".", "lower", "=", "0", "or", "else", "right", ".", "upper", "=", "0", "then", "0", "else", "wide", "'", "max", "(", "wide", "'", "max", "(", "wide", "(", "left", ".", "lower", ")", "/", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "lower", ")", "/", "wide", "(", "right", ".", "upper", ")", ")", ",", "wide", "'", "max", "(", "wide", "(", "left", ".", "upper", ")", "/", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "upper", ")", "/", "wide", "(", "right", ".", "upper", ")", ")", ")", ")", ";", "function", "divide", "(", "left", ",", "right", ":", "interval", ")", "return", "check_result", "is", "(", "if", "contains", "(", "right", ",", "0", ")", "then", "invalid", "elsif", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "unreachable", "else", "checked", "(", "quotient_minimum", "(", "left", ",", "right", ")", ",", "quotient_maximum", "(", "left", ",", "right", ")", ")", ")", ";", "function", "modulo", "(", "left", ",", "right", ":", "interval", ")", "return", "check_result", "is", "(", "if", "contains", "(", "right", ",", "0", ")", "then", "invalid", "elsif", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "(", "if", "contains", "(", "right", ",", "1", ")", "or", "else", "contains", "(", "right", ",", "-", "1", ")", "then", "invalid", "else", "unreachable", ")", "elsif", "left", ".", "lower", "=", "left", ".", "upper", "and", "then", "right", ".", "lower", "=", "right", ".", "upper", "then", "checked", "(", "wide", "(", "left", ".", "lower", ")", "mod", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "lower", ")", "mod", "wide", "(", "right", ".", "lower", ")", ")", "elsif", "right", ".", "lower", ">", "0", "then", "checked", "(", "0", ",", "wide", "(", "right", ".", "upper", ")", "-", "1", ")", "else", "checked", "(", "wide", "(", "right", ".", "lower", ")", "+", "1", ",", "0", ")", ")", ";", "function", "remainder_limit", "(", "right", ":", "interval", ")", "return", "wide", "is", "(", "wide", "'", "max", "(", "abs", "wide", "(", "right", ".", "lower", ")", ",", "abs", "wide", "(", "right", ".", "upper", ")", ")", "-", "1", ")", ";", "function", "remainder", "(", "left", ",", "right", ":", "interval", ")", "return", "check_result", "is", "(", "if", "contains", "(", "right", ",", "0", ")", "then", "invalid", "elsif", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "(", "if", "contains", "(", "right", ",", "1", ")", "or", "else", "contains", "(", "right", ",", "-", "1", ")", "then", "invalid", "else", "unreachable", ")", "elsif", "left", ".", "lower", "=", "left", ".", "upper", "and", "then", "right", ".", "lower", "=", "right", ".", "upper", "then", "checked", "(", "wide", "(", "left", ".", "lower", ")", "rem", "wide", "(", "right", ".", "lower", ")", ",", "wide", "(", "left", ".", "lower", ")", "rem", "wide", "(", "right", ".", "lower", ")", ")", "else", "checked", "(", "(", "if", "left", ".", "lower", "<", "0", "then", "wide", "'", "max", "(", "wide", "(", "left", ".", "lower", ")", ",", "-", "remainder_limit", "(", "right", ")", ")", "else", "0", ")", ",", "(", "if", "left", ".", "upper", ">", "0", "then", "wide", "'", "min", "(", "wide", "(", "left", ".", "upper", ")", ",", "remainder_limit", "(", "right", ")", ")", "else", "0", ")", ")", ")", ";", "end", "silver_scalars", ";"]

abbrev ExpressionTranslation : Prop := Native.WellFormedTrees ∧
  Source.expressionBody "is_empty" Source.scalarsSpecTokens = some Native.isEmptyBody.render ∧
  Source.expressionBody "contains" Source.scalarsSpecTokens = some Native.containsBody.render ∧
  Source.expressionBody "singleton" Source.scalarsSpecTokens = some Native.singletonBody.render ∧
  Source.expressionBody "normalize" Source.scalarsSpecTokens = some Native.normalizeBody.render ∧
  Source.expressionBody "join" Source.scalarsSpecTokens = some Native.joinBody.render ∧
  Source.expressionBody "intersect" Source.scalarsSpecTokens = some Native.intersectBody.render ∧
  Source.expressionBody "compare" Source.scalarsSpecTokens = some Native.compareBody.render ∧
  Source.expressionBody "complement" Source.scalarsSpecTokens = some Native.complementBody.render ∧
  Source.expressionBody "swap" Source.scalarsSpecTokens = some Native.swapBody.render ∧
  Source.expressionBody "below" Source.scalarsSpecTokens = some Native.belowBody.render ∧
  Source.expressionBody "above" Source.scalarsSpecTokens = some Native.aboveBody.render ∧
  Source.expressionBody "refine_true" Source.scalarsSpecTokens = some Native.refineTrueBody.render ∧
  Source.expressionBody "refine" Source.scalarsSpecTokens = some Native.refineBody.render ∧
  Source.expressionBody "in_range" Source.scalarsSpecTokens = some Native.inRangeBody.render ∧
  Source.expressionBody "checked" Source.scalarsSpecTokens = some Native.checkedBody.render ∧
  Source.expressionBody "add" Source.scalarsSpecTokens = some Native.addBody.render ∧
  Source.expressionBody "subtract" Source.scalarsSpecTokens = some Native.subtractBody.render ∧
  Source.expressionBody "negate" Source.scalarsSpecTokens = some Native.negateBody.render ∧
  Source.expressionBody "product_minimum" Source.scalarsSpecTokens = some Native.productMinimumBody.render ∧
  Source.expressionBody "product_maximum" Source.scalarsSpecTokens = some Native.productMaximumBody.render ∧
  Source.expressionBody "multiply" Source.scalarsSpecTokens = some Native.multiplyBody.render ∧
  Source.expressionBody "quotient_minimum" Source.scalarsSpecTokens = some Native.quotientMinimumBody.render ∧
  Source.expressionBody "quotient_maximum" Source.scalarsSpecTokens = some Native.quotientMaximumBody.render ∧
  Source.expressionBody "divide" Source.scalarsSpecTokens = some Native.divideBody.render ∧
  Source.expressionBody "modulo" Source.scalarsSpecTokens = some Native.moduloBody.render ∧
  Source.expressionBody "remainder_limit" Source.scalarsSpecTokens = some Native.remainderLimitBody.render ∧
  Source.expressionBody "remainder" Source.scalarsSpecTokens = some Native.remainderBody.render

theorem expressions_checked : ExpressionTranslation := by
  refine ⟨Native.checked_precedence, ?_⟩
  repeat' apply And.intro
  all_goals decide +kernel

abbrev Headers : Prop :=
  functionHeader "is_empty" "is" Source.scalarsSpecTokens = some ["(", "bounds", ":", "interval", ")", "return", "boolean"] ∧
  functionHeader "contains" "is" Source.scalarsSpecTokens = some ["(", "bounds", ":", "interval", ";", "item", ":", "value", ")", "return", "boolean"] ∧
  functionHeader "singleton" "is" Source.scalarsSpecTokens = some ["(", "item", ":", "value", ")", "return", "interval"] ∧
  functionHeader "normalize" "is" Source.scalarsSpecTokens = some ["(", "bounds", ":", "interval", ")", "return", "interval"] ∧
  functionHeader "join" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "interval"] ∧
  functionHeader "intersect" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "interval"] ∧
  functionHeader "compare" "is" Source.scalarsSpecTokens = some ["(", "operator", ":", "comparison", ";", "left", ",", "right", ":", "value", ")", "return", "boolean"] ∧
  functionHeader "complement" "is" Source.scalarsSpecTokens = some ["(", "operator", ":", "comparison", ")", "return", "comparison"] ∧
  functionHeader "swap" "is" Source.scalarsSpecTokens = some ["(", "operator", ":", "comparison", ")", "return", "comparison"] ∧
  functionHeader "below" "is" Source.scalarsSpecTokens = some ["(", "bounds", ":", "interval", ";", "threshold", ":", "value", ")", "return", "interval"] ∧
  functionHeader "above" "is" Source.scalarsSpecTokens = some ["(", "bounds", ":", "interval", ";", "threshold", ":", "value", ")", "return", "interval"] ∧
  functionHeader "refine_true" "is" Source.scalarsSpecTokens = some ["(", "bounds", ":", "interval", ";", "operator", ":", "comparison", ";", "threshold", ":", "value", ")", "return", "interval"] ∧
  functionHeader "refine" "is" Source.scalarsSpecTokens = some ["(", "bounds", ":", "interval", ";", "operator", ":", "comparison", ";", "threshold", ":", "value", ";", "truth", ":", "boolean", ")", "return", "interval"] ∧
  functionHeader "in_range" "is" Source.scalarsSpecTokens = some ["(", "item", ":", "wide", ")", "return", "boolean"] ∧
  functionHeader "checked" "is" Source.scalarsSpecTokens = some ["(", "lower", ",", "upper", ":", "wide", ")", "return", "check_result"] ∧
  functionHeader "add" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "check_result"] ∧
  functionHeader "subtract" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "check_result"] ∧
  functionHeader "negate" "is" Source.scalarsSpecTokens = some ["(", "operand", ":", "interval", ")", "return", "check_result"] ∧
  functionHeader "product_minimum" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "wide"] ∧
  functionHeader "product_maximum" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "wide"] ∧
  functionHeader "multiply" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "check_result"] ∧
  functionHeader "quotient_minimum" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "wide"] ∧
  functionHeader "quotient_maximum" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "wide"] ∧
  functionHeader "divide" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "check_result"] ∧
  functionHeader "modulo" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "check_result"] ∧
  functionHeader "remainder_limit" "is" Source.scalarsSpecTokens = some ["(", "right", ":", "interval", ")", "return", "wide"] ∧
  functionHeader "remainder" "is" Source.scalarsSpecTokens = some ["(", "left", ",", "right", ":", "interval", ")", "return", "check_result"]

theorem headers_checked : Headers := by
  unfold Headers
  repeat' apply And.intro
  all_goals decide +kernel

abbrev Declarations : Prop :=
  subtypeDeclaration "value" Source.scalarsSpecTokens = some ["integer", "range", "-", "2_147_483_648", "..", "2_147_483_647"] ∧
  subtypeDeclaration "wide" Source.scalarsSpecTokens = some ["long_long_integer"] ∧
  Source.declaration "minimum" Source.scalarsSpecTokens = some ["constant", "wide", ":=", "-", "2_147_483_648"] ∧
  Source.declaration "maximum" Source.scalarsSpecTokens = some ["constant", "wide", ":=", "2_147_483_647"] ∧
  recordDeclaration "interval" Source.scalarsSpecTokens = some ["record", "lower", ",", "upper", ":", "value", ";", "end", "record"] ∧
  Source.declaration "empty" Source.scalarsSpecTokens = some ["constant", "interval", ":=", "(", "1", ",", "0", ")"] ∧
  Source.declaration "full" Source.scalarsSpecTokens = some ["constant", "interval", ":=", "(", "value", "'", "first", ",", "value", "'", "last", ")"] ∧
  typeDeclaration "comparison" Source.scalarsSpecTokens = some ["(", "equal", ",", "unequal", ",", "less", ",", "less_equal", ",", "greater", ",", "greater_equal", ")"] ∧
  recordDeclaration "check_result" Source.scalarsSpecTokens = some ["record", "safe", ":", "boolean", ";", "bounds", ":", "interval", ";", "end", "record"] ∧
  Source.declaration "invalid" Source.scalarsSpecTokens = some ["constant", "check_result", ":=", "(", "false", ",", "empty", ")"] ∧
  Source.declaration "unreachable" Source.scalarsSpecTokens = some ["constant", "check_result", ":=", "(", "true", ",", "empty", ")"]

theorem declarations_checked : Declarations := by decide +kernel

structure CheckedSource : Prop where
  source : Source.lex Source.scalarsSpec = some Source.scalarsSpecTokens
  shape : Source.scalarsSpecTokens = reviewedSpec
  expressions : ExpressionTranslation
  headers : Headers
  declarations : Declarations

theorem checked_source : CheckedSource where
  source := Source.scalarsSpecTokens_correct
  shape := by decide +kernel
  expressions := expressions_checked
  headers := headers_checked
  declarations := declarations_checked

end Silver.Integer.NativeSourceChecks
