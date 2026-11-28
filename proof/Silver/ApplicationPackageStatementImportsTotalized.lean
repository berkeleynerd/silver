module

public import Silver.ApplicationPackageStatementImports

@[expose] public section

/-! As in PredicateBodyHelpers, imported native operations are partial on
their source contracts. These mathematical extensions preserve every call in
the declared domain. Outside it they are modeling artifacts, never replacement
executions or admission checks. The original native contracts, machine types
and GNATprove remain responsible for the source body's call-domain obligations.
Only primitive callbacks are extended; recursive native functions are retained. -/
namespace Silver.ApplicationPackageBodies.StatementImports
open Compose Compose.Expressions Predicate ApplicationPackages Recursive

set_option backward.dsimp.instances true

noncomputable def extend (domain : Prop) (original fallback : α) : α :=
  @ite _ domain (Classical.propDecidable domain) original fallback

theorem extend_native {domain : Prop} {original fallback : α} (valid : domain) :
    extend domain original fallback = original := by simp only [extend, valid, ↓reduceIte]

theorem extend_model {domain : Prop} {original fallback : α} (meaning : domain → original = fallback) :
    extend domain original fallback = fallback := by
  unfold extend
  split
  · exact meaning ‹_›
  · rfl

/-- All Statement token constants are fixed words or symbols. The raw import
also has its complete native enumeration equation in Libraries.token. -/
def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  ValidText text ∧ ValidCursor text position ∧ ValidToken token ∧ Adapter.FixedToken token

def TargetDomain (text : Source) (context : ParseContext) (position : Nat) : Prop :=
  ValidText text ∧ ValidCursor text position ∧ ApplicationPackageActual.ContextDomain text context

def ConditionDomain (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) : Prop :=
  ValidText text ∧ ValidCursor text position ∧ ∃ native : Predicate.Native.Context,
    native.model = context ∧ Predicate.Native.ValidContext text native ∧ Predicate.Native.ValidFlow native facts

def AttributeDomain (text : Source) (position : Nat) (names : ScalarExpression.Environment)
    (arrays : ArrayBindings.Table) (first after : Nat) : Prop :=
  ValidText text ∧ ValidCursor text position ∧ ScalarExpression.ValidEnvironment text names ∧
    ScalarExpression.ValidMask text first after ∧ ArrayBindings.ValidTable text arrays

