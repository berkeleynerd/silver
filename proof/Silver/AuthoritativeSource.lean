/-!
The authoritative input bindings are handwritten and outside the candidate
generator. Generated certificates may prove facts about these definitions;
they cannot choose which source is certified.
-/

namespace Silver.Source

def profileSpec : String := include_str "../../src/silver_profile.ads"
def profileBody : String := include_str "../../src/silver_profile.adb"
def outputProfileSpec : String := include_str "../../src/silver_output_profile.ads"
def outputProfileBody : String := include_str "../../src/silver_output_profile.adb"
def ioSpec : String := include_str "../../src/silver_io.ads"
def ioBody : String := include_str "../../src/silver_io.adb"
def outputLibcSpec : String := include_str "../../src/silver_output_libc.ads"

end Silver.Source
