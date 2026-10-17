import Silver
open Lean Meta Elab Command

def capacityNames : List Name := [
  `Silver.maxSourceLength, `Silver.Compose.maxBindings, `Silver.ScalarExpression.maxBindings,
  `Silver.Compose.maxExpressionOperands, `Silver.Bindings.maxExpressionOperands, `Silver.Compose.maxConcatenations,
  `Silver.ScalarExpression.maxOperands, `Silver.ScalarLiteral.maxExponent, `Silver.ScalarLiteral.maxMagnitude,
  `Silver.Output.Runtime.maxLength, `Silver.Guarded.guaranteedIntegerLast,
  `Silver.Integer.maxValue, `Silver.Integer.minValue]

elab "#capacity_report" : command => do
  let env ← getEnv
  let caps := capacityNames.filter env.contains
  logInfo m!"resolved: {caps}"
  -- per-constant direct-reference statistics over Silver declarations
  let mut lines : Array String := #[]
  for c in caps do
    let mut inType := 0
    let mut inValueOnly := 0
    let mut thmValueOnly := 0
    let mut eqLemmaUsers := 0
    let eqNames : List Name := [c ++ `eq_1, c ++ `eq_def, c.str "eq_1", c.str "eq_def"]
    let mut mods : Std.HashMap Name Nat := {}
    for (n, ci) in env.constants.toList do
      unless (`Silver).isPrefixOf n do continue
      let tyRef := ci.type.getUsedConstants.contains c
      let valRefs := match ci.value? (allowOpaque := true) with
        | some v => v.getUsedConstants
        | none => #[]
      let valRef := valRefs.contains c
      if eqNames.any (valRefs.contains ·) then
        eqLemmaUsers := eqLemmaUsers + 1
      if tyRef then inType := inType + 1
      else if valRef then
        inValueOnly := inValueOnly + 1
        if (match ci with | .thmInfo _ => true | _ => false) then thmValueOnly := thmValueOnly + 1
      if tyRef || valRef then
        match env.getModuleIdxFor? n with
        | some idx => 
          let m := env.header.moduleNames[idx.toNat]!
          mods := mods.insert m (mods.getD m 0 + 1)
        | none => pure ()
    lines := lines.push s!"{c}: declsWithTypeRef={inType} valueOnlyRef={inValueOnly} (theorems {thmValueOnly}) eqLemmaUsers={eqLemmaUsers} modules={mods.size}"
  logInfo (String.intercalate "\n" lines.toList)

#capacity_report
