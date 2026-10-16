module

public import Silver.ImageModelJsonSpelling

@[expose] public section
namespace Silver.ImageModel.JSON

mutual
  /-- Independent syntax-directed normalization for the array/scalar portion of
the pinned Why JSON grammar. The two flags describe position in the syntax;
no scanner state, successful match, or desired template identity is assumed.
A first W-tag string requires a bounded decimal ID in the next position.
This restriction is explicit: arbitrary string lists are not silently claimed
to satisfy it. -/
  inductive NormalValue : Bool → Bool → Value → List Nat → Value → Bool → Prop
    | null (previous : Bool) : NormalValue previous false .null [110, 117, 108, 108] .null false
    | true (previous : Bool) : NormalValue previous false (.boolean true) [116, 114, 117, 101] (.boolean true) false
    | false (previous : Bool) : NormalValue previous false (.boolean false) [102, 97, 108, 115, 101] (.boolean false) false
    | number (previous : Bool) (bytes : List Nat) (valid : IntegerToken bytes) :
        NormalValue previous false (.number bytes) bytes (.number bytes) false
    | id (previous : Bool) (first : Nat) (rest : List Nat) (valid : IntegerToken (first :: rest))
        (decimal : ScannerNative.decimalWord (first :: rest))
        (bounded : ScannerNative.decimalFold 0 (first :: rest) ≤ originalIdMaximum) :
        NormalValue previous true (.number (first :: rest)) (first :: rest) (.number [48]) false
    | string (previous : Bool) (characters bytes : List Nat) (content : StringContent characters bytes) :
        NormalValue previous false (.string characters) ([34] ++ bytes ++ [34]) (.string characters) (previous && nodeTag characters)
    | array (previous : Bool) (values normalized : List Value) (bytes : List Nat)
        (entries : NormalElements true false values bytes normalized) :
        NormalValue previous false (.array values) ([91] ++ bytes ++ [93]) (.array normalized) false

  /-- A syntactically complete array body returns with no outstanding node ID.
Whitespace is represented at its original positions and is removed only from
the normalized output. -/
  inductive NormalElements : Bool → Bool → List Value → List Nat → List Value → Prop
    | empty (previous : Bool) (spaces : List Nat) (whitespace : ScannerNative.Whitespace spaces) :
        NormalElements previous false [] spaces []
    | single (previous pending : Bool) (value normalized : Value) (leading bytes trailing : List Nat)
        (before : ScannerNative.Whitespace leading) (item : NormalValue previous pending value bytes normalized false)
        (after : ScannerNative.Whitespace trailing) :
        NormalElements previous pending [value] (leading ++ (bytes ++ trailing)) [normalized]
    | more (previous pending outgoing : Bool) (value normalized : Value) (values restNormalized : List Value)
        (leading bytes spaces rest : List Nat) (nonempty : values ≠ [])
        (before : ScannerNative.Whitespace leading) (item : NormalValue previous pending value bytes normalized outgoing)
        (between : ScannerNative.Whitespace spaces) (tail : NormalElements false outgoing values rest restNormalized) :
        NormalElements previous pending (value :: values) (leading ++ (bytes ++ spaces ++ [44] ++ rest)) (normalized :: restNormalized)
end

theorem NormalValue.nonempty {previous pending outgoing : Bool} {value normalized : Value} {bytes : List Nat}
    (normal : NormalValue previous pending value bytes normalized outgoing) : bytes ≠ [] := by
  cases normal with
  | null | true | false | id | string | array => simp
  | number _ _ valid => exact valid.nonempty

theorem NormalElements.output_nonempty {previous pending : Bool} {values normalized : List Value} {bytes : List Nat}
    (normal : NormalElements previous pending values bytes normalized) (nonempty : values ≠ []) : normalized ≠ [] := by
  cases normal <;> simp_all

end Silver.ImageModel.JSON
