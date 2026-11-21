module

public import Silver.PredicateConditionAdmission
public import Silver.ArrayBindingsMetadata

@[expose] public section

/-! The array actual is a single visible object or formal name. Its positive
nominal type identity is checked independently of the argument association.
The read does not inspect element values or change the caller's flow. -/
namespace Silver.Predicate
open Compose

def arrayTarget (text : Source) (context : ParseContext) (position : Nat) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if ScalarExpression.lookup text context.scalarNames first after ≠ 0 then 0
  else ArrayBindings.lookup text context.arrayNames first after

def arrayActualAfter (text : Source) (context : ParseContext) (position typeId : Nat) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  let target := arrayTarget text context position
  if typeId = 0 ∨ target = 0 ∨ (ArrayBindings.binding context.arrayNames target).typeId ≠ typeId
  then 0 else after

theorem arrayActualAfter_zero (text : Source) (context : ParseContext) (typeId : Nat) :
    arrayActualAfter text context 0 typeId = 0 := by
  simp [arrayActualAfter, skipAt, nameAfter]

theorem arrayTarget_bound (text : Source) (context : ParseContext) (position : Nat) :
    arrayTarget text context position ≤ context.arrayNames.length := by
  dsimp only [arrayTarget]
  split
  · exact Nat.zero_le _
  · exact ArrayBindings.lookup_bound ..

structure ArrayActualAt (text : Source) (context : ParseContext) (position typeId : Nat)
    (item : ArrayBindings.Binding) (after : Nat) : Prop where
  resolved : item = ArrayBindings.binding context.arrayNames (arrayTarget text context position)
  present : 0 < arrayTarget text context position
  nominal : 0 < typeId
  sameType : item.typeId = typeId
  source : ∃ spelling, Named.IdentifierAt text (skipAt text position) spelling after
  afterName : nameAfter text (skipAt text position) = after

theorem arrayActual_sound {text : Source} {context : ParseContext} {position typeId : Nat}
    (accepted : arrayActualAfter text context position typeId ≠ 0) :
    ArrayActualAt text context position typeId
      (ArrayBindings.binding context.arrayNames (arrayTarget text context position))
      (arrayActualAfter text context position typeId) := by
  dsimp only [arrayActualAfter] at accepted ⊢
  split at accepted
  · contradiction
  · rename_i allowed
    simp only [allowed, ↓reduceIte]
    have first : skipAt text position ≠ 0 := by
      intro absent
      simp [absent, nameAfter] at accepted
    have named : Named.identifierEnd text (skipAt text position) ≠ 0 := by
      simpa only [nameAfter, first, ↓reduceIte] using accepted
    exact ⟨rfl, by omega, by omega, by omega,
      by simpa only [nameAfter, first, ↓reduceIte] using Named.identifierEnd_sound _ _ named, rfl⟩

theorem ArrayActualAt.complete {text context position typeId item after}
    (reading : ArrayActualAt text context position typeId item after) :
    arrayActualAfter text context position typeId = after := by
  have found := reading.sameType
  rw [reading.resolved] at found
  simp [arrayActualAfter, Nat.ne_of_gt reading.nominal, Nat.ne_of_gt reading.present, found, reading.afterName]

theorem ArrayActualAt.cursorBounds {text context position typeId item after}
    (reading : ArrayActualAt text context position typeId item after) (bounded : position ≤ text.length + 1) :
    position < after ∧ after ≤ text.length + 1 := by
  obtain ⟨_, source⟩ := reading.source
  have bounds := Named.identifier_bounds source
  have first : skipAt text position ≠ 0 := by
    intro absent
    have afterZero : after = 0 := by simpa [absent, nameAfter] using reading.afterName.symm
    exact (Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) bounds.2.2.1)) afterZero
  have advances := skipAt_advances text position bounded first
  exact ⟨Nat.lt_of_le_of_lt advances bounds.2.2.1, bounds.2.2.2⟩

theorem ArrayActualAt.matches {text context position typeId item after} {types : ArrayBindings.TypeEnvironment}
    (reading : ArrayActualAt text context position typeId item after)
    (valid : ArrayBindings.ValidTable text ⟨context.arrayNames, types⟩) :
    ((ArrayBindings.arrayType types typeId).domain typeId).Matches typeId item.viewDescriptor := by
  have member : item ∈ context.arrayNames := reading.resolved ▸
    ArrayBindings.binding_mem reading.present (arrayTarget_bound ..)
  have coherent := (valid.member_valid member).2.2
  have named : item.typeId ≠ 0 := by rw [reading.sameType]; exact Nat.ne_of_gt reading.nominal
  obtain ⟨bounds, components⟩ := coherent.2 named
  rw [reading.sameType] at bounds components
  refine ⟨reading.nominal, rfl, ?_, ?_⟩
  · by_cases stored : item.viewSlot = 0 <;>
      simpa [ArrayBindings.Binding.viewDescriptor, stored, ArrayBindings.Binding.descriptor,
        ArrayBindings.ArrayType.domain] using bounds
  · by_cases stored : item.viewSlot = 0 <;>
      simpa [ArrayBindings.Binding.viewDescriptor, stored, ArrayBindings.Binding.descriptor,
        ArrayBindings.ArrayType.domain] using components

end Silver.Predicate
