module

public import Silver.PredicateFunctionCallEquations
public import Silver.PredicateScalarBodyHelpers
public import Silver.PredicateBooleanBodyHelpers
public import Silver.FunctionBindingsSourceBridge
public import Silver.PredicateNativeRanges

@[expose] public section

namespace Silver.Predicate.FunctionCallNative
open Compose FunctionBindings

abbrev CursorDomain := ScalarBodyNative.CursorDomain
abbrev TargetDomain := ScalarBodyNative.TargetDomain
abbrev ReadDomain := BooleanBodyNative.ReadDomain
abbrev AssignmentDomain := ScalarBodyNative.AssignmentDomain

def ArrayLookupDomain (text : Source) (names : ArrayBindings.Metadata) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ ArrayBindings.ValidMetadata text names ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def FunctionLookupDomain (text : Source) (catalog : Metadata) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ ValidMetadata text catalog ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def callTokens : List ShellToken :=
  [.symbol "(", .symbol ")", .symbol ",", .symbol ":="]

def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  CursorDomain text position ∧ token ∈ callTokens

/-- Every helper equation uses its native input domain. Imported functions
remain arbitrary; model values outside those domains only totalize the formal
interpretation. Native proof must establish legality of every executed call. -/
structure ImportsMeaning (imports : Imports) : Prop where
  skip : ∀ text position, CursorDomain text position →
    imports.skip text position = modelImports.skip text position
  nameAfter : ∀ text position, CursorDomain text position →
    imports.nameAfter text position = modelImports.nameAfter text position
  namesLookup : ∀ text names first after, ScalarBodyNative.StringLookupDomain text names first after →
    imports.namesLookup text names first after = modelImports.namesLookup text names first after
  scalarLookup : ∀ text names first after, ScalarBodyNative.LookupDomain text names first after →
    imports.scalarLookup text names first after = modelImports.scalarLookup text names first after
  booleanLookup : ∀ text names first after, BooleanBodyNative.BooleanLookupDomain text names first after →
    imports.booleanLookup text names first after = modelImports.booleanLookup text names first after
  arrayLookup : ∀ text names first after, ArrayLookupDomain text names first after →
    imports.arrayLookup text names first after = modelImports.arrayLookup text names first after
  functionLookup : ∀ text catalog first after, FunctionLookupDomain text catalog first after →
    imports.functionLookup text catalog first after = modelImports.functionLookup text catalog first after
  token : ∀ text position token, TokenDomain text position token →
    imports.token text position token = modelImports.token text position token
  condition : ∀ text context position facts, ReadDomain text context position facts →
    imports.condition text context position facts = modelImports.condition text context position facts
  scalar : ∀ text context position facts, ReadDomain text context position facts →
    imports.scalar text context position facts = modelImports.scalar text context position facts
  isEmpty : ∀ bounds, bounds.Bounded →
    imports.isEmpty bounds = modelImports.isEmpty bounds
  included : ∀ left right, left.Bounded ∧ right.Bounded →
    imports.included left right = modelImports.included left right
  invalid : ∀ scan, scan.count ≤ ScalarExpression.maxBindings →
    imports.invalid scan = modelImports.invalid scan

noncomputable def totalizeImports (imports : Imports) : Imports := by
  classical
  exact {
    skip := fun text position => if CursorDomain text position then imports.skip text position else modelImports.skip text position
    nameAfter := fun text position => if CursorDomain text position then imports.nameAfter text position else modelImports.nameAfter text position
    namesLookup := fun text names first after => if ScalarBodyNative.StringLookupDomain text names first after then imports.namesLookup text names first after else modelImports.namesLookup text names first after
    scalarLookup := fun text names first after => if ScalarBodyNative.LookupDomain text names first after then imports.scalarLookup text names first after else modelImports.scalarLookup text names first after
    booleanLookup := fun text names first after => if BooleanBodyNative.BooleanLookupDomain text names first after then imports.booleanLookup text names first after else modelImports.booleanLookup text names first after
    arrayLookup := fun text names first after => if ArrayLookupDomain text names first after then imports.arrayLookup text names first after else modelImports.arrayLookup text names first after
    functionLookup := fun text catalog first after => if FunctionLookupDomain text catalog first after then imports.functionLookup text catalog first after else modelImports.functionLookup text catalog first after
    token := fun text position token => if TokenDomain text position token then imports.token text position token else modelImports.token text position token
    condition := fun text context position facts => if ReadDomain text context position facts then imports.condition text context position facts else modelImports.condition text context position facts
    scalar := fun text context position facts => if ReadDomain text context position facts then imports.scalar text context position facts else modelImports.scalar text context position facts
    isEmpty := fun bounds => if bounds.Bounded then imports.isEmpty bounds else modelImports.isEmpty bounds
    included := fun left right => if left.Bounded ∧ right.Bounded then imports.included left right else modelImports.included left right
    invalid := fun scan => if scan.count ≤ ScalarExpression.maxBindings then imports.invalid scan else modelImports.invalid scan }

