module

public import Silver.PredicateFlowWidening
public import Silver.ScalarEnvironmentSourceBridge
public import Silver.SourceDeclarations

@[expose] public section

/-! Exact native scalar-flow contracts and their finite-storage projections.
The four helper contracts speak about native record fields, not equality to a
language model. Their typed right-hand sides retain the actual path calls,
interval calls, conditional tests and record update. The frontend interprets
these checked contracts together with the native proof of their implementations.
No statement below assumes that a helper returns the semantic flow. -/
namespace Silver.Predicate.FlowSourceBridge
open Silver.SourceBridge ScalarExpression

abbrev NameStorage := EnvironmentSourceBridge.Storage
abbrev FlowStorage := ActiveFlow.Storage

/-- Only fields read by these helpers. The full native context projects to this
record without discarding any scalar-name array slot. -/
structure Context where
  names : NameStorage
  declarations : Nat
  dynamicFirst : Nat

def Context.InRange (context : Context) : Prop := context.names.count ≤ maxBindings

def initialPath (arguments : Bool) : PathFacts.Context :=
  if arguments then PathFacts.Context.initial maxSourceLength
  else (PathFacts.Context.initial 0).assumeValid

/-- Already interpreted path/scalar library calls, kept arbitrary in the typed
contract evaluator. Their meanings are supplied by the existing library bridges. -/
structure Calls where
  initial : Bool → PathFacts.Context
  pathJoin : PathFacts.Context → PathFacts.Context → PathFacts.Context
  intervalJoin : Integer.Interval → Integer.Interval → Integer.Interval

def modelCalls : Calls := ⟨initialPath, PathFacts.Context.join, Integer.Interval.join⟩

structure CallsMeaning (calls : Calls) : Prop where
  initial : ∀ arguments, calls.initial arguments = initialPath arguments
  pathJoin : ∀ left right, calls.pathJoin left right = left.join right
  intervalJoin : ∀ left right, calls.intervalJoin left right = left.join right

theorem model_calls_meaning : CallsMeaning modelCalls := ⟨fun _ => rfl, fun _ _ => rfl, fun _ _ => rfl⟩

structure Locals where
  context : Context
  facts : FlowStorage
  left : FlowStorage
  right : FlowStorage
  index : Nat

inductive CountExpr | context | left
  deriving DecidableEq

def CountExpr.eval (locals : Locals) : CountExpr → Nat
  | .context => locals.context.names.count
  | .left => locals.left.count

def CountExpr.render : CountExpr → List String
  | .context => expectedTokens "Context.Scalar_Names.Count"
  | .left => expectedTokens "Left.Count"

inductive PathExpr
  | initial | old | left | right | join (left right : PathExpr)
  deriving DecidableEq

def PathExpr.eval (calls : Calls) (locals : Locals) : PathExpr → PathFacts.Context
  | .initial => calls.initial (decide (locals.context.dynamicFirst ≠ 0))
  | .old => locals.facts.path
  | .left => locals.left.path
  | .right => locals.right.path
  | .join first second => calls.pathJoin (first.eval calls locals) (second.eval calls locals)

def PathExpr.render : PathExpr → List String
  | .initial => expectedTokens "Paths.Initial (Context.Dynamic_First /= 0)"
  | .old => expectedTokens "Facts'Old.Path"
  | .left => expectedTokens "Left.Path"
  | .right => expectedTokens "Right.Path"
  | .join first second => ["paths", ".", "join", "("] ++ first.render ++ [","] ++ second.render ++ [")"]

inductive IntervalExpr
  | nameBounds | declared | old | left | right
  | join (left right : IntervalExpr)
  | ifMutable (yes no : IntervalExpr)
  deriving DecidableEq

def IntervalExpr.eval (calls : Calls) (locals : Locals) : IntervalExpr → Integer.Interval
  | .nameBounds => (locals.context.names.items locals.index).bounds
  | .declared => (locals.context.names.items locals.index).declaredBounds
  | .old => locals.facts.values locals.index
  | .left => locals.left.values locals.index
  | .right => locals.right.values locals.index
  | .join first second => calls.intervalJoin (first.eval calls locals) (second.eval calls locals)
  | .ifMutable yes no =>
      if (locals.context.names.items locals.index).mutable then yes.eval calls locals else no.eval calls locals

