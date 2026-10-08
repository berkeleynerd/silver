package Silver_Reports with SPARK_Mode => On is
   Max_Report_Length : constant Positive := 262_144;

   --  A specification of this format recognizer, not JSON authentication.
   --  It removes space/HT/LF/CR (also inside strings), then checks the required
   --  field patterns and the first spark-map prefix's single-entity shape.
   function Recognizes_Null_Report (Report : String) return Boolean
     with Ghost => Static, Global => null;

   --  The null-only profile generates no source-level checks. Require the
   --  trusted GNATprove 16.1 report to confirm completed analysis of its sole
   --  entity, with no failed, skipped, assumed, or outstanding obligations.
   function Complete_Null_Proof (Report : String) return Boolean
     with Global => null,
          Post => (Static =>
            Complete_Null_Proof'Result = Recognizes_Null_Report (Report));
end Silver_Reports;
