module

public import Silver.ApplicationPackageMainIdentityImports
public import Silver.ComposeEquations

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions ApplicationPackageDeclarations

/-- The inherited equations are supplied by the existing composed source
interpretation. They are required on the exact native domain; no successful
Main parse or declaration-history restriction is assumed here. -/
structure DeclarationLibraries where
  identity : IdentityLibraries
  helpers : HelperEquations identity.boundary.names.shared.composed
    (domain := identity.boundary.names.shared.domain)

namespace DeclarationLibraries

def calls (library : DeclarationLibraries) (other : Calls) : Calls :=
  {library.identity.calls other with
    argumentAt := library.identity.boundary.names.shared.composed.function .argument
    readDeclarations := library.identity.boundary.names.shared.composed.function .readDeclarations}

def model (other : Calls) : Calls :=
  {IdentityLibraries.model other with
    argumentAt := Compose.argumentAt
    readDeclarations := Compose.declarationsAt}

theorem nativeState (library : DeclarationLibraries) {text : Source} {frame : ParserState}
    (valid : FunctionDeclarationNative.NativeValidState text frame) :
    NativeState library.identity.boundary.names.shared.domain text frame :=
  ⟨(library.identity.boundary.names.header.domain.state text frame).mpr valid, valid.bounds⟩

theorem argument (library : DeclarationLibraries) {text : Source} (valid : ValidText text)
    (frame : ParserState) (framed : FunctionDeclarationNative.NativeValidState text frame) :
    library.identity.boundary.names.shared.composed.function .argument text frame =
      Compose.argumentAt text frame :=
  interpreted_argument _ library.helpers text valid frame (library.nativeState framed)

theorem argument_domain (library : DeclarationLibraries) {text : Source} (valid : ValidText text)
    (frame : ParserState) (framed : FunctionDeclarationNative.NativeValidState text frame) :
    FunctionDeclarationNative.NativeValidState text (Compose.argumentAt text frame) := by
  have result := library.helpers.ranges.argument text valid frame (library.nativeState framed)
  rw [library.argument valid frame framed] at result
  exact (library.identity.boundary.names.header.domain.state text _).mp result.base

theorem declarations (library : DeclarationLibraries) {text : Source} (valid : ValidText text)
    (frame : ParserState) (arguments : Bool)
    (framed : FunctionDeclarationNative.NativeValidState text frame) :
    library.identity.boundary.names.shared.composed.function .readDeclarations text frame arguments =
      Compose.declarationsAt text frame arguments := by
  rw [library.helpers.readDeclarations text valid frame arguments (library.nativeState framed)]
  exact interpreted_declarations _ library.helpers text valid frame arguments (library.nativeState framed)

theorem declarations_domain (library : DeclarationLibraries) {text : Source} (valid : ValidText text)
    (frame : ParserState) (arguments : Bool)
    (framed : FunctionDeclarationNative.NativeValidState text frame) :
    FunctionDeclarationNative.NativeValidState text (Compose.declarationsAt text frame arguments) := by
  have result := library.helpers.ranges.declarations text valid frame arguments (library.nativeState framed)
  rw [interpreted_declarations _ library.helpers text valid frame arguments (library.nativeState framed)] at result
  exact (library.identity.boundary.names.header.domain.state text _).mp result.base

/-- Compose the optional original argument declaration with the complete
inherited declaration reader, including rejected/zero-position states. -/
theorem argument_declarations (library : DeclarationLibraries) {text : Source} (valid : ValidText text)
    (frame : ParserState) (arguments : Bool)
    (framed : FunctionDeclarationNative.NativeValidState text frame) :
    let actual := library.identity.boundary.names.shared.composed
    let after := if arguments then Compose.argumentAt text frame else frame
    actual.function .readDeclarations text
        (if arguments then actual.function .argument text frame else frame) arguments =
      Compose.declarationsAt text after arguments ∧
    FunctionDeclarationNative.NativeValidState text (Compose.declarationsAt text after arguments) := by
  dsimp only
  have after : FunctionDeclarationNative.NativeValidState text
      (if arguments then Compose.argumentAt text frame else frame) := by
    cases arguments
    · exact framed
    · exact library.argument_domain valid frame framed
  rw [library.argument valid frame framed]
  exact ⟨library.declarations valid _ arguments after,
    library.declarations_domain valid _ arguments after⟩

/-- The original begin-token call consumes the complete declaration result.
Its cursor domain follows from that result's full native contract. -/
theorem begin_token (library : DeclarationLibraries) {text : Source} (valid : ValidText text)
    (frame : ParserState) (arguments : Bool)
    (framed : FunctionDeclarationNative.NativeValidState text frame) :
    library.identity.boundary.names.shared.composed.function .takeToken text
      (Compose.declarationsAt text frame arguments).position (.word "begin") =
      tokenAfter text (Compose.declarationsAt text frame arguments).position (.word "begin") :=
  interpreted_take _ library.helpers.toRawHelperEquations text valid _ _
    (library.declarations_domain valid frame arguments framed).base.1 (by unfold ValidToken; decide)

end DeclarationLibraries
end Silver.ApplicationPackageMain
