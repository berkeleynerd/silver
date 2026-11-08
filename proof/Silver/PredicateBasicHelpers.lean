module

public import Silver.PredicateBasicSizing
public import Silver.PredicateFlowReaderLibraries
public import Silver.PredicateBooleanBodyHelpers
public import Silver.PredicateScalarBodyHelpers
public import Silver.PredicateArrayBodySource

@[expose] public section
namespace Silver.Predicate.BasicNative
open Compose Bindings

/-- Exactly the literal token arguments occurring in the typed Basic_Body. -/
def basicTokens : List ShellToken :=
  [.word "null", .word "silver_io", .symbol ".", .word "put_line", .symbol "(",
   .symbol ")", .word "silver_arguments", .word "reject", .symbol ":=", .symbol ";"]

def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position ∧ token ∈ basicTokens

def ExpressionDomain (text : Source) (position : Nat) (names : Compose.BindingEnvironment) (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata) (booleans : BooleanBindings.Environment) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position ∧ Expressions.NativeNames text names ∧
    ScalarExpression.ValidEnvironment text scalarNames ∧ ArrayBindings.ValidMetadata text arrays ∧
    BooleanBindings.ValidEnvironment text booleans

abbrev TargetDomain := ScalarBodyNative.TargetDomain
abbrev ScalarTargetDomain := TargetDomain
abbrev ScalarAssignmentDomain := ScalarBodyNative.AssignmentDomain

def BodyTokenDomain (text : Source) (context : Native.Context) (scan : BodyScan) (token : ShellToken) : Prop :=
  ScalarAssignmentDomain text context scan ∧ token ∈ basicTokens

def FlowDomain (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow) : Prop :=
  FlowReaders.Legal {text,context,position,facts}

