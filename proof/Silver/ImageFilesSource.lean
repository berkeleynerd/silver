module

public import Silver.ImageFilesTrace
public import Silver.ImageFilesSplice
public import Silver.ImageFilesCapture
public import Silver.ImageFilesSourceShape
import all Init.Data.Repr

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 20000000
namespace Silver.ImageModel.FilesSource
open FilesNative

def snapshotPrefix : List String :=
  ["procedure", "snapshot", "(", "input_name", ",", "snapshot_name", ":", "string", ";", "plan", ":", "out", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "is", "input", ",", "output", ":", "system", ".", "address", ";", "item", ",", "status", ":", "interfaces", ".", "c", ".", "int", ";", "current", ":", "model", ".", "state", ":=", "model", ".", "initial_state", ";", "begin", "plan", ":=", "(", "others", "=>", "<", ">", ")", ";", "success", ":=", "false", ";", "reset_observations", ";", "input", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "input_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"rb\"", ")", ")", ";", "if", "input", "=", "system", ".", "null_address", "then", "return", ";", "end", "if", ";", "output", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "snapshot_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"wbx\"", ")", ")", ";", "if", "output", "=", "system", ".", "null_address", "then", "status", ":=", "c_close", "(", "input", ")", ";", "files_closed", ":=", "status", "=", "0", ";", "return", ";", "end", "if", ";", "loop", "pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "copied_bytes", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "written_bytes", ")", ";"]

def snapshotSuffix : List String :=
  ["end", "loop", ";", "status", ":=", "c_close", "(", "input", ")", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "status", ":=", "c_close", "(", "output", ")", ";", "files_closed", ":=", "status", "=", "0", "and", "then", "success", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "plan", ":=", "model", ".", "finish", "(", "current", ")", ";", "rechecked", ":=", "plan", ";", "success", ":=", "success", "and", "then", "plan", ".", "kind", "/=", "model", ".", "invalid_model", ";", "end", "snapshot", ";"]

def snapshotRender : List String := snapshotPrefix ++ snapshot.render ++ snapshotSuffix

theorem snapshot_block : SourceBridge.block "procedure" "snapshot" Source.imageFilesBodyTokens =
    some snapshotRender := by
  simp only [snapshotRender, snapshot, copiedByte, stopFailure, Command.list,
    List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, Action.render, Test.render]
  decide +kernel

def refinePrefix : List String :=
  ["procedure", "refine", "(", "snapshot_name", ",", "refined_name", ":", "string", ";", "plan", ":", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "is", "input", ",", "output", ":", "system", ".", "address", ";", "item", ",", "status", ":", "interfaces", ".", "c", ".", "int", ";", "current", ":", "model", ".", "state", ":=", "model", ".", "initial_state", ";", "position", ":", "model", ".", "byte_count", ":=", "0", ";", "declarations_done", ",", "includes_done", ":", "boolean", ":=", "false", ";", "checked", ":", "model", ".", "plan", ";", "begin", "success", ":=", "false", ";", "reset_observations", ";", "input", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "snapshot_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"rb\"", ")", ")", ";", "if", "input", "=", "system", ".", "null_address", "then", "return", ";", "end", "if", ";", "output", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "refined_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"wbx\"", ")", ")", ";", "if", "output", "=", "system", ".", "null_address", "then", "status", ":=", "c_close", "(", "input", ")", ";", "files_closed", ":=", "status", "=", "0", ";", "return", ";", "end", "if", ";", "loop", "pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "copied_bytes", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "spliced_prefix", "(", "read_bytes", ",", "written_bytes", ",", "plan", ",", "position", ")", ")", ";", "pragma", "loop_invariant", "(", "declarations_done", "=", "(", "position", ">", "plan", ".", "declarations_offset", ")", ")", ";", "pragma", "loop_invariant", "(", "includes_done", "=", "(", "position", ">", "plan", ".", "includes_offset", ")", ")", ";"]

