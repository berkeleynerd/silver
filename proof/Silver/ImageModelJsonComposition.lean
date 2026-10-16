module

public import Silver.ImageModelAtomResult

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- Matching evidence composes by concatenating the normalized streams. It does
not assume a live candidate or any equality with a selected schema. -/
def Emits (tables : Native.Tables) (before after : Core.State) (normalized : List Nat) : Prop :=
  ∀ kind initial, MatchInvariant (tables.byte kind) (tables.length kind) initial (before.matcher.cells kind) →
    MatchInvariant (tables.byte kind) (tables.length kind) (initial ++ normalized) (after.matcher.cells kind)

theorem Emits.identity (tables : Native.Tables) (state : Core.State) : Emits tables state state [] := by
  intro kind initial invariant
  simpa only [List.append_nil] using invariant

theorem Emits.trans {tables : Native.Tables} {before middle after : Core.State} {left right : List Nat}
    (first : Emits tables before middle left) (second : Emits tables middle after right) :
    Emits tables before after (left ++ right) := by
  intro kind initial invariant
  simpa only [List.append_assoc] using second kind (initial ++ left) (first kind initial invariant)

theorem Emits.of_matcher_eq (tables : Native.Tables) (before after : Core.State)
    (equal : after.matcher = before.matcher) : Emits tables before after [] := by
  intro kind initial invariant
  simpa only [equal, List.append_nil] using invariant

theorem matcher_fold_active (tables : Native.Tables) (matcher : Native.Matcher) (bytes : List Nat) :
    (bytes.foldl (Core.matcher tables) matcher).inTheory = matcher.inTheory := by
  induction bytes generalizing matcher with
  | nil => rfl
  | cons byte rest ih =>
      rw [List.foldl_cons, ih]
      exact Native.match_inTheory tables matcher byte .integer

theorem Emits.of_fold (tables : Native.Tables) (before after : Core.State) (normalized : List Nat)
    (active : before.matcher.inTheory = true)
    (effect : after.matcher = normalized.foldl (Core.matcher tables) before.matcher) :
    Emits tables before after normalized := by
  intro kind initial invariant
  rw [effect, SourceBridge.interpreted_fold tables (Core.matcher tables) ⟨fun _ _ => rfl⟩ _ before.matcher active kind]
  exact match_fold_preserves normalized initial (before.matcher.cells kind) invariant

/-- Fields identifying the enclosing theory, its selected name and insertion
locations. A value nested below its eight top-level fields preserves this view.
Lexical scratch state, bytes and matching cursors have separate observations. -/
structure JsonScope where
  depth : Nat
  phase : TheoryNative.Phase
  theory : Option Native.Theory
  seen : Native.Theory → Bool
  field : Nat
  candidateDeclarations : Nat
  candidateIncludes : Nat
  declarations : Nat
  includes : Nat

def scope (state : Core.State) : JsonScope :=
  ⟨state.depth, state.phase, state.theory, state.seen, state.field,
   state.candidateDeclarations, state.candidateIncludes, state.declarations, state.includes⟩

def Boundary (state : Core.State) : Prop :=
  state.mode = .between ∨ state.mode = .literal ∨
    (state.mode = .number ∧ (state.numberIsId = false ∨ state.numberDigits = true))

def settled (state : Core.State) : Core.State :=
  if state.mode = .number ∨ state.mode = .literal then closedAtom state else state

theorem settled_scope (state : Core.State) : scope (settled state) = scope state := by
  simp only [settled, closedAtom, scope]
  split <;> rfl

theorem settled_matcher (state : Core.State) : (settled state).matcher = state.matcher := by
  simp only [settled, closedAtom]
  split <;> rfl

theorem settled_mode (state : Core.State) (boundary : Boundary state) : (settled state).mode = .between := by
  rcases boundary with mode | mode | ⟨mode, _⟩ <;> simp [settled, closedAtom, mode]

