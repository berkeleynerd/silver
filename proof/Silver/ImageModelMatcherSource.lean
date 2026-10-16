module

public import Silver.ImageModelMatcherNative
public import Silver.ImageModelSourceShape
public import Silver.ImageModelBodyCertificate
public import Silver.ImageModelSpecCertificate
public import Silver.SourceDeclarations

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.SourceBridge

/-- Recover one complete named imperative block, including its signature.
Exact whole-file context below excludes nested or overloaded hidden bindings. -/
def throughEnd (name : String) : List String → Option (List String)
  | [] => none
  | "end" :: actual :: ";" :: tail =>
      if actual = name then some ["end", actual, ";"]
      else (throughEnd name (actual :: ";" :: tail)).map ("end" :: ·)
  | item :: tail => (throughEnd name tail).map (item :: ·)

def blocks (category name : String) : List String → List (List String)
  | [] => []
  | kind :: actual :: tail =>
      let rest := blocks category name (actual :: tail)
      if kind = category ∧ actual = name then
        match throughEnd name tail with
        | some body => (kind :: actual :: body) :: rest
        | none => rest
      else rest
  | [_] => []

def block (category name : String) (tokens : List String) : Option (List String) :=
  match blocks category name tokens with
  | [body] => some body
  | _ => none

theorem spec_shape : Source.imageModelSpecTokens = SourceShape.spec := by decide +kernel

theorem body_shape : Source.imageModelBodyTokens = SourceShape.body := by decide +kernel

/-- Finite commands have both source and transition meaning. This check binds
the exact actual Match_Byte block to that shared typed representation. -/
theorem match_block : block "procedure" "match_byte" Source.imageModelBodyTokens =
    some Native.matchRender := by
  simp only [Native.matchRender, Native.matchCommands, Native.cellCommands, Native.Command.render,
    Native.Command.renderElse, Native.Update.render, Native.Test.render]
  decide +kernel

theorem selected_theories : Silver.Lexical.SourceBridge.subtypeDeclaration "selected_theory"
    Source.imageModelSpecTokens = some ["theory_kind", "range", "integer_theory", "..", "image_theory"] := by decide +kernel

theorem theory_order : Silver.SourceBridge.typeDeclaration "theory_kind" Source.imageModelSpecTokens =
    some ["(", "other_theory", ",", "integer_theory", ",", "string_theory", ",", "image_theory", ")"] := by decide +kernel

theorem template_selector : Silver.SourceBridge.qualifiedExpressionBody "template_kind" Source.imageModelBodyTokens =
    some ["case", "kind", "is", "when", "integer_theory", "=>", "templates", ".", "integer_template", ",",
      "when", "string_theory", "=>", "templates", ".", "string_template", ",",
      "when", "image_theory", "=>", "templates", ".", "image_template"] := by decide +kernel

/-- Exact block interpretation at the documented Ada frontend boundary. It
identifies the typed source commands, not their desired matching property. -/
structure InterpretedMatcher (tables : Native.Tables) (run : Native.Matcher → Nat → Native.Matcher) : Prop where
  commands : ∀ state item, run state item = Native.matchCommands.eval tables item state .integer

theorem interpreted_cell (tables : Native.Tables) (run : Native.Matcher → Nat → Native.Matcher)
    (source : InterpretedMatcher tables run) (state : Native.Matcher) (item : Nat) (kind : Native.Theory) :
    (run state item).cells kind = if state.inTheory
      then matchByte (tables.byte kind) (tables.length kind) (state.cells kind) item
      else state.cells kind := by
  rw [source.commands, Native.match_cells]

theorem interpreted_active (tables : Native.Tables) (run : Native.Matcher → Nat → Native.Matcher)
    (source : InterpretedMatcher tables run) (state : Native.Matcher) (item : Nat) :
    (run state item).inTheory = state.inTheory := by
  rw [source.commands, Native.match_inTheory]

/-- Matching proof applies to every imported table interpretation, independent
of its values. The separate schema/table proof identifies the concrete tables. -/
theorem actual_matcher_preserves (tables : Native.Tables) (run : Native.Matcher → Nat → Native.Matcher)
    (source : InterpretedMatcher tables run) (state : Native.Matcher) (item : Nat)
    (active : state.inTheory = true) (kind : Native.Theory) (input : List Nat)
    (invariant : MatchInvariant (tables.byte kind) (tables.length kind) input (state.cells kind)) :
    MatchInvariant (tables.byte kind) (tables.length kind) (input ++ [item]) ((run state item).cells kind) := by
  rw [interpreted_cell tables run source, active]
  exact matchByte_preserves invariant item

end Silver.ImageModel.SourceBridge
