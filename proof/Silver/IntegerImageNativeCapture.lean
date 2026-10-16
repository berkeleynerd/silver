module

public import Silver.SourceLexer
public import Silver.IntegerImageSpecSource
public meta import Silver.CertificateWitness

@[expose] public section

/-! Kernel-checked physical-line certificates and balanced reconstruction of
`silver_integer_image.ads`, generated with `generate_source_certificate.generate`.
The captured source includes every original byte and the final newline. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Source

def integerImageSpecTokens_line_0 : LineCertificate where
  text := "with Silver_Scalars;"
  tokens := ["with", "silver_scalars", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_1 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_2 : LineCertificate where
  text := "package Silver_Integer_Image with SPARK_Mode => On is"
  tokens := ["package", "silver_integer_image", "with", "spark_mode", "=>", "on", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_3 : LineCertificate where
  text := "   subtype Image_Length is Natural range 2 .. 11;"
  tokens := ["subtype", "image_length", "is", "natural", "range", "2", "..", "11", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_4 : LineCertificate where
  text := "   subtype Possible_Length is Natural range 0 .. 11;"
  tokens := ["subtype", "possible_length", "is", "natural", "range", "0", "..", "11", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_5 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_6 : LineCertificate where
  text := "   --  Signed threshold tests avoid negating Integer'First. Ada's Image adds"
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_7 : LineCertificate where
  text := "   --  one sign or leading-space byte to the decimal magnitude."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_8 : LineCertificate where
  text := "   function Length_Of (Item : Silver_Scalars.Value) return Image_Length is"
  tokens := ["function", "length_of", "(", "item", ":", "silver_scalars", ".", "value", ")", "return", "image_length", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_9 : LineCertificate where
  text := "     (if Item > -10 and then Item < 10 then 2"
  tokens := ["(", "if", "item", ">", "-", "10", "and", "then", "item", "<", "10", "then", "2"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_10 : LineCertificate where
  text := "      elsif Item > -100 and then Item < 100 then 3"
  tokens := ["elsif", "item", ">", "-", "100", "and", "then", "item", "<", "100", "then", "3"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_11 : LineCertificate where
  text := "      elsif Item > -1_000 and then Item < 1_000 then 4"
  tokens := ["elsif", "item", ">", "-", "1_000", "and", "then", "item", "<", "1_000", "then", "4"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_12 : LineCertificate where
  text := "      elsif Item > -10_000 and then Item < 10_000 then 5"
  tokens := ["elsif", "item", ">", "-", "10_000", "and", "then", "item", "<", "10_000", "then", "5"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_13 : LineCertificate where
  text := "      elsif Item > -100_000 and then Item < 100_000 then 6"
  tokens := ["elsif", "item", ">", "-", "100_000", "and", "then", "item", "<", "100_000", "then", "6"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_14 : LineCertificate where
  text := "      elsif Item > -1_000_000 and then Item < 1_000_000 then 7"
  tokens := ["elsif", "item", ">", "-", "1_000_000", "and", "then", "item", "<", "1_000_000", "then", "7"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_15 : LineCertificate where
  text := "      elsif Item > -10_000_000 and then Item < 10_000_000 then 8"
  tokens := ["elsif", "item", ">", "-", "10_000_000", "and", "then", "item", "<", "10_000_000", "then", "8"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_16 : LineCertificate where
  text := "      elsif Item > -100_000_000 and then Item < 100_000_000 then 9"
  tokens := ["elsif", "item", ">", "-", "100_000_000", "and", "then", "item", "<", "100_000_000", "then", "9"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_17 : LineCertificate where
  text := "      elsif Item > -1_000_000_000 and then Item < 1_000_000_000 then 10"
  tokens := ["elsif", "item", ">", "-", "1_000_000_000", "and", "then", "item", "<", "1_000_000_000", "then", "10"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_18 : LineCertificate where
  text := "      else 11);"
  tokens := ["else", "11", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_19 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_20 : LineCertificate where
  text := "   function Minimum_Length (Bounds : Silver_Scalars.Interval)"
  tokens := ["function", "minimum_length", "(", "bounds", ":", "silver_scalars", ".", "interval", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_21 : LineCertificate where
  text := "      return Possible_Length is"
  tokens := ["return", "possible_length", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_22 : LineCertificate where
  text := "     (if Silver_Scalars.Is_Empty (Bounds) then 0"
  tokens := ["(", "if", "silver_scalars", ".", "is_empty", "(", "bounds", ")", "then", "0"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_23 : LineCertificate where
  text := "      elsif Bounds.Lower <= 0 and then Bounds.Upper >= 0 then 2"
  tokens := ["elsif", "bounds", ".", "lower", "<=", "0", "and", "then", "bounds", ".", "upper", ">=", "0", "then", "2"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_24 : LineCertificate where
  text := "      else Image_Length'Min (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));"
  tokens := ["else", "image_length", "'", "min", "(", "length_of", "(", "bounds", ".", "lower", ")", ",", "length_of", "(", "bounds", ".", "upper", ")", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_25 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_26 : LineCertificate where
  text := "   function Maximum_Length (Bounds : Silver_Scalars.Interval)"
  tokens := ["function", "maximum_length", "(", "bounds", ":", "silver_scalars", ".", "interval", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_27 : LineCertificate where
  text := "      return Possible_Length is"
  tokens := ["return", "possible_length", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_28 : LineCertificate where
  text := "     (if Silver_Scalars.Is_Empty (Bounds) then 0"
  tokens := ["(", "if", "silver_scalars", ".", "is_empty", "(", "bounds", ")", "then", "0"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_29 : LineCertificate where
  text := "      else Image_Length'Max (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));"
  tokens := ["else", "image_length", "'", "max", "(", "length_of", "(", "bounds", ".", "lower", ")", ",", "length_of", "(", "bounds", ".", "upper", ")", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_30 : LineCertificate where
  text := "end Silver_Integer_Image;"
  tokens := ["end", "silver_integer_image", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_line_31 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def integerImageSpecTokens_block_0_1 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_0

def integerImageSpecTokens_block_1_2 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_1

def integerImageSpecTokens_block_0_2 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_0_1 integerImageSpecTokens_block_1_2
    "with Silver_Scalars;\n"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', ';']
      []))

def integerImageSpecTokens_block_2_3 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_2

def integerImageSpecTokens_block_3_4 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_3

def integerImageSpecTokens_block_2_4 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_2_3 integerImageSpecTokens_block_3_4
    "package Silver_Integer_Image with SPARK_Mode => On is\n   subtype Image_Length is Natural range 2 .. 11;"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '2', ' ', '.', '.', ' ', '1', '1', ';']))

def integerImageSpecTokens_block_0_4 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_0_2 integerImageSpecTokens_block_2_4
    "with Silver_Scalars;\n\npackage Silver_Integer_Image with SPARK_Mode => On is\n   subtype Image_Length is Natural range 2 .. 11;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', ';', '\n']
      ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '2', ' ', '.', '.', ' ', '1', '1', ';']))

def integerImageSpecTokens_block_4_5 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_4

def integerImageSpecTokens_block_5_6 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_5

def integerImageSpecTokens_block_4_6 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_4_5 integerImageSpecTokens_block_5_6
    "   subtype Possible_Length is Natural range 0 .. 11;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '0', ' ', '.', '.', ' ', '1', '1', ';']
      []))

def integerImageSpecTokens_block_6_7 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_6

def integerImageSpecTokens_block_7_8 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_7

def integerImageSpecTokens_block_6_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_6_7 integerImageSpecTokens_block_7_8
    "   --  Signed threshold tests avoid negating Integer'First. Ada's Image adds\n   --  one sign or leading-space byte to the decimal magnitude."
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'S', 'i', 'g', 'n', 'e', 'd', ' ', 't', 'h', 'r', 'e', 's', 'h', 'o', 'l', 'd', ' ', 't', 'e', 's', 't', 's', ' ', 'a', 'v', 'o', 'i', 'd', ' ', 'n', 'e', 'g', 'a', 't', 'i', 'n', 'g', ' ', 'I', 'n', 't', 'e', 'g', 'e', 'r', '\'', 'F', 'i', 'r', 's', 't', '.', ' ', 'A', 'd', 'a', '\'', 's', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'a', 'd', 'd', 's']
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'o', 'n', 'e', ' ', 's', 'i', 'g', 'n', ' ', 'o', 'r', ' ', 'l', 'e', 'a', 'd', 'i', 'n', 'g', '-', 's', 'p', 'a', 'c', 'e', ' ', 'b', 'y', 't', 'e', ' ', 't', 'o', ' ', 't', 'h', 'e', ' ', 'd', 'e', 'c', 'i', 'm', 'a', 'l', ' ', 'm', 'a', 'g', 'n', 'i', 't', 'u', 'd', 'e', '.']))

def integerImageSpecTokens_block_4_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_4_6 integerImageSpecTokens_block_6_8
    "   subtype Possible_Length is Natural range 0 .. 11;\n\n   --  Signed threshold tests avoid negating Integer'First. Ada's Image adds\n   --  one sign or leading-space byte to the decimal magnitude."
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '0', ' ', '.', '.', ' ', '1', '1', ';', '\n']
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'S', 'i', 'g', 'n', 'e', 'd', ' ', 't', 'h', 'r', 'e', 's', 'h', 'o', 'l', 'd', ' ', 't', 'e', 's', 't', 's', ' ', 'a', 'v', 'o', 'i', 'd', ' ', 'n', 'e', 'g', 'a', 't', 'i', 'n', 'g', ' ', 'I', 'n', 't', 'e', 'g', 'e', 'r', '\'', 'F', 'i', 'r', 's', 't', '.', ' ', 'A', 'd', 'a', '\'', 's', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'a', 'd', 'd', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'o', 'n', 'e', ' ', 's', 'i', 'g', 'n', ' ', 'o', 'r', ' ', 'l', 'e', 'a', 'd', 'i', 'n', 'g', '-', 's', 'p', 'a', 'c', 'e', ' ', 'b', 'y', 't', 'e', ' ', 't', 'o', ' ', 't', 'h', 'e', ' ', 'd', 'e', 'c', 'i', 'm', 'a', 'l', ' ', 'm', 'a', 'g', 'n', 'i', 't', 'u', 'd', 'e', '.']))

def integerImageSpecTokens_block_0_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_0_4 integerImageSpecTokens_block_4_8
    "with Silver_Scalars;\n\npackage Silver_Integer_Image with SPARK_Mode => On is\n   subtype Image_Length is Natural range 2 .. 11;\n   subtype Possible_Length is Natural range 0 .. 11;\n\n   --  Signed threshold tests avoid negating Integer'First. Ada's Image adds\n   --  one sign or leading-space byte to the decimal magnitude."
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '2', ' ', '.', '.', ' ', '1', '1', ';']
      [' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '0', ' ', '.', '.', ' ', '1', '1', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'S', 'i', 'g', 'n', 'e', 'd', ' ', 't', 'h', 'r', 'e', 's', 'h', 'o', 'l', 'd', ' ', 't', 'e', 's', 't', 's', ' ', 'a', 'v', 'o', 'i', 'd', ' ', 'n', 'e', 'g', 'a', 't', 'i', 'n', 'g', ' ', 'I', 'n', 't', 'e', 'g', 'e', 'r', '\'', 'F', 'i', 'r', 's', 't', '.', ' ', 'A', 'd', 'a', '\'', 's', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'a', 'd', 'd', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'o', 'n', 'e', ' ', 's', 'i', 'g', 'n', ' ', 'o', 'r', ' ', 'l', 'e', 'a', 'd', 'i', 'n', 'g', '-', 's', 'p', 'a', 'c', 'e', ' ', 'b', 'y', 't', 'e', ' ', 't', 'o', ' ', 't', 'h', 'e', ' ', 'd', 'e', 'c', 'i', 'm', 'a', 'l', ' ', 'm', 'a', 'g', 'n', 'i', 't', 'u', 'd', 'e', '.']))

def integerImageSpecTokens_block_8_9 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_8

def integerImageSpecTokens_block_9_10 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_9

def integerImageSpecTokens_block_8_10 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_8_9 integerImageSpecTokens_block_9_10
    "   function Length_Of (Item : Silver_Scalars.Value) return Image_Length is\n     (if Item > -10 and then Item < 10 then 2"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'I', 't', 'e', 'm', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', ' ', 't', 'h', 'e', 'n', ' ', '2']))

def integerImageSpecTokens_block_10_11 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_10

def integerImageSpecTokens_block_11_12 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_11

def integerImageSpecTokens_block_10_12 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_10_11 integerImageSpecTokens_block_11_12
    "      elsif Item > -100 and then Item < 100 then 3\n      elsif Item > -1_000 and then Item < 1_000 then 4"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '3']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '4']))

