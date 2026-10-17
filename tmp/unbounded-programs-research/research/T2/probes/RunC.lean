import Silver
open Lean Meta Elab Command

/-! Research probe (T2): lambda-lift capacity constants through their dependency cone
and kernel-check every lifted declaration. A failure means the original proof used the
concrete value (directly or via a hard-coded literal), assuming its lifted dependencies hold.
Nothing is written to the project; the environment is in-memory only. -/

namespace T2Lift

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
  | .inductInfo v => t ++ v.ctors.toArray ++ (v.ctors.toArray.flatMap fun _ => #[])
  | .ctorInfo v => t.push v.induct
  | .recInfo v => t ++ v.all.toArray
  | _ => t

def liftName (n : Name) : Name := `_conc ++ n

partial def liftExpr (cone : Std.HashSet Name) (subs : Std.HashMap Name Expr) (L : Expr) (e : Expr) : Expr :=
  e.replace fun
    | .const c us =>
      match subs.get? c with
      | some s => some s
      | none => if cone.contains c then some (.const (liftName c) us) else none
    | .proj t i s =>
      if cone.contains t then some (.proj (liftName t) i (liftExpr cone subs L s)) else none
    | _ => none

/-- Group key: inductive group representative for ctors/recs/inductives. -/
def groupOf (env : Environment) (n : Name) : Name :=
  match env.find? n with
  | some (.ctorInfo v) => (match env.find? v.induct with
      | some (.inductInfo iv) => iv.all.head!
      | _ => v.induct)
  | some (.recInfo v) => v.all.head!
  | some (.inductInfo v) => v.all.head!
  | _ => n

def clip (s : String) (n : Nat) : String := String.ofList ((s.toList.take n).map fun c => if c == '\n' then ' ' else c)

def runLift (seeds : List (Name × (Expr → MetaM Expr))) (literalDecls : List Name)
    (literalMap : Expr → Expr → MetaM (Option Expr)) (logPath : String) (concreteValue : Expr) : MetaM Unit := do
  let env ← getEnv
  let h ← IO.FS.Handle.mk logPath .write
  let log (s : String) : MetaM Unit := do h.putStrLn s; h.flush
  let silver := env.constants.toList.filter (fun (n, _) => isSilverModule env n)
  let seedSet : Std.HashSet Name := seeds.foldl (fun s (n, _) => s.insert n) {}
  -- literal-sensitive declarations are forced into the cone
  let mut inD : Std.HashSet Name := literalDecls.foldl (fun s n => s.insert n) seedSet
  let mut changed := true
  while changed do
    changed := false
    for (n, ci) in silver do
      if inD.contains n then continue
      if (usedOf ci).any inD.contains then
        inD := inD.insert n
        changed := true
  -- the cone excludes the seeds themselves (they are substituted)
  let cone := seeds.foldl (fun s (n, _) => s.erase n) inD
  log s!"cone size {cone.size}"
  -- topological order over groups
  let mut order : Array Name := #[]
  let mut visited : Std.HashSet Name := {}
  let mut work : Array Name := #[]
  for (n, _) in silver do
    if cone.contains n then work := work.push n
  -- iterative DFS
  for root in work do
    let g := groupOf env root
    if visited.contains g then continue
    let mut stack : Array (Name × Bool) := #[(g, false)]
    while !stack.isEmpty do
      let (x, done) := stack.back!
      stack := stack.pop
      if done then
        order := order.push x
        continue
      if visited.contains x then continue
      visited := visited.insert x
      stack := stack.push (x, true)
      let members : Array Name := match env.find? x with
        | some (.inductInfo v) => v.all.toArray ++ (v.all.toArray.flatMap fun t => match env.find? t with
            | some (.inductInfo tv) => tv.ctors.toArray | _ => #[])
        | _ => #[x]
      for m in members do
        match env.find? m with
        | some ci =>
          for d in usedOf ci do
            if cone.contains d then
              let gd := groupOf env d
              if !visited.contains gd then stack := stack.push (gd, false)
        | none => pure ()
  log s!"groups {order.size}"
  let mut ok := 0
  let mut failed := 0
  let mut idx := 0
  for g in order do
    idx := idx + 1
    let some ci := env.find? g | continue
    let start ← IO.monoMsNow
    let decl? : Option Declaration ← (fun (L : Expr) => (do
      let mut subs : Std.HashMap Name Expr := {}
      for (n, f) in seeds do
        subs := subs.insert n (← f L)
      let litFix (e : Expr) : MetaM Expr := do
        if literalDecls.contains g then
          let r ← Meta.transform e (pre := fun x => do
            match ← literalMap L x with
            | some y => return .done y
            | none => return .continue)
          pure r
        else pure e
      let lift (e : Expr) : MetaM Expr := do
        let e ← litFix e
        pure (liftExpr cone subs L e)
      match ci with
      | .defnInfo v =>
        let ty ← lift v.type
        let val ← lift v.value
        let dv : DefinitionVal := {
          name := liftName v.name
          levelParams := v.levelParams
          type := ty
          value := val
          hints := v.hints
          safety := v.safety
          all := [liftName v.name] }
        pure (some (.defnDecl dv))
      | .thmInfo v =>
        let ty ← lift v.type
        let val ← lift v.value
        let tv : TheoremVal := {
          name := liftName v.name
          levelParams := v.levelParams
          type := ty
          value := val
          all := [liftName v.name] }
        pure (some (.thmDecl tv))
      | .inductInfo v =>
        let mut types : List InductiveType := []
        for t in v.all do
          let tv ← getConstInfoInduct t
          let ty ← lift tv.type
          let mut ctors : List Constructor := []
          for c in tv.ctors do
            let cv ← getConstInfoCtor c
            let cty ← lift cv.type
            ctors := ctors ++ [Constructor.mk (liftName c) cty]
          types := types ++ [InductiveType.mk (liftName t) ty ctors]
        pure (some (.inductDecl v.levelParams v.numParams types v.isUnsafe))
      | _ => pure none) : Expr → MetaM (Option Declaration)) concreteValue
    let some decl := decl? | continue
    let kenv := (← getEnv).toKernelEnv
    let opts ← getOptions
    let modName := match env.getModuleIdxFor? g with
      | some i => env.header.moduleNames[i.toNat]!.toString | none => "?"
    match Kernel.Environment.addDecl kenv opts decl with
    | .ok _ =>
      ok := ok + 1
    | .error e =>
      failed := failed + 1
      let msg ← (e.toMessageData opts).toString
      log s!"FAIL\t{modName}\t{g}\t{clip msg 700}"
    let elapsed := (← IO.monoMsNow) - start
    if elapsed > 5000 then log s!"SLOW\t{elapsed}ms\t{modName}\t{g}"
    -- add without checking so that dependents see the lifted declaration
    try
      withOptions (fun o => o.setBool `debug.skipKernelTC true) (addDecl decl)
    catch ex =>
      log s!"ADDFAIL\t{modName}\t{g}\t{clip (← ex.toMessageData.toString) 300}"
    if idx % 250 == 0 then log s!"progress {idx}/{order.size} ok={ok} failed={failed}"
  log s!"DONE ok={ok} failed={failed} groups={order.size}"

