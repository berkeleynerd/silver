module

public import Silver.ApplicationPackageMainInitialization

@[expose] public section

/-! Raw inline Integer range endpoints in Main and its local callables.
The inventories retain each declaration's actual scalar/array scope and source
reader equations. Their complete arithmetic discharge is a separate result;
normalized initializer ranges alone do not enumerate these obligations. -/
namespace Silver.ApplicationPackageScalarHeaders
open Compose Compose.Expressions Predicate ApplicationPackageInitializers

/-- Optional constraint syntax with the original array table. This contains
reader equations and raw sourceAt, without an inferred-range or checker field. -/
inductive RangeSyntaxAt (text : Source) (names : ScalarExpression.Environment)
    (arrays : ArrayBindings.Table) (position : Nat) (base : Integer.Interval) :
    ScalarConstraintResult → List Integer.Expr → Prop
  | absent (missing : fixedAfter text position "range" true = 0) :
      RangeSyntaxAt text names arrays position base ⟨position, base⟩ []
  | present {low high : Integer.Expr} {lower upper : ScalarExpression.Result}
      (start : fixedAfter text position "range" true ≠ 0)
      (lowRead : ScalarExpression.ArrayGrammar.read text (fixedAfter text position "range" true) names arrays = lower)
      (lowSource : ScalarExpression.ArrayGrammar.SourceAt text names arrays 0 0 .allElements true
        (fixedAfter text position "range" true) ⟨lower.after, low⟩)
      (delimiter : fixedAfter text lower.after ".." false ≠ 0)
      (highRead : ScalarExpression.ArrayGrammar.read text (fixedAfter text lower.after ".." false) names arrays = upper)
      (highSource : ScalarExpression.ArrayGrammar.SourceAt text names arrays 0 0 .allElements true
        (fixedAfter text lower.after ".." false) ⟨upper.after, high⟩) :
      RangeSyntaxAt text names arrays position base
        ⟨upper.after, ⟨lower.bounds.lower, upper.bounds.lower⟩⟩ [low, high]

def rangeObligations (names : ScalarExpression.Environment) (arrays : ArrayBindings.Table)
    (expressions : List Integer.Expr) : List Integer.Obligation :=
  expressions.flatMap fun expression => expression.obligations
    (ArrayBindings.viewRanges arrays.items [] false (ScalarExpression.ranges names))

