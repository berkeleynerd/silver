module

public import Silver.ScalarExpressionEnvironment
public import Silver.SourceDeclarations
public import Silver.ScalarExpressionSpecCertificate

@[expose] public section

/-! The fixed array representation of scalar environments and the exact typed
record expression used by Append. The unused array suffix is never interpreted
as active bindings. -/
namespace Silver.ScalarExpression.EnvironmentSourceBridge
open Silver.SourceBridge

structure Storage where
  count : Nat
  items : Nat → Binding

def Storage.active (names : Storage) : Environment :=
  List.ofFn (fun index : Fin names.count => names.items (index.val + 1))

def Storage.extend (names : Storage) (item : Binding) : Storage :=
  ⟨names.count + 1, fun index => if index = names.count + 1 then item else names.items index⟩

theorem Storage.active_length (names : Storage) : names.active.length = names.count := by
  simp [active]

theorem Storage.extend_active (names : Storage) (item : Binding) :
    (names.extend item).active = names.active ++ [item] := by
  simp only [active, extend]
  rw [List.ofFn_succ_last]
  congr 1
  · apply congrArg List.ofFn
    funext index
    have different : index.val ≠ names.count := Nat.ne_of_lt index.isLt
    simp [different]
  · simp [Fin.val_last]

inductive CountExpr | count | one | add (left right : CountExpr)
  deriving DecidableEq

def CountExpr.eval (names : Storage) : CountExpr → Nat
  | .count => names.count | .one => 1
  | .add left right => left.eval names + right.eval names

def CountExpr.render : CountExpr → List String
  | .count => ["names", ".", "count"] | .one => ["1"]
  | .add left right => left.render ++ ["+"] ++ right.render

inductive ItemsExpr | items | update (base : ItemsExpr) (index : CountExpr)
  deriving DecidableEq

def ItemsExpr.eval (names : Storage) (item : Binding) : ItemsExpr → Nat → Binding
  | .items => names.items
  | .update base index => fun key =>
      if key = index.eval names then item else base.eval names item key

def ItemsExpr.render : ItemsExpr → List String
  | .items => ["names", ".", "items"]
  | .update base index => ["("] ++ base.render ++ ["with", "delta"] ++
      index.render ++ ["=>", "item", ")"]

structure AppendExpr where
  count : CountExpr
  items : ItemsExpr
  deriving DecidableEq

def AppendExpr.eval (tree : AppendExpr) (names : Storage) (item : Binding) : Storage :=
  ⟨tree.count.eval names, tree.items.eval names item⟩

def AppendExpr.render (tree : AppendExpr) : List String :=
  ["(", "count", "=>"] ++ tree.count.render ++ [",", "items", "=>"] ++ tree.items.render ++ [")"]

def appendBody : AppendExpr :=
  ⟨.add .count .one, .update .items (.add .count .one)⟩

theorem append_body_meaning (names : Storage) (item : Binding) :
    (appendBody.eval names item).active = names.active ++ [item] :=
  Storage.extend_active names item

theorem append_count_bounded (names : Storage) (item : Binding)
    (space : names.count < maxBindings) :
    (appendBody.eval names item).count ≤ maxBindings := by
  change names.count + 1 ≤ maxBindings
  omega

/-- The source's record delta replaces only Bounds. Staticness, visibility,
mutability and the declared subtype are retained. -/
inductive BindingBoundsExpr
  | current | declared
  | ifMutable (yes no : BindingBoundsExpr)
  deriving DecidableEq

def BindingBoundsExpr.eval (item : Binding) : BindingBoundsExpr → Integer.Interval
  | .current => item.bounds
  | .declared => item.declaredBounds
  | .ifMutable yes no => if item.mutable then yes.eval item else no.eval item

def BindingBoundsExpr.render : BindingBoundsExpr → List String
  | .current => ["item", ".", "bounds"]
  | .declared => ["item", ".", "declared_bounds"]
  | .ifMutable yes no => ["(", "if", "item", ".", "mutable", "then"] ++
      yes.render ++ ["else"] ++ no.render ++ [")"]

structure BodyBindingExpr where
  bounds : BindingBoundsExpr
  deriving DecidableEq

