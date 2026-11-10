module

public import Silver.PredicateGrammar
public import Silver.ComposeDeclarationBounds
public import Silver.PredicateStringBoundChecks
public import Silver.PredicateChecks
public import Silver.PredicateOuterReadiness

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata}
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
  | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral | booleanName | booleanArrayRead => trivial

/-- Boolean actuals retain the same String/Character source-origin evidence as
ordinary conditions; Integer actuals contain no String expressions. -/
def CallActualBoundsOrigin (names : Compose.BindingEnvironment) : ScalarFunctions.Actual → Prop
  | .integer _ => True
  | .boolean condition => condition.BoundsOrigin names

def CallBoundsOrigin (names : Compose.BindingEnvironment) (call : ScalarFunctions.Call) : Prop :=
  ∀ actual ∈ call.actuals, CallActualBoundsOrigin names actual

def ProcedureActualBoundsOrigin (names : Compose.BindingEnvironment) : ScalarProcedures.Actual → Prop
  | .value value => CallActualBoundsOrigin names value
  | .target _ => True

def ProcedureCallBoundsOrigin (names : Compose.BindingEnvironment)
    (call : ScalarProcedures.Call) : Prop :=
  ∀ actual ∈ call.actuals, ProcedureActualBoundsOrigin names actual

def SimpleBoundsOrigin (names : Compose.BindingEnvironment) : Sequence.SimpleStatement → Prop
  | .null => True
  | .assign update => update.value.BoundsOrigin names
  | .output expression | .put expression => expression.BoundsOrigin names

mutual
  def Statement.BoundsOrigin (names : Compose.BindingEnvironment) : Statement → Prop
    | .simple item => SimpleBoundsOrigin names item
    | .callAssign update => CallBoundsOrigin names update.call
    | .procedureCall call => ProcedureCallBoundsOrigin names call
    | .booleanAssign update | .booleanArrayAssign update => update.value.BoundsOrigin names
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
  | lengthCompare | scalarCompare | inputValid | booleanLiteral | booleanName | booleanArrayRead => trivial

theorem callActualBoundsOrigin_extends {names following : Compose.BindingEnvironment}
    {actual : ScalarFunctions.Actual} (extension : BoundsNamesExtend names following)
    (origin : CallActualBoundsOrigin names actual) : CallActualBoundsOrigin following actual := by
  cases actual with
  | integer _ => trivial
  | boolean condition => exact condition.boundsOrigin_extends extension origin

theorem callBoundsOrigin_extends {names following : Compose.BindingEnvironment}
    {call : ScalarFunctions.Call} (extension : BoundsNamesExtend names following)
    (origin : CallBoundsOrigin names call) : CallBoundsOrigin following call :=
  fun actual member => callActualBoundsOrigin_extends extension (origin actual member)

theorem procedureCallBoundsOrigin_extends {names following : Compose.BindingEnvironment}
    {call : ScalarProcedures.Call} (extension : BoundsNamesExtend names following)
    (origin : ProcedureCallBoundsOrigin names call) : ProcedureCallBoundsOrigin following call := by
  intro actual member
  cases actual with
  | value value => exact callActualBoundsOrigin_extends extension (origin _ member)
  | target _ => trivial

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
  | lengthCompare | scalarCompare | inputValid | booleanLiteral | booleanName | booleanArrayRead => trivial

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
    | booleanArray _ _ _ _ atom => cases atom <;> trivial
    | boolean _ _ _ _ _ atom => cases atom <;> trivial
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
    | pureBoolean _ _ _ _ _ inner => exact booleanRelation_boundsOrigin inner
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

theorem actual_boundsOrigin {text context position facts formal actual after}
    (source : ActualAt text context position facts formal actual after) : CallActualBoundsOrigin context.names actual := by
  obtain ⟨_, _, _, payload⟩ := source
  cases payload with
  | integer => trivial
  | boolean _ reading => exact condition_boundsOrigin reading

theorem actuals_boundsOrigin {text context facts catalog position first last actuals after}
    (source : ActualsAt text context facts catalog position first last actuals after) :
    ∀ actual ∈ actuals, CallActualBoundsOrigin context.names actual := by
  induction source with
  | last first _ =>
      intro actual present
      rcases List.mem_singleton.mp present with rfl
      exact actual_boundsOrigin first
  | next _ first _ ih =>
      intro actual present
      rcases List.mem_cons.mp present with rfl | present
      · exact actual_boundsOrigin first
      · exact ih actual present

theorem basic_boundsOrigin {text context scan item result}
    (parsed : BasicAt (catalog := catalog) text context scan item result) : item.lower.BoundsOrigin context.names := by
  cases parsed.payload with
  | null | reject | scalarAssignment | arrayAssignment =>
      simp only [SourceStatement.lower, Statement.BoundsOrigin, SimpleBoundsOrigin]
  | scalarCallAssignment _ source | booleanCallAssignment _ source =>
      simpa only [SourceStatement.lower, Statement.BoundsOrigin, CallBoundsOrigin] using
        actuals_boundsOrigin source.call.actuals
  | output _ source | put _ source =>
      simpa only [SourceStatement.lower, Statement.BoundsOrigin, SimpleBoundsOrigin] using expression_boundsOrigin source
  | booleanAssignment _ _ source | booleanArrayAssignment _ _ source =>
      simp only [SourceStatement.lower, Statement.BoundsOrigin]
      exact condition_boundsOrigin source
  | assignment _ source =>
      simpa only [SourceStatement.lower, Statement.BoundsOrigin, SimpleBoundsOrigin] using stringAssignment_boundsOrigin source

theorem procedureActual_boundsOrigin {text context position facts formal actual after}
    (source : ProcedureActualAt text context position facts formal actual after) :
    ProcedureActualBoundsOrigin context.names actual := by
  cases source with
  | input _ value => exact actual_boundsOrigin value
  | target => trivial

theorem procedureActuals_boundsOrigin {text context facts catalog position first last actuals after}
    (source : ProcedureActualsAt text context facts catalog position first last actuals after) :
    ∀ actual ∈ actuals, ProcedureActualBoundsOrigin context.names actual := by
  induction source with
  | last reading _ =>
      intro actual member
      rcases List.mem_singleton.mp member with rfl
      exact procedureActual_boundsOrigin reading
  | next _ reading _ rest ih =>
      intro actual member
      rcases List.mem_cons.mp member with rfl | later
      · exact procedureActual_boundsOrigin reading
      · exact ih actual later

theorem basicStep_boundsOrigin {text context scan item result catalog procedures}
    (source : BasicStepAt text context scan item result catalog procedures) : item.lower.BoundsOrigin context.names := by
  cases source.payload with
  | primitive ordinary _ => exact basic_boundsOrigin (source.primitive ordinary)
  | procedure _ reading =>
      simpa only [SourceStatement.lower, Statement.BoundsOrigin, ProcedureCallBoundsOrigin] using
        procedureActuals_boundsOrigin reading.updates.actuals

mutual
  theorem statement_boundsOrigin {procedures : ProcedureBindings.Metadata} {text context scan item result}
      (parsed : StatementAt (catalog := catalog) (procedures := procedures) text context scan item result) : item.lower.BoundsOrigin context.names := by
    cases parsed with
    | basic _ _ _ source _ => exact basicStep_boundsOrigin source
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

  theorem loop_boundsOrigin {procedures : ProcedureBindings.Metadata} {text context scan lower upper body result}
      (parsed : LoopAt (catalog := catalog) (procedures := procedures) text context scan lower upper body result) :
      StatementsBoundsOrigin context.names (lowerStatements body) := by
    cases parsed with
    | loop _ _ _ _ _ source _ _ _ =>
        exact body_boundsOrigin (context := loopInner context (loopHeader text context scan)) source
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem arrayLoop_boundsOrigin {procedures : ProcedureBindings.Metadata} {text context scan body result}
      (parsed : ArrayLoopAt (catalog := catalog) (procedures := procedures) text context scan body result) :
      StatementsBoundsOrigin context.names (lowerStatements body) := by
    cases parsed with
    | loop _ _ _ _ source _ _ _ =>
        exact body_boundsOrigin (context := loopInner context (loopHeader text context scan)) source
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem choice_boundsOrigin {procedures : ProcedureBindings.Metadata} {text context scan condition yes tail result}
      (parsed : ChoiceAt (catalog := catalog) (procedures := procedures) text context scan condition yes tail result) :
      condition.BoundsOrigin context.names ∧ StatementsBoundsOrigin context.names (lowerStatements yes) ∧
        StatementsBoundsOrigin context.names tail.lower := by
    cases parsed with
    | choice condition _ yes _ tail _ _ _ =>
        exact ⟨condition_boundsOrigin condition, body_boundsOrigin yes, alternative_boundsOrigin tail⟩
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem alternative_boundsOrigin {procedures : ProcedureBindings.Metadata} {text context scan tail result}
      (parsed : AlternativeAt (catalog := catalog) (procedures := procedures) text context scan tail result) : StatementsBoundsOrigin context.names tail.lower := by
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

  theorem bodyTail_boundsOrigin {procedures : ProcedureBindings.Metadata} {text context stop scan items result}
      (parsed : BodyTailAt (catalog := catalog) (procedures := procedures) text context stop scan items result) :
      StatementsBoundsOrigin context.names (lowerStatements items) := by
    cases parsed with
    | done => simp only [lowerStatements, StatementsBoundsOrigin]
    | next _ _ first _ rest _ =>
        simp only [lowerStatements, StatementsBoundsOrigin]
        exact ⟨statement_boundsOrigin first, bodyTail_boundsOrigin rest⟩
  termination_by (bodyRemaining text scan, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem body_boundsOrigin {procedures : ProcedureBindings.Metadata} {text context scan stop items result}
      (parsed : BodyAt (catalog := catalog) (procedures := procedures) text context scan stop items result) :
      StatementsBoundsOrigin context.names (lowerStatements items) := by
    cases parsed with
    | cons first _ rest _ =>
        simp only [lowerStatements, StatementsBoundsOrigin]
        exact ⟨statement_boundsOrigin first, bodyTail_boundsOrigin rest⟩
  termination_by (bodyRemaining text scan, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate

namespace Silver.Compose
open Bindings StringObjectBounds

theorem boundsNamesExtend_refl (names : BindingEnvironment) :
    BoundsNamesExtend names names := fun _ _ found => found

theorem boundsNamesExtend_trans {first middle last : BindingEnvironment}
    (before : BoundsNamesExtend first middle) (after : BoundsNamesExtend middle last) :
    BoundsNamesExtend first last := fun index info found => after index info (before index info found)

theorem boundsNamesExtend_append (names : BindingEnvironment) (info : BindingInfo) :
    BoundsNamesExtend names (names ++ [info]) := by
  intro index found present
  by_cases zero : index = 0
  · simp [BindingEnvironment.get, zero] at present
  · have old : names[index - 1]? = some found := by
      simpa only [BindingEnvironment.get, zero, ↓reduceIte] using present
    have within := (List.getElem?_eq_some_iff.mp old).1
    simpa only [BindingEnvironment.get, zero, ↓reduceIte,
      List.getElem?_append_left within] using old

theorem declaration_boundsNamesExtend {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) :
    BoundsNamesExtend state.names next.names := by
  cases parsed with
  | string _ source => cases source; exact boundsNamesExtend_append _ _
  | character source => cases source; exact boundsNamesExtend_append _ _

theorem declarations_boundsNamesExtend {text arguments state final declarations}
    (parsed : DeclarationsAt text arguments state declarations final) :
    BoundsNamesExtend state.names final.names := by
  induction parsed with
  | done => exact boundsNamesExtend_refl _
  | next _ _ _ _ _ _ _ first _ ih =>
      exact boundsNamesExtend_trans (declaration_boundsNamesExtend first) ih
  | scalar _ _ _ _ first _ ih | subtype _ _ _ first _ ih => cases first; exact ih
  | boolean _ _ _ _ _ _ first _ ih => cases first; exact ih
  | array _ _ _ _ _ first _ ih =>
      simpa only [(array_declaration_preserves first).1] using ih
  | booleanArray _ _ _ _ _ first _ ih =>
      simpa only [(boolean_array_declaration_preserves first).1] using ih

  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).names] at ih
      exact ih

