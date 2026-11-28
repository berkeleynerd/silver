module

public import Silver.Cursor
public import Silver.NamedIdentifier

@[expose] public section

/-! Context visibility and existing operation spellings. This module reads source
bytes; it does not rewrite the source given to proof or compilation. -/
namespace Silver.Names

set_option backward.dsimp.instances true

inductive Operation | output | partialOutput | argument | validity | reject
  deriving DecidableEq, Repr

def Operation.name : Operation → String
  | .output => "put_line" | .partialOutput => "put" | .argument => "first_or_default"
  | .validity => "input_is_valid" | .reject => "reject"

structure Context where
  after : Nat := 0
  ioWith : Bool := false
  argumentsWith : Bool := false
  ioUse : Bool := false
  argumentsUse : Bool := false
  deriving DecidableEq, Repr

inductive Mode | clauseStart | withName | useName | withSeparator | useSeparator
  deriving DecidableEq, Repr

structure State where
  context : Context := {}
  mode : Mode := .clauseStart
  complete : Bool := false
  deriving DecidableEq, Repr

def invalidContext : Context := {}
def initialState : State := {context := {after := 1}}
def invalidState : State := {complete := true}

/-- Exactly the native optional-span predicate; the selected span need not
itself satisfy an identifier grammar. -/
def ValidNameState (text : Source) (first after : Nat) : Prop :=
  (first = 0 ∧ after = 0) ∨ (0 < first ∧ first < after ∧ after ≤ text.length + 1)

def ValidContext (text : Source) (contextFirst packageFirst packageAfter : Nat) : Prop :=
  1 ≤ contextFirst ∧ contextFirst ≤ text.length + 1 ∧
    ValidNameState text packageFirst packageAfter

theorem validContext_default (text : Source) : ValidContext text 1 0 0 := by
  simp [ValidContext, ValidNameState]

/-- Match one complete identifier against the selected source span. This does
not use the bounded fixed-word spelling helper. -/
def packageNameAfter (text : Source) (position packageFirst packageAfter : Nat) : Nat :=
  if position = 0 ∨ packageFirst = 0 then 0
  else
    let first := Cursor.triviaPosition text position
    let after := Named.identifierEnd text first
    if after = 0 then 0
    else if Named.equalName text first after packageFirst packageAfter then after else 0

@[simp] theorem packageNameAfter_absent (text : Source) (position packageAfter : Nat) :
    packageNameAfter text position 0 packageAfter = 0 := by simp [packageNameAfter]

theorem packageNameAfter_progress (text : Source) (position packageFirst packageAfter : Nat)
    (bound : position ≤ text.length + 1) :
    packageNameAfter text position packageFirst packageAfter = 0 ∨
      (position < packageNameAfter text position packageFirst packageAfter ∧
        packageNameAfter text position packageFirst packageAfter ≤ text.length + 1) := by
  unfold packageNameAfter
  split
  · exact Or.inl rfl
  · rename_i present
    have trivia := Cursor.triviaPosition_bounds text position (by omega) bound
    dsimp only
    split
    · exact Or.inl rfl
    · rename_i matched
      have identifier := Named.identifierEnd_bounds text _ matched
      split
      · exact Or.inr ⟨by omega, identifier.2⟩
      · exact Or.inl rfl

def fixedAt (text : Source) (position : Nat) (spelling : String) (word : Bool) : Bool :=
  let bytes := spelling.toList.map Char.toNat
  decide (bytes.length ≤ text.length + 1 - position) &&
    decide (∀ index : Fin bytes.length,
      lowercase (Cursor.byteAt text (position + index.val)) = bytes[index.val]) &&
    (!word || decide (position + bytes.length > text.length) ||
      !identifierCharacter (Cursor.byteAt text (position + bytes.length)))

def take (text : Source) (position : Nat) (spelling : String) (word : Bool) : Nat :=
  if position = 0 then 0
  else if fixedAt text (Cursor.triviaPosition text position) spelling word then
    Cursor.triviaPosition text position + spelling.toList.length else 0

@[simp] theorem take_zero (text : Source) (spelling : String) (word : Bool) :
    take text 0 spelling word = 0 := by simp [take]

