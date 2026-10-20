#!/usr/bin/env python3
"""Focused retained frame/source/input join, not a predecessor checker replay.

No process capture, target execution, disassembler, solver or opened-term
interpreter runs. Raw metadata extraction starts at accepted typed term roots.
"""
import functools
import gzip
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
ELF = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
inputs = {}


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    path = Path(path)
    raw = path.read_bytes()
    name = str(path.relative_to(REPO)) if path.is_relative_to(REPO) else str(path)
    inputs[name] = identity(raw)
    return raw


def js(path):
    return json.loads(read(path))


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


# Base own bytes are prologue reservation plus the incoming return slot.
# Trap bytes are separately checked pushes; they are not heap closure sizes.
FRAMES = {
    'camlWhy3__Session_itp__save_session_4339': (32, 0),
    'camlWhy3__Session_itp__save_4319': (64, 0),
    'camlWhy3__Session_itp__fold_all_session_1955': (16, 0),
    'camlWhy3__Session_itp__fold_all_any_of_file_1938': (32, 0),
    'camlWhy3__Session_itp__fold_all_any_of_theory_1931': (32, 0),
    'camlWhy3__Session_itp__fold_all_any_of_proofn_1849': (64, 0),
    'camlWhy3__Session_itp__fold_all_any_of_transn_1848': (48, 0),
    'camlWhy3__Session_itp__fun_10400': (32, 0),
    'camlWhy3__Session_itp__compute_and_add_shape_1642': (32, 0),
    'camlWhy3__Session_itp__save_file_4312': (96, 0),
    'camlWhy3__Session_itp__save_theory_4306': (80, 0),
    'camlWhy3__Session_itp__save_goal_4268': (112, 0),
    'camlWhy3__Session_itp__save_trans_4269': (112, 0),
    'camlWhy3__Session_itp__save_proof_attempt_4252': (112, 0),
    'camlWhy3__Termcode__t_bound_shape_task_2924': (80, 0),
    'camlWhy3__Termcode__do_d_2936': (16, 16),
    'camlWhy3__Termcode__t_shape_2345': (64, 0),
    'camlWhy3__Termcode__vl_rename_alpha_2135': (16, 0),
    'camlWhy3__Termcode__vs_rename_alpha_2129': (32, 0),
    'camlWhy3__Termcode__decoded_2037': (32, 0),
    'camlWhy3__Termcode__ident_v5_2122': (32, 16),
    'camlWhy3__Ident__id_unique_inner_6286': (32, 16),
    'camlWhy3__Ident__find_unique_3105': (64, 16),
    'camlWhy3__Ident__advance_3115': (32, 0),
    'camlWhy3__Ident__retreat_3117': (32, 0),
    'camlWhy3__Ident__testname_3112': (16, 0),
    'camlWhy3__Ident__specname_3109': (32, 0),
    'camlWhy3__Task__local_decls_2592': (16, 0),
    'camlWhy3__Task__filter_2602': (48, 16),
    'camlWhy3__Task__skip_2596': (16, 0),
    'camlWhy3__Task__task_fold_2553': (32, 0),
    'camlWhy3__Task__used_theories_2572': (16, 0),
    'camlWhy3__Task__used_symbols_2581': (16, 0),
    'camlWhy3__Extmap__find_409': (32, 0),
    'camlWhy3__Extmap__add_397': (80, 0),
    'camlWhy3__Extmap__iter_460': (32, 0),
    'camlWhy3__Extmap__fold_489': (32, 0),
    'camlWhy3__Term__t_open_bound_5946': (32, 0),
    'camlWhy3__Term__t_open_quant_5970': (48, 0),
    'camlWhy3__Term__t_subst_unsafe_5860': (80, 0),
    'camlWhy3__Term__bv_subst_unsafe_5861': (48, 0),
    'camlWhy3__Term__b_subst_5867': (48, 0),
    'camlWhy3__Term__t_map_unsafe_5744': (64, 0),
    'camlWhy3__Term__tr_map_5591': (16, 0),
    'camlStdlib__List__iter_507': (32, 0),
    'camlStdlib__List__fold_left_521': (32, 0),
    'camlStdlib__List__map_482': (32, 0),
    'camlWhy3__Extmap__union_590': (80, 0),
    'camlWhy3__Extmap__inter_728': (80, 0),
    'camlWhy3__Extmap__diff_742': (80, 0),
    'camlWhy3__Extmap__disjoint_772': (80, 0),
    'camlWhy3__Extmap__map_467': (48, 0),
    'camlWhy3__Extmap__split_557': (64, 0),
    'camlWhy3__Extmap__join_527': (32, 0),
    'camlWhy3__Extmap__add_min_binding_511': (32, 0),
    'camlWhy3__Extmap__add_max_binding_519': (16, 0),
    'camlWhy3__Extmap__remove_min_binding_434': (32, 0),
    'camlWhy3__Extmap__cons_enum_643': (16, 0),
    'camlWhy3__Extmap__aux_896': (80, 0),
    'camlWhy3__Extmap__fold2_inter_890': (48, 0),
    'camlWhy3__Extmap__min_binding_424': (16, 0),
    'camlWhy3__Extmap__bal_367': (64, 0),
    'camlWhy3__Extmap__create_355': (16, 0),
    'caml_apply2': (16, 0),
}