theorem totalizeImports_eq_model {imports : Imports} (meaning : ImportsMeaning imports) :
    totalizeImports imports = modelImports := by
  apply Imports.ext
  · funext text position
    simp only [totalizeImports]
    split
    · exact meaning.skip text position ‹_›
    · rfl
  · funext text position
    simp only [totalizeImports]
    split
    · exact meaning.nameAfter text position ‹_›
    · rfl
  · funext text names first after
    simp only [totalizeImports]
    split
    · exact meaning.namesLookup text names first after ‹_›
    · rfl
  · funext text names first after
    simp only [totalizeImports]
    split
    · exact meaning.scalarLookup text names first after ‹_›
    · rfl
  · funext text names first after
    simp only [totalizeImports]
    split
    · exact meaning.booleanLookup text names first after ‹_›
    · rfl
  · funext text names first after
    simp only [totalizeImports]
    split
    · exact meaning.arrayLookup text names first after ‹_›
    · rfl
  · funext text catalog first after
    simp only [totalizeImports]
    split
    · exact meaning.functionLookup text catalog first after ‹_›
    · rfl
  · funext text position token
    simp only [totalizeImports]
    split
    · exact meaning.token text position token ‹_›
    · rfl
  · funext text context position facts
    simp only [totalizeImports]
    split
    · exact meaning.condition text context position facts ‹_›
    · rfl
  · funext text context position facts
    simp only [totalizeImports]
    split
    · exact meaning.scalar text context position facts ‹_›
    · rfl
  · funext bounds
    simp only [totalizeImports]
    split
    · exact meaning.isEmpty bounds ‹_›
    · rfl
  · funext left right
    simp only [totalizeImports]
    split
    · exact meaning.included left right ‹_›
    · rfl
  · funext scan
    simp only [totalizeImports]
    split
    · exact meaning.invalid scan ‹_›
    · rfl

theorem model_imports_meaning : ImportsMeaning modelImports := by
  constructor <;> intros <;> rfl

