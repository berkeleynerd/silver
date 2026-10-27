module

public import Silver.ComposeContracts
public import Silver.ComposeArrayElaboration

@[expose] public section

namespace Silver.Compose.Expressions

/-- A single initialized-value update preserves the native parser invariant.
No ordering or compactness of the incoming array table is assumed. -/
theorem model_putArray_valid {text : Source} {state : ParserState} {value : Int}
    (valid : ValidState text state) (room : state.arrayNames.used < ArrayBindings.maxElements)
    (safe : Integer.InRange value) : ValidState text (putArrayValue state value) := by
  rcases valid with ⟨position, names, dynamic, target, capacity, scalarNames,
    metadata, used, initials, allocated⟩
  refine ⟨position, names, dynamic, target, capacity, scalarNames, metadata,
    by dsimp only [putArrayValue]; omega, ?_, ?_⟩
  · exact putInitial_valid initials (by omega) safe
  · intro item present
    have prior := allocated item present
    dsimp only [putArrayValue]
    omega

theorem ArrayValuesDomain.room {text source result position length parsed}
    (valid : ArrayValuesDomain text source result position length parsed)
    (remaining : parsed < length) : result.arrayNames.used < ArrayBindings.maxElements := by
  have used := valid.used
  have capacity := valid.capacity
  have sourceBound := valid.sourceValid.2.2.2.2.2.2.2.1
  omega

theorem ArrayValuesDomain.next {text source result position length parsed value following}
    (valid : ArrayValuesDomain text source result position length parsed)
    (remaining : parsed < length) (safe : Integer.InRange value)
    (positionValid : ValidCursor text following) :
    ArrayValuesDomain text source (putArrayValue result value) following length (parsed + 1) where
  sourceValid := valid.sourceValid
  resultValid := model_putArray_valid valid.resultValid (valid.room remaining) safe
  positionValid := positionValid
  parsedBound := by omega
  capacity := valid.capacity
  used := by dsimp only [putArrayValue]; have same := valid.used; omega

end Silver.Compose.Expressions
