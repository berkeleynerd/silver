module

public import Silver.ImageModelTemplateSource
public import Silver.ImageModelTemplateFragments
public import Silver.ImageModelBodyCertificate
public import Silver.ImageModelSpecCertificate

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.Templates
open Silver.SourceBridge

inductive Fragment
  | declarations | includes
  deriving DecidableEq, Repr

def fragmentKind : Fragment → Kind
  | .declarations => .declarations
  | .includes => .includes

def fragmentBytes : Fragment → List Nat
  | .declarations => Clone.declarationsFragment
  | .includes => Clone.includesFragment

theorem native_template_selector :
    qualifiedExpressionBody "template_kind" Source.imageModelBodyTokens =
      some (expectedTokens "case Kind is when Integer_Theory => Templates.Integer_Template, when String_Theory => Templates.String_Template, when Image_Theory => Templates.Image_Template") := by
  decide +kernel

theorem native_fragment_selector :
    qualifiedExpressionBody "fragment_kind" Source.imageModelBodyTokens =
      some (expectedTokens "case Kind is when Declarations_Insertion => Templates.Declarations_Fragment, when Includes_Insertion => Templates.Includes_Fragment") := by
  decide +kernel

theorem native_insertion_adapters :
    Source.expressionBody "insertion_length" Source.imageModelBodyTokens =
      some (expectedTokens "Templates.Length (Fragment_Kind (Kind))") ∧
    Source.expressionBody "insertion_byte" Source.imageModelBodyTokens =
      some (expectedTokens "Templates.Byte_At (Fragment_Kind (Kind), Position)") ∧
    typeDeclaration "insertion_kind" Source.imageModelSpecTokens =
      some (expectedTokens "(Declarations_Insertion, Includes_Insertion)") := by
  decide +kernel

def Calls.tables (calls : Calls) : Native.Tables where
  length kind := calls.length (templateKind kind)
  byte kind := calls.byteAt (templateKind kind)

theorem interpreted_theory_length (calls : Calls) (source : InterpretedSource calls)
    (kind : Native.Theory) : (calls.tables).length kind = (theoryValue kind).encode.length := by
  rw [serialized_theory]
  exact interpreted_length calls source (templateKind kind)

theorem interpreted_theory_byte (calls : Calls) (source : InterpretedSource calls)
    (kind : Native.Theory) (position : Nat) (positive : 1 ≤ position)
    (bounded : position ≤ (calls.tables).length kind) :
    (calls.tables).byte kind position = (theoryValue kind).encode[position - 1]?.getD 0 := by
  rw [serialized_theory]
  exact interpreted_byte calls source (templateKind kind) position positive bounded

theorem serialized_fragment (kind : Fragment) : bytes (fragmentKind kind) = fragmentBytes kind := by
  cases kind
  · exact declarations_serialized
  · exact includes_serialized

theorem interpreted_fragment_length (calls : Calls) (source : InterpretedSource calls)
    (kind : Fragment) : calls.length (fragmentKind kind) = (fragmentBytes kind).length := by
  rw [interpreted_length calls source, serialized_fragment]

theorem interpreted_fragment_byte (calls : Calls) (source : InterpretedSource calls)
    (kind : Fragment) (position : Nat) (positive : 1 ≤ position)
    (bounded : position ≤ calls.length (fragmentKind kind)) :
    calls.byteAt (fragmentKind kind) position = (fragmentBytes kind)[position - 1]?.getD 0 := by
  rw [interpreted_byte calls source (fragmentKind kind) position positive bounded, serialized_fragment]

end Silver.ImageModel.Templates
