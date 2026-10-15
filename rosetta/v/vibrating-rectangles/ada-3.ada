-- The Vibrating Rectangles Rosetta Code task
-- J. Carter    2026 Jul
-- This implements the version pointed to by the "Create" link in the task statement
-- Uses Ada_GUI (https://github.com/jrcarter/Ada_GUI)

with Ada.Real_Time;
with Ada_GUI;

procedure Vibrating_Rectangles is
   protected Signalling is
      procedure Start;
      -- Releases Wait_For_Start

      procedure Stop;
      -- Releases Wait_For_Stop

      entry Wait_For_Start;
      -- Waits until Start is called

      entry Wait_For_Stop;
      -- Waits until Stop is called
   private -- Signalling
      Running : Boolean := False;
   end Signalling;

   task Artist;
   -- Draws the rectangles

   protected body Signalling is
      procedure Start is
         -- Empty
      begin -- Start
         Running := True;
      end Start;

      procedure Stop is
         -- Empty
      begin -- Stop
         Running := False;
      end Stop;

      entry Wait_For_Start when Running is
         -- Empty
      begin -- Wait_For_Start
         null;
      end Wait_For_Start;

      entry Wait_For_Stop when not Running is
         -- Empty
      begin -- Wait_For_Stop
         null;
      end Wait_For_Stop;
   end Signalling;

   Display : Ada_GUI.Widget_ID;

   task body Artist is
      Max_Size : constant := 45;
      Min_Size : constant :=  3;

      Interval : constant Ada.Real_Time.Time_Span := Ada.Real_Time.To_Time_Span (0.5);

      type Color_Number is mod 3;

      type Color_Map is array (Color_Number) of Ada_GUI.Color_Info;

      Map : constant Color_Map := (0 => (Red => 255, Green =>   0, Blue =>   0, Alpha => 1.0),
                                   1 => (Red =>   0, Green => 255, Blue =>   0, Alpha => 1.0),
                                   2 => (Red =>   0, Green =>   0, Blue => 255, Alpha => 1.0) );

      Center :  Natural; -- Constant after intialization

      Next  : Ada.Real_Time.Time := Ada.Real_Time.Clock;
      Size  : Integer;
      Color : Color_Number := 0;

      use type Ada.Real_Time.Time;
   begin -- Artist
      Signalling.Wait_For_Start;
      Center := Display.Width / 2;

      Forever : loop
         All_Colors : loop
            Size := Max_Size;

            All_Rectangles : loop
               exit All_Rectangles when Size < Min_Size;

               Display.Draw_Rectangle (From_X     => Center - Size,
                                       From_Y     => Center - Size,
                                       To_X       => Center + Size,
                                       To_Y       => Center + Size,
                                       Line_Color => (None => False, Color => Map (Color) ) );
               Next := Next + Interval;
               Size := Size - Min_Size;

               select
                  Signalling.Wait_For_Stop;

                  exit Forever;
               or
                  delay until Next;
               end select;
            end loop All_Rectangles;

            Color := Color + 1;
         end loop All_Colors;
      end loop Forever;
   end Artist;

   Event : Ada_GUI.Next_Result_Info;

   use type Ada_GUI.Event_Kind_ID;
begin -- Vibrating_Rectangles
   Ada_GUI.Set_Up (Title => "Vibrating Rectangles");
   Display := Ada_GUI.New_Graphic_Area (Width => 100, Height => 100);
   Signalling.Start;

   Wait_For_End : loop
      Event := Ada_GUI.Next_Event;

      exit Wait_For_End when not Event.Timed_Out and then Event.Event.Kind = Ada_GUI.Window_Closed;
   end loop Wait_For_End;

   Signalling.Stop;

   delay 1.0;

   Ada_GUI.End_GUI;
end Vibrating_Rectangles;
