module

public import Silver.ImageModelMatcher

@[expose] public section
namespace Silver.ImageModel

/-- The native recognizer retains at most 21 decoded characters and saturates
its length at 22, which distinguishes every longer String from the targets. -/
structure NameState where
  length : Nat := 0
  characters : List Nat := []
  deriving DecidableEq

def nameByte (code : Nat) : Nat := if code ≤ 127 then code else 127

def rememberName (state : NameState) (code : Nat) : NameState :=
  if state.length < 22 then
    let length := state.length + 1
    ⟨length, if length ≤ 21 then state.characters ++ [nameByte code] else state.characters⟩
  else state

def nameObservation (input : List Nat) : NameState :=
  ⟨min input.length 22, (input.take 21).map nameByte⟩

theorem remember_observation (input : List Nat) (code : Nat) :
    rememberName (nameObservation input) code = nameObservation (input ++ [code]) := by
  by_cases short : input.length < 21
  · have lt22 : input.length < 22 := by omega
    simp [rememberName, nameObservation, Nat.min_eq_left (by omega : input.length ≤ 22),
      Nat.min_eq_left (by omega : input.length + 1 ≤ 22), lt22,
      List.take_of_length_le (by omega : input.length ≤ 21),
      List.take_of_length_le (by simp; omega : (input ++ [code]).length ≤ 21), show input.length + 1 ≤ 21 by omega]
  · have long : 21 ≤ input.length := by omega
    have prefixEq : (input ++ [code]).take 21 = input.take 21 := List.take_append_of_le_length long
    by_cases next : input.length = 21
    · simp [rememberName, nameObservation, next, prefixEq]
    · have saturated : 22 ≤ input.length := by omega
      simp [rememberName, nameObservation, Nat.min_eq_right saturated, prefixEq,
        Nat.min_eq_right (show 22 ≤ input.length + 1 by omega)]

theorem remember_fold (input : List Nat) (state : NameState) (before : List Nat)
    (initial : state = nameObservation before) :
    input.foldl rememberName state = nameObservation (before ++ input) := by
  induction input generalizing state before with
  | nil => simpa using initial
  | cons code tail ih =>
      rw [List.foldl_cons]
      have step : rememberName state code = nameObservation (before ++ [code]) := by
        rw [initial, remember_observation]
      simpa only [List.append_assoc, List.cons_append, List.nil_append] using ih _ _ step

def named (state : NameState) (name : List Nat) : Bool :=
  decide (name.length ≤ 21 ∧ state.length = name.length ∧ state.characters = name)

theorem nameByte_exact {code expected : Nat} (ascii : expected < 127) :
    nameByte code = expected ↔ code = expected := by
  unfold nameByte
  split <;> simp_all <;> omega

theorem map_names_exact (input expected : List Nat) (ascii : ∀ code ∈ expected, code < 127) :
    input.map nameByte = expected ↔ input = expected := by
  induction expected generalizing input with
  | nil => simp
  | cons code rest ih =>
      cases input with
      | nil => simp
      | cons head tail =>
          have bound := ascii code (by simp)
          have restBound : ∀ item ∈ rest, item < 127 := by intro item member; exact ascii item (by simp [member])
          simp only [List.map_cons, List.cons.injEq, nameByte_exact bound, ih tail restBound]

theorem named_exact (input expected : List Nat) (bounded : expected.length ≤ 21)
    (ascii : ∀ code ∈ expected, code < 127) :
    named (input.foldl rememberName {}) expected = true ↔ input = expected := by
  have folded := remember_fold input {} [] rfl
  simp only [List.nil_append] at folded
  rw [folded]
  change (decide (expected.length ≤ 21 ∧ min input.length 22 = expected.length ∧
    (input.take 21).map nameByte = expected) = true) ↔ input = expected
  rw [decide_eq_true_eq]
  constructor
  · rintro ⟨_, length, characters⟩
    have small : input.length ≤ 21 := by omega
    rw [List.take_of_length_le small] at characters
    exact (map_names_exact input expected ascii).mp characters
  · intro equal
    subst input
    exact ⟨bounded, Nat.min_eq_left (by omega), by
      rw [List.take_of_length_le bounded]
      exact (map_names_exact expected expected ascii).mpr rfl⟩

end Silver.ImageModel
