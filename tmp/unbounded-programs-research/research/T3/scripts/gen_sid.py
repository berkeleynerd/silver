import sys,os
n=int(sys.argv[1]); d=sys.argv[2]; kind=sys.argv[3]
os.makedirs(d,exist_ok=True)
A='A'*n
if kind=='var': s=f"procedure Main is\n   pragma SPARK_Mode (On);\n{A} : Integer := 0;\nbegin\n{A} := 1;\nend Main;\n"
elif kind=='loop': s=f"procedure Main is\n   pragma SPARK_Mode (On);\nbegin\nfor {A} in 1 .. 2 loop\nnull;\nend loop;\nend Main;\n"
elif kind=='str': s=f"with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\n{A} : String := \"x\";\nbegin\nSilver_IO.Put_Line ({A});\nend Main;\n"
elif kind=='const': s=f"with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\n{A} : constant Integer := 3;\nbegin\nSilver_IO.Put_Line (Integer'Image ({A}));\nend Main;\n"
open(os.path.join(d,'main.adb'),'w').write(s)
print(len(s))
