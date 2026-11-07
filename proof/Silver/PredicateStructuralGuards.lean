module

public import Silver.PredicateScalarBodyNative
public import Silver.PredicateNativeScalarHelpers
public import Silver.PredicateAdapter

@[expose] public section

/-! Constructor-level checks for the three predicate tree languages whose
renderers emit bare logical operators. Categories follow the Ada expression
grammar: `not` takes a primary, a relation has primary operands in these
arithmetic-free languages, and a logical chain uses one operator throughout.
Same-operator Boolean nesting is admitted on either side because its denotation
and short-circuit order agree with the rendered chain. Conditional, case and
declare expressions require their explicit enclosing syntax.

These checks inspect every structural child, but do not parse identifiers,
type-name tokens or other opaque token leaves. In particular they say nothing
about operators hidden inside the fixed leaves of PredicateLoopNative or
ImageModelFinishNative. Exact source checks and the semantic interpretation
premises remain required. -/

namespace Silver.Predicate.ScalarBodyNative

/-- Ada selected/indexed prefixes are names, a narrower class than primaries.
In particular a parenthesized expression or aggregate is not a name. -/
def Expr.prefix : Expr α → Bool
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget
  | .localIndex | .scalarValue | .skip _ | .nameAfter _ | .lookup _ _
  | .stringLookup _ _ | .stringMutable _ | .assignment _ | .read _ | .binding _
  | .mutable _ | .declaredBounds _ | .valueAfter _ | .valueBounds _ | .lower _
  | .upper _ | .isEmpty _ | .invalid => true
  | .zero | .targetResult _ _ | .eqNat _ _ | .neNat _ _ | .leNat _ _
  | .ltInt _ _ | .gtInt _ _ | .not _ | .orElse _ _ | .andThen _ _ | .assigned _
  | .choose _ _ _ | .group _ | .locals _ | .letFirst _ _ | .letAfter _ _
  | .letTarget _ _ | .letIndex _ _ | .letValue _ _ | .beginValue _ => false

def Expr.primary : Expr α → Bool
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget
  | .localIndex | .zero | .scalarValue | .skip _ | .nameAfter _ | .lookup _ _
  | .stringLookup _ _ | .stringMutable _ | .targetResult _ _ | .assignment _
  | .read _ | .binding _ | .mutable _ | .declaredBounds _ | .valueAfter _
  | .valueBounds _ | .lower _ | .upper _ | .isEmpty _ | .invalid | .assigned _
  | .group _ => true
  | .eqNat _ _ | .neNat _ _ | .leNat _ _ | .ltInt _ _ | .gtInt _ _ | .not _
  | .orElse _ _ | .andThen _ _ | .choose _ _ _ | .locals _ | .letFirst _ _
  | .letAfter _ _ | .letTarget _ _ | .letIndex _ _ | .letValue _ _
  | .beginValue _ => false

def Expr.relation (value : Expr α) : Bool := value.primary || match value with
  | .eqNat _ _ | .neNat _ _ | .leNat _ _ | .ltInt _ _ | .gtInt _ _ | .not _ => true
  | _ => false

def Expr.andHead (value : Expr α) : Bool := value.relation || match value with
  | .andThen _ _ => true
  | _ => false

def Expr.orHead (value : Expr α) : Bool := value.relation || match value with
  | .orElse _ _ => true
  | _ => false

def Expr.expression (value : Expr α) : Bool := value.andHead || value.orHead

def Expr.isChoice : Expr α → Bool | .choose _ _ _ => true | _ => false
def Expr.isLocals : Expr α → Bool | .locals _ => true | _ => false
def Expr.isDeclaration : Expr α → Bool
  | .letFirst _ _ | .letAfter _ _ | .letTarget _ _ | .letIndex _ _ | .letValue _ _ => true
  | _ => false
def Expr.isBegin : Expr α → Bool | .beginValue _ => true | _ => false

