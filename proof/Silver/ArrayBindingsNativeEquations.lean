module

public import Silver.ArrayBindingsNativeExpressions

@[expose] public section

namespace Silver.ArrayBindings.Native

set_option backward.dsimp.instances true

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ 4096

def Span (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

abbrev BindingType := ArrayBindings.BindingType

def ArrayTypeType (item : ArrayType) : Prop := item.bounds.Bounded ∧ item.componentBounds.Bounded

def TypesType (types : TypeEnvironment) : Prop :=
  types.length ≤ maxTypes ∧ ∀ item ∈ types,
    item.first ≤ 4097 ∧ item.after ≤ 4097 ∧ ArrayTypeType item

def MetadataType (names : Table) : Prop :=
  TypesType names.types ∧ names.items.length ≤ maxBindings ∧
    ∀ item ∈ names.items, item.first ≤ 4097 ∧ item.after ≤ 4097 ∧ BindingType item

def EnvironmentType (environment : Env) : Prop :=
  MetadataType environment.table ∧ environment.used ≤ maxElements ∧ ValidInitials environment.values

def validNameState (text : Source) (first after : Nat) : Bool :=
  decide ((first = 0 ∧ after = 0) ∨ NameSpan text first after)

structure Primitives (calls : Calls) : Prop where
  equalName : ∀ text, ValidText text → ∀ first after otherFirst otherAfter,
    Span text first after → Span text otherFirst otherAfter →
    calls.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter
  validNameState : ∀ text, ValidText text → ∀ first after, first ≤ 4097 → after ≤ 4097 →
    calls.validNameState text first after = validNameState text first after
  isEmpty : ∀ value, value.Bounded → calls.isEmpty value = value.isEmpty
  singleton : ∀ value, Integer.InRange value → calls.singleton value = Integer.Interval.singleton value
  join : ∀ left right, left.Bounded → right.Bounded → calls.join left right = left.join right

structure Equations (calls : Calls) : Prop where
  lookupModel : ∀ text, ValidText text → ∀ names, ValidTable text names → ∀ first after index,
    first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ names.items.length →
    calls.lookupModel text names first after index = lookupBody.eval calls ({text,names,first,after,index} : Context).locals
  lookup : ∀ text, ValidText text → ∀ names, ValidTable text names → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text names first after = calls.lookupModel text names first after names.items.length
  lookupTypeModel : ∀ text, ValidText text → ∀ types, ValidTypes text types → ∀ first after index,
    first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ types.length →
    calls.lookupTypeModel text types first after index =
      lookupTypeBody.eval calls ({text,types,first,after,index} : Context).locals
  lookupType : ∀ text, ValidText text → ∀ types, ValidTypes text types → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookupType text types first after = calls.lookupTypeModel text types first after types.length
  validType : ∀ item, ArrayTypeType item →
    calls.validType item = validTypeBody.eval calls ({typeItem := item} : Context).locals
  validBinding : ∀ item, BindingType item →
    calls.validBinding item = validBindingBody.eval calls ({item} : Context).locals
  validTypes : ∀ text, ValidText text → ∀ types, TypesType types →
    calls.validTypes text types = validTypesBody.eval calls ({text,types} : Context).locals
  validMetadata : ∀ text, ValidText text → ∀ names, MetadataType names →
    calls.validMetadata text names = validMetadataBody.eval calls ({text,names} : Context).locals
  validEnvironment : ∀ text, ValidText text → ∀ environment, EnvironmentType environment →
    calls.validEnvironment text environment = validEnvironmentBody.eval calls ({text,environment} : Context).locals
  hullModel : ∀ values, ValidInitials values → ∀ first last,
    0 < first → first ≤ last → last ≤ maxElements →
    calls.hullModel values first last = hullBody.eval calls ({values,first,last} : Context).locals
  contains : ∀ item indices, BindingType item → indices.Bounded →
    calls.contains item indices = containsBody.eval calls ({item,indices} : Context).locals
  elementSlot : ∀ item indexValue, ValidNativeBinding item → item.viewSlot = 0 → item.bounds.Contains indexValue →
    calls.elementSlot item indexValue = elementSlotBody.eval calls ({item,indexValue} : Context).locals
  readBounds : ∀ names values elaborating target indices,
    names.items.length ≤ maxBindings → ValidInitials values → 0 < target → target ≤ names.items.length →
    ValidNativeBinding (binding names.items target) → ArrayBindings.contains (binding names.items target) indices = true →
    calls.readBounds names values elaborating target indices =
      if elaborating && decide ((binding names.items target).viewSlot = 0) then calls.hullModel values
        (calls.elementSlot (binding names.items target) indices.lower)
        (calls.elementSlot (binding names.items target) indices.upper)
      else (binding names.items target).componentBounds

def lookupEquation (calls : Calls) (text : Source) (names : Table) (first after index : Nat) : Nat :=
  if first = 0 ∨ after ≤ first ∨ index = 0 then 0
  else if calls.equalName text (binding names.items index).first (binding names.items index).after first after
  then index else calls.lookupModel text names first after (index - 1)

def hullEquation (calls : Calls) (values : Initials) (first last : Nat) : Integer.Interval :=
  if first = last then calls.singleton (initialValue values first)
  else calls.join (calls.hullModel values first (last - 1)) (calls.singleton (initialValue values last))

theorem lookup_denotation (calls : Calls) (text : Source) (names : Table) (first after index : Nat) :
    lookupBody.eval calls ({text,names,first,after,index} : Context).locals =
      lookupEquation calls text names first after index := by
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply3, apply2]
  simp [lookupEquation, Bool.or_eq_true, or_assoc]

