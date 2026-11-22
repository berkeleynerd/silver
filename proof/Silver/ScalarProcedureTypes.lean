module

public import Silver.ScalarFunctionTypes

@[expose] public section

/-! Procedure interfaces distinguish immutable scalar or array inputs from
scalar writable formals. An `out` formal has no incoming value. -/
namespace Silver.ScalarProcedures
open ScalarFunctions (ScalarType Value ArgumentsFit)

inductive Mode
  | input | output | inputOutput
  deriving DecidableEq, Repr

structure Formal where
  mode : Mode
  domain : ScalarType
  deriving DecidableEq, Repr

structure Signature where
  formals : List Formal
  deriving DecidableEq, Repr

def inputTypes : List Formal → List ScalarType
  | [] => []
  | ⟨.output, _⟩ :: rest => inputTypes rest
  | formal :: rest => formal.domain :: inputTypes rest

def outputTypes : List Formal → List ScalarType
  | [] => []
  | ⟨.input, _⟩ :: rest => outputTypes rest
  | formal :: rest => formal.domain :: outputTypes rest

/-- Leading assignments initialize exactly these formals, in declaration order. -/
def outTypes : List Formal → List ScalarType
  | [] => []
  | ⟨.output, domain⟩ :: rest => domain :: outTypes rest
  | _ :: rest => outTypes rest

/-- Package procedures may have no explicit inputs or outputs. Captured state
is supplied separately; local source grammar can impose stricter arities. -/
def Signature.Valid (signature : Signature) : Prop :=
  ∀ formal ∈ signature.formals, formal.domain.Valid ∧
    (formal.mode = .input ∨ formal.domain.IsScalar)

abbrev Signatures := List Signature

/-- Identities agree with the separate native procedure table: one-based, with zero invalid. -/
def lookup (signatures : Signatures) (identity : Nat) : Option Signature :=
  if identity = 0 then none else signatures[identity - 1]?

abbrev CallValues := Nat → List Value → List Value

/-- This is the exported domain theorem, proved when constructing each earlier-prefix
environment. It is not a substitute for body safety or automatic obligation discharge. -/
def ResultsFit (signatures : Signatures) (calls : CallValues) : Prop :=
  ∀ identity signature, lookup signatures identity = some signature →
    ∀ inputs, ArgumentsFit (inputTypes signature.formals) inputs →
      ArgumentsFit (outputTypes signature.formals) (calls identity inputs)

structure Environment where
  signatures : Signatures
  values : CallValues

def Environment.empty : Environment := ⟨[], fun _ _ => []⟩

def Environment.Valid (environment : Environment) : Prop :=
  ResultsFit environment.signatures environment.values

@[simp] theorem lookup_empty (identity : Nat) : lookup [] identity = none := by
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
  have inside : identity - 1 < signatures.length := (List.getElem?_eq_some_iff.mp found).1
  rw [List.getElem?_append_left inside, found]

theorem lookup_append_new (signatures : Signatures) (next : Signature) :
    lookup (signatures ++ [next]) (signatures.length + 1) = some next := by
  simp [lookup]

theorem Environment.empty_valid : Environment.empty.Valid := by
  intro identity signature found
  simp [Environment.empty, lookup_empty] at found

end Silver.ScalarProcedures
