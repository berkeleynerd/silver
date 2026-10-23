"""New retained-source and instruction projection; no target or predecessor runs."""
import hashlib
import io
import json
from pathlib import Path
import re
import struct
import subprocess
import tarfile
import time

ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
BASE='75ac621aeb'
WHY='docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML='docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
inputs={}


def ident(b): return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def frozen(path):
    b=subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
    inputs[path]=ident(b)
    return b


def tokens(s):
    out=[];i=0;depth=0
    while i<len(s):
        if s.startswith('(*)',i): i+=3
        elif s.startswith('(*',i): depth+=1;i+=2
        elif depth:
            if s.startswith('*)',i): depth-=1;i+=2
            else:i+=1
        elif s[i]=="'" and (m:=re.match(r"'(?:\\(?:[0-9]{3}|x[0-9a-fA-F]{2}|.)|[^'\\\n])'",s[i:])):
            i+=len(m[0])
        elif s[i]=='"':
            j=i;i+=1
            while i<len(s):
                if s[i]=='\\':i+=2
                elif s[i]=='"':i+=1;break
                else:i+=1
            else:raise ValueError('unclosed literal')
            out.append(dict(line=s.count('\n',0,j)+1,source=s[j:i],bytes=len(s[j:i].encode())))
        else:i+=1
    assert depth==0
    return out


def source():
    specs={WHY:{
      'why3/src/printer/smtv2.ml':[(13,22),(235,715),(755,1082)],
      'why3/src/core/printer.ml':[(130,228),(288,408),(411,429)],
      'why3/src/driver/driver.ml':[(391,404),(456,474)],
      'why3/src/util/pp.ml':[(15,120),(208,208)],
      'why3/src/util/number.ml':[(165,196),(245,303)],
      'why3/src/util/loc.ml':[(114,130)],
      'why3/src/util/constant.ml':[(45,80)],
    },OCAML:{
      '/stdlib/camlinternalFormat.ml':[(120,140),(1317,1390),(1424,1457),(1515,1605),(1665,1727),(1938,2005)],
      '/stdlib/camlinternalFormatBasics.ml':[(67,90),(232,260),(366,438),(456,470)],
      '/stdlib/format.ml':[(68,208),(937,1007),(1249,1311),(1354,1396)],
      '/stdlib/bytes.ml':[(170,209)],'/stdlib/string.ml':[(116,124)],
      '/stdlib/buffer.ml':[(18,43)],'/stdlib/queue.ml':[(19,54)],
      '/stdlib/stack.ml':[(16,26)],'/stdlib/stdlib.ml':[(252,256)],
      '/runtime/ints.c':[(33,115),(137,186)],'/runtime/str.c':[(61,78),(390,426)],
      '/runtime/alloc.c':[(79,102)],'/runtime/caml/mlvalues.h':[(59,80),(150,168),(238,255)],
      '/asmcomp/cmm_helpers.ml':[(1997,2027)],'/asmcomp/cmmgen.ml':[(368,408)],
    }}
    rows=[];literals=[]
    for archive,files in specs.items():
        data=frozen(archive)
        with tarfile.open(fileobj=io.BytesIO(data),mode='r:gz') as a:
            names=a.getnames()
            for suffix,spans in files.items():
                matches=[n for n in names if n==suffix or n.endswith(suffix)]
                assert len(matches)==1,(suffix,matches)
                name=matches[0];raw=a.extractfile(name).read();ls=raw.decode().splitlines(keepends=True)
                for first,last in spans:
                    assert 1<=first<=last<=len(ls),(name,first,last,len(ls))
                    text=''.join(ls[first-1:last])
                    rows.append(dict(archive=archive,archive_identity=ident(data),member=name,
                        member_identity=ident(raw),first=first,last=last,excerpt=text,excerpt_identity=ident(text.encode())))
                if archive==WHY:
                    all_tokens=tokens(raw.decode())
                    literals.extend(dict(member=name,**t) for t in all_tokens
                                    if any(f<=t['line']<=l for f,l in spans))
    return rows,literals


