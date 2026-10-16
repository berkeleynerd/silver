with Ada.Text_IO;
with Silver_Platform;
with Silver_Image_Theory;

package Silver_Image_Install with SPARK_Mode => On is
   procedure Ensure_Theory (Directory : String; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
       Output => (Silver_Platform.Read_Bytes, Silver_Platform.Read_Count,
         Silver_Platform.Read_Ended, Silver_Platform.Read_Closed,
         Silver_Platform.Written_Bytes, Silver_Platform.Written_Count,
         Silver_Platform.Write_Closed)),
       Pre => Silver_Platform.Valid_Path (Directory)
         and then Directory'Length <= Silver_Platform.Max_Path_Length - 64,
       Post => (Static => (if Success then
         Silver_Platform.Read_Ended and then Silver_Platform.Read_Closed
         and then Silver_Platform.Read_Count = Silver_Image_Theory.Theory_Text'Length
         and then Silver_Platform.Read_Bytes
           (1 .. Silver_Platform.Read_Count) = Silver_Image_Theory.Theory_Text));
end Silver_Image_Install;
