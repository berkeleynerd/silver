with Silver_Report_Projection;
with Silver_Report_Projection_Model;
with Silver_Library_Reports;

--  Apply structural and policy correspondence to the bytes observed by an
--  actual successful read and the exact returned buffer prefix.
package Silver_Report_Projection_Audit
  with SPARK_Mode => On, Ghost => Static
is
   package Model renames Silver_Report_Projection_Model;
   package Bytes renames Model.Byte_Sequences;
   package Reports renames Silver_Library_Reports;

   procedure Application
     (Raw, Emitted : Bytes.Sequence; Current : Silver_Report_Projection.State;
      Buffer : String; Last : Natural; Kind : Reports.Application_Kind)
     with Global => null,
       Pre => Buffer'First = 1 and then Last <= Buffer'Length
         and then Last <= Reports.Max_Report_Length
         and then Silver_Report_Projection.Complete (Current)
         and then Model.Refines (Raw, Emitted, Current)
         and then Model.Matches (Emitted, Buffer, Last),
       Post => Reports.Unbounded_Application_Report_Policy (Raw, Kind) =
         Reports.Application_Report_Policy (Buffer (1 .. Last), Kind);

   procedure Runtime
     (Raw, Emitted : Bytes.Sequence; Current : Silver_Report_Projection.State;
      Buffer : String; Last : Natural; Kind : Reports.Report_Kind)
     with Global => null,
       Pre => Buffer'First = 1 and then Last <= Buffer'Length
         and then Last <= Reports.Max_Runtime_Report_Length
         and then Silver_Report_Projection.Complete (Current)
         and then Model.Refines (Raw, Emitted, Current)
         and then Model.Matches (Emitted, Buffer, Last),
       Post => Reports.Unbounded_Runtime_Report_Policy (Raw, Kind) =
         Reports.Runtime_Report_Policy (Buffer (1 .. Last), Kind);
end Silver_Report_Projection_Audit;
