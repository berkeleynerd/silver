module

public import Silver.PackageBindings
public import Silver.FunctionDeclarationAdmission

@[expose] public section

/-! Package reader values preserve the original defining spans and the nominal
identity of exported Integer subtypes. These equations are source-independent;
their typed native bodies and actual-source bridge are checked separately. -/
namespace Silver.ApplicationPackageNames

open Compose

def metadataText (text : Source) : PackageBindings.Text := ⟨1, text⟩

def packageWord (text : Source) (position : Nat) (word : String) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if first ≠ 0 ∧ after > first ∧
      Named.nameIs text first after (word.toList.map Char.toNat) then after else 0

def sparkPragmaAfter (text : Source) (position : Nat) : Nat :=
  fixedAfter text
    (fixedAfter text
      (fixedAfter text
        (fixedAfter text
          (fixedAfter text (fixedAfter text position "pragma" true) "spark_mode" true)
          "(" false)
        "on" true)
      ")" false)
    ";" false

def packageNameAllowed (text : Source) (name : PackageBindings.NameSpan) : Bool :=
  PackageBindings.validName (metadataText text) name &&
    !Named.forbiddenName text name.first name.after &&
    !Named.nameIs text name.first name.after ("main".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("ada".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("interfaces".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("system".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("gnat".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("silver_arguments".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("silver_output_libc".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("silver_runtime".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("boolean".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("false".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("true".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("integer".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("natural".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("positive".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("short_short_integer".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("short_integer".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("long_integer".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("long_long_integer".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("long_long_long_integer".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("short_float".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("float".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("long_float".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("long_long_float".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("character".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("wide_character".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("wide_wide_character".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("string".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("wide_string".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("wide_wide_string".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("duration".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("constraint_error".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("program_error".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("storage_error".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("tasking_error".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("numeric_error".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("ascii".toList.map Char.toNat)

/-- Identifier declarations directly in the pinned Standard environment, plus
its obsolescent ASCII package. The inherited character literal names are not
identifier declarations. This finite list states the library-unit homograph
restriction separately from runtime-operation visibility. -/
def standardPackageNames : List String :=
  ["boolean", "false", "true", "integer",
   "natural", "positive", "short_short_integer", "short_integer",
   "long_integer", "long_long_integer", "long_long_long_integer", "short_float",
   "float", "long_float", "long_long_float", "character",
   "wide_character", "wide_wide_character", "string", "wide_string",
   "wide_wide_string", "duration", "constraint_error", "program_error",
   "storage_error", "tasking_error", "numeric_error", "ascii"]

/-- Acceptance excludes a Standard homograph on the original selected source
span, including mixed case. No successful identifier/span hypothesis is added. -/
theorem packageNameAllowed_no_standard (text : Source) (name : PackageBindings.NameSpan)
    (word : String) (standard : word ∈ standardPackageNames)
    (allowed : packageNameAllowed text name = true) :
    Named.nameIs text name.first name.after (word.toList.map Char.toNat) = false := by
  simp only [standardPackageNames, List.mem_cons, List.not_mem_nil, or_false] at standard
  rcases standard with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals simp_all only [packageNameAllowed, Bool.and_eq_true, Bool.not_eq_true']

theorem packageNameAllowed_standard (text : Source) (name : PackageBindings.NameSpan)
    (word : String) (standard : word ∈ standardPackageNames)
    (homograph : Named.nameIs text name.first name.after (word.toList.map Char.toNat) = true) :
    packageNameAllowed text name = false := by
  cases allowed : packageNameAllowed text name with
  | false => rfl
  | true =>
      have excluded := packageNameAllowed_no_standard text name word standard allowed
      simp [homograph] at excluded

/-- Kernel controls exercise the complete forbidden Standard list, while the
source-span theorem above covers arbitrary source positions and capitalization. -/
theorem standardPackageNames_rejected :
    standardPackageNames.all (fun word =>
      !packageNameAllowed (word.toList.map Char.toNat) ⟨1, word.toList.length + 1⟩) = true := by
  decide +kernel

theorem legalPackageNames_controls :
    ["Standard", "Nul", "Universal_Integer", "Root_Integer", "Put_Line", "Put",
      "First_Or_Default", "Input_Is_Valid", "Reject"].all (fun word =>
      packageNameAllowed (word.toList.map Char.toNat) ⟨1, word.toList.length + 1⟩) = true := by
  decide +kernel

def packageNameFresh (text : Source) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) : Bool :=
  PackageBindings.validName (metadataText text) name &&
    !Named.forbiddenName text name.first name.after &&
    !PackageBindings.sameName (metadataText text) name ⟨info.nameFirst, info.nameAfter⟩ &&
    decide (PackageBindings.lookupExport (metadataText text) info name = 0) &&
    decide (PackageBindings.lookupState (metadataText text) info name = 0) &&
    (List.range info.routines.length).all (fun index =>
      !PackageBindings.sameName (metadataText text) name (info.routineAt (index + 1)).specName)

structure PackageTypeResult where
  name : PackageBindings.NameSpan := {}
  after : Nat := 0
  kind : FunctionBindings.ScalarKind := .integer
  bounds : Integer.Interval := .empty
  identity : Nat := 1
  deriving DecidableEq, Repr

def packageTypeAt (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (position : Nat) : PackageTypeResult :=
  let first := skipAt text position
  let last := nameAfter text first
  let value := functionTypeAt text frame position
  let exportId := PackageBindings.lookupExport (metadataText text) info ⟨first, last⟩
  if !(PackageBindings.validName (metadataText text) ⟨first, last⟩) ||
      decide (value.after ≠ last) then {}
  else if value.kind = .boolean then ⟨⟨first, last⟩, last, value.kind, .full, 0⟩
  else if Named.nameIs text first last ("integer".toList.map Char.toNat) then
    ⟨⟨first, last⟩, last, value.kind, value.bounds, 1⟩
  else if exportId ≠ 0 ∧ (info.exportAt exportId).kind = .integerSubtype then
    ⟨⟨first, last⟩, last, value.kind, value.bounds, exportId + 1⟩
  else {}

def outerDeclaration (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) : Bool :=
  (List.range info.exports.length).any (fun index => (info.exportAt (index + 1)).name == name) ||
    (List.range info.states.length).any (fun index => (info.stateAt (index + 1)).name == name)

theorem outerDeclaration_iff (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) :
    outerDeclaration info name = true ↔
      (∃ index, index < info.exports.length ∧ (info.exportAt (index + 1)).name = name) ∨
      (∃ index, index < info.states.length ∧ (info.stateAt (index + 1)).name = name) := by
  simp [outerDeclaration, List.any_eq_true, List.mem_range]

end Silver.ApplicationPackageNames
