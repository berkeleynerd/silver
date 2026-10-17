import sys,os
total=int(sys.argv[1]); d=sys.argv[2]; os.makedirs(d,exist_ok=True)
head="with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\nbegin\nnull;\n"
tail="end Main;\n"
line="-- "+"c"*76+"\n"
body=total-len(head)-len(tail)
with open(os.path.join(d,'main.adb'),'w') as f:
    f.write(head)
    n,r=divmod(body,len(line))
    chunk=line*10000
    for _ in range(n//10000): f.write(chunk)
    f.write(line*(n%10000))
    if r: f.write("-"*0 + ("--"+"c"*(r-3)+"\n" if r>=3 else "\n"*r))
    f.write(tail)
print(os.path.getsize(os.path.join(d,'main.adb')))
