module

public import Silver.ApplicationNativeCore
import all Init.Data.Repr

@[expose] public section

/-! Fail-closed structural checks for the feature-local source trees. These
checks distinguish names, primaries, simple expressions and logical chains,
visit every child, and track bound variable types across shadowing. Exact source
extraction and callee equations remain separate required evidence. -/
namespace Silver.ApplicationNative

variable {Fn : Ty → Type}

def identifier (name : String) : Bool :=
  let chars := name.toList
  !chars.isEmpty && decide (97 ≤ (chars.headD ' ').toNat ∧ (chars.headD ' ').toNat ≤ 122) &&
    chars.all (fun c => decide ((97 ≤ c.toNat ∧ c.toNat ≤ 122) ∨
      (48 ≤ c.toNat ∧ c.toNat ≤ 57) ∨ c.toNat = 95)) &&
    decide (chars.getLast? ≠ some '_') &&
    !(chars.zip chars.tail).any (fun pair => pair.1 == '_' && pair.2 == '_') &&
    !(name ∈ Named.forbiddenSpellings) &&
    !(name ∈ ["and", "or", "xor", "not", "if", "then", "else", "elsif", "for", "all",
      "some", "in", "is", "begin", "end", "return", "declare", "constant", "with", "delta",
      "true", "false", "others", "when", "case", "loop", "while", "mod", "rem", "abs"])

def qualifiedName : List String → Bool
  | [] => false
  | [name] => identifier name
  | name :: "." :: rest => identifier name && qualifiedName rest
  | _ => false

/-- Fixed literal leaves cannot smuggle a quote or control token into source. -/
def literalWord (word : String) : Bool :=
  word.toList.all fun c => decide (32 ≤ c.toNat ∧ c.toNat ≤ 126) && c != '"'

def Expr.prefix : Expr Fn ty → Bool
  | .variable _ | .function _ | .app _ _ | .namedApp _ _ _ | .soleApp _ _ | .field _ _ | .property _ _ | .index _ _ _
  | .full | .empty | .invalidCall | .invalidObject | .emptyStateSet | .invalidType | .invalidState | .noHidden | .booleanType | .integerType
  | .scalarKind _ | .exportKind _ | .mode _ | .unitKind _ | .bodyStop _ | .routineKind _ | .token _ | .maxConcatenations | .emptyMetadata | .invalidAnalysis | .sourcePrefix _ _ => true
  | .number _ | .integer _ | .truth _ | .word _ | .add _ _ | .sub _ _ | .eq _ _ | .ne _ _
  | .inRange _ _ _ | .lt _ _ | .le _ _ | .gt _ _ | .ge _ _ | .intLe _ _ | .intGe _ _ | .intNe _ _ | .intervalEq _ _ | .nameEq _ _ | .kindEq _ _ | .routineEq _ _
  | .exportEq _ _ | .modeNe _ _ | .modeEq _ _ | .stateSetNe _ _ | .unitMapEq _ _ | .unitMapNe _ _ | .not _ | .andThen _ _ | .orElse _ _ | .eagerOr _ _ | .group _
  | .ite _ _ _ | .conditionalTrue _ _ | .elsif _ _ _ | .sourceLast _ | .sourceLength _ | .nameSpan _ _
  | .scalarConstraintValue _ _ | .scalarBindingValue _ _ _ _ _ _ _ _ | .booleanBindingValue _ _ _ _ _ _ _ | .stateDeclarationValue _ _ _ _ _ _ _ _ _ | .callValueAggregate _ _ _ | .applicationCall _ _ _ | .packageType _ _ _ _ _ | .scanResult _ _ _ | .analysisValue _ _ _ _ _ _ _ | .forAll _ _ _ _ | .forSome _ _ _ _ | .forAllFlowValues _ _ _ | .forAllActuals _ _ _ | .forAllStates _ _ | .update _ _ | .noCalls | .emptyActuals | .emptySeen | .functionType _ _ _ _ | .functionFormal _ _ _ _ _ | .procedureFormal _ _ _ _ _ _ => false

def Expr.primary : Expr Fn ty → Bool
  | .variable _ | .function _ | .app _ _ | .namedApp _ _ _ | .soleApp _ _ | .field _ _ | .property _ _ | .index _ _ _ | .number _ | .integer _
  | .truth _ | .word _ | .scalarKind _ | .exportKind _ | .mode _ | .unitKind _ | .bodyStop _ | .routineKind _ | .group _
  | .sourceLast _ | .sourceLength _ | .nameSpan _ _ | .scalarConstraintValue _ _ | .scalarBindingValue _ _ _ _ _ _ _ _ | .booleanBindingValue _ _ _ _ _ _ _ | .stateDeclarationValue _ _ _ _ _ _ _ _ _ | .callValueAggregate _ _ _ | .applicationCall _ _ _ | .packageType _ _ _ _ _ | .scanResult _ _ _ | .analysisValue _ _ _ _ _ _ _ | .full | .empty
  | .invalidCall | .invalidObject | .emptyStateSet | .invalidType | .invalidState | .noHidden | .noCalls | .booleanType | .integerType | .update _ _
  | .emptyActuals | .emptySeen | .functionType _ _ _ _ | .functionFormal _ _ _ _ _ | .procedureFormal _ _ _ _ _ _
  | .token _ | .maxConcatenations | .emptyMetadata | .invalidAnalysis | .sourcePrefix _ _ => true
  | .add _ _ | .sub _ _ | .eq _ _ | .ne _ _ | .inRange _ _ _ | .lt _ _ | .le _ _ | .gt _ _ | .ge _ _
  | .intLe _ _ | .intGe _ _ | .intNe _ _ | .intervalEq _ _ | .nameEq _ _ | .kindEq _ _ | .routineEq _ _ | .exportEq _ _ | .modeNe _ _ | .modeEq _ _ | .stateSetNe _ _ | .unitMapEq _ _ | .unitMapNe _ _ | .not _
  | .andThen _ _ | .orElse _ _ | .eagerOr _ _ | .ite _ _ _ | .conditionalTrue _ _ | .elsif _ _ _ | .forAll _ _ _ _ | .forSome _ _ _ _ | .forAllFlowValues _ _ _ | .forAllActuals _ _ _ | .forAllStates _ _ => false

