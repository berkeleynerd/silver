package body Silver_Names with SPARK_Mode => On is
   function Fixed_After
     (Text : String; Position : Literal_Position; Word : String; Is_Word : Boolean)
      return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Word'First = 1
         and then Word'Length in 1 .. 16,
       Post => Fixed_After'Result = 0
         or else Fixed_After'Result in Position + 1 .. Text'Last + 1;
   function Fixed_After
     (Text : String; Position : Literal_Position; Word : String; Is_Word : Boolean)
      return Literal_Position is
     (if Position = 0 then 0
      elsif Token_At (Text, Trivia_End (Text, Position), Word, Is_Word)
      then Trivia_End (Text, Position) + Word'Length else 0);

   function Take
     (Text : String; Position : Literal_Position; Word : String; Is_Word : Boolean)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Word'First = 1
         and then Word'Length in 1 .. 16,
       Post => (Runtime => Take'Result = 0
         or else Take'Result in Position + 1 .. Text'Last + 1,
         Static => Take'Result = Fixed_After (Text, Position, Word, Is_Word));
   function Take
     (Text : String; Position : Literal_Position; Word : String; Is_Word : Boolean)
      return Literal_Position is
      Next : Cursor;
   begin
      if Position = 0 then return 0; end if;
      Next := Position;
      Skip_Trivia (Text, Next);
      if Word'Length > (Text'Last - Next) + 1 then return 0; end if;
      for Index in Word'Range loop
         pragma Loop_Invariant
           (for all Previous in Word'First .. Index - 1 =>
             Lowercase (Text ((Next + Previous) - 1)) = Word (Previous));
         if Lowercase (Text ((Next + Index) - 1)) /= Word (Index) then return 0; end if;
      end loop;
      if Is_Word and then Next + Word'Length <= Text'Last
        and then Is_Identifier_Character (Text (Next + Word'Length))
      then return 0; end if;
      return Next + Word'Length;
   end Take;

   type Context_Mode is
     (Clause_Start, With_Name, Use_Name, With_Separator, Use_Separator);
   type Context_State is record
      Context : Context_Result;
      Mode : Context_Mode;
      Complete : Boolean;
   end record;
   Initial_State : constant Context_State :=
     (Context => (After => 1, others => False), Mode => Clause_Start, Complete => False);
   Invalid_State : constant Context_State :=
     (Context => Invalid_Context, Mode => Clause_Start, Complete => True);

   function Package_Name_After
     (Text : String; Position, Package_First, Package_After : Literal_Position)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Package_First, Package_After),
       Post => Package_Name_After'Result = 0
         or else Package_Name_After'Result in Position + 1 .. Text'Last + 1;
   function Package_Name_After
     (Text : String; Position, Package_First, Package_After : Literal_Position)
      return Literal_Position is
      First, After : Literal_Position;
      Next : Cursor;
      Matched : Boolean;
   begin
      if Position = 0 or else Package_First = 0 then return 0; end if;
      Next := Position;
      Skip_Trivia (Text, Next);
      First := Next;
      Match_Identifier (Text, Next, Matched);
      if not Matched then return 0; end if;
      After := Next;
      if Equal_Name (Text, First, After, Package_First, Package_After) then
         return After;
      end if;
      return 0;
   end Package_Name_After;

   function Context_Step
     (Text : String; State : Context_State;
      Package_First, Package_After : Literal_Position) return Context_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then State.Context.After <= Text'Last + 1
         and then Valid_Name_State (Text, Package_First, Package_After),
       Post => Context_Step'Result.Context.After <= Text'Last + 1
         and then (Context_Step'Result.Context.After = 0
           or else Context_Step'Result.Complete
           or else Context_Step'Result.Context.After > State.Context.After);
   function Context_Step
     (Text : String; State : Context_State;
      Package_First, Package_After : Literal_Position) return Context_State is
     (if State.Context.After = 0 then Invalid_State
      elsif State.Complete then State
      elsif State.Mode = Clause_Start then
        (declare W : constant Literal_Position := Take (Text, State.Context.After, "with", True);
                 U : constant Literal_Position := Take (Text, State.Context.After, "use", True);
         begin (if W /= 0 then
           (State with delta Context => (State.Context with delta After => W), Mode => With_Name)
         elsif U /= 0 then
           (State with delta Context => (State.Context with delta After => U), Mode => Use_Name)
         else (State with delta Complete => True)))
      elsif State.Mode in With_Name | Use_Name then
        (declare I : constant Literal_Position := Take (Text, State.Context.After, "silver_io", True);
                 A : constant Literal_Position := Take (Text, State.Context.After, "silver_arguments", True);
                 P : constant Literal_Position :=
                   (if State.Mode = With_Name then Package_Name_After
                     (Text, State.Context.After, Package_First, Package_After) else 0);
         begin (if I = 0 and then A = 0 and then P = 0 then Invalid_State
         elsif State.Mode = Use_Name and then
           ((I /= 0 and then not State.Context.IO_With)
            or else (A /= 0 and then not State.Context.Arguments_With))
         then Invalid_State
         else (Context =>
           (After => (if I /= 0 then I elsif A /= 0 then A else P),
            IO_With => State.Context.IO_With or else (I /= 0 and then State.Mode = With_Name),
            Arguments_With => State.Context.Arguments_With or else (A /= 0 and then State.Mode = With_Name),
            IO_Use => State.Context.IO_Use or else (I /= 0 and then State.Mode = Use_Name),
            Arguments_Use => State.Context.Arguments_Use or else (A /= 0 and then State.Mode = Use_Name)),
           Mode => (if State.Mode = With_Name then With_Separator else Use_Separator),
           Complete => False)))
      else
        (declare S : constant Literal_Position := Take (Text, State.Context.After, ";", False);
                 C : constant Literal_Position := Take (Text, State.Context.After, ",", False);
         begin (if S /= 0 then
           (State with delta Context => (State.Context with delta After => S), Mode => Clause_Start)
         elsif C /= 0 then
           (State with delta Context => (State.Context with delta After => C),
             Mode => (if State.Mode = With_Separator then With_Name else Use_Name))
         else Invalid_State)));

   function Context_Tail
     (Text : String; State : Context_State;
      Package_First, Package_After : Literal_Position) return Context_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then State.Context.After <= Text'Last + 1
         and then Valid_Name_State (Text, Package_First, Package_After),
       Post => Context_Tail'Result.After <= Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Context.After,
         Decreases => (if State.Complete then 0 else 1));
   function Context_Tail
     (Text : String; State : Context_State;
      Package_First, Package_After : Literal_Position) return Context_Result is
     (if State.Context.After = 0 then Invalid_Context
      elsif State.Complete then State.Context
      else
        (declare Next : constant Context_State :=
           Context_Step (Text, State, Package_First, Package_After);
         begin (if Next.Context.After = 0 then Invalid_Context
           else Context_Tail (Text, Next, Package_First, Package_After))));

   function Context_Model
     (Text : String; Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Context_Result is
     (Context_Tail (Text,
       (Initial_State with delta Context => (After => Context_First, others => False)),
       Package_First, Package_After));

   function Read_Context
     (Text : String; Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Context_Result is
      State : Context_State :=
        (Initial_State with delta Context => (After => Context_First, others => False));
   begin
      while State.Context.After /= 0 and then not State.Complete loop
         pragma Loop_Invariant (State.Context.After <= Text'Last + 1);
         pragma Loop_Invariant (Static =>
           Context_Model (Text, Context_First, Package_First, Package_After) =
             Context_Tail (Text, State, Package_First, Package_After));
         pragma Loop_Variant (Increases => State.Context.After,
           Decreases => (if State.Complete then 0 else 1));
         State := Context_Step (Text, State, Package_First, Package_After);
      end loop;
      return (if State.Context.After = 0 then Invalid_Context else State.Context);
   end Read_Context;

   function Context_After (Text : String; Arguments : Boolean) return Literal_Position is
     (declare Context : constant Context_Result := Read_Context (Text);
      begin (if Context.IO_With and then Context.Arguments_With = Arguments
        then Context.After else 0));

   function Operation_Name (Operation : Operation_Kind) return String
     with Global => null,
       Post => Operation_Name'Result'First = 1 and then Operation_Name'Result'Length in 1 .. 16;
   function Operation_Name (Operation : Operation_Kind) return String is
     (case Operation is
       when Output_Call => "put_line",
       when Partial_Output_Call => "put",
       when Argument_Call => "first_or_default",
       when Validity_Call => "input_is_valid",
       when Reject_Call => "reject");

   function Operation_After
     (Text : String; Position : Literal_Position; Operation : Operation_Kind;
      Hidden : Boolean; Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Literal_Position is
     (declare Context : constant Context_Result :=
        Read_Context (Text, Context_First, Package_First, Package_After);
              Visible : constant Boolean :=
                (if Operation = Output_Call or else Operation = Partial_Output_Call then Context.IO_With else Context.Arguments_With);
              Used : constant Boolean :=
                (if Operation = Output_Call or else Operation = Partial_Output_Call then Context.IO_Use else Context.Arguments_Use);
              Package_Hides : constant Boolean := Package_First /= 0 and then
                Name_Is (Text, Package_First, Package_After, Operation_Name (Operation));
              Qualified : constant Literal_Position := Take (Text,
                Take (Text, Position,
                  (if Operation = Output_Call or else Operation = Partial_Output_Call then "silver_io" else "silver_arguments"), True), ".", False);
      begin (if Context.After = 0 or else not Visible then 0
        elsif Qualified /= 0 then Take (Text, Qualified, Operation_Name (Operation), True)
        elsif Used and then not Hidden and then not Package_Hides
        then Take (Text, Position, Operation_Name (Operation), True)
        else 0));

   function Association_After
     (Text : String; Position : Literal_Position; Default : Boolean)
      return Literal_Position is
     (declare Named : constant Literal_Position := Take (Text,
        Take (Text, Position, (if Default then "default" else "item"), True), "=>", False);
      begin (if Named /= 0 then Named else Position));
end Silver_Names;
