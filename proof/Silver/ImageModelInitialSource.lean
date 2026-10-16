module

public import Silver.ImageModelCoreState

@[expose] public section
namespace Silver.ImageModel.InitialNative

/-- The actual record's field initializers, with both declaration tokens and
their value-setting interpretation. Grouped model observations are updated one
native field at a time. -/
inductive Default
  | failed | bytes | depth | mode | phase | seen | matched | live | inTheory
  | theory | field | candidateDeclarations | candidateIncludes | declarations
  | includes | greatestId | previousArrayStart | nodeIdPending | numberIsId
  | numberValue | numberDigits | isTag | isKey | isName | isTheoryTag
  | stringLength | stringPrefix | unicodeLeft | unicodeValue
  deriving DecidableEq

def Default.name : Default → String
  | .failed => "failed" | .bytes => "bytes" | .depth => "depth"
  | .mode => "mode" | .phase => "phase" | .seen => "seen"
  | .matched => "matched" | .live => "live" | .inTheory => "in_theory"
  | .theory => "theory" | .field => "field"
  | .candidateDeclarations => "candidate_declarations" | .candidateIncludes => "candidate_includes"
  | .declarations => "declarations_offset" | .includes => "includes_offset"
  | .greatestId => "greatest_id" | .previousArrayStart => "previous_array_start"
  | .nodeIdPending => "node_id_pending" | .numberIsId => "number_is_id"
  | .numberValue => "number_value" | .numberDigits => "number_digits"
  | .isTag => "string_is_tag" | .isKey => "string_is_key" | .isName => "string_is_name"
  | .isTheoryTag => "string_is_theory_tag" | .stringLength => "string_length"
  | .stringPrefix => "string_prefix" | .unicodeLeft => "unicode_left" | .unicodeValue => "unicode_value"

def Default.typeTokens : Default → List String
  | .failed | .inTheory | .previousArrayStart | .nodeIdPending | .numberIsId
  | .numberDigits | .isTag | .isKey | .isName | .isTheoryTag => ["boolean"]
  | .bytes | .depth | .candidateDeclarations | .candidateIncludes | .declarations | .includes => ["byte_count"]
  | .greatestId | .numberValue => ["original_node_id"]
  | .mode => ["lexical_mode"] | .phase => ["root_phase"] | .theory => ["theory_kind"]
  | .seen => ["seen_array"] | .matched => ["match_array"] | .live => ["live_array"]
  | .field => ["natural", "range", "0", "..", "8"]
  | .stringLength => ["natural", "range", "0", "..", "22"]
  | .stringPrefix => ["string", "(", "1", "..", "21", ")"]
  | .unicodeLeft => ["natural", "range", "0", "..", "4"]
  | .unicodeValue => ["natural", "range", "0", "..", "65_535"]

def Default.valueTokens : Default → List String
  | .failed | .inTheory | .previousArrayStart | .nodeIdPending | .numberIsId
  | .numberDigits | .isTag | .isKey | .isName | .isTheoryTag => ["false"]
  | .mode => ["between_tokens"] | .phase => ["before_root"] | .theory => ["other_theory"]
  | .seen | .live => ["(", "others", "=>", "false", ")"]
  | .matched => ["(", "others", "=>", "0", ")"]
  | .stringPrefix => ["(", "others", "=>", "' '", ")"]
  | _ => ["0"]

def Default.render (slot : Default) : List String :=
  [slot.name, ":"] ++ slot.typeTokens ++ [":="] ++ slot.valueTokens ++ [";"]

def Default.eval (state : Core.State) : Default → Core.State
  | .failed => {state with failed := false}
  | .bytes => {state with bytes := 0}
  | .depth => {state with depth := 0}
  | .mode => {state with mode := .between}
  | .phase => {state with phase := .beforeRoot}
  | .seen => {state with seen := fun _ => false}
  | .matched => {state with matcher := {state.matcher with cells := fun kind => {state.matcher.cells kind with position := 0}}}
  | .live => {state with matcher := {state.matcher with cells := fun kind => {state.matcher.cells kind with live := false}}}
  | .inTheory => {state with matcher := {state.matcher with inTheory := false}}
  | .theory => {state with theory := none}
  | .field => {state with field := 0}
  | .candidateDeclarations => {state with candidateDeclarations := 0}
  | .candidateIncludes => {state with candidateIncludes := 0}
  | .declarations => {state with declarations := 0}
  | .includes => {state with includes := 0}
  | .greatestId => {state with greatestId := 0}
  | .previousArrayStart => {state with previousArrayStart := false}
  | .nodeIdPending => {state with nodeIdPending := false}
  | .numberIsId => {state with numberIsId := false}
  | .numberValue => {state with numberValue := 0}
  | .numberDigits => {state with numberDigits := false}
  | .isTag => {state with isTag := false}
  | .isKey => {state with isKey := false}
  | .isName => {state with isName := false}
  | .isTheoryTag => {state with isTheoryTag := false}
  | .stringLength => {state with name := {state.name with length := 0}}
  | .stringPrefix => {state with name := {state.name with buffer := fun _ => 32}}
  | .unicodeLeft => {state with unicodeLeft := 0}
  | .unicodeValue => {state with unicodeValue := 0}

def defaults : List Default :=
  [.failed, .bytes, .depth, .mode, .phase, .seen, .matched, .live, .inTheory,
   .theory, .field, .candidateDeclarations, .candidateIncludes, .declarations,
   .includes, .greatestId, .previousArrayStart, .nodeIdPending, .numberIsId,
   .numberValue, .numberDigits, .isTag, .isKey, .isName, .isTheoryTag,
   .stringLength, .stringPrefix, .unicodeLeft, .unicodeValue]

def recordTokens : List String := ["record"] ++ defaults.flatMap Default.render ++ ["end", "record"]

/-- Ada's boxed `others` association evaluates every record field's default. -/
def initialValue (storage : Core.State) : Core.State := defaults.foldl Default.eval storage

theorem initialValue_model (storage : Core.State) : initialValue storage = {} := by rfl

end Silver.ImageModel.InitialNative

namespace Silver.ImageModel.SourceBridge
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem state_default_declarations :
    Silver.Lexical.SourceBridge.recordDeclaration "state" Source.imageModelSpecTokens =
      some InitialNative.recordTokens := by decide +kernel

/-- Both the deferred public constant and its unique private completion are
checked; the private completion uses the record defaults above. -/
theorem initial_state_declarations : Source.declarations "initial_state" Source.imageModelSpecTokens =
    [["constant", "state"], ["constant", "state", ":=", "(", "others", "=>", "<", ">", ")"]] := by
  decide +kernel

/-- The frontend interpretation of the checked boxed-default aggregate. The
arbitrary storage value supplies no initialized observations: every field is
overwritten by the checked record declarations. -/
structure InterpretedInitial (initial : Core.State) : Prop where
  defaults : ∃ storage, initial = InitialNative.initialValue storage

theorem actual_initial (initial : Core.State) (source : InterpretedInitial initial) : initial = {} := by
  obtain ⟨storage, evaluated⟩ := source.defaults
  exact evaluated.trans (InitialNative.initialValue_model storage)

theorem actual_initial_typed (initial : Core.State) (source : InterpretedInitial initial) : initial.Typed := by
  rw [actual_initial initial source]
  exact Core.initial_typed

end Silver.ImageModel.SourceBridge