theorem take_progress (text : Source) (position : Nat) (spelling : String) (word : Bool)
    (bound : position ≤ text.length + 1) (nonempty : 0 < spelling.toList.length) :
    take text position spelling word = 0 ∨
      (position < take text position spelling word ∧ take text position spelling word ≤ text.length + 1) := by
  unfold take
  split
  · exact Or.inl rfl
  · rename_i positive
    have trivia := Cursor.triviaPosition_bounds text position (by omega) bound
    split
    · rename_i found
      have lengthBound : spelling.toList.length ≤ text.length + 1 - Cursor.triviaPosition text position := by
        simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, List.length_map] at found
        exact found.1.1
      exact Or.inr ⟨by omega, by omega⟩
    · exact Or.inl rfl

theorem take_bound (text : Source) (position : Nat) (spelling : String) (word : Bool)
    (bound : position ≤ text.length + 1) (nonempty : 0 < spelling.toList.length) :
    take text position spelling word ≤ text.length + 1 := by
  rcases take_progress text position spelling word bound nonempty with zero | good
  · rw [zero]; omega
  · exact good.2

theorem take_after_range (text : Source) (position after : Nat) (spelling : String) (word : Bool)
    (earlier : after = 0 ∨ (position < after ∧ after ≤ text.length + 1))
    (nonempty : 0 < spelling.toList.length) :
    take text after spelling word = 0 ∨
      (position < take text after spelling word ∧ take text after spelling word ≤ text.length + 1) := by
  rcases earlier with zero | good
  · simp [zero]
  · rcases take_progress text after spelling word good.2 nonempty with zero | next
    · exact Or.inl zero
    · exact Or.inr ⟨by omega, next.2⟩

/-- One token step of the context grammar. A use-clause sees only preceding
with-clauses; repetitions preserve the same visibility flags. -/
def contextStep (text : Source) (state : State) (packageFirst packageAfter : Nat) : State :=
  if state.context.after = 0 then invalidState
  else if state.complete then state
  else if state.mode = .clauseStart then
    let w := take text state.context.after "with" true
    let u := take text state.context.after "use" true
    if w ≠ 0 then {state with context := {state.context with after := w}, mode := .withName}
    else if u ≠ 0 then {state with context := {state.context with after := u}, mode := .useName}
    else {state with complete := true}
  else if state.mode = .withName ∨ state.mode = .useName then
    let i := take text state.context.after "silver_io" true
    let a := take text state.context.after "silver_arguments" true
    let p := if state.mode = .withName then
      packageNameAfter text state.context.after packageFirst packageAfter else 0
    if i = 0 ∧ a = 0 ∧ p = 0 then invalidState
    else if state.mode = .useName ∧ ((i ≠ 0 ∧ !state.context.ioWith) ∨
        (a ≠ 0 ∧ !state.context.argumentsWith)) then invalidState
    else
      { context :=
          { after := (if i ≠ 0 then i else if a ≠ 0 then a else p)
            ioWith := state.context.ioWith || (i != 0 && state.mode == .withName)
            argumentsWith := state.context.argumentsWith || (a != 0 && state.mode == .withName)
            ioUse := state.context.ioUse || (i != 0 && state.mode == .useName)
            argumentsUse := state.context.argumentsUse || (a != 0 && state.mode == .useName) }
        mode := (if state.mode = .withName then .withSeparator else .useSeparator)
        complete := false }
  else
    let s := take text state.context.after ";" false
    let c := take text state.context.after "," false
    if s ≠ 0 then {state with context := {state.context with after := s}, mode := .clauseStart}
    else if c ≠ 0 then {state with context := {state.context with after := c}, mode := (if state.mode = .withSeparator then .withName else .useName)}
    else invalidState

theorem contextStep_progress (text : Source) (state : State) (packageFirst packageAfter : Nat)
    (bound : state.context.after ≤ text.length + 1) :
    (contextStep text state packageFirst packageAfter).context.after ≤ text.length + 1 ∧
    ((contextStep text state packageFirst packageAfter).context.after = 0 ∨
      (state.context.after ≤ (contextStep text state packageFirst packageAfter).context.after ∧
        ((contextStep text state packageFirst packageAfter).complete = true ∨
          state.context.after < (contextStep text state packageFirst packageAfter).context.after))) := by
  have w := take_progress text state.context.after "with" true bound (by decide)
  have u := take_progress text state.context.after "use" true bound (by decide)
  have i := take_progress text state.context.after "silver_io" true bound (by decide)
  have a := take_progress text state.context.after "silver_arguments" true bound (by decide)
  have s := take_progress text state.context.after ";" false bound (by decide)
  have c := take_progress text state.context.after "," false bound (by decide)
  have p := packageNameAfter_progress text state.context.after packageFirst packageAfter bound
  unfold contextStep
  repeat' first | split | (dsimp only)
  all_goals simp_all [invalidState] <;> omega

