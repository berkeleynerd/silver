module

public import Silver.ImageModelInsertion
public import Init.Data.List.Nat.TakeDrop

@[expose] public section
namespace Silver.ImageModel

/-- Zero-based reading of the native static Spliced_Prefix contract after both
fragments have been emitted. Original bytes and the two inserted spans are
specified independently, so the contract cannot conceal any rewritten byte. -/
structure SpliceObservations (original refined first second : List α) (a b : Nat) : Prop where
  output_length : refined.length = original.length + first.length + second.length
  original_read : ∀ i, i < original.length →
    refined[i + (if a ≤ i then first.length else 0) + (if b ≤ i then second.length else 0)]? = original[i]?
  first_span : ∀ i, i < first.length → refined[a+i]? = first[i]?
  second_span : ∀ i, i < second.length → refined[b+first.length+i]? = second[i]?

theorem observations_splice (original refined first second : List α) (a b : Nat)
    (ordered : a ≤ b) (bounded : b ≤ original.length)
    (observed : SpliceObservations original refined first second a b) :
    refined = splice original first second a b := by
  have length := observed.output_length
  have al : (original.take a).length = a := by simp [List.length_take, Nat.min_eq_left (by omega : a ≤ original.length)]
  have bl : ((original.drop a).take (b-a)).length = b-a := by
    simp [List.length_take, List.length_drop, Nat.min_eq_left (by omega : b-a ≤ original.length-a)]
  have shape : splice original first second a b =
      original.take a ++ (first ++ ((original.drop a).take (b-a) ++ (second ++ original.drop b))) := by
    simp only [splice, List.append_assoc]
  apply List.ext_getElem?
  intro i
  rw [shape]
  by_cases h0 : i < a
  · rw [List.getElem?_append_left (by omega), List.getElem?_take_of_lt h0]
    have h := observed.original_read i (by omega)
    simpa only [show ¬ a ≤ i by omega, show ¬ b ≤ i by omega, ↓reduceIte, Nat.add_zero] using h
  · rw [List.getElem?_append_right (by omega), al]
    by_cases h1 : i-a < first.length
    · rw [List.getElem?_append_left h1]
      simpa only [show a+(i-a)=i by omega] using observed.first_span (i-a) h1
    · rw [List.getElem?_append_right (by omega)]
      by_cases h2 : i-a-first.length < b-a
      · rw [List.getElem?_append_left (by omega), List.getElem?_take_of_lt h2, List.getElem?_drop]
        have h := observed.original_read (i-first.length) (by omega)
        simp only [show a ≤ i-first.length by omega, show ¬ b ≤ i-first.length by omega, ↓reduceIte, Nat.add_zero] at h
        simpa only [show i-first.length+first.length=i by omega, show a+(i-a-first.length)=i-first.length by omega] using h
      · rw [List.getElem?_append_right (by omega), bl]
        by_cases h3 : i-a-first.length-(b-a) < second.length
        · rw [List.getElem?_append_left h3]
          simpa only [show b+first.length+(i-a-first.length-(b-a))=i by omega] using observed.second_span (i-a-first.length-(b-a)) h3
        · rw [List.getElem?_append_right (by omega), List.getElem?_drop]
          by_cases h4 : i < refined.length
          · have h := observed.original_read (i-first.length-second.length) (by omega)
            simp only [show a ≤ i-first.length-second.length by omega, show b ≤ i-first.length-second.length by omega, ↓reduceIte] at h
            simpa only [show i-first.length-second.length+first.length+second.length=i by omega, show b+(i-a-first.length-(b-a)-second.length)=i-first.length-second.length by omega] using h
          · rw [List.getElem?_eq_none (by omega), List.getElem?_eq_none (by omega)]

end Silver.ImageModel
