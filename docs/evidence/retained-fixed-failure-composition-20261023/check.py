#!/usr/bin/env python3
"""Focused composition audit. No target, preparer or predecessor checker runs.

Checks identities, finite candidate projections and representation arithmetic.
The source simulation, control closure and service assumptions require review.
"""
import hashlib
import json
from pathlib import Path
import platform
import posixpath
import re
import struct
import subprocess
import tarfile
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
COUNT=0
PINF=1_000_000_010
INT=2**62-1
STRING=2**57-9


def require(ok,label):
    global COUNT
    COUNT+=1
    if not ok: raise AssertionError(label)


def identity(b):
    return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}


def load(name):
    return json.loads((HERE/name).read_text())


def syntax(source):
    """Independent string/comment lexer for driver census, no grammar replay."""
    out=[];strings=[];i=0;depth=0
    while i<len(source):
        if depth:
            if source.startswith('(*',i):depth+=1;i+=2
            elif source.startswith('*)',i):depth-=1;i+=2
            else:
                if source[i]=='\n':out.append('\n')
                i+=1
        elif source.startswith('(*)',i):out.append('(*)');i+=3
        elif source.startswith('(*',i):depth=1;out.append(' ');i+=2
        elif source[i]=='"':
            first=i;i+=1
            while i<len(source):
                if source[i]=='\\':i+=2
                elif source[i]=='"':i+=1;break
                else:i+=1
            token=source[first:i];require(token.endswith('"'),'complete driver quoted token')
            out.append(token);strings.append(token)
        else:out.append(source[i]);i+=1
    require(depth==0,'closed driver comments')
    return ''.join(out),strings


def input_bytes(key):
    if key.startswith('git:'):
        _,commit,path=key.split(':',2)
        return subprocess.check_output(['git','show',f'{commit}:{path}'],cwd=ROOT)
    return (ROOT/key).read_bytes()


def core(B,E):
    L=B+E;I=3*E+2;T=PINF+L+1
    return {'B':B,'E':E,'sentinel_operand':L+79,
            'scan_operand':(3*E+1)*T+L+79,'index_operand':4*I+2,
            'guards': [L+79<=PINF,(3*E+1)*T+L+79<=INT,4*I+2<=INT]}


def scalar(P,U):
    S=max(467,U+256,4*P+2048);C=8*(723+12*S)+65536
    R=31*C;A=341*C;X=4*(R+P+1024)
    Cm=8*(723+12*max(467,P+51))+65536
    std=core(6*X+576,2*X+522)
    private=core(A+P+1024,9936)
    marker=core(85*Cm+1024,4816)
    channel=std['B']+70*(std['E']+2)+2*R+253
    # Imported per-object runtime bound, conservatively covering all private
    # packages rather than just a single returned string.
    string=max(2*(A+P+1024+70*(9936+1)),2*(85*Cm+1024+70*4817))
    return {'P':P,'U':U,'N_id':467,'S':S,'C':C,'R4':R,'A4':A,'X':X,
            'M_marker':15*Cm+1024,'A_marker':85*Cm+1024,
            'private':private,'marker':marker,'standard':std,
            'standard_channel_offer':channel,'private_string_majorant':string,
            'guards':private['guards']+marker['guards']+std['guards']+[channel<=2**63-1,string<=STRING]}


def mlw(raw,M):
    N=raw['expanded_blocks']+raw['expanded_immediates']+1;U=8*N
    S=raw['expanded_direct_string_bytes'];ll=raw['position_candidate_occurrences']
    k=raw['maximum_identical_three_integer_record_occurrences'];L=raw['maximum_direct_string_payload']
    F=256*U+1024;B=256*U+16*S+8*ll*(4*180+82)+8*k*M+1024
    Q=B+F;O=B+70*(F+1);T=max(M,4*180+2,4*L+2,L+16,90)
    return {'P_file':180,'M_marker':M,'N':N,'U':U,'B':B,'F':F,'Q':Q,'O':O,'T':T,
            'marker_copies':8*k,'guards':[4*(Q+PINF+128)<=INT,T<=STRING,O<=2**63-1]}


