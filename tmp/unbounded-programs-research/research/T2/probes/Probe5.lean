import Silver
open Lean Meta Elab Command

def isSilverModule (env : Environment) (n : Name) : Bool :=
  match env.getModuleIdxFor? n with
  | some idx => (`Silver).isPrefixOf env.header.moduleNames[idx.toNat]!
  | none => false

def hasLit (k : Nat) (e : Expr) : Bool :=
  (e.find? fun x => match x with | .lit (.natVal n) => n == k | _ => false).isSome

elab "#lits" : command => do
  let env ← getEnv
  let h ← IO.FS.Handle.mk "/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T2/literal_types.tsv" .write
  let mut count : Nat := 0
  for (n, ci) in env.constants.toList do
    unless isSilverModule env n do continue
    let ty := ci.type
    let tags := [4096, 4097, 341, 32767, 12288, 8192].filter (hasLit · ty)
    let valTags := match ci with
      | .defnInfo v => [4096, 4097, 341].filter (hasLit · v.value)
      | _ => []
    if !tags.isEmpty || !valTags.isEmpty then
      count := count + 1
      let m := match env.getModuleIdxFor? n with | some i => env.header.moduleNames[i.toNat]!.toString | none => "?"
      let kind := match ci with | .defnInfo _ => "defn" | .thmInfo _ => "thm" | .inductInfo _ => "induct" | .ctorInfo _ => "ctor" | .recInfo _ => "rec" | _ => "other"
      h.putStrLn s!"{m}\t{n}\t{kind}\ttype:{tags}\tdefval:{valTags}"
  logInfo m!"{count}"

#lits
