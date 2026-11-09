module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def procedureBindingsSpec : String := include_str "../../src/silver_procedure_bindings.ads"

end Silver.Source