def integerImageSpecTokens_block_8_12 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_8_10 integerImageSpecTokens_block_10_12
    "   function Length_Of (Item : Silver_Scalars.Value) return Image_Length is\n     (if Item > -10 and then Item < 10 then 2\n      elsif Item > -100 and then Item < 100 then 3\n      elsif Item > -1_000 and then Item < 1_000 then 4"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'I', 't', 'e', 'm', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', ' ', 't', 'h', 'e', 'n', ' ', '2']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '3', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '4']))

def integerImageSpecTokens_block_12_13 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_12

def integerImageSpecTokens_block_13_14 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_13

def integerImageSpecTokens_block_12_14 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_12_13 integerImageSpecTokens_block_13_14
    "      elsif Item > -10_000 and then Item < 10_000 then 5\n      elsif Item > -100_000 and then Item < 100_000 then 6"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '5']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '6']))

def integerImageSpecTokens_block_14_15 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_14

def integerImageSpecTokens_block_15_16 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_15

def integerImageSpecTokens_block_14_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_14_15 integerImageSpecTokens_block_15_16
    "      elsif Item > -1_000_000 and then Item < 1_000_000 then 7\n      elsif Item > -10_000_000 and then Item < 10_000_000 then 8"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '7']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '8']))

def integerImageSpecTokens_block_12_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_12_14 integerImageSpecTokens_block_14_16
    "      elsif Item > -10_000 and then Item < 10_000 then 5\n      elsif Item > -100_000 and then Item < 100_000 then 6\n      elsif Item > -1_000_000 and then Item < 1_000_000 then 7\n      elsif Item > -10_000_000 and then Item < 10_000_000 then 8"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '5', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '6']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '7', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '8']))