/-- Selecting an application package adds no use-clause alternative. -/
theorem contextStep_use_package_independent (text : Source) (state : State)
    (packageFirst packageAfter : Nat) (mode : state.mode = .useName) :
    contextStep text state packageFirst packageAfter = contextStep text state 0 0 := by
  simp [contextStep, mode]

/-- A selected application name preserves all runtime visibility flags when
it is distinct from the two runtime names at this source position. -/
theorem contextStep_package_with (text : Source) (state : State)
    (packageFirst packageAfter : Nat) (positive : state.context.after ≠ 0)
    (active : state.complete = false) (mode : state.mode = .withName)
    (noIO : take text state.context.after "silver_io" true = 0)
    (noArguments : take text state.context.after "silver_arguments" true = 0)
    (matched : packageNameAfter text state.context.after packageFirst packageAfter ≠ 0) :
    contextStep text state packageFirst packageAfter =
      ⟨{state.context with after := packageNameAfter text state.context.after packageFirst packageAfter},
        .withSeparator, false⟩ := by
  simp [contextStep, positive, active, mode, noIO, noArguments, matched]

/-- The native recursive contract is total on its bounded source domain. -/
def contextTail (text : Source) (state : State) (packageFirst packageAfter : Nat) : Context :=
  if _bound : state.context.after ≤ text.length + 1 then
    if state.context.after = 0 then invalidContext
    else if state.complete then state.context
    else
      let next := contextStep text state packageFirst packageAfter
      if next.context.after = 0 then invalidContext else contextTail text next packageFirst packageAfter
  else invalidContext
termination_by 2 * (text.length + 1 - state.context.after) + (if state.complete then 0 else 1)
decreasing_by
  change 2 * (text.length + 1 - (contextStep text state packageFirst packageAfter).context.after) +
      (if (contextStep text state packageFirst packageAfter).complete then 0 else 1) <
    2 * (text.length + 1 - state.context.after) + (if state.complete then 0 else 1)
  have progress := contextStep_progress text state packageFirst packageAfter _bound
  rcases progress.2 with zero | ⟨monotone, complete | advancing⟩
  all_goals cases finished : (contextStep text state packageFirst packageAfter).complete <;> simp_all +zetaDelta <;> omega

def readContext (text : Source) (contextFirst : Nat := 1)
    (packageFirst : Nat := 0) (packageAfter : Nat := 0) : Context :=
  contextTail text {initialState with context := {after := contextFirst}} packageFirst packageAfter

def contextAfter (text : Source) (arguments : Bool) : Nat :=
  let context := readContext text
  if context.ioWith && (context.argumentsWith == arguments) then context.after else 0

def operationAfter (text : Source) (position : Nat) (operation : Operation) (hidden : Bool)
    (contextFirst : Nat := 1) (packageFirst : Nat := 0) (packageAfter : Nat := 0) : Nat :=
  let context := readContext text contextFirst packageFirst packageAfter
  let visible := if operation = .output ∨ operation = .partialOutput then context.ioWith else context.argumentsWith
  let used := if operation = .output ∨ operation = .partialOutput then context.ioUse else context.argumentsUse
  let packageHides := decide (packageFirst ≠ 0) &&
    Named.nameIs text packageFirst packageAfter (operation.name.toList.map Char.toNat)
  let qualified := take text (take text position
    (if operation = .output ∨ operation = .partialOutput then "silver_io" else "silver_arguments") true) "." false
  if context.after = 0 ∨ !visible then 0
  else if qualified ≠ 0 then take text qualified operation.name true
  else if used && !hidden && !packageHides then take text position operation.name true
  else 0

/-- A directly visible application package hides every homographic use-visible
runtime operation. This applies at the shared reader, including its direct
initializer and validity-query callers. -/
theorem operationAfter_package_homograph (text : Source) (position : Nat)
    (operation : Operation) (hidden : Bool) (contextFirst packageFirst packageAfter : Nat)
    (present : packageFirst ≠ 0)
    (homograph : Named.nameIs text packageFirst packageAfter
      (operation.name.toList.map Char.toNat) = true)
    (unqualified : take text (take text position
      (if operation = .output ∨ operation = .partialOutput then "silver_io" else "silver_arguments") true)
      "." false = 0) :
    operationAfter text position operation hidden contextFirst packageFirst packageAfter = 0 := by
  simp [operationAfter, present, homograph, unqualified]

