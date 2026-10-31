module

public import Silver.PredicateGrammar
public import Silver.ComposeDeclarationBounds
public import Silver.PredicateStringBoundChecks
public import Silver.PredicateChecks

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

set_option backward.dsimp.instances true

def Condition.BoundsOrigin (names : Compose.BindingEnvironment) : Condition → Prop
  | .stringCompare _ left right => left.BoundsOrigin names ∧ right.BoundsOrigin names
  | .characterCompare _ left right => CharacterOrigin names left ∧ CharacterOrigin names right
  | .parenthesized inner | .negated inner => inner.BoundsOrigin names
  | .andThen left right | .orElse left right | .eager _ left right | .booleanCompare _ left right =>
      left.BoundsOrigin names ∧ right.BoundsOrigin names
  | _ => True

/-- Actual String object bounds at every evaluated condition operand, following
Ada's eager and short-circuit evaluation separately. -/
def Condition.ObjectBoundsSafe (names : Compose.BindingEnvironment) (values : Values)
    (input : Source) (valid : Bool) (integers : Integer.Store) (booleans : Boolean.Store) : Condition → Prop
  | .stringCompare _ left right => left.ObjectBoundsSafe names values input integers ∧
      right.ObjectBoundsSafe names values input integers
  | .parenthesized inner | .negated inner => inner.ObjectBoundsSafe names values input valid integers booleans
  | .andThen left right => left.ObjectBoundsSafe names values input valid integers booleans ∧
      (left.evaluate values input valid integers booleans = true → right.ObjectBoundsSafe names values input valid integers booleans)
  | .orElse left right => left.ObjectBoundsSafe names values input valid integers booleans ∧
      (left.evaluate values input valid integers booleans = false → right.ObjectBoundsSafe names values input valid integers booleans)
  | .eager _ left right | .booleanCompare _ left right =>
      left.ObjectBoundsSafe names values input valid integers booleans ∧
        right.ObjectBoundsSafe names values input valid integers booleans
  | _ => True

