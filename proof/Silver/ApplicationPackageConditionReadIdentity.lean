module

public import Silver.ApplicationPackageScalarReadIdentity
public import Silver.ApplicationPackageConditionEffects

@[expose] public section

/-! Parsed conditions supply original-row lookup facts, including the absence
of a hiding Integer binding for a Boolean read. The rows remain native slots;
the package decoder separately identifies their original state declarations. -/
namespace Silver.ApplicationPackageEffects
open Compose Predicate Packages

def OriginalRow (context : ParseContext) : Cell → Prop
  | .integer slot => slot ≠ 0 ∧ slot ≤ context.scalarNames.length ∧
      (ScalarExpression.binding context.scalarNames slot).qualifierFirst = 0 ∧
      (ScalarExpression.binding context.scalarNames slot).first ≠ 0 ∧
      (ScalarExpression.binding context.scalarNames slot).first <
        (ScalarExpression.binding context.scalarNames slot).after
  | .boolean slot => slot ≠ 0 ∧ slot ≤ context.booleanNames.length ∧
      (BooleanBindings.binding context.booleanNames slot).qualifierFirst = 0 ∧
      (BooleanBindings.binding context.booleanNames slot).first ≠ 0 ∧
      (BooleanBindings.binding context.booleanNames slot).first <
        (BooleanBindings.binding context.booleanNames slot).after

def OriginalLookup (text : Source) (context : ParseContext) : Cell → Prop
  | .integer slot => ScalarExpression.lookup text context.scalarNames
      (ScalarExpression.binding context.scalarNames slot).first
      (ScalarExpression.binding context.scalarNames slot).after = slot
  | .boolean slot => ScalarExpression.lookup text context.scalarNames
      (BooleanBindings.binding context.booleanNames slot).first
      (BooleanBindings.binding context.booleanNames slot).after = 0 ∧
      BooleanBindings.lookup text context.booleanNames
        (BooleanBindings.binding context.booleanNames slot).first
        (BooleanBindings.binding context.booleanNames slot).after = slot

theorem scalar_original_in_flow {text : Source} {context : ParseContext}
    {facts : ActiveFlow} {arrays : ArrayBindings.Table} {mode : ScalarExpression.ArrayReadMode}
    {maskFirst maskAfter position slot : Nat} {allowSign : Bool} {value : ScalarExpression.Parsed}
    (source : ScalarExpression.ArrayGrammar.SourceAt text (context.readingNames facts) arrays
      maskFirst maskAfter mode allowSign position value)
    (row : OriginalRow context (.integer slot))
    (read : .integer slot ∈ integerReads value.expression) :
    OriginalLookup text context (.integer slot) := by
  have overlay := ScalarMetadata.readingNames_binding context.scalarNames context.declarationCount
    facts slot (Nat.pos_of_ne_zero row.1) row.2.1
  have bare : (ScalarExpression.binding (context.readingNames facts) slot).qualifierFirst = 0 := by
    simp only [ParseContext.readingNames, overlay, ScalarMetadata.readingBinding_qualifierFirst, row.2.2.1]
  have first : (ScalarExpression.binding (context.readingNames facts) slot).first =
      (ScalarExpression.binding context.scalarNames slot).first := by
    simp only [ParseContext.readingNames, overlay, ScalarMetadata.readingBinding_first]
  have after : (ScalarExpression.binding (context.readingNames facts) slot).after =
      (ScalarExpression.binding context.scalarNames slot).after := by
    simp only [ParseContext.readingNames, overlay, ScalarMetadata.readingBinding_after]
  have found := scalar_source_original_lookup source bare (by rw [first]; exact row.2.2.2.1)
    (by rw [first, after]; exact row.2.2.2.2) read
  rw [first, after] at found
  simpa only [OriginalLookup, ParseContext.readingNames, ScalarMetadata.readingNames_lookup] using found

private theorem boolean_atom_original {text : Source} {context : ParseContext}
    {position finish : Nat} {condition : Condition} {cell : Cell}
    (source : BooleanAtomAt text context position condition finish)
    (accepted : booleanAtomAfter text context position ≠ 0)
    (row : OriginalRow context cell) (read : cell ∈ conditionReads condition) :
    OriginalLookup text context cell := by
  cases source with
  | literal => simp [conditionReads] at read
  | @name reference referenceSource positive =>
      have equal : cell = .boolean (BooleanBindings.lookup text context.booleanNames
          reference.first reference.after reference.qualifierFirst reference.qualifierAfter) := by
        simpa [conditionReads] using read
      subst cell
      cases referenceSource with
      | @bare bytes after namePositive identifier noDot =>
          have bounds := Named.identifier_bounds identifier
          have spelling := equalName_symm (booleanLookupFrom_spelling rfl positive)
          have retarget := booleanLookup_retarget (names := context.booleanNames) (Nat.ne_of_gt namePositive) bounds.2.2.1
            row.2.2.2.1 row.2.2.2.2 spelling
          refine ⟨?_, retarget.symm⟩
          have parsed := QualifiedNames.read_complete (QualifiedNames.At.bare namePositive identifier noDot)
          change ScalarExpression.readReference text position = _ at parsed
          simp only [booleanAtomAfter, parsed] at accepted
          have absent : ScalarExpression.lookup text context.scalarNames
              (QualifiedNames.skip text position) after = 0 := by
            split at accepted
            · contradiction
            · split at accepted
              · contradiction
              · split at accepted
                · contradiction
                · rename_i allowed
                  exact Classical.byContradiction (fun bad => allowed (Or.inr (Or.inl bad)))
          rw [← scalarLookup_retarget (Nat.ne_of_gt namePositive) bounds.2.2.1
            row.2.2.2.1 row.2.2.2.2 spelling]
          exact absent
      | qualified qualifierPositive _ _ _ _ =>
          have qualifier := booleanLookupFrom_qualifier rfl positive
          have bare := row.2.2.1
          simp only [BooleanBindings.lookup] at bare
          simp only [QualifiedNames.qualifierMatches, Nat.ne_of_gt qualifierPositive,
            ite_false, bare, Nat.lt_irrefl, decide_false, Bool.false_and, Bool.false_eq_true] at qualifier

