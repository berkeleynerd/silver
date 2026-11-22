module

public import Silver.ScalarExpressionBounds
public import Silver.ArrayBindingsMetadata

@[expose] public section

/-! Static shape queries preserve the constrained Integer-array bounds. Their
prefix resolution includes the complete named-type table, independently of
whether any object or initializer cells exist. -/
namespace Silver.ScalarExpression.ArrayAttributes

inductive Query
  | first | last | length | range
  deriving DecidableEq, Repr

def Query.bounds (query : Query) (shape : Integer.Interval) : Integer.Interval :=
  match query with
  | .first => .singleton shape.lower
  | .last => .singleton shape.upper
  | .length => .singleton (shape.upper - shape.lower + 1)
  | .range => shape

def Query.word : Query → Source
  | .first => [102, 105, 114, 115, 116]
  | .last => [108, 97, 115, 116]
  | .length => [108, 101, 110, 103, 116, 104]
  | .range => [114, 97, 110, 103, 101]

def ShapeValid (bounds : Integer.Interval) : Prop :=
  bounds.Bounded ∧ bounds.lower ≤ bounds.upper ∧
    (bounds.upper - bounds.lower + 1).toNat ≤ ArrayBindings.maxElements

theorem Query.bounds_bounded (query : Query) {shape : Integer.Interval}
    (valid : ShapeValid shape) : (query.bounds shape).Bounded := by
  rcases valid with ⟨bounded, nonempty, capacity⟩
  cases query with
  | first => exact ⟨bounded.1, bounded.1⟩
  | last => exact ⟨bounded.2, bounded.2⟩
  | length =>
      have safe := NamedArrayParameters.Attribute.inRange .length shape bounded nonempty capacity
      exact ⟨safe, safe⟩
  | range => exact bounded

theorem Query.bounds_nonempty (query : Query) {shape : Integer.Interval}
    (valid : ShapeValid shape) :
    (query.bounds shape).lower ≤ (query.bounds shape).upper := by
  have ordered := valid.2.1
  cases query <;> simp only [Query.bounds, Integer.Interval.singleton] <;> omega

theorem Query.scalar_singleton (query : Query) (scalar : query ≠ .range)
    (shape : Integer.Interval) :
    query.bounds shape = .singleton (query.bounds shape).lower := by
  cases query <;> first | rfl | contradiction

def selectedShape (text : Source) (arrays : ArrayBindings.Table)
    (first after : Nat) : Option Integer.Interval :=
  let target := ArrayBindings.lookup text arrays.items first after
  let typeId := ArrayBindings.lookupType text arrays.types first after
  if target ≠ 0 then
    if (ArrayBindings.binding arrays.items target).isBoolean then none
    else some (ArrayBindings.binding arrays.items target).bounds
  else if typeId ≠ 0 then some (ArrayBindings.arrayType arrays.types typeId).bounds
  else none

theorem selectedShape_valid {text : Source} {arrays : ArrayBindings.Table}
    (valid : ArrayBindings.ValidTable text arrays) {first after : Nat}
    {shape : Integer.Interval} (selected : selectedShape text arrays first after = some shape) :
    ShapeValid shape := by
  unfold selectedShape at selected
  dsimp only at selected
  split at selected
  · rename_i present
    split at selected
    · cases selected
    · cases selected
      have item := valid.binding_valid (by omega)
        (ArrayBindings.lookup_bound text arrays.items first after)
      exact ⟨item.2.1.1.1, item.2.1.1.2.1, item.2.1.length_bound⟩
  · split at selected
    · rename_i present
      cases selected
      have item := valid.1.type_valid (by omega)
        (ArrayBindings.lookupType_bound text arrays.types first after)
      exact ⟨item.2.1, item.2.2.1, item.2.length_bound⟩
    · cases selected

def selectedQuery (text : Source) (first after : Nat) (rangeQuery : Bool) : Option Query :=
  if rangeQuery then
    if Named.nameIs text first after Query.range.word then some .range else none
  else if Named.nameIs text first after Query.first.word then some .first
  else if Named.nameIs text first after Query.last.word then some .last
  else if Named.nameIs text first after Query.length.word then some .length
  else none

theorem selectedQuery_scalar {text : Source} {first after : Nat} {query : Query}
    (selected : selectedQuery text first after false = some query) : query ≠ .range := by
  simp only [selectedQuery, Bool.false_eq_true, ↓reduceIte] at selected
  repeat' first | split at selected | cases selected
  all_goals decide

theorem selectedQuery_range {text : Source} {first after : Nat} {query : Query}
    (selected : selectedQuery text first after true = some query) : query = .range := by
  simp only [selectedQuery, ↓reduceIte] at selected
  split at selected <;> cases selected
  rfl

structure ParsedQuery where
  after : Nat
  shape : Integer.Interval
  query : Query
  deriving DecidableEq, Repr

def ParsedQuery.result (parsed : ParsedQuery) : Result :=
  ⟨parsed.after, parsed.query.bounds parsed.shape, 1, true⟩