def Expr.wellFormed : Expr α → Bool
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget
  | .localIndex | .zero | .scalarValue | .invalid => true
  | .skip value | .nameAfter value | .assignment value | .read value
  | .binding value | .stringMutable value | .assigned value => value.expression && value.wellFormed
  | .lookup first after | .stringLookup first after | .targetResult first after =>
      first.expression && after.expression && first.wellFormed && after.wellFormed
  | .mutable value | .declaredBounds value => value.prefix && value.wellFormed
  | .valueAfter value | .valueBounds value => value.prefix && value.wellFormed
  | .lower value | .upper value => value.prefix && value.wellFormed
  | .isEmpty value => value.expression && value.wellFormed
  | .eqNat left right | .neNat left right | .leNat left right
  | .ltInt left right | .gtInt left right =>
      left.primary && right.primary && left.wellFormed && right.wellFormed
  | .not value => value.primary && value.wellFormed
  | .andThen left right => left.andHead && right.andHead && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.orHead && left.wellFormed && right.wellFormed
  | .choose test yes no => test.expression && yes.expression && no.expression &&
      test.wellFormed && yes.wellFormed && no.wellFormed
  | .group value => (value.expression || value.isChoice || value.isLocals) && value.wellFormed
  | .locals value => value.isDeclaration && value.wellFormed
  | .letFirst value rest | .letAfter value rest | .letTarget value rest | .letIndex value rest =>
      value.expression && value.wellFormed && (rest.isDeclaration || rest.isBegin) && rest.wellFormed
  | .letValue value rest =>
      value.expression && value.wellFormed && (rest.isDeclaration || rest.isBegin) && rest.wellFormed
  | .beginValue value => value.expression && value.wellFormed

def RuntimeExpr.wellFormed : RuntimeExpr → Bool | .assignmentModel => true

/-- The source extractor supplies the enclosing expression-function syntax.
Declaration items and `begin` fragments are never complete expression roots. -/
def Expr.wellFormedRoot (value : Expr α) : Bool :=
  (value.expression || value.isChoice || value.isLocals) && value.wellFormed

abbrev WellFormedTrees : Prop :=
  targetBody.wellFormedRoot = true ∧ stringTargetBody.wellFormedRoot = true ∧
  assignmentBody.wellFormedRoot = true ∧ assignmentRhs.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

namespace StructuralControls

def atom : Expr Bool := .isEmpty (.valueBounds .scalarValue)

/-- The reported `not` collision is rejected although its tokens are unchanged. -/
theorem not_collision :
    (Expr.not (.orElse atom atom)).render = (Expr.orElse (.not atom) atom).render ∧
    (Expr.not (.orElse atom atom)).wellFormed = false ∧
    (Expr.orElse (.not atom) atom).wellFormed = true := by decide +kernel

/-- The assignment's mutable-test/cursor-test fragment has the same hazard. -/
theorem assignment_not_collision :
    let mutableTest : Expr Bool := .mutable (.binding .localTarget)
    let cursorTest : Expr Bool := .leNat (.valueAfter .scalarValue) .scanPosition
    (Expr.not (.orElse mutableTest cursorTest)).render =
      (Expr.orElse (.not mutableTest) cursorTest).render ∧
    (Expr.not (.orElse mutableTest cursorTest)).wellFormed = false ∧
    (Expr.orElse (.not mutableTest) cursorTest).wellFormed = true := by decide +kernel

theorem same_operator_nesting :
    (Expr.andThen (.andThen atom atom) atom).wellFormed = true ∧
    (Expr.andThen atom (.andThen atom atom)).wellFormed = true ∧
    (Expr.orElse (.orElse atom atom) atom).wellFormed = true ∧
    (Expr.orElse atom (.orElse atom atom)).wellFormed = true := by decide +kernel

