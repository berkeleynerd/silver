module

public import Silver.PredicateProcedureCallNative

@[expose] public section
namespace Silver.Predicate.ProcedureCallNative
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

private theorem nat_beq_decide (left right : Nat) :
    (left == right) = decide (left = right) := by
  apply Bool.eq_iff_iff.mpr
  simp only [beq_iff_eq, decide_eq_true_eq]

def targetScope : Scope :=
  [(.source,"text"),(.context,"context"),(.number,"position"),(.flow,"facts"),(.formal,"parameter")]
def actualsScope : Scope :=
  [(.source,"text"),(.context,"context"),(.number,"position"),(.flow,"facts"),
   (.metadata,"catalog"),(.number,"first"),(.number,"last")]
def actualsTailScope : Scope :=
  actualsScope ++ [(.number,"ordinal"),(.truth,"named"),(.formalSet,"seen")]
def payloadsFreeScope : Scope :=
  [(.source,"text"),(.context,"context"),(.number,"position"),(.flow,"incoming"),
   (.metadata,"catalog"),(.number,"first"),(.number,"last"),(.number,"ordinal"),(.truth,"named"),
   (.number,"call_after"),(.number,"target_first"),(.number,"target_after")]
def updateScope : Scope :=
  [(.source,"text"),(.context,"context"),(.flow,"incoming"),(.scan,"scan"),
   (.formal,"parameter"),(.metadata,"catalog"),(.number,"first"),(.number,"last"),(.number,"call_first"),(.number,"call_after")]
def updatesScope : Scope :=
  [(.source,"text"),(.context,"context"),(.flow,"incoming"),(.scan,"scan"),
   (.metadata,"catalog"),(.number,"first"),(.number,"last"),(.number,"call_first"),(.number,"call_after")]
def updatesTailScope : Scope :=
  updatesScope ++ [(.number,"ordinal"),(.truth,"named"),(.formalSet,"seen")]
def calleeScope : Scope :=
  [(.source,"text"),(.context,"context"),(.number,"position"),(.metadata,"catalog")]
def callScope : Scope :=
  [(.source,"text"),(.context,"context"),(.scan,"scan"),(.metadata,"catalog")]

abbrev CheckedTrees : Prop :=
  targetBody.wellFormed = true ∧ targetBody.scoped targetScope = true ∧
  actualBody.wellFormed = true ∧ actualBody.scoped targetScope = true ∧
  actualsTailBody.wellFormed = true ∧ actualsTailBody.scoped actualsTailScope = true ∧
  payloadsFreeBody.wellFormed = true ∧ payloadsFreeBody.scoped payloadsFreeScope = true ∧
  actualsBody.wellFormed = true ∧ actualsBody.scoped actualsScope = true ∧
  updateBody.wellFormed = true ∧ updateBody.scoped updateScope = true ∧
  updatesTailBody.wellFormed = true ∧ updatesTailBody.scoped updatesTailScope = true ∧
  updatesBody.wellFormed = true ∧ updatesBody.scoped updatesScope = true ∧
  calleeBody.wellFormed = true ∧ calleeBody.scoped calleeScope = true ∧
  callBody.wellFormed = true ∧ callBody.scoped callScope = true

theorem checked_trees : CheckedTrees := by decide +kernel

namespace StructuralControls
def atom : Expr .truth := .truth true
theorem not_collision :
    (Expr.not (.orElse atom atom)).render = (Expr.orElse (.not atom) atom).render ∧
    (Expr.not (.orElse atom atom)).wellFormed = false ∧
    (Expr.orElse (.not atom) atom).wellFormed = true := by decide +kernel

theorem subtraction_collision :
    (Expr.sub (.number 10) (.sub (.number 3) (.number 2))).render =
      (Expr.sub (.sub (.number 10) (.number 3)) (.number 2)).render ∧
    (Expr.sub (.number 10) (.sub (.number 3) (.number 2))).wellFormed = false ∧
    (Expr.sub (.sub (.number 10) (.number 3)) (.number 2)).wellFormed = true := ⟨rfl, by decide +kernel, by decide +kernel⟩

theorem implicit_grouping_rejected :
    (Expr.app (.function .isEmpty) (.ite atom (.variable "x") (.variable "y"))).wellFormed = false ∧
    (Expr.field .actualAfter (.group (.variable "target"))).wellFormed = false ∧
    (Expr.orElse atom (.andThen atom atom)).wellFormed = false ∧
    (Expr.not (.group (.orElse atom atom))).wellFormed = true := by decide +kernel

theorem unbound_or_wrong_kind_rejected :
    (Expr.variable (ty := .actual) "target").scoped callScope = false ∧
    (Expr.variable (ty := .flow) "scan").scoped callScope = false := by decide +kernel
end StructuralControls

theorem target_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) :
    targetBody.eval modelCalls ({text,context,position,facts,parameter} : Frame).locals =
      procedureTargetActual text context.model position facts parameter := by
  dsimp +instances only [List.foldr, Token.shell, targetBody, Command.eval, Expr.eval, modelCalls, Frame.locals, Locals.set,
    Field.get, apply2, apply3, procedureTargetActual, Native.Context.model]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte,
    decide_eq_true_eq, Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', or_assoc]

