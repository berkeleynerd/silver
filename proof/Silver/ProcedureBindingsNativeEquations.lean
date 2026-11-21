module

public import Silver.ProcedureBindingsNativeExpressions

@[expose] public section

namespace Silver.ProcedureBindings.Native

set_option backward.dsimp.instances true

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ 4096

/-- Native scalar subtypes on the active prefixes. Unused array cells are not
read by these operations; arbitrary values of their native types are permitted. -/
def FormalType (item : Formal) : Prop :=
  item.first ≤ 4097 ∧ item.after ≤ 4097 ∧ item.bounds.Bounded ∧ item.typeId ≤ ArrayBindings.maxTypes

def SignatureType (item : Signature) : Prop :=
  item.first ≤ 4097 ∧ item.after ≤ 4097 ∧ item.formalFirst ≤ maxFormals ∧
    item.count ≤ maxFormals

def MetadataType (procedures : Metadata) : Prop :=
  procedures.items.length ≤ maxProcedures ∧ procedures.parameters.length ≤ maxFormals ∧
    (∀ item ∈ procedures.parameters, FormalType item) ∧
    (∀ item ∈ procedures.items, SignatureType item)

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
  lookupModel : ∀ text, ValidText text → ∀ procedures, ValidMetadata text procedures → ∀ first after index,
    first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ procedures.items.length →
    calls.lookupModel text procedures first after index =
      lookupBody.eval calls ({text,procedures,first,after,index} : Context).locals
  lookup : ∀ text, ValidText text → ∀ procedures, ValidMetadata text procedures → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text procedures first after = calls.lookupModel text procedures first after procedures.items.length
  validMetadata : ∀ text, ValidText text → ∀ procedures, MetadataType procedures →
    calls.validMetadata text procedures = validMetadataBody.eval calls ({text,procedures} : Context).locals
  appendFormal : ∀ procedures, MetadataType procedures → ∀ item, FormalType item →
    procedures.parameters.length < maxFormals →
    calls.appendFormal procedures item = appendFormalBody.eval calls ({procedures,parameter := item} : Context).locals
  append : ∀ procedures, MetadataType procedures → ∀ item, SignatureType item →
    procedures.items.length < maxProcedures →
    calls.append procedures item = appendBody.eval calls ({procedures,item} : Context).locals

def lookupEquation (calls : Calls) (text : Source) (procedures : Metadata) (first after index : Nat) : Nat :=
  if first = 0 ∨ after ≤ first ∨ index = 0 then 0
  else if calls.equalName text (signature procedures index).first (signature procedures index).after first after
  then index else calls.lookupModel text procedures first after (index - 1)

theorem lookup_denotation (calls : Calls) (text : Source) (procedures : Metadata) (first after index : Nat) :
    lookupBody.eval calls ({text,procedures,first,after,index} : Context).locals =
      lookupEquation calls text procedures first after index := by
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply3]
  simp [lookupEquation, Bool.or_eq_true, or_assoc]

theorem interpreted_lookupModel (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (procedures : Metadata) (metadata : ValidMetadata text procedures)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ procedures.items.length) :
    calls.lookupModel text procedures first after index = lookupFrom text procedures first after index := by
  induction index with
  | zero =>
      rw [equations.lookupModel text valid procedures metadata first after 0 firstBound afterBound indexBound,
        lookup_denotation]
      simp [lookupEquation, lookupFrom]
  | succ index ih =>
      rw [equations.lookupModel text valid procedures metadata first after (index + 1) firstBound afterBound indexBound,
        lookup_denotation]
      by_cases bad : first = 0 ∨ after ≤ first
      · simp [lookupEquation, lookupFrom, bad]
      · have itemValid := metadata.2.2.2 _ (signature_mem (by omega) indexBound)
        have compared := primitives.equalName text valid (signature procedures (index + 1)).first
          (signature procedures (index + 1)).after first after
          itemValid.1 ⟨by omega,by omega,afterBound⟩
        simp only [lookupEquation, lookupFrom, bad, Nat.add_eq_zero_iff, Nat.one_ne_zero,
          and_false, or_false, ↓reduceIte, compared, Nat.add_sub_cancel, ih (by omega)]

theorem interpreted_lookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (procedures : Metadata) (metadata : ValidMetadata text procedures)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text procedures first after = lookup text procedures first after := by
  rw [equations.lookup text valid procedures metadata first after firstBound afterBound,
    interpreted_lookupModel calls primitives equations text valid procedures metadata first after procedures.items.length
      firstBound afterBound (by omega)]
  rfl

theorem interpreted_appendFormal (calls : Calls) (equations : Equations calls)
    (procedures : Metadata) (typed : MetadataType procedures) (item : Formal) (itemTyped : FormalType item)
    (capacity : procedures.parameters.length < maxFormals) :
    calls.appendFormal procedures item = appendFormal procedures item := by
  rw [equations.appendFormal procedures typed item itemTyped capacity]
  rfl

