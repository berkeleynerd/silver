module

import all Init.Data.Repr

public import Silver.ImageModelTemplateIndex
public import Silver.ImageModelTemplatesSpecCertificate
public import Silver.ImageModelTemplatesBodyCertificate
public import Silver.SourceDeclarations
public meta import Silver.CertificateWitness

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.Templates

open Silver.SourceBridge

/-- The source spelling is reconstructed from the exact interpreted bytes;
Ada doubles interior quotes in string literal spellings. -/
def quoteAda (value : List Nat) : String :=
  String.ofList (([34] ++ value.flatMap (fun byte =>
    if byte = 34 then [34, 34] else [byte]) ++ [34]).map Char.ofNat)

def aggregateTokens (values : List (List Nat)) : List String :=
  ["("] ++ ((values.zipIdx.map (fun (value, index) =>
    [toString (index + 1), "=>", quoteAda value])).intersperse [","]).flatten ++ [")"]

def dataTokens (kind : Kind) : List String :=
  [kind.spelling ++ "_data", ":", "constant", "chunks", ":="] ++
    aggregateTokens (chunkBytes kind) ++ [";"]

def specRender : List String := [
  "package", "silver_image_model_templates", "with", "spark_mode", "=>", "on", "is", "type", "kind",
  "is", "(", "integer_template", ",", "string_template", ",", "image_template", ",", "declarations_fragment",
  ",", "includes_fragment", ")", ";", "function", "length", "(", "item", ":",
  "kind", ")", "return", "positive", "with", "global", "=>", "null", ";",
  "function", "byte_at", "(", "item", ":", "kind", ";", "position", ":",
  "positive", ")", "return", "character", "with", "global", "=>", "null", ",",
  "pre", "=>", "position", "<=", "length", "(", "item", ")", ";",
  "inserted_node_count", ":", "constant", ":=", "23", ";", "end", "silver_image_model_templates", ";"]

def bodyRender : List String :=
  [
  "package", "body", "silver_image_model_templates", "with", "spark_mode", "=>", "on", "is", "subtype",
  "chunk", "is", "string", "(", "1", "..", "128", ")", ";",
  "type", "chunks", "is", "array", "(", "positive", "range", "<", ">",
  ")", "of", "chunk", ";"] ++
  kinds.flatMap dataTokens ++ [
  "function", "length", "(", "item", ":", "kind", ")", "return", "positive",
  "is", "(", "case", "item", "is", "when", "integer_template", "=>", "5039",
  ",", "when", "string_template", "=>", "5618", ",", "when", "image_template", "=>",
  "8343", ",", "when", "declarations_fragment", "=>", "1002", ",", "when", "includes_fragment",
  "=>", "92", ")", ";", "function", "byte_at", "(", "item", ":",
  "kind", ";", "position", ":", "positive", ")", "return", "character", "is",
  "begin", "case", "item", "is", "when", "integer_template", "=>", "return", "integer_template_data",
  "(", "(", "position", "-", "1", ")", "/", "128", "+",
  "1", ")", "(", "(", "position", "-", "1", ")", "mod",
  "128", "+", "1", ")", ";", "when", "string_template", "=>", "return",
  "string_template_data", "(", "(", "position", "-", "1", ")", "/", "128",
  "+", "1", ")", "(", "(", "position", "-", "1", ")",
  "mod", "128", "+", "1", ")", ";", "when", "image_template", "=>",
  "return", "image_template_data", "(", "(", "position", "-", "1", ")", "/",
  "128", "+", "1", ")", "(", "(", "position", "-", "1",
  ")", "mod", "128", "+", "1", ")", ";", "when", "declarations_fragment",
  "=>", "return", "declarations_fragment_data", "(", "(", "position", "-", "1", ")",
  "/", "128", "+", "1", ")", "(", "(", "position", "-",
  "1", ")", "mod", "128", "+", "1", ")", ";", "when",
  "includes_fragment", "=>", "return", "includes_fragment_data", "(", "(", "position", "-", "1",
  ")", "/", "128", "+", "1", ")", "(", "(", "position",
  "-", "1", ")", "mod", "128", "+", "1", ")", ";",
  "end", "case", ";", "end", "byte_at", ";", "end", "silver_image_model_templates", ";"]

/-- Complete source context checks all chunks, selectors, arithmetic, types,
contracts, package bindings, and the inserted-node count together. -/
theorem actual_spec : Source.imageModelTemplatesSpecTokens = specRender := by decide +kernel

theorem actual_body : Source.imageModelTemplatesBodyTokens = bodyRender := by
  kernel_exact (Eq.refl bodyRender)

structure CheckedSource : Prop where
  spec : Source.lex Source.imageModelTemplatesSpec = some specRender
  body : Source.lex Source.imageModelTemplatesBody = some bodyRender
  chunkWidth : ∀ kind chunk, chunk ∈ chunkBytes kind → chunk.length = 128
  ascii : ∀ kind chunk, chunk ∈ chunkBytes kind → ∀ byte ∈ chunk, byte < 128
  lengths : kinds.map length = [5039, 5618, 8343, 1002, 92]

theorem checked_source : CheckedSource where
  spec := Source.imageModelTemplatesSpecTokens_correct.trans (congrArg some actual_spec)
  body := Source.imageModelTemplatesBodyTokens_correct.trans (congrArg some actual_body)
  chunkWidth := chunk_width
  ascii := chunk_ascii
  lengths := content_lengths

structure Calls where
  length : Kind → Nat
  byteAt : Kind → Nat → Nat

/-- Interpretation of the checked case selections and one-based constant-array
lookups at the documented Ada frontend boundary. Padding is not observable. -/
structure InterpretedSource (calls : Calls) : Prop where
  length : ∀ kind, calls.length kind = length kind
  byteAt : ∀ kind position, 1 ≤ position → position ≤ Templates.length kind →
    calls.byteAt kind position =
      ((chunkBytes kind)[(position - 1) / 128]?.getD [])[(position - 1) % 128]?.getD 0

theorem interpreted_length (calls : Calls) (source : InterpretedSource calls) (kind : Kind) :
    calls.length kind = (bytes kind).length := by
  rw [source.length, content_length]

theorem interpreted_byte (calls : Calls) (source : InterpretedSource calls) (kind : Kind)
    (position : Nat) (positive : 1 ≤ position) (bounded : position ≤ calls.length kind) :
    calls.byteAt kind position = (bytes kind)[position - 1]?.getD 0 := by
  rw [source.length] at bounded
  rw [source.byteAt kind position positive bounded]
  exact byteAt_eq kind position positive bounded

def modelCalls : Calls := ⟨length, byteAt⟩

theorem model_interpreted : InterpretedSource modelCalls where
  length _ := rfl
  byteAt _ _ _ _ := rfl

end Silver.ImageModel.Templates
