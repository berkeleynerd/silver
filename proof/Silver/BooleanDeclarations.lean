module

public import Silver.PredicateChecking

@[expose] public section

/-! Boolean declarations initialize consecutive identities in source order.
Each initializer sees exactly the preceding Boolean prefix. Its truth does not
refine the context of a later declaration. -/
namespace Silver.Predicate
open Bindings Compose PathFacts

structure BooleanDeclaration where
  mutable : Bool
  value : Condition
  deriving Repr

def booleanInitialAnalysis (count : Nat) : Boolean.Analysis :=
  { initialized := fun index => decide (0 < index ∧ index ≤ count) }

def booleanBodyAnalysis (declarations : List BooleanDeclaration) : Boolean.Analysis :=
  { initialized := (booleanInitialAnalysis declarations.length).initialized
    mutable := fun index =>
      decide (0 < index ∧ index ≤ declarations.length) &&
        ((declarations[index - 1]?).map (·.mutable)).getD false }

def BooleanDeclarationsWellFormed (hasArguments : Bool) (shape : Shape) :
    Nat → List BooleanDeclaration → Prop
  | _, [] => True
  | count, declaration :: rest =>
      declaration.value.Grammatical ∧
        declaration.value.Readable hasArguments shape (booleanInitialAnalysis count) ∧
        BooleanDeclarationsWellFormed hasArguments shape (count + 1) rest

def checkBooleanDeclarations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) :
    Nat → List BooleanDeclaration → Bool
  | _, [] => true
  | count, declaration :: rest =>
      declaration.value.checkBounds shape analysis flow (booleanInitialAnalysis count) &&
        checkBooleanDeclarations shape analysis flow (count + 1) rest

def executeBooleanDeclarations (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : Nat → List BooleanDeclaration → Boolean.Store → Boolean.Store
  | _, [], booleans => booleans
  | count, declaration :: rest, booleans =>
      executeBooleanDeclarations values input valid integers (count + 1) rest
        (Boolean.put booleans (count + 1) (declaration.value.evaluate values input valid integers booleans))

def checkedBooleanDeclarations (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : Nat → List BooleanDeclaration → Boolean.Store → Option Boolean.Store
  | _, [], booleans => some booleans
  | count, declaration :: rest, booleans =>
      (declaration.value.checkedEvaluate values input valid integers booleans).bind fun value =>
        checkedBooleanDeclarations values input valid integers (count + 1) rest
          (Boolean.put booleans (count + 1) value)

def BooleanDeclarationsSafe (shape : Shape) (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : Nat → List BooleanDeclaration → Boolean.Store → Prop
  | _, [], _ => True
  | count, declaration :: rest, booleans =>
      declaration.value.Safe shape values input valid integers booleans ∧
        BooleanDeclarationsSafe shape values input valid integers (count + 1) rest
          (Boolean.put booleans (count + 1) (declaration.value.evaluate values input valid integers booleans))

theorem boolean_declarations_sound {declarations : List BooleanDeclaration} {count : Nat}
    {shape : Shape} {analysis : Integer.Analysis} {flow : Flow} {hasArguments : Bool}
    {values : Values} {input : Source} {valid rejected : Bool} {integers : Integer.Store}
    {booleans : Boolean.Store}
    (wellFormed : BooleanDeclarationsWellFormed hasArguments shape count declarations)
    (checked : checkBooleanDeclarations shape analysis flow count declarations = true)
    (state : Fits shape input values) (allowed : flow.Allows valid input.length rejected integers) :
    BooleanDeclarationsSafe shape values input valid integers count declarations booleans ∧
      checkedBooleanDeclarations values input valid integers count declarations booleans =
        some (executeBooleanDeclarations values input valid integers count declarations booleans) := by
  induction declarations generalizing count booleans with
  | nil => exact ⟨trivial, rfl⟩
  | cons declaration rest ih =>
      simp only [BooleanDeclarationsWellFormed] at wellFormed
      simp only [checkBooleanDeclarations, Bool.and_eq_true] at checked
      have safe := declaration.value.checkBounds_sound (booleans := booleans)
        state wellFormed.2.1 allowed checked.1
      have agreement := declaration.value.checkedEvaluate_refines safe state
      have following := ih (booleans := Boolean.put booleans (count + 1)
        (declaration.value.evaluate values input valid integers booleans)) wellFormed.2.2 checked.2
      exact ⟨⟨safe, following.1⟩, by
        simpa only [checkedBooleanDeclarations, executeBooleanDeclarations, agreement, Option.bind_some]
          using following.2⟩

theorem boolean_declarations_preserve_prefix (declarations : List BooleanDeclaration)
    (values : Values) (input : Source) (valid : Bool) (integers : Integer.Store)
    (count : Nat) (booleans : Boolean.Store) {index : Nat} (prior : index ≤ count) :
    executeBooleanDeclarations values input valid integers count declarations booleans index = booleans index := by
  induction declarations generalizing count booleans with
  | nil => rfl
  | cons declaration rest ih =>
      rw [executeBooleanDeclarations, ih (count + 1) _ (by omega)]
      exact Boolean.put_other _ _ _ _ (by omega)

end Silver.Predicate
