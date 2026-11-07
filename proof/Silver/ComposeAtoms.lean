module

public import Silver.ComposeCharacterReading
public import Silver.StringExecution

@[expose] public section

namespace Silver.Compose
open Named Bindings

def slicePrefix (text : Source) (position : Nat) (names : BindingEnvironment) : Prop :=
  lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 ∧
    ((names.get (lookupName text names (skipAt text position) (nameAfter text (skipAt text position)))).getD {}).isCharacter = false ∧
    fixedAfter text (nameAfter text (skipAt text position)) "(" false ≠ 0

def stringReference (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) : Prop :=
  lookupName text names (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 ∧
    ((names.get (lookupName text names (skipAt text position) (nameAfter text (skipAt text position)))).getD {}).isCharacter = false ∧
    ScalarExpression.lookup text scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0

def stringReferenceValue (after index : Nat) (info : BindingInfo) : ValueResult :=
  ⟨after, info.valueFirst, info.staticLength, info.staticLength, info.dynamic, true, false, index,
    1, .singleton info.firstIndex, if info.dynamic then ⟨0, maxSourceLength⟩ else .singleton info.lastIndex⟩

inductive ValueAtCore (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    Nat → Operand → ValueResult → Prop
  | literal {position after : Nat} {bytes : Source} :
      skipAt text position ≠ 0 → skipAt text position ≤ text.length →
      Cursor.byteAt text (skipAt text position) = 34 →
      Output.LiteralAt text (skipAt text position + 1) bytes after →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.literal bytes)
        ⟨after, skipAt text position + 1, bytes.length, bytes.length, false, false, false, 0,
          1, .singleton 1, .singleton bytes.length⟩
  | reference {position after index : Nat} {name : Source} {info : BindingInfo} :
      skipAt text position ≠ 0 →
      IdentifierAt text (skipAt text position) name after →
      lookupName text names (skipAt text position) after = index → index ≠ 0 →
      ScalarExpression.lookup text scalarNames (skipAt text position) after = 0 →
      names.get index = some info → info.isCharacter = false →
      fixedAfter text after "(" false = 0 →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.reference index)
        (stringReferenceValue after index info)
  | slice {position : Nat} {info : BindingInfo} {lower upper : Integer.Expr} :
      ¬ QuotedValueAt text position → slicePrefix text position names →
      IndexedReading text names scalarNames arrays initials elaborating false position info lower upper →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position
        (.slice (indexedParts text position names scalarNames arrays initials elaborating false).target info.firstIndex lower upper)
        (indexedValue (indexedParts text position names scalarNames arrays initials elaborating false) false)
  | image {position : Nat} {expression : Integer.Expr} :
      ¬ QuotedValueAt text position → ¬ slicePrefix text position names →
      ¬ stringReference text position names scalarNames →
      ImageReading text names scalarNames integerHidden position expression arrays initials elaborating →
      ValueAtCore text names scalarNames integerHidden arrays initials elaborating position (.image expression)
        (imageValue (imageParts text position scalarNames arrays initials elaborating))

abbrev ValueAt (text : Source) (names : BindingEnvironment) (position : Nat)
    (value : Operand) (result : ValueResult) (scalarNames : ScalarExpression.Environment := [])
    (integerHidden : Bool := false) (arrays : ArrayBindings.Metadata := [])
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) : Prop :=
  ValueAtCore text names scalarNames integerHidden arrays initials elaborating position value result

theorem noQuotedValue {text : Source} {position : Nat} (absent : ¬ QuotedValueAt text position) :
    (literalAt text (skipAt text position)).after = 0 := by
  have missing : ¬ (literalAt text (skipAt text position)).after ≠ 0 :=
    fun found => absent ((quotedValue_iff text position).mpr found)
  omega

