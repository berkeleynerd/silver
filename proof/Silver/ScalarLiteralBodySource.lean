module

@[expose] public section

/-! Handwritten authoritative source binding; generated certificates cannot redefine it. -/
namespace Silver.Source

def scalarLiteralBody : String := include_str "../../src/silver_scalar_literals.adb"

end Silver.Source
