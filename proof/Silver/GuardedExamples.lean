module

public import Silver.GuardedMain
public import Silver.GuardedObligations

@[expose] public section

namespace Silver.Guarded

/-- A small literal source witness, independent of the syntax renderer. -/
def exampleSource : Source :=
  "with Silver_IO;with Silver_Arguments;procedure Main is pragma SPARK_Mode(On);N:constant String:=Silver_Arguments.First_Or_Default(\"\");begin if Silver_Arguments.Input_Is_Valid and then N'Length<=4096 then Silver_IO.Put_Line(\"\"&N&\"\");else Silver_Arguments.Reject;end if;end Main;".toList.map Char.toNat

theorem example_admitted : accepts exampleSource = true := by decide +kernel

theorem noncanonical_decimal_rejected :
    (decimalAt ("04096".toList.map Char.toNat) 1).after = 0 := by decide +kernel

def exampleProgram : Program :=
  ⟨"name".toList.map Char.toNat, "world".toList.map Char.toNat,
   "name".toList.map Char.toNat, 4088, "Hello, ".toList.map Char.toNat,
   "name".toList.map Char.toNat, "!".toList.map Char.toNat⟩

def healthyEnvironment : Output.Runtime.Environment := ⟨fun _ byte => byte, 0⟩

theorem missing_prints_default : execute healthyEnvironment [] exampleProgram =
    some ⟨0, "Hello, world!\n".toList.map Char.toNat⟩ := by decide +kernel

theorem argument_is_decorated : execute healthyEnvironment ["Ada".toList.map Char.toNat] exampleProgram =
    some ⟨0, "Hello, Ada!\n".toList.map Char.toNat⟩ := by decide +kernel

theorem empty_argument_keeps_decorations : execute healthyEnvironment [[]] exampleProgram =
    some ⟨0, "Hello, !\n".toList.map Char.toNat⟩ := by decide +kernel

theorem extra_arguments_reject : execute healthyEnvironment [[], []] exampleProgram =
    some ⟨1, []⟩ := by decide +kernel

/-- Event order, including all three literal payloads, is observable. -/
theorem swapped_literal_payloads_change_output :
    Main.composition.execute healthyEnvironment []
      [.declaration [110], .literal [65] false, .reference [110], .capacity 4094,
       .literal [66] true, .reference [110], .literal [67] true] = some ⟨0, [66, 65, 67, 10]⟩ ∧
    Main.composition.execute healthyEnvironment []
      [.declaration [110], .literal [66] false, .reference [110], .capacity 4094,
       .literal [65] true, .reference [110], .literal [67] true] = some ⟨0, [65, 66, 67, 10]⟩ := by decide +kernel

theorem extra_event_rejected :
    Main.composition.instantiate (exampleProgram.events ++ [.capacity 0]) = none := by decide +kernel

theorem range_checker_rejects_excess :
    (RangeObligation.mk 32767 1).discharge = false := by decide +kernel

end Silver.Guarded
