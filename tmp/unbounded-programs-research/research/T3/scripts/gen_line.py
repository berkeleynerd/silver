import sys,os
kind,L,term,d=sys.argv[1],int(sys.argv[2]),sys.argv[3],sys.argv[4]
os.makedirs(d,exist_ok=True)
base="procedure Main is begin null; end Main;"
if kind=='space': line=base+' '*(L-len(base))
elif kind=='comment': line=base+' --'+'x'*(L-len(base)-3)
elif kind=='tabs':  # base then tabs, L bytes
    line=base+'\t'*(L-len(base))
elif kind=='ident':
    pre="procedure Main is "; post=" : Integer := 0; begin null; end Main;"
    n=L-len(pre)-len(post); line=pre+'A'*n+post
elif kind=='string':
    pre='with Silver_IO; procedure Main is begin Silver_IO.Put_Line ("'; post='"); end Main;'
    n=L-len(pre)-len(post); line=pre+'x'*n+post
elif kind=='number':
    pre="procedure Main is X : constant Integer := "; post="; begin null; end Main;"
    n=L-len(pre)-len(post); line=pre+'0'*(n-1)+'7'+post
assert len(line)==L,(len(line),L)
t={'none':'','lf':'\n','crlf':'\r\n','cr':'\r'}[term]
open(os.path.join(d,'main.adb'),'w',newline='').write(line+t)
