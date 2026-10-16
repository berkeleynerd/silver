module

@[expose] public section

/-! Handwritten authoritative source binding; generated certificates cannot redefine it. -/
namespace Silver.Source

def scalarExpressionBody : String := include_str "../../src/silver_scalar_expressions.adb"

end Silver.Source