def CountedDomain (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (first after : Nat) : Prop :=
  ConditionDomain text context position facts ∧ ScalarExpression.ValidMask text first after

def WidenDomain (context : ParseContext) (facts : ActiveFlow) : Prop :=
  facts.count = context.scalarNames.length ∧ context.scalarNames.length ≤ ScalarExpression.maxBindings

def JoinDomain (left right : ActiveFlow) : Prop :=
  left.count ≤ ScalarExpression.maxBindings ∧ left.count = right.count

def BodyTokenDomain (text : Source) (context : ParseContext) (scan : BodyScan) (token : ShellToken) : Prop :=
  ValidText text ∧ ValidToken token ∧ Adapter.FixedToken token ∧
    ∃ native : Predicate.Native.Context, native.model = context ∧ Predicate.Native.ValidContext text native ∧
      ScanDomain text native.model scan

namespace Libraries

noncomputable def interpreted (library : Libraries) (other : Statement.Calls) : Statement.Calls :=
  let original := library.calls other
  {original with
    takeToken := fun text position token => extend (TokenDomain text position token)
      (original.takeToken text position token) (tokenAfter text position token)
    skipAt := fun text position => extend (LoopNative.CursorDomain text position)
      (original.skipAt text position) (Compose.skipAt text position)
    nameAfter := fun text position => extend (LoopNative.CursorDomain text position)
      (original.nameAfter text position) (Compose.nameAfter text position)
    forbiddenName := fun text first after => extend (LoopNative.NameDomain text first after)
      (original.forbiddenName text first after) (Named.forbiddenName text first after)
    nameIs := fun text first after word => extend (LoopNative.WordDomain text first after word)
      (original.nameIs text first after word) (Named.nameIs text first after (word.toList.map Char.toNat))
    equalName := fun text first after otherFirst otherAfter =>
      extend (LoopNative.EqualNameDomain text first after otherFirst otherAfter)
        (original.equalName text first after otherFirst otherAfter) (Named.equalName text first after otherFirst otherAfter)
    readCondition := fun text context position facts => extend (ConditionDomain text context position facts)
      (original.readCondition text context position facts) (Predicate.readCondition text context position facts)
    joinInto := fun left right => extend (JoinDomain left right) (original.joinInto left right) (left.join right)
    arrayTarget := fun text context position => extend (TargetDomain text context position)
      (original.arrayTarget text context position) (Predicate.arrayTarget text context position)
    readArrayAttribute := fun text position names arrays first after range =>
      extend (AttributeDomain text position names arrays first after)
        (original.readArrayAttribute text position names arrays first after range)
        (ScalarExpression.ArrayAttributes.read text position names arrays first after range)
    readCountedBound := fun text context position facts first after =>
      extend (CountedDomain text context position facts first after)
        (original.readCountedBound text context position facts first after)
        (Predicate.readCountedBound text context position facts first after)
    widenInto := fun context facts => extend (WidenDomain context facts)
      (original.widenInto context facts) (facts.widen context.scalarNames)
    bodyToken := fun text context scan token => extend (BodyTokenDomain text context scan token)
      (original.bodyToken text context scan token) (Predicate.bodyToken text scan token)}

/-- The extension's identity on all native condition inputs, including failed
reads and unreachable paths. No successful condition is required. -/
theorem interpreted_condition_native (library : Libraries) (other : Statement.Calls)
    (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (valid : ConditionDomain text context position facts) :
    (library.interpreted other).readCondition text context position facts =
      (library.calls other).readCondition text context position facts := extend_native valid

theorem interpreted_token_native (library : Libraries) (other : Statement.Calls)
    (text : Source) (position : Nat) (token : ShellToken) (valid : TokenDomain text position token) :
    (library.interpreted other).takeToken text position token =
      (library.calls other).takeToken text position token := extend_native valid

theorem interpreted_counted_native (library : Libraries) (other : Statement.Calls)
    (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) (first after : Nat)
    (valid : CountedDomain text context position facts first after) :
    (library.interpreted other).readCountedBound text context position facts first after =
      (library.calls other).readCountedBound text context position facts first after := extend_native valid

theorem interpreted_attribute_native (library : Libraries) (other : Statement.Calls)
    (text : Source) (position : Nat) (names : ScalarExpression.Environment) (arrays : ArrayBindings.Table)
    (first after : Nat) (range : Bool) (valid : AttributeDomain text position names arrays first after) :
    (library.interpreted other).readArrayAttribute text position names arrays first after range =
      (library.calls other).readArrayAttribute text position names arrays first after range := extend_native valid

theorem interpreted_widen_native (library : Libraries) (other : Statement.Calls)
    (context : ParseContext) (facts : ActiveFlow) (valid : WidenDomain context facts) :
    (library.interpreted other).widenInto context facts =
      (library.calls other).widenInto context facts := extend_native valid

theorem interpreted_join_native (library : Libraries) (other : Statement.Calls)
    (left right : ActiveFlow) (valid : JoinDomain left right) :
    (library.interpreted other).joinInto left right = (library.calls other).joinInto left right := extend_native valid

theorem interpreted_bodyToken_native (library : Libraries) (other : Statement.Calls)
    (text : Source) (context : ParseContext) (scan : BodyScan) (token : ShellToken)
    (valid : BodyTokenDomain text context scan token) :
    (library.interpreted other).bodyToken text context scan token =
      (library.calls other).bodyToken text context scan token := extend_native valid

theorem interpreted_retains (library : Libraries) (other : Statement.Calls) :
    (library.interpreted other).applicationBasic = other.applicationBasic ∧
    (library.interpreted other).applicationTail = other.applicationTail ∧
    (library.interpreted other).sameName = other.sameName ∧
    (library.interpreted other).stateReads = other.stateReads ∧
    (library.interpreted other).validContext = other.validContext ∧
    (library.interpreted other).validBody = other.validBody := ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Primitive normalization is proved from original imported source equations.
The original recursive function values and runtime validity guards survive. -/
theorem interpreted_meaning (library : Libraries) (other : Statement.Calls) :
    library.interpreted other = nativeStatementReaders (library.calls other) := by
  dsimp only [interpreted, nativeStatementReaders, Statement.loopHeaderReaders]
  congr 1
  · funext text position token
    apply extend_model
    intro valid
    exact library.fixed_token other text valid.1 position valid.2.1 token valid.2.2.1 valid.2.2.2
  · funext text position
    apply extend_model
    intro valid
    exact library.skip other text valid.1 position valid.2
  · funext text position
    apply extend_model
    intro valid
    exact library.name other text valid.1 position valid.2
  · funext text first after
    apply extend_model
    intro valid
    exact library.forbidden other text valid.1 first after valid.2
  · funext text first after word
    apply extend_model
    intro valid
    exact library.name_is other text valid.1.1 first after valid.1.2 word valid.2.1 valid.2.2
  · funext text first after otherFirst otherAfter
    apply extend_model
    intro valid
    exact library.equal_name other text valid.1.1 first after otherFirst otherAfter valid.1.2 valid.2
  · funext text context position facts
    apply extend_model
    rintro ⟨valid, bounded, native, same, ready, flow⟩
    rw [← same]
    exact library.condition other text valid native ready position bounded facts flow
  · funext left right
    apply extend_model
    intro valid
    exact library.join other left right valid.1 valid.2
  · funext text context position
    apply extend_model
    rintro ⟨valid, bounded, native, same, ready⟩
    rw [← same]
    exact library.array_target other text valid native ready position bounded
  · funext text position names arrays first after range
    apply extend_model
    rintro ⟨valid, bounded, environment, mask, table⟩
    exact library.array_attribute other text valid position names arrays first after range bounded environment mask table
  · funext text context position facts first after
    apply extend_model
    rintro ⟨⟨valid, bounded, native, same, ready, flow⟩, mask⟩
    rw [← same]
    exact library.counted_bound other text valid native ready position facts first after bounded flow mask
  · funext context facts
    apply extend_model
    intro valid
    exact library.widen_into other context facts valid.1 valid.2
  · funext left right
    exact library.path_join other left right
  · funext text context scan token
    apply extend_model
    rintro ⟨valid, allowed, fixed, native, same, ready, scanValid⟩
    rw [← same]
    exact library.body_token other text valid native ready scan scanValid token allowed fixed

end Libraries
end Silver.ApplicationPackageBodies.StatementImports
