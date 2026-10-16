with Ada.Command_Line;
with Ada.Text_IO;
with Silver_Runtime;
with Silver_Process_Runtime;
with Silver_Platform;
with Silver_Image_Model;
with Silver_Image_Files;
with Silver_Image_Install;
with Silver_Image_Config;
with Silver_Image_Runtime;

procedure Silver_Image_Adapter with SPARK_Mode => On is
   use Silver_Runtime;
   use Silver_Process_Runtime;
   use Silver_Platform;
   use type Silver_Image_Model.Plan_Kind;
   Count : constant Natural := Argument_Count;
   Native_Succeeded : Boolean;

   type Failure_Kind is
     (Too_Many_Arguments, Invalid_Argument, Invalid_Native_Path, Native_Spawn,
      Proof_Argument, Workspace_Creation, Snapshot_Path, Snapshot_Model,
      Unexpected_Plan, Proof_Path, Theory_Installation, Model_Refinement, Input_Path);

   function Reason (Kind : Failure_Kind) return String is
     (case Kind is
        when Too_Many_Arguments => "too many arguments",
        when Invalid_Argument => "argument contains NUL",
        when Invalid_Native_Path => "invalid configured native gnatwhy3 path",
        when Native_Spawn => "could not execute native gnatwhy3",
        when Proof_Argument => "duplicate or missing proof-directory argument",
        when Workspace_Creation => "cannot create private adapter workspace",
        when Snapshot_Path => "invalid private model snapshot path",
        when Snapshot_Model => "cannot read or snapshot a valid input model",
        when Unexpected_Plan => "unsupported input model plan",
        when Proof_Path => "invalid or overlong proof-directory path",
        when Theory_Installation => "cannot install or verify Image theory in proof directory",
        when Model_Refinement => "cannot write or validate refined model",
        when Input_Path => "invalid or overlong input model path");

   procedure Failure (Kind : Failure_Kind)
     with Global => (In_Out => Ada.Text_IO.File_System,
       Output => Silver_Runtime.Exit_State)
   is
   begin
      Ada.Text_IO.Put_Line
        ("{""error"":""Silver Image adapter: " & Reason (Kind)
         & """,""internal"":false,""results"":[]}");
      Set_Exit_Status (3);
   end Failure;

   function Valid_Argument (Item : String) return Boolean is
     (for all Ch of Item => Ch /= Character'Val (0));

   procedure Native
     (Replacement, Added_Proof_Directory : String; Success : out Boolean)
     with Pre => Count <= Natural'Last - 2
       and then Valid_Argument (Replacement)
       and then Valid_Argument (Added_Proof_Directory)
       and then (if Replacement'Length /= 0 then Count > 0)
   is
      Extra : constant Natural := (if Added_Proof_Directory'Length = 0 then 0 else 2);
      Args : Argument_List_Access := new Argument_List (1 .. Count + Extra);
      Status : Integer;
   begin
      Success := False;
      for Index in 1 .. Count loop
         pragma Loop_Invariant
           (for all Previous in 1 .. Index - 1 =>
             Args (Previous) /= null and then Valid_Argument (Args (Previous).all));
         pragma Loop_Invariant
           (Static => (for all Previous in 1 .. Index - 1 =>
             Args (Previous) /= null and then Args (Previous).all =
               (if Previous = Count and then Replacement'Length /= 0
                then Replacement else Argument (Previous))));
         declare
            Item : constant String := Argument (Index);
         begin
            if not Valid_Argument (Item) then
               Free_List (Args);
               pragma Assert (Args = null);
               Failure (Invalid_Argument);
               return;
            end if;
            Args (Index) := new String'
              (if Index = Count and then Replacement'Length /= 0 then Replacement else Item);
         end;
      end loop;
      if Extra = 2 then
         Args (Count + 1) := new String'("--proof-dir");
         Args (Count + 2) := new String'(Added_Proof_Directory);
      end if;
      if not Valid_Path (Silver_Image_Config.Native_Gnatwhy3) then
         Free_List (Args);
         pragma Assert (Args = null);
         Failure (Invalid_Native_Path);
         return;
      end if;
      pragma Assert
        (Static => Args'First = 1 and then Args'Last = Count + Extra
         and then (for all Index in 1 .. Count => Args (Index) /= null
           and then Args (Index).all =
             (if Index = Count and then Replacement'Length /= 0
              then Replacement else Argument (Index)))
         and then (if Extra = 2 then
           Args (Count + 1) /= null and then Args (Count + 1).all = "--proof-dir"
           and then Args (Count + 2) /= null
           and then Args (Count + 2).all = Added_Proof_Directory));
      Status := Spawn (Silver_Image_Config.Native_Gnatwhy3, Args.all);
      Free_List (Args);
      pragma Assert (Args = null);
      if Status in 0 .. 255 then
         Set_Exit_Status (Ada.Command_Line.Exit_Status (Status));
         Success := Status = 0;
      else
         Failure (Native_Spawn);
      end if;
   end Native;

   procedure Release_Workspace (Directory : Workspace_Path; Supplied_Proof : Boolean) is
      Args : Argument_List_Access;
      Status : Integer;
   begin
      if Silver_Image_Runtime.Environment_Value
        ("SILVER_KEEP_IMAGE_WORKSPACES", "") = "1"
      then
         return;
      end if;
      --  This is only called for the workspace just created by this invocation,
      --  after successful synchronous native completion. Check the exact private
      --  namespace again at runtime; never accept a supplied proof directory.
      if not Valid_Path (Directory)
        or else Directory (1 .. Image_Workspace_Prefix'Length) /= Image_Workspace_Prefix
        or else not (for all Index in Image_Workspace_Prefix'Last + 1 .. Directory'Last =>
          Directory (Index) in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9')
      then
         return;
      end if;
      if Supplied_Proof then
         --  A caller-selected proof directory might even be inside this new
         --  workspace. Remove only our exact snapshots and an empty directory;
         --  never recursively remove caller-selected theories or sessions.
         Args := new Argument_List'
           (new String'("-fd"), new String'("--"),
            new String'(Directory & "/original.gnat-json"),
            new String'(Directory & "/refined.gnat-json"), new String'(Directory));
      else
         Args := new Argument_List'
           (new String'("-rf"), new String'("--"), new String'(Directory));
      end if;
      Status := Spawn ("/bin/rm", Args.all);
      Free_List (Args);
      pragma Assert (Args = null);
      if Status /= 0 then
         --  rm retains its inherited stderr. Native JSON is already complete;
         --  preserve that stream, its status and any files left after failure.
         return;
      end if;
   end Release_Workspace;

   procedure Process_Input (Input : String)
     with Pre => Count in 1 .. Natural'Last - 2 and then Valid_Path (Input)
   is
      Directory : Workspace_Path;
      Plan : Silver_Image_Model.Plan;
      Success, Native_OK : Boolean;
      Proof_Index : Natural := 0;
      Inline_Proof : Boolean := False;
   begin
      --  Keep the original option order and value. Ambiguous duplicate or
      --  missing proof-directory arguments are infrastructure errors.
      for Index in 1 .. Count - 1 loop
         pragma Loop_Invariant (Proof_Index <= Count - 1);
         pragma Loop_Invariant (if Inline_Proof then Proof_Index > 0
           and then Argument (Proof_Index)'Length >= 12);
         declare
            Item : constant String := Argument (Index);
         begin
            if Item = "--proof-dir" then
               if Proof_Index /= 0 or else Index >= Count - 1 then
                  Failure (Proof_Argument); return;
               end if;
               Proof_Index := Index + 1;
            elsif Item'Length >= 12 and then Item (Item'First .. Item'First + 11) = "--proof-dir=" then
               if Proof_Index /= 0 then Failure (Proof_Argument); return; end if;
               Proof_Index := Index;
               Inline_Proof := True;
            end if;
         end;
      end loop;
      Create_Workspace (Directory, Success, For_Image => True);
      if not Success then Failure (Workspace_Creation); return; end if;
      declare
         Snapshot : constant String := Directory & "/original.gnat-json";
         Refined : constant String := Directory & "/refined.gnat-json";
      begin
         if not Valid_Path (Snapshot) or else not Valid_Path (Refined)
           or else Snapshot = Input
         then
            Failure (Snapshot_Path); return;
         end if;
         Silver_Image_Files.Snapshot (Input, Snapshot, Plan, Success);
         if not Success then Failure (Snapshot_Model); return; end if;
         if Plan.Kind = Silver_Image_Model.Unchanged then
            --  The native model needs no added theorem; preserve its argv.
            Native ("", "", Native_OK);
            if Native_OK then Release_Workspace (Directory, Proof_Index /= 0); end if;
            return;
         end if;
         if Plan.Kind /= Silver_Image_Model.Refine then Failure (Unexpected_Plan); return; end if;
         declare
            Raw : constant String := (if Proof_Index = 0 then Directory else Argument (Proof_Index));
            Supplied : constant String (1 .. Raw'Length) := Raw;
            Selected : constant String :=
              (if Inline_Proof then Supplied (13 .. Supplied'Last) else Supplied);
         begin
            if not Valid_Path (Selected) or else Selected'Length > Max_Path_Length - 64 then
               Failure (Proof_Path); return;
            end if;
            Silver_Image_Install.Ensure_Theory (Selected, Success);
            if not Success then Failure (Theory_Installation); return; end if;
            Silver_Image_Files.Refine (Snapshot, Refined, Plan, Success);
            if not Success then Failure (Model_Refinement); return; end if;
            Native (Refined, (if Proof_Index = 0 then Selected else ""), Native_OK);
            if Native_OK then Release_Workspace (Directory, Proof_Index /= 0); end if;
         end;
      end;
   end Process_Input;
begin
   Set_Exit_Status (3);
   if Count > Natural'Last - 2 then
      Failure (Too_Many_Arguments);
   elsif Count = 0 then
      Native ("", "", Native_Succeeded);
   else
      declare
         Last : constant String := Argument (Count);
      begin
         if Last'Length >= 10 and then Last (Last'Last - 9 .. Last'Last) = ".gnat-json" then
            if Valid_Path (Last) then Process_Input (Last); else Failure (Input_Path); end if;
         else
            Native ("", "", Native_Succeeded);
         end if;
      end;
   end if;
end Silver_Image_Adapter;
