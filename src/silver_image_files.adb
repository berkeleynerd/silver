with Interfaces.C;
with System;
with Silver_Libc;

package body Silver_Image_Files with SPARK_Mode => On is
   use type Interfaces.C.int;
   use type System.Address;
   use type Model.Byte_Count;
   use type Model.Plan;
   use type Model.Plan_Kind;
   use Silver_Libc;

   procedure Reset_Observations
     with Global => (Output => (Read_Bytes, Copied_Bytes, Written_Bytes,
       Read_Ended, Files_Closed, Rechecked)),
       Post => (Static => Read_Bytes = Copied_Bytes
         and then Read_Bytes = Written_Bytes
         and then Bytes.Length (Read_Bytes) = 0)
   is
   begin
      Read_Bytes := Bytes.Empty_Sequence;
      Copied_Bytes := Bytes.Empty_Sequence;
      Written_Bytes := Bytes.Empty_Sequence;
      Read_Ended := False;
      Files_Closed := False;
      Rechecked := (others => <>);
   end Reset_Observations;

   procedure Put_Byte
     (File : System.Address; Item : Character; Success : out Boolean)
     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),
       Post => (Static => (if Success then
         Written_Bytes = Bytes.Add (Written_Bytes'Old, Item)))
   is
      Status : Interfaces.C.int;
   begin
      Status := C_Put (Interfaces.C.int (Character'Pos (Item)), File);
      Success := Status = Interfaces.C.int (Character'Pos (Item));
      if Success then Written_Bytes := Bytes.Add (Written_Bytes, Item); end if;
   end Put_Byte;

   procedure Put_Insertion
     (File : System.Address; Kind : Model.Insertion_Kind; Success : out Boolean)
     with Global => (In_Out => (Ada.Text_IO.File_System, Written_Bytes)),
       Post => (Static => (if Success then
         Written_Bytes'Old <= Written_Bytes
         and then Bytes.Length (Written_Bytes) = Bytes.Length (Written_Bytes'Old)
           + To_Big_Integer (Model.Insertion_Length (Kind))
         and then (for all I in 1 .. Model.Insertion_Length (Kind) =>
           Bytes.Get (Written_Bytes, Bytes.Length (Written_Bytes'Old)
             + To_Big_Integer (I)) = Model.Insertion_Byte (Kind, I))))
   is
      Before : constant Bytes.Sequence := Written_Bytes with Ghost => Static;
   begin
      Success := True;
      for Position in 1 .. Model.Insertion_Length (Kind) loop
         pragma Loop_Invariant (Static => Before <= Written_Bytes);
         pragma Loop_Invariant (Static => Bytes.Length (Written_Bytes)
           = Bytes.Length (Before) + To_Big_Integer (Position - 1));
         pragma Loop_Invariant (Static =>
           (for all I in 1 .. Position - 1 =>
             Bytes.Get (Written_Bytes, Bytes.Length (Before) + To_Big_Integer (I))
               = Model.Insertion_Byte (Kind, I)));
         Put_Byte (File, Model.Insertion_Byte (Kind, Position), Success);
         exit when not Success;
      end loop;
   end Put_Insertion;

   procedure Snapshot
     (Input_Name, Snapshot_Name : String;
      Plan : out Model.Plan; Success : out Boolean)
   is
      Input, Output : System.Address;
      Item, Status : Interfaces.C.int;
      Current : Model.State := Model.Initial_State;
   begin
      Plan := (others => <>);
      Success := False;
      Reset_Observations;
      Input := C_Open (Interfaces.C.To_C (Input_Name), Interfaces.C.To_C ("rb"));
      if Input = System.Null_Address then return; end if;
      --  Exclusive creation keeps retained observations from being overwritten.
      Output := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C ("wbx"));
      if Output = System.Null_Address then
         Status := C_Close (Input);
         Files_Closed := Status = 0;
         return;
      end if;
      loop
         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);
         pragma Loop_Invariant (Static => Read_Bytes = Written_Bytes);
         Item := C_Get (Input);
         if Item = -1 then
            Read_Ended := True;
            Status := C_Error (Input);
            Success := Status = 0;
            exit;
         elsif Item not in 0 .. 255 then
            Success := False;
            exit;
         end if;
         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));
         Model.Consume (Current, Character'Val (Item));
         Put_Byte (Output, Character'Val (Item), Success);
         if not Success then exit; end if;
         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));
      end loop;
      Status := C_Close (Input);
      Success := Success and then Status = 0;
      Status := C_Close (Output);
      Files_Closed := Status = 0 and then Success;
      Success := Success and then Status = 0;
      Plan := Model.Finish (Current);
      Rechecked := Plan;
      Success := Success and then Plan.Kind /= Model.Invalid_Model;
   end Snapshot;

   procedure Refine
     (Snapshot_Name, Refined_Name : String;
      Plan : Model.Plan; Success : out Boolean)
   is
      Input, Output : System.Address;
      Item, Status : Interfaces.C.int;
      Current : Model.State := Model.Initial_State;
      Position : Model.Byte_Count := 0;
      Declarations_Done, Includes_Done : Boolean := False;
      Checked : Model.Plan;
   begin
      Success := False;
      Reset_Observations;
      Input := C_Open (Interfaces.C.To_C (Snapshot_Name), Interfaces.C.To_C ("rb"));
      if Input = System.Null_Address then return; end if;
      Output := C_Open (Interfaces.C.To_C (Refined_Name), Interfaces.C.To_C ("wbx"));
      if Output = System.Null_Address then
         Status := C_Close (Input);
         Files_Closed := Status = 0;
         return;
      end if;
      loop
         pragma Loop_Invariant (Static => Read_Bytes = Copied_Bytes);
         pragma Loop_Invariant (Static =>
           Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Position));
         pragma Loop_Invariant (Declarations_Done = (Position > Plan.Declarations_Offset));
         pragma Loop_Invariant (Includes_Done = (Position > Plan.Includes_Offset));
         Item := C_Get (Input);
         if Item = -1 then
            Read_Ended := True;
            Status := C_Error (Input);
            Success := Status = 0 and then Position = Plan.Bytes
              and then Declarations_Done and then Includes_Done;
            exit;
         elsif Item not in 0 .. 255 or else Position = Model.Byte_Count'Last then
            Success := False;
            exit;
         end if;
         if Position = Plan.Declarations_Offset then
            Put_Insertion (Output, Model.Declarations_Insertion, Success);
            if not Success then exit; end if;
            Declarations_Done := True;
         elsif Position = Plan.Includes_Offset then
            Put_Insertion (Output, Model.Includes_Insertion, Success);
            if not Success then exit; end if;
            Includes_Done := True;
         end if;
         Read_Bytes := Bytes.Add (Read_Bytes, Character'Val (Item));
         Model.Consume (Current, Character'Val (Item));
         Put_Byte (Output, Character'Val (Item), Success);
         if not Success then exit; end if;
         Copied_Bytes := Bytes.Add (Copied_Bytes, Character'Val (Item));
         Position := Position + 1;
      end loop;
      Status := C_Close (Input);
      Success := Success and then Status = 0;
      Status := C_Close (Output);
      Files_Closed := Status = 0 and then Success;
      Success := Success and then Status = 0;
      Checked := Model.Finish (Current);
      Rechecked := Checked;
      Success := Success and then Checked = Plan;
   end Refine;
end Silver_Image_Files;
