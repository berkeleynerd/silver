--  Silver showcase: every admitted construct in one argument-input program.
with Silver_IO, Silver_Arguments;
use Silver_IO;
use Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := First_Or_Default (Default => "world");
   Echo : String := Name;               --  dynamic alias of the input
   Original : constant String := Echo;  --  snapshot of the alias
   Base : constant Integer := 16#0A#;   --  Ada-static
   Limit : constant Integer range 1 .. 99 := (Base * 9);
   Edge : constant Integer := -2147483648;
   Low : Integer range 10 .. 99 := (Base + 27);
   Size : Integer range 1 .. 9 := 2#100#;
   Phase : Integer range 0 .. 1 := 0;
   Three : Integer range 0 .. 2 := 0;
   Five : Integer range 0 .. 2:100: := 0;
   Mirror : Integer range -9 .. 9 := -3;
   Found : Integer range 0 .. Limit := 0;
   Start : constant Integer := Size;    --  exact snapshot, not static
   Seen : constant String := Integer'Image (Low);
   Code : String := Integer'Image (Low);
   Tag : String := Integer'Image (Mirror);
   Banner : String := "four!";
begin
   if Input_Is_Valid and then Name'Length <= 16#40# then
      Put_Line (Item => "Hello, " & Name & "!");
      if Name = "world" or else Name'Length = 0 then
         Put_Line ("(default or empty name)");
      elsif Name = Integer'Image (Low) then
         Echo := Tag & "#";             --  path: Name'Length = 3
      elsif Echo & "!" = Banner then
         Echo := "FOUR";                --  path: Name'Length = 4
      elsif (Name'Length < 8 and then not (Name = "abc"))
        or else Name'Length >= 1E1
      then
         Echo := Name;
      else
         null;
      end if;
      Put_Line (Original & " / " & Echo);

      for Row in 1 .. Size loop         --  bounds read once: 4 rows
         Size := 1;
         for Col in reverse 1 .. Row loop
            Put (Integer'Image ((Row * Col)));
         end loop;
         Phase := (1 - Phase);
         if Phase = 1 then
            Put_Line (" <");
         else
            Put_Line (" >");
         end if;
      end loop;

      for I in 1 .. 15 loop             --  FizzBuzz by bounded state machines
         if Three = 2 then Three := 0;
         elsif Three = 1 then Three := 2;
         else Three := 1; end if;
         if Five = 4 then Five := 0; elsif Five = 3 then Five := 4;
         elsif Five = 2 then Five := 3; elsif Five = 1 then Five := 2;
         else Five := 1; end if;
         if Three = 0 and then Five = 0 then
            Put_Line ("FizzBuzz");
         elsif Three = 0 then
            Put_Line ("Fizz");
         elsif Five = 0 then
            Put_Line ("Buzz");
         else
            Put_Line (Integer'Image (I));
         end if;
      end loop;

      for N in 1 .. Limit loop
         if Found = 0 and then ((N * N) - ((N - 1) * (N - 1))) > Low then
            Found := N;
         end if;
      end loop;

      for Put_Line in 1 .. 2 loop       --  index hides the use-visible call
         Mirror := (-Mirror);
         Tag := Integer'Image (Mirror);
         Silver_IO.Put_Line (Integer'Image (Put_Line) & ":" & Tag);
      end loop;

      for Row in 1 .. 3 loop
         if Name = Integer'Image (Row) then
            Echo := Tag;                --  path: Name'Length = 2
            Put_Line ("row match:" & Echo);
         end if;
      end loop;

      Low := (109 - Low);
      Code := Integer'Image (Low);
      Banner := Code & "!!";
      Put_Line (Seen & Code & Integer'Image (Start) & Integer'Image (Size));
      Put (Item => Banner);
      Put_Line (Integer'Image (Found) & Integer'Image (Phase));
      Put_Line (Integer'Image (Edge) & Integer'Image (((Edge + 1) * (-1))));

      for K in Start .. 5 loop
         for J in 1 .. K loop
            Put ("*");
         end loop;
         Put_Line ("");
      end loop;
      if Name = "reject" then
         Reject;                        --  sticky status; output continues
      end if;
   else
      Reject;
   end if;
end Main;
