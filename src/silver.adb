with Ada.Command_Line;
with Ada.Text_IO;
with Interfaces.C;
with Silver_Runtime;
with Silver_Numbers;
with Silver_Platform;
with Silver_Profile;
with Silver_Reports;
with Silver_Build;

procedure Silver with SPARK_Mode => On is
   use Ada.Text_IO;
   use Silver_Numbers;
   use Silver_Platform;

   procedure Failure (Message : String; Status : Ada.Command_Line.Exit_Status := 3)
   is
   begin
      Put_Line (Message);
      Silver_Runtime.Set_Exit_Status (Status);
   end Failure;

   procedure Catalogue is
      type Byte_Class is (Whitespace, Allowed, Identifier, Comment_End);
      Word_Written : Boolean := False;

      procedure Bytes (Field : String; Class : Byte_Class)
        with Pre => Field'Length <= 64
      is
         Written : Boolean := False;
         Included : Boolean;
      begin
         Put ("  """ & Field & """: [");
         for Item in Character loop
            Included :=
              (case Class is
                 when Whitespace => Silver_Profile.Is_Whitespace (Item),
                 when Allowed => Silver_Profile.Is_Allowed_Character (Item),
                 when Identifier => Silver_Profile.Is_Identifier_Character (Item),
                 when Comment_End => Silver_Profile.Is_Comment_End (Item));
            if Included then
               if Written then
                  Put (",");
               end if;
               Put (Decimal (Character'Pos (Item)));
               Written := True;
            end if;
         end loop;
         Put_Line ("],");
      end Bytes;
   begin
      Put_Line ("{");
      Put_Line ("  ""schema_version"": 1,");
      Put_Line ("  ""constructs"": [");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""main_procedure"",");
      Put_Line ("      ""ada_kind"": ""library_level_procedure_body"",");
      Put_Line ("      ""token_span"": [");
      Put_Line ("        1,");
      Put_Line ("        15");
      Put_Line ("      ],");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""name"": ""Main"",");
      Put_Line ("        ""parameters"": [],");
      Put_Line ("        ""end_name"": ""Main"",");
      Put_Line ("        ""context_clauses"": [],");
      Put_Line ("        ""additional_declarations"": false,");
      Put_Line ("        ""exception_handlers"": false");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""spark_mode_on"",");
      Put_Line ("      ""ada_kind"": ""pragma"",");
      Put_Line ("      ""token_span"": [");
      Put_Line ("        4,");
      Put_Line ("        9");
      Put_Line ("      ],");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""name"": ""SPARK_Mode"",");
      Put_Line ("        ""argument"": ""On"",");
      Put_Line ("        ""required"": true");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""null_statement"",");
      Put_Line ("      ""ada_kind"": ""null_statement"",");
      Put_Line ("      ""token_span"": [");
      Put_Line ("        11,");
      Put_Line ("        12");
      Put_Line ("      ],");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    }");
      Put_Line ("  ],");
      Put_Line ("  ""composition"": {");
      Put_Line ("    ""root"": ""main_procedure"",");
      Put_Line ("    ""declarative_items"": [");
      Put_Line ("      ""spark_mode_on""");
      Put_Line ("    ],");
      Put_Line ("    ""statements"": [");
      Put_Line ("      ""null_statement""");
      Put_Line ("    ],");
      Put_Line ("    ""additional_units"": false");
      Put_Line ("  },");
      Put_Line ("  ""profile"": ""silver-null-0"",");
      Put_Line ("  ""max_source_bytes"":" & Decimal (Silver_Profile.Max_Source_Length) & ",");
      Put_Line ("  ""procedure_name"": ""Main"",");
      Put_Line ("  ""source_encoding"": ""ASCII"",");
      Bytes ("whitespace_bytes", Whitespace);
      Bytes ("allowed_source_bytes", Allowed);
      Bytes ("identifier_bytes", Identifier);
      Put_Line ("  ""comment_prefix"": """ & Silver_Profile.Comment_Introducer & """,");
      Bytes ("comment_end_bytes", Comment_End);
      Put_Line ("  ""comment_ends_at_eof"": true,");
      Put_Line ("  ""comment_printable_bytes"": [32, 126],");
      Put_Line ("  ""comment_tab_allowed"": true,");
      Put_Line ("  ""ascii_case_insensitive"": true,");
      Put_Line ("  ""whole_identifier_tokens"": true,");
      Put_Line ("  ""additional_constructs"": false,");
      Put ("  ""word_tokens"": [");
      for Token in Silver_Profile.Token_Kind loop
         if Silver_Profile.Is_Word_Token (Token) then
            if Word_Written then
               Put (",");
            end if;
            Put ("""" & Silver_Profile.Spelling (Token) & """");
            Word_Written := True;
         end if;
      end loop;
      Put_Line ("],");
      Put ("  ""casefold_bytes"": [");
      for Item in Character loop
         if Item /= Character'First then
            Put (",");
         end if;
         Put (Decimal (Character'Pos (Silver_Profile.Lowercase (Item))));
      end loop;
      Put_Line ("],");
      Put_Line ("  ""tokens"": [");
      for Index in Silver_Profile.Required_Tokens'Range loop
         Put ("    """ & Silver_Profile.Spelling (Silver_Profile.Required_Tokens (Index)) & """");
         if Index < Silver_Profile.Required_Tokens'Last then
            Put (",");
         end if;
         New_Line;
      end loop;
      Put_Line ("  ]");
      Put_Line ("}");
   end Catalogue;

   function Valid_Command (Command : String) return Boolean is
     (Command'Length in 1 .. 16_384
      and then (for all Item of Command => Item /= Character'Val (0)));

   procedure Execute (Command : String; Success : out Boolean)
     with Post => (if Valid_Command (Command) then
       Command_Length = Command'Length
       and then Command_Text (1 .. Command_Length) = Command
       and then Success = Interfaces.C."=" (Command_Status, 0)
       else not Success)
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
       Post => Last <= Observed'Length
         and then (if Success then
           Observed (Observed'First .. Last) = Expected
           and then Read_Ended and then Read_Closed
           and then Last = Read_Count
           and then Read_Bytes (1 .. Read_Count) = Expected)
   is
      Too_Long : Boolean;
   begin
      Read_File (Name, Observed, Last, Too_Long, Success);
      Success := Success and then not Too_Long
        and then Observed (Observed'First .. Last) = Expected;
   end Same_Source;

   procedure Compile (Source : String; Run_After : Boolean)
     with Pre => Source'Length <= Silver_Profile.Max_Source_Length
       and then Silver_Profile.Is_Member (Source)
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
         Snapshot : constant String := Directory & "/main.adb";
         Project : constant String := Directory & "/program.gpr";
         Report_Name : constant String := Directory & "/obj/gnatprove/main.spark";
         Executable : constant String := Directory & "/bin/main";
         --  Bootstrap quotes the fixed installation path. mkdtemp supplies
         --  only the checked six-character alphanumeric suffix below.
         Shell_Directory : constant String :=
           Silver_Build.Quoted_Root_Directory & "/program-"
           & Directory (Directory'Last - 5 .. Directory'Last);
         Executable_Command : constant String := Shell_Directory & "/bin/main";
         LF : constant Character := Character'Val (10);
         Project_Text : constant String :=
           "project Program is" & LF &
           "   for Languages use (""Ada"");" & LF &
           "   for Source_Dirs use (""."");" & LF &
           "   for Source_Files use (""main.adb"");" & LF &
           "   for Main use (""main.adb"");" & LF &
           "   for Object_Dir use ""obj"";" & LF &
           "   for Exec_Dir use ""bin"";" & LF &
           "   package Compiler is" & LF &
           "      for Default_Switches (""Ada"") use (""-gnat2022"", ""-gnata"", ""-gnato"");" & LF &
           "   end Compiler;" & LF &
           "end Program;" & LF;
         Proof_Command : constant String :=
           Silver_Build.Alire_Exec & "gnatprove -P " & Shell_Directory & "/program.gpr" &
           " --mode=all --report=all --warnings=error";
         Build_Command : constant String :=
           Silver_Build.Alire_Exec & "gprbuild -P " & Shell_Directory & "/program.gpr -p";
         Observed : String (1 .. Silver_Profile.Max_Source_Length) :=
           (others => Character'Val (0));
         Observed_Last : Natural := 0;
         Report : String (1 .. Silver_Reports.Max_Report_Length);
         Report_Last : Natural;
         Report_Read : Boolean;
         Report_Too_Long : Boolean;
         Report_Complete : Boolean;

         --  Past observations are recorded from actual return values and
         --  returned bytes. They never decide executable control flow.
         Source_Written : Boolean with Ghost;
         Initial_Source_Matched : Boolean with Ghost;
         Project_Written : Boolean with Ghost;
         Proof_Returned_Success : Boolean with Ghost;
         Proof_Command_Matched : Boolean with Ghost;
         Proof_Source_Matched : Boolean with Ghost;
         Build_Returned_Success : Boolean with Ghost;
         Build_Command_Matched : Boolean with Ghost;

         procedure Prove
           with Pre => Source_Written and then Valid_Command (Proof_Command)
             and then Initial_Source_Matched and then Project_Written,
             Post => Proof_Returned_Success = Success
               and then (if Success then Proof_Command_Matched)
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
             Source_Written and then Valid_Command (Build_Command)
             and then Initial_Source_Matched and then Project_Written
             and then Proof_Returned_Success and then Proof_Command_Matched
             and then Proof_Source_Matched
             and then Report_Read and then not Report_Too_Long
             and then Report_Last <= Report'Length
             and then Report_Complete,
             Static => Report_Last <= Report'Length
               and then Silver_Reports.Recognizes_Null_Report
                 (Report (1 .. Report_Last))),
             Post => Build_Returned_Success = Success
               and then (if Success then Build_Command_Matched)
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
             Silver_Profile.Is_Member (Source) and then Source_Written
             and then Valid_Path (Snapshot) and then Valid_Path (Report_Name)
             and then Valid_Path (Executable) and then Valid_Command (Executable_Command)
             and then Initial_Source_Matched and then Project_Written
             and then Proof_Returned_Success and then Proof_Command_Matched
             and then Proof_Source_Matched
             and then Build_Returned_Success and then Build_Command_Matched
             and then Report_Read and then not Report_Too_Long
             and then Report_Last <= Report'Length
             and then Report_Complete
             and then Success and then Observed_Last <= Observed'Length
             and then Observed (1 .. Observed_Last) = Source,
             Static => Report_Last <= Report'Length
               and then Silver_Reports.Recognizes_Null_Report
                 (Report (1 .. Report_Last)))
         is
            Ran : Boolean;
         begin
            Put_Line ("Source: " & Snapshot);
            Put_Line ("Proof: " & Report_Name);
            Put_Line ("Executable: " & Executable);
            if Run_After then
               Execute (Executable_Command, Ran);
               if not Ran then
                  Failure ("Execution failure for admitted Silver: toolchain or implementation defect.");
                  return;
               end if;
               Put_Line ("Execution completed successfully.");
            end if;
         end Publish;
      begin
         --  No user-supplied path is interpolated into a shell command. All
         --  command paths below use the checked private workspace name.
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
         Read_File (Report_Name, Report, Report_Last, Report_Too_Long, Report_Read);
         if not Report_Read or else Report_Too_Long then
            Failure ("Verification failure for admitted Silver: missing or incomplete proof evidence.");
            return;
         end if;
         Report_Complete := Silver_Reports.Complete_Null_Proof (Report (1 .. Report_Last));
         if not Report_Complete then
            Failure ("Verification failure for admitted Silver: missing or incomplete proof evidence.");
            return;
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
         Publish;
      end;
   end Compile;

begin
   Silver_Runtime.Set_Exit_Status (0);
   if Silver_Runtime.Argument_Count = 1
     and then Silver_Runtime.Argument (1) = "catalogue"
   then
      Catalogue;
      return;
   end if;
   if Silver_Runtime.Argument_Count /= 2 then
      Failure ("Usage: silver catalogue | silver {check|compile|run} SOURCE", 2);
      return;
   end if;
   declare
      Command : constant String := Silver_Runtime.Argument (1);
      Name : constant String := Silver_Runtime.Argument (2);
      Source : String (1 .. Silver_Profile.Max_Source_Length);
      Last : Natural;
      Too_Long, Success : Boolean;
   begin
      if Command /= "check" and then Command /= "compile" and then Command /= "run" then
         Failure ("Usage: silver catalogue | silver {check|compile|run} SOURCE", 2);
         return;
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
      if Too_Long or else not Silver_Profile.Accepts (Source (1 .. Last)) then
         Failure ("Rejected: source is outside the silver-null-0 catalogue.", 2);
         return;
      end if;
      Put_Line ("Accepted: silver-null-0.");
      if Command /= "check" then
         Compile (Source (1 .. Last), Command = "run");
      end if;
   end;
end Silver;