def ValueDomain (text : Source) (position : Nat) (names : Compose.BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position ∧
    Expressions.ValidNames text names ∧ NamesBoundsValid names ∧
    ScalarExpression.ValidEnvironment text scalarNames ∧ ArrayBindings.ValidMetadata text arrays

structure HelperMeaning (primitive : Primitives) : Prop where
  callAfter : ∀ text names position operation scalarNames arrays hidden booleans, ExpressionDomain text position names scalarNames arrays booleans →
    primitive.callAfter text names position operation scalarNames arrays hidden booleans = Compose.callAfter text names position operation scalarNames arrays hidden booleans
  associationAfter : ∀ text position formal, Expressions.ValidText text → Expressions.ValidCursor text position →
    primitive.associationAfter text position formal = Names.associationAfter text position formal
  token : ∀ text position token, TokenDomain text position token →
    primitive.token text position token = tokenAfter text position token
  expression : ∀ text context position facts, FlowDomain text context position facts →
    primitive.expression text context position facts = readStringInFlow text context.model position facts
  readingNames : ∀ text context facts, FlowDomain text context 0 facts →
    primitive.readingNames context facts = context.model.readingNames facts
  character : ∀ text position names scalarNames arrays, ValueDomain text position names scalarNames arrays →
    primitive.character text position names scalarNames arrays =
      characterAt text position names scalarNames arrays
  indexed : ∀ text position names scalarNames arrays initials elaborating characterElement,
    ValueDomain text position names scalarNames arrays → ArrayBindings.ValidInitials initials →
    primitive.indexed text position names scalarNames arrays initials elaborating characterElement =
      indexedAt text position names scalarNames arrays initials elaborating characterElement
  target : ∀ text context position, TargetDomain text context position →
    primitive.target text context position = ScalarBodyNative.stringTargetEval ScalarBodyNative.modelImports text context position
  bodyToken : ∀ text context scan token, BodyTokenDomain text context scan token →
    primitive.bodyToken text context scan token = Predicate.bodyToken text scan token
  invalid : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → primitive.invalid scan = invalidBody scan
  scalarTarget : ∀ text context position, ScalarTargetDomain text context position →
    primitive.scalarTarget text context position = Predicate.scalarTarget text context.model position
  scalarAssignment : ∀ text context scan, ScalarAssignmentDomain text context scan →
    primitive.scalarAssignment text context scan = scalarAssignmentBody text context.model scan
  callAssignment : ∀ text context scan catalog, ScalarAssignmentDomain text context scan →
    FunctionBindings.ValidMetadata text catalog →
    primitive.callAssignment text context scan catalog = callAssignmentBody text context.model scan catalog
  booleanTarget : ∀ text context position, TargetDomain text context position →
    primitive.booleanTarget text context position = Predicate.booleanTarget text context.model position
  booleanAssignment : ∀ text context scan, ScalarAssignmentDomain text context scan →
    primitive.booleanAssignment text context scan = booleanAssignmentBody text context.model scan
  arrayTarget : ∀ text context position, TargetDomain text context position →
    primitive.arrayTarget text context position = Predicate.arrayTarget text context.model position
  arrayAssignment : ∀ text context scan, ScalarAssignmentDomain text context scan →
    primitive.arrayAssignment text context scan = arrayAssignmentBody text context.model scan
  booleanArrayAssignment : ∀ text context scan, ScalarAssignmentDomain text context scan →
    primitive.booleanArrayAssignment text context scan = booleanArrayAssignmentBody text context.model scan
  fits : ∀ facts summary, primitive.fits facts summary = fitsLengthSummary facts summary
  sameLength : ∀ facts left right, primitive.sameLength facts left right = equalLengthIntervals facts left right
  reject : ∀ facts, primitive.reject facts = facts.reject

/-- Outside verified native call domains this formal extension uses the model.
Its legal values and every complete flow record remain unchanged. -/
noncomputable def totalize (primitive : Primitives) : Primitives := by
  classical
  exact {
    callAfter := fun text names position operation scalarNames arrays hidden booleans => if ExpressionDomain text position names scalarNames arrays booleans then
      primitive.callAfter text names position operation scalarNames arrays hidden booleans else Compose.callAfter text names position operation scalarNames arrays hidden booleans
    associationAfter := fun text position formal => if Expressions.ValidText text ∧ Expressions.ValidCursor text position then
      primitive.associationAfter text position formal else Names.associationAfter text position formal
    token := fun text position token => if TokenDomain text position token then
      primitive.token text position token else tokenAfter text position token
    expression := fun text context position facts => if FlowDomain text context position facts then
      primitive.expression text context position facts else readStringInFlow text context.model position facts
    readingNames := fun context facts => if ∃ text, FlowDomain text context 0 facts then
      primitive.readingNames context facts else context.model.readingNames facts
    character := fun text position names scalarNames arrays => if ValueDomain text position names scalarNames arrays then
      primitive.character text position names scalarNames arrays else characterAt text position names scalarNames arrays
    indexed := fun text position names scalarNames arrays initials elaborating characterElement =>
      if ValueDomain text position names scalarNames arrays ∧ ArrayBindings.ValidInitials initials then
        primitive.indexed text position names scalarNames arrays initials elaborating characterElement
      else indexedAt text position names scalarNames arrays initials elaborating characterElement
    target := fun text context position => if TargetDomain text context position then
      primitive.target text context position else ScalarBodyNative.stringTargetEval ScalarBodyNative.modelImports text context position
    bodyToken := fun text context scan token => if BodyTokenDomain text context scan token then
      primitive.bodyToken text context scan token else Predicate.bodyToken text scan token
    invalid := fun scan => if scan.count ≤ ScalarExpression.maxBindings then primitive.invalid scan else invalidBody scan
    scalarTarget := fun text context position => if ScalarTargetDomain text context position then
      primitive.scalarTarget text context position else Predicate.scalarTarget text context.model position
    scalarAssignment := fun text context scan => if ScalarAssignmentDomain text context scan then
      primitive.scalarAssignment text context scan else scalarAssignmentBody text context.model scan
    callAssignment := fun text context scan catalog =>
      if ScalarAssignmentDomain text context scan ∧ FunctionBindings.ValidMetadata text catalog then
        primitive.callAssignment text context scan catalog else callAssignmentBody text context.model scan catalog
    booleanTarget := fun text context position => if TargetDomain text context position then
      primitive.booleanTarget text context position else Predicate.booleanTarget text context.model position
    booleanAssignment := fun text context scan => if ScalarAssignmentDomain text context scan then
      primitive.booleanAssignment text context scan else booleanAssignmentBody text context.model scan
    arrayTarget := fun text context position => if TargetDomain text context position then
      primitive.arrayTarget text context position else Predicate.arrayTarget text context.model position
    arrayAssignment := fun text context scan => if ScalarAssignmentDomain text context scan then
      primitive.arrayAssignment text context scan else arrayAssignmentBody text context.model scan
    booleanArrayAssignment := fun text context scan => if ScalarAssignmentDomain text context scan then
      primitive.booleanArrayAssignment text context scan else booleanArrayAssignmentBody text context.model scan
    fits := primitive.fits
    sameLength := primitive.sameLength
    reject := primitive.reject }

theorem totalize_equations {primitive : Primitives} (meaning : HelperMeaning primitive) :
    PrimitiveEquations (totalize primitive) where
  callAfter := by
    funext text names position operation scalarNames arrays hidden booleans
    dsimp only [totalize]
    split
    · exact meaning.callAfter text names position operation scalarNames arrays hidden booleans ‹_›
    · rfl
  associationAfter := by
    funext text position formal
    dsimp only [totalize]
    split
    · exact meaning.associationAfter text position formal (And.left ‹_›) (And.right ‹_›)
    · rfl
  token := by
    funext text position token
    dsimp only [totalize]
    split
    · exact meaning.token text position token ‹_›
    · rfl
  expression := by
    funext text context position facts
    dsimp only [totalize]
    split
    · exact meaning.expression text context position facts ‹_›
    · rfl
  readingNames := by
    funext context facts
    dsimp only [totalize]
    split
    · obtain ⟨text, valid⟩ := ‹∃ text, FlowDomain text context 0 facts›
      exact meaning.readingNames text context facts valid
    · rfl
  character := by
    funext text position names scalarNames arrays
    dsimp only [totalize]
    split
    · exact meaning.character text position names scalarNames arrays ‹_›
    · rfl
  indexed := by
    funext text position names scalarNames arrays initials elaborating characterElement
    dsimp only [totalize]
    split
    · exact meaning.indexed text position names scalarNames arrays initials elaborating characterElement
        (And.left ‹_›) (And.right ‹_›)
    · rfl
  target := by
    funext text context position
    dsimp only [totalize]
    split
    · exact meaning.target text context position ‹_›
    · rfl
  bodyToken := by
    funext text context scan token
    dsimp only [totalize]
    split
    · exact meaning.bodyToken text context scan token ‹_›
    · rfl
  invalid := by
    funext scan
    dsimp only [totalize]
    split
    · exact meaning.invalid scan ‹_›
    · rfl
  scalarTarget := by
    funext text context position
    dsimp only [totalize]
    split
    · exact meaning.scalarTarget text context position ‹_›
    · rfl
  scalarAssignment := by
    funext text context scan
    dsimp only [totalize]
    split
    · exact meaning.scalarAssignment text context scan ‹_›
    · rfl
  callAssignment := by
    funext text context scan catalog
    dsimp only [totalize]
    split
    · exact meaning.callAssignment text context scan catalog (And.left ‹_›) (And.right ‹_›)
    · rfl
  booleanTarget := by
    funext text context position
    dsimp only [totalize]
    split
    · exact meaning.booleanTarget text context position ‹_›
    · rfl
  booleanAssignment := by
    funext text context scan
    dsimp only [totalize]
    split
    · exact meaning.booleanAssignment text context scan ‹_›
    · rfl
  arrayTarget := by
    funext text context position
    dsimp only [totalize]
    split
    · exact meaning.arrayTarget text context position ‹_›
    · rfl
  arrayAssignment := by
    funext text context scan
    dsimp only [totalize]
    split
    · exact meaning.arrayAssignment text context scan ‹_›
    · rfl
  booleanArrayAssignment := by
    funext text context scan
    dsimp only [totalize]
    split
    · exact meaning.booleanArrayAssignment text context scan ‹_›
    · rfl
  fits := funext fun facts => funext fun summary => meaning.fits facts summary
  sameLength := funext fun facts => funext fun left => funext fun right => meaning.sameLength facts left right
  reject := funext meaning.reject

theorem totalize_eq_model {primitive : Primitives} (meaning : HelperMeaning primitive) :
    totalize primitive = modelPrimitives := (totalize_equations meaning).eq_model

theorem basicEval_normalized {primitive : Primitives} (meaning : HelperMeaning primitive)
    (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata := {}) :
    basicEval (totalize primitive) text context scan catalog = basicBody text context.model scan catalog :=
  basicEval_of_equations (totalize_equations meaning) text context scan catalog

theorem model_helper_meaning : HelperMeaning modelPrimitives where
  callAfter _ _ _ _ _ _ _ _ _ := rfl
  associationAfter _ _ _ _ _ := rfl
  token _ _ _ _ := rfl
  expression _ _ _ _ _ := rfl
  readingNames _ _ _ _ := rfl
  character _ _ _ _ _ _ := rfl
  indexed _ _ _ _ _ _ _ _ _ _ := rfl
  target _ _ _ _ := rfl
  bodyToken _ _ _ _ _ := rfl
  invalid _ _ := rfl
  scalarTarget _ _ _ _ := rfl
  scalarAssignment _ _ _ _ := rfl
  callAssignment _ _ _ _ _ _ := rfl
  booleanTarget _ _ _ _ := rfl
  booleanAssignment _ _ _ _ := rfl
  arrayTarget _ _ _ _ := rfl
  arrayAssignment _ _ _ _ := rfl
  booleanArrayAssignment _ _ _ _ := rfl
  fits _ _ := rfl
  sameLength _ _ _ := rfl
  reject _ := rfl

theorem basicToken_valid (token : ShellToken) (valid : token ∈ basicTokens) : Expressions.ValidToken token := by
  simp only [basicTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Expressions.ValidToken, Expressions.allTokens]

theorem basicToken_model (text : Source) (position : Nat) (token : ShellToken)
    (valid : token ∈ basicTokens) :
    fixedAfter text position (Expressions.spelling token) (Expressions.isWord token) = tokenAfter text position token := by
  simp only [basicTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

def Test.tokenCalls : Test → List ShellToken
  | .present tok => [tok]
  | .orElse left right | .andThen left right => left.tokenCalls ++ right.tokenCalls
  | _ => []

def Command.tokenCalls : Command → List ShellToken
  | .update (.token tok) => [tok]
  | .sequence first second => first.tokenCalls ++ second.tokenCalls
  | .choose test yes no => test.tokenCalls ++ yes.tokenCalls ++ no.tokenCalls
  | _ => []

/-- The extra finite-token domain restriction is checked against the complete
typed body, including tokens in every unreachable or returning branch. -/
theorem basic_tokens_complete :
    ∀ token ∈ basicCommands.tokenCalls, token ∈ basicTokens := by
  have checked : basicCommands.tokenCalls.all (fun token => decide (token ∈ basicTokens)) = true := by
    decide +kernel
  intro token present
  exact of_decide_eq_true ((List.all_eq_true.mp checked) token present)


end Silver.Predicate.BasicNative
