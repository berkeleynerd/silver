module

public import Silver.StaticBooleanModel
public import Silver.ComposeBounds

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose

/-- The value belongs to the expression read on the original source span. -/
def ExactAt (reading : Nat → Predicate.Condition → Nat → Prop) (frame : ParserState)
    (position : Nat) (result : Result) : Prop :=
  ∃ expression, reading position expression result.after ∧
    evaluate frame.scalarNames frame.booleanNames expression = some result.value

inductive PrimaryAt (text : Source) (frame : ParserState) (nested : Nat → Predicate.Condition → Nat → Prop)
    (position : Nat) : Predicate.Condition → Nat → Prop
  | atom {expression after} : Predicate.BooleanAtomAt text
      (BooleanDeclarationNative.contextOf ⟨frame, false, false⟩).model position expression after →
      PrimaryAt text frame nested position expression after
  | grouped {inner innerAfter} : fixedAfter text position "(" false ≠ 0 →
      nested (fixedAfter text position "(" false) inner innerAfter →
      fixedAfter text innerAfter ")" false ≠ 0 →
      PrimaryAt text frame nested position (.parenthesized inner) (fixedAfter text innerAfter ")" false)

private theorem name_atom {text : Source} {frame : ParserState} {position} (reference : QualifiedNames.Reference)
    (parsed : QualifiedNames.At text position reference)
    (index : Nat) (found : BooleanBindings.lookup text frame.booleanNames reference.first reference.after
      reference.qualifierFirst reference.qualifierAfter = index)
    (present : index ≠ 0) (known : (BooleanBindings.binding frame.booleanNames index).known = true) :
    Predicate.BooleanAtomAt text (BooleanDeclarationNative.contextOf ⟨frame, false, false⟩).model position
      (.booleanName index) reference.after ∧
    evaluate frame.scalarNames frame.booleanNames (.booleanName index) =
      some (BooleanBindings.binding frame.booleanNames index).value := by
  subst index
  refine ⟨.name parsed present, ?_⟩
  have bounded := BooleanBindings.lookup_bound text frame.booleanNames reference.first reference.after
    reference.qualifierFirst reference.qualifierAfter
  exact ite_eq_left ⟨Nat.pos_of_ne_zero present, bounded, known⟩

private theorem literal_atom {text : Source} {frame : ParserState} {position}
    (bound : position ≤ text.length + 1) (present : (QualifiedNames.read text position).after ≠ 0)
    (bare : (QualifiedNames.read text position).qualifierFirst = 0)
    (missing : let ref := QualifiedNames.read text position
      BooleanBindings.lookup text frame.booleanNames ref.first ref.after ref.qualifierFirst ref.qualifierAfter = 0)
    (value : Bool) (spelling : let ref := QualifiedNames.read text position
      Named.nameIs text ref.first ref.after ((if value then "true" else "false").toList.map Char.toNat) = true) :
    Predicate.BooleanAtomAt text (BooleanDeclarationNative.contextOf ⟨frame, false, false⟩).model position
      (.booleanLiteral value) (QualifiedNames.read text position).after := by
  have qualifier := (QualifiedNames.read_bounds text position bound).2.1
  rcases qualifier with empty | nonempty
  · exact .literal (QualifiedNames.read_sound text position present) empty missing spelling
  · exact False.elim (Nat.ne_of_gt nonempty.1 bare)

theorem primary_exact {condition : Reader} {text : Source} {frame : ParserState} {position : Nat}
    (bound : position ≤ text.length + 1) (nested : Nat → Predicate.Condition → Nat → Prop)
    (inner : ∀ start, (condition text frame start).after ≠ 0 →
      ExactAt nested frame start (condition text frame start))
    (accepted : (primaryStep modelImports condition text frame position).after ≠ 0) :
    ExactAt (PrimaryAt text frame nested) frame position (primaryStep modelImports condition text frame position) := by
  let ref := QualifiedNames.read text position
  let index := BooleanBindings.lookup text frame.booleanNames ref.first ref.after ref.qualifierFirst ref.qualifierAfter
  revert accepted
  dsimp only [primaryStep, modelImports]
  split
  · intro accepted; exact False.elim (accepted rfl)
  · split
    · rename_i opened
      intro accepted
      have innerPresent := Expressions.model_fixed_input_nonzero text _ ")" false accepted
      obtain ⟨expression, read, exactValue⟩ := inner _ innerPresent
      exact ⟨.parenthesized expression, .grouped opened read accepted, exactValue⟩
    · split
      · rename_i selected
        intro accepted
        obtain ⟨atom, exactValue⟩ := name_atom (frame := frame) ref
          (QualifiedNames.read_sound text position accepted) index rfl selected.1 selected.2
        exact ⟨.booleanName index, .atom atom, exactValue⟩
      · split
        · rename_i literal
          split
          · rename_i spelled
            intro accepted
            exact ⟨.booleanLiteral true, .atom (literal_atom bound accepted literal.2.1 literal.1 true spelled), rfl⟩
          · split
            · rename_i spelled
              intro accepted
              exact ⟨.booleanLiteral false, .atom (literal_atom bound accepted literal.2.1 literal.1 false spelled), rfl⟩
            · intro accepted; exact False.elim (accepted rfl)
        · intro accepted; exact False.elim (accepted rfl)

inductive FactorAt (text : Source) (primary : Nat → Predicate.Condition → Nat → Prop) (position : Nat) :
    Predicate.Condition → Nat → Prop
  | plain {expression after} : fixedAfter text position "not" true = 0 →
      primary position expression after → FactorAt text primary position expression after
  | negated {expression after} : fixedAfter text position "not" true ≠ 0 →
      primary (fixedAfter text position "not" true) expression after →
      FactorAt text primary position (.negated expression) after

theorem factor_exact {reader : Reader} {text : Source} {frame : ParserState} {position}
    (primary : Nat → Predicate.Condition → Nat → Prop)
    (operand : ∀ start, (reader text frame start).after ≠ 0 → ExactAt primary frame start (reader text frame start))
    (accepted : (factorStep modelImports reader text frame position).after ≠ 0) :
    ExactAt (FactorAt text primary) frame position (factorStep modelImports reader text frame position) := by
  dsimp only [factorStep, modelImports] at accepted ⊢
  by_cases plain : fixedAfter text position "not" true = 0
  · simp only [ite_eq_right (not_not_intro plain), ite_eq_left plain] at accepted ⊢
    obtain ⟨expression, read, value⟩ := operand _ accepted
    exact ⟨expression, .plain plain read, value⟩
  · simp only [ite_eq_left plain, ite_eq_right plain] at accepted ⊢
    obtain ⟨expression, read, value⟩ := operand _ accepted
    exact ⟨.negated expression, .negated plain read, by simp only [evaluate, value, Option.map_some]⟩

end Silver.BooleanElaboration.Native
