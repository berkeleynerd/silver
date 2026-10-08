import Lake
open Lake DSL

package silverProof where
  -- Source certificates share large literal terms; checking declarations in
  -- sequence avoids multiplying their peak memory across worker threads.
  moreLeanArgs := #["-DwarningAsError=true", "-j1"]

@[default_target]
lean_lib Silver
