module

public import Silver.ApplicationPackageInitializerInventory
public import Silver.ApplicationPackageUnitObjectHistory
public import Silver.ApplicationPackageCompletionLocalHistory
public import Silver.ApplicationPackageCompletionLayout
public import Silver.PackageInitializationRanges
public import Silver.PackageInitializerPhases
public import Silver.ApplicationPackageDeclarationsSpecificationStepDomains
public import Silver.ComposeSubtypeChecks
public import Silver.PredicateFunctionCallMeaning
public import Silver.ApplicationPackageRoutineClosedFrames

@[expose] public section

/-! Initializer inventories follow the original declaration histories. Each
RHS keeps the frame entering its own Object call; the final routine frame is
not substituted for an earlier declaration's scope. -/
namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations ApplicationPackageBodies

set_option backward.dsimp.instances true

def stateObjectObligations (text : Source) (entry : StateObject × ObjectSyntax) :
    List Predicate.Obligation :=
  entry.2.obligations text entry.1.before.globals entry.1.before.info false entry.1.object

def localObjectObligations (text : Source) (info : PackageBindings.Metadata)
    (entry : LocalObject × ObjectSyntax) : List Predicate.Obligation :=
  entry.2.obligations text entry.1.before.frame info true entry.1.object

/-- All persistent-state declarations are retained, in source order, together
with their raw range endpoints and initializer syntax. Reader domains and
obligation discharge are conclusions of the original loop. -/
theorem state_objects_inventory {reader : BooleanElaboration.Native.Reader}
    {calls : UnitCalls} {text : Source} {before after : UnitState} {rows : List StateObject}
    (textValid : ValidText text) (framed : ReaderFrame text before.globals)
    (history : StateObjects calls text before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls reader) text row.before.globals row.before.info false) :
    ReaderFrame text after.globals ∧ ∃ entries : List (StateObject × ObjectSyntax),
      entries.map Prod.fst = rows ∧
      (∀ entry ∈ entries, entry.2.SourceAt text entry.1.before.globals entry.1.before.info false entry.1.object) ∧
      Predicate.discharged (entries.flatMap (stateObjectObligations text)) = true := by
  induction history with
  | finished => exact ⟨framed, [], rfl, by simp, rfl⟩
  | @added row following final phase selected capacity parsed advanced writable rest ih =>
    have execution := (original row List.mem_cons_self).symm.trans parsed
    have present : row.object.frame.position ≠ 0 := by omega
    have next := execution ▸ objectStep_reader_frame reader textValid row.before.globals framed
      row.before.info false (execution ▸ present)
    obtain ⟨finalFrame, entries, sameRows, sources, checked⟩ :=
      ih next (fun observed member => original observed (List.mem_cons_of_mem _ member))
    obtain ⟨inventory, source, headChecked⟩ := object_inventory reader text textValid
      row.before.globals framed row.before.info false execution present
    refine ⟨finalFrame, (row, inventory) :: entries, ?_, ?_, ?_⟩
    · simp only [List.map_cons, sameRows]
    · intro entry member
      rcases List.mem_cons.mp member with rfl | later
      · exact source
      · exact sources entry later
    · rw [List.flatMap_cons, Predicate.discharged_append, checked]
      simpa only [stateObjectObligations, Bool.and_true] using headChecked

/-- Every routine-local declaration is recovered at its own source position.
No initializer check or semantic Valid field is required in this inventory. -/
theorem local_objects_inventory {reader : BooleanElaboration.Native.Reader}
    {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {before after : InitializationFrame} {rows : List LocalObject}
    (textValid : ValidText text) (framed : ReaderFrame text before.frame)
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true) :
    ReaderFrame text after.frame ∧ ∃ entries : List (LocalObject × ObjectSyntax),
      entries.map Prod.fst = rows ∧
      (∀ entry ∈ entries, entry.2.SourceAt text entry.1.before.frame info true entry.1.object) ∧
      Predicate.discharged (entries.flatMap (localObjectObligations text info)) = true := by
  induction history with
  | finished => exact ⟨framed, [], rfl, by simp, rfl⟩
  | @added row final following atBegin apart parsed advanced rest ih =>
    have execution := (original row List.mem_cons_self).symm.trans parsed
    have present : row.object.frame.position ≠ 0 := by omega
    have next := execution ▸ objectStep_reader_frame reader textValid row.before.frame framed
      info true (execution ▸ present)
    obtain ⟨finalFrame, entries, sameRows, sources, checked⟩ :=
      ih next (fun observed member => original observed (List.mem_cons_of_mem _ member))
    obtain ⟨inventory, source, headChecked⟩ := object_inventory reader text textValid
      row.before.frame framed info true execution present
    refine ⟨finalFrame, (row, inventory) :: entries, ?_, ?_, ?_⟩
    · simp only [List.map_cons, sameRows]
    · intro entry member
      rcases List.mem_cons.mp member with rfl | later
      · exact source
      · exact sources entry later
    · rw [List.flatMap_cons, Predicate.discharged_append, checked]
      simpa only [localObjectObligations, Bool.and_true] using headChecked

structure OutputObject where
  index : Nat
  before : InitializationFrame
  after : InitializationFrame

/-- Original output-prefix executions. Input formals contribute no initializer.
The source history is separate from all expression-checking conclusions. -/
inductive OutputObjects (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata) :
    List Nat → InitializationFrame → List OutputObject → InitializationFrame → Prop
  | nil {state} : OutputObjects calls text info [] state [] state
  | skipped {index indices state rows final}
      (input : (info.parameterAt index).mode ≠ .output)
      (rest : OutputObjects calls text info indices state rows final) :
      OutputObjects calls text info (index :: indices) state rows final
  | added {row indices rows final}
      (output : (info.parameterAt row.index).mode = .output)
      (read : outputInitializer calls text info (info.parameterAt row.index) row.before = some row.after)
      (rest : OutputObjects calls text info indices row.after rows final) :
      OutputObjects calls text info (row.index :: indices) row.before (row :: rows) final

