module

public import Silver.ApplicationPackageInheritedProjection
public import Silver.ApplicationPackageRecursiveGuards
public import Silver.PredicateLoopHelpers

@[expose] public section

/-! Original Statement primitive imports, on the complete inherited native
callee domains. The three recursive reader symbols and package effects are
kept explicit. Projection removes only native argument-name positions that
the mathematical ParseContext does not retain. -/
namespace Silver.ApplicationPackageBodies.StatementImports
open Compose Compose.Expressions Predicate ApplicationPackages Recursive

set_option backward.dsimp.instances true

structure Libraries where
  inherited : Inherited.Libraries
  lexical : Compose.Lexical.Meaning inherited.inherited.primitive

namespace Libraries

theorem loop_meaning (library : Libraries) : LoopNative.ImportsMeaning library.inherited.calls.loopImports :=
  LoopNative.ImportsMeaning.of_inherited library.inherited.source library.lexical
    library.inherited.definitions.loopScalarPrimitives library.inherited.definitions.loopScalarEquations
    library.inherited.definitions.loopLinks

noncomputable def arrayTarget (library : Libraries) (text : Source) (context : ParseContext) (position : Nat) : Nat :=
  Inherited.project text context 0
    (fun native => library.inherited.calls.loopImports.arrayTarget text native position)

noncomputable def countedBound (library : Libraries) (text : Source) (context : ParseContext)
    (position : Nat) (facts : ActiveFlow) (first after : Nat) : ScalarExpression.Result :=
  Inherited.project text context ScalarExpression.invalid
    (fun native => library.inherited.calls.loopImports.readScalar text native position facts first after)

/-- Widen_Into observes only the scalar table. Its exact native domain has no
text or argument-name validity requirement, so this projection retains that
larger domain rather than requesting an unrelated valid-context witness. -/
def scalarContext (context : ParseContext) : Predicate.Native.Context :=
  {names := [], dynamicFirst := 0, dynamicAfter := 0, scalarNames := context.scalarNames}

def widen (library : Libraries) (context : ParseContext) (facts : ActiveFlow) : ActiveFlow :=
  library.inherited.calls.loopImports.widen (scalarContext context) facts

noncomputable def calls (library : Libraries) (other : Statement.Calls) : Statement.Calls :=
  {other with
    takeToken := library.inherited.inherited.function .takeToken
    skipAt := library.inherited.inherited.function .skip
    nameAfter := library.inherited.inherited.function .nameAfter
    forbiddenName := library.inherited.inherited.primitive.forbidden
    nameIs := library.inherited.inherited.function .nameIs
    equalName := library.inherited.inherited.primitive.equal
    readCondition := library.inherited.projectedCondition
    joinInto := library.inherited.calls.joinInto
    arrayTarget := library.arrayTarget
    readArrayAttribute := library.inherited.calls.loopScalars.readArrayAttribute
    readCountedBound := library.countedBound
    widenInto := library.widen
    pathJoin := library.inherited.calls.loopImports.join
    bodyToken := library.inherited.projectedToken}

theorem token (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position)
    (token : ShellToken) (allowed : ValidToken token) :
    (library.calls other).takeToken text position token =
      fixedAfter text position (spelling token) (isWord token) :=
  interpreted_take _ library.inherited.source text valid position token bounded allowed

theorem fixed_token (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position)
    (token : ShellToken) (allowed : ValidToken token) (fixed : Adapter.FixedToken token) :
    (library.calls other).takeToken text position token = tokenAfter text position token :=
  (library.token other text valid position bounded token allowed).trans
    (Adapter.takeTokenModel_fixed text position token fixed)

theorem skip (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position) :
    (library.calls other).skipAt text position = Compose.skipAt text position :=
  interpreted_skip _ library.inherited.source text valid position bounded

theorem name (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position) :
    (library.calls other).nameAfter text position = Compose.nameAfter text position :=
  interpreted_name _ library.inherited.source text valid position bounded

