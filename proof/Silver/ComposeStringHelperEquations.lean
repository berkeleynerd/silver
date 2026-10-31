module

public import Silver.ComposeCoreHelperEquations
public import Silver.ComposeStringEquations
public import Silver.ComposeNativeRecordBounds
public import Silver.ComposeArrayNativeBounds
public import Silver.ComposeCharacterBounds

@[expose] public section

namespace Silver.Compose.Expressions
variable {domain : StateDomain}
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true
set_option linter.unusedSimpArgs false
attribute [local irreducible] ScalarExpression.read

private theorem toNat_max_zero (value : Int) : (max 0 value).toNat = value.toNat := by omega

private theorem max_capacity (value : Int) : (max 0 value > (maxSourceLength : Int)) ↔
    value.toNat > maxSourceLength := by omega

@[simp] theorem interpreted_symbol (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (word : String)
    (bound : ValidCursor text position) (tokenValid : ValidToken (.symbol word)) :
    calls.function .takeToken text position (.symbol word) = fixedAfter text position word false :=
  interpreted_take calls equations text valid position (.symbol word) bound tokenValid

@[simp] theorem interpreted_indexed (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating element : Bool)
    (bound : ValidCursor text position) (namesValid : NativeNames text names)
    (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) :
    calls.function .indexed text position names scalarNames arrays initials elaborating element =
      indexedAt text position names scalarNames arrays initials elaborating element := by
  let first := skipAt text position
  let after := nameAfter text first
  let start := fixedAfter text after "(" false
  let low := ScalarExpression.read text start scalarNames 0 0 true arrays initials elaborating
  let highStart := fixedAfter text low.after ".." false
  let high := ScalarExpression.read text highStart scalarNames 0 0 true arrays initials elaborating
  have bf : ValidCursor text first := model_skip_valid text position bound
  have ba : ValidCursor text after := model_name_valid text first
  have bs : ValidCursor text start := model_fixed_valid text after "(" false ba
  have bl := model_arrayScalar_valid text start scalarNames arrays initials elaborating bs
  have bhs : ValidCursor text highStart := model_fixed_valid text low.after ".." false bl.1
  have bh := model_arrayScalar_valid text highStart scalarNames arrays initials elaborating bhs
  rw [equations.indexed text valid position names scalarNames arrays initials elaborating element
    bound namesValid scalarValid arraysValid initialsValid, indexed_denotation]
  change indexedEquation calls text position names scalarNames arrays initials elaborating element = _
  dsimp only [indexedEquation]
  rw [interpreted_skip calls equations text valid position bound,
    interpreted_name calls equations text valid first bf,
    interpreted_lookup calls equations text valid names first after namesValid bf ba,
    interpreted_symbol calls equations text valid after "(" ba (by unfold ValidToken; decide),
    equations.scalarRead text valid start scalarNames arrays initials elaborating bs scalarValid arraysValid initialsValid,
    equations.scalarLookup text valid scalarNames first after scalarValid bf ba,
    equations.scalarEmpty low.bounds bl.2]
  cases element with
  | true =>
      rw [interpreted_symbol calls equations text valid low.after ")" bl.1 (by unfold ValidToken; decide)]
      simp only [indexedAt, indexedParts, ↓reduceIte, Bool.or_eq_true,
        decide_eq_true_eq, or_assoc]
      rfl
  | false =>
      rw [interpreted_symbol calls equations text valid low.after ".." bl.1 (by unfold ValidToken; decide),
        equations.scalarRead text valid highStart scalarNames arrays initials elaborating bhs scalarValid arraysValid initialsValid,
        interpreted_symbol calls equations text valid high.after ")" bh.1 (by unfold ValidToken; decide),
        equations.scalarEmpty high.bounds bh.2]
      simp only [indexedAt, indexedParts, Bool.false_eq_true, ↓reduceIte, Bool.or_eq_true,
        Bool.and_eq_true, decide_eq_true_eq, or_assoc, and_assoc,
        StringIndexing.sliceMinimum, StringIndexing.sliceMaximum, StringIndexing.sliceLength,
        toNat_max_zero, max_capacity]
      rfl

@[simp] theorem interpreted_concatenatedLast (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (left : ExpressionState) (right : ValueResult)
    (leftValid : NativeScan text left) (rightValid : NativeValue text right) :
    calls.function .concatenatedLast left right = concatenatedLast left right := by
  rw [equations.concatenatedLast text left right leftValid rightValid, concatenatedLast_denotation]
  change concatenatedLastEquation calls left right = _
  dsimp only [concatenatedLastEquation]
  rw [interpreted_concatenatedFirst calls equations text left right leftValid rightValid,
    equations.scalarEmpty _ (model_concatenated_first_bounded left right leftValid.firstIndex rightValid.firstIndex)]
  simp only [concatenatedLast, Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq, or_assoc]

theorem model_character_after_valid (text : Source) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    ValidCursor text (characterAt text position names scalarNames arrays initials elaborating).after := by
  by_cases zero : (characterAt text position names scalarNames arrays initials elaborating).after = 0
  · simp [ValidCursor, zero]
  · obtain ⟨expression, reading⟩ := character_sound position zero
    exact character_after_bounded reading

@[simp] theorem interpreted_characterValue (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : ValidCursor text position) (namesValid : NativeNames text names)
    (scalarValid : ScalarExpression.ValidEnvironment text scalarNames)
    (arraysValid : ArrayBindings.ValidMetadata text arrays) (initialsValid : ArrayBindings.ValidInitials initials) :
    calls.function .characterValue text position names scalarNames arrays initials elaborating =
      characterAt text position names scalarNames arrays initials elaborating := by
  let first := skipAt text position
  let after := nameAfter text first
  let opened := fixedAfter text first "(" false
  have bf : ValidCursor text first := model_skip_valid text position bound
  have ba : ValidCursor text after := model_name_valid text first
  have bo : ValidCursor text opened := model_fixed_valid text first "(" false bf
  rw [equations.characterValue text valid position names scalarNames arrays initials elaborating
    bound namesValid scalarValid arraysValid initialsValid, character_denotation]
  change characterEquation calls text position names scalarNames arrays initials elaborating = _
  dsimp only [characterEquation]
  rw [interpreted_skip calls equations text valid position bound,
    interpreted_characterLiteral calls equations text valid first bf,
    interpreted_name calls equations text valid first bf,
    interpreted_lookup calls equations text valid names first after namesValid bf ba,
    interpreted_symbol calls equations text valid first "(" bf (by unfold ValidToken; decide)]
  by_cases absent : opened = 0
  · simp only [absent, ne_eq, not_true_eq_false, decide_false, ↓reduceIte]
    rw [equations.scalarLookup text valid scalarNames first after scalarValid bf ba,
      interpreted_indexed calls equations text valid position names scalarNames arrays initials elaborating true
        bound namesValid scalarValid arraysValid initialsValid]
    conv => rhs; rw [characterAt]
    simp only [first, after, opened] at absent ⊢
    simp only [ne_eq, absent, not_true_eq_false, ↓reduceIte, Bool.and_eq_true,
      decide_eq_true_eq, and_assoc]
  · have advance := model_fixed_advances text first "(" false bf (by decide) absent
    have skipped := skipAt_advances text position bound (by
      intro zero
      simp [first, opened, zero, fixedAfter] at absent)
    have smaller : text.length + 1 - opened < text.length + 1 - position := by
      unfold ValidCursor at bo
      omega
    simp only [absent, ne_eq, not_false_eq_true, decide_true, ↓reduceIte]
    rw [interpreted_characterValue calls equations text valid opened names scalarNames arrays initials elaborating
      bo namesValid scalarValid arraysValid initialsValid,
      interpreted_symbol calls equations text valid _ ")"
        (model_character_after_valid text opened names scalarNames arrays initials elaborating) (by unfold ValidToken; decide)]
    conv => rhs; rw [characterAt]
    simp only [first, after, opened] at absent smaller ⊢
    simp only [ne_eq, absent, not_false_eq_true, decide_true, smaller, ↓reduceIte, ↓reduceDIte]
termination_by text.length + 1 - position
decreasing_by exact smaller

end Silver.Compose.Expressions
