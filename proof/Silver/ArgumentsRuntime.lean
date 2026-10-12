module

public import Silver.OutputRuntime

@[expose] public section

/-! Typed statement semantics for the fixed Silver_Arguments implementation.
The same immutable argument vector supplies both pure queries. Missing imported
arguments and unbound locals are explicit interpreter errors; the program proofs
show that the executable count guards make those cases unreachable. The external
GNAT argument ABI, allocation and progress premises are documented separately. -/

namespace Silver.Arguments.Runtime

abbrev Arguments := List Source

inductive MessagePredicate
  | bounded | printable | both (left right : MessagePredicate)
  deriving DecidableEq, Repr

def MessagePredicate.render : MessagePredicate → List String
  | .bounded => ["item", "'", "length", "<=", "silver_io", ".", "max_length"]
  | .printable => ["(", "for", "all", "ch", "of", "item", "=>", "character", "'",
      "pos", "(", "ch", ")", "in", "32", "..", "126", ")"]
  | .both left right => left.render ++ ["and", "then"] ++ right.render

def MessagePredicate.evaluate (item : Source) : MessagePredicate → Bool
  | .bounded => decide (item.length ≤ Output.Runtime.maxLength)
  | .printable => item.all Output.printable
  | .both left right => left.evaluate item && right.evaluate item

def messagePredicate : MessagePredicate := .both .bounded .printable
def message (item : Source) : Bool := messagePredicate.evaluate item

theorem message_iff (item : Source) : message item = true ↔
    item.length ≤ Output.Runtime.maxLength ∧ ∀ byte ∈ item, 32 ≤ byte ∧ byte ≤ 126 := by
  simp [message, messagePredicate, MessagePredicate.evaluate, Output.printable]

@[simp] theorem message_empty : message [] = true := by decide

inductive Kind | boolean | bytes
  deriving DecidableEq

abbrev Value : Kind → Type
  | .boolean => Bool
  | .bytes => Source

inductive Expr : Kind → Type
  | boolean (value : Bool) : Expr .boolean
  | defaultValue : Expr .bytes
  | localItem : Expr .bytes
  | argumentOne : Expr .bytes
  | empty : Expr .bytes
  | countEquals (value : Nat) : Expr .boolean
  | isMessage (value : Expr .bytes) : Expr .boolean

def Expr.render : {kind : Kind} → Expr kind → List String
  | _, .boolean value => [if value then "true" else "false"]
  | _, .defaultValue => ["default"]
  | _, .localItem => ["item"]
  | _, .argumentOne => ["silver_runtime", ".", "argument", "(", "1", ")"]
  | _, .empty => ["\"\""]
  | _, .countEquals value => ["silver_runtime", ".", "argument_count", "=", toString value]
  | _, .isMessage value => ["is_message", "("] ++ value.render ++ [")"]

structure Context where
  arguments : Arguments
  defaultValue : Source
  localItem : Option Source := none

def Expr.evaluate (context : Context) : {kind : Kind} → Expr kind → Option (Value kind)
  | _, .boolean value => some value
  | _, .defaultValue => some context.defaultValue
  | _, .localItem => context.localItem
  | _, .argumentOne => context.arguments.head?
  | _, .empty => some []
  | _, .countEquals value => some (decide (context.arguments.length = value))
  | _, .isMessage value => (value.evaluate context).map message

/-- Absence of a returned value represents statement fallthrough; errors are
kept distinct from normal returns, so an unsafe imported call cannot disappear. -/
inductive Result (kind : Kind)
  | continued
  | returned (value : Value kind)
  | invalid

def Result.thenNext {kind : Kind} (first next : Result kind) : Result kind :=
  match first with
  | .continued => next
  | .returned value => .returned value
  | .invalid => .invalid

inductive Statement : Kind → Type
  | returnValue {kind : Kind} (value : Expr kind) : Statement kind
  /-- Ada extended return constrains the result to 1 .. value'Length and
  initializes it from that same value. The byte semantics forget array indices;
  the rendered bounds and the verified SPARK postcondition fix the lower bound. -/
  | returnRebased (value : Expr .bytes) : Statement .bytes
  | sequence {kind : Kind} (first next : Statement kind) : Statement kind
  | ifThen {kind : Kind} (test : Expr .boolean) (body : Statement kind) : Statement kind
  | ifElsif {kind : Kind} (firstTest : Expr .boolean) (firstBody : Statement kind)
      (nextTest : Expr .boolean) (nextBody : Statement kind) : Statement kind
  | localItem {kind : Kind} (value : Expr .bytes) (body : Statement kind) : Statement kind