theorem value_complete {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment}
    {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat} {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names = result := by
  cases parsed with
  | literal positive bound quote parsed =>
      rename_i after bytes
      have nonzero : after ≠ 0 := by have := Output.literalAt_bounds parsed; omega
      simp [valueAt, literalAt, positive, bound, quote, Output.literalAt_complete parsed,
        Guarded.literalLength_decodes parsed, nonzero]
  | reference positive parsed selected nonzero unmasked present typed noParen =>
      simp [valueAt, literalAt, identifier_not_quote parsed, nameAfter, positive,
        identifierEnd_complete parsed, selected, nonzero, unmasked, present, typed, noParen,
        invalidValue, stringReferenceValue]
  | slice noLiteral presentSlice parsed =>
      unfold slicePrefix at presentSlice
      simp only [valueAt, noQuotedValue noLiteral, ne_eq, not_true_eq_false, ↓reduceIte]
      rw [ite_eq_left presentSlice]
      exact indexed_complete parsed
  | image noLiteral noSlice noReference parsed =>
      unfold slicePrefix at noSlice
      unfold stringReference at noReference
      simp only [valueAt, noQuotedValue noLiteral, ne_eq, not_true_eq_false, ↓reduceIte]
      rw [ite_eq_right noSlice, ite_eq_right noReference]
      exact image_complete parsed

theorem value_sound (text : Source) (position : Nat) (names : BindingEnvironment)
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    (accepted : (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names).after ≠ 0) :
    ∃ value, ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value
      (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names) := by
  by_cases quoted : (literalAt text (skipAt text position)).after ≠ 0
  · obtain ⟨bytes, after, positive, bound, quote, parsed⟩ := (quotedValue_iff text position).mpr quoted
    have source : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden)
        (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position (.literal bytes)
        ⟨after, skipAt text position + 1, bytes.length, bytes.length, false, false, false, 0,
          1, .singleton 1, .singleton bytes.length⟩ := .literal positive bound quote parsed
    exact ⟨_, (value_complete source).symm ▸ source⟩
  · have noLiteral : ¬ QuotedValueAt text position := fun present => quoted ((quotedValue_iff text position).mp present)
    by_cases sliced : slicePrefix text position names
    · have raw : (indexedAt text position names scalarNames arrays initials elaborating false).after ≠ 0 := by
        unfold slicePrefix at sliced
        simp only [valueAt, quoted, ↓reduceIte] at accepted
        rwa [ite_eq_left sliced] at accepted
      obtain ⟨info, lower, upper, parsed⟩ := indexed_sound raw
      have source : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden)
          (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position
          (.slice (indexedParts text position names scalarNames arrays initials elaborating false).target info.firstIndex lower upper)
          (indexedValue (indexedParts text position names scalarNames arrays initials elaborating false) false) :=
        .slice noLiteral sliced parsed
      exact ⟨_, (value_complete source).symm ▸ source⟩
    · by_cases referenced : stringReference text position names scalarNames
      · obtain ⟨positive, advanced, info, present, _⟩ := lookupName_found referenced.1
        have afterPositive : nameAfter text (skipAt text position) ≠ 0 := by omega
        have nameAccepted : identifierEnd text (skipAt text position) ≠ 0 := by
          simpa [nameAfter, positive] using afterPositive
        obtain ⟨name, parsed⟩ := identifierEnd_sound text _ nameAccepted
        have afterSame : nameAfter text (skipAt text position) = identifierEnd text (skipAt text position) := by
          simp [nameAfter, positive]
        have typed : info.isCharacter = false := by simpa [present] using referenced.2.1
        have noParen : fixedAfter text (nameAfter text (skipAt text position)) "(" false = 0 := by
          by_cases zero : fixedAfter text (nameAfter text (skipAt text position)) "(" false = 0
          · exact zero
          · exact False.elim (sliced ⟨referenced.1, referenced.2.1, zero⟩)
        have source : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden)
            (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position
            (.reference (lookupName text names (skipAt text position) (nameAfter text (skipAt text position))))
            (stringReferenceValue (nameAfter text (skipAt text position))
              (lookupName text names (skipAt text position) (nameAfter text (skipAt text position))) info) :=
          .reference positive (by simpa [afterSame] using parsed) rfl referenced.1 referenced.2.2 present typed noParen
        exact ⟨_, (value_complete source).symm ▸ source⟩
      · have raw : (imageAt text position names scalarNames integerHidden arrays initials elaborating).after ≠ 0 := by
          unfold slicePrefix at sliced
          unfold stringReference at referenced
          simpa only [valueAt, quoted, ↓reduceIte, sliced, referenced] using accepted
        obtain ⟨expression, parsed⟩ := image_sound raw
        have source : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden)
            (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position (.image expression)
            (imageValue (imageParts text position scalarNames arrays initials elaborating)) :=
          .image noLiteral sliced referenced parsed
        exact ⟨_, (value_complete source).symm ▸ source⟩

def ValueResult.bound (result : ValueResult) : Bindings.Bound :=
  if result.dynamicSeen then .argument else .fixed result.staticLength

theorem value_inferLength {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult} (normal : NamesNormal names)
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.inferLength names.shape (ArrayBindings.integerRanges arrays initials elaborating (ScalarExpression.ranges scalarNames)) = some result.lengthSummary := by
  cases parsed with
  | literal => rfl
  | reference positive identifier selected nonzero unmasked present typed noParen =>
      rename_i after index name info
      have zero := normal _ _ present
      cases dynamic : info.dynamic
      · simp [Operand.inferLength, Bindings.Value.infer, Bindings.BindingEnvironment.shape,
          present, BindingInfo.cell, Bindings.BindingInfo.bound, dynamic,
          LengthSummary.ofExact, Bound.summary, ValueResult.lengthSummary, stringReferenceValue]
      · simp [Operand.inferLength, Bindings.Value.infer, Bindings.BindingEnvironment.shape,
          present, BindingInfo.cell, Bindings.BindingInfo.bound, dynamic, zero dynamic,
          LengthSummary.ofExact, Bound.summary, ValueResult.lengthSummary, stringReferenceValue]
  | slice _ _ parsed =>
      simp only [Operand.inferLength, Value.extraRange, fixedLengths_of_info parsed.selected parsed.fixed,
        parsed.lowerSource.inferred, (parsed.upperSource rfl).inferred, Option.bind_some,
        slice_check normal parsed, ↓reduceIte, Option.map_some, indexedValue, Bool.false_eq_true,
        ValueResult.lengthSummary]
  | image _ _ _ parsed =>
      simp only [Operand.inferLength, parsed.scalar.inferred, Option.map_some,
        ValueResult.lengthSummary, imageValue, LengthSummary.ofImage]
      split <;> rfl

theorem value_literals {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.PrintableLiterals := by
  cases parsed with
  | literal _ _ _ parsed => exact (Output.literalAt_bounds parsed).2.2
  | reference | image | slice => trivial

def Operand.sourceOperands : Operand → Nat
  | .slice _ _ lower upper => ScalarExpression.leaves lower + ScalarExpression.leaves upper + 1
  | .character expression => expression.sourceOperands
  | .replace _ _ index replacement => ScalarExpression.leaves index + replacement.sourceOperands + 1
  | _ => 1

def Expression.sourceOperands (expression : Expression) : Nat :=
  (expression.map Operand.sourceOperands).sum

theorem Operand.sourceOperands_positive (atom : Operand) : 0 < atom.sourceOperands := by
  cases atom with
  | literal | argument | reference | image | slice | replace => simp [sourceOperands]
  | character expression =>
      induction expression <;> simp_all [sourceOperands, Character.Expr.sourceOperands]

theorem Expression.sourceOperands_append (left right : Expression) :
    (left ++ right).sourceOperands = left.sourceOperands + right.sourceOperands := by
  simp [sourceOperands, List.sum_append]

theorem Expression.length_le_sourceOperands (expression : Expression) :
    expression.length ≤ expression.sourceOperands := by
  induction expression with
  | nil => exact Nat.le_refl _
  | cons head tail ih =>
      have positive := Operand.sourceOperands_positive head
      simp only [sourceOperands, List.map_cons, List.sum_cons, List.length_cons]
      change tail.length ≤ (tail.map Operand.sourceOperands).sum at ih
      omega

theorem value_operands {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
      (initials := initials) (elaborating := elaborating) text names position value result) :
    result.operands = value.sourceOperands ∧ 0 < result.operands ∧ result.operands ≤ maxExpressionOperands := by
  cases parsed with
  | literal | reference | image => exact ⟨rfl, Nat.zero_lt_succ _, by change 1 ≤ 64; omega⟩
  | slice _ _ source =>
      have lower := source.lowerSource.operands
      have upper := (source.upperSource rfl).operands
      have count := (source.sliceBounds rfl).2.1
      simp only [indexedValue, Bool.false_eq_true, ↓reduceIte, Operand.sourceOperands]
      exact ⟨by omega, by omega, by omega⟩

theorem value_readable {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
      (initials := initials) (elaborating := elaborating) text names position value result) :
    value.StringReadable names.shape := by
  cases parsed with
  | literal | image => trivial
  | reference positive identifier selected nonzero unmasked present typed noParen =>
      rename_i after index name info
      exact ⟨info.cell, by simp [BindingEnvironment.shape, present]⟩
  | slice _ _ source => exact ⟨_, fixedLengths_of_info source.selected source.fixed⟩

theorem value_unique {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {left right : Operand} {leftResult rightResult : ValueResult}
    (first : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position left leftResult)
    (second : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position right rightResult) :
    left = right ∧ leftResult = rightResult := by
  have results := (value_complete first).symm.trans (value_complete second)
  refine ⟨?_, results⟩
  cases first with
  | literal positive bound quote parsed =>
      have quoted : QuotedValueAt text position := ⟨_, _, positive, bound, quote, parsed⟩
      cases second with
      | literal _ _ _ other => exact congrArg Bindings.Value.literal (Output.literalAt_unique parsed other).1
      | reference _ name => exact False.elim (identifier_not_quote name quote)
      | slice noLiteral | image noLiteral => exact False.elim (noLiteral quoted)
  | reference positive name selected nonzero unmasked present typed noParen =>
      have noSlice : ¬ slicePrefix text position names := by
        simp [slicePrefix, nameAfter, positive, identifierEnd_complete name, noParen]
      have named : stringReference text position names scalarNames := by
        simp [stringReference, nameAfter, positive, identifierEnd_complete name,
          selected, nonzero, unmasked, present, typed]
      cases second with
      | literal _ _ quote _ => exact False.elim (identifier_not_quote name quote)
      | reference => exact congrArg Bindings.Value.reference (congrArg ValueResult.reference results)
      | slice _ yesSlice => exact False.elim (noSlice yesSlice)
      | image _ _ noReference => exact False.elim (noReference named)
  | slice noLiteral yesSlice parsed =>
      cases second with
      | literal positive bound quote source => exact False.elim (noLiteral ⟨_, _, positive, bound, quote, source⟩)
      | reference positive name _ _ _ _ _ noParen =>
          have absent : ¬ slicePrefix text position names := by
            simp [slicePrefix, nameAfter, positive, identifierEnd_complete name, noParen]
          exact False.elim (absent yesSlice)
      | slice _ _ other =>
          obtain ⟨sameInfo, sameLower, sameUpper⟩ := indexed_unique parsed other
          have sameUpper' := sameUpper rfl
          cases sameInfo
          cases sameLower
          cases sameUpper'
          rfl
      | image _ noSlice => exact False.elim (noSlice yesSlice)
  | image noLiteral noSlice noReference parsed =>
      cases second with
      | literal positive bound quote source => exact False.elim (noLiteral ⟨_, _, positive, bound, quote, source⟩)
      | reference positive name selected nonzero unmasked present typed noParen =>
          apply False.elim
          apply noReference
          simp [stringReference, nameAfter, positive, identifierEnd_complete name,
            selected, nonzero, unmasked, present, typed]
      | slice _ yesSlice => exact False.elim (noSlice yesSlice)
      | image _ _ _ other => exact congrArg Bindings.Value.image (ScalarExpression.at_unique parsed.scalar other.scalar).1

end Silver.Compose