def IntervalExpr.render : IntervalExpr → List String
  | .nameBounds => expectedTokens "Context.Scalar_Names.Items (Index).Bounds"
  | .declared => expectedTokens "Context.Scalar_Names.Items (Index).Declared_Bounds"
  | .old => expectedTokens "Facts'Old.Values (Index)"
  | .left => expectedTokens "Left.Values (Index)"
  | .right => expectedTokens "Right.Values (Index)"
  | .join first second => ["scalars", ".", "join", "("] ++ first.render ++ [","] ++ second.render ++ [")"]
  | .ifMutable yes no => expectedTokens "(if Context.Scalar_Names.Items (Index).Mutable then" ++
      yes.render ++ ["else"] ++ no.render ++ [")"]

inductive ReadingExpr
  | original | withBounds | ifActiveRefinable (yes no : ReadingExpr)
  deriving DecidableEq

def ReadingExpr.eval (locals : Locals) : ReadingExpr → Binding
  | .original => locals.context.names.items locals.index
  | .withBounds => {locals.context.names.items locals.index with bounds := locals.facts.values locals.index}
  | .ifActiveRefinable yes no =>
      if locals.index ≤ locals.facts.count ∧
          ((locals.context.names.items locals.index).mutable = true ∨ locals.context.declarations < locals.index)
      then yes.eval locals else no.eval locals

def ReadingExpr.render : ReadingExpr → List String
  | .original => expectedTokens "Context.Scalar_Names.Items (Index)"
  | .withBounds => expectedTokens "(Context.Scalar_Names.Items (Index) with delta Bounds => Facts.Values (Index))"
  | .ifActiveRefinable yes no =>
      expectedTokens "(if Index <= Facts.Count and then (Context.Scalar_Names.Items (Index).Mutable or else Index > Context.Declaration_Count) then" ++
      yes.render ++ ["else"] ++ no.render ++ [")"]

def initialCount : CountExpr := .context
def initialPathExpr : PathExpr := .initial
def initialValue : IntervalExpr := .nameBounds
def joinedCount : CountExpr := .left
def joinedPath : PathExpr := .join .left .right
def joinedValue : IntervalExpr := .join .left .right
def widenedPath : PathExpr := .old
def widenedValue : IntervalExpr := .ifMutable .declared .old
def readingCount : CountExpr := .context
def readingItem : ReadingExpr := .ifActiveRefinable .withBounds .original

def unusedFlow : FlowStorage := ⟨0, PathFacts.Context.empty, fun _ => Integer.Interval.empty⟩
def unusedContext : Context := ⟨⟨0, fun _ => emptyBinding⟩, 0, 0⟩
def initialLocals (context : Context) (index : Nat := 0) : Locals :=
  ⟨context, unusedFlow, unusedFlow, unusedFlow, index⟩
def joinedLocals (left right : FlowStorage) (index : Nat := 0) : Locals :=
  ⟨unusedContext, unusedFlow, left, right, index⟩
def flowLocals (context : Context) (facts : FlowStorage) (index : Nat := 0) : Locals :=
  ⟨context, facts, unusedFlow, unusedFlow, index⟩

def initialStorage (calls : Calls) (context : Context) : FlowStorage :=
  ⟨initialCount.eval (initialLocals context), initialPathExpr.eval calls (initialLocals context),
    fun index => initialValue.eval calls (initialLocals context index)⟩

def joinedStorage (calls : Calls) (left right : FlowStorage) : FlowStorage :=
  ⟨joinedCount.eval (joinedLocals left right), joinedPath.eval calls (joinedLocals left right),
    fun index => joinedValue.eval calls (joinedLocals left right index)⟩

def widenedStorage (context : Context) (facts : FlowStorage) : FlowStorage :=
  ⟨facts.count, widenedPath.eval modelCalls (flowLocals context facts),
    fun index => widenedValue.eval modelCalls (flowLocals context facts index)⟩

