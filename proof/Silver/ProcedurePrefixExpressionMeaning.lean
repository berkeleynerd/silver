module

public import Silver.ProcedurePrefixReadings
public import Silver.PredicateFunctionCallMeaning
public import Silver.ProcedureNameScalarReadings

@[expose] public section

namespace Silver.Compose
open Predicate ScalarProcedures

/-- A cell outside the fixed read frame has no source binding in a prefix RHS.
Integer and Boolean identities use independent stores. -/
def ProcedureCellOutside (context : ParseContext) : Cell → Prop
  | .integer identity => context.scalarNames.length < identity ∧
      ∀ item ∈ context.arrayNames, ¬item.viewDescriptor.ContainsCell identity
  | .boolean identity => context.booleanNames.length < identity

private theorem integerMentions_readsOnly {expression : Integer.Expr} {count identity : Nat}
    (source : expression.ReadsOnly (fun index => 0 < index ∧ index ≤ count))
    (outside : count < identity) : integerMentions identity expression = false := by
  induction expression with
  | literal | snapshot => rfl
  | name index =>
      simp only [Integer.Expr.ReadsOnly] at source
      simp only [integerMentions, beq_eq_false_iff_ne]
      omega
  | indexed => exact False.elim source
  | positive _ ih | negative _ ih | parenthesized _ ih => exact ih source
  | add _ _ ihl ihr | subtract _ _ ihl ihr | multiply _ _ ihl ihr
  | divide _ _ ihl ihr | modulo _ _ ihl ihr | remainder _ _ ihl ihr =>
      exact Bool.or_eq_false_iff.mpr ⟨ihl source.1, ihr source.2⟩

private theorem prefix_syntax_read_absent {text names arrays maskFirst maskAfter mode allowSign position parsed}
    (source : ScalarExpression.ArrayGrammar.SourceAt text names arrays maskFirst maskAfter mode allowSign position parsed)
    (identity : Nat) (outside : names.length < identity)
    (apart : ∀ item ∈ arrays.items, ¬item.viewDescriptor.ContainsCell identity) :
    integerMentions identity parsed.expression = false := by
  induction source with
  | ordinary _ _ _ atom => exact integerMentions_readsOnly (ScalarExpression.atom_readsOnly atom) outside
  | shape | signed => rfl
  | @indexed _ position _ _ after target _ _ _ _ _ _ _ _ _ _ _ _ resolved positive _ _ _ _ _ _ _ ih =>
      have bounded := ArrayBindings.lookup_bound text arrays.items (ScalarExpression.skip text position) after
      rw [resolved] at bounded
      have separate := apart _ (ArrayBindings.binding_mem (Nat.pos_of_ne_zero positive) bounded)
      simp only [integerMentions, separate, decide_false, Bool.false_or, ih]
  | unary _ _ _ _ _ ih =>
      simp only [ScalarExpression.unary]
      split <;> exact ih
  | grouped _ _ _ _ ih => exact ih
  | binary _ _ _ _ _ _ _ combined _ ihl ihr => simpa only using integerMentions_binary combined ihl ihr

theorem prefix_scalar_read_absent {text} {context : ParseContext}
    {position facts expression result maskFirst maskAfter allowSign initials mode}
    (identity : Nat) (outside : ProcedureCellOutside context (.integer identity))
    (source : ScalarExpression.ArrayGrammar.At text (context.readingNames facts) position expression result
      maskFirst maskAfter allowSign context.arrayTable initials context.elaborating mode) :
    integerMentions identity expression = false := by
  apply prefix_syntax_read_absent source.source identity _ outside.2
  simpa only [ParseContext.readingNames, ScalarMetadata.readingNames_length] using outside.1