theorem hull_denotation (calls : Calls) (values : Initials) (first last : Nat) :
    hullBody.eval calls ({values,first,last} : Context).locals = hullEquation calls values first last := by
  dsimp +instances only [hullBody, Expr.eval, Context.locals, Calls.get, apply3, apply2]
  simp [hullEquation]

theorem binding_mem {names : Metadata} {index : Nat} (positive : 0 < index) (bound : index ≤ names.length) :
    binding names index ∈ names := ArrayBindings.binding_mem positive bound

theorem lookupFrom_bound (text : Source) (names : Metadata) (first after index : Nat) :
    lookupFrom text names first after index ≤ index := ArrayBindings.lookupFrom_bound text names first after index

theorem lookup_bound (text : Source) (names : Metadata) (first after : Nat) :
    lookup text names first after ≤ names.length := ArrayBindings.lookup_bound text names first after

theorem hullModel_step (values : Initials) (first last : Nat) (order : first ≤ last) :
    hullModel values first last =
      if first = last then Integer.Interval.singleton (initialValue values first)
      else (hullModel values first (last - 1)).join (Integer.Interval.singleton (initialValue values last)) := by
  by_cases same : first = last
  · subst last
    simp [hullModel, hullFrom, Integer.Interval.join, Integer.Interval.normalize,
      Integer.Interval.empty, Integer.Interval.singleton, Integer.Interval.isEmpty]
  · have previous : last - 1 + 1 - first + 1 = last + 1 - first := by omega
    have finalSlot : first + (last - 1 + 1 - first) = last := by omega
    simp only [same, ↓reduceIte, hullModel]
    rw [← previous, hullFrom, finalSlot]

theorem elementSlot_bounds {item : Binding} (valid : ValidBinding item) {index : Int}
    (inside : item.bounds.Contains index) : 0 < elementSlot item index ∧ elementSlot item index ≤ maxElements := by
  simp only [elementSlot, Integer.Interval.Contains, ValidBinding] at *
  omega

theorem interpreted_lookupModel (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Table) (metadata : ValidTable text names)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ names.items.length) :
    calls.lookupModel text names first after index = lookupFrom text names.items first after index := by
  induction index with
  | zero =>
      rw [equations.lookupModel text valid names metadata first after 0 firstBound afterBound indexBound,
        lookup_denotation]
      simp [lookupEquation, lookupFrom]
  | succ index ih =>
      rw [equations.lookupModel text valid names metadata first after (index + 1) firstBound afterBound indexBound,
        lookup_denotation]
      by_cases bad : first = 0 ∨ after ≤ first
      · simp [lookupEquation, lookupFrom, bad]
      · have itemValid := metadata.binding_valid (by omega) indexBound
        have compared := primitives.equalName text valid (binding names.items (index + 1)).first
          (binding names.items (index + 1)).after first after
          itemValid.1 ⟨by omega,by omega,afterBound⟩
        simp only [lookupEquation, lookupFrom, bad, Nat.add_eq_zero_iff, Nat.one_ne_zero,
          and_false, or_false, ↓reduceIte, compared, Nat.add_sub_cancel, ih (by omega)]

