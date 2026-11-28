module

public import Silver.ApplicationPackageSpecificationMetadataTypes
public import Silver.ApplicationPackageDeclarationsSignatureStates
public import Silver.ApplicationAdmissionNative

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions PackageBindings

namespace SpecificationUnits

private def Start (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) : SpecificationStart → Prop
  | .returned result => result.info.units = units
  | .loop state => state.info.units = units

private def Step (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) : SpecificationStep → Prop
  | .returned result => result.info.units = units
  | .ready state | .next state => state.info.units = units

private def Exit (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) : SpecificationExit → Prop
  | .returned result => result.info.units = units
  | .ready state => state.info.units = units

private theorem either {α : Type} (meaning : α → Prop) (guard : Prop) [Decidable guard] {yes no : α}
    (left : meaning yes) (right : meaning no) : meaning (if guard then yes else no) := by
  split <;> assumption

private theorem start (calls : SpecificationCalls) (text : Source) (info : Metadata) :
    Start info.units (specificationStart calls text info) := by
  dsimp only [specificationStart]
  repeat' first | rfl | apply either (Start info.units)

private theorem continue_state (calls : SpecificationCalls) (text : Source) (before : Nat)
    (state : SpecificationState) (units : ApplicationUnits.UnitKind → ApplicationUnits.Span)
    (known : state.info.units = units) : Step units (continueSpecification calls text before state) := by
  dsimp only [continueSpecification]
  repeat' first | exact known | apply either (Step units)

