module

public import Silver.ApplicationStaticBooleanLeafImports

@[expose] public section

/-! Normalize the imported leaves at every call in the original static Boolean
reader bodies. Cursor zero and rejected reads remain in the native domains.
Only the recursive readers' written result contracts provide their bounds. -/
namespace Silver.BooleanElaboration.Native.SourceImports
open Compose Compose.Expressions

set_option backward.dsimp.instances true

private theorem reference_first_bound {text : Source} {position : Nat}
    (bounded : position ≤ text.length + 1) :
    (QualifiedNames.read text position).first ≤ text.length + 1 := by
  rcases (QualifiedNames.read_bounds text position bounded).1 with absent | present <;> omega

private theorem scalar_bound {text : Source} {position : Nat} {names : ScalarExpression.Environment}
    (bounded : position ≤ text.length + 1) :
    (modelImports.scalar text position names).after ≤ text.length + 1 := by
  by_cases zero : (modelImports.scalar text position names).after = 0
  · rw [zero]; exact Nat.zero_le _
  · exact (ScalarExpression.read_arrays_bounds bounded zero).2.1

theorem Meaning.primary {imports : Imports} (meaning : Meaning imports)
    {text : Source} {frame : ParserState} {position : Nat} (domain : SourceChecks.Domain text frame position)
    (condition : Reader) (bounded : BoundedReader condition text frame) :
    primaryStep imports condition text frame position = primaryStep modelImports condition text frame position := by
  have reference := QualifiedNames.read_bounds text position domain.cursor
  have firstBound := reference_first_bound domain.cursor
  have afterBound := QualifiedNames.read_after_bound text position domain.cursor
  have openBound := model_fixed_valid text position "(" false domain.cursor
  have resultBound := (bounded _ openBound).limit
  unfold primaryStep
  dsimp only
  rw [meaning.take text domain.textValid position .leftParenthesis domain.cursor,
    meaning.reference text domain.textValid position domain.cursor,
    meaning.lookup text domain.textValid frame.booleanNames
      (modelImports.reference text position).first (modelImports.reference text position).after
      (modelImports.reference text position).qualifierFirst (modelImports.reference text position).qualifierAfter
      domain.frameDomain.base.booleans
      firstBound afterBound reference.2.1,
    meaning.booleanAtom text frame position domain,
    meaning.take text domain.textValid
      (condition text frame (modelImports.take text position .leftParenthesis)).after .rightParenthesis resultBound]
  rcases reference.1 with absent | present
  · simp only [modelImports, absent.1, absent.2, ne_eq, not_true_eq_false, false_and, and_false,
      ↓reduceIte]
  · rw [meaning.nameIs text domain.textValid
      (modelImports.reference text position).first (modelImports.reference text position).after
      "true" present (by decide) (by decide),
      meaning.nameIs text domain.textValid
      (modelImports.reference text position).first (modelImports.reference text position).after
      "false" present (by decide) (by decide)]

theorem Meaning.factor {imports : Imports} (meaning : Meaning imports)
    {text : Source} {frame : ParserState} {position : Nat} (domain : SourceChecks.Domain text frame position)
    (primary : Reader) :
    factorStep imports primary text frame position = factorStep modelImports primary text frame position := by
  unfold factorStep
  rw [meaning.take text domain.textValid position .notKeyword domain.cursor]

theorem Meaning.relation {imports : Imports} (meaning : Meaning imports)
    {text : Source} {frame : ParserState} {position : Nat} (domain : SourceChecks.Domain text frame position)
    (factor : Reader) (bounded : BoundedReader factor text frame) :
    relationStep imports factor text frame position = relationStep modelImports factor text frame position := by
  have names := domain.frameDomain.base.2.2.2.2.2.1
  have leftBound := scalar_bound (names := frame.scalarNames) domain.cursor
  have compareBound : (modelImports.comparison text
      (modelImports.scalar text position frame.scalarNames).after).after ≤ text.length + 1 :=
    Predicate.comparison_bound text _ leftBound
  have flagBound := (bounded position domain.cursor).limit
  unfold relationStep
  dsimp only
  rw [meaning.scalar text domain.textValid position frame.scalarNames domain.cursor names,
    meaning.comparison text domain.textValid _ leftBound,
    meaning.scalar text domain.textValid
      (modelImports.comparison text (modelImports.scalar text position frame.scalarNames).after).after
      frame.scalarNames compareBound names,
    meaning.comparison text domain.textValid _ flagBound]

theorem Meaning.tail_step {imports : Imports} (meaning : Meaning imports)
    {text : Source} (valid : ValidText text) (frame : ParserState) (relation : Reader)
    (selected : Chain) (input : Result) (bounded : input.after ≤ text.length + 1) :
    tailStep imports relation text frame selected input = tailStep modelImports relation text frame selected input := by
  unfold tailStep
  dsimp only
  rw [meaning.chain text valid input.after bounded,
    meaning.chainAfter text valid input.after _ bounded]

theorem Meaning.tail_execution {imports : Imports} (meaning : Meaning imports)
    {text : Source} (valid : ValidText text) {frame : ParserState} {relation : Reader}
    (relationBound : BoundedReader relation text frame) {selected input output}
    (run : TailExec imports relation text frame selected input output)
    (inputBound : input.after ≤ text.length + 1) :
    TailExec modelImports relation text frame selected input output := by
  induction run with
  | finished step =>
    exact .finished ((meaning.tail_step valid _ _ _ _ inputBound).symm.trans step)
  | @next input middle output step _ ih =>
    have normalized := (meaning.tail_step valid _ _ _ _ inputBound).symm.trans step
    obtain ⟨operator, _, _, _, update⟩ := tail_next_source normalized
    have middleBound : middle.after ≤ text.length + 1 := by
      rw [update]
      exact (relationBound _ (Predicate.chainAfter_bound text _ operator inputBound)).limit
    exact .next normalized (ih middleBound)

theorem Meaning.condition_execution {imports : Imports} (meaning : Meaning imports)
    {text : Source} {frame : ParserState} {position : Nat} (domain : SourceChecks.Domain text frame position)
    (relation : Reader) (bounded : BoundedReader relation text frame) {output : Result}
    (run : ConditionExec imports relation text frame position output) :
    ConditionExec modelImports relation text frame position output := by
  unfold ConditionExec at run ⊢
  dsimp only at run ⊢
  have inputBound := (bounded position domain.cursor).limit
  split at run
  · rename_i failed
    simpa only [failed, ↓reduceIte] using run
  · rename_i present
    simp only [present, ↓reduceIte]
    rw [meaning.chain text domain.textValid _ inputBound] at run
    exact meaning.tail_execution domain.textValid bounded run inputBound

end Silver.BooleanElaboration.Native.SourceImports
