module

public import Silver.ImageModelCloneMeaning
public import Silver.ImageModelSelectedMeaning
public import Silver.ImageModelDocumentAllSelected

@[expose] public section
namespace Silver.ImageModel.ConsumerBoundary

/-- Complete selected producer schemas, already derived from actual scanner
acceptance by the refinement endpoint. Equality concerns entire erased semantic
trees, not just names, field counts or the projected substitution rows. -/
def SchemaIdentities (document : JSON.DocumentSpan) : Prop :=
  ∀ kind : Native.Theory, ∃ entry ∈ document.entries,
    ScannerNative.selectedName entry.span.theory.name none = some kind ∧
    entry.span.theory.value.eraseNodeIds.meaning = (Templates.theoryValue kind).meaning

def imageScope : List Nat := JSON.ascii "Standard_String__Img"

/-- The exact finite clone/include constructors interpreted at this boundary.
The source theory, alias, import mode, domain and insertion scope are all fixed.
The consumer law below uses only the exact checked finite substitution list. -/
def CloneImportShape (scope : List Nat) (declaration includeNode : JSON.Value)
    (substitutions : List JSON.Value) : Prop :=
  scope = imageScope ∧
  declaration = .array [Clone.text "W_CLONE_DECLARATION", Clone.number (insertedIdFirst + 20), Clone.number 1,
    Clone.moduleNode (insertedIdFirst + 19) "silver_image" "Integer_Image_Length",
    Clone.text "Silver_Image", Clone.number 2, .array substitutions, Clone.number 1] ∧
  includeNode = .array [Clone.text "W_INCLUDE_DECLARATION", Clone.number (insertedIdFirst + 22), Clone.number 1,
    Clone.moduleNode (insertedIdFirst + 21) "" "Standard__integer", Clone.number 1, Clone.number 2]

theorem checked_clone_shape : CloneImportShape imageScope Clone.declaration Clone.includeDeclaration Clone.substitutions :=
  ⟨rfl, rfl, rfl⟩

/-- Assembly is purely structural. Both type roles and all three function
roles must resolve in order; an unresolved or wrong-kind binding fails. The
returned functions are the predefined-source semantic instance, not a claim
that every model of the original uninterpreted Why3 symbols has these values. -/
def assemble (resolved : List (Option CloneMeaning.Role)) : Option CloneMeaning.Signature :=
  if resolved = CloneMeaning.roles.map some then some CloneMeaning.predefined else none

/-- Mathematical observations of the pinned external consumer. `interpretClone`
is the predefined-source semantic view of its finite symbolic instantiation,
not the native OCaml return type or a solver result. `contextValid` means that
the original producer model forms a valid typed name environment, including
its namespace uniqueness; successful Silver scanning does not establish it.
`theorySource` observes the module text selected by the external library lookup.
`resolve` observes name resolution within the fixed `imageScope`, after its
includes and original declarations, at the appended clone declaration. -/
structure Calls where
  contextValid : JSON.DocumentSpan → Prop
  theorySource : String → String → Option String
  resolve : JSON.DocumentSpan → CloneMeaning.Row → Option CloneMeaning.Role
  interpretClone : JSON.DocumentSpan → List Nat → JSON.Value → JSON.Value → Option CloneMeaning.Signature

/-- Named trusted GNAT/Why consumer interpretation boundary. These are finite
primitive correspondence laws, not a verification of gnatwhy3. The first law
reads the exact checked clone/import and finite substitution constructors and
applies their externally resolved rows; it does not cover arbitrary lists with
the same projected rows, assume resolution succeeds, or assume an assertion
is true. The second identifies the five named predefined type/function roles
only under complete selected schemas and a valid original context.

The reviewed constructor routes are gnat_ast_to_ptree.ml 76–117, 160–173,
1240–1280 and 1315–1330, with the enum/JSON constructor decoding in gnat_ast.ml.
Exact installed theory text and stable external lookup remain separate inputs. -/
structure InterpretedConsumer (calls : Calls) : Prop where
  cloneImport : ∀ document scope declaration includeNode,
    calls.contextValid document →
    calls.theorySource "silver_image" "Integer_Image_Length" = some Integer.Image.Theory.text →
    CloneImportShape scope declaration includeNode Clone.substitutions →
    calls.interpretClone document scope declaration includeNode =
      assemble (Clone.substitutions.map (fun value => calls.resolve document (CloneMeaning.row value)))
  resolvePredefined : ∀ document, calls.contextValid document → SchemaIdentities document →
    ∀ role : CloneMeaning.Role, calls.resolve document role.row = some role

/-- The checked rows and complete selected schema identities determine every
actual external name resolution used by the inserted clone. -/
theorem resolved_clone_rows (calls : Calls) (consumer : InterpretedConsumer calls)
    (document : JSON.DocumentSpan) (context : calls.contextValid document)
    (schemas : SchemaIdentities document) :
    Clone.substitutions.map (fun value => calls.resolve document (CloneMeaning.row value)) = CloneMeaning.roles.map some := by
  change (Clone.substitutions.map CloneMeaning.row).map (calls.resolve document) = _
  rw [CloneMeaning.clone_rows]
  simp only [List.map_map]
  apply List.map_congr_left
  intro role _
  exact consumer.resolvePredefined document context schemas role

/-- Finite consumer correspondence derives successful instantiation and its
concrete semantic signature. Neither success nor the Image assertion is an
input; installed-source identity and external primitive interpretation are. -/
theorem actual_clone_interpretation (calls : Calls) (consumer : InterpretedConsumer calls)
    (document : JSON.DocumentSpan) (context : calls.contextValid document)
    (schemas : SchemaIdentities document)
    (installed : calls.theorySource "silver_image" "Integer_Image_Length" = some Integer.Image.Theory.text) :
    calls.interpretClone document imageScope Clone.declaration Clone.includeDeclaration = some CloneMeaning.predefined := by
  rw [consumer.cloneImport document imageScope Clone.declaration Clone.includeDeclaration
    context installed checked_clone_shape, resolved_clone_rows calls consumer document context schemas]
  simp only [assemble, ↓reduceIte]

theorem actual_clone_matches_model (calls : Calls) (consumer : InterpretedConsumer calls)
    (document : JSON.DocumentSpan) (context : calls.contextValid document)
    (schemas : SchemaIdentities document)
    (installed : calls.theorySource "silver_image" "Integer_Image_Length" = some Integer.Image.Theory.text) :
    calls.interpretClone document imageScope Clone.declaration Clone.includeDeclaration =
      CloneMeaning.interpret Clone.substitutions := by
  rw [actual_clone_interpretation calls consumer document context schemas installed, CloneMeaning.clone_interpretation]

/-- Every signature returned by that actual finite instantiation satisfies the
proved signed-32-bit, size-12 Image assertion. This is the semantic conclusion;
it is absent from every external interpretation premise above. -/
theorem actual_clone_assertion (calls : Calls) (consumer : InterpretedConsumer calls)
    (document : JSON.DocumentSpan) (context : calls.contextValid document)
    (schemas : SchemaIdentities document)
    (installed : calls.theorySource "silver_image" "Integer_Image_Length" = some Integer.Image.Theory.text)
    (signature : CloneMeaning.Signature)
    (interpreted : calls.interpretClone document imageScope Clone.declaration Clone.includeDeclaration = some signature)
    (value : Int) : CloneMeaning.assertion signature value := by
  rw [actual_clone_matches_model calls consumer document context schemas installed] at interpreted
  exact CloneMeaning.interpreted_assertion signature interpreted value

end Silver.ImageModel.ConsumerBoundary
