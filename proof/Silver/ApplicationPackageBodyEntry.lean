module

public import Silver.ApplicationPackageExportRows

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageObjectRows
open ApplicationPackageDeclarations ApplicationPackageExportRows ApplicationUnits

def unitReaders (reader : BooleanElaboration.Native.Reader)
    (completion : Source → ParserState → PackageBindings.Metadata → CompletionResult) : UnitCalls where
  validState := ApplicationPackageFrames.stateValid
  packageWord := packageWord
  skipAt := skipAt
  nameAfter := nameAfter
  takeToken := tokenAfter
  sparkPragmaAfter := sparkPragmaAfter
  sameName text := PackageBindings.sameName (metadataText text)
  objectAt text state info isLocal := objectStep (modelObjectCalls reader) text state info isLocal
  completionAt := completion

private structure CursorRead (text : Source) (start stop : Nat) : Prop where
  positive : stop ≠ 0 → start ≠ 0
  moves : stop ≠ 0 → start ≤ text.length + 1 → start < stop ∧ stop ≤ text.length + 1

private theorem CursorRead.follow {text : Source} {start middle stop : Nat}
    (first : CursorRead text start middle) (next : CursorRead text middle stop) : CursorRead text start stop := by
  refine ⟨fun accepted => first.positive (next.positive accepted), ?_⟩
  intro accepted within
  have prior := first.moves (next.positive accepted) within
  have after := next.moves accepted prior.2
  exact ⟨Nat.lt_trans prior.1 after.1, after.2⟩

private theorem fixed_read (text : Source) (position : Nat) (spelling : String) (word : Bool)
    (nonempty : 0 < spelling.toList.length) : CursorRead text position (fixedAfter text position spelling word) :=
  ⟨fixedAfter_nonzero, fun a _ => fixed_window nonempty a⟩

private theorem CursorRead.take {text : Source} {start middle : Nat} (before : CursorRead text start middle)
    (spelling : String) (word : Bool) (nonempty : 0 < spelling.toList.length) :
    CursorRead text start (fixedAfter text middle spelling word) := before.follow (fixed_read text middle spelling word nonempty)

private theorem name_read (text : Source) (position : Nat) :
    CursorRead text position (nameAfter text (skipAt text position)) := by
  constructor
  · intro present zero
    have positive := (model_name_advances text _ present).1
    simp [zero, skipAt] at positive
  · intro present bounded
    have named := model_name_advances text _ present
    exact ⟨Nat.lt_of_le_of_lt (skipAt_advances text position bounded (Nat.ne_of_gt named.1)) named.2,
      model_name_valid text _⟩

private theorem word_read (text : Source) (position : Nat) (spelling : String) :
    CursorRead text position (packageWord text position spelling) := by
  dsimp only [packageWord]
  split
  · exact name_read text position
  · exact ⟨fun zero => False.elim (zero rfl), fun zero => False.elim (zero rfl)⟩

private theorem pragma_read (text : Source) (position : Nat) : CursorRead text position (sparkPragmaAfter text position) :=
  (((((fixed_read text position "pragma" true (by decide)).take "spark_mode" true (by decide)).take "(" false (by decide)).take
    "on" true (by decide)).take ")" false (by decide)).take ";" false (by decide)

private def declarationsStart (text : Source) (start : Nat) : Nat :=
  sparkPragmaAfter text (tokenAfter text (nameAfter text (skipAt text
    (packageWord text (packageWord text start "package") "body"))) (.word "is"))

private theorem body_start (text : Source) (position : Nat) : CursorRead text position (declarationsStart text position) :=
  (((word_read text position "package").follow (word_read text _ "body")).follow
    (name_read text _)).take "is" true (by decide) |>.follow (pragma_read text _)

private def startCursor (calls : UnitCalls) (text : Source) (info : PackageBindings.Metadata) : Nat :=
  calls.sparkPragmaAfter text (calls.takeToken text (calls.nameAfter text (calls.skipAt text
    (calls.packageWord text (calls.packageWord text (info.units .packageBody).first "package") "body"))) (.word "is"))