def main():
    start=time.monotonic();inputs=load('inputs.json');data={}
    for key,expected in inputs.items():
        b=input_bytes(key);require(identity(b)==expected,'input '+key)
        if key.endswith('.json'):data[key]=json.loads(b)
    providers=load('providers.json')
    for owner,row in providers.items():
        require(len(row['files'])>0,'provider inventory '+owner)
        for f in row['files']:
            require('git:'+f['commit']+':'+f['path'] in inputs,'provider freeze '+f['path'])
    def provider(owner,filename):
        row=providers[owner]
        matches=[f for f in row['files'] if f['commit']==row['author'] and f['path'].endswith('/'+filename)]
        require(len(matches)==1,'provider export '+owner+'/'+filename)
        f=matches[0];return data['git:'+f['commit']+':'+f['path']]
    continuation=provider('continuation','result.json')
    precut=provider('precut','result.json');mprovider=provider('mlw','result.json');sexp=provider('sexp','result.json')
    require(all(p['status']=='pass' for p in [continuation,precut,mprovider,sexp]),'accepted author results')
    require(continuation['provider_files']==67 and continuation['accepted_component_file_checks']==503,'unchanged accepted continuation import scope')
    require(continuation['global_exception_allowance']==2 and continuation['global_save_callbacks']==2 and continuation['global_saves']==3,'one process allowance')
    require(not continuation['arbitrary_pre_cut_failure_prefixes_covered'],'new scope is not silently imported')
    raw=data['git:91ad324d83:docs/evidence/retained-fixed-ptree-capture-20261023/result.json']
    raw={x['case']:x for x in raw['cases']};sexp={x['case']:x for x in sexp['cases']}
    # Independent byte edit reconstruction; do not call prepare.py.
    repair=load('configuration-repair.json');base=input_bytes('docs/evidence/retained-adapter-config-composition-20261020/candidate-base-why3.conf')
    for edit in repair['base_driver_edits']:
        a=edit['before'].encode();b=edit['after'].encode()
        require(len(a)==len(b) and base.count(a)==1,'equal-width selected driver value')
        base=base.replace(a,b)
    require(base==(HERE/'configuration/why3.conf').read_bytes(),'only selected base edits')
    require(identity(base)==repair['base_after'] and len(base)==2069,'quiet base size')
    require(len(repair['base_driver_edits'])==3,'three roots')
    import_edits=0
    for name,row in repair['files'].items():
        before=input_bytes(row['source']);after=(HERE/'configuration/overlay'/name).read_bytes()
        require(identity(before)==row['source_identity'] and identity(after)==row['identity'],'overlay identities '+name)
        require(before.replace(b'import "smt-libv2.gen"',b'import "slv-libv2.gen"')==after,'only common-import edit '+name)
        require(len(before)==len(after) and len(name)==len(row['old_name']),'same widths '+name)
        import_edits+=row['import_replacements']
    require(import_edits==3,'three common import sites')
    closure=load('initial-driver-closure.json')
    require(closure['file_count']==len(closure['files'])==27,'complete original initial closure')
    require(len(closure['actual_installed_entry_names'])==107,'full directory beyond source archive')
    require(sorted(p.name for p in Path(closure['actual_installed_directory']).iterdir())==closure['actual_installed_entry_names'],'exact full installed directory observation')
    require(set(closure['installed_driver_member_names'])<=set(closure['actual_installed_entry_names']),'archive subset of actual installed directory')
    for new in repair['rename'].values():
        require(new not in closure['actual_installed_entry_names'],'unique installed basename '+new)
    require(closure['numeric_placeholder_maximum']==2,'complete numeric substring envelope')
    require(closure['standard_stderr_fragment']=={'B':64,'E':8,'attempts':1},'unchanged initial stderr fragment')
    with tarfile.open(ROOT/'docs/evidence/retained-producer-prefix-gc-20261018/dimensions-sources.tar.gz') as arc:
        for row in closure['files']:
            o=row['origin'];b=arc.extractfile(o['member']).read() if 'member' in o else input_bytes(o['path'])
            require(identity(b)==row['identity'],'complete driver bytes '+row['name'])
            clean,tokens=syntax(b.decode())
            digits=[x for t in tokens for x in re.findall(r'%(?:[a-z])?(\d+)',t)]
            require(max(map(len,digits),default=0)==row['maximum_numeric_placeholder_bytes'],'complete numeric substring census '+row['name'])
            require(len(digits)==row['numeric_placeholder_occurrences'],'numeric occurrence census '+row['name'])
            require(re.findall(r'(?m)^\s*import\s+"([^"\n]+)"',clean)==row['imports'],'initial import closure '+row['name'])
            require(not re.search(r'(?m)^\s*plugin\b',clean),'no driver-loaded plugin '+row['name'])
    # Native witnesses retain complete bytes and their exact installed offsets.
    native=load('resolver-native.json');exe=Path(native['ELF_path']).read_bytes()
    require(identity(exe)==native['ELF_identity'],'native resolver executable')
    h=struct.unpack_from('<16sHHIQQQIHHHHHH',exe)
    sections=[struct.unpack_from('<IIQQQQIIQQ',exe,h[6]+i*h[11]) for i in range(h[12])]
    for row in native['functions']:
        b=bytes.fromhex(row['hex']);require(identity(b)==row['identity'] and len(b)==row['size'],'complete native body '+row['symbol'])
        matches=[s for s in sections if s[1]!=8 and s[3]<=row['address'] and row['address']+row['size']<=s[3]+s[5]]
        require(len(matches)==1,'ELF mapping '+row['symbol']);s=matches[0];off=s[4]+row['address']-s[3]
        require(exe[off:off+len(b)]==b,'native correspondence '+row['symbol'])
    require(len(native['functions'])==6 and native['inferior_runs']==native['new_disassembler_runs']==0,'new static-only attachment')
    for row in load('loader-native.json'):
        b=Path(row['path']).read_bytes();rawdyn=bytes.fromhex(row['dynamic_hex'])
        require(identity(b)==row['identity'],'plugin image '+row['path'])
        phdr=struct.unpack_from('<16sHHIQQQIHHHHHH',b)
        segs=[struct.unpack_from('<IIQQQQQQ',b,phdr[5]+i*phdr[9]) for i in range(phdr[10])]
        dyn=[s for s in segs if s[0]==2]
        require(len(dyn)==1 and dyn[0][2]==row['dynamic_offset'] and dyn[0][5]==len(rawdyn),'ELF-declared dynamic segment')
        require(b[row['dynamic_offset']:row['dynamic_offset']+len(rawdyn)]==rawdyn,'dynamic segment correspondence')
        entries=[list(struct.unpack_from('<QQ',rawdyn,i)) for i in range(0,len(rawdyn),16)]
        require(entries==row['entries'] and not any(t in [1,15,29] for t,v in entries),'no dependency or alternate path search')
        require('/' in row['path'] and '$' not in row['path'],'literal loader argument')
    archives={}
    for row in load('source-witnesses.json'):
        if row['archive'] not in archives:archives[row['archive']]=tarfile.open(ROOT/row['archive'])
        b=archives[row['archive']].extractfile(row['member']).read()
        require(identity(b)==row['member_identity'],'source member '+row['member'])
        part=''.join(b.decode().splitlines(keepends=True)[row['start']-1:row['end']])
        require(part==row['text'] and identity(part.encode())==row['identity'],'source slice')
    for a in archives.values():a.close()
    paths=load('paths.json');require(len(paths['loadpath'])==4 and len(paths['extensions'])==5,'complete initialized search dimensions')
    combined=data['docs/evidence/retained-combined-parallel-startup-20261020/projection.json']
    require(combined['candidate_filetags_names_upper']==945214,'one extra common FileTags name preserved')
    require(combined['credits']=={'minor_words':7582192,'major_words':7578096,'remembered_entries':18924760},'full existing combined credits, not extra renamed-name credit')
    results=[]
    for case,row in paths['domains'].items():
        roles=data['docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json']
        captures=roles[case]['captures'][1]['ordered_opens']
        drivers=[r for r in captures if '/drivers/' in r['path'] or r['path'].endswith(('.drv','.gen'))]
        reference=[r for r in roles['put_line']['captures'][1]['ordered_opens'] if '/drivers/' in r['path'] or r['path'].endswith(('.drv','.gen'))]
        require(drivers==reference and len(drivers)==57 and len({r['path'] for r in drivers})==27,'complete five-domain initial driver roles '+case)
        require(len(captures)==81,'complete five-domain input open occurrences '+case)
        require(len(row['initial_libraries'])==len(set(row['initial_libraries']))==21,'all initial libraries '+case)
        constructed=[d+'/'+b+'.'+e for b in row['initial_libraries'] for d in paths['loadpath'] for e in paths['extensions']]
        require(constructed==row['library_candidates'] and len(constructed)==420,'all initial failed-probe paths '+case)
        require(max(map(len,constructed))==180,'initial probe maximum '+case)
        require(sorted(row['required_existing_library_candidates'])==row['observed_existing_library_candidates'],'unique fixed library membership evidence '+case)
        require(row['PrecutP']=={'max':[180,{'client_initial_cwd_bytes':1,'constant':10}]},'actual cwd remains a symbolic input '+case)
        require(row['client_cwd_observed'] is None and not row['actual_client_cwd_inferred'],'no inferred cwd '+case)
        require(not {'HOME','USERPROFILE','WHY3DATA','WHY3LIB','WHY3LOADPATH'}&row['controlled_environment'].keys(),'controlled environment '+case)
        known={x['path']:x['identity'] for x in row['repaired_driver_files']}
        require(len(known)==28,'repaired complete driver family '+case)
        for r in row['driver_discovery']+row['driver_imports']:
            require([p for p in r['candidates'] if p in known]==[r['required_existing_candidate']],'exact one candidate '+case)
            require(set(r['required_absent_candidates'])==set(r['candidates'])-{r['required_existing_candidate']},'explicit other candidate absence '+case)
            require(max(map(len,r['candidates']))<=180,'driver argument bound '+case)
        common=[p for p in known if p.endswith('/slv-libv2.gen')];require(len(common)==1,'one new common file')
        old=combined['domains'][case]['original_installed_import']
        require(len(common[0])<=len(old),'returned private common is shorter '+case)
        require(row['initial_driver_open_occurrences']==57 and row['initial_input_open_occurrences']==81,'unchanged finite open occurrence envelopes '+case)
        r=raw[case];require(r['native_module_tuple_words']==3 and r['native_module_extra_raw_value']==1,'native module None '+case)
        require(max(r['maximum_direct_string_payload']+6,69+6)<=467,'original abstract lemma suffix '+case)
        se=sexp[case];R=r['expanded_words']+r['expanded_blocks']+r['expanded_immediates']
        sb=4*se['atom_payload_bytes']+3*se['atoms']+2*se['lists']+19*R+4*180*r['position_candidate_occurrences']
        require(sb==se['complete_failure_byte_bound'],'complete Sexp arithmetic '+case)
        backing=1024
        while backing<sb:backing*=2
        require(backing==se['buffer_backing_bound'] and 2*backing<=STRING,'Sexp backing '+case)
        examples=[]
        for cwd in [1,170,406]:
            s=scalar(max(180,cwd+10),row['raw_label_U']);m=mlw(r,s['M_marker'])
            require(all(s['guards']+m['guards']),'joined owner guards '+case)
            require(s['M_marker']==1743304,'marker retained flat interval '+case)
            examples.append({'cwd_bytes_example':cwd,'scalar':s,'mlw':m})
        cont=next(x for x in continuation['cases'] if x['case']==case)
        require(cont['three_save_two_callback_caller_projection']==3*(cont['save_caller_per_save_bytes']+4104)+2*816,'retained R38 complete shell '+case)
        results.append({'case':case,'PrecutP':row['PrecutP'],'P_file':180,'raw_label_U':row['raw_label_U'],
                        'sexp_offer':sb,'sexp_backing':backing,'examples_only':examples})
    # Monotone scalar source functions yield this sufficient region; not a cap.
    lo,hi=180,100000
    while lo+1<hi:
        mid=(lo+hi)//2
        if all(scalar(mid,189)['guards']):lo=mid
        else:hi=mid
    require(all(scalar(lo,189)['guards']) and not all(scalar(hi,189)['guards']),'scalar region endpoint')
    for r in raw.values():require(all(mlw(r,scalar(lo,189)['M_marker'])['guards']),'serializer at region endpoint')
    out={'status':'pass','checks':COUNT,'platform':platform.system()+' '+platform.machine(),
         'scope':'new exact input/source/native/configuration projections and arithmetic; semantic composition remains reviewed prose',
         'provider_input_files':len(inputs),'cases':results,'sufficient_region':{'PrecutP_upper':lo,'client_cwd_bytes_upper':lo-10},
         'global_e_upper':2,'save_entering_callbacks_upper':2,'saves_upper':3,'allowance_renewed':False,
         'normal_and_terminal_prefixes_are_alternatives':True,'aggregate_RAM_or_stack_gate':False,
         'arbitrary_Main_covered':False,'GNATCOLL_spark_collector_covered':False,'production_refinement_established':False,
         'predecessor_checker_replays':0,'target_runs':0,'inferior_operations':0,
         'elapsed_seconds':time.monotonic()-start}
    (HERE/'result.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:out[k] for k in ['status','checks','provider_input_files','sufficient_region','elapsed_seconds']}))


if __name__=='__main__':main()
