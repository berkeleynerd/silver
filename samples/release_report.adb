with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Environment : constant String := Silver_Arguments.First_Or_Default ("staging");
   Application : constant String := "Silver";
   Version : constant String := "0.1";
   Region : constant String := "local";
   Owner : constant String := "language-team";
   Mode : constant String := "preview";
   Status : constant String := "ready";
   Command : constant String := "silver run";
   Policy : constant String := "verified";
begin
   if Silver_Arguments.Input_Is_Valid and then Environment'Length <= 3951 then
      Silver_IO.Put_Line
        ("application=" & Application & "; version=" & Version
         & "; environment=" & Environment & "; region=" & Region
         & "; owner=" & Owner & "; mode=" & Mode & "; status=" & Status
         & "; command=" & Command & "; policy=" & Policy);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
