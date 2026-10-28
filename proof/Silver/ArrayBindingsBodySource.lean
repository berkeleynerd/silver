module

@[expose] public section

/-! Handwritten authoritative source binding; generated certificates cannot redefine it. -/
namespace Silver.Source

def arrayBindingsBody : String := include_str "../../src/silver_array_bindings.adb"

end Silver.Source
