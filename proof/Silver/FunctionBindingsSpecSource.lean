module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def functionBindingsSpec : String := include_str "../../src/silver_function_bindings.ads"

end Silver.Source