/-- Exact source preconditions plus the native Formal component subtype. -/
def ActualDomain (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (parameter : Formal) : Prop :=
  ReadDomain text context position facts ∧ FunctionBindings.Native.FormalType parameter

def ActualsDomain (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : Metadata) (first last : Nat) : Prop :=
  ReadDomain text context position facts ∧ ValidMetadata text catalog ∧
    0 < first ∧ first ≤ last ∧ last ≤ catalog.parameters.length

def CalleeDomain (text : Source) (context : Native.Context) (position : Nat)
    (catalog : Metadata) : Prop := TargetDomain text context position ∧ ValidMetadata text catalog

def CallDomain (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : Metadata) : Prop :=
  ReadDomain text context position facts ∧ ValidMetadata text catalog

/-- Call_Assignment_Result has no Valid_Context/Valid_Body precondition.
Its component subtypes supply bounded cells and active storage capacities. -/
def ResultDomain (context : Native.Context) (scan : BodyScan)
    (scalar flag : Nat) (value : CallResult) : Prop :=
  context.scalarNames.length ≤ ScalarExpression.maxBindings ∧
    (∀ item ∈ context.scalarNames, item.declaredBounds.Bounded) ∧
    context.booleanNames.length ≤ BooleanBindings.maxBindings ∧
    scan.count ≤ ScalarExpression.maxBindings ∧ value.bounds.Bounded ∧
    scalar ≤ context.scalarNames.length ∧ scalar ≤ scan.count ∧ flag ≤ context.booleanNames.length

def FunctionAssignmentDomain (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : Metadata) : Prop := AssignmentDomain text context scan ∧ ValidMetadata text catalog

noncomputable def totalizeCalls (calls : Calls) : Calls := by
  classical
  exact {
    actual := fun text context position facts parameter => if ActualDomain text context position facts parameter then
      calls.actual text context position facts parameter else modelCalls.actual text context position facts parameter
    actuals := fun text context position facts catalog first last => if ActualsDomain text context position facts catalog first last then
      calls.actuals text context position facts catalog first last else modelCalls.actuals text context position facts catalog first last
    callee := fun text context position catalog => if CalleeDomain text context position catalog then
      calls.callee text context position catalog else modelCalls.callee text context position catalog
    callModel := fun text context position facts catalog => if CallDomain text context position facts catalog then
      calls.callModel text context position facts catalog else modelCalls.callModel text context position facts catalog
    readCall := fun text context position facts catalog => if CallDomain text context position facts catalog then
      calls.readCall text context position facts catalog else modelCalls.readCall text context position facts catalog
    scalarTarget := fun text context position => if TargetDomain text context position then
      calls.scalarTarget text context position else modelCalls.scalarTarget text context position
    booleanTarget := fun text context position => if TargetDomain text context position then
      calls.booleanTarget text context position else modelCalls.booleanTarget text context position
    assignmentResult := fun context scan scalar flag value => if ResultDomain context scan scalar flag value then
      calls.assignmentResult context scan scalar flag value else modelCalls.assignmentResult context scan scalar flag value }

structure DefinitionEquations (imports : Imports) (calls : Calls)
    (assignment : Source → Native.Context → BodyScan → Metadata → BodyScan) : Prop where
  actual : ∀ text context position facts parameter, ActualDomain text context position facts parameter →
    calls.actual text context position facts parameter =
      actualBody.eval (totalizeImports imports) (totalizeCalls calls) {text, context, position, facts, parameter}
  actuals : ∀ text context position facts catalog first last, ActualsDomain text context position facts catalog first last →
    calls.actuals text context position facts catalog first last =
      actualsBody.eval (totalizeImports imports) (totalizeCalls calls) {text, context, position, facts, catalog, first, last}
  callee : ∀ text context position catalog, CalleeDomain text context position catalog →
    calls.callee text context position catalog =
      calleeBody.eval (totalizeImports imports) (totalizeCalls calls) {text, context, position, catalog}
  callModel : ∀ text context position facts catalog, CallDomain text context position facts catalog →
    calls.callModel text context position facts catalog =
      callBody.eval (totalizeImports imports) (totalizeCalls calls) {text, context, position, facts, catalog}
  readCall : ∀ text context position facts catalog, CallDomain text context position facts catalog →
    calls.readCall text context position facts catalog = calls.callModel text context position facts catalog
  assignmentResult : ∀ context scan scalar flag value, ResultDomain context scan scalar flag value →
    calls.assignmentResult context scan scalar flag value =
      assignmentResultBody.eval (totalizeImports imports) (totalizeCalls calls) {context, scan, scalar, flag, called := value}
  assignment : ∀ text context scan catalog, FunctionAssignmentDomain text context scan catalog →
    assignment text context scan catalog =
      (assignmentBody true).eval (totalizeImports imports) (totalizeCalls calls) {text, context, scan, catalog}


set_option maxRecDepth 4096
set_option maxHeartbeats 1000000

theorem actual_body_calls (imports : Imports) (left right : Calls) (frame : Frame) :
    actualBody.eval imports left frame = actualBody.eval imports right frame := rfl

theorem callee_body_calls (imports : Imports) (left right : Calls) (frame : Frame) :
    calleeBody.eval imports left frame = calleeBody.eval imports right frame := rfl

theorem result_body_calls (imports : Imports) (left right : Calls) (frame : Frame) :
    assignmentResultBody.eval imports left frame = assignmentResultBody.eval imports right frame := rfl

variable {imports : Imports} {calls : Calls}
  {assignment : Source → Native.Context → BodyScan → Metadata → BodyScan}

theorem normalized_actual (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) :
    (totalizeCalls calls).actual = modelCalls.actual := by
  funext text context position facts parameter
  change (if ActualDomain text context position facts parameter then _ else _) = _
  split
  · rename_i valid
    rw [defs.actual text context position facts parameter valid, totalizeImports_eq_model meaning,
      actual_body_calls modelImports (totalizeCalls calls) modelCalls]
    exact actual_model ..
  · rfl

theorem normalized_callee (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) :
    (totalizeCalls calls).callee = modelCalls.callee := by
  funext text context position catalog
  change (if CalleeDomain text context position catalog then _ else _) = _
  split
  · rename_i valid
    rw [defs.callee text context position catalog valid, totalizeImports_eq_model meaning,
      callee_body_calls modelImports (totalizeCalls calls) modelCalls]
    exact callee_model ..
  · rfl

theorem normalized_result (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) :
    (totalizeCalls calls).assignmentResult = modelCalls.assignmentResult := by
  funext context scan scalar flag value
  change (if ResultDomain context scan scalar flag value then _ else _) = _
  split
  · rename_i valid
    rw [defs.assignmentResult context scan scalar flag value valid, totalizeImports_eq_model meaning,
      result_body_calls modelImports (totalizeCalls calls) modelCalls]
    exact assignmentResult_model ..
  · rfl

/-- The exact native recursive equation has one shorter remaining formal
suffix. No callee-result or whole-reader equality is assumed. -/
theorem normalized_actuals_at (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment)
    (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow)
    (catalog : Metadata) (first last : Nat) :
    (totalizeCalls calls).actuals text context position facts catalog first last =
      modelCalls.actuals text context position facts catalog first last := by
  change (if ActualsDomain text context position facts catalog first last then _ else _) = _
  split
  · rename_i valid
    rw [defs.actuals text context position facts catalog first last valid, totalizeImports_eq_model meaning]
    dsimp only [actualsBody, Expr.eval]
    rw [normalized_actual meaning defs]
    change (if decide (actualAfter text context.model position facts (parameter catalog first) = 0) then 0
      else if decide (first = last) then _ else _) = actualsAfter text context.model position facts catalog first last
    rw [actualsAfter]
    by_cases zero : actualAfter text context.model position facts (parameter catalog first) = 0
    · simp only [zero, decide_true, ↓reduceIte]
    · by_cases final : first = last
      · simp only [zero, final, decide_false, decide_true, Bool.false_eq_true, ↓reduceIte]
        rfl
      · have advancing : first < last := by have ordered := valid.2.2.2.1; omega
        simp only [zero, final, advancing, decide_false, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte]
        exact normalized_actuals_at meaning defs text context _ facts catalog (first + 1) last
  · rfl
termination_by last - first

theorem normalized_actuals (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) :
    (totalizeCalls calls).actuals = modelCalls.actuals := by
  funext text context position facts catalog first last
  exact normalized_actuals_at meaning defs text context position facts catalog first last

theorem normalized_callModel (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) :
    (totalizeCalls calls).callModel = modelCalls.callModel := by
  funext text context position facts catalog
  change (if CallDomain text context position facts catalog then _ else _) = _
  split
  · rename_i valid
    rw [defs.callModel text context position facts catalog valid, totalizeImports_eq_model meaning]
    calc
      _ = callBody.eval modelImports modelCalls {text, context, position, facts, catalog} := by
        simp only [callBody, Expr.eval, normalized_callee meaning defs, normalized_actuals meaning defs]
      _ = _ := call_model text context position facts catalog
  · rfl

theorem normalized_readCall (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) :
    (totalizeCalls calls).readCall = modelCalls.readCall := by
  funext text context position facts catalog
  change (if CallDomain text context position facts catalog then _ else _) = _
  split
  · rename_i valid
    rw [defs.readCall text context position facts catalog valid]
    have result := congrFun (congrFun (congrFun (congrFun (congrFun
      (normalized_callModel meaning defs) text) context) position) facts) catalog
    simpa only [totalizeCalls, valid, ↓reduceIte] using result
  · rfl

structure TargetsMeaning (calls : Calls) : Prop where
  scalar : ∀ text context position, TargetDomain text context position →
    calls.scalarTarget text context position = Predicate.scalarTarget text context.model position
  boolean : ∀ text context position, TargetDomain text context position →
    calls.booleanTarget text context position = Predicate.booleanTarget text context.model position

theorem normalized_scalarTarget (meaning : TargetsMeaning calls) :
    (totalizeCalls calls).scalarTarget = modelCalls.scalarTarget := by
  funext text context position
  change (if TargetDomain text context position then _ else _) = _
  split
  · exact meaning.scalar text context position ‹_›
  · rfl

theorem normalized_booleanTarget (meaning : TargetsMeaning calls) :
    (totalizeCalls calls).booleanTarget = modelCalls.booleanTarget := by
  funext text context position
  change (if TargetDomain text context position then _ else _) = _
  split
  · exact meaning.boolean text context position ‹_›
  · rfl

theorem totalizeCalls_eq_model (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) (targets : TargetsMeaning calls) :
    totalizeCalls calls = modelCalls := by
  apply Calls.ext
  · exact normalized_actual meaning defs
  · exact normalized_actuals meaning defs
  · exact normalized_callee meaning defs
  · exact normalized_callModel meaning defs
  · exact normalized_readCall meaning defs
  · exact normalized_scalarTarget targets
  · exact normalized_booleanTarget targets
  · exact normalized_result meaning defs

theorem assignment_meaning (meaning : ImportsMeaning imports)
    (defs : DefinitionEquations imports calls assignment) (targets : TargetsMeaning calls)
    (text : Source) (context : Native.Context) (scan : BodyScan) (catalog : Metadata)
    (valid : FunctionAssignmentDomain text context scan catalog) :
    assignment text context scan catalog = callAssignmentBody text context.model scan catalog := by
  rw [defs.assignment text context scan catalog valid, totalizeImports_eq_model meaning,
    totalizeCalls_eq_model meaning defs targets]
  exact assignment_model ..

theorem model_targets_meaning : TargetsMeaning modelCalls := by
  constructor <;> intros <;> rfl

theorem model_calls_totalize : totalizeCalls modelCalls = modelCalls := by
  apply Calls.ext <;> funext <;> simp only [totalizeCalls] <;> split <;> rfl

theorem model_definitions_of_meaning (meaning : ImportsMeaning imports) :
    DefinitionEquations imports modelCalls
    (fun text context scan catalog => callAssignmentBody text context.model scan catalog) where
  actual text context position facts parameter _ := by
    rw [totalizeImports_eq_model meaning, model_calls_totalize]
    exact (actual_model ..).symm
  actuals text context position facts catalog first last valid := by
    rw [totalizeImports_eq_model meaning, model_calls_totalize]
    exact (actuals_model text context position facts catalog first last valid.2.2.2.1).symm
  callee text context position catalog _ := by
    rw [totalizeImports_eq_model meaning, model_calls_totalize]
    exact (callee_model ..).symm
  callModel text context position facts catalog _ := by
    rw [totalizeImports_eq_model meaning, model_calls_totalize]
    exact (call_model ..).symm
  readCall _ _ _ _ _ _ := rfl
  assignmentResult context scan scalar flag value _ := by
    rw [totalizeImports_eq_model meaning, model_calls_totalize]
    exact (assignmentResult_model ..).symm
  assignment text context scan catalog _ := by
    rw [totalizeImports_eq_model meaning, model_calls_totalize]
    exact (assignment_model ..).symm

theorem model_definitions : DefinitionEquations modelImports modelCalls
    (fun text context scan catalog => callAssignmentBody text context.model scan catalog) :=
  model_definitions_of_meaning model_imports_meaning

end Silver.Predicate.FunctionCallNative
