module

public import Silver.PackageBindingsEquations
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! The bounded String comparison used by Main. Reuse the metadata expression
language and its arbitrary Ada String bounds. This small command fragment has
no assignments: only Boolean returns, sequencing, tests and source-range loops. -/
namespace Silver.ApplicationPackageSpelling
open PackageBindings PackageBindings.Native

set_option backward.dsimp.instances true

inductive Test
  | expression : Expr .truth → Test
  | validName : Expr .source → Expr .name → Test
  | not : Test → Test
  | orElse : Test → Test → Test
  | lowerNe : Expr .number → Expr .number → Test

def Test.eval (calls : Calls) (locals : Locals) : Test → Bool
  | .expression value => value.eval calls locals
  | .validName text name => calls.validName (text.eval calls locals) (name.eval calls locals)
  | .not value => !(value.eval calls locals)
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .lowerNe left right => decide (Silver.lowercase (left.eval calls locals) ≠ Silver.lowercase (right.eval calls locals))

def Test.render : Test → List String
  | .expression value => value.render
  | .validName text name => ["packages", ".", "valid_name", "("] ++ text.render ++ [","] ++ name.render ++ [")"]
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .lowerNe left right => ["lowercase", "("] ++ left.render ++ [")", "/=", "lowercase", "("] ++ right.render ++ [")"]

def Test.primary : Test → Bool
  | .validName _ _ => true
  | .expression value => value.primary
  | _ => false

def Test.relation : Test → Bool
  | .validName _ _ | .not _ | .lowerNe _ _ => true
  | .expression value => value.relation
  | _ => false

def Test.orHead : Test → Bool
  | .orElse _ _ => true
  | value => value.relation

def Test.wellFormed : Test → Bool
  | .expression value => value.wellFormed && value.condition
  | .validName text name => text.wellFormed && text.simple && name.wellFormed && name.simple
  | .not value => value.wellFormed && value.primary
  | .orElse left right => left.wellFormed && left.orHead && right.wellFormed && right.relation
  | .lowerNe left right => left.wellFormed && left.simple && right.wellFormed && right.simple

def Test.scoped (scope : Scope) : Test → Bool
  | .expression value => value.scoped scope
  | .validName text name => text.scoped scope && name.scoped scope
  | .not value => value.scoped scope
  | .orElse left right => left.scoped scope && right.scoped scope
  | .lowerNe left right => left.scoped scope && right.scoped scope

inductive Command
  | nothing
  | sequence : Command → Command → Command
  | choose : Test → Command → Command
  | forSource (name : String) : Expr .source → Command → Command
  | returned : Bool → Command

def Command.eval (calls : Calls) (locals : Locals) : Command → Option Bool
  | .nothing => none
  | .sequence first second => (first.eval calls locals).orElse fun _ => second.eval calls locals
  | .choose test body => if test.eval calls locals then body.eval calls locals else none
  | .forSource name source body =>
      let value := source.eval calls locals
      (List.range value.bytes.length).findSome? fun offset =>
        body.eval calls (locals.set .integer name (value.first + (offset : Nat)))
  | .returned value => some value

def Command.render : Command → List String
  | .nothing => []
  | .sequence first second => first.render ++ second.render
  | .choose test body => ["if"] ++ test.render ++ ["then"] ++ body.render ++ ["end", "if", ";"]
  | .forSource name source body => ["for", name, "in"] ++ source.render ++
      ["'", "range", "loop"] ++ body.render ++ ["end", "loop", ";"]
  | .returned value => ["return", if value then "true" else "false", ";"]

def Command.wellFormed : Command → Bool
  | .nothing | .returned _ => true
  | .sequence first second => first.wellFormed && second.wellFormed
  | .choose test body => test.wellFormed && test.orHead && body.wellFormed
  | .forSource _ source body => source.wellFormed && source.primary && body.wellFormed

def Command.scoped (scope : Scope) : Command → Bool
  | .nothing | .returned _ => true
  | .sequence first second => first.scoped scope && second.scoped scope
  | .choose test body => test.scoped scope && body.scoped scope
  | .forSource name source body => source.scoped scope && body.scoped ((name,.integer)::scope)

def text : Expr .source := .variable "text"
def word : Expr .source := .variable "word"
def info : Expr .metadata := .variable "info"
def first : Expr .number := .field .packageNameFirst info
def after : Expr .number := .field .packageNameAfter info

def guard : Test := .orElse (.not (.validName text (.name first after)))
  (.expression (.ne (.sourceLength word) (.sub after first)))

def mismatch : Test := .lowerNe (.byte word (.variable "i"))
  (.byte text (.intAdd (.toInteger first) (.group (.intSub (.variable "i") (.sourceFirst word)))))

