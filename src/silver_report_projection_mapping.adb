with Silver_Report_Projection_Types;
package body Silver_Report_Projection_Mapping with SPARK_Mode => On is
   use Silver_Report_Projection_Types;
   procedure Emitted_Bytes (Prefix : Bytes.Sequence; T : Transition)
     with Global => null,
       Post => (for all I in 1 .. T.Length =>
         Bytes.Get (Model.Append_Emission (Prefix, T),
           Bytes.Length (Prefix) + To_Big_Integer (I)) = T.Bytes (I))
   is
   begin
      null;
   end Emitted_Bytes;

   procedure Exact_Content (Raw : Bytes.Sequence; Low, High : Big_Natural) is
   begin
      Spans.Output_Prefix (Raw, High, Bytes.Length (Raw));
      pragma Assert (for all I in Raw =>
        (if Low <= I and then I <= High then
          Bytes.Get (Output (Raw), First (Raw, Low) + I - Low) =
            Bytes.Get (Model.Scan_Bytes (Raw, High), First (Raw, Low) + I - Low)));
   end Exact_Content;

   procedure Tree_Content (Raw : Bytes.Sequence; Low, High : Big_Natural) is
   begin
      Spans.Output_Prefix (Raw, High, Bytes.Length (Raw));
   end Tree_Content;

   procedure Emission_At (Raw : Bytes.Sequence; Position : Big_Natural) is
      T : constant Transition := Model.Advance_Spec
        (Model.Scan_State (Raw, Position - 1), Bytes.Get (Raw, Position));
   begin
      Emitted_Bytes (Model.Scan_Bytes (Raw, Position - 1), T);
      Spans.Output_Prefix (Raw, Position, Bytes.Length (Raw));
      if T.Length >= 1 then
         pragma Assert (Bytes.Get (Output (Raw), First (Raw, Position)) =
           Bytes.Get (Model.Scan_Bytes (Raw, Position), First (Raw, Position)));
      end if;
      if T.Length = 2 then
         pragma Assert (Bytes.Get (Output (Raw), First (Raw, Position) + 1) =
           Bytes.Get (Model.Scan_Bytes (Raw, Position), First (Raw, Position) + 1));
      end if;
   end Emission_At;

   procedure Nonempty_Range (Raw : Bytes.Sequence; Low, High : Big_Natural) is
   begin
      Emission_At (Raw, Low);
      Spans.Output_Prefix (Raw, Low, High);
      Spans.Output_Prefix (Raw, High, Bytes.Length (Raw));
   end Nonempty_Range;

   procedure Interior_Position (Raw : Bytes.Sequence; Low, Position, High : Big_Natural) is
   begin
      Emission_At (Raw, Low);
      Emission_At (Raw, High);
      Spans.Output_Prefix (Raw, Low, Position - 1);
      Spans.Output_Prefix (Raw, Position - 1, High - 1);
   end Interior_Position;

   procedure Interior_End (Raw : Bytes.Sequence; Position, High : Big_Natural) is
   begin
      Emission_At (Raw, High);
      Spans.Output_Prefix (Raw, Position, High - 1);
   end Interior_End;
end Silver_Report_Projection_Mapping;