def Expr.simple (value : Expr Fn ty) : Bool := value.primary || match value with
  | .add _ _ | .sub _ _ => true
  | _ => false

def Expr.relation (value : Expr Fn ty) : Bool := value.simple || match value with
  | .eq _ _ | .ne _ _ | .inRange _ _ _ | .lt _ _ | .le _ _ | .gt _ _ | .ge _ _ | .intLe _ _ | .intGe _ _ | .intNe _ _
  | .intervalEq _ _ | .nameEq _ _ | .kindEq _ _ | .routineEq _ _ | .exportEq _ _ | .modeNe _ _ | .modeEq _ _ | .stateSetNe _ _ | .unitMapEq _ _ | .unitMapNe _ _ | .not _ => true
  | _ => false

def Expr.andHead (value : Expr Fn ty) : Bool := value.relation || match value with
  | .andThen _ _ => true | _ => false

def Expr.orHead (value : Expr Fn ty) : Bool := value.relation || match value with
  | .orElse _ _ => true | _ => false

def Expr.eagerOrHead (value : Expr Fn ty) : Bool := value.relation || match value with
  | .eagerOr _ _ => true | _ => false

def Expr.expression (value : Expr Fn ty) : Bool := value.andHead || value.orHead || value.eagerOrHead

def Expr.logical (value : Expr Fn .truth) : Bool := value.expression

def Expr.conditional : Expr Fn ty → Bool | .ite _ _ _ | .conditionalTrue _ _ => true | _ => false

def Expr.quantified : Expr Fn ty → Bool | .forAll _ _ _ _ | .forSome _ _ _ _ | .forAllFlowValues _ _ _ | .forAllActuals _ _ _ | .forAllStates _ _ => true | _ => false

def Expr.isElsif : Expr Fn ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.callSpine : Expr Fn ty → Bool
  | .function _ => true | .app fn _ | .namedApp _ fn _ => fn.callSpine | _ => false

def Expr.positionalSpine : Expr Fn ty → Bool
  | .function _ => true | .app fn _ => fn.positionalSpine | _ => false

def Expr.namedArguments : Expr Fn ty → List String
  | .app fn _ => fn.namedArguments
  | .namedApp name fn _ => name :: fn.namedArguments
  | _ => []

/-- Position of the next application in the native formal declaration order. -/
def Expr.formalAt (parameters : FunctionParameters Fn) (offset : Nat) : Expr Fn ty → Option String
  | .function symbol => (parameters symbol)[offset]?
  | .app fn _ | .namedApp _ fn _ => fn.formalAt parameters (offset + 1)
  | _ => none

def Updates.fields : Updates Fn owner → List String
  | .one field _ => [field.name]
  | .more field _ rest => field.name :: rest.fields

