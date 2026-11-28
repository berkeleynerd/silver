module

public import Silver.ApplicationPackageRoutineSourceSummary

@[expose] public section

namespace Silver.ApplicationPackageRoutineSources
open Compose Compose.Expressions Packages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageRoutineClosedFrames ApplicationPackageObjectRows
open ApplicationPackageFrameLayout ApplicationPackageExportRows

/-- Persistent declaration/history facts at the original completion cursor.
This is an induction invariant, not a source-meaning certificate. It contains
native representation, original declaration origins and interface domains; no
routine/body/result checker or safety premise occurs here. -/
structure RoutineFrameFacts (specText : Source) (constants : ScalarExpression.Environment)
    (text : Source) (globals : ParserState) (info : PackageBindings.Metadata) : Prop where
  framed : ReaderFrame text globals
  typed : info.Typed
  tables : Tables globals
  initial : StateFrame info.states globals
  origin : GlobalScalarOrigins constants info.states globals.scalarNames
  separated : specText.length < globals.position
  declarations : StateDeclarations text info.states
  clear : GlobalRowsClear text info.states (integerRows globals)
  bounds : ∀ state ∈ info.states, state.declaredBounds.isEmpty = false
  declared : DeclaredFormalModes info
  interfaces : InterfaceDomains info
  exports : ∀ item ∈ info.exports, item.name.first < globals.position

theorem RoutineFrameFacts.next {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {specText text : Source} {constants : ScalarExpression.Environment}
    {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (known : RoutineFrameFacts specText constants text globals info)
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (present : result.globals.position ≠ 0) (typed : result.info.Typed)
    (bounded : result.globals.position ≤ text.length + 1) :
    RoutineFrameFacts specText constants text result.globals result.info := by
  obtain ⟨read⟩ := completion_body_read frames.executed present
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have retained := signed ▸ (readSignature_exec text globals info true).retains_fields
  have fields := completionBody_globals frames.executed present
  have states : result.info.states = info.states := fields.2.2.trans
    (signed ▸ readSignature_states text globals info true)
  have exports : result.info.exports = info.exports := by
    rw [read.stored]
    simpa only [finishedInfo, SignatureStates.unchangedFields] using
      congrArg PackageBindings.Metadata.exports retained
  have tables := (frames.result_tables present).2
  refine ⟨?_, typed, ?_, ?_, ?_, Nat.lt_trans known.separated fields.2.1,
    ?_, ?_, ?_, known.declared.of_declarations tables.declared tables.routineDeclarations,
    known.interfaces.of_declarations tables.declared tables.routineDeclarations, ?_⟩
  · rw [fields.1]
    exact known.framed.at_position bounded
  · rw [fields.1]
    exact ⟨known.tables.dynamicFirst, known.tables.names, known.tables.arrayNames⟩
  · rw [states, fields.1]
    exact ⟨reframe known.initial.order rfl rfl (Nat.le_of_lt fields.2.1),
      fun item member => Nat.lt_trans (known.initial.statesBefore item member) fields.2.1,
      known.initial.scalarFields⟩
  · rw [states, fields.1]
    exact known.origin
  · rw [states]
    exact known.declarations
  · rw [states, fields.1]
    exact known.clear
  · rw [states]
    exact known.bounds
  · rw [exports]
    exact fun item member => Nat.lt_trans (known.exports item member) fields.2.1

/-- The actual native completion contract supplies only component typing.
All persistent source/declaration invariants follow from the original frame
history, which changes the global cursor without changing its binding rows. -/
theorem history_frame_facts {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {specText text : Source} {constants : ScalarExpression.Environment}
    {before : UnitState} {rows : List RoutineRead} {result : ApplicationAdmission.BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (known : RoutineFrameFacts specText constants text before.globals before.info)
    (typing : ∀ globals info, ReaderFrame text globals → info.Typed →
      (readCompletion reader calls text globals info).info.Typed) :
    ∀ row ∈ rows,
      RoutineFrameFacts specText constants text row.before.globals row.before.info ∧
      RoutineFrameFacts specText constants text row.result.globals row.result.info := by
  induction history with
  | finished => simp
  | @added row later result phase pending read advanced rest ih =>
    have actual : readCompletion reader calls text row.before.globals row.before.info = row.result := read
    have present : row.result.globals.position ≠ 0 := by omega
    obtain ⟨frames⟩ := RoutineRead.frames read present
    have typed : row.result.info.Typed := actual ▸ typing _ _ known.framed known.typed
    have bounded : row.result.globals.position ≤ text.length + 1 := actual ▸
      readCompletion_bound reader calls text row.before.globals row.before.info
    have next := known.next frames present typed bounded
    have laterFacts := ih next
    intro seen member
    rcases List.mem_cons.mp member with rfl | later
    · exact ⟨known, next⟩
    · exact laterFacts seen later

end Silver.ApplicationPackageRoutineSources