end T2Lift

open Lean Meta Elab Command T2Lift
set_option maxHeartbeats 0
set_option maxRecDepth 100000
set_option Elab.async false

def hasLitB (k : Nat) (e : Expr) : Bool :=
  (e.find? fun x => match x with | .lit (.natVal n) => n == k | _ => false).isSome

def bigN : Nat := 2147483646

elab "#runC" : command => liftTermElabM do
  let env ← getEnv
  let seeds : List (Name × (Expr → MetaM Expr)) := [
    (`Silver.maxSourceLength, fun L => pure L),
    (`Silver.ScalarExpression.maxBindings, fun L => mkAppM ``HDiv.hDiv #[L, mkNatLit 12]),
    (`Silver.Output.Runtime.maxLength, fun L => pure L),
    (`Silver.Guarded.guaranteedIntegerLast, fun _ => pure (mkNatLit 2147483647))]
  let litModules : List Name := [`Silver.OutputEquations, `Silver.OutputExpressions]
  let mut lits : Array Name := #[`Silver.ScalarExpression.Native.ValidText, `Silver.ScalarExpression.Native.ResultType,
    `Silver.ScalarExpression.Native.LiteralType, `Silver.admitted_bounds, `Silver.Output.member_literal]
  for (n, ci) in env.constants.toList do
    match env.getModuleIdxFor? n with
    | some i =>
      if litModules.contains env.header.moduleNames[i.toNat]! && hasLitB 4096 ci.type && !(n.toString.splitOn "sparseCasesOn").length > 1 then
        lits := lits.push (groupOf env n)
    | none => pure ()
  let litList := lits.toList.eraseDups
  let litMap : Expr → Expr → MetaM (Option Expr) := fun L x => do
    match x with
    | .app (.app (.app (.const ``OfNat.ofNat _) (.const ``Nat [])) (.lit (.natVal 4096))) _ => pure (some L)
    | .app (.app (.app (.const ``OfNat.ofNat _) (.const ``Nat [])) (.lit (.natVal 4097))) _ =>
        pure (some (mkNatLit (bigN + 1)))
    | .lit (.natVal 4096) => pure (some (mkRawNatLit bigN))
    | _ => pure none
  logInfo m!"literal decls: {litList.length}"
  runLift seeds litList litMap "/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T2/runC.log" (mkNatLit bigN)

#runC
