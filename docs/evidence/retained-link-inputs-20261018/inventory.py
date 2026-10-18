"""Read-only ELF/archive inventory; not a linker execution or soundness proof."""
from pathlib import Path
from collections import Counter
import argparse,gzip,hashlib,json,struct
ROOT=Path(__file__).resolve().parent
CAP=ROOT/'capture'
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output',required=True,type=Path)
args=parser.parse_args()
args.output.parent.mkdir(parents=True,exist_ok=True)
text=gzip.decompress((CAP/'link-expansion.stderr.gz').read_bytes()).decode()
def decode_gcc_command(line):
 # Inverse of gcc.cc:3351-3380, not a shell evaluation. Python shlex keeps
 # the backslash before $ inside double quotes; GCC uses it as an escape.
 result=[];i=0
 while i<len(line):
  assert line[i]==' ';i+=1
  if i==len(line):break
  word=[]
  if line[i]=='"':
   i+=1
   while line[i]!='"':
    if line[i]=='\\':
     i+=1;assert line[i] in ('"','\\','$')
    word.append(line[i]);i+=1
   i+=1
  else:
   while i<len(line) and line[i]!=' ':
    assert line[i].isascii() and (line[i].isalnum() or line[i] in '_/-.')
    word.append(line[i]);i+=1
  result.append(''.join(word))
 return result
command=decode_gcc_command(next(s for s in text.split('\n') if s.startswith(' ') and '/collect2 ' in s))
assert command[command.index('-rpath')+1].startswith('$ORIGIN/')
search=[s[2:] for s in command if s.startswith('-L')]
assert len(search)==14
queries=[]

def resolve_library(name):
 candidates=[];chosen=None
 for directory in search:
  for suffix in ('.so','.a'):
   p=Path(directory)/('lib'+name+suffix)
   exists=p.is_file();candidates.append({'path':str(p),'exists':exists})
   if exists:
    chosen=p;break
  if chosen:break
 assert chosen, name
 queries.append({'library':name,'ordered_probes':candidates,'selected':str(chosen),'resolved':str(chosen.resolve())})
 return chosen

libs=Counter(s[2:] for s in command if s.startswith('-l'))
selected={name:resolve_library(name) for name in libs}
assert (selected['atomic_asneeded']).read_text().strip().endswith('INPUT ( AS_NEEDED ( -latomic ) )')
selected['atomic']=resolve_library('atomic');libs['atomic']=1
# This exact selected libc script has three explicit absolute members.
cscript=selected['c'].read_text()
assert cscript.strip().endswith('GROUP ( /usr/lib/x86_64-linux-gnu/libc.so.6 /usr/lib/x86_64-linux-gnu/libc_nonshared.a  AS_NEEDED ( /lib64/ld-linux-x86-64.so.2 ) )')
files={}
for name,p in selected.items():files[str(p)]=(libs[name],'library:'+name)
for name in ['/usr/lib/x86_64-linux-gnu/libc.so.6','/usr/lib/x86_64-linux-gnu/libc_nonshared.a','/lib64/ld-linux-x86-64.so.2']:
 files[name]=(1,'libc-script-member')
case=Path('/tmp/silver-native-option-probe-20261018/null-proposed/obj')
for s in command:
 if s.endswith(('.o','.a')) and not s.startswith('-'):
  p=Path(s) if s.startswith('/') else case/s
  files[str(p)]=(1,'generated-input' if p.name in ('main.o','b__main.o') else 'explicit-fixed-input')


def cstring(raw,pos):
 assert 0<=pos<len(raw)
 end=raw.index(0,pos)
 return raw[pos:end]


def elf(raw):
 assert raw[:6]==b'\x7fELF\x02\x01'
 assert struct.unpack_from('<H',raw,18)[0]==62
 etype=struct.unpack_from('<H',raw,16)[0]
 shoff=struct.unpack_from('<Q',raw,40)[0]
 entsize,n,strings=struct.unpack_from('<HHH',raw,58)
 assert entsize==64 and shoff+64<=len(raw)
 def sh(i):return struct.unpack_from('<IIQQQQIIQQ',raw,shoff+i*64)
 zero=sh(0)
 n=n or zero[5]
 if strings==0xffff:strings=zero[6]
 assert shoff+n*64<=len(raw) and strings<n
 headers=[sh(i) for i in range(n)]
 def payload(h):
  assert h[1]!=8
  b=raw[h[4]:h[4]+h[5]];assert len(b)==h[5];return b
 shstr=payload(headers[strings]);names=[cstring(shstr,h[0]) for h in headers]
 assert not any(s.startswith(b'.gnu.lto_') for s in names)
 assert not any(s.startswith(b'.gnu.offload_lto_') for s in names)
 assert b'.gnu_object_only' not in names
 assert not any(s.startswith(b'.zdebug') for s in names)
 assert not any(h[2]&0x800 for h in headers) # SHF_COMPRESSED
 symbols=[];symbol_count=0;relocs=0;dynneeded=[];soname=[]
 reloc_types=Counter();dynamic_tags=Counter();dynamic_strings=[]
 for h in headers:
  if h[1] in (2,11):
   assert h[9]==24 and h[5]%24==0 and h[6]<n
   syms=payload(h);strs=payload(headers[h[6]])
   for i in range(0,len(syms),24):
    offset=struct.unpack_from('<I',syms,i)[0]
    symbol_count+=1;symbols.append(cstring(strs,offset))
  elif h[1] in (4,9):
   assert h[9] in (16,24) and h[5]%h[9]==0
   relocs+=h[5]//h[9]
   data=payload(h)
   for i in range(0,len(data),h[9]):
    info=struct.unpack_from('<Q',data,i+8)[0]
    reloc_types[str(info&0xffffffff)]+=1
  elif h[1]==6:
   assert h[9]==16 and h[5]%16==0 and h[6]<n
   dyn=payload(h);strs=payload(headers[h[6]])
   for i in range(0,len(dyn),16):
    tag,val=struct.unpack_from('<qQ',dyn,i)
    if tag==0:break
    dynamic_tags[str(tag)]+=1
    if tag==1:dynneeded.append(cstring(strs,val).decode())
    if tag==14:soname.append(cstring(strs,val).decode())
    if tag in (1,14,15,29,0x6ffffefb,0x6ffffefc,0x7ffffffd,0x7fffffff):
     dynamic_strings.append({'tag':tag,'value':cstring(strs,val).decode()})
 allnames=[s for s in symbols+names if s]
 return {'elf_type':etype,'sections':n,'symbol_records':symbol_count,'relocation_records':relocs,'alloc_section_bytes':sum(h[5] for h in headers if h[2]&2),'alloc_alignment_padding_bound':sum(max(0,h[8]-1) for h in headers if h[2]&2),'input_name_occurrences':len(allnames),'unshared_input_name_bytes':sum(len(s)+1 for s in allnames),'max_input_name_bytes':max(map(len,allnames),default=0),'max_section_bytes':max(h[5] for h in headers),'dt_needed':dynneeded,'soname':soname,'gnu_lto_sections':0,'gnu_offload_lto_sections':0,'gnu_object_only_sections':0,'string_table_bytes':sum(h[5] for h in headers if h[1]==3),'max_alignment':max(h[8] for h in headers),'section_types':dict(sorted(Counter(str(h[1]) for h in headers).items())),'relocation_types':dict(sorted(reloc_types.items())),'dynamic_tags':dict(sorted(dynamic_tags.items())),'dynamic_strings':dynamic_strings}


