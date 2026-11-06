module

public import Silver.PredicateChecking

@[expose] public section

/-! Boolean initialization targets are explicit. Scalar object identities and
array-cell identities share the Boolean store without sharing source names.
Each initializer sees the preceding initialized objects; no stored predicate
facts enter analysis. -/
namespace Silver.Predicate
open Bindings Compose PathFacts

theorem Condition.readable_mono {condition : Condition} {shape : Shape} {arguments : Bool}
    {before after : Boolean.Analysis}
    (increasing : ∀ cell, before.initialized cell = true → after.initialized cell = true)
    (readable : condition.Readable arguments shape before) :
    condition.Readable arguments shape after := by
  induction condition with
  | stringCompare | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral => exact readable
  | booleanName index => exact increasing index readable
  | booleanArrayRead array index =>
      apply (array.allCells_iff after.initialized).mpr
      intro cell inside
      exact increasing cell ((array.allCells_iff before.initialized).mp readable cell inside)
  | parenthesized inner ih | negated inner ih => exact ih readable
  | andThen left right ihl ihr | orElse left right ihl ihr | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      exact ⟨ihl readable.1, ihr readable.2⟩

theorem Condition.checkBounds_mono {condition : Condition} {shape : Shape} {analysis : Integer.Analysis}
    {before after : Boolean.Analysis} {flow : Flow}
    (increasing : ∀ cell, before.initialized cell = true → after.initialized cell = true)
    (checked : condition.checkBounds shape analysis flow before = true) :
    condition.checkBounds shape analysis flow after = true := by
  induction condition generalizing flow with
  | stringCompare | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral => exact checked
  | booleanName index => exact increasing index checked
  | booleanArrayRead array index =>
      simp only [checkBounds, Bool.and_eq_true] at checked ⊢
      refine ⟨?_, checked.2⟩
      apply (array.allCells_iff after.initialized).mpr
      intro cell inside
      exact increasing cell ((array.allCells_iff before.initialized).mp checked.1 cell inside)
  | parenthesized inner ih | negated inner ih => exact ih checked
  | andThen left right ihl ihr | orElse left right ihl ihr | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      simp only [checkBounds, Bool.and_eq_true] at checked ⊢
      exact ⟨ihl checked.1, ihr checked.2⟩

structure BooleanDeclaration where
  target : Nat
  mutable : Bool
  value : Condition
  deriving Repr

/-- The scalar-prefix view remains useful at native declaration boundaries. -/
def booleanInitialAnalysis (count : Nat) : Boolean.Analysis :=
  { initialized := fun index => decide (0 < index ∧ index ≤ count) }

def booleanDeclarationsAnalysis : Boolean.Analysis → List BooleanDeclaration → Boolean.Analysis
  | before, [] => before
  | before, declaration :: rest =>
      booleanDeclarationsAnalysis (before.initialize declaration.target declaration.mutable) rest

def booleanBodyAnalysis (declarations : List BooleanDeclaration) : Boolean.Analysis :=
  booleanDeclarationsAnalysis {} declarations

def BooleanDeclarationsWellFormed (hasArguments : Bool) (shape : Shape) :
    Boolean.Analysis → List BooleanDeclaration → Prop
  | _, [] => True
  | before, declaration :: rest =>
      declaration.target ≠ 0 ∧ before.initialized declaration.target = false ∧
        declaration.value.Grammatical ∧ declaration.value.Readable hasArguments shape before ∧
        BooleanDeclarationsWellFormed hasArguments shape
          (before.initialize declaration.target declaration.mutable) rest

def checkBooleanDeclarations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) :
    Boolean.Analysis → List BooleanDeclaration → Bool
  | _, [] => true
  | before, declaration :: rest =>
      declaration.value.checkBounds shape analysis flow before &&
        checkBooleanDeclarations shape analysis flow
          (before.initialize declaration.target declaration.mutable) rest

theorem booleanDeclarationsAnalysis_append (before : Boolean.Analysis) (first rest : List BooleanDeclaration) :
    booleanDeclarationsAnalysis before (first ++ rest) =
      booleanDeclarationsAnalysis (booleanDeclarationsAnalysis before first) rest := by
  induction first generalizing before with
  | nil => rfl
  | cons declaration following ih => exact ih _

