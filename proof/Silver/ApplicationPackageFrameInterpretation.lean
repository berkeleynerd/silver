module

public import Silver.ApplicationPackageFramesNative
public import Silver.ApplicationPackageFrameLoops
public import Silver.ApplicationNativeLoopFacts

@[expose] public section

namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
set_option backward.dsimp.instances true

theorem set_two_fields {α : Type} (rows : List α) (index : Nat) (fallback : α)
    (first second : α → α) :
    (rows.set index (first (rows.getD index fallback))).set index
        (second ((rows.set index (first (rows.getD index fallback))).getD index fallback)) =
      rows.set index (second (first (rows.getD index fallback))) := by
  by_cases inside : index < rows.length
  · simp only [List.getD_eq_getElem?_getD, List.getElem?_set_self inside,
      Option.getD_some, List.set_set]
  · simp only [List.set_eq_of_length_le (Nat.le_of_not_gt inside)]

def scalarQualified (first after : Nat) (row : ScalarExpression.Binding) : ScalarExpression.Binding :=
  {row with qualifierFirst := first, qualifierAfter := after}

def scalarStep (first after index : Nat) (state : ParserState) : ParserState :=
  {state with scalarNames := (updateRow (scalarQualified first after) ScalarExpression.emptyBinding
    state.scalarNames (index - 1))}

theorem scalar_qualify_body (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (qualifyBody .stateScalarNames .scalar .scalarQualifierFirst .scalarQualifierAfter) =
      next (locals.set .state "result"
        (scalarStep (locals .metadata "info").nameFirst (locals .metadata "info").nameAfter
          (locals .number "i") (locals .state "result"))) := by
  simp only [qualifyBody, Command.eval, Place.set, Place.expression, Expr.eval, Field.get, Field.set,
    Index.get, Index.set, ScalarExpression.binding, Native.result, Native.info,
    Locals.set_get_same, Locals.set_shadow]
  let state := locals .state "result"
  let index := locals .number "i" - 1
  let first := (locals .metadata "info").nameFirst
  let after := (locals .metadata "info").nameAfter
  let rows := state.scalarNames
  let firstRows := rows.set index {rows.getD index ScalarExpression.emptyBinding with qualifierFirst := first}
  change next (locals.set .state "result"
    {state with
      scalarNames := firstRows.set index
        {firstRows.getD index ScalarExpression.emptyBinding with qualifierAfter := after}}) = _
  rw [set_two_fields (locals .state "result").scalarNames (locals .number "i" - 1)
    ScalarExpression.emptyBinding
    (fun row => {row with qualifierFirst := (locals .metadata "info").nameFirst})
    (fun row => {row with qualifierAfter := (locals .metadata "info").nameAfter})]
  rfl

end Silver.ApplicationPackageFrames.Native
