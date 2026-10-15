with Cairo;                        use Cairo;
with Cairo.Ellipses;               use Cairo.Ellipses;
with Gdk.Color;                    use Gdk.Color;
with GLib;                         use GLib;
with Gtk.Layered;                  use Gtk.Layered;
with Gtk.Layered.Line;             use Gtk.Layered.Line;
with Gtk.Layered.Refresh_Engine;   use Gtk.Layered.Refresh_Engine;
with Gtk.Missed;                   use Gtk.Missed;
with Gtk.Window;                   use Gtk.Window;
with Gtk.Widget;                   use Gtk.Widget;

with GLib.Object.Checked_Destroy;
with Gtk.Main;

procedure Fading_Rectangles is

   type Refresher is new Layered_Refresh_Engine with null record;
   overriding
      procedure Refresh (Engine : in out Refresher);

   Window  : Gtk_Window;
   Size    : constant := 130;
   Color   : constant Gdk_Color := RGB (0.0, 0.0, 1.0);
   Engine  : Refresher;

   type Rectangle is array (1..4) of access Line_Layer;
   function Create
            (  Widget    : Gtk_Layered;
               Center    : Cairo_Tuple;
               Half_Size : GDouble
            )  return Rectangle is
   begin
      return
      (  Add_Line
         (  Under => Widget,
            From  => (Center.X - Half_Size, Center.Y - Half_Size),
            To    => (Center.X - Half_Size, Center.Y + Half_Size),
            Color => Color
         ),
         Add_Line
         (  Under => Widget,
            From  => (Center.X + Half_Size, Center.Y - Half_Size),
            To    => (Center.X + Half_Size, Center.Y + Half_Size),
            Color => Color
         ),
         Add_Line
         (  Under => Widget,
            From  => (Center.X - Half_Size, Center.Y - Half_Size),
            To    => (Center.X + Half_Size, Center.Y - Half_Size),
            Color => Color
         ),
         Add_Line
         (  Under => Widget,
            From  => (Center.X - Half_Size, Center.Y + Half_Size),
            To    => (Center.X + Half_Size, Center.Y + Half_Size),
            Color => Color
      )  );
   end Create;

   type Rectangle_No is mod 20;
   type Vibration    is mod 10;
   List    : array (Rectangle_No) of Rectangle;
   Current : Rectangle_No := 0;
   Opacity : Vibration    := Vibration'Last;

   function Create return Gtk_Widget is
      Widget  : Gtk_Layered;
      Center  : constant Cairo_Tuple :=
                         (GDouble (Size / 2), GDouble (Size / 2));
   begin
      Gtk_New (Widget);
      for Index in List'Range loop
         List (Index) :=
            Create (Widget, Center, 3.0 * GDouble (Index - 1) + 1.0);
      end loop;
      Engine.Add (Widget);
      return Widget.all'Unchecked_Access;
   end Create;

   procedure Refresh (Engine : in out Refresher) is
   begin
      Current := Current - 1;
      declare
         This : Rectangle renames List (Current);
      begin
         for Index in This'Range loop
            declare
               Line : Line_Layer renames This (Index).all;
            begin
               Line.Set
               (  From    => Line.Get_From,
                  To      => Line.Get_To,
                  Line    => Line.Get_Line,
                  Opacity => GDouble (Opacity) / GDouble (Vibration'Last)
               );
            end;
         end loop;
         if Current = 0 then
            Opacity := Opacity - 1;
         end if;
      end;
      Layered_Refresh_Engine (Engine).Refresh;
   end Refresh;

begin
   Gtk.Main.Init;
   Gtk.Window.Gtk_New (Window);
   Window.Set_Title ("Fading");
   Window.On_Delete_Event (Gtk.Missed.Delete_Event_Handler'Access);
   Window.On_Destroy (Gtk.Missed.Destroy_Handler'Access);
   Window.Set_Size_Request (Size, Size);
   Window.Add (Create);
   Set_Period (Engine, 0.02);
   Window.Show_All;
   Gtk.Main.Main;
end Fading_Rectangles;
