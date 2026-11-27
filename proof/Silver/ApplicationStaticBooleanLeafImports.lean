module

public import Silver.ApplicationPackageDeclarationsValueImports
public import Silver.StaticBooleanReaderDefinitions

@[expose] public section

/-! The static Boolean readers call the same checked lexical, scalar and
predicate libraries as object declarations. These are the original imported
calls, without a model fallback outside their native contracts. Their meaning
is derived on each callee's complete domain from the retained source equations. -/
namespace Silver.BooleanElaboration.Native.SourceImports
open Compose Compose.Expressions ApplicationPackageDeclarations

set_option backward.dsimp.instances true

def decodeChain : Predicate.Native.ChainKind → Chain
  | .noChain => none
  | .shortAnd => some .shortAnd
  | .shortOr => some .shortOr
  | .eagerAnd => some .eagerAnd
  | .eagerOr => some .eagerOr
  | .eagerXor => some .eagerXor

def encodeChain : Predicate.ChainKind → Predicate.Native.ChainKind
  | .shortAnd => .shortAnd
  | .shortOr => .shortOr
  | .eagerAnd => .eagerAnd
  | .eagerOr => .eagerOr
  | .eagerXor => .eagerXor

def ofObjects (library : ObjectLibraries) : Imports where
  take text position token := library.names.shared.composed.function .takeToken text position token.shell
  reference := library.scalar.readReference
  lookup := library.booleanSource.condition.booleanQualifiedLookup
  nameIs := library.names.shared.composed.function .nameIs
  booleanAtom text frame position := library.booleanSource.condition.booleanAtom text
    (BooleanDeclarationNative.Libraries.toNative (library.booleanSource.calls.contextOf ⟨frame, false, false⟩)) position
  scalar text position names := library.scalar.readExpression text position names 0 0 true {} [] true .allElements
  comparison := library.booleanSource.condition.comparison
  chain text position := decodeChain (library.booleanSource.condition.chainToken text position)
  chainAfter text position operator := match operator with
    | none => 0
    | some op => library.booleanSource.condition.chainAfter text position (encodeChain op)

/-- Each premise is an actual leaf contract domain. The reader-domain proof
will establish these premises at every call, including unsuccessful reads. -/
structure Meaning (imports : Imports) : Prop where
  take : ∀ text, ValidText text → ∀ position token, ValidCursor text position →
    imports.take text position token = modelImports.take text position token
  reference : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    imports.reference text position = modelImports.reference text position
  lookup : ∀ text, ValidText text → ∀ names first after qualifierFirst qualifierAfter,
    BooleanBindings.ValidEnvironment text names → ValidCursor text first → ValidCursor text after →
    QualifiedNames.ValidSpan text qualifierFirst qualifierAfter →
    imports.lookup text names first after qualifierFirst qualifierAfter =
      modelImports.lookup text names first after qualifierFirst qualifierAfter
  nameIs : ∀ text, ValidText text → ∀ first after spelling, ValidName text first after →
    0 < spelling.toList.length → spelling.toList.length ≤ 16 →
    imports.nameIs text first after spelling = modelImports.nameIs text first after spelling
  booleanAtom : ∀ text frame position, SourceChecks.Domain text frame position →
    imports.booleanAtom text frame position = modelImports.booleanAtom text frame position
  scalar : ∀ text, ValidText text → ∀ position names, ValidCursor text position →
    ScalarExpression.ValidEnvironment text names →
    imports.scalar text position names = modelImports.scalar text position names
  comparison : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    imports.comparison text position = modelImports.comparison text position
  chain : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    imports.chain text position = modelImports.chain text position
  chainAfter : ∀ text, ValidText text → ∀ position operator, ValidCursor text position →
    imports.chainAfter text position operator = modelImports.chainAfter text position operator

private theorem domain_of_holds (left right : StateDomain) (same : left.holds = right.holds) : left = right := by
  cases left
  cases right
  cases same
  rfl

