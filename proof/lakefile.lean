import Lake
open Lake DSL

package silverProof where
  -- Source certificates share large literal terms; checking declarations in
  -- sequence is the memory-safe default. Scheduling changes need not invalidate
  -- accepted proof terms, unlike semantic options such as warningAsError.
  moreLeanArgs := #["-DwarningAsError=true"]
  weakLeanArgs := #["-j" ++ (get_config? silverThreads).getD "1"] ++
    match get_config? silverMemoryMb with
    | some limit => #["-M" ++ limit]
    | none => #[]

-- include_str does not register external dependencies with Lake. These inputs
-- make changes to the actual authoritative Ada bytes invalidate cached proofs.
-- Keep binary hashing: normalizing CR/LF would lose a source-identity change.
input_file profileSpecSource where
  path := "../src/silver_profile.ads"
  text := false

input_file profileBodySource where
  path := "../src/silver_profile.adb"
  text := false

@[default_target]
lean_lib Silver where
  needs := #[profileSpecSource, profileBodySource]