theorem booleanDeclarationsWellFormed_append (arguments : Bool) (shape : Shape)
    (before : Boolean.Analysis) (first rest : List BooleanDeclaration) :
    BooleanDeclarationsWellFormed arguments shape before (first ++ rest) ↔
      BooleanDeclarationsWellFormed arguments shape before first ∧
        BooleanDeclarationsWellFormed arguments shape (booleanDeclarationsAnalysis before first) rest := by
  induction first generalizing before with
  | nil => simp [BooleanDeclarationsWellFormed, booleanDeclarationsAnalysis]
  | cons declaration following ih =>
      simp only [List.cons_append, BooleanDeclarationsWellFormed, booleanDeclarationsAnalysis, ih, and_assoc]

theorem checkBooleanDeclarations_append (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
    (before : Boolean.Analysis) (first rest : List BooleanDeclaration) :
    checkBooleanDeclarations shape analysis flow before (first ++ rest) =
      (checkBooleanDeclarations shape analysis flow before first &&
        checkBooleanDeclarations shape analysis flow (booleanDeclarationsAnalysis before first) rest) := by
  induction first generalizing before with
  | nil => rfl
  | cons declaration following ih =>
      simp only [List.cons_append, checkBooleanDeclarations, booleanDeclarationsAnalysis, ih, Bool.and_assoc]

def executeBooleanDeclarations (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : List BooleanDeclaration → Boolean.Store → Boolean.Store
  | [], booleans => booleans
  | declaration :: rest, booleans =>
      executeBooleanDeclarations values input valid integers rest
        (Boolean.put booleans declaration.target
          (declaration.value.evaluate values input valid integers booleans))

def checkedBooleanDeclarations (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : List BooleanDeclaration → Boolean.Store → Option Boolean.Store
  | [], booleans => some booleans
  | declaration :: rest, booleans =>
      (declaration.value.checkedEvaluate values input valid integers booleans).bind fun value =>
        checkedBooleanDeclarations values input valid integers rest
          (Boolean.put booleans declaration.target value)

def BooleanDeclarationsSafe (shape : Shape) (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) : List BooleanDeclaration → Boolean.Store → Prop
  | [], _ => True
  | declaration :: rest, booleans =>
      declaration.value.Safe shape values input valid integers booleans ∧
        BooleanDeclarationsSafe shape values input valid integers rest
          (Boolean.put booleans declaration.target
            (declaration.value.evaluate values input valid integers booleans))

theorem boolean_declarations_sound {declarations : List BooleanDeclaration} {before : Boolean.Analysis}
    {shape : Shape} {analysis : Integer.Analysis} {flow : Flow} {hasArguments : Bool}
    {values : Values} {input : Source} {valid rejected : Bool} {integers : Integer.Store}
    {booleans : Boolean.Store}
    (wellFormed : BooleanDeclarationsWellFormed hasArguments shape before declarations)
    (checked : checkBooleanDeclarations shape analysis flow before declarations = true)
    (state : Fits shape input values) (allowed : flow.Allows valid input.length rejected integers) :
    BooleanDeclarationsSafe shape values input valid integers declarations booleans ∧
      checkedBooleanDeclarations values input valid integers declarations booleans =
        some (executeBooleanDeclarations values input valid integers declarations booleans) := by
  induction declarations generalizing before booleans with
  | nil => exact ⟨trivial, rfl⟩
  | cons declaration rest ih =>
      simp only [BooleanDeclarationsWellFormed] at wellFormed
      simp only [checkBooleanDeclarations, Bool.and_eq_true] at checked
      have safe := declaration.value.checkBounds_sound (booleans := booleans)
        state wellFormed.2.2.2.1 allowed checked.1
      have agreement := declaration.value.checkedEvaluate_refines safe state
      have following := ih (booleans := Boolean.put booleans declaration.target
        (declaration.value.evaluate values input valid integers booleans)) wellFormed.2.2.2.2 checked.2
      exact ⟨⟨safe, following.1⟩, by
        simpa only [checkedBooleanDeclarations, executeBooleanDeclarations, agreement, Option.bind_some]
          using following.2⟩

theorem boolean_declarations_preserve (declarations : List BooleanDeclaration)
    (values : Values) (input : Source) (valid : Bool) (integers : Integer.Store)
    (booleans : Boolean.Store) {index : Nat}
    (untouched : ∀ declaration ∈ declarations, declaration.target ≠ index) :
    executeBooleanDeclarations values input valid integers declarations booleans index = booleans index := by
  induction declarations generalizing booleans with
  | nil => rfl
  | cons declaration rest ih =>
      rw [executeBooleanDeclarations, ih _ (fun item member => untouched item (by simp [member]))]
      exact Boolean.put_other _ _ _ _ (Ne.symm (untouched declaration (by simp)))

theorem boolean_declarations_analysis_preserves (declarations : List BooleanDeclaration)
    (before : Boolean.Analysis) {index : Nat} (ready : before.initialized index = true) :
    (booleanDeclarationsAnalysis before declarations).initialized index = true := by
  induction declarations generalizing before with
  | nil => exact ready
  | cons declaration rest ih =>
      exact ih _ (before.initialize_preserves declaration.target declaration.mutable index ready)

theorem boolean_declarations_wellFormed_of_independent {declarations : List BooleanDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {arguments : Bool}
    (positive : ∀ declaration ∈ declarations, declaration.target ≠ 0)
    (fresh : ∀ declaration ∈ declarations, before.initialized declaration.target = false)
    (distinct : declarations.Pairwise (fun left right => left.target ≠ right.target))
    (grammar : ∀ declaration ∈ declarations, declaration.value.Grammatical)
    (readable : ∀ declaration ∈ declarations, declaration.value.Readable arguments shape before) :
    BooleanDeclarationsWellFormed arguments shape before declarations := by
  induction declarations generalizing before with
  | nil => trivial
  | cons declaration rest ih =>
      have apart := List.pairwise_cons.mp distinct
      refine ⟨positive declaration (by simp), fresh declaration (by simp),
        grammar declaration (by simp), readable declaration (by simp), ?_⟩
      apply ih
      · intro item member
        exact positive item (by simp [member])
      · intro item member
        rw [(before.initialize_other declaration.target declaration.mutable item.target
          (Ne.symm (apart.1 item member))).1]
        exact fresh item (by simp [member])
      · exact apart.2
      · intro item member
        exact grammar item (by simp [member])
      · intro item member
        apply Condition.readable_mono (fun cell ready =>
          before.initialize_preserves declaration.target declaration.mutable cell ready)
        exact readable item (by simp [member])

theorem checkBooleanDeclarations_of_snapshot {declarations : List BooleanDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {analysis : Integer.Analysis} {flow : Flow}
    (checked : ∀ declaration ∈ declarations,
      declaration.value.checkBounds shape analysis flow before = true) :
    checkBooleanDeclarations shape analysis flow before declarations = true := by
  induction declarations generalizing before with
  | nil => rfl
  | cons declaration rest ih =>
      rw [checkBooleanDeclarations, checked declaration (by simp), Bool.true_and]
      apply ih
      intro item member
      apply Condition.checkBounds_mono (fun cell ready =>
        before.initialize_preserves declaration.target declaration.mutable cell ready)
      exact checked item (by simp [member])

theorem boolean_declarations_analysis_uniform (declarations : List BooleanDeclaration)
    (before : Boolean.Analysis) (mutable : Bool)
    (uniform : ∀ declaration ∈ declarations, declaration.mutable = mutable) :
    booleanDeclarationsAnalysis before declarations =
      { initialized := fun cell => if declarations.any (fun declaration => declaration.target == cell)
          then true else before.initialized cell
        mutable := fun cell => if declarations.any (fun declaration => declaration.target == cell)
          then mutable else before.mutable cell } := by
  induction declarations generalizing before with
  | nil => rfl
  | cons declaration rest ih =>
      rw [booleanDeclarationsAnalysis, ih _ (fun item member => uniform item (by simp [member]))]
      have mutableSame := uniform declaration (by simp)
      congr 1 <;> funext cell
      all_goals
        by_cases same : cell = declaration.target
        · subst cell
          simp only [List.any_cons, beq_self_eq_true, Bool.true_or, ↓reduceIte,
            Boolean.Analysis.initialize, mutableSame, ite_self]
        · have apart := Ne.symm same
          simp only [List.any_cons, Bool.or_eq_true, beq_iff_eq, apart, false_or,
            Boolean.Analysis.initialize, same, ↓reduceIte]


/-- Snapshot execution evaluates every initializer against the same incoming
Boolean store while accumulating writes in a separate result store. -/
def snapshotBooleanDeclarations (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) (incoming : Boolean.Store) :
    List BooleanDeclaration → Boolean.Store → Boolean.Store
  | [], current => current
  | declaration :: rest, current =>
      snapshotBooleanDeclarations values input valid integers incoming rest
        (Boolean.put current declaration.target
          (declaration.value.evaluate values input valid integers incoming))

theorem snapshotBooleanDeclarations_preserve (declarations : List BooleanDeclaration)
    (values : Values) (input : Source) (valid : Bool) (integers : Integer.Store)
    (incoming current : Boolean.Store) {cell : Nat}
    (untouched : ∀ declaration ∈ declarations, declaration.target ≠ cell) :
    snapshotBooleanDeclarations values input valid integers incoming declarations current cell = current cell := by
  induction declarations generalizing current with
  | nil => rfl
  | cons declaration rest ih =>
      rw [snapshotBooleanDeclarations, ih _ (fun item member => untouched item (by simp [member]))]
      exact Boolean.put_other _ _ _ _ (Ne.symm (untouched declaration (by simp)))

theorem snapshotBooleanDeclarations_member {declarations : List BooleanDeclaration}
    {item : BooleanDeclaration} (values : Values) (input : Source) (valid : Bool)
    (integers : Integer.Store) (incoming current : Boolean.Store)
    (distinct : declarations.Pairwise (fun left right => left.target ≠ right.target))
    (member : item ∈ declarations) :
    snapshotBooleanDeclarations values input valid integers incoming declarations current item.target =
      item.value.evaluate values input valid integers incoming := by
  induction declarations generalizing current with
  | nil => cases member
  | cons declaration rest ih =>
      have apart := List.pairwise_cons.mp distinct
      rcases List.mem_cons.mp member with rfl | member
      · rw [snapshotBooleanDeclarations, snapshotBooleanDeclarations_preserve]
        · exact Boolean.put_same ..
        · intro other present
          exact Ne.symm (apart.1 other present)
      · exact ih _ apart.2 member

theorem boolean_declarations_snapshot {declarations : List BooleanDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {arguments : Bool}
    {values : Values} {input : Source} {valid : Bool} {integers : Integer.Store}
    {incoming current : Boolean.Store}
    (fresh : ∀ declaration ∈ declarations, before.initialized declaration.target = false)
    (readable : ∀ declaration ∈ declarations, declaration.value.Readable arguments shape before)
    (safe : ∀ declaration ∈ declarations,
      declaration.value.Safe shape values input valid integers incoming)
    (agree : ∀ cell, before.initialized cell = true → incoming cell = current cell) :
    executeBooleanDeclarations values input valid integers declarations current =
      snapshotBooleanDeclarations values input valid integers incoming declarations current := by
  induction declarations generalizing current with
  | nil => rfl
  | cons declaration rest ih =>
      have same := Condition.evaluate_booleans_congr
        (readable declaration (by simp)) (safe declaration (by simp)) agree
      simp only [executeBooleanDeclarations, snapshotBooleanDeclarations, ← same]
      apply ih
      · intro item member
        exact fresh item (by simp [member])
      · intro item member
        exact readable item (by simp [member])
      · intro item member
        exact safe item (by simp [member])
      · intro cell ready
        have different : cell ≠ declaration.target := by
          intro equal
          have unavailable := fresh declaration (by simp)
          rw [equal, unavailable] at ready
          contradiction
        rw [Boolean.put_other _ _ _ _ different]
        exact agree cell ready

/-- The checked incoming state establishes all snapshot premises directly.
Fresh allocation, rather than an assumed independence property, prevents an
earlier component write from changing any later initializer's meaning. -/
theorem boolean_declarations_snapshot_of_checked {declarations : List BooleanDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {arguments : Bool}
    {analysis : Integer.Analysis} {flow : Flow} {values : Values}
    {input : Source} {valid rejected : Bool} {integers : Integer.Store} {incoming : Boolean.Store}
    (fresh : ∀ declaration ∈ declarations, before.initialized declaration.target = false)
    (readable : ∀ declaration ∈ declarations, declaration.value.Readable arguments shape before)
    (checked : ∀ declaration ∈ declarations,
      declaration.value.checkBounds shape analysis flow before = true)
    (state : Fits shape input values) (allowed : flow.Allows valid input.length rejected integers) :
    executeBooleanDeclarations values input valid integers declarations incoming =
      snapshotBooleanDeclarations values input valid integers incoming declarations incoming := by
  apply boolean_declarations_snapshot fresh readable
  · intro declaration member
    exact declaration.value.checkBounds_sound state (readable declaration member) allowed
      (checked declaration member)
  · intro cell _
    rfl

structure BooleanArrayDeclaration where
  array : Boolean.ArrayDescriptor
  mutable : Bool
  values : List Condition
  deriving Repr

def BooleanArrayDeclaration.initializations (declaration : BooleanArrayDeclaration) : List BooleanDeclaration :=
  declaration.values.zipIdx.map fun entry =>
    ⟨declaration.array.base + entry.2, declaration.mutable, entry.1⟩

@[simp] theorem BooleanArrayDeclaration.initializations_length (declaration : BooleanArrayDeclaration) :
    declaration.initializations.length = declaration.values.length := by
  simp [initializations]

theorem BooleanArrayDeclaration.initializations_member {declaration : BooleanArrayDeclaration}
    {item : BooleanDeclaration} (member : item ∈ declaration.initializations) :
    item.value ∈ declaration.values ∧
      ∃ offset, offset < declaration.values.length ∧ item.target = declaration.array.base + offset := by
  obtain ⟨entry, present, rfl⟩ := List.mem_map.mp member
  exact ⟨List.fst_mem_of_mem_zipIdx present, entry.2,
    by simpa using List.snd_lt_add_of_mem_zipIdx present, rfl⟩

theorem BooleanArrayDeclaration.initializations_distinct (declaration : BooleanArrayDeclaration) :
    declaration.initializations.Pairwise (fun left right => left.target ≠ right.target) := by
  have ordered (values : List Condition) (start : Nat) :
      ((values.zipIdx start).map fun entry =>
        (⟨declaration.array.base + entry.2, declaration.mutable, entry.1⟩ : BooleanDeclaration)).Pairwise
          (fun left right => left.target < right.target) := by
    induction values generalizing start with
    | nil => exact List.Pairwise.nil
    | cons value rest ih =>
        simp only [List.zipIdx_cons, List.map_cons, List.pairwise_cons]
        refine ⟨?_, ih _⟩
        intro item member
        obtain ⟨entry, present, rfl⟩ := List.mem_map.mp member
        have lower := List.le_snd_of_mem_zipIdx present
        dsimp only
        omega
  exact (ordered declaration.values 0).imp (fun less => Nat.ne_of_lt less)

theorem BooleanArrayDeclaration.initializations_target {declaration : BooleanArrayDeclaration}
    {cell : Nat} :
    (∃ item ∈ declaration.initializations, item.target = cell) ↔
      declaration.array.base ≤ cell ∧ cell - declaration.array.base < declaration.values.length := by
  constructor
  · rintro ⟨item, member, same⟩
    obtain ⟨_, offset, inside, target⟩ := BooleanArrayDeclaration.initializations_member member
    omega
  · rintro ⟨lower, inside⟩
    let offset := cell - declaration.array.base
    let value := declaration.values[offset]'inside
    refine ⟨⟨declaration.array.base + offset, declaration.mutable, value⟩, ?_, by dsimp [offset]; omega⟩
    apply List.mem_map.mpr
    refine ⟨(value, offset), ?_, rfl⟩
    apply List.mk_mem_zipIdx_iff_getElem?.mpr
    exact List.getElem?_eq_getElem inside

theorem BooleanArrayDeclaration.initializations_analysis (declaration : BooleanArrayDeclaration)
    (before : Boolean.Analysis) (count : declaration.values.length = declaration.array.length) :
    booleanDeclarationsAnalysis before declaration.initializations =
      declaration.array.initializeAnalysis before declaration.mutable := by
  rw [boolean_declarations_analysis_uniform declaration.initializations before declaration.mutable
    (by intro item member; obtain ⟨entry, _, rfl⟩ := List.mem_map.mp member; rfl)]
  have cells (cell : Nat) :
      declaration.initializations.any (fun item => item.target == cell) =
        decide (declaration.array.ContainsCell cell) := by
    apply Bool.eq_iff_iff.mpr
    simp only [List.any_eq_true, beq_iff_eq, decide_eq_true_eq,
      BooleanArrayDeclaration.initializations_target]
    change (declaration.array.base ≤ cell ∧ cell - declaration.array.base < declaration.values.length) ↔
      (declaration.array.base ≤ cell ∧ cell < declaration.array.base + declaration.array.length)
    rw [count]
    omega
  simp only [cells, Boolean.ArrayDescriptor.initializeAnalysis, decide_eq_true_eq]

theorem BooleanArrayDeclaration.initializations_wellFormed {declaration : BooleanArrayDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {arguments : Bool}
    (positive : 0 < declaration.array.base)
    (fresh : ∀ offset, offset < declaration.values.length →
      before.initialized (declaration.array.base + offset) = false)
    (grammar : ∀ value ∈ declaration.values, value.Grammatical)
    (readable : ∀ value ∈ declaration.values, value.Readable arguments shape before) :
    BooleanDeclarationsWellFormed arguments shape before declaration.initializations := by
  apply boolean_declarations_wellFormed_of_independent
  · intro item member
    obtain ⟨_, offset, _, target⟩ := initializations_member member
    omega
  · intro item member
    obtain ⟨_, offset, inside, target⟩ := initializations_member member
    rw [target]
    exact fresh offset inside
  · exact declaration.initializations_distinct
  · intro item member
    exact grammar item.value (initializations_member member).1
  · intro item member
    exact readable item.value (initializations_member member).1

theorem BooleanArrayDeclaration.initializations_checked {declaration : BooleanArrayDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {analysis : Integer.Analysis} {flow : Flow}
    (checked : ∀ value ∈ declaration.values, value.checkBounds shape analysis flow before = true) :
    checkBooleanDeclarations shape analysis flow before declaration.initializations = true := by
  apply checkBooleanDeclarations_of_snapshot
  intro item member
  exact checked item.value (initializations_member member).1

theorem BooleanArrayDeclaration.initializations_snapshot {declaration : BooleanArrayDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {arguments : Bool}
    {analysis : Integer.Analysis} {flow : Flow} {values : Values}
    {input : Source} {valid rejected : Bool} {integers : Integer.Store} {incoming : Boolean.Store}
    (fresh : ∀ offset, offset < declaration.values.length →
      before.initialized (declaration.array.base + offset) = false)
    (readable : ∀ value ∈ declaration.values, value.Readable arguments shape before)
    (checked : ∀ value ∈ declaration.values, value.checkBounds shape analysis flow before = true)
    (state : Fits shape input values) (allowed : flow.Allows valid input.length rejected integers) :
    executeBooleanDeclarations values input valid integers declaration.initializations incoming =
      snapshotBooleanDeclarations values input valid integers incoming declaration.initializations incoming := by
  apply boolean_declarations_snapshot_of_checked (before := before) (arguments := arguments)
  · intro item member
    obtain ⟨_, offset, inside, target⟩ := initializations_member member
    rw [target]
    exact fresh offset inside
  · intro item member
    exact readable item.value (initializations_member member).1
  · intro item member
    exact checked item.value (initializations_member member).1
  · exact state
  · exact allowed

/-- Each component receives its own incoming-state value. The theorem uses the
source aggregate's exact position, rather than a Boolean encoding in the shared
Integer allocation table. -/
theorem BooleanArrayDeclaration.initializations_value {declaration : BooleanArrayDeclaration}
    {before : Boolean.Analysis} {shape : Shape} {arguments : Bool}
    {analysis : Integer.Analysis} {flow : Flow} {values : Values}
    {input : Source} {valid rejected : Bool} {integers : Integer.Store} {incoming : Boolean.Store}
    (fresh : ∀ offset, offset < declaration.values.length →
      before.initialized (declaration.array.base + offset) = false)
    (readable : ∀ value ∈ declaration.values, value.Readable arguments shape before)
    (checked : ∀ value ∈ declaration.values, value.checkBounds shape analysis flow before = true)
    (state : Fits shape input values) (allowed : flow.Allows valid input.length rejected integers)
    {offset : Nat} (inside : offset < declaration.values.length) :
    declaration.array.project
        (executeBooleanDeclarations values input valid integers declaration.initializations incoming)
        (declaration.array.bounds.lower + offset) =
      declaration.values[offset].evaluate values input valid integers incoming := by
  rw [declaration.initializations_snapshot fresh readable checked state allowed]
  simp only [Boolean.ArrayDescriptor.project, Boolean.ArrayDescriptor.address_offset]
  apply snapshotBooleanDeclarations_member
    (item := ⟨declaration.array.base + offset, declaration.mutable, declaration.values[offset]⟩)
    values input valid integers incoming incoming declaration.initializations_distinct
  apply List.mem_map.mpr
  refine ⟨(declaration.values[offset], offset), ?_, rfl⟩
  exact List.mk_mem_zipIdx_iff_getElem?.mpr (List.getElem?_eq_getElem inside)

end Silver.Predicate
