import sys,os
n=int(sys.argv[1]); d=sys.argv[2]; kind=sys.argv[3] if len(sys.argv)>3 else 'obj'
os.makedirs(d,exist_ok=True)
A='A'*n
if kind=='obj': s=f"procedure Main is\n{A} : Integer := 0;\nbegin\nnull;\nend Main;\n"
elif kind=='use': s=f"procedure Main is\n{A} : Integer := 0;\nbegin\n{A} := 1;\nend Main;\n"
elif kind=='loop': s=f"procedure Main is\nbegin\nfor {A} in 1 .. 2 loop\nnull;\nend loop;\nend Main;\n"
elif kind=='const': s=f"procedure Main is\n{A} : constant Integer := 0;\nbegin\nnull;\nend Main;\n"
elif kind=='str': s=f"with Silver_IO; procedure Main is\n{A} : String := \"x\";\nbegin\nSilver_IO.Put_Line({A});\nend Main;\n"
open(os.path.join(d,'main.adb'),'w').write(s)
