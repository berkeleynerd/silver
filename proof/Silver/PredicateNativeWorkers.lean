module

public import Silver.PredicateNativeSizing
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.Native.Workers
open Silver.SourceBridge

/-- Observable procedure outputs. The out buffer supplies its fixed extent;
Initials and Incoming retain their distinct immutable input roles. -/
structure Outputs where
  primary : Source → Context → Nat → ActiveFlow → Nat → ArrayBindings.Initials → ConditionResult
  booleanFactor : Source → Context → Nat → ActiveFlow → Nat → ArrayBindings.Initials → ConditionResult
  booleanRelation : Source → Context → Nat → ActiveFlow → Nat → ArrayBindings.Initials → ConditionResult
  relation : Source → Context → Nat → ActiveFlow → Nat → ArrayBindings.Initials → ConditionResult
  condition : Source → Context → Nat → ActiveFlow → Nat → ArrayBindings.Initials → ConditionResult
  chain : Source → Context → ConditionResult → ActiveFlow → ArrayBindings.Initials → ConditionResult

def primaryRhs : Expr .condition :=
  .callPrimary (.variable "text") (.variable "context") (.variable "position") (.variable "facts") (.variable "initials")

def booleanFactorRhs : Expr .condition :=
  .callBooleanFactor (.variable "text") (.variable "context") (.variable "position") (.variable "facts") (.variable "initials")

def booleanRelationRhs : Expr .condition :=
  .callBooleanRelation (.variable "text") (.variable "context") (.variable "position") (.variable "facts") (.variable "initials")

def relationRhs : Expr .condition :=
  .callRelation (.variable "text") (.variable "context") (.variable "position") (.variable "facts") (.variable "initials")

def conditionRhs : Expr .condition := conditionBody

def chainRhs : Expr .condition :=
  .callTail (.variable "text") (.variable "context") (.old (.variable "result"))
    (.chain .shortAnd) (.truth false) (.variable "initials") (.variable "incoming")

abbrev InputDomain := Source → Context → Nat → ActiveFlow → Prop
abbrev ChainDomain := Source → Context → ConditionResult → ActiveFlow → Prop

/-- Exact Static postcondition equations on the native precondition domains.
ValidInitials interprets the fixed Element_Array type, separately from Ada Pre;
no source-allocated or initialized-prefix restriction is imposed. -/
structure Refinement (legal : InputDomain) (chainLegal : ChainDomain)
    (calls : Native.Calls) (outputs : Outputs) : Prop where
  primary : ∀ text context position facts count initials, legal text context position facts → ArrayBindings.ValidInitials initials → count = facts.count →
    outputs.primary text context position facts count initials =
      primaryRhs.eval calls ({text, context, position, facts, initials} : Inputs).locals
  booleanFactor : ∀ text context position facts count initials, legal text context position facts → ArrayBindings.ValidInitials initials → count = facts.count →
    outputs.booleanFactor text context position facts count initials =
      booleanFactorRhs.eval calls ({text, context, position, facts, initials} : Inputs).locals
  booleanRelation : ∀ text context position facts count initials, legal text context position facts → ArrayBindings.ValidInitials initials → count = facts.count →
    outputs.booleanRelation text context position facts count initials =
      booleanRelationRhs.eval calls ({text, context, position, facts, initials} : Inputs).locals
  relation : ∀ text context position facts count initials, legal text context position facts → ArrayBindings.ValidInitials initials → count = facts.count →
    outputs.relation text context position facts count initials =
      relationRhs.eval calls ({text, context, position, facts, initials} : Inputs).locals
  condition : ∀ text context position facts count initials, legal text context position facts → ArrayBindings.ValidInitials initials → count = facts.count →
    outputs.condition text context position facts count initials =
      conditionRhs.eval calls ({text, context, position, facts, initials} : Inputs).locals
  chain : ∀ text context result incoming initials, chainLegal text context result incoming → ArrayBindings.ValidInitials initials →
    outputs.chain text context result incoming initials =
      chainRhs.eval calls ({text, context, result, incoming, initials} : Inputs).locals

def observe (calls : Native.Calls) (outputs : Outputs) : Native.Calls :=
  {calls with condition := fun text context position facts initials =>
    outputs.condition text context position facts facts.count initials}

theorem condition_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts initials} (allowed : legal text context position facts) (iv : ArrayBindings.ValidInitials initials) :
    (observe calls outputs).condition text context position facts initials = calls.model text context position facts initials :=
  verified.condition text context position facts facts.count initials allowed iv rfl

theorem primary_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts count initials} (allowed : legal text context position facts) (iv : ArrayBindings.ValidInitials initials) (same : count = facts.count) :
    outputs.primary text context position facts count initials = calls.primary text context position facts initials :=
  verified.primary text context position facts count initials allowed iv same

