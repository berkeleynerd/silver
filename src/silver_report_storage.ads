with Silver_Library_Reports;

--  One driver invocation audits one application at a time. Keep its complete
--  report in static storage so neither report size nor a later Spawn call
--  reserves this space in the primary stack.
package Silver_Report_Storage with SPARK_Mode => On is
   Bytes : String (1 .. Silver_Library_Reports.Max_Report_Length) :=
     (others => Character'Val (0));
end Silver_Report_Storage;