def BodyBindingExpr.eval (tree : BodyBindingExpr) (item : Binding) : Binding :=
  {item with bounds := tree.bounds.eval item}

def BodyBindingExpr.render (tree : BodyBindingExpr) : List String :=
  ["item", "with", "delta", "bounds", "=>"] ++ tree.bounds.render

def bodyBindingBody : BodyBindingExpr := ⟨.ifMutable .declared .current⟩

theorem body_binding_meaning (item : Binding) :
    bodyBindingBody.eval item = bodyBinding item := rfl

/-- One assignment in the finite native Binding_Index loop. The input array
is read at Index; only the result array's selected cell is overwritten. -/
def Storage.bodyStep (original result : Storage) (index : Nat) : Storage :=
  {result with items := fun key =>
    if key = index then bodyBindingBody.eval (original.items index) else result.items key}

def Storage.bodyLoop (original : Storage) : Nat → Storage
  | 0 => original
  | count + 1 => original.bodyStep (original.bodyLoop count) (count + 1)

theorem Storage.bodyLoop_count (original : Storage) (count : Nat) :
    (original.bodyLoop count).count = original.count := by
  induction count with
  | zero => rfl
  | succ count ih => exact ih

theorem Storage.bodyLoop_items (original : Storage) (count index : Nat) :
    (original.bodyLoop count).items index =
      if 1 ≤ index ∧ index ≤ count then bodyBinding (original.items index)
      else original.items index := by
  induction count with
  | zero =>
    have absent : ¬ (1 ≤ index ∧ index ≤ 0) := by omega
    simp only [bodyLoop, absent, ↓reduceIte]
  | succ count ih =>
    simp only [bodyLoop, bodyStep, body_binding_meaning]
    by_cases last : index = count + 1
    · subst index
      simp
    · rw [ite_eq_right last, ih]
      have same : (1 ≤ index ∧ index ≤ count + 1) ↔ (1 ≤ index ∧ index ≤ count) := by omega
      simp only [same]

theorem Storage.bodyLoop_active (original : Storage) (bound : original.count ≤ maxBindings) :
    (original.bodyLoop maxBindings).active = bodyEnvironment original.active := by
  simp only [Storage.active, bodyEnvironment, List.map_ofFn]
  have count := original.bodyLoop_count maxBindings
  generalize currentDef : original.bodyLoop maxBindings = current at count ⊢
  cases current with
  | mk currentCount currentItems =>
    dsimp only at count
    subst currentCount
    apply congrArg List.ofFn
    funext index
    have mapped := original.bodyLoop_items maxBindings (index.val + 1)
    rw [currentDef] at mapped
    dsimp only at mapped
    have inside : 1 ≤ index.val + 1 ∧ index.val + 1 ≤ maxBindings := by
      have indexBound : index.val < original.count := index.isLt
      omega
    rw [ite_eq_left inside] at mapped
    simpa only [Function.comp_apply] using mapped

/-- Native full-array postcondition: the verified loop maps even inactive
slots, while the language model observes exactly the active prefix. -/
structure InterpretedBodyEnvironment (transform : Storage → Storage) : Prop where
  count : ∀ names, (transform names).count = names.count
  items : ∀ names index, 1 ≤ index → index ≤ maxBindings →
    (transform names).items index = bodyBindingBody.eval (names.items index)

theorem model_bodyEnvironment_interpreted :
    InterpretedBodyEnvironment (fun names => names.bodyLoop maxBindings) where
  count names := names.bodyLoop_count maxBindings
  items names index positive bounded := by
    rw [names.bodyLoop_items maxBindings index, ite_eq_left ⟨positive, bounded⟩]
    rfl

theorem interpreted_bodyEnvironment (transform : Storage → Storage)
    (source : InterpretedBodyEnvironment transform) (names : Storage)
    (bound : names.count ≤ maxBindings) :
    (transform names).active = bodyEnvironment names.active := by
  simp only [Storage.active, bodyEnvironment, List.map_ofFn]
  have count := source.count names
  generalize currentDef : transform names = current at count ⊢
  cases current with
  | mk currentCount currentItems =>
    dsimp only at count
    subst currentCount
    apply congrArg List.ofFn
    funext index
    have mapped := source.items names (index.val + 1) (by omega)
      (by have indexBound : index.val < names.count := index.isLt; omega)
    rw [currentDef] at mapped
    exact mapped

