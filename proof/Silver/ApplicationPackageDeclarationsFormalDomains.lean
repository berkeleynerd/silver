module

public import Silver.ApplicationPackageDeclarationsSignatureDomains

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

/-- Appending a declared formal preserves the whole reader frame, including
capacity rejection. The accepted type and original name supply the only new
range/name facts; incoming metadata and unrelated bindings remain arbitrary. -/
theorem ReaderFrame.append_formal {text : Source} {frame : ParserState}
    (prior : ReaderFrame text frame) (name : PackageBindings.NameSpan)
    (span : ValidName text name.first name.after) (mark : PackageTypeResult)
    (bounded : mark.bounds.Bounded) (ordered : mark.bounds.lower ≤ mark.bounds.upper)
    (mode : ProcedureBindings.Mode) :
    ReaderFrame text (appendFormal frame name mark mode) := by
  have nonempty : mark.bounds.isEmpty = false := by
    simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not]
    omega
  have nameValid : nameStateValid text name.first name.after = true := by
    simp only [nameStateValid, decide_eq_true_eq]
    exact Or.inr span
  unfold appendFormal
  split
  · rename_i selected
    let entry : ScalarExpression.Binding :=
      ⟨name.first,name.after,mark.bounds,false,mark.bounds,decide (mode ≠ .input),0,0⟩
    change ReaderFrame text {frame with scalarNames := frame.scalarNames ++ [entry]}
    constructor
    · refine ⟨prior.typed.context, prior.typed.capacity, prior.typed.namesCount, prior.typed.names,
        ?_, ?_, prior.typed.subtypeCount, prior.typed.subtypes, prior.typed.booleanCount,
        prior.typed.firstParameter, prior.typed.firstProcedureParameter⟩
      · simp only [List.length_append, List.length_singleton]; omega
      · intro item member
        simp only [List.mem_append, List.mem_singleton] at member
        rcases member with old | rfl
        · exact prior.typed.scalars item old
        · exact ⟨bounded,bounded⟩
    · have names : scalarNamesValid text (frame.scalarNames ++ [entry]) = scalarNamesValid text frame.scalarNames := by
        simp only [scalarNamesValid, List.all_append, List.all_cons, List.all_nil, entry, nameValid]
        simp [nameStateValid, span.1]
      have mutable : mutableBoundsValid (frame.scalarNames ++ [entry]) = mutableBoundsValid frame.scalarNames := by
        simp [mutableBoundsValid, entry, nonempty]
      have values : declarationValuesValid (frame.scalarNames ++ [entry]) (frame.scalarNames ++ [entry]).length =
          declarationValuesValid frame.scalarNames frame.scalarNames.length := by
        simp only [declarationValuesValid, Nat.le_refl, decide_true, Bool.true_and, List.take_length,
          List.all_append, List.all_cons, List.all_nil, entry, nonempty, Bool.not_false, Bool.and_true]
      simpa only [stateValid, names, mutable, values] using prior.valid
  · split
    · rename_i selected
      let entry : BooleanBindings.Binding := ⟨name.first,name.after,decide (mode ≠ .input),0,0,false,false⟩
      change ReaderFrame text {frame with booleanNames := frame.booleanNames ++ [entry]}
      constructor
      · refine ⟨prior.typed.context, prior.typed.capacity, prior.typed.namesCount, prior.typed.names,
          prior.typed.scalarCount, prior.typed.scalars, prior.typed.subtypeCount, prior.typed.subtypes,
          ?_, prior.typed.firstParameter, prior.typed.firstProcedureParameter⟩
        simp only [List.length_append, List.length_singleton]; omega
      · have names : booleanNamesValid text (frame.booleanNames ++ [entry]) = booleanNamesValid text frame.booleanNames := by
          simp only [booleanNamesValid, List.all_append, List.all_cons, List.all_nil, entry, nameValid]
          simp [nameStateValid, span.1]
        simpa only [stateValid, names] using prior.valid
    · exact prior.at_position (Nat.zero_le _)

end Silver.ApplicationPackageDeclarations