def Statement.render {kind : Kind} : Statement kind → List String
  | .returnValue value => ["return"] ++ value.render ++ [";"]
  | .returnRebased value =>
      ["return", "result", ":", "string", "(", "1", ".."] ++ value.render ++
      ["'", "length", ")", ":="] ++ value.render ++ [";"]
  | .sequence first next => first.render ++ next.render
  | .ifThen test body =>
      ["if"] ++ test.render ++ ["then"] ++ body.render ++ ["end", "if", ";"]
  | .ifElsif firstTest firstBody nextTest nextBody =>
      ["if"] ++ firstTest.render ++ ["then"] ++ firstBody.render ++
      ["elsif"] ++ nextTest.render ++ ["then"] ++ nextBody.render ++ ["end", "if", ";"]
  | .localItem value body =>
      ["declare", "item", ":", "constant", "string", ":="] ++ value.render ++
      [";", "begin"] ++ body.render ++ ["end", ";"]

def Statement.execute {kind : Kind} (context : Context) : Statement kind → Result kind
  | .returnValue value | .returnRebased value =>
      match value.evaluate context with
      | some result => .returned result
      | none => .invalid
  | .sequence first next => (first.execute context).thenNext (next.execute context)
  | .ifThen test body =>
      match test.evaluate context with
      | some true => body.execute context
      | some false => .continued
      | none => .invalid
  | .ifElsif firstTest firstBody nextTest nextBody =>
      match firstTest.evaluate context with
      | some true => firstBody.execute context
      | some false =>
          match nextTest.evaluate context with
          | some true => nextBody.execute context
          | some false => .continued
          | none => .invalid
      | none => .invalid
  | .localItem value body =>
      match value.evaluate context with
      | some item => body.execute {context with localItem := some item}
      | none => .invalid

def validityProgram : Statement .boolean :=
  .sequence
    (.ifElsif (.countEquals 0) (.returnValue (.boolean true))
      (.countEquals 1) (.returnValue (.isMessage .argumentOne)))
    (.returnValue (.boolean false))

def initializerProgram : Statement .bytes :=
  .sequence
    (.ifElsif (.countEquals 0)
      (.ifThen (.isMessage .defaultValue) (.returnRebased .defaultValue))
      (.countEquals 1)
      (.localItem .argumentOne (.ifThen (.isMessage .localItem) (.returnRebased .localItem))))
    (.returnValue .empty)

/-- Independent case specification of valid process arguments. -/
def inputIsValid : Arguments → Bool
  | [] => true
  | [item] => message item
  | _ => false

/-- The empty value on an invalid input is internal: the mandatory Main guard
rejects that input before calling the output wrapper. -/
def firstOrDefault (defaultValue : Source) : Arguments → Source
  | [] => if message defaultValue then defaultValue else []
  | [item] => if message item then item else []
  | _ => []

theorem validity_refines (arguments : Arguments) (defaultValue : Source) :
    validityProgram.execute ⟨arguments, defaultValue, none⟩ = .returned (inputIsValid arguments) := by
  cases arguments with
  | nil => rfl
  | cons item rest =>
    cases rest with
    | nil => rfl
    | cons other rest =>
      simp [validityProgram, Statement.execute, Expr.evaluate, Result.thenNext, inputIsValid]

theorem initializer_refines (arguments : Arguments) (defaultValue : Source) :
    initializerProgram.execute ⟨arguments, defaultValue, none⟩ = .returned (firstOrDefault defaultValue arguments) := by
  cases arguments with
  | nil =>
    cases domain : message defaultValue <;>
      simp [initializerProgram, Statement.execute, Expr.evaluate, Result.thenNext, firstOrDefault, Option.map, domain]
  | cons item rest =>
    cases rest with
    | nil =>
      cases domain : message item <;>
        simp [initializerProgram, Statement.execute, Expr.evaluate, Result.thenNext, firstOrDefault, Option.map, domain]
    | cons other rest =>
      simp [initializerProgram, Statement.execute, Expr.evaluate, Result.thenNext, firstOrDefault]

