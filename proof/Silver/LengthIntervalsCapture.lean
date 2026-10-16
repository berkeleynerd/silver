module

public import Silver.SourceLexer
public import Silver.LengthIntervalsSpecSource
public import Silver.LengthIntervalsBodySource
public meta import Silver.CertificateWitness

@[expose] public section

/-! Kernel-checked physical-line certificates and balanced reconstruction of
`silver_length_intervals.ads` and `.adb`, generated with
`generate_source_certificate.generate`. Every original byte is retained. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Source

def lengthIntervalsSpecTokens_line_0 : LineCertificate where
  text := "with Silver_Path_Facts;"
  tokens := ["with", "silver_path_facts", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_1 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_2 : LineCertificate where
  text := "package Silver_Length_Intervals with SPARK_Mode => On is"
  tokens := ["package", "silver_length_intervals", "with", "spark_mode", "=>", "on", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_3 : LineCertificate where
  text := "   package Paths renames Silver_Path_Facts;"
  tokens := ["package", "paths", "renames", "silver_path_facts", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_4 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_5 : LineCertificate where
  text := "   --  Both endpoints retain their contributions when an operand has no value."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_6 : LineCertificate where
  text := "   --  In particular, an empty Image must not erase the other String operands."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_7 : LineCertificate where
  text := "   type Summary is record"
  tokens := ["type", "summary", "is", "record"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_8 : LineCertificate where
  text := "      Minimum_Length, Static_Length : Paths.Length_Value;"
  tokens := ["minimum_length", ",", "static_length", ":", "paths", ".", "length_value", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_9 : LineCertificate where
  text := "      Dynamic_Count : Paths.Operand_Count;"
  tokens := ["dynamic_count", ":", "paths", ".", "operand_count", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_10 : LineCertificate where
  text := "      Empty_Value : Boolean := False;"
  tokens := ["empty_value", ":", "boolean", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_11 : LineCertificate where
  text := "   end record;"
  tokens := ["end", "record", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_12 : LineCertificate where
  text := "   Empty_Summary : constant Summary := (0, 0, 0, True);"
  tokens := ["empty_summary", ":", "constant", "summary", ":=", "(", "0", ",", "0", ",", "0", ",", "true", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_13 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_14 : LineCertificate where
  text := "   function Is_Empty (Value : Summary) return Boolean is (Value.Empty_Value);"
  tokens := ["function", "is_empty", "(", "value", ":", "summary", ")", "return", "boolean", "is", "(", "value", ".", "empty_value", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_15 : LineCertificate where
  text := "   function Lower (Value : Summary) return Paths.Summary is"
  tokens := ["function", "lower", "(", "value", ":", "summary", ")", "return", "paths", ".", "summary", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_16 : LineCertificate where
  text := "     (Value.Minimum_Length, Value.Dynamic_Count);"
  tokens := ["(", "value", ".", "minimum_length", ",", "value", ".", "dynamic_count", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_17 : LineCertificate where
  text := "   function Upper (Value : Summary) return Paths.Summary is"
  tokens := ["function", "upper", "(", "value", ":", "summary", ")", "return", "paths", ".", "summary", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_18 : LineCertificate where
  text := "     (Value.Static_Length, Value.Dynamic_Count);"
  tokens := ["(", "value", ".", "static_length", ",", "value", ".", "dynamic_count", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_19 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_20 : LineCertificate where
  text := "   function Fits (Facts : Paths.Context; Value : Summary) return Boolean"
  tokens := ["function", "fits", "(", "facts", ":", "paths", ".", "context", ";", "value", ":", "summary", ")", "return", "boolean"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_21 : LineCertificate where
  text := "     with Global => null;"
  tokens := ["with", "global", "=>", "null", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_22 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_23 : LineCertificate where
  text := "   --  Assignment is directional: Right is the target. Empty values waive"
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_24 : LineCertificate where
  text := "   --  runtime equality, but their retained contribution must fit a fixed target."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_25 : LineCertificate where
  text := "   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean"
  tokens := ["function", "same_length", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "boolean"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_26 : LineCertificate where
  text := "     with Global => null;"
  tokens := ["with", "global", "=>", "null", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_27 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_28 : LineCertificate where
  text := "   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)"
  tokens := ["function", "refine_equal", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_29 : LineCertificate where
  text := "      return Paths.Context"
  tokens := ["return", "paths", ".", "context"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_30 : LineCertificate where
  text := "     with Global => null;"
  tokens := ["with", "global", "=>", "null", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_31 : LineCertificate where
  text := "end Silver_Length_Intervals;"
  tokens := ["end", "silver_length_intervals", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_line_32 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsSpecTokens_block_0_1 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_0

def lengthIntervalsSpecTokens_block_1_2 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_1

def lengthIntervalsSpecTokens_block_0_2 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_0_1 lengthIntervalsSpecTokens_block_1_2
    "with Silver_Path_Facts;\n"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';']
      []))

def lengthIntervalsSpecTokens_block_2_3 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_2

def lengthIntervalsSpecTokens_block_3_4 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_3

def lengthIntervalsSpecTokens_block_2_4 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_2_3 lengthIntervalsSpecTokens_block_3_4
    "package Silver_Length_Intervals with SPARK_Mode => On is\n   package Paths renames Silver_Path_Facts;"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'P', 'a', 't', 'h', 's', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';']))

def lengthIntervalsSpecTokens_block_0_4 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_0_2 lengthIntervalsSpecTokens_block_2_4
    "with Silver_Path_Facts;\n\npackage Silver_Length_Intervals with SPARK_Mode => On is\n   package Paths renames Silver_Path_Facts;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';', '\n']
      ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'P', 'a', 't', 'h', 's', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';']))

def lengthIntervalsSpecTokens_block_4_5 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_4

def lengthIntervalsSpecTokens_block_5_6 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_5

def lengthIntervalsSpecTokens_block_4_6 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_4_5 lengthIntervalsSpecTokens_block_5_6
    "\n   --  Both endpoints retain their contributions when an operand has no value."
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'B', 'o', 't', 'h', ' ', 'e', 'n', 'd', 'p', 'o', 'i', 'n', 't', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', 's', ' ', 'w', 'h', 'e', 'n', ' ', 'a', 'n', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', ' ', 'h', 'a', 's', ' ', 'n', 'o', ' ', 'v', 'a', 'l', 'u', 'e', '.']))

def lengthIntervalsSpecTokens_block_6_7 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_6

def lengthIntervalsSpecTokens_block_7_8 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_7

def lengthIntervalsSpecTokens_block_6_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_6_7 lengthIntervalsSpecTokens_block_7_8
    "   --  In particular, an empty Image must not erase the other String operands.\n   type Summary is record"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'I', 'n', ' ', 'p', 'a', 'r', 't', 'i', 'c', 'u', 'l', 'a', 'r', ',', ' ', 'a', 'n', ' ', 'e', 'm', 'p', 't', 'y', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'm', 'u', 's', 't', ' ', 'n', 'o', 't', ' ', 'e', 'r', 'a', 's', 'e', ' ', 't', 'h', 'e', ' ', 'o', 't', 'h', 'e', 'r', ' ', 'S', 't', 'r', 'i', 'n', 'g', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', 's', '.']
      [' ', ' ', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', ' ', 'r', 'e', 'c', 'o', 'r', 'd']))

def lengthIntervalsSpecTokens_block_4_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_4_6 lengthIntervalsSpecTokens_block_6_8
    "\n   --  Both endpoints retain their contributions when an operand has no value.\n   --  In particular, an empty Image must not erase the other String operands.\n   type Summary is record"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'B', 'o', 't', 'h', ' ', 'e', 'n', 'd', 'p', 'o', 'i', 'n', 't', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', 's', ' ', 'w', 'h', 'e', 'n', ' ', 'a', 'n', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', ' ', 'h', 'a', 's', ' ', 'n', 'o', ' ', 'v', 'a', 'l', 'u', 'e', '.']
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'I', 'n', ' ', 'p', 'a', 'r', 't', 'i', 'c', 'u', 'l', 'a', 'r', ',', ' ', 'a', 'n', ' ', 'e', 'm', 'p', 't', 'y', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'm', 'u', 's', 't', ' ', 'n', 'o', 't', ' ', 'e', 'r', 'a', 's', 'e', ' ', 't', 'h', 'e', ' ', 'o', 't', 'h', 'e', 'r', ' ', 'S', 't', 'r', 'i', 'n', 'g', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', 's', '.', '\n', ' ', ' ', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', ' ', 'r', 'e', 'c', 'o', 'r', 'd']))

def lengthIntervalsSpecTokens_block_0_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_0_4 lengthIntervalsSpecTokens_block_4_8
    "with Silver_Path_Facts;\n\npackage Silver_Length_Intervals with SPARK_Mode => On is\n   package Paths renames Silver_Path_Facts;\n\n   --  Both endpoints retain their contributions when an operand has no value.\n   --  In particular, an empty Image must not erase the other String operands.\n   type Summary is record"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'P', 'a', 't', 'h', 's', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';']
      ['\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'B', 'o', 't', 'h', ' ', 'e', 'n', 'd', 'p', 'o', 'i', 'n', 't', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', 's', ' ', 'w', 'h', 'e', 'n', ' ', 'a', 'n', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', ' ', 'h', 'a', 's', ' ', 'n', 'o', ' ', 'v', 'a', 'l', 'u', 'e', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'I', 'n', ' ', 'p', 'a', 'r', 't', 'i', 'c', 'u', 'l', 'a', 'r', ',', ' ', 'a', 'n', ' ', 'e', 'm', 'p', 't', 'y', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'm', 'u', 's', 't', ' ', 'n', 'o', 't', ' ', 'e', 'r', 'a', 's', 'e', ' ', 't', 'h', 'e', ' ', 'o', 't', 'h', 'e', 'r', ' ', 'S', 't', 'r', 'i', 'n', 'g', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', 's', '.', '\n', ' ', ' ', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', ' ', 'r', 'e', 'c', 'o', 'r', 'd']))

def lengthIntervalsSpecTokens_block_8_9 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_8

def lengthIntervalsSpecTokens_block_9_10 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_9

def lengthIntervalsSpecTokens_block_8_10 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_8_9 lengthIntervalsSpecTokens_block_9_10
    "      Minimum_Length, Static_Length : Paths.Length_Value;\n      Dynamic_Count : Paths.Operand_Count;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', '_', 'V', 'a', 'l', 'u', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'O', 'p', 'e', 'r', 'a', 'n', 'd', '_', 'C', 'o', 'u', 'n', 't', ';']))

def lengthIntervalsSpecTokens_block_10_11 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_10

def lengthIntervalsSpecTokens_block_11_12 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_11

def lengthIntervalsSpecTokens_block_10_12 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_10_11 lengthIntervalsSpecTokens_block_11_12
    "      Empty_Value : Boolean := False;\n   end record;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'r', 'e', 'c', 'o', 'r', 'd', ';']))

def lengthIntervalsSpecTokens_block_8_12 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_8_10 lengthIntervalsSpecTokens_block_10_12
    "      Minimum_Length, Static_Length : Paths.Length_Value;\n      Dynamic_Count : Paths.Operand_Count;\n      Empty_Value : Boolean := False;\n   end record;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', '_', 'V', 'a', 'l', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'O', 'p', 'e', 'r', 'a', 'n', 'd', '_', 'C', 'o', 'u', 'n', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'r', 'e', 'c', 'o', 'r', 'd', ';']))

def lengthIntervalsSpecTokens_block_12_13 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_12

def lengthIntervalsSpecTokens_block_13_14 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_13

def lengthIntervalsSpecTokens_block_12_14 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_12_13 lengthIntervalsSpecTokens_block_13_14
    "   Empty_Summary : constant Summary := (0, 0, 0, True);\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', '=', ' ', '(', '0', ',', ' ', '0', ',', ' ', '0', ',', ' ', 'T', 'r', 'u', 'e', ')', ';']
      []))

def lengthIntervalsSpecTokens_block_14_15 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_14

def lengthIntervalsSpecTokens_block_15_16 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_15

def lengthIntervalsSpecTokens_block_14_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_14_15 lengthIntervalsSpecTokens_block_15_16
    "   function Is_Empty (Value : Summary) return Boolean is (Value.Empty_Value);\n   function Lower (Value : Summary) return Paths.Summary is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ')', ';']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's']))

def lengthIntervalsSpecTokens_block_12_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_12_14 lengthIntervalsSpecTokens_block_14_16
    "   Empty_Summary : constant Summary := (0, 0, 0, True);\n\n   function Is_Empty (Value : Summary) return Boolean is (Value.Empty_Value);\n   function Lower (Value : Summary) return Paths.Summary is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', '=', ' ', '(', '0', ',', ' ', '0', ',', ' ', '0', ',', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's']))

def lengthIntervalsSpecTokens_block_8_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_8_12 lengthIntervalsSpecTokens_block_12_16
    "      Minimum_Length, Static_Length : Paths.Length_Value;\n      Dynamic_Count : Paths.Operand_Count;\n      Empty_Value : Boolean := False;\n   end record;\n   Empty_Summary : constant Summary := (0, 0, 0, True);\n\n   function Is_Empty (Value : Summary) return Boolean is (Value.Empty_Value);\n   function Lower (Value : Summary) return Paths.Summary is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', '_', 'V', 'a', 'l', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'O', 'p', 'e', 'r', 'a', 'n', 'd', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'r', 'e', 'c', 'o', 'r', 'd', ';']
      [' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', '=', ' ', '(', '0', ',', ' ', '0', ',', ' ', '0', ',', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's']))

def lengthIntervalsSpecTokens_block_0_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_0_8 lengthIntervalsSpecTokens_block_8_16
    "with Silver_Path_Facts;\n\npackage Silver_Length_Intervals with SPARK_Mode => On is\n   package Paths renames Silver_Path_Facts;\n\n   --  Both endpoints retain their contributions when an operand has no value.\n   --  In particular, an empty Image must not erase the other String operands.\n   type Summary is record\n      Minimum_Length, Static_Length : Paths.Length_Value;\n      Dynamic_Count : Paths.Operand_Count;\n      Empty_Value : Boolean := False;\n   end record;\n   Empty_Summary : constant Summary := (0, 0, 0, True);\n\n   function Is_Empty (Value : Summary) return Boolean is (Value.Empty_Value);\n   function Lower (Value : Summary) return Paths.Summary is"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'P', 'a', 't', 'h', 's', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'B', 'o', 't', 'h', ' ', 'e', 'n', 'd', 'p', 'o', 'i', 'n', 't', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', 's', ' ', 'w', 'h', 'e', 'n', ' ', 'a', 'n', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', ' ', 'h', 'a', 's', ' ', 'n', 'o', ' ', 'v', 'a', 'l', 'u', 'e', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'I', 'n', ' ', 'p', 'a', 'r', 't', 'i', 'c', 'u', 'l', 'a', 'r', ',', ' ', 'a', 'n', ' ', 'e', 'm', 'p', 't', 'y', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'm', 'u', 's', 't', ' ', 'n', 'o', 't', ' ', 'e', 'r', 'a', 's', 'e', ' ', 't', 'h', 'e', ' ', 'o', 't', 'h', 'e', 'r', ' ', 'S', 't', 'r', 'i', 'n', 'g', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', 's', '.', '\n', ' ', ' ', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', ' ', 'r', 'e', 'c', 'o', 'r', 'd']
      [' ', ' ', ' ', ' ', ' ', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', '_', 'V', 'a', 'l', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'O', 'p', 'e', 'r', 'a', 'n', 'd', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'r', 'e', 'c', 'o', 'r', 'd', ';', '\n', ' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', '=', ' ', '(', '0', ',', ' ', '0', ',', ' ', '0', ',', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's']))

def lengthIntervalsSpecTokens_block_16_17 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_16

def lengthIntervalsSpecTokens_block_17_18 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_17

def lengthIntervalsSpecTokens_block_16_18 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_16_17 lengthIntervalsSpecTokens_block_17_18
    "     (Value.Minimum_Length, Value.Dynamic_Count);\n   function Upper (Value : Summary) return Paths.Summary is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's']))

def lengthIntervalsSpecTokens_block_18_19 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_18

def lengthIntervalsSpecTokens_block_19_20 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_19

def lengthIntervalsSpecTokens_block_18_20 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_18_19 lengthIntervalsSpecTokens_block_19_20
    "     (Value.Static_Length, Value.Dynamic_Count);\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';']
      []))

def lengthIntervalsSpecTokens_block_16_20 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_16_18 lengthIntervalsSpecTokens_block_18_20
    "     (Value.Minimum_Length, Value.Dynamic_Count);\n   function Upper (Value : Summary) return Paths.Summary is\n     (Value.Static_Length, Value.Dynamic_Count);\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n']))

def lengthIntervalsSpecTokens_block_20_21 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_20

def lengthIntervalsSpecTokens_block_21_22 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_21

def lengthIntervalsSpecTokens_block_20_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_20_21 lengthIntervalsSpecTokens_block_21_22
    "   function Fits (Facts : Paths.Context; Value : Summary) return Boolean\n     with Global => null;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';']))

def lengthIntervalsSpecTokens_block_22_23 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_22

def lengthIntervalsSpecTokens_block_23_24 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_23

def lengthIntervalsSpecTokens_block_22_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_22_23 lengthIntervalsSpecTokens_block_23_24
    "\n   --  Assignment is directional: Right is the target. Empty values waive"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'A', 's', 's', 'i', 'g', 'n', 'm', 'e', 'n', 't', ' ', 'i', 's', ' ', 'd', 'i', 'r', 'e', 'c', 't', 'i', 'o', 'n', 'a', 'l', ':', ' ', 'R', 'i', 'g', 'h', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', ' ', 'E', 'm', 'p', 't', 'y', ' ', 'v', 'a', 'l', 'u', 'e', 's', ' ', 'w', 'a', 'i', 'v', 'e']))

def lengthIntervalsSpecTokens_block_20_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_20_22 lengthIntervalsSpecTokens_block_22_24
    "   function Fits (Facts : Paths.Context; Value : Summary) return Boolean\n     with Global => null;\n\n   --  Assignment is directional: Right is the target. Empty values waive"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';']
      ['\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'A', 's', 's', 'i', 'g', 'n', 'm', 'e', 'n', 't', ' ', 'i', 's', ' ', 'd', 'i', 'r', 'e', 'c', 't', 'i', 'o', 'n', 'a', 'l', ':', ' ', 'R', 'i', 'g', 'h', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', ' ', 'E', 'm', 'p', 't', 'y', ' ', 'v', 'a', 'l', 'u', 'e', 's', ' ', 'w', 'a', 'i', 'v', 'e']))

