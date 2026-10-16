package body Silver_Report_Projection_Member_Steps with SPARK_Mode => On is
   procedure Space_Before_End (Raw : Bytes.Sequence; Position, Last : Big_Natural) is
   begin
      if Observations.Space (Bytes.Get (Raw, Position)) then
         Space_Before_End (Raw, Position + 1, Last);
      end if;
   end Space_Before_End;

   procedure Opening (S : State; Item : Character) is
   begin
      null;
   end Opening;

   procedure Closing (S : State; Item : Character; Base : Depth_Range) is
   begin
      null;
   end Closing;

   procedure Key_Or_Close (S : State; Item : Character) is
   begin
      null;
   end Key_Or_Close;

   procedure Value_Starter_At (S : State; Item : Character) is
   begin
      null;
   end Value_Starter_At;

   procedure Comma (S : State) is
   begin
      null;
   end Comma;

   procedure Join_Retained (Raw : Bytes.Sequence; First, Split, Last : Big_Natural) is
   begin
      null;
   end Join_Retained;
end Silver_Report_Projection_Member_Steps;
