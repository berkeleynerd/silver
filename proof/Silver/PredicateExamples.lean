module

public import Silver.Current

@[expose] public section

/-! Small kernel-computed source witnesses exercise the integrated facade.
Universal source/semantic theorems establish assurance; these examples do not
stand in for those proofs. -/
namespace Silver.Predicate

def exampleBytes (text : String) : Source := text.toList.map Char.toNat

def lengthBranchSource : Source := exampleBytes
  "with Silver_IO; procedure Main is pragma SPARK_Mode(On); A:String:=\"\"; begin if A'Length=0 then A:=\"\"; end if; Silver_IO.Put_Line(A); end Main;"

theorem length_branch_admitted : Current.accepts lengthBranchSource = true := by decide +kernel

def invalidAssignmentSource : Source := exampleBytes
  "with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode(On); Input:constant String:=Silver_Arguments.First_Or_Default(\"\"); Work:String:=\"\"; begin if not Silver_Arguments.Input_Is_Valid then Work:=Input&Input; Silver_Arguments.Reject; else null; end if; end Main;"

theorem invalid_input_has_zero_length : Current.accepts invalidAssignmentSource = true := by decide +kernel

def invalidOutputSource : Source := exampleBytes
  "with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode(On); Input:constant String:=Silver_Arguments.First_Or_Default(\"\"); begin if not Silver_Arguments.Input_Is_Valid then Silver_Arguments.Reject; end if; Silver_IO.Put_Line(Input); end Main;"

theorem returning_reject_does_not_grant_validity : Current.accepts invalidOutputSource = false := by decide +kernel

theorem length_branch_has_one_meaning :
    ∃ program, Current.SourceMeaning lengthBranchSource program ∧
      ∀ other, Current.SourceMeaning lengthBranchSource other → other = program := by
  obtain ⟨program, meaning⟩ := Current.member_has_meaning ((Current.accepts_iff_member _).mp length_branch_admitted)
  exact ⟨program, meaning, fun _ other => Current.meaning_unique other meaning⟩

end Silver.Predicate
