module

public import Silver.BooleanBindings
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.BooleanBindings.Native

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ maxSourceLength

def call (name : String) (arguments : List (List String)) : List String :=
  [name, "("] ++ List.flatten (List.intersperse [","] arguments) ++ [")"]

structure Calls where
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  nameIs : Source → Nat → Nat → List Nat → Bool
  lookupModel : Source → Environment → Nat → Nat → Nat → optParam Nat 0 → optParam Nat 0 → Nat
  lookup : Source → Environment → Nat → Nat → optParam Nat 0 → optParam Nat 0 → Nat
  hidesInteger : Source → Environment → Bool

structure Frame where
  text : Source
  names : Environment
  first : Nat
  after : Nat
  index : Nat
  qualifierFirst : Nat := 0
  qualifierAfter : Nat := 0

/-- The closed scalar tree has only the operands appearing in the checked
Boolean lookup equation. Every variable is bound by its fixed function header. -/
inductive Number
  | zero | first | after | index | qualifierFirst | itemQualifierFirst
  | previous (value : Number)
  | recursive (index : Number)
  deriving Repr

inductive Test
  | equal (left right : Number)
  | lessEqual (left right : Number)
  | greater (left right : Number)
  | sameName | sameQualifier
  | orElse (left right : Test)
  | andThen (left right : Test)
  | ite (condition yes no : Test)
  deriving Repr

inductive Tree
  | value (value : Number)
  | ite (condition : Test) (yes no : Tree)
  deriving Repr

def Number.eval (calls : Calls) (frame : Frame) : Number → Nat
  | .zero => 0 | .first => frame.first | .after => frame.after | .index => frame.index
  | .qualifierFirst => frame.qualifierFirst
  | .itemQualifierFirst => (binding frame.names frame.index).qualifierFirst
  | .previous value => value.eval calls frame - 1
  | .recursive argument => calls.lookupModel frame.text frame.names frame.first frame.after (argument.eval calls frame) frame.qualifierFirst frame.qualifierAfter

def Test.eval (calls : Calls) (frame : Frame) : Test → Bool
  | .equal left right => left.eval calls frame == right.eval calls frame
  | .lessEqual left right => decide (left.eval calls frame ≤ right.eval calls frame)
  | .greater left right => decide (right.eval calls frame < left.eval calls frame)
  | .sameName => calls.equalName frame.text (binding frame.names frame.index).first
      (binding frame.names frame.index).after frame.first frame.after
  | .sameQualifier => calls.equalName frame.text (binding frame.names frame.index).qualifierFirst
      (binding frame.names frame.index).qualifierAfter frame.qualifierFirst frame.qualifierAfter
  | .orElse left right => left.eval calls frame || right.eval calls frame
  | .andThen left right => left.eval calls frame && right.eval calls frame
  | .ite condition yes no => if condition.eval calls frame then yes.eval calls frame else no.eval calls frame

def Tree.eval (calls : Calls) (frame : Frame) : Tree → Nat
  | .value term => term.eval calls frame
  | .ite condition yes no => if condition.eval calls frame then yes.eval calls frame else no.eval calls frame

def Number.render : Number → List String
  | .zero => ["0"] | .first => ["first"] | .after => ["after"] | .index => ["index"]
  | .qualifierFirst => ["qualifier_first"]
  | .itemQualifierFirst => ["booleans", ".", "items", "(", "index", ")", ".", "qualifier_first"]
  | .previous value => value.render ++ ["-", "1"]
  | .recursive argument => call "lookup_boolean_model"
      [["text"], ["booleans"], ["first"], ["after"], argument.render, ["qualifier_first"], ["qualifier_after"]]

def Test.render : Test → List String
  | .equal left right => left.render ++ ["="] ++ right.render
  | .lessEqual left right => left.render ++ ["<="] ++ right.render
  | .greater left right => left.render ++ [">"] ++ right.render
  | .sameName => call "equal_name"
      [["text"], ["booleans", ".", "items", "(", "index", ")", ".", "first"],
        ["booleans", ".", "items", "(", "index", ")", ".", "after"], ["first"], ["after"]]
  | .sameQualifier => call "equal_name"
      [["text"], ["booleans", ".", "items", "(", "index", ")", ".", "qualifier_first"],
        ["booleans", ".", "items", "(", "index", ")", ".", "qualifier_after"],
        ["qualifier_first"], ["qualifier_after"]]
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .ite condition yes no => ["(", "if"] ++ condition.render ++ ["then"] ++ yes.render ++
      ["else"] ++ no.render ++ [")"]

def Tree.render : Tree → List String
  | .value term => term.render
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with
       | .ite _ _ _ => ["elsif"] ++ no.render.drop 1
       | .value _ => ["else"] ++ no.render)

/-- Numeric operators are excluded from comparison operands and from the
operand of subtraction; disjunctions associate only to the left. -/
def Number.primary : Number → Bool
  | .zero | .first | .after | .index | .qualifierFirst | .itemQualifierFirst | .recursive _ => true
  | .previous _ => false

