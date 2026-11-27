module

public import Silver.ApplicationPackageDeclarationsSpecificationModel
public import Silver.ComposeAtomReading

@[expose] public section

/-! Total original-unit declaration readers. Every admitted continue path
passes its strict cursor progress guard. The Signature back edge is bounded
by the semicolon token's source semantics; the Specification back edge is
bounded by the executable Valid_State check. -/
namespace Silver.ApplicationPackageDeclarations
open Compose ApplicationPackageNames

def modelSignatureCalls : SignatureCalls where
  skip := skipAt
  nameAfter := Compose.nameAfter
  take := tokenAfter
  validName text name := PackageBindings.validName (metadataText text) name
  sameName text left right := PackageBindings.sameName (metadataText text) left right
  fresh := packageNameFresh
  hide := hideName
  hideOuter := ApplicationPackageFrames.hideOuter
  typeAt := packageTypeAt
  append := appendFormal
  stateValid := ApplicationPackageFrames.stateValid

private def SignatureProgress (text : Source) (before : Nat) : SignatureStep → Prop
  | .returned _ | .ready _ => True
  | .next state => before < state.header.position ∧ state.header.position ≤ text.length + 1

private theorem finishFormal_progress (text : Source) (before : Nat) (state : SignatureState) :
    SignatureProgress text before (finishFormal modelSignatureCalls text before state) := by
  dsimp only [finishFormal]
  split
  · trivial
  · split
    · trivial
    · rename_i advanced
      exact ⟨Nat.lt_of_not_ge advanced, Compose.fixedAfter_result_bound text _ ";" false (by decide)⟩

private theorem signatureProgress_if {text : Source} {before : Nat} (condition : Prop)
    [Decidable condition] {yes no : SignatureStep}
    (whenTrue : SignatureProgress text before yes) (whenFalse : SignatureProgress text before no) :
    SignatureProgress text before (if condition then yes else no) := by
  split <;> assumption

theorem signatureStep_progress (text : Source) (completing : Bool) (state next : SignatureState)
    (continued : signatureStep modelSignatureCalls text completing state = .next next) :
    state.header.position < next.header.position ∧ next.header.position ≤ text.length + 1 := by
  have result : SignatureProgress text state.header.position (signatureStep modelSignatureCalls text completing state) := by
    unfold signatureStep
    repeat' first | exact True.intro | apply finishFormal_progress | apply signatureProgress_if
  rw [continued] at result
  exact result

def runSignatureLoop (text : Source) (completing : Bool) (state : SignatureState) : SignatureExit :=
  match _step : signatureStep modelSignatureCalls text completing state with
  | .returned result => .returned result
  | .ready finalState => .ready finalState
  | .next following => runSignatureLoop text completing following
termination_by text.length + 1 - state.header.position
decreasing_by
  obtain ⟨advance, bound⟩ := signatureStep_progress _ _ _ _ _step
  omega

theorem runSignatureLoop_exec (text : Source) (completing : Bool) (state : SignatureState) :
    SignatureLoop modelSignatureCalls text completing state (runSignatureLoop text completing state) := by
  rw [runSignatureLoop]
  split
  · exact .returned ‹_›
  · exact .ready ‹_›
  · exact .next ‹_› (runSignatureLoop_exec text completing _)
termination_by text.length + 1 - state.header.position
decreasing_by
  obtain ⟨advance, bound⟩ := signatureStep_progress _ _ _ _ ‹_›
  omega

def readSignature (text : Source) (outer : ParserState) (info : PackageBindings.Metadata)
    (completing : Bool) : SignatureResult :=
  match signatureStart modelSignatureCalls text outer info completing with
  | .returned result => result
  | .ready state => finishSignature modelSignatureCalls text outer completing state
  | .loop state => match runSignatureLoop text completing state with
    | .returned result => result
    | .ready finalState => finishSignature modelSignatureCalls text outer completing finalState

theorem readSignature_exec (text : Source) (outer : ParserState) (info : PackageBindings.Metadata)
    (completing : Bool) :
    SignatureExec modelSignatureCalls text outer info completing (readSignature text outer info completing) := by
  unfold SignatureExec readSignature
  cases signatureStart modelSignatureCalls text outer info completing with
  | returned result => rfl
  | ready state => rfl
  | loop state => exact ⟨_,runSignatureLoop_exec text completing state,rfl⟩

