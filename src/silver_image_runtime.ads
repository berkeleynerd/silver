package Silver_Image_Runtime with SPARK_Mode => On is
   --  Existing GNAT Ada.Environment_Variables.Value (Name, Default). The
   --  adapter never mutates the inherited environment. Its stability during
   --  this query and the unconstrained String ABI are runtime premises.
   function Environment_Value (Name, Default : String) return String
     with Import, Convention => Ada,
       External_Name => "ada__environment_variables__value__2",
       Global => null,
       Pre => Name'Length in 1 .. 4_096
         and then (for all Ch of Name => Ch /= Character'Val (0) and then Ch /= '=');
end Silver_Image_Runtime;
