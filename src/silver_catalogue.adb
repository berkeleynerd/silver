with Ada.Text_IO;
with Silver_Numbers;
with Silver_Profile;
with Silver_Output_Profile;

package body Silver_Catalogue with SPARK_Mode => On is
   use Ada.Text_IO;
   use Silver_Numbers;
   use type Silver_Output_Profile.Token_Kind;

   type Byte_Class is (Whitespace, Allowed, Identifier, Comment_End);

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

   procedure Export_Constructs
     with Global => (In_Out => Ada.Text_IO.File_System)
   is
   begin
      Put_Line ("  ""constructs"": [");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""main_procedure"",");
      Put_Line ("      ""ada_kind"": ""library_level_procedure_body"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""name"": ""Main"",");
      Put_Line ("        ""parameters"": [],");
      Put_Line ("        ""end_name"": ""Main"",");
      Put_Line ("        ""additional_declarations"": false,");
      Put_Line ("        ""exception_handlers"": false");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""spark_mode_on"",");
      Put_Line ("      ""ada_kind"": ""pragma"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""name"": ""SPARK_Mode"",");
      Put_Line ("        ""argument"": ""On"",");
      Put_Line ("        ""required"": true");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""null_statement"",");
      Put_Line ("      ""ada_kind"": ""null_statement"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""runtime_context"",");
      Put_Line ("      ""ada_kind"": ""with_clause"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""package"": ""Silver_IO"",");
      Put_Line ("        ""use_clause"": false,");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""literal_output"",");
      Put_Line ("      ""ada_kind"": ""procedure_call_statement"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""operation"": ""Silver_IO.Put_Line"",");
      Put_Line ("        ""qualification_required"": true,");
      Put_Line ("        ""arguments"": [");
      Put_Line ("          ""string_literal""");
      Put_Line ("        ],");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""string_literal"",");
      Put_Line ("      ""ada_kind"": ""string_literal"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""decoded_bytes"": [");
      Put_Line ("          32,");
      Put_Line ("          126");
      Put_Line ("        ],");
      Put_Line ("        ""quote_escape"": ""\""\"""",");
      Put_Line ("        ""empty_allowed"": true,");
      Put_Line ("        ""case_preserved"": true,");
      Put_Line ("        ""concatenation"": false");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""named_string_constant"",");
      Put_Line ("      ""ada_kind"": ""object_declaration"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""type"": ""String"",");
      Put_Line ("        ""constant"": true,");
      Put_Line ("        ""initializer"": [");
      Put_Line ("          ""string_literal"",");
      Put_Line ("          ""argument_initialization""");
      Put_Line ("        ],");
      Put_Line ("        ""count"": 1,");
      Put_Line ("        ""identifier_pattern"": ""[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*"",");
      Put_Line ("        ""excluded_names"": [");
      Put_Line ("          ""String"",");
      Put_Line ("          ""Silver_IO""");
      Put_Line ("        ],");
      Put_Line ("        ""case_insensitive_binding"": true,");
      Put_Line ("        ""exclude_ada_2022_reserved_words"": true");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""named_output"",");
      Put_Line ("      ""ada_kind"": ""procedure_call_statement"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""operation"": ""Silver_IO.Put_Line"",");
      Put_Line ("        ""qualification_required"": true,");
      Put_Line ("        ""arguments"": [");
      Put_Line ("          ""declared_constant_identifier""");
      Put_Line ("        ],");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""argument_context"",");
      Put_Line ("      ""ada_kind"": ""with_clause"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""package"": ""Silver_Arguments"",");
      Put_Line ("        ""use_clause"": false,");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""argument_initialization"",");
      Put_Line ("      ""ada_kind"": ""function_call"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""operation"": ""Silver_Arguments.First_Or_Default"",");
      Put_Line ("        ""qualification_required"": true,");
      Put_Line ("        ""arguments"": [");
      Put_Line ("          ""string_literal""");
      Put_Line ("        ],");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""input_guard"",");
      Put_Line ("      ""ada_kind"": ""if_statement"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""condition"": ""Silver_Arguments.Input_Is_Valid"",");
      Put_Line ("        ""then"": [");
      Put_Line ("          ""named_output""");
      Put_Line ("        ],");
      Put_Line ("        ""else"": [");
      Put_Line ("          ""argument_rejection""");
      Put_Line ("        ],");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""id"": ""argument_rejection"",");
      Put_Line ("      ""ada_kind"": ""procedure_call_statement"",");
      Put_Line ("      ""conditions"": {");
      Put_Line ("        ""operation"": ""Silver_Arguments.Reject"",");
      Put_Line ("        ""qualification_required"": true,");
      Put_Line ("        ""arguments"": [],");
      Put_Line ("        ""exit_status"": 1,");
      Put_Line ("        ""stdout"": """",");
      Put_Line ("        ""count"": 1");
      Put_Line ("      }");
      Put_Line ("    }");
      Put_Line ("  ],");
   end Export_Constructs;

   procedure Export_Compositions
     with Global => (In_Out => Ada.Text_IO.File_System)
   is
   begin
      Put_Line ("  ""compositions"": [");
      Put_Line ("    {");
      Put_Line ("      ""name"": ""null"",");
      Put_Line ("      ""context"": [],");
      Put_Line ("      ""declarative_items"": [");
      Put_Line ("        ""spark_mode_on""");
      Put_Line ("      ],");
      Put_Line ("      ""statements"": [");
      Put_Line ("        ""null_statement""");
      Put_Line ("      ],");
      Put_Line ("      ""library_units"": []");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""name"": ""literal_output"",");
      Put_Line ("      ""context"": [");
      Put_Line ("        ""runtime_context""");
      Put_Line ("      ],");
      Put_Line ("      ""declarative_items"": [");
      Put_Line ("        ""spark_mode_on""");
      Put_Line ("      ],");
      Put_Line ("      ""statements"": [");
      Put_Line ("        ""literal_output""");
      Put_Line ("      ],");
      Put_Line ("      ""library_units"": [");
      Put_Line ("        ""silver_io.ads"",");
      Put_Line ("        ""silver_io.adb"",");
      Put_Line ("        ""silver_output_libc.ads"",");
      Put_Line ("        ""silver_arguments.ads"",");
      Put_Line ("        ""silver_arguments.adb"",");
      Put_Line ("        ""silver_runtime.ads""");
      Put_Line ("      ]");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""name"": ""named_output"",");
      Put_Line ("      ""context"": [");
      Put_Line ("        ""runtime_context""");
      Put_Line ("      ],");
      Put_Line ("      ""declarative_items"": [");
      Put_Line ("        ""spark_mode_on"",");
      Put_Line ("        ""named_string_constant""");
      Put_Line ("      ],");
      Put_Line ("      ""statements"": [");
      Put_Line ("        ""named_output""");
      Put_Line ("      ],");
      Put_Line ("      ""library_units"": [");
      Put_Line ("        ""silver_io.ads"",");
      Put_Line ("        ""silver_io.adb"",");
      Put_Line ("        ""silver_output_libc.ads"",");
      Put_Line ("        ""silver_arguments.ads"",");
      Put_Line ("        ""silver_arguments.adb"",");
      Put_Line ("        ""silver_runtime.ads""");
      Put_Line ("      ],");
      Put_Line ("      ""initializer"": ""string_literal""");
      Put_Line ("    },");
      Put_Line ("    {");
      Put_Line ("      ""name"": ""command_line_output"",");
      Put_Line ("      ""context"": [");
      Put_Line ("        ""runtime_context"",");
      Put_Line ("        ""argument_context""");
      Put_Line ("      ],");
      Put_Line ("      ""declarative_items"": [");
      Put_Line ("        ""spark_mode_on"",");
      Put_Line ("        ""named_string_constant""");
      Put_Line ("      ],");
      Put_Line ("      ""initializer"": ""argument_initialization"",");
      Put_Line ("      ""additional_excluded_names"": [");
      Put_Line ("        ""Silver_Arguments""");
      Put_Line ("      ],");
      Put_Line ("      ""statements"": [");
      Put_Line ("        ""input_guard""");
      Put_Line ("      ],");
      Put_Line ("      ""library_units"": [");
      Put_Line ("        ""silver_io.ads"",");
      Put_Line ("        ""silver_io.adb"",");
      Put_Line ("        ""silver_output_libc.ads"",");
      Put_Line ("        ""silver_arguments.ads"",");
      Put_Line ("        ""silver_arguments.adb"",");
      Put_Line ("        ""silver_runtime.ads""");
      Put_Line ("      ]");
      Put_Line ("    }");
      Put_Line ("  ],");
   end Export_Compositions;

   procedure Export_Rules
     with Global => (In_Out => Ada.Text_IO.File_System)
   is
   begin
      Put_Line ("  ""additional_units"": false,");
      Put_Line ("  ""additional_constructs"": false,");
      Put_Line ("  ""procedure_name"": ""Main"",");
      Put_Line ("  ""source_encoding"": ""ASCII"",");
      Put_Line ("  ""comment_ends_at_eof"": true,");
      Put_Line ("  ""comment_printable_bytes"": [");
      Put_Line ("    32,");
      Put_Line ("    126");
      Put_Line ("  ],");
      Put_Line ("  ""comment_tab_allowed"": true,");
      Put_Line ("  ""ascii_case_insensitive"": true,");
      Put_Line ("  ""literal_case_preserved"": true,");
      Put_Line ("  ""whole_identifier_tokens"": true,");
      Put_Line ("  ""output"": {");
      Put_Line ("    ""operation"": ""Silver_IO.Put_Line"",");
      Put_Line ("    ""stream"": ""stdout"",");
      Put_Line ("    ""appended_bytes"": [");
      Put_Line ("      10");
      Put_Line ("    ],");
      Put_Line ("    ""completion"": ""successful fflush(NULL)"",");
      Put_Line ("    ""detected_failure_exit_status"": 1,");
      Put_Line ("    ""external_signal_failure"": ""nonzero termination"",");
      Put_Line ("    ""partial_output_on_failure"": true");
      Put_Line ("  },");
      Put_Line ("  ""argument_input"": {");
      Put_Line ("    ""operation"": ""Silver_Arguments.First_Or_Default"",");
      Put_Line ("    ""validity_operation"": ""Silver_Arguments.Input_Is_Valid"",");
      Put_Line ("    ""maximum_arguments"": 1,");
      Put_Line ("    ""max_argument_bytes"": 4096,");
      Put_Line ("    ""argument_byte_range"": [");
      Put_Line ("      32,");
      Put_Line ("      126");
      Put_Line ("    ],");
      Put_Line ("    ""missing"": ""supplied_default"",");
      Put_Line ("    ""empty"": ""preserved"",");
      Put_Line ("    ""invalid_exit_status"": 1,");
      Put_Line ("    ""invalid_stdout"": """",");
      Put_Line ("    ""immutable_argument_vector_required"": true");
      Put_Line ("  },");
      Put_Line ("  ""max_source_bytes"":" & Decimal (Silver_Profile.Max_Source_Length) & ",");
      Bytes ("whitespace_bytes", Whitespace);
      Bytes ("allowed_source_bytes", Allowed);
      Bytes ("identifier_bytes", Identifier);
      Put_Line ("  ""comment_prefix"": """ & Silver_Profile.Comment_Introducer & """,");
      Bytes ("comment_end_bytes", Comment_End);
   end Export_Rules;

   procedure Export_Tokens
     with Global => (In_Out => Ada.Text_IO.File_System)
   is
      Word_Written : Boolean := False;
   begin
      Put ("  ""word_tokens"": [");
      for Token in Silver_Profile.Token_Kind loop
         if Silver_Profile.Is_Word_Token (Token) then
            if Word_Written then Put (","); end if;
            Put ("""" & Silver_Profile.Spelling (Token) & """");
            Word_Written := True;
         end if;
      end loop;
      for Token in Silver_Output_Profile.Token_Kind loop
         if Token in Silver_Output_Profile.With_Keyword | Silver_Output_Profile.IO_Name | Silver_Output_Profile.Put_Line_Name
           | Silver_Output_Profile.Constant_Keyword | Silver_Output_Profile.String_Name
           | Silver_Output_Profile.Arguments_Name | Silver_Output_Profile.First_Or_Default_Name
           | Silver_Output_Profile.If_Keyword | Silver_Output_Profile.Input_Is_Valid_Name
           | Silver_Output_Profile.Then_Keyword | Silver_Output_Profile.Else_Keyword
           | Silver_Output_Profile.Reject_Name
         then
            Put (",""" & Silver_Output_Profile.Spelling (Token) & """");
         end if;
      end loop;
      Put_Line ("],");
      Put ("  ""casefold_bytes"": [");
      for Item in Character loop
         if Item /= Character'First then Put (","); end if;
         Put (Decimal (Character'Pos (Silver_Profile.Lowercase (Item))));
      end loop;
      Put_Line ("],");
      Put ("  ""null_tokens"": [");
      for Index in Silver_Profile.Required_Tokens'Range loop
         if Index /= Silver_Profile.Required_Tokens'First then Put (","); end if;
         Put ("""" & Silver_Profile.Spelling (Silver_Profile.Required_Tokens (Index)) & """");
      end loop;
      Put_Line ("],");
      Put ("  ""output_tokens"": [");
      for Index in Silver_Output_Profile.Required_Tokens'Range loop
         if Index /= Silver_Output_Profile.Required_Tokens'First then Put (","); end if;
         if Silver_Output_Profile.Required_Tokens (Index) = Silver_Output_Profile.String_Literal then
            Put ("""<string_literal>""");
         else
            Put ("""" & Silver_Output_Profile.Spelling (Silver_Output_Profile.Required_Tokens (Index)) & """");
         end if;
      end loop;
      Put_Line ("],");
      Put ("  ""named_tokens"": [");
      for Index in Silver_Output_Profile.Named_Required_Tokens'Range loop
         if Index /= Silver_Output_Profile.Named_Required_Tokens'First then Put (","); end if;
         if Silver_Output_Profile.Named_Required_Tokens (Index) = Silver_Output_Profile.String_Literal then
            Put ("""<string_literal>""");
         elsif Silver_Output_Profile.Named_Required_Tokens (Index) = Silver_Output_Profile.Declaration_Name then
            Put ("""<declaration_name>""");
         elsif Silver_Output_Profile.Named_Required_Tokens (Index) = Silver_Output_Profile.Reference_Name then
            Put ("""<reference_name>""");
         else
            Put ("""" & Silver_Output_Profile.Spelling (Silver_Output_Profile.Named_Required_Tokens (Index)) & """");
         end if;
      end loop;
      Put_Line ("],");
      Put ("  ""argument_tokens"": [");
      for Index in Silver_Output_Profile.Argument_Required_Tokens'Range loop
         if Index /= Silver_Output_Profile.Argument_Required_Tokens'First then Put (","); end if;
         if Silver_Output_Profile.Argument_Required_Tokens (Index) = Silver_Output_Profile.String_Literal then
            Put ("""<string_literal>""");
         elsif Silver_Output_Profile.Argument_Required_Tokens (Index) = Silver_Output_Profile.Declaration_Name then
            Put ("""<declaration_name>""");
         elsif Silver_Output_Profile.Argument_Required_Tokens (Index) = Silver_Output_Profile.Reference_Name then
            Put ("""<reference_name>""");
         else
            Put ("""" & Silver_Output_Profile.Spelling (Silver_Output_Profile.Argument_Required_Tokens (Index)) & """");
         end if;
      end loop;
      Put_Line ("]");
   end Export_Tokens;

   procedure Export is
   begin
      Put_Line ("{");
      Put_Line ("  ""schema_version"": 1,");
      Put_Line ("  ""profile"": ""silver"",");
      Export_Constructs;
      Export_Compositions;
      Export_Rules;
      Export_Tokens;
      Put_Line ("}");
   end Export;
end Silver_Catalogue;
