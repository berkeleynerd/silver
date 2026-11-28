module

public import Silver.ApplicationPackageOriginalRoutineEntries

@[expose] public section

/-! Raw declaration ranges are independent of the normalized initializer
values used by the routine checker. Retain both endpoints of every original
local declaration, at its actual declaration frame and signature metadata. -/
namespace Silver.ApplicationPackageRoutineSources
open Compose Compose.Expressions Packages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageInitializers
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax

/-- One original routine's declaration inventory. The entry frame and metadata
are source data; no checker, obligation or semantic safety fact is stored. -/
structure RoutineLocalHeader where
  routine : RoutineRead
  info : PackageBindings.Metadata
  entry : ParserState
  objects : List (LocalObject × ObjectSyntax)

/-- The original completion fixes the exact signature metadata, entry frame
and complete ordered local history. Each raw range and RHS is read in its own
declaration's incoming frame, before later declarations can hide its names. -/
def RoutineLocalHeader.SourceAt (reader : BooleanElaboration.Native.Reader)
    (calls : CompletionCalls) (text : Source) (header : RoutineLocalHeader) : Prop :=
  ∃ frames : CompletionFrames (declarationReaders reader calls) text
      header.routine.before.globals header.routine.before.info header.routine.result,
    header.info = frames.signature.info ∧ header.entry = frames.entry ∧
      header.objects.map Prod.fst = frames.objects ∧
      ∀ object ∈ header.objects, object.2.SourceAt text object.1.before.frame
        header.info true object.1.object

/-- Exact completion order, including empty headers and unused routines.
This relation contains original source histories only. -/
def RoutineLocalHeadersAt (reader : BooleanElaboration.Native.Reader)
    (calls : CompletionCalls) (text : Source) (rows : List RoutineRead)
    (headers : List RoutineLocalHeader) : Prop :=
  headers.map RoutineLocalHeader.routine = rows ∧
    ∀ header ∈ headers, header.SourceAt reader calls text

def RoutineLocalHeader.obligations (text : Source) (header : RoutineLocalHeader) :
    List Predicate.Obligation :=
  header.objects.flatMap (localObjectObligations text header.info)

def routineLocalHeaderObligations (text : Source) (headers : List RoutineLocalHeader) :
    List Predicate.Obligation :=
  headers.flatMap (RoutineLocalHeader.obligations text)

/-- Construct every raw local header from the original completion witnesses.
Only native reader domains are inputs; complete range/RHS obligation discharge
is a separate conclusion for the constructed source inventory. -/
theorem RoutineEntriesAt.local_headers {reader calls text readers specRows rows entries}
    (source : RoutineEntriesAt reader calls text readers specRows rows entries)
    (valid : ValidText text)
    (known : ∀ row ∈ rows,
      ReaderFrame text row.before.globals ∧ row.before.info.Typed) :
    ∃ headers, RoutineLocalHeadersAt reader calls text rows headers ∧
      Predicate.discharged (routineLocalHeaderObligations text headers) = true := by
  induction source with
  | nil => exact ⟨[], ⟨rfl, by simp⟩, rfl⟩
  | @cons row rows entries frames code pending present rest ih =>
    have native := known row List.mem_cons_self
    obtain ⟨_finalFrame, objects, order, originals, checked⟩ :=
      local_objects_inventory valid (frames.entry_reader valid native.1 native.2)
        frames.declarations (fun _ _ => rfl)
    obtain ⟨headers, tailSource, tailChecked⟩ :=
      ih (fun seen member => known seen (List.mem_cons_of_mem _ member))
    let header : RoutineLocalHeader := ⟨row, frames.signature.info, frames.entry, objects⟩
    refine ⟨header :: headers, ⟨?_, ?_⟩, ?_⟩
    · exact congrArg (List.cons row) tailSource.1
    · intro seen member
      rcases List.mem_cons.mp member with rfl | later
      · exact ⟨frames, rfl, rfl, order, originals⟩
      · exact tailSource.2 seen later
    · change Predicate.discharged
        (header.obligations text ++ routineLocalHeaderObligations text headers) = true
      rw [Predicate.discharged_append, tailChecked]
      exact Bool.and_eq_true_iff.mpr ⟨checked, rfl⟩

/-- Original package history transports all native domains to the exact
completion prefixes. No supplied per-routine checker or safety result is needed
to recover and discharge the omitted raw local declaration schemas. -/
theorem original_package_local_headers {reader : BooleanElaboration.Native.Reader}
    {completion : CompletionCalls} {calls : ApplicationAdmission.Calls}
    {sources : ApplicationUnits.Bundle} {result : ApplicationAdmission.AnalysisResult}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    (valid : sources.Valid)
    (framed : ReaderFrame (sources.prefix .packageBody) parsed.history.routinesStart.globals)
    (typed : parsed.history.routinesStart.info.Typed) (finalTyped : parsed.body.info.Typed)
    {readers : Readers} {specRows : List SpecificationItem} {entries : List SummaryRoutineEntry}
    (originals : RoutineEntriesAt reader completion (sources.prefix .packageBody) readers specRows
      parsed.history.rows entries)
    (typing : ∀ (globals : ParserState) (info : PackageBindings.Metadata),
      ReaderFrame (sources.prefix .packageBody) globals → info.Typed →
      (readCompletion reader completion (sources.prefix .packageBody) globals info).info.Typed) :
    ∃ headers, RoutineLocalHeadersAt reader completion (sources.prefix .packageBody)
        parsed.history.rows headers ∧
      Predicate.discharged
        (routineLocalHeaderObligations (sources.prefix .packageBody) headers) = true := by
  have initial := original_frame_facts parsed valid framed typed finalTyped
  have known := history_frame_facts parsed.history.completions initial typing
  have bodyValid : ValidText (sources.prefix .packageBody) := by
    have extent := sources.prefix_length valid .packageBody
    have bounds := sources.span_bounds valid .packageBody
    have capacity := valid.1.2.1
    unfold ValidText
    rw [extent]
    constructor <;> omega
  exact originals.local_headers bodyValid
    (fun row member => ⟨(known row member).1.framed, (known row member).1.typed⟩)

end Silver.ApplicationPackageRoutineSources
