package Audit_State is
   pragma SPARK_Mode (On);
   subtype Small is Integer range 0 .. 10;
   Limit : constant Integer := 10;
   procedure Produce (Answer : out Small; Unread : in Small);
   procedure Depend (Value : in out Small; Drop : in Small);
   procedure Reset;
   procedure Replace;
   function Read return Small;
   function Ignore (Unused : in Small) return Small;
end Audit_State;
