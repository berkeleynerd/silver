#!/usr/bin/env python3
"""Bind the selected fixed signal setters to retained source and native bytes."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time
H = Path(__file__).resolve().parent
R = H.parents[2]
def read(p): return json.loads(p.read_text())
def identity(b): return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}
def derive():
    inputs = read(H/'inputs.json')
    for root, group in [(R,'files'), (H,'local_files')]:
        for n, expected in inputs[group].items():
            assert identity((root/n).read_bytes()) == expected, n
    slices = read(H/'source-witnesses.json')
    for a in {x['archive'] for x in slices}:
        with tarfile.open(R/a) as t:
            for x in (x for x in slices if x['archive'] == a):
                b = t.extractfile(x['member']).read()
                assert identity(b) == x['member_identity']
                assert ''.join(b.decode().splitlines(keepends=True)[x['first_line']-1:x['last_line']]) == x['text']
    meta = read(H/'native-witnesses.json'); b = Path(meta['executable']['path']).read_bytes()
    assert identity(b) == meta['executable']['identity']
    ph = struct.unpack_from('<Q',b,32)[0]; sz,n = struct.unpack_from('<HH',b,54)
    loads = []
    for i in range(n):
        kind,flags,off,addr,_,size,_,_ = struct.unpack_from('<IIQQQQQQ',b,ph+i*sz)
        if kind == 1: loads.append((addr,addr+size,off,flags))
    def matches(addr,raw,code=False):
        return any(lo<=addr and addr+len(raw)<=hi and (not code or flags&1) and b[off+addr-lo:off+addr-lo+len(raw)]==raw for lo,hi,off,flags in loads)
    pat = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')
    bodies = read(H/'native-bodies.json'); checked = 0
    for name,body in bodies.items():
        assert re.match('[0-9a-f]+ <'+re.escape(name)+'>:',body)
        for line in body.splitlines():
            if m := pat.match(line):
                raw=bytes.fromhex(m[2]);assert matches(int(m[1],16),raw,True);checked+=len(raw)
    assert len(bodies)==meta['body_count']==6 and checked==meta['instruction_bytes']==1020
    signal = read(H/'signal-data.json'); raw=bytes.fromhex(signal['bytes_hex'])
    assert matches(signal['address'],raw)
    table=struct.unpack('<28i',raw)
    for x in signal['selected']:
        assert table[-x['portable']-1] == x['native'] and 0<=x['native']<signal['installed_nsig']==65
    handler=bodies['camlGnat_main__save_session_and_exit_3133']
    assert handler.count('<camlStdlib__Sys__set_signal_317>')==3
    for immediate in ['0xfffffffffffffff5','0xfffffffffffffff9','0xffffffffffffffeb']:
        assert immediate in handler
    assert len(re.findall(r'mov\s+\$0x3,%ebx',handler))==3
    closure=read(H/'selected-closure.json')
    for name,targets in closure['direct_edges'].items():
        for target in targets:assert '<'+target+'>' in bodies[name],(name,target)
    assert '$0xb8,%rsp' in bodies['caml_install_signal_handler']
    assert '$0x148,%rsp' in bodies['caml_set_signal_action']
    assert '$0x1000,%rsp' in bodies['caml_c_call']
    imported=read(R/'docs/evidence/retained-why-save-stack-helper-closure-20261020/dispatch.json')
    frames=closure['frames_bytes']
    assert frames['direct_bridge_probe_import']==imported['bridge_transient_high_water_bytes']==4104
    assert frames['pending_signals_normal_scanner_import']==imported['pending_signals_bytes']==192
    assert sum(frames.values())==4936
    return {'scope':'Fixed three ignore setters per selected signal callback',
        'signal_callbacks_upper':2, 'setter_entries_per_callback_upper':3,
        'all_setter_entries_upper':6, 'result_wrapper_bytes_per_entry_upper':16,
        'all_direct_normal_result_wrapper_bytes_upper':96,
        'setter_owned_stack_and_bridge_bytes':4936,
        'incoming_dispatch_excluding_handler_bytes':imported['dispatch_to_save_shell_bytes']-imported['handler_while_saving_bytes'],
        'setter_plus_incoming_dispatch_bytes':4936+816-32,
        'normal_pending_scanner_included':True,
        'nested_callback_stack_included':False,
        'failure_diagnostic_and_service_stack_complete':False,
        'complete_handler_setter_exit_stack':None,
        'complete_save_stack':None,
        'physical_sufficiency_established':False,
        'without_named_relation_usable_bounds':None,
        'source_excerpts':len(slices),'native_bodies':len(bodies),'instruction_bytes':checked,
        'native_runs':0,'predecessor_replays':0}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--write',action='store_true');args=p.parse_args();t=time.monotonic();x=derive();raw=(json.dumps(x,indent=2)+'\n').encode()
    if args.write:(H/'result.json').write_bytes(raw)
    else:assert (H/'result.json').read_bytes()==raw
    print(json.dumps({'status':'pass','source_excerpts':x['source_excerpts'],'native_bodies':x['native_bodies'],'instruction_bytes':x['instruction_bytes'],'setter_stack_bytes':4936,'direct_request_bytes':96,'elapsed_seconds':time.monotonic()-t},indent=2))