inductive Effect | setExitStatus (status : Nat)

def Effect.render : Effect → List String
  | .setExitStatus status =>
      ["silver_output_libc", ".", "set_exit_status", "(", toString status, ")", ";"]

/-- Status assignment returns normally and writes no output. -/
def Effect.execute : Effect → Output.Runtime.ProcessResult
  | .setExitStatus status => ⟨status, []⟩

def rejectProgram : Effect := .setExitStatus 1

/-- Renderer for the complete owned body. The fixed declarations contain no
uninterpreted executable statements and no ghost slots to erase. -/
def renderedBody : List String :=
  ["with", "silver_runtime", ";", "with", "silver_output_libc", ";", "package", "body",
   "silver_arguments", "with", "spark_mode", "=>", "on", "is",
   "function", "is_message", "(", "item", ":", "string", ")", "return", "boolean", "is", "("] ++
  messagePredicate.render ++ [")", ";",
   "function", "input_is_valid", "return", "boolean", "is", "begin"] ++
  validityProgram.render ++ ["end", "input_is_valid", ";",
   "function", "first_or_default", "(", "default", ":", "string", ")", "return", "string", "is", "begin"] ++
  initializerProgram.render ++ ["end", "first_or_default", ";",
   "procedure", "reject", "is", "begin"] ++ rejectProgram.render ++
  ["end", "reject", ";", "end", "silver_arguments", ";"]

def outputMain (environment : Output.Runtime.Environment) (item : Source) : Output.Runtime.ProcessResult :=
  Output.Runtime.completeMain (Output.Runtime.execute environment item Output.Runtime.program [])

/-- Initialization precedes the branch, exactly as in the admitted Main. Both
queries use the same context and can neither modify nor refresh the argument
vector. Invalid interpreter results remain explicit instead of becoming output. -/
def executeMain (environment : Output.Runtime.Environment) (arguments : Arguments)
    (defaultValue : Source) : Option Output.Runtime.ProcessResult :=
  let context : Context := ⟨arguments, defaultValue, none⟩
  match initializerProgram.execute context, validityProgram.execute context with
  | .returned item, .returned valid =>
      some (if (valid : Bool) then outputMain environment item else rejectProgram.execute)
  | _, _ => none

theorem main_refines (environment : Output.Runtime.Environment) (arguments : Arguments)
    (defaultValue : Source) : executeMain environment arguments defaultValue =
    some (if inputIsValid arguments then outputMain environment (firstOrDefault defaultValue arguments)
      else ⟨1, []⟩) := by
  simp [executeMain, initializer_refines, validity_refines, rejectProgram, Effect.execute]

theorem initializer_domain (arguments : Arguments) (defaultValue : Source) :
    message (firstOrDefault defaultValue arguments) = true := by
  cases arguments with
  | nil =>
      cases domain : message defaultValue <;> simp [firstOrDefault, domain]
  | cons item rest =>
    cases rest with
    | nil => cases domain : message item <;> simp [firstOrDefault, domain]
    | cons other rest => simp [firstOrDefault]

theorem invalid_no_output (environment : Output.Runtime.Environment) (arguments : Arguments)
    (defaultValue : Source) (invalid : inputIsValid arguments = false) :
    executeMain environment arguments defaultValue = some ⟨1, []⟩ := by
  simp [main_refines, invalid]

theorem missing_uses_default (environment : Output.Runtime.Environment) (defaultValue : Source)
    (valid : message defaultValue = true) :
    executeMain environment [] defaultValue = some (outputMain environment defaultValue) := by
  simp [main_refines, inputIsValid, firstOrDefault, valid]

theorem single_uses_input (environment : Output.Runtime.Environment) (item defaultValue : Source)
    (valid : message item = true) :
    executeMain environment [item] defaultValue = some (outputMain environment item) := by
  simp [main_refines, inputIsValid, firstOrDefault, valid]