def Number.wellFormed : Number → Bool
  | .zero | .first | .after | .index | .qualifierFirst | .itemQualifierFirst => true
  | .previous value => value.primary && value.wellFormed
  | .recursive argument => argument.wellFormed

def Test.relation : Test → Bool
  | .equal _ _ | .lessEqual _ _ | .greater _ _ | .sameName | .sameQualifier | .ite _ _ _ => true
  | .orElse _ _ | .andThen _ _ => false

def Test.wellFormed : Test → Bool
  | .equal left right | .lessEqual left right | .greater left right =>
      left.primary && right.primary && left.wellFormed && right.wellFormed
  | .sameName | .sameQualifier => true
  | .orElse left right | .andThen left right => left.wellFormed && right.relation && right.wellFormed
  | .ite condition yes no => condition.wellFormed && yes.wellFormed && no.wellFormed

def Tree.wellFormed : Tree → Bool
  | .value term => term.wellFormed
  | .ite condition yes no => condition.wellFormed &&
      (match yes with | .value term => term.wellFormed | .ite _ _ _ => false) && no.wellFormed

def lookupBody : Tree :=
  .ite (.orElse (.orElse (.equal .first .zero) (.lessEqual .after .first)) (.equal .index .zero))
    (.value .zero) (.ite (.andThen .sameName
      (.ite (.equal .qualifierFirst .zero) (.equal .itemQualifierFirst .zero)
        (.andThen (.greater .itemQualifierFirst .zero) .sameQualifier)))
      (.value .index) (.value (.recursive (.previous .index))))

theorem lookup_precedence : lookupBody.wellFormed = true := rfl

/-- A normalized denotation removes dependent decidability instances from
recursive tree evaluation before the lookup induction. -/
def lookupEquation (calls : Calls) (text : Source) (names : Environment)
    (first after index qualifierFirst qualifierAfter : Nat) : Nat :=
  if first = 0 ∨ after ≤ first ∨ index = 0 then 0
  else if calls.equalName text (binding names index).first (binding names index).after first after &&
      (if qualifierFirst = 0 then (binding names index).qualifierFirst == 0
       else decide (0 < (binding names index).qualifierFirst) &&
         calls.equalName text (binding names index).qualifierFirst (binding names index).qualifierAfter
           qualifierFirst qualifierAfter)
  then index else calls.lookupModel text names first after (index - 1) qualifierFirst qualifierAfter

theorem lookup_denotation (calls : Calls) (frame : Frame) :
    lookupBody.eval calls frame = lookupEquation calls frame.text frame.names
      frame.first frame.after frame.index frame.qualifierFirst frame.qualifierAfter := by
  dsimp +instances only [lookupBody, Tree.eval, Test.eval, Number.eval]
  simp [lookupEquation, Bool.or_eq_true, or_assoc]

/-- The quantifier ranges over exactly the active metadata prefix. Its bound
variable is provided only by the quantifier, so no free name can enter this tree. -/
inductive BindingPredicate
  | nameIsInteger

inductive QuantifiedTree
  | any (predicate : BindingPredicate)

def BindingPredicate.eval (calls : Calls) (text : Source) (item : Binding) : BindingPredicate → Bool
  | .nameIsInteger => decide (item.qualifierFirst = 0) &&
      calls.nameIs text item.first item.after ("integer".toList.map Char.toNat)

def BindingPredicate.render : BindingPredicate → List String
  | .nameIsInteger => ["booleans", ".", "items", "(", "index", ")", ".", "qualifier_first", "=", "0", "and", "then"] ++
      call "name_is"
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
    ∀ first after index qualifierFirst qualifierAfter,
      first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ names.length →
      QualifiedNames.ValidSpan text qualifierFirst qualifierAfter →
      calls.lookupModel text names first after index qualifierFirst qualifierAfter =
        lookupBody.eval calls ⟨text, names, first, after, index, qualifierFirst, qualifierAfter⟩
  lookup : ∀ text, ValidText text → ∀ names, ValidEnvironment text names →
    ∀ first after qualifierFirst qualifierAfter,
      first ≤ text.length + 1 → after ≤ text.length + 1 →
      QualifiedNames.ValidSpan text qualifierFirst qualifierAfter →
      calls.lookup text names first after qualifierFirst qualifierAfter =
        calls.lookupModel text names first after names.length qualifierFirst qualifierAfter
  hidesInteger : ∀ text, ValidText text → ∀ names, ValidEnvironment text names →
    calls.hidesInteger text names = hidesIntegerBody calls text names

theorem binding_mem {names : Environment} {index : Nat}
    (positive : 0 < index) (bounded : index ≤ names.length) : binding names index ∈ names := by
  unfold binding
  have within : index - 1 < names.length := by omega
  simpa only [List.getD, List.getElem?_eq_getElem within, Option.getD_some] using List.getElem_mem within

