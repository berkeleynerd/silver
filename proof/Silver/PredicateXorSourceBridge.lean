module

public import Silver.PredicateXorNative
public import Silver.ComposeStringPrimitiveEquations

@[expose] public section

namespace Silver.Predicate.XorSourceBridge

structure InterpretedSource where
  calls : XorNative.Calls
  equations : XorNative.Equations calls

def InterpretedSource.xorFree (source : InterpretedSource) := source.calls.xorFree

theorem InterpretedSource.xorFree_meaning (source : InterpretedSource)
    (text : Source) (tv : XorNative.ValidText text) (first after : Nat)
    (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1) :
    source.xorFree text first after = Predicate.xorFree text first after := by
  rw [InterpretedSource.xorFree, source.equations.runtime text tv first after fb ab,
    XorNative.model_meaning source.calls source.equations text tv first after false false true fb ab]
  rfl

/-- The new literal primitive inherits its meaning from the separately checked
native Character_Literal_After body; the remaining premises are the exact xor
model body and executable wrapper equations. No xor scanner meaning is assumed. -/
def inheritedSource {domain : Compose.Expressions.StateDomain}
    (calls : XorNative.Calls) (composed : Compose.Expressions.Calls)
    (helpers : Compose.Expressions.RawHelperEquations composed (domain := domain))
    (linked : calls.characterLiteral = composed.function .characterLiteral)
    (model : ∀ text, XorNative.ValidText text → ∀ position after quoted comment wordStart,
      position ≤ text.length + 1 → after ≤ text.length + 1 →
      calls.model text position after quoted comment wordStart =
        XorNative.body.eval calls ⟨text, position, after, quoted, comment, wordStart⟩)
    (runtime : ∀ text, XorNative.ValidText text → ∀ first after,
      first ≤ text.length + 1 → after ≤ text.length + 1 →
      calls.xorFree text first after = calls.model text first after false false true) :
    InterpretedSource where
  calls := calls
  equations := {
    characterLiteral := by
      intro text tv position pv
      rw [linked]
      exact Compose.Expressions.interpreted_characterLiteral composed helpers text tv position pv
    model := model
    runtime := runtime }

def modelSource : InterpretedSource := ⟨XorNative.modelCalls, XorNative.model_equations⟩

def tokens (text : String) : List String := (Source.lexLine text).getD []

def modelImpl : List String := tokens
  "(Text : String; Position, After : Literal_Position; Quoted, Comment, Word_Start : Boolean) return Boolean"
def modelSpec : List String := modelImpl ++ tokens
  "with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then After <= Text'Last + 1, Subprogram_Variant => (Decreases => (Text'Last + 1) - Position)"
def runtimeImpl : List String := tokens
  "(Text : String; First, After : Literal_Position) return Boolean"
def runtimeSpec : List String := runtimeImpl ++ tokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => (Static => Xor_Free'Result = Xor_Free_Model (Text, First, After, False, False, True))"

/-- The recursive expression and the executable wrapper's exact refinement
contract. The complete source bridge supplies these checks on certified tokens
and the inherited lexical definitions used for raw byte classification. -/
structure Checked (source : List String) : Prop where
  body : Source.expressionBody "xor_free_model" source = some XorNative.body.render
  precedence : XorNative.body.wellFormed = true
  modelSpec : Silver.SourceBridge.functionHeader "xor_free_model" ";" source = some modelSpec
  modelImpl : Silver.SourceBridge.functionHeader "xor_free_model" "is" source = some modelImpl
  runtimeSpec : Silver.SourceBridge.functionHeader "xor_free" ";" source = some runtimeSpec
  runtimeImpl : Silver.SourceBridge.functionHeader "xor_free" "is" source = some runtimeImpl

end Silver.Predicate.XorSourceBridge
