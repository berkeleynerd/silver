module

public import Silver.ApplicationUnitsExpressions
public import Silver.ApplicationUnitsSourceShape
public import Silver.ComposeBooleanDeclarationSource
public import Silver.ApplicationUnitsSpecCertificate
public import Silver.ApplicationUnitsBodyCertificate
public import Silver.ProfileSpecCertificate
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ApplicationUnits.SourceBridge
open Silver.SourceBridge Silver.Lexical.SourceBridge

abbrev ReviewedShape : Prop :=
  Source.applicationUnitsSpecTokens = SourceShape.spec ∧ Source.applicationUnitsBodyTokens = SourceShape.body

theorem actual_reviewed_shape : ReviewedShape := by decide +kernel

abbrev ExpressionTranslation : Prop :=
  Native.CheckedTrees ∧
  expressionDeclaration "fits" Source.applicationUnitsSpecTokens =
    some (Native.fitsBody.render, ["with", "global", "=>", "null"]) ∧
  expressionDeclaration "valid" Source.applicationUnitsSpecTokens =
    some (Native.validBody.render, ["with", "global", "=>", "null"]) ∧
  expressionDeclaration "unit_span" Source.applicationUnitsBodyTokens = some (Native.unitSpanBody.render, []) ∧
  expressionDeclaration "unit_source" Source.applicationUnitsBodyTokens = some (Native.unitSourceBody.render, []) ∧
  expressionDeclaration "prefix" Source.applicationUnitsBodyTokens = some (Native.prefixBody.render, []) ∧
  Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "pack" Source.applicationUnitsBodyTokens =
    some (Native.packBody.render ++ ["end", "pack", ";"])

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Declarations : Prop :=
  Source.declaration "max_source_length" Source.applicationUnitsSpecTokens =
    some (["constant", "positive", ":=", "silver_profile", ".", "max_source_length"]) ∧
  Source.declaration "max_source_length" Source.specTokens = some (["constant", "positive", ":=", "4_096"]) ∧
  subtypeDeclaration "source_buffer" Source.applicationUnitsSpecTokens =
    some (["string", "(", "1", "..", "max_source_length", ")"]) ∧
  subtypeDeclaration "source_length" Source.applicationUnitsSpecTokens =
    some (["natural", "range", "0", "..", "max_source_length"]) ∧
  subtypeDeclaration "unit_position" Source.applicationUnitsSpecTokens =
    some (["positive", "range", "1", "..", "max_source_length", "+", "1"]) ∧
  typeDeclaration "unit_kind" Source.applicationUnitsSpecTokens =
    some (["(", "package_specification", ",", "package_body", ",", "main_body", ")"]) ∧
  typeDeclaration "span_array" Source.applicationUnitsSpecTokens = some (["array", "(", "unit_kind", ")", "of", "span"]) ∧
  recordDeclaration "span" Source.applicationUnitsSpecTokens =
    some (["record", "first", ":", "unit_position", ":=", "1", ";", "after", ":", "unit_position", ":=", "1", ";", "end", "record"]) ∧
  recordDeclaration "bundle" Source.applicationUnitsSpecTokens =
    some (["record", "pool", ":", "source_buffer", ":=", "(", "others", "=>", "character", "'", "val", "(", "0", ")", ")", ";", "used", ":", "source_length", ":=", "0", ";", "units", ":", "span_array", ":=", "(", "others", "=>", "(", "first", "=>", "1", ",", "after", "=>", "1", ")", ")", ";", "end", "record"])

theorem actual_declarations : Declarations := by decide +kernel

