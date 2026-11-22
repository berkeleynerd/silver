module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def applicationUnitsBody : String := include_str "../../src/silver_application_units.adb"

end Silver.Source
