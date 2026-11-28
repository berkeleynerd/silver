module

public import Silver.ApplicationPackageEffectsInterpretation
public import Silver.ApplicationPackageNamesMeaning
public import Silver.PredicateNativeState

@[expose] public section

namespace Silver.ApplicationPackageEffects
open Compose Compose.Expressions Predicate

/-- The two lookup requirements already contained in native Valid_Context. -/
structure LookupDomain (text : Source) (context : ParseContext) : Prop where
  scalars : ScalarExpression.ValidEnvironment text context.scalarNames
  booleans : BooleanBindings.ValidEnvironment text context.booleanNames

theorem LookupDomain.of_native {text : Source} {context : Predicate.Native.Context}
    (valid : Predicate.Native.ValidContext text context) : LookupDomain text context.model :=
  ⟨valid.2.2.1, valid.booleans⟩

/-- Imported meanings are restricted to the actual inherited helper domains.
In particular no metadata validity is required to inspect a possibly invalid
package state name; the executable valid-name guard supplies the lookup bounds. -/
structure PrimitiveMeaning (calls : Calls) : Prop where
  validName : ∀ text name, calls.validName text name = modelCalls.validName text name
  scalarLookup : ∀ text, ValidText text → ∀ names, ScalarExpression.ValidEnvironment text names →
    ∀ first after, first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.scalarLookup text names first after = modelCalls.scalarLookup text names first after
  booleanLookup : ∀ text, ValidText text → ∀ names, BooleanBindings.ValidEnvironment text names →
    ∀ first after, first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.booleanLookup text names first after = modelCalls.booleanLookup text names first after
  skip : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.skip text position = skipAt text position
  nameAfter : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.nameAfter text position = Compose.nameAfter text position
  lookupState : ∀ text info name, calls.lookupState text info name = modelCalls.lookupState text info name
  actualNameFree : ∀ text, ValidText text → ∀ first after targetFirst targetAfter,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    ValidName text targetFirst targetAfter →
    calls.actualNameFree text first after targetFirst targetAfter =
      modelCalls.actualNameFree text first after targetFirst targetAfter

theorem model_primitives : PrimitiveMeaning modelCalls where
  validName _ _ := rfl
  scalarLookup _ _ _ _ _ _ _ _ := rfl
  booleanLookup _ _ _ _ _ _ _ _ := rfl
  skip _ _ _ _ := rfl
  nameAfter _ _ _ _ := rfl
  lookupState _ _ _ := rfl
  actualNameFree _ _ _ _ _ _ _ _ _ := rfl

theorem visible_meaning (calls : Calls) (primitive : PrimitiveMeaning calls)
    (text : Source) (valid : ValidText text) (context : ParseContext)
    (domain : LookupDomain text context) (info : PackageBindings.Metadata) (index : Nat) :
    visibleState calls text context info index = visibleState modelCalls text context info index := by
  dsimp only [visibleState]
  rw [primitive.validName]
  by_cases rejected : index > info.states.length ∨ modelCalls.validName text (info.stateAt index).name = false
  · simp only [rejected, ↓reduceIte]
  · simp only [rejected, ↓reduceIte]
    have named : PackageBindings.validName (ApplicationPackageNames.metadataText text)
        (info.stateAt index).name = true := by
      simpa only [modelCalls, Bool.not_eq_false] using (not_or.mp rejected).2
    have nameDomain := (ApplicationPackageNames.Native.validName_domain named).2
    have firstBound : (info.stateAt index).name.first ≤ text.length + 1 :=
      Nat.le_trans (Nat.le_of_lt nameDomain.2.1) nameDomain.2.2
    rw [primitive.scalarLookup text valid _ domain.scalars _ _ firstBound nameDomain.2.2,
      primitive.booleanLookup text valid _ domain.booleans _ _ firstBound nameDomain.2.2]

theorem target_meaning (calls : Calls) (primitive : PrimitiveMeaning calls)
    (text : Source) (valid : ValidText text) (context : ParseContext)
    (domain : LookupDomain text context) (info : PackageBindings.Metadata)
    (position : Nat) (bounded : position ≤ text.length + 1) :
    stateTarget calls text context info position = stateTarget modelCalls text context info position := by
  dsimp only [stateTarget]
  rw [primitive.skip text valid position bounded,
    primitive.nameAfter text valid _ (model_skip_valid text position bounded),
    primitive.lookupState, visible_meaning calls primitive text valid context domain]
  rfl

theorem readStep_meaning (calls : Calls) (primitive : PrimitiveMeaning calls)
    (text : Source) (valid : ValidText text) (context : ParseContext)
    (domain : LookupDomain text context) (info : PackageBindings.Metadata)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (result : PackageBindings.StateSet) (index : Nat) :
    readStep calls text context info first after result index =
      readStep modelCalls text context info first after result index := by
  unfold readStep
  rw [visible_meaning calls primitive text valid context domain]
  by_cases visible : visibleState modelCalls text context info index = true
  · simp only [visible, ↓reduceIte]
    have named := (visibleState_guard visible).2
    have nameDomain := (ApplicationPackageNames.Native.validName_domain named).2
    rw [primitive.actualNameFree text valid _ _ _ _ firstBound afterBound nameDomain]
  · simp [visible]

theorem reads_meaning (calls : Calls) (primitive : PrimitiveMeaning calls)
    (text : Source) (valid : ValidText text) (context : ParseContext)
    (domain : LookupDomain text context) (info : PackageBindings.Metadata)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    stateReads calls text context info first after = stateReads modelCalls text context info first after := by
  have step : readStep calls text context info first after = readStep modelCalls text context info first after := by
    funext result index
    exact readStep_meaning calls primitive text valid context domain info first after firstBound afterBound result index
  unfold stateReads
  rw [step]

end Silver.ApplicationPackageEffects
