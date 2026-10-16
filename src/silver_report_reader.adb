with Interfaces.C;
with System;
with Silver_Libc;

package body Silver_Report_Reader with SPARK_Mode => On is
   use type Interfaces.C.int;
   use type System.Address;
   use type Silver_Report_Projection.State;
   use Silver_Libc;

   procedure Read_Report
     (Name : String; Buffer : out String; Last : out Natural;
      Too_Long : out Boolean; Success : out Boolean)
   is
      Current : Silver_Report_Projection.State := Silver_Report_Projection.Initial_State;
      File : System.Address;
      Item, Status : Interfaces.C.int;
   begin
      Buffer := (others => Character'Val (0));
      Last := 0;
      Too_Long := False;
      Success := False;
      Raw_Bytes := Model.Byte_Sequences.Empty_Sequence;
      Projected_Bytes := Model.Byte_Sequences.Empty_Sequence;
      Report_Bytes := (others => Character'Val (0));
      Report_Length := 0;
      Report_State := Silver_Report_Projection.Initial_State;
      Report_Ended := False;
      Report_Closed := False;
      File := C_Open (Interfaces.C.To_C (Name), Interfaces.C.To_C ("rb"));
      if File = System.Null_Address then return; end if;

      loop
         pragma Loop_Invariant (Last <= Buffer'Length);
         pragma Loop_Invariant (not Success and then not Too_Long);
         pragma Loop_Invariant (Static => Report_Length = Last);
         pragma Loop_Invariant (Static => Report_State = Current);
         pragma Loop_Invariant (Static => Model.Refines (Raw_Bytes, Projected_Bytes, Current));
         pragma Loop_Invariant (Static => Model.Matches (Projected_Bytes, Buffer, Last));
         pragma Loop_Invariant (Static =>
           Buffer (1 .. Last) = Report_Bytes (1 .. Report_Length));
         Item := C_Get (File);
         if Item = -1 then
            Report_Ended := True;
            Status := C_Error (File);
            Success := Status = 0 and then Silver_Report_Projection.Complete (Current);
            exit;
         elsif Item not in 0 .. 255 then
            exit;
         end if;
         declare
            Next : constant Silver_Report_Projection.Transition :=
              Silver_Report_Projection.Advance (Current, Character'Val (Item));
         begin
            --  Record precisely the byte returned by this libc call. The
            --  mathematical sequence has no machine-sized length bound.
            Model.Extend_Observations
              (Raw_Bytes, Projected_Bytes, Current, Character'Val (Item));
            Raw_Bytes := Model.Byte_Sequences.Add (Raw_Bytes, Character'Val (Item));
            Projected_Bytes := Model.Append_Emission (Projected_Bytes, Next);
            Current := Next.Following;
            Report_State := Next.Following;
            if Current.Failed then exit; end if;
            if Next.Length > Buffer'Length - Last then
               Too_Long := True;
               exit;
            end if;
            Buffer (Last + 1 .. Last + Next.Length) := Next.Bytes (1 .. Next.Length);
            Report_Bytes (Report_Length + 1 .. Report_Length + Next.Length) :=
              Next.Bytes (1 .. Next.Length);
            Last := Last + Next.Length;
            Report_Length := Report_Length + Next.Length;
         end;
      end loop;
      Status := C_Close (File);
      Report_Closed := Status = 0;
      Success := Success and then Status = 0;
   end Read_Report;
end Silver_Report_Reader;
