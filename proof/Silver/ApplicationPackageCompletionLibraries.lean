module

public import Silver.ApplicationPackageCompletionLeafLibraries
public import Silver.ApplicationPackageDeclarationsReaderImports
public import Silver.ApplicationPackageDeclarationsObjectMeaning
public import Silver.ApplicationPackageRoutineFrameImports
public import Silver.ApplicationPackageCompletionBodyDomains

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames ApplicationPackageNames

/-- Original Signature execution, before identifying its result with the
total reader. This relation retains every early return and partial write. -/
structure SignatureLibrary (names : NameLibraries) where
  call : Source → ParserState → PackageBindings.Metadata → Bool → SignatureResult
  execution : ∀ text, ValidText text → ∀ outer, ReaderFrame text outer → ∀ info completing,
    SignatureExec (names.signatureValidity modelSignatureCalls) text outer info completing
      (call text outer info completing)

theorem SignatureLibrary.meaning {names : NameLibraries} (library : SignatureLibrary names)
    {text : Source} (valid : ValidText text) (outer : ParserState) (framed : ReaderFrame text outer)
    (info : PackageBindings.Metadata) (completing : Bool) :
    library.call text outer info completing = readSignature text outer info completing :=
  (names.signature_exec_iff valid outer framed info completing _).mp
    (library.execution text valid outer framed info completing)

theorem SignatureLibrary.native {names : NameLibraries} (library : SignatureLibrary names)
    (assertions : SignatureNative.Calls) (procedures : ApplicationPackageProcedure.ProcedureCalls)
    (backing : ApplicationPackageDeclarations.Control.Backing) (prior : ApplicationNative.Locals)
    {text : Source} (valid : ValidText text) (outer : ParserState) (framed : ReaderFrame text outer)
    (info : PackageBindings.Metadata) (completing : Bool) :
    SignatureNative.body.Exec
      ({assertions with base := names.signatureValidity modelSignatureCalls} : SignatureNative.Calls).get
      {procedures with appendFormal := ApplicationPackageDeclarations.appendFormal} backing
      (SignatureNative.inputLocals prior text outer info completing)
      (fun store => library.call text outer info completing = SignatureNative.projectResult store) :=
  (signature_imported_reader_exec names assertions procedures backing prior text valid outer framed info completing _).mpr
    (library.meaning valid outer framed info completing)

/-- Imported routines are connected to their typed source equations. The
recursive equations remain the original source equations and do not assume a
recursive postcondition or successful-program certificate. -/
structure Library where
  objects : ObjectLibraries
  signature : SignatureLibrary objects.names
  routine : ApplicationPackageRoutineFrame.Library
  leaves : LeafLibraries
  readers : Recursive.Readers
  recursive : Recursive.Equations (Recursive.nativeReaders readers) Recursive.NativeDomain
  prior : ApplicationNative.Locals

namespace Library

noncomputable def calls (library : Library) (reader : BooleanElaboration.Native.Reader) : CompletionCalls where
  validState := library.routine.calls.validState
  takeToken := library.objects.names.shared.composed.function .takeToken
  skipAt := library.objects.names.shared.composed.function .skip
  nameAfter := library.objects.names.shared.composed.function .nameAfter
  validName text := library.objects.names.shared.packages.validName (metadataText text)
  sameName text := library.objects.names.shared.packages.sameName (metadataText text)
  signatureAt := library.signature.call
  routineFrame := ApplicationPackageRoutineFrame.routineFrame library.routine.calls
  objectAt text frame info localObject := ObjectNative.body.eval (library.objects.object reader).get
    (ObjectNative.inputLocals library.prior text frame info localObject)
  contextOf scan := (library.leaves.flow.context scan).model
  bodyOf := library.leaves.flow.wrappers.bodyOf
  initialFlow := library.leaves.initialFlow
  stateReads := ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls library.leaves.effects)
  actualAfter := library.leaves.returns.actual.projected
  appendFormal := library.routine.appendFormal
  applicationTail := (Recursive.nativeReaders library.readers).statement.applicationTail
  functionReturnAfter := library.leaves.returns.projected

noncomputable def model (library : Library) (reader : BooleanElaboration.Native.Reader) : CompletionCalls :=
  declarationReaders reader (LeafLibraries.model (library.calls reader))

theorem take (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position)
    (token : ShellToken) (allowed : ValidToken token) :
    (library.calls reader).takeToken text position token = fixedAfter text position (spelling token) (isWord token) :=
  interpreted_take _ library.objects.names.shared.inherited text valid position token bounded allowed

theorem skip (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position) :
    (library.calls reader).skipAt text position = Compose.skipAt text position :=
  interpreted_skip _ library.objects.names.shared.inherited text valid position bounded

theorem name (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position) :
    (library.calls reader).nameAfter text position = Compose.nameAfter text position :=
  interpreted_name _ library.objects.names.shared.inherited text valid position bounded

theorem valid_name (library : Library) (reader : BooleanElaboration.Native.Reader)
    (text : Source) (name : PackageBindings.NameSpan) :
    (library.calls reader).validName text name = PackageBindings.validName (metadataText text) name :=
  PackageBindings.Native.interpreted_validName _ library.objects.names.shared.packagePrimitives
    library.objects.names.shared.packageEquations (metadataText text) name

theorem same_name (library : Library) (reader : BooleanElaboration.Native.Reader)
    (text : Source) (left right : PackageBindings.NameSpan) :
    (library.calls reader).sameName text left right = PackageBindings.sameName (metadataText text) left right :=
  PackageBindings.Native.interpreted_sameName _ library.objects.names.shared.packagePrimitives
    library.objects.names.shared.packageEquations (metadataText text) left right

theorem signature_at (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (frame : ParserState) (framed : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (completing : Bool) :
    (library.calls reader).signatureAt text frame info completing = readSignature text frame info completing :=
  library.signature.meaning valid frame framed info completing

theorem routine_frame (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (frame : ParserState) (framed : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (index position : Nat) (bounded : ValidCursor text position) :
    (library.calls reader).routineFrame text frame info index position =
      (library.model reader).routineFrame text frame info index position :=
  library.routine.routine_frame valid frame framed info index position bounded

theorem object_at (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (frame : ParserState) (framed : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (localObject : Bool) :
    (library.calls reader).objectAt text frame info localObject =
      objectStep (modelObjectCalls reader) text frame info localObject :=
  library.objects.object_meaning reader valid frame framed info localObject library.prior

end Library
end Silver.ApplicationPackageCompletion