mutual
def Expr.wellFormed (names : FunctionNames Fn) : Expr Fn ty → Bool
  | .number _ | .truth _ | .scalarKind _ | .exportKind _ | .mode _ | .unitKind _ | .bodyStop _ | .routineKind _ | .emptyActuals | .emptySeen | .full | .empty
  | .invalidCall | .invalidObject | .emptyStateSet | .invalidType | .invalidState | .noHidden | .noCalls | .booleanType | .integerType
  | .maxConcatenations | .emptyMetadata | .invalidAnalysis => true
  | .token value => decide (value ∈ Compose.Expressions.allTokens)
  | .integer value => decide (0 ≤ value)
  | .word value => literalWord value
  | .variable name => identifier name
  | .function symbol => qualifiedName (names symbol)
  | .soleApp symbol argument => qualifiedName (names symbol) &&
      (argument.conditional || argument.quantified) && argument.wellFormed names
  | .app fn argument => fn.positionalSpine && fn.wellFormed names &&
      argument.expression && argument.wellFormed names
  | .namedApp name fn argument => identifier name && fn.callSpine &&
      decide (name ∉ fn.namedArguments) && fn.wellFormed names &&
      argument.expression && argument.wellFormed names
  | .field _ value | .property _ value => value.prefix && value.wellFormed names
  | .index _ value index => value.prefix && value.wellFormed names &&
      index.expression && index.wellFormed names
  | .add left right | .sub left right => left.simple && right.primary &&
      left.wellFormed names && right.wellFormed names
  | .eq left right | .ne left right | .lt left right | .le left right | .gt left right | .ge left right
  | .intLe left right | .intGe left right | .intNe left right | .intervalEq left right | .nameEq left right | .kindEq left right | .routineEq left right | .exportEq left right | .modeNe left right | .modeEq left right | .stateSetNe left right
  | .unitMapEq left right | .unitMapNe left right =>
      left.simple && right.simple && left.wellFormed names && right.wellFormed names
  | .inRange value first last => value.simple && first.simple && last.simple &&
      value.wellFormed names && first.wellFormed names && last.wellFormed names
  | .not value => value.primary && value.wellFormed names
  | .andThen left right => left.andHead && right.relation && left.wellFormed names && right.wellFormed names
  | .orElse left right => left.orHead && right.relation && left.wellFormed names && right.wellFormed names
  | .eagerOr left right => left.eagerOrHead && right.relation && left.wellFormed names && right.wellFormed names
  | .group value => (value.expression || value.conditional || value.quantified) && value.wellFormed names
  | .ite test yes no | .elsif test yes no => test.expression && yes.expression &&
      (no.expression || no.isElsif) && test.wellFormed names && yes.wellFormed names && no.wellFormed names
  | .conditionalTrue test yes => test.expression && yes.expression &&
      test.wellFormed names && yes.wellFormed names
  | .sourceLast value | .sourceLength value => value.prefix && value.wellFormed names
  | .sourcePrefix text last => text.prefix && text.wellFormed names && last.simple && last.wellFormed names
  | .nameSpan first after => first.expression && after.expression && first.wellFormed names && after.wellFormed names
  | .callValueAggregate after kind bounds => after.expression && kind.expression && bounds.expression &&
      after.wellFormed names && kind.wellFormed names && bounds.wellFormed names
  | .applicationCall count value scan => count.expression && value.expression && scan.expression &&
      count.wellFormed names && value.wellFormed names && scan.wellFormed names
  | .scalarConstraintValue after bounds => after.expression && bounds.expression && after.wellFormed names && bounds.wellFormed names
  | .scalarBindingValue first after bounds isStatic declaredBounds mutable qFirst qAfter =>
      first.expression && after.expression && bounds.expression && isStatic.expression && declaredBounds.expression &&
      mutable.expression && qFirst.expression && qAfter.expression && first.wellFormed names && after.wellFormed names &&
      bounds.wellFormed names && isStatic.wellFormed names && declaredBounds.wellFormed names && mutable.wellFormed names &&
      qFirst.wellFormed names && qAfter.wellFormed names
  | .booleanBindingValue first after mutable qFirst qAfter known value =>
      first.expression && after.expression && mutable.expression && qFirst.expression && qAfter.expression && known.expression &&
      value.expression && first.wellFormed names && after.wellFormed names && mutable.wellFormed names && qFirst.wellFormed names &&
      qAfter.wellFormed names && known.wellFormed names && value.wellFormed names
  | .stateDeclarationValue name kind typeName identity declaredBounds initialBounds first after value =>
      name.expression && kind.expression && typeName.expression && identity.expression &&
      declaredBounds.expression && initialBounds.expression && first.expression && after.expression && value.expression &&
      name.wellFormed names && kind.wellFormed names && typeName.wellFormed names && identity.wellFormed names &&
      declaredBounds.wellFormed names && initialBounds.wellFormed names && first.wellFormed names &&
      after.wellFormed names && value.wellFormed names
  | .functionType after kind bounds typeId => after.expression && kind.expression && bounds.expression &&
      typeId.expression && after.wellFormed names && kind.wellFormed names && bounds.wellFormed names && typeId.wellFormed names
  | .functionFormal first after kind bounds typeId => first.expression && after.expression &&
      kind.expression && bounds.expression && typeId.expression && first.wellFormed names &&
      after.wellFormed names && kind.wellFormed names && bounds.wellFormed names && typeId.wellFormed names
  | .procedureFormal first after kind bounds typeId mode => first.expression && after.expression &&
      kind.expression && bounds.expression && typeId.expression && mode.expression && first.wellFormed names &&
      after.wellFormed names && kind.wellFormed names && bounds.wellFormed names && typeId.wellFormed names && mode.wellFormed names
  | .scanResult state assigned output => state.expression && assigned.expression && output.expression &&
      state.wellFormed names && assigned.wellFormed names && output.wellFormed names
  | .analysisValue accepted info functions procedures arguments assigned output =>
      accepted.expression && info.expression && functions.expression && procedures.expression &&
      arguments.expression && assigned.expression && output.expression &&
      accepted.wellFormed names && info.wellFormed names && functions.wellFormed names &&
      procedures.wellFormed names && arguments.wellFormed names && assigned.wellFormed names && output.wellFormed names
  | .packageType name after kind bounds identity => name.expression && after.expression && kind.expression &&
      bounds.expression && identity.expression && name.wellFormed names && after.wellFormed names &&
      kind.wellFormed names && bounds.wellFormed names && identity.wellFormed names
  | .forAll name first last body | .forSome name first last body => identifier name &&
      first.simple && last.simple && body.expression && first.wellFormed names && last.wellFormed names && body.wellFormed names
  | .forAllStates name body => identifier name && body.expression && body.wellFormed names
  | .forAllFlowValues name values body | .forAllActuals name values body =>
      identifier name && values.prefix && body.expression && values.wellFormed names && body.wellFormed names
  | .update base changes => base.expression && base.wellFormed names &&
      decide changes.fields.Nodup && changes.wellFormed names