/-- Selecting a runtime operation through its package bypasses hiding by the
application package, while retaining the original required with-clause. -/
theorem operationAfter_qualified (text : Source) (position : Nat)
    (operation : Operation) (hidden : Bool) (contextFirst packageFirst packageAfter : Nat)
    (context : (readContext text contextFirst packageFirst packageAfter).after ≠ 0)
    (visible : (if operation = .output ∨ operation = .partialOutput then
      (readContext text contextFirst packageFirst packageAfter).ioWith else
      (readContext text contextFirst packageFirst packageAfter).argumentsWith) = true)
    (qualified : take text (take text position
      (if operation = .output ∨ operation = .partialOutput then "silver_io" else "silver_arguments") true)
      "." false ≠ 0) :
    operationAfter text position operation hidden contextFirst packageFirst packageAfter =
      take text (take text (take text position
        (if operation = .output ∨ operation = .partialOutput then "silver_io" else "silver_arguments") true)
        "." false) operation.name true := by
  simp [operationAfter, context, visible, qualified]

namespace VisibilityControls

def runtimePackage (operation : Operation) : String :=
  if operation = .output ∨ operation = .partialOutput then "Silver_IO" else "Silver_Arguments"

def contextPrefix (operation : Operation) : String :=
  "with " ++ operation.name ++ ", " ++ runtimePackage operation ++ "; use " ++
    runtimePackage operation ++ "; procedure Main is pragma SPARK_Mode (On); begin "

def text (operation : Operation) (qualified : Bool) : Source :=
  (contextPrefix operation ++ (if qualified then runtimePackage operation ++ "." else "") ++
    operation.name).toList.map Char.toNat

/-- All five runtime operations reject a directly visible package homograph,
including First_Or_Default whose initializer calls this reader directly. -/
theorem bare_rejected (operation : Operation) :
    operationAfter (text operation false) ((contextPrefix operation).toList.length + 1)
      operation false 1 6 (6 + operation.name.toList.length) = 0 := by
  cases operation <;> decide +kernel

/-- The same five selected application packages retain qualified runtime calls. -/
theorem qualified_accepted (operation : Operation) :
    operationAfter (text operation true) ((contextPrefix operation).toList.length + 1)
      operation false 1 6 (6 + operation.name.toList.length) =
      (text operation true).length + 1 := by
  cases operation <;> decide +kernel

end VisibilityControls

def associationAfter (text : Source) (position : Nat) (default : Bool) : Nat :=
  let named := take text (take text position (if default then "default" else "item") true) "=>" false
  if named ≠ 0 then named else position

@[simp] theorem operationAfter_zero (text : Source) (operation : Operation) (hidden : Bool)
    (contextFirst packageFirst packageAfter : Nat) :
    operationAfter text 0 operation hidden contextFirst packageFirst packageAfter = 0 := by simp [operationAfter]

@[simp] theorem associationAfter_zero (text : Source) (default : Bool) :
    associationAfter text 0 default = 0 := by simp [associationAfter]

theorem contextTail_bound (text : Source) (state : State) (packageFirst packageAfter : Nat) :
    (contextTail text state packageFirst packageAfter).after ≤ text.length + 1 := by
  fun_induction contextTail text state packageFirst packageAfter <;>
    simp_all [invalidContext] <;> omega

theorem readContext_bound (text : Source) (contextFirst packageFirst packageAfter : Nat) :
    (readContext text contextFirst packageFirst packageAfter).after ≤ text.length + 1 :=
  contextTail_bound text _ packageFirst packageAfter

theorem contextAfter_bound (text : Source) (arguments : Bool) :
    contextAfter text arguments ≤ text.length + 1 := by
  have bounded := readContext_bound text 1 0 0
  unfold contextAfter
  dsimp only
  split <;> simp_all

theorem operationAfter_range (text : Source) (position : Nat) (operation : Operation) (hidden : Bool)
    (contextFirst packageFirst packageAfter : Nat)
    (bound : position ≤ text.length + 1) :
    operationAfter text position operation hidden contextFirst packageFirst packageAfter = 0 ∨
      (position < operationAfter text position operation hidden contextFirst packageFirst packageAfter ∧
        operationAfter text position operation hidden contextFirst packageFirst packageAfter ≤ text.length + 1) := by
  have packageName : 0 < (if operation = .output ∨ operation = .partialOutput then "silver_io" else "silver_arguments").toList.length := by
    cases operation <;> decide
  have operationName : 0 < operation.name.toList.length := by cases operation <;> decide
  have startFacts := take_progress text position (if operation = .output ∨ operation = .partialOutput then "silver_io" else "silver_arguments") true bound packageName
  have dot := take_after_range text position _ "." false startFacts (by decide)
  have qualified := take_after_range text position _ operation.name true dot operationName
  have plain := take_progress text position operation.name true bound operationName
  unfold operationAfter
  repeat' first | split | (dsimp only)
  all_goals simp_all <;> omega

