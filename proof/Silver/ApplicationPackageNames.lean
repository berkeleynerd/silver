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
    !Named.nameIs text name.first name.after ("integer".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("boolean".toList.map Char.toNat) &&
    !Named.nameIs text name.first name.after ("character".toList.map Char.toNat)

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
