module

public import Silver.ApplicationPackageDeclarationsSpecificationImports
public import Silver.ApplicationPackageDeclarationsSpecificationSignatureDomains
public import Silver.ApplicationPackageDeclarationsSpecificationStepDomains

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

namespace NameLibraries

theorem specification_continue (library : NameLibraries) (other : SpecificationCalls)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (before : Nat) (state : SpecificationState) (base : SpecificationFrameBase state.exports) :
    continueSpecification (library.specification other) text before state =
      continueSpecification (modelSpecificationCalls reader) text before state := by
  dsimp only [continueSpecification, specification, modelSpecificationCalls]
  rw [ApplicationPackageFrames.Native.frameCalls_valid library.shared library.validity text valid state.exports base.imports]

theorem specification_routine (library : NameLibraries) (other : SpecificationCalls)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (framed : ReaderFrame text state.exports)
    (signature : other.signature text state.exports state.info false = readSignature text state.exports state.info false) :
    specificationRoutine (library.specification other) text state =
      specificationRoutine (modelSpecificationCalls reader) text state := by
  dsimp +instances only [specificationRoutine, specification, modelSpecificationCalls]
  rw [signature]
  let result := readSignature text state.exports state.info false
  change (if result.header.position = 0 ∨ result.info.routines.length = 0 then _ else _) =
    (if result.header.position = 0 ∨ result.info.routines.length = 0 then _ else _)
  split
  · rfl
  · rename_i accepted
    have present : result.header.position ≠ 0 := fun missing => accepted (.inl missing)
    have fields := readSignature_specification_domain text state.exports state.info present
    rw [ApplicationPackageFrames.Native.importedHideName_meaning library.shared text valid
      state.exports.hiding _ _ fields.2]
    exact library.specification_continue other reader valid _ _ ((framed.specification_base valid).header _ _)

theorem specification_subtype (library : NameLibraries) (other : SpecificationCalls)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (framed : ReaderFrame text state.exports)
    (subtype : other.subtype text state.exports false = subtypeDeclarationAt text state.exports false) :
    specificationSubtype (library.specification other) text state =
      specificationSubtype (modelSpecificationCalls reader) text state := by
  dsimp +instances only [specificationSubtype, specification, modelSpecificationCalls]
  rw [subtype]
  split
  · rfl
  · rename_i present
    rw [(ApplicationPackageNames.Native.imported_readers library.shared library.header).fresh]
    split
    · rfl
    · unfold appendExport
      exact library.specification_continue other reader valid _ _
        (specification_subtype_base valid state.exports framed false present)

theorem specification_object (library : NameLibraries) (other : SpecificationCalls)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (framed : ReaderFrame text state.exports)
    (object : other.object text state.exports state.info false =
      objectStep (modelObjectCalls reader) text state.exports state.info false) :
    specificationObject (library.specification other) text state =
      specificationObject (modelSpecificationCalls reader) text state := by
  dsimp +instances only [specificationObject, specification, modelSpecificationCalls]
  rw [object]
  split
  · rfl
  · rename_i accepted
    have present : (objectStep (modelObjectCalls reader) text state.exports state.info false).frame.position ≠ 0 :=
      fun missing => accepted (by simp only [missing, decide_true, Bool.true_or])
    unfold appendExport
    exact library.specification_continue other reader valid _ _
      (objectStep_specification_base reader valid state.exports framed state.info false present)

theorem specification_step (library : NameLibraries) (other : SpecificationCalls)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (framed : ReaderFrame text state.exports)
    (signature : other.signature text state.exports state.info false = readSignature text state.exports state.info false)
    (subtype : other.subtype text state.exports false = subtypeDeclarationAt text state.exports false)
    (object : other.object text state.exports state.info false =
      objectStep (modelObjectCalls reader) text state.exports state.info false) :
    specificationStep (library.specification other) text state =
      specificationStep (modelSpecificationCalls reader) text state := by
  have token (word : String) (domain : ValidToken (.word word)) :
      (library.specification other).take text state.exports.position (.word word) =
        tokenAfter text state.exports.position (.word word) :=
    interpreted_take _ library.shared.inherited text valid _ _ framed.cursor domain
  unfold specificationStep
  rw [token "end" (by unfold ValidToken; decide), token "function" (by unfold ValidToken; decide),
    token "procedure" (by unfold ValidToken; decide), token "subtype" (by unfold ValidToken; decide)]
  rw [library.specification_routine other reader valid state framed signature,
    library.specification_subtype other reader valid state framed subtype,
    library.specification_object other reader valid state framed object]
  simp only [show (modelSpecificationCalls reader).take = tokenAfter from rfl]

end NameLibraries

namespace ObjectLibraries

/-- Actual inherited subtype and complete typed Object calls. Signature is
the total result justified by signature_imported_reader_exec. -/
def specificationBranches (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) : SpecificationCalls :=
  {modelSpecificationCalls reader with
    subtype := library.names.shared.composed.function .subtypeDeclaration
    object := fun text frame info localObject => ObjectNative.body.eval (library.object reader).get
      (ObjectNative.inputLocals prior text frame info localObject)}

def specification (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) : SpecificationCalls :=
  library.names.specification (library.specificationBranches reader prior)

theorem specification_step (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (framed : ReaderFrame text state.exports) :
    specificationStep (library.specification reader prior) text state =
      specificationStep (modelSpecificationCalls reader) text state := by
  apply library.names.specification_step (library.specificationBranches reader prior) reader valid state framed
  · rfl
  · exact interpreted_subtypeDeclaration _ library.names.shared.inherited text valid state.exports false
      (library.names.composed_state framed)
  · exact library.object_meaning reader valid state.exports framed state.info false prior

end ObjectLibraries
end Silver.ApplicationPackageDeclarations
