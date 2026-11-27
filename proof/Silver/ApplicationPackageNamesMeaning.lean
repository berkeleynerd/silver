module

public import Silver.ApplicationPackageNamesEquations

@[expose] public section

namespace Silver.ApplicationPackageNames.Native
open Compose Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- Primitive meanings retain the inherited lexical domains. Package metadata
lookups are total on represented values; lexical names are used only after their
source guard has established the required span and source/word bounds. -/
structure PrimitiveMeaning (calls : Calls) : Prop where
  skip : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    calls.skip text position = skipAt text position
  nameAfter : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    calls.nameAfter text position = Compose.nameAfter text position
  takeToken : ∀ text, ValidText text → ∀ position token, ValidCursor text position → ValidToken token →
    calls.takeToken text position token = fixedAfter text position (spelling token) (isWord token)
  nameIs : ∀ text, ValidText text → ∀ first after word, ValidName text first after →
    0 < word.toList.length → word.toList.length ≤ maxSourceLength →
    calls.nameIs text first after word = Named.nameIs text first after (word.toList.map Char.toNat)
  forbidden : ∀ text, ValidText text → ∀ first after, ValidName text first after →
    calls.forbidden text first after = Named.forbiddenName text first after
  validName : ∀ text name, calls.validName text name = PackageBindings.validName (metadataText text) name
  sameName : ∀ text left right,
    calls.sameName text left right = PackageBindings.sameName (metadataText text) left right
  lookupExport : ∀ text info name,
    calls.lookupExport text info name = PackageBindings.lookupExport (metadataText text) info name
  lookupState : ∀ text info name,
    calls.lookupState text info name = PackageBindings.lookupState (metadataText text) info name

theorem model_primitives : PrimitiveMeaning modelCalls where
  skip _ _ _ _ := rfl
  nameAfter _ _ _ _ := rfl
  takeToken _ _ _ _ _ _ := rfl
  nameIs _ _ _ _ _ _ _ _ := rfl
  forbidden _ _ _ _ _ := rfl
  validName _ _ := rfl
  sameName _ _ _ := rfl
  lookupExport _ _ _ := rfl
  lookupState _ _ _ := rfl

theorem validName_domain {text : Source} {name : PackageBindings.NameSpan}
    (valid : PackageBindings.validName (metadataText text) name = true) :
    ValidText text ∧ ValidName text name.first name.after := by
  simp only [PackageBindings.validName, metadataText, Bool.and_eq_true, decide_eq_true_eq] at valid
  exact ⟨⟨valid.1.2.1,valid.1.2.2.1⟩,
    valid.1.2.2.2.1,valid.1.2.2.2.2.1,valid.1.2.2.2.2.2⟩

theorem allowed_meaning (calls : Calls) (primitives : PrimitiveMeaning calls)
    (text : Source) (name : PackageBindings.NameSpan) :
    allowedEquation calls text name = packageNameAllowed text name := by
  unfold allowedEquation packageNameAllowed
  rw [primitives.validName]
  by_cases valid : PackageBindings.validName (metadataText text) name = true
  · have domain := validName_domain valid
    have words (word : String) (positive : 0 < word.toList.length)
        (bounded : word.toList.length ≤ maxSourceLength) :=
      primitives.nameIs text domain.1 name.first name.after word domain.2 positive bounded
    rw [primitives.forbidden text domain.1 name.first name.after domain.2,
      words "main" (by decide) (by decide), words "ada" (by decide) (by decide),
      words "interfaces" (by decide) (by decide), words "system" (by decide) (by decide),
      words "gnat" (by decide) (by decide), words "silver_arguments" (by decide) (by decide),
      words "silver_output_libc" (by decide) (by decide), words "silver_runtime" (by decide) (by decide),
      words "integer" (by decide) (by decide), words "boolean" (by decide) (by decide),
      words "character" (by decide) (by decide)]
  · simp only [Bool.eq_false_iff.mpr valid, Bool.false_and]

theorem fresh_meaning (calls : Calls) (primitives : PrimitiveMeaning calls)
    (text : Source) (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) :
    freshEquation calls text info name = packageNameFresh text info name := by
  unfold freshEquation packageNameFresh
  rw [primitives.validName]
  by_cases valid : PackageBindings.validName (metadataText text) name = true
  · have domain := validName_domain valid
    simp only [primitives.forbidden text domain.1 name.first name.after domain.2,
      primitives.sameName, primitives.lookupExport, primitives.lookupState]
  · simp only [Bool.eq_false_iff.mpr valid, Bool.false_and]

