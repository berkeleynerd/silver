module

public import Silver.Current
public import Silver.AssignmentSemantics

@[expose] public section

namespace Silver.Assignment

/-- Literal syntax and both case-insensitive references come from independent
source bytes. Universal safety and uniqueness are established separately. -/
def exampleSource : Source :=
  "with Silver_IO;procedure Main is pragma SPARK_Mode(On);M:String:=\"A\";begin m:=\"B\";Silver_IO.Put_Line(M);end Main;".toList.map Char.toNat

theorem example_admitted : accepts exampleSource = true := by decide +kernel

theorem example_current : Current.Member exampleSource :=
  Or.inr ⟨.direct, Sequence.form_reading_sound (by decide +kernel)⟩

/-- Escaped source width differs while decoded value lengths agree. -/
def escapedSource : Source :=
  "with Silver_IO;procedure Main is pragma SPARK_Mode(On);M:String:=\"\"\"\";begin m:=\"B\";Silver_IO.Put_Line(M);end Main;".toList.map Char.toNat

theorem escaped_length_admitted : accepts escapedSource = true := by decide +kernel

def unequalSource : Source :=
  "with Silver_IO;procedure Main is pragma SPARK_Mode(On);M:String:=\"A\";begin m:=\"BB\";Silver_IO.Put_Line(M);end Main;".toList.map Char.toNat

theorem unequal_source_rejected : Current.accepts unequalSource = false := by decide +kernel

def healthyEnvironment : Output.Runtime.Environment := ⟨fun _ byte => byte, 0⟩

theorem assignment_changes_output : execute healthyEnvironment ⟨[109], [65], [109], [66], [109]⟩ =
    some ⟨0, [66, 10]⟩ := by decide +kernel

theorem empty_assignment_preserved : Main.composition.evaluateEvents
    [.declaration [109], .literal [], .reference [109], .literal [], .reference [109]] = some [] := by decide +kernel

theorem unequal_length_rejected : Main.composition.evaluateEvents
    [.declaration [109], .literal [], .reference [109], .literal [65], .reference [109]] = none := by decide +kernel

theorem mismatched_target_rejected : Main.composition.evaluateEvents
    [.declaration [109], .literal [65], .reference [110], .literal [66], .reference [109]] = none := by decide +kernel

theorem mismatched_output_rejected : Main.composition.evaluateEvents
    [.declaration [109], .literal [65], .reference [109], .literal [66], .reference [110]] = none := by decide +kernel

theorem extra_event_rejected : Main.composition.evaluateEvents
    [.declaration [109], .literal [65], .reference [109], .literal [66], .reference [109], .literal []] = none := by decide +kernel

end Silver.Assignment
