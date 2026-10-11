import Lean

/-!
A fresh logical-assumption audit of the Silver modules actually imported by the
calling file. Declarations are selected by their origin module, including private
and generated declarations, rather than just their public names. The three
allowed axioms are Lean's standard logical foundations; this audit does not
assert that external tools have been proved.
-/

open Lean Elab Command

namespace Silver.AxiomAudit

elab "#silver_audit" : command => do
  if debug.skipKernelTC.get (← getOptions) then
    throwError "Kernel type checking must remain enabled"
  let foundations : Array Name := #[``propext, ``Quot.sound, ``Classical.choice]
  let environment := (← getEnv).setExporting false
  let isSilverModule := fun name => (`Silver).isPrefixOf name
  let mut modules : Array Name := #[]
  for moduleName in environment.header.moduleNames.push environment.mainModule do
    if isSilverModule moduleName && !modules.contains moduleName then
      modules := modules.push moduleName
      logInfo m!"SILVER_MODULE {moduleName}"
  let mut inspected : Nat := 0
  let mut used : Array Name := #[]
  for (name, _) in environment.constants.toList do
    let owned := match environment.getModuleIdxFor? name with
      | some index => isSilverModule environment.header.moduleNames[index]!
      | none => isSilverModule environment.mainModule || isSilverModule name
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

end Silver.AxiomAudit