def Updates.wellFormed (names : FunctionNames Fn) : Updates Fn owner → Bool
  | .one _ value => value.expression && value.wellFormed names
  | .more _ value rest => value.expression && value.wellFormed names && rest.wellFormed names
end

def Expr.wellFormedRoot (names : FunctionNames Fn) (value : Expr Fn ty) : Bool :=
  (value.expression || value.conditional || value.quantified) && value.wellFormed names

abbrev Scope := List (Ty × String)

def Scope.contains (scope : Scope) (ty : Ty) (name : String) : Bool := (ty, name) ∈ scope

def Scope.bind (scope : Scope) (ty : Ty) (name : String) : Scope :=
  (ty, name) :: scope.filter (fun entry => entry.2 != name)

mutual
def Expr.scoped (scope : Scope) : Expr Fn ty → Bool
  | .variable (ty := ty) name => (ty, name) ∈ scope
  | .number _ | .integer _ | .truth _ | .word _ | .scalarKind _ | .exportKind _ | .mode _
  | .unitKind _ | .bodyStop _ | .routineKind _ | .emptyActuals | .emptySeen | .function _ | .full | .empty | .invalidCall | .invalidObject | .emptyStateSet | .invalidType | .invalidState | .noHidden
  | .noCalls | .booleanType | .integerType | .token _ | .maxConcatenations | .emptyMetadata | .invalidAnalysis => true
  | .soleApp _ argument => argument.scoped scope
  | .app fn argument | .namedApp _ fn argument => fn.scoped scope && argument.scoped scope
  | .field _ value | .property _ value | .not value | .group value | .sourceLast value | .sourceLength value => value.scoped scope
  | .index _ value index => value.scoped scope && index.scoped scope
  | .add left right | .sub left right | .eq left right | .ne left right | .lt left right
  | .le left right | .gt left right | .ge left right | .intLe left right | .intGe left right | .intNe left right | .intervalEq left right | .nameEq left right
  | .kindEq left right | .routineEq left right | .exportEq left right | .modeNe left right | .modeEq left right | .stateSetNe left right | .andThen left right
  | .orElse left right | .eagerOr left right | .nameSpan left right | .sourcePrefix left right | .conditionalTrue left right
  | .unitMapEq left right | .unitMapNe left right => left.scoped scope && right.scoped scope
  | .inRange value first last => value.scoped scope && first.scoped scope && last.scoped scope
  | .ite test yes no | .elsif test yes no => test.scoped scope && yes.scoped scope && no.scoped scope
  | .callValueAggregate after kind bounds => after.scoped scope && kind.scoped scope && bounds.scoped scope
  | .applicationCall count value scan => count.scoped scope && value.scoped scope && scan.scoped scope
  | .scalarConstraintValue after bounds => after.scoped scope && bounds.scoped scope
  | .scalarBindingValue first after bounds isStatic declaredBounds mutable qFirst qAfter =>
      first.scoped scope && after.scoped scope && bounds.scoped scope && isStatic.scoped scope &&
      declaredBounds.scoped scope && mutable.scoped scope && qFirst.scoped scope && qAfter.scoped scope
  | .booleanBindingValue first after mutable qFirst qAfter known value =>
      first.scoped scope && after.scoped scope && mutable.scoped scope && qFirst.scoped scope &&
      qAfter.scoped scope && known.scoped scope && value.scoped scope
  | .stateDeclarationValue name kind typeName identity declaredBounds initialBounds first after value =>
      name.scoped scope && kind.scoped scope && typeName.scoped scope && identity.scoped scope &&
      declaredBounds.scoped scope && initialBounds.scoped scope && first.scoped scope && after.scoped scope && value.scoped scope
  | .functionType after kind bounds typeId => after.scoped scope && kind.scoped scope && bounds.scoped scope && typeId.scoped scope
  | .functionFormal first after kind bounds typeId => first.scoped scope && after.scoped scope &&
      kind.scoped scope && bounds.scoped scope && typeId.scoped scope
  | .procedureFormal first after kind bounds typeId mode => first.scoped scope && after.scoped scope &&
      kind.scoped scope && bounds.scoped scope && typeId.scoped scope && mode.scoped scope
  | .scanResult state assigned output => state.scoped scope && assigned.scoped scope && output.scoped scope
  | .analysisValue accepted info functions procedures arguments assigned output =>
      accepted.scoped scope && info.scoped scope && functions.scoped scope && procedures.scoped scope &&
      arguments.scoped scope && assigned.scoped scope && output.scoped scope
  | .packageType name after kind bounds identity => name.scoped scope && after.scoped scope &&
      kind.scoped scope && bounds.scoped scope && identity.scoped scope
  | .forAll name first last body | .forSome name first last body =>
      first.scoped scope && last.scoped scope && body.scoped (scope.bind .number name)
  | .forAllStates name body => body.scoped (scope.bind .number name)
  | .forAllFlowValues name values body | .forAllActuals name values body =>
      values.scoped scope && body.scoped (scope.bind .number name)
  | .update base changes => base.scoped scope && changes.scoped scope
def Updates.scoped (scope : Scope) : Updates Fn owner → Bool
  | .one _ value => value.scoped scope
  | .more _ value rest => value.scoped scope && rest.scoped scope
end