def lengthIntervalsSpecTokens_block_16_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_16_20 lengthIntervalsSpecTokens_block_20_24
    "     (Value.Minimum_Length, Value.Dynamic_Count);\n   function Upper (Value : Summary) return Paths.Summary is\n     (Value.Static_Length, Value.Dynamic_Count);\n\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean\n     with Global => null;\n\n   --  Assignment is directional: Right is the target. Empty values waive"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'A', 's', 's', 'i', 'g', 'n', 'm', 'e', 'n', 't', ' ', 'i', 's', ' ', 'd', 'i', 'r', 'e', 'c', 't', 'i', 'o', 'n', 'a', 'l', ':', ' ', 'R', 'i', 'g', 'h', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', ' ', 'E', 'm', 'p', 't', 'y', ' ', 'v', 'a', 'l', 'u', 'e', 's', ' ', 'w', 'a', 'i', 'v', 'e']))

def lengthIntervalsSpecTokens_block_24_25 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_24

def lengthIntervalsSpecTokens_block_25_26 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_25

def lengthIntervalsSpecTokens_block_24_26 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_24_25 lengthIntervalsSpecTokens_block_25_26
    "   --  runtime equality, but their retained contribution must fit a fixed target.\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'r', 'u', 'n', 't', 'i', 'm', 'e', ' ', 'e', 'q', 'u', 'a', 'l', 'i', 't', 'y', ',', ' ', 'b', 'u', 't', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', ' ', 'm', 'u', 's', 't', ' ', 'f', 'i', 't', ' ', 'a', ' ', 'f', 'i', 'x', 'e', 'd', ' ', 't', 'a', 'r', 'g', 'e', 't', '.']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n']))

