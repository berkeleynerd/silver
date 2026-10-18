"""Read-only ELF/reference supplement for the 121 frontend Last globals."""
from pathlib import Path
import json,sys,re,bisect,hashlib
root=Path(__file__).parent
sys.path.insert(0,str(root/'python'))
from elftools.elf.elffile import ELFFile
from elftools.elf.relocation import RelocationSection
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_AC_WRITE
from capstone.x86 import X86_OP_MEM,X86_OP_IMM,X86_REG_RIP
scan=json.loads((root/'static-all-tables.json').read_text())
binary=Path(scan['binary']);targets={x['address']:x['name'] for x in json.loads((root/'all-last-symbols.json').read_text())};starts=sorted(targets)
def overlaps(a,width=1):
 p=bisect.bisect_right(starts,a)-1
 return [targets[t] for t in starts[max(0,p):p+3] if t<a+width and a<t+4]
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True
result=dict(binary=str(binary),sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),executable_sections=[],direct_overlaps=[],immediate_candidates=[],absolute_candidates=[],relocations=[],dynamic_symbols=[],symbol_aliases=[],data_pointer_candidates=[])
with binary.open('rb') as f:
 elf=ELFFile(f);result['elf_type']=elf['e_type'];result['machine']=elf['e_machine']
 syms=list(elf.get_section_by_name('.symtab').iter_symbols())
 for s in syms:
  if overlaps(s['st_value'],max(1,s['st_size'])) and s.name not in targets.values():result['symbol_aliases'].append(dict(name=s.name,address=s['st_value'],size=s['st_size'],type=s['st_info']['type']))
 dyn=elf.get_section_by_name('.dynsym')
 for s in dyn.iter_symbols():
  if s.name in targets.values() or overlaps(s['st_value'],max(1,s['st_size'])):result['dynamic_symbols'].append(s.name)
 for sec in elf.iter_sections():
  if isinstance(sec,RelocationSection):
   symtab=elf.get_section(sec['sh_link'])
   for r in sec.iter_relocations():
    sym=symtab.get_symbol(r['r_info_sym']) if r['r_info_sym'] else None
    add=r['r_addend'] if r.is_RELA() else 0
    value=(sym['st_value'] if sym else 0)+add
    if overlaps(value) or overlaps(r['r_offset'],8) or (sym and sym.name in targets.values()):result['relocations'].append(dict(section=sec.name,offset=r['r_offset'],type=r['r_info_type'],addend=add,symbol=sym.name if sym else None,value=value))
  if sec['sh_flags']&4:
   data=sec.data();base=sec['sh_addr'];decoded=0;insns=0
   for addr,size,mnemonic,ops in md.disasm_lite(data,base):
    decoded+=size;insns+=1
    # Detail decode every memory instruction, plus immediate candidate values.
    if '[' not in ops and not any(overlaps(int(h,16)) for h in re.findall(r'0x[0-9a-f]+',ops)):continue
    i=next(md.disasm(data[addr-base:addr-base+size],addr))
    if i.id==0:continue
    for o in i.operands:
     if o.type==X86_OP_MEM:
      if o.mem.base==X86_REG_RIP:
       a=addr+size+o.mem.disp;hit=overlaps(a,o.size)
       if hit:result['direct_overlaps'].append(dict(section=sec.name,address=hex(addr),bytes=i.bytes.hex(),mnemonic=mnemonic,operands=ops,targets=hit,referent=a,width=o.size,write=bool(o.access&CS_AC_WRITE),address_take=mnemonic=='lea'))
      elif not o.mem.base and not o.mem.index and overlaps(o.mem.disp,o.size):result['absolute_candidates'].append(dict(address=hex(addr),mnemonic=mnemonic,operands=ops))
     elif o.type==X86_OP_IMM and overlaps(o.imm):result['immediate_candidates'].append(dict(address=hex(addr),mnemonic=mnemonic,operands=ops))
   result['executable_sections'].append(dict(name=sec.name,bytes=len(data),decoded_bytes=decoded,instructions=insns))
  elif sec['sh_flags']&2 and sec['sh_type']!='SHT_NOBITS':
   data=sec.data()
   for a,name in targets.items():
    for width in (4,8):
     needle=a.to_bytes(width,'little');pos=data.find(needle)
     while pos>=0:
      result['data_pointer_candidates'].append(dict(section=sec.name,offset=pos,address=sec['sh_addr']+pos,width=width,target=name));pos=data.find(needle,pos+1)
old={int(r['address'],16) for r in scan['references'] if r['target'] in targets.values()}
new={int(r['address'],16) for r in result['direct_overlaps']}
result['additional_direct_instructions']=[r for r in result['direct_overlaps'] if int(r['address'],16) not in old]
result['original_direct_missing']=sorted(old-new)
(root/'address-coverage.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:(len(v) if isinstance(v,list) else v) for k,v in result.items()}))
