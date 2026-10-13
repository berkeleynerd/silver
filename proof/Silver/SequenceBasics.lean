module

public import Silver.SequenceTokens

@[expose] public section

set_option backward.dsimp.instances true

namespace Silver.Sequence
open Compose Bindings

inductive BasicEvents : BasicKind → List Event → SimpleStatement → Prop
  | null : BasicEvents .null [] .null
  | output (expression) : BasicEvents .output [.output expression] (.output expression)
  | assignment (update) : BasicEvents .assignment [.assignment update] (.assign update)

theorem basic_events_sound (kind : BasicKind) (events : List Event)
    (shape : events.map Event.kind = kind.tokens.filterMap ShellToken.eventKind) :
    ∃ item, BasicEvents kind events item := by
  cases kind with
  | null =>
      have empty : events = [] := List.map_eq_nil_iff.mp shape
      subst events
      exact ⟨.null, .null⟩
  | output =>
      cases events with
      | nil => contradiction
      | cons event rest =>
          change event.kind :: rest.map Event.kind = [.output] at shape
          have same : event.kind = .output ∧ rest = [] := by
            simpa only [List.cons.injEq, List.map_eq_nil_iff] using shape
          rcases same with ⟨same, rfl⟩
          cases event <;> simp only [Event.kind] at same
          all_goals try contradiction
          exact ⟨_, .output _⟩
  | assignment =>
      cases events with
      | nil => contradiction
      | cons event rest =>
          change event.kind :: rest.map Event.kind = [.assignment] at shape
          have same : event.kind = .assignment ∧ rest = [] := by
            simpa only [List.cons.injEq, List.map_eq_nil_iff] using shape
          rcases same with ⟨same, rfl⟩
          cases event <;> simp only [Event.kind] at same
          all_goals try contradiction
          exact ⟨_, .assignment _⟩

structure BasicAt (text : Source) (scan : ScanResult) (item : SimpleStatement)
    (next : ScanResult) : Prop where
  scanned : basicStatementAt text scan = next
  reading : ∃ events, TokensAt text .direct (basicKind text scan).tokens scan.state events next.state ∧
    BasicEvents (basicKind text scan) events item

theorem basic_scanned {text scan item next} (parsed : BasicAt text scan item next) :
    basicStatementAt text scan = next := parsed.scanned

theorem basic_positive {text scan item next} (parsed : BasicAt text scan item next) :
    scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  obtain ⟨_, tokens, _⟩ := parsed.reading
  exact tokens_positive tokens

theorem basic_reduction {text : Source} {scan : ScanResult}
    (accepted : (basicStatementAt text scan).state.position ≠ 0) :
    basicStatementAt text scan = basicRaw text scan := by
  unfold basicStatementAt at *
  split <;> rename_i h
  · simp [h, invalidScan, invalidState] at accepted
  · split <;> rename_i h₂
    · simp [h, h₂, invalidScan, invalidState] at accepted
    · rfl

theorem basic_sound (text : Source) (scan : ScanResult)
    (accepted : (basicStatementAt text scan).state.position ≠ 0) :
    ∃ item, BasicAt text scan item (basicStatementAt text scan) := by
  have same := basic_reduction accepted
  have positive : (scanTokens text .direct (basicKind text scan).tokens scan).state.position ≠ 0 := by
    simpa only [same, basicRaw] using accepted
  obtain ⟨events, tokens⟩ := tokens_sound text .direct (basicKind text scan).tokens scan positive
  obtain ⟨item, decoded⟩ := basic_events_sound _ _ (tokens_kinds tokens)
  exact ⟨item, rfl, events, by simpa only [same, basicRaw] using tokens, decoded⟩

theorem basic_unique {text scan left right a b}
    (first : BasicAt text scan left a) (second : BasicAt text scan right b) :
    left = right ∧ a = b := by
  obtain ⟨_, firstTokens, one⟩ := first.reading
  obtain ⟨_, secondTokens, two⟩ := second.reading
  obtain ⟨events, _⟩ := tokens_unique firstTokens secondTokens
  have same := first.scanned.symm.trans second.scanned
  refine ⟨?_, same⟩
  rw [← events] at two
  generalize basicKind text scan = kind at one two
  cases one <;> cases two <;> rfl

theorem basic_shape_tokens (kind : BasicKind) :
    ∀ token ∈ kind.tokens, ShapeToken token := by
  cases kind <;> simp [BasicKind.tokens, outputTokens, assignmentTokens,
    ShapeToken, ShellToken.word, ShellToken.symbol]

theorem basic_valid {text scan item next}
    (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
    (parsed : BasicAt text scan item next) :
    StateValid next.state ∧ item.Valid scan.state.names.shape scan.state.capacity ∧
      next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
  obtain ⟨_, tokens, decoded⟩ := parsed.reading
  obtain ⟨nextValid, validity⟩ := tokens_valid domain tokens valid
  have stream := validity [] trivial
  simp only [List.append_nil] at stream
  have shapes := tokens_shape (basic_shape_tokens _) tokens
  refine ⟨nextValid, ?_, shapes⟩
  generalize basicKind text scan = kind at decoded
  cases decoded with
  | null => trivial
  | output => exact stream.1
  | assignment => exact ⟨stream.1, stream.2.1⟩

end Silver.Sequence