def lengthIntervalsSpecTokens_block_26_27 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_26

def lengthIntervalsSpecTokens_block_27_28 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_27

def lengthIntervalsSpecTokens_block_26_28 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_26_27 lengthIntervalsSpecTokens_block_27_28
    "     with Global => null;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';']
      []))

def lengthIntervalsSpecTokens_block_24_28 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_24_26 lengthIntervalsSpecTokens_block_26_28
    "   --  runtime equality, but their retained contribution must fit a fixed target.\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean\n     with Global => null;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'r', 'u', 'n', 't', 'i', 'm', 'e', ' ', 'e', 'q', 'u', 'a', 'l', 'i', 't', 'y', ',', ' ', 'b', 'u', 't', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', ' ', 'm', 'u', 's', 't', ' ', 'f', 'i', 't', ' ', 'a', ' ', 'f', 'i', 'x', 'e', 'd', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n']))

def lengthIntervalsSpecTokens_block_28_29 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_28

def lengthIntervalsSpecTokens_block_29_30 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_29

def lengthIntervalsSpecTokens_block_28_30 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_28_29 lengthIntervalsSpecTokens_block_29_30
    "   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't']))

def lengthIntervalsSpecTokens_block_30_31 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_30

def lengthIntervalsSpecTokens_block_31_32 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_31

def lengthIntervalsSpecTokens_block_32_33 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsSpecTokens_line_32

def lengthIntervalsSpecTokens_block_31_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_31_32 lengthIntervalsSpecTokens_block_32_33
    "end Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';']
      []))

