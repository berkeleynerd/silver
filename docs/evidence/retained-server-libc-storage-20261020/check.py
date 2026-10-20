#!/usr/bin/env python3
"""Check new package/source/native attachment and object arithmetic only."""
import hashlib
import io
import itertools
import json
from pathlib import Path
import platform
import re
import struct
import sys
import tarfile
import time
sys.dont_write_bytecode=True
from patch_audit import series_entries,patch_paths,controls
from project import HERE,ROOT,SERVER,ELF,INT_MAX,PTRDIFF_MAX,DIR_MAX,C_MAX,bounds,generic_trace,project
COUNTS={}
def ident(b):return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def checked(group,test):
    assert test,group
    COUNTS[group]=COUNTS.get(group,0)+1

def deb_members(raw):
    assert raw[:8]==b'!<arch>\n';off=8;out={}
    while off<len(raw):
        h=raw[off:off+60];assert h[58:60]==b'`\n'
        n=int(h[48:58]);name=h[:16].decode().strip().rstrip('/')
        out[name]=raw[off+60:off+60+n];off+=60+n+n%2
    assert off==len(raw)
    return out

def check_patch_audit():
    patches=json.loads((HERE/'patch-audit.json').read_bytes())
    sources=json.loads((HERE/'source-witnesses.json').read_bytes())
    selected={r['member'].removeprefix('glibc-2.43/') for r in sources}
    checked('selected_source_inventory',sorted(patches['selected_source_members'])==sorted(r['member'] for r in sources))
    acquisition=json.loads((HERE/'acquisition.json').read_bytes())
    name='glibc_2.43-2ubuntu2.4.debian.tar.xz';row=acquisition['archives'][name]
    checked('patch_archive_identity',ident((HERE/name).read_bytes())=={k:row[k] for k in ('bytes','sha256')})
    with tarfile.open(HERE/name) as t:
        series=t.extractfile('debian/patches/series').read()
        checked('patch_series',series.decode()==patches['series']['text'] and ident(series)=={k:patches['series'][k] for k in ('bytes','sha256')})
        entries=series_entries(series.decode())
        checked('complete_patch_inventory',[e['member'] for e in entries]==[r['member'] for r in patches['patches']])
        checked('retained_series_default_strip',all(e['options']==[] and e['strip_components']==1 for e in entries))
        for entry,row in zip(entries,patches['patches']):
            raw=t.extractfile(entry['member']).read()
            checked('patch_series_options',all(row[k]==v for k,v in entry.items()))
            actual=patch_paths(raw.decode(),entry['strip_components'])
            checked('complete_patch_header_inventory',all(row[k]==v for k,v in actual.items()))
            checked('patch_source_exclusion',ident(raw)=={k:row[k] for k in ('bytes','sha256')} and not set(actual['patched_paths'])&selected and row['selected_source_hits']==[])
    checked('patch_controls',controls()==json.loads((HERE/'patch-audit-controls.json').read_bytes()))
    return patches

def patch_repair_main():
    started=time.perf_counter()
    pins=json.loads((HERE/'inputs.json').read_bytes())
    for name in ('check.py','patch_audit.py','patch-audit.json','patch-audit-controls.json','source-witnesses.json','acquisition.json'):
        checked('repair_input_identity',ident((HERE/name).read_bytes())==pins['packet_files'][name])
    patches=check_patch_audit()
    return {'status':'pass','scope':'repaired patch path/strip audit and its controls only; prior source/native/arithmetic evidence not replayed','platform':platform.system()+' '+platform.machine(),'elapsed_seconds':round(time.perf_counter()-started,6),'checks':COUNTS,'enabled_patches':len(patches['patches']),'selected_source_members':len(patches['selected_source_members']),'selected_source_hits':0,'header_pairs':sum(len(r['header_pairs']) for r in patches['patches']),'Index_candidates':sum(len(r['index_candidates']) for r in patches['patches']),'changed_path_sets':len(patches['rows_with_repaired_path_sets']),'controls':len(controls()),'native_target_proof_capture_runs':0,'successful_predecessor_or_whole_packet_replays':0}

