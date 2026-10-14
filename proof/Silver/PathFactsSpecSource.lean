module

@[expose] public section

/-! Handwritten authoritative binding; candidate generation never changes it. -/
namespace Silver.Source

def pathFactsSpec : String := include_str "../../src/silver_path_facts.ads"

end Silver.Source
