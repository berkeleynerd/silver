package body Silver_Report_Projection_Spans with SPARK_Mode => On is
   procedure Silent_Range (Raw : Bytes.Sequence; First, Last : Big_Natural) is
   begin
      if First <= Last then
         Silent_Range (Raw, First, Last - 1);
         pragma Assert (Model.Advance_Spec
           (Model.Scan_State (Raw, Last - 1), Bytes.Get (Raw, Last)).Length = 0);
      end if;
   end Silent_Range;

   procedure Retained_Range (Raw : Bytes.Sequence; First, Last : Big_Natural) is
   begin
      if First <= Last then
         Retained_Range (Raw, First, Last - 1);
         pragma Assert (Model.Advance_Spec
           (Model.Scan_State (Raw, Last - 1), Bytes.Get (Raw, Last)).Length = 1);
         pragma Assert (Model.Advance_Spec
           (Model.Scan_State (Raw, Last - 1), Bytes.Get (Raw, Last)).Bytes (1) = Bytes.Get (Raw, Last));
      end if;
   end Retained_Range;
end Silver_Report_Projection_Spans;