/- Named associations use the same curried evaluator only after this check
matches each label to its native formal at the current application depth. The
source boundary must bind `parameters` to the actual callee headers. -/
mutual
def Expr.namedCorrect (parameters : FunctionParameters Fn) : Expr Fn ty → Bool
  | .variable _ => true
  | .number _ | .integer _ | .truth _ | .word _ | .scalarKind _ | .exportKind _ | .mode _
  | .unitKind _ | .bodyStop _ | .routineKind _ | .emptyActuals | .emptySeen | .function _ | .full | .empty | .invalidCall | .invalidObject | .emptyStateSet | .invalidType | .invalidState | .noHidden
  | .noCalls | .booleanType | .integerType | .token _ | .maxConcatenations | .emptyMetadata | .invalidAnalysis => true
  | .soleApp _ argument => argument.namedCorrect parameters
  | .app fn argument => fn.namedCorrect parameters && argument.namedCorrect parameters
  | .namedApp name fn argument => (fn.formalAt parameters 0 == some name) &&
      fn.namedCorrect parameters && argument.namedCorrect parameters
  | .field _ value | .property _ value | .not value | .group value | .sourceLast value | .sourceLength value => value.namedCorrect parameters
  | .index _ value index => value.namedCorrect parameters && index.namedCorrect parameters
  | .add left right | .sub left right | .eq left right | .ne left right | .lt left right
  | .le left right | .gt left right | .ge left right | .intLe left right | .intGe left right | .intNe left right | .intervalEq left right | .nameEq left right
  | .kindEq left right | .routineEq left right | .exportEq left right | .modeNe left right | .modeEq left right | .stateSetNe left right | .andThen left right
  | .orElse left right | .eagerOr left right | .nameSpan left right | .sourcePrefix left right | .conditionalTrue left right
  | .unitMapEq left right | .unitMapNe left right => left.namedCorrect parameters && right.namedCorrect parameters
  | .inRange value first last => value.namedCorrect parameters && first.namedCorrect parameters && last.namedCorrect parameters
  | .ite test yes no | .elsif test yes no => test.namedCorrect parameters && yes.namedCorrect parameters && no.namedCorrect parameters
  | .callValueAggregate after kind bounds => after.namedCorrect parameters && kind.namedCorrect parameters && bounds.namedCorrect parameters
  | .applicationCall count value scan => count.namedCorrect parameters && value.namedCorrect parameters && scan.namedCorrect parameters
  | .scalarConstraintValue after bounds => after.namedCorrect parameters && bounds.namedCorrect parameters
  | .scalarBindingValue first after bounds isStatic declaredBounds mutable qFirst qAfter =>
      first.namedCorrect parameters && after.namedCorrect parameters && bounds.namedCorrect parameters && isStatic.namedCorrect parameters &&
      declaredBounds.namedCorrect parameters && mutable.namedCorrect parameters && qFirst.namedCorrect parameters && qAfter.namedCorrect parameters
  | .booleanBindingValue first after mutable qFirst qAfter known value =>
      first.namedCorrect parameters && after.namedCorrect parameters && mutable.namedCorrect parameters && qFirst.namedCorrect parameters &&
      qAfter.namedCorrect parameters && known.namedCorrect parameters && value.namedCorrect parameters
  | .stateDeclarationValue name kind typeName identity declaredBounds initialBounds first after value =>
      name.namedCorrect parameters && kind.namedCorrect parameters && typeName.namedCorrect parameters && identity.namedCorrect parameters &&
      declaredBounds.namedCorrect parameters && initialBounds.namedCorrect parameters && first.namedCorrect parameters && after.namedCorrect parameters && value.namedCorrect parameters
  | .functionType after kind bounds typeId => after.namedCorrect parameters && kind.namedCorrect parameters && bounds.namedCorrect parameters && typeId.namedCorrect parameters
  | .functionFormal first after kind bounds typeId => first.namedCorrect parameters && after.namedCorrect parameters &&
      kind.namedCorrect parameters && bounds.namedCorrect parameters && typeId.namedCorrect parameters
  | .procedureFormal first after kind bounds typeId mode => first.namedCorrect parameters && after.namedCorrect parameters &&
      kind.namedCorrect parameters && bounds.namedCorrect parameters && typeId.namedCorrect parameters && mode.namedCorrect parameters
  | .scanResult state assigned output => state.namedCorrect parameters && assigned.namedCorrect parameters && output.namedCorrect parameters
  | .analysisValue accepted info functions procedures arguments assigned output =>
      accepted.namedCorrect parameters && info.namedCorrect parameters && functions.namedCorrect parameters && procedures.namedCorrect parameters &&
      arguments.namedCorrect parameters && assigned.namedCorrect parameters && output.namedCorrect parameters
  | .packageType name after kind bounds identity => name.namedCorrect parameters && after.namedCorrect parameters &&
      kind.namedCorrect parameters && bounds.namedCorrect parameters && identity.namedCorrect parameters
  | .forAll _ first last body | .forSome _ first last body =>
      first.namedCorrect parameters && last.namedCorrect parameters && body.namedCorrect parameters
  | .forAllStates _ body => body.namedCorrect parameters
  | .forAllFlowValues _ values body | .forAllActuals _ values body =>
      values.namedCorrect parameters && body.namedCorrect parameters
  | .update base changes => base.namedCorrect parameters && changes.namedCorrect parameters