private def ReadsResolve (text : Source) (context : ParseContext) (condition : Condition) : Prop :=
  ∀ cell, OriginalRow context cell → cell ∈ conditionReads condition → OriginalLookup text context cell

private theorem combine_resolves {text context left right}
    (leftResolved : ReadsResolve text context left) (rightResolved : ReadsResolve text context right)
    {combined : Condition} (reads : conditionReads combined = conditionReads left ++ conditionReads right) :
    ReadsResolve text context combined := by
  intro cell row read
  rw [reads] at read
  exact (List.mem_append.mp read).elim (leftResolved cell row) (rightResolved cell row)

mutual
  private theorem primary_resolves {text context initials position facts condition result}
      (source : PrimaryAt text context position facts condition result initials) :
      ReadsResolve text context condition := by
    cases source with
    | group _ _ _ inner _ => simpa only [ReadsResolve, conditionReads] using condition_resolves inner
    | booleanArray _ _ _ _ atom => cases atom; intro cell row read; simp [conditionReads] at read
    | boolean _ _ _ result nonzero atom =>
        exact fun _ row read => boolean_atom_original atom (by rw [result]; exact nonzero) row read
    | valid => intro cell row read; simp [conditionReads] at read
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  private theorem factor_resolves {text context initials position facts condition result}
      (source : BooleanFactorAt text context position facts condition result initials) :
      ReadsResolve text context condition := by
    cases source with
    | primary _ inner => exact primary_resolves inner
    | negated _ _ inner => simpa only [ReadsResolve, conditionReads] using primary_resolves inner
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  private theorem boolean_relation_resolves {text context initials position facts condition result}
      (source : BooleanRelationAt text context position facts condition result initials) :
      ReadsResolve text context condition := by
    cases source with
    | factor inner _ _ => exact factor_resolves inner
    | comparison left _ _ _ _ right _ =>
        exact combine_resolves (factor_resolves left) (factor_resolves right) rfl
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  private theorem relation_resolves {text context initials position facts condition result}
      (source : RelationAt text context position facts condition result initials) :
      ReadsResolve text context condition := by
    cases source with
    | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner | primary _ _ _ _ _ _ inner _ =>
        exact boolean_relation_resolves inner
    | length | strings => intro cell row read; simp [conditionReads] at read
    | character _ _ _ _ _ inner _ => cases inner; intro cell row read; simp [conditionReads] at read
    | scalars _ _ _ _ left right _ =>
        intro cell row read
        cases cell with
        | integer slot =>
            exact (List.mem_append.mp read).elim
              (scalar_original_in_flow left.source row) (scalar_original_in_flow right.source row)
        | boolean slot =>
            exact False.elim ((List.mem_append.mp read).elim
              (integerReads_no_boolean _ slot) (integerReads_no_boolean _ slot))
  termination_by (remainingAt text position, 4)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.right _ (by decide)

  private theorem chain_resolves {text context initials incoming originalStart condition result chained final finalResult}
      (source : ChainAt text context condition result chained final finalResult incoming initials originalStart)
      (first : ReadsResolve text context condition) : ReadsResolve text context final := by
    cases source with
    | done => exact first
    | @next _ _ _ _ _ operator _ _ _ _ _ _ _ _ _ _ _ right _ _ _ rest =>
        apply chain_resolves rest
        apply combine_resolves first (relation_resolves right)
        cases operator <;> rfl
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  private theorem condition_resolves {text context initials position facts condition result}
      (source : ConditionAt text context position facts condition result initials) :
      ReadsResolve text context condition := by
    cases source with
    | condition _ first _ _ tail => exact chain_resolves tail (relation_resolves first)
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

theorem condition_source_original_lookup {text context initials position facts condition result cell}
    (source : ConditionAt text context position facts condition result initials)
    (row : OriginalRow context cell) (read : cell ∈ conditionReads condition) :
    OriginalLookup text context cell := condition_resolves source cell row read

end Silver.ApplicationPackageEffects
