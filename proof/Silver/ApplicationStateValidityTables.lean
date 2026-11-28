module

public import Silver.ApplicationStateValidityNative

@[expose] public section

/-! Typed interpretations of the local table guards consumed by Valid_State.
Quantification ranges over exactly the active prefix; no backing-row validity
or reachable parser history is assumed. -/
namespace Silver.ApplicationPackageFrames.ValidityTables
open ApplicationNative Compose

inductive Function : Ty → Type
  | nameState : Function (.arrow .source (.arrow .number (.arrow .number .truth)))
  | empty : Function (.arrow .interval .truth)
  | fixedBounds : Function (.arrow .number (.arrow .truth (.arrow .truth
      (.arrow .integer (.arrow .integer (.arrow .number .truth))))))

def functionNames : FunctionNames Function
  | _, .nameState => ["valid_name_state"]
  | _, .empty => ["scalars", ".", "is_empty"]
  | _, .fixedBounds => ["fixed_bounds_valid"]

def modelCalls : Calls Function
  | _, .nameState => nameStateValid
  | _, .empty => Integer.Interval.isEmpty
  | _, .fixedBounds => fixedBoundsValid

abbrev E := Expr Function

def text : E .source := .variable "text"
def offset (key : String) : E .number := .variable key

def span (first after : E .number) : E .truth :=
  .app (.app (.app (.function .nameState) text) first) after

def entryName (row : E rowTy) (first after qualifierFirst qualifierAfter : Field rowTy .number) : E .truth :=
  .andThen (.andThen (.gt (.field first row) (.number 0))
    (span (.field first row) (.field after row)))
    (span (.field qualifierFirst row) (.field qualifierAfter row))

def scalarBody : E .truth :=
  .forAll "index" (.number 1) (.field .scalarCount (.variable "names"))
    (entryName (.index .scalar (.variable "names") (offset "index"))
      .scalarFirst .scalarAfter .scalarQualifierFirst .scalarQualifierAfter)

def booleanBody : E .truth :=
  .forAll "index" (.number 1) (.field .booleanCount (.variable "booleans"))
    (entryName (.index .boolean (.variable "booleans") (offset "index"))
      .booleanFirst .booleanAfter .booleanQualifierFirst .booleanQualifierAfter)

def subtypeBody : E .truth :=
  let row : E .subtypeBinding := .index .subtype (.variable "subtypes") (offset "index")
  .forAll "index" (.number 1) (.field .subtypeCount (.variable "subtypes"))
    (.andThen (entryName row .subtypeFirst .subtypeAfter .subtypeQualifierFirst .subtypeQualifierAfter)
      (.not (.app (.function .empty) (.field .subtypeBounds row))))

def namesBody : E .truth :=
  let row : E .nameBinding := .index .binding (.variable "names") (offset "i")
  .forAll "i" (.number 1) (.field .nameCount (.variable "names"))
    (.andThen (.andThen (.andThen (.gt (.field .bindingFirst row) (.number 0))
      (span (.field .bindingFirst row) (.field .bindingAfter row)))
      (.le (.field .bindingValueFirst row) (.add (.sourceLast text) (.number 1))))
      (.app (.app (.app (.app (.app (.app (.function .fixedBounds)
        (.field .bindingStaticLength row)) (.field .bindingDynamic row))
        (.field .bindingIsCharacter row)) (.field .bindingFirstIndex row))
        (.field .bindingLastIndex row)) (offset "i")))

def mutableBody : E .truth :=
  let row : E .scalarBinding := .index .scalar (.variable "scalar_names") (offset "index")
  .forAll "index" (.number 1) (.field .scalarCount (.variable "scalar_names"))
    (.group (.conditionalTrue (.field .scalarMutable row)
      (.andThen (.andThen (.not (.app (.function .empty) (.field .scalarBounds row)))
        (.intGe (.field .lower (.field .scalarBounds row)) (.field .lower (.field .scalarDeclaredBounds row))))
        (.intLe (.field .upper (.field .scalarBounds row)) (.field .upper (.field .scalarDeclaredBounds row))))))

def valuesBody : E .truth :=
  .andThen (.le (.variable "count") (.field .scalarCount (.variable "scalar_names")))
    (.group (.forAll "index" (.number 1) (.variable "count")
      (.not (.app (.function .empty) (.field .scalarBounds
        (.index .scalar (.variable "scalar_names") (offset "index")))))))

theorem tables_checked :
    scalarBody.wellFormed functionNames = true ∧
    scalarBody.scoped [(.source,"text"),(.scalars,"names")] = true ∧
    booleanBody.wellFormed functionNames = true ∧
    booleanBody.scoped [(.source,"text"),(.booleans,"booleans")] = true ∧
    subtypeBody.wellFormed functionNames = true ∧
    subtypeBody.scoped [(.source,"text"),(.subtypes,"subtypes")] = true ∧
    namesBody.wellFormed functionNames = true ∧
    namesBody.scoped [(.source,"text"),(.names,"names")] = true ∧
    mutableBody.wellFormed functionNames = true ∧
    mutableBody.scoped [(.scalars,"scalar_names")] = true ∧
    valuesBody.wellFormed functionNames = true ∧
    valuesBody.scoped [(.scalars,"scalar_names"),(.number,"count")] = true := by decide +kernel

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem all_active {α : Type} (rows : List α) (fallback : α) (test : α → Bool) :
    (List.range rows.length).all (fun i => test (rows.getD i fallback)) = rows.all test := by
  apply Bool.eq_iff_iff.mpr
  simp only [List.all_eq_true, List.mem_range]
  constructor
  · intro checked item member
    obtain ⟨i, bound, same⟩ := List.getElem_of_mem member
    simpa only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem bound,
      Option.getD_some, same] using checked i bound
  · intro checked i bound
    simpa only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem bound,
      Option.getD_some] using checked rows[i] (List.getElem_mem bound)

