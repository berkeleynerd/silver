with Ada.Command_Line;
with Ada.Text_IO;
with Interfaces.C;
with Silver_Runtime;
with Silver_Platform;
with Silver_Profile;
with Silver_Reports;
with Silver_Library_Reports;
with Silver_Build;
with Silver_Output_Profile;
with Silver_Libraries;
with Silver_Catalogue;
with Silver_Numbers;
with Silver_Report_Storage;
with Silver_Report_Reader;
with Silver_Report_Projection_Audit;

procedure Silver with SPARK_Mode => On is
   use Ada.Text_IO;
   use Silver_Platform;

   procedure Failure (Message : String; Status : Ada.Command_Line.Exit_Status := 3)
   is
   begin
      Put_Line (Message);
      Silver_Runtime.Set_Exit_Status (Status);
   end Failure;

   function Valid_Command (Command : String) return Boolean is
     (Command'Length in 1 .. 16_384
      and then (for all Item of Command => Item /= Character'Val (0)));

   procedure Execute (Command : String; Success : out Boolean)
     with Post => (Runtime => (if not Valid_Command (Command) then not Success),
       Static => (if Valid_Command (Command) then
       Command_Length = Command'Length
       and then Command_Text (1 .. Command_Length) = Command
       and then Success = Interfaces.C."=" (Command_Status, 0)))
   is
   begin
      if not Valid_Command (Command) then
         Success := False;
         return;
      end if;
      Run (Command, Success);
   end Execute;

   procedure Same_Source
     (Name, Expected : String; Observed : out String;
      Last : out Natural; Success : out Boolean)
     with Pre => Valid_Path (Name) and then Observed'First = 1
       and then Observed'Length = Silver_Profile.Max_Source_Length,
       Post => (Runtime => Last <= Observed'Length
         and then (if Success then
           Observed (Observed'First .. Last) = Expected),
         Static => (if Success then Read_Ended and then Read_Closed
           and then Last = Read_Count
           and then Read_Bytes (1 .. Read_Count) = Expected))
   is
      Too_Long : Boolean;
   begin
      Read_File (Name, Observed, Last, Too_Long, Success);
      Success := Success and then not Too_Long
        and then Observed (Observed'First .. Last) = Expected;
   end Same_Source;

   procedure Compile
     (Source : String; Output_Mode, Run_After : Boolean; Skip_Arguments : Natural)
     with Pre => (Runtime => Source'Length <= Silver_Profile.Max_Source_Length
                    and then Skip_Arguments <= Silver_Runtime.Argument_Count
                    and then (if not Output_Mode then Silver_Profile.Is_Member (Source)),
                  Static => (if Output_Mode then Silver_Output_Profile.Is_Member (Source)
                             else Silver_Profile.Is_Member (Source)))
   is
      Directory : Workspace_Path;
      Success : Boolean;
   begin
      Create_Workspace (Directory, Success);
      if not Success then
         Failure ("Infrastructure error: cannot create a fresh build directory.");
         return;
      end if;

      declare
         Functions : constant Silver_Library_Reports.Function_Metadata :=
           Silver_Output_Profile.Local_Functions (Source);
         Procedures : constant Silver_Library_Reports.Procedure_Metadata :=
           Silver_Output_Profile.Local_Procedures (Source);
         Argument_Mode : constant Boolean := Silver_Output_Profile.Uses_Arguments (Source);
         Assignment_Mode : constant Boolean := Silver_Output_Profile.Uses_Assignment (Source);
         Application_Kind : constant Silver_Library_Reports.Application_Kind :=
           (if Argument_Mode then
              (if Assignment_Mode then Silver_Library_Reports.Selected_Output
               else Silver_Library_Reports.Argument_Output)
            elsif Assignment_Mode then Silver_Library_Reports.Assigned_Output
            else Silver_Library_Reports.Static_Output);
         Snapshot : constant String := Directory & "/main.adb";
         Project : constant String := Directory & "/program.gpr";
         Report_Name : constant String := Directory & "/obj/gnatprove/main~1.spark";
         Executable : constant String := Directory & "/bin/main";
         --  Bootstrap quotes the fixed installation path. mkdtemp supplies
         --  only the checked six-character alphanumeric suffix below.
         Shell_Directory : constant String :=
           Silver_Build.Quoted_Root_Directory & "/program-"
           & Directory (Directory'Last - 5 .. Directory'Last);
         LF : constant Character := Character'Val (10);
         Project_Text : constant String :=
           "project Program is" & LF &
           "   for Languages use (""Ada"");" & LF &
           "   for Source_Dirs use (""."");" & LF &
           (if Output_Mode then
             "   for Source_Files use (""main.adb"", ""silver_io.ads"", ""silver_io.adb"", ""silver_output_libc.ads"", ""silver_arguments.ads"", ""silver_arguments.adb"", ""silver_runtime.ads"");" & LF
            else "   for Source_Files use (""main.adb"");" & LF) &
           "   for Main use (""main.adb"");" & LF &
           "   for Object_Dir use ""obj"";" & LF &
           "   for Exec_Dir use ""bin"";" & LF &
           --  Admission establishes one library-level Main. Its explicit
           --  index bypasses GPR2's LF-only comment scan without changing
           --  the authoritative source (whose comments may end at CR).
           "   package Naming is" & LF &
           "      for Body (""Main"") use ""main.adb"" at 1;" & LF &
           "   end Naming;" & LF &
           "   package Compiler is" & LF &
           "      for Default_Switches (""Ada"") use (""-gnat2022"", ""-gnata"", ""-gnato"");" & LF &
           "   end Compiler;" & LF &
           "end Program;" & LF;
         Proof_Command : constant String :=
           Silver_Build.Alire_Exec & Silver_Build.Image_Gnatprove & " -P " & Shell_Directory & "/program.gpr" &
           " -U --mode=all --report=all" &
           (if Output_Mode then " --warnings=continue" else " --warnings=error") &
           " --checks-as-errors=on" &
           " --level=2 --prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000 -j0" &
           " --no-loop-unrolling" &
           (if Functions.Count > 0 or else Procedures.Count > 0 then " --no-inlining" else "");
         --  The pinned native frontend must not replace a variable by an
         --  inner guard's value while losing its enclosing path facts.
         --  -gnatdM disables that optimization; runtime checks stay enabled.
         --  Apply it only to native compilation, not GNATprove's frontend.
         Build_Command : constant String :=
           Silver_Build.Alire_Exec & "gprbuild -P " & Shell_Directory & "/program.gpr -p -cargs:Ada -gnatdM";
         Observed : String (1 .. Silver_Profile.Max_Source_Length) :=
           (others => Character'Val (0));
         Observed_Last : Natural := 0;
         Report : String renames Silver_Report_Storage.Bytes;
         Report_Last : Natural;
         Report_Read : Boolean;
         Report_Too_Long : Boolean;
         Report_Complete : Boolean;
         Library_Sources : Silver_Libraries.Source_Set :=
           (Bytes => (others => (others => Character'Val (0))), Lengths => (others => 0));
         Runtime_Evidence_Complete : Boolean := False;
         Initial_Libraries_Matched, Proof_Libraries_Matched, Build_Libraries_Matched : Boolean := False
           with Ghost => Static;

         --  Past observations are recorded from actual return values and
         --  returned bytes. They never decide executable control flow.
         Source_Written : Boolean with Ghost => Static;
         Initial_Source_Matched : Boolean with Ghost => Static;
         Project_Written : Boolean with Ghost => Static;
         Proof_Returned_Success : Boolean with Ghost => Static;
         Proof_Command_Matched : Boolean with Ghost => Static;
         Proof_Source_Matched : Boolean with Ghost => Static;
         Build_Returned_Success : Boolean with Ghost => Static;
         Build_Command_Matched : Boolean with Ghost => Static;

         Raw_Application_Report : Silver_Report_Reader.Model.Byte_Sequences.Sequence with Ghost => Static;
         Application_Report_Read_Complete : Boolean with Ghost => Static;

         --  Keep the streaming observation proof local to report loading;
         --  callers use the established audit result and exact returned slice.
         procedure Read_Proof
           with Pre => Valid_Path (Report_Name),
             Post => (Runtime => Report_Last <= Report'Length
               and then (if Report_Complete then Report_Read and then not Report_Too_Long),
               Static => (if Report_Complete then
                 (if Output_Mode then
                    Application_Report_Read_Complete
                    and then Silver_Library_Reports.Unbounded_Application_Report_Policy
                      (Raw_Application_Report, Application_Kind, Source, Functions, Procedures)
                    and then Silver_Library_Reports.Application_Report_Policy
                      (Report (1 .. Report_Last), Application_Kind, Source, Functions, Procedures)
                  else Silver_Reports.Recognizes_Null_Report (Report (1 .. Report_Last)))))
         is
         begin
            Application_Report_Read_Complete := False;
            Raw_Application_Report := Silver_Report_Reader.Model.Byte_Sequences.Empty_Sequence;
            if Output_Mode then
               Silver_Report_Reader.Read_Report
                 (Report_Name, Report, Report_Last, Report_Too_Long, Report_Read);
            else
               --  The null recognizer has its own raw-text policy.
               Read_File (Report_Name, Report, Report_Last, Report_Too_Long, Report_Read);
            end if;
            Report_Complete := False;
            if Report_Read and then not Report_Too_Long then
               if Output_Mode then
                  Silver_Report_Projection_Audit.Application
                    (Silver_Report_Reader.Raw_Bytes, Silver_Report_Reader.Projected_Bytes,
                     Silver_Report_Reader.Report_State, Report, Report_Last, Application_Kind, Source, Functions, Procedures);
                  Raw_Application_Report := Silver_Report_Reader.Raw_Bytes;
                  Application_Report_Read_Complete :=
                    Silver_Report_Reader.Report_Ended and then Silver_Report_Reader.Report_Closed;
               end if;
               Report_Complete := (if Output_Mode then
                 Silver_Library_Reports.Complete_Application_Proof
                   (Report (1 .. Report_Last), Application_Kind, Source, Functions, Procedures)
                else Silver_Reports.Complete_Null_Proof (Report (1 .. Report_Last)));
            end if;
         end Read_Proof;

         procedure Prove
           with Pre => (Runtime => Valid_Command (Proof_Command),
             Static => Source_Written and then Initial_Source_Matched and then Project_Written
               and then (if Output_Mode then Initial_Libraries_Matched)),
             Post => (Static => Proof_Returned_Success = Success
               and then (if Success then Proof_Command_Matched))
         is
         begin
            Execute (Proof_Command, Success);
            Proof_Returned_Success := Success;
            Proof_Command_Matched := Success
              and then Command_Text (1 .. Command_Length) = Proof_Command
              and then Interfaces.C."=" (Command_Status, 0);
         end Prove;

         procedure Build
           with Pre => (Runtime =>
             Valid_Command (Build_Command)
             and then Report_Read and then not Report_Too_Long
             and then Report_Last <= Report'Length
             and then Report_Complete
             and then (if Output_Mode then Runtime_Evidence_Complete),
             Static => Source_Written and then Initial_Source_Matched and then Project_Written
               and then Proof_Returned_Success and then Proof_Command_Matched
               and then Proof_Source_Matched
               and then (if Output_Mode then Initial_Libraries_Matched and then Proof_Libraries_Matched)
               and then Report_Last <= Report'Length
               and then (if Output_Mode then
                 Application_Report_Read_Complete
                 and then Silver_Library_Reports.Unbounded_Application_Report_Policy
                   (Raw_Application_Report, Application_Kind, Source, Functions, Procedures)
                 and then Silver_Libraries.Audited_Raw_Reports
                 and then Silver_Library_Reports.Application_Report_Policy
                   (Report (1 .. Report_Last), Application_Kind, Source, Functions, Procedures)
                else Silver_Reports.Recognizes_Null_Report (Report (1 .. Report_Last)))),
             Post => (Static => Build_Returned_Success = Success
               and then (if Success then Build_Command_Matched))
         is
         begin
            Execute (Build_Command, Success);
            Build_Returned_Success := Success;
            Build_Command_Matched := Success
              and then Command_Text (1 .. Command_Length) = Build_Command
              and then Interfaces.C."=" (Command_Status, 0);
         end Build;

         procedure Publish
           with Pre => (Runtime =>
             Valid_Path (Snapshot) and then Valid_Path (Report_Name)
             and then Valid_Path (Executable)
             and then Skip_Arguments <= Silver_Runtime.Argument_Count
             and then Report_Read and then not Report_Too_Long
             and then Report_Last <= Report'Length
             and then Report_Complete
             and then (if Output_Mode then Runtime_Evidence_Complete)
             and then (if not Output_Mode then Silver_Profile.Is_Member (Source))
             and then Success and then Observed_Last <= Observed'Length
             and then Observed (1 .. Observed_Last) = Source,
             Static => Source_Written and then Initial_Source_Matched and then Project_Written
               and then Proof_Returned_Success and then Proof_Command_Matched
               and then Proof_Source_Matched
               and then Build_Returned_Success and then Build_Command_Matched
               and then (if Output_Mode then Silver_Output_Profile.Is_Member (Source)
                 and then Initial_Libraries_Matched and then Proof_Libraries_Matched
                 and then Build_Libraries_Matched else Silver_Profile.Is_Member (Source))
               and then Report_Last <= Report'Length
               and then (if Output_Mode then
                 Application_Report_Read_Complete
                 and then Silver_Library_Reports.Unbounded_Application_Report_Policy
                   (Raw_Application_Report, Application_Kind, Source, Functions, Procedures)
                 and then Silver_Libraries.Audited_Raw_Reports
                 and then Silver_Library_Reports.Application_Report_Policy
                   (Report (1 .. Report_Last), Application_Kind, Source, Functions, Procedures)
                else Silver_Reports.Recognizes_Null_Report (Report (1 .. Report_Last))))
         is
            Status : Integer;
         begin
            Put_Line ("Source: " & Snapshot);
            Put_Line ("Proof: " & Report_Name);
            Put_Line ("Executable: " & Executable);
            if Run_After then
               Run_Application (Executable, Skip_Arguments, Status);
               if Status not in 0 .. 255 then
                  Failure ("Execution failed: application did not exit normally.");
                  return;
               end if;
               Silver_Runtime.Set_Exit_Status (Ada.Command_Line.Exit_Status (Status));
               if Status /= 0 then
                  Put_Line ("Execution returned status " & Silver_Numbers.Decimal (Status) & ".");
                  return;
               end if;
               Put_Line ("Execution completed successfully.");
            end if;
         end Publish;
      begin
         --  No user-supplied path is interpolated into a shell command. All
         --  command paths below use the checked private workspace name.
         pragma Assert (Static =>
           Valid_Command (Proof_Command) and then Valid_Command (Build_Command)
             and then Valid_Path (Executable));
         pragma Assert
           (Valid_Path (Snapshot) and then Valid_Path (Project)
            and then Valid_Path (Report_Name)
            and then Source'Length <= Max_File_Length);
         if not Valid_Path (Snapshot) or else not Valid_Path (Project)
           or else not Valid_Path (Report_Name)
           or else Source'Length > Max_File_Length
         then
            Failure ("Implementation error: invalid build path or source length.");
            return;
         end if;
         Write_File (Snapshot, Source, Success);
         Source_Written := Success and then Write_Closed
           and then Written_Count = Source'Length
           and then Written_Bytes (1 .. Written_Count) = Source;
         if Success then
            Same_Source (Snapshot, Source, Observed, Observed_Last, Success);
         end if;
         Initial_Source_Matched := Success
           and then Observed (1 .. Observed_Last) = Source;
         if not Success then
            Failure ("Infrastructure error: cannot create an identical source snapshot.");
            return;
         end if;
         if Output_Mode then
            Silver_Libraries.Capture_And_Snapshot (Directory, Library_Sources, Success);
            --  The verified helper reports success only after capturing, writing
            --  and rereading the exact six library byte sequences.
            Initial_Libraries_Matched := Success
              and then Silver_Libraries.Same_Bytes
                (Silver_Libraries.Checked, Library_Sources)
              and then Silver_Libraries.Bound_To_Compiler (Library_Sources);
            if not Success then
               Failure ("Infrastructure error: cannot create identical runtime library snapshots.");
               return;
            end if;
         end if;
         Write_File (Project, Project_Text, Success);
         Project_Written := Success and then Write_Closed
           and then Written_Count = Project_Text'Length
           and then Written_Bytes (1 .. Written_Count) = Project_Text;
         if not Success then
            Failure ("Infrastructure error: cannot write project file.");
            return;
         end if;

         Prove;
         if not Success then
            Failure ("Verification failure for admitted Silver: toolchain or implementation defect.");
            return;
         end if;
         Read_Proof;
         if not Report_Read or else Report_Too_Long then
            Failure ("Verification failure for admitted Silver: missing or incomplete proof evidence.");
            return;
         end if;
         if not Report_Complete then
            Failure ("Verification failure for admitted Silver: missing or incomplete proof evidence.");
            return;
         end if;
         if Output_Mode then
            Silver_Libraries.Check_Proof_Evidence (Directory, Runtime_Evidence_Complete);
            if not Runtime_Evidence_Complete then
               Failure ("Verification failure for admitted Silver: missing or incomplete runtime library evidence.");
               return;
            end if;
            Silver_Libraries.Same_Sources (Directory, Library_Sources, Success);
            --  Same_Sources' successful-return contract establishes exact equality.
            Proof_Libraries_Matched := Success
              and then Silver_Libraries.Same_Bytes
                (Silver_Libraries.Checked, Library_Sources)
              and then Silver_Libraries.Bound_To_Compiler (Library_Sources);
            if not Success then
               Failure ("Infrastructure error: runtime library changed during verification.");
               return;
            end if;
         end if;
         Same_Source (Snapshot, Source, Observed, Observed_Last, Success);
         Proof_Source_Matched := Success
           and then Observed (1 .. Observed_Last) = Source;
         if not Success then
            Failure ("Infrastructure error: source changed during verification.");
            return;
         end if;
         Build;
         if not Success then
            Failure ("Compilation failure for admitted Silver: toolchain or implementation defect.");
            return;
         end if;
         Same_Source (Snapshot, Source, Observed, Observed_Last, Success);
         if not Success then
            Failure ("Infrastructure error: source changed during compilation.");
            return;
         end if;
         if Output_Mode then
            Silver_Libraries.Same_Sources (Directory, Library_Sources, Success);
            Build_Libraries_Matched := Success
              and then Silver_Libraries.Same_Bytes
                (Silver_Libraries.Checked, Library_Sources)
              and then Silver_Libraries.Bound_To_Compiler (Library_Sources);
            if not Success then
               Failure ("Infrastructure error: runtime library changed during compilation.");
               return;
            end if;
         end if;
         Publish;
      end;
   end Compile;

begin
   Silver_Runtime.Set_Exit_Status (0);
   if Silver_Runtime.Argument_Count = 1
     and then Silver_Runtime.Argument (1) = "catalogue"
   then
      Silver_Catalogue.Export;
      return;
   end if;
   if Silver_Runtime.Argument_Count < 2 then
      Failure ("Usage: silver catalogue | silver {check|compile} SOURCE | silver run SOURCE [-- ARGUMENTS...]", 2);
      return;
   end if;
   declare
      Command : constant String := Silver_Runtime.Argument (1);
      Name : constant String := Silver_Runtime.Argument (2);
      Source : String (1 .. Silver_Profile.Max_Source_Length);
      Last : Natural;
      Too_Long, Success : Boolean;
      Null_Accepted, Output_Accepted : Boolean;
      Skip_Arguments : Natural := 2;
   begin
      if Command /= "check" and then Command /= "compile" and then Command /= "run" then
         Failure ("Usage: silver catalogue | silver {check|compile} SOURCE | silver run SOURCE [-- ARGUMENTS...]", 2);
         return;
      end if;
      if Silver_Runtime.Argument_Count > 2 then
         if Command /= "run" or else Silver_Runtime.Argument (3) /= "--" then
            Failure ("Usage: silver catalogue | silver {check|compile} SOURCE | silver run SOURCE [-- ARGUMENTS...]", 2);
            return;
         end if;
         Skip_Arguments := 3;
      end if;
      if not Valid_Path (Name) then
         Failure ("Infrastructure error: source path is empty, too long, or contains NUL.");
         return;
      end if;
      Read_File (Name, Source, Last, Too_Long, Success);
      if not Success then
         Failure ("Infrastructure error: cannot read source file.");
         return;
      end if;
      if Too_Long then
         Failure ("Rejected: source is outside the Silver catalogue.", 2);
         return;
      end if;
      Null_Accepted := Silver_Profile.Accepts (Source (1 .. Last));
      Output_Accepted := not Null_Accepted and then Silver_Output_Profile.Accepts (Source (1 .. Last));
      if not Null_Accepted and then not Output_Accepted then
         Failure ("Rejected: source is outside the Silver catalogue.", 2);
         return;
      end if;
      Put_Line ("Accepted: silver.");
      if Command /= "check" then
         Compile (Source (1 .. Last), Output_Accepted, Command = "run", Skip_Arguments);
      end if;
   end;
end Silver;
