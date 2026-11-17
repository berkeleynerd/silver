module

public import Silver.PredicateProcedureCallEquations
public import Silver.ComposeBooleanDeclarationSource
public import Silver.PathNativeModel

@[expose] public section

/-! The bounded Static identity helper added to Procedure_Updates. Its source
call retains both complete model applications. Erasure introduces no equation,
successful-state hypothesis or assumption about the recursive callees. -/
namespace Silver.Predicate.ProcedureCallNative.BodyEquality
open Silver.SourceBridge

/-- Retain dormant native path bounds as well as every constrained vector cell.
Using ActiveFlow here would lose Lower/Upper when Valid_Reachable is false. -/
structure RawFlow where
  path : PathFacts.Native.Context
  values : List Integer.Interval
  deriving DecidableEq

def RawFlow.count (flow : RawFlow) : Nat := flow.values.length
def RawFlow.project (flow : RawFlow) : ActiveFlow := ⟨flow.path.model, flow.values⟩

structure RawBody where
  position : Nat
  target : Nat
  capacity : Nat
  facts : RawFlow
  assigned : Bool
  output : Bool
  deriving DecidableEq

def RawBody.count (body : RawBody) : Nat := body.facts.count
def RawBody.project (body : RawBody) : BodyScan :=
  ⟨body.position, body.target, body.capacity, body.facts.project, body.assigned, body.output⟩

theorem projected_count (body : RawBody) : body.project.count = body.count := rfl

inductive Clause | count | facts | position | target | capacity | assigned | output
  deriving DecidableEq

def Clause.render : Clause → List String
  | .facts => expectedTokens "Same_Flow (Left.Facts, Right.Facts)"
  | .count => expectedTokens "Left.Count = Right.Count"
  | .position => expectedTokens "Left.Position = Right.Position"
  | .target => expectedTokens "Left.Target = Right.Target"
  | .capacity => expectedTokens "Left.Capacity = Right.Capacity"
  | .assigned => expectedTokens "Left.Assigned = Right.Assigned"
  | .output => expectedTokens "Left.Output = Right.Output"

/-- Same_Flow is the existing native Logical_Equal callee, whose complete
contracts and implementation remain independently verified. Its raw storage
retains all five native path fields and every native 1 .. Count cell. -/
def Clause.eval (sameFlow : RawFlow → RawFlow → Bool)
    (left right : RawBody) : Clause → Bool
  | .count => decide (left.count = right.count)
  | .facts => sameFlow left.facts right.facts
  | .position => decide (left.position = right.position)
  | .target => decide (left.target = right.target)
  | .capacity => decide (left.capacity = right.capacity)
  | .assigned => decide (left.assigned = right.assigned)
  | .output => decide (left.output = right.output)

def clauses : List Clause := [.count, .facts, .position, .target, .capacity, .assigned, .output]
def rendered : List String := (clauses.map Clause.render |>.intersperse ["and", "then"]).flatten
def eval (sameFlow : RawFlow → RawFlow → Bool) (left right : RawBody) : Bool :=
  clauses.all (Clause.eval sameFlow left right)

/-- Count, complete path record and the complete constrained vector. Native
vector bounds are fixed to 1 .. Count; list equality therefore covers every
native cell, including the empty vector, without inventing inactive values. -/
def modelSameFlow (left right : RawFlow) : Bool :=
  decide (left.count = right.count) && decide (left.path = right.path) &&
    decide (left.values = right.values)

