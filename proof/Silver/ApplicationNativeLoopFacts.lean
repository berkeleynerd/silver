module

public import Silver.ApplicationNativeCommands

@[expose] public section

namespace Silver.ApplicationNative

@[simp] theorem Locals.set_get_same (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) :
    (locals.set ty name value) ty name = value := by simp [Locals.set]

@[simp] theorem Locals.set_get_other_name (locals : Locals) (ty other : Ty)
    (name key : String) (value : ty.meaning) (different : key ≠ name) :
    (locals.set ty name value) other key = locals other key := by
  unfold Locals.set
  split <;> simp_all

@[simp] theorem Locals.set_get_other_type (locals : Locals) (ty other : Ty)
    (name key : String) (value : ty.meaning) (different : ty ≠ other) :
    (locals.set ty name value) other key = locals other key := by simp [Locals.set, different]

@[simp] theorem Locals.set_shadow (locals : Locals) (ty : Ty) (name : String)
    (first second : ty.meaning) :
    (locals.set ty name first).set ty name second = locals.set ty name second := by
  funext other key
  unfold Locals.set
  split <;> simp_all

@[simp] theorem Locals.set_unchanged (locals : Locals) (ty : Ty) (name : String) :
    locals.set ty name (locals ty name) = locals := by
  funext other key
  unfold Locals.set
  split
  · rename_i same
    subst other
    split <;> simp_all
  · rfl

theorem Locals.set_commute_types (locals : Locals) (a b : Ty) (first second : String)
    (x : a.meaning) (y : b.meaning) (different : a ≠ b) :
    (locals.set a first x).set b second y = (locals.set b second y).set a first x := by
  funext other key
  by_cases left : a = other
  · subst other
    simp [Locals.set, Ne.symm different]
  · by_cases right : b = other
    · subst other
      simp [Locals.set, different]
    · simp [Locals.set, left, right]

/-- Ordinary loop bodies with no return compose as a left fold. This lemma
does not postulate a body interpretation: every caller supplies its checked
body equation for every local environment and continuation. -/
theorem forValues_fold {resultType : Ty}
    (body : Locals → (Locals → resultType.meaning) → resultType.meaning)
    (step : Locals → Locals)
    (equation : ∀ locals next, body locals next = next (step locals))
    (name : String) (values : List Nat) (locals : Locals)
    (next : Locals → resultType.meaning) :
    forValues body name values locals next =
      next (values.foldl (fun current index => step (current.set .number name index)) locals) := by
  induction values generalizing locals with
  | nil => rfl
  | cons value rest ih =>
      rw [forValues, equation, ih]
      rfl

/-- A loop updating one parser frame preserves its metadata and any unrelated
local values. An index-insensitive continuation observes exactly the frame fold;
the native range-loop exit supplies such a continuation by restoring the index. -/
theorem forValues_state_fold {resultType : Ty}
    (body : Locals → (Locals → resultType.meaning) → resultType.meaning)
    (step : PackageBindings.Metadata → Nat → Compose.ParserState → Compose.ParserState)
    (name key infoName : String)
    (equation : ∀ locals next, body locals next = next
      (locals.set .state key (step (locals .metadata infoName) (locals .number name) (locals .state key))))
    (values : List Nat) (locals : Locals) (next : Locals → resultType.meaning)
    (stable : ∀ current index, next (current.set .number name index) = next current) :
    forValues body name values locals next =
      next (locals.set .state key (values.foldl
        (fun frame index => step (locals .metadata infoName) index frame) (locals .state key))) := by
  induction values generalizing locals with
  | nil => simp only [forValues, List.foldl_nil, Locals.set_unchanged]
  | cons value rest ih =>
      rw [forValues, equation, ih]
      simp only [Locals.set_get_same,
        Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.number ≠ Ty.state),
        Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.metadata),
        Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.number ≠ Ty.metadata),
        Locals.set_shadow, List.foldl_cons]
      rw [Locals.set_commute_types _ .number .state name key value _ (by decide), stable]

end Silver.ApplicationNative
