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

/-- The ordinal counts written actuals; selection retains the fixed formal
slice and incoming flow, including all rejection branches. -/
theorem normalized_actualsTail_at (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat) (named : Bool) (seen : FormalSet) :
    totalizeCalls calls .actualsTail text context position facts catalog first last ordinal named seen =
      modelCalls .actualsTail text context position facts catalog first last ordinal named seen := by
  classical
  change (if ActualsTailDomain text context position facts catalog first last ordinal then _ else _) = _
  split
  · rename_i valid
    rw [defs.actualsTail text context position facts catalog first last ordinal named seen valid]
    calc
      _ = actualsTailBody.eval modelCalls
          ({text,context,position,facts,catalog,first,last,ordinal,named,seen} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, actualsTailBody, Expr.eval, Frame.locals, Locals.set,
          Field.get, apply3, apply5, apply7, apply10]
        simp only [meaning.token, meaning.association, meaning.markFormal, normalized_actual meaning defs, reduceCtorEq,
          String.reduceEq, ↓reduceIte, ↓reduceDIte]
        by_cases final : ordinal = last
        · simp only [final, decide_true, ↓reduceIte]
        · have advancing : ordinal < last := by have ordered := valid.2.2.2.2.1; omega
          have recurse := normalized_actualsTail_at meaning defs text context
            (tokenAfter text (procedureActualAfter text context.model
              (procedureAssociation text position catalog first last ordinal named).payloadFirst facts
              (ProcedureBindings.parameter catalog (procedureAssociation text position catalog first last ordinal named).formal)) (.symbol ","))
            facts catalog first last (ordinal + 1)
            (procedureAssociation text position catalog first last ordinal named).named
            (markFormal seen (procedureAssociation text position catalog first last ordinal named).formal)
          simp only [final, decide_false, Bool.false_eq_true, ↓reduceIte, modelCalls] at recurse ⊢
          rw [recurse]
      _ = _ := actualsTail_model text context position facts catalog first last ordinal named seen valid.2.2.2.2.1
  · rfl
termination_by last - ordinal
decreasing_by omega

