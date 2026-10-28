module

public import Silver.IntegerDeclarations

@[expose] public section

/-! Exact ordered elaboration and the declared-range invariant used throughout
the executable body. Initial mutable reads use declared ranges; executable flow is carried separately. Immutable snapshots retain their initial values, independently of
whether their Ada initializer was a static expression. -/
namespace Silver.Integer

abbrev Mutability := Nat → Bool
def immutable : Mutability := fun _ => false

def Interval.included (source target : Interval) : Bool :=
  source.isEmpty || decide (target.lower ≤ source.lower ∧ source.upper ≤ target.upper)

theorem Interval.included_sound {source target : Interval} {value : Int}
    (included : source.included target = true) (within : source.Contains value) :
    target.Contains value := by
  simp only [Interval.included, contains_nonempty within, Bool.false_or, decide_eq_true_eq] at included
  simp only [Contains] at *
  omega

structure ObjectBinding where
  initial : Int
  bounds : Interval
  mutable : Bool
  deriving DecidableEq, Repr

abbrev ObjectBindings := List ObjectBinding

def ObjectBinding.Valid (binding : ObjectBinding) : Prop :=
  binding.bounds.Bounded ∧ binding.bounds.Contains binding.initial

def ObjectBindings.Valid (bindings : ObjectBindings) : Prop :=
  ∀ binding ∈ bindings, binding.Valid

def ObjectBindings.ranges (bindings : ObjectBindings) : Ranges := fun index =>
  if index = 0 then none else (bindings[index - 1]?).map ObjectBinding.bounds

def ObjectBindings.store (bindings : ObjectBindings) : Store :=
  Constants.store (bindings.map ObjectBinding.initial)

def ObjectBindings.mutability (bindings : ObjectBindings) : Mutability := fun index =>
  if index = 0 then false else ((bindings[index - 1]?).map ObjectBinding.mutable).getD false

theorem ObjectBindings.fits {bindings : ObjectBindings} (valid : bindings.Valid) :
    Fits bindings.ranges bindings.store := by
  intro index bounds found
  simp only [ranges] at found
  split at found
  · contradiction
  · rename_i nonzero
    simp only [Option.map_eq_some_iff] at found
    obtain ⟨binding, present, rfl⟩ := found
    have within := (valid binding (List.mem_of_getElem? present)).2
    simpa only [store, Constants.store, Constants.get, nonzero, ↓reduceIte,
      List.getElem?_map, present, Option.map_some, Option.getD_some] using within

def Declaration.elaborate (constants : Constants) (declaration : Declaration) : ObjectBinding :=
  let value := declaration.value.evaluate constants.store
  ⟨value, if declaration.mutable then declaration.bounds else .singleton value, declaration.mutable⟩

def elaborate : Constants → List Declaration → ObjectBindings
  | _, [] => []
  | constants, declaration :: rest =>
      declaration.elaborate constants :: elaborate (declaration.execute constants) rest

theorem Declaration.elaborate_valid {constants next : Constants} {declaration : Declaration}
    (checked : declaration.check constants = some next) : (declaration.elaborate constants).Valid := by
  have bound := declaration.check_constraint checked
  have range := (declaration.check_sound checked).2.2
  simp only [elaborate, ObjectBinding.Valid]
  split
  · exact bound
  · exact ⟨⟨range, range⟩, (Interval.singleton_contains _ _).mpr rfl⟩

theorem elaborate_valid {constants next : Constants} {declarations : List Declaration}
    (checked : checkDeclarations constants declarations = some next) :
    (elaborate constants declarations).Valid := by
  induction declarations generalizing constants with
  | nil => simp [elaborate, ObjectBindings.Valid]
  | cons declaration rest ih =>
    simp only [checkDeclarations, Option.bind_eq_some_iff] at checked
    obtain ⟨middle, first, remaining⟩ := checked
    have next := (declaration.check_sound first).1
    intro binding member
    simp only [elaborate, List.mem_cons] at member
    rcases member with rfl | member
    · exact declaration.elaborate_valid first
    · exact ih (next ▸ remaining) binding member