def refineSuffix : List String :=
  ["end", "loop", ";", "status", ":=", "c_close", "(", "input", ")", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "status", ":=", "c_close", "(", "output", ")", ";", "files_closed", ":=", "status", "=", "0", "and", "then", "success", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "checked", ":=", "model", ".", "finish", "(", "current", ")", ";", "rechecked", ":=", "checked", ";", "success", ":=", "success", "and", "then", "checked", "=", "plan", ";", "end", "refine", ";"]

def refineRender : List String := refinePrefix ++ refine.render ++ refineSuffix

theorem refine_block : SourceBridge.block "procedure" "refine" Source.imageFilesBodyTokens =
    some refineRender := by
  simp only [refineRender, refine, copiedByte, stopFailure, insertions, Command.list,
    List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, Action.render, Test.render]
  decide +kernel

def specPrefix : List String :=
  ["with", "ada", ".", "text_io", ";", "with", "spark", ".", "big_integers", ";", "with", "spark", ".", "containers", ".", "functional", ".", "infinite_sequences", ";", "with", "silver_image_model", ";", "with", "silver_platform", ";", "package", "silver_image_files", "with", "spark_mode", "=>", "on", "is", "package", "model", "renames", "silver_image_model", ";", "use", "type", "model", ".", "plan", ";", "use", "type", "model", ".", "plan_kind", ";", "use", "type", "model", ".", "byte_count", ";", "package", "bytes", "is", "new", "spark", ".", "containers", ".", "functional", ".", "infinite_sequences", "(", "element_type", "=>", "character", ",", "use_logical_equality", "=>", "true", ")", ";", "use", "type", "bytes", ".", "sequence", ";", "use", "spark", ".", "big_integers", ";", "package", "counts", "is", "new", "signed_conversions", "(", "model", ".", "byte_count", ")", ";", "function", "spliced_prefix", "(", "original", ",", "refined", ":", "bytes", ".", "sequence", ";", "plan", ":", "model", ".", "plan", ";", "count", ":", "model", ".", "byte_count", ")", "return", "boolean", "is"]

def specSuffix : List String :=
  ["with", "ghost", "=>", "static", ",", "pre", "=>", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset", ";", "read_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";", "copied_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";", "written_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";", "read_ended", ",", "files_closed", ":", "boolean", ":=", "false", "with", "ghost", "=>", "static", ";", "rechecked", ":", "model", ".", "plan", ":=", "(", "others", "=>", "<", ">", ")", "with", "ghost", "=>", "static", ";", "procedure", "snapshot", "(", "input_name", ",", "snapshot_name", ":", "string", ";", "plan", ":", "out", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "with", "global", "=>", "(", "in_out", "=>", "ada", ".", "text_io", ".", "file_system", ",", "output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ",", "read_ended", ",", "files_closed", ",", "rechecked", ")", ")", ",", "pre", "=>", "silver_platform", ".", "valid_path", "(", "input_name", ")", "and", "then", "silver_platform", ".", "valid_path", "(", "snapshot_name", ")", "and", "then", "input_name", "/=", "snapshot_name", ",", "post", "=>", "(", "runtime", "=>", "(", "if", "plan", ".", "kind", "=", "model", ".", "refine", "then", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset", "and", "then", "plan", ".", "includes_offset", "<", "plan", ".", "bytes", ")", ",", "static", "=>", "(", "if", "success", "then", "read_ended", "and", "then", "files_closed", "and", "then", "read_bytes", "=", "copied_bytes", "and", "then", "read_bytes", "=", "written_bytes", "and", "then", "plan", "=", "rechecked", ")", ")", ";", "procedure", "refine", "(", "snapshot_name", ",", "refined_name", ":", "string", ";", "plan", ":", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "with", "global", "=>", "(", "in_out", "=>", "ada", ".", "text_io", ".", "file_system", ",", "output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ",", "read_ended", ",", "files_closed", ",", "rechecked", ")", ")", ",", "pre", "=>", "silver_platform", ".", "valid_path", "(", "snapshot_name", ")", "and", "then", "silver_platform", ".", "valid_path", "(", "refined_name", ")", "and", "then", "snapshot_name", "/=", "refined_name", "and", "then", "plan", ".", "kind", "=", "model", ".", "refine", "and", "then", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset", "and", "then", "plan", ".", "includes_offset", "<", "plan", ".", "bytes", ",", "post", "=>", "(", "static", "=>", "(", "if", "success", "then", "read_ended", "and", "then", "files_closed", "and", "then", "read_bytes", "=", "copied_bytes", "and", "then", "rechecked", "=", "plan", "and", "then", "spliced_prefix", "(", "read_bytes", ",", "written_bytes", ",", "plan", ",", "plan", ".", "bytes", ")", ")", ")", ";", "end", "silver_image_files", ";"]

