module

public import Silver.IntegerImageNativeExpressions
public import Silver.IntegerImageNativeCapture
public import Silver.ScalarsNativeSourceBridge
public import Silver.SourceDeclarations
import all Init.Data.Repr

@[expose] public section

/-! Checked capture of the complete native Image helper specification. The
typed bodies preserve every signed comparison, empty-domain test, helper call,
and endpoint min/max operation. Source interpretation remains the documented
frontend premise; the helper meanings follow from the checked body equations. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Integer.Image.NativeSource
open Silver.SourceBridge Silver.Lexical.SourceBridge

def lengthHeader : List String :=
  ["(", "item", ":", "silver_scalars", ".", "value", ")", "return", "image_length"]

def boundsHeader : List String :=
  ["(", "bounds", ":", "silver_scalars", ".", "interval", ")", "return", "possible_length"]

def reviewedSpec : List String :=
  ["with", "silver_scalars", ";", "package", "silver_integer_image", "with", "spark_mode", "=>", "on", "is",
   "subtype", "image_length", "is", "natural", "range", "2", "..", "11", ";",
   "subtype", "possible_length", "is", "natural", "range", "0", "..", "11", ";",
   "function", "length_of"] ++ lengthHeader ++ ["is", "("] ++ Native.lengthBody.render ++ [")", ";",
   "function", "minimum_length"] ++ boundsHeader ++ ["is", "("] ++ Native.minimumBody.render ++ [")", ";",
   "function", "maximum_length"] ++ boundsHeader ++ ["is", "("] ++ Native.maximumBody.render ++ [")", ";",
   "end", "silver_integer_image", ";"]

theorem source_checked : Source.lex Source.integerImageSpec = some reviewedSpec := by
  rw [Source.integerImageSpecTokens_correct]
  decide +kernel

abbrev Headers : Prop :=
  functionHeader "length_of" "is" reviewedSpec = some lengthHeader ∧
  functionHeader "minimum_length" "is" reviewedSpec = some boundsHeader ∧
  functionHeader "maximum_length" "is" reviewedSpec = some boundsHeader

theorem headers_checked : Headers := by decide +kernel

abbrev Declarations : Prop :=
  subtypeDeclaration "image_length" reviewedSpec = some ["natural", "range", "2", "..", "11"] ∧
  subtypeDeclaration "possible_length" reviewedSpec = some ["natural", "range", "0", "..", "11"]

theorem declarations_checked : Declarations := by decide +kernel

abbrev Bodies : Prop :=
  Source.expressionBody "length_of" reviewedSpec = some Native.lengthBody.render ∧
  Source.expressionBody "minimum_length" reviewedSpec = some Native.minimumBody.render ∧
  Source.expressionBody "maximum_length" reviewedSpec = some Native.maximumBody.render

theorem bodies_checked : Bodies := by decide +kernel

structure CheckedSource : Prop where
  source : Source.lex Source.integerImageSpec = some reviewedSpec
  headers : Headers
  declarations : Declarations
  bodies : Bodies
  precedence : Native.lengthBody.wellFormed = true ∧
    Native.minimumBody.wellFormed = true ∧ Native.maximumBody.wellFormed = true
  numerals : ∀ value : Native.Threshold,
    ((value.spelling.toList.filter (· != '_')).foldl
      (fun total digit => 10 * total + (digit.toNat - '0'.toNat)) 0) = value.value
  digits : ∀ value : Native.Threshold,
    (value.spelling.toList.filter (· != '_')).all Char.isDigit = true

theorem checked_source : CheckedSource where
  source := source_checked
  headers := headers_checked
  declarations := declarations_checked
  bodies := bodies_checked
  precedence := Native.checked_precedence
  numerals := Native.Threshold.spelling_value
  digits := Native.Threshold.spelling_digits

structure InterpretedSource (calls : Native.Calls) (scalarCalls : Integer.Native.Calls) : Prop where
  definitions : Native.Equations calls
  scalars : Integer.NativeSourceBridge.InterpretedSource scalarCalls
  scalarLink : calls.isEmpty = scalarCalls .isEmpty

theorem interpreted_meaning (calls : Native.Calls) (scalarCalls : Integer.Native.Calls)
    (source : InterpretedSource calls scalarCalls) : Native.Meaning calls := by
  apply Native.equations_meaning calls source.definitions
  rw [source.scalarLink]
  exact Integer.NativeSourceBridge.interpreted_functions scalarCalls source.scalars .isEmpty

theorem lengthOf_exact (calls : Native.Calls) (scalarCalls : Integer.Native.Calls)
    (source : InterpretedSource calls scalarCalls) (item : Int) (bounded : InRange item) :
    calls.lengthOf item = (bytes item).length := by
  rw [(interpreted_meaning calls scalarCalls source).length]
  exact Native.lengthOf_exact item bounded

theorem minimumLength_eq (calls : Native.Calls) (scalarCalls : Integer.Native.Calls)
    (source : InterpretedSource calls scalarCalls) (bounds : Interval) (bounded : bounds.Bounded) :
    calls.minimumLength bounds = if bounds.isEmpty then 0 else (lengthBounds bounds).1 := by
  rw [(interpreted_meaning calls scalarCalls source).minimum]
  exact Native.minimumLength_eq bounds bounded

theorem maximumLength_eq (calls : Native.Calls) (scalarCalls : Integer.Native.Calls)
    (source : InterpretedSource calls scalarCalls) (bounds : Interval) (bounded : bounds.Bounded) :
    calls.maximumLength bounds = if bounds.isEmpty then 0 else (lengthBounds bounds).2 := by
  rw [(interpreted_meaning calls scalarCalls source).maximum]
  exact Native.maximumLength_eq bounds bounded

theorem actual_source_correspondence : CheckedSource ∧
    ∀ calls scalarCalls, InterpretedSource calls scalarCalls → Native.Meaning calls :=
  ⟨checked_source, interpreted_meaning⟩

theorem model_interpreted : InterpretedSource Native.modelCalls Integer.Native.Function.eval where
  definitions := Native.model_equations
  scalars := Integer.NativeSourceBridge.model_interpreted
  scalarLink := rfl

end Silver.Integer.Image.NativeSource