theorem output_initializers_objects {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {indices : List Nat} {before after : InitializationFrame}
    (run : outputInitializers calls text info indices before = some after) :
    ∃ rows, OutputObjects calls text info indices before rows after := by
  induction indices generalizing before with
  | nil => cases Option.some.inj run; exact ⟨[], .nil⟩
  | cons index indices ih =>
    simp only [outputInitializers, Option.bind_eq_some_iff] at run
    obtain ⟨middle, first, remaining⟩ := run
    by_cases input : (info.parameterAt index).mode ≠ .output
    · have same : before = middle := by
        unfold outputInitializer at first
        rw [ite_eq_left input] at first
        exact Option.some.inj first
      cases same
      obtain ⟨rows, rest⟩ := ih remaining
      exact ⟨rows, .skipped input rest⟩
    · obtain ⟨rows, rest⟩ := ih remaining
      exact ⟨⟨index, before, middle⟩ :: rows,
        .added (row := ⟨index, before, middle⟩) (Classical.not_not.mp input) first rest⟩

theorem OutputObjects.order {calls text info indices before rows after}
    (history : OutputObjects calls text info indices before rows after) :
    rows.map OutputObject.index = indices.filter (fun index => decide ((info.parameterAt index).mode = .output)) := by
  induction history with
  | nil => rfl
  | skipped input rest ih => simpa only [List.filter_cons, input, decide_false, Bool.false_eq_true, ↓reduceIte] using ih
  | added output read rest ih => simp only [List.map_cons, List.filter_cons, output, decide_true, ↓reduceIte, ih]

/-- Cursors advance through the output prefix, but no output row is appended
until every RHS has been read. Thus later RHSs retain the pre-output scope. -/
theorem OutputObjects.preappend {calls text info indices before rows after}
    (history : OutputObjects calls text info indices before rows after) :
    SameDeclarations before.frame after.frame ∧
      ∀ row ∈ rows, SameDeclarations before.frame row.before.frame := by
  induction history with
  | nil => exact ⟨.refl _, by simp⟩
  | skipped _ _ ih => exact ih
  | added _ read _ ih =>
    have same := outputInitializer_sameDeclarations read
    refine ⟨same.trans ih.1, ?_⟩
    intro row member
    rcases List.mem_cons.mp member with rfl | later
    · exact .refl _
    · exact same.trans (ih.2 row later)

def OutputObject.context (calls : CompletionCalls) (row : OutputObject) : ParseContext :=
  {calls.contextOf ⟨row.before.frame, false, false⟩ with declarationCount := 0}

def OutputObject.valueFirst (calls : CompletionCalls) (text : Source) (row : OutputObject) : Nat :=
  calls.takeToken text (calls.nameAfter text (calls.skipAt text row.before.frame.position)) (.symbol ":=")

def OutputObject.formal (info : PackageBindings.Metadata) (row : OutputObject) : FunctionBindings.Formal :=
  let parameter := info.parameterAt row.index
  ⟨parameter.bodyName.first, parameter.bodyName.after, parameter.kind, parameter.bounds, 0⟩

def OutputObject.valueAfter (calls : CompletionCalls) (text : Source)
    (info : PackageBindings.Metadata) (row : OutputObject) : Nat :=
  calls.actualAfter text (row.context calls) (row.valueFirst calls text)
    (calls.initialFlow (row.context calls)) (row.formal info)

theorem OutputObject.declarationCount (calls : CompletionCalls) (row : OutputObject) :
    (row.context calls).declarationCount = 0 := rfl

theorem OutputObjects.reads {calls text info indices before rows after}
    (history : OutputObjects calls text info indices before rows after) :
    ∀ row ∈ rows, (info.parameterAt row.index).mode = .output ∧
      outputInitializer calls text info (info.parameterAt row.index) row.before = some row.after := by
  induction history with
  | nil => simp
  | skipped _ _ ih => exact ih
  | added output read _ ih =>
    intro row member
    rcases List.mem_cons.mp member with rfl | later
    · exact ⟨output, read⟩
    · exact ih row later

structure SubtypeSyntax where
  low : Integer.Expr
  high : Integer.Expr
  lower : ScalarExpression.Result
  upper : ScalarExpression.Result

def SubtypeSyntax.SourceAt (text : Source) (state : ParserState) (inventory : SubtypeSyntax) : Prop :=
  let first := fixedAfter text (subtypeDeclarationParts text state).typeAfter "range" true
  let second := fixedAfter text inventory.lower.after ".." false
  ScalarExpression.ArrayGrammar.read text first state.scalarNames state.arrayNames.table = inventory.lower ∧
    ScalarExpression.ArrayGrammar.SourceAt text state.scalarNames state.arrayNames.table 0 0 .allElements true
      first ⟨inventory.lower.after, inventory.low⟩ ∧
    ScalarExpression.ArrayGrammar.read text second state.scalarNames state.arrayNames.table = inventory.upper ∧
    ScalarExpression.ArrayGrammar.SourceAt text state.scalarNames state.arrayNames.table 0 0 .allElements true
      second ⟨inventory.upper.after, inventory.high⟩

def SubtypeSyntax.obligations (state : ParserState) (inventory : SubtypeSyntax) : List Predicate.Obligation :=
  let ranges := ArrayBindings.viewRanges state.arrayNames.names [] false (ScalarExpression.ranges state.scalarNames)
  (inventory.low.obligations ranges ++ inventory.high.obligations ranges).map .scalar

theorem subtype_inventory {text : Source} {arguments : Bool} {state next : ParserState}
    (reading : SubtypeDeclarationAt text arguments state next) :
    ∃ inventory : SubtypeSyntax, inventory.SourceAt text state ∧
      Predicate.discharged (inventory.obligations state) = true := by
  obtain ⟨checks, low, high, lower, upper, lowRead, highRead, rfl⟩ := subtype_declaration_checks_trace reading
  refine ⟨⟨low, high, lower, upper⟩,
    ⟨ScalarExpression.ArrayGrammar.read_complete lowRead, lowRead.source,
      ScalarExpression.ArrayGrammar.read_complete highRead, highRead.source⟩, ?_⟩
  change Predicate.discharged ((low.obligations _ ++ high.obligations _).map .scalar) = true
  rw [Predicate.scalar_discharged]
  exact subtype_declaration_checks_discharge ⟨low, high, lower, upper, lowRead, highRead, rfl⟩

inductive SpecificationSyntax where
  | routine
  | subtype (inventory : SubtypeSyntax)
  | object (out : ObjectResult) (inventory : ObjectSyntax)

def SpecificationSyntax.SourceAt (reader : BooleanElaboration.Native.Reader) (text : Source)
    (before after : SpecificationState) : SpecificationSyntax → Prop
  | .routine => specificationRoutine (modelSpecificationCalls reader) text before = .next after
  | .subtype inventory => specificationSubtype (modelSpecificationCalls reader) text before = .next after ∧
      inventory.SourceAt text before.exports
  | .object out inventory => specificationObject (modelSpecificationCalls reader) text before = .next after ∧
      objectStep (modelObjectCalls reader) text before.exports before.info false = out ∧
      inventory.SourceAt text before.exports before.info false out

def SpecificationSyntax.obligations (text : Source) (before : SpecificationState) :
    SpecificationSyntax → List Predicate.Obligation
  | .routine => []
  | .subtype inventory => inventory.obligations before.exports
  | .object out inventory => inventory.obligations text before.exports before.info false out

/-- Every successful specification continuation contributes its original source
item, including subtype declarations that allocate no runtime value cell. -/
theorem specification_next_inventory (reader : BooleanElaboration.Native.Reader) {text : Source}
    (textValid : ValidText text) {before after : SpecificationState}
    (framed : ReaderFrame text before.exports)
    (step : specificationStep (modelSpecificationCalls reader) text before = .next after) :
    ∃ inventory : SpecificationSyntax, inventory.SourceAt reader text before after ∧
      Predicate.discharged (inventory.obligations text before) = true := by
  dsimp only [specificationStep] at step
  split at step
  · contradiction
  · split at step
    · exact ⟨.routine, step, rfl⟩
    · split at step
      · contradiction
      · split at step
        · have original := step
          dsimp only [specificationSubtype, modelSpecificationCalls] at step
          split at step
          · contradiction
          · rename_i present
            obtain ⟨inventory, source, checked⟩ := subtype_inventory
              (subtype_declaration_sound text before.exports false present)
            exact ⟨.subtype inventory, ⟨original, source⟩, checked⟩
        · have original := step
          dsimp only [specificationObject, modelSpecificationCalls] at step
          split at step
          · contradiction
          · rename_i accepted
            have present : (objectStep (modelObjectCalls reader) text before.exports before.info false).frame.position ≠ 0 :=
              fun missing => accepted (by simp only [missing, decide_true, Bool.true_or])
            obtain ⟨inventory, source, checked⟩ := object_inventory reader text textValid before.exports framed
              before.info false rfl present
            exact ⟨.object _ inventory, ⟨original, rfl, source⟩, checked⟩

structure SpecificationItem where
  before : SpecificationState
  after : SpecificationState
  inventory : SpecificationSyntax

/-- Exact specification execution with a syntax-only inventory at every
successful continuation. Terminal reader histories remain explicit. -/
inductive SpecificationInventories (reader : BooleanElaboration.Native.Reader) (text : Source) :
    SpecificationState → List SpecificationItem → SpecificationExit → Prop
  | returned {state result} (step : specificationStep (modelSpecificationCalls reader) text state = .returned result) :
      SpecificationInventories reader text state [] (.returned result)
  | ready {state final} (step : specificationStep (modelSpecificationCalls reader) text state = .ready final) :
      SpecificationInventories reader text state [] (.ready final)
  | next {row rows exit}
      (step : specificationStep (modelSpecificationCalls reader) text row.before = .next row.after)
      (source : row.inventory.SourceAt reader text row.before row.after)
      (rest : SpecificationInventories reader text row.after rows exit) :
      SpecificationInventories reader text row.before (row :: rows) exit

def specificationObligations (text : Source) (rows : List SpecificationItem) : List Predicate.Obligation :=
  rows.flatMap fun row => row.inventory.obligations text row.before

theorem specification_loop_inventory (reader : BooleanElaboration.Native.Reader) {text : Source}
    (textValid : ValidText text) {state : SpecificationState} {exit : SpecificationExit}
    (framed : ReaderFrame text state.exports)
    (run : SpecificationLoop (modelSpecificationCalls reader) text state exit) :
    ∃ rows, SpecificationInventories reader text state rows exit ∧
      Predicate.discharged (specificationObligations text rows) = true := by
  induction run with
  | returned step => exact ⟨[], .returned step, rfl⟩
  | ready step => exact ⟨[], .ready step, rfl⟩
  | @next before after exit step rest ih =>
    have next : ReaderFrame text after.exports := by
      have result := specification_step_framed reader textValid before framed
      rw [step] at result
      exact result
    obtain ⟨rows, history, checked⟩ := ih next
    obtain ⟨inventory, source, headChecked⟩ := specification_next_inventory reader textValid framed step
    refine ⟨⟨before, after, inventory⟩ :: rows, .next (row := ⟨before, after, inventory⟩) step source history, ?_⟩
    simp only [specificationObligations, List.flatMap_cons, Predicate.discharged_append] at checked ⊢
    rw [headChecked, checked]
    rfl

/-- Global declaration elaboration retains exact original values. This uses
the Object singleton guard and the actual appended rows, independently of the
Ada staticness flag and of the declared target interval. -/
theorem object_global_elaborated (reader : BooleanElaboration.Native.Reader) (text : Source)
    (frame : ParserState) (info : PackageBindings.Metadata) {out : ObjectResult}
    (static : ScalarExpression.ElaboratedEnvironment frame.scalarNames)
    (parsed : objectStep (modelObjectCalls reader) text frame info false = out)
    (present : out.frame.position ≠ 0) : ScalarExpression.ElaboratedEnvironment out.frame.scalarNames := by
  have added := (ApplicationPackageObjectRows.objectStep_rows reader text frame info false
    (parsed ▸ present)).2
  rw [parsed] at added
  have base : ScalarExpression.ElaboratedEnvironment
      (ApplicationPackageObjectRows.initializerBase text frame info
        (ApplicationPackageObjectRows.objectName text frame) false).scalarNames := static
  cases kind : out.mark.kind with
  | integer =>
      obtain ⟨_, rows, _⟩ := added.integerStorage kind
      rw [rows]
      exact ScalarExpression.elaborated_append base (object_global_singleton reader text frame info parsed present)
  | boolean =>
      obtain ⟨_, _, rows⟩ := added.booleanStorage kind
      rw [rows]
      exact base

private theorem continue_specification_elaborated {calls : SpecificationCalls} {text : Source}
    {before : Nat} {state after : SpecificationState}
    (static : ScalarExpression.ElaboratedEnvironment state.exports.scalarNames)
    (run : continueSpecification calls text before state = .next after) :
    ScalarExpression.ElaboratedEnvironment after.exports.scalarNames := by
  unfold continueSpecification at run
  split at run
  · contradiction
  · cases SpecificationStep.next.inj run
    exact static

theorem SpecificationSyntax.elaborated {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before after : SpecificationState} {inventory : SpecificationSyntax}
    (source : inventory.SourceAt reader text before after)
    (static : ScalarExpression.ElaboratedEnvironment before.exports.scalarNames) :
    ScalarExpression.ElaboratedEnvironment after.exports.scalarNames := by
  cases inventory with
  | routine =>
      change specificationRoutine (modelSpecificationCalls reader) text before = .next after at source
      dsimp only [specificationRoutine] at source
      split at source
      · contradiction
      · apply continue_specification_elaborated (run := source)
        exact static
  | subtype inventory =>
      have run := source.1
      dsimp only [specificationSubtype, modelSpecificationCalls] at run
      split at run
      · contradiction
      · rename_i present
        have rows := (subtype_declaration_preserves
          (subtype_declaration_sound text before.exports false present)).2.1
        split at run
        · contradiction
        · unfold appendExport at run
          apply continue_specification_elaborated (run := run)
          simpa only [rows] using static
  | object out inventory =>
      have run := source.1
      dsimp only [specificationObject, modelSpecificationCalls] at run
      split at run
      · contradiction
      · rename_i accepted
        have present : (objectStep (modelObjectCalls reader) text before.exports before.info false).frame.position ≠ 0 :=
          fun missing => accepted (by simp only [missing, decide_true, Bool.true_or])
        unfold appendExport at run
        exact continue_specification_elaborated
          (object_global_elaborated reader text before.exports before.info static rfl present) run

def specificationExitElaborated : SpecificationExit → Prop
  | .returned _ => True
  | .ready final => ScalarExpression.ElaboratedEnvironment final.exports.scalarNames

/-- The public scalar environment remains exact through every original
specification item. Its final values can seed imported execution only after
the separate raw initializer evaluation theorems identify those values. -/
theorem SpecificationInventories.elaborated {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before : SpecificationState} {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories reader text before rows exit)
    (static : ScalarExpression.ElaboratedEnvironment before.exports.scalarNames) :
    (∀ row ∈ rows, ScalarExpression.ElaboratedEnvironment row.before.exports.scalarNames) ∧
      specificationExitElaborated exit := by
  induction history with
  | returned => exact ⟨by simp, trivial⟩
  | @ready state final step =>
      have same : state = final := by
        dsimp only [specificationStep] at step
        split at step
        · exact SpecificationStep.ready.inj step
        · split at step
          · dsimp only [specificationRoutine, continueSpecification] at step
            split at step <;> (try contradiction)
            split at step <;> contradiction
          · split at step
            · contradiction
            · split at step
              · dsimp only [specificationSubtype, appendExport, continueSpecification] at step
                split at step <;> (try contradiction)
                split at step <;> (try contradiction)
                split at step <;> contradiction
              · dsimp only [specificationObject, appendExport, continueSpecification] at step
                split at step <;> (try contradiction)
                split at step <;> contradiction
      exact ⟨by simp, same ▸ static⟩
  | next step source rest ih =>
      obtain ⟨following, final⟩ := ih (SpecificationSyntax.elaborated source static)
      refine ⟨?_, final⟩
      intro row member
      rcases List.mem_cons.mp member with rfl | later
      · exact static
      · exact following row later

theorem imported_elaborated (exports : ParserState) (info : PackageBindings.Metadata) (position : Nat)
    (static : ScalarExpression.ElaboratedEnvironment exports.scalarNames) :
    ScalarExpression.ElaboratedEnvironment
      (ApplicationPackageFrames.importedFrameRaw exports info position).scalarNames := by
  intro row member
  obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
  exact static original present

open Packages ApplicationPackageFrameLayout

def integerRangeAt (ranges : SharedRanges) : Address → Option Integer.Interval
  | .global identity => ranges.globals identity
  | .local identity => ranges.locals identity

/-- Active bindings are related by their original declaration identity, so
Hide_Outer may compact parser slots without changing their semantic cells. -/
def ScalarRangeRows (info : PackageBindings.Metadata) (ranges : SharedRanges)
    (names : ScalarExpression.Environment) : Prop :=
  ∀ row ∈ names, integerRangeAt ranges
    (rowAddress info .integer ⟨row.first, row.after, row.qualifierFirst, row.qualifierAfter⟩) = some row.bounds

theorem ScalarRangeRows.retain {info ranges before after}
    (rows : ScalarRangeRows info ranges before) (kept : after.Sublist before) :
    ScalarRangeRows info ranges after := fun row member => rows row (kept.subset member)

theorem ScalarRangeRows.view_active {info : PackageBindings.Metadata} {ranges : SharedRanges}
    {context : ParseContext} (rows : ScalarRangeRows info ranges context.scalarNames)
    (bound index : Nat) (active : 0 < index ∧ index ≤ context.scalarNames.length) :
    ranges.view (layout bound info context) index = ScalarExpression.ranges context.scalarNames index := by
  have within : index - 1 < context.scalarNames.length := by omega
  have selected := rows context.scalarNames[index - 1] (List.getElem_mem within)
  change integerRangeAt ranges (slotAddress bound info .integer (scalarRows context) index) = _
  have live : 0 < index ∧ index ≤ (scalarRows context).length := by
    simpa only [scalarRows, List.length_map] using active
  rw [slotAddress, ite_eq_left live, ScalarExpression.ranges, ite_eq_left active]
  have chosen : (scalarRows context).getD (index - 1) {} =
      ⟨context.scalarNames[index - 1].first, context.scalarNames[index - 1].after,
        context.scalarNames[index - 1].qualifierFirst, context.scalarNames[index - 1].qualifierAfter⟩ := by
    simp only [scalarRows, List.getD_eq_getElem?_getD, List.getElem?_map,
      List.getElem?_eq_getElem within, Option.map_some, Option.getD_some]
  rw [chosen]
  simpa only [ScalarExpression.binding, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem within, Option.getD_some] using selected

private theorem scalarExpression_of_readsOnly {expression : Integer.Expr} {allowed : Nat → Prop}
    (reads : expression.ReadsOnly allowed) : ScalarFunctions.scalarExpression expression = true := by
  induction expression with
  | literal | snapshot | name => rfl
  | indexed => contradiction
  | positive _ ih | negative _ ih | parenthesized _ ih => exact ih reads
  | add _ _ ihl ihr | subtract _ _ ihl ihr | multiply _ _ ihl ihr
    | divide _ _ ihl ihr | modulo _ _ ihl ihr | remainder _ _ ihl ihr =>
      exact Bool.and_eq_true_iff.mpr ⟨ihl reads.1, ihr reads.2⟩

def scalarInitializer (bound : Nat) (info : PackageBindings.Metadata)
    (base : ParserState) (out : ObjectResult) (expression : Integer.Expr) : LocalInitializer where
  target := .integer out.name.first
  domain := .integer (if out.constantObject then out.initialBounds else out.mark.bounds)
  value := .integer expression
  layout := layout bound info (booleanInitializerContext base out.name.first out.name.after)
  analysis := (booleanInitializerContext base out.name.first out.name.after).analysis
  booleans := BooleanBindings.analysis base.booleanNames

/-- The existing LocalInitializer consumer checks the original raw Integer
expression under its own source layout. Immutable domains retain the inferred
snapshot interval; original target containment is still derived separately. -/
theorem ValueCalls.scalar_initializer {text : Source} {base : ParserState} {first last : Nat}
    {out : ObjectResult} (calls : ValueCalls text base first last out)
    (kind : out.mark.kind = .integer) (bound : Nat) (info : PackageBindings.Metadata)
    (ranges : SharedRanges) (rows : ScalarRangeRows info ranges base.scalarNames) :
    ∃ expression,
      ScalarExpression.sourceSyntaxAt text base.scalarNames [] first last true out.initFirst
        ⟨out.initAfter, expression⟩ ∧
      (scalarInitializer bound info base out expression).Readable ∧
      (scalarInitializer bound info base out expression).check ranges =
        some {ranges with locals := Integer.put ranges.locals out.name.first (some out.initialBounds)} ∧
      out.initialBounds.included out.mark.bounds = true := by
  obtain ⟨expression, reading, inferred, _, nonempty, included⟩ := calls.scalar_inventory kind
  have reads := ScalarExpression.syntax_readsOnly reading.grammar
  have shaped := scalarExpression_of_readsOnly reads
  have same := Integer.Expr.infer_readsOnly reads
    (fun index active => ScalarRangeRows.view_active
      (context := booleanInitializerContext base out.name.first out.name.after) rows bound index active)
  have model : expression.infer (ranges.view
      (layout bound info (booleanInitializerContext base out.name.first out.name.after))) = some out.initialBounds :=
    same.trans inferred
  have target : out.initialBounds.included
      (if out.constantObject then out.initialBounds else out.mark.bounds) = true := by
    cases fixed : out.constantObject
    · exact included
    · simp [Integer.Interval.included, nonempty]
  refine ⟨expression, ?_, trivial, ?_, included⟩
  · simpa only [(calls.scalar kind).1] using reading.grammar
  · have admitted : ScalarFunctions.scalarActual
        (scalarInitializer bound info base out expression).value = true := shaped
    simp only [LocalInitializer.check, admitted, ite_true]
    change (expression.infer (ranges.view
      (layout bound info (booleanInitializerContext base out.name.first out.name.after)))).bind
        (fun bounds => if !bounds.isEmpty && bounds.included
          (if out.constantObject then out.initialBounds else out.mark.bounds) then
            some {ranges with locals := Integer.put ranges.locals out.name.first (some bounds)}
          else none) = _
    rw [model]
    simp only [Option.bind_some, nonempty, Bool.not_false, target, Bool.and_self, ite_true]

def LocalRangesBound (bound : Nat) (ranges : SharedRanges) : Prop :=
  ∀ identity, bound < identity → ranges.locals identity = none

theorem ScalarRangeRows.view_eq {info : PackageBindings.Metadata} {ranges : SharedRanges}
    {context : ParseContext} {bound : Nat} (rows : ScalarRangeRows info ranges context.scalarNames)
    (bounded : LocalRangesBound bound ranges) :
    ranges.view (layout bound info context) = ScalarExpression.ranges context.scalarNames := by
  funext index
  by_cases active : 0 < index ∧ index ≤ context.scalarNames.length
  · exact rows.view_active bound index active
  · have inactive : ¬ (0 < index ∧ index ≤ (scalarRows context).length) := by
      simpa only [scalarRows, List.length_map] using active
    change integerRangeAt ranges (slotAddress bound info .integer (scalarRows context) index) = _
    rw [slotAddress, ite_eq_right inactive, ScalarExpression.ranges, ite_eq_right active]
    exact bounded _ (by omega)

def booleanInitializer (bound : Nat) (info : PackageBindings.Metadata)
    (base : ParserState) (out : ObjectResult) (condition : Condition) : LocalInitializer where
  target := .boolean out.name.first
  domain := .boolean
  value := .boolean condition
  layout := layout bound info (booleanInitializerContext base out.name.first out.name.after)
  analysis := (booleanInitializerContext base out.name.first out.name.after).analysis
  booleans := BooleanBindings.analysis base.booleanNames

/-- The raw Boolean initializer keeps its full original short-circuit reading.
Its existing semantic consumer checks the same original analysis and flow;
closed scalar frames and stable range correspondence supply the bridge. -/
theorem ValueCalls.boolean_initializer {text : Source} {base : ParserState} {out : ObjectResult}
    (calls : ValueCalls text base out.name.first out.name.after out)
    (textValid : ValidText text) (framed : ReaderFrame text base)
    (kind : out.mark.kind = .boolean) (bound : Nat) (info : PackageBindings.Metadata)
    (ranges : SharedRanges) (rows : ScalarRangeRows info ranges base.scalarNames)
    (bounded : LocalRangesBound bound ranges)
    (pure : base.pure = true) (noArguments : base.dynamicFirst = 0)
    (noStrings : base.names = []) (noArrays : base.arrayNames.names = []) :
    ∃ condition result,
      ConditionAt text (booleanInitializerContext base out.name.first out.name.after) out.initFirst
        (booleanInitializerFacts base) condition result base.arrayNames.values ∧
      result.after = out.initAfter ∧
      (booleanInitializer bound info base out condition).Readable ∧
      (booleanInitializer bound info base out condition).check ranges = some ranges ∧
      Predicate.discharged (booleanObligations base out.name.first out.name.after condition) = true := by
  obtain ⟨condition, result, reading, after, meaning, discharged⟩ :=
    calls.boolean_inventory textValid framed kind
  let context := booleanInitializerContext base out.name.first out.name.after
  have closed : ClosedFunctionContext context := by
    apply ClosedFunctionContext.ofEmpty pure
    · simp only [context, booleanInitializerContext, noArguments, ne_eq, not_true_eq_false, decide_false]
    · exact noStrings
    · exact noArrays
  have shape := condition_source_scalar closed reading
  have oldFlow : context.flow (booleanInitializerFacts base) base.arrayNames.values =
      ⟨ScalarFunctions.entryContext, ScalarExpression.ranges base.scalarNames⟩ := by
    simp only [context, ParseContext.flow, booleanInitializerContext, booleanInitializerFacts,
      noArguments, ne_eq, not_true_eq_false, ite_false, ActiveFlow.initial_model,
      noArrays, ArrayBindings.viewRanges, ArrayBindings.viewNames, List.map_nil,
      ArrayBindings.viewElaborating, List.any_nil, Bool.not_false, Bool.and_true,
      ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil,
      ArrayBindings.ranges_nil]
    rfl
  have same := ScalarRangeRows.view_eq (context := context) rows bounded
  have readable : (booleanInitializer bound info base out condition).Readable := by
    refine ⟨meaning.grammatical, ?_⟩
    simpa only [LocalInitializer.Readable, booleanInitializer, ScalarFunctions.Actual.Readable,
      booleanInitializerContext, noArguments, ne_eq, not_true_eq_false, decide_false,
      noStrings, empty_names_shape, noArrays, ArrayBindings.booleanAnalysis,
      ArrayBindings.booleanNames, List.filter_nil, List.any_nil, Bool.false_or,
      List.find?_nil] using meaning.readable
  have checked : condition.checkBounds Bindings.emptyShape context.analysis
      ⟨ScalarFunctions.entryContext, ranges.view (layout bound info context)⟩
      (BooleanBindings.analysis base.booleanNames) = true := by
    have original := meaning.checked
    change condition.checkBounds context.names.shape context.analysis
      (context.flow (booleanInitializerFacts base) base.arrayNames.values)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = true at original
    rw [oldFlow] at original
    rw [same]
    simpa only [context, booleanInitializerContext, noStrings, empty_names_shape,
      noArrays, ArrayBindings.booleanAnalysis, ArrayBindings.booleanNames,
      List.filter_nil, List.any_nil, Bool.false_or, List.find?_nil] using original
  refine ⟨condition, result, reading, after, readable, ?_, discharged⟩
  have admitted : ScalarFunctions.scalarActual
      (booleanInitializer bound info base out condition).value = true := shape
  simp only [LocalInitializer.check, admitted, ite_true]
  change (if condition.checkBounds Bindings.emptyShape context.analysis
      ⟨ScalarFunctions.entryContext, ranges.view (layout bound info context)⟩
      (BooleanBindings.analysis base.booleanNames) then some ranges else none) = some ranges
  rw [ite_eq_left checked]

/-- Each output RHS is recovered at its original preappend scope and initial
flow. The nonzero result is derived from the following semicolon's progress
guard, rather than assumed as an extra initializer certificate. -/
theorem OutputObject.actual {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {row : OutputObject}
    (textValid : ValidText text) (take : calls.takeToken = tokenAfter)
    (actual : calls.actualAfter = Predicate.actualAfter)
    (names : ValidNames text (row.context calls).names)
    (output : (info.parameterAt row.index).mode = .output)
    (run : outputInitializer calls text info (info.parameterAt row.index) row.before = some row.after) :
    ∃ value, ActualAt text (row.context calls) (row.valueFirst calls text)
      (calls.initialFlow (row.context calls)) (row.formal info) value
      (row.valueAfter calls text info) := by
  have firstBound : row.valueFirst calls text ≤ text.length + 1 := by
    rw [OutputObject.valueFirst, take]
    exact fixedAfter_result_bound text _ ":=" false (by decide)
  have present : row.valueAfter calls text info ≠ 0 := by
    dsimp only [outputInitializer] at run
    simp only [output, ne_eq, not_true_eq_false, ite_false] at run
    split at run
    · contradiction
    · split at run
      · contradiction
      · split at run
        · contradiction
        · rename_i advanced
          have semi : calls.takeToken text (row.valueAfter calls text info) (.symbol ";") ≠ 0 := by
            change ¬ calls.takeToken text (row.valueAfter calls text info) (.symbol ";") ≤ row.before.frame.position at advanced
            omega
          rw [take] at semi
          exact fixedAfter_nonzero semi
  have accepted : Predicate.actualAfter text (row.context calls) (row.valueFirst calls text)
      (calls.initialFlow (row.context calls)) (row.formal info) ≠ 0 := by
    simpa only [OutputObject.valueAfter, actual] using present
  obtain ⟨value, reading⟩ := actual_sound textValid names firstBound accepted
  exact ⟨value, by simpa only [OutputObject.valueAfter, actual] using reading⟩

theorem ScalarRangeRows.put_local {info : PackageBindings.Metadata} {ranges : SharedRanges}
    {names : ScalarExpression.Environment} {identity : Nat} (bounds : Integer.Interval)
    (rows : ScalarRangeRows info ranges names)
    (fresh : ∀ row ∈ names, row.first ≠ identity) :
    ScalarRangeRows info {ranges with locals := Integer.put ranges.locals identity (some bounds)} names := by
  intro row member
  have original := rows row member
  cases selected : stateIndex info .integer
      ⟨row.first, row.after, row.qualifierFirst, row.qualifierAfter⟩ with
  | none =>
      simpa only [integerRangeAt, rowAddress, selected, Integer.put, fresh row member, ite_false] using original
  | some global =>
      simpa only [integerRangeAt, rowAddress, selected] using original

theorem ScalarRangeRows.append_local {info : PackageBindings.Metadata} {ranges : SharedRanges}
    {names : ScalarExpression.Environment} {row : ScalarExpression.Binding}
    (rows : ScalarRangeRows info ranges names)
    (fresh : ∀ prior ∈ names, prior.first ≠ row.first)
    (localRow : rowAddress info .integer
      ⟨row.first, row.after, row.qualifierFirst, row.qualifierAfter⟩ = .local row.first) :
    ScalarRangeRows info {ranges with locals := Integer.put ranges.locals row.first (some row.bounds)}
      (names ++ [row]) := by
  intro item member
  rcases List.mem_append.mp member with prior | added
  · exact rows.put_local row.bounds fresh item prior
  · cases List.mem_singleton.mp added
    simp only [localRow, integerRangeAt, Integer.put, ite_true]

theorem LocalRangesBound.put_local {bound identity : Nat} {ranges : SharedRanges}
    (bounds : Integer.Interval) (prior : LocalRangesBound bound ranges) (inside : identity ≤ bound) :
    LocalRangesBound bound {ranges with locals := Integer.put ranges.locals identity (some bounds)} := by
  intro other outside
  have apart : other ≠ identity := by omega
  simp only [Integer.put, apart, ite_false]
  exact prior other outside

def objectRanges (ranges : SharedRanges) (out : ObjectResult) : SharedRanges :=
  match out.mark.kind with
  | .integer => {ranges with locals := Integer.put ranges.locals out.name.first (some out.initialBounds)}
  | .boolean => ranges

def objectDeclaredRanges (ranges : SharedRanges) (out : ObjectResult) : SharedRanges :=
  match out.mark.kind with
  | .integer => {ranges with locals := Integer.put ranges.locals out.name.first (some
      (if out.constantObject then out.initialBounds else out.mark.bounds))}
  | .boolean => ranges

open ApplicationPackageObjectRows

/-- The new source declaration follows every persistent-state name. Its stable
identity therefore denotes an invocation-local cell, even after Hide_Outer. -/
theorem object_local_address {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    (prior : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) (kind : FunctionBindings.ScalarKind) :
    rowAddress info kind ⟨out.name.first, out.name.after, 0, 0⟩ = .local out.name.first := by
  have positions := parsed ▸ objectStep_positions reader text frame info true (parsed ▸ present)
  cases selected : stateIndex info kind ⟨out.name.first, out.name.after, 0, 0⟩ with
  | none => simp only [rowAddress, selected]
  | some identity =>
    have active := stateIndex_some selected
    have earlier := prior.statesBefore _ (info.stateAt_mem identity active.1 active.2.1)
    have same := active.2.2.2.2.1
    change (info.stateAt identity).name.first = out.name.first at same
    rw [same] at earlier
    have fresh := positions.1
    exact False.elim (by omega)

/-- Original Object storage advances the inferred and declared semantic maps
in parallel. Retained rows keep their exact fields; mutable rows are widened
only in the separate bodyEnvironment view. -/
theorem object_range_rows {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    {ranges declared : SharedRanges} (prior : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0)
    (rows : ScalarRangeRows info ranges frame.scalarNames)
    (domains : ScalarRangeRows info declared (ScalarExpression.bodyEnvironment frame.scalarNames)) :
    ScalarRangeRows info (objectRanges ranges out) out.frame.scalarNames ∧
      ScalarRangeRows info (objectDeclaredRanges declared out)
        (ScalarExpression.bodyEnvironment out.frame.scalarNames) := by
  obtain ⟨storage, kept, _⟩ := objectStep_storage parsed present
  have positions := parsed ▸ objectStep_positions reader text frame info true (parsed ▸ present)
  have fresh : ∀ row ∈ (initializerBase text frame info out.name true).scalarNames,
      row.first ≠ out.name.first := by
    intro row member
    exact Nat.ne_of_lt (Nat.lt_of_lt_of_le (prior.order.scalar_before (kept.subset member)) positions.1)
  have localRow := object_local_address prior parsed present .integer
  cases kind : out.mark.kind with
  | integer =>
    simp only [objectRanges, objectDeclaredRanges, kind]
    obtain ⟨static, installed, _⟩ := storage.integerStorage kind
    rw [installed]
    constructor
    · exact (rows.retain kept).append_local fresh localRow
    · have declaredKept := domains.retain (kept.map ScalarExpression.bodyBinding)
      have freshBody : ∀ row ∈ ScalarExpression.bodyEnvironment
          (initializerBase text frame info out.name true).scalarNames, row.first ≠ out.name.first := by
        intro row member
        obtain ⟨original, included, rfl⟩ := List.mem_map.mp member
        exact fresh original included
      have appended := declaredKept.append_local
        (row := ScalarExpression.bodyBinding
          ⟨out.name.first, out.name.after, out.initialBounds, static, out.mark.bounds, !out.constantObject, 0, 0⟩)
        freshBody localRow
      cases fixed : out.constantObject <;>
        simpa only [objectDeclaredRanges, kind, ScalarExpression.bodyEnvironment,
          List.map_append, List.map_cons, List.map_nil, ScalarExpression.bodyBinding,
          fixed, Bool.not_false, Bool.not_true, ite_true, Bool.false_eq_true, ite_false] using appended
  | boolean =>
    simp only [objectRanges, objectDeclaredRanges, kind]
    obtain ⟨_, _, unchanged⟩ := storage.booleanStorage kind
    rw [unchanged]
    exact ⟨rows.retain kept, domains.retain (kept.map ScalarExpression.bodyBinding)⟩

theorem object_range_bounds {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    {ranges declared : SharedRanges}
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0)
    (bounded : LocalRangesBound text.length ranges) (domains : LocalRangesBound text.length declared) :
    LocalRangesBound text.length (objectRanges ranges out) ∧
      LocalRangesBound text.length (objectDeclaredRanges declared out) := by
  have positions := parsed ▸ objectStep_positions reader text frame info true (parsed ▸ present)
  have inside : out.name.first ≤ text.length := by omega
  cases kind : out.mark.kind with
  | integer =>
    simp only [objectRanges, objectDeclaredRanges, kind]
    exact ⟨bounded.put_local _ inside, domains.put_local _ inside⟩
  | boolean =>
    simpa only [objectRanges, objectDeclaredRanges, kind] using And.intro bounded domains

/-- Only the original value syntax and its own preappend frame are retained.
Readability and successful semantic checking are derived below. -/
inductive LocalValueAt (bound : Nat) (info : PackageBindings.Metadata) (text : Source)
    (frame : ParserState) (out : ObjectResult) : LocalInitializer → Prop
  | integer {expression : Integer.Expr} (kind : out.mark.kind = .integer)
      (reading : ScalarExpression.sourceSyntaxAt text
        (initializerBase text frame info out.name true).scalarNames []
        out.name.first out.name.after true out.initFirst ⟨out.initAfter, expression⟩) :
      LocalValueAt bound info text frame out
        (scalarInitializer bound info (initializerBase text frame info out.name true) out expression)
  | boolean {condition : Condition} {result : ConditionResult}
      (kind : out.mark.kind = .boolean)
      (reading : ConditionAt text
        (booleanInitializerContext (initializerBase text frame info out.name true) out.name.first out.name.after)
        out.initFirst (booleanInitializerFacts (initializerBase text frame info out.name true)) condition result
        (initializerBase text frame info out.name true).arrayNames.values)
      (after : result.after = out.initAfter) :
      LocalValueAt bound info text frame out
        (booleanInitializer bound info (initializerBase text frame info out.name true) out condition)

theorem LocalValueAt.declare {bound info text frame out item}
    (source : LocalValueAt bound info text frame out item) (ranges : SharedRanges) :
    item.declare ranges = objectDeclaredRanges ranges out := by
  cases source with
  | integer kind reading =>
    simp only [LocalInitializer.declare, scalarInitializer, extendRanges, objectDeclaredRanges, kind]
  | boolean kind reading after =>
    simp only [LocalInitializer.declare, booleanInitializer, extendRanges, objectDeclaredRanges, kind]

theorem object_local_initializer {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult} {ranges : SharedRanges}
    (textValid : ValidText text) (framed : ReaderFrame text frame)
    (closed : ApplicationPackageRoutineClosedFrames.Closed frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0)
    (rows : ScalarRangeRows info ranges frame.scalarNames) (bounded : LocalRangesBound text.length ranges) :
    ∃ item, LocalValueAt text.length info text frame out item ∧ item.Readable ∧
      item.check ranges = some (objectRanges ranges out) := by
  have live := parsed ▸ present
  obtain ⟨_, storage⟩ := objectStep_rows reader text frame info true live
  have name : out.name = objectName text frame := by simpa only [parsed] using storage.nameEq
  have calls := parsed ▸ object_value_calls reader text frame framed info true live
  have baseFrame := object_initializer_frame reader text frame framed info true live
  have baseClosed := ApplicationPackageRoutineClosedFrames.initializerBase_closed closed live
  have baseRows := rows.retain (initializerBase_retained reader text frame info true live).1
  rw [← name] at calls baseFrame baseClosed baseRows
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨expression, reading, readable, checked, _⟩ := calls.scalar_initializer kind text.length info ranges baseRows
    exact ⟨_, .integer kind reading, readable, by simpa only [objectRanges, kind] using checked⟩
  | boolean =>
    obtain ⟨condition, result, reading, after, readable, checked, _⟩ :=
      calls.boolean_initializer textValid baseFrame kind text.length info ranges baseRows bounded
        baseClosed.pure baseClosed.dynamicFirst baseClosed.names baseClosed.arrayNames
    exact ⟨_, .boolean kind reading after, readable, by simpa only [objectRanges, kind] using checked⟩

def localRanges (ranges : SharedRanges) (rows : List LocalObject) : SharedRanges :=
  rows.foldl (fun current row => objectRanges current row.object) ranges

def localDeclaredRanges (ranges : SharedRanges) (rows : List LocalObject) : SharedRanges :=
  rows.foldl (fun current row => objectDeclaredRanges current row.object) ranges

inductive LocalValuesAt (bound : Nat) (info : PackageBindings.Metadata) (text : Source) :
    List LocalObject → List LocalInitializer → Prop
  | nil : LocalValuesAt bound info text [] []
  | cons {row item rows items}
      (source : LocalValueAt bound info text row.before.frame row.object item)
      (rest : LocalValuesAt bound info text rows items) :
      LocalValuesAt bound info text (row :: rows) (item :: items)

/-- Source declaration order derives the complete existing initializer pass.
The current map follows inference; the declared map follows source domains.
Neither map is supplied as an admission certificate. -/
theorem local_objects_initializers {reader : BooleanElaboration.Native.Reader}
    {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {routine : PackageBindings.Routine} {before after : InitializationFrame} {rows : List LocalObject}
    {ranges declared : SharedRanges}
    (textValid : ValidText text) (framed : ReaderFrame text before.frame)
    (closed : ApplicationPackageRoutineClosedFrames.Closed before.frame)
    (ordered : StateFrame info.states before.frame)
    (history : LocalObjects calls text info routine before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true)
    (currentRows : ScalarRangeRows info ranges before.frame.scalarNames)
    (declaredRows : ScalarRangeRows info declared (ScalarExpression.bodyEnvironment before.frame.scalarNames))
    (currentBound : LocalRangesBound text.length ranges) (declaredBound : LocalRangesBound text.length declared) :
    ∃ items : List LocalInitializer,
      LocalValuesAt text.length info text rows items ∧
      (∀ item ∈ items, item.Readable) ∧
      checkInitializers ranges items = some (localRanges ranges rows) ∧
      initializerDomains declared items = localDeclaredRanges declared rows ∧
      ScalarRangeRows info (localRanges ranges rows) after.frame.scalarNames ∧
      ScalarRangeRows info (localDeclaredRanges declared rows) (ScalarExpression.bodyEnvironment after.frame.scalarNames) ∧
      LocalRangesBound text.length (localRanges ranges rows) ∧
      LocalRangesBound text.length (localDeclaredRanges declared rows) := by
  induction history generalizing ranges declared with
  | finished => exact ⟨[], .nil, by simp, rfl, rfl, currentRows, declaredRows, currentBound, declaredBound⟩
  | @added row final following atBegin apart parsed advanced rest ih =>
    have execution := (original row List.mem_cons_self).symm.trans parsed
    have present : row.object.frame.position ≠ 0 := by omega
    obtain ⟨item, source, readable, checked⟩ :=
      object_local_initializer textValid framed closed execution present currentRows currentBound
    have nextFrame := execution ▸ objectStep_reader_frame reader textValid row.before.frame framed info true
      (execution ▸ present)
    have nextClosed : ApplicationPackageRoutineClosedFrames.Closed row.object.frame := by
      rw [← execution]
      exact (ApplicationPackageRoutineClosedFrames.objectStep_retains rfl (execution ▸ present)).closed closed
    have nextOrder := ordered.after_object execution present
    have nextRows := object_range_rows ordered execution present currentRows declaredRows
    have nextBounds := object_range_bounds execution present currentBound declaredBound
    obtain ⟨items, sources, readables, checking, domains, finalRows, finalDomains, finalBound, finalDeclaredBound⟩ :=
      ih nextFrame nextClosed nextOrder
        (fun observed member => original observed (List.mem_cons_of_mem _ member))
        nextRows.1 nextRows.2 nextBounds.1 nextBounds.2
    refine ⟨item :: items, .cons source sources, ?_, ?_, ?_, finalRows, finalDomains, finalBound, finalDeclaredBound⟩
    · intro observed member
      rcases List.mem_cons.mp member with rfl | later
      · exact readable
      · exact readables observed later
    · simpa only [checkInitializers, checked, Option.bind_some, localRanges, List.foldl_cons] using checking
    · simpa only [initializerDomains, source.declare, localDeclaredRanges, List.foldl_cons] using domains

def objectCell (out : ObjectResult) : Cell :=
  match out.mark.kind with
  | .integer => .integer out.name.first
  | .boolean => .boolean out.name.first

def objectMutableCells (out : ObjectResult) : List Cell :=
  if out.constantObject then [] else [objectCell out]

def mutableLocalCells (rows : List LocalObject) : List Cell :=
  rows.flatMap (fun row => objectMutableCells row.object)

/-- Inference changes only cells selected for the later native widening.
Hidden cells remain in the map and satisfy the same exact equality. -/
def RangesAgreeOutside (current declared : SharedRanges) (mutable : List Cell) : Prop :=
  current.globals = declared.globals ∧
    ∀ identity, .integer identity ∉ mutable → current.locals identity = declared.locals identity

theorem RangesAgreeOutside.refl (ranges : SharedRanges) (mutable : List Cell) :
    RangesAgreeOutside ranges ranges mutable := ⟨rfl, fun _ _ => rfl⟩

theorem RangesAgreeOutside.widen_eq {current declared : SharedRanges} {mutable : List Cell}
    (same : RangesAgreeOutside current declared mutable) : current.widenLocals declared mutable = declared := by
  have locals : (current.widenLocals declared mutable).locals = declared.locals := by
    funext identity
    by_cases selected : .integer identity ∈ mutable
    · exact SharedRanges.widenLocals_selected _ _ _ selected
    · exact (SharedRanges.widenLocals_unselected _ _ _ selected).trans (same.2 identity selected)
  cases current
  cases declared
  cases same.1
  exact congrArg (SharedRanges.mk _) locals

theorem RangesAgreeOutside.object {current declared : SharedRanges} {mutable : List Cell}
    (same : RangesAgreeOutside current declared mutable) (out : ObjectResult) :
    RangesAgreeOutside (objectRanges current out) (objectDeclaredRanges declared out)
      (mutable ++ objectMutableCells out) := by
  constructor
  · cases kind : out.mark.kind <;> simpa only [objectRanges, objectDeclaredRanges, kind] using same.1
  · intro identity outside
    have prior : .integer identity ∉ mutable := fun selected => outside (List.mem_append_left _ selected)
    have added : .integer identity ∉ objectMutableCells out := fun selected => outside (List.mem_append_right _ selected)
    cases kind : out.mark.kind with
    | integer =>
      cases fixed : out.constantObject with
      | false =>
        have apart : identity ≠ out.name.first := by
          intro equal
          apply added
          simp only [objectMutableCells, fixed, Bool.false_eq_true, ite_false, objectCell,
            kind, List.mem_singleton, equal]
        simpa only [objectRanges, objectDeclaredRanges, kind, Integer.put, apart, ite_false] using same.2 identity prior
      | true =>
        by_cases equal : identity = out.name.first
        · simp only [objectRanges, objectDeclaredRanges, kind, fixed, ite_true, Integer.put, equal]
        · simpa only [objectRanges, objectDeclaredRanges, kind, Integer.put, equal, ite_false] using same.2 identity prior
    | boolean => simpa only [objectRanges, objectDeclaredRanges, kind] using same.2 identity prior

theorem RangesAgreeOutside.locals {current declared : SharedRanges} {mutable : List Cell}
    (same : RangesAgreeOutside current declared mutable) (rows : List LocalObject) :
    RangesAgreeOutside (localRanges current rows) (localDeclaredRanges declared rows)
      (mutable ++ mutableLocalCells rows) := by
  induction rows generalizing current declared mutable with
  | nil => simpa only [localRanges, localDeclaredRanges, mutableLocalCells, List.foldl_nil,
      List.flatMap_nil, List.append_nil] using same
  | cons row rows ih =>
    simpa only [localRanges, localDeclaredRanges, mutableLocalCells, List.foldl_cons,
      List.flatMap_cons, List.append_assoc] using ih (same.object row.object)

/-- This is exactly the native local-to-output bodyEnvironment phase. The
equality covers the full maps, including source cells hidden by shadowing. -/
theorem local_ranges_widen (ranges : SharedRanges) (rows : List LocalObject) :
    (localRanges ranges rows).widenLocals (localDeclaredRanges ranges rows) (mutableLocalCells rows) =
      localDeclaredRanges ranges rows := by
  have same := (RangesAgreeOutside.refl ranges []).locals rows
  simpa only [List.nil_append] using same.widen_eq

end Silver.ApplicationPackageInitializers
