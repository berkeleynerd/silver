with Silver_Report_Projection_Types;
use Silver_Report_Projection_Types;

package body Silver_Report_Projection with SPARK_Mode => On is
   package Model renames Silver_Report_Projection_Model;
   function Space (C : Character) return Boolean is
     (C in ' ' | Character'Val (9) | Character'Val (10) | Character'Val (13));
   function Hex (C : Character) return Boolean is
     (C in '0' .. '9' | 'A' .. 'F' | 'a' .. 'f');

   function Advance (Before : State; Item : Character) return Transition is
      Result : Transition := (Following => Before, others => <>);
      S : State renames Result.Following;

      function Keeping return Boolean is
        (S.Depth = 0 or else S.Stack (S.Depth).Keep);

      procedure Emit (C : Character)
        with Pre => Result.Length < 2,
          Post => (Static => Result.Length = Result.Length'Old + 1
            and then Result.Following = Result.Following'Old
            and then Result.Bytes = (Result.Bytes'Old with delta Result.Length => C))
      is
      begin
         Result.Length := Result.Length + 1;
         Result.Bytes (Result.Length) := C;
      end Emit;

      procedure End_Value
        with Post => (Static => Result.Length = Result.Length'Old
          and then Result.Bytes = Result.Bytes'Old
          and then S = Model.Ended (S'Old))
      is
      begin
         if S.Depth = 0 then
            S.Finished := True;
         elsif S.Stack (S.Depth).Container = Object_Container then
            S.Stack (S.Depth).Position := Object_Separator;
         else
            S.Stack (S.Depth).Position := Array_Separator;
         end if;
      end End_Value;

      procedure End_String
        with Post => (Static => Result.Length = Result.Length'Old
          and then Result.Bytes = Result.Bytes'Old
          and then S = Model.Ended_String (S'Old))
      is
      begin
         S.Mode := Between_Tokens;
         if S.String_Is_Key then
            if S.Depth = 0 then
               S.Failed := True;
               return;
            end if;
            S.Stack (S.Depth).Key := Other_Key;
            if not S.Name_Escaped then
               if S.Name_Length = 4 and then S.Name (1 .. 4) = "flow" then
                  S.Stack (S.Depth).Key := Flow_Key;
               elsif S.Name_Length = 5 and then S.Name (1 .. 5) = "proof" then
                  S.Stack (S.Depth).Key := Proof_Key;
               elsif S.Name_Length = 10 and then S.Name = "check_tree" then
                  S.Stack (S.Depth).Key := Tree_Key;
               end if;
            end if;
            S.Stack (S.Depth).Position := Colon;
         else
            End_Value;
         end if;
      end End_String;

      procedure Start_String (Is_Key : Boolean; Keep : Boolean)
        with Post => (Static => Result.Length = Result.Length'Old
          and then Result.Bytes = Result.Bytes'Old
          and then S = Model.Started_String (S'Old, Is_Key, Keep))
      is
      begin
         S.Mode := In_String;
         S.String_Is_Key := Is_Key;
         S.Token_Keep := Keep;
         S.Name_Length := 0;
         S.Name_Escaped := False;
         S.Name := (others => ' ');
      end Start_String;

      procedure Start_Value
        with Pre => Result.Length = 0 and then Result.Bytes = "  ",
          Post => (Static => Result = Model.Value_Transition (S'Old, Item))
      is
         Keep : constant Boolean := Keeping;
         Project : constant Boolean := Keep and then S.Depth > 0
           and then S.Stack (S.Depth).Role = Check_Record
           and then S.Stack (S.Depth).Position = Object_Value
           and then S.Stack (S.Depth).Key = Tree_Key;
         New_Role : Role_Kind := Ordinary;
      begin
         --  Emit exactly one replacement token, never a member or record.
         if Project then
            Emit ('{');
            Emit ('}');
         elsif Keep then
            Emit (Item);
         end if;
         S.Started := True;
         if Item in '{' | '[' then
            if S.Depth = Max_Depth then
               S.Failed := True;
               return;
            end if;
            if S.Depth = 0 and then Item = '{' then
               New_Role := Root_Object;
            elsif S.Depth > 0 and then S.Stack (S.Depth).Role = Root_Object
              and then S.Stack (S.Depth).Position = Object_Value
              and then S.Stack (S.Depth).Key in Flow_Key | Proof_Key
              and then Item = '['
            then
               New_Role := Check_List;
            elsif S.Depth > 0 and then S.Stack (S.Depth).Role = Check_List
              and then Item = '{'
            then
               New_Role := Check_Record;
            end if;
            S.Depth := S.Depth + 1;
            S.Stack (S.Depth) :=
              (Container => (if Item = '{' then Object_Container else Array_Container),
               Position => (if Item = '{' then First_Key else First_Item),
               Role => New_Role, Key => Other_Key, Keep => Keep and then not Project);
         elsif Item = '"' then
            Start_String (False, Keep and then not Project);
         elsif Item = '-' or else Item in '0' .. '9' then
            S.Mode := In_Number;
            S.Token_Keep := Keep and then not Project;
            S.Number := (if Item = '-' then After_Minus
                         elsif Item = '0' then After_Zero else Integer_Digits);
         elsif Item in 't' | 'f' | 'n' then
            S.Mode := In_Literal;
            S.Token_Keep := Keep and then not Project;
            S.Literal := (if Item = 't' then True_Literal
                          elsif Item = 'f' then False_Literal else Null_Literal);
            S.Literal_Position := 2;
         else
            S.Failed := True;
         end if;
      end Start_Value;

      procedure Between
        with Pre => Result.Length = 0 and then Result.Bytes = "  ",
          Post => (Static => Result = Model.Between_Transition (S'Old, Item))
      is
      begin
         if Space (Item) then
            if Keeping then Emit (Item); end if;
         elsif S.Finished then
            S.Failed := True;
         elsif S.Depth = 0 then
            if S.Started then S.Failed := True; else Start_Value; end if;
         elsif Item in '}' | ']' then
            if (Item = '}' and then S.Stack (S.Depth).Container = Object_Container
                  and then S.Stack (S.Depth).Position in First_Key | Object_Separator)
              or else (Item = ']' and then S.Stack (S.Depth).Container = Array_Container
                  and then S.Stack (S.Depth).Position in First_Item | Array_Separator)
            then
               if Keeping then Emit (Item); end if;
               S.Depth := S.Depth - 1;
               End_Value;
            else
               S.Failed := True;
            end if;
         else
            case S.Stack (S.Depth).Position is
               when First_Key | Next_Key =>
                  if Item = '"' then
                     if Keeping then Emit (Item); end if;
                     Start_String (True, Keeping);
                  else S.Failed := True;
                  end if;
               when Colon =>
                  if Item = ':' then
                     if Keeping then Emit (Item); end if;
                     S.Stack (S.Depth).Position := Object_Value;
                  else S.Failed := True;
                  end if;
               when Object_Value | First_Item | Next_Item => Start_Value;
               when Object_Separator | Array_Separator =>
                  if Item = ',' then
                     if Keeping then Emit (Item); end if;
                     S.Stack (S.Depth).Position :=
                       (if S.Stack (S.Depth).Container = Object_Container
                        then Next_Key else Next_Item);
                  else S.Failed := True;
                  end if;
            end case;
         end if;
      end Between;

      procedure Number_Byte
        with Pre => Result.Length = 0 and then Result.Bytes = "  ",
          Post => (Static => Result = Model.Number_Transition (S'Old, Item))
      is
         Terminal : Boolean := False;
      begin
         case S.Number is
            when After_Minus =>
               if Item = '0' then S.Number := After_Zero;
               elsif Item in '1' .. '9' then S.Number := Integer_Digits;
               else S.Failed := True;
               end if;
            when After_Zero | Integer_Digits =>
               if Item in '0' .. '9' and then S.Number = Integer_Digits then null;
               elsif Item = '.' then S.Number := After_Dot;
               elsif Item in 'e' | 'E' then S.Number := After_Exponent;
               else Terminal := True;
               end if;
            when After_Dot =>
               if Item in '0' .. '9' then S.Number := Fraction_Digits;
               else S.Failed := True;
               end if;
            when Fraction_Digits =>
               if Item in '0' .. '9' then null;
               elsif Item in 'e' | 'E' then S.Number := After_Exponent;
               else Terminal := True;
               end if;
            when After_Exponent =>
               if Item in '+' | '-' then S.Number := After_Exponent_Sign;
               elsif Item in '0' .. '9' then S.Number := Exponent_Digits;
               else S.Failed := True;
               end if;
            when After_Exponent_Sign =>
               if Item in '0' .. '9' then S.Number := Exponent_Digits;
               else S.Failed := True;
               end if;
            when Exponent_Digits =>
               if Item not in '0' .. '9' then Terminal := True; end if;
         end case;
         if Terminal then
            S.Mode := Between_Tokens;
            End_Value;
            Between;
         elsif S.Token_Keep then
            Emit (Item);
         end if;
      end Number_Byte;
   begin
      if S.Failed then return Result; end if;
      case S.Mode is
         when Between_Tokens => Between;
         when In_Number => Number_Byte;
         when In_String =>
            if S.Token_Keep then Emit (Item); end if;
            if Character'Pos (Item) < 32 then S.Failed := True;
            elsif Item = '"' then End_String;
            elsif Item = '\' then
               S.Mode := After_Escape;
               S.Name_Escaped := True;
            elsif S.String_Is_Key and then S.Name_Length < 11 then
               S.Name_Length := S.Name_Length + 1;
               if S.Name_Length <= 10 then S.Name (S.Name_Length) := Item; end if;
            end if;
         when After_Escape =>
            if S.Token_Keep then Emit (Item); end if;
            if Item = 'u' then
               S.Mode := Unicode_Escape;
               S.Unicode_Left := 4;
            elsif Item in '"' | '\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' then
               S.Mode := In_String;
            else S.Failed := True;
            end if;
         when Unicode_Escape =>
            if S.Token_Keep then Emit (Item); end if;
            if not Hex (Item) or else S.Unicode_Left = 0 then S.Failed := True;
            else
               S.Unicode_Left := S.Unicode_Left - 1;
               if S.Unicode_Left = 0 then S.Mode := In_String; end if;
            end if;
         when In_Literal =>
            if S.Token_Keep then Emit (Item); end if;
            declare
               Expected : constant String :=
                 (case S.Literal is when True_Literal => "true",
                  when False_Literal => "false", when Null_Literal => "null");
            begin
               if S.Literal_Position > Expected'Length
                 or else Item /= Expected (S.Literal_Position)
               then S.Failed := True;
               elsif S.Literal_Position = Expected'Length then
                  S.Mode := Between_Tokens;
                  End_Value;
               else S.Literal_Position := S.Literal_Position + 1;
               end if;
            end;
      end case;
      return Result;
   end Advance;
end Silver_Report_Projection;
