with Ada.Text_IO;
with Silver_Numbers;
with Silver_Profile;
with Silver_Output_Profile;

package body Silver_Catalogue with SPARK_Mode => On is
   use Ada.Text_IO;
   use Silver_Numbers;
   use type Silver_Output_Profile.Token_Kind;

   procedure Export is
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
      Put_Line ("  ""profile"": ""silver"",");
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
      Put_Line ("    }");
      Put_Line ("  ],");
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
      Put_Line ("        ""silver_output_libc.ads""");
      Put_Line ("      ]");
      Put_Line ("    }");
      Put_Line ("  ],");
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
      Put_Line ("  ""max_source_bytes"":" & Decimal (Silver_Profile.Max_Source_Length) & ",");
      Bytes ("whitespace_bytes", Whitespace);
      Bytes ("allowed_source_bytes", Allowed);
      Bytes ("identifier_bytes", Identifier);
      Put_Line ("  ""comment_prefix"": """ & Silver_Profile.Comment_Introducer & """,");
      Bytes ("comment_end_bytes", Comment_End);
      Put ("  ""word_tokens"": [");
      for Token in Silver_Profile.Token_Kind loop
         if Silver_Profile.Is_Word_Token (Token) then
            if Word_Written then Put (","); end if;
            Put ("""" & Silver_Profile.Spelling (Token) & """");
            Word_Written := True;
         end if;
      end loop;
      for Token in Silver_Output_Profile.Token_Kind loop
         if Token in Silver_Output_Profile.With_Keyword | Silver_Output_Profile.IO_Name | Silver_Output_Profile.Put_Line_Name then
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
      Put_Line ("]");
      Put_Line ("}");
   end Export;
end Silver_Catalogue;
