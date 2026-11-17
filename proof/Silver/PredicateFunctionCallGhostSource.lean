module

public import Silver.PredicateFunctionCallHelpers
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! The exact one-step helper is a Static ghost procedure. Its call preserves
every model argument and erases only because its checked declaration is Ghost;
it supplies no assumption about the runtime loop or accepted author programs. -/
namespace Silver.Predicate.FunctionCallNative.ActualsAdvance
open Compose FunctionBindings Silver.SourceBridge

structure StaticCall where
  position : Expr Nat
  first : Expr Nat
  last : Expr Nat
  ordinal : Expr Nat
  named : Expr Bool
  seen : Expr FormalSet
  association : Expr ActualAssociation
  after : Expr Nat

def StaticCall.render (node : StaticCall) : List String :=
  call ["lemma_function_actuals_advance"]
    [["text"], ["context"], node.position.render, ["facts"], ["catalog"],
      node.first.render, node.last.render, node.ordinal.render, node.named.render,
      node.seen.render, node.association.render, node.after.render] ++ [";"]

def StaticCall.wellFormed (node : StaticCall) : Bool :=
  node.position.simple && node.position.wellFormed &&
  node.first.simple && node.first.wellFormed && node.last.simple && node.last.wellFormed &&
  node.ordinal.simple && node.ordinal.wellFormed && node.named.simple && node.named.wellFormed &&
  node.seen.simple && node.seen.wellFormed && node.association.simple && node.association.wellFormed &&
  node.after.simple && node.after.wellFormed

def StaticCall.scoped (node : StaticCall) (scope : Scope) : Bool :=
  decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope ∧ ("facts", 7) ∈ scope ∧ ("catalog", 8) ∈ scope) &&
  node.position.scoped scope && node.first.scoped scope && node.last.scoped scope &&
  node.ordinal.scoped scope && node.named.scoped scope && node.seen.scoped scope &&
  node.association.scoped scope && node.after.scoped scope

def StaticCall.eval (_node : StaticCall) (imports : Imports) (calls : Calls) (frame : Frame)
    (continuation : Expr α) : α := continuation.eval imports calls frame

theorem static_call_erased (node : StaticCall) (imports : Imports) (calls : Calls) (frame : Frame)
    (continuation : Expr α) : node.eval imports calls frame continuation = continuation.eval imports calls frame := rfl

def loopCall : StaticCall :=
  ⟨.loopCursor, .first, .last, .loopIndex, .named, .seen, .associationValue, .after⟩

def loopScope : Scope :=
  [("text",5),("context",6),("facts",7),("catalog",8),("position",0),("cursor",0),
   ("first",0),("last",0),("index",0),("named",11),("seen",12),("association",13),("after",0),("following",0)]

theorem loop_call_checked :
    loopCall.wellFormed = true ∧ loopCall.scoped loopScope = true ∧
    (loopCall.scoped (loopScope.filter (fun item => item.1 != "seen"))) = false ∧
    ({loopCall with ordinal := .ordinal}.scoped loopScope) = false := by decide +kernel

/-- The same complete transition over an arbitrary visited set is a direct
consequence of the recursive semantic definition. The native helper retains
its full cursor, context, metadata, payload and after bounds as well. -/
theorem model_advance (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : Metadata) (first last ordinal : Nat) (named : Bool)
    (seen : FormalSet) (association : ActualAssociation) (after : Nat)
    (valid : ActualsTailDomain text context position facts catalog first last ordinal)
    (advancing : ordinal < last)
    (selected : association = functionAssociation text position catalog first last ordinal named)
    (formalBounds : first ≤ association.formal ∧ association.formal ≤ last)
    (_payloadBound : association.payloadFirst ≤ text.length + 1)
    (unseen : seen association.formal = false)
    (afterNonzero : after ≠ 0) (_afterBound : after ≤ text.length + 1)
    (afterValue : after = actualAfter text context.model association.payloadFirst facts (parameter catalog association.formal))
    (comma : tokenAfter text after (.symbol ",") ≠ 0) :
    functionActualsTailModel text context.model position facts catalog first last ordinal named seen =
      functionActualsTailModel text context.model (tokenAfter text after (.symbol ",")) facts catalog
        first last (ordinal + 1) association.named (markFormal seen association.formal) := by
  have formalNonzero : association.formal ≠ 0 := by have positive := valid.2.2.1; omega
  have notLast : ordinal ≠ last := by omega
  rw [functionActualsTailModel, ← selected]
  simp only [formalNonzero, unseen, Bool.false_eq_true, or_self, ↓reduceIte]
  rw [← afterValue]
  simp only [tokenAfter, ShellToken.symbol] at comma ⊢
  simp only [afterNonzero, notLast, advancing, comma, ↓reduceIte, ↓reduceDIte]