theorem selected_prefixes :
    (Expr.valueAfter (.group (.choose atom .scalarValue .scalarValue))).wellFormed = false ∧
    (Expr.valueAfter (.group .scalarValue)).wellFormed = false ∧
    (Expr.valueAfter (.read .inputPosition)).wellFormed = true ∧
    (Expr.lower (.valueBounds (.read .inputPosition))).wellFormed = true ∧
    (Expr.mutable (.binding .localTarget)).wellFormed = true := by decide +kernel

theorem categories_and_nested_children :
    (Expr.andThen atom (.orElse atom atom)).wellFormed = false ∧
    (Expr.orElse (.andThen atom atom) atom).wellFormed = false ∧
    (Expr.andThen atom (.group (.orElse atom atom))).wellFormed = true ∧
    (Expr.not (.eqNat .zero .zero)).wellFormed = false ∧
    (Expr.eqNat (.choose atom .zero .zero) .zero).wellFormed = false ∧
    (Expr.eqNat (.group (.choose atom .zero .zero)) .zero).wellFormed = true ∧
    (Expr.isEmpty (.valueBounds (.read (.choose atom .zero .zero)))).wellFormed = false ∧
    (Expr.locals (.beginValue .zero)).wellFormed = false ∧
    (Expr.group (.letFirst .zero (.beginValue .zero))).wellFormed = false ∧
    (Expr.letFirst .zero (.beginValue .zero)).wellFormedRoot = false ∧
    (Expr.beginValue .zero).wellFormedRoot = false := by decide +kernel

end StructuralControls
end Silver.Predicate.ScalarBodyNative

namespace Silver.Predicate.Native.ScalarHelpers

def Expr.prefix : Expr ty → Bool
  | .variable _ | .scalarComparison _ | .names _ | .declarations _ | .bindingAt _ _
  | .mutable _ | .lower _ | .upper _ | .resultBounds _ | .resultAfter _
  | .resultStatic _ | .count _ | .cell _ _ | .skip _ _ | .nameAfter _ _
  | .lookup _ _ _ _ | .scalarRefine _ _ _ _ | .scalarEmpty _ | .scalarSwap _
  | .scalarOperator _ | .refineKeep _ _ _ _ | .bareTarget _ _ _ _
  | .refinedFlow _ _ _ _ _ => true
  | .number _ | .truth _ | .eq _ _ | .ne _ _ | .gt _ _ | .valueEq _ _
  | .andThen _ _ | .orElse _ _ | .ite _ _ _ | .elsif _ _ _ | .group _
  | .local _ _ _ _ | .locals _ | .operatorCase _ _ _ _ _ _ _ | .emptyPath _
  | .replace _ _ _ | .condition _ _ _ _ => false

def Expr.primary : Expr ty → Bool
  | .variable _ | .number _ | .truth _ | .scalarComparison _ | .names _
  | .declarations _ | .bindingAt _ _ | .mutable _ | .lower _ | .upper _
  | .resultBounds _ | .resultAfter _ | .resultStatic _ | .count _ | .cell _ _
  | .group _ | .emptyPath _ | .replace _ _ _ | .condition _ _ _ _ | .skip _ _
  | .nameAfter _ _ | .lookup _ _ _ _ | .scalarRefine _ _ _ _ | .scalarEmpty _
  | .scalarSwap _ | .scalarOperator _ | .refineKeep _ _ _ _ | .bareTarget _ _ _ _
  | .refinedFlow _ _ _ _ _ => true
  | .eq _ _ | .ne _ _ | .gt _ _ | .valueEq _ _ | .andThen _ _ | .orElse _ _
  | .ite _ _ _ | .elsif _ _ _ | .local _ _ _ _ | .locals _
  | .operatorCase _ _ _ _ _ _ _ => false

def Expr.relation (value : Expr ty) : Bool := value.primary || match value with
  | .eq _ _ | .ne _ _ | .gt _ _ | .valueEq _ _ => true
  | _ => false

def Expr.andHead (value : Expr ty) : Bool := value.relation || match value with
  | .andThen _ _ => true
  | _ => false

