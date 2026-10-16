module

public import Silver.IntegerExpressions

@[expose] public section

/-! Immutable Integer declarations, initialized in source order. Scalar ids
are one-based and independent of the String store. Source name checking owns
the single Ada namespace and rejects cross-type reads before this layer. -/

namespace Silver.Integer

abbrev Constants := List Int

def Constants.get (constants : Constants) (index : Nat) : Option Int :=
  if index = 0 then none else constants[index - 1]?

def Constants.ranges (constants : Constants) : Ranges :=
  fun index => (constants.get index).map Interval.singleton

def Constants.store (constants : Constants) : Store :=
  fun index => (constants.get index).getD 0

def Constants.Valid (constants : Constants) : Prop := ∀ value ∈ constants, InRange value

theorem Constants.fits (constants : Constants) : Fits constants.ranges constants.store := by
  intro index bounds found
  simp only [ranges, Option.map_eq_some_iff] at found
  obtain ⟨value, present, rfl⟩ := found
  simp only [store, present, Option.getD_some, Interval.singleton_contains]

structure Declaration where
  value : Expr
  deriving DecidableEq, Repr

def Declaration.check (constants : Constants) (declaration : Declaration) : Option Constants :=
  (declaration.value.infer constants.ranges).bind fun bounds =>
    if bounds.lower = bounds.upper then some (constants ++ [bounds.lower]) else none

def Declaration.execute (constants : Constants) (declaration : Declaration) : Constants :=
  constants ++ [declaration.value.evaluate constants.store]

def checkDeclarations : Constants → List Declaration → Option Constants
  | constants, [] => some constants
  | constants, declaration :: rest => (declaration.check constants).bind fun next => checkDeclarations next rest

def executeDeclarations : Constants → List Declaration → Constants
  | constants, [] => constants
  | constants, declaration :: rest => executeDeclarations (declaration.execute constants) rest

def DeclarationsSafe : Constants → List Declaration → Prop
  | _, [] => True
  | constants, declaration :: rest => declaration.value.Safe constants.store ∧
      DeclarationsSafe (declaration.execute constants) rest

theorem Declaration.check_sound {constants next : Constants} {declaration : Declaration}
    (checked : declaration.check constants = some next) :
    next = declaration.execute constants ∧ declaration.value.Safe constants.store ∧
      InRange (declaration.value.evaluate constants.store) := by
  simp only [check, Option.bind_eq_some_iff] at checked
  obtain ⟨bounds, inferred, tail⟩ := checked
  split at tail
  · rename_i singleton
    have sound := Expr.infer_sound inferred constants.fits
    have same : bounds.lower = declaration.value.evaluate constants.store := by
      simp only [Interval.Contains] at sound
      omega
    simp only [Option.some.injEq] at tail
    exact ⟨by simpa only [execute, same] using tail.symm, sound.2, Expr.safe_value sound.2⟩
  · contradiction

theorem Declaration.check_preserves {constants next : Constants} {declaration : Declaration}
    (valid : constants.Valid) (checked : declaration.check constants = some next) : next.Valid := by
  obtain ⟨rfl, _, range⟩ := check_sound checked
  intro value present
  rcases List.mem_append.mp present with earlier | last
  · exact valid value earlier
  · have same := List.mem_singleton.mp last
    simpa only [same] using range

theorem declarations_sound {constants next : Constants} {declarations : List Declaration}
    (checked : checkDeclarations constants declarations = some next) :
    next = executeDeclarations constants declarations ∧ DeclarationsSafe constants declarations := by
  induction declarations generalizing constants with
  | nil => simp only [checkDeclarations, Option.some.injEq] at checked; exact ⟨checked.symm, trivial⟩
  | cons declaration rest ih =>
      simp only [checkDeclarations, Option.bind_eq_some_iff] at checked
      obtain ⟨middle, first, restChecked⟩ := checked
      obtain ⟨same, safe, _⟩ := Declaration.check_sound first
      obtain ⟨result, restSafe⟩ := ih restChecked
      exact ⟨by simpa only [executeDeclarations, same] using result,
        safe, by simpa only [same] using restSafe⟩

theorem declarations_preserve {constants next : Constants} {declarations : List Declaration}
    (valid : constants.Valid) (checked : checkDeclarations constants declarations = some next) : next.Valid := by
  induction declarations generalizing constants with
  | nil => simp only [checkDeclarations, Option.some.injEq] at checked; simpa only [← checked] using valid
  | cons declaration rest ih =>
      simp only [checkDeclarations, Option.bind_eq_some_iff] at checked
      obtain ⟨middle, first, restChecked⟩ := checked
      exact ih (Declaration.check_preserves valid first) restChecked

theorem declarations_length {constants next : Constants} {declarations : List Declaration}
    (checked : checkDeclarations constants declarations = some next) :
    next.length = constants.length + declarations.length := by
  induction declarations generalizing constants with
  | nil => simp_all [checkDeclarations]
  | cons declaration rest ih =>
      simp only [checkDeclarations, Option.bind_eq_some_iff] at checked
      obtain ⟨middle, first, restChecked⟩ := checked
      have same := (Declaration.check_sound first).1
      simpa only [same, Declaration.execute, List.length_append, List.length_singleton,
        List.length_cons, List.length_nil, Nat.zero_add, Nat.add_assoc, Nat.add_comm 1] using ih restChecked

end Silver.Integer