def lengthIntervalsSpecTokens_block_30_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_30_31 lengthIntervalsSpecTokens_block_31_33
    "     with Global => null;\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';']
      ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsSpecTokens_block_28_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_28_30 lengthIntervalsSpecTokens_block_30_33
    "   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context\n     with Global => null;\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsSpecTokens_block_24_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_24_28 lengthIntervalsSpecTokens_block_28_33
    "   --  runtime equality, but their retained contribution must fit a fixed target.\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean\n     with Global => null;\n\n   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context\n     with Global => null;\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'r', 'u', 'n', 't', 'i', 'm', 'e', ' ', 'e', 'q', 'u', 'a', 'l', 'i', 't', 'y', ',', ' ', 'b', 'u', 't', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', ' ', 'm', 'u', 's', 't', ' ', 'f', 'i', 't', ' ', 'a', ' ', 'f', 'i', 'x', 'e', 'd', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsSpecTokens_block_16_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_16_24 lengthIntervalsSpecTokens_block_24_33
    "     (Value.Minimum_Length, Value.Dynamic_Count);\n   function Upper (Value : Summary) return Paths.Summary is\n     (Value.Static_Length, Value.Dynamic_Count);\n\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean\n     with Global => null;\n\n   --  Assignment is directional: Right is the target. Empty values waive\n   --  runtime equality, but their retained contribution must fit a fixed target.\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean\n     with Global => null;\n\n   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context\n     with Global => null;\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'A', 's', 's', 'i', 'g', 'n', 'm', 'e', 'n', 't', ' ', 'i', 's', ' ', 'd', 'i', 'r', 'e', 'c', 't', 'i', 'o', 'n', 'a', 'l', ':', ' ', 'R', 'i', 'g', 'h', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', ' ', 'E', 'm', 'p', 't', 'y', ' ', 'v', 'a', 'l', 'u', 'e', 's', ' ', 'w', 'a', 'i', 'v', 'e']
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'r', 'u', 'n', 't', 'i', 'm', 'e', ' ', 'e', 'q', 'u', 'a', 'l', 'i', 't', 'y', ',', ' ', 'b', 'u', 't', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', ' ', 'm', 'u', 's', 't', ' ', 'f', 'i', 't', ' ', 'a', ' ', 'f', 'i', 'x', 'e', 'd', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsSpecTokens_block_0_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsSpecTokens_block_0_16 lengthIntervalsSpecTokens_block_16_33
    "with Silver_Path_Facts;\n\npackage Silver_Length_Intervals with SPARK_Mode => On is\n   package Paths renames Silver_Path_Facts;\n\n   --  Both endpoints retain their contributions when an operand has no value.\n   --  In particular, an empty Image must not erase the other String operands.\n   type Summary is record\n      Minimum_Length, Static_Length : Paths.Length_Value;\n      Dynamic_Count : Paths.Operand_Count;\n      Empty_Value : Boolean := False;\n   end record;\n   Empty_Summary : constant Summary := (0, 0, 0, True);\n\n   function Is_Empty (Value : Summary) return Boolean is (Value.Empty_Value);\n   function Lower (Value : Summary) return Paths.Summary is\n     (Value.Minimum_Length, Value.Dynamic_Count);\n   function Upper (Value : Summary) return Paths.Summary is\n     (Value.Static_Length, Value.Dynamic_Count);\n\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean\n     with Global => null;\n\n   --  Assignment is directional: Right is the target. Empty values waive\n   --  runtime equality, but their retained contribution must fit a fixed target.\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean\n     with Global => null;\n\n   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context\n     with Global => null;\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'P', 'a', 't', 'h', 's', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'a', 't', 'h', '_', 'F', 'a', 'c', 't', 's', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'B', 'o', 't', 'h', ' ', 'e', 'n', 'd', 'p', 'o', 'i', 'n', 't', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', 's', ' ', 'w', 'h', 'e', 'n', ' ', 'a', 'n', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', ' ', 'h', 'a', 's', ' ', 'n', 'o', ' ', 'v', 'a', 'l', 'u', 'e', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'I', 'n', ' ', 'p', 'a', 'r', 't', 'i', 'c', 'u', 'l', 'a', 'r', ',', ' ', 'a', 'n', ' ', 'e', 'm', 'p', 't', 'y', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'm', 'u', 's', 't', ' ', 'n', 'o', 't', ' ', 'e', 'r', 'a', 's', 'e', ' ', 't', 'h', 'e', ' ', 'o', 't', 'h', 'e', 'r', ' ', 'S', 't', 'r', 'i', 'n', 'g', ' ', 'o', 'p', 'e', 'r', 'a', 'n', 'd', 's', '.', '\n', ' ', ' ', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', ' ', 'r', 'e', 'c', 'o', 'r', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', '_', 'V', 'a', 'l', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'O', 'p', 'e', 'r', 'a', 'n', 'd', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'r', 'e', 'c', 'o', 'r', 'd', ';', '\n', ' ', ' ', ' ', 'E', 'm', 'p', 't', 'y', '_', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', ':', '=', ' ', '(', '0', ',', ' ', '0', ',', ' ', '0', ',', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'E', 'm', 'p', 't', 'y', '_', 'V', 'a', 'l', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ',', ' ', 'V', 'a', 'l', 'u', 'e', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'A', 's', 's', 'i', 'g', 'n', 'm', 'e', 'n', 't', ' ', 'i', 's', ' ', 'd', 'i', 'r', 'e', 'c', 't', 'i', 'o', 'n', 'a', 'l', ':', ' ', 'R', 'i', 'g', 'h', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', ' ', 'E', 'm', 'p', 't', 'y', ' ', 'v', 'a', 'l', 'u', 'e', 's', ' ', 'w', 'a', 'i', 'v', 'e', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'r', 'u', 'n', 't', 'i', 'm', 'e', ' ', 'e', 'q', 'u', 'a', 'l', 'i', 't', 'y', ',', ' ', 'b', 'u', 't', ' ', 't', 'h', 'e', 'i', 'r', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'c', 'o', 'n', 't', 'r', 'i', 'b', 'u', 't', 'i', 'o', 'n', ' ', 'm', 'u', 's', 't', ' ', 'f', 'i', 't', ' ', 'a', ' ', 'f', 'i', 'x', 'e', 'd', ' ', 't', 'a', 'r', 'g', 'e', 't', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsSpecTokens_certificates : List LineCertificate :=
  lengthIntervalsSpecTokens_block_0_33.lines

def lengthIntervalsSpecTokens : Tokens :=
  ["with", "silver_path_facts", ";", "package", "silver_length_intervals", "with", "spark_mode", "=>", "on", "is", "package", "paths", "renames", "silver_path_facts", ";", "type", "summary", "is", "record", "minimum_length", ",", "static_length", ":", "paths", ".", "length_value", ";", "dynamic_count", ":", "paths", ".", "operand_count", ";", "empty_value", ":", "boolean", ":=", "false", ";", "end", "record", ";", "empty_summary", ":", "constant", "summary", ":=", "(", "0", ",", "0", ",", "0", ",", "true", ")", ";", "function", "is_empty", "(", "value", ":", "summary", ")", "return", "boolean", "is", "(", "value", ".", "empty_value", ")", ";", "function", "lower", "(", "value", ":", "summary", ")", "return", "paths", ".", "summary", "is", "(", "value", ".", "minimum_length", ",", "value", ".", "dynamic_count", ")", ";", "function", "upper", "(", "value", ":", "summary", ")", "return", "paths", ".", "summary", "is", "(", "value", ".", "static_length", ",", "value", ".", "dynamic_count", ")", ";", "function", "fits", "(", "facts", ":", "paths", ".", "context", ";", "value", ":", "summary", ")", "return", "boolean", "with", "global", "=>", "null", ";", "function", "same_length", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "boolean", "with", "global", "=>", "null", ";", "function", "refine_equal", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "paths", ".", "context", "with", "global", "=>", "null", ";", "end", "silver_length_intervals", ";"]

theorem lengthIntervalsSpecTokens_source :
    String.intercalate "\n" (lengthIntervalsSpecTokens_certificates.map (·.text)) = lengthIntervalsSpec := by
  exact lengthIntervalsSpecTokens_block_0_33.correct

theorem lengthIntervalsSpecTokens_values :
    lengthIntervalsSpecTokens_certificates.flatMap (·.tokens) = lengthIntervalsSpecTokens := by rfl

theorem lengthIntervalsSpecTokens_correct : lex lengthIntervalsSpec = some lengthIntervalsSpecTokens := by
  rw [← lengthIntervalsSpecTokens_source, reconstructed_source_lex lengthIntervalsSpecTokens_certificates
    lengthIntervalsSpecTokens_block_0_33.nonempty]
  rw [lengthIntervalsSpecTokens_values]

