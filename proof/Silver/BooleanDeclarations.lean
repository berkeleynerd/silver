module

public import Silver.PredicateChecking

@[expose] public section

/-! Boolean initialization targets are explicit. Scalar object identities and
array-cell identities share the Boolean store without sharing source names.
Each initializer sees the preceding initialized objects; no stored predicate
facts enter analysis. -/
namespace Silver.Predicate
open Bindings Compose PathFacts

structure BooleanDeclaration where
  target : Nat
  mutable : Bool
  value : Condition
  deriving Repr

/-- The scalar-prefix view remains useful at native declaration boundaries. -/
def booleanInitialAnalysis (count : Nat) : Boolean.Analysis :=
  { initialized := fun index => decide (0 < index ∧ index ≤ count) }

def booleanDeclarationsAnalysis : Boolean.Analysis → List BooleanDeclaration → Boolean.Analysis
  | before, [] => before
  | before, declaration :: rest =>
      booleanDeclarationsAnalysis (before.initialize declaration.target declaration.mutable) rest

def booleanBodyAnalysis (declarations : List BooleanDeclaration) : Boolean.Analysis :=
  booleanDeclarationsAnalysis {} declarations

def BooleanDeclarationsWellFormed (hasArguments : Bool) (shape : Shape) :
    Boolean.Analysis → List BooleanDeclaration → Prop
  | _, [] => True
  | before, declaration :: rest =>
      declaration.target ≠ 0 ∧ before.initialized declaration.target = false ∧
        declaration.value.Grammatical ∧ declaration.value.Readable hasArguments shape before ∧
        BooleanDeclarationsWellFormed hasArguments shape
          (before.initialize declaration.target declaration.mutable) rest

def checkBooleanDeclarations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) :
    Boolean.Analysis → List BooleanDeclaration → Bool
  | _, [] => true
  | before, declaration :: rest =>
      declaration.value.checkBounds shape analysis flow before &&
        checkBooleanDeclarations shape analysis flow
          (before.initialize declaration.target declaration.mutable) rest

def executeBooleanDeclarations (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : List BooleanDeclaration → Boolean.Store → Boolean.Store
  | [], booleans => booleans
  | declaration :: rest, booleans =>
      executeBooleanDeclarations values input valid integers rest
        (Boolean.put booleans declaration.target
          (declaration.value.evaluate values input valid integers booleans))

def checkedBooleanDeclarations (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : List BooleanDeclaration → Boolean.Store → Option Boolean.Store
  | [], booleans => some booleans
  | declaration :: rest, booleans =>
      (declaration.value.checkedEvaluate values input valid integers booleans).bind fun value =>
        checkedBooleanDeclarations values input valid integers rest
          (Boolean.put booleans declaration.target value)

def BooleanDeclarationsSafe (shape : Shape) (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : List BooleanDeclaration → Boolean.Store → Prop
  | [], _ => True
  | declaration :: rest, booleans =>
      declaration.value.Safe shape values input valid integers booleans ∧
        BooleanDeclarationsSafe shape values input valid integers rest
          (Boolean.put booleans declaration.target
            (declaration.value.evaluate values input valid integers booleans))

theorem boolean_declarations_sound {declarations : List BooleanDeclaration} {before : Boolean.Analysis}
    {shape : Shape} {analysis : Integer.Analysis} {flow : Flow} {hasArguments : Bool}
    {values : Values} {input : Source} {valid rejected : Bool} {integers : Integer.Store}
    {booleans : Boolean.Store}
    (wellFormed : BooleanDeclarationsWellFormed hasArguments shape before declarations)
    (checked : checkBooleanDeclarations shape analysis flow before declarations = true)
    (state : Fits shape input values) (allowed : flow.Allows valid input.length rejected integers) :
    BooleanDeclarationsSafe shape values input valid integers declarations booleans ∧
      checkedBooleanDeclarations values input valid integers declarations booleans =
        some (executeBooleanDeclarations values input valid integers declarations booleans) := by
  induction declarations generalizing before booleans with
  | nil => exact ⟨trivial, rfl⟩
  | cons declaration rest ih =>
      simp only [BooleanDeclarationsWellFormed] at wellFormed
      simp only [checkBooleanDeclarations, Bool.and_eq_true] at checked
      have safe := declaration.value.checkBounds_sound (booleans := booleans)
        state wellFormed.2.2.2.1 allowed checked.1
      have agreement := declaration.value.checkedEvaluate_refines safe state
      have following := ih (booleans := Boolean.put booleans declaration.target
        (declaration.value.evaluate values input valid integers booleans)) wellFormed.2.2.2.2 checked.2
      exact ⟨⟨safe, following.1⟩, by
        simpa only [checkedBooleanDeclarations, executeBooleanDeclarations, agreement, Option.bind_some]
          using following.2⟩

theorem boolean_declarations_preserve (declarations : List BooleanDeclaration)
    (values : Values) (input : Source) (valid : Bool) (integers : Integer.Store)
    (booleans : Boolean.Store) {index : Nat}
    (untouched : ∀ declaration ∈ declarations, declaration.target ≠ index) :
    executeBooleanDeclarations values input valid integers declarations booleans index = booleans index := by
  induction declarations generalizing booleans with
  | nil => rfl
  | cons declaration rest ih =>
      rw [executeBooleanDeclarations, ih _ (fun item member => untouched item (by simp [member]))]
      exact Boolean.put_other _ _ _ _ (Ne.symm (untouched declaration (by simp)))

theorem boolean_declarations_analysis_preserves (declarations : List BooleanDeclaration)
    (before : Boolean.Analysis) {index : Nat} (ready : before.initialized index = true) :
    (booleanDeclarationsAnalysis before declarations).initialized index = true := by
  induction declarations generalizing before with
  | nil => exact ready
  | cons declaration rest ih =>
      exact ih _ (before.initialize_preserves declaration.target declaration.mutable index ready)

structure BooleanArrayDeclaration where
  array : Boolean.ArrayDescriptor
  mutable : Bool
  values : List Condition
  deriving Repr

def BooleanArrayDeclaration.initializations (declaration : BooleanArrayDeclaration) : List BooleanDeclaration :=
  declaration.values.zipIdx.map fun entry =>
    ⟨declaration.array.base + entry.2, declaration.mutable, entry.1⟩

@[simp] theorem BooleanArrayDeclaration.initializations_length (declaration : BooleanArrayDeclaration) :
    declaration.initializations.length = declaration.values.length := by
  simp [initializations]

end Silver.Predicate
