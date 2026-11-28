module

public import Silver.ApplicationPackageNames
public import Silver.ApplicationAdmissionModel

@[expose] public section

/-! Exact value records for the package declaration readers. Failure does not
roll back in-out metadata: SignatureResult preserves the metadata at the actual
return point independently of its possibly invalid header. -/
namespace Silver.ApplicationPackageDeclarations
open Compose

structure ObjectResult where
  frame : ParserState := invalidState
  name : PackageBindings.NameSpan := {}
  mark : ApplicationPackageNames.PackageTypeResult := {}
  initFirst : Nat := 0
  initAfter : Nat := 0
  initialBounds : Integer.Interval := .empty
  constantObject : Bool := false
  booleanValue : Bool := false
  deriving DecidableEq, Repr

def invalidObject : ObjectResult := {}

structure SignatureResult where
  info : PackageBindings.Metadata
  header : ParserState := invalidState

abbrev SpecificationResult := ApplicationAdmission.SpecificationResult

end Silver.ApplicationPackageDeclarations