def Expr.orHead (value : Expr ty) : Bool := value.relation || match value with
  | .orElse _ _ => true
  | _ => false

def Expr.expression (value : Expr ty) : Bool := value.andHead || value.orHead
def Expr.isIf : Expr ty → Bool | .ite _ _ _ => true | _ => false
def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false
def Expr.isCase : Expr ty → Bool | .operatorCase _ _ _ _ _ _ _ => true | _ => false
def Expr.isLocals : Expr ty → Bool | .locals _ => true | _ => false
def Expr.isLocal : Expr ty → Bool | .local _ _ _ _ => true | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .variable _ | .number _ | .truth _ | .scalarComparison _ => true
  | .names value | .declarations value => value.prefix && value.wellFormed
  | .mutable value => value.prefix && value.wellFormed
  | .lower value | .upper value => value.prefix && value.wellFormed
  | .resultBounds value | .resultAfter value | .resultStatic value => value.prefix && value.wellFormed
  | .count value => value.prefix && value.wellFormed
  | .bindingAt value index | .cell value index =>
      value.prefix && index.expression && value.wellFormed && index.wellFormed
  | .eq left right | .ne left right | .gt left right | .valueEq left right =>
      left.primary && right.primary && left.wellFormed && right.wellFormed
  | .andThen left right => left.andHead && right.andHead && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.orHead && left.wellFormed && right.wellFormed
  | .ite test yes no | .elsif test yes no =>
      test.expression && yes.expression && (no.expression || no.isElsif) &&
      test.wellFormed && yes.wellFormed && no.wellFormed
  | .group value => (value.expression || value.isIf || value.isCase || value.isLocals) && value.wellFormed
  | .local _ _ value rest => value.expression && value.wellFormed &&
      (rest.expression || rest.isLocal) && rest.wellFormed
  | .locals value => value.isLocal && value.wellFormed
  | .operatorCase operator equal unequal less lessEqual greater greaterEqual =>
      operator.expression && equal.expression && unequal.expression && less.expression &&
      lessEqual.expression && greater.expression && greaterEqual.expression &&
      operator.wellFormed && equal.wellFormed && unequal.wellFormed && less.wellFormed &&
      lessEqual.wellFormed && greater.wellFormed && greaterEqual.wellFormed
  | .emptyPath facts => facts.primary && facts.wellFormed
  | .replace facts index bounds => facts.prefix && index.expression && bounds.expression &&
      facts.wellFormed && index.wellFormed && bounds.wellFormed
  | .condition size after yes no => size.expression && after.expression && yes.expression && no.expression &&
      size.wellFormed && after.wellFormed && yes.wellFormed && no.wellFormed
  | .skip text position | .nameAfter text position =>
      text.expression && position.expression && text.wellFormed && position.wellFormed
  | .lookup text environment first after => text.expression && environment.expression && first.expression && after.expression &&
      text.wellFormed && environment.wellFormed && first.wellFormed && after.wellFormed
  | .scalarRefine bounds operator threshold outcome | .refineKeep bounds operator threshold outcome =>
      bounds.expression && operator.expression && threshold.expression && outcome.expression &&
      bounds.wellFormed && operator.wellFormed && threshold.wellFormed && outcome.wellFormed
  | .scalarEmpty value | .scalarSwap value | .scalarOperator value => value.expression && value.wellFormed
  | .bareTarget text context position after => text.expression && context.expression && position.expression && after.expression &&
      text.wellFormed && context.wellFormed && position.wellFormed && after.wellFormed
  | .refinedFlow facts index operator threshold outcome =>
      facts.expression && index.expression && operator.expression && threshold.expression && outcome.expression &&
      facts.wellFormed && index.wellFormed && operator.wellFormed && threshold.wellFormed && outcome.wellFormed