theorem scalar_meaning (locals : Locals) :
    scalarBody.eval modelCalls locals = scalarNamesValid (locals .source "text") (locals .scalars "names") := by
  dsimp only [scalarBody, entryName, span, text, offset, Expr.eval, Field.get, Index.get, modelCalls]
  simp only [Nat.add_sub_cancel, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  simp only [scalarNamesValid, ScalarExpression.binding, Nat.add_sub_cancel_left]
  exact all_active (locals .scalars "names") ScalarExpression.emptyBinding
    (fun row => decide (0 < row.first) && nameStateValid (locals .source "text") row.first row.after &&
      nameStateValid (locals .source "text") row.qualifierFirst row.qualifierAfter)

theorem boolean_meaning (locals : Locals) :
    booleanBody.eval modelCalls locals = booleanNamesValid (locals .source "text") (locals .booleans "booleans") := by
  dsimp only [booleanBody, entryName, span, text, offset, Expr.eval, Field.get, Index.get, modelCalls]
  simp only [Nat.add_sub_cancel, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  simp only [booleanNamesValid, BooleanBindings.binding, Nat.add_sub_cancel_left]
  exact all_active (locals .booleans "booleans") {}
    (fun row => decide (0 < row.first) && nameStateValid (locals .source "text") row.first row.after &&
      nameStateValid (locals .source "text") row.qualifierFirst row.qualifierAfter)

theorem subtype_meaning (locals : Locals) :
    subtypeBody.eval modelCalls locals = subtypesValid (locals .source "text") (locals .subtypes "subtypes") := by
  dsimp only [subtypeBody, entryName, span, text, offset, Expr.eval, Field.get, Index.get, modelCalls]
  simp only [Nat.add_sub_cancel, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  simp only [subtypesValid, Nat.add_sub_cancel_left]
  exact all_active (locals .subtypes "subtypes").items {}
    (fun row => decide (0 < row.first) && nameStateValid (locals .source "text") row.first row.after &&
      nameStateValid (locals .source "text") row.qualifierFirst row.qualifierAfter && !row.bounds.isEmpty)

theorem names_meaning (locals : Locals) :
    namesBody.eval modelCalls locals = stringNamesValid (locals .source "text") (locals .names "names") := by
  dsimp only [namesBody, span, text, offset, Expr.eval, Field.get, Index.get, modelCalls]
  simp only [Nat.add_sub_cancel, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  simp only [stringNamesValid, Nat.add_comm 1, Nat.add_sub_cancel]

theorem mutable_meaning (locals : Locals) :
    mutableBody.eval modelCalls locals = mutableBoundsValid (locals .scalars "scalar_names") := by
  dsimp only [mutableBody, offset, Expr.eval, Field.get, Index.get, modelCalls]
  simp only [Nat.add_sub_cancel, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
  simp only [mutableBoundsValid, ScalarExpression.binding, Nat.add_sub_cancel_left]
  exact all_active (locals .scalars "scalar_names") ScalarExpression.emptyBinding
    (fun row => if row.mutable then !row.bounds.isEmpty &&
      decide (row.declaredBounds.lower ≤ row.bounds.lower) && decide (row.bounds.upper ≤ row.declaredBounds.upper)
      else true)

theorem all_prefix {α : Type} (rows : List α) (fallback : α) (test : α → Bool)
    (count : Nat) (bounded : count ≤ rows.length) :
    (List.range count).all (fun i => test (rows.getD i fallback)) = (rows.take count).all test := by
  rw [← all_active (rows.take count) fallback test, List.length_take, Nat.min_eq_left bounded]
  apply Bool.eq_iff_iff.mpr
  simp only [List.all_eq_true, List.mem_range]
  constructor <;> intro checked i member
  · simpa only [List.getD_eq_getElem?_getD, List.getElem?_take_of_lt member] using checked i member
  · simpa only [List.getD_eq_getElem?_getD, List.getElem?_take_of_lt member] using checked i member

theorem values_meaning (locals : Locals) :
    valuesBody.eval modelCalls locals = declarationValuesValid
      (locals .scalars "scalar_names") (locals .number "count") := by
  dsimp only [valuesBody, offset, Expr.eval, Field.get, Index.get, modelCalls]
  simp only [Nat.add_sub_cancel, Locals.set, reduceCtorEq, ↓reduceDIte, ↓reduceIte,
    ScalarExpression.binding, Nat.add_sub_cancel_left]
  unfold declarationValuesValid
  by_cases bounded : locals .number "count" ≤ (locals .scalars "scalar_names").length
  · simp only [bounded, decide_true, Bool.true_and]
    exact all_prefix (locals .scalars "scalar_names") ScalarExpression.emptyBinding
      (fun row => !row.bounds.isEmpty) _ bounded
  · simp only [bounded, decide_false, Bool.false_and]

end Silver.ApplicationPackageFrames.ValidityTables
