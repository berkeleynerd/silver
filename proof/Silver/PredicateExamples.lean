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

def namedOutputSource : Source := exampleBytes
  "with Silver_IO; use Silver_IO; procedure Main is pragma SPARK_Mode(On); begin Put_Line(Item=>\"\"); end Main;"

theorem named_unqualified_output_admitted : Current.accepts namedOutputSource = true := by decide +kernel

def hiddenOutputSource : Source := exampleBytes
  "with Silver_IO; use Silver_IO; procedure Main is pragma SPARK_Mode(On); Put_Line:String:=\"\"; begin Put_Line(\"\"); end Main;"

theorem hidden_unqualified_output_rejected : Current.accepts hiddenOutputSource = false := by decide +kernel

def qualifiedHiddenOutputSource : Source := exampleBytes
  "with Silver_IO; use Silver_IO; procedure Main is pragma SPARK_Mode(On); Put_Line:String:=\"\"; begin Silver_IO.Put_Line(Item=>\"\"); end Main;"

theorem qualified_hidden_output_admitted : Current.accepts qualifiedHiddenOutputSource = true := by decide +kernel

def partialOutputSource : Source := exampleBytes
  "with Silver_IO; use Silver_IO; procedure Main is pragma SPARK_Mode(On); begin Put(Item=>\"Release: \"); Silver_IO.Put_Line(\"production\"); end Main;"

theorem mixed_partial_output_admitted : Current.accepts partialOutputSource = true := by decide +kernel

def hiddenPartialOutputSource : Source := exampleBytes
  "with Silver_IO; use Silver_IO; procedure Main is pragma SPARK_Mode(On); Put:String:=\"\"; begin Put(Item=>\"\"); end Main;"

theorem hidden_partial_output_rejected : Current.accepts hiddenPartialOutputSource = false := by decide +kernel

def qualifiedHiddenPartialOutputSource : Source := exampleBytes
  "with Silver_IO; use Silver_IO; procedure Main is pragma SPARK_Mode(On); Put:String:=\"\"; begin Silver_IO.Put(Item=>Put); end Main;"

theorem qualified_hidden_partial_output_admitted : Current.accepts qualifiedHiddenPartialOutputSource = true := by decide +kernel

end Silver.Predicate
