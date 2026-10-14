module

public import Silver.SequenceModelRanges
public import Silver.SequenceEquations
public import Silver.ComposeModelEquations

@[expose] public section

/-! Concrete inhabitants of the sequence source equations. The model satisfies
the equations independently of the conditional source-correspondence proof. -/

namespace Silver.Sequence.Expressions
open Compose

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

def modelCalls : Calls where
  helpers := Compose.Expressions.modelCalls
  scanToken := Sequence.scanToken
  basic := basicStatementAt
  basicTail := Sequence.basicTail
  readBasic := readBasicStatements
  native := Native.modelCalls
  readStatements := Sequence.readStatements
  scanStep := Sequence.scanStep
  suffix := fun text form index scan =>
    scanSuffix text form (form.tokens.drop (index - 1)) scan
  formResult := Sequence.formResult
  member := accepts
  arguments := hasArguments
  assignment := hasAssignment
  output := hasOutput

theorem model_helpers : HelperMeaning modelCalls where
  equations := (Compose.Expressions.model_definitions Compose.Expressions.model_ranges).toHelperEquations
  step _ _ _ _ _ _ _ := rfl
  trivia _ _ _ _ _ := rfl

theorem model_ranges : RangeContracts modelCalls where
  token text valid scan token context _ := model_scanToken_valid text valid scan token context
  basic text valid scan context := by
    refine ⟨model_basicStatementAt_valid text valid scan context, ?_⟩
    by_cases zero : (basicStatementAt text scan).state.position = 0
    · exact Or.inl zero
    · exact Or.inr (basic_progress zero)
  basicTail text valid scan stop context _ := model_basicTail_valid text valid scan stop context
  readBasic text valid scan stop context _ := model_readBasicStatements_valid text valid scan stop context
  readStatements text valid scan stop context _ := model_readStatements_valid text valid scan stop context
  step text valid form token scan _ context := model_scanStep_valid text valid form token scan context

theorem model_callTokens (text : Source) (tokens : List ShellToken) (scan : ScanResult) :
    callTokens modelCalls text tokens scan = scanTokens text .direct tokens scan := rfl

theorem model_basicRaw (text : Source) (scan : ScanResult) :
    basicRawCalls modelCalls text scan = basicRaw text scan := by
  change (if fixedAfter text scan.state.position "null" true ≠ 0 then
    scanTokens text .direct BasicKind.null.tokens scan
  else if fixedAfter text scan.state.position "silver_io" true ≠ 0 then
    {scanTokens text .direct BasicKind.output.tokens scan with output := true}
  else {scanTokens text .direct BasicKind.assignment.tokens scan with assigned := true}) = _
  by_cases hasNull : fixedAfter text scan.state.position "null" true ≠ 0
  · simp +instances [basicRaw, basicKind, hasNull, BEq.beq]
  · by_cases hasOutput : fixedAfter text scan.state.position "silver_io" true ≠ 0
    · simp +instances [basicRaw, basicKind, hasNull, hasOutput, BEq.beq]
    · simp +instances [basicRaw, basicKind, hasNull, hasOutput, BEq.beq]

theorem model_basic (text : Source) (scan : ScanResult) :
    modelCalls.basic text scan = basicBody.run modelCalls {text,scan} := by
  rw [basic_eval, model_basicRaw]
  rfl

