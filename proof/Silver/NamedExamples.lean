module

public import Silver.Current
public import Silver.NamedSemantics

@[expose] public section

namespace Silver.Named

/-- Closed grammar checks exercise case-insensitive binding and the permitted
local name Main; universal claims are proved by the other Named modules. -/
def exampleSource : Source :=
  "with Silver_IO; procedure Main is pragma SPARK_Mode (On); Main : constant String := \"Hello, world!\"; begin Silver_IO.Put_Line (mAIN); end Main;".toList.map Char.toNat

theorem example_admitted : accepts exampleSource = true := by decide +kernel

theorem example_current : Current.Member exampleSource :=
  Or.inr ⟨.static, (Compose.formAccepts_iff exampleSource .static).mp (by decide +kernel)⟩

def mismatchedSource : Source :=
  "with Silver_IO; procedure Main is pragma SPARK_Mode (On); Name : constant String := \"\"; begin Silver_IO.Put_Line (Other); end Main;".toList.map Char.toNat

theorem mismatched_rejected : accepts mismatchedSource = false := by decide +kernel

end Silver.Named
