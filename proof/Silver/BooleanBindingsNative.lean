module

public import Silver.BooleanBindings
public import Silver.ComposeExpressions
public import Silver.ComposeBounds
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.BooleanBindings.Native

abbrev ValidText := Compose.Expressions.ValidText

structure Calls where
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  nameIs : Source → Nat → Nat → List Nat → Bool
  lookupModel : Source → Environment → Nat → Nat → Nat → Nat
  lookup : Source → Environment → Nat → Nat → Nat
  hidesInteger : Source → Environment → Bool

structure Frame where
  text : Source
  names : Environment
  first : Nat
  after : Nat
  index : Nat

/-- The closed scalar tree has only the operands appearing in the checked
Boolean lookup equation. Every variable is bound by its fixed function header. -/
inductive Number
  | zero | first | after | index
  | previous (value : Number)
  | recursive (index : Number)
  deriving Repr

inductive Test
  | equal (left right : Number)
  | lessEqual (left right : Number)
  | sameName
  | orElse (left right : Test)
  deriving Repr

inductive Tree
  | value (value : Number)
  | ite (condition : Test) (yes no : Tree)
  deriving Repr

def Number.eval (calls : Calls) (frame : Frame) : Number → Nat
  | .zero => 0 | .first => frame.first | .after => frame.after | .index => frame.index
  | .previous value => value.eval calls frame - 1
  | .recursive argument => calls.lookupModel frame.text frame.names frame.first frame.after (argument.eval calls frame)

def Test.eval (calls : Calls) (frame : Frame) : Test → Bool
  | .equal left right => left.eval calls frame == right.eval calls frame
  | .lessEqual left right => decide (left.eval calls frame ≤ right.eval calls frame)
  | .sameName => calls.equalName frame.text (binding frame.names frame.index).first
      (binding frame.names frame.index).after frame.first frame.after
  | .orElse left right => left.eval calls frame || right.eval calls frame

def Tree.eval (calls : Calls) (frame : Frame) : Tree → Nat
  | .value term => term.eval calls frame
  | .ite condition yes no => if condition.eval calls frame then yes.eval calls frame else no.eval calls frame

def Number.render : Number → List String
  | .zero => ["0"] | .first => ["first"] | .after => ["after"] | .index => ["index"]
  | .previous value => value.render ++ ["-", "1"]
  | .recursive argument => Compose.Expressions.call "lookup_boolean_model"
      [["text"], ["booleans"], ["first"], ["after"], argument.render]

def Test.render : Test → List String
  | .equal left right => left.render ++ ["="] ++ right.render
  | .lessEqual left right => left.render ++ ["<="] ++ right.render
  | .sameName => Compose.Expressions.call "equal_name"
      [["text"], ["booleans", ".", "items", "(", "index", ")", ".", "first"],
        ["booleans", ".", "items", "(", "index", ")", ".", "after"], ["first"], ["after"]]
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render

def Tree.render : Tree → List String
  | .value term => term.render
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with
       | .ite _ _ _ => ["elsif"] ++ no.render.drop 1
       | .value _ => ["else"] ++ no.render)

/-- Numeric operators are excluded from comparison operands and from the
operand of subtraction; disjunctions associate only to the left. -/
def Number.primary : Number → Bool
  | .zero | .first | .after | .index | .recursive _ => true
  | .previous _ => false

def Number.wellFormed : Number → Bool
  | .zero | .first | .after | .index => true
  | .previous value => value.primary && value.wellFormed
  | .recursive argument => argument.wellFormed

def Test.relation : Test → Bool
  | .equal _ _ | .lessEqual _ _ | .sameName => true
  | .orElse _ _ => false

def Test.wellFormed : Test → Bool
  | .equal left right | .lessEqual left right =>
      left.primary && right.primary && left.wellFormed && right.wellFormed
  | .sameName => true
  | .orElse left right => left.wellFormed && right.relation && right.wellFormed

def Tree.wellFormed : Tree → Bool
  | .value term => term.wellFormed
  | .ite condition yes no => condition.wellFormed &&
      (match yes with | .value term => term.wellFormed | .ite _ _ _ => false) && no.wellFormed

def lookupBody : Tree :=
  .ite (.orElse (.orElse (.equal .first .zero) (.lessEqual .after .first)) (.equal .index .zero))
    (.value .zero) (.ite .sameName (.value .index) (.value (.recursive (.previous .index))))

theorem lookup_precedence : lookupBody.wellFormed = true := rfl

/-- The quantifier ranges over exactly the active metadata prefix. Its bound
variable is provided only by the quantifier, so no free name can enter this tree. -/
inductive BindingPredicate
  | nameIsInteger

inductive QuantifiedTree
  | any (predicate : BindingPredicate)

def BindingPredicate.eval (calls : Calls) (text : Source) (item : Binding) : BindingPredicate → Bool
  | .nameIsInteger => calls.nameIs text item.first item.after ("integer".toList.map Char.toNat)

def BindingPredicate.render : BindingPredicate → List String
  | .nameIsInteger => Compose.Expressions.call "name_is"
      [["text"], ["booleans", ".", "items", "(", "index", ")", ".", "first"],
        ["booleans", ".", "items", "(", "index", ")", ".", "after"], ["\"integer\""]]

def QuantifiedTree.eval (calls : Calls) (text : Source) (names : Environment) : QuantifiedTree → Bool
  | .any predicate => names.any fun item => predicate.eval calls text item

def QuantifiedTree.render : QuantifiedTree → List String
  | .any predicate => ["for", "some", "index", "in", "1", "..", "booleans", ".", "count", "=>"] ++ predicate.render

