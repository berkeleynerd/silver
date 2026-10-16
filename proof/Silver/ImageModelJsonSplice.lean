module

public import Silver.ImageModelJsonSpelling
public import Silver.ImageModelInsertion

@[expose] public section
namespace Silver.ImageModel.JSON

/-- Appending serialized entries retains every original byte, including the
whitespace after the last original element. The leading comma is valid because
both lists have actual entries; `null` and empty arrays are not conflated. -/
theorem AsciiElements.append_nonempty {left right : List Value} {before after : List Nat}
    (first : AsciiElements left before) (second : AsciiElements right after)
    (leftNonempty : left ≠ []) (rightNonempty : right ≠ []) :
    AsciiElements (left ++ right) (before ++ [44] ++ after) := by
  induction left generalizing before with
  | nil => contradiction
  | cons value values ih =>
      cases first with
      | single value leading bytes trailing whitespace item spaces =>
          exact .more value right leading bytes trailing after rightNonempty whitespace item spaces second
      | more value values leading bytes spaces rest nonempty whitespace item between tail =>
          have joined := AsciiElements.more value (values ++ right) leading bytes spaces
            (rest ++ [44] ++ after) (by simp [nonempty]) whitespace item between (ih tail nonempty)
          simpa only [List.cons_append, List.append_assoc] using joined

/-- Inserting a comma and a valid node immediately before a nonempty array's
closing bracket appends precisely that node to the parsed list. -/
theorem AsciiElements.append_node {values : List Value} {body : List Nat}
    (original : AsciiElements values body) (nonempty : values ≠ [])
    (node : Value) (bytes : List Nat) (inserted : AsciiSpelling node bytes) :
    AsciiSpelling (.array (values ++ [node])) ([91] ++ body ++ [44] ++ bytes ++ [93]) := by
  have last : AsciiElements [node] bytes := by
    simpa using AsciiElements.single node [] bytes [] (by intro byte member; simp at member)
      inserted (by intro byte member; simp at member)
  simpa only [List.append_assoc] using AsciiSpelling.array (values ++ [node])
    (body ++ [44] ++ bytes) (original.append_nonempty last nonempty (by simp))

end Silver.ImageModel.JSON

namespace Silver.ImageModel

/-- Original byte offsets at two explicit splits determine the exact spliced
sequence. This connects scanner-derived closing offsets with typed syntax. -/
theorem splice_segments (pre middle suffix first second : List α) :
    splice (pre ++ middle ++ suffix) first second pre.length
      (pre.length + middle.length) = pre ++ first ++ middle ++ second ++ suffix := by
  have firstTake : (pre ++ middle ++ suffix).take pre.length = pre := by
    rw [List.append_assoc, List.take_left]
  have firstDrop : (pre ++ middle ++ suffix).drop pre.length = middle ++ suffix := by
    rw [List.append_assoc, List.drop_left]
  have finalDrop : (pre ++ middle ++ suffix).drop (pre.length + middle.length) = suffix := by
    rw [← List.length_append, List.drop_left]
  simp only [splice, firstTake, firstDrop, finalDrop, Nat.add_sub_cancel_left, List.take_left]

/-- Two selected array closures yield exact appended declaration/include lists.
The surrounding document bytes and all existing entries remain unchanged. -/
theorem splice_array_nodes (pre between suffix leftBody rightBody firstBytes secondBytes : List Nat)
    (left right : List JSON.Value) (first second : JSON.Value)
    (leftSyntax : JSON.AsciiElements left leftBody)
    (rightSyntax : JSON.AsciiElements right rightBody)
    (leftNonempty : left ≠ []) (rightNonempty : right ≠ [])
    (firstSyntax : JSON.AsciiSpelling first firstBytes)
    (secondSyntax : JSON.AsciiSpelling second secondBytes) :
    let original := pre ++ [91] ++ leftBody ++ [93] ++ between ++ [91] ++ rightBody ++ [93] ++ suffix
    let a := pre.length + 1 + leftBody.length
    let b := a + 1 + between.length + 1 + rightBody.length
    splice original ([44] ++ firstBytes) ([44] ++ secondBytes) a b =
      pre ++ ([91] ++ leftBody ++ [44] ++ firstBytes ++ [93]) ++ between ++
        ([91] ++ rightBody ++ [44] ++ secondBytes ++ [93]) ++ suffix ∧
    JSON.AsciiSpelling (.array (left ++ [first])) ([91] ++ leftBody ++ [44] ++ firstBytes ++ [93]) ∧
    JSON.AsciiSpelling (.array (right ++ [second])) ([91] ++ rightBody ++ [44] ++ secondBytes ++ [93]) := by
  refine ⟨?_, leftSyntax.append_node leftNonempty first firstBytes firstSyntax,
    rightSyntax.append_node rightNonempty second secondBytes secondSyntax⟩
  have result := splice_segments (pre ++ [91] ++ leftBody)
    ([93] ++ between ++ [91] ++ rightBody) ([93] ++ suffix) ([44] ++ firstBytes) ([44] ++ secondBytes)
  simpa only [List.length_append, List.length_cons, List.length_nil, Nat.add_zero, Nat.zero_add,
    List.append_assoc, Nat.add_assoc] using result

end Silver.ImageModel
