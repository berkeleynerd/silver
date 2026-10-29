module

public import Silver.ArrayBindingsNativeExpressions

@[expose] public section

namespace Silver.ArrayBindings.Native

set_option backward.dsimp.instances true

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ 4096

def Span (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

def BindingType (item : Binding) : Prop :=
  item.bounds.Bounded ∧ item.offset ≤ maxElements ∧ item.length ≤ maxElements ∧
    item.componentBounds.Bounded

structure Primitives (calls : Calls) : Prop where
  equalName : ∀ text, ValidText text → ∀ first after otherFirst otherAfter,
    Span text first after → Span text otherFirst otherAfter →
    calls.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter
  isEmpty : ∀ value, value.Bounded → calls.isEmpty value = value.isEmpty
  singleton : ∀ value, Integer.InRange value → calls.singleton value = Integer.Interval.singleton value
  join : ∀ left right, left.Bounded → right.Bounded → calls.join left right = left.join right

structure Equations (calls : Calls) : Prop where
  lookupModel : ∀ text, ValidText text → ∀ names, ValidMetadata text names → ∀ first after index,
    first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ names.length →
    calls.lookupModel text names first after index = lookupBody.eval calls ({text,names,first,after,index} : Context).locals
  lookup : ∀ text, ValidText text → ∀ names, ValidMetadata text names → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text names first after = calls.lookupModel text names first after names.length
  hullModel : ∀ values, ValidInitials values → ∀ first last,
    0 < first → first ≤ last → last ≤ maxElements →
    calls.hullModel values first last = hullBody.eval calls ({values,first,last} : Context).locals
  contains : ∀ item indices, BindingType item → indices.Bounded →
    calls.contains item indices = containsBody.eval calls ({item,indices} : Context).locals
  elementSlot : ∀ item indexValue, ValidBinding item → item.bounds.Contains indexValue →
    calls.elementSlot item indexValue = elementSlotBody.eval calls ({item,indexValue} : Context).locals
  readBounds : ∀ names values elaborating target indices,
    names.length ≤ maxBindings → ValidInitials values → 0 < target → target ≤ names.length →
    ValidBinding (binding names target) → ArrayBindings.contains (binding names target) indices = true →
    calls.readBounds names values elaborating target indices =
      if elaborating then calls.hullModel values
        (calls.elementSlot (binding names target) indices.lower)
        (calls.elementSlot (binding names target) indices.upper)
      else (binding names target).componentBounds

def lookupEquation (calls : Calls) (text : Source) (names : Metadata) (first after index : Nat) : Nat :=
  if first = 0 ∨ after ≤ first ∨ index = 0 then 0
  else if calls.equalName text (binding names index).first (binding names index).after first after
  then index else calls.lookupModel text names first after (index - 1)

def hullEquation (calls : Calls) (values : Initials) (first last : Nat) : Integer.Interval :=
  if first = last then calls.singleton (initialValue values first)
  else calls.join (calls.hullModel values first (last - 1)) (calls.singleton (initialValue values last))

theorem lookup_denotation (calls : Calls) (text : Source) (names : Metadata) (first after index : Nat) :
    lookupBody.eval calls ({text,names,first,after,index} : Context).locals =
      lookupEquation calls text names first after index := by
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, Calls.get, Field.get, apply5, apply3, apply2]
  simp [lookupEquation, Bool.or_eq_true, or_assoc]

theorem hull_denotation (calls : Calls) (values : Initials) (first last : Nat) :
    hullBody.eval calls ({values,first,last} : Context).locals = hullEquation calls values first last := by
  dsimp +instances only [hullBody, Expr.eval, Context.locals, Calls.get, apply3, apply2]
  simp [hullEquation]

theorem binding_mem {names : Metadata} {index : Nat} (positive : 0 < index) (bound : index ≤ names.length) :
    binding names index ∈ names := by
  have within : index - 1 < names.length := by omega
  simp only [binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

theorem lookupFrom_bound (text : Source) (names : Metadata) (first after index : Nat) :
    lookupFrom text names first after index ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih =>
      simp only [lookupFrom]
      split
      · omega
      · split <;> omega

theorem lookup_bound (text : Source) (names : Metadata) (first after : Nat) :
    lookup text names first after ≤ names.length := lookupFrom_bound text names first after names.length

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
    (text : Source) (valid : ValidText text) (names : Metadata) (metadata : ValidMetadata text names)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ names.length) :
    calls.lookupModel text names first after index = lookupFrom text names first after index := by
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
      · have itemValid := metadata.2.1 _ (binding_mem (by omega) indexBound)
        have compared := primitives.equalName text valid (binding names (index + 1)).first
          (binding names (index + 1)).after first after
          ⟨itemValid.1,itemValid.2.1,itemValid.2.2.1⟩ ⟨by omega,by omega,afterBound⟩
        simp only [lookupEquation, lookupFrom, bad, Nat.add_eq_zero_iff, Nat.one_ne_zero,
          and_false, or_false, ↓reduceIte, compared, Nat.add_sub_cancel, ih (by omega)]

