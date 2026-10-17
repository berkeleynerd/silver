import sys,os
kind=sys.argv[1]; n=int(sys.argv[2]); d=sys.argv[3]
os.makedirs(d,exist_ok=True)
H="with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\n"
out=[]
def wrap(tokens,per=40):
    lines=[];cur=[]
    for t in tokens:
        cur.append(t)
        if len(cur)>=per: lines.append(''.join(cur)); cur=[]
    if cur: lines.append(''.join(cur))
    return '\n'.join(lines)
if kind=='parens':
    s=H+"X : Integer := 0;\nbegin\nX := "+wrap(['(']*n)+"1"+wrap([')']*n)+";\nSilver_IO.Put_Line (Integer'Image (X));\nend Main;\n"
elif kind=='if':
    s=H+"X : Integer := 0;\nbegin\n"+"if X = 0 then\n"*n+"X := 1;\n"+"end if;\n"*n+"Silver_IO.Put_Line (Integer'Image (X));\nend Main;\n"
elif kind=='loop':
    s=H+"X : Integer := 0;\nbegin\n"+''.join(f"for I{i} in 1 .. 1 loop\n" for i in range(n))+"X := 1;\n"+"end loop;\n"*n+"Silver_IO.Put_Line (Integer'Image (X));\nend Main;\n"
elif kind=='elsif':
    s=H+"X : Integer := 0;\nbegin\nif X = 1 then\nX := 2;\n"+''.join(f"elsif X = {i+2} then\nX := 3;\n" for i in range(n))+"end if;\nSilver_IO.Put_Line (Integer'Image (X));\nend Main;\n"
elif kind=='decls':
    s=H+''.join(f"V{i} : Integer := 0;\n" for i in range(n))+"begin\nnull;\nend Main;\n"
elif kind=='stmts':
    s=H+"X : Integer := 0;\nbegin\n"+"X := 1;\n"*n+"Silver_IO.Put_Line (Integer'Image (X));\nend Main;\n"
elif kind=='puts':
    s=H+"begin\n"+"Silver_IO.Put_Line (\"hello world\");\n"*n+"end Main;\n"
elif kind=='concat':
    s=H+"X : String := \"a\";\nbegin\nSilver_IO.Put_Line ("+wrap(['X & ']*n,20)+"X);\nend Main;\n"
elif kind=='plus':
    s=H+"X : Integer := 0;\nbegin\nX := "+wrap(['X + ']*n,20)+"0;\nSilver_IO.Put_Line (Integer'Image (X));\nend Main;\n"
elif kind=='notnot':
    s=H+"X : Boolean := True;\nbegin\nX := "+wrap(['not ']*n,20)+"X;\nend Main;\n"
elif kind=='andthen':
    s=H+"X : Boolean := True;\nbegin\nX := "+wrap(['X and then ']*n,10)+"X;\nend Main;\n"
elif kind=='comment':  # total size via comment lines
    s=H+"begin\nnull;\n"+("-- "+"c"*76+"\n")*n+"end Main;\n"
open(os.path.join(d,'main.adb'),'w').write(s)
print(len(s))
