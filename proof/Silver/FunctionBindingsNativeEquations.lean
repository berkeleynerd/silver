module

public import Silver.FunctionBindingsNativeExpressions

@[expose] public section

namespace Silver.FunctionBindings.Native

set_option backward.dsimp.instances true

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ 4096

/-- Native scalar subtypes on the active prefixes. Unused array cells are not
read by these operations; arbitrary values of their native types are permitted. -/
def FormalType (item : Formal) : Prop :=
  item.first ≤ 4097 ∧ item.after ≤ 4097 ∧ item.bounds.Bounded

def SignatureType (item : Signature) : Prop :=
  item.first ≤ 4097 ∧ item.after ≤ 4097 ∧ item.formalFirst ≤ maxFormals ∧
    item.count ≤ maxFormals ∧ item.resultBounds.Bounded

def MetadataType (functions : Metadata) : Prop :=
  functions.items.length ≤ maxFunctions ∧ functions.parameters.length ≤ maxFormals ∧
    (∀ item ∈ functions.parameters, FormalType item) ∧
    (∀ item ∈ functions.items, SignatureType item)

def validNameState (text : Source) (first after : Nat) : Bool :=
  decide ((first = 0 ∧ after = 0) ∨ NameSpan text first after)

structure Primitives (calls : Calls) : Prop where
  equalName : ∀ text, ValidText text → ∀ first after otherFirst otherAfter,
    NameSpan text first after → NameSpan text otherFirst otherAfter →
    calls.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter
  validNameState : ∀ text, ValidText text → ∀ first after, first ≤ 4097 → after ≤ 4097 →
    calls.validNameState text first after = validNameState text first after
  isEmpty : ∀ value, value.Bounded → calls.isEmpty value = value.isEmpty

/-- Lookup's equation is its verified static postcondition. The other equations
interpret the checked expression bodies, on the actual native input domains. -/
structure Equations (calls : Calls) : Prop where
  lookupModel : ∀ text, ValidText text → ∀ functions, ValidMetadata text functions → ∀ first after index,
    first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ functions.items.length →
    calls.lookupModel text functions first after index =
      lookupBody.eval calls ({text,functions,first,after,index} : Context).locals
  lookup : ∀ text, ValidText text → ∀ functions, ValidMetadata text functions → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text functions first after = calls.lookupModel text functions first after functions.items.length
  validMetadata : ∀ text, ValidText text → ∀ functions, MetadataType functions →
    calls.validMetadata text functions = validMetadataBody.eval calls ({text,functions} : Context).locals
  appendFormal : ∀ functions, MetadataType functions → ∀ item, FormalType item →
    functions.parameters.length < maxFormals →
    calls.appendFormal functions item = appendFormalBody.eval calls ({functions,parameter := item} : Context).locals
  append : ∀ functions, MetadataType functions → ∀ item, SignatureType item →
    functions.items.length < maxFunctions →
    calls.append functions item = appendBody.eval calls ({functions,item} : Context).locals

def lookupEquation (calls : Calls) (text : Source) (functions : Metadata) (first after index : Nat) : Nat :=
  if first = 0 ∨ after ≤ first ∨ index = 0 then 0
  else if calls.equalName text (signature functions index).first (signature functions index).after first after
  then index else calls.lookupModel text functions first after (index - 1)

theorem lookup_denotation (calls : Calls) (text : Source) (functions : Metadata) (first after index : Nat) :
    lookupBody.eval calls ({text,functions,first,after,index} : Context).locals =
      lookupEquation calls text functions first after index := by
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply3]
  simp [lookupEquation, Bool.or_eq_true, or_assoc]

