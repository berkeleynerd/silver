module

public import Silver.ApplicationPackageSpelling

@[expose] public section

namespace Silver.ApplicationPackageSpelling.SourceChecks
open Silver.SourceBridge

def header : List String := expectedTokens
  "(Text : String; Info : Packages.Metadata; Word : String) return Boolean with Global => null"

def candidateTokens : List String := expectedTokens
  "   function Same_Package_Spelling\n     (Text : String; Info : Packages.Metadata; Word : String) return Boolean\n     with Global => null\n   is\n   begin\n      if not Packages.Valid_Name (Text, (Info.Name_First, Info.Name_After))\n        or else Word'Length /= Info.Name_After - Info.Name_First\n      then return False; end if;\n      for I in Word'Range loop\n         if Lowercase (Word (I)) /= Lowercase (Text (Info.Name_First + (I - Word'First))) then return False; end if;\n      end loop;\n      return True;\n   end Same_Package_Spelling;"

structure Checked (tokens : List String) : Prop where
  tree : CheckedTree
  header : functionHeader "same_package_spelling" "is" tokens = some header
  body : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "same_package_spelling" tokens = some bodyTokens

theorem candidate_checked : Checked candidateTokens where
  tree := checked_tree
  header := by decide +kernel
  body := by decide +kernel

end Silver.ApplicationPackageSpelling.SourceChecks
