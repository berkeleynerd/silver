module

public import Silver.ApplicationPackageDeclarationsSignatureNative

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control ApplicationPackageProcedure

set_option backward.dsimp.instances true
set_option maxHeartbeats 2000000
set_option maxRecDepth 20000

def projectResult (store : Locals) : SignatureResult := ⟨store .metadata "info", store .state "header"⟩

def projectState (store : Locals) : SignatureState where
  info := store .metadata "info"
  header := store .state "header"
  item := store .routine "item"
  routineId := store .number "routine_id"
  formalCount := store .number "formal_count"
  formalStart := store .number "formal_start"

def rawCalls (calls : Calls) (procedures : ProcedureCalls) : SignatureCalls :=
  {calls.base with append := procedures.appendFormal}

def inputLocals (prior : Locals) (source : Source) (outer : ParserState) (info : PackageBindings.Metadata)
    (completing : Bool) : Locals :=
  (((prior.set .source "text" source).set .state "outer" outer).set .metadata "info" info).set .truth "completing" completing

abbrev Continuation (α : Sort u) := Source → ParserState → Bool → SignatureState → α

def onState (observe : Continuation α) (store : Locals) : α :=
  observe (store .source "text") (store .state "outer") (store .truth "completing") (projectState store)

def observeStep (source : Source) (outer : ParserState) (completing : Bool) (next : Continuation α)
    (returned : SignatureResult → α) (exited : Continuation α) : SignatureStep → α
  | .next state => next source outer completing state
  | .returned result => returned result
  | .ready state => exited source outer completing state

macro "signature_values" : tactic => `(tactic|
  dsimp +instances only [Statement.eval, Statement.list, Control.TableKind.resize, ApplicationPackageProcedure.Primitive.eval,
    Place.expression, Place.set, Expr.eval, Updates.eval, Field.get, Field.set, Index.get, Index.set,
    PackageRecord.defaults, Declaration.eval, Declaration.names, Initialization.value, List.foldr, List.foldl,
    Control.constant, Control.localDeclaration, Calls.get, Control.call2, Control.call3, Control.call4,
    take, empty, present, inc, validState, rejected, rejectIf, returnIf, SignatureNative.text, SignatureNative.outer,
    SignatureNative.info, header, SignatureNative.completing, original, functionEnd, procedureEnd, nameFirst, nameAfter,
    name, item, routineId, formalCount, formalStart, opened, first, last, nextPos, modeEnd, mode, mark, parameter,
    slot, before, position, outerPosition, completed, routineCount, parameterCount, itemCount, itemStart, itemFunction,
    marked, markedKind, markedIdentity, markedBounds, markedName, formalName, onState, projectState, projectResult])

macro "signature_lookups" : tactic => `(tactic|
  simp only [Locals.set, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte])

/-- The right parenthesis exits before the semicolon read. A nonadvancing
semicolon returns the current metadata and the invalid frame. -/
theorem endParameter_meaning (calls : Calls) (procedures : ProcedureCalls) (backing : Backing)
    (store : Locals) (next : Continuation α) (returned : SignatureResult → α) (exited : Continuation α) :
    endParameter.eval calls.get procedures backing store (onState next)
      (fun out => returned (projectResult out)) (onState exited) =
    observeStep (store .source "text") (store .state "outer") (store .truth "completing") next returned exited
      (finishFormal (rawCalls calls procedures) (store .source "text") (store .number "before") (projectState store)) := by
  unfold endParameter finishFormal rawCalls
  signature_values
  signature_lookups
  simp only [decide_eq_true_eq]
  split <;> first | rfl | (split <;> rfl)

def observeStart (source : Source) (outer : ParserState) (completing : Bool) (loop finish : Continuation α)
    (returned : SignatureResult → α) : SignatureStart → α
  | .returned result => returned result
  | .ready state => finish source outer completing state
  | .loop state => loop source outer completing state

def afterEntry (loop finish : Continuation α) (store : Locals) : α :=
  let state := projectState store
  let opened := store .number "open"
  if opened = 0 then onState finish store else
    loop (store .source "text") (store .state "outer") (store .truth "completing")
      {state with header := {state.header with position := opened}}

/-- The declaration list computes the source name once. Completion starts
from the next stored routine; declaration starts a fresh routine record. -/
theorem entry_meaning (calls : Calls) (procedures : ProcedureCalls) (backing : Backing) (prior : Locals)
    (source : Source) (outer : ParserState) (info : PackageBindings.Metadata) (completing : Bool)
    (loop finish : Continuation α) (returned : SignatureResult → α) (exited : Locals → α) :
    entry.eval calls.get procedures backing
      (body.declarations.foldl (Declaration.eval calls.get) (inputLocals prior source outer info completing))
      (afterEntry loop finish) (fun store => returned (projectResult store)) exited =
    observeStart source outer completing loop finish returned
      (signatureStart (rawCalls calls procedures) source outer info completing) := by
  unfold body entry completeItem newItem signatureStart startSignatureBody rawCalls afterEntry inputLocals
  signature_values
  signature_lookups
  cases completing <;>
    simp only [Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', Bool.false_eq_true,
      bne_iff_ne, decide_eq_true_eq, ↓reduceIte, or_assoc] <;>
    repeat' first | rfl | split

end Silver.ApplicationPackageDeclarations.SignatureNative