private theorem exact_domain (library : ObjectLibraries) :
    library.names.shared.domain = Predicate.OuterReadiness.domain := by
  apply domain_of_holds
  funext text state
  apply propext
  rw [library.names.header.domain.state]
  exact ⟨fun original => ⟨original.base, original.ready, original.bounds⟩,
    fun original => ⟨original.base, original.ready, original.bounds⟩⟩

private theorem helpers (library : ObjectLibraries) :
    Predicate.Native.HelperMeaning library.booleanSource.condition := by
  apply library.booleanSource.source.meaning
  rw [← exact_domain library]
  exact library.names.shared.inherited

theorem decode_chain_model (text : Source) (position : Nat) :
    decodeChain (Predicate.Native.chainTokenModel text position) = Predicate.chainOperator text position := by
  unfold Predicate.Native.chainTokenModel Predicate.chainOperator
  split
  · split <;> rfl
  · split
    · split <;> rfl
    · split <;> rfl

theorem ofObjects_meaning (library : ObjectLibraries) : Meaning (ofObjects library) where
  take text valid position token bounded := by
    change library.names.shared.composed.function .takeToken text position token.shell = _
    rw [interpreted_take _ library.names.shared.inherited text valid position token.shell bounded
      (by cases token <;> simp [ValidToken, allTokens, Token.shell])]
    cases token <;> rfl
  reference text valid position bounded :=
    ScalarExpression.SourceBridge.interpreted_readReference library.scalar library.scalarSource
      text valid position bounded
  lookup text valid names first after qualifierFirst qualifierAfter environment firstBound afterBound qualifier :=
    (helpers library).booleanQualifiedLookup text valid names first after qualifierFirst qualifierAfter
      environment firstBound afterBound qualifier
  nameIs text valid first after spelling name positive bounded :=
    library.names.shared.inherited.nameIs text valid first after spelling name positive bounded
  booleanAtom text frame position domain := by
    change library.booleanSource.condition.booleanAtom text
      (BooleanDeclarationNative.Libraries.toNative (library.booleanSource.calls.contextOf ⟨frame, false, false⟩))
      position = _
    rw [library.booleanSource.links.context _ domain.frameDomain.base.2.2.2.2.2.1.1]
    change library.booleanSource.condition.booleanAtom text (Predicate.Adapter.contextOf ⟨frame, false, false⟩)
      position = _
    exact Predicate.Native.booleanAtom_meaning (helpers library) library.booleanSource.definitions
      text domain.textValid _ (Predicate.Adapter.context_valid text ⟨frame, false, false⟩ domain.frameDomain)
      position domain.cursor
  scalar text valid position names bounded environment := by
    have reading := ScalarExpression.SourceBridge.interpreted_readExpression_table library.scalar library.scalarSource
      text valid position names 0 0 true {} [] true .allElements bounded environment (.inl ⟨rfl, rfl⟩)
      (by simp [ArrayBindings.ValidTable, ArrayBindings.ValidTypes, ArrayBindings.maxBindings, ArrayBindings.maxTypes])
      (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])
    exact reading.trans (ScalarExpression.Native.table_read_empty text _ _ _ _ true [] true .allElements)
  comparison text valid position bounded :=
    Predicate.Native.comparison_meaning (helpers library) library.booleanSource.definitions text valid position bounded
  chain text valid position bounded := by
    change decodeChain (library.booleanSource.condition.chainToken text position) = Predicate.chainOperator text position
    rw [Predicate.Native.chainToken_meaning (helpers library) library.booleanSource.definitions text valid position bounded]
    exact decode_chain_model text position
  chainAfter text valid position operator bounded := by
    cases operator with
    | none => rfl
    | some op =>
      change library.booleanSource.condition.chainAfter text position (encodeChain op) = Predicate.chainAfter text position op
      rw [Predicate.Native.chainAfter_meaning (helpers library) library.booleanSource.definitions text valid position
        (encodeChain op) bounded (by cases op <;> rfl)]
      cases op <;> rfl

end Silver.BooleanElaboration.Native.SourceImports
