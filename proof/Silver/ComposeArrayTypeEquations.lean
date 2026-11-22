module

public import Silver.ComposeHelperEquations
public import Silver.ComposeArrayTypeDenotations

@[expose] public section

namespace Silver.Compose.Expressions

variable {domain : StateDomain}
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
attribute [local irreducible] ScalarExpression.ArrayGrammar.read scalarTypeAt

@[simp] theorem interpreted_arrayTypeAt (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (position : Nat)
    (stateValid : NativeState domain text state) (bound : ValidCursor text position) :
    calls.function .arrayTypeAt text state position = arrayTypeAt text state position := by
  let first := skipAt text position
  let after := nameAfter text first
  have bf : ValidCursor text first := model_skip_valid text position bound
  have ba : ValidCursor text after := model_name_valid text first
  have ef := interpreted_skip calls equations text valid position bound
  have ea := interpreted_name calls equations text valid first bf
  have names := interpreted_lookup calls equations text valid state.names first after
    stateValid.nativeNames bf ba
  have scalars := equations.scalarLookup text valid state.scalarNames first after
    stateValid.valid.2.2.2.2.2.1 bf ba
  have arrays := equations.arrayLookup text valid state.arrayNames.table first after
    stateValid.valid.arrays.1 bf ba
  have booleans := equations.booleanLookup text valid state.booleanNames first after
    stateValid.valid.booleans bf ba
  have functions := equations.functionLookup text valid state.functions first after
    stateValid.valid.functions bf ba
  have procedures := equations.procedureLookup text valid state.procedures first after
    stateValid.valid.procedures bf ba
  have hides := equations.formalHides text valid state first after stateValid bf ba
  have types := equations.arrayTypeLookup text valid state.arrayNames.types first after
    stateValid.valid.arrayTypes bf ba
  rw [equations.arrayTypeAt text valid state position stateValid bound, arrayTypeAt_denotation]
  dsimp only [arrayTypeAtEquation, lexical]
  rw [ef, ea, names, scalars, arrays, booleans, functions, procedures, hides, types]
  simp only [arrayTypeAt, first, after, Bool.or_eq_true, decide_eq_true_eq, or_assoc]
  rfl

@[simp] theorem interpreted_arrayTypeDeclaration (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : NativeState domain text state) :
    calls.function .arrayTypeDeclaration text state arguments = arrayTypeDeclarationAt text state arguments := by
  let typeAfter := fixedAfter text state.position "type" true
  let first := skipAt text typeAfter
  let after := nameAfter text first
  let isAfter := fixedAfter text after "is" true
  let arrayAfter := fixedAfter text isAfter "array" true
  let start := fixedAfter text arrayAfter "(" false
  let low := ScalarExpression.ArrayGrammar.read text start state.scalarNames state.arrayNames.table
  let highPosition := fixedAfter text low.after ".." false
  let high := ScalarExpression.ArrayGrammar.read text highPosition state.scalarNames state.arrayNames.table
  let close := fixedAfter text high.after ")" false
  let componentPosition := fixedAfter text close "of" true
  let component := scalarTypeAt text state componentPosition
  let following := fixedAfter text component.after ";" false
  have bt : ValidCursor text typeAfter := model_fixed_valid text state.position "type" true stateValid.valid.1
  have bf : ValidCursor text first := model_skip_valid text typeAfter bt
  have ba : ValidCursor text after := model_name_valid text first
  have bi : ValidCursor text isAfter := model_fixed_valid text after "is" true ba
  have bar : ValidCursor text arrayAfter := model_fixed_valid text isAfter "array" true bi
  have bs : ValidCursor text start := model_fixed_valid text arrayAfter "(" false bar
  have bl := model_arrayScalar_valid text start state.scalarNames state.arrayNames.table [] false bs
  have bhp : ValidCursor text highPosition := model_fixed_valid text low.after ".." false bl.1
  have bh := model_arrayScalar_valid text highPosition state.scalarNames state.arrayNames.table [] false bhp
  have bc : ValidCursor text close := model_fixed_valid text high.after ")" false bh.1
  have bcp : ValidCursor text componentPosition := model_fixed_valid text close "of" true bc
  have bcomponent : ValidCursor text component.after := scalarTypeAt_position_valid text state componentPosition
  have et : calls.function .takeToken text state.position (.word "type") = typeAfter :=
    interpreted_take calls equations text valid _ _ stateValid.valid.1 (by unfold ValidToken; decide)
  have ef : calls.function .skip text typeAfter = first := interpreted_skip calls equations text valid _ bt
  have ea : calls.function .nameAfter text first = after := interpreted_name calls equations text valid _ bf
  have ei : calls.function .takeToken text after (.word "is") = isAfter :=
    interpreted_take calls equations text valid _ _ ba (by unfold ValidToken; decide)
  have ear : calls.function .takeToken text isAfter (.word "array") = arrayAfter :=
    interpreted_take calls equations text valid _ _ bi (by unfold ValidToken; decide)
  have es : calls.function .takeToken text arrayAfter (.symbol "(") = start :=
    interpreted_take calls equations text valid _ _ bar (by unfold ValidToken; decide)
  have el : calls.function .scalarRead text start state.scalarNames state.arrayNames.table [] false = low :=
    equations.scalarRead text valid _ _ _ _ _ bs stateValid.valid.2.2.2.2.2.1 stateValid.valid.arrays.1
      (by simp [ArrayBindings.ValidInitials])
  have ehp : calls.function .takeToken text low.after (.symbol "..") = highPosition :=
    interpreted_take calls equations text valid _ _ bl.1 (by unfold ValidToken; decide)
  have eh : calls.function .scalarRead text highPosition state.scalarNames state.arrayNames.table [] false = high :=
    equations.scalarRead text valid _ _ _ _ _ bhp stateValid.valid.2.2.2.2.2.1 stateValid.valid.arrays.1
      (by simp [ArrayBindings.ValidInitials])
  have ec : calls.function .takeToken text high.after (.symbol ")") = close :=
    interpreted_take calls equations text valid _ _ bh.1 (by unfold ValidToken; decide)
  have ecp : calls.function .takeToken text close (.word "of") = componentPosition :=
    interpreted_take calls equations text valid _ _ bc (by unfold ValidToken; decide)
  have ecomponent : calls.function .scalarType text state componentPosition = component :=
    interpreted_scalarType calls equations text valid state _ stateValid bcp
  have ee : calls.function .takeToken text component.after (.symbol ";") = following :=
    interpreted_take calls equations text valid _ _ bcomponent (by unfold ValidToken; decide)
  have en := interpreted_newName calls equations text valid state first after arguments stateValid bf ba
  have emptyLow := equations.scalarEmpty low.bounds bl.2
  have emptyHigh := equations.scalarEmpty high.bounds bh.2
  rw [equations.arrayTypeDeclaration text valid state arguments stateValid, arrayTypeDeclaration_denotation]
  dsimp only [arrayTypeDeclarationEquation, lexical]
  rw [et, ef, ea, ei, ear, es, el, ehp, eh, ec, ecp, ecomponent, ee, en, emptyLow, emptyHigh]
  by_cases allowed : newNameAllowed text state first after arguments = true
  · have nameValid := model_new_name_valid text state first after arguments ba allowed
    rw [equations.nameIs text valid first after "integer" nameValid (by decide) (by decide),
      equations.nameIs text valid first after "true" nameValid (by decide) (by decide),
      equations.nameIs text valid first after "false" nameValid (by decide) (by decide),
      equations.nameIs text valid first after "put_line" nameValid (by decide) (by decide),
      equations.nameIs text valid first after "put" nameValid (by decide) (by decide),
      equations.nameIs text valid first after "first_or_default" nameValid (by decide) (by decide),
      equations.nameIs text valid first after "input_is_valid" nameValid (by decide) (by decide),
      equations.nameIs text valid first after "reject" nameValid (by decide) (by decide)]
    dsimp only [arrayTypeDeclarationAt, typeAfter, first, after, isAfter, arrayAfter, start,
      low, highPosition, high, close, componentPosition, component, following,
      IntegerSubtypes.CallHiding.add, Names.Operation.name]
    simp only [Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true', or_assoc]
  · have rejected := Bool.eq_false_iff.mpr allowed
    simp only [rejected, Bool.not_false, Bool.or_true, Bool.true_or, ↓reduceIte]
    dsimp only [first, after, typeAfter] at rejected
    simp only [arrayTypeDeclarationAt, rejected, Bool.not_false, or_true, true_or, ↓reduceIte]

end Silver.Compose.Expressions
