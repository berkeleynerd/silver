package body Silver_Application_Report_Metadata with SPARK_Mode => On is
   use type Functions.Metadata;
   use type Procedures.Metadata;

   function Function_Model
     (Info : Packages.Metadata; Count : Packages.Routine_Count_Type) return Functions.Metadata is
     (if Count = 0 then
        (Functions.Empty_Metadata with delta Parameter_Count => Info.Parameter_Count,
         Parameters => Function_Parameters (Info))
      elsif Info.Routines (Count).Kind = Packages.Function_Routine then
        Functions.Append
          (Function_Model (Info, Count - 1), Function_View (Info.Routines (Count)))
      else Function_Model (Info, Count - 1));

   function Procedure_Model
     (Info : Packages.Metadata; Count : Packages.Routine_Count_Type) return Procedures.Metadata is
     (if Count = 0 then
        (Procedures.Empty_Metadata with delta Parameter_Count => Info.Parameter_Count,
         Parameters => Procedure_Parameters (Info))
      elsif Info.Routines (Count).Kind = Packages.Procedure_Routine then
        Procedures.Append
          (Procedure_Model (Info, Count - 1), Procedure_View (Info.Routines (Count)))
      else Procedure_Model (Info, Count - 1));

   function Owned_Functions (Info : Packages.Metadata) return Functions.Metadata is
      Result : Functions.Metadata :=
        (Functions.Empty_Metadata with delta Parameter_Count => Info.Parameter_Count,
         Parameters => Function_Parameters (Info));
   begin
      for I in 1 .. Info.Routine_Count loop
         pragma Loop_Invariant (Result.Count < I);
         pragma Loop_Invariant (Static => Result = Function_Model (Info, I - 1));
         if Info.Routines (I).Kind = Packages.Function_Routine then
            Result := Functions.Append (Result, Function_View (Info.Routines (I)));
         end if;
      end loop;
      return Result;
   end Owned_Functions;

   function Owned_Procedures (Info : Packages.Metadata) return Procedures.Metadata is
      Result : Procedures.Metadata :=
        (Procedures.Empty_Metadata with delta Parameter_Count => Info.Parameter_Count,
         Parameters => Procedure_Parameters (Info));
   begin
      for I in 1 .. Info.Routine_Count loop
         pragma Loop_Invariant (Result.Count < I);
         pragma Loop_Invariant (Static => Result = Procedure_Model (Info, I - 1));
         if Info.Routines (I).Kind = Packages.Procedure_Routine then
            Result := Procedures.Append (Result, Procedure_View (Info.Routines (I)));
         end if;
      end loop;
      return Result;
   end Owned_Procedures;
end Silver_Application_Report_Metadata;