/-- Closing an atom is an observation at a token boundary, not an extra input
byte. The next actual delimiter performs that closure and its structural step
in the single native Consume call. -/
theorem consume_boundary_delimiter (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (boundary : Boundary state) (delimiter : isDelimiter item = true) :
    consume helpers state item = structural helpers (counted (settled state)) item := by
  rcases boundary with mode | mode | ⟨mode, ordinary⟩
  · rw [consume_between helpers state item good room mode]
    simp [settled, mode]
  · rw [consume_atom_delimiter helpers state item good room (.inr mode)
      (by intro number; rw [mode] at number; contradiction) delimiter]
    simp only [settled, mode, or_true, ↓reduceIte, closedAtom, counted]
  · rw [consume_atom_delimiter helpers state item good room (.inl mode)
      (by intro _ isId; rcases ordinary with ordinary | digits; rw [ordinary] at isId; contradiction; exact digits) delimiter]
    simp only [settled, mode, true_or, ↓reduceIte, closedAtom, counted]

theorem atom_effect_emits (tables : Native.Tables) (state : Core.State) (input : List Nat)
    (active : state.matcher.inTheory = true) : Emits tables state (atomEffect tables state input) input :=
  Emits.of_fold tables state _ input active rfl

theorem atom_effect_scope (tables : Native.Tables) (state : Core.State) (input : List Nat) :
    scope (atomEffect tables state input) = scope state := rfl

theorem quoted_result_emits (tables : Native.Tables) (state : Core.State) (characters : List Nat)
    (count left value : Nat) (active : state.matcher.inTheory = true) :
    Emits tables state (quotedResult tables state characters count left value) (JSON.stringBytes characters) :=
  Emits.of_fold tables state _ _ active rfl

theorem nested_string_scope (tables : Native.Tables) (state : Core.State) (characters : List Nat)
    (count left value : Nat) (depth : 4 ≤ state.depth) :
    scope (quotedResult tables state characters count left value) = scope state ∧
      (quotedResult tables state characters count left value).failed = state.failed := by
  have one : state.depth ≠ 1 := by omega
  have three : state.depth ≠ 3 := by omega
  simp [quotedResult, quoteContext, scope, one, three]

theorem nested_array_close_scope (state : Core.State) (depth : 5 ≤ state.depth) :
    scope (closeNestedArray state) = {scope state with depth := state.depth - 1} := by
  have four : state.depth ≠ 4 := by omega
  simp [closeNestedArray, scope, four]

/-- Observations needed to compose one nested value with the following comma or
closing delimiter. Numeric/literal modes remain explicit until that delimiter.
All enclosing name/offset fields are preserved, and matching records the whole
normalized stream regardless of whether a candidate remains alive. -/
structure LocalResult (tables : Native.Tables) (before after : Core.State)
    (input normalized : List Nat) (pending : Bool) : Prop where
  good : after.failed = false
  active : after.matcher.inTheory = true
  context : scope after = scope before
  bytes : after.bytes = before.bytes + input.length
  boundary : Boundary after
  previous : after.previousArrayStart = false
  nodeId : after.nodeIdPending = pending
  emits : Emits tables before after normalized

theorem local_string (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.StringContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth)
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    LocalResult tables state (([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state)
      ([34] ++ input ++ [34]) (JSON.stringBytes characters) (state.previousArrayStart && JSON.nodeTag characters) := by
  obtain ⟨left, value, result⟩ := quoted_string_result tables state characters input encoding good mode notId (.inl active) room
  rw [result]
  have context := nested_string_scope tables state characters (input.length + 2) left value depth
  refine ⟨context.2.trans good, ?_, context.1, ?_, .inl rfl, rfl, rfl, ?_⟩
  · exact (matcher_fold_active tables state.matcher _).trans active
  · simp only [quotedResult, List.length_append, List.length_cons, List.length_nil]
    omega
  · exact quoted_result_emits tables state characters _ left value active

theorem local_integer (tables : Native.Tables) (state : Core.State) (input : List Nat)
    (token : JSON.IntegerToken input) (good : state.failed = false) (mode : state.mode = .between)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (room : state.bytes + input.length ≤ 9223372036854775807) :
    LocalResult tables state (input.foldl (consume (Core.modelHelpers tables)) state) input input false := by
  obtain ⟨digits, result⟩ := ordinary_integer_result tables state input token good mode notId active room
  rw [result]
  refine ⟨good, ?_, rfl, rfl, .inr (.inr ⟨rfl, .inl rfl⟩), rfl, rfl, ?_⟩
  · exact (matcher_fold_active tables state.matcher input).trans active
  · exact Emits.of_fold tables state _ input active rfl

theorem local_literal (tables : Native.Tables) (state : Core.State) (first : Nat) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (start : first = 116 ∨ first = 102 ∨ first = 110)
    (tail : ∀ byte ∈ rest, isDelimiter byte = false)
    (room : state.bytes + (first :: rest).length ≤ 9223372036854775807) :
    LocalResult tables state ((first :: rest).foldl (consume (Core.modelHelpers tables)) state)
      (first :: rest) (first :: rest) false := by
  rw [literal_result tables state first rest good mode notId active start tail room]
  refine ⟨good, ?_, rfl, rfl, .inr (.inl rfl), rfl, notId, ?_⟩
  · exact (matcher_fold_active tables state.matcher _).trans active
  · exact Emits.of_fold tables state _ _ active rfl

theorem local_node_id (tables : Native.Tables) (state : Core.State) (first : Nat) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = true)
    (active : state.matcher.inTheory = true) (word : decimalWord (first :: rest))
    (room : state.bytes + (first :: rest).length ≤ 9223372036854775807)
    (bounded : decimalFold 0 (first :: rest) ≤ originalIdMaximum) :
    LocalResult tables state ((first :: rest).foldl (consume (Core.modelHelpers tables)) state)
      (first :: rest) [48] false := by
  rw [consume_node_id tables state first rest good mode pending active word room bounded]
  refine ⟨good, ?_, rfl, rfl, .inr (.inr ⟨rfl, .inr rfl⟩), rfl, rfl, ?_⟩
  · exact (Native.match_inTheory tables state.matcher 48 .integer).trans active
  · exact Emits.of_fold tables state _ [48] active rfl

end Silver.ImageModel.ScannerNative