/-- Outer expression-function parentheses may enclose `if`, `case` or
`declare`, but cannot supply a missing `if` or `declare` introducer. -/
def Expr.wellFormedRoot (value : Expr ty) : Bool :=
  (value.expression || value.isIf || value.isCase || value.isLocals) && value.wellFormed

abbrev WellFormedTrees : Prop :=
  invalidBody.wellFormedRoot = true ∧ operatorBody.wellFormedRoot = true ∧
  refineKeepBody.wellFormedRoot = true ∧ bareTargetBody.wellFormedRoot = true ∧
  refinedFlowBody.wellFormedRoot = true ∧ scalarConditionBody.wellFormedRoot = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

namespace StructuralControls

def atom : Expr .truth := .truth true

theorem same_operator_nesting :
    (Expr.andThen (.andThen atom atom) atom).wellFormed = true ∧
    (Expr.andThen atom (.andThen atom atom)).wellFormed = true ∧
    (Expr.orElse (.orElse atom atom) atom).wellFormed = true ∧
    (Expr.orElse atom (.orElse atom atom)).wellFormed = true := by decide +kernel

theorem selected_prefixes :
    (Expr.resultAfter (.group (.ite atom (.variable "r") (.variable "r")))).wellFormed = false ∧
    (Expr.resultAfter (.group (.variable "r"))).wellFormed = false ∧
    (Expr.count (.emptyPath (.variable "facts"))).wellFormed = false ∧
    (Expr.cell (.group (.variable "facts")) (.number 1)).wellFormed = false ∧
    (Expr.replace (.group (.variable "facts")) (.number 1) (.variable "bounds")).wellFormed = false ∧
    (Expr.lower (.resultBounds (.variable "r"))).wellFormed = true ∧
    (Expr.lower (.refineKeep (.variable "bounds") (.variable "operator")
      (.variable "threshold") atom)).wellFormed = true := by decide +kernel

theorem categories_and_nested_children :
    (Expr.andThen atom (.orElse atom atom)).wellFormed = false ∧
    (Expr.orElse (.andThen atom atom) atom).wellFormed = false ∧
    (Expr.orElse (.group (.andThen atom atom)) atom).wellFormed = true ∧
    (Expr.eq (.ite atom (.number 0) (.number 1)) (.number 0)).wellFormed = false ∧
    (Expr.eq (.group (.ite atom (.number 0) (.number 1))) (.number 0)).wellFormed = true ∧
    (Expr.scalarEmpty (.refineKeep (.variable "bounds") (.variable "operator") (.variable "threshold")
      (.andThen atom (.orElse atom atom)))).wellFormed = false ∧
    (Expr.group (.elsif atom (.number 0) (.number 1))).wellFormed = false ∧
    (Expr.locals (.number 0)).wellFormed = false ∧
    (Expr.group (.local "x" ["natural"] (.number 0) (.number 0))).wellFormed = false ∧
    (Expr.elsif atom (.number 0) (.number 1)).wellFormedRoot = false ∧
    (Expr.local "x" ["natural"] (.number 0) (.number 0)).wellFormedRoot = false := by decide +kernel

end StructuralControls
end Silver.Predicate.Native.ScalarHelpers

namespace Silver.Predicate.Adapter

def Expr.prefix : Expr α → Bool
  | .scan | .body | .context | .original | .result | .position
  | .token | .stop | .field _ _ | .stopValue _ | .initial _ | .initialFlow _
  | .nameCount _ | .completed _ | .bodyEnvironment _ | .takeToken _ _ | .invalid
  | .contextOf _ | .bodyOf _ | .expand _ _ _ | .read _ _ _ _ => true
  | .truth _ | .number _ | .zero _ | .nonzero _ | .not _ | .or _ _ | .orElse _ _
  | .tokenEqual _ | .choose _ _ _ | .contextValue _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  | .bodyValue _ _ _ _ _ _ _ | .stateValue _ _ _ _ _ _ _ _ _ | .scanValue _ _ _
  | .bodyToken _ _ | .stopCase _ _ _ _ => false