def integerImageSpecTokens_block_8_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_8_12 integerImageSpecTokens_block_12_16
    "   function Length_Of (Item : Silver_Scalars.Value) return Image_Length is\n     (if Item > -10 and then Item < 10 then 2\n      elsif Item > -100 and then Item < 100 then 3\n      elsif Item > -1_000 and then Item < 1_000 then 4\n      elsif Item > -10_000 and then Item < 10_000 then 5\n      elsif Item > -100_000 and then Item < 100_000 then 6\n      elsif Item > -1_000_000 and then Item < 1_000_000 then 7\n      elsif Item > -10_000_000 and then Item < 10_000_000 then 8"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'I', 't', 'e', 'm', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', ' ', 't', 'h', 'e', 'n', ' ', '2', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '3', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '4']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '5', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '6', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '7', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '8']))

def integerImageSpecTokens_block_0_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_0_8 integerImageSpecTokens_block_8_16
    "with Silver_Scalars;\n\npackage Silver_Integer_Image with SPARK_Mode => On is\n   subtype Image_Length is Natural range 2 .. 11;\n   subtype Possible_Length is Natural range 0 .. 11;\n\n   --  Signed threshold tests avoid negating Integer'First. Ada's Image adds\n   --  one sign or leading-space byte to the decimal magnitude.\n   function Length_Of (Item : Silver_Scalars.Value) return Image_Length is\n     (if Item > -10 and then Item < 10 then 2\n      elsif Item > -100 and then Item < 100 then 3\n      elsif Item > -1_000 and then Item < 1_000 then 4\n      elsif Item > -10_000 and then Item < 10_000 then 5\n      elsif Item > -100_000 and then Item < 100_000 then 6\n      elsif Item > -1_000_000 and then Item < 1_000_000 then 7\n      elsif Item > -10_000_000 and then Item < 10_000_000 then 8"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '2', ' ', '.', '.', ' ', '1', '1', ';', '\n', ' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '0', ' ', '.', '.', ' ', '1', '1', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'S', 'i', 'g', 'n', 'e', 'd', ' ', 't', 'h', 'r', 'e', 's', 'h', 'o', 'l', 'd', ' ', 't', 'e', 's', 't', 's', ' ', 'a', 'v', 'o', 'i', 'd', ' ', 'n', 'e', 'g', 'a', 't', 'i', 'n', 'g', ' ', 'I', 'n', 't', 'e', 'g', 'e', 'r', '\'', 'F', 'i', 'r', 's', 't', '.', ' ', 'A', 'd', 'a', '\'', 's', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'a', 'd', 'd', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'o', 'n', 'e', ' ', 's', 'i', 'g', 'n', ' ', 'o', 'r', ' ', 'l', 'e', 'a', 'd', 'i', 'n', 'g', '-', 's', 'p', 'a', 'c', 'e', ' ', 'b', 'y', 't', 'e', ' ', 't', 'o', ' ', 't', 'h', 'e', ' ', 'd', 'e', 'c', 'i', 'm', 'a', 'l', ' ', 'm', 'a', 'g', 'n', 'i', 't', 'u', 'd', 'e', '.']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'I', 't', 'e', 'm', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', ' ', 't', 'h', 'e', 'n', ' ', '2', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '3', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '4', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '5', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '6', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '7', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '8']))

