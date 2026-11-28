module

public import Silver.ApplicationPackageDeclarationsSignatureLoopImports
public import Silver.ApplicationPackageDeclarationsObjectMeaning
public import Silver.ComposeSubtypeDeclarations

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

/-- Native component domains needed before the Specification continuation
evaluates Valid_State. Its executable guard supplies the remaining frame fact. -/
structure SpecificationFrameBase (state : ParserState) : Prop where
  typed : StateType state
  imports : ValidityNative.ImportedTypes state

theorem ReaderFrame.specification_base {text state} (frame : ReaderFrame text state)
    (valid : ValidText text) : SpecificationFrameBase state :=
  ⟨frame.typed, frame.imported_types valid⟩

theorem state_type_specification_header {state} (typed : StateType state)
    (position : Nat) (flags : HiddenMarks) : StateType {state with position, «hiding» := flags} :=
  ⟨typed.context, typed.capacity, typed.namesCount, typed.names, typed.scalarCount, typed.scalars,
    typed.subtypeCount, typed.subtypes, typed.booleanCount, typed.firstParameter, typed.firstProcedureParameter⟩

theorem SpecificationFrameBase.header {state} (frame : SpecificationFrameBase state)
    (position : Nat) (flags : HiddenMarks) :
    SpecificationFrameBase {state with position, «hiding» := flags} :=
  ⟨state_type_specification_header frame.typed position flags,
    ⟨frame.imports.functions, frame.imports.procedures, frame.imports.arrays⟩⟩

theorem initial_reader_frame (text : Source) : ReaderFrame text initialState := by
  constructor
  · constructor <;> simp [initialState]
  · simp [stateValid, initialState, nameStateValid, FunctionBindings.ValidMetadata,
      ProcedureBindings.ValidMetadata, stringNamesValid, scalarNamesValid,
      ArrayBindings.ValidNativeEnvironment, ArrayBindings.ValidTable, ArrayBindings.ValidTypes,
      ArrayBindings.Env.table, ArrayBindings.ValidInitials, subtypesValid, booleanNamesValid,
      mutableBoundsValid, declarationValuesValid]

theorem ReaderFrame.package_name {text state} (frame : ReaderFrame text state)
    (name : PackageBindings.NameSpan) (span : ValidName text name.first name.after) :
    ReaderFrame text {state with packageFirst := name.first, packageAfter := name.after} := by
  refine ⟨⟨frame.typed.context, frame.typed.capacity, frame.typed.namesCount, frame.typed.names,
    frame.typed.scalarCount, frame.typed.scalars, frame.typed.subtypeCount, frame.typed.subtypes,
    frame.typed.booleanCount, frame.typed.firstParameter, frame.typed.firstProcedureParameter⟩, ?_⟩
  have checked := frame.valid
  simp only [stateValid, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at checked ⊢
  exact ⟨checked.1, checked.2.1, (nameStateValid_meaning ..).mpr (.inr span), checked.2.2.2⟩

def SpecificationStartFramed (text : Source) : SpecificationStart → Prop
  | .returned _ => True
  | .loop state => ReaderFrame text state.exports

def SpecificationStepFramed (text : Source) : SpecificationStep → Prop
  | .returned _ => True
  | .ready state | .next state => ReaderFrame text state.exports

theorem specification_start_framed (reader : BooleanElaboration.Native.Reader) (text : Source)
    (info : PackageBindings.Metadata) :
    SpecificationStartFramed text (specificationStart (modelSpecificationCalls reader) text info) := by
  dsimp only [specificationStart, modelSpecificationCalls]
  generalize firstRead : skipAt text (packageWord text 1 "package") = first
  generalize nameRead : nameAfter text first = last
  generalize positionRead : sparkPragmaAfter text (tokenAfter text last (.word "is")) = position
  split
  · trivial
  · rename_i accepted
    have allowed : packageNameAllowed text ⟨first,last⟩ = true :=
      Bool.of_not_eq_false (fun failed => accepted (by simp only [failed, Bool.not_false]))
    have named : PackageBindings.validName (metadataText text) ⟨first,last⟩ = true := by
      simp only [packageNameAllowed, Bool.and_eq_true, and_assoc] at allowed
      exact allowed.1
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    split
    · trivial
    · have cursor : ValidCursor text position := by
        rw [← positionRead]
        exact fixedAfter_result_bound text _ ";" false (by decide)
      have initial : ReaderFrame text {initialState with position} := (initial_reader_frame text).at_position cursor
      exact initial.package_name ⟨first,last⟩ span

theorem continue_specification_framed (reader : BooleanElaboration.Native.Reader) (text : Source)
    (before : Nat) (state : SpecificationState) (typed : StateType state.exports) :
    SpecificationStepFramed text (continueSpecification (modelSpecificationCalls reader) text before state) := by
  dsimp only [continueSpecification, modelSpecificationCalls]
  split
  · trivial
  · rename_i accepted
    exact ⟨typed, Bool.of_not_eq_false (fun failed => accepted (by simp only [failed, Bool.not_false, Bool.or_true]))⟩

theorem subtype_specification_base {text : Source} (valid : ValidText text)
    {frame next : ParserState} (framed : ReaderFrame text frame) {arguments : Bool}
    (reading : SubtypeDeclarationAt text arguments frame next) : SpecificationFrameBase next := by
  have fields := subtype_declaration_valid reading framed.native.base.2.2.2.2.2.2.2.1
  have imported := framed.imported_types valid
  cases reading with
  | declaration parts ready constraint =>
    refine ⟨⟨framed.typed.context, framed.typed.capacity, framed.typed.namesCount, framed.typed.names,
      framed.typed.scalarCount, framed.typed.scalars, fields.1, ?_, framed.typed.booleanCount,
      framed.typed.firstParameter, framed.typed.firstProcedureParameter⟩,
      ⟨imported.functions, imported.procedures, imported.arrays⟩⟩
    intro item member
    exact (fields.2 item member).2.2.2.1

theorem specification_subtype_base {text : Source} (valid : ValidText text)
    (frame : ParserState) (framed : ReaderFrame text frame) (arguments : Bool)
    (present : (subtypeDeclarationAt text frame arguments).position ≠ 0) :
    SpecificationFrameBase (subtypeDeclarationAt text frame arguments) :=
  subtype_specification_base valid framed (subtype_declaration_sound text frame arguments present)

end Silver.ApplicationPackageDeclarations
