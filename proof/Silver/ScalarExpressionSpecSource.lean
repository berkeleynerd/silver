module

@[expose] public section

/-! Handwritten authoritative source binding; generated certificates cannot redefine it. -/
namespace Silver.Source

def scalarExpressionSpec : String := include_str "../../src/silver_scalar_expressions.ads"

end Silver.Source
