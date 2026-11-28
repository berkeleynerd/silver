module

public import Silver.ApplicationPackageDeclarationDomains
public import Silver.ComposeHelperEquations

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageFrames ApplicationPackageNames

/-- Source interpretations used by the name and shadowing calls shared by
the package declaration readers. The inherited header fixes the state domain. -/
structure NameLibraries where
  shared : ApplicationPackageImports.Imports
  header : ApplicationPackageNames.Native.HeaderLibrary shared
  validity : ValidityNative.Imports

namespace NameLibraries

theorem composed_state (library : NameLibraries) {text frame} (state : ReaderFrame text frame) :
    NativeState library.shared.domain text frame :=
  ⟨(library.header.domain.state text frame).mpr state.native, state.native.bounds⟩

def hideOuter (library : NameLibraries) (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) : ParserState :=
  ApplicationPackageFrames.Native.hideOuterBody.eval
    (ApplicationPackageFrames.Native.frameCalls library.shared library.validity)
    ({text, frame, info, name} : ApplicationPackageNames.Native.Inputs).locals

theorem hide_outer (library : NameLibraries) {text frame} (valid : ValidText text) (state : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) (span : ValidName text name.first name.after) :
    library.hideOuter text frame info name = ApplicationPackageFrames.hideOuter text frame info name :=
  ApplicationPackageFrames.Native.hideOuter_imports library.shared library.validity
    ({text, frame, info, name} : ApplicationPackageNames.Native.Inputs).locals
    valid state.valid (state.imported_types valid) span

def object (library : NameLibraries) (other : ObjectCalls) : ObjectCalls :=
  {other with
    skip := library.shared.composed.function .skip
    nameAfter := library.shared.composed.function .nameAfter
    take := library.shared.composed.function .takeToken
    validName := fun text => library.shared.packages.validName (metadataText text)
    hideOuter := library.hideOuter
    fresh := ApplicationPackageNames.Native.freshName library.header.names
    newName := library.shared.composed.function .newName
    hide := ApplicationPackageFrames.Native.importedHideName library.shared}

end NameLibraries

/-- The actual successful Object name guard supplies the later call domains.
Hide_Outer can return the invalid frame. The suffix tests its zero cursor
before making any type or initializer call. -/
structure ObjectNameDomain (text : Source) (first last colonEnd constantEnd : Nat) (result : ObjectResult) : Prop where
  span : ValidName text first last
  name : result.name = ⟨first,last⟩
  colon : ValidCursor text colonEnd
  qualifier : ValidCursor text constantEnd
  frame : result.frame.position ≠ 0 → ReaderFrame text result.frame

/-- Interpret the entire Object name prefix against the real imported lexical,
metadata, freshness, visibility and shadowing readers. Its two continuations
need agree only on the original native calls that can actually reach them. -/
theorem objectNameStep_imports (library : NameLibraries) (other : ObjectCalls) (reader : BooleanElaboration.Native.Reader)
    (text : Source) (valid : ValidText text) (frame : ParserState) (state : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (localObject : Bool) (actual model : ObjectContinuation)
    (next : ∀ first last colon constant seed, ObjectNameDomain text first last colon constant seed →
      actual text frame info first last colon constant localObject seed =
        model text frame info first last colon constant localObject seed) :
    objectNameStep (library.object other) text frame info localObject actual =
      objectNameStep (modelObjectCalls reader) text frame info localObject model := by
  let first := skipAt text frame.position
  let last := nameAfter text first
  let name : PackageBindings.NameSpan := ⟨first,last⟩
  let colon := fixedAfter text last ":" false
  let constant := fixedAfter text colon "constant" true
  have firstBound := model_skip_valid text _ state.cursor
  have lastBound := model_name_valid text first
  have colonBound := model_fixed_valid text last ":" false lastBound
  have constantBound := model_fixed_valid text colon "constant" true colonBound
  have skipped : library.shared.composed.function .skip text frame.position = first :=
    interpreted_skip _ library.shared.inherited text valid _ state.cursor
  have identifier : library.shared.composed.function .nameAfter text first = last :=
    interpreted_name _ library.shared.inherited text valid _ firstBound
  have colonEq : library.shared.composed.function .takeToken text last (.symbol ":") = colon :=
    interpreted_take _ library.shared.inherited text valid _ _ lastBound (by unfold ValidToken; decide)
  have constantEq : library.shared.composed.function .takeToken text colon (.word "constant") = constant :=
    interpreted_take _ library.shared.inherited text valid _ _ colonBound (by unfold ValidToken; decide)
  have declared := PackageBindings.Native.interpreted_validName library.shared.packages
    library.shared.packagePrimitives library.shared.packageEquations (metadataText text) ⟨first,last⟩
  dsimp only [objectNameStep, NameLibraries.object, modelObjectCalls]
  simp only [skipped, identifier, colonEq, constantEq, declared]
  change (if !PackageBindings.validName (metadataText text) name || decide (colon = 0) then invalidObject else _) =
    (if !PackageBindings.validName (metadataText text) name || decide (colon = 0) then invalidObject else _)
  by_cases invalid : (!PackageBindings.validName (metadataText text) name || decide (colon = 0)) = true
  · rw [ite_eq_left invalid, ite_eq_left invalid]
  · rw [ite_eq_right invalid, ite_eq_right invalid]
    have found : PackageBindings.validName (metadataText text) name = true :=
      Bool.of_not_eq_false (fun bad => invalid (by simp [bad]))
    have span := (ApplicationPackageNames.Native.validName_domain found).2
    cases localObject with
    | true =>
      simp only [↓reduceIte]
      rw [library.hide_outer valid state info name span]
      exact next _ _ _ _ _ ⟨span, rfl, colonBound, constantBound, fun present => state.hide_outer info name present⟩
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      rw [(ApplicationPackageNames.Native.imported_readers library.shared library.header).fresh text info name,
        interpreted_newName _ library.shared.inherited text valid frame first last false (library.composed_state state)
          firstBound lastBound]
      by_cases fresh : (packageNameFresh text info name && newNameAllowed text frame first last false) = true
      · rw [ite_eq_left fresh, ite_eq_left fresh, ApplicationPackageFrames.Native.importedHideName_meaning
            library.shared text valid frame.hiding first last span]
        exact next _ _ _ _ _ ⟨span, rfl, colonBound, constantBound, fun _ => state.hidden_name _⟩
      · rw [ite_eq_right fresh, ite_eq_right fresh]

end Silver.ApplicationPackageDeclarations
