import Silver
open Lean Meta Elab Command

def tops : List Name := [
  `Silver.Current.accepts_iff_member, `Silver.Current.member_has_meaning, `Silver.Current.meaning_unique,
  `Silver.Current.uniform_discharge, `Silver.Current.automatic_discharge_complete,
  `Silver.Current.admitted_fragment, `Silver.Current.all_obligations_discharge,
  `Silver.Current.execution_specified, `Silver.Current.effects_domain, `Silver.Current.healthy_execution,
  `Silver.Current.cumulative_output_bound, `Silver.Current.admitted_assurance, `Silver.Current.every_meaning_assured,
  `Silver.Current.model_tool_contract, `Silver.Current.automatic_pipeline, `Silver.Current.pipeline_checks_valid,
  `Silver.Current.pipeline_preserves, `Silver.Current.pipeline_realizes, `Silver.Semantics.admitted_assurance,
  `Silver.Predicate.member_has_meaning, `Silver.Predicate.meaning_unique, `Silver.Predicate.accepts_iff_member]

elab "#roots" : command => do
  let env ← getEnv
  let roots ← (IO.FS.lines "/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T2/runA_roots.txt")
  let rootSet : Std.HashSet Name := roots.foldl (fun s r => s.insert r.toName) {}
  -- also find correspondence top-level theorems: every theorem in modules *SourceBridge / *Correspondence
  let mut extra : Array Name := #[]
  for (n, ci) in env.constants.toList do
    match ci, env.getModuleIdxFor? n with
    | .thmInfo _, some i =>
      let m := env.header.moduleNames[i.toNat]!.toString
      if (m == "Silver.PredicateCorrespondence" || m == "Silver.PredicateSourceBridge" || m == "Silver.PredicateNativeSourceBridge") && !n.isInternal then
        extra := extra.push n
    | _, _ => pure ()
  let mut lines : Array String := #[]
  for t in tops ++ extra.toList do
    let some _ := env.find? t | lines := lines.push s!"{t}: missing"; continue
    let mut seen : Std.HashSet Name := {}
    let mut stack := #[t]
    let mut hit : Array Name := #[]
    while !stack.isEmpty do
      let x := stack.back!
      stack := stack.pop
      if seen.contains x then continue
      seen := seen.insert x
      if rootSet.contains x then hit := hit.push x
      match env.find? x with
      | some ci =>
        let used := ci.type.getUsedConstants ++ (match ci with
          | .defnInfo v => v.value.getUsedConstants | .thmInfo v => v.value.getUsedConstants | _ => #[])
        for u in used do
          if !seen.contains u then
            match env.getModuleIdxFor? u with
            | some i => if (`Silver).isPrefixOf env.header.moduleNames[i.toNat]! then stack := stack.push u
            | none => pure ()
      | none => pure ()
    lines := lines.push s!"{t}\t{hit.size}\t{hit.toList.take 40}"
  IO.FS.writeFile "/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T2/top_roots.tsv" (String.intercalate "\n" lines.toList)
  logInfo m!"done {lines.size}"

#roots
