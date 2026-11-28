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
  dsimp only [qualifyBody, Command.eval, Place.set, Place.expression, Expr.eval, Field.get, Field.set,
    Index.get, Index.set, ScalarExpression.binding, Native.result, Native.info]
  simp only [Locals.set_get_same, Locals.set_shadow]
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

def booleanQualified (first after : Nat) (row : BooleanBindings.Binding) : BooleanBindings.Binding :=
  {row with qualifierFirst := first, qualifierAfter := after}

def booleanStep (first after index : Nat) (state : ParserState) : ParserState :=
  {state with booleanNames := updateRow (booleanQualified first after) {} state.booleanNames (index - 1)}

theorem boolean_qualify_body (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (qualifyBody .stateBooleanNames .boolean .booleanQualifierFirst .booleanQualifierAfter) =
      next (locals.set .state "result"
        (booleanStep (locals .metadata "info").nameFirst (locals .metadata "info").nameAfter
          (locals .number "i") (locals .state "result"))) := by
  dsimp only [qualifyBody, Command.eval, Place.set, Place.expression, Expr.eval, Field.get, Field.set,
    Index.get, Index.set, BooleanBindings.binding, Native.result, Native.info]
  simp only [Locals.set_get_same, Locals.set_shadow]
  let state := locals .state "result"
  let index := locals .number "i" - 1
  let first := (locals .metadata "info").nameFirst
  let after := (locals .metadata "info").nameAfter
  let rows := state.booleanNames
  let firstRows := rows.set index {rows.getD index {} with qualifierFirst := first}
  change next (locals.set .state "result"
    {state with
      booleanNames := firstRows.set index
        {firstRows.getD index {} with qualifierAfter := after}}) = _
  rw [set_two_fields (locals .state "result").booleanNames (locals .number "i" - 1) {}
    (fun row => {row with qualifierFirst := (locals .metadata "info").nameFirst})
    (fun row => {row with qualifierAfter := (locals .metadata "info").nameAfter})]
  rfl

def subtypeQualified (first after : Nat) (row : IntegerSubtypes.Binding) : IntegerSubtypes.Binding :=
  {row with qualifierFirst := first, qualifierAfter := after}

def subtypeStep (first after index : Nat) (state : ParserState) : ParserState :=
  {state with subtypeNames := {state.subtypeNames with
    items := updateRow (subtypeQualified first after) {} state.subtypeNames.items (index - 1)}}

theorem subtype_qualify_body (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (qualifyBody .stateSubtypeNames .subtype .subtypeQualifierFirst .subtypeQualifierAfter) =
      next (locals.set .state "result"
        (subtypeStep (locals .metadata "info").nameFirst (locals .metadata "info").nameAfter
          (locals .number "i") (locals .state "result"))) := by
  dsimp only [qualifyBody, Command.eval, Place.set, Place.expression, Expr.eval, Field.get, Field.set,
    Index.get, Index.set, Native.result, Native.info]
  simp only [Locals.set_get_same, Locals.set_shadow]
  let state := locals .state "result"
  let index := locals .number "i" - 1
  let first := (locals .metadata "info").nameFirst
  let after := (locals .metadata "info").nameAfter
  let rows := state.subtypeNames.items
  let firstRows := rows.set index {rows.getD index {} with qualifierFirst := first}
  change next (locals.set .state "result"
    {state with
      subtypeNames := {state.subtypeNames with
        items := firstRows.set index {firstRows.getD index {} with qualifierAfter := after}}}) = _
  rw [set_two_fields (locals .state "result").subtypeNames.items (locals .number "i" - 1) {}
    (fun row => {row with qualifierFirst := (locals .metadata "info").nameFirst})
    (fun row => {row with qualifierAfter := (locals .metadata "info").nameAfter})]
  rfl

theorem scalarSteps_fold (first after : Nat) (indices : List Nat) (state : ParserState) :
    (indices.map (· + 1)).foldl (fun current index => scalarStep first after index current) state =
      {state with
        scalarNames := indices.foldl
          (updateRow (scalarQualified first after) ScalarExpression.emptyBinding) state.scalarNames} := by
  induction indices generalizing state with
  | nil => rfl
  | cons index rest ih =>
      simp only [List.map_cons, List.foldl_cons]
      rw [ih]
      rfl

theorem booleanSteps_fold (first after : Nat) (indices : List Nat) (state : ParserState) :
    (indices.map (· + 1)).foldl (fun current index => booleanStep first after index current) state =
      {state with booleanNames := indices.foldl (updateRow (booleanQualified first after) {}) state.booleanNames} := by
  induction indices generalizing state with
  | nil => rfl
  | cons index rest ih =>
      simp only [List.map_cons, List.foldl_cons]
      rw [ih]
      rfl

theorem subtypeSteps_fold (first after : Nat) (indices : List Nat) (state : ParserState) :
    (indices.map (· + 1)).foldl (fun current index => subtypeStep first after index current) state =
      {state with subtypeNames := {state.subtypeNames with
        items := indices.foldl (updateRow (subtypeQualified first after) {}) state.subtypeNames.items}} := by
  induction indices generalizing state with
  | nil => rfl
  | cons index rest ih =>
      simp only [List.map_cons, List.foldl_cons]
      rw [ih]
      rfl

theorem scalar_qualify_loop (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (qualifyLoop .stateScalarNames .scalarCount .scalar .scalarQualifierFirst .scalarQualifierAfter) =
      next (locals.set .state "result" {(locals .state "result") with
        scalarNames := (locals .state "result").scalarNames.map
          (scalarQualified (locals .metadata "info").nameFirst (locals .metadata "info").nameAfter)}) := by
  change forValues
    (fun current continuation => Command.eval calls current continuation
      (qualifyBody .stateScalarNames .scalar .scalarQualifierFirst .scalarQualifierAfter))
    "i" ((List.range (locals .state "result").scalarNames.length).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  rw [show (fun i : Nat => 1 + i) = (fun i => i + 1) by funext i; omega]
  rw [forValues_state_fold (resultType := .state) _
    (fun info index state => scalarStep info.nameFirst info.nameAfter index state)
    "i" "result" "info" (scalar_qualify_body calls) _ locals _
    (by intros; simp only [Locals.set_shadow])]
  rw [scalarSteps_fold, updateRows_full]
  rw [Locals.set_commute_types _ .state .number "result" "i" _ _ (by decide), Locals.set_unchanged]

theorem boolean_qualify_loop (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (qualifyLoop .stateBooleanNames .booleanCount .boolean .booleanQualifierFirst .booleanQualifierAfter) =
      next (locals.set .state "result" {(locals .state "result") with
        booleanNames := (locals .state "result").booleanNames.map
          (booleanQualified (locals .metadata "info").nameFirst (locals .metadata "info").nameAfter)}) := by
  change forValues
    (fun current continuation => Command.eval calls current continuation
      (qualifyBody .stateBooleanNames .boolean .booleanQualifierFirst .booleanQualifierAfter))
    "i" ((List.range (locals .state "result").booleanNames.length).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  rw [show (fun i : Nat => 1 + i) = (fun i => i + 1) by funext i; omega]
  rw [forValues_state_fold (resultType := .state) _
    (fun info index state => booleanStep info.nameFirst info.nameAfter index state)
    "i" "result" "info" (boolean_qualify_body calls) _ locals _
    (by intros; simp only [Locals.set_shadow])]
  rw [booleanSteps_fold, updateRows_full]
  rw [Locals.set_commute_types _ .state .number "result" "i" _ _ (by decide), Locals.set_unchanged]

theorem subtype_qualify_loop (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (qualifyLoop .stateSubtypeNames .subtypeCount .subtype .subtypeQualifierFirst .subtypeQualifierAfter) =
      next (locals.set .state "result" {(locals .state "result") with
        subtypeNames := {(locals .state "result").subtypeNames with
          items := (locals .state "result").subtypeNames.items.map
            (subtypeQualified (locals .metadata "info").nameFirst (locals .metadata "info").nameAfter)}}) := by
  change forValues
    (fun current continuation => Command.eval calls current continuation
      (qualifyBody .stateSubtypeNames .subtype .subtypeQualifierFirst .subtypeQualifierAfter))
    "i" ((List.range (locals .state "result").subtypeNames.items.length).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  rw [show (fun i : Nat => 1 + i) = (fun i => i + 1) by funext i; omega]
  rw [forValues_state_fold (resultType := .state) _
    (fun info index state => subtypeStep info.nameFirst info.nameAfter index state)
    "i" "result" "info" (subtype_qualify_body calls) _ locals _
    (by intros; simp only [Locals.set_shadow])]
  rw [subtypeSteps_fold, updateRows_full]
  rw [Locals.set_commute_types _ .state .number "result" "i" _ _ (by decide), Locals.set_unchanged]

def importedInitial (exports : ParserState) (info : PackageBindings.Metadata) (position : Nat) : ParserState :=
  {exports with
    position := position, contextFirst := (info.units .mainBody).first,
    packageFirst := info.nameFirst, packageAfter := info.nameAfter,
    pure := false, «hiding» := {}}

def importedEquation (calls : Calls Function) (text : Source) (exports : ParserState)
    (info : PackageBindings.Metadata) (position : Nat) : ParserState :=
  let result := importedFrameRaw exports info position
  if calls _ .validState text result then result else invalidState

theorem importedFrame_model (text : Source) (exports : ParserState)
    (info : PackageBindings.Metadata) (position : Nat) :
    importedEquation modelCalls text exports info position = importedFrame text exports info position := rfl

end Silver.ApplicationPackageFrames.Native