def specRender : List String := specPrefix ++ FilesSplice.expression.render ++ specSuffix

theorem splice_expression : Source.imageFilesSpecTokens = specRender := by
  simp only [specRender, FilesSplice.expression, FilesSplice.shifted,
    FilesSplice.Predicate.render, FilesSplice.Number.render, FilesSplice.Byte.render,
    FilesSplice.Sequence.name, FilesSplice.Fragment.render, FilesSplice.Fragment.renderOffset,
    FilesSplice.Fragment.renderLength, FilesSplice.Fragment.name]
  decide +kernel

theorem body_context : Source.imageFilesBodyTokens = FilesShape.body := by decide +kernel

/-- Exact authoritative bytes and lexical context, with both loop bodies and
Spliced_Prefix interpreted by the typed command/expression renderings above. -/
structure ActualSource : Prop where
  spec : Source.lex Source.imageFilesSpec = some specRender
  body : Source.lex Source.imageFilesBody = some FilesShape.body
  snapshot : SourceBridge.block "procedure" "snapshot" Source.imageFilesBodyTokens = some snapshotRender
  refine : SourceBridge.block "procedure" "refine" Source.imageFilesBodyTokens = some refineRender

theorem actual_source : ActualSource := by
  constructor
  · rw [Source.imageFilesSpecTokens_correct, splice_expression]
  · rw [Source.imageFilesBodyTokens_correct, body_context]
  · exact snapshot_block
  · exact refine_block

/-- Full finite executions of either checked native loop determine the scanner
state from the exact observed input bytes, including partial failed reads. -/
theorem loop_model (command : Command) (selected : command = snapshot ∨ command = refine)
    (tables : Native.Tables) (nativeHelpers : Core.Helpers)
    (helpers : SourceBridge.NativeHelperBodies tables nativeHelpers)
    (runStructural runConsume : Core.State → Nat → Core.State)
    (scanner : SourceBridge.InterpretedScanner (SourceBridge.totalizedHelpers tables nativeHelpers) runStructural runConsume)
    (before after : Frame) (empty : before.read = [])
    (execution : LoopRun command runConsume before after) :
    after.current = after.read.foldl (ScannerNative.consume (Core.modelHelpers tables)) before.current := by
  have trace : SourceBridge.NativeScan runConsume before.current after.read after.current := by
    rcases selected with h | h <;> subst command
    · exact snapshot_trace runConsume before after empty execution
    · exact refine_trace runConsume before after empty execution
  exact SourceBridge.native_scan_model tables nativeHelpers helpers runStructural runConsume scanner _ _ _ trace

theorem loop_plan (command : Command) (selected : command = snapshot ∨ command = refine)
    (tables : Native.Tables) (nativeHelpers : Core.Helpers)
    (helpers : SourceBridge.NativeHelperBodies tables nativeHelpers)
    (runStructural runConsume : Core.State → Nat → Core.State)
    (scanner : SourceBridge.InterpretedScanner (SourceBridge.totalizedHelpers tables nativeHelpers) runStructural runConsume)
    (runFinish : FinishNative.Input → FinishNative.Plan) (finish : SourceBridge.InterpretedFinish runFinish)
    (before after : Frame) (empty : before.read = [])
    (execution : LoopRun command runConsume before after) :
    runFinish after.current.finishView = FinishNative.model
      (after.read.foldl (ScannerNative.consume (Core.modelHelpers tables)) before.current).finishView := by
  rw [SourceBridge.interpreted_finish runFinish finish,
    loop_model command selected tables nativeHelpers helpers runStructural runConsume scanner before after empty execution]

end Silver.ImageModel.FilesSource
