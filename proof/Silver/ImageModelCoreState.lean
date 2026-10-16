module

public import Silver.ImageModelFinishSource

@[expose] public section
namespace Silver.ImageModel.Core

/-- Mathematical observations of the complete native private State record.
Match cursors and prefix storage are grouped only to share the checked helper
interpretations. Every native field has exactly one observation below. -/
@[ext] structure State where
  failed : Bool := false
  bytes : Nat := 0
  depth : Nat := 0
  mode : StringNative.Mode := .between
  phase : TheoryNative.Phase := .beforeRoot
  seen : Native.Theory → Bool := fun _ => false
  matcher : Native.Matcher := ⟨false, fun _ => ⟨0, false⟩⟩
  theory : Option Native.Theory := none
  field : Nat := 0
  candidateDeclarations : Nat := 0
  candidateIncludes : Nat := 0
  declarations : Nat := 0
  includes : Nat := 0
  greatestId : Nat := 0
  previousArrayStart : Bool := false
  nodeIdPending : Bool := false
  numberIsId : Bool := false
  numberValue : Nat := 0
  numberDigits : Bool := false
  isTag : Bool := false
  isKey : Bool := false
  isName : Bool := false
  isTheoryTag : Bool := false
  name : DecodedNative.RawName := ⟨0, fun _ => 32⟩
  unicodeLeft : Nat := 0
  unicodeValue : Nat := 0

/-- Native type domains; GNATprove checks preservation for every public Consume
call. Source interpretations apply to these represented native values. -/
def State.Typed (state : State) : Prop :=
  state.bytes ≤ 9223372036854775807 ∧ state.depth ≤ 9223372036854775807 ∧
    state.field ≤ 8 ∧ state.greatestId ≤ originalIdMaximum ∧
    state.numberValue ≤ originalIdMaximum ∧ state.name.length ≤ 22 ∧
    (∀ i, 1 ≤ i → i ≤ 21 → state.name.buffer i ≤ 255) ∧
    state.unicodeLeft ≤ 4 ∧ state.unicodeValue ≤ 65535 ∧
    ∀ kind, (state.matcher.cells kind).position ≤ 2147483647

theorem initial_typed : State.Typed {} := by
  simp [State.Typed, originalIdMaximum]

def State.stringView (state : State) : StringNative.Frame :=
  {failed := state.failed, matcher := state.matcher, name := state.name,
   mode := state.mode, phase := state.phase, theory := state.theory,
   isKey := state.isKey, isTheoryTag := state.isTheoryTag, isName := state.isName,
   isTag := state.isTag, nodeIdPending := state.nodeIdPending}

def State.setString (state : State) (frame : StringNative.Frame) : State :=
  { state with
    failed := frame.failed, matcher := frame.matcher, name := frame.name,
    mode := frame.mode, phase := frame.phase, theory := frame.theory,
    isKey := frame.isKey, isTheoryTag := frame.isTheoryTag, isName := frame.isName,
    isTag := frame.isTag, nodeIdPending := frame.nodeIdPending}

theorem State.setString_view (state : State) : state.setString state.stringView = state := by cases state; rfl

def State.theoryView (state : State) : TheoryNative.Frame :=
  {failed := state.failed, matcher := state.matcher, field := state.field,
   theory := state.theory, seen := state.seen, candidateDeclarations := state.candidateDeclarations,
   candidateIncludes := state.candidateIncludes, declarations := state.declarations,
   includes := state.includes, depth := state.depth, phase := state.phase}

def State.setTheory (state : State) (frame : TheoryNative.Frame) : State :=
  { state with
    failed := frame.failed, matcher := frame.matcher, field := frame.field,
    theory := frame.theory, seen := frame.seen, candidateDeclarations := frame.candidateDeclarations,
    candidateIncludes := frame.candidateIncludes, declarations := frame.declarations,
    includes := frame.includes, depth := frame.depth, phase := frame.phase}

theorem State.setTheory_view (state : State) : state.setTheory state.theoryView = state := by cases state; rfl

def State.finishView (state : State) : FinishNative.Input :=
  {failed := state.failed, mode := state.mode, phase := state.phase, depth := state.depth,
   inTheory := state.matcher.inTheory, nodeIdPending := state.nodeIdPending, seen := state.seen,
   bytes := state.bytes, declarations := state.declarations, includes := state.includes,
   greatestId := state.greatestId}

structure Helpers where
  matchByte : State → Nat → State
  decoded : State → Nat → State
  endString : State → State
  endTheory : State → State
  hex : Nat → Nat

def matcher (tables : Native.Tables) : DecodedNative.MatchCall :=
  fun state byte => Native.matchCommands.eval tables byte state .integer

def nameCall : StringNative.NameCall := NameNative.body.eval

def hexadecimal (code : Nat) : Nat :=
  if 48 ≤ code ∧ code ≤ 57 then code - 48
  else if 97 ≤ code ∧ code ≤ 102 then (code - 97) + 10
  else if 65 ≤ code ∧ code ≤ 70 then (code - 65) + 10
  else 16

def modelHelpers (tables : Native.Tables) : Helpers where
  matchByte state byte := {state with matcher := matcher tables state.matcher byte}
  decoded state code :=
    let result := DecodedNative.output (matcher tables)
      {name := DecodedNative.remember state.name code, matcher := state.matcher, code}
    {state with name := result.name, matcher := result.matcher}
  endString state := state.setString (StringNative.model (matcher tables) nameCall state.stringView)
  endTheory state := state.setTheory (TheoryNative.model tables (matcher tables) state.theoryView)
  hex := hexadecimal

/-- Source-level call linking through the already checked helper bodies. These
premises name primitive call interpretations, not desired scanner properties. -/
structure HelperDefinitions (tables : Native.Tables) (helpers : Helpers) : Prop where
  matchByte : ∀ state byte, helpers.matchByte state byte =
    {state with matcher := Native.matchCommands.eval tables byte state.matcher .integer}
  decoded : ∀ state code, helpers.decoded state code =
    let result := DecodedNative.commands.eval (matcher tables) ⟨state.name, state.matcher, code⟩
    {state with name := result.name, matcher := result.matcher}
  endString : ∀ state, helpers.endString state =
    state.setString (StringNative.commands.eval (matcher tables) nameCall state.stringView)
  endTheory : ∀ state, helpers.endTheory state =
    state.setTheory (TheoryNative.commands.eval tables (matcher tables) state.theoryView)
  hex : helpers.hex = hexadecimal

theorem helper_definitions_model (tables : Native.Tables) : HelperDefinitions tables (modelHelpers tables) where
  matchByte _ _ := rfl
  decoded state code := by simp only [modelHelpers, DecodedNative.decoded_eval]
  endString state := by simp only [modelHelpers, StringNative.eval_model]
  endTheory state := by simp only [modelHelpers, TheoryNative.eval_model]
  hex := rfl

theorem interpreted_helpers (tables : Native.Tables) (helpers : Helpers) (source : HelperDefinitions tables helpers) :
    helpers = modelHelpers tables := by
  cases helpers with
  | mk matchByte decoded endString endTheory hex =>
    have a := source.matchByte
    have b := source.decoded
    have c := source.endString
    have d := source.endTheory
    have e := source.hex
    simp only [DecodedNative.decoded_eval] at b
    simp only [StringNative.eval_model] at c
    simp only [TheoryNative.eval_model] at d
    congr 1
    · exact funext (fun state => funext (a state))
    · exact funext (fun state => funext (b state))
    · exact funext c
    · exact funext d

end Silver.ImageModel.Core