def hidesIntegerTree : QuantifiedTree := .any .nameIsInteger

def hidesIntegerBody (calls : Calls) (text : Source) (names : Environment) : Bool :=
  hidesIntegerTree.eval calls text names

def hidesIntegerTokens : List String := hidesIntegerTree.render

structure Primitives (calls : Calls) : Prop where
  equalName : ∀ text, ValidText text → ∀ first after otherFirst otherAfter,
    0 < first → first < after → after ≤ text.length + 1 →
    0 < otherFirst → otherFirst < otherAfter → otherAfter ≤ text.length + 1 →
    calls.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter
  nameIs : ∀ text, ValidText text → ∀ first after,
    0 < first → first < after → after ≤ text.length + 1 → ∀ expected,
    0 < expected.length → expected.length ≤ maxSourceLength →
    calls.nameIs text first after expected = Named.nameIs text first after expected

structure Equations (calls : Calls) : Prop where
  lookupModel : ∀ text, ValidText text → ∀ names, ValidEnvironment text names →
    ∀ first after index, first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ names.length →
      calls.lookupModel text names first after index = lookupBody.eval calls ⟨text, names, first, after, index⟩
  lookup : ∀ text, ValidText text → ∀ names, ValidEnvironment text names →
    ∀ first after, first ≤ text.length + 1 → after ≤ text.length + 1 →
      calls.lookup text names first after = calls.lookupModel text names first after names.length
  hidesInteger : ∀ text, ValidText text → ∀ names, ValidEnvironment text names →
    calls.hidesInteger text names = hidesIntegerBody calls text names

theorem binding_mem {names : Environment} {index : Nat}
    (positive : 0 < index) (bounded : index ≤ names.length) : binding names index ∈ names := by
  unfold binding
  have within : index - 1 < names.length := by omega
  simpa only [List.getD, List.getElem?_eq_getElem within, Option.getD_some] using List.getElem_mem within

theorem lookupModel_meaning (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (tv : ValidText text) (names : Environment) (nv : ValidEnvironment text names)
    (first after : Nat) (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1)
    (index : Nat) (ib : index ≤ names.length) :
    calls.lookupModel text names first after index = lookupFrom text names first after index := by
  induction index with
  | zero =>
      rw [equations.lookupModel text tv names nv first after 0 fb ab ib]
      simp [lookupBody, Tree.eval, Test.eval, Number.eval, lookupFrom]
  | succ index ih =>
      rw [equations.lookupModel text tv names nv first after (index + 1) fb ab ib]
      by_cases firstZero : first = 0
      · simp [lookupBody, Tree.eval, Test.eval, Number.eval, lookupFrom, firstZero]
      · by_cases order : after ≤ first
        · simp [lookupBody, Tree.eval, Test.eval, Number.eval, lookupFrom, order]
        · have item := nv.2 _ (binding_mem (by omega) ib)
          have same := primitives.equalName text tv _ _ first after item.1 item.2.1 item.2.2
            (by omega) (by omega) ab
          simp [lookupBody, Tree.eval, Test.eval, Number.eval, lookupFrom,
            firstZero, order, same, ih (by omega)]

theorem lookup_meaning (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (tv : ValidText text) (names : Environment) (nv : ValidEnvironment text names)
    (first after : Nat) (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1) :
    calls.lookup text names first after = BooleanBindings.lookup text names first after := by
  rw [equations.lookup text tv names nv first after fb ab]
  exact lookupModel_meaning calls primitives equations text tv names nv first after fb ab names.length (Nat.le_refl _)

theorem hidesInteger_meaning (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (tv : ValidText text) (names : Environment) (nv : ValidEnvironment text names) :
    calls.hidesInteger text names = BooleanBindings.hidesInteger text names := by
  rw [equations.hidesInteger text tv names nv]
  simp only [hidesIntegerBody, QuantifiedTree.eval, BindingPredicate.eval, BooleanBindings.hidesInteger]
  have agree : ∀ item ∈ names,
      calls.nameIs text item.first item.after ("integer".toList.map Char.toNat) =
        Named.nameIs text item.first item.after ("integer".toList.map Char.toNat) := by
    intro item member
    have valid := nv.2 item member
    exact primitives.nameIs text tv item.first item.after valid.1 valid.2.1 valid.2.2 _
      (by decide) (by decide)
  clear nv
  induction names with
  | nil => rfl
  | cons item rest ih =>
      simp only [List.any_cons, agree item (List.mem_cons_self ..)]
      rw [ih (fun other present => agree other (List.mem_cons_of_mem item present))]

def modelCalls : Calls where
  equalName := Named.equalName
  nameIs := Named.nameIs
  lookupModel := lookupFrom
  lookup := BooleanBindings.lookup
  hidesInteger := BooleanBindings.hidesInteger

theorem model_primitives : Primitives modelCalls where
  equalName := by intros; rfl
  nameIs := by intros; rfl

theorem model_equations : Equations modelCalls where
  lookupModel text tv names nv first after index fb ab ib := by
    cases index with
    | zero => simp [modelCalls, lookupFrom, lookupBody, Tree.eval, Test.eval, Number.eval]
    | succ index =>
      simp only [modelCalls, lookupFrom, lookupBody, Tree.eval, Test.eval, Number.eval]
      by_cases a : first = 0 <;> by_cases b : after ≤ first <;> simp [a, b] <;> rfl
  lookup := by intros; rfl
  hidesInteger := by intros; rfl

end Silver.BooleanBindings.Native