theorem booleanFactor_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts count initials} (allowed : legal text context position facts) (iv : ArrayBindings.ValidInitials initials) (same : count = facts.count) :
    outputs.booleanFactor text context position facts count initials = calls.booleanFactor text context position facts initials :=
  verified.booleanFactor text context position facts count initials allowed iv same

theorem booleanRelation_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts count initials} (allowed : legal text context position facts) (iv : ArrayBindings.ValidInitials initials) (same : count = facts.count) :
    outputs.booleanRelation text context position facts count initials = calls.booleanRelation text context position facts initials :=
  verified.booleanRelation text context position facts count initials allowed iv same

theorem relation_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context position facts count initials} (allowed : legal text context position facts) (iv : ArrayBindings.ValidInitials initials) (same : count = facts.count) :
    outputs.relation text context position facts count initials = calls.relation text context position facts initials :=
  verified.relation text context position facts count initials allowed iv same

theorem chain_refines {legal chainLegal calls outputs}
    (verified : Refinement legal chainLegal calls outputs)
    {text context result incoming initials} (allowed : chainLegal text context result incoming) (iv : ArrayBindings.ValidInitials initials) :
    outputs.chain text context result incoming initials = calls.tail text context result .shortAnd false initials incoming :=
  verified.chain text context result incoming initials allowed iv

def modelOutputs (calls : Native.Calls) : Outputs where
  primary text context position facts _ initials := calls.primary text context position facts initials
  booleanFactor text context position facts _ initials := calls.booleanFactor text context position facts initials
  booleanRelation text context position facts _ initials := calls.booleanRelation text context position facts initials
  relation text context position facts _ initials := calls.relation text context position facts initials
  condition text context position facts _ initials := calls.model text context position facts initials
  chain text context result incoming initials := calls.tail text context result .shortAnd false initials incoming

theorem model_refinement (legal : InputDomain) (chainLegal : ChainDomain) (calls : Native.Calls) :
    Refinement legal chainLegal calls (modelOutputs calls) := by
  constructor <;> intros <;> rfl

def expectedTokens (source : String) : List String := (Source.lexLine source).getD []

def outputHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Result : out Condition_Result; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)"

def outputSpec (rhs : Expr .condition) (rank : Nat) : List String :=
  outputHeader ++ expectedTokens
    "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Result.Count = Facts.Count, Post => (Runtime => Valid_Condition (Context, Result) and then (Result.After = 0 or else Result.After in Position + 1 .. Text'Last + 1), Static => Result =" ++
  rhs.render ++ expectedTokens
    ("), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => " ++ toString rank ++ ")")

def chainHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Result : in out Condition_Result; Incoming : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)"

def chainSpec : List String :=
  chainHeader ++ expectedTokens
    "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Result.After in 1 .. Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Condition (Context, Result) and then Valid_Flow (Context, Incoming) and then Incoming.Count = Result.Count and then Chain_Token (Text, Result.After) /= No_Chain, Post => (Runtime => Valid_Condition (Context, Result) and then (Result.After = 0 or else Result.After in Result.After'Old .. Text'Last + 1), Static => Result =" ++
  chainRhs.render ++ expectedTokens
    "), Subprogram_Variant => (Decreases => (Text'Last + 1) - Result.After, Decreases => 6)"

structure Checked (tokens : List String) : Prop where
  primarySpec : procedureHeader "read_primary_into" ";" tokens = some (outputSpec primaryRhs 1)
  primaryBody : procedureHeader "read_primary_into" "is" tokens = some outputHeader
  booleanFactorSpec : procedureHeader "read_boolean_factor_into" ";" tokens = some (outputSpec booleanFactorRhs 2)
  booleanFactorBody : procedureHeader "read_boolean_factor_into" "is" tokens = some outputHeader
  booleanRelationSpec : procedureHeader "read_boolean_relation_into" ";" tokens = some (outputSpec booleanRelationRhs 3)
  booleanRelationBody : procedureHeader "read_boolean_relation_into" "is" tokens = some outputHeader
  relationSpec : procedureHeader "read_relation_into" ";" tokens = some (outputSpec relationRhs 4)
  relationBody : procedureHeader "read_relation_into" "is" tokens = some outputHeader
  conditionSpec : procedureHeader "read_condition_into" ";" tokens = some (outputSpec conditionRhs 7)
  conditionBody : procedureHeader "read_condition_into" "is" tokens = some outputHeader
  chainSpec : procedureHeader "read_chain_into" ";" tokens = some chainSpec
  chainBody : procedureHeader "read_chain_into" "is" tokens = some chainHeader

end Silver.Predicate.Native.Workers
