module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def procedureBindingsBody : String := include_str "../../src/silver_procedure_bindings.adb"

end Silver.Source
