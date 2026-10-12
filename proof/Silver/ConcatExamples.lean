module

public import Silver.Current
public import Silver.ConcatSemantics

@[expose] public section

namespace Silver.Concat

/-- A concrete source witness is independent of the syntax renderer. -/
def exampleSource : Source :=
  "with Silver_IO; procedure Main is pragma SPARK_Mode (On); Name : constant String := \"world\"; begin Silver_IO.Put_Line (\"Hello, \" & nAME & \"!\"); end Main;".toList.map Char.toNat

theorem example_admitted : accepts exampleSource = true := by decide +kernel

theorem example_current : Current.Member exampleSource :=
  Or.inr ⟨.static, (Compose.formAccepts_iff exampleSource .static).mp (by decide +kernel)⟩

def repeatedReference : Source :=
  "with Silver_IO; procedure Main is pragma SPARK_Mode (On); Name : constant String := \"world\"; begin Silver_IO.Put_Line (Name & Name & \"!\"); end Main;".toList.map Char.toNat

def wrongReference : Source :=
  "with Silver_IO; procedure Main is pragma SPARK_Mode (On); Name : constant String := \"world\"; begin Silver_IO.Put_Line (\"Hello, \" & Other & \"!\"); end Main;".toList.map Char.toNat

def shadowedName : Source :=
  "with Silver_IO; procedure Main is pragma SPARK_Mode (On); Silver_IO : constant String := \"world\"; begin Silver_IO.Put_Line (\"Hello, \" & Silver_IO & \"!\"); end Main;".toList.map Char.toNat

theorem repeated_reference_admitted : Current.accepts repeatedReference = true := by decide +kernel
theorem wrong_reference_rejected : Current.accepts wrongReference = false := by decide +kernel
theorem shadowed_name_rejected : Current.accepts shadowedName = false := by decide +kernel

def exampleProgram : Program :=
  ⟨"name".toList.map Char.toNat, "world".toList.map Char.toNat,
   "Hello, ".toList.map Char.toNat, "name".toList.map Char.toNat, "!".toList.map Char.toNat⟩

def healthyEnvironment : Output.Runtime.Environment := ⟨fun _ byte => byte, 0⟩

theorem greeting_exact : execute healthyEnvironment exampleProgram =
    some ⟨0, "Hello, world!\n".toList.map Char.toNat⟩ := by decide +kernel

/-- The literal values come from the source events in order. Reordering them
changes the bytes even though all literal slots share one token constructor. -/
theorem reordered_literal_events_change_bytes :
    Main.composition.evaluateEvents
      [.declaration [110], .literal [65], .literal [66], .reference [110], .literal [67]] = some [66, 65, 67] ∧
    Main.composition.evaluateEvents
      [.declaration [110], .literal [66], .literal [65], .reference [110], .literal [67]] = some [65, 66, 67] := by decide +kernel

theorem extra_event_rejected : Main.composition.evaluateEvents
    (exampleProgram.events ++ [.literal []]) = none := by decide +kernel

theorem empty_components_preserved :
    Main.composition.evaluateEvents
      [.declaration [110], .literal [], .literal [], .reference [110], .literal []] = some [] := by decide +kernel

theorem mismatched_event_reference_rejected :
    Main.composition.evaluateEvents
      [.declaration [110], .literal [], .literal [], .reference [109], .literal []] = none := by decide +kernel

end Silver.Concat
