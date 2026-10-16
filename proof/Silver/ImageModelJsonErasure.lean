module

public import Silver.ImageModelJsonNormalization

@[expose] public section
namespace Silver.ImageModel.JSON

def eraseAt (pending : Bool) (value : Value) : Value :=
  match value with
  | .number bytes => if pending then .number [48] else .number bytes
  | value => value.eraseNodeIds

def pendingAfter (previous : Bool) : Value → Bool
  | .string characters => previous && nodeTag characters
  | _ => false

def eraseElements (previous pending : Bool) : List Value → List Value
  | [] => []
  | value :: rest => eraseAt pending value :: eraseElements false (pendingAfter previous value) rest

theorem eraseAt_false (value : Value) : eraseAt false value = value.eraseNodeIds := by
  cases value <;> simp only [eraseAt, Bool.false_eq_true, ↓reduceIte, Value.eraseNodeIds]

theorem pendingAfter_false (value : Value) : pendingAfter false value = false := by
  cases value <;> simp [pendingAfter]

theorem eraseElements_rest (values : List Value) : eraseElements false false values = values.map Value.eraseNodeIds := by
  induction values with
  | nil => rfl
  | cons value rest ih => simp only [eraseElements, eraseAt_false, pendingAfter_false, ih, List.map_cons]

theorem eraseElements_next (pending : Bool) (value : Value) (rest : List Value) :
    eraseElements false pending (value :: rest) = eraseAt pending value :: rest.map Value.eraseNodeIds := by
  simp only [eraseElements, pendingAfter_false, eraseElements_rest]

/-- The independent flag-driven list normalization is precisely the established
whole-value node-ID erasure. It does not erase any other numeric position. -/
theorem eraseElements_array (values : List Value) :
    .array (eraseElements true false values) = (Value.array values).eraseNodeIds := by
  cases values with
  | nil => simp [eraseElements, Value.eraseNodeIds]
  | cons value rest =>
      cases value with
      | null | boolean | number | array | object =>
          simp [eraseElements, pendingAfter, eraseAt_false, eraseElements_rest, Value.eraseNodeIds]
      | string characters =>
          cases rest with
          | nil => simp [eraseElements, eraseAt_false, Value.eraseNodeIds]
          | cons value rest =>
              rw [eraseElements, eraseElements_next]
              cases value <;> simp [pendingAfter, eraseAt, Value.eraseNodeIds]
              split <;> rfl

theorem NormalValue.outgoing {previous pending outgoing : Bool} {value normalized : Value} {input : List Nat}
    (normal : NormalValue previous pending value input normalized outgoing) : outgoing = pendingAfter previous value := by
  cases normal <;> rfl

mutual
  /-- The grammar's normalized value is derived, rather than supplied as an
arbitrary schema premise: it is exactly node-ID erasure at this position. -/
  theorem NormalValue.erasure (previous pending outgoing : Bool) (value normalized : Value) (input : List Nat)
      (normal : NormalValue previous pending value input normalized outgoing) : normalized = eraseAt pending value := by
    cases normal with
    | null | true | false | number | id | string => simp [eraseAt, Value.eraseNodeIds]
    | array _ values normalized bytes entries =>
        rw [NormalElements.erasure true false values normalized bytes entries]
        exact eraseElements_array values
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem NormalElements.erasure (previous pending : Bool) (values normalized : List Value) (input : List Nat)
      (normal : NormalElements previous pending values input normalized) : normalized = eraseElements previous pending values := by
    cases normal with
    | empty => rfl
    | single _ _ value normalized leading bytes trailing _ item _ =>
        simp only [eraseElements, NormalValue.erasure previous pending false value normalized bytes item]
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest _ _ item _ tail =>
        rw [NormalValue.erasure previous pending outgoing value normalized bytes item,
          NormalElements.erasure false outgoing values restNormalized rest tail, item.outgoing]
        rfl
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

theorem NormalValue.eraseNodeIds {previous outgoing : Bool} {value normalized : Value} {input : List Nat}
    (normal : NormalValue previous Bool.false value input normalized outgoing) : normalized = value.eraseNodeIds :=
  (NormalValue.erasure previous Bool.false outgoing value normalized input normal).trans (eraseAt_false value)

end Silver.ImageModel.JSON
