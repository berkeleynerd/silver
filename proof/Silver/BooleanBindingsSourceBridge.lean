module

public import Silver.BooleanBindingsNative

@[expose] public section

namespace Silver.BooleanBindings.SourceBridge

/-- Interpretation of the extracted helper equations and native lookup
postcondition. The aggregate source theorem separately supplies their exact
source/token checks. No scanner-equivalence premise is assumed. -/
structure InterpretedSource where
  calls : Native.Calls
  primitives : Native.Primitives calls
  definitions : Native.Equations calls

def InterpretedSource.lookup (source : InterpretedSource) := source.calls.lookup
def InterpretedSource.hidesInteger (source : InterpretedSource) := source.calls.hidesInteger

theorem InterpretedSource.lookup_meaning (source : InterpretedSource)
    (text : Source) (tv : Native.ValidText text) (names : Environment) (nv : ValidEnvironment text names)
    (first after : Nat) (fb : first ≤ text.length + 1) (ab : after ≤ text.length + 1) :
    source.lookup text names first after = BooleanBindings.lookup text names first after :=
  Native.lookup_meaning source.calls source.primitives source.definitions text tv names nv first after fb ab

theorem InterpretedSource.hidesInteger_meaning (source : InterpretedSource)
    (text : Source) (tv : Native.ValidText text) (names : Environment) (nv : ValidEnvironment text names) :
    source.hidesInteger text names = BooleanBindings.hidesInteger text names :=
  Native.hidesInteger_meaning source.calls source.primitives source.definitions text tv names nv

def modelSource : InterpretedSource :=
  ⟨Native.modelCalls, Native.model_primitives, Native.model_equations⟩

end Silver.BooleanBindings.SourceBridge
