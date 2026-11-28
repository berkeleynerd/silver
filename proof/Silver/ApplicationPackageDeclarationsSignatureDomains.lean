module

public import Silver.ApplicationPackageDeclarationsSignatureImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

/-- A continuation frame supplied by the actual Signature entry. Failure has
no successor; both the parameter loop and zero-formal path retain Valid_State. -/
def SignatureStartFramed (text : Source) : SignatureStart → Prop
  | .returned _ => True
  | .ready state | .loop state => ReaderFrame text state.header

theorem signature_body_framed {text : Source} {outer : ParserState}
    (state : ReaderFrame text outer) (info : PackageBindings.Metadata)
    (first last identity : Nat) (item : PackageBindings.Routine) (formalStart : Nat)
    (span : ValidName text first last) :
    SignatureStartFramed text
      (startSignatureBody modelSignatureCalls text outer info first last identity item formalStart) := by
  have opened : ValidCursor text (tokenAfter text last (.symbol "(")) :=
    fixedAfter_result_bound text last "(" false (by decide)
  dsimp +instances only [startSignatureBody, modelSignatureCalls]
  split
  · exact state.header last span.2.2 true _
  · exact state.header _ opened true _

namespace NameLibraries

/-- The formal suffix's closing parenthesis and strict semicolon progress
check use their original lexical preconditions, including a zero cursor. -/
theorem signature_finish_formal (library : NameLibraries) (other : SignatureCalls)
    {text : Source} (valid : ValidText text) (before : Nat) (updated : SignatureState)
    (state : ReaderFrame text updated.header) :
    finishFormal (library.signature other) text before updated =
      finishFormal modelSignatureCalls text before updated := by
  have closed := interpreted_take _ library.shared.inherited text valid updated.header.position
    (.symbol ")") state.cursor (by unfold ValidToken; decide)
  have following := interpreted_take _ library.shared.inherited text valid updated.header.position
    (.symbol ";") state.cursor (by unfold ValidToken; decide)
  dsimp +instances only [finishFormal, signature, modelSignatureCalls]
  rw [closed, following]
  rfl

/-- The complete source-bound Valid_State predicate, rather than a successful
state assumption, is used at the end of the Signature reader. -/
def signatureValidity (library : NameLibraries) (append : SignatureCalls) : SignatureCalls :=
  library.signature {append with stateValid := fun text frame =>
    ApplicationPackageFrames.Native.frameCalls library.shared library.validity _ .validState text frame}

theorem signature_validity (library : NameLibraries) (append : SignatureCalls)
    {text : Source} (valid : ValidText text) (frame : ParserState)
    (typed : ValidityNative.ImportedTypes frame) :
    (library.signatureValidity append).stateValid text frame = stateValid text frame :=
  ApplicationPackageFrames.Native.frameCalls_valid library.shared library.validity text valid frame typed

/-- The actual type reader is invoked only on a cursor within the original
text and an existing ReaderFrame. No metadata-validity premise is needed. -/
theorem signature_type (library : NameLibraries) (other : SignatureCalls)
    {text : Source} (valid : ValidText text) (frame : ParserState)
    (state : ReaderFrame text frame) (info : PackageBindings.Metadata)
    (position : Nat) (cursor : ValidCursor text position) :
    (library.signature other).typeAt text frame info position = packageTypeAt text frame info position :=
  (ApplicationPackageNames.Native.imported_readers library.shared library.header).typeAt
    text valid frame state.typed state.valid info position cursor

end NameLibraries
end Silver.ApplicationPackageDeclarations
