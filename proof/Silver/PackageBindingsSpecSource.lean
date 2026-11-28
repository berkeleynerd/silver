module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def packageBindingsSpec : String := include_str "../../src/silver_package_bindings.ads"

end Silver.Source