end Silver.Compose

namespace Silver.Predicate
open Bindings Compose PathFacts

private def BoundsHeaderToken : ShellToken → Prop
  | .contextClauses | .fixed _ _ | .declarations | .argumentDeclaration => True
  | _ => False

/-- Last retained complete declaration table. An argument event does not carry
its source-name metadata, so it clears the accumulator. Every admitted prefix
ends in the mixed declarations event, including an empty declaration region. -/
private def retainedNamesStep (previous : Option Compose.BindingEnvironment) : Event →
    Option Compose.BindingEnvironment
  | .declarations _ names => some names
  | .argument _ => none
  | _ => previous

private def retainedNames (previous : Option Compose.BindingEnvironment) (events : List Event) :=
  events.foldl retainedNamesStep previous

private theorem step_retainedNames {text form token state next event previous}
    (ordinary : BoundsHeaderToken token)
    (prior : ∀ names, previous = some names → names = state.names)
    (parsed : StepAt text form token state next event) :
    ∀ names, retainedNames previous event.toList = some names → names = next.names := by
  have payload := parsed.payload
  cases token with
  | declarations =>
      obtain ⟨values, reading, rfl⟩ := payload
      intro names equal
      exact (Option.some.inj equal).symm
  | argumentDeclaration =>
      obtain ⟨fallback, reading, rfl⟩ := payload
      simp [retainedNames, retainedNamesStep]
  | contextClauses | fixed =>
      change event = none at payload
      subst event
      have same := (Sequence.step_shape (by trivial) parsed).1
      intro names equal
      exact (prior names equal).trans same.symm
  | _ => contradiction

private theorem tokens_retainedNames {text form tokens state events final previous}
    (ordinary : ∀ token ∈ tokens, BoundsHeaderToken token)
    (prior : ∀ names, previous = some names → names = state.names)
    (parsed : Sequence.TokensAt text form tokens state events final) :
    ∀ names, retainedNames previous events = some names → names = final.names := by
  induction parsed generalizing previous with
  | done => exact prior
  | next first _ ih =>
      have next := step_retainedNames (ordinary _ (by simp)) prior first
      simpa only [retainedNames, List.foldl_append] using
        ih (fun token present => ordinary token (by simp [present])) next

theorem decoded_body_and_names {source form events items scalars constants checks arrays booleans booleanChecks functions procedures program}
    (header : Sequence.TokensAt source form.helper form.prefix initialState events
      (prefixScan source form).state)
    (decoded : decodePrefix form events items scalars constants checks arrays booleans booleanChecks functions procedures = some program) :
    program.names = (contextOf (prefixScan source form)).names ∧
      program.statements = lowerStatements items := by
  have retained := tokens_retainedNames
    (by cases form <;> simp [Form.prefix, Form.hasArguments, currentHeader, BoundsHeaderToken,
      ShellToken.word, ShellToken.symbol])
    (previous := none) (by simp) header
  have payload : retainedNames none events = some program.names ∧
      program.statements = lowerStatements items := by
    unfold decodePrefix at decoded
    split at decoded <;> cases decoded <;> exact ⟨rfl, rfl⟩
  exact ⟨retained _ payload.1, payload.2⟩

private theorem step_header_bounds {text input : Source} {form token state next event values}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (printable : Bindings.Printable input) (ordinary : BoundsHeaderToken token)
    (valid : StateValid state) (metadata : NamesBoundsValid state.names)
    (count : state.names.length ≤ maxBindings) (strings : Fits state.names.shape input values)
    (parsed : StepAt text form token state next event) :
    NamesBoundsValid next.names ∧ next.names.length ≤ maxBindings ∧
      ∃ following, Fits next.names.shape input following := by
  have payload := parsed.payload
  cases token with
  | declarations =>
      obtain ⟨declarations, source, _⟩ := payload
      have actual := declarations_bounds textBound inputBound printable count metadata strings valid.2.2.2 source
      exact ⟨actual.1, actual.2.1, _, actual.2.2⟩
  | argumentDeclaration =>
      obtain ⟨fallback, source, _⟩ := payload
      have metadata := argument_bounds source
      have shape := argument_shape source
      have values := Bindings.declaration_preserves (empty_fits input) printable shape.2.2
      change Fits argumentShape input (argumentDeclaration.execute emptyValues input) at values
      exact ⟨metadata.1, metadata.2, _, shape.2.1.symm ▸ values⟩
  | contextClauses | fixed =>
      have names := (Sequence.step_shape (by trivial) parsed).1
      rw [names]
      exact ⟨metadata, count, values, strings⟩
  | _ => contradiction

private theorem tokens_header_bounds {text input : Source} {form tokens state events final values}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (printable : Bindings.Printable input) (ordinary : ∀ token ∈ tokens, BoundsHeaderToken token)
    (valid : StateValid state) (metadata : NamesBoundsValid state.names)
    (count : state.names.length ≤ maxBindings) (strings : Fits state.names.shape input values)
    (parsed : Sequence.TokensAt text form tokens state events final) :
    NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
      ∃ following, Fits final.names.shape input following := by
  induction parsed generalizing values with
  | done => exact ⟨metadata, count, values, strings⟩
  | next first _ ih =>
      obtain ⟨nextMetadata, nextCount, following, nextStrings⟩ :=
        step_header_bounds textBound inputBound printable (ordinary _ (by simp)) valid metadata count strings first
      exact ih (fun token present => ordinary token (by simp [present]))
        (step_valid textBound valid first).1 nextMetadata nextCount nextStrings

theorem prefix_names_bounds {source form events}
    (textBound : source.length ≤ maxSourceLength)
    (header : Sequence.TokensAt source form.helper form.prefix initialState events
      (prefixScan source form).state) :
    NamesBoundsValid (prefixScan source form).state.names ∧
      (prefixScan source form).state.names.length ≤ maxBindings := by
  have result := tokens_header_bounds (input := []) textBound (by simp)
    (by simp [Bindings.Printable])
    (by cases form <;> simp [Form.prefix, Form.hasArguments, currentHeader, BoundsHeaderToken,
      ShellToken.word, ShellToken.symbol]) Compose.initial_valid namesBoundsValid_empty
    (by simp [initialState]) (by simpa only [initialState, empty_names_shape] using empty_fits []) header
  exact ⟨result.1, result.2.1⟩

theorem boolean_array_values_boundsOrigin {text state maskFirst maskAfter position length parsed raw finish}
    (trace : BooleanArrayValuesAt text state maskFirst maskAfter position length parsed raw finish) :
    ∀ value ∈ raw, value.BoundsOrigin state.names := by
  induction trace with
  | done => intro value member; cases member
  | next _ reading _ ih =>
      intro value member
      rcases List.mem_cons.mp member with rfl | member
      · exact condition_boundsOrigin reading
      · exact ih value member

theorem boolean_array_declaration_boundsOrigin {text state declaration checks}
    (trace : BooleanArrayDeclarationChecksAt text state declaration checks) :
    ∀ value ∈ declaration.values, value.BoundsOrigin state.names := by
  obtain ⟨parts, position, raw, finish, _, _, values, rfl, _⟩ := trace
  intro value member
  obtain ⟨condition, present, rfl⟩ := List.mem_map.mp member
  exact Condition.boundsOrigin_freeze _ (boolean_array_values_boundsOrigin values condition present)

theorem boolean_declarations_boundsOrigin {source arguments before after declarations checks}
    (trace : BooleanDeclarationsAt source arguments before declarations checks after) :
    ∀ declaration ∈ declarations, declaration.value.BoundsOrigin after.names := by
  induction trace with
  | done => simp
  | string _ _ _ _ _ _ _ _ _ ih | scalar _ _ _ _ _ _ ih => exact ih
  | array _ _ _ _ _ _ _ ih | subtype _ _ _ _ _ ih => exact ih
  | @booleanArray state middle final declaration rest firstChecks checks _ _ _ _ _ first raw tail ih =>
      intro selected present
      rcases List.mem_append.mp present with member | member
      · have origin := boolean_array_declaration_boundsOrigin raw selected.value
          (declaration.initializations_member member).1
        obtain ⟨strings, remaining⟩ := boolean_declarations_reading tail
        have extension := declarations_boundsNamesExtend remaining
        rw [(boolean_array_declaration_preserves first).1] at extension
        exact Condition.boundsOrigin_extends extension origin
      · exact ih selected member
  | @boolean state middle final declaration rest firstChecks checks _ _ _ _ _ _ first raw tail ih =>
      intro selected present
      rcases List.mem_cons.mp present with rfl | present
      · obtain ⟨condition, parsed, rfl, _⟩ := raw
        have origin := Condition.boundsOrigin_freeze
          (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)
          (condition_boundsOrigin parsed)
        obtain ⟨strings, remaining⟩ := boolean_declarations_reading tail
        have extension := declarations_boundsNamesExtend remaining
        rw [(boolean_declaration_preserves first).1] at extension
        exact Condition.boundsOrigin_extends extension origin
      · exact ih _ present

  | callable _ _ _ _ ih => exact ih

