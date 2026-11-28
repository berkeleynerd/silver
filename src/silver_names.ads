with Silver_Profile;
with Silver_Output_Lexical;

package Silver_Names with SPARK_Mode => On is
   use Silver_Profile;
   use Silver_Output_Lexical;

   type Operation_Kind is (Output_Call, Partial_Output_Call, Argument_Call, Validity_Call, Reject_Call);

   --  Runtime packages and an optional selected application package participate
   --  in context visibility. Application packages are never use-visible.
   type Context_Result is record
      After : Literal_Position;
      IO_With, Arguments_With, IO_Use, Arguments_Use : Boolean;
   end record;
   Invalid_Context : constant Context_Result :=
     (After => 0, others => False);

   function Context_Model
     (Text : String; Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Context_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Context_First <= Text'Last + 1
         and then Valid_Name_State (Text, Package_First, Package_After),
       Post => Context_Model'Result.After <= Text'Last + 1;

   function Read_Context
     (Text : String; Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Context_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Context_First <= Text'Last + 1
         and then Valid_Name_State (Text, Package_First, Package_After),
       Post => (Runtime => Read_Context'Result.After <= Text'Last + 1,
         Static => Read_Context'Result =
           Context_Model (Text, Context_First, Package_First, Package_After));

   function Context_After (Text : String; Arguments : Boolean) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length,
       Post => Context_After'Result <= Text'Last + 1;

   --  Hidden records a declaration of the operation name in the local scope.
   --  Such a declaration and the selected application package identity hide a
   --  use-visible operation, never a qualified call.
   function Operation_After
     (Text : String; Position : Literal_Position; Operation : Operation_Kind;
      Hidden : Boolean; Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Context_First <= Text'Last + 1
         and then Valid_Name_State (Text, Package_First, Package_After),
       Post => Operation_After'Result = 0
         or else Operation_After'Result in Position + 1 .. Text'Last + 1;

   --  A single actual may be positional or use its API's exact formal name.
   --  Without the complete named association prefix, retain the positional
   --  cursor so a local object named Item or Default remains usable.
   function Association_After
     (Text : String; Position : Literal_Position; Default : Boolean)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Association_After'Result in Position .. Text'Last + 1;
end Silver_Names;
