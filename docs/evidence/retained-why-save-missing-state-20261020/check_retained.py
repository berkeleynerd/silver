#!/usr/bin/env python3
"""Exercise new decoder/isomorphism on hash-checked Is_Message retained bytes.
No accepted binder/alpha/observer interpreter is invoked.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import time
import missing_state as ms
from correspondence import identity,load_blocks,fields,compare_graphs,accepted_inputs,get

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('accepted_raw_store_fixture',HERE.parent/'retained-why-session-save-observer-20261018/session_observer.py')
api=importlib.util.module_from_spec(spec);spec.loader.exec_module(api)


class Renamed:
    def __init__(self,blocks,delta):self.blocks,self.delta=blocks,delta
    def __getitem__(self,address):
        tag,words,raw=self.blocks[address-self.delta]
        if tag<246:
            values=struct.unpack('<'+'Q'*words,raw)
            raw=struct.pack('<'+'Q'*words,*(v if v&1 else v+self.delta for v in values))
        return tag,words,raw


def check(capture):
    start=time.perf_counter();accepted,manifest,cert_path,cert=accepted_inputs('is_message')
    names=['session-blocks.jsonl','session-root.json']
    for n in names:assert identity(capture/n)==manifest['is_message/capture/'+n]
    blocks=load_blocks(capture/'session-blocks.jsonl');headers={}
    with (capture/'session-blocks.jsonl').open() as f:
        for line in f:
            r=json.loads(line);headers[r['address']]=bytes.fromhex(r['header_hex'])
    def read(address,size):
        if size==8 and address+8 in headers:return headers[address+8]
        raw=blocks[address][2];assert len(raw)==size;return raw
    roots=get(capture/'session-root.json');sf=fields(blocks,roots['session'],17)
    previous=get(HERE.parent/'retained-why-save-entry-inputs-20261020/is-message.json')
    with tempfile.TemporaryDirectory(prefix='save-retained-fixture-') as d:
        class Session:
            out=Path(d);store=api.RawStore(read,Path(d),api.DEFAULT_LIMITS)
            def save(self,name,value):(self.out/name).write_text(json.dumps(value,indent=2)+'\n')
        session=Session();decoder=ms.MissingState(session,{},'retained fixture only')
        assert decoder.string(sf[7])==previous['session_dir']
        table=decoder.table(sf[0],ms.integer,lambda p:p)
        assert table['binding_visits']==previous['table_bindings']['proof_attempts']
        decoder.section('old_missing_prover_ids',lambda:decoder.table(sf[9],decoder.prover,ms.integer))
        assert decoder.result['sections']['old_missing_prover_ids']['value'] is None
        session.store.close()
    pointers=[p for task in cert['tasks'].values() for p in task['logical_declarations']]
    delta=0x1000000000;join=compare_graphs(blocks,Renamed(blocks,delta),[(p,p+delta) for p in pointers])
    assert all(v==k+delta for k,v in join.items())
    return {'scope':'New decoder and raw pointer-bijection safety on accepted Is_Message bytes; synthetic renaming is not a fresh native-process join',
        'accepted_pid':accepted['pid'],'inputs':{n:identity(capture/n) for n in names},
        'accepted_certificate_identity':identity(cert_path),'decoded_session_directory_bytes':previous['session_dir']['bytes'],
        'decoded_proof_attempt_table_bindings':table['binding_visits'],'decoded_proof_attempt_table_capacity':table['bucket_capacity'],
        'missing_old_prover_id_state_remains_unknown':True,'synthetically_renamed_real_graph_blocks':len(join),
        'native_runs':0,'observer_replays':0,'binder_recomputations':0,'alpha_replays':0,'elapsed_seconds':time.perf_counter()-start}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--capture',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    result=check(a.capture);a.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
