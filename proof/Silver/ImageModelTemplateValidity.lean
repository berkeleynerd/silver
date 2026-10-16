module

public import Silver.ImageModelJsonCanonical
public import Silver.ImageModelTemplateData
public import Silver.ImageModelClone

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.TemplateValidity
open JSON

/-- The concrete ASTs use nonnegative numeric tokens. Signed mathematical
endpoints occur in JSON strings and do not require a numeric-token extension. -/
def naturalTokenCheck : List Nat → Bool
  | [] => false
  | first :: rest =>
      if first = 48 then rest.isEmpty
      else decide (49 ≤ first ∧ first ≤ 57) &&
        rest.all (fun digit => decide (48 ≤ digit ∧ digit ≤ 57))

theorem naturalTokenCheck_sound (bytes : List Nat)
    (checked : naturalTokenCheck bytes = true) : IntegerToken bytes := by
  cases bytes with
  | nil => simp [naturalTokenCheck] at checked
  | cons first rest =>
      by_cases zero : first = 48
      · subst first
        have empty : rest = [] := by simpa [naturalTokenCheck] using checked
        subst rest
        exact .zero
      · have positive : (decide (49 ≤ first ∧ first ≤ 57) &&
            rest.all (fun digit => decide (48 ≤ digit ∧ digit ≤ 57))) = true := by
          simpa only [naturalTokenCheck, ite_eq_right zero] using checked
        obtain ⟨nonzero, digits⟩ := Bool.and_eq_true_iff.mp positive
        exact .positive first rest (of_decide_eq_true nonzero)
          (fun digit member => of_decide_eq_true (List.all_eq_true.mp digits digit member))

/-- A positive certificate for the finite array-based Why AST schemas. Object
values are deliberately outside this certificate; this is not a JSON parser. -/
def spellingCheck : Value → Bool
  | .null => true
  | .boolean _ => true
  | .number digits => naturalTokenCheck digits
  | .string characters => characters.all (fun code => decide (code < 127))
  | .array values => (values.map spellingCheck).all id
  | .object _ => false
decreasing_by all_goals decreasing_tactic

/-- Boolean computation supplies only finite leaf facts. The structural proof
constructs the shared grammar witness, independently of any consumer parser. -/
theorem spellingCheck_valid (value : Value) (checked : spellingCheck value = true) :
    Valid value := by
  cases value with
  | null => exact ⟨_, AsciiSpelling.null⟩
  | boolean value =>
      cases value
      · exact ⟨_, AsciiSpelling.false⟩
      · exact ⟨_, AsciiSpelling.true⟩
  | number digits =>
      simp only [spellingCheck] at checked
      exact ⟨_, AsciiSpelling.number digits (naturalTokenCheck_sound digits checked)⟩
  | string characters =>
      simp only [spellingCheck] at checked
      have ascii : ∀ code ∈ characters, code < 127 := by
        intro code member
        exact of_decide_eq_true (List.all_eq_true.mp checked code member)
      exact ⟨_, AsciiSpelling.string characters _
        (StringContent.canonical_of_ascii characters ascii)⟩
  | array values =>
      simp only [spellingCheck, List.all_map, Function.comp_def, id_eq] at checked
      have children : ∀ child ∈ values, AsciiSpelling child child.encode := by
        intro child member
        exact (spellingCheck_valid child (List.all_eq_true.mp checked child member)).canonical
      exact ⟨_, AsciiSpelling.array values _ (elements_canonical values children)⟩
  | object members => simp [spellingCheck] at checked
termination_by sizeOf value
decreasing_by
  have small := List.sizeOf_lt_of_mem ‹_ ∈ values›
  simp_all only [Value.array.sizeOf_spec]
  omega

/-- Every leaf and nested field in each complete selected theory is checked. -/
theorem theory_checked (kind : Native.Theory) :
    spellingCheck (Templates.theoryValue kind) = true := by
  cases kind with
  | integer =>
      simp only [Templates.theoryValue, Templates.integerTheory, spellingCheck,
        List.map_cons, List.map_nil, List.all_cons, List.all_nil, id_eq] <;> decide +kernel
  | string =>
      simp only [Templates.theoryValue, Templates.stringTheory, spellingCheck,
        List.map_cons, List.map_nil, List.all_cons, List.all_nil, id_eq] <;> decide +kernel
  | image =>
      simp only [Templates.theoryValue, Templates.imageTheory, spellingCheck,
        List.map_cons, List.map_nil, List.all_cons, List.all_nil, id_eq] <;> decide +kernel

theorem clone_declaration_checked : spellingCheck Clone.declaration = true := by
  simp only [Clone.declaration, Clone.substitutions, Clone.imageSubstitution,
    Clone.textSubstitution, Clone.scalarImageSubstitution, Clone.stringImageSubstitution,
    Clone.lengthSubstitution, Clone.substitution, Clone.moduleNode, Clone.nameNode,
    Clone.number, Clone.text, spellingCheck, List.map_cons, List.map_nil,
    List.all_cons, List.all_nil, id_eq] <;>
    decide +kernel

theorem clone_include_checked : spellingCheck Clone.includeDeclaration = true := by
  simp only [Clone.includeDeclaration, Clone.moduleNode, Clone.number, Clone.text,
    spellingCheck, List.map_cons, List.map_nil, List.all_cons, List.all_nil, id_eq] <;>
    decide +kernel

theorem theory_valid (kind : Native.Theory) : Valid (Templates.theoryValue kind) :=
  spellingCheck_valid _ (theory_checked kind)

theorem clone_declaration_valid : Valid Clone.declaration :=
  spellingCheck_valid _ clone_declaration_checked

theorem clone_include_valid : Valid Clone.includeDeclaration :=
  spellingCheck_valid _ clone_include_checked

theorem theory_canonical (kind : Native.Theory) :
    AsciiSpelling (Templates.theoryValue kind) (Templates.theoryValue kind).encode :=
  (theory_valid kind).canonical

theorem clone_declaration_canonical :
    AsciiSpelling Clone.declaration Clone.declaration.encode :=
  clone_declaration_valid.canonical

theorem clone_include_canonical :
    AsciiSpelling Clone.includeDeclaration Clone.includeDeclaration.encode :=
  clone_include_valid.canonical

end Silver.ImageModel.TemplateValidity