def readingStorage (context : Context) (facts : FlowStorage) : NameStorage :=
  ⟨readingCount.eval (flowLocals context facts),
    fun index => readingItem.eval (flowLocals context facts index)⟩

/-- Native count types give the sole implicit domain restriction. Initial_Flow
has no Valid_Context or nonemptiness precondition. -/
structure InterpretedInitial (calls : Calls) (initial : Context → FlowStorage) : Prop where
  count : ∀ context, context.InRange → (initial context).count = initialCount.eval (initialLocals context)
  path : ∀ context, context.InRange → (initial context).path = initialPathExpr.eval calls (initialLocals context)
  values : ∀ context, context.InRange → ∀ index, 1 ≤ index → index ≤ (initial context).count →
    (initial context).values index = initialValue.eval calls (initialLocals context index)

structure InterpretedJoined (calls : Calls) (joined : FlowStorage → FlowStorage → FlowStorage) : Prop where
  count : ∀ left right, left.count ≤ maxBindings → left.count = right.count →
    (joined left right).count = joinedCount.eval (joinedLocals left right)
  path : ∀ left right, left.count ≤ maxBindings → left.count = right.count →
    (joined left right).path = joinedPath.eval calls (joinedLocals left right)
  values : ∀ left right, left.count ≤ maxBindings → left.count = right.count →
    ∀ index, 1 ≤ index → index ≤ (joined left right).count →
      (joined left right).values index = joinedValue.eval calls (joinedLocals left right index)

structure InterpretedReadingNames (reading : Context → FlowStorage → NameStorage) : Prop where
  count : ∀ context facts, context.InRange → facts.count = context.names.count →
    (reading context facts).count = readingCount.eval (flowLocals context facts)
  items : ∀ context facts, context.InRange → facts.count = context.names.count →
    ∀ index, 1 ≤ index → index ≤ maxBindings →
      (reading context facts).items index = readingItem.eval (flowLocals context facts index)

/-- The Count clause is the unchanged discriminant of the constrained in-out
object. The native body assigns only Path/Values components; the remaining two
clauses are exactly its postcondition, including the old-value branch. -/
structure InterpretedWidenInto (widen : Context → FlowStorage → FlowStorage) : Prop where
  count : ∀ context facts, context.InRange → facts.count = context.names.count →
    (widen context facts).count = facts.count
  path : ∀ context facts, context.InRange → facts.count = context.names.count →
    (widen context facts).path = widenedPath.eval modelCalls (flowLocals context facts)
  values : ∀ context facts, context.InRange → facts.count = context.names.count →
    ∀ index, 1 ≤ index → index ≤ (widen context facts).count →
      (widen context facts).values index = widenedValue.eval modelCalls (flowLocals context facts index)

theorem model_initial_interpreted (calls : Calls) : InterpretedInitial calls (initialStorage calls) :=
  ⟨fun _ _ => rfl, fun _ _ => rfl, fun _ _ _ _ _ => rfl⟩

theorem model_joined_interpreted (calls : Calls) : InterpretedJoined calls (joinedStorage calls) :=
  ⟨fun _ _ _ _ => rfl, fun _ _ _ _ => rfl, fun _ _ _ _ _ _ _ => rfl⟩

theorem model_reading_interpreted : InterpretedReadingNames readingStorage :=
  ⟨fun _ _ _ _ => rfl, fun _ _ _ _ _ _ _ => rfl⟩

theorem model_widen_interpreted : InterpretedWidenInto widenedStorage :=
  ⟨fun _ _ _ _ => rfl, fun _ _ _ _ => rfl, fun _ _ _ _ _ _ _ => rfl⟩

theorem active_name (names : NameStorage) (index : Nat)
    (positive : 0 < index) (bounded : index ≤ names.count) :
    binding names.active index = names.items index := by
  simp only [binding, EnvironmentSourceBridge.Storage.active, List.getD_eq_getElem?_getD,
    List.getElem?_ofFn, show index - 1 < names.count by omega, ↓reduceDIte, Option.getD_some]
  congr 1
  omega

