module

public import Silver.ImageModelDocumentEntries

@[expose] public section
namespace Silver.ImageModel.TheoryNative

theorem model_seen (tables : Native.Tables) (matchCall : DecodedNative.MatchCall) (frame : Frame) (kind : Native.Theory) :
    (model tables matchCall frame).seen kind = if frame.theory = some kind then true else frame.seen kind := by
  cases name : frame.theory with
  | none => simp [model, name]
  | some selected =>
      simp only [model, name, Option.isSome_some, ↓reduceIte, TheoryNative.selected, Option.getD_some]
      by_cases same : kind = selected <;> simp_all [eq_comm]

theorem model_offsets (tables : Native.Tables) (matchCall : DecodedNative.MatchCall) (frame : Frame) :
    (model tables matchCall frame).declarations = (if frame.theory = some .image then frame.candidateDeclarations else frame.declarations) ∧
    (model tables matchCall frame).includes = (if frame.theory = some .image then frame.candidateIncludes else frame.includes) := by
  cases name : frame.theory <;> simp [model, name]

end Silver.ImageModel.TheoryNative

namespace Silver.ImageModel.ScannerNative

def GlobalScope (context : JsonScope) := (context.seen, context.declarations, context.includes)

theorem valueScope_global (context : JsonScope) (start : Nat) (value : JSON.Value) (length : Nat) :
    GlobalScope (valueScope context start value length) = GlobalScope context := by cases value <;> rfl

theorem fieldsScope_global (context : JsonScope) (start : Nat) (spans : List JSON.FieldSpan) :
    GlobalScope (fieldsScope context start spans) = GlobalScope context := by
  induction spans generalizing context start with
  | nil => rfl
  | cons span spans ih =>
      cases spans with
      | nil => exact valueScope_global context _ span.value _
      | cons next rest =>
          rw [fieldsScope_cons context start span (next :: rest) (by simp), ih]
          exact valueScope_global context _ span.value _

theorem closed_theory_seen (tables : Native.Tables) (state : Core.State) (kind : Native.Theory) :
    (closedTheory tables state).seen kind = if state.theory = some kind then true else state.seen kind := by
  have result := TheoryNative.model_seen tables (Core.matcher tables) (counted (settled state)).theoryView kind
  change (closedTheory tables state).seen kind = _ at result
  rw [show (counted (settled state)).theoryView.theory = state.theory from congrArg JsonScope.theory (settled_scope state),
    show (counted (settled state)).theoryView.seen = state.seen from congrArg JsonScope.seen (settled_scope state)] at result
  exact result

theorem closed_theory_offsets (tables : Native.Tables) (state : Core.State) :
    (closedTheory tables state).declarations = (if state.theory = some .image then state.candidateDeclarations else state.declarations) ∧
    (closedTheory tables state).includes = (if state.theory = some .image then state.candidateIncludes else state.includes) := by
  have result := TheoryNative.model_offsets tables (Core.matcher tables) (counted (settled state)).theoryView
  change (closedTheory tables state).declarations = _ ∧ (closedTheory tables state).includes = _ at result
  rw [show (counted (settled state)).theoryView.theory = state.theory from congrArg JsonScope.theory (settled_scope state),
    show (counted (settled state)).theoryView.candidateDeclarations = state.candidateDeclarations from congrArg JsonScope.candidateDeclarations (settled_scope state),
    show (counted (settled state)).theoryView.candidateIncludes = state.candidateIncludes from congrArg JsonScope.candidateIncludes (settled_scope state),
    show (counted (settled state)).theoryView.declarations = state.declarations from congrArg JsonScope.declarations (settled_scope state),
    show (counted (settled state)).theoryView.includes = state.includes from congrArg JsonScope.includes (settled_scope state)] at result
  exact result

theorem closed_theory_unseen (tables : Native.Tables) (state : Core.State) (kind : Native.Theory)
    (selected : state.theory = some kind) (accepted : (closedTheory tables state).failed = false) : state.seen kind = false := by
  have name : (counted (settled state)).theoryView.theory = some kind :=
    (congrArg JsonScope.theory (settled_scope state)).trans selected
  have result := (TheoryNative.successful_selected tables (Core.matcher tables) (counted (settled state)).theoryView kind name accepted).2.1
  have seen := congrArg JsonScope.seen (settled_scope state)
  change (settled state).seen = state.seen at seen
  change (settled state).seen kind = false at result
  rw [seen] at result
  exact result