theorem model_tail_equation (text : Source) (read : ScanResult → ScanResult)
    (preserves : ∀ scan, ValidScan text scan → ValidScan text (read scan))
    (progress : ∀ scan, (read scan).state.position ≠ 0 → scan.state.position < (read scan).state.position)
    (stop : ShellToken) (scan : ScanResult) (context : ValidScan text scan) :
    Sequence.tail text read (.token stop) scan =
      if scan.state.position = 0 then invalidScan
      else if tokenAfter text scan.state.position stop ≠ 0 then scan
      else if (read scan).state.position = 0 then invalidScan
      else Sequence.tail text read (.token stop) (read scan) := by
  rw [Sequence.tail]
  dsimp +instances only [stopAfter]
  by_cases zero : scan.state.position = 0
  · simp +instances only [zero, ↓reduceIte]
  · simp +instances only [zero, ↓reduceIte]
    by_cases done : tokenAfter text scan.state.position stop ≠ 0
    · rw [ite_eq_left done, ite_eq_left done]
    · simp +instances only [done, ↓reduceIte]
      by_cases failed : (read scan).state.position = 0
      · simp +instances only [failed, ↓reduceIte]
      · simp +instances only [failed, ↓reduceIte]
        have bound : (read scan).state.position ≤ text.length + 1 := (preserves scan context).1
        have advances := progress scan failed
        have decreases : text.length + 1 - (read scan).state.position <
            text.length + 1 - scan.state.position := by omega
        simp +instances only [decreases, ↓reduceDIte]

theorem model_stop (text : Source) (position : Nat) (stop : ShellToken)
    (valid : ValidStop stop) :
    modelCalls.helpers.function .takeToken text position stop = tokenAfter text position stop := by
  rcases valid with rfl | rfl <;>
    rfl

theorem model_basicTail (text : Source) (valid : ValidText text)
    (scan : ScanResult) (stop : ShellToken) (context : ValidScan text scan) (stopValid : ValidStop stop) :
    modelCalls.basicTail text scan stop = basicTailBody.eval modelCalls {text,scan,stop} := by
  change Sequence.tail text (basicStatementAt text) (.token stop) scan = _
  rw [model_tail_equation text (basicStatementAt text) (model_basicStatementAt_valid text valid)
    (fun _ h => basic_progress h) stop scan context]
  dsimp +instances only [basicTailBody, Expr.eval, Condition.eval, HelperRef.eval]
  simp only [model_stop text _ _ stopValid, decide_eq_true_eq]
  rfl

theorem model_suffix (text : Source) (form : Form) (index : Nat) (scan : ScanResult)
    (first : 1 ≤ index) :
    modelCalls.suffix text form index scan = suffixBody.eval modelCalls {text,scan,form,nextToken := index} := by
  dsimp +instances only [suffixBody, Expr.eval, Condition.eval, IndexRef.eval, modelCalls,
    Compose.Expressions.modelCalls, Compose.Expressions.modelPrimitives]
  simp only [decide_eq_true_eq]
  by_cases zero : scan.state.position = 0
  · cases form.tokens.drop (index - 1) <;> simp +instances [scanSuffix, zero]
  · simp +instances only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · have enough : form.tokens.length ≤ index - 1 := by omega
      simp +instances [finished, List.drop_eq_nil_of_le enough, scanSuffix, zero]
    · have present : index - 1 < form.tokens.length := by omega
      have drop := List.drop_eq_getElem_cons present
      have next : index - 1 + 1 = index := by omega
      simp +instances only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, scanSuffix, next,
        List.getD, List.getElem?_eq_getElem present, Option.getD_some]
      simp +instances [zero]

theorem model_definitions : DefinitionEquations modelCalls where
  ranges := model_ranges
  token _ _ _ _ _ _ := rfl
  basic text _ scan _ := model_basic text scan
  basicTail := model_basicTail
  readBasic _ _ _ _ _ _ := rfl
  native := Native.model_equations
  readStatements text valid scan stop context stopValid :=
    (Native.model_adapter text valid scan stop context stopValid).symm
  step text _ form token scan _ _ := by
    cases token <;> rfl
  suffix text _ form index scan _ first _ := model_suffix text form index scan first
  formResult text form := by
    simp +instances [modelCalls, formBody, Expr.eval, Condition.eval, Sequence.formResult,
      Compose.Expressions.modelCalls]
  member text := by
    simp only [modelCalls, MembershipBody.eval, memberBody, accepts, selectedForm,
      List.isSome_find?, Bool.and_true]
    rfl
  arguments _ := rfl
  assignment _ := rfl
  output _ := rfl

end Silver.Sequence.Expressions