theorem elaborate_values (constants : Constants) (declarations : List Declaration) :
    executeDeclarations constants declarations =
      constants ++ (elaborate constants declarations).map ObjectBinding.initial := by
  induction declarations generalizing constants with
  | nil => simp [executeDeclarations, elaborate]
  | cons declaration rest ih =>
    simp only [executeDeclarations, ih, elaborate, List.map_cons,
      Declaration.execute, Declaration.elaborate, List.append_assoc, List.singleton_append]

theorem elaborate_append (constants : Constants) (first rest : List Declaration) :
    elaborate constants (first ++ rest) = elaborate constants first ++
      elaborate (executeDeclarations constants first) rest := by
  induction first generalizing constants with
  | nil => rfl
  | cons declaration remaining ih =>
    simp only [List.cons_append, elaborate, executeDeclarations, ih]

theorem elaborate_initial_store (declarations : List Declaration) :
    (executeDeclarations [] declarations).store = (elaborate [] declarations).store := by
  rw [elaborate_values]
  rfl

structure Assignment where
  target : Nat
  value : Expr
  bounds : Interval := .full
  deriving DecidableEq, Repr

/-- Empty RHS intervals are rejected even in unreachable loop bodies: the
pinned Ada/SPARK frontend still checks statically predictable assignments.
Mathematical interval inclusion itself retains the empty-subset law. -/
def Assignment.check (assignment : Assignment) (ranges : Ranges) (mutable : Mutability)
    (declared : Ranges := ranges) : Bool :=
  mutable assignment.target &&
    match declared assignment.target, assignment.value.infer ranges with
    | some target, some value =>
        decide (assignment.bounds = target) && (!value.isEmpty && value.included target)
    | _, _ => false

def Assignment.execute (assignment : Assignment) (values : Store) : Store :=
  put values assignment.target (assignment.value.evaluate values)

def Assignment.checkedExecute (assignment : Assignment) (values : Store) : Option Store :=
  (assignment.value.checkedEvaluate values).bind fun value =>
    if assignment.bounds.Contains value then some (put values assignment.target value) else none

/-- Replacement records the RHS interval, including singleton assignments. -/
def Assignment.after (assignment : Assignment) (ranges : Ranges) : Ranges :=
  put ranges assignment.target (assignment.value.infer ranges)

theorem Assignment.check_flow_sound {assignment : Assignment} {ranges declared : Ranges}
    {mutable : Mutability} {values : Store}
    (checked : assignment.check ranges mutable declared = true)
    (fits : Fits ranges values) (declaredFits : Fits declared values) :
    assignment.value.Safe values ∧ Fits declared (assignment.execute values) ∧
      Fits (assignment.after ranges) (assignment.execute values) ∧
      assignment.checkedExecute values = some (assignment.execute values) := by
  simp only [check, Bool.and_eq_true] at checked
  cases target : declared assignment.target with
  | none => simp [target] at checked
  | some targetBounds =>
    cases value : assignment.value.infer ranges with
    | none => simp [value, target] at checked
    | some valueBounds =>
      have compatible : assignment.bounds = targetBounds ∧
          valueBounds.isEmpty = false ∧ valueBounds.included targetBounds = true := by
        simpa only [target, value, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] using checked.2
      have inferred := Expr.infer_sound value fits
      have within := Interval.included_sound compatible.2.2 inferred.1
      refine ⟨inferred.2, ?_, ?_, ?_⟩
      · intro index bounds found
        by_cases same : index = assignment.target
        · subst index
          rw [target] at found
          cases found
          simpa only [execute, put, ↓reduceIte] using within
        · simpa only [execute, put, same, ↓reduceIte] using declaredFits index bounds found
      · intro index bounds found
        by_cases same : index = assignment.target
        · subst index
          simp only [after, put, ↓reduceIte, value, Option.some.injEq] at found
          subst bounds
          simpa only [execute, put, ↓reduceIte] using inferred.1
        · simp only [after, put, same, ↓reduceIte] at found
          simpa only [execute, put, same, ↓reduceIte] using fits index bounds found
      · simp only [checkedExecute, Expr.checkedEvaluate_agrees inferred.2, Option.bind_some,
          compatible.1, within, ↓reduceIte, execute]

