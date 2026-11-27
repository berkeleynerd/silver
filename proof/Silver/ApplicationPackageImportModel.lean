module

public import Silver.ApplicationPackageImportNative

@[expose] public section

/-! Direct scanner transitions. The stored candidate keeps the original span
in the normalized Main bytes. Use clauses never select a package, and every
non-runtime with-name must agree with the selected candidate. -/
namespace Silver.ApplicationPackageImport.Model
open Compose

structure Cursor where
  position : Nat
  candidate : PackageBindings.NameSpan
  deriving DecidableEq, Repr

inductive Step
  | next (cursor : Cursor)
  | done (cursor : Cursor)
  | reject
  deriving DecidableEq, Repr

def innerStep (calls : Native.Calls) (text : Source) (withClause : Bool) (cursor : Cursor) : Step :=
  let first := calls.skip text cursor.position
  let after := calls.nameAfter text first
  let name : PackageBindings.NameSpan := ⟨first, after⟩
  let comma := calls.take text after (.symbol ",")
  let semicolon := calls.take text after (.symbol ";")
  if !calls.validName text name || (comma = 0 && semicolon = 0) then .reject else
  let select := withClause && !calls.nameIs text first after "silver_io" &&
    !calls.nameIs text first after "silver_arguments"
  if select && cursor.candidate.first ≠ 0 && !calls.sameName text cursor.candidate name then .reject else
  let candidate := if select then name else cursor.candidate
  if semicolon ≠ 0 then .done ⟨semicolon, candidate⟩ else .next ⟨comma, candidate⟩

def innerLoop (calls : Native.Calls) (text : Source) (withClause : Bool) :
    Nat → Cursor → Option (Except Unit Cursor)
  | 0, _ => none
  | fuel + 1, cursor =>
      match innerStep calls text withClause cursor with
      | .next next => innerLoop calls text withClause fuel next
      | .done last => some (.ok last)
      | .reject => some (.error ())

def outerStep (calls : Native.Calls) (text : Source) (innerFuel : Nat) (cursor : Cursor) : Option Step :=
  let first := calls.skip text cursor.position
  let after := calls.nameAfter text first
  let withClause := first > 0 && after > first && calls.nameIs text first after "with"
  let useClause := first > 0 && after > first && calls.nameIs text first after "use"
  if !withClause && !useClause then some (.done cursor) else
  match innerLoop calls text withClause innerFuel {cursor with position := after} with
  | none => none
  | some (.error _) => some .reject
  | some (.ok next) => some (.next next)

def outerLoop (calls : Native.Calls) (text : Source) (innerFuel : Nat) :
    Nat → Cursor → Option (Except Unit Cursor)
  | 0, _ => none
  | fuel + 1, cursor =>
      match outerStep calls text innerFuel cursor with
      | none => none
      | some (.next next) => outerLoop calls text innerFuel fuel next
      | some (.done last) => some (.ok last)
      | some .reject => some (.error ())

def imported (calls : Native.Calls) (fuel : Nat) (source : Source) : Option Source :=
  if source.length = 0 ∨ Silver.maxSourceLength < source.length then some [] else
  let text := calls.normalize source
  match outerLoop calls text fuel fuel ⟨1, {}⟩ with
  | none => none
  | some (.error _) => some []
  | some (.ok result) =>
      if result.candidate.first = 0 then some []
      else some ((text.drop (result.candidate.first - 1)).take
        (result.candidate.after - result.candidate.first))

end Silver.ApplicationPackageImport.Model