def Updates.namedCorrect (parameters : FunctionParameters Fn) : Updates Fn owner → Bool
  | .one _ value => value.namedCorrect parameters
  | .more _ value rest => value.namedCorrect parameters && rest.namedCorrect parameters
end

namespace StructuralControls

inductive NamedFunction : Ty → Type
  | sample : NamedFunction (.arrow .number (.arrow .truth .number))

def namedFunctionNames : FunctionNames NamedFunction
  | _, .sample => ["sample"]

def namedFunctionParameters : FunctionParameters NamedFunction
  | _, .sample => ["position", "local"]

def namedTail (label : String) : Expr NamedFunction .number :=
  .namedApp label (.app (.function .sample) (.number 1)) (.truth true)

theorem named_call_order_and_labels :
    (namedTail "local").wellFormedRoot namedFunctionNames = true ∧
    (namedTail "local").namedCorrect namedFunctionParameters = true ∧
    (namedTail "range_query").namedCorrect namedFunctionParameters = false ∧
    (namedTail "local)").wellFormedRoot namedFunctionNames = false ∧
    (Expr.app (.namedApp "position" (.function .sample) (.number 1)) (.truth true) : Expr NamedFunction .number).wellFormedRoot namedFunctionNames = false ∧
    (Expr.namedApp "position" (.namedApp "position" (.function .sample) (.number 1)) (.truth true) : Expr NamedFunction .number).wellFormedRoot namedFunctionNames = false := by decide +kernel

theorem named_call_exact_render :
    (namedTail "local").render namedFunctionNames =
      ["sample", "(", "1", ",", "local", "=>", "true", ")"] := by decide +kernel

theorem named_call_meaning (calls : Calls Fn) (locals : Locals)
    (name : String) (fn : Expr Fn (.arrow a b)) (argument : Expr Fn a) :
    (Expr.namedApp name fn argument).eval calls locals =
      fn.eval calls locals (argument.eval calls locals) := rfl

abbrev NoFunctions := fun (_ : Ty) => Empty

def noNames : FunctionNames NoFunctions := fun symbol => nomatch symbol

def atom : Expr NoFunctions .truth := .variable "flag"

theorem not_collision :
    (Expr.not (.orElse atom atom)).render noNames = (Expr.orElse (.not atom) atom).render noNames ∧
    (Expr.not (.orElse atom atom)).wellFormedRoot noNames = false ∧
    (Expr.orElse (.not atom) atom).wellFormedRoot noNames = true := by decide +kernel

theorem nested_operators :
    (Expr.andThen atom (.orElse atom atom)).wellFormedRoot noNames = false ∧
    (Expr.andThen atom (.group (.orElse atom atom))).wellFormedRoot noNames = true ∧
    (Expr.sub (.number 4) (.sub (.number 2) (.number 1)) : Expr NoFunctions .number).wellFormedRoot noNames = false ∧
    (Expr.sub (.sub (.number 4) (.number 2)) (.number 1) : Expr NoFunctions .number).wellFormedRoot noNames = true := by decide +kernel

/-- Call parentheses cover one conditional argument; adding an ordinary or
named argument would lose those parentheses and is rejected. -/
theorem sole_conditional_call_guard :
    (Expr.soleApp NamedFunction.sample (.ite (.truth true) (.number 1) (.number 0))).wellFormedRoot namedFunctionNames = true ∧
    (Expr.app (.soleApp NamedFunction.sample (.ite (.truth true) (.number 1) (.number 0))) (.truth true)).wellFormedRoot namedFunctionNames = false ∧
    (Expr.namedApp "enabled" (.soleApp NamedFunction.sample (.ite (.truth true) (.number 1) (.number 0))) (.truth true)).wellFormedRoot namedFunctionNames = false := by decide +kernel

theorem sole_conditional_call_meaning (symbol : Fn (.arrow a b)) (calls : Calls Fn)
    (locals : Locals) (argument : Expr Fn a) :
    (Expr.soleApp symbol argument).eval calls locals = calls _ symbol (argument.eval calls locals) := rfl

theorem prefixes_and_conditional_children :
    (Expr.field .nameFirst (.group (.variable "name")) : Expr NoFunctions .number).wellFormedRoot noNames = false ∧
    (Expr.field .nameFirst (.variable "name") : Expr NoFunctions .number).wellFormedRoot noNames = true ∧
    (Expr.group (.ite atom (.not (.orElse atom atom)) atom)).wellFormedRoot noNames = false := by decide +kernel

theorem quantified_scope :
    (Expr.forAll "i" (.number 1) (.number 3) (.le (.variable "i") (.number 3)) : Expr NoFunctions .truth).scoped [] = true ∧
    (Expr.forAll "i" (.number 1) (.number 3) (.variable "i") : Expr NoFunctions .truth).scoped [(.truth, "i")] = false ∧
    (Expr.forAll "i" (.variable "i") (.number 3) (.truth true) : Expr NoFunctions .truth).scoped [] = false := by decide +kernel

theorem update_children_and_duplicates :
    (Expr.update (.variable "frame") (.one .statePure (.not (.orElse atom atom))) : Expr NoFunctions .state).wellFormedRoot noNames = false ∧
    (Expr.update (.variable "frame") (.more .statePure (.truth false) (.one .statePure (.truth true))) : Expr NoFunctions .state).wellFormedRoot noNames = false ∧
    (Expr.update (.variable "frame") (.one .statePure (.truth true)) : Expr NoFunctions .state).wellFormedRoot noNames = true := by decide +kernel

