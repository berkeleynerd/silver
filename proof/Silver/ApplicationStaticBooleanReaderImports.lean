module

public import Silver.ApplicationStaticBooleanScalarImports
public import Silver.StaticBooleanSourceExpressions

@[expose] public section

/-! The four original reader bodies retain their actual imported calls and
one shared recursive family. Full native result contracts justify the leaf
domains; source recursion uniqueness derives the complete returned values. -/
namespace Silver.BooleanElaboration.Native.SourceImports
open Compose ApplicationPackageDeclarations

/-- Raw executions of the complete typed source bodies, before leaf imports
are interpreted. There is no equality to a model reader in this interface. -/
structure OriginalBodies (imports : Imports) (readers : ReaderStage → Reader) : Prop where
  primary (text frame position) : SourceChecks.Domain text frame position →
    readers .primary text frame position =
      primaryBody.eval imports ⟨readers .condition, readers .primary⟩ text frame position
  factor (text frame position) : SourceChecks.Domain text frame position →
    readers .factor text frame position =
      factorBody.eval imports ⟨readers .condition, readers .primary⟩ text frame position
  relation (initial : Relation.Frame) : SourceChecks.Domain initial.text initial.state initial.position →
    readers .relation initial.text initial.state initial.position = Relation.eval imports (readers .factor) initial
  condition (initial : Condition.Frame) : SourceChecks.Domain initial.text initial.state initial.position →
    Condition.BodyExec imports (readers .relation) initial
      (readers .condition initial.text initial.state initial.position)

/-- Exactly the postconditions checked by the native source requirements,
over the full native precondition domain. -/
def ReaderContracts (readers : ReaderStage → Reader) : Prop :=
  ∀ stage text frame position, SourceChecks.Domain text frame position →
    SourceChecks.ResultContract text position (readers stage text frame position)

theorem ReaderContracts.bounded {readers : ReaderStage → Reader} (contracts : ReaderContracts readers)
    {text frame position} (domain : SourceChecks.Domain text frame position) (stage : ReaderStage) :
    BoundedReader (readers stage) text frame := by
  intro start within accepted
  rcases contracts stage text frame start {domain with cursor := within} with failed | succeeded
  · exact False.elim (accepted failed)
  · exact succeeded

theorem OriginalBodies.normalized {imports : Imports} (meaning : Meaning imports)
    {readers : ReaderStage → Reader} (bodies : OriginalBodies imports readers)
    (contracts : ReaderContracts readers) : BodyReads readers where
  primary text frame position domain :=
    (bodies.primary text frame position domain).trans
      ((primary_body_denotation imports ⟨readers .condition, readers .primary⟩ text frame position).trans
        ((meaning.primary domain (readers .condition) (contracts.bounded domain .condition)).trans
          (primary_body_denotation modelImports ⟨readers .condition, readers .primary⟩ text frame position).symm))
  factor text frame position domain :=
    (bodies.factor text frame position domain).trans
      ((factor_body_denotation imports ⟨readers .condition, readers .primary⟩ text frame position).trans
        ((meaning.factor domain (readers .primary)).trans
          (factor_body_denotation modelImports ⟨readers .condition, readers .primary⟩ text frame position).symm))
  relation initial domain :=
    (bodies.relation initial domain).trans
      ((Relation.denotation imports _ initial).trans
        ((meaning.relation domain (readers .factor) (contracts.bounded domain .factor)).trans
          (Relation.denotation modelImports _ initial).symm))
  condition initial domain := by
    apply (Condition.body_denotation modelImports (readers .relation) initial _).mpr
    exact meaning.condition_execution domain (readers .relation) (contracts.bounded domain .relation)
      ((Condition.body_denotation imports (readers .relation) initial _).mp (bodies.condition initial domain))

/-- An actual source library uses the original imports selected by the object
declaration library. Native safety contracts remain explicit and separate from
the semantic result equality derived below. -/
structure Library (objects : ObjectLibraries) where
  readers : ReaderStage → Reader
  bodies : OriginalBodies (ofObjects objects) readers
  contracts : ReaderContracts readers

theorem Library.bodyReads {objects : ObjectLibraries} (library : Library objects) : BodyReads library.readers :=
  library.bodies.normalized (ofObjects_meaning objects) library.contracts

theorem Library.scalar_empty {objects : ObjectLibraries} (library : Library objects) (initial : Relation.Frame)
    (domain : SourceChecks.Domain initial.text initial.state initial.position) (which : Relation.ScalarLocal) :
    objects.names.shared.composed.function .scalarEmpty
      ((scalarOperandsFrame objects (library.readers .factor) initial).scalars which).bounds =
      (Relation.Expr.empty (.bounds (.scalar which))).eval (ofObjects objects) (library.readers .factor)
        (scalarOperandsFrame objects (library.readers .factor) initial) :=
  scalar_empty_source objects (library.readers .factor) initial domain which

theorem Library.determined {objects : ObjectLibraries} (library : Library objects)
    {tokens : List String} (checked : SourceChecks.Checked tokens) (text : Source) (frame : ParserState)
    (stage : ReaderStage) (position : Nat) (domain : SourceChecks.Domain text frame position) :
    library.readers stage text frame position = closedReader stage text frame position :=
  library.bodyReads.determined checked text frame stage position domain

def Library.condition {objects : ObjectLibraries} (library : Library objects) : Reader := library.readers .condition

theorem Library.condition_meaning {objects : ObjectLibraries} (library : Library objects)
    {tokens : List String} (checked : SourceChecks.Checked tokens) (text : Source) (frame : ParserState)
    (position : Nat) (domain : SourceChecks.Domain text frame position) :
    library.condition text frame position = closedReader .condition text frame position :=
  library.determined checked text frame .condition position domain

theorem Library.condition_source {objects : ObjectLibraries} (library : Library objects)
    {tokens : List String} (checked : SourceChecks.Checked tokens) (text : Source) (frame : ParserState)
    (position : Nat) (domain : SourceChecks.Domain text frame position)
    (accepted : (library.condition text frame position).after ≠ 0) :
    ExactAt (ExpressionAt text frame .condition) frame position (library.condition text frame position) :=
  library.bodyReads.source_expression checked text frame .condition position domain accepted

/-- Object declarations consume this very reader family, whose imported leaves
and recursive result are established above on the complete native domain. -/
def Library.object {objects : ObjectLibraries} (library : Library objects) : ObjectNative.Calls :=
  objects.object library.condition

theorem Library.object_staticBoolean {objects : ObjectLibraries} (library : Library objects) :
    library.object.base.staticBoolean = library.condition := rfl

end Silver.BooleanElaboration.Native.SourceImports
