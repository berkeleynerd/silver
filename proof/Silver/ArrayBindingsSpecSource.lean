module

@[expose] public section

/-! Handwritten authoritative source binding; generated certificates cannot redefine it. -/
namespace Silver.Source

def arrayBindingsSpec : String := include_str "../../src/silver_array_bindings.ads"

end Silver.Source
