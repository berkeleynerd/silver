module

public import Silver.PredicateProcedureCallEquations
public import Silver.PredicateFunctionCallHelpers
public import Silver.PredicateScalarBodyHelpers
public import Silver.ProcedureBindingsNativeEquations
public import Silver.ProcedureNameFreeNative

@[expose] public section
namespace Silver.Predicate.ProcedureCallNative
open Compose

abbrev CursorDomain := FunctionCallNative.CursorDomain
abbrev TargetDomain := ScalarBodyNative.TargetDomain
abbrev AssignmentDomain := ScalarBodyNative.AssignmentDomain
abbrev ReadDomain := FunctionCallNative.ReadDomain

def ActualDomain (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) : Prop :=
  ReadDomain text context position facts ∧ ProcedureBindings.Native.FormalType parameter

def ActualsDomain (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last : Nat) : Prop :=
  ReadDomain text context position facts ∧ ProcedureBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ last ∧ last ≤ catalog.parameters.length

def ActualsTailDomain (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat) : Prop :=
  ReadDomain text context position facts ∧ ProcedureBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ ordinal ∧ ordinal ≤ last ∧ last ≤ catalog.parameters.length

def PayloadsFreeModelDomain (text : Source) (context : Native.Context) (position : Nat)
    (incoming : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last ordinal callAfter targetFirst targetAfter : Nat) : Prop :=
  ActualsTailDomain text context position incoming catalog first last ordinal ∧
    Expressions.ValidCursor text callAfter ∧ Expressions.ValidName text targetFirst targetAfter

def PayloadsFreeDomain (text : Source) (context : Native.Context) (position : Nat)
    (incoming : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last callAfter targetFirst targetAfter : Nat) : Prop :=
  ActualsDomain text context position incoming catalog first last ∧
    Expressions.ValidCursor text callAfter ∧ Expressions.ValidName text targetFirst targetAfter