def specHeaders : List (String × String × List String) := [
  ("fits", "is", ["(", "specification_source", ",", "body_source", ",", "main_source", ":", "string", ")", "return", "boolean"]),
  ("valid", "is", ["(", "sources", ":", "bundle", ")", "return", "boolean"]),
  ("unit_span", ";", ["(", "sources", ":", "bundle", ";", "kind", ":", "unit_kind", ")", "return", "span", "with", "global", "=>", "null", ",", "pre", "=>", "valid", "(", "sources", ")", ",", "post", "=>", "unit_span", "'", "result", "=", "sources", ".", "units", "(", "kind", ")", "and", "then", "unit_span", "'", "result", ".", "first", "<", "unit_span", "'", "result", ".", "after", "and", "then", "unit_span", "'", "result", ".", "after", "<=", "sources", ".", "used", "+", "1"]),
  ("unit_source", ";", ["(", "sources", ":", "bundle", ";", "kind", ":", "unit_kind", ")", "return", "string", "with", "global", "=>", "null", ",", "pre", "=>", "valid", "(", "sources", ")", ",", "post", "=>", "unit_source", "'", "result", "'", "first", "=", "sources", ".", "units", "(", "kind", ")", ".", "first", "and", "then", "unit_source", "'", "result", "'", "last", "=", "sources", ".", "units", "(", "kind", ")", ".", "after", "-", "1", "and", "then", "unit_source", "'", "result", "=", "sources", ".", "pool", "(", "sources", ".", "units", "(", "kind", ")", ".", "first", "..", "sources", ".", "units", "(", "kind", ")", ".", "after", "-", "1", ")"]),
  ("prefix", ";", ["(", "sources", ":", "bundle", ";", "kind", ":", "unit_kind", ")", "return", "string", "with", "global", "=>", "null", ",", "pre", "=>", "valid", "(", "sources", ")", ",", "post", "=>", "prefix", "'", "result", "'", "first", "=", "1", "and", "then", "prefix", "'", "result", "'", "last", "=", "sources", ".", "units", "(", "kind", ")", ".", "after", "-", "1", "and", "then", "prefix", "'", "result", "=", "sources", ".", "pool", "(", "1", "..", "sources", ".", "units", "(", "kind", ")", ".", "after", "-", "1", ")"]),
  ("pack", ";", ["(", "specification_source", ",", "body_source", ",", "main_source", ":", "string", ")", "return", "bundle", "with", "global", "=>", "null", ",", "pre", "=>", "fits", "(", "specification_source", ",", "body_source", ",", "main_source", ")", ",", "post", "=>", "valid", "(", "pack", "'", "result", ")", "and", "then", "pack", "'", "result", ".", "used", "=", "specification_source", "'", "length", "+", "body_source", "'", "length", "+", "main_source", "'", "length", "and", "then", "pack", "'", "result", ".", "units", "(", "package_specification", ")", "=", "(", "first", "=>", "1", ",", "after", "=>", "specification_source", "'", "length", "+", "1", ")", "and", "then", "pack", "'", "result", ".", "units", "(", "package_body", ")", "=", "(", "first", "=>", "specification_source", "'", "length", "+", "1", ",", "after", "=>", "specification_source", "'", "length", "+", "body_source", "'", "length", "+", "1", ")", "and", "then", "pack", "'", "result", ".", "units", "(", "main_body", ")", "=", "(", "first", "=>", "specification_source", "'", "length", "+", "body_source", "'", "length", "+", "1", ",", "after", "=>", "pack", "'", "result", ".", "used", "+", "1", ")", "and", "then", "unit_source", "(", "pack", "'", "result", ",", "package_specification", ")", "=", "specification_source", "and", "then", "unit_source", "(", "pack", "'", "result", ",", "package_body", ")", "=", "body_source", "and", "then", "unit_source", "(", "pack", "'", "result", ",", "main_body", ")", "=", "main_source", "and", "then", "(", "for", "all", "position", "in", "pack", "'", "result", ".", "used", "+", "1", "..", "max_source_length", "=>", "pack", "'", "result", ".", "pool", "(", "position", ")", "=", "character", "'", "val", "(", "0", ")", ")"])]

def bodyHeaders : List (String × String × List String) := [
  ("unit_span", "is", ["(", "sources", ":", "bundle", ";", "kind", ":", "unit_kind", ")", "return", "span"]),
  ("unit_source", "is", ["(", "sources", ":", "bundle", ";", "kind", ":", "unit_kind", ")", "return", "string"]),
  ("prefix", "is", ["(", "sources", ":", "bundle", ";", "kind", ":", "unit_kind", ")", "return", "string"]),
  ("pack", "is", ["(", "specification_source", ",", "body_source", ",", "main_source", ":", "string", ")", "return", "bundle"])]

abbrev Headers : Prop :=
  (∀ item ∈ specHeaders, functionHeader item.1 item.2.1 Source.applicationUnitsSpecTokens = some item.2.2) ∧
  (∀ item ∈ bodyHeaders, functionHeader item.1 item.2.1 Source.applicationUnitsBodyTokens = some item.2.2)

theorem actual_headers : Headers := by decide +kernel

structure CheckedSource : Prop where
  specification : Source.lex Source.applicationUnitsSpec = some Source.applicationUnitsSpecTokens
  implementation : Source.lex Source.applicationUnitsBody = some Source.applicationUnitsBodyTokens
  reviewedShape : ReviewedShape
  expressions : ExpressionTranslation
  declarations : Declarations
  headers : Headers

theorem checked_source : CheckedSource where
  specification := Source.applicationUnitsSpecTokens_correct
  implementation := Source.applicationUnitsBodyTokens_correct
  reviewedShape := actual_reviewed_shape
  expressions := actual_expressions
  declarations := actual_declarations
  headers := actual_headers

end Silver.ApplicationUnits.SourceBridge