theorem qualifier_meaning (calls : Calls) (primitives : Primitives calls)
    (text : Source) (tv : ValidText text) (item : Binding)
    (itemValid : QualifiedNames.ValidSpan text item.qualifierFirst item.qualifierAfter)
    (first after : Nat) (valid : QualifiedNames.ValidSpan text first after) :
    (if first = 0 then item.qualifierFirst == 0 else
      decide (0 < item.qualifierFirst) &&
        calls.equalName text item.qualifierFirst item.qualifierAfter first after) =
      QualifiedNames.qualifierMatches text item.qualifierFirst item.qualifierAfter first after := by
  by_cases zero : first = 0
  · simp [QualifiedNames.qualifierMatches, zero]
  · rcases valid with absent | span
    · exact False.elim (zero absent.1)
    · by_cases itemZero : item.qualifierFirst = 0
      · simp [QualifiedNames.qualifierMatches, zero, itemZero]
      · rcases itemValid with absent | itemSpan
        · exact False.elim (itemZero absent.1)
        · simp only [QualifiedNames.qualifierMatches, zero, ↓reduceIte]
          rw [primitives.equalName text tv _ _ _ _ itemSpan.1 itemSpan.2.1 itemSpan.2.2
            span.1 span.2.1 span.2.2]

theorem lookupModel_qualified_meaning (calls : Calls) (primitives : Primitives calls)
    (equations : Equations calls) (text : Source) (tv : ValidText text)
    (names : Environment) (nv : ValidEnvironment text names)
    (first after : Nat) (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1)
    (index : Nat) (ib : index ≤ names.length) (qualifierFirst qualifierAfter : Nat)
    (qv : QualifiedNames.ValidSpan text qualifierFirst qualifierAfter) :
    calls.lookupModel text names first after index qualifierFirst qualifierAfter =
      lookupFrom text names first after index qualifierFirst qualifierAfter := by
  induction index with
  | zero =>
      rw [equations.lookupModel text tv names nv first after 0 qualifierFirst qualifierAfter fb ab ib qv,
        lookup_denotation]
      simp [lookupEquation, lookupFrom]
  | succ index ih =>
      rw [equations.lookupModel text tv names nv first after (index + 1) qualifierFirst qualifierAfter fb ab ib qv,
        lookup_denotation]
      by_cases firstZero : first = 0
      · simp [lookupEquation, lookupFrom, firstZero]
      · by_cases order : after ≤ first
        · simp [lookupEquation, lookupFrom, order]
        · have item := nv.2 _ (binding_mem (by omega) ib)
          have same := primitives.equalName text tv _ _ first after item.1 item.2.1 item.2.2.1
            (by omega) (by omega) ab
          have qualifier := qualifier_meaning calls primitives text tv _ item.2.2.2
            qualifierFirst qualifierAfter qv
          simp [lookupEquation, lookupFrom, firstZero, order, same, qualifier, ih (by omega)]

theorem lookup_qualified_meaning (calls : Calls) (primitives : Primitives calls)
    (equations : Equations calls) (text : Source) (tv : ValidText text)
    (names : Environment) (nv : ValidEnvironment text names)
    (first after : Nat) (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1)
    (qualifierFirst qualifierAfter : Nat) (qv : QualifiedNames.ValidSpan text qualifierFirst qualifierAfter) :
    calls.lookup text names first after qualifierFirst qualifierAfter =
      BooleanBindings.lookup text names first after qualifierFirst qualifierAfter := by
  rw [equations.lookup text tv names nv first after qualifierFirst qualifierAfter fb ab qv]
  exact lookupModel_qualified_meaning calls primitives equations text tv names nv first after fb ab
    names.length (Nat.le_refl _) qualifierFirst qualifierAfter qv

theorem lookupModel_meaning (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (tv : ValidText text) (names : Environment) (nv : ValidEnvironment text names)
    (first after : Nat) (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1)
    (index : Nat) (ib : index ≤ names.length) :
    calls.lookupModel text names first after index = lookupFrom text names first after index :=
  lookupModel_qualified_meaning calls primitives equations text tv names nv first after fb ab index ib
    0 0 (Or.inl ⟨rfl, rfl⟩)

theorem lookup_meaning (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (tv : ValidText text) (names : Environment) (nv : ValidEnvironment text names)
    (first after : Nat) (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1) :
    calls.lookup text names first after = BooleanBindings.lookup text names first after :=
  lookup_qualified_meaning calls primitives equations text tv names nv first after fb ab 0 0 (Or.inl ⟨rfl, rfl⟩)

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
    exact primitives.nameIs text tv item.first item.after valid.1 valid.2.1 valid.2.2.1 _
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
  lookupModel := @lookupFrom
  lookup := @BooleanBindings.lookup
  hidesInteger := BooleanBindings.hidesInteger

theorem model_primitives : Primitives modelCalls where
  equalName := by intros; rfl
  nameIs := by intros; rfl

theorem model_equations : Equations modelCalls where
  lookupModel text tv names nv first after index qualifierFirst qualifierAfter fb ab ib qv := by
    rw [lookup_denotation]
    cases index <;> simp [modelCalls, lookupFrom, lookupEquation, QualifiedNames.qualifierMatches]
  lookup := by intros; rfl
  hidesInteger := by intros; rfl

end Silver.BooleanBindings.Native