def parse (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat := 0)
    (rangeQuery : Bool := false) : Option ParsedQuery :=
  let first := skip text position
  let after := nameAfter text first
  let attributeFirst := skip text (symbol text after 39)
  let attributeAfter := nameAfter text attributeFirst
  if first = 0 ∨ after ≤ first ∨ attributeFirst = 0 ∨ attributeAfter ≤ attributeFirst ∨
      lookup text names first after ≠ 0 ∨
      (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter first after = true) then none
  else do
    let shape ← selectedShape text arrays first after
    let query ← selectedQuery text attributeFirst attributeAfter rangeQuery
    some ⟨attributeAfter, shape, query⟩

def read (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat := 0)
    (rangeQuery : Bool := false) : Result :=
  match parse text position names arrays maskFirst maskAfter rangeQuery with
  | none => invalid
  | some parsed => parsed.result

theorem parse_shape {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {rangeQuery : Bool}
    {parsed : ParsedQuery} (valid : ArrayBindings.ValidTable text arrays)
    (found : parse text position names arrays maskFirst maskAfter rangeQuery = some parsed) :
    ShapeValid parsed.shape := by
  unfold parse at found
  dsimp only at found
  split at found
  · cases found
  · change (Option.bind _ _) = some parsed at found
    obtain ⟨shape, selected, found⟩ := Option.bind_eq_some_iff.mp found
    change (Option.bind _ _) = some parsed at found
    obtain ⟨query, _, same⟩ := Option.bind_eq_some_iff.mp found
    cases same
    exact selectedShape_valid valid selected

theorem parse_scalar {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {parsed : ParsedQuery}
    (found : parse text position names arrays maskFirst maskAfter false = some parsed) :
    parsed.query ≠ .range := by
  unfold parse at found
  dsimp only at found
  split at found
  · cases found
  · change (Option.bind _ _) = some parsed at found
    obtain ⟨shape, _, found⟩ := Option.bind_eq_some_iff.mp found
    change (Option.bind _ _) = some parsed at found
    obtain ⟨query, selected, same⟩ := Option.bind_eq_some_iff.mp found
    cases same
    exact selectedQuery_scalar selected

theorem parse_result_safe {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {rangeQuery : Bool}
    {parsed : ParsedQuery} (valid : ArrayBindings.ValidTable text arrays)
    (found : parse text position names arrays maskFirst maskAfter rangeQuery = some parsed) :
    parsed.result.bounds.Bounded ∧ parsed.result.bounds.lower ≤ parsed.result.bounds.upper ∧
      parsed.result.operands = 1 ∧ parsed.result.isStatic = true := by
  have shape := parse_shape valid found
  exact ⟨parsed.query.bounds_bounded shape, parsed.query.bounds_nonempty shape, rfl, rfl⟩

theorem nameAfter_bounds {text : Source} {position : Nat}
    (found : nameAfter text position ≠ 0) :
    position < nameAfter text position ∧ nameAfter text position ≤ text.length + 1 := by
  have positive : position ≠ 0 := by intro zero; simp [nameAfter, zero] at found
  simpa only [nameAfter, positive, ↓reduceIte] using
    Named.identifierEnd_bounds text position (by simpa [nameAfter, positive] using found)

theorem parse_bounds {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {rangeQuery : Bool}
    {parsed : ParsedQuery} (positionBound : position ≤ text.length + 1)
    (found : parse text position names arrays maskFirst maskAfter rangeQuery = some parsed) :
    position < parsed.after ∧ parsed.after ≤ text.length + 1 := by
  unfold parse at found
  dsimp only at found
  split at found
  · cases found
  · rename_i header
    have first := skip_bounds text position positionBound
    have prefixBounds := nameAfter_bounds
      (show nameAfter text (skip text position) ≠ 0 by omega)
    have apostrophe : symbol text (nameAfter text (skip text position)) 39 ≠ 0 := by
      intro zero
      have absent : skip text (symbol text (nameAfter text (skip text position)) 39) = 0 :=
        by rw [zero]; rfl
      exact header (Or.inr (Or.inr (Or.inl absent)))
    have separator := symbol_bounds prefixBounds.2 apostrophe
    have attributeBounds := skip_bounds text (symbol text (nameAfter text (skip text position)) 39) separator.2
    have ending := nameAfter_bounds
      (show nameAfter text (skip text (symbol text (nameAfter text (skip text position)) 39)) ≠ 0 by omega)
    change (Option.bind _ _) = some parsed at found
    obtain ⟨shape, _, found⟩ := Option.bind_eq_some_iff.mp found
    change (Option.bind _ _) = some parsed at found
    obtain ⟨query, _, same⟩ := Option.bind_eq_some_iff.mp found
    cases same
    dsimp only
    exact ⟨by omega, ending.2⟩

theorem read_contract {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {rangeQuery : Bool}
    (positionBound : position ≤ text.length + 1) (valid : ArrayBindings.ValidTable text arrays) :
    let result := read text position names arrays maskFirst maskAfter rangeQuery
    result.after = 0 ∨ (position < result.after ∧ result.after ≤ text.length + 1 ∧
      result.bounds.Bounded ∧ result.bounds.lower ≤ result.bounds.upper ∧
      result.operands = 1 ∧ result.isStatic = true) := by
  unfold read
  cases found : parse text position names arrays maskFirst maskAfter rangeQuery with
  | none => exact Or.inl rfl
  | some parsed =>
      have cursor := parse_bounds positionBound found
      have safe := parse_result_safe valid found
      exact Or.inr ⟨cursor.1, cursor.2, safe⟩

end Silver.ScalarExpression.ArrayAttributes
