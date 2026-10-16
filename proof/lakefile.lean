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

input_file outputProfileSpecSource where
  path := "../src/silver_output_profile.ads"
  text := false
input_file outputProfileBodySource where
  path := "../src/silver_output_profile.adb"
  text := false
input_file ioSpecSource where
  path := "../src/silver_io.ads"
  text := false
input_file ioBodySource where
  path := "../src/silver_io.adb"
  text := false
input_file outputLibcSource where
  path := "../src/silver_output_libc.ads"
  text := false

input_file argumentsSpecSource where
  path := "../src/silver_arguments.ads"
  text := false
input_file argumentsBodySource where
  path := "../src/silver_arguments.adb"
  text := false
input_file runtimeSpecSource where
  path := "../src/silver_runtime.ads"
  text := false

-- The umbrella has no external source dependency. Exact one-module libraries
-- below assign each include_str binding its own binary source dependency.
-- Lake resolves overlapping module owners in reverse declaration order, so keep
-- these exact libraries after Silver. Imports carry each dependency onward.
@[default_target]
lean_lib Silver

lean_lib ProfileSpecSource where
  roots := #[]
  globs := #[.one `Silver.ProfileSpecSource]
  needs := #[profileSpecSource]

lean_lib ProfileBodySource where
  roots := #[]
  globs := #[.one `Silver.ProfileBodySource]
  needs := #[profileBodySource]

lean_lib OutputProfileSpecSource where
  roots := #[]
  globs := #[.one `Silver.OutputProfileSpecSource]
  needs := #[outputProfileSpecSource]

lean_lib OutputProfileBodySource where
  roots := #[]
  globs := #[.one `Silver.OutputProfileBodySource]
  needs := #[outputProfileBodySource]

lean_lib IoSpecSource where
  roots := #[]
  globs := #[.one `Silver.IoSpecSource]
  needs := #[ioSpecSource]

lean_lib IoBodySource where
  roots := #[]
  globs := #[.one `Silver.IoBodySource]
  needs := #[ioBodySource]

lean_lib OutputLibcSpecSource where
  roots := #[]
  globs := #[.one `Silver.OutputLibcSpecSource]
  needs := #[outputLibcSource]

lean_lib ArgumentsSpecSource where
  roots := #[]
  globs := #[.one `Silver.ArgumentsSpecSource]
  needs := #[argumentsSpecSource]

lean_lib ArgumentsBodySource where
  roots := #[]
  globs := #[.one `Silver.ArgumentsBodySource]
  needs := #[argumentsBodySource]

lean_lib RuntimeSpecSource where
  roots := #[]
  globs := #[.one `Silver.RuntimeSpecSource]
  needs := #[runtimeSpecSource]

input_file outputLexicalSpecSource where
  path := "../src/silver_output_lexical.ads"
  text := false

lean_lib OutputLexicalSpecSource where
  roots := #[]
  globs := #[.one `Silver.OutputLexicalSpecSource]
  needs := #[outputLexicalSpecSource]

input_file outputLexicalBodySource where
  path := "../src/silver_output_lexical.adb"
  text := false

lean_lib OutputLexicalBodySource where
  roots := #[]
  globs := #[.one `Silver.OutputLexicalBodySource]
  needs := #[outputLexicalBodySource]

input_file integerLiteralSpecSource where
  path := "../src/silver_integer_literals.ads"
  text := false

lean_lib IntegerLiteralSpecSource where
  roots := #[]
  globs := #[.one `Silver.IntegerLiteralSpecSource]
  needs := #[integerLiteralSpecSource]

input_file integerLiteralBodySource where
  path := "../src/silver_integer_literals.adb"
  text := false

lean_lib IntegerLiteralBodySource where
  roots := #[]
  globs := #[.one `Silver.IntegerLiteralBodySource]
  needs := #[integerLiteralBodySource]

input_file scalarsSpecSource where
  path := "../src/silver_scalars.ads"
  text := false

lean_lib ScalarsSpecSource where
  roots := #[]
  globs := #[.one `Silver.ScalarsSpecSource]
  needs := #[scalarsSpecSource]

input_file scalarLiteralSpecSource where
  path := "../src/silver_scalar_literals.ads"
  text := false

lean_lib ScalarLiteralSpecSource where
  roots := #[]
  globs := #[.one `Silver.ScalarLiteralSpecSource]
  needs := #[scalarLiteralSpecSource]

input_file scalarLiteralBodySource where
  path := "../src/silver_scalar_literals.adb"
  text := false

lean_lib ScalarLiteralBodySource where
  roots := #[]
  globs := #[.one `Silver.ScalarLiteralBodySource]
  needs := #[scalarLiteralBodySource]

input_file scalarExpressionSpecSource where
  path := "../src/silver_scalar_expressions.ads"
  text := false

lean_lib ScalarExpressionSpecSource where
  roots := #[]
  globs := #[.one `Silver.ScalarExpressionSpecSource]
  needs := #[scalarExpressionSpecSource]

input_file scalarExpressionBodySource where
  path := "../src/silver_scalar_expressions.adb"
  text := false

lean_lib ScalarExpressionBodySource where
  roots := #[]
  globs := #[.one `Silver.ScalarExpressionBodySource]
  needs := #[scalarExpressionBodySource]

input_file pathFactsSpecSource where
  path := "../src/silver_path_facts.ads"
  text := false

lean_lib PathFactsSpecSource where
  roots := #[]
  globs := #[.one `Silver.PathFactsSpecSource]
  needs := #[pathFactsSpecSource]

input_file namesSpecSource where
  path := "../src/silver_names.ads"
  text := false

lean_lib NamesSpecSource where
  roots := #[]
  globs := #[.one `Silver.NamesSpecSource]
  needs := #[namesSpecSource]

input_file namesBodySource where
  path := "../src/silver_names.adb"
  text := false

lean_lib NamesBodySource where
  roots := #[]
  globs := #[.one `Silver.NamesBodySource]
  needs := #[namesBodySource]

input_file imageTheorySpecSource where
  path := "../src/silver_image_theory.ads"
  text := false

lean_lib ImageTheorySpecSource where
  roots := #[]
  globs := #[.one `Silver.ImageTheorySpecSource]
  needs := #[imageTheorySpecSource]

input_file imageModelSpecSource where
  path := "../src/silver_image_model.ads"
  text := false

lean_lib ImageModelSpecSource where
  roots := #[]
  globs := #[.one `Silver.ImageModelSpecSource]
  needs := #[imageModelSpecSource]

input_file imageModelBodySource where
  path := "../src/silver_image_model.adb"
  text := false

lean_lib ImageModelBodySource where
  roots := #[]
  globs := #[.one `Silver.ImageModelBodySource]
  needs := #[imageModelBodySource]

input_file imageModelTemplatesSpecSource where
  path := "../src/silver_image_model_templates.ads"
  text := false

lean_lib ImageModelTemplatesSpecSource where
  roots := #[]
  globs := #[.one `Silver.ImageModelTemplatesSpecSource]
  needs := #[imageModelTemplatesSpecSource]

input_file imageModelTemplatesBodySource where
  path := "../src/silver_image_model_templates.adb"
  text := false

lean_lib ImageModelTemplatesBodySource where
  roots := #[]
  globs := #[.one `Silver.ImageModelTemplatesBodySource]
  needs := #[imageModelTemplatesBodySource]