def body : Command := .sequence (.choose guard (.returned false))
  (.sequence (.forSource "i" word (.choose mismatch (.returned false))) (.returned true))

def bodyTokens : List String := ["begin"] ++ body.render ++ ["end", "same_package_spelling", ";"]

abbrev CheckedTree : Prop := body.wellFormed = true ∧
  body.scoped [("text",.source),("info",.metadata),("word",.source)] = true

theorem checked_tree : CheckedTree := by decide +kernel

def inputs (source : Text) (metadata : Metadata) (spelling : Text) : Locals
  | .source, "text" => source
  | .source, "word" => spelling
  | .metadata, "info" => metadata
  | ty, _ => ty.default

def sameSpelling (source : Text) (metadata : Metadata) (spelling : Text) : Bool :=
  if !PackageBindings.validName source ⟨metadata.nameFirst, metadata.nameAfter⟩ ||
      decide (spelling.bytes.length ≠ metadata.nameAfter - metadata.nameFirst) then false
  else (List.range spelling.bytes.length).all fun offset =>
    decide (Silver.lowercase (spelling.bytes.getD offset 0) =
      Silver.lowercase (source.bytes.getD ((metadata.nameFirst : Int) + offset - source.first).toNat 0))

private theorem find_mismatch (values : List Nat) (equal : Nat → Bool) :
    (values.findSome? (fun index => if equal index then none else some false)).orElse (fun _ => some true) =
      some (values.all equal) := by
  induction values with
  | nil => rfl
  | cons index rest ih =>
    cases h : equal index <;>
      simp only [List.findSome?, h, Bool.false_eq_true, ↓reduceIte, Option.orElse_some,
        List.all_cons, Bool.false_and, Bool.true_and]
    exact ih

/-- The original lower bound cancels inside each comparison, including words
whose first index is not one. Invalid names and unequal lengths return before
indexing; empty words execute no loop iterations. -/
theorem body_meaning (calls : Calls)
    (names : ∀ source name, calls.validName source name = PackageBindings.validName source name)
    (source : Text) (metadata : Metadata) (spelling : Text) :
    body.eval calls (inputs source metadata spelling) = some (sameSpelling source metadata spelling) := by
  have guardEq : guard.eval calls (inputs source metadata spelling) =
      (!PackageBindings.validName source ⟨metadata.nameFirst, metadata.nameAfter⟩ ||
        decide (spelling.bytes.length ≠ metadata.nameAfter - metadata.nameFirst)) := by
    simp only [guard, Test.eval, Expr.eval, inputs, first, after, info, text, word, Field.get, names]
  have compare (offset : Nat) : mismatch.eval calls
      ((inputs source metadata spelling).set .integer "i" (spelling.first + offset)) =
      decide (Silver.lowercase (spelling.bytes.getD offset 0) ≠
        Silver.lowercase (source.bytes.getD ((metadata.nameFirst : Int) + offset - source.first).toNat 0)) := by
    simp only [mismatch, Test.eval, Expr.eval, inputs, Locals.set, first, info, text, word,
      Field.get, reduceCtorEq, ↓reduceDIte, ↓reduceIte]
    have cancel : spelling.first + (offset : Int) - spelling.first = offset := by omega
    rw [cancel]
    simp only [Int.toNat_natCast]
    rfl
  simp only [body, Command.eval, guardEq, sameSpelling]
  split
  · rfl
  · simp only [Option.orElse_none]
    change ((List.range spelling.bytes.length).findSome? (fun (offset : Nat) =>
      if mismatch.eval calls ((inputs source metadata spelling).set .integer "i" (spelling.first + offset))
      then some false else none)).orElse (fun _ => some true) = _
    simp only [compare]
    simp only [decide_eq_true_eq]
    simpa only [decide_eq_true_eq, ite_not] using
      find_mismatch (List.range spelling.bytes.length) (fun offset =>
        decide (Silver.lowercase (spelling.bytes.getD offset 0) =
          Silver.lowercase (source.bytes.getD ((metadata.nameFirst : Int) + offset - source.first).toNat 0)))

/-- String sliding changes no comparison result. The original Imported_Package
return may retain a slice lower bound; Main's byte-list adapter is still exact. -/
theorem word_first_irrelevant (source : Text) (metadata : Metadata) (bytes : Source)
    (first otherFirst : Int) :
    sameSpelling source metadata ⟨first,bytes⟩ = sameSpelling source metadata ⟨otherFirst,bytes⟩ := rfl

theorem imported_body_meaning (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (source : Text) (metadata : Metadata) (spelling : Text) :
    body.eval calls (inputs source metadata spelling) = some (sameSpelling source metadata spelling) :=
  body_meaning calls (interpreted_validName calls primitives equations) source metadata spelling

end Silver.ApplicationPackageSpelling
