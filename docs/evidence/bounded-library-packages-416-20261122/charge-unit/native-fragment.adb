   procedure Charge_Unit
     (Text : String; Remaining : in out Concatenation_Count; Accepted : out Boolean)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
   is
      Position : Cursor := 1;
      First, After_Name, After_Character : Literal_Position;
      Number : Silver_Scalar_Literals.Literal_Result;
      Quoted : Value_Result;
      Charge : Boolean;
   begin
      Accepted := False;
      loop
         pragma Loop_Invariant (Position <= Text'Last + 1);
         pragma Loop_Variant (Increases => Position);
         First := Skip_At (Text, Position);
         if First = 0 then return; end if;
         if First > Text'Last then Accepted := True; return; end if;
         After_Character := Character_Literal_After (Text, First);
         After_Name := Name_After (Text, First);
         Number := Silver_Scalar_Literals.Read_Integer (Text, First);
         Charge := False;
         if After_Character /= 0 then Position := After_Character;
         elsif Text (First) = Character'Val (34) then
            Quoted := Literal_At (Text, First);
            if Quoted.After = 0 then return; end if;
            Position := Quoted.After;
         elsif After_Name /= 0 then
            Charge := Name_Is (Text, First, After_Name, "mod") or else Name_Is (Text, First, After_Name, "rem");
            Position := After_Name;
         elsif Number.After /= 0 then Position := Number.After;
         elsif Text (First) = '/' and then First < Text'Last and then Text (First + 1) = '=' then Position := First + 2;
         else
            Charge := Text (First) in '&' | '+' | '-' | '*' | '/';
            Position := First + 1;
         end if;
         if Charge then
            if Remaining = 0 then return; end if;
            Remaining := Remaining - 1;
         end if;
      end loop;
   end Charge_Unit;