theorem active_value (facts : FlowStorage) (index : Nat)
    (positive : 0 < index) (bounded : index ≤ facts.count) :
    facts.active.values.getD (index - 1) Integer.Interval.empty = facts.values index := by
  simp only [ActiveFlow.Storage.active, List.getD_eq_getElem?_getD, List.getElem?_ofFn,
    show index - 1 < facts.count by omega, ↓reduceDIte, Option.getD_some]
  congr 1
  omega

theorem initial_storage_active (calls : Calls) (meaning : CallsMeaning calls) (context : Context) :
    (initialStorage calls context).active =
      ActiveFlow.initial context.names.active (initialPath (decide (context.dynamicFirst ≠ 0))) := by
  simp only [initialStorage, initialCount, initialPathExpr, initialValue, CountExpr.eval,
    PathExpr.eval, IntervalExpr.eval, initialLocals, ActiveFlow.Storage.active,
    ActiveFlow.initial, EnvironmentSourceBridge.Storage.active, List.map_ofFn, meaning.initial]
  rfl

theorem activeFlow_ext {left right : ActiveFlow}
    (path : left.path = right.path) (values : left.values = right.values) : left = right := by
  cases left
  cases right
  simp_all

theorem joined_storage_active (calls : Calls) (meaning : CallsMeaning calls)
    (left right : FlowStorage) (same : left.count = right.count) :
    (joinedStorage calls left right).active = left.active.join right.active := by
  apply activeFlow_ext
  · exact meaning.pathJoin left.path right.path
  · apply List.ext_getElem
    · simp only [joinedStorage, joinedCount, CountExpr.eval, joinedLocals,
        ActiveFlow.Storage.active, ActiveFlow.join, List.length_ofFn, List.length_zipWith, same,
        Nat.min_self]
    · intro index firstBound secondBound
      have leftBound : index < left.count := by
        simpa only [joinedStorage, joinedCount, CountExpr.eval, joinedLocals,
          ActiveFlow.Storage.active, List.length_ofFn] using firstBound
      have rightBound : index < right.count := by omega
      simp only [joinedStorage, joinedCount, joinedValue, CountExpr.eval, IntervalExpr.eval,
        joinedLocals, ActiveFlow.Storage.active, ActiveFlow.join, List.getElem_ofFn,
        List.getElem_zipWith, meaning.intervalJoin]

theorem reading_storage_active (context : Context) (facts : FlowStorage)
    (same : facts.count = context.names.count) :
    (readingStorage context facts).active =
      ScalarMetadata.readingNames context.names.active context.declarations facts.active := by
  apply List.ext_getElem
  · simp [readingStorage, readingCount, CountExpr.eval, flowLocals,
      EnvironmentSourceBridge.Storage.active, ScalarMetadata.readingNames]
  · intro index firstBound secondBound
    have within : index < context.names.count := by
      simpa only [readingStorage, readingCount, CountExpr.eval, flowLocals,
        EnvironmentSourceBridge.Storage.active, List.length_ofFn] using firstBound
    have active : index + 1 ≤ facts.count := by omega
    have value : facts.active.values.getD index Integer.Interval.empty = facts.values (index + 1) := by
      simpa only [Nat.add_sub_cancel] using active_value facts (index + 1) (Nat.succ_pos _) active
    simp only [readingStorage, readingCount, readingItem, CountExpr.eval, ReadingExpr.eval,
      flowLocals, EnvironmentSourceBridge.Storage.active, ScalarMetadata.readingNames,
      List.getElem_ofFn, ScalarMetadata.readingBinding,
      value]
    simp only [active, true_and, Bool.or_eq_true, decide_eq_true_eq]

theorem widened_storage_active (context : Context) (facts : FlowStorage)
    (same : facts.count = context.names.count) :
    (widenedStorage context facts).active = ActiveFlow.widen context.names.active facts.active := by
  apply activeFlow_ext
  · rfl
  · apply List.ext_getElem
    · simp [widenedStorage, ActiveFlow.Storage.active, ActiveFlow.widen,
        EnvironmentSourceBridge.Storage.active, same]
    · intro index firstBound secondBound
      simp only [widenedStorage, widenedValue, IntervalExpr.eval, flowLocals,
        ActiveFlow.Storage.active, ActiveFlow.widen, EnvironmentSourceBridge.Storage.active,
        List.getElem_ofFn, List.getElem_zipWith]