def archive(raw):
 assert raw.startswith(b'!<arch>\n')
 pos=8;names=b'';rows=[];special=[]
 while pos<len(raw):
  hdr=raw[pos:pos+60];assert len(hdr)==60 and hdr[58:]==b'`\n'
  name=hdr[:16].decode().rstrip();size=int(hdr[48:58]);start=pos+60
  data=raw[start:start+size];assert len(data)==size
  if name=='//':names=data;special.append({'name':name,'bytes':size})
  elif name in ('/','/SYM64/'):
   width=4 if name=='/' else 8
   count=int.from_bytes(data[:width],'big');assert width*(count+1)<=size
   offsets=[int.from_bytes(data[width*(i+1):width*(i+2)],'big') for i in range(count)]
   at=width*(count+1);symnames=[]
   for _ in range(count):
    symbol=cstring(data,at);symnames.append(symbol);at+=len(symbol)+1
   special.append({'name':name,'bytes':size,'symbols':count,'offset_width':width,'symbol_string_bytes':size-width*(count+1),'max_symbol_name_bytes':max(map(len,symnames),default=0),'member_header_offsets':sorted(set(offsets))})
  else:
   if name.startswith('/'):
    at=int(name[1:]);end=names.index(b'/\n',at);name=names[at:end].decode()
   else:assert name.endswith('/');name=name[:-1]
   rows.append({'name':name,'header_offset':pos,'bytes':size,'sha256':hashlib.sha256(data).hexdigest(),**elf(data)})
  pos=start+size+(size%2)
 assert pos==len(raw)
 for record in special:
  if 'member_header_offsets' in record:
   assert set(record['member_header_offsets'])<=set(r['header_offset'] for r in rows)
 return rows,special

records=[];allmembers=[]
for spelling,(multiplicity,role) in files.items():
 p=Path(spelling);raw=p.read_bytes()
 row={'path':spelling,'resolved':str(p.resolve()),'role':role,'link_argv_occurrences':multiplicity,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}
 if raw.startswith(b'!<arch>'):
  members,special=archive(raw);row.update(kind='archive',members=members,archive_metadata=special)
 elif raw.startswith(b'\x7fELF'):
  members=[elf(raw)];row.update(kind='elf',elf=members[0])
 else:
  members=[];row.update(kind='script',text=raw.decode())
 records.append(row)
 if role!='generated-input':allmembers.extend((m,multiplicity) for m in members)
keys=['sections','symbol_records','relocation_records','alloc_section_bytes','alloc_alignment_padding_bound','input_name_occurrences','unshared_input_name_bytes','string_table_bytes']
summary={'fixed_elf_occurrences':sum(k for _,k in allmembers),'fixed_unique_input_file_spellings':sum(r['role']!='generated-input' for r in records),'weighted_fixed_sums':{key:sum(m[key]*k for m,k in allmembers) for key in keys},'max_fixed_name_bytes':max(m['max_input_name_bytes'] for m,_ in allmembers),'max_fixed_section_bytes':max(m['max_section_bytes'] for m,_ in allmembers),'all_input_elfs_have_no_gnu_lto_sections':True,'fixed_library_file_bytes_weighted':sum(r['bytes']*r['link_argv_occurrences'] for r in records if r['role']!='generated-input'),'generated_objects_excluded_from_fixed_sums':True,'whole_linker_capacity_established':False}
result={'scope':'Read-only inventory of explicit selected link inputs and exact two scripts; no claim all transitive inputs or lifetime link events','collect2_argv':command,'search_directories':search,'library_resolution':queries,'files':records,'summary':summary}
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(summary,indent=2))