def modelSpecificationCalls (staticBoolean : BooleanElaboration.Native.Reader) : SpecificationCalls where
  skip := skipAt
  nameAfter := Compose.nameAfter
  take := tokenAfter
  word := packageWord
  pragmaAfter := sparkPragmaAfter
  allowed := packageNameAllowed
  fresh := packageNameFresh
  sameName text left right := PackageBindings.sameName (metadataText text) left right
  hide := hideName
  signature := readSignature
  subtype := subtypeDeclarationAt
  object := fun text state info localObject => objectStep (modelObjectCalls staticBoolean) text state info localObject
  stateValid := ApplicationPackageFrames.stateValid

private def SpecificationProgress (text : Source) (before : Nat) : SpecificationStep → Prop
  | .returned _ | .ready _ => True
  | .next state => before < state.exports.position ∧ state.exports.position ≤ text.length + 1

private theorem continueSpecification_progress (reader : BooleanElaboration.Native.Reader) (text : Source)
    (before : Nat) (state : SpecificationState) :
    SpecificationProgress text before (continueSpecification (modelSpecificationCalls reader) text before state) := by
  unfold continueSpecification
  split
  · trivial
  · rename_i guarded
    simp only [Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true', not_or] at guarded
    have valid : ApplicationPackageFrames.stateValid text state.exports = true := by
      apply Bool.of_not_eq_false
      exact guarded.2
    simp only [ApplicationPackageFrames.stateValid, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at valid
    exact ⟨by omega, valid.1⟩

theorem specificationStep_progress (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state next : SpecificationState)
    (continued : specificationStep (modelSpecificationCalls reader) text state = .next next) :
    state.exports.position < next.exports.position ∧ next.exports.position ≤ text.length + 1 := by
  have result : SpecificationProgress text state.exports.position (specificationStep (modelSpecificationCalls reader) text state) := by
    dsimp only [specificationStep, specificationRoutine, specificationSubtype, specificationObject, appendExport]
    repeat' first | exact continueSpecification_progress .. | trivial | split
  rw [continued] at result
  exact result

def runSpecificationLoop (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) : SpecificationExit :=
  match _step : specificationStep (modelSpecificationCalls reader) text state with
  | .returned result => .returned result
  | .ready finalState => .ready finalState
  | .next following => runSpecificationLoop reader text following
termination_by text.length + 1 - state.exports.position
decreasing_by
  obtain ⟨advance, bound⟩ := specificationStep_progress _ _ _ _ _step
  omega

theorem runSpecificationLoop_exec (reader : BooleanElaboration.Native.Reader) (text : Source) (state : SpecificationState) :
    SpecificationLoop (modelSpecificationCalls reader) text state (runSpecificationLoop reader text state) := by
  rw [runSpecificationLoop]
  split
  · exact .returned ‹_›
  · exact .ready ‹_›
  · exact .next ‹_› (runSpecificationLoop_exec reader text _)
termination_by text.length + 1 - state.exports.position
decreasing_by
  obtain ⟨advance, bound⟩ := specificationStep_progress _ _ _ _ ‹_›
  omega

def readSpecification (reader : BooleanElaboration.Native.Reader) (text : Source)
    (info : PackageBindings.Metadata) : SpecificationResult :=
  let calls := modelSpecificationCalls reader
  match specificationStart calls text info with
  | .returned result => result
  | .loop state => match runSpecificationLoop reader text state with
    | .returned result => result
    | .ready finalState => finishSpecification calls text finalState

theorem readSpecification_exec (reader : BooleanElaboration.Native.Reader) (text : Source)
    (info : PackageBindings.Metadata) :
    SpecificationExec (modelSpecificationCalls reader) text info (readSpecification reader text info) := by
  dsimp only [SpecificationExec, readSpecification]
  cases specificationStart (modelSpecificationCalls reader) text info with
  | returned result => rfl
  | loop state => exact ⟨_,runSpecificationLoop_exec reader text state,rfl⟩

end Silver.ApplicationPackageDeclarations