theorem actual_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) :
    actualBody.eval modelCalls ({text,context,position,facts,parameter} : Frame).locals =
      procedureActualAfter text context.model position facts parameter := by
  dsimp +instances only [List.foldr, Token.shell, actualBody, Expr.eval, modelCalls, Frame.locals, Field.get, apply5,
    procedureActualAfter, procedureInputFormal]
  simp only [String.reduceEq, ↓reduceIte, decide_eq_true_eq]

theorem actualsTail_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (seen : FormalSet) (ordered : ordinal ≤ last) :
    actualsTailBody.eval modelCalls ({text,context,position,facts,catalog,first,last,ordinal,named,seen} : Frame).locals =
      procedureActualsTailModel text context.model position facts catalog first last ordinal named seen := by
  rw [procedureActualsTailModel]
  dsimp +instances only [List.foldr, Token.shell, actualsTailBody, Expr.eval, modelCalls, Frame.locals, Locals.set, Field.get,
    apply3, apply5, apply7, apply10, tokenAfter, ShellToken.symbol]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true]
  by_cases final : ordinal = last
  · simp only [final, ↓reduceIte]
  · have before : ordinal < last := by omega
    simp only [final, before, ↓reduceIte, ↓reduceDIte]

theorem actuals_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last : Nat) (_ordered : first ≤ last) :
    actualsBody.eval modelCalls ({text,context,position,facts,catalog,first,last} : Frame).locals =
      procedureActualsAfter text context.model position facts catalog first last := by
  rfl

theorem payloadsFree_model (text : Source) (context : Native.Context) (position : Nat)
    (incoming : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (callAfter targetFirst targetAfter : Nat) (ordered : ordinal ≤ last) :
    payloadsFreeBody.eval modelCalls
        ({text,context,position,incoming,catalog,first,last,ordinal,named,callAfter,targetFirst,targetAfter} : Frame).locals =
      procedurePayloadsFreeModel text context.model position incoming catalog first last ordinal named callAfter targetFirst targetAfter := by
  rw [procedurePayloadsFreeModel]
  dsimp +instances only [List.foldr, Token.shell, payloadsFreeBody, Expr.eval, modelCalls, Frame.locals, Locals.set, Field.get,
    apply2, apply3, apply5, apply7, apply12, tokenAfter, ShellToken.symbol]
  simp only [nat_beq_decide, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true,
    Bool.not_eq_true']
  by_cases final : ordinal = last
  · simp only [final, ↓reduceIte]
  · have before : ordinal < last := by omega
    simp only [final, before, ↓reduceIte, ↓reduceDIte]

theorem update_model (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (parameter : ProcedureBindings.Formal) (catalog : ProcedureBindings.Metadata)
    (first last callFirst callAfter : Nat) :
    updateBody.eval modelCalls ({text,context,incoming,scan,parameter,catalog,first,last,callFirst,callAfter} : Frame).locals =
      procedureUpdateStep text context.model incoming scan parameter catalog first last callFirst callAfter := by
  dsimp +instances only [List.foldr, Token.shell, updateBody, Command.eval, Expr.eval, modelCalls, Frame.locals, Locals.set,
    Field.get, ScanField.set, apply5, apply10, procedureUpdateStep]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte,
    decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true', or_assoc]

theorem updatesTail_model (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (seen : FormalSet) (callFirst callAfter : Nat) (ordered : ordinal ≤ last) :
    updatesTailBody.eval modelCalls ({text,context,incoming,scan,catalog,first,last,ordinal,named,seen,callFirst,callAfter} : Frame).locals =
      procedureUpdatesTailModel text context.model incoming scan catalog first last ordinal named seen callFirst callAfter := by
  rw [procedureUpdatesTailModel]
  dsimp +instances only [List.foldr, Token.shell, updatesTailBody, Expr.eval, modelCalls, Frame.locals, Locals.set,
    Field.get, ScanField.set, apply4, apply7, apply10, apply12]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true]
  by_cases final : ordinal = last
  · simp only [final, ↓reduceIte]
  · have before : ordinal < last := by omega
    simp only [final, before, ↓reduceIte, ↓reduceDIte]

theorem updates_model (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat)
    (_ordered : first ≤ last) :
    updatesBody.eval modelCalls ({text,context,incoming,scan,catalog,first,last,callFirst,callAfter} : Frame).locals =
      procedureUpdatesModel text context.model incoming scan catalog first last callFirst callAfter := by
  rfl

theorem callee_model (text : Source) (context : Native.Context) (position : Nat)
    (catalog : ProcedureBindings.Metadata) :
    calleeBody.eval modelCalls ({text,context,position,catalog} : Frame).locals =
      procedureCalleeAt text context.model position catalog := by
  dsimp +instances only [List.foldr, Token.shell, calleeBody, Expr.eval, modelCalls, Frame.locals, Locals.set, Field.get,
    apply2, apply4, procedureCalleeAt, Native.Context.model, Native.Context.arrayTable]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte,
    decide_eq_true_eq, Bool.or_eq_true, or_assoc]

theorem call_model (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) :
    callBody.eval modelCalls ({text,context,scan,catalog} : Frame).locals =
      procedureCallBody text context.model scan catalog := by
  dsimp +instances only [List.foldr, Token.shell, callBody, Command.eval, Expr.eval, modelCalls, Frame.locals, Locals.set, Field.get,
    ScanField.set, apply2, apply3, apply4, apply7, apply8, procedureCallBody, tokenAfter, ShellToken.symbol]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte,
    decide_eq_true_eq, Bool.or_eq_true]

end Silver.Predicate.ProcedureCallNative