def integerImageSpecTokens_block_16_17 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_16

def integerImageSpecTokens_block_17_18 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_17

def integerImageSpecTokens_block_16_18 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_16_17 integerImageSpecTokens_block_17_18
    "      elsif Item > -100_000_000 and then Item < 100_000_000 then 9\n      elsif Item > -1_000_000_000 and then Item < 1_000_000_000 then 10"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '9']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '1', '0']))

def integerImageSpecTokens_block_18_19 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_18

def integerImageSpecTokens_block_19_20 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_19

def integerImageSpecTokens_block_18_20 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_18_19 integerImageSpecTokens_block_19_20
    "      else 11);\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', '1', '1', ')', ';']
      []))

def integerImageSpecTokens_block_16_20 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_16_18 integerImageSpecTokens_block_18_20
    "      elsif Item > -100_000_000 and then Item < 100_000_000 then 9\n      elsif Item > -1_000_000_000 and then Item < 1_000_000_000 then 10\n      else 11);\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '9', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '1', '0']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', '1', '1', ')', ';', '\n']))

def integerImageSpecTokens_block_20_21 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_20

def integerImageSpecTokens_block_21_22 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_21

def integerImageSpecTokens_block_20_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_20_21 integerImageSpecTokens_block_21_22
    "   function Minimum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's']))

