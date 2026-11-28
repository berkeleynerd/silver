module

public import Silver.ApplicationStateValidityPrimitives
import all Init.Data.Repr

@[expose] public section

namespace Silver.ApplicationPackageFrames.ValidityTables.Primitives.Source
open SourceBridge

def nameHeader : List String := expectedTokens
  "(Text : String; First, After : Literal_Position) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length"

def nameImplementation : List String := expectedTokens
  "(Text : String; First, After : Literal_Position) return Boolean"

def boundsHeader : List String := expectedTokens
  "(Length : Capacity_Value; Dynamic, Is_Character : Boolean; First_Index, Last_Index : Scalars.Value; Slot : Binding_Index) return Boolean"

structure Checked (lexical profile : List String) : Prop where
  nameTree : nameStateBody.wellFormedRoot noNames = true ∧
    nameStateBody.scoped [(.source,"text"),(.number,"first"),(.number,"after")] = true
  boundsTree : Compose.StringNative.fixedBoundsBody.wellFormed = true ∧
    Compose.StringNative.fixedBoundsBody.scoped [("length",.number),("dynamic",.truth),
      ("is_character",.truth),("first_index",.integer),("last_index",.integer),("slot",.number)] = true
  nameSpecification : functionHeader "valid_name_state" ";" lexical = some nameHeader
  nameImplementation : functionHeader "valid_name_state" "is" lexical = some nameImplementation
  nameExpression : Silver.Source.expressionBody "valid_name_state" lexical =
    some (nameStateBody.render noNames)
  boundsHeader : functionHeader "fixed_bounds_valid" "is" profile = some boundsHeader
  boundsExpression : Silver.Source.expressionBody "fixed_bounds_valid" profile =
    some Compose.StringNative.fixedBoundsBody.render

def lexicalCandidate : List String := expectedTokens
  "function Valid_Name_State (Text : String; First, After : Literal_Position) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length; function Valid_Name_State (Text : String; First, After : Literal_Position) return Boolean is ((First = 0 and then After = 0) or else (First > 0 and then First < After and then After <= Text'Last + 1));"

def profileCandidate : List String := expectedTokens
  "function Fixed_Bounds_Valid (Length : Capacity_Value; Dynamic, Is_Character : Boolean; First_Index, Last_Index : Scalars.Value; Slot : Binding_Index) return Boolean is (if Is_Character then not Dynamic and then Length = 1 and then First_Index = 1 and then Last_Index = 1 elsif Dynamic then Length = 0 elsif Length = 0 then First_Index > Last_Index else First_Index >= 1 and then Last_Index >= First_Index and then (Scalars.Wide (Last_Index) - Scalars.Wide (First_Index)) + 1 = Scalars.Wide (Length) and then Scalars.Wide (Last_Index) <= Scalars.Wide (Slot) * Scalars.Wide (Max_Source_Length));"

set_option maxRecDepth 10000
set_option maxHeartbeats 10000000

theorem candidate_checked : Checked lexicalCandidate profileCandidate where
  nameTree := nameState_checked
  boundsTree := by decide +kernel
  nameSpecification := by decide +kernel
  nameImplementation := by decide +kernel
  nameExpression := by decide +kernel
  boundsHeader := by decide +kernel
  boundsExpression := by decide +kernel

end Silver.ApplicationPackageFrames.ValidityTables.Primitives.Source
