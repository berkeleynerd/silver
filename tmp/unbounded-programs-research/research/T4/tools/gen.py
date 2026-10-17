import sys
HDR='with Silver_IO;\nprocedure Main is\n   pragma SPARK_Mode (On);\n'
def f1(k):
    decl=f'''   A{k} : Integer range 0 .. 9 := 3;
   B{k} : Integer range -5 .. 5 := 0;
   C{k} : constant Integer := A{k};
   S{k} : String := "abc";
'''
    body=f'''   A{k} := (9 - A{k});
   B{k} := (-B{k});
   if A{k} > C{k} then
      S{k} := "xyz";
   elsif A{k} = 0 then
      B{k} := 5;
   else
      S{k} := "abc";
   end if;
   for I{k} in 1 .. 3 loop
      for J{k} in 0 .. I{k} loop
         Silver_IO.Put (Integer'Image ((I{k} * J{k})));
      end loop;
      B{k} := (I{k} - 3);
   end loop;
   A{k} := 7;
   Silver_IO.Put_Line (S{k} & Integer'Image (B{k}));
'''
    return decl,body
def f2(k):
    decl=f'''P{k}:Integer range 0..9:=1;
Q{k}:Integer range 0..5:=2;
K{k}:constant Integer:=P{k};
T{k}:String:="ab";
U{k}:String:=T{k};
'''
    body=f'''P{k}:=(9-P{k});
Q{k}:=K{k};
T{k}:=U{k};
Silver_IO.Put_Line(Integer'Image(P{k}));
U{k}:=T{k};
Q{k}:=(5-Q{k});
P{k}:=Q{k};
T{k}:="cd";
Q{k}:=K{k};
P{k}:=K{k};
Silver_IO.Put_Line(T{k}&U{k});
'''
    return decl,body
FAM={'f1':f1,'f2':f2}
def program(fam,n,start=0):
    ds=[];bs=[]
    for k in range(start,start+n):
        d,b=FAM[fam](k);ds.append(d);bs.append(b)
    return HDR+''.join(ds)+'begin\n'+''.join(bs)+'end Main;\n'
def sized(fam,target):
    # largest n with size <= target
    n=1
    while len(program(fam,n+1).encode())<=target: n+=1
    return n,program(fam,n)
if __name__=='__main__':
    fam=sys.argv[1]; mode=sys.argv[2]
    if mode=='block':
        sys.stdout.write(program(fam,1,int(sys.argv[3])))
    else:
        n,src=sized(fam,int(sys.argv[3])); sys.stderr.write(f'{fam} blocks={n} bytes={len(src)}\n'); sys.stdout.write(src)
