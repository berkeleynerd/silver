module

public import Silver.ApplicationPackageObjectCursors

@[expose] public section

namespace Silver.ApplicationPackageObjectRows
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageDeclarations

private def EndsAfter (text : Source) (minimum : Nat) (out : ObjectResult) : Prop :=
  out.frame.position ≠ 0 → minimum < out.frame.position ∧ out.frame.position ≤ text.length + 1

private theorem invalid_end (text : Source) (minimum : Nat) : EndsAfter text minimum invalidObject :=
  fun present => False.elim (present rfl)

private theorem finish_end (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (minimum : Nat) (seed : ObjectResult) (prior : minimum ≤ seed.initAfter) :
    EndsAfter text minimum (finishObject (modelObjectCalls reader) text original seed) := by
  dsimp only [finishObject]
  split
  · exact invalid_end _ _
  · intro present
    change fixedAfter text seed.initAfter ";" false ≠ 0 at present
    have step := fixed_window (by decide) present
    exact ⟨Nat.lt_of_le_of_lt prior step.1, step.2⟩

private theorem scalar_end (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (seed : ObjectResult) (constraint : ScalarConstraintResult)
    (start : last < seed.initFirst ∧ seed.initFirst ≤ text.length + 1) :
    EndsAfter text last (objectScalar (modelObjectCalls reader) text original first last constantEnd localObject seed constraint) := by
  dsimp only [objectScalar]
  split
  · exact invalid_end _ _
  · rename_i guard
    have value : ((modelObjectCalls reader).scalar text seed.initFirst seed.frame.scalarNames first last).after ≠ 0 :=
      fun missing => guard (by simp [missing])
    have window := ScalarExpression.read_arrays_bounds start.2 value
    apply finish_end
    exact Nat.le_of_lt (Nat.lt_trans start.1 window.1)

private theorem boolean_end (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (seed : ObjectResult)
    (start : last < seed.initFirst) :
    EndsAfter text last (objectBoolean (modelObjectCalls reader) text original first last constantEnd localObject seed) := by
  dsimp only [objectBoolean]
  split
  · exact invalid_end _ _
  · rename_i guard
    have value : ((modelObjectCalls reader).booleanInitializer text seed.frame seed.initFirst first last) ≠ 0 :=
      fun missing => guard (by simp [missing])
    have advanced := Predicate.Native.condition_progress text _ _ _ value
    have accepted (result : ObjectResult) : EndsAfter text last
        (objectBooleanFinish (modelObjectCalls reader) text original first last constantEnd
          (booleanInitializerAfter text seed.frame seed.initFirst first last) localObject result) :=
      finish_end reader text original last _ (Nat.le_of_lt (Nat.lt_trans start advanced))
    split
    · split
      · exact invalid_end _ _
      · exact accepted _
    · exact accepted _

private theorem initialized_end (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (seed : ObjectResult) (constraint : ScalarConstraintResult)
    (prior : constraint.after ≠ 0 → last ≤ constraint.after) :
    EndsAfter text last
      (objectInitialized (modelObjectCalls reader) text original first last constantEnd localObject seed constraint) := by
  dsimp only [objectInitialized]
  split
  · exact invalid_end _ _
  · rename_i started
    change ¬ decide (skipAt text (fixedAfter text constraint.after ":=" false) = 0) = true at started
    have positive : skipAt text (fixedAfter text constraint.after ":=" false) ≠ 0 :=
      fun zero => started (by simpa only [decide_eq_true_eq] using zero)
    have next := initializer_start prior positive
    split
    · apply scalar_end
      exact next
    · apply boolean_end
      exact next.1

private theorem typed_end (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (info : PackageBindings.Metadata) (first last colonEnd constantEnd : Nat) (localObject : Bool) (seed : ObjectResult)
    (prior : let position := if decide (constantEnd = 0) then colonEnd else constantEnd
      last ≤ position ∧ position ≤ text.length + 1) :
    EndsAfter text last (objectTyped (modelObjectCalls reader) text original info first last colonEnd constantEnd localObject seed) := by
  let position := if decide (constantEnd = 0) then colonEnd else constantEnd
  let mark := packageTypeAt text seed.frame info position
  let marked := {seed with mark, constantObject := decide (constantEnd ≠ 0)}
  change EndsAfter text last (if decide (seed.frame.position = 0) then invalidObject
    else if decide (mark.after = 0) then invalidObject
    else if decide (mark.kind = .integer) then
      objectInitialized _ text original first last constantEnd localObject marked
        (scalarConstraintAt text mark.after seed.frame.scalarNames mark.bounds)
    else objectInitialized _ text original first last constantEnd localObject marked ⟨mark.after, mark.bounds⟩)
  by_cases missing : seed.frame.position = 0
  · rw [ite_eq_left (by simpa only [decide_eq_true_eq] using missing)]
    exact invalid_end _ _
  · rw [ite_eq_right (by simpa only [decide_eq_true_eq] using missing)]
    by_cases absent : mark.after = 0
    · rw [ite_eq_left (by simpa only [decide_eq_true_eq] using absent)]
      exact invalid_end _ _
    · rw [ite_eq_right (by simpa only [decide_eq_true_eq] using absent)]
      have typed := type_window prior.2 absent
      have later : last ≤ mark.after := Nat.le_trans prior.1 (Nat.le_of_lt typed.1)
      split
      · apply initialized_end
        intro consumed
        exact Nat.le_trans later (constraint_window typed.2 consumed).1
      · apply initialized_end
        exact fun _ => later

private theorem chosen_type_position {text : Source} {last : Nat}
    (colon : fixedAfter text last ":" false ≠ 0) :
    let colonEnd := fixedAfter text last ":" false
    let constantEnd := fixedAfter text colonEnd "constant" true
    let position := if decide (constantEnd = 0) then colonEnd else constantEnd
    last ≤ position ∧ position ≤ text.length + 1 := by
  have colonWindow := fixed_window (by decide) colon
  dsimp only
  split
  · exact ⟨Nat.le_of_lt colonWindow.1, colonWindow.2⟩
  · rename_i present
    have ok : fixedAfter text (fixedAfter text last ":" false) "constant" true ≠ 0 :=
      fun zero => present (by simp only [zero, decide_true])
    have wordWindow := fixed_window (by decide) ok
    exact ⟨Nat.le_of_lt (Nat.lt_trans colonWindow.1 wordWindow.1), wordWindow.2⟩

private theorem objectStep_extent (reader : BooleanElaboration.Native.Reader) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool) :
    EndsAfter text (objectName text frame).after (objectStep (modelObjectCalls reader) text frame info localObject) := by
  dsimp only [objectStep, objectNameStep]
  split
  · exact invalid_end _ _
  · rename_i present
    have colon : (modelObjectCalls reader).take text (objectName text frame).after (.symbol ":") ≠ 0 := by
      intro missing
      apply present
      change (_ || decide ((modelObjectCalls reader).take text (objectName text frame).after (.symbol ":") = 0)) = true
      simp [missing]
    have prior := chosen_type_position colon
    cases localObject with
    | true => exact typed_end reader text frame info _ _ _ _ true _ prior
    | false =>
      split
      · contradiction
      · split
        · exact typed_end reader text frame info _ _ _ _ false _ prior
        · exact invalid_end _ _

theorem objectStep_positions (reader : BooleanElaboration.Native.Reader) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool)
    (accepted : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    let out := objectStep (modelObjectCalls reader) text frame info localObject
    frame.position ≤ out.name.first ∧ out.name.first < out.name.after ∧
      out.name.after < out.frame.position ∧ out.frame.position ≤ text.length + 1 := by
  obtain ⟨valid, rows⟩ := objectStep_rows reader text frame info localObject accepted
  have ended := objectStep_extent reader text frame info localObject accepted
  simp only [PackageBindings.validName, metadataText, Bool.and_eq_true, decide_eq_true_eq] at valid
  have between := valid.1.2.2.2
  have inputBound : frame.position ≤ text.length + 1 := by
    by_cases active : frame.position ≤ text.length + 1
    · exact active
    · have positive : frame.position ≠ 0 := by omega
      have empty : Cursor.remaining text frame.position = [] := List.drop_eq_nil_of_le (by omega)
      have final : (objectName text frame).first = text.length + 1 := by
        simp [objectName, skipAt, positive, Cursor.triviaPosition, empty, Cursor.endPosition, triviaEnd]
      omega
  dsimp only
  rw [rows.nameEq]
  exact ⟨skipAt_advances text frame.position inputBound (Nat.ne_of_gt between.1), between.2.1, ended⟩

end Silver.ApplicationPackageObjectRows