theorem interpreted_lookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Metadata) (metadata : ValidMetadata text names)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names first after := by
  rw [equations.lookup text valid names metadata first after firstBound afterBound,
    interpreted_lookupModel calls primitives equations text valid names metadata first after names.length
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
    (item : Binding) (index : Int) (valid : ValidBinding item) (inside : item.bounds.Contains index) :
    calls.elementSlot item index = elementSlot item index := by
  rw [equations.elementSlot item index valid inside]
  change ((item.offset : Int) + 1 + (index - item.bounds.lower)).toNat = elementSlot item index
  simp only [elementSlot, Integer.Interval.Contains] at *
  omega

theorem interpreted_readBounds (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (names : Metadata) (values : Initials) (elaborating : Bool) (target : Nat) (indices : Integer.Interval)
    (metadataCap : names.length ≤ maxBindings) (valuesValid : ValidInitials values)
    (positive : 0 < target) (targetBound : target ≤ names.length)
    (itemValid : ValidBinding (binding names target)) (inside : contains (binding names target) indices = true) :
    calls.readBounds names values elaborating target indices = readBounds names values elaborating target indices := by
  rw [equations.readBounds names values elaborating target indices metadataCap valuesValid positive targetBound itemValid inside]
  have bounds := inside
  simp only [contains, decide_eq_true_eq] at bounds
  have lower : (binding names target).bounds.Contains indices.lower := ⟨bounds.2.1, by omega⟩
  have upper : (binding names target).bounds.Contains indices.upper := ⟨by omega, bounds.2.2⟩
  rw [interpreted_elementSlot calls equations _ _ itemValid lower,
    interpreted_elementSlot calls equations _ _ itemValid upper]
  have firstSlot := elementSlot_bounds itemValid lower
  have lastSlot := elementSlot_bounds itemValid upper
  have order : elementSlot (binding names target) indices.lower ≤ elementSlot (binding names target) indices.upper := by
    simp only [elementSlot]; omega
  rw [interpreted_hullModel calls primitives equations values valuesValid _ _ firstSlot.1 order lastSlot.2]
  rfl

def modelCalls : Calls where
  lookupModel := lookupFrom
  lookup := ArrayBindings.lookup
  hullModel := ArrayBindings.hullModel
  readBounds := ArrayBindings.readBounds
  contains := ArrayBindings.contains
  elementSlot := ArrayBindings.elementSlot
  equalName := Named.equalName
  isEmpty := Integer.Interval.isEmpty
  singleton := Integer.Interval.singleton
  join := Integer.Interval.join

theorem model_primitives : Primitives modelCalls where
  equalName _ _ _ _ _ _ _ _ := rfl
  isEmpty _ _ := rfl
  singleton _ _ := rfl
  join _ _ _ _ := rfl

theorem validBinding_meaning (calls : Calls) (primitives : Primitives calls)
    (item : Binding) (typed : BindingType item) :
    validBindingBody.eval calls ({item} : Context).locals = true ↔ ValidBinding item := by
  change (((!calls.isEmpty item.bounds && decide (item.length > 0) &&
    decide (item.offset ≤ maxElements - item.length)) &&
    decide (item.bounds.upper - item.bounds.lower = (item.length : Int) - 1)) &&
    !calls.isEmpty item.componentBounds) = true ↔ ValidBinding item
  rw [primitives.isEmpty item.bounds typed.1,
    primitives.isEmpty item.componentBounds typed.2.2.2]
  simp only [Bool.and_eq_true, Integer.Interval.isEmpty, not_decide_eq_true,
    decide_eq_true_eq, ValidBinding, and_assoc]
  have lengthBound := typed.2.2.1
  constructor
  · rintro ⟨nonempty, positive, capacity, exact, componentNonempty⟩
    exact ⟨typed.1, by omega, positive, by omega, exact, typed.2.2.2, by omega⟩
  · rintro ⟨_, nonempty, positive, capacity, exact, _, componentNonempty⟩
    exact ⟨by omega, positive, by omega, exact, by omega⟩

theorem model_equations : Equations modelCalls where
  lookupModel text _ names _ first after index _ _ _ := by
    rw [lookup_denotation]
    cases index <;> simp [lookupEquation, modelCalls, lookupFrom]
    all_goals rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  hullModel values _ first last _ order _ := by
    rw [hull_denotation]
    exact hullModel_step values first last order
  contains item indices _ _ := by
    change contains item indices = (!indices.isEmpty && decide (indices.lower ≥ item.bounds.lower) &&
      decide (indices.upper ≤ item.bounds.upper))
    apply Bool.eq_iff_iff.mpr
    simp [contains, Integer.Interval.isEmpty, Bool.and_eq_true, and_assoc]
  elementSlot item index _ inside := by
    change elementSlot item index = ((item.offset : Int) + 1 + (index - item.bounds.lower)).toNat
    simp only [elementSlot, Integer.Interval.Contains] at *
    omega
  readBounds _ _ _ _ _ _ _ _ _ _ _ := rfl

end Silver.ArrayBindings.Native
