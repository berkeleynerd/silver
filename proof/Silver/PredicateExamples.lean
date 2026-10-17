module

public import Silver.Current

-- Kernel-computed Image witnesses need the standard library digit definitions.
import all Init.Data.Repr

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


/-! Integer/loop witnesses added for review L15 (#64). The first three
literals retain the exact checked-in sample bytes. These inhabited examples
corroborate admission; the imported universal theorems supply assurance. -/

def triangleSource : Source := exampleBytes
  "with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\nbegin\n   for I in 1 .. 5 loop\n      for J in 1 .. I loop\n         Silver_IO.Put (\"*\");\n      end loop;\n      Silver_IO.Put_Line (\"\");\n   end loop;\nend Main;\n"

theorem triangle_admitted : Current.accepts triangleSource = true := by decide +kernel

def computedStepSource : Source := exampleBytes
  "with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\n   Step : constant Integer := 2;\nbegin\n   for I in 1 .. 5 loop\n      Silver_IO.Put_Line (Integer'Image ((I * Step)));\n   end loop;\nend Main;\n"

theorem computedStep_admitted : Current.accepts computedStepSource = true := by decide +kernel

def countdownSource : Source := exampleBytes
  "with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\nbegin\n   for I in reverse 0 .. 10 loop\n      Silver_IO.Put_Line (Integer'Image (I));\n   end loop;\nend Main;\n"

theorem countdown_admitted : Current.accepts countdownSource = true := by decide +kernel

def reverseNullLoopSource : Source := exampleBytes
  "with Silver_IO; procedure Main is pragma SPARK_Mode(On); begin for I in reverse 5..1 loop null;end loop;end Main;"

theorem reverseNullLoop_admitted :
    Current.accepts reverseNullLoopSource = true := by decide +kernel

def uncertainNestedAssignmentSource : Source := exampleBytes
  "with Silver_IO; procedure Main is pragma SPARK_Mode(On); S:String:=\" 0\";begin for I in 0..2 loop for J in 1..I loop S:=Integer'Image(J);end loop;end loop;Silver_IO.Put_Line(S);end Main;"

theorem uncertainNestedAssignment_admitted :
    Current.accepts uncertainNestedAssignmentSource = true := by decide +kernel

def hiddenOwnBoundSource : Source := exampleBytes
  "with Silver_IO; procedure Main is pragma SPARK_Mode(On); begin for I in 1..3 loop for I in 1..I loop null;end loop;end loop;end Main;"

theorem hiddenOwnBound_rejected :
    Current.accepts hiddenOwnBoundSource = false := by decide +kernel

def expiredIndexSource : Source := exampleBytes
  "with Silver_IO; procedure Main is pragma SPARK_Mode(On); begin for I in 1..3 loop null;end loop;Silver_IO.Put_Line(Integer'Image(I));end Main;"

theorem expiredIndex_rejected :
    Current.accepts expiredIndexSource = false := by decide +kernel

def integerHomonymSource : Source := exampleBytes
  "with Silver_IO; procedure Main is pragma SPARK_Mode(On); Integer:constant String:=Integer'Image(1);begin null;end Main;"

theorem integerHomonym_rejected :
    Current.accepts integerHomonymSource = false := by decide +kernel

theorem countdown_automatic_discharge : Current.automaticDischarge countdownSource = some true :=
  (Current.admitted_assurance ((Current.accepts_iff_member _).mp countdown_admitted)).1

end Silver.Predicate
