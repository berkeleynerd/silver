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