theorem explicit_empty_preserved (environment : Output.Runtime.Environment) (defaultValue : Source) :
    executeMain environment [[]] defaultValue = some (outputMain environment []) := by
  exact single_uses_input _ _ _ message_empty

theorem extra_arguments_rejected (environment : Output.Runtime.Environment)
    (first second defaultValue : Source) (rest : Arguments) :
    executeMain environment (first :: second :: rest) defaultValue = some ⟨1, []⟩ := by
  exact invalid_no_output _ _ _ rfl

theorem invalid_argument_rejected (environment : Output.Runtime.Environment) (item defaultValue : Source)
    (invalid : message item = false) :
    executeMain environment [item] defaultValue = some ⟨1, []⟩ := by
  exact invalid_no_output _ _ _ invalid

theorem oversized_rejected (environment : Output.Runtime.Environment) (item defaultValue : Source)
    (oversized : Output.Runtime.maxLength < item.length) :
    executeMain environment [item] defaultValue = some ⟨1, []⟩ := by
  apply invalid_argument_rejected
  cases domain : message item
  · rfl
  · have bounded := ((message_iff item).mp domain).1
    omega

theorem unsupported_byte_rejected (environment : Output.Runtime.Environment)
    (item defaultValue : Source) (byte : Nat) (member : byte ∈ item)
    (unsupported : byte < 32 ∨ 126 < byte) :
    executeMain environment [item] defaultValue = some ⟨1, []⟩ := by
  apply invalid_argument_rejected
  cases domain : message item
  · rfl
  · have printable := ((message_iff item).mp domain).2 byte member
    omega

theorem valid_healthy_output (environment : Output.Runtime.Environment)
    (healthy : Output.Runtime.Healthy environment) (arguments : Arguments) (defaultValue : Source)
    (valid : inputIsValid arguments = true) :
    executeMain environment arguments defaultValue =
      some ⟨0, firstOrDefault defaultValue arguments ++ [10]⟩ := by
  have domain := (message_iff _).mp (initializer_domain arguments defaultValue)
  have bytes : ∀ byte ∈ firstOrDefault defaultValue arguments, byte ≤ 255 := by
    intro byte member
    have printable := domain.2 byte member
    omega
  simp [main_refines, valid, outputMain,
    Output.Runtime.healthy_output environment healthy _ domain.1 bytes, Output.Runtime.completeMain]

theorem valid_output_failure (environment : Output.Runtime.Environment)
    (arguments : Arguments) (defaultValue accepted : Source) (status : Nat)
    (valid : inputIsValid arguments = true)
    (failed : Output.Runtime.execute environment (firstOrDefault defaultValue arguments)
      Output.Runtime.program [] = .failedReturn status accepted) :
    executeMain environment arguments defaultValue = some ⟨1, accepted⟩ ∧
      ∃ suffix, accepted ++ suffix = firstOrDefault defaultValue arguments ++ [10] := by
  obtain ⟨code, suffix⟩ := Output.Runtime.failed_output _ _ _ _ failed
  subst status
  exact ⟨by simp [main_refines, valid, outputMain, failed, Output.Runtime.completeMain], suffix⟩

/-- Every input reaches a modeled return under the completed-import premises.
The runtime can fail, but the interpreter never reaches an unsafe argument read. -/
theorem completed_main (environment : Output.Runtime.Environment) (arguments : Arguments)
    (defaultValue : Source) : ∃ result, executeMain environment arguments defaultValue = some result := by
  exact ⟨_, main_refines _ _ _⟩

theorem valid_output_success (environment : Output.Runtime.Environment)
    (arguments : Arguments) (defaultValue accepted : Source)
    (valid : inputIsValid arguments = true)
    (returned : Output.Runtime.execute environment (firstOrDefault defaultValue arguments)
      Output.Runtime.program [] = .returned accepted) :
    executeMain environment arguments defaultValue = some ⟨0, accepted⟩ ∧
      accepted = firstOrDefault defaultValue arguments ++ [10] ∧ environment.flushStatus = 0 := by
  have result := Output.Runtime.successful_output _ _ _ returned
  exact ⟨by simp [main_refines, valid, outputMain, returned, Output.Runtime.completeMain], result.2⟩

end Silver.Arguments.Runtime