theorem interpreted_lookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Table) (metadata : ValidTable text names)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names.items first after := by
  rw [equations.lookup text valid names metadata first after firstBound afterBound,
    interpreted_lookupModel calls primitives equations text valid names metadata first after names.items.length
      firstBound afterBound (by omega)]
  rfl

theorem lookupType_denotation (calls : Calls) (text : Source) (types : TypeEnvironment)
    (first after index : Nat) :
    lookupTypeBody.eval calls ({text,types,first,after,index} : Context).locals =
      (if first = 0 ∨ after ≤ first ∨ index = 0 then 0
       else if calls.equalName text (arrayType types index).first (arrayType types index).after first after
       then index else calls.lookupTypeModel text types first after (index - 1)) := by
  dsimp +instances only [lookupTypeBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply3, apply2]
  simp [Bool.or_eq_true, or_assoc]

theorem interpreted_lookupTypeModel (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (types : TypeEnvironment) (metadata : ValidTypes text types)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ types.length) :
    calls.lookupTypeModel text types first after index = lookupTypeFrom text types first after index := by
  induction index with
  | zero =>
      rw [equations.lookupTypeModel text valid types metadata first after 0 firstBound afterBound indexBound,
        lookupType_denotation]
      simp [lookupTypeFrom]
  | succ index ih =>
      rw [equations.lookupTypeModel text valid types metadata first after (index + 1) firstBound afterBound indexBound,
        lookupType_denotation]
      by_cases bad : first = 0 ∨ after ≤ first
      · simp [lookupTypeFrom, bad]
      · have itemValid := metadata.type_valid (by omega) indexBound
        have compared := primitives.equalName text valid (arrayType types (index + 1)).first
          (arrayType types (index + 1)).after first after itemValid.1 ⟨by omega, by omega, afterBound⟩
        simp only [lookupTypeFrom, bad, Nat.add_eq_zero_iff, Nat.one_ne_zero,
          and_false, or_false, ↓reduceIte, compared, Nat.add_sub_cancel, ih (by omega)]

