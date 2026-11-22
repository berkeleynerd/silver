with Queue, Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Added : Boolean := False;
   Present : Boolean := False;
   Is_Empty : Boolean := False;
   Value : Queue.Element := 0;
begin
   Is_Empty := Queue.Empty;
   if Is_Empty then
      Silver_IO.Put_Line ("initially empty");
   end if;
   Queue.Push (11, Added);
   Queue.Push (22, Added);
   Queue.Push (33, Added);
   if not Added then
      Silver_IO.Put_Line ("queue full");
   end if;
   Queue.Pop (Value, Present);
   if Present then
      Silver_IO.Put_Line (Integer'Image (Value));
   end if;
   Queue.Push (33, Added);
   Queue.Pop (Value, Present);
   if Present then
      Silver_IO.Put_Line (Integer'Image (Value));
   end if;
   Queue.Pop (Value, Present);
   if Present then
      Silver_IO.Put_Line (Integer'Image (Value));
   end if;
   Queue.Pop (Value, Present);
   if not Present then
      Silver_IO.Put_Line ("queue empty");
   end if;
   Is_Empty := Queue.Empty;
   if Is_Empty then
      Silver_IO.Put_Line ("finally empty");
   end if;
end Main;
