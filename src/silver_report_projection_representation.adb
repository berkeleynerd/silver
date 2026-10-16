with SPARK.Big_Integers;
package body Silver_Report_Projection_Representation with SPARK_Mode => On is
   use SPARK.Big_Integers;
   procedure From_Buffer (Emitted : Bytes.Sequence; Buffer : String; Last : Natural) is
      Converted : constant Bytes.Sequence := Scan.From_String (Buffer (1 .. Last));
   begin
      pragma Assert (for all I in 1 .. Last =>
        Bytes.Get (Emitted, To_Big_Integer (I)) = Bytes.Get (Converted, To_Big_Integer (I)));
      pragma Assert (for all I in Emitted =>
        Bytes.Get (Emitted, I) = Bytes.Get (Converted, I));
   end From_Buffer;
end Silver_Report_Projection_Representation;