theorem interpreted_lookupModel (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (functions : Metadata) (metadata : ValidMetadata text functions)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ functions.items.length) :
    calls.lookupModel text functions first after index = lookupFrom text functions first after index := by
  induction index with
  | zero =>
      rw [equations.lookupModel text valid functions metadata first after 0 firstBound afterBound indexBound,
        lookup_denotation]
      simp [lookupEquation, lookupFrom]
  | succ index ih =>
      rw [equations.lookupModel text valid functions metadata first after (index + 1) firstBound afterBound indexBound,
        lookup_denotation]
      by_cases bad : first = 0 ∨ after ≤ first
      · simp [lookupEquation, lookupFrom, bad]
      · have itemValid := metadata.2.2.2 _ (signature_mem (by omega) indexBound)
        have compared := primitives.equalName text valid (signature functions (index + 1)).first
          (signature functions (index + 1)).after first after
          itemValid.1 ⟨by omega,by omega,afterBound⟩
        simp only [lookupEquation, lookupFrom, bad, Nat.add_eq_zero_iff, Nat.one_ne_zero,
          and_false, or_false, ↓reduceIte, compared, Nat.add_sub_cancel, ih (by omega)]

theorem interpreted_lookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (functions : Metadata) (metadata : ValidMetadata text functions)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text functions first after = lookup text functions first after := by
  rw [equations.lookup text valid functions metadata first after firstBound afterBound,
    interpreted_lookupModel calls primitives equations text valid functions metadata first after functions.items.length
      firstBound afterBound (by omega)]
  rfl

theorem interpreted_appendFormal (calls : Calls) (equations : Equations calls)
    (functions : Metadata) (typed : MetadataType functions) (item : Formal) (itemTyped : FormalType item)
    (capacity : functions.parameters.length < maxFormals) :
    calls.appendFormal functions item = appendFormal functions item := by
  rw [equations.appendFormal functions typed item itemTyped capacity]
  rfl

theorem interpreted_append (calls : Calls) (equations : Equations calls)
    (functions : Metadata) (typed : MetadataType functions) (item : Signature) (itemTyped : SignatureType item)
    (capacity : functions.items.length < maxFunctions) :
    calls.append functions item = append functions item := by
  rw [equations.append functions typed item itemTyped capacity]
  rfl

theorem indexed_all_iff {α : Type} (items : List α) (fallback : α) (test : α → Prop) :
    (∀ index, index < items.length → test (items.getD index fallback)) ↔ ∀ item ∈ items, test item := by
  constructor
  · intro checked item member
    obtain ⟨index, bound, equal⟩ := List.mem_iff_getElem.mp member
    have found := checked index bound
    simpa [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem bound, equal] using found
  · intro checked index bound
    apply checked
    simp only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem bound, Option.getD_some]
    exact List.getElem_mem bound

theorem formal_test (calls : Calls) (primitives : Primitives calls)
    (text : Source) (valid : ValidText text) (item : Formal) (typed : FormalType item) :
    (decide (item.first > 0) && calls.validNameState text item.first item.after &&
      !calls.isEmpty item.bounds) = true ↔ ValidFormal text item := by
  rw [primitives.validNameState text valid _ _ typed.1 typed.2.1,
    primitives.isEmpty _ typed.2.2]
  unfold validNameState
  simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq,
    Integer.Interval.isEmpty, decide_eq_false_iff_not, ValidFormal]
  constructor
  · rintro ⟨⟨positive, zero | span⟩, nonempty⟩
    · omega
    · exact ⟨span, typed.2.2, by omega⟩
  · rintro ⟨span, _, nonempty⟩
    exact ⟨⟨span.1, .inr span⟩, by omega⟩

