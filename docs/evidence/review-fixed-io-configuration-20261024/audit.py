#!/usr/bin/env python3
"""One offline audit of the two new #212 freezes; no predecessor replay.

Source reachability and instruction semantics are reviewed manually. This
checks exact inputs, arithmetic and native byte attachment independently of
the author checkers. Native reads use PT_LOAD ranges instead of section ranges.
No selected target or libc service is executed.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import struct
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
IO = ROOT / 'docs/evidence/retained-fixed-report-composition-20261024/bodies'
NATIVE = ROOT / 'docs/evidence/retained-fixed-report-native-inputs-20261024'
IO_AUTHOR = '0f39a36c1458f7af4f216fce3f9bcde8d8aab123'
NATIVE_AUTHOR = '9bb63660fd9e29c7b67b359f00acd844f19771cc'
started = time.monotonic()


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


receipt = {}
targets = [(IO_AUTHOR, ROOT/'docs/research/retained-fixed-report-composition.md')]
targets += [(IO_AUTHOR, IO/name) for name in
            ('README.md', 'capacity.py', 'check.py', 'source-manifest.json',
             'message-census.json', 'result.json', 'round.json')]
targets += [(NATIVE_AUTHOR, NATIVE/name) for name in
            ('README.md', 'check.py', 'inputs.json', 'result.json',
             'new-sources.tar.gz')]
for commit, path in targets:
    rel = path.relative_to(ROOT).as_posix()
    raw = path.read_bytes()
    assert raw == subprocess.check_output(['git', 'show', commit+':'+rel], cwd=ROOT)
    receipt[rel] = dict(author_commit=commit, sha256=sha(raw))

manifest = json.loads((IO/'source-manifest.json').read_text())
for path, expected in manifest['repository_files'].items():
    assert sha((ROOT/path).read_bytes()) == expected, path
prefix = manifest['accepted_research_prefix']
assert sha((ROOT/prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']


def archive_check(spec):
    path = ROOT/spec['path']
    assert sha(path.read_bytes()) == spec['sha256']
    with tarfile.open(path) as stream:
        for member, expected in spec['members'].items():
            assert sha(stream.extractfile(member).read()) == expected, member


archive_check(manifest['archive'])
gcc = manifest['gcc_source']
known = {row['path']:row['sha256'] for row in
         json.loads((ROOT/gcc['manifest']).read_text())['files']}
for path, expected in gcc['files'].items():
    assert sha((Path(gcc['default_root'])/path).read_bytes()) == expected == known[path]
gnat = manifest['gnatcoll']
archive_check(dict(path=gnat['path'], sha256=gnat['sha256'],
                   members={gnat['member']:gnat['member_sha256']}))

f = load(IO/'capacity.py', 'review_io_composition')
saved = json.loads((IO/'result.json').read_text())
graphs = f.graph_rows()
# Independently sum the documented constructors and remaining emitter rows.
constructors = {
    'Put_Line': [10,34,50,105,12,6,2,4,25,16,2,4,16],
    'Put': [10,34,40,75,9,6,2,3,25,16,2,4,15],
    'Silver_IO': [10,14,25,16,4,6],
}
flow_sums = {}
for name, objects, calls in [('Put_Line',17,7), ('Put',17,5), ('Silver_IO',7,0)]:
    vertices = sum(constructors[name])
    if calls:
        rows = [1, 8*objects, 6*objects, 2*vertices*objects,
                vertices, 2*objects, vertices+1, vertices,
                2*vertices*objects+2*objects, objects, 13*calls, 2]
    else:
        rows = [1, 4*objects, 6*objects, 2*vertices*objects,
                vertices+1, vertices, 2*vertices*objects+2*objects, 2]
    flow_sums[name] = sum(rows)
    assert graphs[name]['eligible_vertices'] == vertices
    assert graphs[name]['flow_records'] == sum(rows)
    assert graphs[name]['constructor_vertices'] == 19837+vertices
assert flow_sums == dict(Put_Line=20724, Put=17503, Silver_IO=2338)
assert sum(flow_sums.values())+2+8*18 == 40711
assert 16547+21+17+13*(7+5) == 16741

endpoints = {}
for path in (0, 1, 607, 608):
    row = f.io_report(path_bytes=path)
    reader = f.c.parsed_report(row['full'], path_bytes=path,
                              max_path=4096, page_size=65536)
    guards = dict(row['incoming']['guards'], **row['writer']['guards'],
                  **row['flow_brief']['guards'], **reader['guards'],
                  third_pool=row['third_pool']['guard'])
    assert row['full'].pretty == 478273421+1568238*path
    assert row['projected'].pretty == (
        saved['projected_pretty_affine']['constant']
        + saved['projected_pretty_affine']['path_coefficient']*path)
    assert row['printed_cp_bytes'] == 15581 and row['proof_message_bytes'] == 31439
    assert row['claim_domain'] == {'claims':30,'edges':42}
    assert row['incoming']['trace_attempts'] == 19570
    assert row['third_pool']['find_calls'] == 2*(12+12+52+40711+40+30+42)
    assert row['source_counts_bound'] and not row['whole_process_capacity_bound']
    assert not row['path_configuration_bound']
    assert not row['source_span_join_complete']
    assert not row['native_warning_location_join_complete']
    assert all(guards.values()) == (path <= 607)
    endpoints[str(path)] = dict(pretty=row['full'].pretty,
        writer_backing=row['writer']['unbounded_allocation'],
        failed_guards=[key for key,value in guards.items() if not value])
    if path == 607:
        assert saved['endpoint_writer'] == row['writer']
        assert saved['endpoint_reader'] == reader
        assert saved['incoming'] == row['incoming']

# Exercise exactly the fixed-character classes claimed by factor two. Path
# controls and non-ASCII bytes retain the generic factor six independently.
fixed = ''.join(chr(x) for x in range(32,127))+'\b\f\n\r\t'
path = '/controls/\x00\x01\x1f/é/漢/😀'
encoded = json.dumps(fixed+path, ensure_ascii=True)
assert len(encoded) <= f.mixed_string(len(fixed),len(path.encode())).pretty

native_inputs = json.loads((NATIVE/'inputs.json').read_text())
native_saved = json.loads((NATIVE/'result.json').read_text())
for row in native_inputs['repository']:
    assert sha((ROOT/row['path']).read_bytes()) == row['sha256']
for archive in native_inputs['archives']:
    archive_check(archive)
reader = load(ROOT/native_inputs['elf_reader'], 'review_native_symbols')
native_receipt = []
for target, retained in zip(native_inputs['targets'], native_saved['native'], strict=True):
    raw = Path(target['path']).read_bytes()
    assert len(raw) == target['bytes'] and sha(raw) == target['sha256']
    elf = reader.Elf(raw)
    header = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
    segments = [struct.unpack_from('<IIQQQQQQ', raw, header[5]+i*header[9])
                for i in range(header[10])]

    def mapped(address, size):
        fits = [s for s in segments if s[0] == 1 and s[3] <= address
                and address+size <= s[3]+s[5]]
        assert len(fits) == 1
        s = fits[0]
        offset = s[2]+address-s[3]
        return raw[offset:offset+size]

    def symbol(name):
        sym = elf.symbols[name]
        return mapped(sym['address'], sym['bytes'])

    name = 'spark2014vsn__spark2014_version_string'
    function = symbol(name)
    assert function.hex() == retained['version_function_hex']
    assert len(function) == 66
    assert function[:15] == bytes.fromhex('4883ec08be04000000bf14000000e8')
    destination = elf.symbols[name]['address']+19+int.from_bytes(function[15:19], 'little', signed=True)
    assert destination == elf.symbols['system__secondary_stack__ss_allocate']['address']
    assert struct.unpack('<ii',function[21:29]) == (1,10)
    value = function[31:39]+function[43:45]
    assert value == b'FSF 16.1.0'
    assert symbol('spark2014vsn__spark2014_static_version_string') == value+bytes(6)
    assert symbol('__gnat_max_path_len') == (4096).to_bytes(4,'little',signed=True)
    info = dict(role=target['role'], target_sha256=sha(raw),
                version_text=value.decode(), version_length=10, max_path=4096,
                attachment='independent PT_LOAD-address mapping')
    if target['role'] == 'reporter':
        name = 'gnatcoll__mmap__system__get_page_size'
        function = symbol(name)
        assert function.hex() == retained['page_function_hex']
        plt = elf.symbols[name]['address']+9+int.from_bytes(function[5:9],'little',signed=True)
        jump = mapped(plt,6)
        assert jump[:2] == bytes.fromhex('ff25')
        slot = plt+6+int.from_bytes(jump[2:6],'little',signed=True)
        imports = []
        for section in elf.sections:
            if section[1] != 4:
                continue
            symbols = elf.sections[section[6]]
            if symbols[1] != 11:
                continue
            strings = elf.sections[symbols[6]]
            names = raw[strings[4]:strings[4]+strings[5]]
            for pos in range(section[4],section[4]+section[5],section[9]):
                address, relocation, addend = struct.unpack_from('<QQq',raw,pos)
                if address == slot:
                    assert relocation & 0xffffffff == 7 and addend == 0
                    off = symbols[4]+(relocation >> 32)*symbols[9]
                    index = struct.unpack_from('<I',raw,off)[0]
                    imports.append(names[index:names.index(0,index)].decode())
        assert imports == ['getpagesize']
        info['page_import'] = imports[0]
        info['retained_host_service_observation'] = native_saved['observed_page_size']
        assert info['retained_host_service_observation'] == 4096
    native_receipt.append(info)

result = dict(status='PASS', exact_inputs=receipt, io_graph_flow_sums=flow_sums,
    io_endpoints=endpoints, native=native_receipt,
    author_checker_runs=0, predecessor_checker_runs=0,
    selected_target_executions=0, compiler_prover_runs=0, libc_service_queries=0,
    selected_host=platform.platform(), elapsed_seconds=round(time.monotonic()-started,6),
    complete_common_path=False, gnat2why_owner_attachment=False,
    complete_issue_212=False, complete_issue_119=False)
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps({key:result[key] for key in ('status','elapsed_seconds','io_endpoints')},indent=2))
