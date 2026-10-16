module

public import Silver.SourceLexer
public import Silver.ImageFilesSpecSource
public import Silver.ImageFilesBodySource
public meta import Silver.CertificateWitness

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Source

def imageFilesSpecTokens_line_0 : LineCertificate where
  text := "with Ada.Text_IO;"
  tokens := ["with", "ada", ".", "text_io", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_1 : LineCertificate where
  text := "with SPARK.Big_Integers;"
  tokens := ["with", "spark", ".", "big_integers", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_2 : LineCertificate where
  text := "with SPARK.Containers.Functional.Infinite_Sequences;"
  tokens := ["with", "spark", ".", "containers", ".", "functional", ".", "infinite_sequences", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_3 : LineCertificate where
  text := "with Silver_Image_Model;"
  tokens := ["with", "silver_image_model", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_4 : LineCertificate where
  text := "with Silver_Platform;"
  tokens := ["with", "silver_platform", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_5 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_6 : LineCertificate where
  text := "package Silver_Image_Files with SPARK_Mode => On is"
  tokens := ["package", "silver_image_files", "with", "spark_mode", "=>", "on", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_7 : LineCertificate where
  text := "   package Model renames Silver_Image_Model;"
  tokens := ["package", "model", "renames", "silver_image_model", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_8 : LineCertificate where
  text := "   use type Model.Plan;"
  tokens := ["use", "type", "model", ".", "plan", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_9 : LineCertificate where
  text := "   use type Model.Plan_Kind;"
  tokens := ["use", "type", "model", ".", "plan_kind", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_10 : LineCertificate where
  text := "   use type Model.Byte_Count;"
  tokens := ["use", "type", "model", ".", "byte_count", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_11 : LineCertificate where
  text := "   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences"
  tokens := ["package", "bytes", "is", "new", "spark", ".", "containers", ".", "functional", ".", "infinite_sequences"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_12 : LineCertificate where
  text := "     (Element_Type => Character, Use_Logical_Equality => True);"
  tokens := ["(", "element_type", "=>", "character", ",", "use_logical_equality", "=>", "true", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_13 : LineCertificate where
  text := "   use type Bytes.Sequence;"
  tokens := ["use", "type", "bytes", ".", "sequence", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_14 : LineCertificate where
  text := "   use SPARK.Big_Integers;"
  tokens := ["use", "spark", ".", "big_integers", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_15 : LineCertificate where
  text := "   package Counts is new Signed_Conversions (Model.Byte_Count);"
  tokens := ["package", "counts", "is", "new", "signed_conversions", "(", "model", ".", "byte_count", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_16 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_17 : LineCertificate where
  text := "   --  Exact byte-level splice, stated independently of the streaming loop."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_18 : LineCertificate where
  text := "   --  Count is the number of original bytes already copied. A fragment is"
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_19 : LineCertificate where
  text := "   --  present once the byte at its zero-based insertion offset was copied."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_20 : LineCertificate where
  text := "   function Spliced_Prefix"
  tokens := ["function", "spliced_prefix"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_21 : LineCertificate where
  text := "     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;"
  tokens := ["(", "original", ",", "refined", ":", "bytes", ".", "sequence", ";", "plan", ":", "model", ".", "plan", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_22 : LineCertificate where
  text := "      Count : Model.Byte_Count) return Boolean is"
  tokens := ["count", ":", "model", ".", "byte_count", ")", "return", "boolean", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_23 : LineCertificate where
  text := "     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)"
  tokens := ["(", "bytes", ".", "length", "(", "original", ")", "=", "counts", ".", "to_big_integer", "(", "count", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_24 : LineCertificate where
  text := "      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)"
  tokens := ["and", "then", "bytes", ".", "length", "(", "refined", ")", "=", "counts", ".", "to_big_integer", "(", "count", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_25 : LineCertificate where
  text := "        + (if Count > Plan.Declarations_Offset then"
  tokens := ["+", "(", "if", "count", ">", "plan", ".", "declarations_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_26 : LineCertificate where
  text := "             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
  tokens := ["to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", ")", "else", "0", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_27 : LineCertificate where
  text := "        + (if Count > Plan.Includes_Offset then"
  tokens := ["+", "(", "if", "count", ">", "plan", ".", "includes_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_28 : LineCertificate where
  text := "             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)"
  tokens := ["to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "includes_insertion", ")", ")", "else", "0", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_29 : LineCertificate where
  text := "      and then (for all I in Model.Byte_Count range 1 .. Count =>"
  tokens := ["and", "then", "(", "for", "all", "i", "in", "model", ".", "byte_count", "range", "1", "..", "count", "=>"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_30 : LineCertificate where
  text := "        Bytes.Get (Refined, Counts.To_Big_Integer (I)"
  tokens := ["bytes", ".", "get", "(", "refined", ",", "counts", ".", "to_big_integer", "(", "i", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_31 : LineCertificate where
  text := "          + (if I > Plan.Declarations_Offset then"
  tokens := ["+", "(", "if", "i", ">", "plan", ".", "declarations_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_32 : LineCertificate where
  text := "               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
  tokens := ["to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", ")", "else", "0", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_33 : LineCertificate where
  text := "          + (if I > Plan.Includes_Offset then"
  tokens := ["+", "(", "if", "i", ">", "plan", ".", "includes_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_34 : LineCertificate where
  text := "               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))"
  tokens := ["to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "includes_insertion", ")", ")", "else", "0", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_35 : LineCertificate where
  text := "        = Bytes.Get (Original, Counts.To_Big_Integer (I)))"
  tokens := ["=", "bytes", ".", "get", "(", "original", ",", "counts", ".", "to_big_integer", "(", "i", ")", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_36 : LineCertificate where
  text := "      and then (if Count > Plan.Declarations_Offset then"
  tokens := ["and", "then", "(", "if", "count", ">", "plan", ".", "declarations_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_37 : LineCertificate where
  text := "        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>"
  tokens := ["(", "for", "all", "i", "in", "1", "..", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", "=>"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_38 : LineCertificate where
  text := "          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)"
  tokens := ["bytes", ".", "get", "(", "refined", ",", "counts", ".", "to_big_integer", "(", "plan", ".", "declarations_offset", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_39 : LineCertificate where
  text := "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))"
  tokens := ["+", "to_big_integer", "(", "i", ")", ")", "=", "model", ".", "insertion_byte", "(", "model", ".", "declarations_insertion", ",", "i", ")", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_40 : LineCertificate where
  text := "      and then (if Count > Plan.Includes_Offset then"
  tokens := ["and", "then", "(", "if", "count", ">", "plan", ".", "includes_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_41 : LineCertificate where
  text := "        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>"
  tokens := ["(", "for", "all", "i", "in", "1", "..", "model", ".", "insertion_length", "(", "model", ".", "includes_insertion", ")", "=>"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_42 : LineCertificate where
  text := "          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)"
  tokens := ["bytes", ".", "get", "(", "refined", ",", "counts", ".", "to_big_integer", "(", "plan", ".", "includes_offset", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_43 : LineCertificate where
  text := "            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))"
  tokens := ["+", "to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_44 : LineCertificate where
  text := "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))"
  tokens := ["+", "to_big_integer", "(", "i", ")", ")", "=", "model", ".", "insertion_byte", "(", "model", ".", "includes_insertion", ",", "i", ")", ")", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_45 : LineCertificate where
  text := "     with Ghost => Static,"
  tokens := ["with", "ghost", "=>", "static", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_46 : LineCertificate where
  text := "       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;"
  tokens := ["pre", "=>", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_47 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_48 : LineCertificate where
  text := "   --  Observations of successful libc byte operations. These do not add a"
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_49 : LineCertificate where
  text := "   --  finite input-buffer limit or execute in the adapter binary."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_50 : LineCertificate where
  text := "   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;"
  tokens := ["read_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_51 : LineCertificate where
  text := "   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;"
  tokens := ["copied_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_52 : LineCertificate where
  text := "   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;"
  tokens := ["written_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_53 : LineCertificate where
  text := "   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;"
  tokens := ["read_ended", ",", "files_closed", ":", "boolean", ":=", "false", "with", "ghost", "=>", "static", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_54 : LineCertificate where
  text := "   Rechecked : Model.Plan := (others => <>) with Ghost => Static;"
  tokens := ["rechecked", ":", "model", ".", "plan", ":=", "(", "others", "=>", "<", ">", ")", "with", "ghost", "=>", "static", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_55 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_56 : LineCertificate where
  text := "   procedure Snapshot"
  tokens := ["procedure", "snapshot"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_57 : LineCertificate where
  text := "     (Input_Name, Snapshot_Name : String;"
  tokens := ["(", "input_name", ",", "snapshot_name", ":", "string", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_58 : LineCertificate where
  text := "      Plan : out Model.Plan; Success : out Boolean)"
  tokens := ["plan", ":", "out", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_59 : LineCertificate where
  text := "     with Global => (In_Out => Ada.Text_IO.File_System,"
  tokens := ["with", "global", "=>", "(", "in_out", "=>", "ada", ".", "text_io", ".", "file_system", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_60 : LineCertificate where
  text := "       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,"
  tokens := ["output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ",", "read_ended", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_61 : LineCertificate where
  text := "                  Files_Closed, Rechecked)),"
  tokens := ["files_closed", ",", "rechecked", ")", ")", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_62 : LineCertificate where
  text := "       Pre => Silver_Platform.Valid_Path (Input_Name)"
  tokens := ["pre", "=>", "silver_platform", ".", "valid_path", "(", "input_name", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_63 : LineCertificate where
  text := "         and then Silver_Platform.Valid_Path (Snapshot_Name)"
  tokens := ["and", "then", "silver_platform", ".", "valid_path", "(", "snapshot_name", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_64 : LineCertificate where
  text := "         and then Input_Name /= Snapshot_Name,"
  tokens := ["and", "then", "input_name", "/=", "snapshot_name", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_65 : LineCertificate where
  text := "       Post => (Runtime => (if Plan.Kind = Model.Refine then"
  tokens := ["post", "=>", "(", "runtime", "=>", "(", "if", "plan", ".", "kind", "=", "model", ".", "refine", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_66 : LineCertificate where
  text := "         Plan.Declarations_Offset < Plan.Includes_Offset"
  tokens := ["plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_67 : LineCertificate where
  text := "         and then Plan.Includes_Offset < Plan.Bytes),"
  tokens := ["and", "then", "plan", ".", "includes_offset", "<", "plan", ".", "bytes", ")", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_68 : LineCertificate where
  text := "         Static => (if Success then Read_Ended and then Files_Closed"
  tokens := ["static", "=>", "(", "if", "success", "then", "read_ended", "and", "then", "files_closed"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_69 : LineCertificate where
  text := "         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes"
  tokens := ["and", "then", "read_bytes", "=", "copied_bytes", "and", "then", "read_bytes", "=", "written_bytes"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_70 : LineCertificate where
  text := "         and then Plan = Rechecked));"
  tokens := ["and", "then", "plan", "=", "rechecked", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_71 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_72 : LineCertificate where
  text := "   procedure Refine"
  tokens := ["procedure", "refine"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_73 : LineCertificate where
  text := "     (Snapshot_Name, Refined_Name : String;"
  tokens := ["(", "snapshot_name", ",", "refined_name", ":", "string", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_74 : LineCertificate where
  text := "      Plan : Model.Plan; Success : out Boolean)"
  tokens := ["plan", ":", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_75 : LineCertificate where
  text := "     with Global => (In_Out => Ada.Text_IO.File_System,"
  tokens := ["with", "global", "=>", "(", "in_out", "=>", "ada", ".", "text_io", ".", "file_system", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_76 : LineCertificate where
  text := "       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,"
  tokens := ["output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ",", "read_ended", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_77 : LineCertificate where
  text := "                  Files_Closed, Rechecked)),"
  tokens := ["files_closed", ",", "rechecked", ")", ")", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_78 : LineCertificate where
  text := "       Pre => Silver_Platform.Valid_Path (Snapshot_Name)"
  tokens := ["pre", "=>", "silver_platform", ".", "valid_path", "(", "snapshot_name", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_79 : LineCertificate where
  text := "         and then Silver_Platform.Valid_Path (Refined_Name)"
  tokens := ["and", "then", "silver_platform", ".", "valid_path", "(", "refined_name", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_80 : LineCertificate where
  text := "         and then Snapshot_Name /= Refined_Name"
  tokens := ["and", "then", "snapshot_name", "/=", "refined_name"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_81 : LineCertificate where
  text := "         and then Plan.Kind = Model.Refine"
  tokens := ["and", "then", "plan", ".", "kind", "=", "model", ".", "refine"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_82 : LineCertificate where
  text := "         and then Plan.Declarations_Offset < Plan.Includes_Offset"
  tokens := ["and", "then", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_83 : LineCertificate where
  text := "         and then Plan.Includes_Offset < Plan.Bytes,"
  tokens := ["and", "then", "plan", ".", "includes_offset", "<", "plan", ".", "bytes", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_84 : LineCertificate where
  text := "       Post => (Static => (if Success then Read_Ended and then Files_Closed"
  tokens := ["post", "=>", "(", "static", "=>", "(", "if", "success", "then", "read_ended", "and", "then", "files_closed"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_85 : LineCertificate where
  text := "         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan"
  tokens := ["and", "then", "read_bytes", "=", "copied_bytes", "and", "then", "rechecked", "=", "plan"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_86 : LineCertificate where
  text := "         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));"
  tokens := ["and", "then", "spliced_prefix", "(", "read_bytes", ",", "written_bytes", ",", "plan", ",", "plan", ".", "bytes", ")", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_87 : LineCertificate where
  text := "end Silver_Image_Files;"
  tokens := ["end", "silver_image_files", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_line_88 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesSpecTokens_block_0_1 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_0

def imageFilesSpecTokens_block_1_2 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_1

def imageFilesSpecTokens_block_0_2 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_0_1 imageFilesSpecTokens_block_1_2
    "with Ada.Text_IO;\nwith SPARK.Big_Integers;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', ';']
      ['w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';']))

def imageFilesSpecTokens_block_2_3 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_2

def imageFilesSpecTokens_block_3_4 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_3

def imageFilesSpecTokens_block_4_5 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_4

def imageFilesSpecTokens_block_3_5 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_3_4 imageFilesSpecTokens_block_4_5
    "with Silver_Image_Model;\nwith Silver_Platform;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';']
      ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', ';']))

def imageFilesSpecTokens_block_2_5 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_2_3 imageFilesSpecTokens_block_3_5
    "with SPARK.Containers.Functional.Infinite_Sequences;\nwith Silver_Image_Model;\nwith Silver_Platform;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', ';']
      ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', ';']))

def imageFilesSpecTokens_block_0_5 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_0_2 imageFilesSpecTokens_block_2_5
    "with Ada.Text_IO;\nwith SPARK.Big_Integers;\nwith SPARK.Containers.Functional.Infinite_Sequences;\nwith Silver_Image_Model;\nwith Silver_Platform;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';']
      ['w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', ';']))

def imageFilesSpecTokens_block_5_6 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_5

def imageFilesSpecTokens_block_6_7 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_6

def imageFilesSpecTokens_block_7_8 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_7

def imageFilesSpecTokens_block_6_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_6_7 imageFilesSpecTokens_block_7_8
    "package Silver_Image_Files with SPARK_Mode => On is\n   package Model renames Silver_Image_Model;"
    (by kernel_exact (string_join_ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'M', 'o', 'd', 'e', 'l', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';']))

def imageFilesSpecTokens_block_5_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_5_6 imageFilesSpecTokens_block_6_8
    "\npackage Silver_Image_Files with SPARK_Mode => On is\n   package Model renames Silver_Image_Model;"
    (by kernel_exact (string_join_ofList []
      ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'M', 'o', 'd', 'e', 'l', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';']))

def imageFilesSpecTokens_block_8_9 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_8

def imageFilesSpecTokens_block_9_10 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_9

def imageFilesSpecTokens_block_10_11 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_10

def imageFilesSpecTokens_block_9_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_9_10 imageFilesSpecTokens_block_10_11
    "   use type Model.Plan_Kind;\n   use type Model.Byte_Count;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']))

def imageFilesSpecTokens_block_8_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_8_9 imageFilesSpecTokens_block_9_11
    "   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use type Model.Byte_Count;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']))

def imageFilesSpecTokens_block_5_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_5_8 imageFilesSpecTokens_block_8_11
    "\npackage Silver_Image_Files with SPARK_Mode => On is\n   package Model renames Silver_Image_Model;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use type Model.Byte_Count;"
    (by kernel_exact (string_join_ofList ['\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'M', 'o', 'd', 'e', 'l', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']))

def imageFilesSpecTokens_block_0_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_0_5 imageFilesSpecTokens_block_5_11
    "with Ada.Text_IO;\nwith SPARK.Big_Integers;\nwith SPARK.Containers.Functional.Infinite_Sequences;\nwith Silver_Image_Model;\nwith Silver_Platform;\n\npackage Silver_Image_Files with SPARK_Mode => On is\n   package Model renames Silver_Image_Model;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use type Model.Byte_Count;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', ';']
      ['\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'M', 'o', 'd', 'e', 'l', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']))

def imageFilesSpecTokens_block_11_12 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_11

def imageFilesSpecTokens_block_12_13 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_12

def imageFilesSpecTokens_block_11_13 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_11_12 imageFilesSpecTokens_block_12_13
    "   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences\n     (Element_Type => Character, Use_Logical_Equality => True);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'B', 'y', 't', 'e', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'E', 'l', 'e', 'm', 'e', 'n', 't', '_', 'T', 'y', 'p', 'e', ' ', '=', '>', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ',', ' ', 'U', 's', 'e', '_', 'L', 'o', 'g', 'i', 'c', 'a', 'l', '_', 'E', 'q', 'u', 'a', 'l', 'i', 't', 'y', ' ', '=', '>', ' ', 'T', 'r', 'u', 'e', ')', ';']))

def imageFilesSpecTokens_block_13_14 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_13

def imageFilesSpecTokens_block_14_15 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_14

def imageFilesSpecTokens_block_15_16 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_15

def imageFilesSpecTokens_block_14_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_14_15 imageFilesSpecTokens_block_15_16
    "   use SPARK.Big_Integers;\n   package Counts is new Signed_Conversions (Model.Byte_Count);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';']
      [' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'C', 'o', 'u', 'n', 't', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'i', 'g', 'n', 'e', 'd', '_', 'C', 'o', 'n', 'v', 'e', 'r', 's', 'i', 'o', 'n', 's', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ';']))

def imageFilesSpecTokens_block_13_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_13_14 imageFilesSpecTokens_block_14_16
    "   use type Bytes.Sequence;\n   use SPARK.Big_Integers;\n   package Counts is new Signed_Conversions (Model.Byte_Count);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'C', 'o', 'u', 'n', 't', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'i', 'g', 'n', 'e', 'd', '_', 'C', 'o', 'n', 'v', 'e', 'r', 's', 'i', 'o', 'n', 's', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ';']))

def imageFilesSpecTokens_block_11_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_11_13 imageFilesSpecTokens_block_13_16
    "   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences\n     (Element_Type => Character, Use_Logical_Equality => True);\n   use type Bytes.Sequence;\n   use SPARK.Big_Integers;\n   package Counts is new Signed_Conversions (Model.Byte_Count);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'B', 'y', 't', 'e', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'E', 'l', 'e', 'm', 'e', 'n', 't', '_', 'T', 'y', 'p', 'e', ' ', '=', '>', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ',', ' ', 'U', 's', 'e', '_', 'L', 'o', 'g', 'i', 'c', 'a', 'l', '_', 'E', 'q', 'u', 'a', 'l', 'i', 't', 'y', ' ', '=', '>', ' ', 'T', 'r', 'u', 'e', ')', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'C', 'o', 'u', 'n', 't', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'i', 'g', 'n', 'e', 'd', '_', 'C', 'o', 'n', 'v', 'e', 'r', 's', 'i', 'o', 'n', 's', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ';']))

def imageFilesSpecTokens_block_16_17 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_16

def imageFilesSpecTokens_block_17_18 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_17

def imageFilesSpecTokens_block_18_19 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_18

def imageFilesSpecTokens_block_17_19 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_17_18 imageFilesSpecTokens_block_18_19
    "   --  Exact byte-level splice, stated independently of the streaming loop.\n   --  Count is the number of original bytes already copied. A fragment is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'a', 'c', 't', ' ', 'b', 'y', 't', 'e', '-', 'l', 'e', 'v', 'e', 'l', ' ', 's', 'p', 'l', 'i', 'c', 'e', ',', ' ', 's', 't', 'a', 't', 'e', 'd', ' ', 'i', 'n', 'd', 'e', 'p', 'e', 'n', 'd', 'e', 'n', 't', 'l', 'y', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 's', 't', 'r', 'e', 'a', 'm', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'p', '.']
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ' ', 'b', 'y', 't', 'e', 's', ' ', 'a', 'l', 'r', 'e', 'a', 'd', 'y', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', ' ', 'A', ' ', 'f', 'r', 'a', 'g', 'm', 'e', 'n', 't', ' ', 'i', 's']))

def imageFilesSpecTokens_block_16_19 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_16_17 imageFilesSpecTokens_block_17_19
    "\n   --  Exact byte-level splice, stated independently of the streaming loop.\n   --  Count is the number of original bytes already copied. A fragment is"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'a', 'c', 't', ' ', 'b', 'y', 't', 'e', '-', 'l', 'e', 'v', 'e', 'l', ' ', 's', 'p', 'l', 'i', 'c', 'e', ',', ' ', 's', 't', 'a', 't', 'e', 'd', ' ', 'i', 'n', 'd', 'e', 'p', 'e', 'n', 'd', 'e', 'n', 't', 'l', 'y', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 's', 't', 'r', 'e', 'a', 'm', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'p', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ' ', 'b', 'y', 't', 'e', 's', ' ', 'a', 'l', 'r', 'e', 'a', 'd', 'y', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', ' ', 'A', ' ', 'f', 'r', 'a', 'g', 'm', 'e', 'n', 't', ' ', 'i', 's']))

def imageFilesSpecTokens_block_19_20 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_19

def imageFilesSpecTokens_block_20_21 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_20

def imageFilesSpecTokens_block_21_22 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_21

def imageFilesSpecTokens_block_20_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_20_21 imageFilesSpecTokens_block_21_22
    "   function Spliced_Prefix\n     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x']
      [' ', ' ', ' ', ' ', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']))

def imageFilesSpecTokens_block_19_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_19_20 imageFilesSpecTokens_block_20_22
    "   --  present once the byte at its zero-based insertion offset was copied.\n   function Spliced_Prefix\n     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't', ' ', 'o', 'n', 'c', 'e', ' ', 't', 'h', 'e', ' ', 'b', 'y', 't', 'e', ' ', 'a', 't', ' ', 'i', 't', 's', ' ', 'z', 'e', 'r', 'o', '-', 'b', 'a', 's', 'e', 'd', ' ', 'i', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', 'o', 'f', 'f', 's', 'e', 't', ' ', 'w', 'a', 's', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.']
      [' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']))

def imageFilesSpecTokens_block_16_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_16_19 imageFilesSpecTokens_block_19_22
    "\n   --  Exact byte-level splice, stated independently of the streaming loop.\n   --  Count is the number of original bytes already copied. A fragment is\n   --  present once the byte at its zero-based insertion offset was copied.\n   function Spliced_Prefix\n     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'a', 'c', 't', ' ', 'b', 'y', 't', 'e', '-', 'l', 'e', 'v', 'e', 'l', ' ', 's', 'p', 'l', 'i', 'c', 'e', ',', ' ', 's', 't', 'a', 't', 'e', 'd', ' ', 'i', 'n', 'd', 'e', 'p', 'e', 'n', 'd', 'e', 'n', 't', 'l', 'y', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 's', 't', 'r', 'e', 'a', 'm', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'p', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ' ', 'b', 'y', 't', 'e', 's', ' ', 'a', 'l', 'r', 'e', 'a', 'd', 'y', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', ' ', 'A', ' ', 'f', 'r', 'a', 'g', 'm', 'e', 'n', 't', ' ', 'i', 's']
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't', ' ', 'o', 'n', 'c', 'e', ' ', 't', 'h', 'e', ' ', 'b', 'y', 't', 'e', ' ', 'a', 't', ' ', 'i', 't', 's', ' ', 'z', 'e', 'r', 'o', '-', 'b', 'a', 's', 'e', 'd', ' ', 'i', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', 'o', 'f', 'f', 's', 'e', 't', ' ', 'w', 'a', 's', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']))

def imageFilesSpecTokens_block_11_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_11_16 imageFilesSpecTokens_block_16_22
    "   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences\n     (Element_Type => Character, Use_Logical_Equality => True);\n   use type Bytes.Sequence;\n   use SPARK.Big_Integers;\n   package Counts is new Signed_Conversions (Model.Byte_Count);\n\n   --  Exact byte-level splice, stated independently of the streaming loop.\n   --  Count is the number of original bytes already copied. A fragment is\n   --  present once the byte at its zero-based insertion offset was copied.\n   function Spliced_Prefix\n     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'B', 'y', 't', 'e', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'E', 'l', 'e', 'm', 'e', 'n', 't', '_', 'T', 'y', 'p', 'e', ' ', '=', '>', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ',', ' ', 'U', 's', 'e', '_', 'L', 'o', 'g', 'i', 'c', 'a', 'l', '_', 'E', 'q', 'u', 'a', 'l', 'i', 't', 'y', ' ', '=', '>', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'C', 'o', 'u', 'n', 't', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'i', 'g', 'n', 'e', 'd', '_', 'C', 'o', 'n', 'v', 'e', 'r', 's', 'i', 'o', 'n', 's', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ';']
      ['\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'a', 'c', 't', ' ', 'b', 'y', 't', 'e', '-', 'l', 'e', 'v', 'e', 'l', ' ', 's', 'p', 'l', 'i', 'c', 'e', ',', ' ', 's', 't', 'a', 't', 'e', 'd', ' ', 'i', 'n', 'd', 'e', 'p', 'e', 'n', 'd', 'e', 'n', 't', 'l', 'y', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 's', 't', 'r', 'e', 'a', 'm', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'p', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ' ', 'b', 'y', 't', 'e', 's', ' ', 'a', 'l', 'r', 'e', 'a', 'd', 'y', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', ' ', 'A', ' ', 'f', 'r', 'a', 'g', 'm', 'e', 'n', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't', ' ', 'o', 'n', 'c', 'e', ' ', 't', 'h', 'e', ' ', 'b', 'y', 't', 'e', ' ', 'a', 't', ' ', 'i', 't', 's', ' ', 'z', 'e', 'r', 'o', '-', 'b', 'a', 's', 'e', 'd', ' ', 'i', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', 'o', 'f', 'f', 's', 'e', 't', ' ', 'w', 'a', 's', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']))

def imageFilesSpecTokens_block_0_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_0_11 imageFilesSpecTokens_block_11_22
    "with Ada.Text_IO;\nwith SPARK.Big_Integers;\nwith SPARK.Containers.Functional.Infinite_Sequences;\nwith Silver_Image_Model;\nwith Silver_Platform;\n\npackage Silver_Image_Files with SPARK_Mode => On is\n   package Model renames Silver_Image_Model;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use type Model.Byte_Count;\n   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences\n     (Element_Type => Character, Use_Logical_Equality => True);\n   use type Bytes.Sequence;\n   use SPARK.Big_Integers;\n   package Counts is new Signed_Conversions (Model.Byte_Count);\n\n   --  Exact byte-level splice, stated independently of the streaming loop.\n   --  Count is the number of original bytes already copied. A fragment is\n   --  present once the byte at its zero-based insertion offset was copied.\n   function Spliced_Prefix\n     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'M', 'o', 'd', 'e', 'l', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']
      [' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'B', 'y', 't', 'e', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'E', 'l', 'e', 'm', 'e', 'n', 't', '_', 'T', 'y', 'p', 'e', ' ', '=', '>', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ',', ' ', 'U', 's', 'e', '_', 'L', 'o', 'g', 'i', 'c', 'a', 'l', '_', 'E', 'q', 'u', 'a', 'l', 'i', 't', 'y', ' ', '=', '>', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'C', 'o', 'u', 'n', 't', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'i', 'g', 'n', 'e', 'd', '_', 'C', 'o', 'n', 'v', 'e', 'r', 's', 'i', 'o', 'n', 's', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'a', 'c', 't', ' ', 'b', 'y', 't', 'e', '-', 'l', 'e', 'v', 'e', 'l', ' ', 's', 'p', 'l', 'i', 'c', 'e', ',', ' ', 's', 't', 'a', 't', 'e', 'd', ' ', 'i', 'n', 'd', 'e', 'p', 'e', 'n', 'd', 'e', 'n', 't', 'l', 'y', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 's', 't', 'r', 'e', 'a', 'm', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'p', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ' ', 'b', 'y', 't', 'e', 's', ' ', 'a', 'l', 'r', 'e', 'a', 'd', 'y', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', ' ', 'A', ' ', 'f', 'r', 'a', 'g', 'm', 'e', 'n', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't', ' ', 'o', 'n', 'c', 'e', ' ', 't', 'h', 'e', ' ', 'b', 'y', 't', 'e', ' ', 'a', 't', ' ', 'i', 't', 's', ' ', 'z', 'e', 'r', 'o', '-', 'b', 'a', 's', 'e', 'd', ' ', 'i', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', 'o', 'f', 'f', 's', 'e', 't', ' ', 'w', 'a', 's', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']))

def imageFilesSpecTokens_block_22_23 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_22

def imageFilesSpecTokens_block_23_24 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_23

def imageFilesSpecTokens_block_22_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_22_23 imageFilesSpecTokens_block_23_24
    "      Count : Model.Byte_Count) return Boolean is\n     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', '(', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')']))

def imageFilesSpecTokens_block_24_25 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_24

def imageFilesSpecTokens_block_25_26 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_25

def imageFilesSpecTokens_block_26_27 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_26

def imageFilesSpecTokens_block_25_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_25_26 imageFilesSpecTokens_block_26_27
    "        + (if Count > Plan.Declarations_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']))

def imageFilesSpecTokens_block_24_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_24_25 imageFilesSpecTokens_block_25_27
    "      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)\n        + (if Count > Plan.Declarations_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']))

def imageFilesSpecTokens_block_22_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_22_24 imageFilesSpecTokens_block_24_27
    "      Count : Model.Byte_Count) return Boolean is\n     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)\n      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)\n        + (if Count > Plan.Declarations_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']))

def imageFilesSpecTokens_block_27_28 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_27

def imageFilesSpecTokens_block_28_29 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_28

def imageFilesSpecTokens_block_29_30 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_29

def imageFilesSpecTokens_block_28_30 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_28_29 imageFilesSpecTokens_block_29_30
    "             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)\n      and then (for all I in Model.Byte_Count range 1 .. Count =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '1', ' ', '.', '.', ' ', 'C', 'o', 'u', 'n', 't', ' ', '=', '>']))

def imageFilesSpecTokens_block_27_30 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_27_28 imageFilesSpecTokens_block_28_30
    "        + (if Count > Plan.Includes_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)\n      and then (for all I in Model.Byte_Count range 1 .. Count =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '1', ' ', '.', '.', ' ', 'C', 'o', 'u', 'n', 't', ' ', '=', '>']))

def imageFilesSpecTokens_block_30_31 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_30

def imageFilesSpecTokens_block_31_32 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_31

def imageFilesSpecTokens_block_32_33 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_32

def imageFilesSpecTokens_block_31_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_31_32 imageFilesSpecTokens_block_32_33
    "          + (if I > Plan.Declarations_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']))

def imageFilesSpecTokens_block_30_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_30_31 imageFilesSpecTokens_block_31_33
    "        Bytes.Get (Refined, Counts.To_Big_Integer (I)\n          + (if I > Plan.Declarations_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']))

def imageFilesSpecTokens_block_27_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_27_30 imageFilesSpecTokens_block_30_33
    "        + (if Count > Plan.Includes_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)\n      and then (for all I in Model.Byte_Count range 1 .. Count =>\n        Bytes.Get (Refined, Counts.To_Big_Integer (I)\n          + (if I > Plan.Declarations_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '1', ' ', '.', '.', ' ', 'C', 'o', 'u', 'n', 't', ' ', '=', '>']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']))

def imageFilesSpecTokens_block_22_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_22_27 imageFilesSpecTokens_block_27_33
    "      Count : Model.Byte_Count) return Boolean is\n     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)\n      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)\n        + (if Count > Plan.Declarations_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)\n        + (if Count > Plan.Includes_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)\n      and then (for all I in Model.Byte_Count range 1 .. Count =>\n        Bytes.Get (Refined, Counts.To_Big_Integer (I)\n          + (if I > Plan.Declarations_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '1', ' ', '.', '.', ' ', 'C', 'o', 'u', 'n', 't', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']))

def imageFilesSpecTokens_block_33_34 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_33

def imageFilesSpecTokens_block_34_35 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_34

def imageFilesSpecTokens_block_33_35 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_33_34 imageFilesSpecTokens_block_34_35
    "          + (if I > Plan.Includes_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ')']))

def imageFilesSpecTokens_block_35_36 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_35

def imageFilesSpecTokens_block_36_37 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_36

def imageFilesSpecTokens_block_37_38 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_37

def imageFilesSpecTokens_block_36_38 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_36_37 imageFilesSpecTokens_block_37_38
    "      and then (if Count > Plan.Declarations_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>']))

def imageFilesSpecTokens_block_35_38 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_35_36 imageFilesSpecTokens_block_36_38
    "        = Bytes.Get (Original, Counts.To_Big_Integer (I)))\n      and then (if Count > Plan.Declarations_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>']))

def imageFilesSpecTokens_block_33_38 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_33_35 imageFilesSpecTokens_block_35_38
    "          + (if I > Plan.Includes_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))\n        = Bytes.Get (Original, Counts.To_Big_Integer (I)))\n      and then (if Count > Plan.Declarations_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>']))

def imageFilesSpecTokens_block_38_39 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_38

def imageFilesSpecTokens_block_39_40 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_39

def imageFilesSpecTokens_block_40_41 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_40

def imageFilesSpecTokens_block_39_41 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_39_40 imageFilesSpecTokens_block_40_41
    "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))\n      and then (if Count > Plan.Includes_Offset then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']))

def imageFilesSpecTokens_block_38_41 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_38_39 imageFilesSpecTokens_block_39_41
    "          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)\n            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))\n      and then (if Count > Plan.Includes_Offset then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']))

def imageFilesSpecTokens_block_41_42 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_41

def imageFilesSpecTokens_block_42_43 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_42

def imageFilesSpecTokens_block_43_44 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_43

def imageFilesSpecTokens_block_42_44 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_42_43 imageFilesSpecTokens_block_43_44
    "          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)\n            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')']))

def imageFilesSpecTokens_block_41_44 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_41_42 imageFilesSpecTokens_block_42_44
    "        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)\n            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')']))

def imageFilesSpecTokens_block_38_44 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_38_41 imageFilesSpecTokens_block_41_44
    "          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)\n            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))\n      and then (if Count > Plan.Includes_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)\n            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')']))

def imageFilesSpecTokens_block_33_44 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_33_38 imageFilesSpecTokens_block_38_44
    "          + (if I > Plan.Includes_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))\n        = Bytes.Get (Original, Counts.To_Big_Integer (I)))\n      and then (if Count > Plan.Declarations_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)\n            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))\n      and then (if Count > Plan.Includes_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)\n            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')']))

def imageFilesSpecTokens_block_22_44 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_22_33 imageFilesSpecTokens_block_33_44
    "      Count : Model.Byte_Count) return Boolean is\n     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)\n      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)\n        + (if Count > Plan.Declarations_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)\n        + (if Count > Plan.Includes_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)\n      and then (for all I in Model.Byte_Count range 1 .. Count =>\n        Bytes.Get (Refined, Counts.To_Big_Integer (I)\n          + (if I > Plan.Declarations_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)\n          + (if I > Plan.Includes_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))\n        = Bytes.Get (Original, Counts.To_Big_Integer (I)))\n      and then (if Count > Plan.Declarations_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)\n            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))\n      and then (if Count > Plan.Includes_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)\n            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '1', ' ', '.', '.', ' ', 'C', 'o', 'u', 'n', 't', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')']))

def imageFilesSpecTokens_block_0_44 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_0_22 imageFilesSpecTokens_block_22_44
    "with Ada.Text_IO;\nwith SPARK.Big_Integers;\nwith SPARK.Containers.Functional.Infinite_Sequences;\nwith Silver_Image_Model;\nwith Silver_Platform;\n\npackage Silver_Image_Files with SPARK_Mode => On is\n   package Model renames Silver_Image_Model;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use type Model.Byte_Count;\n   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences\n     (Element_Type => Character, Use_Logical_Equality => True);\n   use type Bytes.Sequence;\n   use SPARK.Big_Integers;\n   package Counts is new Signed_Conversions (Model.Byte_Count);\n\n   --  Exact byte-level splice, stated independently of the streaming loop.\n   --  Count is the number of original bytes already copied. A fragment is\n   --  present once the byte at its zero-based insertion offset was copied.\n   function Spliced_Prefix\n     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;\n      Count : Model.Byte_Count) return Boolean is\n     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)\n      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)\n        + (if Count > Plan.Declarations_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)\n        + (if Count > Plan.Includes_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)\n      and then (for all I in Model.Byte_Count range 1 .. Count =>\n        Bytes.Get (Refined, Counts.To_Big_Integer (I)\n          + (if I > Plan.Declarations_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)\n          + (if I > Plan.Includes_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))\n        = Bytes.Get (Original, Counts.To_Big_Integer (I)))\n      and then (if Count > Plan.Declarations_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)\n            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))\n      and then (if Count > Plan.Includes_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)\n            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'M', 'o', 'd', 'e', 'l', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'B', 'y', 't', 'e', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'E', 'l', 'e', 'm', 'e', 'n', 't', '_', 'T', 'y', 'p', 'e', ' ', '=', '>', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ',', ' ', 'U', 's', 'e', '_', 'L', 'o', 'g', 'i', 'c', 'a', 'l', '_', 'E', 'q', 'u', 'a', 'l', 'i', 't', 'y', ' ', '=', '>', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'C', 'o', 'u', 'n', 't', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'i', 'g', 'n', 'e', 'd', '_', 'C', 'o', 'n', 'v', 'e', 'r', 's', 'i', 'o', 'n', 's', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'a', 'c', 't', ' ', 'b', 'y', 't', 'e', '-', 'l', 'e', 'v', 'e', 'l', ' ', 's', 'p', 'l', 'i', 'c', 'e', ',', ' ', 's', 't', 'a', 't', 'e', 'd', ' ', 'i', 'n', 'd', 'e', 'p', 'e', 'n', 'd', 'e', 'n', 't', 'l', 'y', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 's', 't', 'r', 'e', 'a', 'm', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'p', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ' ', 'b', 'y', 't', 'e', 's', ' ', 'a', 'l', 'r', 'e', 'a', 'd', 'y', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', ' ', 'A', ' ', 'f', 'r', 'a', 'g', 'm', 'e', 'n', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't', ' ', 'o', 'n', 'c', 'e', ' ', 't', 'h', 'e', ' ', 'b', 'y', 't', 'e', ' ', 'a', 't', ' ', 'i', 't', 's', ' ', 'z', 'e', 'r', 'o', '-', 'b', 'a', 's', 'e', 'd', ' ', 'i', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', 'o', 'f', 'f', 's', 'e', 't', ' ', 'w', 'a', 's', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '1', ' ', '.', '.', ' ', 'C', 'o', 'u', 'n', 't', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')']))

def imageFilesSpecTokens_block_44_45 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_44

def imageFilesSpecTokens_block_45_46 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_45

def imageFilesSpecTokens_block_44_46 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_44_45 imageFilesSpecTokens_block_45_46
    "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))\n     with Ghost => Static,"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', ')']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ',']))

def imageFilesSpecTokens_block_46_47 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_46

def imageFilesSpecTokens_block_47_48 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_47

def imageFilesSpecTokens_block_48_49 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_48

def imageFilesSpecTokens_block_47_49 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_47_48 imageFilesSpecTokens_block_48_49
    "\n   --  Observations of successful libc byte operations. These do not add a"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'o', 'f', ' ', 's', 'u', 'c', 'c', 'e', 's', 's', 'f', 'u', 'l', ' ', 'l', 'i', 'b', 'c', ' ', 'b', 'y', 't', 'e', ' ', 'o', 'p', 'e', 'r', 'a', 't', 'i', 'o', 'n', 's', '.', ' ', 'T', 'h', 'e', 's', 'e', ' ', 'd', 'o', ' ', 'n', 'o', 't', ' ', 'a', 'd', 'd', ' ', 'a']))

def imageFilesSpecTokens_block_46_49 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_46_47 imageFilesSpecTokens_block_47_49
    "       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;\n\n   --  Observations of successful libc byte operations. These do not add a"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ';']
      ['\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'o', 'f', ' ', 's', 'u', 'c', 'c', 'e', 's', 's', 'f', 'u', 'l', ' ', 'l', 'i', 'b', 'c', ' ', 'b', 'y', 't', 'e', ' ', 'o', 'p', 'e', 'r', 'a', 't', 'i', 'o', 'n', 's', '.', ' ', 'T', 'h', 'e', 's', 'e', ' ', 'd', 'o', ' ', 'n', 'o', 't', ' ', 'a', 'd', 'd', ' ', 'a']))

def imageFilesSpecTokens_block_44_49 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_44_46 imageFilesSpecTokens_block_46_49
    "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))\n     with Ghost => Static,\n       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;\n\n   --  Observations of successful libc byte operations. These do not add a"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'o', 'f', ' ', 's', 'u', 'c', 'c', 'e', 's', 's', 'f', 'u', 'l', ' ', 'l', 'i', 'b', 'c', ' ', 'b', 'y', 't', 'e', ' ', 'o', 'p', 'e', 'r', 'a', 't', 'i', 'o', 'n', 's', '.', ' ', 'T', 'h', 'e', 's', 'e', ' ', 'd', 'o', ' ', 'n', 'o', 't', ' ', 'a', 'd', 'd', ' ', 'a']))

def imageFilesSpecTokens_block_49_50 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_49

def imageFilesSpecTokens_block_50_51 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_50

def imageFilesSpecTokens_block_51_52 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_51

def imageFilesSpecTokens_block_50_52 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_50_51 imageFilesSpecTokens_block_51_52
    "   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']
      [' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesSpecTokens_block_49_52 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_49_50 imageFilesSpecTokens_block_50_52
    "   --  finite input-buffer limit or execute in the adapter binary.\n   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'f', 'i', 'n', 'i', 't', 'e', ' ', 'i', 'n', 'p', 'u', 't', '-', 'b', 'u', 'f', 'f', 'e', 'r', ' ', 'l', 'i', 'm', 'i', 't', ' ', 'o', 'r', ' ', 'e', 'x', 'e', 'c', 'u', 't', 'e', ' ', 'i', 'n', ' ', 't', 'h', 'e', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'b', 'i', 'n', 'a', 'r', 'y', '.']
      [' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesSpecTokens_block_52_53 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_52

def imageFilesSpecTokens_block_53_54 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_53

def imageFilesSpecTokens_block_54_55 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_54

def imageFilesSpecTokens_block_53_55 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_53_54 imageFilesSpecTokens_block_54_55
    "   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;\n   Rechecked : Model.Plan := (others => <>) with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']
      [' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesSpecTokens_block_52_55 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_52_53 imageFilesSpecTokens_block_53_55
    "   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;\n   Rechecked : Model.Plan := (others => <>) with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']
      [' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesSpecTokens_block_49_55 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_49_52 imageFilesSpecTokens_block_52_55
    "   --  finite input-buffer limit or execute in the adapter binary.\n   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;\n   Rechecked : Model.Plan := (others => <>) with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', '-', '-', ' ', ' ', 'f', 'i', 'n', 'i', 't', 'e', ' ', 'i', 'n', 'p', 'u', 't', '-', 'b', 'u', 'f', 'f', 'e', 'r', ' ', 'l', 'i', 'm', 'i', 't', ' ', 'o', 'r', ' ', 'e', 'x', 'e', 'c', 'u', 't', 'e', ' ', 'i', 'n', ' ', 't', 'h', 'e', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'b', 'i', 'n', 'a', 'r', 'y', '.', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']
      [' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesSpecTokens_block_44_55 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_44_49 imageFilesSpecTokens_block_49_55
    "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))\n     with Ghost => Static,\n       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;\n\n   --  Observations of successful libc byte operations. These do not add a\n   --  finite input-buffer limit or execute in the adapter binary.\n   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;\n   Rechecked : Model.Plan := (others => <>) with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'o', 'f', ' ', 's', 'u', 'c', 'c', 'e', 's', 's', 'f', 'u', 'l', ' ', 'l', 'i', 'b', 'c', ' ', 'b', 'y', 't', 'e', ' ', 'o', 'p', 'e', 'r', 'a', 't', 'i', 'o', 'n', 's', '.', ' ', 'T', 'h', 'e', 's', 'e', ' ', 'd', 'o', ' ', 'n', 'o', 't', ' ', 'a', 'd', 'd', ' ', 'a']
      [' ', ' ', ' ', '-', '-', ' ', ' ', 'f', 'i', 'n', 'i', 't', 'e', ' ', 'i', 'n', 'p', 'u', 't', '-', 'b', 'u', 'f', 'f', 'e', 'r', ' ', 'l', 'i', 'm', 'i', 't', ' ', 'o', 'r', ' ', 'e', 'x', 'e', 'c', 'u', 't', 'e', ' ', 'i', 'n', ' ', 't', 'h', 'e', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'b', 'i', 'n', 'a', 'r', 'y', '.', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesSpecTokens_block_55_56 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_55

def imageFilesSpecTokens_block_56_57 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_56

def imageFilesSpecTokens_block_55_57 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_55_56 imageFilesSpecTokens_block_56_57
    "\n   procedure Snapshot"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't']))

def imageFilesSpecTokens_block_57_58 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_57

def imageFilesSpecTokens_block_58_59 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_58

def imageFilesSpecTokens_block_59_60 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_59

def imageFilesSpecTokens_block_58_60 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_58_59 imageFilesSpecTokens_block_59_60
    "      Plan : out Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',']))

def imageFilesSpecTokens_block_57_60 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_57_58 imageFilesSpecTokens_block_58_60
    "     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',']))

def imageFilesSpecTokens_block_55_60 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_55_57 imageFilesSpecTokens_block_57_60
    "\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't']
      [' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',']))

def imageFilesSpecTokens_block_60_61 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_60

def imageFilesSpecTokens_block_61_62 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_61

def imageFilesSpecTokens_block_62_63 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_62

def imageFilesSpecTokens_block_61_63 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_61_62 imageFilesSpecTokens_block_62_63
    "                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Input_Name)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')']))

def imageFilesSpecTokens_block_60_63 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_60_61 imageFilesSpecTokens_block_61_63
    "       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Input_Name)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')']))

def imageFilesSpecTokens_block_63_64 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_63

def imageFilesSpecTokens_block_64_65 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_64

def imageFilesSpecTokens_block_65_66 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_65

def imageFilesSpecTokens_block_64_66 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_64_65 imageFilesSpecTokens_block_65_66
    "         and then Input_Name /= Snapshot_Name,\n       Post => (Runtime => (if Plan.Kind = Model.Refine then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'R', 'u', 'n', 't', 'i', 'm', 'e', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', ' ', 't', 'h', 'e', 'n']))

def imageFilesSpecTokens_block_63_66 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_63_64 imageFilesSpecTokens_block_64_66
    "         and then Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Input_Name /= Snapshot_Name,\n       Post => (Runtime => (if Plan.Kind = Model.Refine then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'R', 'u', 'n', 't', 'i', 'm', 'e', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', ' ', 't', 'h', 'e', 'n']))

def imageFilesSpecTokens_block_60_66 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_60_63 imageFilesSpecTokens_block_63_66
    "       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Input_Name)\n         and then Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Input_Name /= Snapshot_Name,\n       Post => (Runtime => (if Plan.Kind = Model.Refine then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'R', 'u', 'n', 't', 'i', 'm', 'e', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', ' ', 't', 'h', 'e', 'n']))

def imageFilesSpecTokens_block_55_66 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_55_60 imageFilesSpecTokens_block_60_66
    "\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Input_Name)\n         and then Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Input_Name /= Snapshot_Name,\n       Post => (Runtime => (if Plan.Kind = Model.Refine then"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'R', 'u', 'n', 't', 'i', 'm', 'e', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', ' ', 't', 'h', 'e', 'n']))

def imageFilesSpecTokens_block_44_66 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_44_55 imageFilesSpecTokens_block_55_66
    "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))\n     with Ghost => Static,\n       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;\n\n   --  Observations of successful libc byte operations. These do not add a\n   --  finite input-buffer limit or execute in the adapter binary.\n   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;\n   Rechecked : Model.Plan := (others => <>) with Ghost => Static;\n\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Input_Name)\n         and then Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Input_Name /= Snapshot_Name,\n       Post => (Runtime => (if Plan.Kind = Model.Refine then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'o', 'f', ' ', 's', 'u', 'c', 'c', 'e', 's', 's', 'f', 'u', 'l', ' ', 'l', 'i', 'b', 'c', ' ', 'b', 'y', 't', 'e', ' ', 'o', 'p', 'e', 'r', 'a', 't', 'i', 'o', 'n', 's', '.', ' ', 'T', 'h', 'e', 's', 'e', ' ', 'd', 'o', ' ', 'n', 'o', 't', ' ', 'a', 'd', 'd', ' ', 'a', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'f', 'i', 'n', 'i', 't', 'e', ' ', 'i', 'n', 'p', 'u', 't', '-', 'b', 'u', 'f', 'f', 'e', 'r', ' ', 'l', 'i', 'm', 'i', 't', ' ', 'o', 'r', ' ', 'e', 'x', 'e', 'c', 'u', 't', 'e', ' ', 'i', 'n', ' ', 't', 'h', 'e', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'b', 'i', 'n', 'a', 'r', 'y', '.', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']
      ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'R', 'u', 'n', 't', 'i', 'm', 'e', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', ' ', 't', 'h', 'e', 'n']))

def imageFilesSpecTokens_block_66_67 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_66

def imageFilesSpecTokens_block_67_68 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_67

def imageFilesSpecTokens_block_66_68 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_66_67 imageFilesSpecTokens_block_67_68
    "         Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes),"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ',']))

def imageFilesSpecTokens_block_68_69 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_68

def imageFilesSpecTokens_block_69_70 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_69

def imageFilesSpecTokens_block_70_71 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_70

def imageFilesSpecTokens_block_69_71 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_69_70 imageFilesSpecTokens_block_70_71
    "         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes\n         and then Plan = Rechecked));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', ' ', '=', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ';']))

def imageFilesSpecTokens_block_68_71 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_68_69 imageFilesSpecTokens_block_69_71
    "         Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes\n         and then Plan = Rechecked));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', ' ', '=', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ';']))

def imageFilesSpecTokens_block_66_71 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_66_68 imageFilesSpecTokens_block_68_71
    "         Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes),\n         Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes\n         and then Plan = Rechecked));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', ' ', '=', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ';']))

def imageFilesSpecTokens_block_71_72 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_71

def imageFilesSpecTokens_block_72_73 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_72

def imageFilesSpecTokens_block_73_74 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_73

def imageFilesSpecTokens_block_72_74 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_72_73 imageFilesSpecTokens_block_73_74
    "   procedure Refine\n     (Snapshot_Name, Refined_Name : String;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e']
      [' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';']))

def imageFilesSpecTokens_block_71_74 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_71_72 imageFilesSpecTokens_block_72_74
    "\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';']))

def imageFilesSpecTokens_block_74_75 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_74

def imageFilesSpecTokens_block_75_76 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_75

def imageFilesSpecTokens_block_76_77 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_76

def imageFilesSpecTokens_block_75_77 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_75_76 imageFilesSpecTokens_block_76_77
    "     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',']))

def imageFilesSpecTokens_block_74_77 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_74_75 imageFilesSpecTokens_block_75_77
    "      Plan : Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',']))

def imageFilesSpecTokens_block_71_77 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_71_74 imageFilesSpecTokens_block_74_77
    "\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',']))

def imageFilesSpecTokens_block_66_77 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_66_71 imageFilesSpecTokens_block_71_77
    "         Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes),\n         Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes\n         and then Plan = Rechecked));\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', ' ', '=', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ';']
      ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',']))

def imageFilesSpecTokens_block_77_78 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_77

def imageFilesSpecTokens_block_78_79 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_78

def imageFilesSpecTokens_block_79_80 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_79

def imageFilesSpecTokens_block_78_80 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_78_79 imageFilesSpecTokens_block_79_80
    "       Pre => Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Silver_Platform.Valid_Path (Refined_Name)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')']))

def imageFilesSpecTokens_block_77_80 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_77_78 imageFilesSpecTokens_block_78_80
    "                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Silver_Platform.Valid_Path (Refined_Name)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')']))

def imageFilesSpecTokens_block_80_81 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_80

def imageFilesSpecTokens_block_81_82 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_81

def imageFilesSpecTokens_block_82_83 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_82

def imageFilesSpecTokens_block_81_83 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_81_82 imageFilesSpecTokens_block_82_83
    "         and then Plan.Kind = Model.Refine\n         and then Plan.Declarations_Offset < Plan.Includes_Offset"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't']))

def imageFilesSpecTokens_block_80_83 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_80_81 imageFilesSpecTokens_block_81_83
    "         and then Snapshot_Name /= Refined_Name\n         and then Plan.Kind = Model.Refine\n         and then Plan.Declarations_Offset < Plan.Includes_Offset"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't']))

def imageFilesSpecTokens_block_77_83 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_77_80 imageFilesSpecTokens_block_80_83
    "                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Silver_Platform.Valid_Path (Refined_Name)\n         and then Snapshot_Name /= Refined_Name\n         and then Plan.Kind = Model.Refine\n         and then Plan.Declarations_Offset < Plan.Includes_Offset"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't']))

def imageFilesSpecTokens_block_83_84 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_83

def imageFilesSpecTokens_block_84_85 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_84

def imageFilesSpecTokens_block_85_86 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_85

def imageFilesSpecTokens_block_84_86 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_84_85 imageFilesSpecTokens_block_85_86
    "       Post => (Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n']))

def imageFilesSpecTokens_block_83_86 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_83_84 imageFilesSpecTokens_block_84_86
    "         and then Plan.Includes_Offset < Plan.Bytes,\n       Post => (Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n']))

def imageFilesSpecTokens_block_86_87 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_86

def imageFilesSpecTokens_block_87_88 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_87

def imageFilesSpecTokens_block_88_89 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesSpecTokens_line_88

def imageFilesSpecTokens_block_87_89 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_87_88 imageFilesSpecTokens_block_88_89
    "end Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';']
      []))

def imageFilesSpecTokens_block_86_89 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_86_87 imageFilesSpecTokens_block_87_89
    "         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ')', ')', ';']
      ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesSpecTokens_block_83_89 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_83_86 imageFilesSpecTokens_block_86_89
    "         and then Plan.Includes_Offset < Plan.Bytes,\n       Post => (Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan\n         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesSpecTokens_block_77_89 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_77_83 imageFilesSpecTokens_block_83_89
    "                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Silver_Platform.Valid_Path (Refined_Name)\n         and then Snapshot_Name /= Refined_Name\n         and then Plan.Kind = Model.Refine\n         and then Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes,\n       Post => (Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan\n         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesSpecTokens_block_66_89 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_66_77 imageFilesSpecTokens_block_77_89
    "         Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes),\n         Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes\n         and then Plan = Rechecked));\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Silver_Platform.Valid_Path (Refined_Name)\n         and then Snapshot_Name /= Refined_Name\n         and then Plan.Kind = Model.Refine\n         and then Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes,\n       Post => (Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan\n         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', ' ', '=', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesSpecTokens_block_44_89 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_44_66 imageFilesSpecTokens_block_66_89
    "            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))\n     with Ghost => Static,\n       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;\n\n   --  Observations of successful libc byte operations. These do not add a\n   --  finite input-buffer limit or execute in the adapter binary.\n   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;\n   Rechecked : Model.Plan := (others => <>) with Ghost => Static;\n\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Input_Name)\n         and then Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Input_Name /= Snapshot_Name,\n       Post => (Runtime => (if Plan.Kind = Model.Refine then\n         Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes),\n         Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes\n         and then Plan = Rechecked));\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Silver_Platform.Valid_Path (Refined_Name)\n         and then Snapshot_Name /= Refined_Name\n         and then Plan.Kind = Model.Refine\n         and then Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes,\n       Post => (Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan\n         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'o', 'f', ' ', 's', 'u', 'c', 'c', 'e', 's', 's', 'f', 'u', 'l', ' ', 'l', 'i', 'b', 'c', ' ', 'b', 'y', 't', 'e', ' ', 'o', 'p', 'e', 'r', 'a', 't', 'i', 'o', 'n', 's', '.', ' ', 'T', 'h', 'e', 's', 'e', ' ', 'd', 'o', ' ', 'n', 'o', 't', ' ', 'a', 'd', 'd', ' ', 'a', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'f', 'i', 'n', 'i', 't', 'e', ' ', 'i', 'n', 'p', 'u', 't', '-', 'b', 'u', 'f', 'f', 'e', 'r', ' ', 'l', 'i', 'm', 'i', 't', ' ', 'o', 'r', ' ', 'e', 'x', 'e', 'c', 'u', 't', 'e', ' ', 'i', 'n', ' ', 't', 'h', 'e', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'b', 'i', 'n', 'a', 'r', 'y', '.', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'R', 'u', 'n', 't', 'i', 'm', 'e', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', ' ', '=', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesSpecTokens_block_0_89 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesSpecTokens_block_0_44 imageFilesSpecTokens_block_44_89
    "with Ada.Text_IO;\nwith SPARK.Big_Integers;\nwith SPARK.Containers.Functional.Infinite_Sequences;\nwith Silver_Image_Model;\nwith Silver_Platform;\n\npackage Silver_Image_Files with SPARK_Mode => On is\n   package Model renames Silver_Image_Model;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use type Model.Byte_Count;\n   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences\n     (Element_Type => Character, Use_Logical_Equality => True);\n   use type Bytes.Sequence;\n   use SPARK.Big_Integers;\n   package Counts is new Signed_Conversions (Model.Byte_Count);\n\n   --  Exact byte-level splice, stated independently of the streaming loop.\n   --  Count is the number of original bytes already copied. A fragment is\n   --  present once the byte at its zero-based insertion offset was copied.\n   function Spliced_Prefix\n     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;\n      Count : Model.Byte_Count) return Boolean is\n     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)\n      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)\n        + (if Count > Plan.Declarations_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)\n        + (if Count > Plan.Includes_Offset then\n             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)\n      and then (for all I in Model.Byte_Count range 1 .. Count =>\n        Bytes.Get (Refined, Counts.To_Big_Integer (I)\n          + (if I > Plan.Declarations_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)\n          + (if I > Plan.Includes_Offset then\n               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))\n        = Bytes.Get (Original, Counts.To_Big_Integer (I)))\n      and then (if Count > Plan.Declarations_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)\n            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))\n      and then (if Count > Plan.Includes_Offset then\n        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>\n          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)\n            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))\n            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))\n     with Ghost => Static,\n       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;\n\n   --  Observations of successful libc byte operations. These do not add a\n   --  finite input-buffer limit or execute in the adapter binary.\n   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;\n   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;\n   Rechecked : Model.Plan := (others => <>) with Ghost => Static;\n\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Input_Name)\n         and then Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Input_Name /= Snapshot_Name,\n       Post => (Runtime => (if Plan.Kind = Model.Refine then\n         Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes),\n         Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes\n         and then Plan = Rechecked));\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n     with Global => (In_Out => Ada.Text_IO.File_System,\n       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,\n                  Files_Closed, Rechecked)),\n       Pre => Silver_Platform.Valid_Path (Snapshot_Name)\n         and then Silver_Platform.Valid_Path (Refined_Name)\n         and then Snapshot_Name /= Refined_Name\n         and then Plan.Kind = Model.Refine\n         and then Plan.Declarations_Offset < Plan.Includes_Offset\n         and then Plan.Includes_Offset < Plan.Bytes,\n       Post => (Static => (if Success then Read_Ended and then Files_Closed\n         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan\n         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'M', 'o', 'd', 'e', 'l', ' ', 'r', 'e', 'n', 'a', 'm', 'e', 's', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'B', 'y', 't', 'e', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'C', 'o', 'n', 't', 'a', 'i', 'n', 'e', 'r', 's', '.', 'F', 'u', 'n', 'c', 't', 'i', 'o', 'n', 'a', 'l', '.', 'I', 'n', 'f', 'i', 'n', 'i', 't', 'e', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'E', 'l', 'e', 'm', 'e', 'n', 't', '_', 'T', 'y', 'p', 'e', ' ', '=', '>', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ',', ' ', 'U', 's', 'e', '_', 'L', 'o', 'g', 'i', 'c', 'a', 'l', '_', 'E', 'q', 'u', 'a', 'l', 'i', 't', 'y', ' ', '=', '>', ' ', 'T', 'r', 'u', 'e', ')', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'P', 'A', 'R', 'K', '.', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', 's', ';', '\n', ' ', ' ', ' ', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'C', 'o', 'u', 'n', 't', 's', ' ', 'i', 's', ' ', 'n', 'e', 'w', ' ', 'S', 'i', 'g', 'n', 'e', 'd', '_', 'C', 'o', 'n', 'v', 'e', 'r', 's', 'i', 'o', 'n', 's', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'a', 'c', 't', ' ', 'b', 'y', 't', 'e', '-', 'l', 'e', 'v', 'e', 'l', ' ', 's', 'p', 'l', 'i', 'c', 'e', ',', ' ', 's', 't', 'a', 't', 'e', 'd', ' ', 'i', 'n', 'd', 'e', 'p', 'e', 'n', 'd', 'e', 'n', 't', 'l', 'y', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 's', 't', 'r', 'e', 'a', 'm', 'i', 'n', 'g', ' ', 'l', 'o', 'o', 'p', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', 'i', 's', ' ', 't', 'h', 'e', ' ', 'n', 'u', 'm', 'b', 'e', 'r', ' ', 'o', 'f', ' ', 'o', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ' ', 'b', 'y', 't', 'e', 's', ' ', 'a', 'l', 'r', 'e', 'a', 'd', 'y', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', ' ', 'A', ' ', 'f', 'r', 'a', 'g', 'm', 'e', 'n', 't', ' ', 'i', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'p', 'r', 'e', 's', 'e', 'n', 't', ' ', 'o', 'n', 'c', 'e', ' ', 't', 'h', 'e', ' ', 'b', 'y', 't', 'e', ' ', 'a', 't', ' ', 'i', 't', 's', ' ', 'z', 'e', 'r', 'o', '-', 'b', 'a', 's', 'e', 'd', ' ', 'i', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', 'o', 'f', 'f', 's', 'e', 't', ' ', 'w', 'a', 's', ' ', 'c', 'o', 'p', 'i', 'e', 'd', '.', '\n', ' ', ' ', ' ', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'u', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ')', ' ', 'r', 'e', 't', 'u', 'r', 'n', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ')', ' ', '=', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'C', 'o', 'u', 'n', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', 'r', 'a', 'n', 'g', 'e', ' ', '1', ' ', '.', '.', ' ', 'C', 'o', 'u', 'n', 't', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', '(', 'i', 'f', ' ', 'I', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')', ' ', 'e', 'l', 's', 'e', ' ', '0', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'O', 'r', 'i', 'g', 'i', 'n', 'a', 'l', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'i', 'f', ' ', 'C', 'o', 'u', 'n', 't', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', ',', ' ', 'C', 'o', 'u', 'n', 't', 's', '.', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ')', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ';', '\n', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'o', 'f', ' ', 's', 'u', 'c', 'c', 'e', 's', 's', 'f', 'u', 'l', ' ', 'l', 'i', 'b', 'c', ' ', 'b', 'y', 't', 'e', ' ', 'o', 'p', 'e', 'r', 'a', 't', 'i', 'o', 'n', 's', '.', ' ', 'T', 'h', 'e', 's', 'e', ' ', 'd', 'o', ' ', 'n', 'o', 't', ' ', 'a', 'd', 'd', ' ', 'a', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'f', 'i', 'n', 'i', 't', 'e', ' ', 'i', 'n', 'p', 'u', 't', '-', 'b', 'u', 'f', 'f', 'e', 'r', ' ', 'l', 'i', 'm', 'i', 't', ' ', 'o', 'r', ' ', 'e', 'x', 'e', 'c', 'u', 't', 'e', ' ', 'i', 'n', ' ', 't', 'h', 'e', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'b', 'i', 'n', 'a', 'r', 'y', '.', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'R', 'u', 'n', 't', 'i', 'm', 'e', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', ' ', '=', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'r', 'e', ' ', '=', '>', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'P', 'l', 'a', 't', 'f', 'o', 'r', 'm', '.', 'V', 'a', 'l', 'i', 'd', '_', 'P', 'a', 't', 'h', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', '/', '=', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', '<', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', ')', ')', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesSpecTokens_certificates : List LineCertificate :=
  imageFilesSpecTokens_block_0_89.lines

def imageFilesSpecTokens : Tokens :=
  ["with", "ada", ".", "text_io", ";", "with", "spark", ".", "big_integers", ";", "with", "spark", ".", "containers", ".", "functional", ".", "infinite_sequences", ";", "with", "silver_image_model", ";", "with", "silver_platform", ";", "package", "silver_image_files", "with", "spark_mode", "=>", "on", "is", "package", "model", "renames", "silver_image_model", ";", "use", "type", "model", ".", "plan", ";", "use", "type", "model", ".", "plan_kind", ";", "use", "type", "model", ".", "byte_count", ";", "package", "bytes", "is", "new", "spark", ".", "containers", ".", "functional", ".", "infinite_sequences", "(", "element_type", "=>", "character", ",", "use_logical_equality", "=>", "true", ")", ";", "use", "type", "bytes", ".", "sequence", ";", "use", "spark", ".", "big_integers", ";", "package", "counts", "is", "new", "signed_conversions", "(", "model", ".", "byte_count", ")", ";", "function", "spliced_prefix", "(", "original", ",", "refined", ":", "bytes", ".", "sequence", ";", "plan", ":", "model", ".", "plan", ";", "count", ":", "model", ".", "byte_count", ")", "return", "boolean", "is", "(", "bytes", ".", "length", "(", "original", ")", "=", "counts", ".", "to_big_integer", "(", "count", ")", "and", "then", "bytes", ".", "length", "(", "refined", ")", "=", "counts", ".", "to_big_integer", "(", "count", ")", "+", "(", "if", "count", ">", "plan", ".", "declarations_offset", "then", "to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", ")", "else", "0", ")", "+", "(", "if", "count", ">", "plan", ".", "includes_offset", "then", "to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "includes_insertion", ")", ")", "else", "0", ")", "and", "then", "(", "for", "all", "i", "in", "model", ".", "byte_count", "range", "1", "..", "count", "=>", "bytes", ".", "get", "(", "refined", ",", "counts", ".", "to_big_integer", "(", "i", ")", "+", "(", "if", "i", ">", "plan", ".", "declarations_offset", "then", "to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", ")", "else", "0", ")", "+", "(", "if", "i", ">", "plan", ".", "includes_offset", "then", "to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "includes_insertion", ")", ")", "else", "0", ")", ")", "=", "bytes", ".", "get", "(", "original", ",", "counts", ".", "to_big_integer", "(", "i", ")", ")", ")", "and", "then", "(", "if", "count", ">", "plan", ".", "declarations_offset", "then", "(", "for", "all", "i", "in", "1", "..", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", "=>", "bytes", ".", "get", "(", "refined", ",", "counts", ".", "to_big_integer", "(", "plan", ".", "declarations_offset", ")", "+", "to_big_integer", "(", "i", ")", ")", "=", "model", ".", "insertion_byte", "(", "model", ".", "declarations_insertion", ",", "i", ")", ")", ")", "and", "then", "(", "if", "count", ">", "plan", ".", "includes_offset", "then", "(", "for", "all", "i", "in", "1", "..", "model", ".", "insertion_length", "(", "model", ".", "includes_insertion", ")", "=>", "bytes", ".", "get", "(", "refined", ",", "counts", ".", "to_big_integer", "(", "plan", ".", "includes_offset", ")", "+", "to_big_integer", "(", "model", ".", "insertion_length", "(", "model", ".", "declarations_insertion", ")", ")", "+", "to_big_integer", "(", "i", ")", ")", "=", "model", ".", "insertion_byte", "(", "model", ".", "includes_insertion", ",", "i", ")", ")", ")", ")", "with", "ghost", "=>", "static", ",", "pre", "=>", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset", ";", "read_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";", "copied_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";", "written_bytes", ":", "bytes", ".", "sequence", ":=", "bytes", ".", "empty_sequence", "with", "ghost", "=>", "static", ";", "read_ended", ",", "files_closed", ":", "boolean", ":=", "false", "with", "ghost", "=>", "static", ";", "rechecked", ":", "model", ".", "plan", ":=", "(", "others", "=>", "<", ">", ")", "with", "ghost", "=>", "static", ";", "procedure", "snapshot", "(", "input_name", ",", "snapshot_name", ":", "string", ";", "plan", ":", "out", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "with", "global", "=>", "(", "in_out", "=>", "ada", ".", "text_io", ".", "file_system", ",", "output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ",", "read_ended", ",", "files_closed", ",", "rechecked", ")", ")", ",", "pre", "=>", "silver_platform", ".", "valid_path", "(", "input_name", ")", "and", "then", "silver_platform", ".", "valid_path", "(", "snapshot_name", ")", "and", "then", "input_name", "/=", "snapshot_name", ",", "post", "=>", "(", "runtime", "=>", "(", "if", "plan", ".", "kind", "=", "model", ".", "refine", "then", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset", "and", "then", "plan", ".", "includes_offset", "<", "plan", ".", "bytes", ")", ",", "static", "=>", "(", "if", "success", "then", "read_ended", "and", "then", "files_closed", "and", "then", "read_bytes", "=", "copied_bytes", "and", "then", "read_bytes", "=", "written_bytes", "and", "then", "plan", "=", "rechecked", ")", ")", ";", "procedure", "refine", "(", "snapshot_name", ",", "refined_name", ":", "string", ";", "plan", ":", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "with", "global", "=>", "(", "in_out", "=>", "ada", ".", "text_io", ".", "file_system", ",", "output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ",", "read_ended", ",", "files_closed", ",", "rechecked", ")", ")", ",", "pre", "=>", "silver_platform", ".", "valid_path", "(", "snapshot_name", ")", "and", "then", "silver_platform", ".", "valid_path", "(", "refined_name", ")", "and", "then", "snapshot_name", "/=", "refined_name", "and", "then", "plan", ".", "kind", "=", "model", ".", "refine", "and", "then", "plan", ".", "declarations_offset", "<", "plan", ".", "includes_offset", "and", "then", "plan", ".", "includes_offset", "<", "plan", ".", "bytes", ",", "post", "=>", "(", "static", "=>", "(", "if", "success", "then", "read_ended", "and", "then", "files_closed", "and", "then", "read_bytes", "=", "copied_bytes", "and", "then", "rechecked", "=", "plan", "and", "then", "spliced_prefix", "(", "read_bytes", ",", "written_bytes", ",", "plan", ",", "plan", ".", "bytes", ")", ")", ")", ";", "end", "silver_image_files", ";"]

theorem imageFilesSpecTokens_source :
    String.intercalate "\n" (imageFilesSpecTokens_certificates.map (·.text)) = imageFilesSpec := by
  exact imageFilesSpecTokens_block_0_89.correct

theorem imageFilesSpecTokens_values :
    imageFilesSpecTokens_certificates.flatMap (·.tokens) = imageFilesSpecTokens := by rfl

theorem imageFilesSpecTokens_correct : lex imageFilesSpec = some imageFilesSpecTokens := by
  rw [← imageFilesSpecTokens_source, reconstructed_source_lex imageFilesSpecTokens_certificates
    imageFilesSpecTokens_block_0_89.nonempty]
  rw [imageFilesSpecTokens_values]

def imageFilesBodyTokens_line_0 : LineCertificate where
  text := "with Interfaces.C;"
  tokens := ["with", "interfaces", ".", "c", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_1 : LineCertificate where
  text := "with System;"
  tokens := ["with", "system", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_2 : LineCertificate where
  text := "with Silver_Libc;"
  tokens := ["with", "silver_libc", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_3 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_4 : LineCertificate where
  text := "package body Silver_Image_Files with SPARK_Mode => On is"
  tokens := ["package", "body", "silver_image_files", "with", "spark_mode", "=>", "on", "is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_5 : LineCertificate where
  text := "   use type Interfaces.C.int;"
  tokens := ["use", "type", "interfaces", ".", "c", ".", "int", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_6 : LineCertificate where
  text := "   use type System.Address;"
  tokens := ["use", "type", "system", ".", "address", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_7 : LineCertificate where
  text := "   use type Model.Byte_Count;"
  tokens := ["use", "type", "model", ".", "byte_count", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_8 : LineCertificate where
  text := "   use type Model.Plan;"
  tokens := ["use", "type", "model", ".", "plan", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_9 : LineCertificate where
  text := "   use type Model.Plan_Kind;"
  tokens := ["use", "type", "model", ".", "plan_kind", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_10 : LineCertificate where
  text := "   use Silver_Libc;"
  tokens := ["use", "silver_libc", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_11 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_12 : LineCertificate where
  text := "   procedure Reset_Observations"
  tokens := ["procedure", "reset_observations"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_13 : LineCertificate where
  text := "     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,"
  tokens := ["with", "global", "=>", "(", "output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_14 : LineCertificate where
  text := "       Read_Ended, Files_Closed, Rechecked)),"
  tokens := ["read_ended", ",", "files_closed", ",", "rechecked", ")", ")", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_15 : LineCertificate where
  text := "       Post => (Static => Read_Bytes = Copied_Bytes"
  tokens := ["post", "=>", "(", "static", "=>", "read_bytes", "=", "copied_bytes"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_16 : LineCertificate where
  text := "         and then Read_Bytes = Written_Bytes"
  tokens := ["and", "then", "read_bytes", "=", "written_bytes"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_17 : LineCertificate where
  text := "         and then Bytes.Length (Read_Bytes) = 0)"
  tokens := ["and", "then", "bytes", ".", "length", "(", "read_bytes", ")", "=", "0", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_18 : LineCertificate where
  text := "   is"
  tokens := ["is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_19 : LineCertificate where
  text := "   begin"
  tokens := ["begin"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_20 : LineCertificate where
  text := "      Read_Bytes := Bytes.Empty_Sequence;"
  tokens := ["read_bytes", ":=", "bytes", ".", "empty_sequence", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_21 : LineCertificate where
  text := "      Copied_Bytes := Bytes.Empty_Sequence;"
  tokens := ["copied_bytes", ":=", "bytes", ".", "empty_sequence", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_22 : LineCertificate where
  text := "      Written_Bytes := Bytes.Empty_Sequence;"
  tokens := ["written_bytes", ":=", "bytes", ".", "empty_sequence", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_23 : LineCertificate where
  text := "      Read_Ended := False;"
  tokens := ["read_ended", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_24 : LineCertificate where
  text := "      Files_Closed := False;"
  tokens := ["files_closed", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_25 : LineCertificate where
  text := "      Rechecked := (others => <>);"
  tokens := ["rechecked", ":=", "(", "others", "=>", "<", ">", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_26 : LineCertificate where
  text := "   end Reset_Observations;"
  tokens := ["end", "reset_observations", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_27 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_28 : LineCertificate where
  text := "   procedure Put_Byte"
  tokens := ["procedure", "put_byte"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_29 : LineCertificate where
  text := "     (File : System.Address; Item : Character; Success : out Boolean)"
  tokens := ["(", "file", ":", "system", ".", "address", ";", "item", ":", "character", ";", "success", ":", "out", "boolean", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_30 : LineCertificate where
  text := "     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),"
  tokens := ["with", "global", "=>", "(", "in_out", "=>", "(", "ada", ".", "text_io", ".", "file_system", ",", "written_bytes", ")", ")", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_31 : LineCertificate where
  text := "       Post => (Static => (if Success then"
  tokens := ["post", "=>", "(", "static", "=>", "(", "if", "success", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_32 : LineCertificate where
  text := "         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))"
  tokens := ["written_bytes", "=", "bytes", ".", "add", "(", "written_bytes", "'", "old", ",", "item", ")", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_33 : LineCertificate where
  text := "   is"
  tokens := ["is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_34 : LineCertificate where
  text := "      Status : Interfaces.C.int;"
  tokens := ["status", ":", "interfaces", ".", "c", ".", "int", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_35 : LineCertificate where
  text := "   begin"
  tokens := ["begin"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_36 : LineCertificate where
  text := "      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);"
  tokens := ["status", ":=", "c_put", "(", "interfaces", ".", "c", ".", "int", "(", "character", "'", "pos", "(", "item", ")", ")", ",", "file", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_37 : LineCertificate where
  text := "      Success := Status = Interfaces.C.int (Character'Pos (Item));"
  tokens := ["success", ":=", "status", "=", "interfaces", ".", "c", ".", "int", "(", "character", "'", "pos", "(", "item", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_38 : LineCertificate where
  text := "      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;"
  tokens := ["if", "success", "then", "written_bytes", ":=", "bytes", ".", "add", "(", "written_bytes", ",", "item", ")", ";", "end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_39 : LineCertificate where
  text := "   end Put_Byte;"
  tokens := ["end", "put_byte", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_40 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_41 : LineCertificate where
  text := "   procedure Put_Insertion"
  tokens := ["procedure", "put_insertion"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_42 : LineCertificate where
  text := "     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)"
  tokens := ["(", "file", ":", "system", ".", "address", ";", "kind", ":", "model", ".", "insertion_kind", ";", "success", ":", "out", "boolean", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_43 : LineCertificate where
  text := "     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),"
  tokens := ["with", "global", "=>", "(", "in_out", "=>", "(", "ada", ".", "text_io", ".", "file_system", ",", "written_bytes", ")", ")", ","]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_44 : LineCertificate where
  text := "       Post => (Static => (if Success then"
  tokens := ["post", "=>", "(", "static", "=>", "(", "if", "success", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_45 : LineCertificate where
  text := "         Written_Bytes'Old <= Written_Bytes"
  tokens := ["written_bytes", "'", "old", "<=", "written_bytes"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_46 : LineCertificate where
  text := "         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)"
  tokens := ["and", "then", "bytes", ".", "length", "(", "written_bytes", ")", "=", "bytes", ".", "length", "(", "written_bytes", "'", "old", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_47 : LineCertificate where
  text := "           + To_Big_Integer (Model.Insertion_Length (Kind))"
  tokens := ["+", "to_big_integer", "(", "model", ".", "insertion_length", "(", "kind", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_48 : LineCertificate where
  text := "         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>"
  tokens := ["and", "then", "(", "for", "all", "i", "in", "1", "..", "model", ".", "insertion_length", "(", "kind", ")", "=>"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_49 : LineCertificate where
  text := "           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)"
  tokens := ["bytes", ".", "get", "(", "written_bytes", ",", "bytes", ".", "length", "(", "written_bytes", "'", "old", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_50 : LineCertificate where
  text := "             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))"
  tokens := ["+", "to_big_integer", "(", "i", ")", ")", "=", "model", ".", "insertion_byte", "(", "kind", ",", "i", ")", ")", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_51 : LineCertificate where
  text := "   is"
  tokens := ["is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_52 : LineCertificate where
  text := "      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;"
  tokens := ["before", ":", "constant", "bytes", ".", "sequence", ":=", "written_bytes", "with", "ghost", "=>", "static", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_53 : LineCertificate where
  text := "   begin"
  tokens := ["begin"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_54 : LineCertificate where
  text := "      Success := True;"
  tokens := ["success", ":=", "true", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_55 : LineCertificate where
  text := "      for Position in 1 .. Model.Insertion_Length (Kind) loop"
  tokens := ["for", "position", "in", "1", "..", "model", ".", "insertion_length", "(", "kind", ")", "loop"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_56 : LineCertificate where
  text := "         pragma Loop_Invariant (Static => Before <= Written_Bytes);"
  tokens := ["pragma", "loop_invariant", "(", "static", "=>", "before", "<=", "written_bytes", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_57 : LineCertificate where
  text := "         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)"
  tokens := ["pragma", "loop_invariant", "(", "static", "=>", "bytes", ".", "length", "(", "written_bytes", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_58 : LineCertificate where
  text := "           = Bytes.Length (Before) + To_Big_Integer (Position - 1));"
  tokens := ["=", "bytes", ".", "length", "(", "before", ")", "+", "to_big_integer", "(", "position", "-", "1", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_59 : LineCertificate where
  text := "         pragma Loop_Invariant (Static =>"
  tokens := ["pragma", "loop_invariant", "(", "static", "=>"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_60 : LineCertificate where
  text := "           (for all I in 1 .. Position - 1 =>"
  tokens := ["(", "for", "all", "i", "in", "1", "..", "position", "-", "1", "=>"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_61 : LineCertificate where
  text := "             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))"
  tokens := ["bytes", ".", "get", "(", "written_bytes", ",", "bytes", ".", "length", "(", "before", ")", "+", "to_big_integer", "(", "i", ")", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_62 : LineCertificate where
  text := "               = Model.Insertion_Byte (Kind, I)));"
  tokens := ["=", "model", ".", "insertion_byte", "(", "kind", ",", "i", ")", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_63 : LineCertificate where
  text := "         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);"
  tokens := ["put_byte", "(", "file", ",", "model", ".", "insertion_byte", "(", "kind", ",", "position", ")", ",", "success", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_64 : LineCertificate where
  text := "         exit when not Success;"
  tokens := ["exit", "when", "not", "success", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_65 : LineCertificate where
  text := "      end loop;"
  tokens := ["end", "loop", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_66 : LineCertificate where
  text := "   end Put_Insertion;"
  tokens := ["end", "put_insertion", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_67 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_68 : LineCertificate where
  text := "   procedure Snapshot"
  tokens := ["procedure", "snapshot"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_69 : LineCertificate where
  text := "     (Input_Name, Snapshot_Name : String;"
  tokens := ["(", "input_name", ",", "snapshot_name", ":", "string", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_70 : LineCertificate where
  text := "      Plan : out Model.Plan; Success : out Boolean)"
  tokens := ["plan", ":", "out", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_71 : LineCertificate where
  text := "   is"
  tokens := ["is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_72 : LineCertificate where
  text := "      Input, Output : System.Address;"
  tokens := ["input", ",", "output", ":", "system", ".", "address", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_73 : LineCertificate where
  text := "      Item, Status : Interfaces.C.int;"
  tokens := ["item", ",", "status", ":", "interfaces", ".", "c", ".", "int", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_74 : LineCertificate where
  text := "      Current : Model.State := Model.Initial_State;"
  tokens := ["current", ":", "model", ".", "state", ":=", "model", ".", "initial_state", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_75 : LineCertificate where
  text := "   begin"
  tokens := ["begin"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_76 : LineCertificate where
  text := "      Plan := (others => <>);"
  tokens := ["plan", ":=", "(", "others", "=>", "<", ">", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_77 : LineCertificate where
  text := "      Success := False;"
  tokens := ["success", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_78 : LineCertificate where
  text := "      Reset_Observations;"
  tokens := ["reset_observations", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_79 : LineCertificate where
  text := "      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));"
  tokens := ["input", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "input_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"rb\"", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_80 : LineCertificate where
  text := "      if Input = System.Null_Address then return; end if;"
  tokens := ["if", "input", "=", "system", ".", "null_address", "then", "return", ";", "end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_81 : LineCertificate where
  text := "      --  Exclusive creation keeps retained observations from being overwritten."
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_82 : LineCertificate where
  text := "      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));"
  tokens := ["output", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "snapshot_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"wbx\"", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_83 : LineCertificate where
  text := "      if Output = System.Null_Address then"
  tokens := ["if", "output", "=", "system", ".", "null_address", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_84 : LineCertificate where
  text := "         Status := C_Close (Input);"
  tokens := ["status", ":=", "c_close", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_85 : LineCertificate where
  text := "         Files_Closed := Status = 0;"
  tokens := ["files_closed", ":=", "status", "=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_86 : LineCertificate where
  text := "         return;"
  tokens := ["return", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_87 : LineCertificate where
  text := "      end if;"
  tokens := ["end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_88 : LineCertificate where
  text := "      loop"
  tokens := ["loop"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_89 : LineCertificate where
  text := "         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);"
  tokens := ["pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "copied_bytes", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_90 : LineCertificate where
  text := "         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
  tokens := ["pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "written_bytes", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_91 : LineCertificate where
  text := "         Item := C_Get (Input);"
  tokens := ["item", ":=", "c_get", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_92 : LineCertificate where
  text := "         if Item = -1 then"
  tokens := ["if", "item", "=", "-", "1", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_93 : LineCertificate where
  text := "            Read_Ended := True;"
  tokens := ["read_ended", ":=", "true", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_94 : LineCertificate where
  text := "            Status := C_Error (Input);"
  tokens := ["status", ":=", "c_error", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_95 : LineCertificate where
  text := "            Success := Status = 0;"
  tokens := ["success", ":=", "status", "=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_96 : LineCertificate where
  text := "            exit;"
  tokens := ["exit", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_97 : LineCertificate where
  text := "         elsif Item not in 0 .. 255 then"
  tokens := ["elsif", "item", "not", "in", "0", "..", "255", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_98 : LineCertificate where
  text := "            Success := False;"
  tokens := ["success", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_99 : LineCertificate where
  text := "            exit;"
  tokens := ["exit", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_100 : LineCertificate where
  text := "         end if;"
  tokens := ["end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_101 : LineCertificate where
  text := "         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));"
  tokens := ["read_bytes", ":=", "bytes", ".", "add", "(", "read_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_102 : LineCertificate where
  text := "         Model.Consume (Current, Character'Val (Item));"
  tokens := ["model", ".", "consume", "(", "current", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_103 : LineCertificate where
  text := "         Put_Byte (Output, Character'Val (Item), Success);"
  tokens := ["put_byte", "(", "output", ",", "character", "'", "val", "(", "item", ")", ",", "success", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_104 : LineCertificate where
  text := "         if not Success then exit; end if;"
  tokens := ["if", "not", "success", "then", "exit", ";", "end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_105 : LineCertificate where
  text := "         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));"
  tokens := ["copied_bytes", ":=", "bytes", ".", "add", "(", "copied_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_106 : LineCertificate where
  text := "      end loop;"
  tokens := ["end", "loop", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_107 : LineCertificate where
  text := "      Status := C_Close (Input);"
  tokens := ["status", ":=", "c_close", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_108 : LineCertificate where
  text := "      Success := Success and then Status = 0;"
  tokens := ["success", ":=", "success", "and", "then", "status", "=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_109 : LineCertificate where
  text := "      Status := C_Close (Output);"
  tokens := ["status", ":=", "c_close", "(", "output", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_110 : LineCertificate where
  text := "      Files_Closed := Status = 0 and then Success;"
  tokens := ["files_closed", ":=", "status", "=", "0", "and", "then", "success", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_111 : LineCertificate where
  text := "      Success := Success and then Status = 0;"
  tokens := ["success", ":=", "success", "and", "then", "status", "=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_112 : LineCertificate where
  text := "      Plan := Model.Finish (Current);"
  tokens := ["plan", ":=", "model", ".", "finish", "(", "current", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_113 : LineCertificate where
  text := "      Rechecked := Plan;"
  tokens := ["rechecked", ":=", "plan", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_114 : LineCertificate where
  text := "      Success := Success and then Plan.Kind /= Model.Invalid_Model;"
  tokens := ["success", ":=", "success", "and", "then", "plan", ".", "kind", "/=", "model", ".", "invalid_model", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_115 : LineCertificate where
  text := "   end Snapshot;"
  tokens := ["end", "snapshot", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_116 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_117 : LineCertificate where
  text := "   procedure Refine"
  tokens := ["procedure", "refine"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_118 : LineCertificate where
  text := "     (Snapshot_Name, Refined_Name : String;"
  tokens := ["(", "snapshot_name", ",", "refined_name", ":", "string", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_119 : LineCertificate where
  text := "      Plan : Model.Plan; Success : out Boolean)"
  tokens := ["plan", ":", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_120 : LineCertificate where
  text := "   is"
  tokens := ["is"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_121 : LineCertificate where
  text := "      Input, Output : System.Address;"
  tokens := ["input", ",", "output", ":", "system", ".", "address", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_122 : LineCertificate where
  text := "      Item, Status : Interfaces.C.int;"
  tokens := ["item", ",", "status", ":", "interfaces", ".", "c", ".", "int", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_123 : LineCertificate where
  text := "      Current : Model.State := Model.Initial_State;"
  tokens := ["current", ":", "model", ".", "state", ":=", "model", ".", "initial_state", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_124 : LineCertificate where
  text := "      Position : Model.Byte_Count := 0;"
  tokens := ["position", ":", "model", ".", "byte_count", ":=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_125 : LineCertificate where
  text := "      Declarations_Done, Includes_Done : Boolean := False;"
  tokens := ["declarations_done", ",", "includes_done", ":", "boolean", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_126 : LineCertificate where
  text := "      Checked : Model.Plan;"
  tokens := ["checked", ":", "model", ".", "plan", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_127 : LineCertificate where
  text := "   begin"
  tokens := ["begin"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_128 : LineCertificate where
  text := "      Success := False;"
  tokens := ["success", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_129 : LineCertificate where
  text := "      Reset_Observations;"
  tokens := ["reset_observations", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_130 : LineCertificate where
  text := "      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));"
  tokens := ["input", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "snapshot_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"rb\"", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_131 : LineCertificate where
  text := "      if Input = System.Null_Address then return; end if;"
  tokens := ["if", "input", "=", "system", ".", "null_address", "then", "return", ";", "end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_132 : LineCertificate where
  text := "      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));"
  tokens := ["output", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "refined_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"wbx\"", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_133 : LineCertificate where
  text := "      if Output = System.Null_Address then"
  tokens := ["if", "output", "=", "system", ".", "null_address", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_134 : LineCertificate where
  text := "         Status := C_Close (Input);"
  tokens := ["status", ":=", "c_close", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_135 : LineCertificate where
  text := "         Files_Closed := Status = 0;"
  tokens := ["files_closed", ":=", "status", "=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_136 : LineCertificate where
  text := "         return;"
  tokens := ["return", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_137 : LineCertificate where
  text := "      end if;"
  tokens := ["end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_138 : LineCertificate where
  text := "      loop"
  tokens := ["loop"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_139 : LineCertificate where
  text := "         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);"
  tokens := ["pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "copied_bytes", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_140 : LineCertificate where
  text := "         pragma Loop_Invariant (Static =>"
  tokens := ["pragma", "loop_invariant", "(", "static", "=>"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_141 : LineCertificate where
  text := "           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));"
  tokens := ["spliced_prefix", "(", "read_bytes", ",", "written_bytes", ",", "plan", ",", "position", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_142 : LineCertificate where
  text := "         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));"
  tokens := ["pragma", "loop_invariant", "(", "declarations_done", "=", "(", "position", ">", "plan", ".", "declarations_offset", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_143 : LineCertificate where
  text := "         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));"
  tokens := ["pragma", "loop_invariant", "(", "includes_done", "=", "(", "position", ">", "plan", ".", "includes_offset", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_144 : LineCertificate where
  text := "         Item := C_Get (Input);"
  tokens := ["item", ":=", "c_get", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_145 : LineCertificate where
  text := "         if Item = -1 then"
  tokens := ["if", "item", "=", "-", "1", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_146 : LineCertificate where
  text := "            Read_Ended := True;"
  tokens := ["read_ended", ":=", "true", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_147 : LineCertificate where
  text := "            Status := C_Error (Input);"
  tokens := ["status", ":=", "c_error", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_148 : LineCertificate where
  text := "            Success := Status = 0 and then Position = Plan.Bytes"
  tokens := ["success", ":=", "status", "=", "0", "and", "then", "position", "=", "plan", ".", "bytes"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_149 : LineCertificate where
  text := "              and then Declarations_Done and then Includes_Done;"
  tokens := ["and", "then", "declarations_done", "and", "then", "includes_done", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_150 : LineCertificate where
  text := "            exit;"
  tokens := ["exit", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_151 : LineCertificate where
  text := "         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then"
  tokens := ["elsif", "item", "not", "in", "0", "..", "255", "or", "else", "position", "=", "model", ".", "byte_count", "'", "last", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_152 : LineCertificate where
  text := "            Success := False;"
  tokens := ["success", ":=", "false", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_153 : LineCertificate where
  text := "            exit;"
  tokens := ["exit", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_154 : LineCertificate where
  text := "         end if;"
  tokens := ["end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_155 : LineCertificate where
  text := "         if Position = Plan.Declarations_Offset then"
  tokens := ["if", "position", "=", "plan", ".", "declarations_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_156 : LineCertificate where
  text := "            Put_Insertion (Output, Model.Declarations_Insertion, Success);"
  tokens := ["put_insertion", "(", "output", ",", "model", ".", "declarations_insertion", ",", "success", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_157 : LineCertificate where
  text := "            if not Success then exit; end if;"
  tokens := ["if", "not", "success", "then", "exit", ";", "end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_158 : LineCertificate where
  text := "            Declarations_Done := True;"
  tokens := ["declarations_done", ":=", "true", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_159 : LineCertificate where
  text := "         elsif Position = Plan.Includes_Offset then"
  tokens := ["elsif", "position", "=", "plan", ".", "includes_offset", "then"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_160 : LineCertificate where
  text := "            Put_Insertion (Output, Model.Includes_Insertion, Success);"
  tokens := ["put_insertion", "(", "output", ",", "model", ".", "includes_insertion", ",", "success", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_161 : LineCertificate where
  text := "            if not Success then exit; end if;"
  tokens := ["if", "not", "success", "then", "exit", ";", "end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_162 : LineCertificate where
  text := "            Includes_Done := True;"
  tokens := ["includes_done", ":=", "true", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_163 : LineCertificate where
  text := "         end if;"
  tokens := ["end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_164 : LineCertificate where
  text := "         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));"
  tokens := ["read_bytes", ":=", "bytes", ".", "add", "(", "read_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_165 : LineCertificate where
  text := "         Model.Consume (Current, Character'Val (Item));"
  tokens := ["model", ".", "consume", "(", "current", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_166 : LineCertificate where
  text := "         Put_Byte (Output, Character'Val (Item), Success);"
  tokens := ["put_byte", "(", "output", ",", "character", "'", "val", "(", "item", ")", ",", "success", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_167 : LineCertificate where
  text := "         if not Success then exit; end if;"
  tokens := ["if", "not", "success", "then", "exit", ";", "end", "if", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_168 : LineCertificate where
  text := "         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));"
  tokens := ["copied_bytes", ":=", "bytes", ".", "add", "(", "copied_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_169 : LineCertificate where
  text := "         Position := Position + 1;"
  tokens := ["position", ":=", "position", "+", "1", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_170 : LineCertificate where
  text := "      end loop;"
  tokens := ["end", "loop", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_171 : LineCertificate where
  text := "      Status := C_Close (Input);"
  tokens := ["status", ":=", "c_close", "(", "input", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_172 : LineCertificate where
  text := "      Success := Success and then Status = 0;"
  tokens := ["success", ":=", "success", "and", "then", "status", "=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_173 : LineCertificate where
  text := "      Status := C_Close (Output);"
  tokens := ["status", ":=", "c_close", "(", "output", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_174 : LineCertificate where
  text := "      Files_Closed := Status = 0 and then Success;"
  tokens := ["files_closed", ":=", "status", "=", "0", "and", "then", "success", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_175 : LineCertificate where
  text := "      Success := Success and then Status = 0;"
  tokens := ["success", ":=", "success", "and", "then", "status", "=", "0", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_176 : LineCertificate where
  text := "      Checked := Model.Finish (Current);"
  tokens := ["checked", ":=", "model", ".", "finish", "(", "current", ")", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_177 : LineCertificate where
  text := "      Rechecked := Checked;"
  tokens := ["rechecked", ":=", "checked", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_178 : LineCertificate where
  text := "      Success := Success and then Checked = Plan;"
  tokens := ["success", ":=", "success", "and", "then", "checked", "=", "plan", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_179 : LineCertificate where
  text := "   end Refine;"
  tokens := ["end", "refine", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_180 : LineCertificate where
  text := "end Silver_Image_Files;"
  tokens := ["end", "silver_image_files", ";"]
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_line_181 : LineCertificate where
  text := ""
  tokens := []
  correct := by decide +kernel
  noNewline := by decide +kernel

def imageFilesBodyTokens_block_0_1 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_0

def imageFilesBodyTokens_block_1_2 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_1

def imageFilesBodyTokens_block_0_2 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_0_1 imageFilesBodyTokens_block_1_2
    "with Interfaces.C;\nwith System;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', ';']
      ['w', 'i', 't', 'h', ' ', 'S', 'y', 's', 't', 'e', 'm', ';']))

def imageFilesBodyTokens_block_2_3 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_2

def imageFilesBodyTokens_block_3_4 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_3

def imageFilesBodyTokens_block_4_5 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_4

def imageFilesBodyTokens_block_3_5 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_3_4 imageFilesBodyTokens_block_4_5
    "\npackage body Silver_Image_Files with SPARK_Mode => On is"
    (by kernel_exact (string_join_ofList []
      ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']))

def imageFilesBodyTokens_block_2_5 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_2_3 imageFilesBodyTokens_block_3_5
    "with Silver_Libc;\n\npackage body Silver_Image_Files with SPARK_Mode => On is"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';']
      ['\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']))

def imageFilesBodyTokens_block_0_5 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_0_2 imageFilesBodyTokens_block_2_5
    "with Interfaces.C;\nwith System;\nwith Silver_Libc;\n\npackage body Silver_Image_Files with SPARK_Mode => On is"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'y', 's', 't', 'e', 'm', ';']
      ['w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']))

def imageFilesBodyTokens_block_5_6 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_5

def imageFilesBodyTokens_block_6_7 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_6

def imageFilesBodyTokens_block_7_8 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_7

def imageFilesBodyTokens_block_6_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_6_7 imageFilesBodyTokens_block_7_8
    "   use type System.Address;\n   use type Model.Byte_Count;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']))

def imageFilesBodyTokens_block_5_8 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_5_6 imageFilesBodyTokens_block_6_8
    "   use type Interfaces.C.int;\n   use type System.Address;\n   use type Model.Byte_Count;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']))

def imageFilesBodyTokens_block_8_9 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_8

def imageFilesBodyTokens_block_9_10 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_9

def imageFilesBodyTokens_block_10_11 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_10

def imageFilesBodyTokens_block_9_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_9_10 imageFilesBodyTokens_block_10_11
    "   use type Model.Plan_Kind;\n   use Silver_Libc;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';']))

def imageFilesBodyTokens_block_8_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_8_9 imageFilesBodyTokens_block_9_11
    "   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use Silver_Libc;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';']))

def imageFilesBodyTokens_block_5_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_5_8 imageFilesBodyTokens_block_8_11
    "   use type Interfaces.C.int;\n   use type System.Address;\n   use type Model.Byte_Count;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use Silver_Libc;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';']))

def imageFilesBodyTokens_block_0_11 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_0_5 imageFilesBodyTokens_block_5_11
    "with Interfaces.C;\nwith System;\nwith Silver_Libc;\n\npackage body Silver_Image_Files with SPARK_Mode => On is\n   use type Interfaces.C.int;\n   use type System.Address;\n   use type Model.Byte_Count;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use Silver_Libc;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'y', 's', 't', 'e', 'm', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's']
      [' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';']))

def imageFilesBodyTokens_block_11_12 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_11

def imageFilesBodyTokens_block_12_13 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_12

def imageFilesBodyTokens_block_11_13 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_11_12 imageFilesBodyTokens_block_12_13
    "\n   procedure Reset_Observations"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's']))

def imageFilesBodyTokens_block_13_14 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_13

def imageFilesBodyTokens_block_14_15 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_14

def imageFilesBodyTokens_block_15_16 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_15

def imageFilesBodyTokens_block_14_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_14_15 imageFilesBodyTokens_block_15_16
    "       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's']))

def imageFilesBodyTokens_block_13_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_13_14 imageFilesBodyTokens_block_14_16
    "     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,\n       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's']))

def imageFilesBodyTokens_block_11_16 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_11_13 imageFilesBodyTokens_block_13_16
    "\n   procedure Reset_Observations\n     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,\n       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's']))

def imageFilesBodyTokens_block_16_17 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_16

def imageFilesBodyTokens_block_17_18 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_17

def imageFilesBodyTokens_block_18_19 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_18

def imageFilesBodyTokens_block_17_19 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_17_18 imageFilesBodyTokens_block_18_19
    "         and then Bytes.Length (Read_Bytes) = 0)\n   is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')']
      [' ', ' ', ' ', 'i', 's']))

def imageFilesBodyTokens_block_16_19 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_16_17 imageFilesBodyTokens_block_17_19
    "         and then Read_Bytes = Written_Bytes\n         and then Bytes.Length (Read_Bytes) = 0)\n   is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')', '\n', ' ', ' ', ' ', 'i', 's']))

def imageFilesBodyTokens_block_19_20 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_19

def imageFilesBodyTokens_block_20_21 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_20

def imageFilesBodyTokens_block_21_22 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_21

def imageFilesBodyTokens_block_20_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_20_21 imageFilesBodyTokens_block_21_22
    "      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']))

def imageFilesBodyTokens_block_19_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_19_20 imageFilesBodyTokens_block_20_22
    "   begin\n      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']))

def imageFilesBodyTokens_block_16_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_16_19 imageFilesBodyTokens_block_19_22
    "         and then Read_Bytes = Written_Bytes\n         and then Bytes.Length (Read_Bytes) = 0)\n   is\n   begin\n      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')', '\n', ' ', ' ', ' ', 'i', 's']
      [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']))

def imageFilesBodyTokens_block_11_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_11_16 imageFilesBodyTokens_block_16_22
    "\n   procedure Reset_Observations\n     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,\n       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes\n         and then Read_Bytes = Written_Bytes\n         and then Bytes.Length (Read_Bytes) = 0)\n   is\n   begin\n      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']))

def imageFilesBodyTokens_block_0_22 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_0_11 imageFilesBodyTokens_block_11_22
    "with Interfaces.C;\nwith System;\nwith Silver_Libc;\n\npackage body Silver_Image_Files with SPARK_Mode => On is\n   use type Interfaces.C.int;\n   use type System.Address;\n   use type Model.Byte_Count;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use Silver_Libc;\n\n   procedure Reset_Observations\n     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,\n       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes\n         and then Read_Bytes = Written_Bytes\n         and then Bytes.Length (Read_Bytes) = 0)\n   is\n   begin\n      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'y', 's', 't', 'e', 'm', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';']
      ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']))

def imageFilesBodyTokens_block_22_23 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_22

def imageFilesBodyTokens_block_23_24 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_23

def imageFilesBodyTokens_block_22_24 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_22_23 imageFilesBodyTokens_block_23_24
    "      Written_Bytes := Bytes.Empty_Sequence;\n      Read_Ended := False;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']))

def imageFilesBodyTokens_block_24_25 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_24

def imageFilesBodyTokens_block_25_26 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_25

def imageFilesBodyTokens_block_26_27 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_26

def imageFilesBodyTokens_block_25_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_25_26 imageFilesBodyTokens_block_26_27
    "      Rechecked := (others => <>);\n   end Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';']
      [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_24_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_24_25 imageFilesBodyTokens_block_25_27
    "      Files_Closed := False;\n      Rechecked := (others => <>);\n   end Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_22_27 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_22_24 imageFilesBodyTokens_block_24_27
    "      Written_Bytes := Bytes.Empty_Sequence;\n      Read_Ended := False;\n      Files_Closed := False;\n      Rechecked := (others => <>);\n   end Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_27_28 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_27

def imageFilesBodyTokens_block_28_29 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_28

def imageFilesBodyTokens_block_29_30 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_29

def imageFilesBodyTokens_block_28_30 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_28_29 imageFilesBodyTokens_block_29_30
    "   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e']
      [' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']))

def imageFilesBodyTokens_block_27_30 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_27_28 imageFilesBodyTokens_block_28_30
    "\n   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']))

def imageFilesBodyTokens_block_30_31 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_30

def imageFilesBodyTokens_block_31_32 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_31

def imageFilesBodyTokens_block_32_33 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_32

def imageFilesBodyTokens_block_31_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_31_32 imageFilesBodyTokens_block_32_33
    "       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')']))

def imageFilesBodyTokens_block_30_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_30_31 imageFilesBodyTokens_block_31_33
    "     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')']))

def imageFilesBodyTokens_block_27_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_27_30 imageFilesBodyTokens_block_30_33
    "\n   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))"
    (by kernel_exact (string_join_ofList ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')']))

def imageFilesBodyTokens_block_22_33 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_22_27 imageFilesBodyTokens_block_27_33
    "      Written_Bytes := Bytes.Empty_Sequence;\n      Read_Ended := False;\n      Files_Closed := False;\n      Rechecked := (others => <>);\n   end Reset_Observations;\n\n   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']
      ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')']))

def imageFilesBodyTokens_block_33_34 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_33

def imageFilesBodyTokens_block_34_35 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_34

def imageFilesBodyTokens_block_35_36 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_35

def imageFilesBodyTokens_block_34_36 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_34_35 imageFilesBodyTokens_block_35_36
    "      Status : Interfaces.C.int;\n   begin"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';']
      [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']))

def imageFilesBodyTokens_block_33_36 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_33_34 imageFilesBodyTokens_block_34_36
    "   is\n      Status : Interfaces.C.int;\n   begin"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']))

def imageFilesBodyTokens_block_36_37 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_36

def imageFilesBodyTokens_block_37_38 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_37

def imageFilesBodyTokens_block_38_39 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_38

def imageFilesBodyTokens_block_37_39 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_37_38 imageFilesBodyTokens_block_38_39
    "      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_36_39 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_36_37 imageFilesBodyTokens_block_37_39
    "      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);\n      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'P', 'u', 't', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ',', ' ', 'F', 'i', 'l', 'e', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_33_39 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_33_36 imageFilesBodyTokens_block_36_39
    "   is\n      Status : Interfaces.C.int;\n   begin\n      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);\n      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'P', 'u', 't', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ',', ' ', 'F', 'i', 'l', 'e', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_39_40 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_39

def imageFilesBodyTokens_block_40_41 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_40

def imageFilesBodyTokens_block_41_42 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_41

def imageFilesBodyTokens_block_40_42 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_40_41 imageFilesBodyTokens_block_41_42
    "\n   procedure Put_Insertion"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n']))

def imageFilesBodyTokens_block_39_42 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_39_40 imageFilesBodyTokens_block_40_42
    "   end Put_Byte;\n\n   procedure Put_Insertion"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ';']
      ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n']))

def imageFilesBodyTokens_block_42_43 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_42

def imageFilesBodyTokens_block_43_44 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_43

def imageFilesBodyTokens_block_44_45 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_44

def imageFilesBodyTokens_block_43_45 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_43_44 imageFilesBodyTokens_block_44_45
    "     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_42_45 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_42_43 imageFilesBodyTokens_block_43_45
    "     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'K', 'i', 'n', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'K', 'i', 'n', 'd', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']
      [' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_39_45 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_39_42 imageFilesBodyTokens_block_42_45
    "   end Put_Byte;\n\n   procedure Put_Insertion\n     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n']
      [' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'K', 'i', 'n', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'K', 'i', 'n', 'd', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_33_45 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_33_39 imageFilesBodyTokens_block_39_45
    "   is\n      Status : Interfaces.C.int;\n   begin\n      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);\n      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;\n   end Put_Byte;\n\n   procedure Put_Insertion\n     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'P', 'u', 't', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ',', ' ', 'F', 'i', 'l', 'e', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'K', 'i', 'n', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'K', 'i', 'n', 'd', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_22_45 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_22_33 imageFilesBodyTokens_block_33_45
    "      Written_Bytes := Bytes.Empty_Sequence;\n      Read_Ended := False;\n      Files_Closed := False;\n      Rechecked := (others => <>);\n   end Reset_Observations;\n\n   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))\n   is\n      Status : Interfaces.C.int;\n   begin\n      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);\n      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;\n   end Put_Byte;\n\n   procedure Put_Insertion\n     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')']
      [' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'P', 'u', 't', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ',', ' ', 'F', 'i', 'l', 'e', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'K', 'i', 'n', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'K', 'i', 'n', 'd', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_0_45 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_0_22 imageFilesBodyTokens_block_22_45
    "with Interfaces.C;\nwith System;\nwith Silver_Libc;\n\npackage body Silver_Image_Files with SPARK_Mode => On is\n   use type Interfaces.C.int;\n   use type System.Address;\n   use type Model.Byte_Count;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use Silver_Libc;\n\n   procedure Reset_Observations\n     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,\n       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes\n         and then Read_Bytes = Written_Bytes\n         and then Bytes.Length (Read_Bytes) = 0)\n   is\n   begin\n      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;\n      Written_Bytes := Bytes.Empty_Sequence;\n      Read_Ended := False;\n      Files_Closed := False;\n      Rechecked := (others => <>);\n   end Reset_Observations;\n\n   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))\n   is\n      Status : Interfaces.C.int;\n   begin\n      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);\n      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;\n   end Put_Byte;\n\n   procedure Put_Insertion\n     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'y', 's', 't', 'e', 'm', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'P', 'u', 't', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ',', ' ', 'F', 'i', 'l', 'e', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'K', 'i', 'n', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'K', 'i', 'n', 'd', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_45_46 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_45

def imageFilesBodyTokens_block_46_47 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_46

def imageFilesBodyTokens_block_45_47 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_45_46 imageFilesBodyTokens_block_46_47
    "         Written_Bytes'Old <= Written_Bytes\n         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')']))

def imageFilesBodyTokens_block_47_48 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_47

def imageFilesBodyTokens_block_48_49 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_48

def imageFilesBodyTokens_block_49_50 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_49

def imageFilesBodyTokens_block_48_50 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_48_49 imageFilesBodyTokens_block_49_50
    "         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')']))

def imageFilesBodyTokens_block_47_50 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_47_48 imageFilesBodyTokens_block_48_50
    "           + To_Big_Integer (Model.Insertion_Length (Kind))\n         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')']))

def imageFilesBodyTokens_block_45_50 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_45_47 imageFilesBodyTokens_block_47_50
    "         Written_Bytes'Old <= Written_Bytes\n         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)\n           + To_Big_Integer (Model.Insertion_Length (Kind))\n         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')']))

def imageFilesBodyTokens_block_50_51 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_50

def imageFilesBodyTokens_block_51_52 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_51

def imageFilesBodyTokens_block_52_53 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_52

def imageFilesBodyTokens_block_51_53 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_51_52 imageFilesBodyTokens_block_52_53
    "   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesBodyTokens_block_50_53 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_50_51 imageFilesBodyTokens_block_51_53
    "             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))\n   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ')']
      [' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']))

def imageFilesBodyTokens_block_53_54 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_53

def imageFilesBodyTokens_block_54_55 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_54

def imageFilesBodyTokens_block_55_56 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_55

def imageFilesBodyTokens_block_54_56 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_54_55 imageFilesBodyTokens_block_55_56
    "      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p']))

def imageFilesBodyTokens_block_53_56 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_53_54 imageFilesBodyTokens_block_54_56
    "   begin\n      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p']))

def imageFilesBodyTokens_block_50_56 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_50_53 imageFilesBodyTokens_block_53_56
    "             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))\n   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;\n   begin\n      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';']
      [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p']))

def imageFilesBodyTokens_block_45_56 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_45_50 imageFilesBodyTokens_block_50_56
    "         Written_Bytes'Old <= Written_Bytes\n         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)\n           + To_Big_Integer (Model.Insertion_Length (Kind))\n         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)\n             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))\n   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;\n   begin\n      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p']))

def imageFilesBodyTokens_block_56_57 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_56

def imageFilesBodyTokens_block_57_58 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_57

def imageFilesBodyTokens_block_58_59 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_58

def imageFilesBodyTokens_block_57_59 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_57_58 imageFilesBodyTokens_block_58_59
    "         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';']))

def imageFilesBodyTokens_block_56_59 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_56_57 imageFilesBodyTokens_block_57_59
    "         pragma Loop_Invariant (Static => Before <= Written_Bytes);\n         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';']))

def imageFilesBodyTokens_block_59_60 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_59

def imageFilesBodyTokens_block_60_61 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_60

def imageFilesBodyTokens_block_61_62 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_61

def imageFilesBodyTokens_block_60_62 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_60_61 imageFilesBodyTokens_block_61_62
    "           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')']))

def imageFilesBodyTokens_block_59_62 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_59_60 imageFilesBodyTokens_block_60_62
    "         pragma Loop_Invariant (Static =>\n           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')']))

def imageFilesBodyTokens_block_56_62 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_56_59 imageFilesBodyTokens_block_59_62
    "         pragma Loop_Invariant (Static => Before <= Written_Bytes);\n         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));\n         pragma Loop_Invariant (Static =>\n           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')']))

def imageFilesBodyTokens_block_62_63 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_62

def imageFilesBodyTokens_block_63_64 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_63

def imageFilesBodyTokens_block_64_65 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_64

def imageFilesBodyTokens_block_63_65 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_63_64 imageFilesBodyTokens_block_64_65
    "         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';']))

def imageFilesBodyTokens_block_62_65 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_62_63 imageFilesBodyTokens_block_63_65
    "               = Model.Insertion_Byte (Kind, I)));\n         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';']))

def imageFilesBodyTokens_block_65_66 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_65

def imageFilesBodyTokens_block_66_67 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_66

def imageFilesBodyTokens_block_67_68 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_67

def imageFilesBodyTokens_block_66_68 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_66_67 imageFilesBodyTokens_block_67_68
    "   end Put_Insertion;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';']
      []))

def imageFilesBodyTokens_block_65_68 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_65_66 imageFilesBodyTokens_block_66_68
    "      end loop;\n   end Put_Insertion;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';']
      [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';', '\n']))

def imageFilesBodyTokens_block_62_68 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_62_65 imageFilesBodyTokens_block_65_68
    "               = Model.Insertion_Byte (Kind, I)));\n         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;\n      end loop;\n   end Put_Insertion;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';', '\n']))

def imageFilesBodyTokens_block_56_68 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_56_62 imageFilesBodyTokens_block_62_68
    "         pragma Loop_Invariant (Static => Before <= Written_Bytes);\n         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));\n         pragma Loop_Invariant (Static =>\n           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))\n               = Model.Insertion_Byte (Kind, I)));\n         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;\n      end loop;\n   end Put_Insertion;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';', '\n']))

def imageFilesBodyTokens_block_45_68 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_45_56 imageFilesBodyTokens_block_56_68
    "         Written_Bytes'Old <= Written_Bytes\n         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)\n           + To_Big_Integer (Model.Insertion_Length (Kind))\n         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)\n             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))\n   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;\n   begin\n      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop\n         pragma Loop_Invariant (Static => Before <= Written_Bytes);\n         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));\n         pragma Loop_Invariant (Static =>\n           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))\n               = Model.Insertion_Byte (Kind, I)));\n         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;\n      end loop;\n   end Put_Insertion;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';', '\n']))

def imageFilesBodyTokens_block_68_69 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_68

def imageFilesBodyTokens_block_69_70 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_69

def imageFilesBodyTokens_block_68_70 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_68_69 imageFilesBodyTokens_block_69_70
    "   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't']
      [' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';']))

def imageFilesBodyTokens_block_70_71 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_70

def imageFilesBodyTokens_block_71_72 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_71

def imageFilesBodyTokens_block_72_73 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_72

def imageFilesBodyTokens_block_71_73 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_71_72 imageFilesBodyTokens_block_72_73
    "   is\n      Input, Output : System.Address;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';']))

def imageFilesBodyTokens_block_70_73 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_70_71 imageFilesBodyTokens_block_71_73
    "      Plan : out Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']
      [' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';']))

def imageFilesBodyTokens_block_68_73 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_68_70 imageFilesBodyTokens_block_70_73
    "   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';']))

def imageFilesBodyTokens_block_73_74 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_73

def imageFilesBodyTokens_block_74_75 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_74

def imageFilesBodyTokens_block_75_76 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_75

def imageFilesBodyTokens_block_74_76 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_74_75 imageFilesBodyTokens_block_75_76
    "      Current : Model.State := Model.Initial_State;\n   begin"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';']
      [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']))

def imageFilesBodyTokens_block_73_76 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_73_74 imageFilesBodyTokens_block_74_76
    "      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n   begin"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']))

def imageFilesBodyTokens_block_76_77 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_76

def imageFilesBodyTokens_block_77_78 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_77

def imageFilesBodyTokens_block_78_79 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_78

def imageFilesBodyTokens_block_77_79 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_77_78 imageFilesBodyTokens_block_78_79
    "      Success := False;\n      Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_76_79 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_76_77 imageFilesBodyTokens_block_77_79
    "      Plan := (others => <>);\n      Success := False;\n      Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_73_79 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_73_76 imageFilesBodyTokens_block_76_79
    "      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n   begin\n      Plan := (others => <>);\n      Success := False;\n      Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_68_79 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_68_73 imageFilesBodyTokens_block_73_79
    "   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n   begin\n      Plan := (others => <>);\n      Success := False;\n      Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_79_80 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_79

def imageFilesBodyTokens_block_80_81 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_80

def imageFilesBodyTokens_block_81_82 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_81

def imageFilesBodyTokens_block_80_82 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_80_81 imageFilesBodyTokens_block_81_82
    "      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten."
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.']))

def imageFilesBodyTokens_block_79_82 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_79_80 imageFilesBodyTokens_block_80_82
    "      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten."
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.']))

def imageFilesBodyTokens_block_82_83 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_82

def imageFilesBodyTokens_block_83_84 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_83

def imageFilesBodyTokens_block_84_85 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_84

def imageFilesBodyTokens_block_83_85 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_83_84 imageFilesBodyTokens_block_84_85
    "      if Output = System.Null_Address then\n         Status := C_Close (Input);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']))

def imageFilesBodyTokens_block_82_85 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_82_83 imageFilesBodyTokens_block_83_85
    "      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']))

def imageFilesBodyTokens_block_79_85 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_79_82 imageFilesBodyTokens_block_82_85
    "      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten.\n      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.']
      [' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']))

def imageFilesBodyTokens_block_85_86 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_85

def imageFilesBodyTokens_block_86_87 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_86

def imageFilesBodyTokens_block_87_88 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_87

def imageFilesBodyTokens_block_86_88 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_86_87 imageFilesBodyTokens_block_87_88
    "         return;\n      end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_85_88 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_85_86 imageFilesBodyTokens_block_86_88
    "         Files_Closed := Status = 0;\n         return;\n      end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_88_89 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_88

def imageFilesBodyTokens_block_89_90 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_89

def imageFilesBodyTokens_block_90_91 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_90

def imageFilesBodyTokens_block_89_91 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_89_90 imageFilesBodyTokens_block_90_91
    "         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']))

def imageFilesBodyTokens_block_88_91 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_88_89 imageFilesBodyTokens_block_89_91
    "      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']))

def imageFilesBodyTokens_block_85_91 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_85_88 imageFilesBodyTokens_block_88_91
    "         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']))

def imageFilesBodyTokens_block_79_91 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_79_85 imageFilesBodyTokens_block_85_91
    "      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten.\n      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']))

def imageFilesBodyTokens_block_68_91 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_68_79 imageFilesBodyTokens_block_79_91
    "   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n   begin\n      Plan := (others => <>);\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten.\n      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']))

def imageFilesBodyTokens_block_45_91 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_45_68 imageFilesBodyTokens_block_68_91
    "         Written_Bytes'Old <= Written_Bytes\n         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)\n           + To_Big_Integer (Model.Insertion_Length (Kind))\n         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)\n             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))\n   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;\n   begin\n      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop\n         pragma Loop_Invariant (Static => Before <= Written_Bytes);\n         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));\n         pragma Loop_Invariant (Static =>\n           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))\n               = Model.Insertion_Byte (Kind, I)));\n         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;\n      end loop;\n   end Put_Insertion;\n\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n   begin\n      Plan := (others => <>);\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten.\n      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';', '\n']
      [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']))

def imageFilesBodyTokens_block_0_91 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_0_45 imageFilesBodyTokens_block_45_91
    "with Interfaces.C;\nwith System;\nwith Silver_Libc;\n\npackage body Silver_Image_Files with SPARK_Mode => On is\n   use type Interfaces.C.int;\n   use type System.Address;\n   use type Model.Byte_Count;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use Silver_Libc;\n\n   procedure Reset_Observations\n     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,\n       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes\n         and then Read_Bytes = Written_Bytes\n         and then Bytes.Length (Read_Bytes) = 0)\n   is\n   begin\n      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;\n      Written_Bytes := Bytes.Empty_Sequence;\n      Read_Ended := False;\n      Files_Closed := False;\n      Rechecked := (others => <>);\n   end Reset_Observations;\n\n   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))\n   is\n      Status : Interfaces.C.int;\n   begin\n      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);\n      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;\n   end Put_Byte;\n\n   procedure Put_Insertion\n     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes'Old <= Written_Bytes\n         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)\n           + To_Big_Integer (Model.Insertion_Length (Kind))\n         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)\n             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))\n   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;\n   begin\n      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop\n         pragma Loop_Invariant (Static => Before <= Written_Bytes);\n         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));\n         pragma Loop_Invariant (Static =>\n           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))\n               = Model.Insertion_Byte (Kind, I)));\n         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;\n      end loop;\n   end Put_Insertion;\n\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n   begin\n      Plan := (others => <>);\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten.\n      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'y', 's', 't', 'e', 'm', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'P', 'u', 't', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ',', ' ', 'F', 'i', 'l', 'e', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'K', 'i', 'n', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'K', 'i', 'n', 'd', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']))

def imageFilesBodyTokens_block_91_92 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_91

def imageFilesBodyTokens_block_92_93 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_92

def imageFilesBodyTokens_block_91_93 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_91_92 imageFilesBodyTokens_block_92_93
    "         Item := C_Get (Input);\n         if Item = -1 then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_93_94 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_93

def imageFilesBodyTokens_block_94_95 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_94

def imageFilesBodyTokens_block_95_96 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_95

def imageFilesBodyTokens_block_94_96 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_94_95 imageFilesBodyTokens_block_95_96
    "            Status := C_Error (Input);\n            Success := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_93_96 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_93_94 imageFilesBodyTokens_block_94_96
    "            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_91_96 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_91_93 imageFilesBodyTokens_block_93_96
    "         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_96_97 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_96

def imageFilesBodyTokens_block_97_98 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_97

def imageFilesBodyTokens_block_98_99 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_98

def imageFilesBodyTokens_block_97_99 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_97_98 imageFilesBodyTokens_block_98_99
    "         elsif Item not in 0 .. 255 then\n            Success := False;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']))

def imageFilesBodyTokens_block_96_99 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_96_97 imageFilesBodyTokens_block_97_99
    "            exit;\n         elsif Item not in 0 .. 255 then\n            Success := False;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']))

def imageFilesBodyTokens_block_99_100 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_99

def imageFilesBodyTokens_block_100_101 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_100

def imageFilesBodyTokens_block_101_102 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_101

def imageFilesBodyTokens_block_100_102 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_100_101 imageFilesBodyTokens_block_101_102
    "         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']))

def imageFilesBodyTokens_block_99_102 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_99_100 imageFilesBodyTokens_block_100_102
    "            exit;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']))

def imageFilesBodyTokens_block_96_102 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_96_99 imageFilesBodyTokens_block_99_102
    "            exit;\n         elsif Item not in 0 .. 255 then\n            Success := False;\n            exit;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']))

def imageFilesBodyTokens_block_91_102 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_91_96 imageFilesBodyTokens_block_96_102
    "         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0;\n            exit;\n         elsif Item not in 0 .. 255 then\n            Success := False;\n            exit;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']))

def imageFilesBodyTokens_block_102_103 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_102

def imageFilesBodyTokens_block_103_104 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_103

def imageFilesBodyTokens_block_102_104 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_102_103 imageFilesBodyTokens_block_103_104
    "         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']))

def imageFilesBodyTokens_block_104_105 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_104

def imageFilesBodyTokens_block_105_106 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_105

def imageFilesBodyTokens_block_106_107 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_106

def imageFilesBodyTokens_block_105_107 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_105_106 imageFilesBodyTokens_block_106_107
    "         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';']))

def imageFilesBodyTokens_block_104_107 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_104_105 imageFilesBodyTokens_block_105_107
    "         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';']))

def imageFilesBodyTokens_block_102_107 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_102_104 imageFilesBodyTokens_block_104_107
    "         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';']))

def imageFilesBodyTokens_block_107_108 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_107

def imageFilesBodyTokens_block_108_109 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_108

def imageFilesBodyTokens_block_109_110 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_109

def imageFilesBodyTokens_block_108_110 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_108_109 imageFilesBodyTokens_block_109_110
    "      Success := Success and then Status = 0;\n      Status := C_Close (Output);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';']))

def imageFilesBodyTokens_block_107_110 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_107_108 imageFilesBodyTokens_block_108_110
    "      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';']))

def imageFilesBodyTokens_block_110_111 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_110

def imageFilesBodyTokens_block_111_112 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_111

def imageFilesBodyTokens_block_112_113 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_112

def imageFilesBodyTokens_block_111_113 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_111_112 imageFilesBodyTokens_block_112_113
    "      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';']))

def imageFilesBodyTokens_block_110_113 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_110_111 imageFilesBodyTokens_block_111_113
    "      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';']))

def imageFilesBodyTokens_block_107_113 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_107_110 imageFilesBodyTokens_block_110_113
    "      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';']))

def imageFilesBodyTokens_block_102_113 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_102_107 imageFilesBodyTokens_block_107_113
    "         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';']))

def imageFilesBodyTokens_block_91_113 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_91_102 imageFilesBodyTokens_block_102_113
    "         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0;\n            exit;\n         elsif Item not in 0 .. 255 then\n            Success := False;\n            exit;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';']))

def imageFilesBodyTokens_block_113_114 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_113

def imageFilesBodyTokens_block_114_115 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_114

def imageFilesBodyTokens_block_113_115 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_113_114 imageFilesBodyTokens_block_114_115
    "      Rechecked := Plan;\n      Success := Success and then Plan.Kind /= Model.Invalid_Model;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'P', 'l', 'a', 'n', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '/', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'v', 'a', 'l', 'i', 'd', '_', 'M', 'o', 'd', 'e', 'l', ';']))

def imageFilesBodyTokens_block_115_116 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_115

def imageFilesBodyTokens_block_116_117 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_116

def imageFilesBodyTokens_block_117_118 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_117

def imageFilesBodyTokens_block_116_118 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_116_117 imageFilesBodyTokens_block_117_118
    "\n   procedure Refine"
    (by kernel_exact (string_join_ofList []
      [' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e']))

def imageFilesBodyTokens_block_115_118 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_115_116 imageFilesBodyTokens_block_116_118
    "   end Snapshot;\n\n   procedure Refine"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', ';']
      ['\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e']))

def imageFilesBodyTokens_block_113_118 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_113_115 imageFilesBodyTokens_block_115_118
    "      Rechecked := Plan;\n      Success := Success and then Plan.Kind /= Model.Invalid_Model;\n   end Snapshot;\n\n   procedure Refine"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '/', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'v', 'a', 'l', 'i', 'd', '_', 'M', 'o', 'd', 'e', 'l', ';']
      [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e']))

def imageFilesBodyTokens_block_118_119 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_118

def imageFilesBodyTokens_block_119_120 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_119

def imageFilesBodyTokens_block_120_121 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_120

def imageFilesBodyTokens_block_119_121 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_119_120 imageFilesBodyTokens_block_120_121
    "      Plan : Model.Plan; Success : out Boolean)\n   is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')']
      [' ', ' ', ' ', 'i', 's']))

def imageFilesBodyTokens_block_118_121 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_118_119 imageFilesBodyTokens_block_119_121
    "     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n   is"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's']))

def imageFilesBodyTokens_block_121_122 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_121

def imageFilesBodyTokens_block_122_123 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_122

def imageFilesBodyTokens_block_123_124 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_123

def imageFilesBodyTokens_block_122_124 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_122_123 imageFilesBodyTokens_block_123_124
    "      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';']))

def imageFilesBodyTokens_block_121_124 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_121_122 imageFilesBodyTokens_block_122_124
    "      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';']))

def imageFilesBodyTokens_block_118_124 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_118_121 imageFilesBodyTokens_block_121_124
    "     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';']))

def imageFilesBodyTokens_block_113_124 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_113_118 imageFilesBodyTokens_block_118_124
    "      Rechecked := Plan;\n      Success := Success and then Plan.Kind /= Model.Invalid_Model;\n   end Snapshot;\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '/', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'v', 'a', 'l', 'i', 'd', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e']
      [' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';']))

def imageFilesBodyTokens_block_124_125 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_124

def imageFilesBodyTokens_block_125_126 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_125

def imageFilesBodyTokens_block_126_127 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_126

def imageFilesBodyTokens_block_125_127 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_125_126 imageFilesBodyTokens_block_126_127
    "      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']))

def imageFilesBodyTokens_block_124_127 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_124_125 imageFilesBodyTokens_block_125_127
    "      Position : Model.Byte_Count := 0;\n      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']))

def imageFilesBodyTokens_block_127_128 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_127

def imageFilesBodyTokens_block_128_129 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_128

def imageFilesBodyTokens_block_129_130 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_129

def imageFilesBodyTokens_block_128_130 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_128_129 imageFilesBodyTokens_block_129_130
    "      Success := False;\n      Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_127_130 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_127_128 imageFilesBodyTokens_block_128_130
    "   begin\n      Success := False;\n      Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_124_130 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_124_127 imageFilesBodyTokens_block_127_130
    "      Position : Model.Byte_Count := 0;\n      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;\n   begin\n      Success := False;\n      Reset_Observations;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';']
      [' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']))

def imageFilesBodyTokens_block_130_131 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_130

def imageFilesBodyTokens_block_131_132 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_131

def imageFilesBodyTokens_block_132_133 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_132

def imageFilesBodyTokens_block_131_133 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_131_132 imageFilesBodyTokens_block_132_133
    "      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';']))

def imageFilesBodyTokens_block_130_133 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_130_131 imageFilesBodyTokens_block_131_133
    "      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';']))

def imageFilesBodyTokens_block_133_134 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_133

def imageFilesBodyTokens_block_134_135 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_134

def imageFilesBodyTokens_block_135_136 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_135

def imageFilesBodyTokens_block_134_136 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_134_135 imageFilesBodyTokens_block_135_136
    "         Status := C_Close (Input);\n         Files_Closed := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_133_136 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_133_134 imageFilesBodyTokens_block_134_136
    "      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_130_136 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_130_133 imageFilesBodyTokens_block_133_136
    "      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_124_136 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_124_130 imageFilesBodyTokens_block_130_136
    "      Position : Model.Byte_Count := 0;\n      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;\n   begin\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_113_136 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_113_124 imageFilesBodyTokens_block_124_136
    "      Rechecked := Plan;\n      Success := Success and then Plan.Kind /= Model.Invalid_Model;\n   end Snapshot;\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n      Position : Model.Byte_Count := 0;\n      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;\n   begin\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '/', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'v', 'a', 'l', 'i', 'd', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_91_136 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_91_113 imageFilesBodyTokens_block_113_136
    "         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0;\n            exit;\n         elsif Item not in 0 .. 255 then\n            Success := False;\n            exit;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);\n      Rechecked := Plan;\n      Success := Success and then Plan.Kind /= Model.Invalid_Model;\n   end Snapshot;\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n      Position : Model.Byte_Count := 0;\n      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;\n   begin\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '/', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'v', 'a', 'l', 'i', 'd', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_136_137 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_136

def imageFilesBodyTokens_block_137_138 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_137

def imageFilesBodyTokens_block_136_138 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_136_137 imageFilesBodyTokens_block_137_138
    "         return;\n      end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_138_139 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_138

def imageFilesBodyTokens_block_139_140 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_139

def imageFilesBodyTokens_block_140_141 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_140

def imageFilesBodyTokens_block_139_141 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_139_140 imageFilesBodyTokens_block_140_141
    "         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>']))

def imageFilesBodyTokens_block_138_141 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_138_139 imageFilesBodyTokens_block_139_141
    "      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>']))

def imageFilesBodyTokens_block_136_141 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_136_138 imageFilesBodyTokens_block_138_141
    "         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>']))

def imageFilesBodyTokens_block_141_142 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_141

def imageFilesBodyTokens_block_142_143 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_142

def imageFilesBodyTokens_block_143_144 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_143

def imageFilesBodyTokens_block_142_144 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_142_143 imageFilesBodyTokens_block_143_144
    "         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';']))

def imageFilesBodyTokens_block_141_144 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_141_142 imageFilesBodyTokens_block_142_144
    "           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));\n         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';']))

def imageFilesBodyTokens_block_144_145 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_144

def imageFilesBodyTokens_block_145_146 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_145

def imageFilesBodyTokens_block_146_147 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_146

def imageFilesBodyTokens_block_145_147 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_145_146 imageFilesBodyTokens_block_146_147
    "         if Item = -1 then\n            Read_Ended := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_144_147 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_144_145 imageFilesBodyTokens_block_145_147
    "         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_141_147 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_141_144 imageFilesBodyTokens_block_144_147
    "           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));\n         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));\n         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_136_147 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_136_141 imageFilesBodyTokens_block_141_147
    "         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>\n           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));\n         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));\n         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_147_148 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_147

def imageFilesBodyTokens_block_148_149 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_148

def imageFilesBodyTokens_block_149_150 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_149

def imageFilesBodyTokens_block_148_150 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_148_149 imageFilesBodyTokens_block_149_150
    "            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';']))

def imageFilesBodyTokens_block_147_150 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_147_148 imageFilesBodyTokens_block_148_150
    "            Status := C_Error (Input);\n            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';']))

def imageFilesBodyTokens_block_150_151 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_150

def imageFilesBodyTokens_block_151_152 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_151

def imageFilesBodyTokens_block_152_153 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_152

def imageFilesBodyTokens_block_151_153 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_151_152 imageFilesBodyTokens_block_152_153
    "         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']))

def imageFilesBodyTokens_block_150_153 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_150_151 imageFilesBodyTokens_block_151_153
    "            exit;\n         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']))

def imageFilesBodyTokens_block_147_153 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_147_150 imageFilesBodyTokens_block_150_153
    "            Status := C_Error (Input);\n            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;\n            exit;\n         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']))

def imageFilesBodyTokens_block_153_154 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_153

def imageFilesBodyTokens_block_154_155 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_154

def imageFilesBodyTokens_block_155_156 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_155

def imageFilesBodyTokens_block_154_156 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_154_155 imageFilesBodyTokens_block_155_156
    "         end if;\n         if Position = Plan.Declarations_Offset then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_153_156 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_153_154 imageFilesBodyTokens_block_154_156
    "            exit;\n         end if;\n         if Position = Plan.Declarations_Offset then"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']))

def imageFilesBodyTokens_block_156_157 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_156

def imageFilesBodyTokens_block_157_158 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_157

def imageFilesBodyTokens_block_158_159 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_158

def imageFilesBodyTokens_block_157_159 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_157_158 imageFilesBodyTokens_block_158_159
    "            if not Success then exit; end if;\n            Declarations_Done := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_156_159 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_156_157 imageFilesBodyTokens_block_157_159
    "            Put_Insertion (Output, Model.Declarations_Insertion, Success);\n            if not Success then exit; end if;\n            Declarations_Done := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_153_159 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_153_156 imageFilesBodyTokens_block_156_159
    "            exit;\n         end if;\n         if Position = Plan.Declarations_Offset then\n            Put_Insertion (Output, Model.Declarations_Insertion, Success);\n            if not Success then exit; end if;\n            Declarations_Done := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_147_159 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_147_153 imageFilesBodyTokens_block_153_159
    "            Status := C_Error (Input);\n            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;\n            exit;\n         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;\n            exit;\n         end if;\n         if Position = Plan.Declarations_Offset then\n            Put_Insertion (Output, Model.Declarations_Insertion, Success);\n            if not Success then exit; end if;\n            Declarations_Done := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_136_159 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_136_147 imageFilesBodyTokens_block_147_159
    "         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>\n           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));\n         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));\n         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;\n            exit;\n         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;\n            exit;\n         end if;\n         if Position = Plan.Declarations_Offset then\n            Put_Insertion (Output, Model.Declarations_Insertion, Success);\n            if not Success then exit; end if;\n            Declarations_Done := True;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']))

def imageFilesBodyTokens_block_159_160 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_159

def imageFilesBodyTokens_block_160_161 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_160

def imageFilesBodyTokens_block_159_161 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_159_160 imageFilesBodyTokens_block_160_161
    "         elsif Position = Plan.Includes_Offset then\n            Put_Insertion (Output, Model.Includes_Insertion, Success);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']))

def imageFilesBodyTokens_block_161_162 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_161

def imageFilesBodyTokens_block_162_163 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_162

def imageFilesBodyTokens_block_163_164 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_163

def imageFilesBodyTokens_block_162_164 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_162_163 imageFilesBodyTokens_block_163_164
    "            Includes_Done := True;\n         end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_161_164 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_161_162 imageFilesBodyTokens_block_162_164
    "            if not Success then exit; end if;\n            Includes_Done := True;\n         end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_159_164 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_159_161 imageFilesBodyTokens_block_161_164
    "         elsif Position = Plan.Includes_Offset then\n            Put_Insertion (Output, Model.Includes_Insertion, Success);\n            if not Success then exit; end if;\n            Includes_Done := True;\n         end if;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']))

def imageFilesBodyTokens_block_164_165 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_164

def imageFilesBodyTokens_block_165_166 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_165

def imageFilesBodyTokens_block_166_167 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_166

def imageFilesBodyTokens_block_165_167 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_165_166 imageFilesBodyTokens_block_166_167
    "         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']))

def imageFilesBodyTokens_block_164_167 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_164_165 imageFilesBodyTokens_block_165_167
    "         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']))

def imageFilesBodyTokens_block_167_168 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_167

def imageFilesBodyTokens_block_168_169 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_168

def imageFilesBodyTokens_block_169_170 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_169

def imageFilesBodyTokens_block_168_170 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_168_169 imageFilesBodyTokens_block_169_170
    "         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';']))

def imageFilesBodyTokens_block_167_170 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_167_168 imageFilesBodyTokens_block_168_170
    "         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';']))

def imageFilesBodyTokens_block_164_170 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_164_167 imageFilesBodyTokens_block_167_170
    "         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';']))

def imageFilesBodyTokens_block_159_170 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_159_164 imageFilesBodyTokens_block_164_170
    "         elsif Position = Plan.Includes_Offset then\n            Put_Insertion (Output, Model.Includes_Insertion, Success);\n            if not Success then exit; end if;\n            Includes_Done := True;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';']))

def imageFilesBodyTokens_block_170_171 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_170

def imageFilesBodyTokens_block_171_172 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_171

def imageFilesBodyTokens_block_172_173 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_172

def imageFilesBodyTokens_block_171_173 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_171_172 imageFilesBodyTokens_block_172_173
    "      Status := C_Close (Input);\n      Success := Success and then Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_170_173 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_170_171 imageFilesBodyTokens_block_171_173
    "      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_173_174 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_173

def imageFilesBodyTokens_block_174_175 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_174

def imageFilesBodyTokens_block_175_176 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_175

def imageFilesBodyTokens_block_174_176 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_174_175 imageFilesBodyTokens_block_175_176
    "      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_173_176 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_173_174 imageFilesBodyTokens_block_174_176
    "      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_170_176 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_170_173 imageFilesBodyTokens_block_173_176
    "      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']))

def imageFilesBodyTokens_block_176_177 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_176

def imageFilesBodyTokens_block_177_178 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_177

def imageFilesBodyTokens_block_178_179 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_178

def imageFilesBodyTokens_block_177_179 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_177_178 imageFilesBodyTokens_block_178_179
    "      Rechecked := Checked;\n      Success := Success and then Checked = Plan;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';']))

def imageFilesBodyTokens_block_176_179 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_176_177 imageFilesBodyTokens_block_177_179
    "      Checked := Model.Finish (Current);\n      Rechecked := Checked;\n      Success := Success and then Checked = Plan;"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';']))

def imageFilesBodyTokens_block_179_180 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_179

def imageFilesBodyTokens_block_180_181 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_180

def imageFilesBodyTokens_block_181_182 : ReconstructionCertificate :=
  ReconstructionCertificate.single imageFilesBodyTokens_line_181

def imageFilesBodyTokens_block_180_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_180_181 imageFilesBodyTokens_block_181_182
    "end Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';']
      []))

def imageFilesBodyTokens_block_179_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_179_180 imageFilesBodyTokens_block_180_182
    "   end Refine;\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 'f', 'i', 'n', 'e', ';']
      ['e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesBodyTokens_block_176_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_176_179 imageFilesBodyTokens_block_179_182
    "      Checked := Model.Finish (Current);\n      Rechecked := Checked;\n      Success := Success and then Checked = Plan;\n   end Refine;\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';']
      [' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 'f', 'i', 'n', 'e', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesBodyTokens_block_170_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_170_176 imageFilesBodyTokens_block_176_182
    "      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Checked := Model.Finish (Current);\n      Rechecked := Checked;\n      Success := Success and then Checked = Plan;\n   end Refine;\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 'f', 'i', 'n', 'e', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesBodyTokens_block_159_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_159_170 imageFilesBodyTokens_block_170_182
    "         elsif Position = Plan.Includes_Offset then\n            Put_Insertion (Output, Model.Includes_Insertion, Success);\n            if not Success then exit; end if;\n            Includes_Done := True;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Checked := Model.Finish (Current);\n      Rechecked := Checked;\n      Success := Success and then Checked = Plan;\n   end Refine;\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 'f', 'i', 'n', 'e', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesBodyTokens_block_136_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_136_159 imageFilesBodyTokens_block_159_182
    "         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>\n           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));\n         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));\n         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;\n            exit;\n         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;\n            exit;\n         end if;\n         if Position = Plan.Declarations_Offset then\n            Put_Insertion (Output, Model.Declarations_Insertion, Success);\n            if not Success then exit; end if;\n            Declarations_Done := True;\n         elsif Position = Plan.Includes_Offset then\n            Put_Insertion (Output, Model.Includes_Insertion, Success);\n            if not Success then exit; end if;\n            Includes_Done := True;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Checked := Model.Finish (Current);\n      Rechecked := Checked;\n      Success := Success and then Checked = Plan;\n   end Refine;\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 'f', 'i', 'n', 'e', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesBodyTokens_block_91_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_91_136 imageFilesBodyTokens_block_136_182
    "         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0;\n            exit;\n         elsif Item not in 0 .. 255 then\n            Success := False;\n            exit;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);\n      Rechecked := Plan;\n      Success := Success and then Plan.Kind /= Model.Invalid_Model;\n   end Snapshot;\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n      Position : Model.Byte_Count := 0;\n      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;\n   begin\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>\n           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));\n         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));\n         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;\n            exit;\n         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;\n            exit;\n         end if;\n         if Position = Plan.Declarations_Offset then\n            Put_Insertion (Output, Model.Declarations_Insertion, Success);\n            if not Success then exit; end if;\n            Declarations_Done := True;\n         elsif Position = Plan.Includes_Offset then\n            Put_Insertion (Output, Model.Includes_Insertion, Success);\n            if not Success then exit; end if;\n            Includes_Done := True;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Checked := Model.Finish (Current);\n      Rechecked := Checked;\n      Success := Success and then Checked = Plan;\n   end Refine;\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '/', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'v', 'a', 'l', 'i', 'd', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 'f', 'i', 'n', 'e', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesBodyTokens_block_0_182 : ReconstructionCertificate :=
  ReconstructionCertificate.join imageFilesBodyTokens_block_0_91 imageFilesBodyTokens_block_91_182
    "with Interfaces.C;\nwith System;\nwith Silver_Libc;\n\npackage body Silver_Image_Files with SPARK_Mode => On is\n   use type Interfaces.C.int;\n   use type System.Address;\n   use type Model.Byte_Count;\n   use type Model.Plan;\n   use type Model.Plan_Kind;\n   use Silver_Libc;\n\n   procedure Reset_Observations\n     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,\n       Read_Ended, Files_Closed, Rechecked)),\n       Post => (Static => Read_Bytes = Copied_Bytes\n         and then Read_Bytes = Written_Bytes\n         and then Bytes.Length (Read_Bytes) = 0)\n   is\n   begin\n      Read_Bytes := Bytes.Empty_Sequence;\n      Copied_Bytes := Bytes.Empty_Sequence;\n      Written_Bytes := Bytes.Empty_Sequence;\n      Read_Ended := False;\n      Files_Closed := False;\n      Rechecked := (others => <>);\n   end Reset_Observations;\n\n   procedure Put_Byte\n     (File : System.Address; Item : Character; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))\n   is\n      Status : Interfaces.C.int;\n   begin\n      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);\n      Success := Status = Interfaces.C.int (Character'Pos (Item));\n      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;\n   end Put_Byte;\n\n   procedure Put_Insertion\n     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)\n     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),\n       Post => (Static => (if Success then\n         Written_Bytes'Old <= Written_Bytes\n         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)\n           + To_Big_Integer (Model.Insertion_Length (Kind))\n         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>\n           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)\n             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))\n   is\n      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;\n   begin\n      Success := True;\n      for Position in 1 .. Model.Insertion_Length (Kind) loop\n         pragma Loop_Invariant (Static => Before <= Written_Bytes);\n         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)\n           = Bytes.Length (Before) + To_Big_Integer (Position - 1));\n         pragma Loop_Invariant (Static =>\n           (for all I in 1 .. Position - 1 =>\n             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))\n               = Model.Insertion_Byte (Kind, I)));\n         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);\n         exit when not Success;\n      end loop;\n   end Put_Insertion;\n\n   procedure Snapshot\n     (Input_Name, Snapshot_Name : String;\n      Plan : out Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n   begin\n      Plan := (others => <>);\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      --  Exclusive creation keeps retained observations from being overwritten.\n      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);\n         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0;\n            exit;\n         elsif Item not in 0 .. 255 then\n            Success := False;\n            exit;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Plan := Model.Finish (Current);\n      Rechecked := Plan;\n      Success := Success and then Plan.Kind /= Model.Invalid_Model;\n   end Snapshot;\n\n   procedure Refine\n     (Snapshot_Name, Refined_Name : String;\n      Plan : Model.Plan; Success : out Boolean)\n   is\n      Input, Output : System.Address;\n      Item, Status : Interfaces.C.int;\n      Current : Model.State := Model.Initial_State;\n      Position : Model.Byte_Count := 0;\n      Declarations_Done, Includes_Done : Boolean := False;\n      Checked : Model.Plan;\n   begin\n      Success := False;\n      Reset_Observations;\n      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C (\"rb\"));\n      if Input = System.Null_Address then return; end if;\n      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C (\"wbx\"));\n      if Output = System.Null_Address then\n         Status := C_Close (Input);\n         Files_Closed := Status = 0;\n         return;\n      end if;\n      loop\n         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);\n         pragma Loop_Invariant (Static =>\n           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));\n         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));\n         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));\n         Item := C_Get (Input);\n         if Item = -1 then\n            Read_Ended := True;\n            Status := C_Error (Input);\n            Success := Status = 0 and then Position = Plan.Bytes\n              and then Declarations_Done and then Includes_Done;\n            exit;\n         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then\n            Success := False;\n            exit;\n         end if;\n         if Position = Plan.Declarations_Offset then\n            Put_Insertion (Output, Model.Declarations_Insertion, Success);\n            if not Success then exit; end if;\n            Declarations_Done := True;\n         elsif Position = Plan.Includes_Offset then\n            Put_Insertion (Output, Model.Includes_Insertion, Success);\n            if not Success then exit; end if;\n            Includes_Done := True;\n         end if;\n         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));\n         Model.Consume (Current, Character'Val (Item));\n         Put_Byte (Output, Character'Val (Item), Success);\n         if not Success then exit; end if;\n         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));\n         Position := Position + 1;\n      end loop;\n      Status := C_Close (Input);\n      Success := Success and then Status = 0;\n      Status := C_Close (Output);\n      Files_Closed := Status = 0 and then Success;\n      Success := Success and then Status = 0;\n      Checked := Model.Finish (Current);\n      Rechecked := Checked;\n      Success := Success and then Checked = Plan;\n   end Refine;\nend Silver_Image_Files;\n"
    (by kernel_exact (string_join_ofList ['w', 'i', 't', 'h', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'y', 's', 't', 'e', 'm', ';', '\n', 'w', 'i', 't', 'h', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', 'p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'b', 'o', 'd', 'y', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 't', 'y', 'p', 'e', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', '_', 'K', 'i', 'n', 'd', ';', '\n', ' ', ' ', ' ', 'u', 's', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'L', 'i', 'b', 'c', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', '>', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ',', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ',', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', '0', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'E', 'm', 'p', 't', 'y', '_', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'I', 't', 'e', 'm', ' ', ':', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ',', ' ', 'I', 't', 'e', 'm', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'P', 'u', 't', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ',', ' ', 'F', 'i', 'l', 'e', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ' ', '(', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'P', 'o', 's', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'I', 't', 'e', 'm', ')', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'F', 'i', 'l', 'e', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', ' ', 'K', 'i', 'n', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'K', 'i', 'n', 'd', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', ' ', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'l', 'o', 'b', 'a', 'l', ' ', '=', '>', ' ', '(', 'I', 'n', '_', 'O', 'u', 't', ' ', '=', '>', ' ', '(', 'A', 'd', 'a', '.', 'T', 'e', 'x', 't', '_', 'I', 'O', '.', 'F', 'i', 'l', 'e', '_', 'S', 'y', 's', 't', 'e', 'm', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ')', ',', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 't', ' ', '=', '>', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', '(', 'i', 'f', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', '\'', 'O', 'l', 'd', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'B', 'y', 't', 'e', 's', '.', 'S', 'e', 'q', 'u', 'e', 'n', 'c', 'e', ' ', ':', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ' ', 'w', 'i', 't', 'h', ' ', 'G', 'h', 'o', 's', 't', ' ', '=', '>', ' ', 'S', 't', 'a', 't', 'i', 'c', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'f', 'o', 'r', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'K', 'i', 'n', 'd', ')', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'e', 'f', 'o', 'r', 'e', ' ', '<', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '(', 'f', 'o', 'r', ' ', 'a', 'l', 'l', ' ', 'I', ' ', 'i', 'n', ' ', '1', ' ', '.', '.', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '-', ' ', '1', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B', 'y', 't', 'e', 's', '.', 'G', 'e', 't', ' ', '(', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'B', 'y', 't', 'e', 's', '.', 'L', 'e', 'n', 'g', 't', 'h', ' ', '(', 'B', 'e', 'f', 'o', 'r', 'e', ')', ' ', '+', ' ', 'T', 'o', '_', 'B', 'i', 'g', '_', 'I', 'n', 't', 'e', 'g', 'e', 'r', ' ', '(', 'I', ')', ')', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'I', ')', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'F', 'i', 'l', 'e', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', '_', 'B', 'y', 't', 'e', ' ', '(', 'K', 'i', 'n', 'd', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ' ', 'w', 'h', 'e', 'n', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'o', 'u', 't', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', '(', 'o', 't', 'h', 'e', 'r', 's', ' ', '=', '>', ' ', '<', '>', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'I', 'n', 'p', 'u', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', '-', '-', ' ', ' ', 'E', 'x', 'c', 'l', 'u', 's', 'i', 'v', 'e', ' ', 'c', 'r', 'e', 'a', 't', 'i', 'o', 'n', ' ', 'k', 'e', 'e', 'p', 's', ' ', 'r', 'e', 't', 'a', 'i', 'n', 'e', 'd', ' ', 'o', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ' ', 'f', 'r', 'o', 'm', ' ', 'b', 'e', 'i', 'n', 'g', ' ', 'o', 'v', 'e', 'r', 'w', 'r', 'i', 't', 't', 'e', 'n', '.', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ')', ';']
      [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'l', 'a', 'n', '.', 'K', 'i', 'n', 'd', ' ', '/', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'v', 'a', 'l', 'i', 'd', '_', 'M', 'o', 'd', 'e', 'l', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', ';', '\n', '\n', ' ', ' ', ' ', 'p', 'r', 'o', 'c', 'e', 'd', 'u', 'r', 'e', ' ', 'R', 'e', 'f', 'i', 'n', 'e', '\n', ' ', ' ', ' ', ' ', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ',', ' ', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ' ', ':', ' ', 'S', 't', 'r', 'i', 'n', 'g', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'l', 'a', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', ' ', 'o', 'u', 't', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ')', '\n', ' ', ' ', ' ', 'i', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ',', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'A', 'd', 'd', 'r', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ',', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'i', 'n', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'u', 'r', 'r', 'e', 'n', 't', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'S', 't', 'a', 't', 'e', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'i', 't', 'i', 'a', 'l', '_', 'S', 't', 'a', 't', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', ' ', ':', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ',', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', ' ', 'B', 'o', 'o', 'l', 'e', 'a', 'n', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'b', 'e', 'g', 'i', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 's', 'e', 't', '_', 'O', 'b', 's', 'e', 'r', 'v', 'a', 't', 'i', 'o', 'n', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'S', 'n', 'a', 'p', 's', 'h', 'o', 't', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'r', 'b', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 'n', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', ':', '=', ' ', 'C', '_', 'O', 'p', 'e', 'n', ' ', '(', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', 'R', 'e', 'f', 'i', 'n', 'e', 'd', '_', 'N', 'a', 'm', 'e', ')', ',', ' ', 'I', 'n', 't', 'e', 'r', 'f', 'a', 'c', 'e', 's', '.', 'C', '.', 'T', 'o', '_', 'C', ' ', '(', '"', 'w', 'b', 'x', '"', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'O', 'u', 't', 'p', 'u', 't', ' ', '=', ' ', 'S', 'y', 's', 't', 'e', 'm', '.', 'N', 'u', 'l', 'l', '_', 'A', 'd', 'd', 'r', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'r', 'e', 't', 'u', 'r', 'n', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'l', 'o', 'o', 'p', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', '=', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'S', 't', 'a', 't', 'i', 'c', ' ', '=', '>', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'p', 'l', 'i', 'c', 'e', 'd', '_', 'P', 'r', 'e', 'f', 'i', 'x', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'W', 'r', 'i', 't', 't', 'e', 'n', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'P', 'l', 'a', 'n', ',', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'p', 'r', 'a', 'g', 'm', 'a', ' ', 'L', 'o', 'o', 'p', '_', 'I', 'n', 'v', 'a', 'r', 'i', 'a', 'n', 't', ' ', '(', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', '=', ' ', '(', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '>', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 't', 'e', 'm', ' ', ':', '=', ' ', 'C', '_', 'G', 'e', 't', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', '=', ' ', '-', '1', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'E', 'n', 'd', 'e', 'd', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'E', 'r', 'r', 'o', 'r', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'B', 'y', 't', 'e', 's', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'I', 't', 'e', 'm', ' ', 'n', 'o', 't', ' ', 'i', 'n', ' ', '0', ' ', '.', '.', ' ', '2', '5', '5', ' ', 'o', 'r', ' ', 'e', 'l', 's', 'e', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'B', 'y', 't', 'e', '_', 'C', 'o', 'u', 'n', 't', '\'', 'L', 'a', 's', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'F', 'a', 'l', 's', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'x', 'i', 't', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'D', 'e', 'c', 'l', 'a', 'r', 'a', 't', 'i', 'o', 'n', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'l', 's', 'i', 'f', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '=', ' ', 'P', 'l', 'a', 'n', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'O', 'f', 'f', 's', 'e', 't', ' ', 't', 'h', 'e', 'n', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'I', 'n', 's', 'e', 'r', 't', 'i', 'o', 'n', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'I', 'n', 'c', 'l', 'u', 'd', 'e', 's', '_', 'D', 'o', 'n', 'e', ' ', ':', '=', ' ', 'T', 'r', 'u', 'e', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'R', 'e', 'a', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'C', 'o', 'n', 's', 'u', 'm', 'e', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'u', 't', '_', 'B', 'y', 't', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ',', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'i', 'f', ' ', 'n', 'o', 't', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 't', 'h', 'e', 'n', ' ', 'e', 'x', 'i', 't', ';', ' ', 'e', 'n', 'd', ' ', 'i', 'f', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ' ', ':', '=', ' ', 'B', 'y', 't', 'e', 's', '.', 'A', 'd', 'd', ' ', '(', 'C', 'o', 'p', 'i', 'e', 'd', '_', 'B', 'y', 't', 'e', 's', ',', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', 'I', 't', 'e', 'm', ')', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', ':', '=', ' ', 'P', 'o', 's', 'i', 't', 'i', 'o', 'n', ' ', '+', ' ', '1', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'l', 'o', 'o', 'p', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'I', 'n', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', ':', '=', ' ', 'C', '_', 'C', 'l', 'o', 's', 'e', ' ', '(', 'O', 'u', 't', 'p', 'u', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'F', 'i', 'l', 'e', 's', '_', 'C', 'l', 'o', 's', 'e', 'd', ' ', ':', '=', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'S', 't', 'a', 't', 'u', 's', ' ', '=', ' ', '0', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'M', 'o', 'd', 'e', 'l', '.', 'F', 'i', 'n', 'i', 's', 'h', ' ', '(', 'C', 'u', 'r', 'r', 'e', 'n', 't', ')', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'R', 'e', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', ':', '=', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ';', '\n', ' ', ' ', ' ', ' ', ' ', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', ':', '=', ' ', 'S', 'u', 'c', 'c', 'e', 's', 's', ' ', 'a', 'n', 'd', ' ', 't', 'h', 'e', 'n', ' ', 'C', 'h', 'e', 'c', 'k', 'e', 'd', ' ', '=', ' ', 'P', 'l', 'a', 'n', ';', '\n', ' ', ' ', ' ', 'e', 'n', 'd', ' ', 'R', 'e', 'f', 'i', 'n', 'e', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'F', 'i', 'l', 'e', 's', ';', '\n']))

def imageFilesBodyTokens_certificates : List LineCertificate :=
  imageFilesBodyTokens_block_0_182.lines

def imageFilesBodyTokens : Tokens :=
  ["with", "interfaces", ".", "c", ";", "with", "system", ";", "with", "silver_libc", ";", "package", "body", "silver_image_files", "with", "spark_mode", "=>", "on", "is", "use", "type", "interfaces", ".", "c", ".", "int", ";", "use", "type", "system", ".", "address", ";", "use", "type", "model", ".", "byte_count", ";", "use", "type", "model", ".", "plan", ";", "use", "type", "model", ".", "plan_kind", ";", "use", "silver_libc", ";", "procedure", "reset_observations", "with", "global", "=>", "(", "output", "=>", "(", "read_bytes", ",", "copied_bytes", ",", "written_bytes", ",", "read_ended", ",", "files_closed", ",", "rechecked", ")", ")", ",", "post", "=>", "(", "static", "=>", "read_bytes", "=", "copied_bytes", "and", "then", "read_bytes", "=", "written_bytes", "and", "then", "bytes", ".", "length", "(", "read_bytes", ")", "=", "0", ")", "is", "begin", "read_bytes", ":=", "bytes", ".", "empty_sequence", ";", "copied_bytes", ":=", "bytes", ".", "empty_sequence", ";", "written_bytes", ":=", "bytes", ".", "empty_sequence", ";", "read_ended", ":=", "false", ";", "files_closed", ":=", "false", ";", "rechecked", ":=", "(", "others", "=>", "<", ">", ")", ";", "end", "reset_observations", ";", "procedure", "put_byte", "(", "file", ":", "system", ".", "address", ";", "item", ":", "character", ";", "success", ":", "out", "boolean", ")", "with", "global", "=>", "(", "in_out", "=>", "(", "ada", ".", "text_io", ".", "file_system", ",", "written_bytes", ")", ")", ",", "post", "=>", "(", "static", "=>", "(", "if", "success", "then", "written_bytes", "=", "bytes", ".", "add", "(", "written_bytes", "'", "old", ",", "item", ")", ")", ")", "is", "status", ":", "interfaces", ".", "c", ".", "int", ";", "begin", "status", ":=", "c_put", "(", "interfaces", ".", "c", ".", "int", "(", "character", "'", "pos", "(", "item", ")", ")", ",", "file", ")", ";", "success", ":=", "status", "=", "interfaces", ".", "c", ".", "int", "(", "character", "'", "pos", "(", "item", ")", ")", ";", "if", "success", "then", "written_bytes", ":=", "bytes", ".", "add", "(", "written_bytes", ",", "item", ")", ";", "end", "if", ";", "end", "put_byte", ";", "procedure", "put_insertion", "(", "file", ":", "system", ".", "address", ";", "kind", ":", "model", ".", "insertion_kind", ";", "success", ":", "out", "boolean", ")", "with", "global", "=>", "(", "in_out", "=>", "(", "ada", ".", "text_io", ".", "file_system", ",", "written_bytes", ")", ")", ",", "post", "=>", "(", "static", "=>", "(", "if", "success", "then", "written_bytes", "'", "old", "<=", "written_bytes", "and", "then", "bytes", ".", "length", "(", "written_bytes", ")", "=", "bytes", ".", "length", "(", "written_bytes", "'", "old", ")", "+", "to_big_integer", "(", "model", ".", "insertion_length", "(", "kind", ")", ")", "and", "then", "(", "for", "all", "i", "in", "1", "..", "model", ".", "insertion_length", "(", "kind", ")", "=>", "bytes", ".", "get", "(", "written_bytes", ",", "bytes", ".", "length", "(", "written_bytes", "'", "old", ")", "+", "to_big_integer", "(", "i", ")", ")", "=", "model", ".", "insertion_byte", "(", "kind", ",", "i", ")", ")", ")", ")", "is", "before", ":", "constant", "bytes", ".", "sequence", ":=", "written_bytes", "with", "ghost", "=>", "static", ";", "begin", "success", ":=", "true", ";", "for", "position", "in", "1", "..", "model", ".", "insertion_length", "(", "kind", ")", "loop", "pragma", "loop_invariant", "(", "static", "=>", "before", "<=", "written_bytes", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "bytes", ".", "length", "(", "written_bytes", ")", "=", "bytes", ".", "length", "(", "before", ")", "+", "to_big_integer", "(", "position", "-", "1", ")", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "(", "for", "all", "i", "in", "1", "..", "position", "-", "1", "=>", "bytes", ".", "get", "(", "written_bytes", ",", "bytes", ".", "length", "(", "before", ")", "+", "to_big_integer", "(", "i", ")", ")", "=", "model", ".", "insertion_byte", "(", "kind", ",", "i", ")", ")", ")", ";", "put_byte", "(", "file", ",", "model", ".", "insertion_byte", "(", "kind", ",", "position", ")", ",", "success", ")", ";", "exit", "when", "not", "success", ";", "end", "loop", ";", "end", "put_insertion", ";", "procedure", "snapshot", "(", "input_name", ",", "snapshot_name", ":", "string", ";", "plan", ":", "out", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "is", "input", ",", "output", ":", "system", ".", "address", ";", "item", ",", "status", ":", "interfaces", ".", "c", ".", "int", ";", "current", ":", "model", ".", "state", ":=", "model", ".", "initial_state", ";", "begin", "plan", ":=", "(", "others", "=>", "<", ">", ")", ";", "success", ":=", "false", ";", "reset_observations", ";", "input", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "input_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"rb\"", ")", ")", ";", "if", "input", "=", "system", ".", "null_address", "then", "return", ";", "end", "if", ";", "output", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "snapshot_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"wbx\"", ")", ")", ";", "if", "output", "=", "system", ".", "null_address", "then", "status", ":=", "c_close", "(", "input", ")", ";", "files_closed", ":=", "status", "=", "0", ";", "return", ";", "end", "if", ";", "loop", "pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "copied_bytes", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "written_bytes", ")", ";", "item", ":=", "c_get", "(", "input", ")", ";", "if", "item", "=", "-", "1", "then", "read_ended", ":=", "true", ";", "status", ":=", "c_error", "(", "input", ")", ";", "success", ":=", "status", "=", "0", ";", "exit", ";", "elsif", "item", "not", "in", "0", "..", "255", "then", "success", ":=", "false", ";", "exit", ";", "end", "if", ";", "read_bytes", ":=", "bytes", ".", "add", "(", "read_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";", "model", ".", "consume", "(", "current", ",", "character", "'", "val", "(", "item", ")", ")", ";", "put_byte", "(", "output", ",", "character", "'", "val", "(", "item", ")", ",", "success", ")", ";", "if", "not", "success", "then", "exit", ";", "end", "if", ";", "copied_bytes", ":=", "bytes", ".", "add", "(", "copied_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";", "end", "loop", ";", "status", ":=", "c_close", "(", "input", ")", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "status", ":=", "c_close", "(", "output", ")", ";", "files_closed", ":=", "status", "=", "0", "and", "then", "success", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "plan", ":=", "model", ".", "finish", "(", "current", ")", ";", "rechecked", ":=", "plan", ";", "success", ":=", "success", "and", "then", "plan", ".", "kind", "/=", "model", ".", "invalid_model", ";", "end", "snapshot", ";", "procedure", "refine", "(", "snapshot_name", ",", "refined_name", ":", "string", ";", "plan", ":", "model", ".", "plan", ";", "success", ":", "out", "boolean", ")", "is", "input", ",", "output", ":", "system", ".", "address", ";", "item", ",", "status", ":", "interfaces", ".", "c", ".", "int", ";", "current", ":", "model", ".", "state", ":=", "model", ".", "initial_state", ";", "position", ":", "model", ".", "byte_count", ":=", "0", ";", "declarations_done", ",", "includes_done", ":", "boolean", ":=", "false", ";", "checked", ":", "model", ".", "plan", ";", "begin", "success", ":=", "false", ";", "reset_observations", ";", "input", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "snapshot_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"rb\"", ")", ")", ";", "if", "input", "=", "system", ".", "null_address", "then", "return", ";", "end", "if", ";", "output", ":=", "c_open", "(", "interfaces", ".", "c", ".", "to_c", "(", "refined_name", ")", ",", "interfaces", ".", "c", ".", "to_c", "(", "\"wbx\"", ")", ")", ";", "if", "output", "=", "system", ".", "null_address", "then", "status", ":=", "c_close", "(", "input", ")", ";", "files_closed", ":=", "status", "=", "0", ";", "return", ";", "end", "if", ";", "loop", "pragma", "loop_invariant", "(", "static", "=>", "read_bytes", "=", "copied_bytes", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "spliced_prefix", "(", "read_bytes", ",", "written_bytes", ",", "plan", ",", "position", ")", ")", ";", "pragma", "loop_invariant", "(", "declarations_done", "=", "(", "position", ">", "plan", ".", "declarations_offset", ")", ")", ";", "pragma", "loop_invariant", "(", "includes_done", "=", "(", "position", ">", "plan", ".", "includes_offset", ")", ")", ";", "item", ":=", "c_get", "(", "input", ")", ";", "if", "item", "=", "-", "1", "then", "read_ended", ":=", "true", ";", "status", ":=", "c_error", "(", "input", ")", ";", "success", ":=", "status", "=", "0", "and", "then", "position", "=", "plan", ".", "bytes", "and", "then", "declarations_done", "and", "then", "includes_done", ";", "exit", ";", "elsif", "item", "not", "in", "0", "..", "255", "or", "else", "position", "=", "model", ".", "byte_count", "'", "last", "then", "success", ":=", "false", ";", "exit", ";", "end", "if", ";", "if", "position", "=", "plan", ".", "declarations_offset", "then", "put_insertion", "(", "output", ",", "model", ".", "declarations_insertion", ",", "success", ")", ";", "if", "not", "success", "then", "exit", ";", "end", "if", ";", "declarations_done", ":=", "true", ";", "elsif", "position", "=", "plan", ".", "includes_offset", "then", "put_insertion", "(", "output", ",", "model", ".", "includes_insertion", ",", "success", ")", ";", "if", "not", "success", "then", "exit", ";", "end", "if", ";", "includes_done", ":=", "true", ";", "end", "if", ";", "read_bytes", ":=", "bytes", ".", "add", "(", "read_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";", "model", ".", "consume", "(", "current", ",", "character", "'", "val", "(", "item", ")", ")", ";", "put_byte", "(", "output", ",", "character", "'", "val", "(", "item", ")", ",", "success", ")", ";", "if", "not", "success", "then", "exit", ";", "end", "if", ";", "copied_bytes", ":=", "bytes", ".", "add", "(", "copied_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";", "position", ":=", "position", "+", "1", ";", "end", "loop", ";", "status", ":=", "c_close", "(", "input", ")", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "status", ":=", "c_close", "(", "output", ")", ";", "files_closed", ":=", "status", "=", "0", "and", "then", "success", ";", "success", ":=", "success", "and", "then", "status", "=", "0", ";", "checked", ":=", "model", ".", "finish", "(", "current", ")", ";", "rechecked", ":=", "checked", ";", "success", ":=", "success", "and", "then", "checked", "=", "plan", ";", "end", "refine", ";", "end", "silver_image_files", ";"]

theorem imageFilesBodyTokens_source :
    String.intercalate "\n" (imageFilesBodyTokens_certificates.map (·.text)) = imageFilesBody := by
  exact imageFilesBodyTokens_block_0_182.correct

theorem imageFilesBodyTokens_values :
    imageFilesBodyTokens_certificates.flatMap (·.tokens) = imageFilesBodyTokens := by rfl

theorem imageFilesBodyTokens_correct : lex imageFilesBody = some imageFilesBodyTokens := by
  rw [← imageFilesBodyTokens_source, reconstructed_source_lex imageFilesBodyTokens_certificates
    imageFilesBodyTokens_block_0_182.nonempty]
  rw [imageFilesBodyTokens_values]

end Silver.Source