def main():
    start=time.perf_counter()
    pins=json.loads((HERE/'inputs.json').read_bytes())
    for group in ('context_files','packet_files'):
        base=ROOT if group=='context_files' else HERE
        for name,h in pins[group].items():checked(group,ident((base/name).read_bytes())==h)
    acquisition=json.loads((HERE/'acquisition.json').read_bytes())
    for name,h in acquisition['archives'].items():
        checked('archives',ident((HERE/name).read_bytes())=={k:h[k] for k in ('bytes','sha256')})
    for key in ('libc','objdump'):
        h=acquisition[key];checked('installed_identities',ident(Path(h['path']).read_bytes())=={k:h[k] for k in ('bytes','sha256')})
    checked('selected_server_identity',ident(SERVER.read_bytes())=={'bytes':96904,'sha256':'143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80'})
    old=json.loads((ROOT/'docs/evidence/retained-why-server-buffer-copy-20261020/inputs.json').read_bytes())
    checked('retained_library_attachment',old['libc']['sha256']==acquisition['libc']['sha256'])
    dsc=(HERE/'glibc_2.43-2ubuntu2.4.dsc').read_text()
    checked('source_package_version','\nVersion: 2.43-2ubuntu2.4\n' in dsc and '\nSource: glibc\n' in dsc)
    for name in ('glibc_2.43.orig.tar.xz','glibc_2.43-2ubuntu2.4.debian.tar.xz'):
        row=acquisition['archives'][name]
        checked('dsc_archive_members',f" {row['sha256']} {row['bytes']} {name}\n" in dsc)
    ar=deb_members((HERE/'libc6_2.43-2ubuntu2.4_amd64.deb').read_bytes())
    with tarfile.open(fileobj=io.BytesIO(next(v for k,v in ar.items() if k.startswith('data.tar')))) as t:
        member=next(m for m in t.getmembers() if m.name.endswith('/libc.so.6'))
        checked('package_installed_byte_join',t.extractfile(member).read()==Path(acquisition['libc']['path']).read_bytes())
    with tarfile.open(fileobj=io.BytesIO(next(v for k,v in ar.items() if k.startswith('control.tar')))) as t:
        control=t.extractfile('./control').read().decode()
        checked('binary_package_metadata','\nSource: glibc\n' in control and '\nVersion: 2.43-2ubuntu2.4\n' in control and '\nArchitecture: amd64\n' in control)
    sources=json.loads((HERE/'source-witnesses.json').read_bytes());selected=set()
    with tarfile.open(HERE/'glibc_2.43.orig.tar.xz') as t:
        for w in sources:
            raw=t.extractfile(w['member']).read();selected.add(w['member'].removeprefix('glibc-2.43/'))
            checked('source_members',ident(raw)=={k:w[k] for k in ('bytes','sha256')} and raw.decode()==w['text'])
    patches=check_patch_audit()
    native=json.loads((HERE/'native.json').read_bytes());lib=ELF(Path(acquisition['libc']['path']).read_bytes());instruction_count=0
    for body in native['bodies']:
        checked('native_bodies',lib.read(body['va'],body['size']).hex()==body['hex'])
        cursor=body['va']
        for row in body['instructions']:
            b=bytes.fromhex(row['hex']);checked('native_instruction_bytes',row['va']==cursor and b==lib.read(cursor,len(b)))
            cursor+=len(b);instruction_count+=1
        checked('complete_native_body',cursor==body['va']+body['size'])
    # Explicit operand encodings support, rather than replace, review of the
    # source/native path argument and service premises.
    operands={0xbb963:'488d5801',0xbb967:'4889df',0xbb974:'4889d9',0xbb977:'4889da',0x126ca8:'be00100000',0x126cad:'3d00100000',0x126cb2:'0f4df0',0x126cb5:'4863f6',0x127254:'bf00100000',0x126f94:'490f42cc',0x126f98:'4801c8',0xf6773:'b800800000',0xf677f:'b800001000',0xf678b:'488d7b30',0x127440:'480f44c3'}
    for va,h in operands.items():checked('native_operands',lib.read(va,len(bytes.fromhex(h))).hex()==h)
    result=project();checked('new_projection',result==json.loads((HERE/'projection.json').read_bytes()))
    # All finite sequences of these threshold-straddling component lengths up
    # to four ancestors, with both shrink outcomes. Not a universal proof.
    lengths=(1,2,255,4094,4095);examples=0
    for depth in range(5):
        for names in itertools.product(lengths,repeat=depth):
            for shrink in (False,True):
                r=generic_trace(names,shrink_succeeds=shrink);b=bounds(r['C'],11,4096)
                checked('growth_threshold_models',r['H']<=r['C']//2 and r['peak']<=b['getcwd_peak'] and r['cumulative']<=b['getcwd_cumulative'] and r['retained']<=b['getcwd_retained'] and r['path_request_sum']<=2*b['B'])
                examples+=1
    for c in (1,2,4095,4096,4097,1000000,C_MAX):
        for p in (4096,8192,INT_MAX):
            b=bounds(c,11,p)
            checked('native_representation_guards',b['B']<=PTRDIFF_MAX and c+1<=PTRDIFF_MAX and DIR_MAX<=PTRDIFF_MAX and b['getcwd_cumulative']<2**64 and b['getcwd_peak']<=bounds(c,11,INT_MAX)['getcwd_peak'])
    for names in ((4094,4095),(4095,)*4096):
        r=generic_trace(names,INT_MAX);b=bounds(r['C'],11,INT_MAX)
        checked('large_path_boundary',r['peak']<=b['getcwd_peak'] and r['cumulative']<=b['getcwd_cumulative'] and r['retained']<=b['getcwd_retained'])
    a=u=n=4096
    checked('unguarded_growth_counterexample',a+max(a,n)==8192 and u+n+1==8193)
    try:generic_trace((4094,4096))
    except AssertionError:checked('component_guard_rejection',True)
    else:raise AssertionError('component guard was not enforced')
    rejected=0
    for c,s,p in ((0,11,4096),(C_MAX+1,11,4096),(1,PTRDIFF_MAX,4096),(1,11,INT_MAX+1)):
        try:bounds(c,s,p)
        except AssertionError:rejected+=1
    checked('guard_rejections',rejected==4)
    return {'status':'pass','platform':platform.system()+' '+platform.machine(),'elapsed_seconds':round(time.perf_counter()-start,6),'checks':COUNTS,'source_members':len(sources),'enabled_patches':len(patches['patches']),'selected_source_changes':0,'native_bodies':len(native['bodies']),'native_bytes':sum(r['size'] for r in native['bodies']),'native_instruction_rows':instruction_count,'native_operand_witnesses':len(operands),'growth_model_examples':examples,'target_solver_compiler_proof_capture_runs':0,'predecessor_checker_replays':0,'source_semantics_machine_proved':False,'historical_server_loaded_library_observed':False,'whole_libc_allocator_physical_closed':False,'complete_q':None,'production_adopted':False}

if __name__=='__main__':
    assert sys.argv[1:] in ([],['--patch-audit-only'])
    result=patch_repair_main() if sys.argv[1:] else main()
    print(json.dumps(result,indent=2,sort_keys=True))