private theorem startUnit_fields {calls : UnitCalls} {text : Source} {exports : ParserState}
    {info : PackageBindings.Metadata} {state : UnitState}
    (entered : startUnit calls text exports info = .continued state) :
    startCursor calls text info ≠ 0 ∧ state.phase = .objects ∧ state.info.units = info.units ∧
      state.info.states = info.states ∧ state.globals = {exports with position := startCursor calls text info} := by
  dsimp only [startUnit] at entered
  split at entered
  · contradiction
  · split at entered
    · contradiction
    · rename_i present
      cases entered
      exact ⟨present, rfl, rfl, rfl, rfl⟩

structure StateEntry (sources : Bundle) (state : UnitState) : Prop where
  objects : state.phase = .objects
  units : state.info.units = sources.units
  empty : state.info.states = []
  frame : StateFrame state.info.states state.globals
  capacity : state.globals.scalarNames.length ≤ ScalarExpression.maxBindings
  bounded : state.globals.position ≤ (sources.prefix .packageBody).length + 1

private theorem accepted_specification_rows (reader : BooleanElaboration.Native.Reader)
    (text : Source) (info : PackageBindings.Metadata) {result : SpecificationResult}
    (read : readSpecification reader text info = result) (accepted : result.exports.position ≠ 0) :
    ExportRows info result.info result.exports ∧ result.exports.position ≤ text.length + 1 := by
  subst result
  exact specification_rows reader text info accepted

private theorem body_span_bounds {sources : Bundle} (valid : sources.Valid) :
    (sources.prefix .packageSpecification).length + 1 ≤ (sources.units .packageBody).first ∧
      (sources.units .packageBody).first ≤ (sources.prefix .packageBody).length + 1 := by
  have spec := sources.span_bounds valid .packageSpecification
  have body := sources.span_bounds valid .packageBody
  have joined := valid.2.2.2.1
  rw [sources.prefix_length valid .packageSpecification, sources.prefix_length valid .packageBody]
  omega

private theorem body_cursor {reader : BooleanElaboration.Native.Reader}
    {completion : Source → ParserState → PackageBindings.Metadata → CompletionResult}
    {text : Source} {info : PackageBindings.Metadata}
    (present : startCursor (unitReaders reader completion) text info ≠ 0)
    (bounded : (info.units .packageBody).first ≤ text.length + 1) :
    (info.units .packageBody).first < startCursor (unitReaders reader completion) text info ∧
      startCursor (unitReaders reader completion) text info ≤ text.length + 1 := by
  have cursor := body_start text (info.units .packageBody).first
  dsimp only [declarationsStart] at cursor
  dsimp only [startCursor, unitReaders] at present ⊢
  exact cursor.moves present bounded

private theorem exports_at_body {exports : ParserState} (order : FrameOrder exports) (position : Nat)
    (progress : exports.position ≤ position) : StateFrame [] {exports with position} :=
  StateFrame.empty (reframe (after := {exports with position}) order rfl rfl progress)

private theorem StateEntry.of_frame {sources : Bundle} {state : UnitState} {exports : ParserState}
    {position : Nat} (phase : state.phase = .objects) (units : state.info.units = sources.units)
    (empty : state.info.states = []) (globals : state.globals = {exports with position})
    (order : FrameOrder exports) (capacity : exports.scalarNames.length ≤ ScalarExpression.maxBindings)
    (progress : exports.position ≤ position) (bounded : position ≤ (sources.prefix .packageBody).length + 1) :
    StateEntry sources state := by
  refine ⟨phase, units, empty, ?_, ?_, ?_⟩
  · rw [empty, globals]
    exact exports_at_body order position progress
  · rw [globals]
    exact capacity
  · rw [globals]
    exact bounded

