module

public import Silver.PredicateNativeSourceChecks
public import Silver.PredicateNativeHelpers

@[expose] public section

/-! The native predicate source interface. Exact source checks and the documented
Ada/frontend interpretation remain explicit premises. The conclusion derives
recursive scanner meaning from typed body equations, primitive helper meanings,
and the checked domains; scanner equivalence is never an input premise. -/
namespace Silver.Predicate.NativeSourceBridge
open Native Compose

structure InterpretedSource (tokens : List String) (calls : Calls) : Prop where
  source : NativeSourceChecks.Checked tokens
  helpers : HelperMeaning calls
  definitions : DefinitionEquations calls
  contracts : Contracts calls

variable {tokens : List String} {calls : Calls}

theorem interpreted_equations (source : InterpretedSource tokens calls) : Equations calls :=
  equations_of_definitions source.helpers source.definitions source.contracts

theorem summary_correct (source : InterpretedSource tokens calls) (value : ExpressionResult) :
    calls.summary value = summaryOf value := summary_meaning source.definitions value

theorem bound_correct (source : InterpretedSource tokens calls) (binding : Bindings.BindingInfo) :
    calls.bound binding = binding.bound := bound_meaning source.definitions binding

theorem bindingSummary_correct (source : InterpretedSource tokens calls) (binding : Bindings.BindingInfo) :
    calls.bindingSummary binding = LengthSummary.ofExact binding.bound.summary := bindingSummary_meaning source.definitions binding

theorem comparison_correct (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (position : Nat) (bounded : position ≤ text.length + 1) :
    calls.comparison text position = comparisonAt text position :=
  comparison_meaning source.helpers source.definitions text tv position bounded

theorem character_correct (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (context : Native.Context) (cv : ValidContext text context)
    (position : Nat) (bounded : position ≤ text.length + 1) (facts : ActiveFlow)
    (fv : ValidFlow context facts) (initials : ArrayBindings.Initials)
    (iv : ArrayBindings.ValidInitials initials) :
    calls.characterCondition text context position facts initials =
      Predicate.characterCondition text context.model position facts initials :=
  character_meaning source.helpers source.definitions text tv context cv position bounded facts fv initials iv

theorem length_correct (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (context : Native.Context) (cv : ValidContext text context)
    (position : Nat) (literal : Bool) (bounded : position ≤ text.length + 1) :
    calls.length text context position literal = lengthAt text context.model position literal :=
  length_meaning source.helpers source.definitions text tv context cv position literal bounded

theorem booleanAtom_correct (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (context : Native.Context) (cv : ValidContext text context)
    (position : Nat) (bounded : position ≤ text.length + 1) :
    calls.booleanAtom text context position = booleanAtomAfter text context.model position :=
  booleanAtom_meaning source.helpers source.definitions text tv context cv position bounded

theorem chainToken_correct (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (position : Nat) (bounded : position ≤ text.length + 1) :
    calls.chainToken text position = chainTokenModel text position :=
  chainToken_meaning source.helpers source.definitions text tv position bounded

theorem chainAfter_correct (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (position : Nat) (operator : Native.ChainKind)
    (bounded : position ≤ text.length + 1) (valid : operator.isChain = true) :
    calls.chainAfter text position operator = Predicate.chainAfter text position operator.predicate := by
  rw [chainAfter_meaning source.helpers source.definitions text tv position operator bounded valid]
  cases operator <;> simp_all [Native.ChainKind.isChain, chainAfterModel]

theorem condition_correct (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (context : Native.Context) (cv : ValidContext text context)
    (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts)
    (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    calls.condition text context position facts initials = readCondition text context.model position facts initials :=
  condition_of_source_equations source.helpers source.definitions source.contracts
    text tv context cv position bounded facts fv initials iv

theorem condition_valid (source : InterpretedSource tokens calls) (text : Source)
    (tv : ValidText text) (context : Native.Context) (cv : ValidContext text context)
    (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts)
    (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    ValidResult text context (calls.condition text context position facts initials) := by
  rw [condition_correct source text tv context cv position bounded facts fv initials iv]
  exact model_condition_valid text tv context cv position bounded facts fv initials

theorem model_interpreted (checked : NativeSourceChecks.Checked tokens) :
    InterpretedSource tokens modelCalls :=
  ⟨checked, model_helper_meaning, model_definition_equations, model_contracts⟩

theorem source_interface_inhabited (checked : NativeSourceChecks.Checked tokens) :
    ∃ calls, InterpretedSource tokens calls := ⟨modelCalls, model_interpreted checked⟩

end Silver.Predicate.NativeSourceBridge