def Expr.primary : Expr α → Bool
  | .scan | .body | .context | .truth _ | .number _ | .original
  | .result | .position | .token | .stop | .field _ _ | .stopValue _
  | .choose _ _ _ | .initial _ | .initialFlow _ | .nameCount _ | .completed _
  | .bodyEnvironment _ | .contextValue _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  | .bodyValue _ _ _ _ _ _ _ | .stateValue _ _ _ _ _ _ _ _ _ | .scanValue _ _ _
  | .bodyToken _ _ | .takeToken _ _ | .invalid | .contextOf _ | .bodyOf _
  | .expand _ _ _ | .read _ _ _ _ | .stopCase _ _ _ _ => true
  | .zero _ | .nonzero _ | .not _ | .or _ _ | .orElse _ _ | .tokenEqual _ => false

def Expr.relation (value : Expr α) : Bool := value.primary || match value with
  | .zero _ | .nonzero _ | .not _ | .tokenEqual _ => true
  | _ => false

def Expr.expression (value : Expr α) : Bool := value.relation || match value with
  | .or _ _ | .orElse _ _ => true
  | _ => false

/-- Ada permits nesting of the same logical operator; eager and short-circuit
forms must not be mixed without an explicitly parenthesized expression. -/
def Expr.eagerOrOperand (value : Expr α) : Bool := value.relation || match value with
  | .or _ _ => true
  | _ => false

def Expr.shortOrOperand (value : Expr α) : Bool := value.relation || match value with
  | .orElse _ _ => true
  | _ => false

def Expr.wellFormed : Expr α → Bool
  | .scan | .body | .context | .truth _ | .number _ | .original
  | .result | .position | .token | .stop | .tokenEqual _ | .stopValue _ | .invalid => true
  | .field _ value | .nameCount value => value.prefix && value.wellFormed
  | .zero value | .nonzero value | .not value =>
      value.primary && value.wellFormed
  | .orElse left right => left.shortOrOperand && right.shortOrOperand && left.wellFormed && right.wellFormed
  | .or left right => left.eagerOrOperand && right.eagerOrOperand && left.wellFormed && right.wellFormed
  | .choose test yes no => test.expression && yes.expression && no.expression &&
      test.wellFormed && yes.wellFormed && no.wellFormed
  | .initial value | .initialFlow value | .completed value | .bodyEnvironment value
  | .contextOf value | .bodyOf value => value.expression && value.wellFormed
  | .contextValue names scalarNames arrayNames hidden booleans trueHidden falseHidden pure integerHidden elaborating maskFirst maskAfter count first after =>
      names.expression && scalarNames.expression && arrayNames.expression && hidden.expression && booleans.expression &&
      trueHidden.expression && falseHidden.expression && pure.expression && integerHidden.expression && elaborating.expression && maskFirst.expression &&
      maskAfter.expression && count.expression && first.expression && after.expression &&
      names.wellFormed && scalarNames.wellFormed && arrayNames.wellFormed && hidden.wellFormed && booleans.wellFormed &&
      trueHidden.wellFormed && falseHidden.wellFormed && pure.wellFormed && integerHidden.wellFormed && elaborating.wellFormed && maskFirst.wellFormed &&
      maskAfter.wellFormed && count.wellFormed && first.wellFormed && after.wellFormed
  | .bodyValue count facts pos target capacity assigned output =>
      count.expression && facts.expression && pos.expression && target.expression && capacity.expression &&
      assigned.expression && output.expression && count.wellFormed && facts.wellFormed && pos.wellFormed &&
      target.wellFormed && capacity.wellFormed && assigned.wellFormed && output.wellFormed
  | .stateValue originalExpr pos names scalarNames booleans first after target capacity =>
      originalExpr.expression && pos.expression && names.expression && scalarNames.expression &&
      booleans.expression && first.expression && after.expression && target.expression && capacity.expression &&
      originalExpr.wellFormed && pos.wellFormed && names.wellFormed && scalarNames.wellFormed &&
      booleans.wellFormed && first.wellFormed && after.wellFormed && target.wellFormed && capacity.wellFormed
  | .scanValue state assigned output => state.expression && assigned.expression && output.expression &&
      state.wellFormed && assigned.wellFormed && output.wellFormed
  | .bodyToken value tok => value.prefix && tok.expression && value.wellFormed && tok.wellFormed
  | .takeToken pos _ => pos.expression && pos.wellFormed
  | .expand ctx value originalExpr =>
      ctx.expression && value.expression && originalExpr.expression &&
      ctx.wellFormed && value.wellFormed && originalExpr.wellFormed
  | .read ctx value boundary catalog => ctx.expression && value.expression && boundary.expression && catalog.expression &&
      ctx.wellFormed && value.wellFormed && boundary.wellFormed && catalog.wellFormed
  | .stopCase ending alternative arm returning => ending.expression && alternative.expression && arm.expression && returning.expression &&
      ending.wellFormed && alternative.wellFormed && arm.wellFormed && returning.wellFormed

