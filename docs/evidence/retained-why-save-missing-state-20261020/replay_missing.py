#!/usr/bin/env python3
"""Decode only the fresh missing-state projection from retained bytes.

No old observer, binder, alpha, target, solver or proof execution. The new
collector uses accumulated complete blocks plus its extension-only direct reads.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import time
import missing_state
from correspondence import identity, load_blocks, fields, get

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('accepted_raw_store',HERE.parent/'retained-why-session-save-observer-20261018/session_observer.py')
api=importlib.util.module_from_spec(spec);spec.loader.exec_module(api)


class RetainedMemory:
    def __init__(self,capture):
        self.blocks=load_blocks(capture/'session-blocks.jsonl');self.direct={}
        with (capture/'save-state-memory-reads.jsonl').open() as f:
            for line in f:
                row=json.loads(line);raw=bytes.fromhex(row['hex']);key=row['address'],row['bytes']
                assert len(raw)==key[1]
                assert self.direct.setdefault(key,raw)==raw,('read changed at stopped state',key)
    def read(self,address,size):
        if (address,size) in self.direct:return self.direct[address,size]
        if address+8 in self.blocks and size==8:
            tag,words,raw=self.blocks[address+8]
            # Preserve the original retained header including GC color bits.
            return self.headers[address+8]
        tag,words,raw=self.blocks[address]
        assert size==len(raw)
        return raw
    def load_headers(self,capture):
        self.headers={}
        with (capture/'session-blocks.jsonl').open() as f:
            for line in f:
                row=json.loads(line);self.headers[row['address']]=bytes.fromhex(row['header_hex'])


class Session:
    def __init__(self,memory,capture,out,plan):
        self.out=out;self.roots=get(capture/'session-root.json')
        self.session_fields=fields(memory.blocks,self.roots['session'],17)
        self.store=api.RawStore(memory.read,out,plan['session_observer']['limits'])
        path=capture/'session-symbols.json'
        if path.exists():
            meta=get(path);self.symbols={k:v['address'] for k,v in meta['checks'].items()}
        else:self.symbols=get(capture/'session-observer.json')['symbols']
    def address(self,name):return self.symbols[name]
    def save(self,name,value):(self.out/name).write_text(json.dumps(value,indent=2)+'\n')


def replay(capture):
    start=time.perf_counter();plan=get(capture.parent.parent/'plan.json');saved=get(capture/'save-missing-state.json')
    assert saved['complete'] and not saved['capacity_established']
    recorded_root=Path(plan['inputs'][0]['cwd']).parent
    assert identity(HERE/'missing_state.py')==plan['file_identities'][str(recorded_root/'missing_state.py')]
    observer=HERE.parent/'retained-why-session-save-observer-20261018/session_observer.py'
    assert identity(observer)==plan['file_identities'][str(recorded_root/'session_observer.py')]
    memory=RetainedMemory(capture);memory.load_headers(capture)
    with tempfile.TemporaryDirectory(prefix='save-missing-replay-') as directory:
        out=Path(directory);session=Session(memory,capture,out,plan)
        try:result=missing_state.collect(session,plan,saved['phase'])
        finally:session.store.close()
        assert result['complete']
        checked=[]
        for path in out.iterdir():
            # RawStore dedup/cache history differs from the earlier observer;
            # the complete typed projection and graph address lists must agree.
            if path.name in ('session-blocks.jsonl','save-state-memory-reads.jsonl'):continue
            assert identity(path)==identity(capture/path.name),('decoded file differs',path.name)
            checked.append(path.name)
    return {'scope':'Fresh extension typed decode from accumulated retained blocks/direct reads',
            'capture':str(capture),'input_identities':{n:identity(capture/n) for n in ['session-blocks.jsonl','save-state-memory-reads.jsonl','save-missing-state.json','session-root.json']},
            'byte_equal_files':sorted(checked),'complete':True,'old_observer_replays':0,
            'binder_recomputations':0,'alpha_replays':0,'native_runs':0,'elapsed_seconds':time.perf_counter()-start}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--capture',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    result=replay(a.capture);a.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
