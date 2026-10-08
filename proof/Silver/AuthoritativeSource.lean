/-!
The authoritative input bindings are handwritten and outside the candidate
generator. Generated certificates may prove facts about these definitions;
they cannot choose which source is certified.
-/

namespace Silver.Source

def profileSpec : String := include_str "../../src/silver_profile.ads"
def profileBody : String := include_str "../../src/silver_profile.adb"

end Silver.Source