def integerImageSpecTokens_block_22_23 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_22

def integerImageSpecTokens_block_23_24 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_23

def integerImageSpecTokens_block_22_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_22_23 integerImageSpecTokens_block_23_24
    "     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      elsif Bounds.Lower <= 0 and then Bounds.Upper >= 0 then 2"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ' ', '<', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ' ', '>', '=', ' ', '0', ' ', 't', 'h', 'e', 'n', ' ', '2']))

def integerImageSpecTokens_block_20_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_20_22 integerImageSpecTokens_block_22_24
    "   function Minimum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is\n     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      elsif Bounds.Lower <= 0 and then Bounds.Upper >= 0 then 2"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ' ', '<', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ' ', '>', '=', ' ', '0', ' ', 't', 'h', 'e', 'n', ' ', '2']))

def integerImageSpecTokens_block_16_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_16_20 integerImageSpecTokens_block_20_24
    "      elsif Item > -100_000_000 and then Item < 100_000_000 then 9\n      elsif Item > -1_000_000_000 and then Item < 1_000_000_000 then 10\n      else 11);\n\n   function Minimum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is\n     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      elsif Bounds.Lower <= 0 and then Bounds.Upper >= 0 then 2"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '9', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '1', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', '1', '1', ')', ';', '\n']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ' ', '<', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ' ', '>', '=', ' ', '0', ' ', 't', 'h', 'e', 'n', ' ', '2']))