theorem normalized_actualsTail (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .actualsTail = modelCalls .actualsTail := by
  funext text context position facts catalog first last ordinal named seen
  exact normalized_actualsTail_at meaning defs text context position facts catalog first last ordinal named seen

theorem normalized_actualsModel (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .actualsModel = modelCalls .actualsModel := by
  classical
  funext text context position facts catalog first last
  change (if ActualsDomain text context position facts catalog first last then _ else _) = _
  split
  · rename_i valid
    rw [defs.actualsModel text context position facts catalog first last valid]
    dsimp +instances only [List.foldr, actualsBody, Expr.eval, Frame.locals, apply10]
    rw [normalized_actualsTail meaning defs]
    rfl
  · rfl

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

theorem normalized_payloadsFreeModel_at (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (context : Native.Context) (position : Nat) (incoming : ActiveFlow)
    (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat) (named : Bool)
    (callAfter targetFirst targetAfter : Nat) :
    totalizeCalls calls .payloadsFreeModel text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter =
      modelCalls .payloadsFreeModel text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter := by
  classical
  change (if PayloadsFreeModelDomain text context position incoming catalog first last ordinal callAfter targetFirst targetAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.payloadsFreeModel text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter valid]
    calc
      _ = payloadsFreeBody.eval modelCalls
          ({text,context,position,incoming,catalog,first,last,ordinal,named,callAfter,targetFirst,targetAfter} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, payloadsFreeBody, Expr.eval, Frame.locals, Locals.set,
          Field.get, apply2, apply3, apply5, apply7, apply12]
        simp only [meaning.skip, meaning.token, meaning.nameFreeModel, meaning.association,
          normalized_actual meaning defs, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
        by_cases final : ordinal = last
        · simp only [final, decide_true, ↓reduceIte]
        · have advancing : ordinal < last := by have ordered := valid.1.2.2.2.2.1; omega
          have recurse := normalized_payloadsFreeModel_at meaning defs text context
            (tokenAfter text (procedureActualAfter text context.model
              (procedureAssociation text position catalog first last ordinal named).payloadFirst incoming
              (ProcedureBindings.parameter catalog (procedureAssociation text position catalog first last ordinal named).formal)) (.symbol ","))
            incoming catalog first last (ordinal + 1)
            (procedureAssociation text position catalog first last ordinal named).named callAfter targetFirst targetAfter
          simp only [final, decide_false, Bool.false_eq_true, ↓reduceIte, modelCalls] at recurse ⊢
          rw [recurse]
      _ = _ := payloadsFree_model text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter valid.1.2.2.2.2.1
  · rfl
termination_by last - ordinal
decreasing_by omega

theorem normalized_payloadsFreeModel (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .payloadsFreeModel = modelCalls .payloadsFreeModel := by
  funext text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter
  exact normalized_payloadsFreeModel_at meaning defs text context position incoming catalog first last ordinal named callAfter targetFirst targetAfter

theorem normalized_payloadsFree (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .payloadsFree = modelCalls .payloadsFree := by
  classical
  funext text context position incoming catalog first last callAfter targetFirst targetAfter
  change (if PayloadsFreeDomain text context position incoming catalog first last callAfter targetFirst targetAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.payloadsFree text context position incoming catalog first last callAfter targetFirst targetAfter valid]
    have inner : PayloadsFreeModelDomain text context position incoming catalog first last first callAfter targetFirst targetAfter :=
      ⟨⟨valid.1.1, valid.1.2.1, valid.1.2.2.1, Nat.le_refl _, valid.1.2.2.2⟩, valid.2⟩
    have result := normalized_payloadsFreeModel_at meaning defs text context position incoming catalog first last first false callAfter targetFirst targetAfter
    simpa only [totalizeCalls, modelCalls, inner, ↓reduceIte, procedurePayloadsFree] using result
  · rfl

theorem normalized_update (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .update = modelCalls .update := by
  classical
  funext text context incoming scan parameter catalog first last callFirst callAfter
  change (if UpdateDomain text context incoming scan parameter catalog first last callFirst callAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.update text context incoming scan parameter catalog first last callFirst callAfter valid]
    calc
      _ = updateBody.eval modelCalls ({text,context,incoming,scan,parameter,catalog,first,last,callFirst,callAfter} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, updateBody, Command.eval, Expr.eval, apply5, apply10,
          Frame.locals, Locals.set, Field.get, ScanField.set]
        simp only [meaning.invalid, normalized_payloadsFree meaning defs,
          normalized_actual meaning defs, normalized_target meaning defs]
      _ = _ := update_model ..
  · rfl

theorem normalized_updatesTail_at (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls)
    (text : Source) (context : Native.Context) (incoming : ActiveFlow) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat) (named : Bool) (seen : FormalSet)
    (callFirst callAfter : Nat) :
    totalizeCalls calls .updatesTail text context incoming scan catalog first last ordinal named seen callFirst callAfter =
      modelCalls .updatesTail text context incoming scan catalog first last ordinal named seen callFirst callAfter := by
  classical
  change (if UpdatesTailDomain text context incoming scan catalog first last ordinal callFirst callAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.updatesTail text context incoming scan catalog first last ordinal named seen callFirst callAfter valid]
    calc
      _ = updatesTailBody.eval modelCalls
          ({text,context,incoming,scan,catalog,first,last,ordinal,named,seen,callFirst,callAfter} : Frame).locals := by
        dsimp +instances only [List.foldr, Token.shell, updatesTailBody, Expr.eval, Frame.locals, Locals.set,
          Field.get, ScanField.set, apply4, apply7, apply10, apply12]
        simp only [meaning.bodyToken, meaning.invalidModel, meaning.association, meaning.markFormal, normalized_update meaning defs,
          reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]
        by_cases final : ordinal = last
        · simp only [final, decide_true, ↓reduceIte]
        · have advancing : ordinal < last := by have ordered := valid.2.2.2.2.2.1; omega
          have recurse := normalized_updatesTail_at meaning defs text context incoming
            (bodyToken text (procedureUpdateStep text context.model incoming
              {scan with position := (procedureAssociation text scan.position catalog first last ordinal named).payloadFirst}
              (ProcedureBindings.parameter catalog (procedureAssociation text scan.position catalog first last ordinal named).formal)
              catalog first last callFirst callAfter) (.symbol ","))
            catalog first last (ordinal + 1) (procedureAssociation text scan.position catalog first last ordinal named).named
            (markFormal seen (procedureAssociation text scan.position catalog first last ordinal named).formal) callFirst callAfter
          simp only [final, decide_false, Bool.false_eq_true, ↓reduceIte, modelCalls] at recurse ⊢
          rw [recurse]
      _ = _ := updatesTail_model text context incoming scan catalog first last ordinal named seen callFirst callAfter valid.2.2.2.2.2.1
  · rfl
termination_by last - ordinal
decreasing_by omega

theorem normalized_updatesTail (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .updatesTail = modelCalls .updatesTail := by
  funext text context incoming scan catalog first last ordinal named seen callFirst callAfter
  exact normalized_updatesTail_at meaning defs text context incoming scan catalog first last ordinal named seen callFirst callAfter

theorem normalized_updatesModel (meaning : ImportsMeaning calls) (defs : DefinitionEquations calls) :
    totalizeCalls calls .updatesModel = modelCalls .updatesModel := by
  classical
  funext text context incoming scan catalog first last callFirst callAfter
  change (if UpdatesModelDomain text context incoming scan catalog first last callFirst callAfter then _ else _) = _
  split
  · rename_i valid
    rw [defs.updatesModel text context incoming scan catalog first last callFirst callAfter valid]
    dsimp +instances only [List.foldr, updatesBody, Expr.eval, Frame.locals, apply12]
    rw [normalized_updatesTail meaning defs]
    rfl
  · rfl

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
        simp only [meaning.skip, meaning.nameAfter, meaning.namesLookup, meaning.scalarLookup, meaning.booleanLookup, meaning.arrayLookup, meaning.arrayTypeLookup, meaning.procedureLookup]
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