theorem signature_test (calls : Calls) (primitives : Primitives calls)
    (text : Source) (valid : ValidText text) (functions : Metadata) (item : Signature)
    (typed : SignatureType item) :
    (decide (item.first > 0) && calls.validNameState text item.first item.after &&
      decide (item.count > 0) && decide (item.formalFirst > 0) &&
      decide (item.formalFirst ≤ functions.parameters.length) &&
      decide (item.count ≤ functions.parameters.length - item.formalFirst + 1) &&
      !calls.isEmpty item.resultBounds) = true ↔ ValidSignature text functions item := by
  rw [primitives.validNameState text valid _ _ typed.1 typed.2.1,
    primitives.isEmpty _ typed.2.2.2.2]
  unfold validNameState
  simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq,
    Integer.Interval.isEmpty, decide_eq_false_iff_not, ValidSignature]
  constructor
  · rintro ⟨⟨⟨⟨⟨⟨positive, zero | span⟩, count⟩, first⟩, firstBound⟩, countBound⟩, nonempty⟩
    · omega
    · exact ⟨span, count, first, firstBound, countBound, typed.2.2.2.2, by omega⟩
  · rintro ⟨span, count, first, firstBound, countBound, _, nonempty⟩
    exact ⟨⟨⟨⟨⟨⟨span.1, .inr span⟩, count⟩, first⟩, firstBound⟩, countBound⟩, by omega⟩

theorem validMetadata_meaning (calls : Calls) (primitives : Primitives calls)
    (text : Source) (textValid : ValidText text) (functions : Metadata)
    (typed : MetadataType functions) :
    validMetadataBody.eval calls ({text,functions} : Context).locals =
      decide (ValidMetadata text functions) := by
  apply Bool.eq_iff_iff.mpr
  simp only [decide_eq_true_eq]
  dsimp +instances only [validMetadataBody, Expr.eval, Context.locals, Calls.get,
    Field.get, Locals.withIndex, apply3]
  simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range]
  have formal (index : Nat) (bound : index < functions.parameters.length) :=
    formal_test calls primitives text textValid (parameter functions (index + 1))
      (typed.2.2.1 _ (parameter_mem (by omega) (by omega)))
  have item (index : Nat) (bound : index < functions.items.length) :=
    signature_test calls primitives text textValid functions (signature functions (index + 1))
      (typed.2.2.2 _ (signature_mem (by omega) (by omega)))
  simp only [Bool.and_eq_true] at formal item
  simp only [↓reduceIte]
  constructor
  · rintro ⟨formalTests, itemTests⟩
    refine ⟨typed.1, typed.2.1, ?_, ?_⟩
    · apply (indexed_all_iff functions.parameters emptyFormal (ValidFormal text)).mp
      intro index bound
      simpa only [parameter, Nat.add_sub_cancel] using (formal index bound).mp (formalTests index bound)
    · apply (indexed_all_iff functions.items emptySignature (ValidSignature text functions)).mp
      intro index bound
      simpa only [signature, Nat.add_sub_cancel] using (item index bound).mp (itemTests index bound)
  · intro valid
    constructor
    · intro index bound
      exact (formal index bound).mpr (valid.2.2.1 _ (parameter_mem (by omega) (by omega)))
    · intro index bound
      exact (item index bound).mpr (valid.2.2.2 _ (signature_mem (by omega) (by omega)))

theorem interpreted_validMetadata (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (textValid : ValidText text) (functions : Metadata)
    (typed : MetadataType functions) :
    calls.validMetadata text functions = decide (ValidMetadata text functions) := by
  rw [equations.validMetadata text textValid functions typed]
  exact validMetadata_meaning calls primitives text textValid functions typed

def modelCalls : Calls where
  lookupModel := lookupFrom
  lookup := lookup
  equalName := Named.equalName
  validNameState := validNameState
  isEmpty := Integer.Interval.isEmpty
  validMetadata := fun text functions => decide (ValidMetadata text functions)
  appendFormal := appendFormal
  append := append

theorem model_primitives : Primitives modelCalls where
  equalName _ _ _ _ _ _ _ _ := rfl
  validNameState _ _ _ _ _ _ := rfl
  isEmpty _ _ := rfl

theorem model_equations : Equations modelCalls where
  lookupModel text _ functions _ first after index _ _ _ := by
    rw [lookup_denotation]
    cases index <;> simp [lookupEquation, modelCalls, lookupFrom]
    all_goals rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  validMetadata text textValid functions typed :=
    (validMetadata_meaning modelCalls model_primitives text textValid functions typed).symm
  appendFormal _ _ _ _ _ := rfl
  append _ _ _ _ _ := rfl

end Silver.FunctionBindings.Native
