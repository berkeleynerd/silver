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
