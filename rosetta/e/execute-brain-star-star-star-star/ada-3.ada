with System.Storage_Elements;  use System.Storage_Elements;
with BF;

procedure Test_BF_Hello is
   Memory : Storage_Array := (0..100_000 => 0);
begin
   BF ("++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.", Memory);
end Test_BF_Hello;
