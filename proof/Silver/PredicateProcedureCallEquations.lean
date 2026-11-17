module

public import Silver.PredicateProcedureCallNative

@[expose] public section
namespace Silver.Predicate.ProcedureCallNative
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def targetScope : Scope :=
  [(.source,"text"),(.context,"context"),(.number,"position"),(.flow,"facts"),(.formal,"parameter")]
def actualsScope : Scope :=
  [(.source,"text"),(.context,"context"),(.number,"position"),(.flow,"facts"),
   (.metadata,"catalog"),(.number,"first"),(.number,"last")]
def updateScope : Scope :=
  [(.source,"text"),(.context,"context"),(.flow,"incoming"),(.scan,"scan"),
   (.formal,"parameter"),(.number,"call_first"),(.number,"call_after")]
def updatesScope : Scope :=
  [(.source,"text"),(.context,"context"),(.flow,"incoming"),(.scan,"scan"),
   (.metadata,"catalog"),(.number,"first"),(.number,"last"),(.number,"call_first"),(.number,"call_after")]
def calleeScope : Scope :=
  [(.source,"text"),(.context,"context"),(.number,"position"),(.metadata,"catalog")]
def callScope : Scope :=
  [(.source,"text"),(.context,"context"),(.scan,"scan"),(.metadata,"catalog")]

abbrev CheckedTrees : Prop :=
  targetBody.wellFormed = true ∧ targetBody.scoped targetScope = true ∧
  actualBody.wellFormed = true ∧ actualBody.scoped targetScope = true ∧
  actualsBody.wellFormed = true ∧ actualsBody.scoped actualsScope = true ∧
  updateBody.wellFormed = true ∧ updateBody.scoped updateScope = true ∧
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
    procedureActualAfter]
  simp only [String.reduceEq, ↓reduceIte, decide_eq_true_eq]

theorem actuals_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last : Nat) (ordered : first ≤ last) :
    actualsBody.eval modelCalls ({text,context,position,facts,catalog,first,last} : Frame).locals =
      procedureActualsAfter text context.model position facts catalog first last := by
  rw [procedureActualsAfter]
  dsimp +instances only [List.foldr, Token.shell, actualsBody, Expr.eval, modelCalls, Frame.locals, Locals.set, Field.get,
    apply3, apply5, apply7, tokenAfter, ShellToken.symbol]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  by_cases final : first = last
  · simp only [final, ↓reduceIte]
  · have before : first < last := by omega
    simp only [final, before, ↓reduceIte, ↓reduceDIte]

theorem update_model (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (parameter : ProcedureBindings.Formal) (callFirst callAfter : Nat) :
    updateBody.eval modelCalls ({text,context,incoming,scan,parameter,callFirst,callAfter} : Frame).locals =
      procedureUpdateStep text context.model incoming scan parameter callFirst callAfter := by
  dsimp +instances only [List.foldr, Token.shell, updateBody, Command.eval, Expr.eval, modelCalls, Frame.locals, Locals.set,
    Field.get, ScanField.set, apply5, procedureUpdateStep]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte,
    decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true', or_assoc]

theorem updates_model (text : Source) (context : Native.Context) (incoming : ActiveFlow)
    (scan : BodyScan) (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat)
    (ordered : first ≤ last) :
    updatesBody.eval modelCalls ({text,context,incoming,scan,catalog,first,last,callFirst,callAfter} : Frame).locals =
      procedureUpdatesModel text context.model incoming scan catalog first last callFirst callAfter := by
  rw [procedureUpdatesModel]
  dsimp +instances only [List.foldr, Token.shell, updatesBody, Expr.eval, modelCalls, Frame.locals, Locals.set, Field.get,
    apply4, apply7, apply9]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  by_cases final : first = last
  · simp only [final, ↓reduceIte]
  · have before : first < last := by omega
    simp only [final, before, ↓reduceIte, ↓reduceDIte]

theorem callee_model (text : Source) (context : Native.Context) (position : Nat)
    (catalog : ProcedureBindings.Metadata) :
    calleeBody.eval modelCalls ({text,context,position,catalog} : Frame).locals =
      procedureCalleeAt text context.model position catalog := by
  dsimp +instances only [List.foldr, Token.shell, calleeBody, Expr.eval, modelCalls, Frame.locals, Locals.set, Field.get,
    apply2, apply4, procedureCalleeAt, Native.Context.model]
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
