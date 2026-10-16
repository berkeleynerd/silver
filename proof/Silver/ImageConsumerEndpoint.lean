module

public import Silver.ImageProducerEndpoint
public import Silver.ImageModelConsumerBoundary

@[expose] public section
namespace Silver.ImageModel

theorem selected_image_scope (characters : List Nat)
    (selected : ScannerNative.selectedName characters none = some .image) :
    characters = ConsumerBoundary.imageScope := by
  unfold ScannerNative.selectedName at selected
  split at selected
  · contradiction
  · split at selected
    · contradiction
    · split at selected
      · rename_i named
        exact named.trans (by decide +kernel)
      · contradiction

/-- The exact inserted clone lies in the selected Image scope and denotes the
proved instance under the named external consumer and installed-source
interfaces. The original-document context and all unaffected bytes are those
established by the native refinement endpoint. -/
theorem RefinedDocument.consumer_instance
    (document : JSON.DocumentSpan) (output : List Nat) (refined : RefinedDocument document output)
    (calls : ConsumerBoundary.Calls) (consumer : ConsumerBoundary.InterpretedConsumer calls)
    (context : calls.contextValid document)
    (installed : calls.theorySource "silver_image" "Integer_Image_Length" = some Integer.Image.Theory.text) :
    ∃ preceding entry following core,
      document.entries = preceding ++ entry :: following ∧
      output = document.leading ++ core ++ document.trailing ∧
      JSON.CodeUnitSpelling
        (.object [(JSON.ascii "theory_declarations", .array
          (preceding.map JSON.TheoryEntry.value ++
            (entry.span.theory.appendNodes Clone.declaration Clone.includeDeclaration).value ::
            following.map JSON.TheoryEntry.value))]) core ∧
      entry.span.theory.name = ConsumerBoundary.imageScope ∧
      calls.interpretClone document entry.span.theory.name Clone.declaration Clone.includeDeclaration =
        some CloneMeaning.predefined ∧
      (∀ signature, calls.interpretClone document entry.span.theory.name Clone.declaration Clone.includeDeclaration = some signature →
        ∀ value, CloneMeaning.assertion signature value) := by
  obtain ⟨schemas, preceding, entry, following, core, position, selected, spelling, tree⟩ := refined
  have scope := selected_image_scope entry.span.theory.name selected
  refine ⟨preceding, entry, following, core, position, spelling, tree, scope, ?_, ?_⟩
  · rw [scope]
    exact ConsumerBoundary.actual_clone_interpretation calls consumer document context schemas installed
  · intro signature interpreted value
    rw [scope] at interpreted
    exact ConsumerBoundary.actual_clone_assertion calls consumer document context schemas installed signature interpreted value

end Silver.ImageModel
