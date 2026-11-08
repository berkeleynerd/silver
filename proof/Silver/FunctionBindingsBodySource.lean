module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def functionBindingsBody : String := include_str "../../src/silver_function_bindings.adb"

end Silver.Source