theorem forbidden (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (first after : Nat) (span : ValidName text first after) :
    (library.calls other).forbiddenName text first after = Named.forbiddenName text first after :=
  library.lexical.forbidden text valid.1 valid.2 first after span.1 span.2.1 span.2.2

theorem name_is (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (first after : Nat) (span : ValidName text first after)
    (word : String) (positive : 0 < word.toList.length) (bounded : word.toList.length ≤ 16) :
    (library.calls other).nameIs text first after word =
      Named.nameIs text first after (word.toList.map Char.toNat) :=
  library.inherited.source.nameIs text valid first after word span positive bounded

theorem equal_name (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (first after otherFirst otherAfter : Nat)
    (left : ValidName text first after) (right : ValidName text otherFirst otherAfter) :
    (library.calls other).equalName text first after otherFirst otherAfter =
      Named.equalName text first after otherFirst otherAfter :=
  library.lexical.equal text valid.1 valid.2 first after otherFirst otherAfter
    left.1 left.2.1 left.2.2 right.1 right.2.1 right.2.2

theorem condition (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (position : Nat)
    (bounded : ValidCursor text position) (facts : ActiveFlow)
    (flow : Predicate.Native.ValidFlow native facts) :
    (library.calls other).readCondition text native.model position facts =
      Predicate.readCondition text native.model position facts :=
  library.inherited.projected_condition text valid native contextValid position bounded facts flow

theorem join (library : Libraries) (other : Statement.Calls) (left right : ActiveFlow)
    (capacity : left.count ≤ ScalarExpression.maxBindings) (same : left.count = right.count) :
    (library.calls other).joinInto left right = left.join right :=
  library.inherited.joinInto left right capacity same

theorem array_target (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (position : Nat)
    (bounded : ValidCursor text position) :
    (library.calls other).arrayTarget text native.model position =
      Predicate.arrayTarget text native.model position := by
  dsimp only [calls, arrayTarget]
  apply Inherited.project_eq text native contextValid
  intro chosen same ready
  rw [library.loop_meaning.arrayTarget text chosen position ⟨valid, ready, bounded⟩, same]

theorem array_attribute (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (position : Nat) (names : ScalarExpression.Environment)
    (arrays : ArrayBindings.Table) (first after : Nat) (range : Bool)
    (bounded : ValidCursor text position) (environment : ScalarExpression.ValidEnvironment text names)
    (mask : ScalarExpression.ValidMask text first after) (table : ArrayBindings.ValidTable text arrays) :
    (library.calls other).readArrayAttribute text position names arrays first after range =
      ScalarExpression.ArrayAttributes.read text position names arrays first after range :=
  ScalarExpression.Native.interpreted_arrayAttribute library.inherited.calls.loopScalars
    library.inherited.definitions.loopScalarPrimitives library.inherited.definitions.loopScalarEquations
    text valid position names arrays first after range bounded environment mask table

theorem counted_bound (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (position : Nat) (facts : ActiveFlow)
    (first after : Nat) (bounded : ValidCursor text position)
    (flow : Predicate.Native.ValidFlow native facts) (mask : ScalarExpression.ValidMask text first after) :
    (library.calls other).readCountedBound text native.model position facts first after =
      Predicate.readCountedBound text native.model position facts first after := by
  dsimp only [calls, countedBound]
  apply Inherited.project_eq text native contextValid
  intro chosen same ready
  rw [library.loop_meaning.readScalar text chosen position facts first after
    ⟨⟨valid, ready, ApplicationPackageActual.flow_transport same.symm flow⟩, bounded, mask⟩, same]

theorem widen_into (library : Libraries) (other : Statement.Calls) (context : ParseContext)
    (facts : ActiveFlow) (same : facts.count = context.scalarNames.length)
    (bounded : context.scalarNames.length ≤ ScalarExpression.maxBindings) :
    (library.calls other).widenInto context facts = facts.widen context.scalarNames :=
  library.loop_meaning.widen (scalarContext context) facts ⟨same, bounded⟩

theorem widen_native (library : Libraries) (native : Predicate.Native.Context) (facts : ActiveFlow)
    (domain : LoopNative.WidenDomain native facts) :
    library.widen native.model facts = library.inherited.calls.loopImports.widen native facts :=
  (library.loop_meaning.widen (scalarContext native.model) facts domain).trans
    (library.loop_meaning.widen native facts domain).symm

theorem path_join (library : Libraries) (other : Statement.Calls) (left right : PathFacts.Context) :
    (library.calls other).pathJoin left right = left.join right := library.loop_meaning.join left right

theorem body_token (library : Libraries) (other : Statement.Calls) (text : Source)
    (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (scan : BodyScan)
    (legal : ScanDomain text native.model scan) (token : ShellToken)
    (allowed : ValidToken token) (fixed : Adapter.FixedToken token) :
    (library.calls other).bodyToken text native.model scan token = Predicate.bodyToken text scan token :=
  library.inherited.projected_token text valid native contextValid scan
    ⟨legal.position, legal.controls, legal.path, legal.flow⟩ token allowed fixed

end Libraries
end Silver.ApplicationPackageBodies.StatementImports