# One finite recursive map operation, excluding callbacks/comparators. Summing
# exact frames (rather than inventing a uniform frame size) deliberately loses
# exclusivity between the alternative operations. Two operands have at most 2N
# nodes; the source recursion removes a node or descends a strict subtree.
MAP_FAMILY = [n for n in FRAMES if n.startswith('camlWhy3__Extmap__')]


def map_projection(n):
    return sum(FRAMES[s][0] for s in MAP_FAMILY) * (2*n+1)


def native():
    raw = read(DISASM)
    assert identity(raw) == dict(bytes=69046582, sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
    bodies = {m.group(1): m.group(0) for m in re.finditer(
        r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)', raw.decode(), re.M | re.S)}
    elf = read(ELF)
    assert identity(elf) == dict(bytes=24561432, sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
    hdr = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
    segments = [struct.unpack_from('<IIQQQQQQ', elf, hdr[5] + i * hdr[9]) for i in range(hdr[10])]
    keep = dict.fromkeys(list(FRAMES) + ['camlGnat_checks__save_session_2537'])
    frames, total = {}, 0
    for symbol in keep:
        body = bodies[symbol]
        keep[symbol] = body
        code = []
        for line in body.splitlines()[1:]:
            match = re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)', line)
            if not match:
                assert not line.strip(), line
                continue
            address = int(match[1], 16)
            bs = bytes.fromhex(match[2])
            segment = next(s for s in segments if s[0] == 1 and s[3] <= address and address + len(bs) <= s[3] + s[5])
            offset = segment[2] + address - segment[3]
            assert elf[offset:offset+len(bs)] == bs, (symbol, address)
            total += len(bs)
            if match[3]:
                code.append(match[3])
        if symbol in FRAMES:
            base, trap = FRAMES[symbol]
            assert code[0] == f'sub    $0x{base-8:x},%rsp', (symbol, code[0])
            assert sum(bool(re.match(r'push\s', line)) for line in code) == trap // 8, symbol
            assert not any(re.match(r'sub\s.*%rsp', line) for line in code[1:]), symbol
            frames[symbol] = dict(base_own_bytes=base, additional_trap_bytes=trap,
                own_high_water_upper=base+trap,
                identity=identity(body.encode()),
                direct_transfers=re.findall(r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>', body))
    # Named backedges after prologue prove these loops do not accumulate frames.
    loops = {
        'camlStdlib__List__iter_507': '9490f4',
        'camlStdlib__List__fold_left_521': '9491c4',
        'camlWhy3__Ident__advance_3115': '56daa4',
        'camlWhy3__Ident__retreat_3117': '56dae4',
        'camlWhy3__Task__skip_2596': '598a94',
        'camlWhy3__Extmap__find_409': '54a3c4',
    }
    for symbol, address in loops.items():
        assert re.search(r'\bjmp\s+' + address + r'\s', keep[symbol]), symbol
        frames[symbol]['loop_backedge_after_prologue'] = address
    assert 'call   598ae0 <camlWhy3__Task__filter_2602>' in keep['camlWhy3__Task__filter_2602']
    assert 'jmp    7fc430 <camlWhy3__Session_itp__save_4319>' in keep['camlWhy3__Session_itp__save_session_4339']
    assert 'jmp    7fc850 <camlWhy3__Session_itp__save_session_4339>' in keep['camlGnat_checks__save_session_2537']
    write('native-bodies.json', keep)
    write('native-frames.json', frames)
    return dict(bodies=len(keep), checked_instruction_bytes=total, new_disassembly_runs=0,
        source_native_correspondence='existing premise; exact retained instruction-byte correspondence checked')


def administrative(atoms):
    provenance = atoms['provenance']
    archive = REPO / provenance['archive']
    read(archive)
    with tarfile.open(archive) as stream:
        member = stream.getmember(provenance['member'])
        assert member.isfile() and not member.issym() and not member.islnk()
        raw = stream.extractfile(member).read()
    assert identity(raw) == provenance['member_identity']
    blocks = {}
    for row in map(json.loads, raw.splitlines()):
        assert row['address'] not in blocks
        blocks[row['address']] = row
    reads = set()

    def fields(pointer, words=None, tag=0):
        reads.add(pointer)
        row = blocks[pointer]
        raw = bytes.fromhex(row['payload_hex'])
        assert row['tag'] == tag and row['header'] & 255 == tag
        assert row['header'] >> 10 == row['words']
        assert len(raw) == row['words'] * 8
        assert words is None or words == row['words']
        return struct.unpack('<' + 'Q' * row['words'], raw)

    active_maps = set()
    @functools.lru_cache(None)
    def mapping(pointer):
        if pointer == 1:
            return (), 0
        assert pointer not in active_maps, ('map cycle', pointer)
        active_maps.add(pointer)
        l, key, value, r, height = fields(pointer, 5)
        assert height & 1
        left, lh = mapping(l)
        right, rh = mapping(r)
        pairs = left + ((key, value),) + right
        assert len(set(k for k, _ in pairs)) == len(pairs)
        active_maps.remove(pointer)
        return pairs, 1 + max(lh, rh)

    @functools.lru_cache(None)
    def sequence(pointer):
        seen, values = set(), []
        while pointer != 1:
            assert pointer not in seen, ('list cycle', pointer)
            seen.add(pointer)
            v, pointer = fields(pointer, 2)
            values.append(v)
        return tuple(values)

    terms = set(atoms['covered_term_pointers'])
    assert not atoms['pattern_pointers'] and not atoms['case_patterns']
    infos, variables, edges = set(), set(), {}
    max_sequence = 0
    for term in sorted(terms):
        node = fields(term, 4)[0]
        children, info = [], None
        if node & 1:
            assert node in (1, 3)
        else:
            tag = blocks[node]['tag']
            sizes = (1, 1, 2, 3, 2, 2, 1, 2, 3, 1)
            assert 0 <= tag < len(sizes) and tag != 5
            xs = fields(node, sizes[tag], tag)
            if tag == 0:
                variables.add(xs[0])
            elif tag == 2:
                children.extend(sequence(xs[1]))
                max_sequence = max(max_sequence, len(children))
            elif tag == 3:
                children.extend(xs)
            elif tag in (4, 6):
                v, info, body = fields(xs[1] if tag == 4 else xs[0], 3)
                variables.add(v)
                children.append(body)
                if tag == 4:
                    children.append(xs[0])
            elif tag == 7:
                vl, info, triggers, body = fields(xs[1], 4)
                vs, ts = sequence(vl), sequence(triggers)
                variables.update(vs)
                max_sequence = max(max_sequence, len(vs), len(ts))
                children.append(body)
                for trigger in ts:
                    row = sequence(trigger)
                    max_sequence = max(max_sequence, len(row))
                    children.extend(row)
            elif tag == 8:
                children.extend(xs[1:])
            elif tag == 9:
                children.append(xs[0])
        if info is not None:
            infos.add(info)
            _, subst = fields(info, 2)
            children.extend(v for _, v in mapping(subst)[0])
        assert set(children) <= terms
        edges[term] = children

    records = {}
    for info in sorted(infos):
        free, subst = fields(info, 2)
        free_pairs, free_depth = mapping(free)
        sub_pairs, sub_depth = mapping(subst)
        variables.update(k for k, _ in free_pairs)
        variables.update(k for k, _ in sub_pairs)
        for var, _ in free_pairs + sub_pairs:
            fields(var, 2)  # variable layout, not a type-graph traversal
        records[str(info)] = dict(bv_vars_count=len(free_pairs), bv_vars_depth=free_depth,
            bv_subst_count=len(sub_pairs), bv_subst_depth=sub_depth,
            substitution_values=[v for _, v in sub_pairs])

    active = set()
    @functools.lru_cache(None)
    def mass(pointer):
        assert pointer not in active, ('administrative term cycle', pointer)
        active.add(pointer)
        rows = [mass(child) for child in edges[pointer]]
        active.remove(pointer)
        return 1 + sum(x[0] for x in rows), 1 + max((x[1] for x in rows), default=0)
    masses = [mass(term) for term in terms]
    substitution_values = sorted({v for r in records.values() for v in r['substitution_values']})
    value_rows = []
    for value in substitution_values:
        node = fields(value, 4)[0]
        tag = None if node & 1 else blocks[node]['tag']
        kind = ('Ttrue' if node == 1 else 'Tfalse') if tag is None else (
            'Tvar','Tconst','Tapp','Tif','Tlet','Tcase','Teps','Tquant','Tbinop','Tnot')[tag]
        value_rows.append(dict(pointer=value, constructor=kind,
            stored_administrative_term_mass=mass(value)[0],
            stored_administrative_term_depth=mass(value)[1]))
    return dict(case=atoms['case'], stored_terms=len(terms), binder_info_records=len(infos),
        initial_variable_identity_union=len(variables),
        max_bv_vars_cardinality=max((r['bv_vars_count'] for r in records.values()), default=0),
        max_bv_subst_cardinality=max((r['bv_subst_count'] for r in records.values()), default=0),
        max_bv_vars_depth=max((r['bv_vars_depth'] for r in records.values()), default=0),
        max_bv_subst_depth=max((r['bv_subst_depth'] for r in records.values()), default=0),
        max_initial_sequence_length=max_sequence,
        max_stored_administrative_term_mass=max(x[0] for x in masses),
        max_stored_administrative_term_depth=max(x[1] for x in masses),
        initial_administrative_term_graph_acyclic=True,
        all_substitution_values_in_accepted_typed_closure=True,
        initial_substitution_values=value_rows,
        binder_records=records, read_pointers=sorted(reads),
        initial_term_constructor_counts_imported=atoms['term_constructor_counts'],
        initial_substitution_values_are_variables=all(v['constructor']=='Tvar' for v in value_rows),
        variable_only_substitution_shape_transfer_established=True,
        complete_native_binder_helper_stack_established=False,
        raw_type_graph_extracted=False,
        attribute_counts_imported={k:atoms[k] for k in ['term_attribute_summary', 'goal_identifier_attribute_summary']})


def sources():
    archive = E / 'retained-why-session-helper-source-20261019/sources.tar.gz'
    read(archive)
    selected = {
        'why3/src/session/session_itp.ml': [(415,459), (1954,1977), (2099,2244)],
        'why3/src/session/termcode.ml': [(358,387), (427,506), (601,628)],
        'why3/src/core/term.ml': [(404,418), (588,675), (739,831)],
        'why3/src/core/task.ml': [(225,276)],
        'why3/src/core/ident.ml': [(232,289)],
        'why3/src/util/extmap.ml': [(214,241), (259,307), (321,336), (438,500), (550,585)],
    }
    out = []
    with tarfile.open(archive) as stream:
        for member, ranges in selected.items():
            raw = stream.extractfile(member).read()
            lines = raw.decode().splitlines()
            for first,last in ranges:
                out.append(dict(member=member, identity=identity(raw), first=first, last=last,
                    text='\n'.join(lines[first-1:last])))
    write('source-witnesses.json', out)


def main():
    native_result = native()
    sources()
    shapes = js(E / 'retained-why-session-shape-transfer-20261020/bounds.json')
    state = {c['case']:c for c in js(E / 'retained-why-save-state-join-20261020/result.json')['cases']}
    # Reuse accepted formatter/path results by exact identity, never replay.
    for name in ['retained-why-save-format-accumulator-20261020', 'retained-why-path-lookup-capacity-20261020']:
        read(E / name / 'result.json')
    cases, admin = [], []
    for c in shapes:
        atom_path = E / 'retained-why-fixed-session-atoms-20261020' / (c['case'].replace('_','-') + '-atoms.json.gz')
        atoms = json.loads(gzip.decompress(read(atom_path)))
        assert atoms['typed_graph_complete'] and not atoms['coverage_failures']
        cert_path = REPO / c['provenance']['occurrence_certificate']
        cert = js(cert_path)
        cert = cert.get('full_certificate', cert)
        assert cert == atoms['saved_occurrence_certificate']
        raw_admin = administrative(atoms)
        assert raw_admin['initial_substitution_values_are_variables']
        d = raw_admin['max_stored_administrative_term_depth']
        l = raw_admin['max_initial_sequence_length']
        f0 = raw_admin['max_bv_vars_cardinality']
        s0 = raw_admin['max_bv_subst_cardinality']
        deferred = s0 + f0*d
        environment = deferred + l
        attribute_union = len(atoms['term_attribute_union'])
        raw_admin['dynamic_transfer'] = dict(constructor_depth_upper=d,
            child_and_binder_list_length_upper=l, bv_vars_cardinality_upper=f0,
            bv_subst_cardinality_upper=deferred,
            opening_environment_cardinality_upper=environment,
            attribute_union_cardinality_upper=attribute_union,
            raw_task_writeback=False,
            formula='bv_subst <= S0 + F0*D; opening environment <= S0 + F0*D + L')
        t = max(b['T'] for b in c['task_bounds'].values())
        chain = max(b['chain_length'] for b in cert['tasks'].values())
        f = state[c['case']]['conditional_growth']['preserved_forest']
        g, tr, th, files = (f[k] for k in ['G','T','Th','F'])
        # Deliberately use whole-forest counts rather than an unattached depth.
        fold = 32*files + 32*th + 64*g + 48*tr + 32*(files+th+g+tr)
        serial = 96*files + 80*th + 112*g + 112*tr + 112 + 32*(files+th+g+tr+1)
        # Scoped projection: shape-owned frames, direct list iterators and wrappers.
        shape = 80 + 32 + 64*d + 32*(2*d+1) + 16 + 32
        binder_term = 80*(d+1) + 64*d + 32*(l+1)*(d+2) + 32 + 48 + 48 + 48 + 16
        binder_maps = map_projection(environment) + map_projection(attribute_union)
        task_filter = 64*(chain+1) + 16 + 32 + 16
        name = 48 + 32 + 48 + 80 + 32 + 16 + 32
        # N is already the all-save publication bound, never multiplied in the key domain again.
        n = state[c['case']]['conditional_operational_transfer']['index_map_bindings_upper']
        # These are only known shape-dictionary map invocations, excluding administrative maps.
        dictionary = 80*(n+1) + 32*(n+1) + 32
        caller = 32 + 64 + 16 + 32 + 32
        per_save = fold + serial + shape + binder_term + binder_maps + task_filter + name + dictionary + caller + 2176 + 48
        cases.append(dict(case=c['case'], logical_pid=c['provenance']['pid'], fresh_pid=state[c['case']]['new_pid'],
            max_task_opened_term_occurrences=t, max_task_chain_length=chain, forest=f,
            binder_dynamic_transfer=raw_admin['dynamic_transfer'],
            dictionary_bindings_all_saves_upper=n,
            scoped_components_per_save=dict(structural_fold=fold, serializer=serial, shape_descent=shape,
                binder_term_recursive_frames=binder_term, binder_map_recursive_frames=binder_maps,
                task_filter=task_filter, identifier_search=name, dictionary_map_frames=dictionary,
                callers=caller, output_acc=2176, path_find_rec=48),
            scoped_projection_per_save_bytes=per_save,
            scoped_projection_all_three_saves_bytes=3*per_save,
            complete_save_added_stack_upper=None,
            complete_dynamic_helper_stack_established=False,
            service_stack_demand=None, suspended_preparation_stack=None,
            pending_dispatch_stack=None))
        admin.append(raw_admin)
    packed = json.dumps(admin, sort_keys=True, separators=(',', ':')).encode() + b'\n'
    (HERE / 'administrative-inputs.json.gz').write_bytes(gzip.compress(packed, mtime=0))
    write('administrative-summary.json', [{k:v for k,v in c.items() if k not in
        ['binder_records','read_pointers','initial_substitution_values']} for c in admin])
    write('result.json', dict(scope='Source/native scoped save-stack composition plus initial binder administrative input; residual explicit',
        global_save_entries_upper=3, global_signal_entries_upper=2,
        map_projection=dict(symbols=MAP_FAMILY, frame_sum=sum(FRAMES[s][0] for s in MAP_FAMILY),
            formula='sum(exact native own-frame sizes) * (2*N + 1)', callbacks_included=False),
        cases=cases, native=native_result, target_executions=0, captures=0, predecessor_checker_replays=0,
        complete_save_stack_established=False, whole_pipeline_capacity_established=False))
    write('inputs.json', inputs)
    print(json.dumps(dict(cases=len(cases), native=native_result,
        scoped_three_save_bytes=[c['scoped_projection_all_three_saves_bytes'] for c in cases],
        administrative_depth=[c['max_stored_administrative_term_depth'] for c in admin],
        complete_save_stack_established=False), indent=2))


if __name__ == '__main__':
    main()