theorem prefix_boolean_boundsOrigin {source form declarations checks}
    (trace : BooleanHeaderAt source form declarations checks) :
    ∀ declaration ∈ declarations,
      declaration.value.BoundsOrigin (contextOf (prefixScan source form)).names := by
  obtain ⟨before, after, leading, event, _, trace, ending⟩ := trace
  have names := (Sequence.step_shape (by trivial) ending).1
  change (prefixScan source form).state.names = after.names at names
  simpa only [contextOf, names] using boolean_declarations_boundsOrigin trace

structure HeaderBoundsFacts (program : Program) : Prop where
  metadata : NamesBoundsValid program.names
  count : program.names.length ≤ maxBindings
  statements : StatementsBoundsOrigin program.names program.statements
  booleanOrigins : ∀ declaration ∈ program.booleanDeclarations,
    declaration.value.BoundsOrigin program.names

theorem source_header_bounds_facts {source program}
    (meaning : SourceMeaning source program) : HeaderBoundsFacts program := by
  obtain ⟨form, events, items, scalars, checks, booleans, booleanChecks, domain, _,
    reading, _, _, booleanTrace, functions, procedures, _, decoded⟩ := meaning
  have names := decoded_body_and_names reading.header decoded
  have metadata := prefix_names_bounds domain.2.1 reading.header
  have booleanFields := decoded_boolean_state decoded
  refine ⟨?_, ?_, ?_, ?_⟩
  · simpa only [names.1, contextOf] using metadata.1
  · simpa only [names.1, contextOf] using metadata.2
  · rw [names.1, names.2]
    exact body_boundsOrigin reading.statements
  · rw [names.1, booleanFields.1]
    exact prefix_boolean_boundsOrigin booleanTrace


/-- The declaration certificate refines the exact retained source schema, not
the larger uniform fragment schema. The latter is used only by the existing
fragment soundness proof. -/
def declarationBoundsCertificate (names : Compose.BindingEnvironment)
    (declaration : Declaration) : StringBoundsObligation :=
  ⟨names.length, .declaration (expressionSchema names.shape maxSourceLength declaration.initializer)⟩

theorem declarationBoundsCertificate_refines {names : Compose.BindingEnvironment}
    (count : names.length ≤ maxBindings) (declaration : Declaration) :
    (Check.stringBounds (declarationBoundsCertificate names declaration)).Refines
      (.declaration (.range (expressionSchema names.shape maxSourceLength declaration.initializer))) := by
  exact ⟨count, _, rfl, Nat.le_refl _, Nat.le_refl _⟩

theorem declaration_range_check_present {program : Program} {schema : Guarded.RangeObligation}
    (present : schema ∈ declarationRangeObligations emptyShape program.names.shape program.declarations) :
    Check.declaration (.range schema) ∈ program.checks := by
  simp only [Program.checks, declarationChecks, List.mem_append, List.mem_map]
  exact Or.inr (Or.inl (Or.inl (Or.inl ⟨.range schema,
    Or.inl ⟨schema, present, rfl⟩, rfl⟩)))

theorem raw_boolean_check_present {program : Program} {check : Obligation}
    (present : check ∈ program.booleanInitializerChecks) : Check.path check ∈ program.checks := by
  simp only [Program.checks, List.mem_append, List.mem_map]
  exact Or.inr (Or.inl (Or.inr ⟨check, Or.inl present, rfl⟩))

