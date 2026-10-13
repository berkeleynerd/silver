module

public import Silver.SequenceGrammar

@[expose] public section

/-! The three outer shells have distinct concrete prefixes: direct/argument
contexts differ at `procedure`/`with`, and the two guards at `then`/`and`.
This permits exact routing to the unique accepted shell. -/

namespace Silver.Sequence
open Compose

def firstSpellingByte (word : String) : Nat := (word.toList.headD ' ').toNat

theorem fixed_step_first {text : Source} {form : Compose.Form} {spelling : String} {word : Bool}
    {state next : ParserState} {event : Option Event}
    (nonempty : spelling.toList ≠ [])
    (parsed : StepAt text form (.fixed spelling word) state next event) :
    lowercase (Cursor.byteAt text (Cursor.triviaPosition text state.position)) = firstSpellingByte spelling := by
  have positive := parsed.following
  rw [← parsed.scanned] at positive
  have matched : fixedAt text (Cursor.triviaPosition text state.position) spelling word = true := by
    by_cases matched : fixedAt text (Cursor.triviaPosition text state.position) spelling word = true
    · exact matched
    · simp [step, parsed.positive, fixedAfter, matched] at positive
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at matched
  cases letters : spelling.toList with
  | nil => exact False.elim (nonempty letters)
  | cons first rest =>
      have byte := matched.1.2 ⟨0, by simp [letters]⟩
      simpa [firstSpellingByte, letters] using byte

inductive PrefixConflict (firstForm secondForm : Compose.Form) :
    List ShellToken → List ShellToken → Prop
  | mismatch {first second : String} {firstWord secondWord : Bool} {left right : List ShellToken} :
      first.toList ≠ [] → second.toList ≠ [] → firstSpellingByte first ≠ firstSpellingByte second →
      PrefixConflict firstForm secondForm (.fixed first firstWord :: left) (.fixed second secondWord :: right)
  | common {token left right} :
      (∀ text state, step text firstForm token state = step text secondForm token state) →
      PrefixConflict firstForm secondForm left right →
      PrefixConflict firstForm secondForm (token :: left) (token :: right)

theorem prefix_conflict_impossible {text : Source} {firstForm secondForm : Compose.Form}
    {left right : List ShellToken} (conflict : PrefixConflict firstForm secondForm left right)
    {state : ParserState} {firstEvents secondEvents : List Event} {firstFinal secondFinal : ParserState}
    (a : TokensAt text firstForm left state firstEvents firstFinal)
    (b : TokensAt text secondForm right state secondEvents secondFinal) : False := by
  induction conflict generalizing state firstEvents secondEvents with
  | mismatch firstNonempty secondNonempty different =>
      cases a with
      | next first _ =>
          cases b with
          | next second _ =>
              exact different ((fixed_step_first firstNonempty first).symm.trans
                (fixed_step_first secondNonempty second))
  | common same _ ih =>
      cases a with
      | next first following =>
          cases b with
          | next second rest =>
              have equal := first.scanned.symm.trans ((same text state).trans second.scanned)
              cases equal
              exact ih following rest

theorem distinct_form_prefixes (first second : Form) (different : first ≠ second) :
    PrefixConflict first.helper second.helper first.prefix second.prefix := by
  cases first <;> cases second
  all_goals try contradiction
  all_goals repeat apply PrefixConflict.common (by intros; rfl)
  all_goals exact PrefixConflict.mismatch (by decide) (by decide) (by decide)

theorem form_reading_unique {source : Source} {first second : Form}
    {firstEvents secondEvents : List Event} {firstItems secondItems : List Statement}
    (a : FormReading source first firstEvents firstItems)
    (b : FormReading source second secondEvents secondItems) : first = second := by
  by_cases same : first = second
  · exact same
  · exact False.elim (prefix_conflict_impossible (distinct_form_prefixes first second same) a.header b.header)

theorem accepted_form_unique {source : Source} {first second : Form}
    (a : (formResult source first).state.position ≠ 0)
    (b : (formResult source second).state.position ≠ 0) : first = second := by
  obtain ⟨_, _, _, firstRead⟩ := form_reading_sound a
  obtain ⟨_, _, _, secondRead⟩ := form_reading_sound b
  exact form_reading_unique firstRead secondRead

end Silver.Sequence
