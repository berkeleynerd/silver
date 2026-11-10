module

public import Silver.ProcedureDeclarationBodyNative
public import Silver.ProcedureDeclarationOuterNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative.HighSourceChecks
open Silver.SourceBridge

/-- The complete Static helper header binds the erased call to its native
contract; native verification still discharges every obligation. -/
def metadataAppendHeader : List String := expectedTokens
  "(Text : String; Environment : Procedures.Metadata; Item : Procedures.Signature) with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Procedures.Valid_Metadata (Text, Environment) and then Environment.Count < Procedures.Max_Procedures and then Item.First > 0 and then Valid_Name_State (Text, Item.First, Item.After) and then Item.Count > 0 and then Item.Formal_First > 0 and then Item.Formal_First <= Environment.Parameter_Count and then Item.Count <= Environment.Parameter_Count - Item.Formal_First + 1, Post => Procedures.Valid_Metadata (Text, Procedures.Append (Environment, Item))"

/-- Every written input binder must be in scope; guards also enforce the
Ada operator categories and selected-component prefixes. -/
def CheckedTrees : Prop :=
  procedureBodyBody.scoped [(.source, "text"), (.state, "outer"), (.state, "frame"),
    (.number, "first"), (.number, "after"), (.truth, "arguments")] = true ∧
  procedureBodyBody.wellFormed = true ∧
  procedureDeclarationBody.scoped [(.source, "text"), (.state, "state"),
    (.truth, "arguments")] = true ∧
  procedureDeclarationBody.wellFormed = true

theorem checked_trees : CheckedTrees := by
  unfold CheckedTrees
  decide +kernel

/-- Complete native preconditions remain visible beside each body header. -/
def headers : List (String × String × List String) := [
  ("procedure_body_at", ";", ["(", "text", ":", "string", ";", "outer", ",", "frame", ":", "parser_state", ";", "first", ",", "after", ":", "literal_position", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "outer", ")", "and", "then", "valid_state", "(", "text", ",", "frame", ")", "and", "then", "outer", ".", "procedures", ".", "parameter_count", "<=", "frame", ".", "procedures", ".", "parameter_count", "and", "then", "frame", ".", "first_procedure_parameter", ">", "0", "and", "then", "frame", ".", "first_procedure_parameter", "<=", "frame", ".", "procedures", ".", "parameter_count", "and", "then", "frame", ".", "procedures", ".", "count", "<", "procedures", ".", "max_procedures", "and", "then", "valid_name_state", "(", "text", ",", "first", ",", "after", ")", "and", "then", "first", ">", "0", ",", "post", "=>", "valid_state", "(", "text", ",", "procedure_body_at", "'", "result", ")", "and", "then", "(", "procedure_body_at", "'", "result", ".", "position", "=", "0", "or", "else", "procedure_body_at", "'", "result", ".", "position", ">", "outer", ".", "position", ")"]),
  ("procedure_body_at", "is", ["(", "text", ":", "string", ";", "outer", ",", "frame", ":", "parser_state", ";", "first", ",", "after", ":", "literal_position", ";", "arguments", ":", "boolean", ")", "return", "parser_state"]),
  ("procedure_declaration_at", ";", ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "procedure_declaration_at", "'", "result", ")", "and", "then", "(", "procedure_declaration_at", "'", "result", ".", "position", "=", "0", "or", "else", "procedure_declaration_at", "'", "result", ".", "position", ">", "state", ".", "position", ")"]),
  ("procedure_declaration_at", "is", ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state"])]

def ordinary : List (String × List String) := [
  ("procedure_body_at", procedureBodyBody.render ++ ["end", "procedure_body_at", ";"]),
  ("procedure_declaration_at", procedureDeclarationBody.render ++ ["end", "procedure_declaration_at", ";"])]

structure Checked (tokens : List String) : Prop where
  trees : CheckedTrees
  metadataAppend : procedureHeader "lemma_procedure_metadata_append" "is" tokens = some metadataAppendHeader
  headers : ∀ item ∈ headers, functionHeader item.1 item.2.1 tokens = some item.2.2
  ordinary : ∀ item ∈ ordinary,
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 tokens = some item.2

end Silver.Compose.ProcedureDeclarationNative.HighSourceChecks
