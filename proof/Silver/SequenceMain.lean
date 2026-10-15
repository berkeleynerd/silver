module

public import Silver.SequenceSelectors
public import Silver.SequenceExecution
public import Silver.SequenceEffects

@[expose] public section

/-! The decoded statement tree retains the source's exact sequential order and
if/then/else structure. Token readings keep expression and assignment payloads,
not merely their safety properties. The independent checked execution then
refines that tree, including assignment state changes and returning output calls.
Ada frontend interpretation of these ordinary constructs remains the documented
external premise; this module does not model the GNAT frontend. -/

namespace Silver.Sequence
open Compose

def SimpleStatement.tokens : SimpleStatement → List ShellToken
  | .null => [.word "null", .symbol ";"]
  | .assign _ => assignmentTokens .assignmentTarget
  | .output _ => outputTokens
  | .put _ => [.word "silver_io", .symbol ".", .word "put", .symbol "(", .outputExpression, .symbol ")", .symbol ";"]

def SimpleStatement.events : SimpleStatement → List Event
  | .null => []
  | .assign update => [.assignment update]
  | .output expression | .put expression => [.output expression]

mutual
  def Statement.tokens : Statement → List ShellToken
    | .simple item => item.tokens
    | .choice _ _ yes tail => equalityTokens ++ statementsTokens yes ++ tail.tokens ++ endIfTokens
  termination_by item => sizeOf item
  def Alternative.tokens : Alternative → List ShellToken
    | .absent => []
    | .otherwise items => [.word "else"] ++ statementsTokens items
    | .elsif _ _ yes tail => elsifTokens ++ statementsTokens yes ++ tail.tokens
  termination_by tail => sizeOf tail
  def statementsTokens : List Statement → List ShellToken
    | [] => []
    | item :: rest => item.tokens ++ statementsTokens rest
  termination_by items => sizeOf items
end

mutual
  def Statement.events : Statement → List Event
    | .simple item => item.events
    | .choice left right yes tail => [.comparison left right] ++ statementsEvents yes ++ tail.events
  termination_by item => sizeOf item
  def Alternative.events : Alternative → List Event
    | .absent => []
    | .otherwise items => statementsEvents items
    | .elsif left right yes tail => [.comparison left right] ++ statementsEvents yes ++ tail.events
  termination_by tail => sizeOf tail
  def statementsEvents : List Statement → List Event
    | [] => []
    | item :: rest => item.events ++ statementsEvents rest
  termination_by items => sizeOf items
end

theorem statementsTokens_eq_flatMap (items : List Statement) :
    statementsTokens items = items.flatMap Statement.tokens := by
  induction items with
  | nil => simp only [statementsTokens, List.flatMap_nil]
  | cons item rest ih => simp only [statementsTokens, List.flatMap_cons, ih]

theorem statementsEvents_eq_flatMap (items : List Statement) :
    statementsEvents items = items.flatMap Statement.events := by
  induction items with
  | nil => simp only [statementsEvents, List.flatMap_nil]
  | cons item rest ih => simp only [statementsEvents, List.flatMap_cons, ih]

theorem tokens_append {text form first second state middle final left right}
    (a : TokensAt text form first state left middle)
    (b : TokensAt text form second middle right final) :
    TokensAt text form (first ++ second) state (left ++ right) final := by
  induction a with
  | done => exact b
  | next head _ ih =>
      simpa only [List.cons_append, List.append_assoc] using TokensAt.next head (ih b)

theorem basic_source_tokens {text scan item next} (parsed : BasicAt text scan item next) :
    TokensAt text .direct item.tokens scan.state item.events next.state := by
  obtain ⟨events, tokens, decoded⟩ := parsed.reading
  generalize basicKind text scan = kind at tokens decoded
  cases decoded <;> exact tokens

theorem tail_source_tokens {text : Source} {read : ScanResult → ScanResult} {stop : BodyStop}
    {Reading : ScanResult → α → ScanResult → Prop}
    (tokens : α → List ShellToken) (events : α → List Event)
    (sourceTokens : ∀ {scan item next}, Reading scan item next →
      TokensAt text .direct (tokens item) scan.state (events item) next.state)
    {scan final : ScanResult} {items : List α}
    (parsed : TailAt text read stop Reading scan items final) :
    TokensAt text .direct (items.flatMap tokens) scan.state (items.flatMap events) final.state := by
  induction parsed with
  | done positive _ => exact .done positive
  | next _ _ first _ _ _ ih => exact tokens_append (sourceTokens first) ih

theorem nonempty_source_tokens {text : Source} {read : ScanResult → ScanResult} {stop : BodyStop}
    {Reading : ScanResult → α → ScanResult → Prop}
    (tokens : α → List ShellToken) (events : α → List Event)
    (sourceTokens : ∀ {scan item next}, Reading scan item next →
      TokensAt text .direct (tokens item) scan.state (events item) next.state)
    {scan final : ScanResult} {items : List α}
    (parsed : NonemptyAt text read stop Reading scan items final) :
    TokensAt text .direct (items.flatMap tokens) scan.state (items.flatMap events) final.state := by
  cases parsed with
  | cons first _ following =>
      exact tokens_append (sourceTokens first)
        (tail_source_tokens tokens events sourceTokens following)

theorem basicList_source_tokens {text scan stop items final}
    (parsed : BasicListAt text scan stop items final) :
    TokensAt text .direct (items.flatMap SimpleStatement.tokens) scan.state
      (items.flatMap SimpleStatement.events) final.state :=
  nonempty_source_tokens SimpleStatement.tokens SimpleStatement.events basic_source_tokens parsed

