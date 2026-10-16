module

public import Silver.ImageModelTemplateIndex

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.Templates

def field (value : JSON.Value) (index : Nat) : JSON.Value :=
  match value with
  | .array values => values[index]?.getD .null
  | _ => .null

def path (value : JSON.Value) (indices : List Nat) : JSON.Value :=
  indices.foldl field value

def arraySize : JSON.Value → Nat
  | .array values => values.length
  | _ => 0

/-- Complete finite serialization, including every declaration, include, label,
domain, scoped origin, boolean, and null field in each selected theory. -/
theorem serialized_theory (kind : Native.Theory) :
    (theoryValue kind).encode = bytes (templateKind kind) := by
  cases kind <;> simp only [theoryValue, integerTheory, stringTheory, imageTheory,
    JSON.Value.encode, List.map_cons, List.map_nil] <;> decide +kernel

theorem schema_shape :
    [integerTheory, stringTheory, imageTheory].map arraySize = [8, 8, 8] ∧
    [integerTheory, stringTheory, imageTheory].map (fun value => arraySize (field value 3)) = [10, 15, 5] ∧
    [integerTheory, stringTheory, imageTheory].map (fun value => arraySize (field value 6)) = [3, 8, 4] := by
  decide +kernel

theorem selected_names :
    [integerTheory, stringTheory, imageTheory].map (fun value => (field value 4).encode) =
      ["Standard__integer", "Standard__string", "Standard_String__Img"].map
        (fun name => (JSON.Value.string (JSON.ascii name)).encode) := by
  simp only [integerTheory, stringTheory, imageTheory, field,
    List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some, JSON.Value.encode,
    List.map_cons, List.map_nil] <;> decide +kernel

theorem selected_tags :
    ∀ kind : Native.Theory,
      (field (theoryValue kind) 0).encode = (JSON.Value.string (JSON.ascii "W_THEORY_DECLARATION")).encode ∧
      (field (theoryValue kind) 2).encode = JSON.ascii "4" ∧
      (field (theoryValue kind) 5).encode = JSON.ascii "1" := by
  intro kind
  cases kind <;> simp only [theoryValue, integerTheory, stringTheory, imageTheory,
    field, List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some,
    JSON.Value.encode] <;> decide +kernel

theorem signed32_range :
    (path integerTheory [3, 0, 6]).encode =
      (JSON.Value.array [.string (JSON.ascii "W_RANGE_TYPE_DEFINITION"),
        .number [48], .number [49], .string (JSON.ascii "-2147483648"),
        .string (JSON.ascii "2147483647")]).encode := by
  simp only [integerTheory, field, path, List.foldl_cons,
    List.foldl_nil, List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some,
    JSON.Value.encode, List.map_cons, List.map_nil] <;> decide +kernel

theorem selected_declarations :
    (path integerTheory [3, 0, 4, 3]).encode = (JSON.Value.string (JSON.ascii "integer")).encode ∧
    (path integerTheory [3, 4, 3]).encode =
      (JSON.Value.array [.string (JSON.ascii "W_MODULE"), .number [48], .number [49],
        .string (JSON.ascii "ada__model"), .string (JSON.ascii "Static_Discrete")]).encode ∧
    (path stringTheory [3, 3, 4, 3]).encode = (JSON.Value.string (JSON.ascii "string__")).encode ∧
    (path stringTheory [3, 2, 3]).encode =
      (JSON.Value.array [.string (JSON.ascii "W_MODULE"), .number [48], .number [49],
        .string (JSON.ascii "ada__model"), .string (JSON.ascii "Unconstr_Array")]).encode := by
  simp only [integerTheory, stringTheory, field, path,
    List.foldl_cons, List.foldl_nil, List.getElem?_cons_succ, List.getElem?_cons_zero,
    Option.getD_some, JSON.Value.encode, List.map_cons, List.map_nil] <;> decide +kernel

theorem image_to_string_signature :
    (path imageTheory [3, 0, 3, 3, 3]).encode = (JSON.Value.string (JSON.ascii "to_string")).encode ∧
    arraySize (path imageTheory [3, 0, 4]) = 2 ∧
    (path imageTheory [3, 0, 4, 0, 4, 4]).encode =
      (JSON.Value.array [.string (JSON.ascii "W_NAME"), .number [48], .number [49],
        .string (JSON.ascii "__image"), .string [],
        .array [.string (JSON.ascii "W_MODULE"), .number [48], .number [49],
          .string (JSON.ascii "_gnatprove_standard"), .string (JSON.ascii "Main")],
        .boolean false]).encode ∧
    (path imageTheory [3, 0, 4, 1, 4, 4, 3]).encode = (JSON.Value.string (JSON.ascii "int")).encode ∧
    (path imageTheory [3, 0, 8, 4]).encode =
      (JSON.Value.array [.string (JSON.ascii "W_NAME"), .number [48], .number [49],
        .string (JSON.ascii "string__"), .string [],
        .array [.string (JSON.ascii "W_MODULE"), .number [48], .number [49],
          .string [], .string (JSON.ascii "Standard__string")], .boolean false]).encode := by
  simp only [imageTheory, field, path, List.foldl_cons,
    List.foldl_nil, List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some,
    JSON.Value.encode, List.map_cons, List.map_nil] <;> decide +kernel

end Silver.ImageModel.Templates
