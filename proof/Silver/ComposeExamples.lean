import Silver.Current

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
  Or.inr ((accepts_iff_member exampleSource).mp example_admitted)

def repeatedStatic : Expression := List.replicate 16 .staticReference

theorem repeated_static_exact_bound : repeatedStatic.Bounded 256 4096 := by
  unfold Expression.Bounded
  decide +kernel

theorem repeated_static_overflow_rejected : ¬repeatedStatic.Bounded 257 4096 := by
  unfold Expression.Bounded
  decide +kernel

def sixteenEmptyOperands : Source := "\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"&\"\"".toList.map Char.toNat

theorem operand_limit_admitted : (expressionAt sixteenEmptyOperands 1 {}).after = 48 := by decide +kernel

theorem extra_operand_rejected :
    (expressionAt (sixteenEmptyOperands ++ [38, 34, 34]) 1 {}).after = 0 := by decide +kernel

theorem repeated_dynamic_rejected :
    (expressionAt [78, 38, 78] 1 {dynamicFirst := 1, dynamicAfter := 2}).after = 0 := by decide +kernel

def narrowDefault : Program := .argument [65] (some 0) [.dynamicReference]

theorem tighter_capacity_rejects_oversized_default : narrowDefault.action [] = .reject := by decide +kernel

theorem explicit_empty_satisfies_zero_capacity : narrowDefault.action [[]] = .output [] := by decide +kernel

end Silver.Compose
