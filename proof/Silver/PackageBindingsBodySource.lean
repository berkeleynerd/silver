module

@[expose] public section

/-! The authoritative Ada source is bound independently of generated witnesses. -/
namespace Silver.Source

def packageBindingsBody : String := include_str "../../src/silver_package_bindings.adb"

end Silver.Source