theorem Assignment.check_sound {assignment : Assignment} {ranges : Ranges} {mutable : Mutability}
    {values : Store} (checked : assignment.check ranges mutable = true) (fits : Fits ranges values) :
    assignment.value.Safe values ∧ Fits ranges (assignment.execute values) ∧
      assignment.checkedExecute values = some (assignment.execute values) := by
  have sound := check_flow_sound checked fits fits
  exact ⟨sound.1, sound.2.1, sound.2.2.2⟩

theorem Assignment.unchanged {assignment : Assignment} {ranges declared : Ranges} {mutable : Mutability}
    {values : Store} (checked : assignment.check ranges mutable declared = true) {index : Nat}
    (readonly : mutable index = false) : assignment.execute values index = values index := by
  simp only [check, Bool.and_eq_true] at checked
  have changed : mutable assignment.target = true := checked.1
  have distinct : index ≠ assignment.target := by
    intro same
    rw [same, changed] at readonly
    contradiction
  simp only [execute, put, distinct, ↓reduceIte]

/-- Ada staticness follows declaration dependencies, never interval width. -/
def Expr.isStatic (names : Mutability) : Expr → Bool
  | .literal _ => true
  | .snapshot _ => false
  | .name index => names index
  | .indexed _ _ => false
  | .positive inner | .negative inner | .parenthesized inner => inner.isStatic names
  | .add left right | .subtract left right | .multiply left right
  | .divide left right | .modulo left right | .remainder left right =>
      left.isStatic names && right.isStatic names

def nameFlags (flags : List Bool) : Mutability := fun index =>
  if index = 0 then false else (flags[index - 1]?).getD false

def declarationStaticFlags : List Bool → List Declaration → List Bool
  | flags, [] => flags
  | flags, declaration :: rest =>
      declarationStaticFlags
        (flags ++ [!declaration.mutable && declaration.value.isStatic (nameFlags flags)]) rest

structure Analysis where
  declared : Ranges
  mutable : Mutability
  static : Mutability
  refinable : Mutability

def Analysis.empty : Analysis := ⟨emptyRanges, immutable, immutable, immutable⟩

def Analysis.ofDeclarations (declarations : List Declaration) : Analysis :=
  let bindings := elaborate [] declarations
  ⟨bindings.ranges, bindings.mutability, nameFlags (declarationStaticFlags [] declarations),
    bindings.mutability⟩

def Analysis.withIndex (analysis : Analysis) (index : Nat) (bounds : Interval) : Analysis :=
  ⟨put analysis.declared index (some bounds), put analysis.mutable index false,
    put analysis.static index false, put analysis.refinable index true⟩

/-- Restore only the lexical index cell after a loop body. All writes to other
scalar objects remain observable by the next iteration and later statements. -/
def restore (before after : Store) (index : Nat) : Store := put after index (before index)

theorem restore_fits {ranges : Ranges} {before after : Store} {index : Nat} {bounds : Interval}
    (original : Fits ranges before) (current : Fits (put ranges index (some bounds)) after) :
    Fits ranges (restore before after index) := by
  intro other interval found
  by_cases same : other = index
  · subst other
    simpa only [restore, put, ↓reduceIte] using original index interval found
  · have present : put ranges index (some bounds) other = some interval := by
      simpa only [put, same, ↓reduceIte] using found
    simpa only [restore, put, same, ↓reduceIte] using current other interval present

end Silver.Integer