theorem interpreted_initial (calls : Calls) (meaning : CallsMeaning calls)
    (initial : Context → FlowStorage) (source : InterpretedInitial calls initial)
    (context : Context) (legal : context.InRange) :
    (initial context).active =
      ActiveFlow.initial context.names.active (initialPath (decide (context.dynamicFirst ≠ 0))) := by
  apply Eq.trans (b := (initialStorage calls context).active)
  · apply ActiveFlow.Storage.active_ext
    · exact source.count context legal
    · exact source.path context legal
    · exact source.values context legal
  · exact initial_storage_active calls meaning context

theorem interpreted_joined (calls : Calls) (meaning : CallsMeaning calls)
    (joined : FlowStorage → FlowStorage → FlowStorage) (source : InterpretedJoined calls joined)
    (left right : FlowStorage) (legal : left.count ≤ maxBindings) (same : left.count = right.count) :
    (joined left right).active = left.active.join right.active := by
  apply Eq.trans (b := (joinedStorage calls left right).active)
  · apply ActiveFlow.Storage.active_ext
    · exact source.count left right legal same
    · exact source.path left right legal same
    · exact source.values left right legal same
  · exact joined_storage_active calls meaning left right same

theorem interpreted_readingNames (reading : Context → FlowStorage → NameStorage)
    (source : InterpretedReadingNames reading) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count) :
    (reading context facts).active =
      ScalarMetadata.readingNames context.names.active context.declarations facts.active := by
  apply Eq.trans (b := (readingStorage context facts).active)
  · have count := source.count context facts legal same
    change (reading context facts).count = context.names.count at count
    unfold EnvironmentSourceBridge.Storage.active
    generalize resultDef : reading context facts = result at count ⊢
    cases result with
    | mk resultCount resultItems =>
      dsimp only at count
      subst resultCount
      apply congrArg List.ofFn
      funext index
      have mapped := source.items context facts legal same (index.val + 1)
        (Nat.succ_pos _) (by
          have bounded : index.val < context.names.count := index.isLt
          exact Nat.le_trans (Nat.succ_le_of_lt bounded) legal)
      rw [resultDef] at mapped
      exact mapped
  · exact reading_storage_active context facts same

theorem interpreted_widenInto (widen : Context → FlowStorage → FlowStorage)
    (source : InterpretedWidenInto widen) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count) :
    (widen context facts).active = ActiveFlow.widen context.names.active facts.active := by
  apply Eq.trans (b := (widenedStorage context facts).active)
  · apply ActiveFlow.Storage.active_ext
    · exact source.count context facts legal same
    · exact source.path context facts legal same
    · exact source.values context facts legal same
  · exact widened_storage_active context facts same

theorem interpreted_reading_inactive (reading : Context → FlowStorage → NameStorage)
    (source : InterpretedReadingNames reading) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count)
    (index : Nat) (positive : 1 ≤ index) (bounded : index ≤ maxBindings)
    (inactive : facts.count < index) :
    (reading context facts).items index = context.names.items index := by
  rw [source.items context facts legal same index positive bounded]
  simp only [readingItem, ReadingExpr.eval, flowLocals, show ¬index ≤ facts.count by omega,
    false_and, ↓reduceIte]

theorem interpreted_reading_metadata (reading : Context → FlowStorage → NameStorage)
    (source : InterpretedReadingNames reading) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count)
    (index : Nat) (positive : 1 ≤ index) (bounded : index ≤ maxBindings) :
    let result := (reading context facts).items index
    let original := context.names.items index
    result.first = original.first ∧ result.after = original.after ∧
      result.isStatic = original.isStatic ∧ result.mutable = original.mutable ∧
      result.declaredBounds = original.declaredBounds := by
  dsimp only
  rw [source.items context facts legal same index positive bounded]
  simp only [readingItem, ReadingExpr.eval, flowLocals]
  split <;> exact ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem interpreted_reading_ranges (reading : Context → FlowStorage → NameStorage)
    (source : InterpretedReadingNames reading) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count)
    (compatible : ScalarMetadata.OverlayCompatible context.names.active context.declarations facts.active) :
    ScalarExpression.ranges (reading context facts).active = facts.active.model.scalars := by
  rw [interpreted_readingNames reading source context facts legal same]
  exact ScalarMetadata.readingNames_ranges compatible