def native():
    old=json.loads(frozen('docs/evidence/retained-why-save-formatter-core-20261020/native-witnesses.json'))
    path=Path(old['existing_disassembly']['path']);dis=path.read_bytes()
    assert ident(dis)=={k:old['existing_disassembly'][k] for k in ('bytes','sha256')}
    binary=Path(old['executable']['path']).read_bytes()
    assert ident(binary)==old['executable']['identity']
    assert binary[:6]==b'\x7fELF\x02\x01'
    phoff=struct.unpack_from('<Q',binary,32)[0]
    phsize,phnum=struct.unpack_from('<HH',binary,54)
    segments=[]
    for i in range(phnum):
        ptype,flags,off,va,pa,fs,ms,align=struct.unpack_from('<IIQQQQQQ',binary,phoff+i*phsize)
        if ptype==1:segments.append((va,va+fs,off))
    def checkbytes(address,raw):
        hits=[off+address-lo for lo,hi,off in segments if lo<=address and address+len(raw)<=hi]
        assert len(hits)==1 and binary[hits[0]:hits[0]+len(raw)]==raw
    blocks=re.split(r'(?m)^(?=[0-9a-f]+ <[^>]+>:\n)',dis.decode())
    prefixes=('camlCamlinternalFormat__','camlStdlib__Format__','camlWhy3__Smtv2__',
              'camlWhy3__Pp__','camlWhy3__Number__','camlWhy3__Printer__',
              'camlWhy3__Driver__','camlWhy3__Loc__','camlWhy3__Constant__')
    selected=('make_printf_','make_padding_','make_int_padding_precision_','open_box_of_string_',
              'failwith_message_','string_to_caml_string_','fix_padding_','convert_int_',
              'compute_tag_','output_acc_','kfprintf_','kasprintf_')
    runtime={'caml_format_int','caml_int_of_string','caml_alloc_sprintf','caml_alloc_string','caml_curry2','caml_curry3'}
    bodies={};headers=[];scanned=0
    for body in blocks:
        m=re.match(r'([0-9a-f]+) <([^>]+)>:',body)
        if not m:continue
        name=m[2];module=name.startswith(prefixes)
        keep=(name.startswith(('camlCamlinternalFormat__','camlStdlib__Format__'))
              and any('__'+s in name for s in selected)) or name in runtime
        if not(module or keep):continue
        ins=[]
        for line in body.splitlines()[1:]:
            q=re.match(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2}\s+)+)(.*)$',line)
            if not q:continue
            address=int(q[1],16);hx=''.join(q[2].split());text=q[3].strip()
            if not text and ins and address==ins[-1]['address']+len(bytes.fromhex(ins[-1]['hex'])):
                ins[-1]['hex']+=hx
            else:ins.append(dict(address=address,hex=hx,text=text))
        if module:scanned+=1
        for row in ins:
            q=re.search(r'\bmov(?:q|abs)?\s+\$0x([0-9a-f]+),',row['text'])
            if q and int(q[1],16)&255==247:
                v=int(q[1],16);checkbytes(row['address'],bytes.fromhex(row['hex']))
                headers.append(dict(symbol=name,payload_words=v>>10,header=v,**row))
        if keep:
            for row in ins:checkbytes(row['address'],bytes.fromhex(row['hex']))
            assert ins,name
            bodies[name]=dict(text=body,identity=ident(body.encode()),instructions=ins)
    return dict(executable=old['executable'],existing_disassembly=old['existing_disassembly'],
                module_prefixes=list(prefixes),scanned_module_functions=scanned,
                closure_header_witnesses=headers,
                maximum_corroborating_closure_payload_words=max(r['payload_words'] for r in headers),
                bodies=bodies,new_disassembler_or_native_execution=False,
                universal_binary_source_refinement=False)


def main():
    start=time.perf_counter();rows,literals=source();nat=native()
    providers={}
    for name,path in {
      'output':'docs/evidence/retained-why-printer-output-20261023/result.json',
      'output_review':'docs/reviews/review-printer-output-20261023.md',
      'raw_name':'docs/evidence/retained-why-raw-name-length-20261023/result.json',
      'source_native':'docs/research/retained-tool-source-identity.md',
      'trusted_boundary':'docs/trusted-boundary.md',
    }.items():
        b=frozen(path)
        if path.endswith('.json'):providers[name]=json.loads(b)
    maximum=max(r['bytes'] for r in literals)
    assert maximum<=512
    census=dict(base=subprocess.check_output(['git','rev-parse',BASE],cwd=ROOT,text=True).strip(),
                literal_source_byte_maximum=maximum,
                conservative_format_tree_and_accumulator_nodes=4*(maximum+1),
                source_literals=literals,
                fixed_nonstring_object_payload_words_upper=128,
                reached_annotation_failure_format='invalid box description %S',
                annotation_error_bytes_upper=len('invalid box description ')+4*5+2,
                fixed_native_closure_header_corroboration_upper=nat['maximum_corroborating_closure_payload_words'])
    for n,v in [('inputs.json',inputs),('source-witnesses.json',rows),('native-witnesses.json',nat),
                ('census.json',census),('providers.json',providers)]:
        (HERE/n).write_text(json.dumps(v,indent=2,sort_keys=True)+'\n')
    print(json.dumps(dict(source_spans=len(rows),literals=len(literals),literal_max=maximum,
                         native_bodies=len(nat['bodies']),closure_headers=len(nat['closure_header_witnesses']),
                         elapsed_seconds=time.perf_counter()-start)))


if __name__=='__main__':main()