theorem word_meaning (calls : Calls) (primitives : PrimitiveMeaning calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position)
    (word : String) (positive : 0 < word.toList.length) (length : word.toList.length ≤ 16) :
    wordEquation calls text position word = packageWord text position word := by
  dsimp only [wordEquation]
  rw [primitives.skip text valid position bounded,
    primitives.nameAfter text valid _ (model_skip_valid text position bounded)]
  unfold packageWord
  by_cases first : skipAt text position = 0
  · simp [first]
  · by_cases advanced : skipAt text position < Compose.nameAfter text (skipAt text position)
    · have span : ValidName text (skipAt text position) (Compose.nameAfter text (skipAt text position)) :=
        ⟨by omega, advanced, model_name_valid text _⟩
      rw [primitives.nameIs text valid _ _ word span positive (Nat.le_trans length (by decide))]
      simp [first, advanced]
    · simp [first, advanced]

theorem token_bound (text : Source) (position : Nat) (bounded : ValidCursor text position)
    (token : ShellToken) : ValidCursor text (tokenAfter text position token) := by
  cases token <;> try simp [tokenAfter, ValidCursor]
  exact model_fixed_valid text position _ _ bounded

theorem pragma_meaning (calls : Calls) (primitives : PrimitiveMeaning calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position) :
    pragmaEquation calls text position = sparkPragmaAfter text position := by
  have pragmaBound := model_fixed_valid text position "pragma" true bounded
  have modeBound := model_fixed_valid text _ "spark_mode" true pragmaBound
  have openBound := model_fixed_valid text _ "(" false modeBound
  have onBound := model_fixed_valid text _ "on" true openBound
  have closeBound := model_fixed_valid text _ ")" false onBound
  have fixed (cursor : Nat) (word : String) (flag : Bool) (bound : ValidCursor text cursor)
      (token : ValidToken (.fixed word flag)) :
      calls.takeToken text cursor (.fixed word flag) = fixedAfter text cursor word flag :=
    primitives.takeToken text valid cursor (.fixed word flag) bound token
  unfold pragmaEquation sparkPragmaAfter
  simp only [ShellToken.word, ShellToken.symbol]
  rw [fixed position "pragma" true bounded (by unfold ValidToken; decide +kernel),
    fixed _ "spark_mode" true pragmaBound (by unfold ValidToken; decide +kernel),
    fixed _ "(" false modeBound (by unfold ValidToken; decide +kernel),
    fixed _ "on" true openBound (by unfold ValidToken; decide +kernel),
    fixed _ ")" false onBound (by unfold ValidToken; decide +kernel),
    fixed _ ";" false closeBound (by unfold ValidToken; decide +kernel)]

/-- The Function_Type_At premise identifies one imported call, whose full native
state domain is established by the caller/source-library bridge. It does not
assume the result of Package_Type_At or any package admission fact. -/
theorem type_meaning (calls : Calls) (primitives : PrimitiveMeaning calls)
    (text : Source) (valid : ValidText text) (frame : ParserState) (info : PackageBindings.Metadata)
    (position : Nat) (bounded : ValidCursor text position)
    (typeCall : calls.functionType text frame position = functionTypeAt text frame position) :
    typeEquation calls text frame info position = packageTypeAt text frame info position := by
  dsimp only [typeEquation, packageTypeAt]
  rw [primitives.skip text valid position bounded,
    primitives.nameAfter text valid _ (model_skip_valid text position bounded), typeCall,
    primitives.lookupExport, primitives.validName]
  by_cases nameValid : PackageBindings.validName (metadataText text)
      ⟨skipAt text position,Compose.nameAfter text (skipAt text position)⟩ = true
  · have domain := validName_domain nameValid
    rw [primitives.nameIs text valid _ _ "integer" domain.2 (by decide) (by decide)]
  · simp only [Bool.eq_false_iff.mpr nameValid, Bool.not_false, Bool.true_or, ↓reduceIte]

end Silver.ApplicationPackageNames.Native
