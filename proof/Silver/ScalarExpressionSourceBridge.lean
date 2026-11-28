module

public import Silver.ScalarExpressionNativeEquations
public import Silver.ScalarExpressionSourceChecks
public import Silver.ArrayBindingsSourceBridge

@[expose] public section

/-! Actual-source scalar-expression correspondence. The interpreted bodies
leave every call arbitrary; imported helper meanings and exact native
refinements identify the implementation by well-founded uniqueness. -/
namespace Silver.ScalarExpression.SourceBridge

structure InterpretedSource (calls : Native.Calls) : Prop where
  primitives : Native.Primitives calls
  definitions : Native.Equations calls

theorem interpreted_readReference (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (bound : position ≤ text.length + 1) :
    calls.readReference text position = readReference text position :=
  Native.interpreted_readReference calls source.primitives source.definitions text valid position bound

theorem interpreted_lookup_qualified (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (names : Environment)
    (environment : ValidEnvironment text names) (first after : Nat)
    (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (qualifierFirst qualifierAfter : Nat) (queryValid : QualifiedNames.ValidSpan text qualifierFirst qualifierAfter) :
    calls.lookup text names first after qualifierFirst qualifierAfter =
      lookup text names first after qualifierFirst qualifierAfter :=
  Native.interpreted_lookup_qualified calls source.primitives source.definitions
    text valid names environment first after firstBound afterBound qualifierFirst qualifierAfter queryValid

theorem interpreted_readExpression (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter) :
    calls.readExpression text position names maskFirst maskAfter allowSign =
      read text position names maskFirst maskAfter allowSign :=
  Native.interpreted_readExpression calls source.primitives source.definitions
    text valid position names maskFirst maskAfter allowSign bound environment mask

theorem interpreted_array_helpers (calls : Native.Calls) (source : InterpretedSource calls) :
    ArrayBindings.SourceBridge.InterpretedSource calls.arrays :=
  ⟨source.primitives.arrayPrimitives, source.primitives.arrayEquations⟩

theorem interpreted_readExpression_table (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter)
    (metadata : ArrayBindings.ValidTable text arrays) (values : ArrayBindings.ValidInitials initials) :
    calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads :=
  Native.interpreted_readExpression_table calls source.primitives source.definitions
    text valid position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads bound environment mask metadata values

theorem interpreted_admission_table (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter)
    (metadata : ArrayBindings.ValidTable text arrays) (values : ArrayBindings.ValidInitials initials)
    (result : Result) :
    (∃ expression, ArrayGrammar.At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads) ↔
      calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads = result ∧ result.after ≠ 0 := by
  rw [interpreted_readExpression_table calls source text valid position names maskFirst maskAfter allowSign
    arrays initials elaborating arrayReads bound environment mask metadata values]
  constructor
  · rintro ⟨expression, parsed⟩
    exact ⟨ArrayGrammar.read_complete parsed, by have bounds := parsed.cursorBounds; omega⟩
  · rintro ⟨same, success⟩
    obtain ⟨expression, parsed⟩ := ArrayGrammar.read_sound bound (show
      (ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after ≠ 0
      from by rwa [same])
    exact ⟨expression, by simpa only [same] using parsed⟩

theorem interpreted_safe_table (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter)
    (metadata : ArrayBindings.ValidTable text arrays) (initialsValid : ArrayBindings.ValidInitials initials)
    (values : Integer.Store) (fits : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) values)
    (success : (calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads).after ≠ 0) :
    ∃ expression : Integer.Expr, expression.Safe values ∧
      (calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads).bounds.Contains
        (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  rw [interpreted_readExpression_table calls source text valid position names maskFirst maskAfter allowSign
    arrays initials elaborating arrayReads bound environment mask metadata initialsValid] at success ⊢
  exact ArrayGrammar.read_safe success fits

theorem interpreted_arrayAttribute (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat) (rangeQuery : Bool)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidTable text arrays) :
    calls.readArrayAttribute text position names arrays maskFirst maskAfter rangeQuery =
      ArrayAttributes.read text position names arrays maskFirst maskAfter rangeQuery :=
  Native.interpreted_arrayAttribute calls source.primitives source.definitions
    text valid position names arrays maskFirst maskAfter rangeQuery bound environment mask metadata

theorem interpreted_lookup (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (names : Environment)
    (environment : ValidEnvironment text names) (first after : Nat)
    (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names first after :=
  Native.interpreted_lookup calls source.primitives source.definitions
    text valid names environment first after firstBound afterBound

theorem interpreted_admission (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter)
    (result : Result) :
    (∃ expression, At text names position expression result maskFirst maskAfter allowSign) ↔
      calls.readExpression text position names maskFirst maskAfter allowSign = result ∧ result.after ≠ 0 := by
  rw [interpreted_readExpression calls source text valid position names maskFirst maskAfter allowSign bound environment mask]
  exact admission_iff bound

theorem interpreted_safe (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter)
    (values : Integer.Store) (fits : Integer.Fits (ranges names) values)
    (success : (calls.readExpression text position names maskFirst maskAfter allowSign).after ≠ 0) :
    ∃ expression : Integer.Expr, expression.Safe values ∧
      (calls.readExpression text position names maskFirst maskAfter allowSign).bounds.Contains
        (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  rw [interpreted_readExpression calls source text valid position names maskFirst maskAfter allowSign bound environment mask] at success ⊢
  exact read_safe success fits

theorem model_interpreted : InterpretedSource Native.modelCalls :=
  ⟨Native.model_primitives, Native.model_equations⟩

theorem actual_source_correspondence : SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, Native.ValidText text → ∀ position names maskFirst maskAfter allowSign,
      position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
      calls.readExpression text position names maskFirst maskAfter allowSign =
        read text position names maskFirst maskAfter allowSign :=
  ⟨SourceChecks.checked_source, interpreted_readExpression⟩

theorem actual_table_source_correspondence : SourceChecks.CheckedSource ∧
    ArrayBindings.SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, Native.ValidText text →
      ∀ position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads,
      position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
      ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials →
      calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
        ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads :=
  ⟨SourceChecks.checked_source, ArrayBindings.SourceChecks.checked_source, interpreted_readExpression_table⟩

theorem actual_attribute_source_correspondence : SourceChecks.CheckedSource ∧
    ArrayBindings.SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, Native.ValidText text →
      ∀ position names arrays maskFirst maskAfter rangeQuery,
      position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
      ArrayBindings.ValidTable text arrays →
      calls.readArrayAttribute text position names arrays maskFirst maskAfter rangeQuery =
        ArrayAttributes.read text position names arrays maskFirst maskAfter rangeQuery :=
  ⟨SourceChecks.checked_source, ArrayBindings.SourceChecks.checked_source, interpreted_arrayAttribute⟩

end Silver.ScalarExpression.SourceBridge