theorem interpreted_lookupType (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (types : TypeEnvironment) (metadata : ValidTypes text types)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookupType text types first after = lookupType text types first after := by
  rw [equations.lookupType text valid types metadata first after firstBound afterBound,
    interpreted_lookupTypeModel calls primitives equations text valid types metadata first after types.length
      firstBound afterBound (by omega)]
  rfl

theorem interpreted_hullModel (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (values : Initials) (valid : ValidInitials values) (first last : Nat)
    (positive : 0 < first) (order : first ≤ last) (bounded : last ≤ maxElements) :
    calls.hullModel values first last = hullModel values first last := by
  induction last generalizing first with
  | zero => omega
  | succ last ih =>
      rw [equations.hullModel values valid first (last + 1) positive order bounded, hull_denotation]
      unfold hullEquation
      by_cases same : first = last + 1
      · simp only [same, ↓reduceIte, primitives.singleton _ (initialValue_inRange valid _)]
        rw [hullModel_step values (last + 1) (last + 1) (by omega)]
        simp
      · have before : first ≤ last := by omega
        simp only [same, ↓reduceIte, Nat.add_sub_cancel]
        have prefixBounded : (hullModel values first last).Bounded := hullFrom_bounded valid first _
        have finalBounded : (Integer.Interval.singleton (initialValue values (last + 1))).Bounded :=
          ⟨initialValue_inRange valid _, initialValue_inRange valid _⟩
        rw [ih first positive before (by omega), primitives.singleton _ (initialValue_inRange valid _),
          primitives.join _ _ prefixBounded finalBounded,
          hullModel_step values first (last + 1) order]
        simp only [same, ↓reduceIte, Nat.add_sub_cancel]

theorem interpreted_contains (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (item : Binding) (indices : Integer.Interval) (itemType : BindingType item) (indexType : indices.Bounded) :
    calls.contains item indices = contains item indices := by
  rw [equations.contains item indices itemType indexType]
  change (!calls.isEmpty indices && decide (indices.lower ≥ item.bounds.lower) &&
    decide (indices.upper ≤ item.bounds.upper)) = contains item indices
  rw [primitives.isEmpty indices indexType]
  apply Bool.eq_iff_iff.mpr
  simp [contains, Integer.Interval.isEmpty, Bool.and_eq_true, and_assoc]

theorem interpreted_elementSlot (calls : Calls) (equations : Equations calls)
    (item : Binding) (index : Int) (valid : ValidNativeBinding item) (stored : item.viewSlot = 0) (inside : item.bounds.Contains index) :
    calls.elementSlot item index = elementSlot item index := by
  rw [equations.elementSlot item index valid stored inside]
  change ((item.offset : Int) + 1 + (index - item.bounds.lower)).toNat = elementSlot item index
  simp only [elementSlot, Integer.Interval.Contains] at *
  omega

theorem interpreted_readBounds (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (names : Table) (values : Initials) (elaborating : Bool) (target : Nat) (indices : Integer.Interval)
    (metadataCap : names.items.length ≤ maxBindings) (valuesValid : ValidInitials values)
    (positive : 0 < target) (targetBound : target ≤ names.items.length)
    (itemValid : ValidNativeBinding (binding names.items target)) (inside : contains (binding names.items target) indices = true) :
    calls.readBounds names values elaborating target indices = readViewBounds names.items values elaborating target indices := by
  rw [equations.readBounds names values elaborating target indices metadataCap valuesValid positive targetBound itemValid inside]
  unfold readViewBounds readBounds
  by_cases stored : (binding names.items target).viewSlot = 0
  · have bounds := inside
    simp only [contains, decide_eq_true_eq] at bounds
    have lower : (binding names.items target).bounds.Contains indices.lower := ⟨bounds.2.1, by omega⟩
    have upper : (binding names.items target).bounds.Contains indices.upper := ⟨by omega, bounds.2.2⟩
    rw [interpreted_elementSlot calls equations _ _ itemValid stored lower,
      interpreted_elementSlot calls equations _ _ itemValid stored upper]
    have firstSlot := elementSlot_bounds itemValid.1 lower
    have lastSlot := elementSlot_bounds itemValid.1 upper
    have order : elementSlot (binding names.items target) indices.lower ≤ elementSlot (binding names.items target) indices.upper := by
      simp only [elementSlot]; omega
    rw [interpreted_hullModel calls primitives equations values valuesValid _ _ firstSlot.1 order lastSlot.2]
  · simp [stored]


def modelCalls : Calls where
  lookupModel := fun text names => lookupFrom text names.items
  lookup := fun text names => ArrayBindings.lookup text names.items
  hullModel := ArrayBindings.hullModel
  readBounds := fun names => ArrayBindings.readViewBounds names.items
  contains := ArrayBindings.contains
  elementSlot := ArrayBindings.elementSlot
  equalName := Named.equalName
  isEmpty := Integer.Interval.isEmpty
  singleton := Integer.Interval.singleton
  join := Integer.Interval.join
  validNameState := validNameState
  validBinding := fun item => decide (ValidNativeBinding item)
  validMetadata := fun text names => decide (ValidTable text names)
  validEnvironment := fun text environment => decide (ValidNativeEnvironment text environment)
  lookupTypeModel := lookupTypeFrom
  lookupType := ArrayBindings.lookupType
  validType := fun item => decide (ValidType item)
  validTypes := fun text types => decide (ValidTypes text types)

theorem model_primitives : Primitives modelCalls where
  equalName _ _ _ _ _ _ _ _ := rfl
  validNameState _ _ _ _ _ _ := rfl
  isEmpty _ _ := rfl
  singleton _ _ := rfl
  join _ _ _ _ := rfl

theorem validBinding_meaning (calls : Calls) (primitives : Primitives calls)
    (item : Binding) (typed : BindingType item) :
    validBindingBody.eval calls ({item} : Context).locals = true ↔ ValidNativeBinding item := by
  change (!calls.isEmpty item.bounds && decide (item.length > 0) &&
    decide (item.offset ≤ maxElements - item.length) &&
    decide (item.bounds.upper - item.bounds.lower = (item.length : Int) - 1) &&
    !calls.isEmpty item.componentBounds &&
    (!decide (item.typeId ≠ 0) || !item.isBoolean) &&
    (!decide (item.viewSlot ≠ 0) ||
      (decide (item.typeId ≠ 0) && decide (item.offset = 0) && !item.mutable && !item.isBoolean))) = true ↔
      ValidNativeBinding item
  rw [primitives.isEmpty item.bounds typed.1,
    primitives.isEmpty item.componentBounds typed.2.2.2.1]
  simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true', Integer.Interval.isEmpty,
    decide_eq_false_iff_not, decide_eq_true_eq, ← Decidable.imp_iff_not_or, ValidNativeBinding, ValidBinding, and_assoc]
  have lengthBound := typed.2.2.1
  constructor
  · rintro ⟨nonempty, positive, capacity, exactLength, componentNonempty, nominal, view⟩
    exact ⟨typed.1, by omega, positive, by omega, exactLength, typed.2.2.2.1, by omega,
      typed.2.2.2.2.1, typed.2.2.2.2.2, nominal, view⟩
  · rintro ⟨_, nonempty, positive, capacity, exactLength, _, componentNonempty, _, _, nominal, view⟩
    exact ⟨by omega, positive, by omega, exactLength, by omega, nominal, view⟩

theorem validType_meaning (calls : Calls) (primitives : Primitives calls)
    (item : ArrayType) (typed : ArrayTypeType item) :
    validTypeBody.eval calls ({typeItem := item} : Context).locals = decide (ValidType item) := by
  change (!calls.isEmpty item.bounds && !calls.isEmpty item.componentBounds &&
    decide (item.bounds.upper - item.bounds.lower < (maxElements : Int))) = decide (ValidType item)
  rw [primitives.isEmpty item.bounds typed.1, primitives.isEmpty item.componentBounds typed.2]
  apply Bool.eq_iff_iff.mpr
  rw [decide_eq_true_eq]
  simp only [Bool.and_eq_true, Bool.not_eq_true', Integer.Interval.isEmpty,
    decide_eq_false_iff_not, decide_eq_true_eq, ValidType]
  constructor
  · rintro ⟨⟨nonempty, components⟩, capacity⟩
    exact ⟨typed.1, by omega, typed.2, by omega, capacity⟩
  · rintro ⟨_, nonempty, _, components, capacity⟩
    exact ⟨⟨by omega, by omega⟩, capacity⟩

theorem interpreted_validType (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (item : ArrayType) (typed : ArrayTypeType item) :
    calls.validType item = decide (ValidType item) := by
  rw [equations.validType item typed, validType_meaning calls primitives item typed]

theorem interpreted_validBinding (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (item : Binding) (typed : BindingType item) :
    calls.validBinding item = decide (ValidNativeBinding item) := by
  rw [equations.validBinding item typed]
  exact Bool.eq_iff_iff.mpr ((validBinding_meaning calls primitives item typed).trans (by simp))

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

theorem name_test (calls : Calls) (primitives : Primitives calls) (text : Source) (valid : ValidText text)
    (first after : Nat) (firstBound : first ≤ 4097) (afterBound : after ≤ 4097) :
    (decide (first > 0) && calls.validNameState text first after) = decide (NameSpan text first after) := by
  rw [primitives.validNameState text valid first after firstBound afterBound]
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.and_eq_true, decide_eq_true_eq, validNameState]
  constructor
  · rintro ⟨positive, zero | span⟩
    · omega
    · exact span
  · intro span
    exact ⟨span.1, .inr span⟩

theorem validTypes_meaning (calls : Calls) (primitives : Primitives calls)
    (validType : ∀ item, ArrayTypeType item → calls.validType item = decide (ValidType item))
    (text : Source) (valid : ValidText text) (types : TypeEnvironment) (typed : TypesType types) :
    validTypesBody.eval calls ({text,types} : Context).locals = decide (ValidTypes text types) := by
  change (List.range types.length).all (fun index =>
    decide ((arrayType types (index + 1)).first > 0) &&
      calls.validNameState text (arrayType types (index + 1)).first (arrayType types (index + 1)).after &&
      calls.validType (arrayType types (index + 1))) = decide (ValidTypes text types)
  apply Bool.eq_iff_iff.mpr
  simp only [List.all_eq_true, List.mem_range, decide_eq_true_eq]
  have test (index : Nat) (bound : index < types.length) :=
    typed.2 _ (arrayType_mem (by omega) (by omega : index + 1 ≤ types.length))
  constructor
  · intro checked
    refine ⟨typed.1, ?_⟩
    apply (indexed_all_iff types emptyType (fun item => NameSpan text item.first item.after ∧ ValidType item)).mp
    intro index bound
    have item := checked index bound
    rw [name_test calls primitives text valid _ _ (test index bound).1 (test index bound).2.1,
      validType _ (test index bound).2.2] at item
    simpa only [Bool.and_eq_true, decide_eq_true_eq, arrayType, Nat.add_sub_cancel] using item
  · intro checked
    intro index bound
    rw [name_test calls primitives text valid _ _ (test index bound).1 (test index bound).2.1,
      validType _ (test index bound).2.2]
    simp only [Bool.and_eq_true, decide_eq_true_eq]
    exact checked.2 _ (arrayType_mem (by omega) (by omega))

theorem interpreted_validTypes (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (types : TypeEnvironment) (typed : TypesType types) :
    calls.validTypes text types = decide (ValidTypes text types) := by
  rw [equations.validTypes text valid types typed]
  exact validTypes_meaning calls primitives (interpreted_validType calls primitives equations) text valid types typed

theorem validMetadata_meaning (calls : Calls) (primitives : Primitives calls)
    (validBinding : ∀ item, BindingType item → calls.validBinding item = decide (ValidNativeBinding item))
    (validTypes : ∀ text, ValidText text → ∀ types, TypesType types →
      calls.validTypes text types = decide (ValidTypes text types))
    (text : Source) (valid : ValidText text) (names : Table) (typed : MetadataType names) :
    validMetadataBody.eval calls ({text,names} : Context).locals = decide (ValidTable text names) := by
  change (calls.validTypes text names.types && (List.range names.items.length).all (fun index =>
    let item := binding names.items (index + 1)
    let previous := binding names.items index
    let ty := arrayType names.types item.typeId
    decide (item.first > 0) && calls.validNameState text item.first item.after &&
      calls.validBinding item && decide (item.typeId ≤ names.types.length) &&
      (!decide (item.typeId ≠ 0) || (decide (item.bounds = ty.bounds) &&
        decide (item.componentBounds = ty.componentBounds))) &&
      (!decide (item.viewSlot ≠ 0) || decide (item.viewSlot = index + 1)) &&
      (!decide (index + 1 > 1) ||
        (decide (decide (item.viewSlot = 0) = decide (previous.viewSlot = 0)) &&
          (!decide (item.viewSlot = 0) || decide (item.offset ≥ previous.offset + previous.length)))))) =
      decide (ValidTable text names)
  rw [validTypes text valid names.types typed.1]
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.and_eq_true, List.all_eq_true, List.mem_range, decide_eq_true_eq]
  have itemTyped (index : Nat) (bound : index < names.items.length) :=
    typed.2.2 _ (binding_mem (by omega) (by omega : index + 1 ≤ names.items.length))
  have test (index : Nat) (bound : index < names.items.length) :
      ((binding names.items (index + 1)).first > 0 ∧
        calls.validNameState text (binding names.items (index + 1)).first
          (binding names.items (index + 1)).after = true) ↔
      NameSpan text (binding names.items (index + 1)).first (binding names.items (index + 1)).after := by
    have named := Bool.eq_iff_iff.mp
      (name_test calls primitives text valid _ _ (itemTyped index bound).1 (itemTyped index bound).2.1)
    simpa only [Bool.and_eq_true, decide_eq_true_eq] using named
  simp only [ValidTable, typed.2.1, true_and, List.mem_range]
  constructor
  · rintro ⟨typesValid, checked⟩
    refine ⟨typesValid, ?_⟩
    intro index bound
    have item := checked index bound
    rw [validBinding _ (itemTyped index bound).2.2] at item
    simp only [Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq,
      decide_eq_false_iff_not, decide_eq_decide, ← Decidable.imp_iff_not_or,
      TypeCoherent, Adjacent, and_assoc] at item ⊢
    exact ⟨(test index bound).mp ⟨item.1, item.2.1⟩, item.2.2.1,
      item.2.2.2.1, item.2.2.2.2.1, item.2.2.2.2.2.1,
      fun positive => item.2.2.2.2.2.2 (by omega)⟩
  · rintro ⟨typesValid, checked⟩
    refine ⟨typesValid, ?_⟩
    intro index bound
    rw [validBinding _ (itemTyped index bound).2.2]
    have item := checked index bound
    simp only [Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq,
      decide_eq_false_iff_not, decide_eq_decide, ← Decidable.imp_iff_not_or,
      TypeCoherent, Adjacent, and_assoc] at item ⊢
    have span := (test index bound).mpr item.1
    exact ⟨span.1, span.2, item.2.1, item.2.2.1, item.2.2.2.1, item.2.2.2.2.1,
      fun positive => item.2.2.2.2.2 (by omega)⟩

theorem interpreted_validMetadata (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Table) (typed : MetadataType names) :
    calls.validMetadata text names = decide (ValidTable text names) := by
  rw [equations.validMetadata text valid names typed]
  exact validMetadata_meaning calls primitives (interpreted_validBinding calls primitives equations)
    (interpreted_validTypes calls primitives equations) text valid names typed

theorem validEnvironment_meaning (calls : Calls)
    (validMetadata : ∀ text, ValidText text → ∀ names, MetadataType names →
      calls.validMetadata text names = decide (ValidTable text names))
    (text : Source) (valid : ValidText text) (environment : Env) (typed : EnvironmentType environment) :
    validEnvironmentBody.eval calls ({text,environment} : Context).locals =
      decide (ValidNativeEnvironment text environment) := by
  change (calls.validMetadata text environment.table &&
    (List.range environment.names.length).all (fun index =>
      let item := binding environment.names (index + 1)
      !decide (item.viewSlot = 0) || decide (item.offset + item.length ≤ environment.used))) =
        decide (ValidNativeEnvironment text environment)
  rw [validMetadata text valid environment.table typed.1]
  apply Bool.eq_iff_iff.mpr
  rw [decide_eq_true_eq]
  simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq,
    decide_eq_false_iff_not, ← Decidable.imp_iff_not_or, List.all_eq_true, List.mem_range,
    ValidNativeEnvironment, typed.2.1, typed.2.2, true_and, binding, Nat.add_sub_cancel]
  exact and_congr_right fun _ => indexed_all_iff environment.names emptyBinding
    (fun item => item.viewSlot = 0 → item.offset + item.length ≤ environment.used)

theorem interpreted_validEnvironment (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (environment : Env) (typed : EnvironmentType environment) :
    calls.validEnvironment text environment = decide (ValidNativeEnvironment text environment) := by
  rw [equations.validEnvironment text valid environment typed]
  exact validEnvironment_meaning calls (interpreted_validMetadata calls primitives equations) text valid environment typed

theorem model_equations : Equations modelCalls where
  lookupModel text _ names _ first after index _ _ _ := by
    rw [lookup_denotation]
    cases index <;> simp [lookupEquation, modelCalls, lookupFrom]
    all_goals rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  lookupTypeModel text _ types _ first after index _ _ _ := by
    rw [lookupType_denotation]
    cases index <;> simp [modelCalls, lookupTypeFrom]
    all_goals rfl
  lookupType _ _ _ _ _ _ _ _ := rfl
  validType item typed := (validType_meaning modelCalls model_primitives item typed).symm
  validBinding item typed := Bool.eq_iff_iff.mpr (by
    simp only [modelCalls, decide_eq_true_eq]
    exact (validBinding_meaning modelCalls model_primitives item typed).symm)
  validTypes text valid types typed :=
    (validTypes_meaning modelCalls model_primitives (fun _ _ => rfl) text valid types typed).symm
  validMetadata text valid names typed :=
    (validMetadata_meaning modelCalls model_primitives (fun _ _ => rfl) (fun _ _ _ _ => rfl) text valid names typed).symm
  validEnvironment text valid environment typed :=
    (validEnvironment_meaning modelCalls (fun _ _ _ _ => rfl) text valid environment typed).symm
  hullModel values _ first last _ order _ := by
    rw [hull_denotation]
    exact hullModel_step values first last order
  contains item indices _ _ := by
    change contains item indices = (!indices.isEmpty && decide (indices.lower ≥ item.bounds.lower) &&
      decide (indices.upper ≤ item.bounds.upper))
    apply Bool.eq_iff_iff.mpr
    simp [contains, Integer.Interval.isEmpty, Bool.and_eq_true, and_assoc]
  elementSlot item index _ _ inside := by
    change elementSlot item index = ((item.offset : Int) + 1 + (index - item.bounds.lower)).toNat
    simp only [elementSlot, Integer.Interval.Contains] at *
    omega
  readBounds _ _ _ _ _ _ _ _ _ _ _ := rfl


end Silver.ArrayBindings.Native
