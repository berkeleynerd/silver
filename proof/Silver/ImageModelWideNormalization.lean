module

public import Silver.ImageModelJsonSpelling

@[expose] public section
namespace Silver.ImageModel.JSON

mutual
  /-- Broad byte-oriented syntax-directed normalization for the array/scalar portion of
the pinned Why JSON grammar. The two flags describe position in the syntax;
no scanner state, successful match, or desired template identity is assumed.
A first W-tag string requires a bounded decimal ID in the next position.
This restriction is explicit: arbitrary string lists are not silently claimed
to satisfy it. Strings include every supported raw byte and Unicode escape;
there is no ASCII restriction in this grammar. Accepted selected matching must
derive conversion to NormalValue/NormalElements. -/
  inductive WideValue : Bool → Bool → Value → List Nat → Value → Bool → Prop
    | null (previous : Bool) : WideValue previous false .null [110, 117, 108, 108] .null false
    | true (previous : Bool) : WideValue previous false (.boolean true) [116, 114, 117, 101] (.boolean true) false
    | false (previous : Bool) : WideValue previous false (.boolean false) [102, 97, 108, 115, 101] (.boolean false) false
    | number (previous : Bool) (bytes : List Nat) (valid : IntegerToken bytes) :
        WideValue previous false (.number bytes) bytes (.number bytes) false
    | id (previous : Bool) (first : Nat) (rest : List Nat) (valid : IntegerToken (first :: rest))
        (decimal : ScannerNative.decimalWord (first :: rest))
        (bounded : ScannerNative.decimalFold 0 (first :: rest) ≤ originalIdMaximum) :
        WideValue previous true (.number (first :: rest)) (first :: rest) (.number [48]) false
    | string (previous : Bool) (characters bytes : List Nat) (content : CodeUnitContent characters bytes) :
        WideValue previous false (.string characters) ([34] ++ bytes ++ [34]) (.string characters) (previous && nodeTag characters)
    | array (previous : Bool) (values normalized : List Value) (bytes : List Nat)
        (entries : WideElements true false values bytes normalized) :
        WideValue previous false (.array values) ([91] ++ bytes ++ [93]) (.array normalized) false

  /-- A syntactically complete array body returns with no outstanding node ID.
Whitespace is represented at its original positions and is removed only from
the normalized output. -/
  inductive WideElements : Bool → Bool → List Value → List Nat → List Value → Prop
    | empty (previous : Bool) (spaces : List Nat) (whitespace : ScannerNative.Whitespace spaces) :
        WideElements previous false [] spaces []
    | single (previous pending : Bool) (value normalized : Value) (leading bytes trailing : List Nat)
        (before : ScannerNative.Whitespace leading) (item : WideValue previous pending value bytes normalized false)
        (after : ScannerNative.Whitespace trailing) :
        WideElements previous pending [value] (leading ++ (bytes ++ trailing)) [normalized]
    | more (previous pending outgoing : Bool) (value normalized : Value) (values restNormalized : List Value)
        (leading bytes spaces rest : List Nat) (nonempty : values ≠ [])
        (before : ScannerNative.Whitespace leading) (item : WideValue previous pending value bytes normalized outgoing)
        (between : ScannerNative.Whitespace spaces) (tail : WideElements false outgoing values rest restNormalized) :
        WideElements previous pending (value :: values) (leading ++ (bytes ++ spaces ++ [44] ++ rest)) (normalized :: restNormalized)
end

theorem WideValue.nonempty {previous pending outgoing : Bool} {value normalized : Value} {bytes : List Nat}
    (normal : WideValue previous pending value bytes normalized outgoing) : bytes ≠ [] := by
  cases normal with
  | null | true | false | id | string | array => simp
  | number _ _ valid => exact valid.nonempty

theorem WideElements.output_nonempty {previous pending : Bool} {values normalized : List Value} {bytes : List Nat}
    (normal : WideElements previous pending values bytes normalized) (nonempty : values ≠ []) : normalized ≠ [] := by
  cases normal <;> simp_all

end Silver.ImageModel.JSON
