package body Silver_Report_Projection_Windows with SPARK_Mode => On is
   procedure Exact_Window (Raw : Bytes.Sequence; Low, High : Big_Natural) is
      Target : constant Bytes.Sequence := Mapping.Output (Raw);
      D : constant Big_Integer := Shift (Raw, Low);
   begin
      Mapping.Exact_Content (Raw, Low, High);
      pragma Assert (for all P in Target =>
        (if Low + D <= P and then P <= High + D then
          Bytes.Get (Raw, P - D) = Bytes.Get (Target, P)));
   end Exact_Window;

   procedure Offset_Within
     (Raw : Bytes.Sequence; Low, High, Position : Big_Natural)
   is
   begin
      Spans.Retained_Range (Raw, Low, Position - 1);
   end Offset_Within;
end Silver_Report_Projection_Windows;
