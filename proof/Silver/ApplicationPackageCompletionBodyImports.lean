module

public import Silver.ApplicationPackageCompletionOutputImports
public import Silver.ApplicationPackageRecursiveMasks

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames ApplicationPackageNames

set_option backward.dsimp.instances true

theorem completionReturn_congr (actual model : CompletionCalls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (result : ApplicationScan)
    (takeEq : actual.takeToken text result.scan.position (.word "return") =
      model.takeToken text result.scan.position (.word "return"))
    (returnEq : actual.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩ =
      model.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩)
    (readsEq : actual.stateReads text context info (model.takeToken text result.scan.position (.word "return"))
        (model.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩) =
      model.stateReads text context info (model.takeToken text result.scan.position (.word "return"))
        (model.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩))
    (semiEq : actual.takeToken text
        (model.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩) (.symbol ";") =
      model.takeToken text
        (model.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩) (.symbol ";")) :
    completionReturn actual text context info item result = completionReturn model text context info item result := by
  unfold completionReturn
  split
  · dsimp only
    rw [takeEq, returnEq, readsEq, semiEq]
  · rfl

theorem completionFooter_congr (actual model : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine) (result : ApplicationScan)
    (endEq : actual.takeToken text result.scan.position (.word "end") = model.takeToken text result.scan.position (.word "end"))
    (skipEq : actual.skipAt text (model.takeToken text result.scan.position (.word "end")) =
      model.skipAt text (model.takeToken text result.scan.position (.word "end")))
    (nameEq : actual.nameAfter text (model.skipAt text (model.takeToken text result.scan.position (.word "end"))) =
      model.nameAfter text (model.skipAt text (model.takeToken text result.scan.position (.word "end"))))
    (semiEq : actual.takeToken text
        (model.nameAfter text (model.skipAt text (model.takeToken text result.scan.position (.word "end")))) (.symbol ";") =
      model.takeToken text
        (model.nameAfter text (model.skipAt text (model.takeToken text result.scan.position (.word "end")))) (.symbol ";"))
    (nameSame : actual.sameName text
        ⟨model.skipAt text (model.takeToken text result.scan.position (.word "end")),
          model.nameAfter text (model.skipAt text (model.takeToken text result.scan.position (.word "end")))⟩ item.bodyName =
      model.sameName text
        ⟨model.skipAt text (model.takeToken text result.scan.position (.word "end")),
          model.nameAfter text (model.skipAt text (model.takeToken text result.scan.position (.word "end")))⟩ item.bodyName) :
    completionFooter actual text globals info index item result =
      completionFooter model text globals info index item result := by
  dsimp only [completionFooter]
  rw [endEq, skipEq, nameEq, semiEq, nameSame]

theorem completionReturn_mask_width {calls : CompletionCalls} {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {result returned : ApplicationScan}
    (width : result.MaskWidth) (read : completionReturn calls text context info item result = some returned) :
    returned.MaskWidth := by
  unfold completionReturn at read
  split at read
  · dsimp only at read
    split at read
    · contradiction
    · cases read
      exact ⟨by simp only [PackageBindings.stateUnion, List.length_map, List.length_range], width.2⟩
  · cases read; exact width

theorem completionReturn_scan {calls : CompletionCalls} {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {result returned : ApplicationScan}
    (legal : Recursive.ScanDomain text context result.scan)
    (bounded : calls.takeToken text
      (calls.functionReturnAfter text context result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩) (.symbol ";") ≤ text.length + 1)
    (read : completionReturn calls text context info item result = some returned) :
    Recursive.ScanDomain text context returned.scan := by
  unfold completionReturn at read
  split at read
  · dsimp only at read
    split at read
    · contradiction
    · cases read
      exact ⟨bounded, legal.controls, legal.path, legal.flow⟩
  · cases read; exact legal

theorem uncheckedCompletionBody_congr (actual model : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine) (state : InitializationFrame)
    (dispatchEq : completionDispatch actual text info item state = completionDispatch model text info item state)
    (contextEq : completionContextOf actual state = completionContextOf model state)
    (returnEq : completionReturn actual text (completionContextOf model state) info item
        (completionDispatch model text info item state) =
      completionReturn model text (completionContextOf model state) info item
        (completionDispatch model text info item state))
    (footerEq : ∀ returned, completionReturn model text (completionContextOf model state) info item
        (completionDispatch model text info item state) = some returned →
      completionFooter actual text globals info index item returned =
        completionFooter model text globals info index item returned) :
    uncheckedCompletionBody actual text globals info index item state =
      uncheckedCompletionBody model text globals info index item state := by
  dsimp only [uncheckedCompletionBody]
  rw [dispatchEq]
  split
  · rfl
  · rw [contextEq, returnEq]
    cases returned : completionReturn model text (completionContextOf model state) info item
        (completionDispatch model text info item state) with
    | none => rfl
    | some result => exact footerEq result returned

theorem completionBody_congr (actual model : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine) (state : InitializationFrame)
    (validEq : actual.validState text state.frame = model.validState text state.frame)
    (bodyEq : model.validState text state.frame = true →
      uncheckedCompletionBody actual text globals info index item state =
        uncheckedCompletionBody model text globals info index item state) :
    completionBody actual text globals info index item state = completionBody model text globals info index item state := by
  unfold completionBody
  rw [validEq]
  split
  · exact bodyEq ‹_›
  · rfl

namespace Library

theorem completion_context (library : Library) (reader : BooleanElaboration.Native.Reader) (state : InitializationFrame) :
    completionContextOf (library.calls reader) state = completionContextOf (library.model reader) state := by
  dsimp only [completionContextOf]
  rw [library.context_of]
  rfl

theorem dispatch (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (state : InitializationFrame)
    (framed : ReaderFrame text state.frame) :
    completionDispatch (library.calls reader) text info item state =
      completionDispatch (library.model reader) text info item state := by
  dsimp only [completionDispatch]
  rw [library.completion_context]
  dsimp only [completionInput]
  rw [library.body_of reader _ framed.typed.scalarCount]
  rfl

theorem dispatch_scan (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata) (typed : info.Typed)
    (item : PackageBindings.Routine) (state : InitializationFrame) (framed : ReaderFrame text state.frame) :
    Recursive.ScanDomain text (nativeContext state).model
      (completionDispatch (library.model reader) text info item state).scan :=
  tail_scan library.recursive reader (LeafLibraries.model (library.calls reader)) valid info typed item state framed
    (if item.kind = .function then .returnOnly else .endOnly) (decide (item.kind = .procedure) && !state.initialized)

theorem return_of (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (typed : item.Typed) (state : InitializationFrame)
    (framed : ReaderFrame text state.frame) (result : ApplicationScan)
    (legal : Recursive.ScanDomain text (nativeContext state).model result.scan) :
    completionReturn (library.calls reader) text (nativeContext state).model info item result =
      completionReturn (library.model reader) text (nativeContext state).model info item result := by
  have returned := return_domain state framed item typed result.scan legal
  have afterBound := ApplicationPackageActual.ReturnLibrary.model_bound text valid (nativeContext state)
    result.scan ⟨0, item.resultKind, item.resultBounds, 0⟩ (context_valid state framed)
  apply completionReturn_congr
  · exact library.take reader valid _ legal.position _ (by unfold ValidToken; decide)
  · exact library.leaves.returns.projected_meaning text valid _ _ _ returned
  · exact library.leaves.state_reads text valid _ (context_valid state framed) info _ _
      (fixedAfter_result_bound text _ "return" true (by decide)) afterBound
  · exact library.take reader valid _ afterBound _ (by unfold ValidToken; decide)

theorem return_scan (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (state : InitializationFrame) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (result returned : ApplicationScan)
    (legal : Recursive.ScanDomain text (nativeContext state).model result.scan)
    (read : completionReturn (library.model reader) text (nativeContext state).model info item result = some returned) :
    Recursive.ScanDomain text (nativeContext state).model returned.scan :=
  completionReturn_scan legal (fixedAfter_result_bound text _ ";" false (by decide)) read

theorem footer (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : PackageBindings.Metadata)
    (index : Nat) (item : PackageBindings.Routine) (result : ApplicationScan)
    (bounded : ValidCursor text result.scan.position) :
    completionFooter (library.calls reader) text globals info index item result =
      completionFooter (library.model reader) text globals info index item result := by
  apply completionFooter_congr
  · exact library.take reader valid _ bounded _ (by unfold ValidToken; decide)
  · exact library.skip reader valid _ (fixedAfter_result_bound text _ "end" true (by decide))
  · exact library.name reader valid _ (model_skip_valid text _ (fixedAfter_result_bound text _ "end" true (by decide)))
  · exact library.take reader valid _ (function_nameAfter_bound text _) _ (by unfold ValidToken; decide)
  · exact library.same_name reader text _ _

theorem unchecked_body (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : PackageBindings.Metadata) (typed : info.Typed)
    (index : Nat) (item : PackageBindings.Routine) (itemTyped : item.Typed)
    (state : InitializationFrame) (framed : ReaderFrame text state.frame) :
    uncheckedCompletionBody (library.calls reader) text globals info index item state =
      uncheckedCompletionBody (library.model reader) text globals info index item state := by
  have scan := library.dispatch_scan reader valid info typed item state framed
  apply uncheckedCompletionBody_congr
  · exact library.dispatch reader info item state framed
  · exact library.completion_context reader state
  · exact library.return_of reader valid info item itemTyped state framed _ scan
  · intro returned parsed
    exact library.footer reader valid globals info index item returned
      (library.return_scan reader state info item _ returned scan parsed).position

theorem body (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : PackageBindings.Metadata) (typed : info.Typed)
    (index : Nat) (item : PackageBindings.Routine) (itemTyped : item.Typed)
    (state : InitializationFrame) (prior : OutputFrame state.frame) :
    completionBody (library.calls reader) text globals info index item state =
      completionBody (library.model reader) text globals info index item state := by
  apply completionBody_congr
  · exact library.routine.valid_state valid state.frame prior.imported
  · intro accepted
    exact library.unchecked_body reader valid globals info typed index item itemTyped state (prior.checked accepted)

end Library
end Silver.ApplicationPackageCompletion
