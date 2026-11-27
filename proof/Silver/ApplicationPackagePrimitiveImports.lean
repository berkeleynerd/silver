module

public import Silver.ApplicationPackageNamesMeaning
public import Silver.PackageBindingsSourceBridge
public import Silver.ComposeLexical
public import Silver.ComposeCoreHelperEquations

@[expose] public section

/-! Shared concrete lexical and package imports. Every meaning is derived from
its existing source equations on the original pooled bytes and full native
argument domain. No completed package-reader meaning is an assumption. -/
namespace Silver.ApplicationPackageImports
open Compose Compose.Expressions

structure Imports where
  composed : Compose.Expressions.Calls
  domain : StateDomain
  inherited : RawHelperEquations composed (domain := domain)
  lexical : Guarded.Expressions.Calls
  token : Source → Nat → String → Bool → Bool
  lexicalSource : Compose.Lexical.InterpretedSource lexical token
  packages : PackageBindings.Native.Calls
  packagePrimitives : PackageBindings.Native.Primitives packages
  packageEquations : PackageBindings.Native.Equations packages

def nameIs (imports : Imports) (text : Source) (first after : Nat) (word : String) : Bool :=
  imports.lexical.base.identifier.name text first after (word.toList.map Char.toNat)

def forbidden (imports : Imports) : Source → Nat → Nat → Bool :=
  imports.lexical.base.identifier.forbidden

def equal (imports : Imports) : Source → Nat → Nat → Nat → Nat → Bool :=
  imports.lexical.base.identifier.equal

def sameName (imports : Imports) (text : Source) : PackageBindings.NameSpan → PackageBindings.NameSpan → Bool :=
  imports.packages.sameName (ApplicationPackageNames.metadataText text)

theorem nameIs_meaning (imports : Imports) (text : Source) (valid : ValidText text)
    (first after : Nat) (name : ValidName text first after) (word : String)
    (positive : 0 < word.toList.length) (bounded : word.toList.length ≤ maxSourceLength) :
    nameIs imports text first after word = Named.nameIs text first after (word.toList.map Char.toNat) := by
  exact (Compose.Lexical.interpreted_identifier_equations imports.lexical imports.token
    imports.lexicalSource).name text valid.1 valid.2 first after
      (word.toList.map Char.toNat) name.1 name.2.1 name.2.2
      (by simpa only [List.length_map] using positive)
      (by simpa only [List.length_map] using bounded)

theorem forbidden_meaning (imports : Imports) (text : Source) (valid : ValidText text)
    (first after : Nat) (name : ValidName text first after) :
    forbidden imports text first after = Named.forbiddenName text first after :=
  Named.forbidden_implementation imports.lexical.base.identifier
    (Compose.Lexical.interpreted_identifier_equations imports.lexical imports.token imports.lexicalSource)
      text valid.1 valid.2 first after name.1 name.2.1 name.2.2

theorem equal_meaning (imports : Imports) (text : Source) (valid : ValidText text)
    (first after otherFirst otherAfter : Nat) (name : ValidName text first after)
    (other : ValidName text otherFirst otherAfter) :
    equal imports text first after otherFirst otherAfter =
      Named.equalName text first after otherFirst otherAfter :=
  (Compose.Lexical.interpreted_identifier_equations imports.lexical imports.token
    imports.lexicalSource).equal text valid.1 valid.2 first after otherFirst otherAfter
      name.1 name.2.1 name.2.2 other.1 other.2.1 other.2.2

theorem sameName_meaning (imports : Imports) (text : Source)
    (left right : PackageBindings.NameSpan) :
    sameName imports text left right =
      PackageBindings.sameName (ApplicationPackageNames.metadataText text) left right :=
  PackageBindings.Native.interpreted_sameName imports.packages imports.packagePrimitives
    imports.packageEquations (ApplicationPackageNames.metadataText text) left right

end Silver.ApplicationPackageImports