theorem token_spellings :
    (Expr.token (.word "pragma") : Expr NoFunctions .token).wellFormedRoot noNames = true ∧
    (Expr.token (.symbol "=") : Expr NoFunctions .token).wellFormedRoot noNames = true ∧
    (Expr.token (.word "unknown_token") : Expr NoFunctions .token).wellFormedRoot noNames = false ∧
    (Expr.token (.symbol "pragma") : Expr NoFunctions .token).wellFormedRoot noNames = false := by decide +kernel

theorem unit_map_equality (calls : Calls Fn) (locals : Locals)
    (left right : Expr Fn .unitMap) :
    (Expr.unitMapEq left right).eval calls locals = true ↔
      left.eval calls locals = right.eval calls locals :=
  ApplicationAdmission.unitsEqual_iff _ _

theorem integer_comparison_children :
    (Expr.intGe (.variable "lower") (.integer 0) : Expr NoFunctions .truth).wellFormedRoot noNames = true ∧
    (Expr.intGe (.variable "lower") (.integer (-1)) : Expr NoFunctions .truth).wellFormedRoot noNames = false ∧
    (Expr.intGe (.variable "lower") (.variable "upper") : Expr NoFunctions .truth).scoped [(.integer,"lower")] = false ∧
    (Expr.intGe (.variable "lower") (.variable "upper") : Expr NoFunctions .truth).scoped [(.integer,"lower"),(.integer,"upper")] = true := by decide +kernel

theorem conditional_true_children :
    (Expr.group (.conditionalTrue atom atom)).wellFormedRoot noNames = true ∧
    (Expr.andThen atom (.conditionalTrue atom atom)).wellFormedRoot noNames = false ∧
    (Expr.group (.conditionalTrue (.not (.orElse atom atom)) atom)).wellFormedRoot noNames = false ∧
    (Expr.group (.conditionalTrue atom (.not (.orElse atom atom)))).wellFormedRoot noNames = false ∧
    (Expr.conditionalTrue atom (.variable "other")).scoped [(.truth,"flag")] = false ∧
    (Expr.conditionalTrue (.variable "other") atom).scoped [(.truth,"flag")] = false ∧
    (Expr.conditionalTrue atom atom).scoped [(.truth,"flag")] = true := by decide +kernel

theorem conditional_true_meaning (calls : Calls Fn) (locals : Locals)
    (test yes : Expr Fn .truth) :
    (Expr.conditionalTrue test yes).eval calls locals =
      (if test.eval calls locals then yes.eval calls locals else true) := rfl

theorem integer_ge_meaning (calls : Calls Fn) (locals : Locals)
    (left right : Expr Fn .integer) :
    (Expr.intGe left right).eval calls locals =
      decide (left.eval calls locals ≥ right.eval calls locals) := rfl

theorem formal_children :
    (Expr.functionFormal (.number 1) (.number 2) (.scalarKind .integer) .full (.sub (.number 3) (.sub (.number 2) (.number 1))) : Expr NoFunctions .functionFormal).wellFormedRoot noNames = false ∧
    (Expr.functionFormal (.number 1) (.number 2) (.scalarKind .integer) .full (.variable "type_id") : Expr NoFunctions .functionFormal).scoped [] = false ∧
    (Expr.procedureFormal (.number 1) (.number 2) (.scalarKind .integer) .full (.number 0) (.variable "mode") : Expr NoFunctions .procedureFormal).scoped [] = false ∧
    (Expr.procedureFormal (.number 1) (.number 2) (.scalarKind .integer) .full (.number 0) (.mode .output) : Expr NoFunctions .procedureFormal).wellFormedRoot noNames = true := by decide +kernel

theorem direct_array_rendering :
    (Expr.index .actual (.variable "actuals") (.number 1) : Expr NoFunctions .packageActual).render noNames = ["actuals", "(", "1", ")"] ∧
    (Expr.index .stateBit (.variable "reads") (.number 2) : Expr NoFunctions .truth).render noNames = ["reads", "(", "2", ")"] ∧
    (Expr.index .formal (.variable "info") (.number 3) : Expr NoFunctions .formal).render noNames = ["info", ".", "parameters", "(", "3", ")"] := by decide +kernel

/-- Native procedure records place Type_Id before Mode; the model fields have
the opposite constructor order. The typed aggregate preserves both explicitly. -/
theorem procedure_formal_fields (calls : Calls Fn) (locals : Locals)
    (first after typeId : Expr Fn .number) (kind : Expr Fn .scalarKind)
    (bounds : Expr Fn .interval) (mode : Expr Fn .mode) :
    ((Expr.procedureFormal first after kind bounds typeId mode).eval calls locals).typeId = typeId.eval calls locals ∧
    ((Expr.procedureFormal first after kind bounds typeId mode).eval calls locals).mode = mode.eval calls locals := ⟨rfl,rfl⟩

theorem fixed_array_initialization (calls : Calls Fn) (locals : Locals) :
    (Expr.emptyActuals.eval calls locals).length = PackageBindings.maxFormals ∧
    (Expr.emptySeen.eval calls locals).length = PackageBindings.maxFormals := by
  change (List.replicate PackageBindings.maxFormals ({} : ApplicationPackages.PackageActual)).length = _ ∧
    (List.replicate PackageBindings.maxFormals false).length = _
  exact ⟨List.length_replicate .., List.length_replicate ..⟩

