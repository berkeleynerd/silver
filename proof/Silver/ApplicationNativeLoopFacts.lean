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

end Silver.ApplicationNative