def lengthIntervalsBodyTokens_line_0 : LineCertificate where
  text := "package body Silver_Length_Intervals with SPARK_Mode => On is"
  tokens := ["package", "body", "silver_length_intervals", "with", "spark_mode", "=>", "on", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_1 : LineCertificate where
  text := "   function Fits (Facts : Paths.Context; Value : Summary) return Boolean is"
  tokens := ["function", "fits", "(", "facts", ":", "paths", ".", "context", ";", "value", ":", "summary", ")", "return", "boolean", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_2 : LineCertificate where
  text := "     (Value.Static_Length <= Paths.Max_Length"
  tokens := ["(", "value", ".", "static_length", "<=", "paths", ".", "max_length"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_3 : LineCertificate where
  text := "      and then (Is_Empty (Value) or else Paths.Fits (Facts, Upper (Value))));"
  tokens := ["and", "then", "(", "is_empty", "(", "value", ")", "or", "else", "paths", ".", "fits", "(", "facts", ",", "upper", "(", "value", ")", ")", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_4 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_5 : LineCertificate where
  text := "   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean is"
  tokens := ["function", "same_length", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "boolean", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_6 : LineCertificate where
  text := "     (if Is_Empty (Left) or else Is_Empty (Right) then"
  tokens := ["(", "if", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_7 : LineCertificate where
  text := "        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length"
  tokens := ["right", ".", "dynamic_count", "/=", "0", "or", "else", "left", ".", "minimum_length", "<=", "right", ".", "static_length"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_8 : LineCertificate where
  text := "      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))"
  tokens := ["else", "paths", ".", "same_length", "(", "facts", ",", "lower", "(", "left", ")", ",", "upper", "(", "right", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_9 : LineCertificate where
  text := "        and then Paths.Same_Length (Facts, Upper (Left), Lower (Right)));"
  tokens := ["and", "then", "paths", ".", "same_length", "(", "facts", ",", "upper", "(", "left", ")", ",", "lower", "(", "right", ")", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_10 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_11 : LineCertificate where
  text := "   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)"
  tokens := ["function", "equal_increasing", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_12 : LineCertificate where
  text := "      return Paths.Context"
  tokens := ["return", "paths", ".", "context"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_13 : LineCertificate where
  text := "     with Global => null,"
  tokens := ["with", "global", "=>", "null", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_14 : LineCertificate where
  text := "       Pre => Left.Dynamic_Count > Right.Dynamic_Count;"
  tokens := ["pre", "=>", "left", ".", "dynamic_count", ">", "right", ".", "dynamic_count", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_15 : LineCertificate where
  text := "   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)"
  tokens := ["function", "equal_increasing", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_16 : LineCertificate where
  text := "      return Paths.Context is"
  tokens := ["return", "paths", ".", "context", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_17 : LineCertificate where
  text := "     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else"
  tokens := ["(", "if", "right", ".", "static_length", "<", "left", ".", "minimum_length", "then", "paths", ".", "empty_context", "else"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_18 : LineCertificate where
  text := "        (declare"
  tokens := ["(", "declare"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_19 : LineCertificate where
  text := "            Difference : constant Positive := Left.Dynamic_Count - Right.Dynamic_Count;"
  tokens := ["difference", ":", "constant", "positive", ":=", "left", ".", "dynamic_count", "-", "right", ".", "dynamic_count", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_20 : LineCertificate where
  text := "            Numerator : constant Natural :="
  tokens := ["numerator", ":", "constant", "natural", ":="]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_21 : LineCertificate where
  text := "              (if Right.Minimum_Length > Left.Static_Length"
  tokens := ["(", "if", "right", ".", "minimum_length", ">", "left", ".", "static_length"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_22 : LineCertificate where
  text := "               then Right.Minimum_Length - Left.Static_Length else 0);"
  tokens := ["then", "right", ".", "minimum_length", "-", "left", ".", "static_length", "else", "0", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_23 : LineCertificate where
  text := "            Low : constant Natural := ((Numerator + Difference) - 1) / Difference;"
  tokens := ["low", ":", "constant", "natural", ":=", "(", "(", "numerator", "+", "difference", ")", "-", "1", ")", "/", "difference", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_24 : LineCertificate where
  text := "            High : constant Natural := (Right.Static_Length - Left.Minimum_Length) / Difference;"
  tokens := ["high", ":", "constant", "natural", ":=", "(", "right", ".", "static_length", "-", "left", ".", "minimum_length", ")", "/", "difference", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_25 : LineCertificate where
  text := "         begin Paths.Intersect (Facts, Low, High)));"
  tokens := ["begin", "paths", ".", "intersect", "(", "facts", ",", "low", ",", "high", ")", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_26 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_27 : LineCertificate where
  text := "   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)"
  tokens := ["function", "refine_equal", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_28 : LineCertificate where
  text := "      return Paths.Context is"
  tokens := ["return", "paths", ".", "context", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_29 : LineCertificate where
  text := "     (if Is_Empty (Left) or else Is_Empty (Right) then Paths.Empty_Context"
  tokens := ["(", "if", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "paths", ".", "empty_context"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_30 : LineCertificate where
  text := "      elsif Left.Dynamic_Count = Right.Dynamic_Count then"
  tokens := ["elsif", "left", ".", "dynamic_count", "=", "right", ".", "dynamic_count", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_31 : LineCertificate where
  text := "        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length"
  tokens := ["paths", ".", "keep_if", "(", "facts", ",", "left", ".", "minimum_length", "<=", "right", ".", "static_length"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_32 : LineCertificate where
  text := "          and then Right.Minimum_Length <= Left.Static_Length)"
  tokens := ["and", "then", "right", ".", "minimum_length", "<=", "left", ".", "static_length", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_33 : LineCertificate where
  text := "      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)"
  tokens := ["elsif", "left", ".", "dynamic_count", ">", "right", ".", "dynamic_count", "then", "equal_increasing", "(", "facts", ",", "left", ",", "right", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_34 : LineCertificate where
  text := "      else Equal_Increasing (Facts, Right, Left));"
  tokens := ["else", "equal_increasing", "(", "facts", ",", "right", ",", "left", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_35 : LineCertificate where
  text := "end Silver_Length_Intervals;"
  tokens := ["end", "silver_length_intervals", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_line_36 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def lengthIntervalsBodyTokens_block_0_1 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_0

def lengthIntervalsBodyTokens_block_1_2 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_1

def lengthIntervalsBodyTokens_block_0_2 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_0_1 lengthIntervalsBodyTokens_block_1_2
    "package body Silver_Length_Intervals with SPARK_Mode => On is\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean is"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's']))

def lengthIntervalsBodyTokens_block_2_3 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_2

def lengthIntervalsBodyTokens_block_3_4 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_3

def lengthIntervalsBodyTokens_block_2_4 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_2_3 lengthIntervalsBodyTokens_block_3_4
    "     (Value.Static_Length <= Paths.Max_Length\n      and then (Is_Empty (Value) or else Paths.Fits (Facts, Upper (Value))));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'P', 'a', 't', 'h', 's', '.', 'M', 'a', 'x', '_', 'L', 'e', 'n', 'g', 't', 'h']
      [' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ')', ')', ')', ';']))

def lengthIntervalsBodyTokens_block_0_4 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_0_2 lengthIntervalsBodyTokens_block_2_4
    "package body Silver_Length_Intervals with SPARK_Mode => On is\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean is\n     (Value.Static_Length <= Paths.Max_Length\n      and then (Is_Empty (Value) or else Paths.Fits (Facts, Upper (Value))));"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'P', 'a', 't', 'h', 's', '.', 'M', 'a', 'x', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ')', ')', ')', ';']))

def lengthIntervalsBodyTokens_block_4_5 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_4

def lengthIntervalsBodyTokens_block_5_6 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_5

def lengthIntervalsBodyTokens_block_4_6 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_4_5 lengthIntervalsBodyTokens_block_5_6
    "\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean is"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's']))

def lengthIntervalsBodyTokens_block_6_7 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_6

def lengthIntervalsBodyTokens_block_7_8 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_7

def lengthIntervalsBodyTokens_block_8_9 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_8

def lengthIntervalsBodyTokens_block_7_9 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_7_8 lengthIntervalsBodyTokens_block_8_9
    "        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length\n      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '/', '=', ' ', '0', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')']))

def lengthIntervalsBodyTokens_block_6_9 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_6_7 lengthIntervalsBodyTokens_block_7_9
    "     (if Is_Empty (Left) or else Is_Empty (Right) then\n        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length\n      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '/', '=', ' ', '0', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')']))

def lengthIntervalsBodyTokens_block_4_9 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_4_6 lengthIntervalsBodyTokens_block_6_9
    "\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean is\n     (if Is_Empty (Left) or else Is_Empty (Right) then\n        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length\n      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '/', '=', ' ', '0', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')']))

def lengthIntervalsBodyTokens_block_0_9 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_0_4 lengthIntervalsBodyTokens_block_4_9
    "package body Silver_Length_Intervals with SPARK_Mode => On is\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean is\n     (Value.Static_Length <= Paths.Max_Length\n      and then (Is_Empty (Value) or else Paths.Fits (Facts, Upper (Value))));\n\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean is\n     (if Is_Empty (Left) or else Is_Empty (Right) then\n        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length\n      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'P', 'a', 't', 'h', 's', '.', 'M', 'a', 'x', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ')', ')', ')', ';']
      ['\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '/', '=', ' ', '0', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')']))

def lengthIntervalsBodyTokens_block_9_10 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_9

def lengthIntervalsBodyTokens_block_10_11 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_10

def lengthIntervalsBodyTokens_block_9_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_9_10 lengthIntervalsBodyTokens_block_10_11
    "        and then Paths.Same_Length (Facts, Upper (Left), Lower (Right)));\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')', ')', ';']
      []))

def lengthIntervalsBodyTokens_block_11_12 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_11

def lengthIntervalsBodyTokens_block_12_13 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_12

def lengthIntervalsBodyTokens_block_11_13 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_11_12 lengthIntervalsBodyTokens_block_12_13
    "   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't']))

def lengthIntervalsBodyTokens_block_9_13 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_9_11 lengthIntervalsBodyTokens_block_11_13
    "        and then Paths.Same_Length (Facts, Upper (Left), Lower (Right)));\n\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')', ')', ';', '\n']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't']))

def lengthIntervalsBodyTokens_block_13_14 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_13

def lengthIntervalsBodyTokens_block_14_15 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_14

def lengthIntervalsBodyTokens_block_13_15 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_13_14 lengthIntervalsBodyTokens_block_14_15
    "     with Global => null,\n       Pre => Left.Dynamic_Count > Right.Dynamic_Count;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';']))

def lengthIntervalsBodyTokens_block_15_16 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_15

def lengthIntervalsBodyTokens_block_16_17 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_16

def lengthIntervalsBodyTokens_block_17_18 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_17

def lengthIntervalsBodyTokens_block_16_18 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_16_17 lengthIntervalsBodyTokens_block_17_18
    "      return Paths.Context is\n     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'e', 'l', 's', 'e']))

def lengthIntervalsBodyTokens_block_15_18 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_15_16 lengthIntervalsBodyTokens_block_16_18
    "   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'e', 'l', 's', 'e']))

def lengthIntervalsBodyTokens_block_13_18 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_13_15 lengthIntervalsBodyTokens_block_15_18
    "     with Global => null,\n       Pre => Left.Dynamic_Count > Right.Dynamic_Count;\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'e', 'l', 's', 'e']))

def lengthIntervalsBodyTokens_block_9_18 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_9_13 lengthIntervalsBodyTokens_block_13_18
    "        and then Paths.Same_Length (Facts, Upper (Left), Lower (Right)));\n\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context\n     with Global => null,\n       Pre => Left.Dynamic_Count > Right.Dynamic_Count;\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'e', 'l', 's', 'e']))

def lengthIntervalsBodyTokens_block_0_18 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_0_9 lengthIntervalsBodyTokens_block_9_18
    "package body Silver_Length_Intervals with SPARK_Mode => On is\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean is\n     (Value.Static_Length <= Paths.Max_Length\n      and then (Is_Empty (Value) or else Paths.Fits (Facts, Upper (Value))));\n\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean is\n     (if Is_Empty (Left) or else Is_Empty (Right) then\n        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length\n      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))\n        and then Paths.Same_Length (Facts, Upper (Left), Lower (Right)));\n\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context\n     with Global => null,\n       Pre => Left.Dynamic_Count > Right.Dynamic_Count;\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'P', 'a', 't', 'h', 's', '.', 'M', 'a', 'x', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '/', '=', ' ', '0', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'e', 'l', 's', 'e']))

def lengthIntervalsBodyTokens_block_18_19 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_18

def lengthIntervalsBodyTokens_block_19_20 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_19

def lengthIntervalsBodyTokens_block_18_20 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_18_19 lengthIntervalsBodyTokens_block_19_20
    "        (declare\n            Difference : constant Positive := Left.Dynamic_Count - Right.Dynamic_Count;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'd', 'e', 'c', 'l', 'a', 'r', 'e']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e', ' ', ':', '=', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '-', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';']))

def lengthIntervalsBodyTokens_block_20_21 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_20

def lengthIntervalsBodyTokens_block_21_22 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_21

def lengthIntervalsBodyTokens_block_20_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_20_21 lengthIntervalsBodyTokens_block_21_22
    "            Numerator : constant Natural :=\n              (if Right.Minimum_Length > Left.Static_Length"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '>', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']))

def lengthIntervalsBodyTokens_block_18_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_18_20 lengthIntervalsBodyTokens_block_20_22
    "        (declare\n            Difference : constant Positive := Left.Dynamic_Count - Right.Dynamic_Count;\n            Numerator : constant Natural :=\n              (if Right.Minimum_Length > Left.Static_Length"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'd', 'e', 'c', 'l', 'a', 'r', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e', ' ', ':', '=', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '-', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '>', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']))

def lengthIntervalsBodyTokens_block_22_23 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_22

def lengthIntervalsBodyTokens_block_23_24 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_23

def lengthIntervalsBodyTokens_block_22_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_22_23 lengthIntervalsBodyTokens_block_23_24
    "               then Right.Minimum_Length - Left.Static_Length else 0);\n            Low : constant Natural := ((Numerator + Difference) - 1) / Difference;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'L', 'o', 'w', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', '(', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', '+', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ')', ' ', '-', ' ', '1', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';']))

def lengthIntervalsBodyTokens_block_24_25 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_24

def lengthIntervalsBodyTokens_block_25_26 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_25

def lengthIntervalsBodyTokens_block_26_27 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_26

def lengthIntervalsBodyTokens_block_25_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_25_26 lengthIntervalsBodyTokens_block_26_27
    "         begin Paths.Intersect (Facts, Low, High)));\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'I', 'n', 't', 'e', 'r', 's', 'e', 'c', 't', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', ',', ' ', 'H', 'i', 'g', 'h', ')', ')', ')', ';']
      []))

def lengthIntervalsBodyTokens_block_24_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_24_25 lengthIntervalsBodyTokens_block_25_27
    "            High : constant Natural := (Right.Static_Length - Left.Minimum_Length) / Difference;\n         begin Paths.Intersect (Facts, Low, High)));\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'H', 'i', 'g', 'h', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'I', 'n', 't', 'e', 'r', 's', 'e', 'c', 't', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', ',', ' ', 'H', 'i', 'g', 'h', ')', ')', ')', ';', '\n']))

def lengthIntervalsBodyTokens_block_22_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_22_24 lengthIntervalsBodyTokens_block_24_27
    "               then Right.Minimum_Length - Left.Static_Length else 0);\n            Low : constant Natural := ((Numerator + Difference) - 1) / Difference;\n            High : constant Natural := (Right.Static_Length - Left.Minimum_Length) / Difference;\n         begin Paths.Intersect (Facts, Low, High)));\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'L', 'o', 'w', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', '(', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', '+', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ')', ' ', '-', ' ', '1', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'H', 'i', 'g', 'h', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'I', 'n', 't', 'e', 'r', 's', 'e', 'c', 't', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', ',', ' ', 'H', 'i', 'g', 'h', ')', ')', ')', ';', '\n']))

def lengthIntervalsBodyTokens_block_18_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_18_22 lengthIntervalsBodyTokens_block_22_27
    "        (declare\n            Difference : constant Positive := Left.Dynamic_Count - Right.Dynamic_Count;\n            Numerator : constant Natural :=\n              (if Right.Minimum_Length > Left.Static_Length\n               then Right.Minimum_Length - Left.Static_Length else 0);\n            Low : constant Natural := ((Numerator + Difference) - 1) / Difference;\n            High : constant Natural := (Right.Static_Length - Left.Minimum_Length) / Difference;\n         begin Paths.Intersect (Facts, Low, High)));\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'd', 'e', 'c', 'l', 'a', 'r', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e', ' ', ':', '=', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '-', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '>', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'L', 'o', 'w', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', '(', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', '+', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ')', ' ', '-', ' ', '1', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'H', 'i', 'g', 'h', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'I', 'n', 't', 'e', 'r', 's', 'e', 'c', 't', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', ',', ' ', 'H', 'i', 'g', 'h', ')', ')', ')', ';', '\n']))

def lengthIntervalsBodyTokens_block_27_28 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_27

def lengthIntervalsBodyTokens_block_28_29 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_28

def lengthIntervalsBodyTokens_block_27_29 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_27_28 lengthIntervalsBodyTokens_block_28_29
    "   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's']))

def lengthIntervalsBodyTokens_block_29_30 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_29

def lengthIntervalsBodyTokens_block_30_31 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_30

def lengthIntervalsBodyTokens_block_31_32 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_31

def lengthIntervalsBodyTokens_block_30_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_30_31 lengthIntervalsBodyTokens_block_31_32
    "      elsif Left.Dynamic_Count = Right.Dynamic_Count then\n        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'a', 't', 'h', 's', '.', 'K', 'e', 'e', 'p', '_', 'I', 'f', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']))

def lengthIntervalsBodyTokens_block_29_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_29_30 lengthIntervalsBodyTokens_block_30_32
    "     (if Is_Empty (Left) or else Is_Empty (Right) then Paths.Empty_Context\n      elsif Left.Dynamic_Count = Right.Dynamic_Count then\n        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'a', 't', 'h', 's', '.', 'K', 'e', 'e', 'p', '_', 'I', 'f', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']))

def lengthIntervalsBodyTokens_block_27_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_27_29 lengthIntervalsBodyTokens_block_29_32
    "   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Is_Empty (Left) or else Is_Empty (Right) then Paths.Empty_Context\n      elsif Left.Dynamic_Count = Right.Dynamic_Count then\n        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'a', 't', 'h', 's', '.', 'K', 'e', 'e', 'p', '_', 'I', 'f', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']))

def lengthIntervalsBodyTokens_block_32_33 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_32

def lengthIntervalsBodyTokens_block_33_34 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_33

def lengthIntervalsBodyTokens_block_32_34 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_32_33 lengthIntervalsBodyTokens_block_33_34
    "          and then Right.Minimum_Length <= Left.Static_Length)\n      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ')']))

def lengthIntervalsBodyTokens_block_34_35 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_34

def lengthIntervalsBodyTokens_block_35_36 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_35

def lengthIntervalsBodyTokens_block_36_37 : ReconstructionCertificate :=
  ReconstructionCertificate.single lengthIntervalsBodyTokens_line_36

def lengthIntervalsBodyTokens_block_35_37 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_35_36 lengthIntervalsBodyTokens_block_36_37
    "end Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';']
      []))

def lengthIntervalsBodyTokens_block_34_37 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_34_35 lengthIntervalsBodyTokens_block_35_37
    "      else Equal_Increasing (Facts, Right, Left));\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'R', 'i', 'g', 'h', 't', ',', ' ', 'L', 'e', 'f', 't', ')', ')', ';']
      ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsBodyTokens_block_32_37 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_32_34 lengthIntervalsBodyTokens_block_34_37
    "          and then Right.Minimum_Length <= Left.Static_Length)\n      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)\n      else Equal_Increasing (Facts, Right, Left));\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'R', 'i', 'g', 'h', 't', ',', ' ', 'L', 'e', 'f', 't', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsBodyTokens_block_27_37 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_27_32 lengthIntervalsBodyTokens_block_32_37
    "   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Is_Empty (Left) or else Is_Empty (Right) then Paths.Empty_Context\n      elsif Left.Dynamic_Count = Right.Dynamic_Count then\n        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length\n          and then Right.Minimum_Length <= Left.Static_Length)\n      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)\n      else Equal_Increasing (Facts, Right, Left));\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'a', 't', 'h', 's', '.', 'K', 'e', 'e', 'p', '_', 'I', 'f', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'R', 'i', 'g', 'h', 't', ',', ' ', 'L', 'e', 'f', 't', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsBodyTokens_block_18_37 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_18_27 lengthIntervalsBodyTokens_block_27_37
    "        (declare\n            Difference : constant Positive := Left.Dynamic_Count - Right.Dynamic_Count;\n            Numerator : constant Natural :=\n              (if Right.Minimum_Length > Left.Static_Length\n               then Right.Minimum_Length - Left.Static_Length else 0);\n            Low : constant Natural := ((Numerator + Difference) - 1) / Difference;\n            High : constant Natural := (Right.Static_Length - Left.Minimum_Length) / Difference;\n         begin Paths.Intersect (Facts, Low, High)));\n\n   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Is_Empty (Left) or else Is_Empty (Right) then Paths.Empty_Context\n      elsif Left.Dynamic_Count = Right.Dynamic_Count then\n        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length\n          and then Right.Minimum_Length <= Left.Static_Length)\n      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)\n      else Equal_Increasing (Facts, Right, Left));\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'd', 'e', 'c', 'l', 'a', 'r', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e', ' ', ':', '=', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '-', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '>', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'L', 'o', 'w', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', '(', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', '+', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ')', ' ', '-', ' ', '1', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'H', 'i', 'g', 'h', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'I', 'n', 't', 'e', 'r', 's', 'e', 'c', 't', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', ',', ' ', 'H', 'i', 'g', 'h', ')', ')', ')', ';', '\n']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'a', 't', 'h', 's', '.', 'K', 'e', 'e', 'p', '_', 'I', 'f', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'R', 'i', 'g', 'h', 't', ',', ' ', 'L', 'e', 'f', 't', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsBodyTokens_block_0_37 : ReconstructionCertificate :=
  ReconstructionCertificate.join lengthIntervalsBodyTokens_block_0_18 lengthIntervalsBodyTokens_block_18_37
    "package body Silver_Length_Intervals with SPARK_Mode => On is\n   function Fits (Facts : Paths.Context; Value : Summary) return Boolean is\n     (Value.Static_Length <= Paths.Max_Length\n      and then (Is_Empty (Value) or else Paths.Fits (Facts, Upper (Value))));\n\n   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean is\n     (if Is_Empty (Left) or else Is_Empty (Right) then\n        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length\n      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))\n        and then Paths.Same_Length (Facts, Upper (Left), Lower (Right)));\n\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context\n     with Global => null,\n       Pre => Left.Dynamic_Count > Right.Dynamic_Count;\n   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else\n        (declare\n            Difference : constant Positive := Left.Dynamic_Count - Right.Dynamic_Count;\n            Numerator : constant Natural :=\n              (if Right.Minimum_Length > Left.Static_Length\n               then Right.Minimum_Length - Left.Static_Length else 0);\n            Low : constant Natural := ((Numerator + Difference) - 1) / Difference;\n            High : constant Natural := (Right.Static_Length - Left.Minimum_Length) / Difference;\n         begin Paths.Intersect (Facts, Low, High)));\n\n   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)\n      return Paths.Context is\n     (if Is_Empty (Left) or else Is_Empty (Right) then Paths.Empty_Context\n      elsif Left.Dynamic_Count = Right.Dynamic_Count then\n        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length\n          and then Right.Minimum_Length <= Left.Static_Length)\n      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)\n      else Equal_Increasing (Facts, Right, Left));\nend Silver_Length_Intervals;\n"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'V', 'a', 'l', 'u', 'e', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'V', 'a', 'l', 'u', 'e', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'P', 'a', 't', 'h', 's', '.', 'M', 'a', 'x', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'F', 'i', 't', 's', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'V', 'a', 'l', 'u', 'e', ')', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '/', '=', ' ', '0', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'S', 'a', 'm', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'U', 'p', 'p', 'e', 'r', ' ', '(', 'L', 'e', 'f', 't', ')', ',', ' ', 'L', 'o', 'w', 'e', 'r', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', 'n', 'u', 'l', 'l', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'e', 'l', 's', 'e']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'd', 'e', 'c', 'l', 'a', 'r', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'P', 'o', 's', 'i', 't', 'i', 'v', 'e', ' ', ':', '=', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '-', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '>', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'L', 'o', 'w', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', '(', 'N', 'u', 'm', 'e', 'r', 'a', 't', 'o', 'r', ' ', '+', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ')', ' ', '-', ' ', '1', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'H', 'i', 'g', 'h', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', ':', '=', ' ', '(', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '-', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', ' ', '/', ' ', 'D', 'i', 'f', 'f', 'e', 'r', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'I', 'n', 't', 'e', 'r', 's', 'e', 'c', 't', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'o', 'w', ',', ' ', 'H', 'i', 'g', 'h', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '_', 'E', 'q', 'u', 'a', 'l', ' ', '(', 'F', 'a', 'c', 't', 's', ' ', ':', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ';', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ' ', ':', ' ', 'S', 'u', 'm', 'm', 'a', 'r', 'y', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'C', 'o', 'n', 't', 'e', 'x', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'L', 'e', 'f', 't', ')', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'R', 'i', 'g', 'h', 't', ')', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'a', 't', 'h', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'C', 'o', 'n', 't', 'e', 'x', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'a', 't', 'h', 's', '.', 'K', 'e', 'e', 'p', '_', 'I', 'f', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'R', 'i', 'g', 'h', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'i', 'g', 'h', 't', '.', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '<', '=', ' ', 'L', 'e', 'f', 't', '.', 'S', 't', 'a', 't', 'i', 'c', '_', 'L', 'e', 'n', 'g', 't', 'h', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'L', 'e', 'f', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'R', 'i', 'g', 'h', 't', '.', 'D', 'y', 'n', 'a', 'm', 'i', 'c', '_', 'C', 'o', 'u', 'n', 't', ' ', 't', 'h', 'e', 'n', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'L', 'e', 'f', 't', ',', ' ', 'R', 'i', 'g', 'h', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'E', 'q', 'u', 'a', 'l', '_', 'I', 'n', 'c', 'r', 'e', 'a', 's', 'i', 'n', 'g', ' ', '(', 'F', 'a', 'c', 't', 's', ',', ' ', 'R', 'i', 'g', 'h', 't', ',', ' ', 'L', 'e', 'f', 't', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'e', 'n', 'g', 't', 'h', '_', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', 's', ';', '\n']))

def lengthIntervalsBodyTokens_certificates : List LineCertificate :=
  lengthIntervalsBodyTokens_block_0_37.lines

def lengthIntervalsBodyTokens : Tokens :=
  ["package", "body", "silver_length_intervals", "with", "spark_mode", "=>", "on", "is", "function", "fits", "(", "facts", ":", "paths", ".", "context", ";", "value", ":", "summary", ")", "return", "boolean", "is", "(", "value", ".", "static_length", "<=", "paths", ".", "max_length", "and", "then", "(", "is_empty", "(", "value", ")", "or", "else", "paths", ".", "fits", "(", "facts", ",", "upper", "(", "value", ")", ")", ")", ")", ";", "function", "same_length", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "boolean", "is", "(", "if", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "right", ".", "dynamic_count", "/=", "0", "or", "else", "left", ".", "minimum_length", "<=", "right", ".", "static_length", "else", "paths", ".", "same_length", "(", "facts", ",", "lower", "(", "left", ")", ",", "upper", "(", "right", ")", ")", "and", "then", "paths", ".", "same_length", "(", "facts", ",", "upper", "(", "left", ")", ",", "lower", "(", "right", ")", ")", ")", ";", "function", "equal_increasing", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "paths", ".", "context", "with", "global", "=>", "null", ",", "pre", "=>", "left", ".", "dynamic_count", ">", "right", ".", "dynamic_count", ";", "function", "equal_increasing", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "paths", ".", "context", "is", "(", "if", "right", ".", "static_length", "<", "left", ".", "minimum_length", "then", "paths", ".", "empty_context", "else", "(", "declare", "difference", ":", "constant", "positive", ":=", "left", ".", "dynamic_count", "-", "right", ".", "dynamic_count", ";", "numerator", ":", "constant", "natural", ":=", "(", "if", "right", ".", "minimum_length", ">", "left", ".", "static_length", "then", "right", ".", "minimum_length", "-", "left", ".", "static_length", "else", "0", ")", ";", "low", ":", "constant", "natural", ":=", "(", "(", "numerator", "+", "difference", ")", "-", "1", ")", "/", "difference", ";", "high", ":", "constant", "natural", ":=", "(", "right", ".", "static_length", "-", "left", ".", "minimum_length", ")", "/", "difference", ";", "begin", "paths", ".", "intersect", "(", "facts", ",", "low", ",", "high", ")", ")", ")", ";", "function", "refine_equal", "(", "facts", ":", "paths", ".", "context", ";", "left", ",", "right", ":", "summary", ")", "return", "paths", ".", "context", "is", "(", "if", "is_empty", "(", "left", ")", "or", "else", "is_empty", "(", "right", ")", "then", "paths", ".", "empty_context", "elsif", "left", ".", "dynamic_count", "=", "right", ".", "dynamic_count", "then", "paths", ".", "keep_if", "(", "facts", ",", "left", ".", "minimum_length", "<=", "right", ".", "static_length", "and", "then", "right", ".", "minimum_length", "<=", "left", ".", "static_length", ")", "elsif", "left", ".", "dynamic_count", ">", "right", ".", "dynamic_count", "then", "equal_increasing", "(", "facts", ",", "left", ",", "right", ")", "else", "equal_increasing", "(", "facts", ",", "right", ",", "left", ")", ")", ";", "end", "silver_length_intervals", ";"]

theorem lengthIntervalsBodyTokens_source :
    String.intercalate "\n" (lengthIntervalsBodyTokens_certificates.map (·.text)) = lengthIntervalsBody := by
  exact lengthIntervalsBodyTokens_block_0_37.correct

theorem lengthIntervalsBodyTokens_values :
    lengthIntervalsBodyTokens_certificates.flatMap (·.tokens) = lengthIntervalsBodyTokens := by rfl

theorem lengthIntervalsBodyTokens_correct : lex lengthIntervalsBody = some lengthIntervalsBodyTokens := by
  rw [← lengthIntervalsBodyTokens_source, reconstructed_source_lex lengthIntervalsBodyTokens_certificates
    lengthIntervalsBodyTokens_block_0_37.nonempty]
  rw [lengthIntervalsBodyTokens_values]

end Silver.Source