def integerImageSpecTokens_block_24_25 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_24

def integerImageSpecTokens_block_25_26 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_25

def integerImageSpecTokens_block_24_26 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_24_25 integerImageSpecTokens_block_25_26
    "      else Image_Length'Min (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'i', 'n', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';']
      []))

def integerImageSpecTokens_block_26_27 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_26

def integerImageSpecTokens_block_27_28 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_27

def integerImageSpecTokens_block_26_28 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_26_27 integerImageSpecTokens_block_27_28
    "   function Maximum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'a', 'x', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's']))

def integerImageSpecTokens_block_24_28 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_24_26 integerImageSpecTokens_block_26_28
    "      else Image_Length'Min (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\n\n   function Maximum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'i', 'n', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';', '\n']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'a', 'x', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's']))

def integerImageSpecTokens_block_28_29 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_28

def integerImageSpecTokens_block_29_30 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_29

def integerImageSpecTokens_block_28_30 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_28_29 integerImageSpecTokens_block_29_30
    "     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      else Image_Length'Max (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'a', 'x', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';']))

def integerImageSpecTokens_block_30_31 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_30

def integerImageSpecTokens_block_31_32 : ReconstructionCertificate :=
  ReconstructionCertificate.single integerImageSpecTokens_line_31

def integerImageSpecTokens_block_30_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_30_31 integerImageSpecTokens_block_31_32
    "end Silver_Integer_Image;\n"
    (by kernel_exact (string_join_ofList ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ';']
      []))

def integerImageSpecTokens_block_28_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_28_30 integerImageSpecTokens_block_30_32
    "     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      else Image_Length'Max (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\nend Silver_Integer_Image;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'a', 'x', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';']
      ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ';', '\n']))

def integerImageSpecTokens_block_24_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_24_28 integerImageSpecTokens_block_28_32
    "      else Image_Length'Min (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\n\n   function Maximum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is\n     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      else Image_Length'Max (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\nend Silver_Integer_Image;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'i', 'n', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'a', 'x', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'a', 'x', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ';', '\n']))

def integerImageSpecTokens_block_16_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_16_24 integerImageSpecTokens_block_24_32
    "      elsif Item > -100_000_000 and then Item < 100_000_000 then 9\n      elsif Item > -1_000_000_000 and then Item < 1_000_000_000 then 10\n      else 11);\n\n   function Minimum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is\n     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      elsif Bounds.Lower <= 0 and then Bounds.Upper >= 0 then 2\n      else Image_Length'Min (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\n\n   function Maximum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is\n     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      else Image_Length'Max (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\nend Silver_Integer_Image;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '9', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '1', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', '1', '1', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ' ', '<', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ' ', '>', '=', ' ', '0', ' ', 't', 'h', 'e', 'n', ' ', '2']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'i', 'n', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'a', 'x', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'a', 'x', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ';', '\n']))