theorem constraint_inventory {text : Source} {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {position : Nat} {base : Integer.Interval}
    {result : ScalarConstraintResult}
    (reading : ScalarConstraintAt (arrays := arrays) text names position base result) :
    ∃ expressions, RangeSyntaxAt text names arrays position base result expressions ∧
      Integer.discharged (rangeObligations names arrays expressions) = true := by
  cases reading with
  | absent missing => exact ⟨[], .absent missing, rfl⟩
  | @present low high lower upper start lowRead delimiter highRead _ _ _ _ _ _ _ =>
    refine ⟨[low, high], .present start (ScalarExpression.ArrayGrammar.read_complete lowRead)
      lowRead.source delimiter (ScalarExpression.ArrayGrammar.read_complete highRead) highRead.source, ?_⟩
    simp only [rangeObligations, List.flatMap_cons, List.flatMap_nil, List.append_nil,
      Integer.discharged_append, Integer.Expr.obligations_discharge lowRead.inferred,
      Integer.Expr.obligations_discharge highRead.inferred, Bool.and_self]

structure Header where
  state : ParserState
  expressions : List Integer.Expr

def Header.SourceAt (header : Header) (text : Source) (state : ParserState) : Prop :=
  header.state = state ∧
    RangeSyntaxAt text state.scalarNames state.arrayNames.table
      (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).after
      (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).bounds
      (scalarDeclarationParts text state).constraint header.expressions

def Header.obligations (header : Header) : List Integer.Obligation :=
  rangeObligations header.state.scalarNames header.state.arrayNames.table header.expressions

def obligations (headers : List Header) : List Integer.Obligation :=
  headers.flatMap Header.obligations

theorem obligations_append (first rest : List Header) :
    obligations (first ++ rest) = obligations first ++ obligations rest := List.flatMap_append

theorem declaration_inventory {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration}
    (reading : ScalarDeclarationAt text arguments state declaration next) :
    ∃ header : Header, header.SourceAt text state ∧ Integer.discharged header.obligations = true := by
  cases reading with
  | declaration parts _ constraint _ =>
    obtain ⟨expressions, sourceAt, discharged⟩ := constraint_inventory constraint.constraint
    refine ⟨⟨_, expressions⟩, ⟨rfl, ?_⟩, discharged⟩
    simpa only [parts] using sourceAt

/-- The complete scalar declaration projection, including every original
skip and every inline constraint at its own declaration-time frame. -/
inductive TopHeadersAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Declaration → ParserState → List Header → Prop
  | done {state} : state.position ≠ 0 → fixedAfter text state.position "begin" true ≠ 0 →
      TopHeadersAt text arguments state [] state []
  | callable {state final rest headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position ≠ 0 →
      TopHeadersAt text arguments (callableDeclarationAt text state arguments) rest final headers →
      TopHeadersAt text arguments state rest final headers
  | arrayType {state middle final rest headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      ArrayTypeDeclarationAt text arguments state middle →
      TopHeadersAt text arguments middle rest final headers →
      TopHeadersAt text arguments state rest final headers
  | string {state middle final declaration rest headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      TopHeadersAt text arguments middle rest final headers →
      TopHeadersAt text arguments state rest final headers
  | scalar {state middle final declaration rest header headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      Header.SourceAt header text state →
      TopHeadersAt text arguments middle rest final headers →
      TopHeadersAt text arguments state (declaration :: rest) final (header :: headers)
  | array {state middle final declaration rest headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      TopHeadersAt text arguments middle rest final headers →
      TopHeadersAt text arguments state rest final headers
  | booleanArray {state middle final rest headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanArrayDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      TopHeadersAt text arguments middle rest final headers →
      TopHeadersAt text arguments state rest final headers
  | subtype {state middle final rest headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      SubtypeDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      TopHeadersAt text arguments middle rest final headers →
      TopHeadersAt text arguments state rest final headers
  | boolean {state middle final rest headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      TopHeadersAt text arguments middle rest final headers →
      TopHeadersAt text arguments state rest final headers

theorem top_headers {text arguments entry declarations final}
    (source : ScalarDeclarationsAt text arguments entry declarations final) :
    ∃ headers, TopHeadersAt text arguments entry declarations final headers ∧
      Integer.discharged (obligations headers) = true := by
  induction source with
  | done present stop => exact ⟨[], .done present stop, rfl⟩
  | callable present more accepted _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .callable present more accepted sourceAt, checks⟩
  | arrayType present more noCallable first _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .arrayType present more noCallable first sourceAt, checks⟩
  | string present more noCallable noSubtype noScalar noArray noBoolean first noArrayType _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .string present more noCallable noSubtype noScalar noArray noBoolean first noArrayType sourceAt, checks⟩
  | scalar present more noCallable noSubtype first noArrayType _ ih =>
    obtain ⟨header, firstSource, firstChecks⟩ := declaration_inventory first
    obtain ⟨headers, sourceAt, checks⟩ := ih
    refine ⟨header :: headers, .scalar present more noCallable noSubtype first noArrayType firstSource sourceAt, ?_⟩
    change Integer.discharged (header.obligations ++ obligations headers) = true
    rw [Integer.discharged_append, firstChecks, checks]
    rfl
  | array present more noCallable noSubtype noScalar first noArrayType _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .array present more noCallable noSubtype noScalar first noArrayType sourceAt, checks⟩
  | booleanArray present more noCallable noSubtype noScalar first noArrayType _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .booleanArray present more noCallable noSubtype noScalar first noArrayType sourceAt, checks⟩
  | subtype present more noCallable first noArrayType _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .subtype present more noCallable first noArrayType sourceAt, checks⟩
  | boolean present more noCallable noSubtype noScalar noArray first noArrayType _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .boolean present more noCallable noSubtype noScalar noArray first noArrayType sourceAt, checks⟩

/-- Callable-local declaration order and all original initializer syntax are
retained independently of the newly listed raw constraint endpoints. -/
inductive LocalHeadersAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Declaration → List BooleanDeclaration →
      List Integer.Obligation → List Predicate.Obligation → ParserState → List Header → Prop
  | done {state} : state.position ≠ 0 → fixedAfter text state.position "begin" true ≠ 0 →
      LocalHeadersAt text arguments state [] [] [] [] state []
  | integer {state middle final declaration integers booleans firstChecks checks booleanChecks header headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      ScalarDeclarationChecksAt text state declaration firstChecks →
      remainingAt text middle.position < remainingAt text state.position →
      Header.SourceAt header text state →
      LocalHeadersAt text arguments middle integers booleans checks booleanChecks final headers →
      LocalHeadersAt text arguments state (declaration :: integers) booleans
        (firstChecks ++ checks) booleanChecks final (header :: headers)
  | boolean {state middle final declaration integers booleans checks firstChecks booleanChecks headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      BooleanDeclarationChecksAt text state declaration firstChecks →
      remainingAt text middle.position < remainingAt text state.position →
      LocalHeadersAt text arguments middle integers booleans checks booleanChecks final headers →
      LocalHeadersAt text arguments state integers (declaration :: booleans)
        checks (firstChecks ++ booleanChecks) final headers

theorem local_headers {text arguments entry integers booleans checks booleanChecks final}
    (source : FunctionLocalsAt text arguments entry integers booleans checks booleanChecks final) :
    ∃ headers, LocalHeadersAt text arguments entry integers booleans checks booleanChecks final headers ∧
      Integer.discharged (obligations headers) = true := by
  induction source with
  | done present stop => exact ⟨[], .done present stop, rfl⟩
  | integer present more first raw advanced _ ih =>
    obtain ⟨header, firstSource, firstChecks⟩ := declaration_inventory first
    obtain ⟨headers, sourceAt, checks⟩ := ih
    refine ⟨header :: headers, .integer present more first raw advanced firstSource sourceAt, ?_⟩
    change Integer.discharged (header.obligations ++ obligations headers) = true
    rw [Integer.discharged_append, firstChecks, checks]
    rfl
  | boolean present more noScalar first raw advanced _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .boolean present more noScalar first raw advanced sourceAt, checks⟩

structure FunctionHeadersAt (text : Source) (state : ParserState) (arguments : Bool)
    (definition : ScalarFunctions.Definition) (headers : List Header) : Prop where
  original : FunctionDeclarationSource text state arguments definition
  locals : LocalHeadersAt text arguments (functionHeaderFrame text state arguments)
    definition.integers definition.booleans definition.initializerChecks definition.booleanInitializerChecks
    (functionLocals text (functionHeaderFrame text state arguments) arguments) headers

structure ProcedureHeadersAt (text : Source) (state : ParserState) (arguments : Bool)
    (definition : ScalarProcedures.Definition) (headers : List Header) : Prop where
  original : ProcedureDeclarationSource text state arguments definition
  locals : LocalHeadersAt text arguments (procedureHeaderFrame text state arguments)
    definition.integers definition.booleans definition.initializerChecks definition.booleanInitializerChecks
    (functionLocals text (procedureHeaderFrame text state arguments) arguments) headers

theorem function_headers {text state arguments definition}
    (source : FunctionDeclarationSource text state arguments definition) :
    ∃ headers, FunctionHeadersAt text state arguments definition headers ∧
      Integer.discharged (obligations headers) = true := by
  have original := source
  cases source with
  | parsed _ body =>
    cases body with
    | parsed locals _ _ _ _ =>
      obtain ⟨headers, sourceAt, checks⟩ := local_headers locals
      exact ⟨headers, ⟨original, sourceAt⟩, checks⟩

theorem procedure_headers {text state arguments definition}
    (source : ProcedureDeclarationSource text state arguments definition) :
    ∃ headers, ProcedureHeadersAt text state arguments definition headers ∧
      Integer.discharged (obligations headers) = true := by
  have original := source
  cases source with
  | parsed _ body =>
    cases body with
    | parsed initialized _ =>
      obtain ⟨headers, sourceAt, checks⟩ := local_headers initialized.locals
      exact ⟨headers, ⟨original, sourceAt⟩, checks⟩

/-- Every declared local callable contributes its full local-header list,
whether or not any runtime path calls it. Noncallables retain their source step. -/
inductive CallableHeadersAt (text : Source) (arguments : Bool) :
    ParserState → List ScalarFunctions.Definition → List ScalarProcedures.Definition →
      ParserState → List Header → Prop
  | done {state} : state.position ≠ 0 → fixedAfter text state.position "begin" true ≠ 0 →
      CallableHeadersAt text arguments state [] [] state []
  | function {state final definition functions procedures first rest} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      FunctionHeadersAt text state arguments definition first →
      CallableHeadersAt text arguments (functionDeclarationAt text state arguments) functions procedures final rest →
      CallableHeadersAt text arguments state (definition :: functions) procedures final (first ++ rest)
  | procedure {state final definition functions procedures first rest} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (functionDeclarationAt text state arguments).position = 0 →
      ProcedureHeadersAt text state arguments definition first →
      CallableHeadersAt text arguments (procedureDeclarationAt text state arguments) functions procedures final rest →
      CallableHeadersAt text arguments state functions (definition :: procedures) final (first ++ rest)
  | other {state final functions procedures headers} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (functionDeclarationAt text state arguments).position = 0 →
      (procedureDeclarationAt text state arguments).position = 0 →
      (declarationAt text state arguments).position ≠ 0 →
      CallableHeadersAt text arguments (declarationAt text state arguments) functions procedures final headers →
      CallableHeadersAt text arguments state functions procedures final headers

theorem callable_headers {text arguments entry functions procedures final}
    (source : MixedDeclarationsAt text arguments entry functions procedures final) :
    ∃ headers, CallableHeadersAt text arguments entry functions procedures final headers ∧
      Integer.discharged (obligations headers) = true := by
  induction source with
  | done present stop => exact ⟨[], .done present stop, rfl⟩
  | function present more first _ ih =>
    obtain ⟨front, firstSource, firstChecks⟩ := function_headers first
    obtain ⟨headers, sourceAt, checks⟩ := ih
    refine ⟨front ++ headers, .function present more firstSource sourceAt, ?_⟩
    simp only [obligations_append, Integer.discharged_append, firstChecks, checks, Bool.and_self]
  | procedure present more noFunction first _ ih =>
    obtain ⟨front, firstSource, firstChecks⟩ := procedure_headers first
    obtain ⟨headers, sourceAt, checks⟩ := ih
    refine ⟨front ++ headers, .procedure present more noFunction firstSource sourceAt, ?_⟩
    simp only [obligations_append, Integer.discharged_append, firstChecks, checks, Bool.and_self]
  | other present more noFunction noProcedure accepted _ ih =>
    obtain ⟨headers, sourceAt, checks⟩ := ih
    exact ⟨headers, .other present more noFunction noProcedure accepted sourceAt, checks⟩

structure MainHeaders where
  top : List Header
  callables : List Header

def MainHeaders.SourceAt (headers : MainHeaders) {text arguments entry final inventory}
    (_original : MainInventory.SourceAt text arguments entry final inventory) : Prop :=
  TopHeadersAt text arguments entry inventory.integers final headers.top ∧
    CallableHeadersAt text arguments entry inventory.functions inventory.procedures final headers.callables

def MainHeaders.obligations (headers : MainHeaders) : List Integer.Obligation :=
  ApplicationPackageScalarHeaders.obligations headers.top ++
    ApplicationPackageScalarHeaders.obligations headers.callables

/-- Construct both source inventories from the original Main declaration
history and derive their complete raw arithmetic discharge separately. -/
theorem main_headers {text arguments entry final inventory}
    (original : MainInventory.SourceAt text arguments entry final inventory) :
    ∃ headers : MainHeaders, headers.SourceAt original ∧
      Integer.discharged headers.obligations = true := by
  obtain ⟨top, topSource, topChecks⟩ := top_headers original.integers
  obtain ⟨callables, callableSource, callableChecks⟩ := callable_headers original.callables
  refine ⟨⟨top, callables⟩, ⟨topSource, callableSource⟩, ?_⟩
  simp only [MainHeaders.obligations, Integer.discharged_append, topChecks, callableChecks, Bool.and_self]

end Silver.ApplicationPackageScalarHeaders