/-- The first body frame is built from the actual specification exports.
The exact packed original unit boundary places every export before the first
body declaration; no separator or flattened copy of the units is required. -/
theorem source_state_entry (reader : BooleanElaboration.Native.Reader)
    (completion : Source → ParserState → PackageBindings.Metadata → CompletionResult) (sources : Bundle)
    (valid : sources.Valid) {specification : SpecificationResult} {state : UnitState}
    (specified : readSpecification reader (sources.prefix .packageSpecification) {units := sources.units} = specification)
    (accepted : specification.exports.position ≠ 0)
    (entered : startUnit (unitReaders reader completion) (sources.prefix .packageBody)
      specification.exports specification.info = .continued state) : StateEntry sources state := by
  obtain ⟨fields, bound⟩ := accepted_specification_rows reader _ _ specified accepted
  obtain ⟨adjacent, bodyBound⟩ := body_span_bounds valid
  have next : specification.exports.position ≤ (specification.info.units .packageBody).first := by
    rw [fields.units]
    exact Nat.le_trans bound adjacent
  have within : (specification.info.units .packageBody).first ≤ (sources.prefix .packageBody).length + 1 := by
    rw [fields.units]
    exact bodyBound
  obtain ⟨present, phase, units, states, globals⟩ := startUnit_fields entered
  have advanced := body_cursor (reader := reader) (completion := completion) (info := specification.info)
    (text := sources.prefix .packageBody) present within
  exact StateEntry.of_frame phase (units.trans fields.units) (states.trans fields.states) globals
    fields.order fields.capacity (Nat.le_trans next (Nat.le_of_lt advanced.1)) advanced.2

private theorem cursor_fields {before after : ParserState} {position : Nat}
    (same : after = {before with position}) :
    after.scalarNames = before.scalarNames ∧ after.position = position := by
  cases same
  exact ⟨rfl, rfl⟩

/-- The original packed body starts strictly after the specification, and
the header advances its cursor without changing the exported scalar rows. -/
theorem source_state_entry_positions (reader : BooleanElaboration.Native.Reader)
    (completion : Source → ParserState → PackageBindings.Metadata → CompletionResult) (sources : Bundle)
    (valid : sources.Valid) {specification : SpecificationResult} {state : UnitState}
    (specified : readSpecification reader (sources.prefix .packageSpecification) {units := sources.units} = specification)
    (accepted : specification.exports.position ≠ 0)
    (entered : startUnit (unitReaders reader completion) (sources.prefix .packageBody)
      specification.exports specification.info = .continued state) :
    state.globals.scalarNames = specification.exports.scalarNames ∧
      (sources.prefix .packageSpecification).length < state.globals.position ∧
      (sources.units .packageBody).first < state.globals.position := by
  obtain ⟨fields, _⟩ := accepted_specification_rows reader _ _ specified accepted
  obtain ⟨adjacent, bodyBound⟩ := body_span_bounds valid
  have within : (specification.info.units .packageBody).first ≤ (sources.prefix .packageBody).length + 1 := by
    rw [fields.units]
    exact bodyBound
  obtain ⟨present, _, _, _, globals⟩ := startUnit_fields entered
  have stored := cursor_fields (before := specification.exports)
    (position := startCursor (unitReaders reader completion) (sources.prefix .packageBody) specification.info) globals
  have advanced := body_cursor (reader := reader) (completion := completion) (info := specification.info)
    (text := sources.prefix .packageBody) present within
  have same : (specification.info.units .packageBody).first = (sources.units .packageBody).first :=
    congrArg (fun units => (units .packageBody).first) fields.units
  have afterBody : (sources.units .packageBody).first < state.globals.position := by
    calc
      _ = (specification.info.units .packageBody).first := same.symm
      _ < startCursor (unitReaders reader completion) (sources.prefix .packageBody) specification.info := advanced.1
      _ = state.globals.position := stored.2.symm
  exact ⟨stored.1,
    Nat.lt_trans (Nat.lt_of_lt_of_le (Nat.lt_succ_self _) adjacent) afterBody, afterBody⟩

end Silver.ApplicationPackageBodies