def Function.wellFormed (fn : Function) : Bool :=
  fn.context.expression && fn.result.expression && fn.returned.expression &&
  fn.context.wellFormed && fn.result.wellFormed && fn.returned.wellFormed

abbrev WellFormedTrees : Prop :=
  contextExpr.wellFormed = true ∧ bodyExpr.wellFormed = true ∧
  expandExpr.wellFormed = true ∧ tokenExpr.wellFormed = true ∧
  atStopExpr.wellFormed = true ∧ adapterFunction.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

namespace StructuralControls

def atom : Expr Bool := .truth true

theorem not_collision :
    (Expr.not (.orElse atom atom)).render = (Expr.orElse (.not atom) atom).render ∧
    (Expr.not (.orElse atom atom)).wellFormed = false ∧
    (Expr.orElse (.not atom) atom).wellFormed = true := by decide +kernel

theorem eager_or_structure :
    (Expr.not (.or atom atom)).render = (Expr.or (.not atom) atom).render ∧
    (Expr.not (.or atom atom)).wellFormed = false ∧
    (Expr.or (.not atom) atom).wellFormed = true ∧
    (Expr.or (.or atom atom) atom).wellFormed = true ∧
    (Expr.or atom (.or atom atom)).wellFormed = true ∧
    (Expr.or (.orElse atom atom) atom).wellFormed = false ∧
    (Expr.orElse atom (.or atom atom)).wellFormed = false := by decide +kernel

theorem same_operator_nesting :
    (Expr.orElse (.orElse atom atom) atom).wellFormed = true ∧
    (Expr.orElse atom (.orElse atom atom)).wellFormed = true := by decide +kernel

theorem selected_prefixes :
    (Expr.field .bodyPosition (.choose atom .body .body)).wellFormed = false ∧
    (Expr.field .bodyPosition (.bodyToken .body .token)).wellFormed = false ∧
    (Expr.bodyToken (.choose atom .body .body) .token).wellFormed = false ∧
    (Expr.field .bodyPosition (.read .context .body .stop (.field .stateFunctions (.field .scanState .scan)))).wellFormed = true ∧
    (Expr.field .statePosition (.field .scanState .scan)).wellFormed = true := by decide +kernel

theorem categories_and_nested_children :
    (Expr.not (.zero .position)).wellFormed = false ∧
    (Expr.not (.choose atom (.zero .position) atom)).wellFormed = true ∧
    (Expr.initial (.not (.orElse atom atom))).wellFormed = false ∧
    (Expr.stopCase atom atom (.not (.orElse atom atom)) atom).wellFormed = false ∧
    (Function.wellFormed ⟨.context, .body, .choose (.not (.orElse atom atom)) .invalid .scan⟩) = false := by
  decide +kernel

end StructuralControls
end Silver.Predicate.Adapter