theorem fixed_array_writes_keep_capacity
    (actuals : List ApplicationPackages.PackageActual) (seen : List Bool)
    (index : Nat) (item : ApplicationPackages.PackageActual) (flag : Bool) :
    (Index.actual.set actuals index item).length = actuals.length ∧
    (Index.seen.set seen index flag).length = seen.length := by
  simp [Index.set]


theorem membership_and_interval_equality_children :
    (Expr.inRange (.variable "cursor") (.number 1) (.add (.sourceLast (.variable "text")) (.number 1)) : Expr NoFunctions .truth).wellFormedRoot noNames = true ∧
    (Expr.not (.inRange (.variable "cursor") (.number 1) (.number 2)) : Expr NoFunctions .truth).wellFormedRoot noNames = false ∧
    (Expr.inRange (.variable "cursor") (.number 1) (.variable "last") : Expr NoFunctions .truth).scoped [(.number, "cursor")] = false ∧
    (Expr.intervalEq .empty .full : Expr NoFunctions .truth).wellFormedRoot noNames = true ∧
    (Expr.intervalEq (.ite (.truth true) .empty .full) .full : Expr NoFunctions .truth).wellFormedRoot noNames = false := by decide +kernel

theorem storage_range_scope_and_children :
    (Expr.forAllFlowValues "i" (.variable "facts") (.le (.variable "i") (.property .flowCount (.variable "facts"))) : Expr NoFunctions .truth).scoped [(.activeFlow, "facts")] = true ∧
    (Expr.forAllFlowValues "i" (.variable "facts") (.variable "i") : Expr NoFunctions .truth).scoped [(.activeFlow, "facts"), (.truth, "i")] = false ∧
    (Expr.forAllActuals "i" (.variable "actuals") (.truth true) : Expr NoFunctions .truth).scoped [] = false ∧
    (Expr.forAllActuals "i" (.group (.variable "actuals")) (.truth true) : Expr NoFunctions .truth).wellFormedRoot noNames = false ∧
    (Expr.forAllActuals "i" (.variable "actuals") (.not (.orElse atom atom)) : Expr NoFunctions .truth).wellFormedRoot noNames = false ∧
    (Expr.forAllActuals "i" (.variable "actuals") (.truth true) : Expr NoFunctions .truth).wellFormedRoot noNames = true := by decide +kernel

theorem storage_range_rendering :
    (Expr.forAllFlowValues "i" (.variable "facts") (.truth true) : Expr NoFunctions .truth).render noNames =
      ["for", "all", "i", "in", "facts", ".", "values", "'", "range", "=>", "true"] ∧
    (Expr.forAllActuals "a" (.variable "actuals") (.truth true) : Expr NoFunctions .truth).render noNames =
      ["for", "all", "a", "in", "actuals", "'", "range", "=>", "true"] := by decide +kernel

theorem flow_values_quantifier (calls : Calls Fn) (locals : Locals) (name : String)
    (facts : Expr Fn .activeFlow) (body : Expr Fn .truth) :
    (Expr.forAllFlowValues name facts body).eval calls locals = true ↔
      ∀ index, 0 < index → index ≤ (facts.eval calls locals).count →
        body.eval calls (locals.set .number name index) = true := by
  change (List.range (facts.eval calls locals).count).all
    (fun offset => body.eval calls (locals.set .number name (offset + 1))) = true ↔ _
  simp only [List.all_eq_true, List.mem_range]
  constructor
  · intro checked index positive bounded
    simpa only [Nat.sub_add_cancel positive] using checked (index - 1) (by omega)
  · intro checked index bounded
    exact checked (index + 1) (by omega) (by omega)

/-- Package_Actual_Array has the full static Formal_Index domain. A shorter
mathematical list does not shorten the source quantifier. Native representation
separately requires its storage length to equal maxFormals. -/
theorem actuals_quantifier (calls : Calls Fn) (locals : Locals) (name : String)
    (actuals : Expr Fn .packageActuals) (body : Expr Fn .truth) :
    (Expr.forAllActuals name actuals body).eval calls locals = true ↔
      ∀ index, 0 < index → index ≤ PackageBindings.maxFormals →
        body.eval calls (locals.set .number name index) = true := by
  change (List.range PackageBindings.maxFormals).all
    (fun offset => body.eval calls (locals.set .number name (offset + 1))) = true ↔ _
  simp only [List.all_eq_true, List.mem_range]
  constructor
  · intro checked index positive bounded
    simpa only [Nat.sub_add_cancel positive] using checked (index - 1) (by omega)
  · intro checked index bounded
    exact checked (index + 1) (by omega) (by omega)

theorem actuals_native_storage (calls : Calls Fn) (locals : Locals) (name : String)
    (actuals : Expr Fn .packageActuals) (body : Expr Fn .truth)
    (allocated : (actuals.eval calls locals).length = PackageBindings.maxFormals) :
    (Expr.forAllActuals name actuals body).eval calls locals =
      (List.range (actuals.eval calls locals).length).all
        (fun offset => body.eval calls (locals.set .number name (offset + 1))) := by
  rw [allocated]
  rfl

end StructuralControls
end Silver.ApplicationNative
