package body Silver_Report_Observations with SPARK_Mode => On is
   function Window (Raw : Bytes.Sequence; First : Offset; Count : Natural)
     return String
   is
      Result : String (1 .. Count) := (others => Character'Val (0));
   begin
      for I in Result'Range loop
         Result (I) := Bytes.Get (Raw, First + To_Big_Integer (I - 1));
         pragma Loop_Invariant
           (for all J in 1 .. I =>
             Result (J) = Bytes.Get (Raw, First + To_Big_Integer (J - 1)));
      end loop;
      return Result;
   end Window;

   function From_String (Text : String) return Bytes.Sequence is
      Result : Bytes.Sequence := Bytes.Empty_Sequence;
   begin
      for I in Text'Range loop
         Result := Bytes.Add (Result, Text (I));
         pragma Loop_Invariant
           (Bytes.Length (Result) = To_Big_Integer (I - Text'First) + 1);
         pragma Loop_Invariant
           (for all J in Text'First .. I =>
             Bytes.Get (Result, To_Big_Integer (J - Text'First) + 1) = Text (J));
      end loop;
      return Result;
   end From_String;

   procedure Matching_Windows
     (Raw : Bytes.Sequence; First : Offset; Left, Right : String) is
   begin
      pragma Assert (for all I in Left'Range => Left (I) = Right (I));
   end Matching_Windows;
end Silver_Report_Observations;
