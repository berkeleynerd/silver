module

public import Silver.ApplicationPackageInitializerInventory
public import Silver.ApplicationPackageUnitObjectHistory
public import Silver.ApplicationPackageCompletionLocalHistory
public import Silver.ApplicationPackageCompletionLayout
public import Silver.PackageInitializationRanges
public import Silver.ApplicationPackageDeclarationsSpecificationStepDomains
public import Silver.ComposeSubtypeChecks

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

end Silver.ApplicationPackageInitializers
