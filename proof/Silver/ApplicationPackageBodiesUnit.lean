module

public import Silver.ApplicationPackageBodiesCompletion

@[expose] public section

/-! Package-body control follows original declaration/completion order and
retains partial metadata on every returning failure. Execution bounds count
cursor progress plus the two phase transitions; they add no admission rule. -/
namespace Silver.ApplicationPackageBodies
open Compose ApplicationPackageDeclarations
open ApplicationAdmission (BodyResult)

structure UnitCalls where
  validState : Source → ParserState → Bool
  packageWord : Source → Nat → String → Nat
  skipAt : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  takeToken : Source → Nat → ShellToken → Nat
  sparkPragmaAfter : Source → Nat → Nat
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool
  objectAt : Source → ParserState → PackageBindings.Metadata → Bool → ObjectResult
  completionAt : Source → ParserState → PackageBindings.Metadata → CompletionResult

inductive BodyPhase | objects | routines | footer
  deriving DecidableEq, Repr

def BodyPhase.rank : BodyPhase → Nat | .objects => 2 | .routines => 1 | .footer => 0

structure UnitState where
  globals : ParserState
  info : PackageBindings.Metadata
  phase : BodyPhase

inductive UnitStep
  | returned (result : BodyResult)
  | continued (state : UnitState)

def startUnit (calls : UnitCalls) (text : Source) (exports : ParserState)
    (info : PackageBindings.Metadata) : UnitStep :=
  let first := calls.skipAt text (calls.packageWord text
    (calls.packageWord text (info.units .packageBody).first "package") "body")
  let last := calls.nameAfter text first
  if !calls.sameName text ⟨first, last⟩ ⟨info.nameFirst, info.nameAfter⟩ then .returned ⟨info, false⟩
  else
    let info := {info with bodyNameFirst := first, bodyNameAfter := last}
    let globals := {exports with position := calls.sparkPragmaAfter text (calls.takeToken text last (.word "is"))}
    if globals.position = 0 then .returned ⟨info, false⟩ else .continued ⟨globals, info, .objects⟩

def stateDeclaration (object : ObjectResult) : PackageBindings.StateDeclaration :=
  {
    name := object.name
    kind := object.mark.kind
    typeName := object.mark.name
    typeIdentity := object.mark.identity
    declaredBounds := object.mark.bounds
    initialBounds := object.initialBounds
    initializerFirst := object.initFirst
    initializerAfter := object.initAfter
    booleanInitial := object.booleanValue}

def unitStep (calls : UnitCalls) (text : Source) (state : UnitState) : UnitStep :=
  match state.phase with
  | .objects =>
      if calls.takeToken text state.globals.position (.word "function") = 0 ∧
          calls.takeToken text state.globals.position (.word "procedure") = 0 ∧
          calls.takeToken text state.globals.position (.word "end") = 0 then
        if state.info.states.length = PackageBindings.maxStates then .returned ⟨state.info, false⟩
        else
          let object := calls.objectAt text state.globals state.info false
          if object.frame.position ≤ state.globals.position ∨ object.constantObject = true then
            .returned ⟨state.info, false⟩
          else .continued ⟨object.frame,
            {state.info with states := state.info.states ++ [stateDeclaration object]}, .objects⟩
      else .continued {state with phase := .routines}
  | .routines =>
      if state.info.completed < state.info.routines.length then
        let result := calls.completionAt text state.globals state.info
        if result.globals.position ≤ state.globals.position then .returned ⟨result.info, false⟩
        else .continued ⟨result.globals, result.info, .routines⟩
      else .continued {state with phase := .footer}
  | .footer =>
      let first := calls.skipAt text (calls.takeToken text state.globals.position (.word "end"))
      let last := calls.nameAfter text first
      let following := calls.takeToken text last (.symbol ";")
      .returned ⟨state.info,
        calls.sameName text ⟨first, last⟩ ⟨state.info.nameFirst, state.info.nameAfter⟩ &&
          decide (following ≠ 0) && decide (calls.skipAt text following = text.length + 1)⟩

def unitFuel (step : UnitState → UnitStep) : Nat → UnitState → Option BodyResult
  | 0, _ => none
  | fuel + 1, state => match step state with
    | .returned result => some result
    | .continued next => unitFuel step fuel next

def packageBodyFuel (calls : UnitCalls) (fuel : Nat) (text : Source) (exports : ParserState)
    (info : PackageBindings.Metadata) : Option BodyResult :=
  match startUnit calls text exports info with
  | .returned result => some result
  | .continued state => unitFuel (unitStep calls text) fuel state

theorem unitStep_progress {calls : UnitCalls} {text : Source} {before after : UnitState}
    (continued : unitStep calls text before = .continued after) :
    before.globals.position < after.globals.position ∨
      (before.globals = after.globals ∧ after.phase.rank < before.phase.rank) := by
  unfold unitStep at continued
  split at continued
  · split at continued
    · split at continued
      · contradiction
      · dsimp only at continued
        split at continued
        · contradiction
        · cases continued
          left
          dsimp only
          omega
    · cases continued
      right
      refine ⟨rfl, ?_⟩
      simp_all only [BodyPhase.rank]
      decide
  · split at continued
    · dsimp only at continued
      split at continued
      · contradiction
      · cases continued
        left
        dsimp only
        omega
    · cases continued
      right
      refine ⟨rfl, ?_⟩
      simp_all only [BodyPhase.rank]
      decide
  · contradiction

def unitRemaining (limit : Nat) (state : UnitState) : Nat :=
  3 * (limit - state.globals.position) + state.phase.rank

theorem unitRemaining_decreases {calls : UnitCalls} {text : Source} {limit : Nat}
    {before after : UnitState} (boundedBefore : before.globals.position ≤ limit)
    (boundedAfter : after.globals.position ≤ limit)
    (continued : unitStep calls text before = .continued after) :
    unitRemaining limit after < unitRemaining limit before := by
  have progress := unitStep_progress continued
  have beforeRank : before.phase.rank ≤ 2 := by cases before.phase <;> decide
  have afterRank : after.phase.rank ≤ 2 := by cases after.phase <;> decide
  unfold unitRemaining
  rcases progress with advanced | ⟨same, lower⟩
  · omega
  · have positions := congrArg ParserState.position same
    omega

theorem unitFuel_total {calls : UnitCalls} {text : Source} {valid : UnitState → Prop} {limit : Nat}
    (bounded : ∀ state, valid state → state.globals.position ≤ limit)
    (preserved : ∀ state next, valid state → unitStep calls text state = .continued next → valid next)
    {state : UnitState} (legal : valid state) {fuel : Nat}
    (enough : unitRemaining limit state + 1 ≤ fuel) :
    ∃ result, unitFuel (unitStep calls text) fuel state = some result := by
  induction fuel generalizing state with
  | zero => omega
  | succ fuel induction =>
      simp only [unitFuel]
      split
      · exact ⟨_, rfl⟩
      · rename_i next continued
        have nextValid := preserved state next legal continued
        have decreasing := unitRemaining_decreases (bounded state legal) (bounded next nextValid) continued
        apply induction nextValid
        omega

end Silver.ApplicationPackageBodies
