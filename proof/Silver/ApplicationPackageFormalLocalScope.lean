module

public import Silver.ApplicationPackageFormalEntry

@[expose] public section

namespace Silver.ApplicationPackageFormalStorage
open Compose ApplicationPackageBodies ApplicationPackageDeclarations ApplicationPackageObjectRows ApplicationPackageFrameLayout
open PackageBindings (Formal)

private theorem before_later {pos next : Nat} {rows : List Row} (prior : BeforeCursor pos rows) (later : pos ≤ next) :
    BeforeCursor next rows := ⟨prior.ordered, fun row member => Nat.lt_of_lt_of_le (prior.before row member) later⟩

theorem LocalFrame.reposition {states outputs} {frame : ParserState} {position : Nat}
    (prior : LocalFrame states outputs frame) (later : frame.position ≤ position) :
    LocalFrame states outputs {frame with position} :=
  ⟨⟨⟨before_later prior.source.order.1 later, before_later prior.source.order.2 later⟩,
    fun state member => Nat.lt_of_lt_of_le (prior.source.statesBefore state member) later, prior.source.scalarFields⟩,
    fun formal member => Nat.lt_of_lt_of_le (prior.outputBefore formal member) later,
    prior.scalarApart, prior.flagApart, prior.outputOrder, prior.distinctStates⟩

private theorem apart_installed {prior kept : List Row} {outputs : List Formal} {fresh : Row}
    (apart : Apart prior outputs) (retained : kept.Sublist prior)
    (later : ∀ formal ∈ outputs, formal.bodyName.first < fresh.first) (selected : Prop) [Decidable selected] :
    Apart (kept ++ (if selected then [fresh] else [])) outputs := by
  intro row present formal member
  rcases List.mem_append.mp present with existing | installed
  · exact apart row (retained.subset existing) formal member
  · split at installed
    · cases List.mem_singleton.mp installed
      exact Nat.ne_of_gt (later formal member)
    · contradiction

theorem LocalFrame.after_object {reader : BooleanElaboration.Native.Reader} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata} {out : ObjectResult} {outputs : List Formal}
    (prior : LocalFrame info.states outputs frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) : LocalFrame info.states outputs out.frame := by
  have positions := parsed ▸ objectStep_positions reader text frame info true (parsed ▸ present)
  obtain ⟨storage, keepInts, keepFlags⟩ := objectStep_storage parsed present
  have later (formal : Formal) (member : formal ∈ outputs) : formal.bodyName.first < (reference out.name).first :=
    Nat.lt_of_lt_of_le (prior.outputBefore formal member) positions.1
  refine ⟨prior.source.after_object parsed present, ?_, ?_, ?_, prior.outputOrder, prior.distinctStates⟩
  · intro formal member
    exact Nat.lt_trans (later formal member) (Nat.lt_trans positions.2.1 positions.2.2.1)
  · rw [storage.integers]
    exact apart_installed prior.scalarApart (keepInts.map _) later _
  · rw [storage.flags]
    exact apart_installed prior.flagApart (keepFlags.map _) later _

theorem LocalFrame.locals {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {before after : InitializationFrame} {rows : List LocalObject} {outputs : List Formal}
    (prior : LocalFrame info.states outputs before.frame)
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true) :
    LocalFrame info.states outputs after.frame := by
  induction history with
  | finished => exact prior
  | @added row final following atBegin apart parsed advanced rest ih =>
    apply ih (prior.after_object ((original row List.mem_cons_self).symm.trans parsed) (by omega))
    exact fun seen member => original seen (List.mem_cons_of_mem _ member)

theorem LocalFrame.initializers {states outputs} {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {indices : List Nat} {before after : InitializationFrame}
    (prior : LocalFrame states outputs before.frame)
    (run : outputInitializers calls text info indices before = some after) : LocalFrame states outputs after.frame := by
  obtain ⟨same, advanced⟩ := outputInitializers_frame indices run
  rw [same]
  exact prior.reposition advanced

end Silver.ApplicationPackageFormalStorage
