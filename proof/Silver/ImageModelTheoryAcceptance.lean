module

public import Silver.ImageModelDocumentEffects
public import Silver.ImageModelProducerSyntax
public import Silver.ImageModelNormalExact

@[expose] public section
namespace Silver.ImageModel.TheoryNative

/-- The concrete closing checks succeed from eight fields, freshness and an
exact complete match. No scanner-acceptance premise is needed. -/
theorem model_accepts (tables : Native.Tables) (matchCall : DecodedNative.MatchCall) (frame : Frame)
    (good : frame.failed = false) (fields : frame.field = 7)
    (selected : ∀ kind, frame.theory = some kind → frame.seen kind = false ∧
      (matchCall frame.matcher 93).cells kind = ⟨tables.length kind, true⟩) :
    (model tables matchCall frame).failed = false := by
  cases name : frame.theory with
  | none => simp [model, name, fields, good]
  | some kind =>
      obtain ⟨unseen, matched⟩ := selected kind name
      simp [model, name, fields, good, invalid, TheoryNative.selected, unseen, matched]

end Silver.ImageModel.TheoryNative

namespace Silver.ImageModel.ScannerNative

theorem wide_fields_index {index : Nat} {previous pending : Bool}
    {spans : List JSON.FieldSpan} {normalized : List JSON.Value}
    (wide : JSON.WideFields index previous pending spans normalized) :
    ∀ context start, context.field = index → (fieldsScope context start spans).field = 7 := by
  induction wide with
  | last previous pending span normalized fieldNormal =>
      intro context start field
      exact (valueScope_field _ _ _ _).trans field
  | more index previous pending outgoing span normalized spans restNormalized bounded fieldNormal tail ih =>
      intro context start field
      rw [fieldsScope_cons _ _ span spans tail.nonempty.1]
      exact ih _ _ (by change context.field + 1 = index + 1; rw [field])

theorem closed_theory_exact (tables : Native.Tables) (state : Core.State)
    (active : state.matcher.inTheory = true) : ExactEmits tables state (closedTheory tables state) [93] := by
  intro kind
  rw [closed_theory_cells]
  exact (ExactEmits.of_fold tables state ((Core.modelHelpers tables).matchByte state 93) [93] active rfl) kind

theorem closed_theory_accepts (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (fields : state.field = 7)
    (selected : ∀ kind, state.theory = some kind → state.seen kind = false ∧
      (closedTheory tables state).matcher.cells kind = ⟨tables.length kind, true⟩) :
    (closedTheory tables state).failed = false := by
  apply TheoryNative.model_accepts tables (Core.matcher tables) (counted (settled state)).theoryView
  · exact (settled_failed state).trans good
  · exact (congrArg JsonScope.field (settled_scope state)).trans fields
  · intro kind target
    have name : state.theory = some kind :=
      (congrArg JsonScope.theory (settled_scope state)).symm.trans target
    obtain ⟨unseen, matched⟩ := selected kind name
    refine ⟨?_, ?_⟩
    · exact congrFun (congrArg JsonScope.seen (settled_scope state)) kind |>.trans unseen
    · change (Core.matcher tables (settled state).matcher 93).cells kind = _
      rw [settled_matcher, ← closed_theory_cells]
      exact matched

/-- Independent broad producer syntax executes successfully whenever every
selected theory is fresh and its valid erased tree is exactly the selected
template. Other theories retain the broad string/code-unit domain. -/
theorem theory_span_accepts (tables : Native.Tables) (state : Core.State) (span : JSON.TheorySpan)
    (good : state.failed = false) (before : BeforeTheory state)
    (room : state.bytes + span.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes span.spans).length ≤ 9223372036854775807)
    (fresh : ∀ kind, selectedName span.theory.name none = some kind → state.seen kind = false)
    (selected : ∀ kind, selectedName span.theory.name none = some kind →
      JSON.Valid span.theory.value.eraseNodeIds ∧
      span.theory.value.eraseNodeIds.encode.length = tables.length kind ∧
      ∀ index, (bound : index < span.theory.value.eraseNodeIds.encode.length) →
        span.theory.value.eraseNodeIds.encode[index] = tables.byte kind (index + 1)) :
    (span.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false := by
  have openingActive : (openedTheory tables state).matcher.inTheory = true :=
    Native.match_inTheory tables (beginTheory (counted state)).matcher 91 .integer
  have bodyRoom : (openedTheory tables state).bytes + (JSON.fieldsBytes span.spans).length ≤ 9223372036854775807 := by
    change state.bytes + 1 + (JSON.fieldsBytes span.spans).length ≤ _
    simp only [JSON.TheorySpan.bytes, List.length_append, List.length_cons, List.length_nil] at room
    omega
  obtain ⟨body, _⟩ := wide_fields tables 0 true false span.spans span.normalized span.spelling (openedTheory tables state)
    good before.mode rfl before.pending openingActive rfl rfl bodyRoom depthRoom
  let middle := (JSON.fieldsBytes span.spans).foldl (consume (Core.modelHelpers tables)) (openedTheory tables state)
  obtain ⟨run, _, _, _, _⟩ := theory_span_run tables state span good
    before.mode before.pending before.depth before.phase room depthRoom
  have fields : middle.field = 7 :=
    (congrArg JsonScope.field body.context).trans (wide_fields_index span.spelling _ _ rfl)
  have name : middle.theory = selectedName span.theory.name none :=
    (congrArg JsonScope.theory body.context).trans (theory_span_selected tables state span)
  have globals := (congrArg GlobalScope body.context).trans (fieldsScope_global _ _ span.spans)
  have seen : middle.seen = state.seen := congrArg Prod.fst globals
  rw [run]
  apply closed_theory_accepts tables middle body.good fields
  intro kind target
  have named : selectedName span.theory.name none = some kind := name.symm.trans target
  obtain ⟨valid, size, items⟩ := selected kind named
  have normal := span.normal_of_erased_valid valid
  have exactBody := normal_fields_exact tables 0 true false span.spans span.normalized normal (openedTheory tables state)
    good before.mode rfl before.pending openingActive rfl rfl bodyRoom depthRoom
  have opening := ExactEmits.of_fold tables (beginTheory (counted state)) (openedTheory tables state) [91] rfl rfl
  have stream := ((opening.trans exactBody).trans (closed_theory_exact tables middle body.active)) kind
  have encoded : (closedTheory tables middle).matcher.cells kind =
      span.theory.value.eraseNodeIds.encode.foldl (matchByte (tables.byte kind) (tables.length kind)) {} := by
    simpa only [← span.wide_erasure, JSON.Value.encode, List.append_assoc, beginTheory] using stream
  refine ⟨?_, ?_⟩
  · rw [seen]
    exact fresh kind named
  · rw [encoded]
    exact match_fold_complete (tables.byte kind) (tables.length kind) _ size items

end Silver.ImageModel.ScannerNative
