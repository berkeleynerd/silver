import Silver.Current

namespace Silver.Branching

/-- Independent source bytes exercise the admitted grammar and mixed-case
binding. The universal interpretation and uniqueness proofs do not depend on
this witness or on any particular literal text. -/
def exampleSource : Source :=
  "with Silver_IO;with Silver_Arguments;procedure Main is pragma SPARK_Mode(On);M:constant String:=Silver_Arguments.First_Or_Default(\"A\");begin if Silver_Arguments.Input_Is_Valid then if m=\"B\" then Silver_IO.Put_Line(\"yes\");else Silver_IO.Put_Line(\"no\");end if;else Silver_Arguments.Reject;end if;end Main;".toList.map Char.toNat

theorem example_admitted : accepts exampleSource = true := by decide +kernel

theorem example_current : Current.Member exampleSource :=
  Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr
    ((accepts_iff_member exampleSource).mp example_admitted)))))))

def exampleProgram : Program :=
  ⟨[109], [65], [109], [66], [121, 101, 115], [110, 111]⟩

def healthyEnvironment : Output.Runtime.Environment := ⟨fun _ byte => byte, 0⟩

theorem missing_selects_default_branch : execute healthyEnvironment [] exampleProgram =
    some ⟨0, [110, 111, 10]⟩ := by decide +kernel

theorem matching_input_selects_yes : execute healthyEnvironment [[66]] exampleProgram =
    some ⟨0, [121, 101, 115, 10]⟩ := by decide +kernel

theorem comparison_preserves_case : execute healthyEnvironment [[98]] exampleProgram =
    some ⟨0, [110, 111, 10]⟩ := by decide +kernel

theorem unequal_lengths_select_no : execute healthyEnvironment [[66, 66]] exampleProgram =
    some ⟨0, [110, 111, 10]⟩ := by decide +kernel

theorem explicit_empty_compares_empty :
    execute healthyEnvironment [[]] {exampleProgram with comparison := []} =
      some ⟨0, [121, 101, 115, 10]⟩ := by decide +kernel

theorem invalid_input_never_uses_empty_fallback :
    execute healthyEnvironment [[0]] {exampleProgram with comparison := []} =
      some ⟨1, []⟩ := by decide +kernel

theorem extra_arguments_reject : execute healthyEnvironment [[66], []] exampleProgram =
    some ⟨1, []⟩ := by decide +kernel

/-- The two literal-output source occurrences remain ordered events; exchanging
their values changes the selected branch's output. -/
theorem swapped_literal_payloads_change_output :
    Main.composition.execute healthyEnvironment [[66]]
      [.declaration [109], .literal [65], .reference [109], .literal [66], .literal [88], .literal [89]] =
        some ⟨0, [88, 10]⟩ ∧
    Main.composition.execute healthyEnvironment [[66]]
      [.declaration [109], .literal [65], .reference [109], .literal [66], .literal [89], .literal [88]] =
        some ⟨0, [89, 10]⟩ := by decide +kernel

theorem mismatched_reference_fails :
    execute healthyEnvironment [[66]] {exampleProgram with reference := [110]} = none := by decide +kernel

theorem extra_event_rejected :
    Main.composition.instantiate (exampleProgram.events ++ [.literal []]) = none := by decide +kernel

theorem missing_event_rejected :
    Main.composition.instantiate exampleProgram.events.dropLast = none := by decide +kernel

end Silver.Branching