def integerImageSpecTokens_block_0_32 : ReconstructionCertificate :=
  ReconstructionCertificate.join integerImageSpecTokens_block_0_16 integerImageSpecTokens_block_16_32
    "with Silver_Scalars;\n\npackage Silver_Integer_Image with SPARK_Mode => On is\n   subtype Image_Length is Natural range 2 .. 11;\n   subtype Possible_Length is Natural range 0 .. 11;\n\n   --  Signed threshold tests avoid negating Integer'First. Ada's Image adds\n   --  one sign or leading-space byte to the decimal magnitude.\n   function Length_Of (Item : Silver_Scalars.Value) return Image_Length is\n     (if Item > -10 and then Item < 10 then 2\n      elsif Item > -100 and then Item < 100 then 3\n      elsif Item > -1_000 and then Item < 1_000 then 4\n      elsif Item > -10_000 and then Item < 10_000 then 5\n      elsif Item > -100_000 and then Item < 100_000 then 6\n      elsif Item > -1_000_000 and then Item < 1_000_000 then 7\n      elsif Item > -10_000_000 and then Item < 10_000_000 then 8\n      elsif Item > -100_000_000 and then Item < 100_000_000 then 9\n      elsif Item > -1_000_000_000 and then Item < 1_000_000_000 then 10\n      else 11);\n\n   function Minimum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is\n     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      elsif Bounds.Lower <= 0 and then Bounds.Upper >= 0 then 2\n      else Image_Length'Min (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\n\n   function Maximum_Length (Bounds : Silver_Scalars.Interval)\n      return Possible_Length is\n     (if Silver_Scalars.Is_Empty (Bounds) then 0\n      else Image_Length'Max (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));\nend Silver_Integer_Image;\n"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '2', ' ', '.', '.', ' ', '1', '1', ';', '\n', ' ', ' ', ' ', 's', 'u', 'b', 't', 'y', 'p', 'e', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', ' ', 'N', 'a', 't', 'u', 'r', 'a', 'l', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '0', ' ', '.', '.', ' ', '1', '1', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'S', 'i', 'g', 'n', 'e', 'd', ' ', 't', 'h', 'r', 'e', 's', 'h', 'o', 'l', 'd', ' ', 't', 'e', 's', 't', 's', ' ', 'a', 'v', 'o', 'i', 'd', ' ', 'n', 'e', 'g', 'a', 't', 'i', 'n', 'g', ' ', 'I', 'n', 't', 'e', 'g', 'e', 'r', '\'', 'F', 'i', 'r', 's', 't', '.', ' ', 'A', 'd', 'a', '\'', 's', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'a', 'd', 'd', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'o', 'n', 'e', ' ', 's', 'i', 'g', 'n', ' ', 'o', 'r', ' ', 'l', 'e', 'a', 'd', 'i', 'n', 'g', '-', 's', 'p', 'a', 'c', 'e', ' ', 'b', 'y', 't', 'e', ' ', 't', 'o', ' ', 't', 'h', 'e', ' ', 'd', 'e', 'c', 'i', 'm', 'a', 'l', ' ', 'm', 'a', 'g', 'n', 'i', 't', 'u', 'd', 'e', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'I', 't', 'e', 'm', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'V', 'a', 'l', 'u', 'e', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', ' ', 't', 'h', 'e', 'n', ' ', '2', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '3', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '4', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '5', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '6', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '7', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '8']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '9', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '>', ' ', '-', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 't', 'e', 'm', ' ', '<', ' ', '1', '_', '0', '0', '0', '_', '0', '0', '0', '_', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '1', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', '1', '1', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'i', 'n', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ' ', '<', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ' ', '>', '=', ' ', '0', ' ', 't', 'h', 'e', 'n', ' ', '2', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'i', 'n', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'M', 'a', 'x', 'i', 'm', 'u', 'm', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ' ', ':', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 'n', 't', 'e', 'r', 'v', 'a', 'l', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'P', 'o', 's', 's', 'i', 'b', 'l', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'i', 'f', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'S', 'c', 'a', 'l', 'a', 'r', 's', '.', 'I', 's', '_', 'E', 'm', 'p', 't', 'y', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', ')', ' ', 't', 'h', 'e', 'n', ' ', '0', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'e', ' ', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '\'', 'M', 'a', 'x', ' ', '(', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'L', 'o', 'w', 'e', 'r', ')', ',', ' ', 'L', 'e', 'n', 'g', 't', 'h', '_', 'O', 'f', ' ', '(', 'B', 'o', 'u', 'n', 'd', 's', '.', 'U', 'p', 'p', 'e', 'r', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', ';', '\n']))

