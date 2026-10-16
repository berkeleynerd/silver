module

public import Silver.ImageModelDecodedNative

@[expose] public section
namespace Silver.ImageModel.NameNative
open DecodedNative (RawName)

inductive Test
  | bounded | length | contents
  deriving DecidableEq

def Test.eval (state : RawName) (name : List Nat) : Test → Bool
  | .bounded => decide (name.length ≤ 21)
  | .length => decide (state.length = name.length)
  | .contents => decide ((List.range state.length).map (fun i => state.buffer (i+1)) = name)

def Test.render : Test → List String
  | .bounded => ["name", "'", "length", "<=", "21"]
  | .length => ["current", ".", "string_length", "=", "name", "'", "length"]
  | .contents => ["current", ".", "string_prefix", "(", "1", "..", "current", ".", "string_length", ")", "=", "name"]

inductive Expression
  | test (value : Test) | andThen (left right : Expression)
  deriving DecidableEq

def Expression.eval (state : RawName) (name : List Nat) : Expression → Bool
  | .test value => value.eval state name
  | .andThen left right => left.eval state name && right.eval state name

def Expression.render : Expression → List String
  | .test value => value.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render

def body : Expression := .andThen (.andThen (.test .bounded) (.test .length)) (.test .contents)

theorem body_model (state : RawName) (name : List Nat) :
    body.eval state name = named state.observe name := by
  apply Bool.eq_iff_iff.mpr
  change ((decide (name.length ≤ 21) && decide (state.length = name.length)) &&
    decide ((List.range state.length).map (fun i => state.buffer (i+1)) = name)) = true ↔
    decide (name.length ≤ 21 ∧ state.length = name.length ∧
      (List.range (min state.length 21)).map (fun i => state.buffer (i+1)) = name) = true
  simp only [Bool.and_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨⟨bound, length⟩, contents⟩
    have short : state.length ≤ 21 := by omega
    exact ⟨bound, length, by simpa only [Nat.min_eq_left short] using contents⟩
  · rintro ⟨bound, length, contents⟩
    have short : state.length ≤ 21 := by omega
    exact ⟨⟨bound, length⟩, by simpa only [Nat.min_eq_left short] using contents⟩

theorem remember_fold_observe (input : List Nat) (state : RawName) :
    (input.foldl DecodedNative.remember state).observe =
      input.foldl rememberName state.observe := by
  induction input generalizing state with
  | nil => rfl
  | cons code tail ih =>
      simp only [List.foldl_cons, ih, DecodedNative.remember_observe]

/-- The initial prefix storage can contain anything: only bytes actually written
by Decoded participate in matching. Longer names cannot match a target. -/
theorem remembers_exact (input expected : List Nat) (buffer : Nat → Nat)
    (bounded : expected.length ≤ 21) (ascii : ∀ code ∈ expected, code < 127) :
    body.eval (input.foldl DecodedNative.remember ⟨0, buffer⟩) expected = true ↔ input = expected := by
  rw [body_model, remember_fold_observe]
  exact named_exact input expected bounded ascii

end Silver.ImageModel.NameNative
