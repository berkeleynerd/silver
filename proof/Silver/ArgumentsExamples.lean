import Silver.Current
import Silver.ArgumentsSemantics

namespace Silver.Arguments

/-- Closed kernel-checked grammar witnesses supplement the universal proofs.
They use literal source text independently of the composition renderer. -/
def exampleSource : Source :=
  "with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode (On); Main : constant String := Silver_Arguments.First_Or_Default (\"Hello, world!\"); begin if Silver_Arguments.Input_Is_Valid then Silver_IO.Put_Line (mAIN); else Silver_Arguments.Reject; end if; end Main;".toList.map Char.toNat

theorem example_admitted : accepts exampleSource = true := by decide +kernel

theorem example_current : Current.Member exampleSource :=
  Or.inr ⟨.argument, (Compose.formAccepts_iff exampleSource .argument).mp (by decide +kernel)⟩

def swappedSource : Source :=
  "with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode (On); Message : constant String := Silver_Arguments.First_Or_Default (\"\"); begin if Silver_Arguments.Input_Is_Valid then Silver_Arguments.Reject; else Silver_IO.Put_Line (Message); end if; end Main;".toList.map Char.toNat

def negatedSource : Source :=
  "with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode (On); Message : constant String := Silver_Arguments.First_Or_Default (\"\"); begin if not Silver_Arguments.Input_Is_Valid then Silver_IO.Put_Line (Message); else Silver_Arguments.Reject; end if; end Main;".toList.map Char.toNat

def shadowedSource : Source :=
  "with Silver_IO; with Silver_Arguments; procedure Main is pragma SPARK_Mode (On); Silver_Arguments : constant String := Silver_Arguments.First_Or_Default (\"\"); begin if Silver_Arguments.Input_Is_Valid then Silver_IO.Put_Line (Silver_Arguments); else Silver_Arguments.Reject; end if; end Main;".toList.map Char.toNat

theorem swapped_rejected : accepts swappedSource = false := by decide +kernel
theorem negated_rejected : accepts negatedSource = false := by decide +kernel
theorem shadowed_rejected : accepts shadowedSource = false := by decide +kernel

def exampleProgram : Program :=
  ⟨"main".toList.map Char.toNat, "Hello, world!".toList.map Char.toNat, "main".toList.map Char.toNat⟩

def healthyEnvironment : Output.Runtime.Environment := ⟨fun _ byte => byte, 0⟩

theorem missing_uses_initialized_default :
    execute healthyEnvironment [] exampleProgram = some ⟨0, exampleProgram.defaultValue ++ [10]⟩ := by decide +kernel

theorem explicit_empty_stays_empty :
    execute healthyEnvironment [[]] exampleProgram = some ⟨0, [10]⟩ := by decide +kernel

theorem extra_arguments_reject :
    execute healthyEnvironment [[], []] exampleProgram = some ⟨1, []⟩ := by decide +kernel

/-- Changing branch fields changes execution as well as rendered tokens. -/
theorem swapped_branches_reject_missing :
    ({Main.composition with body := .conditional .inputIsValid .reject (.output .reference)} : Main.Composition).execute
      healthyEnvironment [] exampleProgram = some ⟨1, []⟩ := by decide +kernel

end Silver.Arguments
