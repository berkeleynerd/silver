module

public import Silver.PredicateXorNative

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