mutual
  theorem prefix_primary_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context descriptors) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : PrimaryAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | group _ _ _ inner _ =>
        simpa only [conditionMentions] using prefix_condition_read_absent closed cell outside inner
    | boolean _ _ _ _ _ atom =>
        cases atom with
        | name _ _ =>
            cases cell with
            | integer => rfl
            | boolean identity =>
                have bounded := BooleanBindings.lookup_bound text context.booleanNames
                  (skipAt text position) (nameAfter text (skipAt text position))
                simp only [ProcedureCellOutside] at outside
                change (Cell.boolean identity == .boolean _) = false
                apply beq_eq_false_iff_ne.mpr
                intro same
                have indices := Cell.boolean.inj same
                omega
        | literal => cases cell <;> rfl
    | valid => rfl
    | booleanArray _ _ _ _ atom => exact (closed.noBooleanRead atom).elim
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem prefix_booleanFactor_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context descriptors) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : BooleanFactorAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | primary _ inner => exact prefix_primary_read_absent closed cell outside inner
    | negated _ _ inner =>
        simpa only [conditionMentions] using prefix_primary_read_absent closed cell outside inner
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem prefix_booleanRelation_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context descriptors) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : BooleanRelationAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | factor inner _ _ => exact prefix_booleanFactor_read_absent closed cell outside inner
    | comparison left _ _ _ _ right _ =>
        exact Bool.or_eq_false_iff.mpr ⟨prefix_booleanFactor_read_absent closed cell outside left,
          prefix_booleanFactor_read_absent closed cell outside right⟩
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem prefix_relation_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context descriptors) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : RelationAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner =>
        exact prefix_booleanRelation_read_absent closed cell outside inner
    | length => rfl
    | scalars _ _ _ _ left right _ =>
        cases cell with
        | boolean => rfl
        | integer identity =>
            exact Bool.or_eq_false_iff.mpr ⟨prefix_scalar_read_absent identity outside left,
              prefix_scalar_read_absent identity outside right⟩
    | strings _ _ _ _ _ _ _ _ impure | character _ _ _ _ _ _ impure
    | primary _ _ _ _ _ _ _ impure => simp [closed.pure] at impure
  termination_by (remainingAt text position, 4)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem prefix_chain_read_absent {text context condition result chained final finalResult facts initials originalStart}
      (closed : ClosedFunctionContext context descriptors) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : ChainAt text context condition result chained final finalResult facts initials originalStart)
      (first : conditionMentions cell condition = false) : conditionMentions cell final = false := by
    cases source with
    | done => exact first
    | @next _ _ condition result chained operator right rightResult final finalResult _ _ _ _ _ _ _ rightRead _ _ _ rest =>
        apply prefix_chain_read_absent closed cell outside rest
        have following := prefix_relation_read_absent closed cell outside rightRead
        cases operator <;> exact Bool.or_eq_false_iff.mpr ⟨first, following⟩
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem prefix_condition_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context descriptors) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : ConditionAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | condition _ first _ _ tail =>
        exact prefix_chain_read_absent closed cell outside tail (prefix_relation_read_absent closed cell outside first)
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

theorem prefix_actual_read_absent {text context position facts formal actual after}
    (closed : ClosedFunctionContext context descriptors) (cell : Cell) (outside : ProcedureCellOutside context cell)
    (source : ActualAt text context position facts formal actual after) : valueMentions cell actual = false := by
  cases source.payload with
  | integer _ _ expression _ _ =>
      cases cell with
      | integer identity => exact prefix_scalar_read_absent identity outside expression
      | boolean => rfl
  | boolean _ _ condition => exact prefix_condition_read_absent closed cell outside condition
  | @array item reading =>
      cases cell with
      | boolean => rfl
      | integer identity => exact decide_eq_false (outside.2 item reading.member)

theorem ProcedurePrefixAt.reads_absent {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (closed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount) descriptors)
    (cell : Cell) (outside : ProcedureCellOutside (procedurePrefixContext readFrame declarationCount) cell) :
    ∀ actual ∈ actuals, valueMentions cell actual = false := by
  induction source with
  | done => simp
  | skip _ _ _ _ ih => exact ih
  | next _ _ _ first _ _ ih =>
      intro actual member
      rcases List.mem_cons.mp member with rfl | later
      · exact prefix_actual_read_absent closed cell outside first.value
      · exact ih actual later

theorem ProcedurePrefixAt.scalarOnly {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (closed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount) descriptors) :
    actuals.all (ScalarFunctions.frameActual descriptors) = true := by
  induction source with
  | done => rfl
  | skip _ _ _ _ ih => exact ih
  | next _ _ _ first _ _ ih =>
      exact Bool.and_eq_true_iff.mpr ⟨actual_source_scalar closed first.value, ih⟩

end Silver.Compose
