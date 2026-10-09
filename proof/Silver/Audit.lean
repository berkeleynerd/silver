import Silver
import Lean

/-!
Check transitive logical assumptions for every declaration originating in a
Silver proof module, including generated and private declarations. In
particular, `sorryAx`, project-specific axioms, and native-evaluation trust
axioms fail this command. The allowed names are Lean's standard logical
foundations; this audit does not assert that external tools have been proved.
-/

open Lean Elab Command

run_cmd do
  if debug.skipKernelTC.get (← getOptions) then
    throwError "Kernel type checking must remain enabled"
  let foundations : Array Name := #[``propext, ``Quot.sound, ``Classical.choice]
  let environment := (← getEnv).setExporting false
  for moduleName in environment.header.moduleNames do
    if (`Silver).isPrefixOf moduleName then
      logInfo m!"SILVER_MODULE {moduleName}"
  logInfo "SILVER_MODULE Silver.Audit"
  let mut inspected : Nat := 0
  let mut used : Array Name := #[]
  for (name, _) in environment.constants.toList do
    let owned := match environment.getModuleIdxFor? name with
      | some index => (`Silver).isPrefixOf environment.header.moduleNames[index]!
      | none => (`Silver).isPrefixOf name
    if owned then
      inspected := inspected + 1
      let assumptions ← collectAxioms name
      for assumption in assumptions do
        unless foundations.contains assumption do
          throwError "Unapproved logical assumption {assumption} in {name}"
        unless used.contains assumption do
          used := used.push assumption
  if inspected = 0 then
    throwError "Axiom audit inspected no Silver declarations"
  logInfo m!"Silver axiom audit passed: {inspected} declarations; foundations: {used.toList}"

#print axioms Silver.accepts_iff_member
#print axioms Silver.Cursor.isMember_iff
#print axioms Silver.Semantics.admitted_assurance
#print axioms Silver.SourceBridge.authoritative_source_member_iff
#print axioms Silver.SourceBridge.actual_catalogue
#print axioms Silver.SourceBridge.checked_membership_supported_pipeline
#print axioms Silver.Expressions.member_implementation_iff
#print axioms Silver.Expressions.model_equations
#print axioms Silver.SourceBridge.checked_source
#print axioms Silver.Source.hidden_declaration_rejected
#print axioms Silver.Source.unsupported_literal_syntax_rejected
#print axioms Silver.Output.accepts_iff_member
#print axioms Silver.Output.source_implementation_member_iff
#print axioms Silver.Arguments.SourceBridge.authoritative_current_member_iff
#print axioms Silver.Output.SourceBridge.authoritative_runtime_correct
#print axioms Silver.Output.Runtime.healthy_output
#print axioms Silver.Current.every_meaning_assured
#print axioms Silver.Current.automatic_pipeline
#print axioms Silver.Current.pipeline_preserves
#print axioms Silver.Current.pipeline_realizes
#print axioms Silver.Arguments.SourceBridge.checked_current_pipeline

#print axioms Silver.Output.literalAt_unique
#print axioms Silver.Output.parsed_unique
#print axioms Silver.Output.Expressions.model_interpreted
#print axioms Silver.Output.Runtime.ghost_blocks_no_effect_calls
#print axioms Silver.Output.Runtime.program_refines
#print axioms Silver.Output.Runtime.successful_output
#print axioms Silver.Output.Runtime.failed_output
#print axioms Silver.Output.SourceBridge.actual_runtime_declarations
#print axioms Silver.Current.accepts_iff_member
#print axioms Silver.Current.member_disjoint
#print axioms Silver.Current.meaning_unique
#print axioms Silver.Current.literal_domain
#print axioms Silver.Current.healthy_execution
#print axioms Silver.Current.model_tool_contract

#print axioms Silver.Named.accepts_iff_member
#print axioms Silver.Named.identifierEnd_sound
#print axioms Silver.Named.identifierEnd_complete
#print axioms Silver.Named.parsed_unique
#print axioms Silver.Named.meaning_unique
#print axioms Silver.Named.meaning_binds
#print axioms Silver.Named.evaluate_literal
#print axioms Silver.Named.execution_refines
#print axioms Silver.Named.literal_named_disjoint
#print axioms Silver.Named.null_named_disjoint
#print axioms Silver.Named.model_identifier_equations
#print axioms Silver.Named.model_equations
#print axioms Silver.Named.SourceBridge.checked_source
#print axioms Silver.Current.named_execution_refines

-- The named interface now contains only retained suffix/helper equations.
#print axioms Silver.Named.Expressions.interpreted_equations
#print axioms Silver.Named.Expressions.model_interpreted

#print axioms Silver.Arguments.accepts_iff_member
#print axioms Silver.Arguments.meaning_unique
#print axioms Silver.Arguments.meaning_binds
#print axioms Silver.Arguments.evaluate_initializer
#print axioms Silver.Arguments.execution_refines
#print axioms Silver.Arguments.invalid_execution
#print axioms Silver.Arguments.Runtime.initializer_refines
#print axioms Silver.Arguments.Runtime.validity_refines
#print axioms Silver.Arguments.Runtime.main_refines
#print axioms Silver.Arguments.Runtime.invalid_no_output
#print axioms Silver.Arguments.Runtime.explicit_empty_preserved
#print axioms Silver.Arguments.Expressions.interpreted_equations
#print axioms Silver.Arguments.Expressions.model_interpreted
#print axioms Silver.Arguments.SourceBridge.actual_runtime_translation
#print axioms Silver.Arguments.SourceBridge.checked_source
#print axioms Silver.Current.argument_execution_refines
#print axioms Silver.Current.argument_rejection

#print axioms Silver.Arguments.Main.rendered_tokens
#print axioms Silver.Arguments.Main.swapped_branches_differ
#print axioms Silver.Arguments.Main.uninitialized_initializer_fails
#print axioms Silver.Arguments.SourceBridge.authoritative_main_correct
#print axioms Silver.Arguments.example_current
#print axioms Silver.Arguments.missing_uses_initialized_default
#print axioms Silver.Output.Expressions.checked_precedence
#print axioms Silver.Named.Expressions.checked_precedence
#print axioms Silver.Arguments.Expressions.checked_precedence

#print axioms Silver.Concat.accepts_iff_member
#print axioms Silver.Concat.parsed_literal_consumption
#print axioms Silver.Concat.concatenation_bounds
#print axioms Silver.Concat.output_domain
#print axioms Silver.Concat.meaning_unique
#print axioms Silver.Concat.meaning_binds
#print axioms Silver.Concat.Main.rendered_tokens
#print axioms Silver.Concat.Main.checked_precedence
#print axioms Silver.Concat.Main.right_nested_rejected
#print axioms Silver.Concat.evaluation_refines
#print axioms Silver.Concat.Expressions.interpreted_equations
#print axioms Silver.Concat.Expressions.model_interpreted
#print axioms Silver.Concat.SourceBridge.authoritative_main_correct
#print axioms Silver.Current.concat_execution_refines