private theorem append (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (next : ParserState) (item : ExportDeclaration) (units : ApplicationUnits.UnitKind → ApplicationUnits.Span)
    (known : state.info.units = units) : Step units (appendExport calls text state next item) :=
  continue_state calls text _ _ units known

private theorem routine (reader : BooleanElaboration.Native.Reader) (text : Source) (state : SpecificationState)
    (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) (known : state.info.units = units) :
    Step units (specificationRoutine (modelSpecificationCalls reader) text state) := by
  have retained := (readSignature_units text state.exports state.info false).trans known
  dsimp only [specificationRoutine, modelSpecificationCalls]
  repeat' first | exact retained | exact continue_state _ _ _ _ units retained | apply either (Step units)

private theorem subtype (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) (known : state.info.units = units) :
    Step units (specificationSubtype calls text state) := by
  dsimp only [specificationSubtype]
  repeat' first | exact known | exact append _ _ _ _ _ units known | apply either (Step units)

private theorem object (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) (known : state.info.units = units) :
    Step units (specificationObject calls text state) := by
  dsimp only [specificationObject]
  repeat' first | exact known | exact append _ _ _ _ _ units known | apply either (Step units)

private theorem step (reader : BooleanElaboration.Native.Reader) (text : Source) (state : SpecificationState)
    (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) (known : state.info.units = units) :
    Step units (specificationStep (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationStep]
  repeat' first
    | exact known
    | exact routine reader text state units known
    | exact subtype _ text state units known
    | exact object _ text state units known
    | apply either (Step units)

private theorem loop {reader text state result}
    (run : SpecificationLoop (modelSpecificationCalls reader) text state result)
    (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) (known : state.info.units = units) :
    Exit units result := by
  induction run with
  | returned parsed =>
    have retained := step reader text _ units known
    rwa [parsed] at retained
  | ready parsed =>
    have retained := step reader text _ units known
    rwa [parsed] at retained
  | next parsed _ ih =>
    have retained := step reader text _ units known
    rw [parsed] at retained
    exact ih retained

private theorem finish (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (units : ApplicationUnits.UnitKind → ApplicationUnits.Span) (known : state.info.units = units) :
    (finishSpecification calls text state).info.units = units := by
  dsimp only [finishSpecification]
  split <;> exact known

end SpecificationUnits

/-- The original unit-span table survives every declaration and rejected exit.
No validity, successful result or metadata-type premise is needed. -/
theorem SpecificationExec.retains_units {reader text info result}
    (exec : SpecificationExec (modelSpecificationCalls reader) text info result) :
    result.info.units = info.units := by
  have started := SpecificationUnits.start (modelSpecificationCalls reader) text info
  unfold SpecificationExec at exec
  cases entry : specificationStart (modelSpecificationCalls reader) text info with
  | returned failed =>
    simp only [entry] at started exec
    subst result
    exact started
  | loop state =>
    simp only [entry] at started exec
    obtain ⟨exit, ran, resultEq⟩ := exec
    have retained := SpecificationUnits.loop ran info.units started
    cases exit with
    | returned failed =>
      subst result
      exact retained
    | ready finalState =>
      subst result
      exact SpecificationUnits.finish _ _ _ _ retained

theorem readSpecification_units (reader : BooleanElaboration.Native.Reader) (text : Source) (info : Metadata) :
    (readSpecification reader text info).info.units = info.units :=
  (readSpecification_exec reader text info).retains_units

/-- Native storage alone types the original empty metadata after its Units
assignment. Layout, lexical acceptance and parsed declarations are unnecessary. -/
theorem specification_seed_typed (sources : ApplicationUnits.Bundle) (represented : sources.Representable) :
    ({units := sources.units} : Metadata).Typed := by
  simpa [Metadata.Typed, NameSpan.Typed] using represented.2.2

theorem specification_prefix_valid (sources : ApplicationUnits.Bundle) (valid : sources.Valid)
    (kind : ApplicationUnits.UnitKind) : ValidText (sources.prefix kind) := by
  have extent := sources.prefix_length valid kind
  have bounds := sources.span_bounds valid kind
  have capacity := valid.1.2.1
  unfold ValidText
  rw [extent]
  constructor <;> omega

/-- The native imported body has the same exact result and full output
contract for arbitrary caller locals and table backing, on all original inputs. -/
theorem specification_imported_complete_contract (library : ObjectLibraries)
    (reader : BooleanElaboration.Native.Reader) (procedures : ApplicationPackageProcedure.ProcedureCalls)
    (backing : Control.Backing) (prior : ApplicationNative.Locals)
    (text : Source) (valid : ValidText text) (info : Metadata) (typed : info.Typed) :
    SpecificationNative.body.Exec (SpecificationNative.functions (library.specification reader prior))
      {procedures with signature := readSignature} backing (SpecificationNative.inputLocals prior text info)
      (fun store => readSpecification reader text info = SpecificationNative.projectResult store) ∧
    (readSpecification reader text info).info.Typed ∧
    (readSpecification reader text info).info.units = info.units ∧
    ReaderFrame text (readSpecification reader text info).exports := by
  have result := readSpecification_typed reader valid info typed
  exact ⟨(specification_imported_reader_exec library reader procedures backing prior text valid info _).mpr rfl,
    result.1, readSpecification_units reader text info, result.2⟩

namespace ObjectLibraries

/-- The enclosing admission wrapper receives the unique original in/out
Specification result. Other imports retain their existing ownership. -/
def specification_admission (_library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (other : ApplicationAdmission.Native.Callees) : ApplicationAdmission.Native.Callees :=
  {other with packageSpecification := readSpecification reader}

theorem specification_admission_call (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (other : ApplicationAdmission.Native.Callees) (procedures : ApplicationPackageProcedure.ProcedureCalls)
    (backing : Control.Backing) (prior : ApplicationNative.Locals)
    (text : Source) (valid : ValidText text) (info : Metadata) (result : SpecificationResult) :
    SpecificationNative.body.Exec (SpecificationNative.functions (library.specification reader prior))
      {procedures with signature := readSignature} backing (SpecificationNative.inputLocals prior text info)
      (fun store => result = SpecificationNative.projectResult store) ↔
      result = (library.specification_admission reader other).packageSpecification text info :=
  specification_imported_reader_exec library reader procedures backing prior text valid info result

end ObjectLibraries
end Silver.ApplicationPackageDeclarations
