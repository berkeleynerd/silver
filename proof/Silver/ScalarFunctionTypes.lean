module

public import Silver.IntegerMutable
public import Silver.BooleanModel
public import Silver.NamedArrayParameters

@[expose] public section

/-! Functions retain scalar results. Input domains also include named
constrained Integer arrays, identified by their type declarations. -/
namespace Silver.ScalarFunctions

inductive ScalarType
  | integer (bounds : Integer.Interval)
  | boolean
  | array (domain : NamedArrayParameters.Domain)
  deriving DecidableEq, Repr

inductive Value
  | integer (value : Int)
  | boolean (value : Bool)
  | array (argument : NamedArrayParameters.Argument)
  deriving DecidableEq, Repr

def ScalarType.Valid : ScalarType → Prop
  | .integer bounds => bounds.Bounded ∧ bounds.lower ≤ bounds.upper
  | .boolean => True
  | .array domain => domain.Valid

def ScalarType.IsScalar : ScalarType → Prop
  | .integer _ | .boolean => True
  | .array _ => False

def ScalarType.Contains : ScalarType → Value → Prop
  | .integer bounds, .integer value => bounds.Contains value
  | .boolean, .boolean _ => True
  | .array domain, .array argument => domain.Contains argument
  | _, _ => False

instance (domain : ScalarType) (value : Value) : Decidable (domain.Contains value) := by
  cases domain <;> cases value <;> simp only [ScalarType.Contains] <;> infer_instance

def ScalarType.contains (domain : ScalarType) (value : Value) : Bool :=
  decide (domain.Contains value)

@[simp] theorem ScalarType.contains_iff (domain : ScalarType) (value : Value) :
    domain.contains value = true ↔ domain.Contains value := by
  simp [contains]

structure Signature where
  formals : List ScalarType
  result : ScalarType
  deriving DecidableEq, Repr

def Signature.Valid (signature : Signature) : Prop :=
  signature.formals ≠ [] ∧ (∀ domain ∈ signature.formals, domain.Valid) ∧
    signature.result.Valid ∧ signature.result.IsScalar

def ArgumentsFit : List ScalarType → List Value → Prop
  | [], [] => True
  | formal :: formals, value :: values => formal.Contains value ∧ ArgumentsFit formals values
  | _, _ => False

def checkArguments : List ScalarType → List Value → Bool
  | [], [] => true
  | formal :: formals, value :: values => formal.contains value && checkArguments formals values
  | _, _ => false

theorem checkArguments_iff (formals : List ScalarType) (values : List Value) :
    checkArguments formals values = true ↔ ArgumentsFit formals values := by
  induction formals generalizing values with
  | nil => cases values <;> simp [checkArguments, ArgumentsFit]
  | cons formal formals ih =>
      cases values <;> simp [checkArguments, ArgumentsFit, ih]

theorem ArgumentsFit.length_eq {formals : List ScalarType} {values : List Value}
    (fits : ArgumentsFit formals values) : formals.length = values.length := by
  induction formals generalizing values with
  | nil => cases values <;> simp_all [ArgumentsFit]
  | cons formal formals ih =>
      cases values with
      | nil => contradiction
      | cons value values => exact congrArg Nat.succ (ih fits.2)

abbrev Signatures := List Signature

/-- Native callable identities start at one. Zero never resolves. -/
def lookup (signatures : Signatures) (identity : Nat) : Option Signature :=
  if identity = 0 then none else signatures[identity - 1]?

abbrev CallValues := Nat → List Value → Value

/-- This is the result-containment part of the function induction. It is not
an assumption of callee safety or termination; those must be established from
each checked body when constructing the actual evaluator. -/
def ResultsFit (signatures : Signatures) (calls : CallValues) : Prop :=
  ∀ identity signature, lookup signatures identity = some signature →
    ∀ values, ArgumentsFit signature.formals values → signature.result.Contains (calls identity values)

theorem lookup_empty (identity : Nat) : lookup [] identity = none := by
  simp [lookup]

theorem lookup_nonzero {signatures : Signatures} {identity : Nat} {signature : Signature}
    (found : lookup signatures identity = some signature) : identity ≠ 0 := by
  intro zero
  simp [lookup, zero] at found

theorem lookup_append_old {signatures : Signatures} {identity : Nat} {signature : Signature}
    (found : lookup signatures identity = some signature) (next : Signature) :
    lookup (signatures ++ [next]) identity = some signature := by
  have positive := lookup_nonzero found
  simp only [lookup, positive, ↓reduceIte] at found ⊢
  have inside : identity - 1 < signatures.length := by
    exact List.getElem?_eq_some_iff.mp found |>.1
  rw [List.getElem?_append_left inside, found]

theorem lookup_append_new (signatures : Signatures) (next : Signature) :
    lookup (signatures ++ [next]) (signatures.length + 1) = some next := by
  simp [lookup]

/-- A computational callable table. The definition fold constructs it without
an admission proof; soundness separately establishes Environment.Valid. -/
structure Environment where
  signatures : Signatures
  values : CallValues

def Environment.empty : Environment where
  signatures := []
  values := fun _ _ => .integer 0

def Environment.Valid (environment : Environment) : Prop :=
  ResultsFit environment.signatures environment.values

theorem Environment.empty_valid : Environment.empty.Valid := by
  intro identity signature found
  simp [Environment.empty, lookup_empty] at found

end Silver.ScalarFunctions
