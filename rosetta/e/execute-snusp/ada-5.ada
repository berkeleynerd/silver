with Ada.Text_IO;
with SNUSP;
procedure Main is

   Test_Code : SNUSP.Code :=
      (1 => "Example taken from RosettaCode.org                                       ",
       2 => "                                                                         ",
       3 => "$@\G.@\o.o.@\d.--b.@\y.@\e.>@\comma.@\.<-@\W.+@\o.+++r.------l.@\d.>+.! #",
       4 => "  |   |     \@------|#  |    \@@+@@++|+++#-    \\               -        ",
       5 => "  |   \@@@@=+++++#  |   \===--------!\===!\-----|-------#-------/        ",
       6 => "  \@@+@@@+++++#     \!#+++++++++++++++++++++++#!/                        ");

   My_SNUSP_Machine : SNUSP.SNUSP_Machine;

begin

   SNUSP.Run (My_SNUSP_Machine, Test_Code);

end Main;