theorem operationAfter_bound (text : Source) (position : Nat) (operation : Operation) (hidden : Bool)
    (contextFirst packageFirst packageAfter : Nat)
    (bound : position ≤ text.length + 1) :
    operationAfter text position operation hidden contextFirst packageFirst packageAfter ≤ text.length + 1 := by
  rcases operationAfter_range text position operation hidden contextFirst packageFirst packageAfter bound with zero | good
  · rw [zero]; omega
  · exact good.2

theorem operationAfter_progress (text : Source) (position : Nat) (operation : Operation) (hidden : Bool)
    (contextFirst packageFirst packageAfter : Nat)
    (bound : position ≤ text.length + 1) (accepted : operationAfter text position operation hidden contextFirst packageFirst packageAfter ≠ 0) :
    position < operationAfter text position operation hidden contextFirst packageFirst packageAfter := by
  exact ((operationAfter_range text position operation hidden contextFirst packageFirst packageAfter bound).resolve_left accepted).1

theorem associationAfter_range (text : Source) (position : Nat) (default : Bool)
    (bound : position ≤ text.length + 1) :
    position ≤ associationAfter text position default ∧ associationAfter text position default ≤ text.length + 1 := by
  have name : 0 < (if default then "default" else "item").toList.length := by cases default <;> decide
  have first := take_progress text position (if default then "default" else "item") true bound name
  have second := take_after_range text position _ "=>" false first (by decide)
  unfold associationAfter
  repeat' first | split | (dsimp only)
  all_goals simp_all <;> omega

theorem associationAfter_bound (text : Source) (position : Nat) (default : Bool)
    (bound : position ≤ text.length + 1) :
    associationAfter text position default ≤ text.length + 1 :=
  (associationAfter_range text position default bound).2

theorem associationAfter_progress (text : Source) (position : Nat) (default : Bool)
    (bound : position ≤ text.length + 1) :
    position ≤ associationAfter text position default :=
  (associationAfter_range text position default bound).1

theorem contextTail_use_without_with (text : Source) (context : Context)
    (packageFirst packageAfter : Nat)
    (noIO : context.ioWith = false) (noArguments : context.argumentsWith = false) :
    contextTail text {context, mode := .useName} packageFirst packageAfter = invalidContext := by
  have stepBad : contextStep text {context, mode := .useName} packageFirst packageAfter = invalidState := by
    unfold contextStep
    repeat' first | split | (dsimp only)
    all_goals simp_all <;> omega
  rw [contextTail]
  dsimp only
  split
  · split
    · rfl
    · simp [stepBad, invalidState]
  · rfl

theorem contextAfter_firstWith (text : Source) (arguments : Bool)
    (accepted : contextAfter text arguments ≠ 0) : take text 1 "with" true ≠ 0 := by
  intro absent
  have noIO : (readContext text).ioWith = false := by
    unfold readContext
    rw [contextTail]
    simp +instances only [initialState, Nat.le_add_left, ↓reduceDIte, Nat.one_ne_zero, Bool.false_eq_true, ↓reduceIte]
    have start : contextStep text initialState 0 0 =
        if take text 1 "use" true ≠ 0 then
          {context := {after := take text 1 "use" true}, mode := .useName}
        else {context := {after := 1}, complete := true} := by
      by_cases used : take text 1 "use" true = 0 <;> simp [contextStep, initialState, absent, used]
    have start' : contextStep text {context := {after := 1}} 0 0 =
        if take text 1 "use" true ≠ 0 then
          {context := {after := take text 1 "use" true}, mode := .useName}
        else {context := {after := 1}, complete := true} := start
    simp +instances only [start']
    by_cases used : take text 1 "use" true = 0
    · simp +instances only [used, ne_eq, not_true_eq_false, ↓reduceIte, Nat.one_ne_zero]
      rw [contextTail]
      simp
    · simp +instances only [used, ne_eq, not_false_eq_true, ↓reduceIte]
      rw [contextTail_use_without_with text _ 0 0 rfl rfl]
      rfl
  simp [contextAfter, noIO] at accepted

end Silver.Names