def UpdateDomain (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (parameter : ProcedureBindings.Formal) (catalog : ProcedureBindings.Metadata)
    (first last callFirst callAfter : Nat) : Prop :=
  AssignmentDomain text context scan ∧ Native.ValidFlow context incoming ∧
    ProcedureBindings.Native.FormalType parameter ∧ ProcedureBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ last ∧ last ≤ catalog.parameters.length ∧
    Expressions.ValidCursor text callFirst ∧ Expressions.ValidCursor text callAfter

def UpdatesTailDomain (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (catalog : ProcedureBindings.Metadata) (first last ordinal callFirst callAfter : Nat) : Prop :=
  AssignmentDomain text context scan ∧ Native.ValidFlow context incoming ∧
    ProcedureBindings.ValidMetadata text catalog ∧ 0 < first ∧ first ≤ ordinal ∧ ordinal ≤ last ∧
    last ≤ catalog.parameters.length ∧ Expressions.ValidCursor text callFirst ∧ Expressions.ValidCursor text callAfter

def UpdatesModelDomain (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) : Prop :=
  AssignmentDomain text context scan ∧ Native.ValidFlow context incoming ∧
    ProcedureBindings.ValidMetadata text catalog ∧ 0 < first ∧ first ≤ last ∧
    last ≤ catalog.parameters.length ∧ Expressions.ValidCursor text callFirst ∧
    Expressions.ValidCursor text callAfter

def UpdatesDomain (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) : Prop :=
  AssignmentDomain text context scan ∧ ProcedureBindings.ValidMetadata text catalog ∧
    0 < first ∧ first ≤ last ∧ last ≤ catalog.parameters.length ∧
    Expressions.ValidCursor text callFirst ∧ Expressions.ValidCursor text callAfter

def CalleeDomain (text : Source) (context : Native.Context) (position : Nat)
    (catalog : ProcedureBindings.Metadata) : Prop :=
  TargetDomain text context position ∧ ProcedureBindings.ValidMetadata text catalog

def CallDomain (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) : Prop :=
  AssignmentDomain text context scan ∧ ProcedureBindings.ValidMetadata text catalog

def ProcedureLookupDomain (text : Source) (catalog : ProcedureBindings.Metadata) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ ProcedureBindings.ValidMetadata text catalog ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def callTokens : List ShellToken := [.symbol "(", .symbol ")", .symbol ","]
def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  CursorDomain text position ∧ token ∈ callTokens

def BodyTokenDomain (text : Source) (context : Native.Context) (scan : BodyScan) (token : ShellToken) : Prop :=
  AssignmentDomain text context scan ∧ token ∈ callTokens

/-- These are exactly the native preconditions and component subtypes. In
particular zero cursors and arbitrary typed formals remain in the domain.
Outside a native domain, the model merely supplies the formal total extension;
GNATprove must establish legality of every executed native call. -/
noncomputable def totalizeCalls (calls : Calls) : Calls := by
  classical
  exact fun
    | .markFormal => fun seen formal => if AssociationNative.MarkDomain formal then
        calls .markFormal seen formal else modelCalls .markFormal seen formal
    | .skip => fun text position =>
        if CursorDomain text position then calls .skip text position else modelCalls .skip text position
    | .nameAfter => fun text position =>
        if CursorDomain text position then calls .nameAfter text position else modelCalls .nameAfter text position
    | .namesLookup => fun text names first after =>
        if FunctionCallNative.StringLookupDomain text names first after then calls .namesLookup text names first after else modelCalls .namesLookup text names first after
    | .scalarLookup => fun text names first after =>
        if FunctionCallNative.ScalarLookupDomain text names first after then calls .scalarLookup text names first after else modelCalls .scalarLookup text names first after
    | .booleanLookup => fun text names first after =>
        if FunctionCallNative.BooleanLookupDomain text names first after then calls .booleanLookup text names first after else modelCalls .booleanLookup text names first after
    | .arrayLookup => fun text names first after =>
        if FunctionCallNative.ArrayLookupDomain text names first after then calls .arrayLookup text names first after else modelCalls .arrayLookup text names first after
    | .arrayTypeLookup => fun text names first after =>
        if FunctionCallNative.ArrayTypeLookupDomain text names first after then calls .arrayTypeLookup text names first after else modelCalls .arrayTypeLookup text names first after
    | .procedureLookup => fun text catalog first after =>
        if ProcedureLookupDomain text catalog first after then calls .procedureLookup text catalog first after else modelCalls .procedureLookup text catalog first after
    | .token => fun text position token =>
        if TokenDomain text position token then calls .token text position token else modelCalls .token text position token
    | .isEmpty => fun bounds =>
        if bounds.Bounded then calls .isEmpty bounds else modelCalls .isEmpty bounds
    | .included => fun left right =>
        if left.Bounded ∧ right.Bounded then calls .included left right else modelCalls .included left right
    | .scalarTarget => fun text context position =>
        if TargetDomain text context position then calls .scalarTarget text context position else modelCalls .scalarTarget text context position
    | .booleanTarget => fun text context position =>
        if TargetDomain text context position then calls .booleanTarget text context position else modelCalls .booleanTarget text context position
    | .functionActual => fun text context position facts parameter =>
        if FunctionCallNative.ActualDomain text context position facts parameter then calls .functionActual text context position facts parameter else modelCalls .functionActual text context position facts parameter
    | .nameFree => fun text position after targetFirst targetAfter =>
        if ProcedureNameNative.StepDomain text position after targetFirst targetAfter then calls .nameFree text position after targetFirst targetAfter else modelCalls .nameFree text position after targetFirst targetAfter
    | .nameFreeModel => fun text position after targetFirst targetAfter =>
        if ProcedureNameNative.StepDomain text position after targetFirst targetAfter then calls .nameFreeModel text position after targetFirst targetAfter else modelCalls .nameFreeModel text position after targetFirst targetAfter
    | .association => fun text position catalog first last ordinal named =>
        if AssociationNative.ProcedureAssociationDomain text position catalog first last ordinal then
          calls .association text position catalog first last ordinal named else modelCalls .association text position catalog first last ordinal named
    | .actualsTail => fun text context position facts catalog first last ordinal named seen =>
        if ActualsTailDomain text context position facts catalog first last ordinal then
          calls .actualsTail text context position facts catalog first last ordinal named seen
        else modelCalls .actualsTail text context position facts catalog first last ordinal named seen
    | .payloadsFreeModel => fun text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter =>
        if PayloadsFreeModelDomain text context position incoming catalog first last ordinal callAfter targetFirst targetAfter then
          calls .payloadsFreeModel text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter
        else modelCalls .payloadsFreeModel text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter
    | .payloadsFree => fun text context position incoming catalog first last callAfter targetFirst targetAfter =>
        if PayloadsFreeDomain text context position incoming catalog first last callAfter targetFirst targetAfter then
          calls .payloadsFree text context position incoming catalog first last callAfter targetFirst targetAfter
        else modelCalls .payloadsFree text context position incoming catalog first last callAfter targetFirst targetAfter
    | .updatesTail => fun text context incoming scan catalog first last ordinal named seen callFirst callAfter =>
        if UpdatesTailDomain text context incoming scan catalog first last ordinal callFirst callAfter then
          calls .updatesTail text context incoming scan catalog first last ordinal named seen callFirst callAfter
        else modelCalls .updatesTail text context incoming scan catalog first last ordinal named seen callFirst callAfter
    | .invalid => fun scan =>
        if scan.count ≤ ScalarExpression.maxBindings then calls .invalid scan else modelCalls .invalid scan
    | .invalidModel => fun scan =>
        if scan.count ≤ ScalarExpression.maxBindings then calls .invalidModel scan else modelCalls .invalidModel scan
    | .bodyToken => fun text context scan token =>
        if BodyTokenDomain text context scan token then calls .bodyToken text context scan token else modelCalls .bodyToken text context scan token
    | .target => fun text context position facts parameter =>
        if ActualDomain text context position facts parameter then calls .target text context position facts parameter else modelCalls .target text context position facts parameter
    | .actual => fun text context position facts parameter =>
        if ActualDomain text context position facts parameter then calls .actual text context position facts parameter else modelCalls .actual text context position facts parameter
    | .actualsModel => fun text context position facts catalog first last =>
        if ActualsDomain text context position facts catalog first last then calls .actualsModel text context position facts catalog first last else modelCalls .actualsModel text context position facts catalog first last
    | .actuals => fun text context position facts catalog first last =>
        if ActualsDomain text context position facts catalog first last then calls .actuals text context position facts catalog first last else modelCalls .actuals text context position facts catalog first last
    | .update => fun text context incoming scan parameter catalog first last callFirst callAfter =>
        if UpdateDomain text context incoming scan parameter catalog first last callFirst callAfter then
          calls .update text context incoming scan parameter catalog first last callFirst callAfter
        else modelCalls .update text context incoming scan parameter catalog first last callFirst callAfter
    | .updatesModel => fun text context incoming scan catalog first last callFirst callAfter =>
        if UpdatesModelDomain text context incoming scan catalog first last callFirst callAfter then calls .updatesModel text context incoming scan catalog first last callFirst callAfter else modelCalls .updatesModel text context incoming scan catalog first last callFirst callAfter
    | .updates => fun text context scan catalog first last callFirst callAfter =>
        if UpdatesDomain text context scan catalog first last callFirst callAfter then calls .updates text context scan catalog first last callFirst callAfter else modelCalls .updates text context scan catalog first last callFirst callAfter
    | .callee => fun text context position catalog =>
        if CalleeDomain text context position catalog then calls .callee text context position catalog else modelCalls .callee text context position catalog
    | .call => fun text context scan catalog =>
        if CallDomain text context scan catalog then calls .call text context scan catalog else modelCalls .call text context scan catalog

/-- Only separately checked imported functions occur here. No completed
procedure-target, recursive-actuals, update, callee or call law is assumed. -/
structure ImportsMeaning (calls : Calls) : Prop where
  markFormal : totalizeCalls calls .markFormal = modelCalls .markFormal
  skip : totalizeCalls calls .skip = modelCalls .skip
  nameAfter : totalizeCalls calls .nameAfter = modelCalls .nameAfter
  namesLookup : totalizeCalls calls .namesLookup = modelCalls .namesLookup
  scalarLookup : totalizeCalls calls .scalarLookup = modelCalls .scalarLookup
  booleanLookup : totalizeCalls calls .booleanLookup = modelCalls .booleanLookup
  arrayLookup : totalizeCalls calls .arrayLookup = modelCalls .arrayLookup
  arrayTypeLookup : totalizeCalls calls .arrayTypeLookup = modelCalls .arrayTypeLookup
  procedureLookup : totalizeCalls calls .procedureLookup = modelCalls .procedureLookup
  token : totalizeCalls calls .token = modelCalls .token
  isEmpty : totalizeCalls calls .isEmpty = modelCalls .isEmpty
  included : totalizeCalls calls .included = modelCalls .included
  scalarTarget : totalizeCalls calls .scalarTarget = modelCalls .scalarTarget
  booleanTarget : totalizeCalls calls .booleanTarget = modelCalls .booleanTarget
  functionActual : totalizeCalls calls .functionActual = modelCalls .functionActual
  nameFree : totalizeCalls calls .nameFree = modelCalls .nameFree
  nameFreeModel : totalizeCalls calls .nameFreeModel = modelCalls .nameFreeModel
  association : totalizeCalls calls .association = modelCalls .association
  invalid : totalizeCalls calls .invalid = modelCalls .invalid
  invalidModel : totalizeCalls calls .invalidModel = modelCalls .invalidModel
  bodyToken : totalizeCalls calls .bodyToken = modelCalls .bodyToken

/-- Every equation is the interpretation of its checked source tree or the
verified Static equality between a runtime loop and its recursive source model. -/
structure DefinitionEquations (calls : Calls) : Prop where
  target : ∀ text context position facts parameter, ActualDomain text context position facts parameter →
    calls .target text context position facts parameter =
      targetBody.eval (totalizeCalls calls) ({text,context,position,facts,parameter} : Frame).locals
  actual : ∀ text context position facts parameter, ActualDomain text context position facts parameter →
    calls .actual text context position facts parameter =
      actualBody.eval (totalizeCalls calls) ({text,context,position,facts,parameter} : Frame).locals
  actualsModel : ∀ text context position facts catalog first last, ActualsDomain text context position facts catalog first last →
    calls .actualsModel text context position facts catalog first last =
      actualsBody.eval (totalizeCalls calls) ({text,context,position,facts,catalog,first,last} : Frame).locals
  actualsTail : ∀ text context position facts catalog first last ordinal named seen,
    ActualsTailDomain text context position facts catalog first last ordinal →
    calls .actualsTail text context position facts catalog first last ordinal named seen =
      actualsTailBody.eval (totalizeCalls calls) ({text,context,position,facts,catalog,first,last,ordinal,named,seen} : Frame).locals
  payloadsFreeModel : ∀ text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter,
    PayloadsFreeModelDomain text context position incoming catalog first last ordinal callAfter targetFirst targetAfter →
    calls .payloadsFreeModel text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter =
      payloadsFreeBody.eval (totalizeCalls calls)
        ({text,context,position,incoming,catalog,first,last,ordinal,named,callAfter,targetFirst,targetAfter} : Frame).locals
  payloadsFree : ∀ text context position incoming catalog first last callAfter targetFirst targetAfter,
    PayloadsFreeDomain text context position incoming catalog first last callAfter targetFirst targetAfter →
    calls .payloadsFree text context position incoming catalog first last callAfter targetFirst targetAfter =
      calls .payloadsFreeModel text context position incoming catalog first last first false callAfter targetFirst targetAfter
  update : ∀ text context incoming scan parameter catalog first last callFirst callAfter,
    UpdateDomain text context incoming scan parameter catalog first last callFirst callAfter →
    calls .update text context incoming scan parameter catalog first last callFirst callAfter =
      updateBody.eval (totalizeCalls calls) ({text,context,incoming,scan,parameter,catalog,first,last,callFirst,callAfter} : Frame).locals
  updatesTail : ∀ text context incoming scan catalog first last ordinal named seen callFirst callAfter,
    UpdatesTailDomain text context incoming scan catalog first last ordinal callFirst callAfter →
    calls .updatesTail text context incoming scan catalog first last ordinal named seen callFirst callAfter =
      updatesTailBody.eval (totalizeCalls calls)
        ({text,context,incoming,scan,catalog,first,last,ordinal,named,seen,callFirst,callAfter} : Frame).locals
  updatesModel : ∀ text context incoming scan catalog first last callFirst callAfter, UpdatesModelDomain text context incoming scan catalog first last callFirst callAfter →
    calls .updatesModel text context incoming scan catalog first last callFirst callAfter =
      updatesBody.eval (totalizeCalls calls) ({text,context,incoming,scan,catalog,first,last,callFirst,callAfter} : Frame).locals
  callee : ∀ text context position catalog, CalleeDomain text context position catalog →
    calls .callee text context position catalog =
      calleeBody.eval (totalizeCalls calls) ({text,context,position,catalog} : Frame).locals
  call : ∀ text context scan catalog, CallDomain text context scan catalog →
    calls .call text context scan catalog =
      callBody.eval (totalizeCalls calls) ({text,context,scan,catalog} : Frame).locals
  actuals : ∀ text context position facts catalog first last,
    ActualsDomain text context position facts catalog first last →
      calls .actuals text context position facts catalog first last =
        calls .actualsModel text context position facts catalog first last
  updates : ∀ text context scan catalog first last callFirst callAfter,
    UpdatesDomain text context scan catalog first last callFirst callAfter →
      calls .updates text context scan catalog first last callFirst callAfter =
        calls .updatesModel text context scan.facts scan catalog first last callFirst callAfter

theorem model_calls_totalize : totalizeCalls modelCalls = modelCalls := by
  funext fn
  cases fn <;> funext <;> simp only [totalizeCalls] <;> split <;> rfl

theorem model_imports_meaning : ImportsMeaning modelCalls := by
  constructor <;> rw [model_calls_totalize]

theorem model_definitions : DefinitionEquations modelCalls where
  target text context position facts parameter _ := by
    rw [model_calls_totalize]
    exact (target_model ..).symm
  actual text context position facts parameter _ := by
    rw [model_calls_totalize]
    exact (actual_model ..).symm
  actualsModel text context position facts catalog first last valid := by
    rw [model_calls_totalize]
    exact (actuals_model text context position facts catalog first last valid.2.2.2.1).symm
  actualsTail text context position facts catalog first last ordinal named seen valid := by
    rw [model_calls_totalize]
    exact (actualsTail_model text context position facts catalog first last ordinal named seen valid.2.2.2.2.1).symm
  payloadsFreeModel text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter valid := by
    rw [model_calls_totalize]
    exact (payloadsFree_model text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter valid.1.2.2.2.2.1).symm
  payloadsFree := by intros; rfl
  update text context incoming scan parameter catalog first last callFirst callAfter _ := by
    rw [model_calls_totalize]
    exact (update_model ..).symm
  updatesTail text context incoming scan catalog first last ordinal named seen callFirst callAfter valid := by
    rw [model_calls_totalize]
    exact (updatesTail_model text context incoming scan catalog first last ordinal named seen callFirst callAfter valid.2.2.2.2.2.1).symm
  updatesModel text context incoming scan catalog first last callFirst callAfter valid := by
    rw [model_calls_totalize]
    exact (updates_model text context incoming scan catalog first last callFirst callAfter valid.2.2.2.2.1).symm
  callee text context position catalog _ := by
    rw [model_calls_totalize]
    exact (callee_model ..).symm
  call text context scan catalog _ := by
    rw [model_calls_totalize]
    exact (call_model ..).symm
  actuals _ _ _ _ _ _ _ _ := rfl
  updates _ _ _ _ _ _ _ _ _ := rfl

end Silver.Predicate.ProcedureCallNative
