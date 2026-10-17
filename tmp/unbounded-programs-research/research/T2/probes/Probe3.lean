import Silver
open Lean Meta Elab Command

def isSilverModule (env : Environment) (n : Name) : Bool :=
  match env.getModuleIdxFor? n with
  | some idx => (`Silver).isPrefixOf env.header.moduleNames[idx.toNat]!
  | none => false

def usedOf (ci : ConstantInfo) : Array Name :=
  let t := ci.type.getUsedConstants
  match ci with
  | .defnInfo v => t ++ v.value.getUsedConstants
  | .thmInfo v => t ++ v.value.getUsedConstants
  | .opaqueInfo v => t ++ v.value.getUsedConstants
  | .inductInfo v => t ++ v.ctors.toArray
  | .ctorInfo v => t.push v.induct
  | .recInfo v => t ++ (v.rules.toArray.flatMap fun r => r.rhs.getUsedConstants) ++ v.all.toArray
  | _ => t

elab "#cone " k:ident : command => do
  let env ← getEnv
  let k := k.getId
  let silver := env.constants.toList.filter (fun (n, _) => isSilverModule env n)
  logInfo m!"silver decls: {silver.length}"
  -- fixpoint over dependents
  let mut inD : Std.HashSet Name := {}
  inD := inD.insert k
  let mut changed := true
  let mut rounds : Nat := 0
  while changed do
    changed := false
    rounds := rounds + 1
    for (n, ci) in silver do
      if inD.contains n then continue
      if (usedOf ci).any inD.contains then
        inD := inD.insert n
        changed := true
  let mut kinds : Std.HashMap String Nat := {}
  let mut missing : Nat := 0
  let mut inductives : Array Name := #[]
  for (n, ci) in silver do
    if inD.contains n && n != k then
      let kind := match ci with
        | .defnInfo _ => "defn" | .thmInfo _ => "thm" | .opaqueInfo _ => "opaque"
        | .inductInfo _ => "induct" | .ctorInfo _ => "ctor" | .recInfo _ => "rec"
        | .axiomInfo _ => "axiom" | .quotInfo _ => "quot"
      kinds := kinds.insert kind (kinds.getD kind 0 + 1)
      if kind == "induct" then inductives := inductives.push n
  logInfo m!"rounds {rounds}; cone size {inD.size - 1}; kinds {kinds.toList}"
  logInfo m!"inductives in cone ({inductives.size}): {inductives.toList.take 80}"

#cone Silver.maxSourceLength
