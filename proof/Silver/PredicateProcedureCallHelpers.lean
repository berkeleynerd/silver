module

public import Silver.PredicateProcedureCallDomains

@[expose] public section
namespace Silver.Predicate.ProcedureCallNative
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

variable {calls : Calls}

theorem normalized_target (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .target = modelCalls .target := by
  classical
  funext text context position facts parameter
  change (if ActualDomain text context position facts parameter then _ else _) = _
  split
  · rename_i valid
    rw [defs.target text context position facts parameter valid]
    calc
      _ = targetBody.eval modelCalls ({text,context,position,facts,parameter} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, targetBody, Command.eval, Expr.eval, apply2, apply3,
          Frame.locals, Locals.set, Field.get, ScanField.set]
        simp only [meaning.skip, meaning.nameAfter, meaning.scalarTarget, meaning.booleanTarget, meaning.isEmpty, meaning.included]
      _ = _ := target_model ..
  · rfl

theorem normalized_actual (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .actual = modelCalls .actual := by
  classical
  funext text context position facts parameter
  change (if ActualDomain text context position facts parameter then _ else _) = _
  split
  · rename_i valid
    rw [defs.actual text context position facts parameter valid]
    calc
      _ = actualBody.eval modelCalls ({text,context,position,facts,parameter} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, actualBody, Expr.eval, apply5,
          Frame.locals, Locals.set, Field.get, ScanField.set]
        simp only [meaning.functionActual, normalized_target meaning defs]
      _ = _ := actual_model ..
  · rfl

/-- The source recursive model is interpreted by its remaining formal suffix.
The recursive call stays arbitrary until this induction establishes its meaning. -/
theorem normalized_actualsModel_at (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) (first last : Nat) :
    totalizeCalls calls .actualsModel text context position facts catalog first last =
      modelCalls .actualsModel text context position facts catalog first last := by
  classical
  change (if ActualsDomain text context position facts catalog first last then _ else _) = _
  split
  · rename_i valid
    rw [defs.actualsModel text context position facts catalog first last valid]
    dsimp +instances only [List.foldr, Token.shell, actualsBody, Expr.eval, Frame.locals, Locals.set, Field.get,
      apply3, apply5, apply7]
    simp only [meaning.token, normalized_actual meaning defs, reduceCtorEq,
      String.reduceEq, ↓reduceIte, ↓reduceDIte]
    simp only [modelCalls]
    rw [procedureActualsAfter]
    by_cases zero : procedureActualAfter text context.model position facts (ProcedureBindings.parameter catalog first) = 0
    · simp only [zero, decide_true, ↓reduceIte]
    · by_cases final : first = last
      · subst last
        simp only [zero, decide_false, decide_true, Bool.false_eq_true, ↓reduceIte]
        rfl
      · have advancing : first < last := by have ordered := valid.2.2.2.1; omega
        simp only [zero, final, advancing, decide_false, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte]
        by_cases comma : fixedAfter text
            (procedureActualAfter text context.model position facts (ProcedureBindings.parameter catalog first)) "," false = 0
        · simp only [tokenAfter, ShellToken.symbol, comma, decide_true, ↓reduceIte]
        · simp only [tokenAfter, ShellToken.symbol, comma, decide_false,
            Bool.false_eq_true, ↓reduceIte]
          exact normalized_actualsModel_at meaning defs text context _ facts catalog (first + 1) last
  · rfl
termination_by last - first
decreasing_by omega

theorem normalized_actualsModel (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .actualsModel = modelCalls .actualsModel := by
  funext text context position facts catalog first last
  exact normalized_actualsModel_at meaning defs text context position facts catalog first last

theorem normalized_actuals (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .actuals = modelCalls .actuals := by
  classical
  funext text context position facts catalog first last
  change (if ActualsDomain text context position facts catalog first last then _ else _) = _
  split
  · rename_i valid
    rw [defs.actuals text context position facts catalog first last valid]
    have result := congrFun (congrFun (congrFun (congrFun (congrFun (congrFun (congrFun
      (normalized_actualsModel meaning defs) text) context) position) facts) catalog) first) last
    simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result
  · rfl

theorem normalized_update (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .update = modelCalls .update := by
  classical
  funext text context incoming scan parameter callFirst callAfter
  change (if UpdateDomain text context incoming scan parameter callFirst callAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.update text context incoming scan parameter callFirst callAfter valid]
    calc
      _ = updateBody.eval modelCalls ({text,context,incoming,scan,parameter,callFirst,callAfter} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, updateBody, Command.eval, Expr.eval, apply5,
          Frame.locals, Locals.set, Field.get, ScanField.set]
        simp only [meaning.nameFree, meaning.invalid, normalized_actual meaning defs, normalized_target meaning defs]
      _ = _ := update_model ..
  · rfl

theorem normalized_updatesModel_at (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (context : Native.Context) (incoming : ActiveFlow) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) :
    totalizeCalls calls .updatesModel text context incoming scan catalog first last callFirst callAfter =
      modelCalls .updatesModel text context incoming scan catalog first last callFirst callAfter := by
  classical
  change (if UpdatesModelDomain text context incoming scan catalog first last callFirst callAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.updatesModel text context incoming scan catalog first last callFirst callAfter valid]
    dsimp +instances only [List.foldr, Token.shell, updatesBody, Expr.eval, Frame.locals, Locals.set, Field.get,
      apply4, apply7, apply9]
    simp only [meaning.bodyToken, meaning.invalidModel, normalized_update meaning defs,
      reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
    change (if decide ((procedureUpdateStep text context.model incoming scan
      (ProcedureBindings.parameter catalog first) callFirst callAfter).position = 0) then _
      else if decide (first = last) then _ else _) =
      procedureUpdatesModel text context.model incoming scan catalog first last callFirst callAfter
    rw [procedureUpdatesModel]
    by_cases zero : (procedureUpdateStep text context.model incoming scan
        (ProcedureBindings.parameter catalog first) callFirst callAfter).position = 0
    · simp only [zero, decide_true, ↓reduceIte]
      rfl
    · by_cases final : first = last
      · subst last
        simp only [zero, decide_false, decide_true, Bool.false_eq_true, ↓reduceIte]
        rfl
      · have advancing : first < last := by have ordered := valid.2.2.2.2.1; omega
        simp only [zero, final, advancing, decide_false, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte]
        by_cases comma : (bodyToken text (procedureUpdateStep text context.model incoming scan
            (ProcedureBindings.parameter catalog first) callFirst callAfter) (.symbol ",")).position = 0
        · simp only [modelCalls, comma, decide_true, ↓reduceIte]
        · simp only [modelCalls, comma, decide_false, Bool.false_eq_true, ↓reduceIte]
          exact normalized_updatesModel_at meaning defs text context incoming _ catalog
            (first + 1) last callFirst callAfter
  · rfl
termination_by last - first
decreasing_by omega

theorem normalized_updatesModel (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .updatesModel = modelCalls .updatesModel := by
  funext text context incoming scan catalog first last callFirst callAfter
  exact normalized_updatesModel_at meaning defs text context incoming scan catalog first last callFirst callAfter

theorem normalized_updates (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .updates = modelCalls .updates := by
  classical
  funext text context scan catalog first last callFirst callAfter
  change (if UpdatesDomain text context scan catalog first last callFirst callAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.updates text context scan catalog first last callFirst callAfter valid]
    have inner : UpdatesModelDomain text context scan.facts scan catalog first last callFirst callAfter :=
      ⟨valid.1, valid.1.2.2, valid.2⟩
    have result := congrFun (congrFun (congrFun (congrFun (congrFun (congrFun (congrFun (congrFun (congrFun
      (normalized_updatesModel meaning defs) text) context) scan.facts) scan) catalog) first) last) callFirst) callAfter
    simpa only [totalizeCalls, modelCalls, inner, ↓reduceIte, procedureUpdates] using result
  · rfl

theorem normalized_callee (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .callee = modelCalls .callee := by
  classical
  funext text context position catalog
  change (if CalleeDomain text context position catalog then _ else _) = _
  split
  · rename_i valid
    rw [defs.callee text context position catalog valid]
    calc
      _ = calleeBody.eval modelCalls ({text,context,position,catalog} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, calleeBody, Expr.eval, apply2, apply4,
          Frame.locals, Locals.set, Field.get, ScanField.set]
        simp only [meaning.skip, meaning.nameAfter, meaning.namesLookup, meaning.scalarLookup, meaning.booleanLookup, meaning.arrayLookup, meaning.procedureLookup]
      _ = _ := callee_model ..
  · rfl

theorem normalized_call (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .call = modelCalls .call := by
  classical
  funext text context scan catalog
  change (if CallDomain text context scan catalog then _ else _) = _
  split
  · rename_i valid
    rw [defs.call text context scan catalog valid]
    calc
      _ = callBody.eval modelCalls ({text,context,scan,catalog} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, callBody, Command.eval, Expr.eval, apply2, apply3, apply4, apply7, apply8,
          Frame.locals, Locals.set, Field.get, ScanField.set]
        simp only [meaning.skip, meaning.nameAfter, meaning.token, meaning.invalid, normalized_callee meaning defs, normalized_actuals meaning defs, normalized_updates meaning defs]
      _ = _ := call_model ..
  · rfl

theorem callee_meaning (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (context : Native.Context) (position : Nat) (catalog : ProcedureBindings.Metadata)
    (valid : CalleeDomain text context position catalog) :
    calls .callee text context position catalog = procedureCalleeAt text context.model position catalog := by
  have result := congrFun (congrFun (congrFun (congrFun (normalized_callee meaning defs) text) context) position) catalog
  simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result

theorem call_meaning (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (context : Native.Context) (scan : BodyScan) (catalog : ProcedureBindings.Metadata)
    (valid : CallDomain text context scan catalog) :
    calls .call text context scan catalog = procedureCallBody text context.model scan catalog := by
  have result := congrFun (congrFun (congrFun (congrFun (normalized_call meaning defs) text) context) scan) catalog
  simpa only [totalizeCalls, modelCalls, valid, ↓reduceIte] using result

end Silver.Predicate.ProcedureCallNative