theorem interpreted_reading_lookup (reading : Context → FlowStorage → NameStorage)
    (source : InterpretedReadingNames reading) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count)
    (text : Source) (first after : Nat) :
    lookup text (reading context facts).active first after = lookup text context.names.active first after := by
  rw [interpreted_readingNames reading source context facts legal same]
  exact ScalarMetadata.readingNames_lookup text context.names.active context.declarations facts.active first after

theorem interpreted_reading_staticness (reading : Context → FlowStorage → NameStorage)
    (source : InterpretedReadingNames reading) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count) :
    ScalarMetadata.staticness (reading context facts).active = ScalarMetadata.staticness context.names.active := by
  rw [interpreted_readingNames reading source context facts legal same]
  exact ScalarMetadata.readingNames_staticness ..

theorem interpreted_widen_model (widen : Context → FlowStorage → FlowStorage)
    (source : InterpretedWidenInto widen) (context : Context) (facts : FlowStorage)
    (legal : context.InRange) (same : facts.count = context.names.count)
    (ready : BodyReady context.names.active) :
    (widen context facts).active.model =
      ⟨facts.path, (ScalarMetadata.analysis context.names.active context.declarations).widen facts.active.model.scalars⟩ := by
  rw [interpreted_widenInto widen source context facts legal same]
  exact ActiveFlow.widen_model context.names.active context.declarations facts.active
    (by simpa only [ActiveFlow.Storage.active_count, EnvironmentSourceBridge.Storage.active_length] using same) ready

/-- Canonical finite-storage witnesses used by the mathematical native model.
Their inactive cells are merely witnesses; the arbitrary-native-array contracts
above still constrain every actual name slot and observe only active flow cells. -/
def ofNames (names : Environment) : NameStorage := ⟨names.length, binding names⟩

def ofFlow (facts : ActiveFlow) : FlowStorage :=
  ⟨facts.count, facts.path, fun index => facts.values.getD (index - 1) Integer.Interval.empty⟩

@[simp] theorem ofNames_count (names : Environment) : (ofNames names).count = names.length := rfl
@[simp] theorem ofFlow_count (facts : ActiveFlow) : (ofFlow facts).count = facts.count := rfl

@[simp] theorem ofNames_active (names : Environment) : (ofNames names).active = names := by
  apply List.ext_getElem
  · simp only [ofNames, EnvironmentSourceBridge.Storage.active, List.length_ofFn]
  · intro index leftBound rightBound
    simp only [ofNames, EnvironmentSourceBridge.Storage.active, List.getElem_ofFn,
      binding, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem rightBound, Option.getD_some]

@[simp] theorem ofFlow_active (facts : ActiveFlow) : (ofFlow facts).active = facts := by
  apply activeFlow_ext
  · rfl
  · apply List.ext_getElem
    · simp only [ofFlow, ActiveFlow.Storage.active, List.length_ofFn, ActiveFlow.count]
    · intro index leftBound rightBound
      simp only [ofFlow, ActiveFlow.Storage.active, List.getElem_ofFn, Nat.add_sub_cancel,
        List.getD_eq_getElem?_getD, List.getElem?_eq_getElem rightBound, Option.getD_some]

/-- Complete forward declarations. Typed RHS trees are inserted into the checked
postconditions, so changing a tested field, guard, old-value read or helper call
changes the very expression interpreted above. -/
def initialHeader : List String :=
  expectedTokens "(Context : Body_Context) return Scalar_Flow with Global => null, Post => Initial_Flow'Result.Count =" ++
  initialCount.render ++ expectedTokens "and then Initial_Flow'Result.Path =" ++ initialPathExpr.render ++
  expectedTokens "and then (for all Index in Initial_Flow'Result.Values'Range => Initial_Flow'Result.Values (Index) =" ++
  initialValue.render ++ [")"]