def integerImageSpecTokens_certificates : List LineCertificate :=
  integerImageSpecTokens_block_0_32.lines

def integerImageSpecTokens : Tokens :=
  ["with", "silver_scalars", ";", "package", "silver_integer_image", "with", "spark_mode", "=>", "on", "is", "subtype", "image_length", "is", "natural", "range", "2", "..", "11", ";", "subtype", "possible_length", "is", "natural", "range", "0", "..", "11", ";", "function", "length_of", "(", "item", ":", "silver_scalars", ".", "value", ")", "return", "image_length", "is", "(", "if", "item", ">", "-", "10", "and", "then", "item", "<", "10", "then", "2", "elsif", "item", ">", "-", "100", "and", "then", "item", "<", "100", "then", "3", "elsif", "item", ">", "-", "1_000", "and", "then", "item", "<", "1_000", "then", "4", "elsif", "item", ">", "-", "10_000", "and", "then", "item", "<", "10_000", "then", "5", "elsif", "item", ">", "-", "100_000", "and", "then", "item", "<", "100_000", "then", "6", "elsif", "item", ">", "-", "1_000_000", "and", "then", "item", "<", "1_000_000", "then", "7", "elsif", "item", ">", "-", "10_000_000", "and", "then", "item", "<", "10_000_000", "then", "8", "elsif", "item", ">", "-", "100_000_000", "and", "then", "item", "<", "100_000_000", "then", "9", "elsif", "item", ">", "-", "1_000_000_000", "and", "then", "item", "<", "1_000_000_000", "then", "10", "else", "11", ")", ";", "function", "minimum_length", "(", "bounds", ":", "silver_scalars", ".", "interval", ")", "return", "possible_length", "is", "(", "if", "silver_scalars", ".", "is_empty", "(", "bounds", ")", "then", "0", "elsif", "bounds", ".", "lower", "<=", "0", "and", "then", "bounds", ".", "upper", ">=", "0", "then", "2", "else", "image_length", "'", "min", "(", "length_of", "(", "bounds", ".", "lower", ")", ",", "length_of", "(", "bounds", ".", "upper", ")", ")", ")", ";", "function", "maximum_length", "(", "bounds", ":", "silver_scalars", ".", "interval", ")", "return", "possible_length", "is", "(", "if", "silver_scalars", ".", "is_empty", "(", "bounds", ")", "then", "0", "else", "image_length", "'", "max", "(", "length_of", "(", "bounds", ".", "lower", ")", ",", "length_of", "(", "bounds", ".", "upper", ")", ")", ")", ";", "end", "silver_integer_image", ";"]

theorem integerImageSpecTokens_source :
    String.intercalate "\n" (integerImageSpecTokens_certificates.map (·.text)) = integerImageSpec := by
  exact integerImageSpecTokens_block_0_32.correct

theorem integerImageSpecTokens_values :
    integerImageSpecTokens_certificates.flatMap (·.tokens) = integerImageSpecTokens := by rfl

theorem integerImageSpecTokens_correct : lex integerImageSpec = some integerImageSpecTokens := by
  rw [← integerImageSpecTokens_source, reconstructed_source_lex integerImageSpecTokens_certificates
    integerImageSpecTokens_block_0_32.nonempty]
  rw [integerImageSpecTokens_values]

end Silver.Source