theorem expression_objectBoundsSafe_of_safe {names : Compose.BindingEnvironment} {expression : Expression}
    {values : Values} {input : Source} {integers : Integer.Store}
    (count : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
    (strings : Fits names.shape input values) (origin : expression.BoundsOrigin names)
    (safe : expression.RuntimeSafe values input integers) : expression.ObjectBoundsSafe names values input integers := by
  apply Expression.objectBoundsSafe_of_endpoint metadata strings origin safe (Int.le_refl _)
  intro first positive bounded
  have ceiling := namesBoundCeiling_upper count
  have length := safe.2
  omega

theorem Condition.objectBoundsSafe_of_safe {names : Compose.BindingEnvironment} {condition : Condition}
    {values : Values} {input : Source} {valid : Bool} {integers : Integer.Store} {booleans : Boolean.Store}
    (count : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
    (strings : Fits names.shape input values) (origin : condition.BoundsOrigin names)
    (safe : condition.Safe names.shape values input valid integers booleans) :
    condition.ObjectBoundsSafe names values input valid integers booleans := by
  induction condition with
  | stringCompare => exact ⟨expression_objectBoundsSafe_of_safe count metadata strings origin.1 safe.1,
      expression_objectBoundsSafe_of_safe count metadata strings origin.2 safe.2⟩
  | parenthesized inner ih | negated inner ih => exact ih origin safe
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      exact ⟨ihl origin.1 safe.1, fun reached => ihr origin.2 (safe.2 reached)⟩
  | eager operator left right ihl ihr | booleanCompare unequal left right ihl ihr =>
      exact ⟨ihl origin.1 safe.1, ihr origin.2 safe.2⟩
  | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral | booleanName => trivial

def SimpleBoundsOrigin (names : Compose.BindingEnvironment) : Sequence.SimpleStatement → Prop
  | .null => True
  | .assign update => update.value.BoundsOrigin names
  | .output expression | .put expression => expression.BoundsOrigin names

mutual
  def Statement.BoundsOrigin (names : Compose.BindingEnvironment) : Statement → Prop
    | .simple item => SimpleBoundsOrigin names item
    | .booleanAssign update => update.value.BoundsOrigin names
    | .choice condition yes no => condition.BoundsOrigin names ∧
        StatementsBoundsOrigin names yes ∧ StatementsBoundsOrigin names no
    | .forLoop _ _ _ _ body | .arrayLoop _ _ _ body => StatementsBoundsOrigin names body
    | _ => True
  termination_by item => sizeOf item
  def StatementsBoundsOrigin (names : Compose.BindingEnvironment) : List Statement → Prop
    | [] => True
    | item :: rest => item.BoundsOrigin names ∧ StatementsBoundsOrigin names rest
  termination_by items => sizeOf items
end

theorem Condition.boundsOrigin_extends {names following : Compose.BindingEnvironment} {condition : Condition}
    (extension : BoundsNamesExtend names following) (origin : condition.BoundsOrigin names) :
    condition.BoundsOrigin following := by
  induction condition with
  | stringCompare => exact ⟨Expression.boundsOrigin_extends extension origin.1,
      Expression.boundsOrigin_extends extension origin.2⟩
  | characterCompare => exact ⟨characterOrigin_extends extension origin.1, characterOrigin_extends extension origin.2⟩
  | parenthesized inner ih | negated inner ih => exact ih origin
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      exact ⟨ihl origin.1, ihr origin.2⟩
  | eager operator left right ihl ihr | booleanCompare unequal left right ihl ihr =>
      exact ⟨ihl origin.1, ihr origin.2⟩
  | lengthCompare | scalarCompare | inputValid | booleanLiteral | booleanName => trivial

theorem Condition.boundsOrigin_freeze {names : Compose.BindingEnvironment} {condition : Condition}
    (snapshot : Integer.Store) (origin : condition.BoundsOrigin names) :
    (condition.freezeIntegers snapshot).BoundsOrigin names := by
  induction condition with
  | stringCompare => exact ⟨Expression.boundsOrigin_freeze snapshot origin.1,
      Expression.boundsOrigin_freeze snapshot origin.2⟩
  | characterCompare => exact ⟨characterOrigin_freeze snapshot origin.1, characterOrigin_freeze snapshot origin.2⟩
  | parenthesized inner ih | negated inner ih => exact ih origin
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      exact ⟨ihl origin.1, ihr origin.2⟩
  | eager operator left right ihl ihr | booleanCompare unequal left right ihl ihr =>
      exact ⟨ihl origin.1, ihr origin.2⟩
  | lengthCompare | scalarCompare | inputValid | booleanLiteral | booleanName => trivial

private theorem chainCondition_boundsOrigin {names : Compose.BindingEnvironment} {left right : Condition}
    (operator : ChainKind) (a : left.BoundsOrigin names) (b : right.BoundsOrigin names) :
    (chainCondition left right operator).BoundsOrigin names := by
  cases operator <;> exact ⟨a, b⟩

mutual
  theorem primary_boundsOrigin {text context position facts condition result initials}
      (parsed : PrimaryAt text context position facts condition result initials) :
      condition.BoundsOrigin context.names := by
    cases parsed with
    | group _ _ _ inner _ =>
        simp only [Condition.BoundsOrigin]
        exact condition_boundsOrigin inner
    | boolean _ _ _ _ atom => cases atom <;> trivial
    | valid => trivial
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem booleanFactor_boundsOrigin {text context position facts condition result initials}
      (parsed : BooleanFactorAt text context position facts condition result initials) :
      condition.BoundsOrigin context.names := by
    cases parsed with
    | primary _ inner => exact primary_boundsOrigin inner
    | negated _ _ inner =>
        simp only [Condition.BoundsOrigin]
        exact primary_boundsOrigin inner
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem booleanRelation_boundsOrigin {text context position facts condition result initials}
      (parsed : BooleanRelationAt text context position facts condition result initials) :
      condition.BoundsOrigin context.names := by
    cases parsed with
    | factor inner _ _ => exact booleanFactor_boundsOrigin inner
    | comparison left _ _ _ _ right _ => exact ⟨booleanFactor_boundsOrigin left, booleanFactor_boundsOrigin right⟩
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem relation_boundsOrigin {text context position facts condition result initials}
      (parsed : RelationAt text context position facts condition result initials) :
      condition.BoundsOrigin context.names := by
    cases parsed with
    | booleanNot _ _ inner | primary _ _ _ _ _ _ inner => exact booleanRelation_boundsOrigin inner
    | length | scalars => trivial
    | strings _ _ _ _ left right _ _ => exact ⟨expression_boundsOrigin left, expression_boundsOrigin right⟩
    | character _ _ _ _ _ inner =>
        cases inner with
        | comparison left right _ _ _ _ => exact ⟨character_boundsOrigin left, character_boundsOrigin right⟩
  termination_by (remainingAt text position, 4)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem chain_boundsOrigin {text context condition result chained final finalResult facts initials originalStart}
      (parsed : ChainAt text context condition result chained final finalResult facts initials originalStart)
      (origin : condition.BoundsOrigin context.names) : final.BoundsOrigin context.names := by
    cases parsed with
    | done => exact origin
    | next _ _ _ _ _ _ _ right _ _ _ rest =>
        exact chain_boundsOrigin rest (chainCondition_boundsOrigin _ origin (relation_boundsOrigin right))
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem condition_boundsOrigin {text context position facts condition result initials}
      (parsed : ConditionAt text context position facts condition result initials) :
      condition.BoundsOrigin context.names := by
    cases parsed with
    | condition _ first _ _ tail => exact chain_boundsOrigin tail (relation_boundsOrigin first)
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

theorem stringAssignment_boundsOrigin {text context scan update}
    (reading : StringAssignmentReading text context scan update) : update.value.BoundsOrigin context.names := by
  cases reading with
  | whole _ _ source => exact expression_boundsOrigin source
  | character _ _ source =>
      intro atom member
      have same := List.mem_singleton.mp member
      subst atom
      exact character_boundsOrigin source
  | @element info index upper value result target _ indexed source =>
      obtain ⟨name, targetInfo, _, found, _, mutable, _, _⟩ := target
      change context.names.get (stringAssignmentTarget text context scan).target = some targetInfo at found
      have positive : (stringAssignmentTarget text context scan).target ≠ 0 := by
        intro zero
        simp [BindingEnvironment.get, zero] at found
      have targetEq : (indexedParts text scan.position context.names (context.readingNames scan.facts)
          context.arrayNames [] false true).target = (stringAssignmentTarget text context scan).target :=
        (stringAssignment_target_index positive).symm
      intro atom member
      have same := List.mem_singleton.mp member
      subst atom
      refine ⟨⟨info, ?_, indexed.fixed, indexed.stringTyped, rfl⟩, character_boundsOrigin source⟩
      simpa only [targetEq] using indexed.selected

theorem basic_boundsOrigin {text context scan item result}
    (parsed : BasicAt text context scan item result) : item.lower.BoundsOrigin context.names := by
  cases parsed.payload with
  | null | reject | scalarAssignment | arrayAssignment =>
      simp only [SourceStatement.lower, Statement.BoundsOrigin, SimpleBoundsOrigin]
  | output _ source | put _ source =>
      simpa only [SourceStatement.lower, Statement.BoundsOrigin, SimpleBoundsOrigin] using expression_boundsOrigin source
  | booleanAssignment _ source =>
      simpa only [SourceStatement.lower, Statement.BoundsOrigin] using condition_boundsOrigin source
  | assignment _ source =>
      simpa only [SourceStatement.lower, Statement.BoundsOrigin, SimpleBoundsOrigin] using stringAssignment_boundsOrigin source

mutual
  theorem statement_boundsOrigin {text context scan item result}
      (parsed : StatementAt text context scan item result) : item.lower.BoundsOrigin context.names := by
    cases parsed with
    | basic _ _ _ source _ => exact basic_boundsOrigin source
    | choice _ _ source _ =>
        simp only [SourceStatement.lower, Statement.BoundsOrigin]
        exact choice_boundsOrigin source
    | loop _ _ _ source _ =>
        simp only [SourceStatement.lower, Statement.BoundsOrigin]
        exact loop_boundsOrigin source
    | arrayLoop _ _ _ source _ =>
        simp only [SourceStatement.lower, Statement.BoundsOrigin]
        exact arrayLoop_boundsOrigin source
  termination_by (bodyRemaining text scan, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem loop_boundsOrigin {text context scan lower upper body result}
      (parsed : LoopAt text context scan lower upper body result) :
      StatementsBoundsOrigin context.names (lowerStatements body) := by
    cases parsed with
    | loop _ _ _ _ _ source _ _ _ =>
        exact body_boundsOrigin (context := loopInner context (loopHeader text context scan)) source
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem arrayLoop_boundsOrigin {text context scan body result}
      (parsed : ArrayLoopAt text context scan body result) :
      StatementsBoundsOrigin context.names (lowerStatements body) := by
    cases parsed with
    | loop _ _ _ _ source _ _ _ =>
        exact body_boundsOrigin (context := loopInner context (loopHeader text context scan)) source
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem choice_boundsOrigin {text context scan condition yes tail result}
      (parsed : ChoiceAt text context scan condition yes tail result) :
      condition.BoundsOrigin context.names ∧ StatementsBoundsOrigin context.names (lowerStatements yes) ∧
        StatementsBoundsOrigin context.names tail.lower := by
    cases parsed with
    | choice condition _ yes _ tail _ _ _ =>
        exact ⟨condition_boundsOrigin condition, body_boundsOrigin yes, alternative_boundsOrigin tail⟩
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem alternative_boundsOrigin {text context scan tail result}
      (parsed : AlternativeAt text context scan tail result) : StatementsBoundsOrigin context.names tail.lower := by
    cases parsed with
    | absent => simp only [SourceAlternative.lower, StatementsBoundsOrigin]
    | otherwise _ _ _ _ body _ =>
        simp only [SourceAlternative.lower]
        exact body_boundsOrigin body
    | elsif _ _ condition _ yes _ tail _ _ _ =>
        simp only [SourceAlternative.lower, StatementsBoundsOrigin, Statement.BoundsOrigin]
        exact ⟨⟨condition_boundsOrigin condition, body_boundsOrigin yes, alternative_boundsOrigin tail⟩, trivial⟩
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem bodyTail_boundsOrigin {text context stop scan items result}
      (parsed : BodyTailAt text context stop scan items result) :
      StatementsBoundsOrigin context.names (lowerStatements items) := by
    cases parsed with
    | done => simp only [lowerStatements, StatementsBoundsOrigin]
    | next _ _ first _ rest _ =>
        simp only [lowerStatements, StatementsBoundsOrigin]
        exact ⟨statement_boundsOrigin first, bodyTail_boundsOrigin rest⟩
  termination_by (bodyRemaining text scan, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem body_boundsOrigin {text context scan stop items result}
      (parsed : BodyAt text context scan stop items result) :
      StatementsBoundsOrigin context.names (lowerStatements items) := by
    cases parsed with
    | cons first _ rest _ =>
        simp only [lowerStatements, StatementsBoundsOrigin]
        exact ⟨statement_boundsOrigin first, bodyTail_boundsOrigin rest⟩
  termination_by (bodyRemaining text scan, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate
