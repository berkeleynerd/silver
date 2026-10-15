with Ada.Streams;               use Ada.Streams;
with Ada.Text_IO.Text_Streams;  use Ada.Text_IO.Text_Streams;
with Ada.Text_IO;               use Ada.Text_IO;
with System.Storage_Elements;   use System.Storage_Elements;

procedure BF
          (  Source : String;
             Memory : in out Storage_Array;
             Input  : access Root_Stream_Type'Class := Stream (Standard_Input);
             Output : access Root_Stream_Type'Class := Stream (Standard_Output)
          )  is
   subtype Address is Storage_Offset range Memory'Range;
   PC      : Address := Address'First;
   Index   : Integer := Source'First;
   Nesting : Natural := 0;
begin
   while Index <= Source'Last loop
      case Source (Index) is
         when '>' => -- Increment PC
            PC := PC + 1;
         when '<' => -- Decrement PC
            PC := PC - 1;
         when '+' => -- Increment at PC
            Memory (PC) := Memory (PC) + 1;
         when '-' => -- Decrement at PC
            Memory (PC) := Memory (PC) - 1;
         when '.' => -- Output at PC
            Storage_Element'Write (Output, Memory (PC));
         when ',' => -- Input at PC
            Storage_Element'Read (Input, Memory (PC));
         when '[' => --	Forward if zero at PC
            if Memory (PC) = 0 then
               loop
                  Index := Index + 1;
                  case Source (Index) is
                     when '[' =>
                        Nesting := Nesting + 1;
                     when ']' =>
                        exit when Nesting = 0;
                        Nesting := Nesting - 1;
                     when others =>
                        null;
                  end case;
               end loop;
            end if;
         when ']' => --	Backward if non-zero at PC
            if Memory (PC) /= 0 then
               loop
                  Index := Index - 1;
                  case Source (Index) is
                     when '[' =>
                        exit when Nesting = 0;
                        Nesting := Nesting - 1;
                     when ']' =>
                        Nesting := Nesting + 1;
                     when others =>
                        null;
                  end case;
               end loop;
            end if;
         when others => -- Comment
            null;
      end case;
      Index := Index + 1;
   end loop;
end BF;
