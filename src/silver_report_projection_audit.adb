with Silver_Report_Projection_Composition;
with Silver_Report_Projection_Representation;
package body Silver_Report_Projection_Audit with SPARK_Mode => On is

   procedure Application
     (Raw, Emitted : Bytes.Sequence; Current : Silver_Report_Projection.State;
      Buffer : String; Last : Natural; Kind : Reports.Application_Kind;
      Source : String := ""; Functions : Reports.Function_Metadata := Reports.Empty_Functions)
   is
   begin
      Silver_Report_Projection_Composition.Actual_Projection (Raw);
      Silver_Report_Projection_Representation.From_Buffer (Emitted, Buffer, Last);
      Reports.Application_Projection_Correspondence (Raw, Buffer (1 .. Last), Kind, Source, Functions);
   end Application;

   procedure Runtime
     (Raw, Emitted : Bytes.Sequence; Current : Silver_Report_Projection.State;
      Buffer : String; Last : Natural; Kind : Reports.Report_Kind)
   is
   begin
      Silver_Report_Projection_Composition.Actual_Projection (Raw);
      Silver_Report_Projection_Representation.From_Buffer (Emitted, Buffer, Last);
      Reports.Runtime_Projection_Correspondence (Raw, Buffer (1 .. Last), Kind);
   end Runtime;
end Silver_Report_Projection_Audit;
