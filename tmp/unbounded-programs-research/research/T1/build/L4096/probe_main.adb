with Ada.Command_Line;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Ada.Calendar;
with Silver_Output_Profile;
procedure Probe_Main is
   use Ada.Streams.Stream_IO;
   use type Ada.Calendar.Time;
   F : File_Type;
   Mode : constant String := Ada.Command_Line.Argument (1);
begin
   Open (F, In_File, Ada.Command_Line.Argument (2));
   declare
      N : constant Natural := Natural (Size (F));
      type String_Access is access String;
      Text : constant String_Access := new String (1 .. N);
      S : Stream_Access := Stream (F);
      T0 : Ada.Calendar.Time;
      R : Boolean;
   begin
      String'Read (S, Text.all);
      Close (F);
      T0 := Ada.Calendar.Clock;
      if Mode = "accepts" then
         R := Silver_Output_Profile.Accepts (Text.all);
      else
         R := Silver_Output_Profile.Accepts (Text.all)
           and then (Silver_Output_Profile.Uses_Arguments (Text.all) or else True)
           and then (Silver_Output_Profile.Uses_Assignment (Text.all) or else True);
      end if;
      Ada.Text_IO.Put_Line ((if R then "ACCEPT" else "REJECT") & Duration'Image (Ada.Calendar.Clock - T0));
   end;
end Probe_Main;
