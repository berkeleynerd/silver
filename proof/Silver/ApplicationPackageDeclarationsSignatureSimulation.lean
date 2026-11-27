module

public import Silver.ApplicationPackageDeclarationsSignatureLoopSimulation

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxRecDepth 20000
set_option maxHeartbeats 2000000
attribute [local irreducible] entry iteration finish

private def openedStore (store : Locals) : Locals :=
  store.set .state "header" {store .state "header" with position := store .number "open"}

private def guardStart (store : Locals) : Option Transfer :=
  if store .number "open" = 0 then some (.exited store) else some (.next (openedStore store))

private def nativeStart (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (prior : Locals)
    (source : Source) (outer : ParserState) (info : PackageBindings.Metadata) (completing : Bool) : Option Transfer :=
  entry.eval calls.get procedures backing
    (body.declarations.foldl (Declaration.eval calls.get) (inputLocals prior source outer info completing))
    guardStart (fun store => some (.returned store)) (fun _ => none)

private def rawEntry (cfg : Configuration) : SignatureStart → Observation Context SignatureResult
  | .returned result => .returned result
  | .ready state => .exited (cfg, state)
  | .loop state => .next (cfg, state)

private theorem start_agrees (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (prior : Locals)
    (source : Source) (outer : ParserState) (info : PackageBindings.Metadata) (completing : Bool) :
    (nativeStart calls procedures backing prior source outer info completing).map (Transfer.project context projectResult) =
      some (rawEntry ⟨source, outer, completing⟩ (signatureStart (rawCalls calls procedures) source outer info completing)) := by
  let entering : Continuation (Option (Observation Context SignatureResult)) :=
    fun text out mode state => some (.next (⟨text, out, mode⟩, state))
  let finishing : Continuation (Option (Observation Context SignatureResult)) :=
    fun text out mode state => some (.exited (⟨text, out, mode⟩, state))
  let returning : SignatureResult → Option (Observation Context SignatureResult) := fun value => some (.returned value)
  have ordinary (store : Locals) :
      (guardStart store).map (Transfer.project context projectResult) = afterEntry entering finishing store := by
    unfold guardStart afterEntry
    split <;> simp_all [entering, finishing, onState, openedStore, context, configuration, projectState, Locals.set, Transfer.project]
  unfold nativeStart
  rw [Statement.eval_map (statement := entry)
    (observe := fun transfer : Option Transfer => transfer.map (Transfer.project context projectResult))]
  simp only [Function.comp_def, ordinary, Option.map_some, Option.map_none, Transfer.project]
  have result := entry_meaning calls procedures backing prior source outer info completing entering finishing returning (fun _ => none)
  refine result.trans ?_
  cases signatureStart (rawCalls calls procedures) source outer info completing <;> rfl

private def consume (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (result : SignatureResult) :
    Option Transfer → Prop
  | none => False
  | some (.next store) => nativeLoop calls procedures backing result store
  | some (.exited store) => nativeFinish calls procedures backing result store
  | some (.returned store) => result = projectResult store

private theorem exec_start (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (prior : Locals)
    (source : Source) (outer : ParserState) (info : PackageBindings.Metadata) (completing : Bool) (result : SignatureResult) :
    body.Exec calls.get procedures backing (inputLocals prior source outer info completing)
      (fun store => result = projectResult store) =
    consume calls procedures backing result (nativeStart calls procedures backing prior source outer info completing) := by
  let test := present opened.expression
  let before : S := .assign position opened.expression
  let ordinary := fun store => if test.eval calls.get store then
    before.eval calls.get procedures backing store (nativeLoop calls procedures backing result)
      (fun out => result = projectResult out) (fun _ => False)
    else nativeFinish calls procedures backing result store
  have ordinaryEq (store : Locals) : ordinary store = consume calls procedures backing result (guardStart store) := by
    dsimp only [ordinary, test, before]
    unfold guardStart
    signature_values
    by_cases zero : store .number "open" = 0 <;> simp [zero, consume, openedStore]
  unfold nativeStart
  rw [Statement.eval_map (statement := entry) (observe := consume calls procedures backing result)]
  simp only [Body.Exec, show body.entry = entry from rfl, show body.guarded = some (test, before) from rfl,
    show body.finish = finish from rfl, show body.iteration = iteration from rfl]
  change entry.eval calls.get procedures backing
    (body.declarations.foldl (Declaration.eval calls.get) (inputLocals prior source outer info completing))
    ordinary (fun store => result = projectResult store) (fun _ => False) = _
  rw [show ordinary = fun store => consume calls procedures backing result (guardStart store) from funext ordinaryEq]
  rfl

private def acceptedStart (calls : SignatureCalls) (result : SignatureResult) : Observation Context SignatureResult → Prop
  | .next (cfg,state) => rawLoop calls result cfg state
  | .exited (cfg,state) => result = finishSignature calls cfg.source cfg.outer cfg.completing state
  | .returned value => result = value

private def slotAtStart : Observation Context SignatureResult → Prop
  | .next (cfg,state) | .exited (cfg,state) => RoutineSlot cfg.completing state
  | .returned _ => True

private theorem consumes (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (result : SignatureResult)
    (transfer : Transfer) (slot : slotAtStart (transfer.project context projectResult)) :
    consume calls procedures backing result (some transfer) =
      acceptedStart (rawCalls calls procedures) result (transfer.project context projectResult) := by
  cases transfer with
  | next store => exact propext (loop_iff calls procedures backing result store slot)
  | exited store => exact finish_meaning calls procedures backing store slot (fun value => result = value) _
  | returned store => rfl

/-- Full typed execution agrees with the raw signature relation for every
input frame, metadata record, backing array and completion flag. The entry
and loop establish the fresh slot law required by the final routine write. -/
theorem exec_iff (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (prior : Locals)
    (source : Source) (outer : ParserState) (info : PackageBindings.Metadata) (completing : Bool) (result : SignatureResult) :
    body.Exec calls.get procedures backing (inputLocals prior source outer info completing)
      (fun store => result = projectResult store) ↔
    SignatureExec (rawCalls calls procedures) source outer info completing result := by
  let actual := rawCalls calls procedures
  let cfg : Configuration := ⟨source, outer, completing⟩
  let start := signatureStart actual source outer info completing
  have slot : slotAtStart (rawEntry cfg start) := by
    have law := start_slot actual source outer info completing
    dsimp only [start]
    generalize h : signatureStart actual source outer info completing = chosen at law ⊢
    cases chosen <;> exact law
  have reading : acceptedStart actual result (rawEntry cfg start) ↔ SignatureExec actual source outer info completing result := by
    dsimp only [start, SignatureExec]
    cases signatureStart actual source outer info completing <;> rfl
  have agrees := start_agrees calls procedures backing prior source outer info completing
  rw [exec_start]
  cases captured : nativeStart calls procedures backing prior source outer info completing with
  | none => rw [captured] at agrees; contradiction
  | some transfer =>
      rw [captured] at agrees
      have same : transfer.project context projectResult = rawEntry cfg start := Option.some.inj agrees
      rw [consumes calls procedures backing result transfer (same.symm ▸ slot), same]
      exact reading

end Silver.ApplicationPackageDeclarations.SignatureNative
