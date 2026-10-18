import sys,json,hashlib,bisect,re
from pathlib import Path
sys.path.insert(0,str(Path(__file__).parent/'python'))
from elftools.elf.elffile import ELFFile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_AC_WRITE
from capstone.x86 import X86_OP_MEM,X86_REG_RIP
binary=Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnat2why')
names=[s['name'] for s in json.loads((Path(__file__).parent/'all-last-symbols.json').read_text())]+['checks__determine_range_cache_n']
with binary.open('rb') as f:
    elf=ELFFile(f);syms=list(elf.get_section_by_name('.symtab').iter_symbols())
    targets={s['st_value']:s.name for s in syms if s.name in names}
    funcs=sorted([(s['st_value'],s['st_size'],s.name) for s in syms if s['st_info']['type']=='STT_FUNC' and s['st_size']],key=lambda x:x[0]);starts=[x[0] for x in funcs]
    sec=elf.get_section_by_name('.text');data=sec.data();base=sec['sh_addr']
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True
rows=[];count=0
for addr,size,mnemonic,opstr in md.disasm_lite(data,base):
    count+=1
    m=re.search(r"\[rip ([+-]) (0x[0-9a-f]+)\]",opstr)
    if not m:continue
    a=addr+size+int(m[2],16)*(1 if m[1]=="+" else -1)
    if a not in targets:continue
    i=next(md.disasm(data[addr-base:addr-base+size],addr))
    for o in i.operands:
        if o.type==X86_OP_MEM and o.mem.base==X86_REG_RIP:
            a=i.address+i.size+o.mem.disp
            if a in targets:
                p=bisect.bisect_right(starts,i.address)-1;fn=funcs[p] if p>=0 else None
                rows.append(dict(address=hex(i.address),bytes=i.bytes.hex(),mnemonic=i.mnemonic,operands=i.op_str,target=targets[a],access=o.access,function=fn,write=bool(o.access&CS_AC_WRITE),address_take=i.mnemonic=='lea'))
result=dict(binary=str(binary),sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),text_bytes=len(data),instructions=count,targets={hex(k):v for k,v in targets.items()},references=rows)
out=Path(__file__).parent/'static-all-tables.json';out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='references'}))
print('references',len(rows),'writes',sum(r['write'] for r in rows),'address_takes',sum(r['address_take'] for r in rows))
print('store mnemonics',sorted(set(r['mnemonic'] for r in rows if r['write'])))
for r in rows:
    if r['address_take'] or r['target']=='checks__determine_range_cache_n':print(json.dumps(r))
