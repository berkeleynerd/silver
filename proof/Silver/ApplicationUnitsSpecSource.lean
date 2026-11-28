module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def applicationUnitsSpec : String := include_str "../../src/silver_application_units.ads"

end Silver.Source
