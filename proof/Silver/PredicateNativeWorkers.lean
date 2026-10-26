module

public import Silver.PredicateNativeSizing
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.Native.Workers
open Silver.SourceBridge

/-- Observable procedure outputs. An out buffer contributes only its fixed
extent. Its uninitialized contents are not an input. -/
structure Outputs where
  primary : Source → Context → Nat → ActiveFlow → Nat → ConditionResult
  relation : Source → Context → Nat → ActiveFlow → Nat → ConditionResult
  condition : Source → Context → Nat → ActiveFlow → Nat → ConditionResult
  chain : Source → Context → ConditionResult → ConditionResult

def primaryRhs : Expr .condition :=
  .callPrimary (.variable "text") (.variable "context") (.variable "position") (.variable "facts")

def relationRhs : Expr .condition :=
  .callRelation (.variable "text") (.variable "context") (.variable "position") (.variable "facts")

def conditionRhs : Expr .condition := conditionBody

/-- Contract locals are evaluated in the procedure entry state. -/
def chainRhs : Expr .condition :=
  .callTail (.variable "text") (.variable "context") (.old (.variable "result"))
    (.token .andKeyword) (.truth false)

abbrev InputDomain := Source → Context → Nat → ActiveFlow → Prop
abbrev ChainDomain := Source → Context → ConditionResult → Prop

/-- Equalities are the exact rendered Static postcondition right-hand sides.
The chosen domains are supplied by the native validity interface. -/
structure Refinement (legal : InputDomain) (chainLegal : ChainDomain)
    (calls : Native.Calls) (outputs : Outputs) : Prop where
  primary : ∀ text context position facts count, legal text context position facts → count = facts.count →
    outputs.primary text context position facts count =
      primaryRhs.eval calls ({text, context, position, facts} : Inputs).locals
  relation : ∀ text context position facts count, legal text context position facts → count = facts.count →
    outputs.relation text context position facts count =
      relationRhs.eval calls ({text, context, position, facts} : Inputs).locals
  condition : ∀ text context position facts count, legal text context position facts → count = facts.count →
    outputs.condition text context position facts count =
      conditionRhs.eval calls ({text, context, position, facts} : Inputs).locals
  chain : ∀ text context result, chainLegal text context result →
    outputs.chain text context result = chainRhs.eval calls ({text, context, result} : Inputs).locals

def observe (calls : Native.Calls) (outputs : Outputs) : Native.Calls :=
  {calls with condition := fun text context position facts =>
    outputs.condition text context position facts facts.count}

theorem condition_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts} (allowed : legal text context position facts) :
    (observe calls outputs).condition text context position facts = calls.model text context position facts :=
  verified.condition text context position facts facts.count allowed rfl

theorem primary_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts count} (allowed : legal text context position facts) (same : count = facts.count) :
    outputs.primary text context position facts count = calls.primary text context position facts :=
  verified.primary text context position facts count allowed same

theorem relation_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts count} (allowed : legal text context position facts) (same : count = facts.count) :
    outputs.relation text context position facts count = calls.relation text context position facts :=
  verified.relation text context position facts count allowed same

theorem chain_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context result} (allowed : chainLegal text context result) :
    outputs.chain text context result = calls.tail text context result .andKeyword false :=
  verified.chain text context result allowed

def modelOutputs (calls : Native.Calls) : Outputs where
  primary text context position facts _ := calls.primary text context position facts
  relation text context position facts _ := calls.relation text context position facts
  condition text context position facts _ := calls.model text context position facts
  chain text context result := calls.tail text context result .andKeyword false

theorem model_refinement (legal : InputDomain) (chainLegal : ChainDomain) (calls : Native.Calls) :
    Refinement legal chainLegal calls (modelOutputs calls) :=
  ⟨fun _ _ _ _ _ _ _ => rfl, fun _ _ _ _ _ _ _ => rfl,
    fun _ _ _ _ _ _ _ => rfl, fun _ _ _ _ => rfl⟩

def expectedTokens (source : String) : List String := (Source.lexLine source).getD []

def outputHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Result : out Condition_Result)"

def outputSpec (rhs : Expr .condition) (rank : Nat) : List String :=
  outputHeader ++ expectedTokens
    "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Result.Count = Facts.Count, Post => (Runtime => Valid_Condition (Context, Result) and then (Result.After = 0 or else Result.After in Position + 1 .. Text'Last + 1), Static => Result =" ++
  rhs.render ++ expectedTokens
    ("), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => " ++ toString rank ++ ")")

def chainHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Result : in out Condition_Result)"

def chainSpec : List String :=
  chainHeader ++ expectedTokens
    "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Result.After in 1 .. Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Condition (Context, Result) and then Chain_Token (Text, Result.After) in And_Keyword | Or_Keyword, Post => (Runtime => Valid_Condition (Context, Result) and then (Result.After = 0 or else Result.After in Result.After'Old .. Text'Last + 1), Static => Result =" ++
  chainRhs.render ++ expectedTokens
    "), Subprogram_Variant => (Decreases => (Text'Last + 1) - Result.After, Decreases => 4)"

structure Checked (tokens : List String) : Prop where
  primarySpec : procedureHeader "read_primary_into" ";" tokens = some (outputSpec primaryRhs 1)
  primaryBody : procedureHeader "read_primary_into" "is" tokens = some outputHeader
  relationSpec : procedureHeader "read_relation_into" ";" tokens = some (outputSpec relationRhs 2)
  relationBody : procedureHeader "read_relation_into" "is" tokens = some outputHeader
  conditionSpec : procedureHeader "read_condition_into" ";" tokens = some (outputSpec conditionRhs 5)
  conditionBody : procedureHeader "read_condition_into" "is" tokens = some outputHeader
  chainSpec : procedureHeader "read_chain_into" ";" tokens = some chainSpec
  chainBody : procedureHeader "read_chain_into" "is" tokens = some chainHeader

end Silver.Predicate.Native.Workers
