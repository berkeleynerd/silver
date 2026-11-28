pragma SPARK_Mode (On);
package body Audit_State is
   Stored : Small := 0;
   Never : Integer := 1;
   Flag : Boolean := False;
   procedure Produce (ANSWER : out Small; UNREAD : in Small) is
   begin
      ANSWER := 0;
   end Produce;
   procedure Depend (VALUE : in out Small; DROP : in Small) is
   begin
      VALUE := DROP;
   end Depend;
   procedure Reset is
   begin
      Stored := 0;
      Flag := False;
   end Reset;
   procedure Replace is
   begin
      if Stored = 0 then
         Stored := 1;
      else
         Stored := 1;
      end if;
   end Replace;
   procedure Local_Warnings is
      Idle : Small := 0;
      Changed : Small := 1;
      Flag_Local : Boolean := False;
   begin
      Changed := 2;
      Stored := Changed;
      Reset;
      Reset;
      if False then
         Stored := 1;
      else
         null;
      end if;
   end Local_Warnings;
   function Read return Small is
   begin
      return Stored;
   end Read;
   function Ignore (UNUSED : in Small) return Small is
   begin
      return Stored;
   end Ignore;
end Audit_State;
