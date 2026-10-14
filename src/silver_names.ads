with Silver_Profile;
with Silver_Output_Lexical;

package Silver_Names with SPARK_Mode => On is
   use Silver_Profile;
   use Silver_Output_Lexical;

   type Operation_Kind is (Output_Call, Argument_Call, Validity_Call, Reject_Call);

   --  Only the two admitted packages participate in context visibility. The
   --  complete source bound limits repetitions; there is no separate clause cap.
   type Context_Result is record
      After : Literal_Position;
      IO_With, Arguments_With, IO_Use, Arguments_Use : Boolean;
   end record;
   Invalid_Context : constant Context_Result :=
     (After => 0, others => False);

   function Context_Model (Text : String) return Context_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length,
       Post => Context_Model'Result.After <= Text'Last + 1;

   function Read_Context (Text : String) return Context_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length,
       Post => (Runtime => Read_Context'Result.After <= Text'Last + 1,
         Static => Read_Context'Result = Context_Model (Text));

   function Context_After (Text : String; Arguments : Boolean) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length,
       Post => Context_After'Result <= Text'Last + 1;

   --  Hidden records a declaration of the operation name in the local scope.
   --  Such a declaration hides a use-visible operation, never a qualified call.
   function Operation_After
     (Text : String; Position : Literal_Position; Operation : Operation_Kind;
      Hidden : Boolean) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
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
