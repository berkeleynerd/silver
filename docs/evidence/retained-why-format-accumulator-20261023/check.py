"""Focused author identity/layout check. No predecessor or native execution."""
import hashlib
import io
import json
from pathlib import Path
import struct
import subprocess
import tarfile
import time
from transfer import derive, MAX_INT, MAX_STRING, MAX_WOSIZE

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]


def identity(b): return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def main():
    start=time.perf_counter()
    census=json.loads((HERE/'census.json').read_text())
    inputs=json.loads((HERE/'inputs.json').read_text())
    witnesses=json.loads((HERE/'source-witnesses.json').read_text())
    native=json.loads((HERE/'native-witnesses.json').read_text())
    providers=json.loads((HERE/'providers.json').read_text())
    blobs={}
    for p,expected in inputs.items():
        b=subprocess.check_output(['git','show',census['base']+':'+p],cwd=ROOT)
        assert identity(b)==expected,p
        blobs[p]=b
    members={};seen=set()
    for row in witnesses:
        archive=row['archive'];data=blobs[archive]
        assert identity(data)==row['archive_identity']
        if archive not in members:
            with tarfile.open(fileobj=io.BytesIO(data),mode='r:gz') as a:
                names={r['member'] for r in witnesses if r['archive']==archive}
                members[archive]={n:a.extractfile(n).read() for n in names}
        raw=members[archive][row['member']]
        assert identity(raw)==row['member_identity']
        lines=raw.decode().splitlines(keepends=True)
        first,last=row['first'],row['last']
        assert type(first) is int and type(last) is int
        assert 1<=first<=last<=len(lines)
        key=(archive,row['member'],first,last)
        assert key not in seen;seen.add(key)
        excerpt=''.join(lines[first-1:last])
        assert excerpt==row['excerpt'] and identity(excerpt.encode())==row['excerpt_identity']
    assert max(r['bytes'] for r in census['source_literals'])==census['literal_source_byte_maximum']==90
    assert all(len(r['source'].encode())==r['bytes'] for r in census['source_literals'])
    assert census['conservative_format_tree_and_accumulator_nodes']==4*(90+1)==364
    assert len('invalid box description ')+4*5+2==census['annotation_error_bytes_upper']==46
    assert providers['output']==json.loads(blobs['docs/evidence/retained-why-printer-output-20261023/result.json'])
    assert providers['raw_name']==json.loads(blobs['docs/evidence/retained-why-raw-name-length-20261023/result.json'])
    binary=Path(native['executable']['path']).read_bytes()
    assert identity(binary)==native['executable']['identity']
    assert binary[:6]==b'\x7fELF\x02\x01'
    phoff=struct.unpack_from('<Q',binary,32)[0]
    phsize,phnum=struct.unpack_from('<HH',binary,54)
    segments=[]
    for i in range(phnum):
        ptype,flags,off,va,pa,fs,ms,align=struct.unpack_from('<IIQQQQQQ',binary,phoff+i*phsize)
        if ptype==1:segments.append((va,va+fs,off))
    verified={}
    rows=list(native['closure_header_witnesses'])
    for body in native['bodies'].values():
        assert identity(body['text'].encode())==body['identity']
        rows.extend(body['instructions'])
    for row in rows:
        addr=row['address'];raw=bytes.fromhex(row['hex'])
        offsets=[off+addr-lo for lo,hi,off in segments if lo<=addr and addr+len(raw)<=hi]
        assert len(offsets)==1 and binary[offsets[0]:offsets[0]+len(raw)]==raw
        if addr in verified:assert verified[addr]==raw
        verified[addr]=raw
    assert all(r['header']&255==247 and r['header']>>10==r['payload_words']
               for r in native['closure_header_witnesses'])
    assert max(r['payload_words'] for r in native['closure_header_witnesses'])==103
    assert 4*3+16==28<128<MAX_WOSIZE and 8*(128+1)==1032<MAX_INT
    result=derive(census,providers)
    assert len(result['cases'])==5 and all(len(c['drivers'])==3 for c in result['cases'])
    assert result['all_local_representation_guards']
    assert result['global_escape_budget']==2 and not result['budget_renewed']
    assert not result['whole_printer_capacity'] and not result['aggregate_RAM_or_stack_gate']
    assert MAX_STRING==8*MAX_WOSIZE-1
    (HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    report=dict(status='pass',inputs=len(inputs),source_spans=len(witnesses),
                source_members=sum(map(len,members.values())),driver_case_joins=15,
                native_functions=len(native['bodies']),
                instruction_fragments_byte_matched=len(verified),
                instruction_bytes_byte_matched=sum(map(len,verified.values())),
                elapsed_seconds=time.perf_counter()-start,
                new_native_or_disassembler_executions=0,predecessor_programs_run=0,
                source_argument_machine_checked=False,independent_review=False)
    (HERE/'check-result.json').write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(json.dumps(report))


if __name__=='__main__':main()
