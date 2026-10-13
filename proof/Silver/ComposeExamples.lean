module

public import Silver.Current

@[expose] public section

/-! Small source and boundary witnesses supplement the universal grammar and
composition theorems. No concrete example substitutes for those theorems. -/

namespace Silver.Compose

def exampleSource : Source :=
  "with Silver_IO;\nwith Silver_Arguments;\nprocedure Main is\n   pragma SPARK_Mode (On);\n   Mode : constant String := Silver_Arguments.First_Or_Default (\"brief\");\n   Result : String := \"ready\";\nbegin\n   if Silver_Arguments.Input_Is_Valid and then Mode'Length <= 4074 then\n      if Mode = \"verbose\" then\n         Result := \"extra\";\n      else\n         Result := \"ready\";\n      end if;\n      Silver_IO.Put_Line (\"Mode: \" & Mode & \" / \" & Result & \" / \" & Result);\n   else\n      Silver_Arguments.Reject;\n   end if;\nend Main;\n".toList.map Char.toNat

theorem example_form_admitted : formAccepts exampleSource .guardedResult = true := by decide +kernel

theorem example_admitted : accepts exampleSource = true :=
  (accepts_iff_member exampleSource).mpr
    ⟨.guardedResult, (formAccepts_iff exampleSource .guardedResult).mp example_form_admitted⟩

theorem example_current : Current.Member exampleSource :=
  Or.inr ⟨.guardedArgument, Sequence.form_reading_sound (by decide +kernel)⟩

def repeatedStatic : Expression := List.replicate 16 (.reference 1)

def fixedShape (length : Nat) : Bindings.Shape :=
  Bindings.put Bindings.emptyShape 1 (some ⟨.fixed length, true⟩)

theorem repeated_static_exact_bound : repeatedStatic.Bounded (fixedShape 256) 4096 := by
  unfold Expression.Bounded
  decide +kernel

theorem repeated_static_overflow_rejected : ¬repeatedStatic.Bounded (fixedShape 257) 4096 := by
  unfold Expression.Bounded
  decide +kernel

def sixteenEmptyOperands : Source := "\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"".toList.map Char.toNat

theorem operand_limit_admitted : (expressionAt sixteenEmptyOperands 1 []).after = 48 := by decide +kernel

theorem extra_operand_rejected :
    (expressionAt (sixteenEmptyOperands ++ [38, 34, 34]) 1 []).after = 0 := by decide +kernel

theorem repeated_dynamic_counted :
    (expressionAt [78, 38, 78] 1 [⟨1, 2, 0, 0, true, false⟩]).dynamicCount = 2 := by decide +kernel

theorem repeated_dynamic_fits_half_capacity :
    fits (expressionAt [78, 38, 78] 1 [⟨1, 2, 0, 0, true, false⟩]) 2048 = true := by decide +kernel

theorem repeated_dynamic_overflow_rejected :
    fits (expressionAt [78, 38, 78] 1 [⟨1, 2, 0, 0, true, false⟩]) 2049 = false := by decide +kernel

def narrowDefault : Program :=
  ⟨[argumentDeclaration], [⟨1, 2, 0, 0, true, false⟩], [65], .argument (some 0) [.reference 1]⟩

theorem tighter_capacity_rejects_oversized_default : narrowDefault.action [] = .reject := by decide +kernel

theorem explicit_empty_satisfies_zero_capacity : narrowDefault.action [[]] = .output [] := by decide +kernel

def copyAssignmentSource (secondInitializer replacement output : String) : Source :=
  ("with Silver_IO; procedure Main is pragma SPARK_Mode (On); " ++
   "First : constant String := \"ab\"; Second : constant String := " ++ secondInitializer ++
   "; Result : String := fIrSt; begin Result := " ++ replacement ++
   "; Silver_IO.Put_Line (" ++ output ++ "); end Main;").toList.map Char.toNat

theorem two_constants_copy_admitted :
    formAccepts (copyAssignmentSource "\"cd\"" "sEcOnD" "First & Result & Second") .assignment = true := by
  decide +kernel

theorem unequal_named_copy_rejected :
    accepts (copyAssignmentSource "\"cde\"" "Second" "Result") = false := by decide +kernel

theorem unused_assignment_target_admitted :
    accepts (copyAssignmentSource "\"cd\"" "Second" "First & Second") = true := by decide +kernel

theorem constant_alias_initializer_admitted :
    accepts (copyAssignmentSource "First" "Second" "Result") = true := by decide +kernel

theorem mutable_copy_source_admitted :
    accepts (copyAssignmentSource "\"cd\"" "Result" "Result") = true := by decide +kernel

def copiedBranchSource : Source :=
  "with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode (On); Mode : constant String := Silver_Arguments.First_Or_Default (\"brief\"); Ready : constant String := \"ready\"; Detailed : constant String := \"extra\"; Result : String := Ready; begin if Silver_Arguments.Input_Is_Valid and then Mode'Length <= 4081 then if Mode = \"verbose\" then Result := Detailed; else Result := Ready; end if; Silver_IO.Put_Line (Ready & Result & Detailed & Mode); else Silver_Arguments.Reject; end if; end Main;".toList.map Char.toNat

theorem two_constants_guarded_branch_admitted :
    formAccepts copiedBranchSource .guardedResult = true := by decide +kernel


def snapshotSource : Source :=
  "with Silver_IO; procedure Main is pragma SPARK_Mode (On); A : String := \"ab\"; B : constant String := A; C : String := B; begin A := \"cd\"; Silver_IO.Put_Line (A & B & C); end Main;".toList.map Char.toNat

theorem ordered_snapshots_admitted : formAccepts snapshotSource .assignment = true := by decide +kernel

def snapshotProgram : Program :=
  ⟨[⟨1, true, [.literal [97, 98]]⟩, ⟨2, false, [.reference 1]⟩, ⟨3, true, [.reference 2]⟩],
    [⟨0, 0, 0, 2, false, true⟩, ⟨0, 0, 0, 2, false, false⟩, ⟨0, 0, 0, 2, false, true⟩], [],
    .assignment ⟨1, [.literal [99, 100]]⟩ [.reference 1, .reference 2, .reference 3]⟩

theorem snapshots_keep_initial_values : snapshotProgram.action [] = .output [99, 100, 97, 98, 97, 98] := by
  decide +kernel

theorem concatenated_initializer_assignment_and_output_admitted :
    accepts (copyAssignmentSource "(First & (\"\"))" "(\"\" & Second)" "((First) & Result)") = true := by
  decide +kernel

def groupedLiteral : Source := "(\"a\" & (\"b\" & \"c\"))".toList.map Char.toNat

theorem grouped_literal_summary :
    (expressionAt groupedLiteral 1 []).staticLength = 3 ∧
      (expressionAt groupedLiteral 1 []).dynamicCount = 0 := by decide +kernel

theorem unfinished_parenthesis_rejected :
    (expressionAt ("(\"a\" & \"b\"".toList.map Char.toNat) 1 []).after = 0 := by decide +kernel

theorem missing_operand_rejected :
    (expressionAt ("(\"a\" & )".toList.map Char.toNat) 1 []).after = 0 := by decide +kernel

end Silver.Compose