theorem modelSameFlow_meaning (left right : RawFlow) :
    modelSameFlow left right = decide (left = right) := by
  apply Bool.eq_iff_iff.mpr
  simp only [modelSameFlow, Bool.and_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨⟨_, path⟩, values⟩
    cases left
    cases right
    simp_all
  · intro equal
    subst right
    simp

/-- No Valid_Body or nonempty-count restriction: all fields of arbitrary native
record interpretations participate, including invalid positions and Count = 0. -/
theorem meaning (sameFlow : RawFlow → RawFlow → Bool)
    (flowMeaning : ∀ left right, sameFlow left right = decide (left = right))
    (left right : RawBody) : eval sameFlow left right = decide (left = right) := by
  apply Bool.eq_iff_iff.mpr
  simp only [eval, clauses, List.all_cons, List.all_nil, Bool.and_true,
    Bool.and_eq_true, Clause.eval, flowMeaning, decide_eq_true_eq]
  constructor
  · rintro ⟨_, facts, position, target, capacity, assigned, output⟩
    cases left
    cases right
    simp_all
  · intro equal
    subst right
    simp

/-- Full native helper contract, under exactly its raw equality precondition. -/
theorem contract (sameFlow : RawFlow → RawFlow → Bool)
    (flowMeaning : ∀ left right, sameFlow left right = decide (left = right))
    (left right : RawBody) (equal : left = right) :
    eval sameFlow left right = true ∧ left = right := by
  rw [meaning sameFlow flowMeaning]
  exact ⟨by simp [equal], equal⟩

theorem model_contract (left right : RawBody) (equal : left = right) :
    eval modelSameFlow left right = true ∧ left = right :=
  contract modelSameFlow modelSameFlow_meaning left right equal

/-- Equality projects forward. The converse is deliberately absent because
unreachable native Lower/Upper fields are erased by the path projection. -/
theorem projection_preserved (left right : RawBody)
    (same : eval modelSameFlow left right = true) : left.project = right.project := by
  rw [meaning modelSameFlow modelSameFlow_meaning] at same
  exact congrArg RawBody.project (of_decide_eq_true same)

/-- Regression for the exact noninjective path projection: both native Count=0
records project identically, but their dormant native bounds remain unequal. -/
theorem dormant_bounds_distinguished :
    let left : RawBody := ⟨0, 0, 0, ⟨⟨0, 0, false, false, true⟩, []⟩, false, false⟩
    let right : RawBody := ⟨0, 0, 0, ⟨⟨1, 1, false, false, true⟩, []⟩, false, false⟩
    left.project = right.project ∧ eval modelSameFlow left right = false := by
  decide +kernel

/-- The native vector has exactly 1 .. Count cells. This storage view retains
arbitrary functions only to enumerate those cells; no outside cell is native. -/
structure RawStorage where
  count : Nat
  path : PathFacts.Native.Context
  values : Nat → Integer.Interval

def RawStorage.active (storage : RawStorage) : RawFlow :=
  ⟨storage.path, List.ofFn fun index : Fin storage.count => storage.values (index.val + 1)⟩

theorem RawStorage.active_count (storage : RawStorage) : storage.active.count = storage.count := by
  simp [RawStorage.active, RawFlow.count]

theorem RawStorage.active_ext (left right : RawStorage) (size : left.count = right.count)
    (path : left.path = right.path)
    (cells : ∀ index, 1 ≤ index → index ≤ left.count → left.values index = right.values index) :
    left.active = right.active := by
  cases left with
  | mk leftCount leftPath leftValues =>
    cases right with
    | mk rightCount rightPath rightValues =>
      dsimp only at size path cells
      subst rightCount
      subst rightPath
      unfold RawStorage.active
      congr 1
      apply congrArg List.ofFn
      funext index
      exact cells (index.val + 1) (Nat.succ_pos _) (Nat.succ_le_of_lt index.isLt)

/-- Native Body_Scan constrains Facts by its Count discriminant, and Facts.Values
has exactly 1 .. Count bounds. The list representation includes every such cell;
the count is derived from this store, not assumed positive or independently lost. -/
def fromStorage (facts : RawStorage) (position target capacity : Nat)
    (assigned output : Bool) : RawBody :=
  ⟨position, target, capacity, facts.active, assigned, output⟩

theorem fromStorage_count (facts : RawStorage) (position target capacity : Nat)
    (assigned output : Bool) :
    (fromStorage facts position target capacity assigned output).count = facts.count :=
  facts.active_count

theorem fromStorage_ext (left right : RawStorage) (size : left.count = right.count)
    (path : left.path = right.path)
    (cells : ∀ index, 1 ≤ index → index ≤ left.count → left.values index = right.values index)
    (position target capacity : Nat) (assigned output : Bool) :
    fromStorage left position target capacity assigned output =
      fromStorage right position target capacity assigned output := by
  unfold fromStorage
  rw [RawStorage.active_ext left right size path cells]

/-- This node names only Lemma_Body_Equality; it is not a generic ignored call. -/
structure StaticCall where
  left : Expr .scan
  right : Expr .scan

def StaticCall.render (call : StaticCall) : List String :=
  ["lemma_body_equality", "("] ++ call.left.render ++ [","] ++ call.right.render ++ [")", ";"]
def StaticCall.wellFormed (call : StaticCall) : Bool :=
  call.left.value && call.right.value && call.left.wellFormed && call.right.wellFormed
def StaticCall.scoped (call : StaticCall) (scope : Scope) : Bool :=
  call.left.scoped scope && call.right.scoped scope
def StaticCall.eval (_call : StaticCall) (calls : Calls) (locals : Locals)
    (continuation : Command ty) : ty.meaning := continuation.eval calls locals

theorem static_call_erased (call : StaticCall) (calls : Calls) (locals : Locals)
    (continuation : Command ty) :
    call.eval calls locals continuation = continuation.eval calls locals := rfl

def updatesCall : StaticCall :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let scan : Expr .scan := .variable "scan"
  let catalog : Expr .metadata := .variable "catalog"
  let last : Expr .number := .variable "last"
  let callFirst : Expr .number := .variable "call_first"
  let callAfter : Expr .number := .variable "call_after"
  ⟨apply9 (.function .updatesModel) text context (.field .scanFacts scan) scan catalog
      (.variable "first") last callFirst callAfter,
   apply12 (.function .updatesTail) text context (.field .scanFacts scan) (.variable "current") catalog
      (.variable "first") last (.variable "index") (.variable "named") (.variable "seen") callFirst callAfter⟩

def updatesScope : Scope :=
  [(.source, "text"), (.context, "context"), (.scan, "scan"), (.scan, "current"),
   (.metadata, "catalog"), (.number, "first"), (.number, "index"), (.number, "last"),
   (.number, "call_first"), (.number, "call_after"), (.truth, "named"), (.formalSet, "seen")]

theorem updates_call_checked :
    updatesCall.wellFormed = true ∧ updatesCall.scoped updatesScope = true ∧
    (StaticCall.mk (.beginValue updatesCall.left) updatesCall.right).wellFormed = false ∧
    updatesCall.scoped (updatesScope.filter (fun entry => entry.2 != "scan")) = false ∧
    updatesCall.scoped (updatesScope.filter (fun entry => entry.2 != "current")) = false := by
  decide +kernel

def sameBodyHeader : List String := expectedTokens "(Left, Right : Body_Scan) return Boolean"
def sameBodyAspects : List String := expectedTokens
  "with Ghost => Static, Global => null, Annotate => (GNATprove, Logical_Equal)"
def lemmaHeader : List String := expectedTokens
  "(Left, Right : Body_Scan) with Ghost => Static, Global => null, Pre => Left = Right, Post => Same_Body (Left, Right) and then Left = Right"
def lemmaBody : List String := expectedTokens
  "begin Lemma_Flow_Equality (Left.Facts, Right.Facts); end Lemma_Body_Equality;"

/-- Retain the complete named procedure body; no token or assertion is erased
by extraction. Only the checked Ghost aspect authorizes runtime erasure. -/
def ordinaryBodies : List String → List (List String)
  | [] => []
  | "procedure" :: name :: tokens =>
      let later := ordinaryBodies (name :: tokens)
      if name == "lemma_body_equality" then
        match headerEnd 0 tokens with
        | some (header, "is") =>
            match Compose.BooleanDeclarationNative.SourceChecks.throughEnd name
                (tokens.drop (header.length + 1)) with
            | some body => body :: later
            | none => later
        | _ => later
      else later
  | _ :: tokens => ordinaryBodies tokens

def ordinaryBody (tokens : List String) : Option (List String) :=
  match ordinaryBodies tokens with | [body] => some body | _ => none

structure Checked (tokens : List String) : Prop where
  sameHeader : functionHeader "same_body" "is" tokens = some sameBodyHeader
  sameBody : expressionDeclaration "same_body" tokens = some (rendered, sameBodyAspects)
  lemmaHeader : procedureHeader "lemma_body_equality" "is" tokens = some lemmaHeader
  lemmaBody : ordinaryBody tokens = some lemmaBody

end Silver.Predicate.ProcedureCallNative.BodyEquality
