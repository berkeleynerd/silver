with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Values;
with Silver_Report_Projection_Member_Steps;
with Silver_Report_Projection_Emissions;
package body Silver_Report_Projection_Container_Mapping with SPARK_Mode => On is
   package Bridge renames Silver_Report_Projection_Bridge;
   package Values renames Silver_Report_Projection_Values;
   package Steps renames Silver_Report_Projection_Member_Steps;
   package Emissions renames Silver_Report_Projection_Emissions;

   procedure Container_Content
     (Raw : Bytes.Sequence; Object : Scan.Span; Kind : Container_Kind)
   is
   begin
      Bounds.Container_Boundary (Raw, Object, Kind);
      Values.Value_Boundary (Raw, Object.First);
      Bridge.Prefix_Context (Raw, Object.First - 1);
      Bridge.Prefix_Context (Raw, Object.First);
      Steps.Opening (Model.Scan_State (Raw, Object.First - 1), Bytes.Get (Raw, Object.First));
      Emissions.Retained (Model.Scan_State (Raw, Object.First - 1), Bytes.Get (Raw, Object.First));
      Bridge.Prefix_Context (Raw, Object.Last - 1);
      Bridge.Prefix_Context (Raw, Object.Last);
      Steps.Closing
        (Model.Scan_State (Raw, Object.Last - 1), Bytes.Get (Raw, Object.Last),
         Model.Scan_State (Raw, Object.Last).Depth);
      Steps.Shallow_Kept (Model.Scan_State (Raw, Object.Last - 1));
      Steps.Closing_Retention (Model.Scan_State (Raw, Object.Last - 1), Bytes.Get (Raw, Object.Last));
      Mapping.Emission_At (Raw, Object.First);
      Mapping.Emission_At (Raw, Object.Last);
      Mapping.Nonempty_Range (Raw, Object.First, Object.Last);
   end Container_Content;

   procedure Cursor_Content
     (Raw : Bytes.Sequence; Object : Scan.Span; Position : Big_Natural; Kind : Container_Kind)
   is
   begin
      Container_Content (Raw, Object, Kind);
      Bridge.Prefix_Context (Raw, Position - 1);
      Steps.Shallow_Kept (Model.Scan_State (Raw, Position - 1));
      Mapping.Interior_Position (Raw, Object.First, Position, Object.Last);
   end Cursor_Content;
end Silver_Report_Projection_Container_Mapping;
