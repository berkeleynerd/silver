with Silver_Report_Projection_Model;
with Silver_Report_Observations;

--  Connect the reader's observed stored prefix to the auditor's String view.
package Silver_Report_Projection_Representation
  with SPARK_Mode => On, Ghost => Static
is
   package Model renames Silver_Report_Projection_Model;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;
   use type Bytes.Sequence;

   procedure From_Buffer (Emitted : Bytes.Sequence; Buffer : String; Last : Natural)
     with Global => null,
       Pre => Buffer'First = 1 and then Last <= Buffer'Length
         and then Model.Matches (Emitted, Buffer, Last),
       Post => Emitted = Scan.From_String (Buffer (1 .. Last));
end Silver_Report_Projection_Representation;
