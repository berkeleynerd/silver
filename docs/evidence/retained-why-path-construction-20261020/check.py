#!/usr/bin/env python3
"""Focused retained-byte/source and concat-bound checks; no native execution."""
import hashlib
import itertools
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import construction_bounds, MAX_STRING_BYTES, PREMISES

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')

def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}

def read(p):
    return json.loads(p.read_text())

def main():
    start = time.monotonic()
    inputs = read(HERE/'inputs.json')
    for category, root in (('files', ROOT), ('local_files', HERE)):
        for name, expected in inputs[category].items():
            assert identity((root/name).read_bytes()) == expected, name
    sources = read(HERE/'source-witnesses.json')
    for s in sources:
        with tarfile.open(ROOT/s['archive']) as archive:
            raw = archive.extractfile(s['member']).read()
        assert identity(raw) == s['member_identity']
        assert ''.join(raw.decode().splitlines(keepends=True)[s['first_line']-1:s['last_line']]) == s['text']
    native = read(HERE/'native-witnesses.json')
    elf = Path(native['executable']['path']).read_bytes()
    assert identity(elf) == native['executable']['identity']
    assert elf[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q', elf, 32)[0]
    entsize, count = struct.unpack_from('<HH', elf, 54)
    loads=[]
    for i in range(count):
        kind, flags, off, addr, _, size, _, _ = struct.unpack_from('<IIQQQQQQ', elf, phoff+i*entsize)
        if kind == 1: loads.append((addr,addr+size,off,flags))
    def at(addr,size,executable=False):
        for lo,hi,off,flags in loads:
            if lo <= addr and addr+size <= hi and (not executable or flags & 1):
                return elf[off+addr-lo:off+addr-lo+size]
        raise AssertionError((addr,size))
    bodies = read(HERE/'native-bodies.json')
    assert sorted(bodies) == native['body_names']
    checked=0
    for name, text in bodies.items():
        assert re.search(r'^[0-9a-f]+ <'+re.escape(name)+'>:',text)
        for line in text.splitlines():
            match=INSN.match(line)
            if match:
                addr,data=int(match[1],16),bytes.fromhex(match[2])
                assert at(addr,len(data),True)==data
                checked+=len(data)
    assert checked==native['instruction_bytes']
    dot=native['dot_literal']; addr=int(dot['address'],16)
    raw=at(addr-8,16)
    assert raw.hex()==dot['header_and_payload_hex']
    words=struct.unpack_from('<Q',raw)[0] >> 10
    assert words==1 and 8*words-1-raw[-1]==1 and raw[8:9]==b'.'
    # Exact route/poll/backedge diagnostics corroborate the reviewed source proof.
    assert '<camlStdlib__String__concat_419>' in bodies['camlWhy3__Session_itp__save_ident_4262']
    assert 'jmp    951b44 ' in bodies['camlStdlib__String__sum_lengths_403']
    assert 'jmp    951be4 ' in bodies['camlStdlib__String__unsafe_blits_410']
    assert 'jmp    951b4d ' in bodies['camlStdlib__String__sum_lengths_403']
    assert 'jmp    951bf0 ' in bodies['camlStdlib__String__unsafe_blits_410']
    assert '$0x1fffffffffffff7' in bodies['caml_create_bytes']
    assert '<memmove@plt>' in bodies['caml_blit_string']
    complete={p:True for p in PREMISES}
    enumerated=0
    for m in range(1,7):
        for lengths in itertools.product(range(4),repeat=m):
            j=sum(lengths)+m-1
            result=construction_bounds(j,1,1,complete)
            assert result['construction_bounds'] is not None
            assert m <= result['candidate']['component_count_per_nonempty_path_upper']
            offset=0; calls=0; copied=0
            for i,a in enumerate(lengths):
                assert 0<=offset<=j and offset+a<=j
                offset+=a; copied+=a; calls+=1
                if i+1<m:
                    assert offset+1<=j
                    offset+=1; copied+=1; calls+=1
            assert offset==copied==j and calls==2*m-1
            enumerated+=1
    assert construction_bounds(MAX_STRING_BYTES,1,1,complete)['construction_bounds'] is not None
    assert construction_bounds(MAX_STRING_BYTES+1,1,1,complete)['construction_bounds'] is None
    assert construction_bounds(0,1,1,complete)['candidate']['requested_string_block_bytes_per_concat_upper']==16
    for p in PREMISES:
        assert construction_bounds(25,2,premises={**complete,p:False})['construction_bounds'] is None
    for values in ((True,1,1),(-1,1,1),(1,False,1),(1,1,-1)):
        try: construction_bounds(*values)
        except ValueError: pass
        else: raise AssertionError(values)
    for bad in ({'unknown':True},{PREMISES[0]:1}):
        try: construction_bounds(1,1,premises=bad)
        except ValueError: pass
        else: raise AssertionError(bad)
    path=read(ROOT/'docs/evidence/retained-why-path-payload-bound-20261020/result.json')
    expected=[]
    for c in path['cases']:
        expected.append({'case':c['case'],'pid':c['pid'],'payload_candidate':path['library_origin_lemma_payload_upper'],
                         'no_external_assertion':construction_bounds(path['library_origin_lemma_payload_upper'],c['identifier_occurrences']),
                         'under_supplied_premises':construction_bounds(path['library_origin_lemma_payload_upper'],c['identifier_occurrences'],premises=complete)})
    assert read(HERE/'result.json')['cases']==expected
    print(json.dumps({'status':'pass','source_excerpts':len(sources),'native_bodies':len(bodies),
                      'instruction_bytes':checked,'native_literal_bytes':16,'small_length_lists':enumerated,
                      'cases':len(expected),'actual_path_bound_established':False,'native_runs':0,
                      'elapsed_seconds':time.monotonic()-start},indent=2))

if __name__=='__main__': main()