def lemmaSpec : List String := ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "catalog", ":", "functions", ".", "metadata", ";", "first", ",", "last", ",", "ordinal", ":", "functions", ".", "formal_index", ";", "named", ":", "boolean", ";", "seen", ":", "formal_set", ";", "association", ":", "actual_association", ";", "after", ":", "literal_position", ")", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "catalog", ")", "and", "then", "first", "<=", "ordinal", "and", "then", "ordinal", "<", "last", "and", "then", "last", "<=", "catalog", ".", "parameter_count", "and", "then", "association", "=", "function_association", "(", "text", ",", "position", ",", "catalog", ",", "first", ",", "last", ",", "ordinal", ",", "named", ")", "and", "then", "association", ".", "formal", "in", "first", "..", "last", "and", "then", "association", ".", "payload_first", "<=", "text", "'", "last", "+", "1", "and", "then", "not", "seen", "(", "association", ".", "formal", ")", "and", "then", "after", "/=", "0", "and", "then", "after", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "=", "actual_model", "(", "text", ",", "context", ",", "association", ".", "payload_first", ",", "facts", ",", "catalog", ".", "parameters", "(", "association", ".", "formal", ")", ")", "and", "then", "take_token", "(", "text", ",", "after", ",", "comma", ")", "/=", "0", ",", "post", "=>", "function_actuals_tail_model", "(", "text", ",", "context", ",", "position", ",", "facts", ",", "catalog", ",", "first", ",", "last", ",", "ordinal", ",", "named", ",", "seen", ")", "=", "function_actuals_tail_model", "(", "text", ",", "context", ",", "take_token", "(", "text", ",", "after", ",", "comma", ")", ",", "facts", ",", "catalog", ",", "first", ",", "last", ",", "ordinal", "+", "1", ",", "association", ".", "named", ",", "mark_formal", "(", "seen", ",", "association", ".", "formal", ")", ")"]

def lemmaImpl : List String := ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "catalog", ":", "functions", ".", "metadata", ";", "first", ",", "last", ",", "ordinal", ":", "functions", ".", "formal_index", ";", "named", ":", "boolean", ";", "seen", ":", "formal_set", ";", "association", ":", "actual_association", ";", "after", ":", "literal_position", ")"]

def lemmaBody : List String :=
  ["begin", "null", ";", "end", "lemma_function_actuals_advance", ";"]

/-- Keep the complete Static ghost body; no assertion or token is elided. -/
def ordinaryBodies : List String → List (List String)
  | [] => []
  | "procedure" :: name :: tokens =>
      let later := ordinaryBodies (name :: tokens)
      if name == "lemma_function_actuals_advance" then
        match headerEnd 0 tokens with
        | some (header, "is") =>
            match Compose.BooleanDeclarationNative.SourceChecks.throughEnd name
                (tokens.drop (header.length + 1)) with
            | some body => body :: later
            | none => later
        | _ => later
      else later
  | _ :: tokens => ordinaryBodies tokens

def ordinaryBody (tokens : List String) : Option (List String) :=
  match ordinaryBodies tokens with | [body] => some body | _ => none

structure Checked (tokens : List String) : Prop where
  spec : procedureHeader "lemma_function_actuals_advance" ";" tokens = some lemmaSpec
  impl : procedureHeader "lemma_function_actuals_advance" "is" tokens = some lemmaImpl
  body : ordinaryBody tokens = some lemmaBody

end Silver.Predicate.FunctionCallNative.ActualsAdvance
