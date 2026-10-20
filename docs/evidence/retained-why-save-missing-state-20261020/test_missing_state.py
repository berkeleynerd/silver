#!/usr/bin/env python3
"""Offline safety/layout fixtures; no target, proof, binder or alpha execution."""
import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import unittest
import missing_state as ms

HERE = Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('accepted_observer', HERE.parent/'retained-why-session-save-observer-20261018/session_observer.py')
api=importlib.util.module_from_spec(spec);spec.loader.exec_module(api)


def i(n): return ((n << 1) | 1) & ((1 << 64)-1)


class Memory:
    def __init__(self): self.m={};self.next=0x10000;self.reads=[]
    def put(self,a,b): self.m.update((a+j,v) for j,v in enumerate(b))
    def word(self,a,n):self.put(a,struct.pack('<Q',n))
    def block(self,fields,tag=0):
        p=self.next+8;self.word(p-8,len(fields)<<10|tag)
        self.put(p,struct.pack('<'+'Q'*len(fields),*fields));self.next+=(len(fields)+1)*8
        return p
    def string(self,s):
        raw=s.encode() if isinstance(s,str) else s
        pad=7-len(raw)%8; raw += b'\0'*pad+bytes([pad])
        return self.block(struct.unpack('<'+'Q'*(len(raw)//8),raw),252)
    def seq(self,x):
        p=1
        for v in reversed(x):p=self.block([v,p])
        return p
    def table(self,rows,ints=True):
        heads=[1]*4
        for k,v in reversed(rows):
            n=(ms.integer(k)&3) if ints else 0
            heads[n]=self.block([k,v,heads[n]])
        return self.block([i(len(rows)),self.block(heads),i(0),i(4)])
    def read(self,a,n):
        raw=bytes(self.m[a+j] for j in range(n));self.reads.append((a,n,raw));return raw


class Session:
    def __init__(self,m,out,fields):
        self.store=api.RawStore(m.read,out,api.DEFAULT_LIMITS)
        self.session_fields=fields;self.roots={'complete':True,'session':m.block(fields)};self.out=out
    def address(self,name):return ms.SYMBOLS[name]['elf_value']+0x80000000
    def save(self,name,v):(self.out/name).write_text(json.dumps(v,indent=2)+'\n')


def fixture(out):
    m=Memory()
    def ident(name,tag):return m.block([m.string(name),1,1,i(tag)])
    goalname=ident('Goal',7);theoryname=ident('Theory',8)
    prover=m.block([m.string('cvc5'),m.string('1.2'),m.string('')])
    attempts=m.table([(prover,i(0)),(prover,i(0))],False)
    theory=m.block([theoryname,m.seq([i(1)]),i(0),i(0)])
    pn=m.block([goalname,m.string('explanation'),m.block([theory],1),attempts,1])
    file=m.block([i(0),m.seq([m.string('src'),m.string('a.mlw')]),m.string('whyml'),i(0),m.seq([theory])])
    lim=m.block([m.block([0],253),i(100),i(-1)])
    attempt=m.block([i(1),prover,lim,1,i(0),m.block([m.seq([m.string('proof.why')])])])
    text=m.string('shape')
    hyp=m.block([1,text,i(-2),1,i(1)]);index=m.block([1,i(-2),text,1,i(1)])
    gs=m.block([hyp,index,i(5)])
    shape=m.block([i(5),i(1),gs,m.table([(i(1),m.seq([i(-2),i(5)]))]),
                   m.table([(i(1),m.string('old'))]),m.table([(i(1),m.string('checksum'))])])
    fields=[m.table([(i(0),attempt)]),i(1),m.table([(i(1),pn)]),i(2),m.table([]),i(0),i(1),
            m.string('session'),m.table([(i(0),file)]),m.table([(prover,i(-4)),(prover,i(2))],False),shape,
            m.table([]),m.table([]),m.table([(i(0),i(1))]),m.table([(theoryname,i(1))],False),m.table([]),m.table([(i(1),i(0))])]
    session=Session(m,out,fields)
    for witness in ms.LAYOUT_CHECKS:m.put(session.address(witness['symbol'])+witness['offset'],bytes.fromhex(witness['code_hex']))
    buf=m.block([m.string('0123456789'),i(4),i(10),m.string('abc')]);m.word(session.address('camlWhy3__Termcode')+0x1c0,buf)
    none=0x77770000;m.word(session.address('caml_ephe_none'),none)
    restored=m.block([m.seq([m.string('lib')]),m.string('Theory'),m.seq([m.string('Scope'),m.string('Goal')])])
    eph=m.block([0,restored,goalname],251)
    heads=[1]*4;heads[7&3]=m.block([i(7),eph,1])
    weak=m.block([i(1),m.block(heads),i(0),i(4)])
    closure=m.block([session.address('camlWhy3__Theory__restore_path_4035'),0x100000000000005,weak],247)
    m.word(session.address('camlWhy3__Theory')+0x100,closure)
    return m,session,{'buffer':buf,'shape':shape,'prover':prover,'goalname':goalname}


class Check(unittest.TestCase):
    def test_all_sections_and_duplicates(self):
        with tempfile.TemporaryDirectory() as d:
            m,s,roots=fixture(Path(d));out=ms.collect(s,{},'fixture')
            self.assertTrue(out['complete'],out['sections'])
            p=out['sections']['prover_ids']['value'];self.assertEqual((p['size'],p['binding_visits'],p['bucket_capacity']),(2,2,4))
            self.assertEqual([r['value'] for r in p['entries']],[-4,2])
            self.assertEqual(out['sections']['bound_shapes']['value']['entries'][0]['value']['indices'],[-2,5])
            paths=out['sections']['restore_paths']['value']['required_identifiers']
            self.assertEqual([p['serializer_name_bytes'] for p in paths],[10,6])
            self.assertEqual(out['sections']['shape_buffer']['value']['capacity'],10)
            s.store.close()
    def test_cycle_and_shared_chains_fail_without_hiding_bytes(self):
        with tempfile.TemporaryDirectory() as d:
            m,s,_=fixture(Path(d));x=ms.MissingState(s,{},'fixture')
            cell=m.block([i(0),i(9),1]);m.word(cell+16,cell)
            table=m.block([i(1),m.block([cell,1,1,1]),i(0),i(4)])
            with self.assertRaisesRegex(ValueError,'cycle or shared'):x.table(table,ms.integer,ms.integer)
            self.assertIn(cell,s.store.seen);s.store.close()
    def test_bad_buffer_and_unreadable_table_stay_unknown(self):
        with tempfile.TemporaryDirectory() as d:
            m,s,roots=fixture(Path(d));m.word(roots['buffer']+8,i(11));s.session_fields[9]=0x66660000
            out=ms.collect(s,{},'fixture')
            self.assertFalse(out['complete']);self.assertFalse(out['sections']['shape_buffer']['known'])
            self.assertIsNone(out['sections']['prover_ids']['value']);self.assertTrue(out['sections']['gshape']['known']);s.store.close()
    def test_size_is_not_binding_visits(self):
        with tempfile.TemporaryDirectory() as d:
            m,s,_=fixture(Path(d));m.word(s.session_fields[9],i(0))
            out=ms.collect(s,{},'fixture');t=out['sections']['prover_ids']['value']
            self.assertEqual(t['binding_visits'],2);self.assertEqual(t['size'],0)
            self.assertFalse(t['size_equals_binding_visits']);s.store.close()
    def test_map_bad_height_fails_and_signed_indices_preserved(self):
        with tempfile.TemporaryDirectory() as d:
            m,s,roots=fixture(Path(d));x=ms.MissingState(s,{},'fixture');p=m.block([1,i(-3),m.string('x'),1,i(7)])
            with self.assertRaisesRegex(ValueError,'height'):x.map(p,ms.integer,x.string)
            self.assertIn(p,s.store.seen);s.store.close()
    def test_partial_string_does_not_default_empty(self):
        with tempfile.TemporaryDirectory() as d:
            m,s,_=fixture(Path(d));x=ms.MissingState(s,{},'fixture');p=m.string('24-byte-payload-value-xxx')
            del m.m[p+19]
            with self.assertRaises(KeyError):x.string(p)
            s.store.close()


if __name__=='__main__':unittest.main()
