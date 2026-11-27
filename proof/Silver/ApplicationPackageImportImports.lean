module

public import Silver.ApplicationPackageImportLoops
public import Silver.ApplicationPackageNamesImports
public import Silver.OutputExpressions

@[expose] public section

namespace Silver.ApplicationPackageImport
open Compose Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem outerLoop_meaning (calls : ApplicationPackageNames.Native.Calls)
    (primitives : ApplicationPackageNames.Native.PrimitiveMeaning calls)
    (normalize : Source → Source) (text : Source) (valid : ValidText text)
    (innerFuel fuel : Nat) (enoughInner : text.length + 2 ≤ innerFuel)
    (cursor : Model.Cursor) (cursorValid : cursor.Valid text) :
    Model.outerLoop (fromNames calls normalize) text innerFuel fuel cursor =
      Model.outerLoop modelCalls text innerFuel fuel cursor := by
  induction fuel generalizing cursor with
  | zero => rfl
  | succ fuel ih =>
      rw [Model.outerLoop, outerStep_meaning calls primitives normalize text valid innerFuel cursor cursorValid]
      obtain ⟨step, finished, resultValid⟩ := Model.outerStep_total text innerFuel cursor cursorValid enoughInner
      rw [finished, Model.outerLoop, finished]
      cases step with
      | reject => rfl
      | done final => rfl
      | next next => exact ih next resultValid.2

theorem imported_meaning (calls : ApplicationPackageNames.Native.Calls)
    (primitives : ApplicationPackageNames.Native.PrimitiveMeaning calls)
    (normalize : Source → Source) (normalized : ∀ text, text.length ≤ maxSourceLength → normalize text = text)
    (source : Source) (fuel : Nat) (enough : source.length + 2 ≤ fuel) :
    Model.imported (fromNames calls normalize) fuel source = Model.imported modelCalls fuel source := by
  unfold Model.imported
  by_cases invalid : source.length = 0 ∨ maxSourceLength < source.length
  · simp only [invalid, ↓reduceIte]
  · have valid : ValidText source := ⟨by omega, by omega⟩
    simp only [invalid, ↓reduceIte, fromNames, modelCalls, id_eq, normalized source valid.2]
    have initial : (⟨1, {}⟩ : Model.Cursor).Valid source := ⟨by decide, by change (1 : Nat) ≤ source.length + 1; omega, Or.inl rfl⟩
    have same := outerLoop_meaning calls primitives normalize source valid fuel fuel enough _ initial
    dsimp +instances only [fromNames, modelCalls] at same
    rw [same]

theorem imported_total (source : Source) (fuel : Nat) (enough : source.length + 2 ≤ fuel) :
    ∃ result, Model.imported modelCalls fuel source = some result := by
  unfold Model.imported
  by_cases invalid : source.length = 0 ∨ maxSourceLength < source.length
  · exact ⟨[], by simp only [invalid, ↓reduceIte]⟩
  · simp only [invalid, ↓reduceIte]
    change ∃ result, (match Model.outerLoop modelCalls source fuel fuel ⟨1, {}⟩ with
      | none => none
      | some (.error _) => some []
      | some (.ok last) => if last.candidate.first = 0 then some [] else
          some ((source.drop (last.candidate.first - 1)).take (last.candidate.after - last.candidate.first))) = some result
    have initial : (⟨1, {}⟩ : Model.Cursor).Valid source := ⟨by decide, by change (1 : Nat) ≤ source.length + 1; omega, Or.inl rfl⟩
    obtain ⟨result, finished, _⟩ := Model.outerLoop_total source fuel fuel _ initial enough (by omega)
    rw [finished]
    cases result with
    | error _ => exact ⟨[], rfl⟩
    | ok last =>
        dsimp only
        split <;> exact ⟨_, rfl⟩

def importedCalls (imports : ApplicationPackageImports.Imports)
    (output : Output.PrimitiveCalls) : Native.Calls :=
  fromNames (ApplicationPackageNames.Native.importedCalls imports functionTypeAt) output.normalize

/-- Existing source-bound lexical and package equations close every scanner
callee on its actual domain. The source length supplies finite fuel for both
loops; arbitrary initial scratch storage cannot affect the returned bytes. -/
theorem execute_imports (imports : ApplicationPackageImports.Imports)
    (outputCalls : Output.Calls) (output : Output.PrimitiveCalls)
    (sourceMeaning : Output.Expressions.PrimitiveInterpretation outputCalls output)
    (source : Source) (fuel : Nat) (enough : source.length + 2 ≤ fuel)
    (prior : ApplicationNative.Locals) :
    Native.execute (importedCalls imports output) fuel prior source = Model.imported modelCalls fuel source ∧
      ∃ result, Native.execute (importedCalls imports output) fuel prior source = some result := by
  have meaning : Native.execute (importedCalls imports output) fuel prior source = Model.imported modelCalls fuel source := by
    rw [Native.execute_model]
    exact imported_meaning _ (ApplicationPackageNames.Native.imported_primitives imports functionTypeAt)
      output.normalize sourceMeaning.normalize source fuel enough
  exact ⟨meaning, by rw [meaning]; exact imported_total source fuel enough⟩

end Silver.ApplicationPackageImport
