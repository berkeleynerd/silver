module

public import Silver.ApplicationStateValidityTables
public import Silver.ComposeModelCalls

@[expose] public section

namespace Silver.ApplicationPackageFrames.ValidityTables.Primitives
open ApplicationNative Compose

inductive NoCalls : Ty → Type
def noCalls : Calls NoCalls := fun _ value => nomatch value
def noNames : FunctionNames NoCalls := fun value => nomatch value

def nameStateBody : Expr NoCalls .truth :=
  let first : Expr NoCalls .number := .variable "first"
  let after : Expr NoCalls .number := .variable "after"
  .orElse (.group (.andThen (.eq first (.number 0)) (.eq after (.number 0))))
    (.group (.andThen (.andThen (.gt first (.number 0)) (.lt first after))
      (.le after (.add (.sourceLast (.variable "text")) (.number 1)))))

def nameLocals (text : Source) (first after : Nat) : Locals
  | .source, "text" => text
  | .number, "first" => first
  | .number, "after" => after
  | ty, _ => ty.default

def nameState (text : Source) (first after : Nat) : Bool :=
  nameStateBody.eval noCalls (nameLocals text first after)

theorem nameState_checked : nameStateBody.wellFormedRoot noNames = true ∧
    nameStateBody.scoped [(.source,"text"),(.number,"first"),(.number,"after")] = true := by
  decide +kernel

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

theorem nameState_meaning (text : Source) (first after : Nat) :
    nameState text first after = nameStateValid text first after := by
  dsimp only [nameState, nameStateBody, Expr.eval, nameLocals]
  simp only [nameStateValid, Bool.decide_or, Bool.decide_and, Bool.and_assoc]

def fixedBounds (length : Nat) (dynamic isCharacter : Bool)
    (firstIndex lastIndex : Int) (slot : Nat) : Bool :=
  Compose.StringNative.fixedBoundsBody.eval Compose.Expressions.modelCalls
    (Compose.Expressions.Context.locals
      {length, dynamicSeen := dynamic, isCharacter, firstIndex, lastIndex, slot})

/-- The fixed-bound helper has no imported calls. Its existing typed expression
is evaluated here with its complete arguments rather than assuming its result. -/
theorem fixedBounds_meaning (length : Nat) (dynamic isCharacter : Bool)
    (firstIndex lastIndex : Int) (slot : Nat) :
    fixedBounds length dynamic isCharacter firstIndex lastIndex slot =
      fixedBoundsValid length dynamic isCharacter firstIndex lastIndex slot := by
  dsimp +instances only [fixedBounds, Compose.StringNative.fixedBoundsBody,
    Compose.Expressions.Expr.eval, Compose.Expressions.Context.locals,
    Compose.Expressions.Calls.get, Compose.Expressions.Field.get]
  cases isCharacter <;> cases dynamic <;>
    simp [fixedBoundsValid, Bool.decide_and, Bool.and_assoc]

def calls : Calls ValidityTables.Function
  | _, .nameState => nameState
  | _, .empty => Integer.Interval.isEmpty
  | _, .fixedBounds => fixedBounds

theorem calls_meaning : calls = ValidityTables.modelCalls := by
  funext ty function
  cases function with
  | nameState => funext text first after; exact nameState_meaning text first after
  | empty => rfl
  | fixedBounds =>
    funext length dynamic isCharacter firstIndex lastIndex slot
    exact fixedBounds_meaning length dynamic isCharacter firstIndex lastIndex slot

end Silver.ApplicationPackageFrames.ValidityTables.Primitives