/-- Expression functions may put their contract after the closing expression.
Keep that tail as part of the unique extracted declaration. -/
def postfixExpressionBodies (name : String) : List String → List (List String × List String)
  | [] => []
  | "function" :: actual :: tokens =>
      let later := postfixExpressionBodies name (actual :: tokens)
      if actual == name then
        match tokens.dropWhile (· != "return") with
        | "return" :: _resultType :: "is" :: "(" :: expression =>
            match Source.balanced 1 expression with
            | some (body, "with" :: tail) =>
                match Source.declarationEnd 0 tail with
                | some contract => (body, "with" :: contract) :: later
                | none => later
            | _ => later
        | _ => later
      else later
  | _ :: tokens => postfixExpressionBodies name tokens

def postfixExpressionBody (name : String) (tokens : List String) : Option (List String × List String) :=
  match postfixExpressionBodies name tokens with
  | [body] => some body
  | _ => none

structure Checked (tokens : List String) : Prop where
  bodyBinding : Source.expressionBody "body_binding" tokens = some bodyBindingBody.render
  bodyBindingHeader : functionHeader "body_binding" "is" tokens = some
    (expectedTokens "(Item : Binding) return Binding")
  bodyEnvironmentHeader : functionHeader "body_environment" ";" tokens = some
    (expectedTokens "(Names : Environment) return Environment with Global => null, Post => Body_Environment'Result.Count = Names.Count and then (for all Index in Binding_Index => Body_Environment'Result.Items (Index) = Body_Binding (Names.Items (Index)))")
  body : postfixExpressionBody "append" tokens =
    some (appendBody.render, expectedTokens "with Pre => Names.Count < Max_Bindings")
  header : functionHeader "append" "is" tokens = some
    (expectedTokens "(Names : Environment; Item : Binding) return Environment")
  count : Lexical.SourceBridge.subtypeDeclaration "binding_count" tokens =
    some (expectedTokens "Natural range 0 .. Max_Bindings")
  index : Lexical.SourceBridge.subtypeDeclaration "binding_index" tokens =
    some (expectedTokens "Positive range 1 .. Max_Bindings")
  maximum : Source.declaration "max_bindings" tokens =
    some (expectedTokens "constant Positive := Max_Source_Length / 12")
  items : typeDeclaration "binding_array" tokens =
    some (expectedTokens "array (Binding_Index) of Binding")
  environment : Lexical.SourceBridge.recordDeclaration "environment" tokens =
    some (expectedTokens "record Count : Binding_Count; Items : Binding_Array; end record")

set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem actual_source_checked : Checked Source.scalarExpressionSpecTokens := by
  constructor <;> decide +kernel

/-- The checked native contract supplies Count and every finite Items result;
the independently proved loop model demonstrates the contract's exact mapping,
and the active-prefix theorem derives the language environment meaning. -/
theorem actual_body_environment_correspondence : Checked Source.scalarExpressionSpecTokens ∧
    ∀ transform, InterpretedBodyEnvironment transform → ∀ names,
      names.count ≤ maxBindings →
      (transform names).active = bodyEnvironment names.active :=
  ⟨actual_source_checked, interpreted_bodyEnvironment⟩

/-- The body equation is the typed interpretation of the checked record and
array update; the active-prefix conclusion is derived above. -/
structure InterpretedAppend (append : Storage → Binding → Storage) : Prop where
  equation : ∀ names item, names.count < maxBindings →
    append names item = appendBody.eval names item

theorem interpreted_append (append : Storage → Binding → Storage)
    (source : InterpretedAppend append) (names : Storage) (item : Binding)
    (space : names.count < maxBindings) :
    (append names item).active = names.active ++ [item] := by
  rw [source.equation names item space]
  exact append_body_meaning names item

end Silver.ScalarExpression.EnvironmentSourceBridge
