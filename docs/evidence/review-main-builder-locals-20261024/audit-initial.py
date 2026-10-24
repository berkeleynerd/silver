#!/usr/bin/env python3
"""Independent audit of new local representation obligations only.

No author/predecessor checker or extractor is imported or executed. Native
evidence is read as data; no target or disassembler execution is involved.
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
from unittest.mock import patch

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT/'docs/evidence/retained-main-construction-demand-20261024/builder-locals'
FREEZE = '0d64f5f7d18b77632146174f1777be238cc43f60'
PRIOR = '93fdabb2232e0fc7fe2fd7c39f167c1985991f5a'
COUNTS = Counter()


def check(ok, family):
    assert ok, family
    COUNTS[family] += 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(name):
    return json.loads((PACKET/name).read_text())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def inputs():
    hashes = {}
    for p in sorted(PACKET.iterdir()) + [ROOT/'docs/research/retained-main-construction-demand.md']:
        if not p.is_file():
            continue
        rel = str(p.relative_to(ROOT))
        check(p.read_bytes() == git('show', FREEZE+':'+rel), 'exact author freeze')
        hashes[rel] = sha(p.read_bytes())
    old = 'docs/evidence/retained-main-construction-demand-20261024/contract-builders'
    check(not git('diff', '--name-only', PRIOR, FREEZE, '--', old), 'accepted R1 packet unchanged')
    for row in read('inputs.json')['providers']:
        check(sha((ROOT/row['path']).read_bytes()) == row['sha256'], 'accepted provider identity')
    sources = {}
    for archive in read('source-witnesses.json'):
        check(sha((ROOT/archive['path']).read_bytes()) == archive['sha256'], 'source archive identity')
        with tarfile.open(ROOT/archive['path']) as tar:
            for row in archive['files']:
                raw = tar.extractfile(row['path']).read()
                check(sha(raw) == row['sha256'], 'whole source identity')
                sources[row['path']] = raw.decode()
                lines = raw.decode().splitlines()
                for span in row['spans']:
                    code = '\n'.join(lines[span['first']-1:span['last']])+'\n'
                    check(code == span['source'] and sha(code.encode()) == span['sha256'], 'source span correspondence')
    return hashes, sources


def native():
    witness, bodies = read('native-witnesses.json'), read('native-bodies.json')
    raw = Path(witness['executable']['path']).read_bytes()
    dis = Path(witness['existing_disassembly']['path']).read_bytes()
    check(sha(raw) == witness['executable']['identity']['sha256'], 'retained ELF identity')
    check(sha(dis) == witness['existing_disassembly']['sha256'], 'retained disassembly identity')
    # Re-extract complete labelled bodies independently. This also detects a
    # retained body that omits instructions while matching its remaining bytes.
    text = dis.decode()
    labels = list(re.finditer(r'(?m)^[0-9a-f]+ <([^>]+)>:\n', text))
    corpus = {m[1]: text[m.start():labels[i+1].start()].rstrip('\n')+'\n'
              for i, m in enumerate(labels[:-1])}
    corpus[labels[-1][1]] = text[labels[-1].start():].rstrip('\n')+'\n'
    check(set(bodies) == set(witness['local_bodies']) | set(witness['adapter_bodies']), 'native inventory matches witness')
    phoff = struct.unpack_from('<Q', raw, 32)[0]
    entsize, count = struct.unpack_from('<HH', raw, 54)
    segments = []
    for i in range(count):
        kind, flags, off, address, _, size, _, _ = struct.unpack_from('<IIQQQQQQ', raw, phoff+i*entsize)
        if kind == 1:
            segments.append((address, address+size, off, flags))

    def memory(address, length, executable=False):
        for low, high, off, flags in segments:
            if low <= address and address+length <= high and (not executable or flags & 1):
                return raw[off+address-low:off+address-low+length]
        raise AssertionError('address outside retained segment')

    instruction = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')
    total, heap, headers, length_callers = 0, [], [], {}
    external = set()
    for name, body in bodies.items():
        check(body.rstrip('\n') == corpus[name].rstrip('\n'), 'complete body retained from disassembly')
        chunks = [(int(m[1], 16), bytes.fromhex(m[2])) for line in body.splitlines() if (m := instruction.match(line))]
        check(all(a+len(b) == c for (a,b),(c,_) in zip(chunks, chunks[1:])), 'instruction byte chunks are contiguous')
        joined = b''.join(b for _,b in chunks)
        check(joined == memory(chunks[0][0], len(joined), True), 'whole retained body agrees with ELF')
        total += len(joined)
        reservations = re.findall(r'\bsub\s+\$(0x[0-9a-f]+),%r15', body)
        heap.extend(int(x,16) for x in reservations)
        writes = [line for line in body.splitlines() if re.search(r',%r15\s*$', line)
                  and not re.search(r'\b(?:cmp\s+\(%r14\),|mov\s+0x8\(%r14\),|sub\s+\$0x[0-9a-f]+,)%r15', line)]
        check(not writes and not re.search(r'\bsub\s+[^\n$]*,%rsp', body), 'no variable local heap or stack reservation')
        check(not re.search(r'<caml_alloc(?:_shr|_small|_custom|_string|_array)', body), 'no direct variable allocation primitive')
        for value in re.findall(r'\bmovq?\s+\$(0x[0-9a-f]+),-0x8\(%r\w+\)', body):
            headers.append(int(value,16))
        refs = set(re.findall(r'<([^>+]+)(?:\+[^>]+)?>', body))
        external |= (refs & corpus.keys()) - bodies.keys()
        length_calls = len(re.findall(r'\bcall\s+[0-9a-f]+ <camlStdlib__List__length', body))
        if length_calls and '__length' not in name:
            length_callers[name] = length_calls
    check(total == 38376 and len(bodies) == 332, 'complete new native byte inventory')
    check(max(heap) == 104 and all(x > 0 and x % 8 == 0 for x in heap), 'fixed aligned reservation ceiling')
    check(max(x >> 10 for x in headers) == 9 and max(heap)//8-1 == 12 < 2**54,
          'literal headers and conservative payload ceiling representable')
    check(external == {r['target'] for r in read('native-boundary.json')['direct_code_edges']},
          'every external direct code reference has a disposition')
    addresses = {name:int(re.match(r'([0-9a-f]+)', body)[1],16) for name,body in corpus.items()}
    for name, row in witness['constant_closure_targets'].items():
        header = struct.unpack('<Q', memory(row['address']-8,8))[0]
        check(header == row['header'] and header & 255 == 247 and (header >> 10)*8 == row['size'],
              'static closure tag header and exact extent')
        words = struct.unpack('<'+'Q'*(row['size']//8), memory(row['address'],row['size']))
        check(all(addresses[target] in words and target in bodies for target in row['targets']),
              'static closure callbacks enter retained bodies')
    expected_lengths = {'camlWhy3__Ity__its_check_args_4741':3, 'camlWhy3__Ity__its_match_args_4745':1,
                        'camlWhy3__Ity__its_match_regs_4749':1, 'camlWhy3__Ity__ity_tuple_5589':1,
                        'camlWhy3__Ity__mask_check_5704':2, 'camlWhy3__Term__ls_arg_inst_6204':1,
                        'camlWhy3__Term__t_tuple_6457':1, 'camlWhy3__Ty__ty_app_3244':3,
                        'camlWhy3__Ty__ty_tuple_3372':1}
    check(length_callers == expected_lengths, 'all native length callers accounted separately')
    return {'bodies':len(bodies), 'local_bodies':len(witness['local_bodies']),
            'adapter_bodies':len(witness['adapter_bodies']), 'instruction_bytes':total,
            'static_closures':len(witness['constant_closure_targets']), 'external_direct_references':len(external),
            'maximum_reservation_bytes':max(heap), 'literal_header_sites':len(headers),
            'maximum_literal_header_words':max(x >> 10 for x in headers),
            'conservative_payload_words':max(heap)//8-1, 'length_callers':length_callers}


def diagrams(sources):
    spec = importlib.util.spec_from_file_location('reviewed_builder_locals', PACKET/'local.py')
    l = importlib.util.module_from_spec(spec); sys.modules[spec.name] = l; spec.loader.exec_module(l)
    b, k = l.b, l.k
    INT, BOOL = b.Ty('int'), b.Ty('bool')
    arrow = b.Ty('arrow',(INT,BOOL))
    # Contract arity is deliberately greater than the type-argument bound.
    formals = tuple(b.PV(k.Var(1+i,INT)) for i in range(7))
    actuals = tuple(b.PV(k.Var(101+i,INT)) for i in range(7))
    registry = {v.var:v for v in formals}
    old, new = b.Demand(10000,20000,30000), l.Demand(10000,20000,30000)
    for mod, demand in ((b,old),(l,new)):
        contract = mod.create_cty(formals,(),(),b.Effect(),INT,registry,demand)
        mod.c_app(contract,actuals,INT,demand)
    e = new.local_export()
    check(new.export() == old.export(), 'shape extension preserves accepted request and owner vector')
    check(e['new_local_representation_safety_closed'] and e['maximum_observed_type_argument_arity'] == 0
          and new.input_shape['actual_argument_list_cells'] == 7, 'formal and actual arity not conflated with type arity')
    # Shared images are counted at each stored occurrence; empty trigger
    # groups are real outer-list cells even though no term is inside them.
    image = k.node('app',ty=arrow,symbol='closed_image')
    quant = k.Term('forall', binding=k.Binding((k.Var(201,INT),),k.node('true'),((),(),(k.node('true'),)),
                                               {},{k.Var(202,arrow):image}))
    pattern = b.b.Pattern('or',INT,(b.b.Pattern('wild',INT),b.b.Pattern('wild',INT)))
    case = b.b.Case(k.node('const',ty=INT),((pattern,k.Binding((),quant,(),{},{k.Var(203,arrow):image})),))
    post = k.Term('eps',binding=k.Binding((k.Var(204,b.UNIT),),case,(),{},{}),ty=b.UNIT)
    shapes = l.Demand(10000,20000,30000)
    l.create_cty((),(),(post,),b.Effect(),b.UNIT,{},shapes)
    for key, expected in {'term_occurrences':8,'case_branch_list_cells':1,'pattern_occurrences':3,
                          'saved_bindings':2,'trigger_group_list_cells':3,'trigger_term_list_cells':1,
                          'type_occurrences':19,'type_argument_list_cells':8}.items():
        check(shapes.input_shape[key] == expected, 'independent stored shape count: '+key)
    check(shapes.local_export()['new_local_representation_safety_closed'] and not shapes.kernel.ident_increments,
          'context traversal stays finite without binder opening')
    controls = {}
    for name in ('partial','promotion','reference','tuple_mask','type_variable','arity_three'):
        d = l.Demand(10000,20000,30000)
        try:
            if name == 'partial':
                l.c_app(b.Contract(formals,(),(),b.Effect(),INT),actuals[:1],INT,d)
            elif name == 'promotion':
                l.c_app(b.Contract(formals[:1],(),(),b.Effect(),INT),(b.PV(k.Var(301,INT),ghost=True),),INT,d)
            elif name == 'reference':
                region = b.Region(302,b.Ty('ref')); pv = b.PV(k.Var(303,region.ty),region)
                l.c_app(b.Contract((pv,),(),(),b.Effect(),INT),(pv,),INT,d)
            else:
                ty = b.Ty('a',variable=True) if name == 'type_variable' else b.Ty('three',(INT,INT,INT)) if name == 'arity_three' else INT
                l.create_cty((),(),(),b.Effect(),ty,{},d,mask='tuple' if name == 'tuple_mask' else 'visible')
        except ValueError:
            check(name != 'arity_three', 'residual partition rejected by inherited gate')
        else:
            check(name == 'arity_three', 'arity frontier handled by export guard')
        controls[name] = d.local_export()['new_local_representation_safety_closed']
        check(not controls[name], 'out-of-domain diagram cannot close local representation')
    # Tiny predicate controls, not giant fabricated source terms or ELF claims.
    d = l.Demand(); d.type_arities[k.MAX_INT+1] = 1
    check(not d.local_export()['type_list_length_guard'] and not d.local_export()['new_local_representation_safety_closed'],
          'length predicate participates in closure flag')
    with patch.object(l.json, 'loads', return_value={'maximum_heap_reservation_bytes':8*(2**54+1)}):
        d = l.Demand(); bad_header = d.local_export()
        check(not bad_header['native_local_header_representable'] and not bad_header['new_local_representation_safety_closed'],
              'header predicate participates in closure flag')
    ity, term = sources['src/mlw/ity.ml'], sources['src/core/term.ml']
    check('let ls_arg_inst ls tl =' in term and 'Invalid_argument _ -> raise (BadArity (ls, List.length tl))' in term,
          'logical actual-list length is an excluded malformed-arity branch')
    apply = ity[ity.index('let cty_apply c vl args res ='):ity.index('let cty_tuple args =')]
    check('List.length' not in apply and 'apply gh same (match_v isb u v) (vsb_add vsb u v) ul vl' in apply,
          'contract argument recursion has no native length accumulator')
    check('fn (tr_fold fn (bnd_fold fn acc b) tl) f1' in term
          and 'fn (pat_gen_fold fnT fnL (bnd_fold fn acc b) p) t' in term,
          'native source includes trigger saved-image and pattern descent')
    return {'seven_argument_contract':e, 'shared_images_and_trigger_spines':shapes.local_export(), 'residual_controls':controls}


def main():
    start = time.monotonic()
    hashes, sources = inputs()
    native_result = native()
    examples = diagrams(sources)
    result = {'status':'pass', 'assertions':sum(COUNTS.values()), 'families':dict(COUNTS),
              'elapsed_seconds':time.monotonic()-start, 'host':platform.platform(),
              'author_freeze':FREEZE, 'accepted_R1_author':PRIOR,
              'accepted_R1_review':'ed10f9ba6201024b5053a84b6595bc770b2bcfeb',
              'input_sha256':hashes, 'native':native_result, 'diagrams':examples,
              'audit_sha256':sha(Path(__file__).read_bytes()),
              'author_checker_runs':0, 'predecessor_checker_runs':0, 'native_target_runs':0,
              'disassembler_runs':0, 'compiler_prover_Lean_runs':0,
              'cumulative_local_bytes_required_for_representation_safety':False,
              'shared_services_closed':False, 'whole_source_to_VC_storage_closed':False}
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('status','assertions','elapsed_seconds','host')}))


if __name__ == '__main__':
    main()