theorem interpreted_append (calls : Calls) (equations : Equations calls)
    (procedures : Metadata) (typed : MetadataType procedures) (item : Signature) (itemTyped : SignatureType item)
    (capacity : procedures.items.length < maxProcedures) :
    calls.append procedures item = append procedures item := by
  rw [equations.append procedures typed item itemTyped capacity]
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
      !calls.isEmpty item.bounds &&
      (!decide (item.typeId ≠ 0) || (decide (item.mode = .input) && decide (item.kind = .integer)))) = true ↔ ValidFormal text item := by
  rw [primitives.validNameState text valid _ _ typed.1 typed.2.1,
    primitives.isEmpty _ typed.2.2.1]
  simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq,
    decide_eq_false_iff_not, validNameState, Integer.Interval.isEmpty, ValidFormal]
  constructor
  · rintro ⟨⟨⟨positive, zero | span⟩, nonempty⟩, nominal⟩
    · omega
    · exact ⟨span, typed.2.2.1, by omega, by
      intro active
      rcases nominal with absent | canonical
      · exact False.elim (absent active)
      · exact canonical⟩
  · rintro ⟨span, _, nonempty, nominal⟩
    exact ⟨⟨⟨span.1, .inr span⟩, by omega⟩, by
      by_cases active : item.typeId ≠ 0
      · exact Or.inr (nominal active)
      · exact Or.inl active⟩

theorem signature_test (calls : Calls) (primitives : Primitives calls)
    (text : Source) (valid : ValidText text) (procedures : Metadata) (item : Signature)
    (typed : SignatureType item) :
    (decide (item.first > 0) && calls.validNameState text item.first item.after &&
      decide (item.count > 0) && decide (item.formalFirst > 0) &&
      decide (item.formalFirst ≤ procedures.parameters.length) &&
      decide (item.count ≤ procedures.parameters.length - item.formalFirst + 1)) = true ↔
      ValidSignature text procedures item := by
  rw [primitives.validNameState text valid _ _ typed.1 typed.2.1]
  unfold validNameState
  simp only [Bool.and_eq_true, decide_eq_true_eq, ValidSignature]
  constructor
  · rintro ⟨⟨⟨⟨⟨positive, zero | span⟩, count⟩, first⟩, firstBound⟩, countBound⟩
    · omega
    · exact ⟨span, count, first, firstBound, countBound⟩
  · rintro ⟨span, count, first, firstBound, countBound⟩
    exact ⟨⟨⟨⟨⟨span.1, .inr span⟩, count⟩, first⟩, firstBound⟩, countBound⟩

theorem validMetadata_meaning (calls : Calls) (primitives : Primitives calls)
    (text : Source) (textValid : ValidText text) (procedures : Metadata)
    (typed : MetadataType procedures) :
    validMetadataBody.eval calls ({text,procedures} : Context).locals =
      decide (ValidMetadata text procedures) := by
  apply Bool.eq_iff_iff.mpr
  simp only [decide_eq_true_eq]
  dsimp +instances only [validMetadataBody, Expr.eval, Context.locals, Calls.get,
    Field.get, Locals.withIndex, apply3]
  simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range]
  have formal (index : Nat) (bound : index < procedures.parameters.length) :=
    formal_test calls primitives text textValid (parameter procedures (index + 1))
      (typed.2.2.1 _ (parameter_mem (by omega) (by omega)))
  have item (index : Nat) (bound : index < procedures.items.length) :=
    signature_test calls primitives text textValid procedures (signature procedures (index + 1))
      (typed.2.2.2 _ (signature_mem (by omega) (by omega)))
  simp only [Bool.and_eq_true] at formal item
  simp only [↓reduceIte]
  constructor
  · rintro ⟨formalTests, itemTests⟩
    refine ⟨typed.1, typed.2.1, ?_, ?_⟩
    · apply (indexed_all_iff procedures.parameters emptyFormal (ValidFormal text)).mp
      intro index bound
      simpa only [parameter, Nat.add_sub_cancel] using (formal index bound).mp (formalTests index bound)
    · apply (indexed_all_iff procedures.items emptySignature (ValidSignature text procedures)).mp
      intro index bound
      simpa only [signature, Nat.add_sub_cancel] using (item index bound).mp (itemTests index bound)
  · intro valid
    constructor
    · intro index bound
      exact (formal index bound).mpr (valid.2.2.1 _ (parameter_mem (by omega) (by omega)))
    · intro index bound
      exact (item index bound).mpr (valid.2.2.2 _ (signature_mem (by omega) (by omega)))

theorem interpreted_validMetadata (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (textValid : ValidText text) (procedures : Metadata)
    (typed : MetadataType procedures) :
    calls.validMetadata text procedures = decide (ValidMetadata text procedures) := by
  rw [equations.validMetadata text textValid procedures typed]
  exact validMetadata_meaning calls primitives text textValid procedures typed

def modelCalls : Calls where
  lookupModel := lookupFrom
  lookup := lookup
  equalName := Named.equalName
  validNameState := validNameState
  isEmpty := Integer.Interval.isEmpty
  validMetadata := fun text procedures => decide (ValidMetadata text procedures)
  appendFormal := appendFormal
  append := append

theorem model_primitives : Primitives modelCalls where
  equalName _ _ _ _ _ _ _ _ := rfl
  validNameState _ _ _ _ _ _ := rfl
  isEmpty _ _ := rfl

theorem model_equations : Equations modelCalls where
  lookupModel text _ procedures _ first after index _ _ _ := by
    rw [lookup_denotation]
    cases index <;> simp [lookupEquation, modelCalls, lookupFrom]
    all_goals rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  validMetadata text textValid procedures typed :=
    (validMetadata_meaning modelCalls model_primitives text textValid procedures typed).symm
  appendFormal _ _ _ _ _ := rfl
  append _ _ _ _ _ := rfl

end Silver.ProcedureBindings.Native