mutual
  theorem statement_source_tokens {text scan item next} (parsed : StatementAt text scan item next) :
      TokensAt text .direct item.tokens scan.state item.events next.state := by
    cases parsed with
    | simple _ basic =>
        simpa only [Statement.tokens, Statement.events] using basic_source_tokens basic
    | conditional _ choice => exact conditional_source_tokens choice
  termination_by (sizeOf item, 1)
  decreasing_by all_goals subst_vars <;> exact Prod.Lex.right _ (by decide)

  theorem conditional_source_tokens {text scan item next} (parsed : ConditionalAt text scan item next) :
      TokensAt text .direct item.tokens scan.state item.events next.state := by
    cases parsed with
    | choice _ comparison _ yes tail ending =>
        have reading := tokens_append (tokens_append (tokens_append
          comparison (body_source_tokens yes)) (alternative_source_tokens tail)) ending
        simpa only [Statement.tokens, Statement.events, statementsTokens_eq_flatMap,
          statementsEvents_eq_flatMap, List.append_nil] using reading
  termination_by (sizeOf item, 0)

  theorem alternative_source_tokens {text scan item next} (parsed : AlternativeAt text scan item next) :
      TokensAt text .direct item.tokens scan.state item.events next.state := by
    cases parsed with
    | absent positive _ _ _ =>
        simpa only [Alternative.tokens, Alternative.events] using
          (TokensAt.done (text := text) (form := Compose.Form.direct) positive)
    | otherwise _ _ _ _ token items =>
        simpa only [Alternative.tokens, Alternative.events, statementsTokens_eq_flatMap,
          statementsEvents_eq_flatMap, List.nil_append] using
          tokens_append token (body_source_tokens items)
    | elsif _ _ _ comparison yes tail =>
        simpa only [Alternative.tokens, Alternative.events, statementsTokens_eq_flatMap,
          statementsEvents_eq_flatMap] using
          tokens_append (tokens_append comparison (body_source_tokens yes)) (alternative_source_tokens tail)
  termination_by (sizeOf item, 0)

  theorem body_source_tokens {text scan stop items final} (parsed : BodyAt text scan stop items final) :
      TokensAt text .direct (items.flatMap Statement.tokens) scan.state
        (items.flatMap Statement.events) final.state := by
    cases parsed with
    | cons _ first following => exact tokens_append (statement_source_tokens first) (tailBody_source_tokens following)
  termination_by (sizeOf items, 0)

  theorem tailBody_source_tokens {text scan stop items final} (parsed : TailBodyAt text scan stop items final) :
      TokensAt text .direct (items.flatMap Statement.tokens) scan.state
        (items.flatMap Statement.events) final.state := by
    cases parsed with
    | done positive _ => exact .done positive
    | next _ _ _ first following => exact tokens_append (statement_source_tokens first) (tailBody_source_tokens following)
  termination_by (sizeOf items, 0)
end

theorem statements_source_tokens {text scan stop items final}
    (parsed : StatementsAt text scan stop items final) :
    TokensAt text .direct (items.flatMap Statement.tokens) scan.state
      (items.flatMap Statement.events) final.state :=
  body_source_tokens parsed

/-- Source syntax with the decoded body rendered back into its token skeleton.
Payload events retain all expression trees, targets, and source branch order. -/
def MainReading (source : Source) (program : Program) : Prop :=
  ∃ form events, SourceDomain source ∧ selectedForm source = some form ∧
    TokensAt source form.helper form.prefix initialState events (prefixScan source form).state ∧
    decodePrefix form events program.body.statements = some program ∧
    TokensAt source .direct (program.body.statements.flatMap Statement.tokens)
      (prefixScan source form).state (program.body.statements.flatMap Statement.events)
      (bodyScan source form).state ∧
    (∃ footerEvents, TokensAt source form.helper form.footer (bodyScan source form).state
      footerEvents (finalScan source form).state) ∧
    Cursor.triviaPosition source (finalScan source form).state.position = source.length + 1

theorem source_main_reading {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : MainReading source program := by
  obtain ⟨form, events, items, domain, selected, parsed, decoded⟩ := meaning
  have body := (decoded_body decoded).1
  refine ⟨form, events, domain, selected, parsed.header, ?_, ?_, parsed.footer, parsed.finished⟩
  · simpa only [body] using decoded
  · simpa only [body] using statements_source_tokens parsed.statements

/-- Source control-flow structure, initialized fixed-shape safety, and ordinary
checked execution refer to the same uniquely decoded program. -/
theorem authoritative_main_correct {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    MainReading source program ∧ program.Valid ∧
      (∀ arguments, program.checkedExecute arguments = some (program.execute arguments)) ∧
      hasArguments source = program.body.shell.hasArguments ∧
      hasAssignment source = program.body.hasAssignment ∧ hasOutput source = program.body.hasOutput :=
  ⟨source_main_reading meaning, meaning_valid meaning,
    program_execution_refines (meaning_valid meaning), meaning_selectors meaning⟩

/-- Every completed call contributes its own outcome, including calls following
failure; the actual cumulative bound scales with the number of output calls. -/
theorem source_execution_specified {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Environment) :
    SpecifiedOutcome environment program (execute environment program) ∧
      (execute environment program).accepted.length ≤
        outputCount (program.effects environment.arguments) * (maxSourceLength + 1) :=
  ⟨execution_specified environment program,
    accepted_effects_bound environment.output 0
      (program_execution_valid (meaning_valid meaning) environment.arguments).2⟩

end Silver.Sequence
