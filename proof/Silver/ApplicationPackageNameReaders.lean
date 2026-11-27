module

public import Silver.ApplicationPackageNamesTypeImports
public import Silver.ApplicationPackageFrameValidity
public import Silver.FunctionDeclarationStateRecords

@[expose] public section
namespace Silver.ApplicationPackageNames.Native
open Compose

/-- Source interpretations used by the actual Function_Type_At called from
Package_Type_At. These links identify the inherited header and its native callees. -/
structure HeaderLibrary (imports : ApplicationPackageImports.Imports) where
  calls : FunctionDeclarationNative.Calls
  metadata : FunctionBindings.Native.Calls
  visibility : FunctionVisibilityNative.Implementation
  equations : FunctionDeclarationNative.HeaderEquations calls
  domain : FunctionDeclarationNative.ExactDomain imports.domain
  functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata
  primitives : FunctionVisibilityNative.Primitives visibility.calls
  visibilitySource : FunctionVisibilityNative.Equations visibility
  links : FunctionDeclarationNative.HeaderLinks calls imports.composed metadata visibility

def HeaderLibrary.names {imports} (header : HeaderLibrary imports) : Calls :=
  importedCalls imports (header.calls .functionType)

def readWord (calls : Calls) (source : Source) (position : Nat) (word : String) : Nat :=
  packageWordBody.eval calls.get ({text := source, position, word} : Inputs).locals

def readPragma (calls : Calls) (source : Source) (position : Nat) : Nat :=
  sparkPragmaBody.eval calls.get ({text := source, position} : Inputs).locals

def allowedName (calls : Calls) (source : Source) (name : PackageBindings.NameSpan) : Bool :=
  nameAllowedBody.eval calls.get ({text := source, name} : Inputs).locals

def freshName (calls : Calls) (source : Source) (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) : Bool :=
  nameFreshBody.eval calls.get ({text := source, info, name} : Inputs).locals

def outerName (calls : Calls) (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) : Bool :=
  outerDeclarationBody.eval calls.get ({info, name} : Inputs).locals

def readType (calls : Calls) (source : Source) (frame : ParserState) (info : PackageBindings.Metadata) (position : Nat) :
    PackageTypeResult :=
  packageTypeBody.eval calls.get ({text := source, frame, info, position} : Inputs).locals

structure ReaderMeanings (calls : Calls) : Prop where
  word : ∀ source, Expressions.ValidText source → ∀ position, Expressions.ValidCursor source position →
    ∀ word : String, 0 < word.toList.length → word.toList.length ≤ 16 →
      readWord calls source position word = packageWord source position word
  pragmaAfter : ∀ source, Expressions.ValidText source → ∀ position, Expressions.ValidCursor source position →
    readPragma calls source position = sparkPragmaAfter source position
  allowed : ∀ source name, allowedName calls source name = packageNameAllowed source name
  fresh : ∀ source info name, freshName calls source info name = packageNameFresh source info name
  outer : ∀ info name, outerName calls info name = outerDeclaration info name
  typeAt : ∀ source, Expressions.ValidText source → ∀ frame,
    ApplicationPackageFrames.StateType frame → ApplicationPackageFrames.stateValid source frame = true →
    ∀ info position, Expressions.ValidCursor source position → readType calls source frame info position =
      packageTypeAt source frame info position

/-- All six name-reader bodies, with the source text domains of their original
functions. Machine component bounds and the executable Valid_State derive the
entire input to the underlying function header. -/
theorem imported_readers (imports : ApplicationPackageImports.Imports) (header : HeaderLibrary imports) :
    ReaderMeanings header.names where
  word source valid position bounded word positive length :=
    (word_denotation ..).trans (word_meaning _ (imported_primitives imports (header.calls .functionType))
      source valid position bounded word positive length)
  pragmaAfter source valid position bounded :=
    (pragma_denotation ..).trans (pragma_meaning _ (imported_primitives imports (header.calls .functionType))
      source valid position bounded)
  allowed source name := (allowed_denotation ..).trans
    (allowed_meaning _ (imported_primitives imports (header.calls .functionType)) source name)
  fresh source info name := (fresh_denotation ..).trans
    (fresh_meaning _ (imported_primitives imports (header.calls .functionType)) source info name)
  outer info name := outer_denotation header.names info name
  typeAt source valid frame typed frameValid info position bounded := by
    have native := ApplicationPackageFrames.stateValid_domain typed frameValid
    exact imported_type imports header.calls header.equations header.domain header.functions header.primitives
      header.visibilitySource header.links source valid frame info position
      (FunctionDeclarationNative.StateInput.ofNative valid ⟨native.base, native.ready, native.bounds⟩) bounded

end Silver.ApplicationPackageNames.Native
