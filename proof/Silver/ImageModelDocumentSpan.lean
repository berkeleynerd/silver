module

public import Silver.ImageModelCodeUnitSpelling

@[expose] public section
namespace Silver.ImageModel.JSON

structure TheoryEntry where
  span : TheorySpan
  leading : List Nat
  trailing : List Nat
  before : ScannerNative.Whitespace leading
  after : ScannerNative.Whitespace trailing

def TheoryEntry.bytes (entry : TheoryEntry) : List Nat := entry.leading ++ entry.span.bytes ++ entry.trailing
def TheoryEntry.value (entry : TheoryEntry) : Value := entry.span.theory.value

def entriesBytes : List TheoryEntry → List Nat
  | [] => []
  | [entry] => entry.bytes
  | entry :: next :: rest => entry.bytes ++ [44] ++ entriesBytes (next :: rest)

theorem entriesBytes_cons (entry : TheoryEntry) (entries : List TheoryEntry) (nonempty : entries ≠ []) :
    entriesBytes (entry :: entries) = entry.bytes ++ [44] ++ entriesBytes entries := by
  cases entries with
  | nil => contradiction
  | cons => rfl

theorem entries_spelling (entries : List TheoryEntry) :
    CodeUnitElements (entries.map TheoryEntry.value) (entriesBytes entries) := by
  induction entries with
  | nil => exact .empty [] (by simp [ScannerNative.Whitespace])
  | cons entry entries ih =>
      cases entries with
      | nil => exact .single entry.value entry.leading entry.span.bytes entry.trailing entry.before entry.span.original_spelling entry.after
      | cons next rest =>
          have nonempty : (next :: rest).map TheoryEntry.value ≠ [] := by simp
          simpa only [entriesBytes, TheoryEntry.bytes, List.map_cons, List.append_assoc] using
            CodeUnitElements.more entry.value ((next :: rest).map TheoryEntry.value) entry.leading entry.span.bytes entry.trailing
              (entriesBytes (next :: rest)) nonempty entry.before entry.span.original_spelling entry.after ih

def entryPrefix (entries : List TheoryEntry) : List Nat := if entries = [] then [] else entriesBytes entries ++ [44]
def entrySuffix (entries : List TheoryEntry) : List Nat := if entries = [] then [] else [44] ++ entriesBytes entries

theorem entriesBytes_split (before : List TheoryEntry) (entry : TheoryEntry) (after : List TheoryEntry) :
    entriesBytes (before ++ entry :: after) = entryPrefix before ++ entry.bytes ++ entrySuffix after := by
  induction before with
  | nil =>
      cases after <;> simp [entriesBytes, entryPrefix, entrySuffix]
  | cons head before ih =>
      rw [List.cons_append, entriesBytes_cons head (before ++ entry :: after) (by simp), ih]
      cases before <;> simp [entryPrefix, entriesBytes, List.append_assoc]

/-- Complete producer-document spelling. Only the root has an object member;
theories retain broad byte-oriented string spellings and their original spans.
Root-key contents are fixed by the producer grammar, while its escapes and all
external/inter-token whitespace remain explicit. -/
structure DocumentSpan where
  entries : List TheoryEntry
  leading : List Nat
  beforeKey : List Nat
  key : List Nat
  beforeColon : List Nat
  afterColon : List Nat
  emptyList : List Nat
  afterList : List Nat
  trailing : List Nat
  leadingSpace : ScannerNative.Whitespace leading
  beforeKeySpace : ScannerNative.Whitespace beforeKey
  keyContent : CodeUnitContent (ascii "theory_declarations") key
  beforeColonSpace : ScannerNative.Whitespace beforeColon
  afterColonSpace : ScannerNative.Whitespace afterColon
  emptyListSpace : ScannerNative.Whitespace emptyList
  afterListSpace : ScannerNative.Whitespace afterList
  trailingSpace : ScannerNative.Whitespace trailing

def DocumentSpan.listBytes (document : DocumentSpan) : List Nat :=
  if document.entries = [] then document.emptyList else entriesBytes document.entries

def DocumentSpan.memberBytes (document : DocumentSpan) : List Nat :=
  document.beforeKey ++ [34] ++ document.key ++ [34] ++ document.beforeColon ++ [58] ++ document.afterColon ++
    ([91] ++ document.listBytes ++ [93]) ++ document.afterList

def DocumentSpan.coreBytes (document : DocumentSpan) : List Nat := [123] ++ document.memberBytes ++ [125]
def DocumentSpan.bytes (document : DocumentSpan) : List Nat := document.leading ++ document.coreBytes ++ document.trailing
def DocumentSpan.value (document : DocumentSpan) : Value :=
  .object [(ascii "theory_declarations", .array (document.entries.map TheoryEntry.value))]

def DocumentSpan.header (document : DocumentSpan) : List Nat :=
  document.leading ++ [123] ++ document.beforeKey ++ [34] ++ document.key ++ [34] ++
    document.beforeColon ++ [58] ++ document.afterColon ++ [91]

def DocumentSpan.footer (document : DocumentSpan) : List Nat := [93] ++ document.afterList ++ [125] ++ document.trailing

theorem DocumentSpan.bytes_split (document : DocumentSpan) :
    document.bytes = document.header ++ document.listBytes ++ document.footer := by
  simp only [DocumentSpan.bytes, DocumentSpan.coreBytes, DocumentSpan.memberBytes,
    DocumentSpan.header, DocumentSpan.footer, List.append_assoc]

theorem DocumentSpan.original_spelling (document : DocumentSpan) : CodeUnitSpelling document.value document.coreBytes := by
  have elements : CodeUnitElements (document.entries.map TheoryEntry.value) document.listBytes := by
    by_cases empty : document.entries = []
    · simpa only [DocumentSpan.listBytes, empty, ↓reduceIte, List.map_nil] using CodeUnitElements.empty document.emptyList document.emptyListSpace
    · simpa only [DocumentSpan.listBytes, empty, ↓reduceIte] using entries_spelling document.entries
  exact .object [(ascii "theory_declarations", .array (document.entries.map TheoryEntry.value))] document.memberBytes
    (.single (ascii "theory_declarations") (.array (document.entries.map TheoryEntry.value))
      document.beforeKey document.key document.beforeColon document.afterColon ([91] ++ document.listBytes ++ [93]) document.afterList
      document.beforeKeySpace document.keyContent document.beforeColonSpace document.afterColonSpace
      (.array (document.entries.map TheoryEntry.value) document.listBytes elements) document.afterListSpace)

/-- Original source bytes around any chosen theory entry. These are the exact
whole-document contexts used when replacing only the selected theory's two
array fields. -/
theorem DocumentSpan.split_entry (document : DocumentSpan) (before : List TheoryEntry) (entry : TheoryEntry) (after : List TheoryEntry)
    (position : document.entries = before ++ entry :: after) :
    document.bytes =
      (document.header ++ entryPrefix before ++ entry.leading) ++ entry.span.bytes ++
        (entry.trailing ++ entrySuffix after ++ document.footer) := by
  rw [document.bytes_split]
  have nonempty : document.entries ≠ [] := by rw [position]; simp
  simp only [DocumentSpan.listBytes, nonempty, ↓reduceIte]
  rw [position, entriesBytes_split]
  simp only [TheoryEntry.bytes, List.append_assoc]

end Silver.ImageModel.JSON
