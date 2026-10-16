module

public import Silver.ImageModelJsonFields

@[expose] public section
namespace Silver.ImageModel.JSON

/-- An original field span includes its own adjacent whitespace. The spelling
relation below proves its body and whitespace separately. -/
structure FieldSpan where
  value : Value
  leading : List Nat
  body : List Nat
  trailing : List Nat

def FieldSpan.bytes (span : FieldSpan) : List Nat := span.leading ++ span.body ++ span.trailing

def fieldsBytes : List FieldSpan → List Nat
  | [] => []
  | [span] => span.bytes
  | span :: next :: rest => span.bytes ++ [44] ++ fieldsBytes (next :: rest)

inductive NormalField (index : Nat) (previous pending : Bool) (span : FieldSpan) (normalized : Value) (outgoing : Bool) : Prop
  | mk (before : ScannerNative.Whitespace span.leading)
      (value : NormalValue previous pending span.value span.body normalized outgoing)
      (legal : ScannerNative.FieldLegal index span.value)
      (after : ScannerNative.Whitespace span.trailing)

/-- Exactly the eight top-level theory positions are represented when starting
at index zero. These constructors contain only syntax/domain subderivations. -/
inductive NormalFields : Nat → Bool → Bool → List FieldSpan → List Value → Prop
  | last (previous pending : Bool) (span : FieldSpan) (normalized : Value)
      (field : NormalField 7 previous pending span normalized false) :
      NormalFields 7 previous pending [span] [normalized]
  | more (index : Nat) (previous pending outgoing : Bool) (span : FieldSpan) (normalized : Value)
      (spans : List FieldSpan) (restNormalized : List Value) (bounded : index < 7)
      (field : NormalField index previous pending span normalized outgoing)
      (tail : NormalFields (index + 1) false outgoing spans restNormalized) :
      NormalFields index previous pending (span :: spans) (normalized :: restNormalized)

theorem NormalFields.nonempty {index : Nat} {previous pending : Bool} {spans : List FieldSpan} {normalized : List Value}
    (normal : NormalFields index previous pending spans normalized) : spans ≠ [] ∧ normalized ≠ [] := by
  cases normal <;> simp

theorem NormalFields.length {index : Nat} {previous pending : Bool} {spans : List FieldSpan} {normalized : List Value}
    (normal : NormalFields index previous pending spans normalized) : spans.length + index = 8 ∧ normalized.length = spans.length := by
  induction normal with
  | last => simp
  | more _ _ _ _ _ _ _ _ bounded field tail ih => simp only [List.length_cons]; omega

theorem fieldsBytes_cons (span : FieldSpan) (spans : List FieldSpan) (nonempty : spans ≠ []) :
    fieldsBytes (span :: spans) = span.bytes ++ [44] ++ fieldsBytes spans := by
  cases spans with
  | nil => contradiction
  | cons => rfl

end Silver.ImageModel.JSON

namespace Silver.ImageModel.ScannerNative

def valueScope (context : JsonScope) (start : Nat) (value : JSON.Value) (length : Nat) : JsonScope :=
  match value with
  | .string characters => {context with theory := if context.field = 4 then selectedName characters context.theory else context.theory}
  | .array _ => {context with
      candidateDeclarations := if context.field = 3 then start + length - 1 else context.candidateDeclarations
      candidateIncludes := if context.field = 6 then start + length - 1 else context.candidateIncludes}
  | _ => context

theorem fieldScope_valueScope (state : Core.State) (value : JSON.Value) (length : Nat) :
    fieldScope state value length = valueScope (scope state) state.bytes value length := by cases value <;> rfl

def spanScope (context : JsonScope) (start : Nat) (span : JSON.FieldSpan) : JsonScope :=
  valueScope context (start + span.leading.length) span.value span.body.length

def fieldsScope (context : JsonScope) (start : Nat) : List JSON.FieldSpan → JsonScope
  | [] => context
  | [span] => spanScope context start span
  | span :: next :: rest =>
      fieldsScope {spanScope context start span with field := context.field + 1}
        (start + span.bytes.length + 1) (next :: rest)

theorem valueScope_depth (context : JsonScope) (start : Nat) (value : JSON.Value) (length : Nat) :
    (valueScope context start value length).depth = context.depth := by cases value <;> rfl

theorem valueScope_field (context : JsonScope) (start : Nat) (value : JSON.Value) (length : Nat) :
    (valueScope context start value length).field = context.field := by cases value <;> rfl

theorem fieldsScope_cons (context : JsonScope) (start : Nat) (span : JSON.FieldSpan) (spans : List JSON.FieldSpan)
    (nonempty : spans ≠ []) : fieldsScope context start (span :: spans) =
      fieldsScope {spanScope context start span with field := context.field + 1}
        (start + span.bytes.length + 1) spans := by
  cases spans with
  | nil => contradiction
  | cons => rfl

structure ScopedResult (tables : Native.Tables) (before after : Core.State) (context : JsonScope)
    (input normalized : List Nat) (pending : Bool) : Prop where
  good : after.failed = false
  active : after.matcher.inTheory = true
  context : scope after = context
  bytes : after.bytes = before.bytes + input.length
  boundary : Boundary after
  previous : after.previousArrayStart = false
  nodeId : after.nodeIdPending = pending
  emits : Emits tables before after normalized

end Silver.ImageModel.ScannerNative
