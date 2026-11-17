module

public import Silver.PredicateAssociationSyntax

@[expose] public section

namespace Silver.Predicate.AssociationNative
open Compose

def functionFormalBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let catalog : Expr .functions := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let nameFirst : Expr .number := .variable "name_first"
  let nameAfter : Expr .number := .variable "name_after"
  let parameter := Expr.functionParameter catalog first
  .ite (.orElse (.eq nameFirst (.number 0)) (.le nameAfter nameFirst)) (.number 0)
    (.elsif (apply5 (.function .equalName) text (.field .functionFirst parameter)
      (.field .functionAfter parameter) nameFirst nameAfter) first
      (.elsif (.eq first last) (.number 0)
        (apply6 (.function .functionFormalModel) text catalog (.add first (.number 1))
          last nameFirst nameAfter)))

def procedureFormalBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let catalog : Expr .procedures := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let nameFirst : Expr .number := .variable "name_first"
  let nameAfter : Expr .number := .variable "name_after"
  let parameter := Expr.procedureParameter catalog first
  .ite (.orElse (.eq nameFirst (.number 0)) (.le nameAfter nameFirst)) (.number 0)
    (.elsif (apply5 (.function .equalName) text (.field .procedureFirst parameter)
      (.field .procedureAfter parameter) nameFirst nameAfter) first
      (.elsif (.eq first last) (.number 0)
        (apply6 (.function .procedureFormalModel) text catalog (.add first (.number 1))
          last nameFirst nameAfter)))

def functionAssociationBody : Expr .association :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let catalog : Expr .functions := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let ordinal : Expr .number := .variable "ordinal"
  let named : Expr .truth := .variable "named"
  let nameFirst : Expr .number := .variable "name_first"
  let nameEnd : Expr .number := .variable "name_end"
  let payload : Expr .number := .variable "payload"
  .declare <|
    .letValue "name_first" ["literal_position"] (apply2 (.function .skip) text position) <|
    .letValue "name_end" ["literal_position"] (apply2 (.function .nameAfter) text nameFirst) <|
    .letValue "payload" ["literal_position"] (apply3 (.function .token) text nameEnd (.token .arrow)) <|
    .beginValue <| .group <| .ite (.eq position (.number 0)) .invalidAssociation
      (.elsif (.ne payload (.number 0))
        (.association (apply6 (.function .functionFormalAt) text catalog first last nameFirst nameEnd)
          payload (.truth true))
        (.elsif named .invalidAssociation (.association ordinal position (.truth false))))

def procedureAssociationBody : Expr .association :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let catalog : Expr .procedures := .variable "catalog"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let ordinal : Expr .number := .variable "ordinal"
  let named : Expr .truth := .variable "named"
  let nameFirst : Expr .number := .variable "name_first"
  let nameEnd : Expr .number := .variable "name_end"
  let payload : Expr .number := .variable "payload"
  .declare <|
    .letValue "name_first" ["literal_position"] (apply2 (.function .skip) text position) <|
    .letValue "name_end" ["literal_position"] (apply2 (.function .nameAfter) text nameFirst) <|
    .letValue "payload" ["literal_position"] (apply3 (.function .token) text nameEnd (.token .arrow)) <|
    .beginValue <| .group <| .ite (.eq position (.number 0)) .invalidAssociation
      (.elsif (.ne payload (.number 0))
        (.association (apply6 (.function .procedureFormalAt) text catalog first last nameFirst nameEnd)
          payload (.truth true))
        (.elsif named .invalidAssociation (.association ordinal position (.truth false))))

def modelCalls : Calls
  | .skip => skipAt
  | .nameAfter => Compose.nameAfter
  | .equalName => Named.equalName
  | .token => tokenAfter
  | .functionFormalModel | .functionFormalAt => functionFormalModel
  | .procedureFormalModel | .procedureFormalAt => procedureFormalModel
  | .functionAssociation => functionAssociation
  | .procedureAssociation => procedureAssociation

structure Frame where
  text : Source := []
  functions : FunctionBindings.Metadata := {}
  procedures : ProcedureBindings.Metadata := {}
  position : Nat := 0
  first : Nat := 0
  last : Nat := 0
  ordinal : Nat := 0
  named : Bool := false
  nameFirst : Nat := 0
  nameAfter : Nat := 0

def Frame.locals (frame : Frame) : Locals :=
  ((fun (ty : Ty) (_ : String) => ty.default) : Locals)
    |> fun locals => Locals.set locals .source "text" frame.text
    |> fun locals => Locals.set locals .functions "catalog" frame.functions
    |> fun locals => Locals.set locals .procedures "catalog" frame.procedures
    |> fun locals => Locals.set locals .number "position" frame.position
    |> fun locals => Locals.set locals .number "first" frame.first
    |> fun locals => Locals.set locals .number "last" frame.last
    |> fun locals => Locals.set locals .number "ordinal" frame.ordinal
    |> fun locals => Locals.set locals .truth "named" frame.named
    |> fun locals => Locals.set locals .number "name_first" frame.nameFirst
    |> fun locals => Locals.set locals .number "name_after" frame.nameAfter

def formalScope (metadata : Ty) : Scope :=
  [(.source, "text"), (metadata, "catalog"), (.number, "first"), (.number, "last"),
    (.number, "name_first"), (.number, "name_after")]
def associationScope (metadata : Ty) : Scope :=
  [(.source, "text"), (.number, "position"), (metadata, "catalog"), (.number, "first"),
    (.number, "last"), (.number, "ordinal"), (.truth, "named")]

abbrev CheckedTrees : Prop :=
  functionFormalBody.wellFormed = true ∧ functionFormalBody.scoped (formalScope .functions) = true ∧
  procedureFormalBody.wellFormed = true ∧ procedureFormalBody.scoped (formalScope .procedures) = true ∧
  functionAssociationBody.wellFormed = true ∧ functionAssociationBody.scoped (associationScope .functions) = true ∧
  procedureAssociationBody.wellFormed = true ∧ procedureAssociationBody.scoped (associationScope .procedures) = true

theorem checked_trees : CheckedTrees := by decide +kernel

namespace StructuralControls

theorem not_collision :
    (Expr.not (.orElse (.truth true) (.truth true))).render =
      (Expr.orElse (.not (.truth true)) (.truth true)).render ∧
    (Expr.not (.orElse (.truth true) (.truth true))).wellFormed = false ∧
    (Expr.orElse (.not (.truth true)) (.truth true)).wellFormed = true := by decide +kernel

theorem undeclared_or_wrong_catalog_rejected :
    (Expr.variable (ty := .number) "payload").scoped (associationScope .functions) = false ∧
    (Expr.variable (ty := .procedures) "catalog").scoped (associationScope .functions) = false ∧
    (Expr.field .formal (.group (.variable "choice"))).wellFormed = false := by decide +kernel

theorem arrow_token_paired : Token.arrow.name = Expressions.tokenName (.symbol "=>") := rfl

end StructuralControls

end Silver.Predicate.AssociationNative