def joinedHeader : List String :=
  expectedTokens "(Left, Right : Scalar_Flow) return Scalar_Flow with Ghost => Static, Global => null, Pre => Left.Count = Right.Count, Post => Joined'Result.Count =" ++
  joinedCount.render ++ expectedTokens "and then Joined'Result.Path =" ++ joinedPath.render ++
  expectedTokens "and then (for all Index in Joined'Result.Values'Range => Joined'Result.Values (Index) =" ++
  joinedValue.render ++ [")"]

def widenedHeader : List String :=
  expectedTokens "(Context : Body_Context; Facts : in out Scalar_Flow) with Global => null, Pre => Facts.Count = Context.Scalar_Names.Count, Post => Facts.Path =" ++
  widenedPath.render ++ expectedTokens "and then (for all Index in Facts.Values'Range => Facts.Values (Index) =" ++
  widenedValue.render ++ [")"]

def readingHeader : List String :=
  expectedTokens "(Context : Body_Context; Facts : Scalar_Flow) return Scalar_Expressions.Environment with Ghost => Static, Global => null, Pre => Facts.Count = Context.Scalar_Names.Count, Post => Reading_Names'Result.Count =" ++
  readingCount.render ++ expectedTokens "and then (for all Index in Scalar_Expressions.Binding_Index => Reading_Names'Result.Items (Index) =" ++
  readingItem.render ++ [")"]

structure Checked (tokens : List String) : Prop where
  initial : functionHeader "initial_flow" ";" tokens = some initialHeader
  joined : functionHeader "joined" ";" tokens = some joinedHeader
  widened : procedureHeader "widen_into" ";" tokens = some widenedHeader
  reading : functionHeader "reading_names" ";" tokens = some readingHeader
  vector : typeDeclaration "interval_vector" tokens =
    some (expectedTokens "array (Positive range <>) of Scalars.Interval")
  flow : Lexical.SourceBridge.discriminatedRecordDeclaration "scalar_flow" tokens =
    some (expectedTokens "(Count : Scalar_Expressions.Binding_Count) is record Path : Paths.Context; Values : Interval_Vector (1 .. Count); end record")

/-- Source-selected theorem bundle. The caller supplies the actual-token check,
the independently verified native contracts and meanings of the three library
calls; the projection conclusions are consequences, not extra premises. -/
theorem checked_correspondence (tokens : List String) (checked : Checked tokens)
    (calls : Calls) (meaning : CallsMeaning calls)
    (initial : Context → FlowStorage) (initialSource : InterpretedInitial calls initial)
    (joined : FlowStorage → FlowStorage → FlowStorage) (joinedSource : InterpretedJoined calls joined)
    (reading : Context → FlowStorage → NameStorage) (readingSource : InterpretedReadingNames reading)
    (widen : Context → FlowStorage → FlowStorage) (widenSource : InterpretedWidenInto widen) :
    Checked tokens ∧
    (∀ context, context.InRange → (initial context).active =
      ActiveFlow.initial context.names.active (initialPath (decide (context.dynamicFirst ≠ 0)))) ∧
    (∀ left right, left.count ≤ maxBindings → left.count = right.count →
      (joined left right).active = left.active.join right.active) ∧
    (∀ context facts, context.InRange → facts.count = context.names.count →
      (reading context facts).active =
        ScalarMetadata.readingNames context.names.active context.declarations facts.active) ∧
    (∀ context facts, context.InRange → facts.count = context.names.count →
      (widen context facts).active = ActiveFlow.widen context.names.active facts.active) :=
  ⟨checked, interpreted_initial calls meaning initial initialSource,
    interpreted_joined calls meaning joined joinedSource,
    interpreted_readingNames reading readingSource, interpreted_widenInto widen widenSource⟩

end Silver.Predicate.FlowSourceBridge
