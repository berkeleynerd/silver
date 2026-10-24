#!/usr/bin/env python3
"""Independent offline review; no author checker/extractor or native execution.

Run phases separately so a later fixture defect never repeats a successful
source/ELF phase. The math phase imports only the supplied mathematical API.
"""
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import re
import struct
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = '22cdc0d78c850525c78f8c3bda05424462324f84'
PREVIOUS = '0d64f5f7d18b77632146174f1777be238cc43f60'
PACKET = ROOT/'docs/evidence/retained-main-construction-demand-20261024/shared-services'
COUNTS = Counter()


def check(ok, name):
    if not ok:
        raise AssertionError(name)
    COUNTS[name] += 1


def sha(b):
    return hashlib.sha256(b).hexdigest()


def read(name):
    return json.loads((PACKET/name).read_text())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def source_elf():
    changes = git('diff', '--name-only', PREVIOUS, AUTHOR).decode().splitlines()
    prefix = str(PACKET.relative_to(ROOT))+'/'
    note = 'docs/research/retained-main-construction-demand.md'
    check(all(p.startswith(prefix) or p == note for p in changes), 'author scope')
    check(git('show', AUTHOR+':'+note).startswith(git('show', PREVIOUS+':'+note)), 'immutable research prefix')
    identities = []
    for p in sorted(PACKET.iterdir()):
        if p.is_file():
            rel = str(p.relative_to(ROOT))
            check(p.read_bytes() == git('show', AUTHOR+':'+rel), 'exact author input')
            identities.append({'path': rel, 'sha256': sha(p.read_bytes())})
    for p in read('inputs.json')['providers']:
        check(sha((ROOT/p['path']).read_bytes()) == p['sha256'], 'accepted provider identity')
        check((ROOT/p['path']).read_bytes() == git('show', PREVIOUS+':'+p['path']), 'provider unchanged from accepted author')
    supplements = []
    for a in read('source-witnesses.json'):
        check(sha((ROOT/a['path']).read_bytes()) == a['sha256'], 'source archive identity')
        with tarfile.open(ROOT/a['path']) as tf:
            for f in a['files']:
                raw = tf.extractfile(f['path']).read()
                check(sha(raw) == f['sha256'], 'complete source identity')
                lines = raw.decode().splitlines()
                for s in f['spans']:
                    body = '\n'.join(lines[s['first']-1:s['last']])+'\n'
                    check(body == s['source'] and sha(body.encode()) == s['sha256'], 'exact source excerpt')
            if 'ocaml' in a['path']:
                for suffix, first, last in [('runtime/weak.c', 399, 485), ('stdlib/array.ml', 78, 95), ('stdlib/array.ml', 128, 129)]:
                    name = next(n for n in tf.getnames() if n.endswith('/'+suffix))
                    raw = tf.extractfile(name).read()
                    body = '\n'.join(raw.decode().splitlines()[first-1:last])+'\n'
                    supplements.append({'archive': a['path'], 'path': name, 'complete_sha256': sha(raw),
                                        'first': first, 'last': last, 'sha256': sha(body.encode()), 'source': body})
    # Independent ELF parser, including declared symbol extents; no objdump.
    w = read('native-witnesses.json')
    raw = Path(w['executable']['path']).read_bytes()
    check(sha(raw) == w['executable']['identity']['sha256'], 'retained ELF identity')
    check(raw[:6] == b'\x7fELF\x02\x01', 'ELF64 little endian')
    off = struct.unpack_from('<Q', raw, 40)[0]
    size, count = struct.unpack_from('<HH', raw, 58)
    sections = [struct.unpack_from('<IIQQQQIIQQ', raw, off+i*size) for i in range(count)]
    symbols = {}
    for sec in sections:
        if sec[1] != 2:
            continue
        st = sections[sec[6]]
        strings = raw[st[4]:st[4]+st[5]]
        for pos in range(sec[4], sec[4]+sec[5], sec[9]):
            name, info, _, ndx, addr, extent = struct.unpack_from('<IBBHQQ', raw, pos)
            name = strings[name:strings.find(b'\0', name)].decode()
            if 0 < ndx < len(sections):
                s = sections[ndx]
                symbols[name] = (addr, extent, s[4]+addr-s[3], bool(s[2]&4))
    bodies = read('native-bodies.json')
    check(set(bodies) == set(w['selected_bodies']) and len(bodies) == 65, 'selected native inventory')
    insn = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)(.*)$')
    total = 0
    reservations = []
    edges = set()
    sym_extents = {}
    for name, body in bodies.items():
        chunks = [(int(m[1], 16), bytes.fromhex(m[2]), m[3])
                  for line in body.splitlines() if (m := insn.match(line))]
        addr, extent, pos, executable = symbols[name]
        code = b''.join(c[1] for c in chunks)
        check(executable and chunks[0][0] == addr and len(code) >= extent, 'full ELF symbol extent retained')
        check(all(a+len(b) == c for (a,b,_),(c,_,_) in zip(chunks, chunks[1:])), 'contiguous retained bytes')
        check(raw[pos:pos+len(code)] == code, 'selected bytes agree with ELF')
        total += len(code)
        sym_extents[name] = {'ELF_symbol_bytes': extent, 'retained_bytes_including_alignment': len(code)}
        for a, codepart, assembly in chunks:
            # Independently decode direct call/jump displacement, not op text.
            if len(codepart) == 5 and codepart[0] in (0xe8, 0xe9):
                target = a+5+int.from_bytes(codepart[1:], 'little', signed=True)
                m = re.search(r'\b(?:call|jmp)\s+([0-9a-f]+)', assembly)
                check(m is not None and int(m[1],16) == target, 'direct rel32 target agrees with bytes')
        for ref in re.findall(r'<([^>+]+)(?:\+[^>]+)?>', body):
            if ref in symbols and symbols[ref][3] and ref not in bodies:
                edges.add(ref)
        reservations += [int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%r15', body)]
        r15 = [l for l in body.splitlines() if re.search(r',%r15\s*$',l)]
        check(all(re.search(r'\b(?:sub\s+\$0x[0-9a-f]+,|cmp\s+\(%r14\),|mov\s+0x8\(%r14\),)%r15',l) for l in r15), 'only fixed own heap reservations')
    check(total == 8576 and max(reservations) == 152, 'native bytes and fixed request ceiling')
    check(edges == set(w['external_code_references']) == {v['target'] for v in read('native-boundary.json')['direct_code_edges']}, 'every external direct code edge has disposition')
    for name, expected in [('camlWhy3__Ty__tag_2290',24), ('camlWhy3__Ity__tag_3788',32)]:
        body = bodies[name]
        check([int(x,16) for x in re.findall(r'sub\s+\$(0x[0-9a-f]+),%r15',body)] == [expected], 'tag copy exact reservation')
    for name, c in w['constant_closures'].items():
        addr, _, pos, _ = symbols[name]
        header = struct.unpack_from('<Q',raw,pos-8)[0]
        words = struct.unpack_from('<'+'Q'*(c['size']//8),raw,pos)
        check(addr == c['address'] and header == c['header'] and (header>>10)*8 == c['size'], 'purity closure exact extent')
        check(all(symbols[t][0] in words for t in c['targets']), 'purity closure exact target')
    old = (PACKET/'check-initial.py').read_text()
    check(old.replace("n=='apply_vsb_add'", "n=='formal_actual_add'") == (PACKET/'check.py').read_text(), 'author repair is selector only')
    check(read('diagram-result.json')['assertions'] == 20 and read('diagram-result.json')['native_census'] is None, 'author corrected diagram receipt scope')
    check(read('final-checks.json')['assertions'] == read('final-checks-initial.json')['assertions'] == 11, 'separate author final receipts')
    check(not read('round.json')['validation']['full_combined_green_run'], 'no invented initial all-green run')
    (HERE/'source-supplements.json').write_text(json.dumps(supplements,indent=2)+'\n')
    return {'inputs': identities, 'ELF_sha256': sha(raw), 'bodies': sym_extents, 'instruction_bytes': total,
            'max_own_reservation_bytes': max(reservations), 'external_direct_edges': sorted(edges)}


def math():
    spec = importlib.util.spec_from_file_location('independent_shared_api', PACKET/'shared.py')
    s = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = s
    spec.loader.exec_module(s)
    b, k = s.b, s.k
    check(s.create_cty is s.local.create_cty and s.c_app is s.local.c_app, 'accepted wrappers reused exactly')
    state = {'Hsty': {'outer_length': 5003, 'bucket_max': 7, 'allocated_slots': 12},
             'Hsity': {'outer_length': 97, 'bucket_max': 3, 'allocated_slots': 9}}
    d = s.Demand(101, 503, 907)
    empty = b.Contract((),(),(),b.Effect(),b.UNIT)
    t = b.Ty('arrow',(b.Ty('int'), b.Ty('arrow',(b.Ty('bool'),b.Ty('int')))))
    for _ in range(2):
        s.create_cty((),(),(),b.Effect(),t,{},d)
    for _ in range(5):
        s.c_app(empty,(),b.UNIT,d,unit=True)
    # The second failing pair still spends its possible formal/actual map add.
    formals = tuple(b.PV(k.Var(10+i,b.Ty('int'))) for i in range(3))
    actuals = tuple(b.PV(k.Var(20+i,b.Ty('bool') if i == 1 else b.Ty('int'))) for i in range(3))
    try:
        s.c_app(b.Contract(formals,(),(),b.Effect(),b.UNIT),actuals,b.UNIT,d)
    except b.SourceFailure:
        pass
    else:
        raise AssertionError('expected second-pair failure')
    s.c_app(empty,(),b.UNIT,d,constructor_one=True)
    out = d.shared_export(state)
    vector = out['accepted_local_export']['accepted_request_vector']
    check(vector == d.export(), 'shared export preserves exact accepted vector')
    check(vector['owner_requests_upper'] == {'Hsty':20,'Hsity':5,'Ident':5}, 'mixed source fold cumulative requests')
    check({o:v['final_upper'] for o,v in out['owner_counters'].items()} == {'Hsty':523,'Hsity':912,'Ident':106}, 'distinct inherited owners preserved')
    check(vector['memo_reads'] == {'ts_tuple':10,'fs_tuple':5,'its_tuple':5,'fs_tuple_ids.mem':6}, 'Unit and ordinary constructor lookup multiplicity')
    check(len([x for x in vector['map_events'] if x[0] == 'formal_actual_add']) == 2, 'failed second pair map charge retained')
    check(out['conditional_shared_representation_interface_applies'], 'mixed conditional interface holds')
    check(not out['actual_Main_initial_process_attachment_established'] and not out['complete_source_entry_and_candidate_multiplicities'], 'diagram never certifies Main attachment')
    check(not d.shared_export()['conditional_shared_representation_interface_applies'], 'missing table states keep interface open')
    for o in ('Hsty','Hsity'):
        row = out['weak_backing'][o]
        check(row['external_merge_requests_upper'] == vector['owner_requests_upper'][o] and row['inherited'] == state[o], 'backing uses same cut and source requests')
    # Closed-form boundary independent of imported implementation.
    am = 2**54-1
    nm = 2*(am-6)//3
    for q in (0,1,2,3,9,100,nm-1,nm,nm+1,2**62):
        r = s.backing({'outer_length':7,'bucket_max':0,'allocated_slots':0},q)
        aa = max(7,13,3*q+3)
        bb = max(0,3*q//2+3)
        tr = r['accepted_weak_transfer']
        check((tr['individual_outer_array_length_upper'],tr['individual_bucket_length_upper']) == (aa,bb), 'independent backing formula')
        check(r['representation_guards_hold'] == (3*max(aa,bb)+6 <= 2**62-1 and aa <= am and bb+2 <= am-2 and 8*(aa+1)<2**64 and 8*(bb+3)<2**64), 'independent exact backing guard')
    # Isolate strict weak bucket cap using an inherited allocated bucket.
    for bucket, expected in ((am-4,True),(am-3,False)):
        r = s.backing({'outer_length':7,'bucket_max':bucket,'allocated_slots':bucket},0)
        # N makes the conservative dynamic bucket bound larger; test the
        # individual guard against its exported K, without pretending a table trace.
        kk = r['accepted_weak_transfer']['individual_bucket_length_upper']
        check(r['guards']['weak_bucket_payload'] == (kk <= am-4), 'strict weak cap before saturation')
    for initial, expected in ((2**62-3,True),(2**62-2,False)):
        n = s.Demand(0,initial,0)
        s.c_app(empty,(),b.UNIT,n,unit=True)
        check(n.shared_export(state)['conditional_shared_representation_interface_applies'] == expected, 'exact Hsty owner boundary')
    bad = s.Demand()
    s.create_cty((),(),(),b.Effect(),b.Ty('bad',(b.Ty('int'),)*3),{},bad)
    check(not bad.shared_export(state)['conditional_shared_representation_interface_applies'], 'unsupported arity cannot close')
    for invalid in (True,-1,0.5):
        try:
            s.backing({'outer_length':7,'bucket_max':0,'allocated_slots':invalid},0)
        except ValueError:
            check(True, 'malformed backing rejected')
        else:
            raise AssertionError('malformed backing accepted')
    check(out['new_exception_or_save_allowance'] == 0, 'no renewed exception/save allowance')
    return {'mixed_export':out,'native_service_execution':False,'mathematical_diagrams_only':True}


def main():
    start = time.perf_counter()
    phase = sys.argv[1]
    details = {'source-elf':source_elf, 'math':math}[phase]()
    result = {'status':'passed','phase':phase,'reviewed_author':AUTHOR,
              'assertions':sum(COUNTS.values()),'groups':dict(COUNTS),
              'elapsed_seconds':time.perf_counter()-start,'host':platform.platform(),
              'script_sha256':sha(Path(__file__).read_bytes()),'details':details,
              'native_target_compiler_prover_Lean_disassembler_service_runs':0,
              'author_or_predecessor_checker_runs':0}
    (HERE/(phase+'-result.json')).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k != 'details'},indent=2))


if __name__ == '__main__':
    main()
