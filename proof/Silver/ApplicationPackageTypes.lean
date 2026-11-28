module

public import Silver.PackageBindings
public import Silver.PredicateProcedureCallAdmission

@[expose] public section

/-! Native application scanner values shared by calls and statement bodies.
The existing BodyScan representation stores the Ada Count discriminant in its
flow count. Application values preserve that same count, without imposing any
extra source, metadata or safety condition on the represented native fields.
Fixed-capacity effect arrays retain their complete bit domain. -/
namespace Silver.ApplicationPackages

structure ApplicationScan where
  scan : Predicate.BodyScan
  allowProcedureCalls : Bool := true
  reads : PackageBindings.StateSet := PackageBindings.emptyStateSet
  writes : PackageBindings.StateSet := PackageBindings.emptyStateSet
  deriving DecidableEq, Repr

def ApplicationScan.count (value : ApplicationScan) : Nat := value.scan.count

def applicationOf (scan : Predicate.BodyScan) : ApplicationScan := {scan}

def invalidApplication (value : ApplicationScan) : ApplicationScan :=
  {value with scan := Predicate.invalidBody value.scan}

structure PackageActual where
  first : Nat := 0
  after : Nat := 0
  target : Predicate.ProcedureActualResult := Predicate.invalidProcedureActual
  reads : PackageBindings.StateSet := PackageBindings.emptyStateSet
  writtenState : Nat := 0
  deriving DecidableEq, Repr

structure ApplicationCall where
  value : Predicate.CallResult := Predicate.invalidCall
  result : ApplicationScan
  deriving DecidableEq, Repr

def ApplicationCall.count (value : ApplicationCall) : Nat := value.result.count

@[simp] theorem applicationOf_count (scan : Predicate.BodyScan) :
    (applicationOf scan).count = scan.count := rfl

@[simp] theorem invalidApplication_count (value : ApplicationScan) :
    (invalidApplication value).count = value.count := rfl

@[simp] theorem invalidApplication_calls (value : ApplicationScan) :
    (invalidApplication value).allowProcedureCalls = value.allowProcedureCalls := rfl

@[simp] theorem invalidApplication_reads (value : ApplicationScan) :
    (invalidApplication value).reads = value.reads := rfl

@[simp] theorem invalidApplication_writes (value : ApplicationScan) :
    (invalidApplication value).writes = value.writes := rfl

@[simp] theorem invalidApplication_position (value : ApplicationScan) :
    (invalidApplication value).scan.position = 0 := rfl

end Silver.ApplicationPackages