/-- A complete local occurrence witness. `values` is supplied by the source-
order traversal, so it is the store before this declaration, not the final body
store. Both raw and frozen expressions quantify over every grouping. -/
def RawStringInitializerBounds (text : Source) (program : Program) (state next : ParserState)
    (declaration : Declaration) (input : Source) (values : Values) : Prop :=
  ∃ raw result certificate,
    ExpressionAt text state.names (declarationValuePosition text state) raw result
      state.scalarNames (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true ∧
    declaration.initializer = raw.freezeImages
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    certificate = declarationBoundsCertificate state.names declaration ∧
    Check.declaration (.range (expressionSchema state.names.shape maxSourceLength declaration.initializer))
      ∈ program.checks ∧
    (Check.stringBounds certificate).Refines
      (.declaration (.range (expressionSchema state.names.shape maxSourceLength declaration.initializer))) ∧
    certificate.Valid ∧
    (∀ valid rejected, certificate.length.Covers valid input.length rejected
      (raw.evaluate values input (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).length) ∧
    raw.ObjectBoundsSafe state.names values input
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    (∀ after, declaration.initializer.ObjectBoundsSafe state.names values input after) ∧
    (∀ grouped : GroupedExpression, grouped.flatten = raw → ∀ after,
      (grouped.freezeImages (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).flatten =
        declaration.initializer ∧
      (grouped.freezeImages (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).objectBounds
        state.names input after = grouped.objectBounds state.names input
          (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
      (grouped.freezeImages (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).BoundsSafe
        state.names input after) ∧
    (∃ info, next.names.get declaration.index = some info ∧ info.isCharacter = false ∧
      (info.dynamic = false → BindingInfo.objectBounds info = raw.objectBounds state.names input
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)))

theorem raw_string_initializer_bounds {text input : Source} {arguments state next declaration values program}
    (valid : program.Valid) (inputBound : input.length ≤ maxSourceLength)
    (count : state.names.length ≤ maxBindings) (metadata : NamesBoundsValid state.names)
    (strings : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (present : Check.declaration (.range
      (expressionSchema state.names.shape maxSourceLength declaration.initializer)) ∈ program.checks)
    (parsed : StringDeclarationAt text arguments state declaration next) :
    RawStringInitializerBounds text program state next declaration input values := by
  have capture := string_declaration_capture input values metadata.normal static parsed
  cases parsed with
  | @declaration parts expression partsEq allowed following notFull bounded nonempty exactLength fixedBounds source =>
      let snapshot := frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values
      let frozen := expression.freezeImages snapshot
      let declaration : Declaration := ⟨state.names.length + 1, decide (parts.constantAfter = 0), frozen⟩
      let certificate := declarationBoundsCertificate state.names declaration
      have refined := declarationBoundsCertificate_refines count declaration
      have fragment := Check.fragment_of_refines refined (Program.checks_fragment valid _ present)
      have certificateValid : certificate.Valid := Check.fragment_valid fragment
      have frozenSafe := expressionAt_safe metadata.normal static source bounded
      have scalars := frozenIntegers_fits (arrays := state.arrayNames.names)
        (initials := state.arrayNames.values) static
      have rawSafe : expression.RuntimeSafe values input snapshot := by
        refine ⟨(Expression.inferLength_sound (expressionAt_inferLength metadata.normal source) strings scalars).2, ?_⟩
        rw [← Expression.freezeImages_evaluate]
        exact Expression.output_bound frozenSafe strings inputBound
      have frozenLength := Expression.evaluate_length strings frozenSafe.1
      have covered : ∀ valid rejected, certificate.length.Covers valid input.length rejected
          (expression.evaluate values input snapshot).length := by
        intro valid rejected
        refine ⟨frozen.dynamicCount state.names.shape * input.length,
          Nat.mul_le_mul_left _ inputBound, ?_⟩
        rw [← Expression.freezeImages_evaluate]
        exact Nat.le_of_eq frozenLength
      have rawBounds := StringBoundsObligation.expression_safe certificateValid (Nat.le_refl _)
        metadata strings (expression_boundsOrigin source) rawSafe (covered true false)
      have frozenBounds : ∀ after, frozen.ObjectBoundsSafe state.names values input after := by
        intro after
        apply StringBoundsObligation.expression_safe certificateValid (Nat.le_refl _) metadata strings
          (Expression.boundsOrigin_freeze snapshot (expression_boundsOrigin source))
          (frozen_expression_safe rawSafe)
        simpa only [frozen, frozen_expression_evaluate] using covered true false
      refine ⟨expression, parts.value, certificate, source, rfl, rfl, present, refined,
        certificateValid, covered, rawBounds, frozenBounds, ?_, ?_⟩
      · intro grouped ordered after
        refine ⟨?_, GroupedExpression.freezeImages_objectBounds grouped snapshot after _ _, ?_⟩
        · rw [GroupedExpression.freezeImages_flatten, ordered]
        · exact (GroupedExpression.freezeImages_boundsSafe grouped snapshot after _ _).mpr
            (rawBounds grouped ordered).1
      · obtain ⟨other, result, info, otherRead, selected, typed, _, bounds⟩ := capture
        have same := expressionTail_unique source otherRead
        cases same.1
        exact ⟨info, selected, typed, bounds⟩

def RawCharacterInitializerBounds (text : Source) (program : Program) (state next : ParserState)
    (declaration : Declaration) (input : Source) (values : Values) : Prop :=
  ∃ position raw result certificate,
    CharacterAt text state.names state.scalarNames state.arrayNames.names state.arrayNames.values true
      position raw result ∧
    declaration.initializer = Expression.freezeImages [.character raw]
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    certificate = declarationBoundsCertificate state.names declaration ∧
    Check.declaration (.range (expressionSchema state.names.shape maxSourceLength declaration.initializer))
      ∈ program.checks ∧
    (Check.stringBounds certificate).Refines
      (.declaration (.range (expressionSchema state.names.shape maxSourceLength declaration.initializer))) ∧
    certificate.Valid ∧
    (∀ valid rejected, certificate.length.Covers valid input.length rejected 1) ∧
    Expression.RuntimeSafe ([.character raw]) values input
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    Expression.ObjectBoundsSafe ([.character raw]) state.names values input
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    (∀ after, declaration.initializer.ObjectBoundsSafe state.names values input after) ∧
    (∃ position expression result info,
      CharacterAt text state.names state.scalarNames state.arrayNames.names state.arrayNames.values true
        position expression result ∧
      next.names.get declaration.index = some info ∧ info.isCharacter = true ∧
      BindingInfo.objectBounds info = StringObjectBounds.Bounds.canonical 1 ∧
      declaration.initializer.evaluate values input = [expression.evaluate values
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)])

theorem raw_character_initializer_bounds {text input : Source} {arguments state next declaration values program}
    (valid : program.Valid) (inputBound : input.length ≤ maxSourceLength)
    (count : state.names.length ≤ maxBindings) (metadata : NamesBoundsValid state.names)
    (strings : Fits state.names.shape input values)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (present : Check.declaration (.range
      (expressionSchema state.names.shape maxSourceLength declaration.initializer)) ∈ program.checks)
    (parsed : CharacterDeclarationAt text arguments state declaration next) :
    RawCharacterInitializerBounds text program state next declaration input values := by
  have capture := character_declaration_capture input values parsed
  cases parsed with
  | @declaration parts expression partsEq checked following source =>
      let snapshot := frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values
      let raw : Expression := [.character expression]
      let frozen := raw.freezeImages snapshot
      let declaration : Declaration := ⟨state.names.length + 1, decide (parts.constantAfter = 0), frozen⟩
      let certificate := declarationBoundsCertificate state.names declaration
      have refined := declarationBoundsCertificate_refines count declaration
      have certificateValid : certificate.Valid := Check.fragment_valid
        (Check.fragment_of_refines refined (Program.checks_fragment valid _ present))
      have scalars := frozenIntegers_fits (arrays := state.arrayNames.names)
        (initials := state.arrayNames.values) static
      have frozenSafe := characterExpression_frozen_safe metadata.normal source scalars
      have rawOrigin : raw.BoundsOrigin state.names := by
        intro atom member
        have same := List.mem_singleton.mp member
        subst atom
        exact character_boundsOrigin source
      have rawSafe : raw.RuntimeSafe values input snapshot := by
        refine ⟨(Expression.inferLength_sound (characterExpression_inferLength metadata.normal source)
          strings scalars).2, ?_⟩
        simp [raw, Expression.evaluate, Value.evaluate, maxSourceLength]
      have length : (raw.evaluate values input snapshot).length = 1 := by
        simp [raw, Expression.evaluate, Value.evaluate]
      have frozenLength := Expression.evaluate_length strings frozenSafe.1
      have covered : ∀ valid rejected, certificate.length.Covers valid input.length rejected 1 := by
        intro valid rejected
        refine ⟨frozen.dynamicCount state.names.shape * input.length,
          Nat.mul_le_mul_left _ inputBound, ?_⟩
        rw [← length, ← Expression.freezeImages_evaluate]
        exact Nat.le_of_eq frozenLength
      have rawBounds := StringBoundsObligation.expression_safe certificateValid (Nat.le_refl _)
        metadata strings rawOrigin rawSafe (length.symm ▸ covered true false)
      have frozenBounds : ∀ after, frozen.ObjectBoundsSafe state.names values input after := by
        intro after
        apply StringBoundsObligation.expression_safe certificateValid (Nat.le_refl _) metadata strings
          (Expression.boundsOrigin_freeze snapshot rawOrigin) (frozen_expression_safe rawSafe)
        simpa only [frozen, frozen_expression_evaluate, length] using covered true false
      exact ⟨_, expression, parts.value, certificate, source, rfl, rfl, present, refined,
        certificateValid, covered, rawSafe, rawBounds, frozenBounds, capture⟩

/-- The old retained declaration schema is calculated in exactly the prefix
table used by this raw initializer. This is the key source-order inventory
identity; only complete metadata extension can justify the fixed slot lookup. -/
theorem declaration_range_inventory_step {text arguments state middle final declaration rest}
    (normal : NamesNormal state.names) (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (first : DeclarationAt text arguments state declaration middle)
    (remaining : DeclarationsAt text arguments middle rest final) :
    declarationRangeObligations state.names.shape final.names.shape (declaration :: rest) =
      expressionSchema state.names.shape maxSourceLength declaration.initializer ::
        declarationRangeObligations middle.names.shape final.names.shape rest := by
  obtain ⟨bound, valid, shape⟩ := declaration_shape normal static first
  have nextNormal := declaration_normal normal first
  have nextStatic := (declaration_scalarNames first).symm ▸ static
  have tail := declarations_shape nextNormal nextStatic remaining
  have target : final.names.shape declaration.index = some ⟨bound, declaration.mutable⟩ := by
    apply declarations_extend tail
    rw [shape]
    simp [Declaration.extend, put_same]
  simp only [declarationRangeObligations, declarationBound, target, Option.map_some,
    Option.getD_some, ← shape]

/-- Raw Boolean checks are retained before freezing; each String-range member
gets a concrete endpoint certificate, linked to the existing program stream. -/
def RawBooleanBoundsCertificates (program : Program) (names : Compose.BindingEnvironment)
    (checks : List Obligation) : Prop :=
  ∀ context summary, Obligation.stringRange context summary ∈ checks →
    ∃ certificate : StringBoundsObligation,
      certificate.bindingCount = names.length ∧ certificate.length = .path context summary ∧
      Check.path (.stringRange context summary) ∈ program.checks ∧
      (Check.stringBounds certificate).Refines (.path (.stringRange context summary)) ∧
      certificate.Valid

theorem raw_boolean_bounds_certificates {program : Program} {names : Compose.BindingEnvironment}
    {checks : List Obligation} (valid : program.Valid) (count : names.length ≤ maxBindings)
    (members : ∀ check ∈ checks, check ∈ program.booleanInitializerChecks) :
    RawBooleanBoundsCertificates program names checks := by
  intro context summary member
  let certificate : StringBoundsObligation := ⟨names.length, .path context summary⟩
  have present := raw_boolean_check_present (members _ member)
  have refined : (Check.stringBounds certificate).Refines (.path (.stringRange context summary)) := ⟨count, rfl⟩
  have fragment := Check.fragment_of_refines refined (Program.checks_fragment valid _ present)
  exact ⟨certificate, rfl, rfl, present, refined, Check.fragment_valid fragment⟩

/-- Consume the exact certificates of the raw source condition at each reached
String comparison. In particular, the proof of actual bounds does not discard
the occurrence-to-schema linkage and replace it with an unrelated uniform
arithmetic fact. Short-circuit refinement follows the original raw condition. -/
theorem condition_objectBounds_from_raw_certificates {condition : Condition} {program : Program}
    {names : Compose.BindingEnvironment} {hasArguments : Bool} {analysis : Integer.Analysis}
    {flow : Flow} {integers : Integer.Store} {values : Values} {input : Source}
    {valid rejected : Bool} {booleanAnalysis : Boolean.Analysis} {booleans : Boolean.Store}
    (metadata : NamesBoundsValid names) (strings : Fits names.shape input values)
    (origin : condition.BoundsOrigin names)
    (readable : condition.Readable hasArguments names.shape booleanAnalysis)
    (allowed : flow.Allows valid input.length rejected integers)
    (checked : condition.checkBounds names.shape analysis flow booleanAnalysis = true)
    (certificates : RawBooleanBoundsCertificates program names
      (condition.obligations names.shape analysis flow booleanAnalysis)) :
    condition.ObjectBoundsSafe names values input valid integers booleans := by
  induction condition generalizing flow with
  | stringCompare unequal left right =>
      simp only [Condition.checkBounds] at checked
      split at checked
      · rename_i a b leftKnown rightKnown
        obtain ⟨leftChecked, rightChecked⟩ := Bool.and_eq_true_iff.mp checked
        have leftMember : Obligation.stringRange flow.path a ∈
            (Condition.stringCompare unequal left right).obligations names.shape analysis flow booleanAnalysis := by
          simp [Condition.obligations, leftKnown, rightKnown]
        have rightMember : Obligation.stringRange flow.path b ∈
            (Condition.stringCompare unequal left right).obligations names.shape analysis flow booleanAnalysis := by
          simp [Condition.obligations, leftKnown, rightKnown]
        obtain ⟨leftCertificate, leftCount, leftLength, _, _, leftValid⟩ := certificates _ _ leftMember
        obtain ⟨rightCertificate, rightCount, rightLength, _, _, rightValid⟩ := certificates _ _ rightMember
        constructor
        · apply StringBoundsObligation.expression_safe leftValid (Nat.le_of_eq leftCount.symm)
            metadata strings origin.1 (expression_safe_on_path leftKnown strings allowed.2 allowed.1 leftChecked)
          rw [leftLength]
          exact ⟨allowed.1, _, (Expression.inferLength_sound leftKnown strings allowed.2).1, Nat.le_refl _⟩
        · apply StringBoundsObligation.expression_safe rightValid (Nat.le_of_eq rightCount.symm)
            metadata strings origin.2 (expression_safe_on_path rightKnown strings allowed.2 allowed.1 rightChecked)
          rw [rightLength]
          exact ⟨allowed.1, _, (Expression.inferLength_sound rightKnown strings allowed.2).1, Nat.le_refl _⟩
      · contradiction
  | parenthesized inner ih | negated inner ih => exact ih origin readable allowed checked certificates
  | andThen left right ihl ihr =>
      obtain ⟨leftChecked, rightChecked⟩ := Bool.and_eq_true_iff.mp checked
      refine ⟨ihl origin.1 readable.1 allowed leftChecked
        (fun context summary member => certificates context summary (List.mem_append_left _ member)), ?_⟩
      intro reached
      apply ihr origin.2 readable.2 _ rightChecked
        (fun context summary member => certificates context summary (List.mem_append_right _ member))
      have next := left.refine_sound (analysis := analysis) (booleans := booleans) strings readable.1 allowed
      simpa only [reached] using next
  | orElse left right ihl ihr =>
      obtain ⟨leftChecked, rightChecked⟩ := Bool.and_eq_true_iff.mp checked
      refine ⟨ihl origin.1 readable.1 allowed leftChecked
        (fun context summary member => certificates context summary (List.mem_append_left _ member)), ?_⟩
      intro reached
      apply ihr origin.2 readable.2 _ rightChecked
        (fun context summary member => certificates context summary (List.mem_append_right _ member))
      have next := left.refine_sound (analysis := analysis) (booleans := booleans) strings readable.1 allowed
      simpa only [reached] using next
  | eager operator left right ihl ihr | booleanCompare unequal left right ihl ihr =>
      obtain ⟨leftChecked, rightChecked⟩ := Bool.and_eq_true_iff.mp checked
      exact ⟨ihl origin.1 readable.1 allowed leftChecked
          (fun context summary member => certificates context summary (List.mem_append_left _ member)),
        ihr origin.2 readable.2 allowed rightChecked
          (fun context summary member => certificates context summary (List.mem_append_right _ member))⟩
  | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral | booleanName | booleanArrayRead => trivial

/-- For each declaration-time String store satisfying the actual prefix table,
the raw Boolean condition is safe at the source snapshot. Arbitrary Boolean
stores are intentional: Boolean names do not strengthen the initial flow. -/
def RawBooleanInitializerBounds (text : Source) (program : Program) (state : ParserState)
    (declaration : BooleanDeclaration) (checks : List Obligation)
    (input : Source) (inputValid : Bool) (values : Values) : Prop :=
  ∃ raw,
    ConditionAt text (booleanDeclarationContext state (booleanDeclarationParts text state))
      (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state)
      raw (booleanDeclarationValue text state) state.arrayNames.values ∧
    declaration = ⟨state.booleanNames.length + 1,
      decide ((booleanDeclarationParts text state).constantAfter = 0),
      raw.freezeIntegers (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)⟩ ∧
    checks = raw.obligations state.names.shape
      (booleanDeclarationContext state (booleanDeclarationParts text state)).analysis
      ((booleanDeclarationContext state (booleanDeclarationParts text state)).flow
        (booleanDeclarationFacts state) state.arrayNames.values)
      (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) ∧
    RawBooleanBoundsCertificates program state.names checks ∧
    (∀ booleans, raw.ObjectBoundsSafe state.names values input inputValid
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) booleans) ∧
    (∀ after booleans, declaration.value.ObjectBoundsSafe state.names values input inputValid after booleans)

/-- This local lemma consumes the same checked raw condition and its exact
declaration-time flow. The global traversal must derive `allowed` from the
decoded program's initial input context, never assume it as a native contract. -/
theorem raw_boolean_initializer_bounds {text state declaration checks program input inputValid values}
    (valid : program.Valid) (count : state.names.length ≤ maxBindings)
    (metadata : NamesBoundsValid state.names) (strings : Fits state.names.shape input values)
    (stateValid : Compose.Expressions.ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (allowed : (booleanDeclarationFacts state).path.Allows inputValid input.length false)
    (members : ∀ check ∈ checks, check ∈ program.booleanInitializerChecks)
    (trace : BooleanDeclarationChecksAt text state declaration checks) :
    RawBooleanInitializerBounds text program state declaration checks input inputValid values := by
  obtain ⟨raw, parsed, frozen, schemas⟩ := trace
  have meaning := boolean_declaration_meaning metadata.normal stateValid ready parsed
  have origin := condition_boundsOrigin parsed
  have fits := boolean_declaration_ranges_fit (parts := booleanDeclarationParts text state) static
  have flowAllowed : ((booleanDeclarationContext state (booleanDeclarationParts text state)).flow
      (booleanDeclarationFacts state) state.arrayNames.values).Allows inputValid input.length false
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) := ⟨allowed, fits⟩
  have safe : ∀ booleans, raw.Safe state.names.shape values input inputValid
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) booleans :=
    fun _ => Condition.checkBounds_sound strings meaning.readable flowAllowed meaning.checked
  have certificates := raw_boolean_bounds_certificates valid count members
  refine ⟨raw, parsed, frozen, schemas, certificates, ?_, ?_⟩
  · intro booleans
    rw [schemas] at certificates
    exact condition_objectBounds_from_raw_certificates metadata strings origin meaning.readable
      flowAllowed meaning.checked certificates
  · intro after booleans
    rw [frozen]
    exact Condition.objectBoundsSafe_of_safe count metadata strings
      (Condition.boundsOrigin_freeze _ origin) (Condition.freezeIntegers_safe (safe booleans))


/-- Every component retains its source condition and raw certificates. All
components use the same incoming Integer and Boolean snapshot, independently
of the ordered allocation events used by the semantic declaration stream. -/
def RawBooleanArrayInitializerBounds (text : Source) (program : Program) (state : ParserState)
    (declaration : BooleanArrayDeclaration) (checks : List Obligation)
    (input : Source) (inputValid : Bool) (values : Values) : Prop :=
  ∃ parts position raw finish,
    arrayDeclarationParts text state = parts ∧
    ArrayAggregateAt text state parts position ∧
    BooleanArrayValuesAt text state parts.first parts.after position parts.length 0 raw finish ∧
    declaration = ⟨(parts.binding state).booleanDescriptor, decide (parts.constantAfter = 0),
      raw.map (fun value => value.freezeIntegers
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values))⟩ ∧
    checks = booleanArrayRawChecks state parts.first parts.after raw ∧
    RawBooleanBoundsCertificates program state.names checks ∧
    (∀ value ∈ raw, ∀ booleans, value.ObjectBoundsSafe state.names values input inputValid
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) booleans) ∧
    (∀ value ∈ declaration.values, ∀ after booleans,
      value.ObjectBoundsSafe state.names values input inputValid after booleans)

theorem raw_boolean_array_initializer_bounds {text state declaration checks program input inputValid values}
    (valid : program.Valid) (count : state.names.length ≤ maxBindings)
    (metadata : NamesBoundsValid state.names) (strings : Fits state.names.shape input values)
    (stateValid : Compose.Expressions.ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (allowed : (booleanDeclarationFacts state).path.Allows inputValid input.length false)
    (members : ∀ check ∈ checks, check ∈ program.booleanInitializerChecks)
    (trace : BooleanArrayDeclarationChecksAt text state declaration checks) :
    RawBooleanArrayInitializerBounds text program state declaration checks input inputValid values := by
  obtain ⟨parts, position, raw, finish, partsEq, aggregate, source, frozen, schemas⟩ := trace
  have meaning := source.valid metadata.normal stateValid ready
  have origins := boolean_array_values_boundsOrigin source
  have fits := boolean_initializer_ranges_fit (maskFirst := parts.first) (maskAfter := parts.after) static
  have flowAllowed : ((booleanInitializerContext state parts.first parts.after).flow
      (booleanInitializerFacts state) state.arrayNames.values).Allows inputValid input.length false
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) := ⟨allowed, fits⟩
  have certificates := raw_boolean_bounds_certificates valid count members
  have safe : ∀ value ∈ raw, ∀ booleans, value.Safe state.names.shape values input inputValid
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) booleans := by
    intro value member booleans
    exact Condition.checkBounds_sound strings (meaning value member).2.1 flowAllowed (meaning value member).2.2
  refine ⟨parts, position, raw, finish, partsEq, aggregate, source, frozen, schemas, certificates, ?_, ?_⟩
  · intro value member booleans
    apply condition_objectBounds_from_raw_certificates metadata strings (origins value member)
      (meaning value member).2.1 flowAllowed (meaning value member).2.2
    intro context summary check
    apply certificates context summary
    rw [schemas]
    exact List.mem_flatMap.mpr ⟨value, member, check⟩
  · intro value member after booleans
    rw [frozen] at member
    obtain ⟨condition, present, rfl⟩ := List.mem_map.mp member
    exact Condition.objectBoundsSafe_of_safe count metadata strings
      (Condition.boundsOrigin_freeze _ (origins condition present))
      (Condition.freezeIntegers_safe (safe condition present booleans))

/-- This checked trace follows all eight alternatives of the *same* mixed source
declaration grammar. The String store advances only at String/Character
declarations, and each Boolean initializer is checked against the store at its
own source position. There is no constructor that omits an initializer. -/
inductive RawHeaderBoundsTrace (text : Source) (arguments : Bool) (program : Program)
    (input : Source) (inputValid : Bool) :
    ParserState → Values → List Declaration → List BooleanDeclaration → List Obligation → ParserState → Prop
  | done {state values} : state.position ≠ 0 → fixedAfter text state.position "begin" true ≠ 0 →
      RawHeaderBoundsTrace text arguments program input inputValid state values [] [] [] state
  | callable {state final values strings booleans checks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position ≠ 0 →
      RawHeaderBoundsTrace text arguments program input inputValid
        (callableDeclarationAt text state arguments) values strings booleans checks final →
      RawHeaderBoundsTrace text arguments program input inputValid state values strings booleans checks final
  | string {state middle final values declaration strings booleans checks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      (RawStringInitializerBounds text program state middle declaration input values ∨
        RawCharacterInitializerBounds text program state middle declaration input values) →
      RawHeaderBoundsTrace text arguments program input inputValid middle
        (declaration.execute values input) strings booleans checks final →
      RawHeaderBoundsTrace text arguments program input inputValid state values
        (declaration :: strings) booleans checks final
  | scalar {state middle final values declaration strings booleans checks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      RawHeaderBoundsTrace text arguments program input inputValid middle values strings booleans checks final →
      RawHeaderBoundsTrace text arguments program input inputValid state values strings booleans checks final
  | array {state middle final values declaration strings booleans checks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      RawHeaderBoundsTrace text arguments program input inputValid middle values strings booleans checks final →
      RawHeaderBoundsTrace text arguments program input inputValid state values strings booleans checks final
  | booleanArray {state middle final values declaration strings booleans firstChecks checks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanArrayDeclarationAt text arguments state middle →
      BooleanArrayDeclarationChecksAt text state declaration firstChecks →
      RawBooleanArrayInitializerBounds text program state declaration firstChecks input inputValid values →
      RawHeaderBoundsTrace text arguments program input inputValid middle values strings booleans checks final →
      RawHeaderBoundsTrace text arguments program input inputValid state values strings
        (declaration.initializations ++ booleans) (firstChecks ++ checks) final
  | subtype {state middle final values strings booleans checks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      SubtypeDeclarationAt text arguments state middle →
      RawHeaderBoundsTrace text arguments program input inputValid middle values strings booleans checks final →
      RawHeaderBoundsTrace text arguments program input inputValid state values strings booleans checks final
  | boolean {state middle final values declaration strings booleans firstChecks checks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      BooleanDeclarationChecksAt text state declaration firstChecks →
      RawBooleanInitializerBounds text program state declaration firstChecks input inputValid values →
      RawHeaderBoundsTrace text arguments program input inputValid middle values strings booleans checks final →
      RawHeaderBoundsTrace text arguments program input inputValid state values strings
        (declaration :: booleans) (firstChecks ++ checks) final

/-- Source correspondence is retained by the safety trace itself, in addition
to the checked occurrence witnesses stored at each node. -/
theorem RawHeaderBoundsTrace.source {text arguments program input inputValid state values strings booleans checks final}
    (trace : RawHeaderBoundsTrace text arguments program input inputValid state values strings booleans checks final) :
    DeclarationsAt text arguments state strings final ∧
      BooleanDeclarationsAt text arguments state booleans checks final := by
  induction trace with
  | done positive stop => exact ⟨.done positive stop, .done positive stop⟩
  | string positive more noCallable noSubtype noScalar noArray noBoolean first _ _ ih =>
      exact ⟨.next positive more noCallable noSubtype noScalar noArray noBoolean first ih.1,
        .string positive more noCallable noSubtype noScalar noArray noBoolean first ih.2⟩
  | scalar positive more noCallable noSubtype first _ ih =>
      exact ⟨.scalar positive more noCallable noSubtype first ih.1, .scalar positive more noCallable noSubtype first ih.2⟩
  | array positive more noCallable noSubtype noScalar first _ ih =>
      exact ⟨.array positive more noCallable noSubtype noScalar first ih.1,
        .array positive more noCallable noSubtype noScalar first ih.2⟩
  | booleanArray positive more noCallable noSubtype noScalar first raw _ _ ih =>
      exact ⟨.booleanArray positive more noCallable noSubtype noScalar first ih.1,
        .booleanArray positive more noCallable noSubtype noScalar first raw ih.2⟩
  | subtype positive more noCallable first _ ih =>
      exact ⟨.subtype positive more noCallable first ih.1, .subtype positive more noCallable first ih.2⟩
  | boolean positive more noCallable noSubtype noScalar noArray first raw _ _ ih =>
      exact ⟨.boolean positive more noCallable noSubtype noScalar noArray first ih.1,
        .boolean positive more noCallable noSubtype noScalar noArray first raw ih.2⟩

  | callable positive more accepted _ ih =>
      exact ⟨.callable positive more accepted ih.1, .callable positive more accepted ih.2⟩

/-- The universal String-schema inventory parameter is an induction device:
declaration uniqueness makes all its source witnesses identical. It is
instantiated from `decodePrefix` and `Program.checks`, never exposed as a native
helper or admitted-program premise. -/
theorem boolean_region_bounds_trace {text input : Source} {arguments state final booleans checks inputValid values program}
    (textValid : Compose.Expressions.ValidText text) (inputBound : input.length ≤ maxSourceLength)
    (printable : Bindings.Printable input) (valid : program.Valid)
    (metadata : NamesBoundsValid state.names) (count : state.names.length ≤ maxBindings)
    (stringsFit : Fits state.names.shape input values)
    (stateValid : Compose.Expressions.ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (allowed : (booleanDeclarationFacts state).path.Allows inputValid input.length false)
    (trace : BooleanDeclarationsAt text arguments state booleans checks final)
    (rangeInventory : ∀ declarations, DeclarationsAt text arguments state declarations final →
      ∀ schema ∈ declarationRangeObligations state.names.shape final.names.shape declarations,
        Check.declaration (.range schema) ∈ program.checks)
    (booleanInventory : ∀ check ∈ checks, check ∈ program.booleanInitializerChecks) :
    ∃ declarations, DeclarationsAt text arguments state declarations final ∧
      RawHeaderBoundsTrace text arguments program input inputValid state values declarations booleans checks final := by
  induction trace generalizing values with
  | done positive stop => exact ⟨[], .done positive stop, .done positive stop⟩
  | @string state middle final declaration booleans checks positive more noCallable noSubtype noScalar noArray noBoolean first tail ih =>
      have nextMetadata := declaration_bounds textValid.2 inputBound count metadata stringsFit static first
      have nextCount := declaration_count_bound count first
      obtain ⟨bound, declarationValid, shape⟩ := declaration_shape metadata.normal static first
      have nextStrings := Bindings.declaration_preserves stringsFit printable declarationValid
      rw [← shape] at nextStrings
      have fields := declaration_context_fields first
      have nextStatic := fields.1.symm ▸ static
      have nextReady := fields.1.symm ▸ ready
      have nextState := Compose.Expressions.model_object_reading_valid textValid stateValid first
      have dynamic := fields.2.2.2.2.2.2.1
      have nextAllowed : (booleanDeclarationFacts middle).path.Allows inputValid input.length false := by
        simpa only [booleanDeclarationFacts, ActiveFlow.initial, dynamic] using allowed
      obtain ⟨tailStrings, tailSource⟩ := boolean_declarations_reading tail
      have fullSource := DeclarationsAt.next positive more noCallable noSubtype noScalar noArray noBoolean first tailSource
      have present := rangeInventory (declaration :: tailStrings) fullSource
        (expressionSchema state.names.shape maxSourceLength declaration.initializer)
        (by simp [declarationRangeObligations])
      have localBounds : RawStringInitializerBounds text program state middle declaration input values ∨
          RawCharacterInitializerBounds text program state middle declaration input values := by
        cases first with
        | string _ source => exact Or.inl (raw_string_initializer_bounds valid inputBound count metadata stringsFit static present source)
        | character source => exact Or.inr (raw_character_initializer_bounds valid inputBound count metadata stringsFit static present source)
      have nextInventory : ∀ declarations, DeclarationsAt text arguments middle declarations final →
          ∀ schema ∈ declarationRangeObligations middle.names.shape final.names.shape declarations,
            Check.declaration (.range schema) ∈ program.checks := by
        intro declarations source schema member
        apply rangeInventory (declaration :: declarations)
          (.next positive more noCallable noSubtype noScalar noArray noBoolean first source) schema
        rw [declaration_range_inventory_step metadata.normal static first source]
        exact List.mem_cons_of_mem _ member
      obtain ⟨declarations, source, bounds⟩ := ih nextMetadata nextCount nextStrings nextState
        nextReady nextStatic nextAllowed nextInventory booleanInventory
      exact ⟨declaration :: declarations,
        .next positive more noCallable noSubtype noScalar noArray noBoolean first source,
        .string positive more noCallable noSubtype noScalar noArray noBoolean first localBounds bounds⟩
  | @scalar state middle final declaration booleans checks positive more noCallable noSubtype first tail ih =>
      have names : middle.names = state.names := by cases first; rfl
      have dynamic : middle.dynamicFirst = state.dynamicFirst := by cases first; rfl
      have nextState := Compose.Expressions.model_scalar_reading_valid stateValid first
      have nextReady := scalar_declaration_header_ready ready first
      have nextStatic := scalar_declaration_static static first
      have nextAllowed : (booleanDeclarationFacts middle).path.Allows inputValid input.length false := by
        simpa only [booleanDeclarationFacts, ActiveFlow.initial, dynamic] using allowed
      have nextInventory : ∀ declarations, DeclarationsAt text arguments middle declarations final →
          ∀ schema ∈ declarationRangeObligations middle.names.shape final.names.shape declarations,
            Check.declaration (.range schema) ∈ program.checks := by
        intro declarations source schema member
        exact rangeInventory declarations (.scalar positive more noCallable noSubtype first source) schema (names ▸ member)
      obtain ⟨declarations, source, bounds⟩ := ih (names.symm ▸ metadata) (names.symm ▸ count)
        (names.symm ▸ stringsFit) nextState nextReady nextStatic nextAllowed nextInventory booleanInventory
      exact ⟨declarations, .scalar positive more noCallable noSubtype first source,
        .scalar positive more noCallable noSubtype first bounds⟩
  | @array state middle final declaration booleans checks positive more noCallable noSubtype noScalar first tail ih =>
      have names := (array_declaration_preserves first).1
      have scalars := (array_declaration_preserves first).2
      have dynamic := (array_declaration_fields first).2.2.1
      have nextAllowed : (booleanDeclarationFacts middle).path.Allows inputValid input.length false := by
        simpa only [booleanDeclarationFacts, ActiveFlow.initial, dynamic] using allowed
      have nextInventory : ∀ declarations, DeclarationsAt text arguments middle declarations final →
          ∀ schema ∈ declarationRangeObligations middle.names.shape final.names.shape declarations,
            Check.declaration (.range schema) ∈ program.checks := by
        intro declarations source schema member
        exact rangeInventory declarations (.array positive more noCallable noSubtype noScalar first source) schema (names ▸ member)
      obtain ⟨declarations, source, bounds⟩ := ih (names.symm ▸ metadata) (names.symm ▸ count)
        (names.symm ▸ stringsFit) (Compose.Expressions.model_array_reading_valid stateValid first)
        (scalars.symm ▸ ready) (scalars.symm ▸ static) nextAllowed nextInventory booleanInventory
      exact ⟨declarations, .array positive more noCallable noSubtype noScalar first source,
        .array positive more noCallable noSubtype noScalar first bounds⟩
  | @booleanArray state middle final declaration booleans firstChecks checks positive more noCallable noSubtype noScalar first raw tail ih =>
      have localBounds := raw_boolean_array_initializer_bounds valid count metadata stringsFit stateValid ready static allowed
        (fun check member => booleanInventory check (List.mem_append_left _ member)) raw
      have names := (boolean_array_declaration_preserves first).1
      have scalars := (boolean_array_declaration_preserves first).2.1
      have dynamic := congrArg ParserState.dynamicFirst (boolean_array_declaration_fields first)
      have nextAllowed : (booleanDeclarationFacts middle).path.Allows inputValid input.length false := by
        simpa only [booleanDeclarationFacts, ActiveFlow.initial, dynamic] using allowed
      have nextInventory : ∀ declarations, DeclarationsAt text arguments middle declarations final →
          ∀ schema ∈ declarationRangeObligations middle.names.shape final.names.shape declarations,
            Check.declaration (.range schema) ∈ program.checks := by
        intro declarations source schema member
        exact rangeInventory declarations (.booleanArray positive more noCallable noSubtype noScalar first source) schema (names ▸ member)
      obtain ⟨declarations, source, bounds⟩ := ih (names.symm ▸ metadata) (names.symm ▸ count)
        (names.symm ▸ stringsFit) (Compose.Expressions.model_boolean_array_reading_valid stateValid first)
        (scalars.symm ▸ ready) (scalars.symm ▸ static) nextAllowed nextInventory
        (fun check member => booleanInventory check (List.mem_append_right _ member))
      exact ⟨declarations, .booleanArray positive more noCallable noSubtype noScalar first source,
        .booleanArray positive more noCallable noSubtype noScalar first raw localBounds bounds⟩
  | @subtype state middle final booleans checks positive more noCallable first tail ih =>
      have names : middle.names = state.names := by cases first; rfl
      have scalars : middle.scalarNames = state.scalarNames := by cases first; rfl
      have dynamic : middle.dynamicFirst = state.dynamicFirst := by cases first; rfl
      have nextAllowed : (booleanDeclarationFacts middle).path.Allows inputValid input.length false := by
        simpa only [booleanDeclarationFacts, ActiveFlow.initial, dynamic] using allowed
      have nextInventory : ∀ declarations, DeclarationsAt text arguments middle declarations final →
          ∀ schema ∈ declarationRangeObligations middle.names.shape final.names.shape declarations,
            Check.declaration (.range schema) ∈ program.checks := by
        intro declarations source schema member
        exact rangeInventory declarations (.subtype positive more noCallable first source) schema (names ▸ member)
      obtain ⟨declarations, source, bounds⟩ := ih (names.symm ▸ metadata) (names.symm ▸ count)
        (names.symm ▸ stringsFit) (Compose.Expressions.model_subtype_reading_valid stateValid first)
        (scalars.symm ▸ ready) (scalars.symm ▸ static) nextAllowed nextInventory booleanInventory
      exact ⟨declarations, .subtype positive more noCallable first source, .subtype positive more noCallable first bounds⟩
  | @boolean state middle final declaration booleans firstChecks checks positive more noCallable noSubtype noScalar noArray first raw tail ih =>
      have localBounds := raw_boolean_initializer_bounds valid count metadata stringsFit stateValid ready static allowed
        (fun check member => booleanInventory check (List.mem_append_left _ member)) raw
      have names := (boolean_declaration_preserves first).1
      have scalars := (boolean_declaration_preserves first).2.1
      have dynamic : middle.dynamicFirst = state.dynamicFirst := by cases first; rfl
      have nextAllowed : (booleanDeclarationFacts middle).path.Allows inputValid input.length false := by
        simpa only [booleanDeclarationFacts, ActiveFlow.initial, dynamic] using allowed
      have nextInventory : ∀ declarations, DeclarationsAt text arguments middle declarations final →
          ∀ schema ∈ declarationRangeObligations middle.names.shape final.names.shape declarations,
            Check.declaration (.range schema) ∈ program.checks := by
        intro declarations source schema member
        exact rangeInventory declarations (.boolean positive more noCallable noSubtype noScalar noArray first source) schema (names ▸ member)
      obtain ⟨declarations, source, bounds⟩ := ih (names.symm ▸ metadata) (names.symm ▸ count)
        (names.symm ▸ stringsFit) (Compose.Expressions.model_boolean_reading_valid stateValid first)
        (scalars.symm ▸ ready) (scalars.symm ▸ static) nextAllowed nextInventory
        (fun check member => booleanInventory check (List.mem_append_right _ member))
      exact ⟨declarations, .boolean positive more noCallable noSubtype noScalar noArray first source,
        .boolean positive more noCallable noSubtype noScalar noArray first raw localBounds bounds⟩

  | @callable state final booleans checks positive more accepted tail ih =>
      have kept := callableDeclarationAt_preserves_outer text state arguments accepted
      have nextAllowed : (booleanDeclarationFacts (callableDeclarationAt text state arguments)).path.Allows
          inputValid input.length false := by
        simpa only [booleanDeclarationFacts, ActiveFlow.initial, kept.dynamicFirst] using allowed
      have nextInventory : ∀ declarations,
          DeclarationsAt text arguments (callableDeclarationAt text state arguments) declarations final →
          ∀ schema ∈ declarationRangeObligations (callableDeclarationAt text state arguments).names.shape
            final.names.shape declarations, Check.declaration (.range schema) ∈ program.checks := by
        intro declarations source schema member
        exact rangeInventory declarations (.callable positive more accepted source) schema (kept.names ▸ member)
      obtain ⟨declarations, source, bounds⟩ := ih (kept.names.symm ▸ metadata) (kept.names.symm ▸ count)
        (kept.names.symm ▸ stringsFit) (Compose.Expressions.model_callable_declaration_valid textValid stateValid)
        (kept.scalarNames.symm ▸ ready) (kept.scalarNames.symm ▸ static) nextAllowed nextInventory booleanInventory
      exact ⟨declarations, .callable positive more accepted source, .callable positive more accepted bounds⟩

def headerLeadDeclarations (form : Form) : List Declaration :=
  if form.hasArguments then [argumentDeclaration] else []

def headerLeadShape (form : Form) : Shape :=
  if form.hasArguments then argumentShape else emptyShape

private theorem tokens_split_exact {text form first rest state events final}
    (parsed : Sequence.TokensAt text form (first ++ rest) state events final) :
    ∃ middle leading following, events = leading ++ following ∧
      Sequence.TokensAt text form first state leading middle ∧
      Sequence.TokensAt text form rest middle following final := by
  induction first generalizing state events with
  | nil => exact ⟨state, [], events, rfl, .done (Sequence.tokens_positive parsed).1, parsed⟩
  | cons token tokens ih =>
      cases parsed with
      | next head tail =>
          obtain ⟨middle, leading, following, equal, before, after⟩ := ih tail
          exact ⟨middle, _, following, by simp only [equal, List.append_assoc], .next head before, after⟩

private theorem decoded_region_fields {source : Source} {form : Form} {before after : ParserState}
    {leading strings items scalars constants checks arrays booleans booleanChecks functions procedures program}
    (lead : Sequence.TokensAt source form.helper (booleanHeaderLead form) initialState leading before)
    (decoded : decodePrefix form (leading ++ [.declarations strings after.names]) items
      scalars constants checks arrays booleans booleanChecks functions procedures = some program) :
    program.declarations = headerLeadDeclarations form ++ strings ∧
      program.names = after.names ∧ program.hasArguments = form.hasArguments ∧
      before.names.shape = headerLeadShape form := by
  have kinds := Sequence.tokens_kinds lead
  have shapes := congrArg Prod.fst (Sequence.tokens_context lead)
  cases form with
  | direct =>
      have kindsEmpty : leading.map Event.kind = [] := by
        simpa [booleanHeaderLead, Form.hasArguments, ShellToken.word, ShellToken.symbol,
          ShellToken.eventKind, List.filterMap_cons, List.filterMap_nil, Option.toList] using kinds
      have empty : leading = [] := List.map_eq_nil_iff.mp kindsEmpty
      subst leading
      simp only [List.nil_append, decodePrefix] at decoded
      cases decoded
      refine ⟨rfl, rfl, rfl, ?_⟩
      simpa only [Sequence.eventsContext, List.foldl_nil, initialState, empty_names_shape,
        headerLeadShape, Form.hasArguments, Bool.false_eq_true, ↓reduceIte] using shapes.symm
  | argument =>
      have shape : leading.map Event.kind = [.argument] := by
        simpa [booleanHeaderLead, Form.hasArguments, ShellToken.word, ShellToken.symbol,
          ShellToken.eventKind, List.filterMap_cons, List.filterMap_nil, Option.toList] using kinds
      obtain ⟨fallback, rest, rfl, empty⟩ := (argument_event_shape _ _).mp shape
      have restEmpty := List.map_eq_nil_iff.mp empty
      subst rest
      simp only [List.singleton_append, decodePrefix] at decoded
      cases decoded
      refine ⟨rfl, rfl, rfl, ?_⟩
      simpa only [Sequence.eventsContext, Sequence.eventContext, List.foldl_cons, List.foldl_nil,
        headerLeadShape, Form.hasArguments, Bool.false_eq_true, ↓reduceIte] using shapes.symm

structure HeaderRegionFacts (source : Source) (program : Program) (form : Form)
    (before after : ParserState) (strings : List Declaration) : Prop where
  selected : selectedForm source = some form
  leading : ∃ events, Sequence.TokensAt source form.helper (booleanHeaderLead form) initialState events before
  declarations : DeclarationsAt source form.helper.hasArguments before strings after
  booleans : BooleanDeclarationsAt source form.helper.hasArguments before
    program.booleanDeclarations program.booleanInitializerChecks after
  ending : ∃ event, StepAt source form.helper (.word "begin") after (prefixScan source form).state event
  declarationList : program.declarations = headerLeadDeclarations form ++ strings
  names : program.names = after.names
  argumentFlag : program.hasArguments = form.hasArguments
  entryShape : before.names.shape = headerLeadShape form
  entryContext : program.initialContext = (booleanDeclarationFacts before).path

private theorem header_begin_dynamic {source form state next event}
    (parsed : StepAt source form (.word "begin") state next event) :
    next.dynamicFirst = state.dynamicFirst := by
  rw [← parsed.scanned]
  simp only [step, parsed.positive, ↓reduceIte, ShellToken.word]

theorem source_header_region {source program} (meaning : SourceMeaning source program) :
    ∃ form before after strings, HeaderRegionFacts source program form before after strings := by
  obtain ⟨form, events, items, scalars, checks, booleans, booleanChecks, _, selected,
    reading, _, _, booleanTrace, functions, procedures, _, decoded⟩ := meaning
  have header := reading.header
  rw [boolean_header_split] at header
  obtain ⟨before, leading, following, eventEquality, leadingRead, suffix⟩ := tokens_split_exact header
  cases suffix with
  | next declaration tail =>
      cases tail with
      | next ending tail =>
          cases tail
          obtain ⟨strings, regionSource, declarationEvent⟩ := declaration.payload
          have noEndEvent := ending.payload
          change _ = none at noEndEvent
          rw [declarationEvent, noEndEvent] at eventEquality
          simp only [Option.toList_some, Option.toList_none,
            List.append_nil] at eventEquality
          rw [eventEquality] at decoded
          have fields := decoded_region_fields leadingRead decoded
          obtain ⟨otherBefore, otherAfter, otherLeading, otherEvent, otherLead, booleanRegion, otherEnd⟩ := booleanTrace
          have sameBefore := (Sequence.tokens_unique leadingRead otherLead).2
          subst otherBefore
          obtain ⟨otherStrings, otherSource⟩ := boolean_declarations_reading booleanRegion
          have sameAfter := (declarations_unique regionSource otherSource).2
          subst otherAfter
          have booleanFields := decoded_boolean_state decoded
          have booleans := booleanRegion
          rw [← booleanFields.1, ← booleanFields.2] at booleans
          have context : program.initialContext = (booleanDeclarationFacts before).path := by
            have flag := prefix_arguments reading.header
            change decide ((prefixScan source form).state.dynamicFirst ≠ 0) = form.hasArguments at flag
            have endDynamic := header_begin_dynamic ending
            rw [endDynamic, (declarations_fields regionSource).2.2.1] at flag
            simp only [Program.initialContext, fields.2.2.1, booleanDeclarationFacts,
              ActiveFlow.initial]
            rw [← flag]
            simp only [decide_eq_true_eq]
          exact ⟨form, before, _, strings, selected, ⟨leading, leadingRead⟩, regionSource, booleans,
            ⟨_, ending⟩, fields.1, fields.2.1, fields.2.2.1, fields.2.2.2, context⟩

private theorem bounds_tokens_outer_ready {source form tokens state final events}
    (textValid : Compose.Expressions.ValidText source)
    (parsed : Sequence.TokensAt source form tokens state events final)
    (valid : OuterReadiness.ValidState source state) : OuterReadiness.ValidState source final := by
  induction parsed with
  | done => exact valid
  | next first _ ih =>
      apply ih
      rw [← first.scanned]
      exact OuterReadiness.step_valid source textValid form _ _ valid

/-- The optional Arguments initializer is also represented by its own present
range schema. Its source call is retained in HeaderRegionFacts.leading. -/
def HeaderLeadBoundsSafe (program : Program) (form : Form)
    (arguments : Arguments.Runtime.Arguments) : Prop :=
  form.hasArguments = true →
    ∃ certificate : StringBoundsObligation,
      certificate = declarationBoundsCertificate [] argumentDeclaration ∧
      Check.declaration (.range (expressionSchema emptyShape maxSourceLength argumentDeclaration.initializer))
        ∈ program.checks ∧
      (Check.stringBounds certificate).Refines
        (.declaration (.range (expressionSchema emptyShape maxSourceLength argumentDeclaration.initializer))) ∧
      certificate.Valid ∧
      certificate.length.Covers (program.inputValid arguments) (program.input arguments).length false
        (program.input arguments).length ∧
      argumentDeclaration.initializer.ObjectBoundsSafe [] emptyValues (program.input arguments) Integer.emptyStore

theorem header_lead_bounds {source program form before after strings}
    (valid : program.Valid) (region : HeaderRegionFacts source program form before after strings)
    (arguments : Arguments.Runtime.Arguments) : HeaderLeadBoundsSafe program form arguments := by
  intro hasArguments
  have present : Check.declaration (.range
      (expressionSchema emptyShape maxSourceLength argumentDeclaration.initializer)) ∈ program.checks := by
    apply declaration_range_check_present
    rw [region.declarationList]
    simp [headerLeadDeclarations, hasArguments, declarationRangeObligations]
  let certificate := declarationBoundsCertificate [] argumentDeclaration
  have count : ([] : Compose.BindingEnvironment).length ≤ maxBindings := Nat.zero_le _
  have refined : (Check.stringBounds certificate).Refines
      (.declaration (.range (expressionSchema emptyShape maxSourceLength argumentDeclaration.initializer))) := by
    simpa only [empty_names_shape] using declarationBoundsCertificate_refines count argumentDeclaration
  have checked : certificate.Valid := Check.fragment_valid
    (Check.fragment_of_refines refined (Program.checks_fragment valid _ present))
  have covered : certificate.length.Covers (program.inputValid arguments) (program.input arguments).length false
      (program.input arguments).length := by
    refine ⟨(program.input arguments).length, ?_, ?_⟩
    · simpa [certificate, declarationBoundsCertificate, expressionSchema, argumentDeclaration,
        Expression.dynamicCount, Operand.dynamicCount, Operand.bound, Value.infer,
        Bound.dynamicPart] using (program.input_domain arguments).1
    · simp [expressionSchema, argumentDeclaration,
        Expression.staticLength, Operand.staticLength, Operand.bound, Value.infer, Bound.staticPart]
  refine ⟨certificate, rfl, present, refined, checked, covered, ?_⟩
  apply StringBoundsObligation.expression_safe checked (Nat.le_refl _)
    namesBoundsValid_empty (by simpa only [empty_names_shape] using empty_fits (program.input arguments))
  · simp [argumentDeclaration, Expression.BoundsOrigin, Operand.BoundsOrigin]
  · constructor
    · intro atom member
      have same := List.mem_singleton.mp member
      subst atom
      trivial
    · simpa [argumentDeclaration, Expression.evaluate, Value.evaluate] using (program.input_domain arguments).1
  · simpa only [argumentDeclaration, Expression.evaluate, Value.evaluate, List.append_nil] using covered

/-- No additional source/history premise appears in the final claim. The
trace starts in the exact declaration-time byte store produced by the decoded
optional argument declaration and covers the full mixed region. -/
def RawInitializersBoundsSafe (source : Source) (program : Program)
    (arguments : Arguments.Runtime.Arguments) : Prop :=
  ∃ form before after strings, HeaderRegionFacts source program form before after strings ∧
    HeaderLeadBoundsSafe program form arguments ∧
    RawHeaderBoundsTrace source form.helper.hasArguments program (program.input arguments)
      (program.inputValid arguments) before
      (executeDeclarations (program.input arguments) (headerLeadDeclarations form) emptyValues)
      strings program.booleanDeclarations program.booleanInitializerChecks after

theorem source_raw_initializers_bounds {source program} (meaning : SourceMeaning source program)
    (arguments : Arguments.Runtime.Arguments) : RawInitializersBoundsSafe source program arguments := by
  have valid := meaning_valid meaning
  have domain : SourceDomain source := by
    obtain ⟨_, _, _, _, _, _, _, domain, _⟩ := meaning
    exact domain
  have textValid : Compose.Expressions.ValidText source := ⟨domain.1, domain.2.1⟩
  obtain ⟨form, before, after, strings, region⟩ := source_header_region meaning
  obtain ⟨events, leading⟩ := region.leading
  have ready := bounds_tokens_outer_ready textValid leading (OuterReadiness.initial_valid source)
  have static := (Sequence.tokens_valid domain.2.1 leading Compose.initial_valid).1.2.2.2
  have inputDomain := program.input_domain arguments
  have count : before.names.length ≤ maxBindings := ready.base.2.1.1
  have entryFits : Fits before.names.shape (program.input arguments)
      (executeDeclarations (program.input arguments) (headerLeadDeclarations form) emptyValues) := by
    rw [region.entryShape]
    cases form with
    | direct => exact empty_fits _
    | argument =>
        change Fits argumentShape (program.input arguments)
          (argumentDeclaration.execute emptyValues (program.input arguments))
        simpa only [argumentShape, argumentDeclaration, Declaration.extend] using
          Bindings.declaration_preserves (empty_fits (program.input arguments)) inputDomain.2 argument_declaration_valid

  have inventory : ∀ declarations, DeclarationsAt source form.helper.hasArguments before declarations after →
      ∀ schema ∈ declarationRangeObligations before.names.shape after.names.shape declarations,
        Check.declaration (.range schema) ∈ program.checks := by
    intro declarations source schema member
    have same := (declarations_unique region.declarations source).1
    subst declarations
    apply declaration_range_check_present
    rw [region.declarationList, region.names]
    cases form with
    | direct => simpa only [region.entryShape, headerLeadDeclarations, headerLeadShape, Form.hasArguments,
        Bool.false_eq_true, ↓reduceIte, List.nil_append] using member
    | argument =>
        have fullShape := declarations_shape ready.bounds.normal static region.declarations
        have target : after.names.shape 1 = some ⟨.argument, false⟩ := by
          apply declarations_extend fullShape
          rw [region.entryShape]
          simp [headerLeadShape, Form.hasArguments, argumentShape, put_same]
        have entryShape : before.names.shape = argumentShape := region.entryShape
        simp only [headerLeadDeclarations, Form.hasArguments, ↓reduceIte, List.singleton_append,
          declarationRangeObligations, declarationBound, argumentDeclaration, target,
          Option.map_some, Option.getD_some, Declaration.extend]
        exact List.mem_cons_of_mem _ (by simpa only [entryShape, argumentShape] using member)
  have allowed : (booleanDeclarationFacts before).path.Allows
      (program.inputValid arguments) (program.input arguments).length false := by
    rw [← region.entryContext]
    exact program.initial_allowed arguments
  obtain ⟨actual, actualSource, trace⟩ := boolean_region_bounds_trace textValid inputDomain.1 inputDomain.2
    valid ready.bounds count entryFits ready.base ready.ready static allowed region.booleans inventory
    (fun _ present => present)
  have same := (declarations_unique region.declarations actualSource).1
  subst actual
  exact ⟨form, before, after, strings, region, header_lead_bounds valid region arguments, trace⟩

theorem source_string_bounds_facts {source program} (meaning : SourceMeaning source program) :
    HeaderBoundsFacts program ∧ ∀ arguments, RawInitializersBoundsSafe source program arguments :=
  ⟨source_header_bounds_facts meaning, source_raw_initializers_bounds meaning⟩

end Silver.Predicate