/-- The only persistent list effects are the decoded selected-name seen bit and
Image's exact candidate offsets. Successful repeated selections are impossible. -/
theorem theory_span_effects (tables : Native.Tables) (state : Core.State) (span : JSON.TheorySpan)
    (good : state.failed = false) (before : BeforeTheory state)
    (room : state.bytes + span.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes span.spans).length ≤ 9223372036854775807)
    (accepted : (span.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    let final := span.bytes.foldl (consume (Core.modelHelpers tables)) state
    let context := fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) span.spans
    (∀ kind, final.seen kind = if selectedName span.theory.name none = some kind then true else state.seen kind) ∧
      final.declarations = (if selectedName span.theory.name none = some .image then context.candidateDeclarations else state.declarations) ∧
      final.includes = (if selectedName span.theory.name none = some .image then context.candidateIncludes else state.includes) ∧
      (∀ kind, selectedName span.theory.name none = some kind → state.seen kind = false) := by
  obtain ⟨run, context, _, _, _⟩ := theory_span_run tables state span good before.mode before.pending before.depth before.phase room depthRoom
  let middle := (JSON.fieldsBytes span.spans).foldl (consume (Core.modelHelpers tables)) (openedTheory tables state)
  have globals := (congrArg GlobalScope context).trans (fieldsScope_global _ _ span.spans)
  have seen : middle.seen = state.seen := congrArg Prod.fst globals
  have declarations : middle.declarations = state.declarations := congrArg (fun g => g.2.1) globals
  have includes : middle.includes = state.includes := congrArg (fun g => g.2.2) globals
  have name : middle.theory = selectedName span.theory.name none :=
    (congrArg JsonScope.theory context).trans (theory_span_selected tables state span)
  have candidateDeclarations : middle.candidateDeclarations =
      (fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) span.spans).candidateDeclarations :=
    congrArg JsonScope.candidateDeclarations context
  have candidateIncludes : middle.candidateIncludes =
      (fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) span.spans).candidateIncludes :=
    congrArg JsonScope.candidateIncludes context
  rw [run] at accepted ⊢
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro kind
    rw [closed_theory_seen, name, seen]
  · rw [(closed_theory_offsets tables middle).1, name, declarations, candidateDeclarations]
  · rw [(closed_theory_offsets tables middle).2, name, includes, candidateIncludes]
  · intro kind selected
    rw [← seen]
    exact closed_theory_unseen tables middle kind (name.trans selected) accepted


def entryScope (tables : Native.Tables) (state : Core.State) (entry : JSON.TheoryEntry) : JsonScope :=
  fieldsScope (scope (openedTheory tables {state with bytes := state.bytes + entry.leading.length}))
    (state.bytes + entry.leading.length + 1) entry.span.spans

theorem theory_entry_effects (tables : Native.Tables) (state : Core.State) (entry : JSON.TheoryEntry)
    (good : state.failed = false) (before : BeforeTheory state)
    (room : state.bytes + entry.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (accepted : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    let final := entry.bytes.foldl (consume (Core.modelHelpers tables)) state
    (∀ kind, final.seen kind = if selectedName entry.span.theory.name none = some kind then true else state.seen kind) ∧
      final.declarations = (if selectedName entry.span.theory.name none = some .image then (entryScope tables state entry).candidateDeclarations else state.declarations) ∧
      final.includes = (if selectedName entry.span.theory.name none = some .image then (entryScope tables state entry).candidateIncludes else state.includes) ∧
      (∀ kind, selectedName entry.span.theory.name none = some kind → state.seen kind = false) := by
  obtain ⟨run, finalGood, _, _, _, _⟩ := theory_entry_run tables state entry good before room depthRoom accepted
  have effects := theory_span_effects tables {state with bytes := state.bytes + entry.leading.length} entry.span good
    ⟨before.mode, before.depth, before.pending, before.phase⟩
    (by change state.bytes + entry.leading.length + entry.span.bytes.length ≤ _
        simp only [JSON.TheoryEntry.bytes, List.length_append] at room; omega) depthRoom finalGood
  rw [run]
  exact effects

end Silver.ImageModel.ScannerNative
