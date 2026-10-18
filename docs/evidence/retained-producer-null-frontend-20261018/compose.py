#!/usr/bin/env python3
"""Offline selected null light-frontend capacity conjunction; no tool execution.

The source projection and complete launch/search descriptor are premises, not
facts proved by matching hashes or by one successful debugger observation.
"""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32, I64 = 2**31-1, 2**63-1
NATIVE = REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017'


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def require(condition, message):
    if not condition:
        raise ValueError(message)


def retained():
    manifest = json.loads((HERE/'identity.json').read_bytes())
    archives = {}
    for name, expected in manifest['archives'].items():
        require(identity((HERE/name).read_bytes()) == expected['archive'], name)
        with tarfile.open(HERE/name) as tar:
            require(all(m.isfile() for m in tar), 'non-file archive member')
            data = {m.name:tar.extractfile(m).read() for m in tar.getmembers()}
        require({n:identity(b) for n,b in data.items()} == expected['members'], name+' members')
        archives[name] = data
    for name, expected in manifest['dependencies'].items():
        require(identity((REPO/name).read_bytes()) == expected, name)
    raw = archives['observations.tar.gz']
    get = lambda name: json.loads(raw[name])
    plan, result = get('plan.json'), get('result.json')
    capture_root = Path(plan['cases'][0]['cwd']).parent
    executable = plan['cases'][0]['argv'][0]
    for path, expected in plan['inputs'].items():
        if Path(path).is_relative_to(capture_root):
            member = str(Path(path).relative_to(capture_root))
        elif Path(path).name in ('system.ads','system.ali'):
            member = 'runtime/'+Path(path).name
        else:
            require(path == executable, 'unrecognized external retained input')
            continue
        require(identity(raw[member]) == expected, 'launch-input identity: '+path)
    require(result['completed'] and result['retained_inputs_unchanged'], 'incomplete witness')
    require(result['Main_VCs'] == 0, 'nonempty Main VC set')
    events = [json.loads(x) for x in raw['managed/events.jsonl'].splitlines()]
    require(events[-1]['event'] == 'finished' and events[-1]['outcome'] == 'success', 'managed run')
    scan = get('static-all-tables.json')
    require(scan['sha256'] == plan['inputs'][executable]['sha256'], 'observed executable')
    prior = REPO/'docs/evidence/retained-main-semantics-20261018/fixed-capture'
    coverage = json.loads((prior/'address-coverage.json').read_bytes())
    require(coverage['sha256'] == scan['sha256'], 'coverage executable mismatch')
    for key in ('immediate_candidates','absolute_candidates','relocations','dynamic_symbols',
                'symbol_aliases','data_pointer_candidates','additional_direct_instructions',
                'original_direct_missing'):
        require(coverage[key] == [], 'unresolved store coverage: '+key)
    require(len(coverage['direct_overlaps']) == 4375, 'coverage inventory')
    require(not any(r['address_take'] for r in coverage['direct_overlaps']), 'escaped table Last')
    require(all(r['bytes'] == r['decoded_bytes'] for r in coverage['executable_sections']),
            'incomplete instruction decoding')
    stores = {int(r['address'],16) for r in scan['references'] if r['write']}
    hooks = get('decrease-hooks.json')
    kept = {r['address'] for r in hooks}
    omitted = {r['address'] for r in json.loads((prior/'excluded-positive-stores.json').read_bytes())}
    require(not kept & omitted and kept | omitted == stores, 'store partition')
    require((len(stores),len(kept),len(omitted)) == (2299,1265,1034), 'store counts')
    vectors, summaries = {}, []
    for case, execution in zip(plan['cases'],result['cases'],strict=True):
        phase = case['name']; capture = get(phase+'/pool-counters.json')
        require(case['argv'][0] == executable and len(case['argv']) == 18,
                'selected frontend argument count')
        require('-gnateI1' in case['argv'] and '-Wno-free-nonheap-object' in case['argv'],
                'selected frontend switches')
        require(identity(raw[phase+'/options.tmp'])['sha256'] ==
                plan['inputs'][case['cwd']+'/options.tmp']['sha256'], 'options input')
        require(execution['name'] == phase and execution['returncode'] == 0 and
                not execution['timed_out'] and b'exited normally' in raw[phase+'/probe.log'], phase+' completion')
        require(capture['phases'][-1]['phase'] == 'before_name_finalize', phase+' endpoint')
        require(capture['cache_calls'] == dict(discrete=34,real=0) and
                len(capture['queries']) == len(capture['returns']) == capture['range_mutations'] == 34,
                phase+' range-query coverage')
        require(capture['coherence_failures'] == [] and
                capture['backend_calls'] == capture['unexpected_collect'] == 0, phase+' unexpected work')
        seen = {}
        for request, response in zip(capture['queries'],capture['returns'],strict=True):
            require(all(response[k] == v for k,v in request.items()), 'query-return mismatch')
            key = tuple(request[k] for k in ('n','original','valid'))
            require(key not in seen or seen[key] == response['returned'], 'incoherent return')
            seen[key] = response['returned']
        smap = capture['source_map']; rows = smap['rows']
        require(smap['record_size'] == 128 and len(rows) == 4, 'source layout/frontier')
        require([r['source_last']-r['source_first'] for r in rows] == [7503,69,327,7503], 'source extents')
        require(all(r['template'] == r['instance'] == 0 and r['inlined_call'] == -1 for r in rows), 'virtual source')
        require(all(rows[3]['source_first'] <= q['sloc'] <= rows[3]['source_last']
                    for q in capture['queries']), 'range query outside fixed System source')
        pools = capture['phases'][-1]['pools']
        require(len(pools) == 121, 'table inventory')
        for symbol, row in pools.items():
            require(row['positive'] == row['position']-row['initial']+row['negative'] >= 0,
                    'growth arithmetic: '+symbol)
        require([(r['address'],r['target']) for r in capture['stores']] ==
                [(r['address'],r['target']) for r in hooks], 'capture hooks')
        vectors[phase] = {n:r['positive'] for n,r in pools.items()}
        summaries.append(dict(phase=phase, logical_table_positions=121, all_miss_queries=34,
            coherent_range_keys=len(seen), debugger_seconds=execution['duration_seconds'],
            final_physical_sources=4, virtual_sources=0))
    require(get('phase2/main~1.spark')['flow'] == get('phase2/main~1.spark')['proof'] == [], 'Main report')
    return dict(manifest=manifest, raw=raw, sources=archives['sources.tar.gz'],
                plan=plan, vectors=vectors, summaries=summaries)


def physical_sources(raw, data, native, table):
    inputs = [('System_target',data['runtime/system.ads']),('Main',raw),
              ('naming',data['phase1/GNAT-TEMP-000002.TMP']),('System_semantic',data['runtime/system.ads'])]
    rows = []
    for role, source in inputs:
        shape = native['physical_source_shape'](source)
        cap = 500
        while cap < shape['physical_line_entries_bound']:
            cap *= 2
        checks = dict(source_length_and_EOF=len(source)+1 <= I32,
            source_buffer_object=len(source)+17 <= I64,
            line_table_bit_product=32*cap <= I32,
            physical_line_index=shape['physical_line_entries_bound'] <= I32,
            expanded_column=shape['max_expanded_final_column'] <= 32766)
        rows.append(dict(role=role, **identity(source), **shape,
            line_table_capacity=cap, line_table_bytes=4*cap, checks=checks))
    extent = sum(r['aligned_source_extent'] for r in rows)
    tables = dict(Source_File=table(5,1,10,200,128,I32),
        Instances=table(1,0,10,200,4,I32), SFN_Patterns=table(6,1,10,100,64,I32),
        SFN_Table=table(1,0,10,200,12,I32))
    checks = dict(each_source=all(all(r['checks'].values()) for r in rows),
        source_cursor_and_next_block=extent-1 <= I32-4096,
        source_tables=all(r['all_selected_checks_pass'] for r in tables.values()))
    return dict(sources=rows, aligned_source_extent=extent, physical_sources=4,
        virtual_sources=0, source_file_lifetime_demand=5, tables=tables,
        checks=checks, all_selected_checks_pass=all(checks.values()))


# These source-checked core table instances use the same generic Table contract
# as the native component. Fixed auxiliary trajectories transfer separately;
# this list is deliberately not advertised as the complete 121-table inventory.
CORE = [
 ('node_offsets','atree__atree_private_part__node_offsets__last_val',0,500000,100,16,1999999999),
 ('orig_nodes','atree__orig_nodes__last_valX',0,500000,100,4,1999999999),
 ('slots','atree__atree_private_part__slots__last_val',1,2000000,100,4,I32),
 ('next_node','nlists__next_node__last_valX',0,500000,100,4,I32),
 ('prev_node','nlists__prev_node__last_valX',0,500000,100,4,I32),
 ('lists','nlists__lists__last_valX',-99999999,4000,200,12,-1),
 ('elists','elists__elists__last_valX',-199999998,200,100,8,-100000000),
 ('elmts','elists__elmts__last_valX',-299999998,1200,100,8,-200000000),
 ('uints','uintp__uints__last_val',-699999999,5000,100,8,-600000000),
 ('udigits','uintp__udigits__last_val',0,10000,100,4,I32),
 ('ureals','urealp__ureals__last_valX',-599999998,200,100,16,-500000000),
 ('strings','stringt__strings__last_valX',-499999998,500,150,8,-400000000),
 ('string_chars','stringt__string_chars__last_valX',0,2500,150,4,I32),
 ('xrefs','lib__xref__xrefs__last_valXn',1,5000,300,40,I32),
 ('compilation_switches','lib__compilation_switches__last_val',1,30,100,16,I32),
 ('all_interp','sem_type__all_interp__last_valX',0,1000,100,16,I32),
 ('scope_stack','sem__scope_stack__last_val',0,10,200,320,I32),
]


def compose(source, descriptor, model, evidence=None):
    ev = evidence or retained()
    native = runpy.run_path(str(NATIVE/'compose-null-capacity.py'))
    require(set(descriptor) == {'scope','complete_path_bound','capture_plan_sha256',
        'paths','phase_options_sha256'}, 'descriptor schema')
    require(descriptor['scope'] == 'selected indexed null light phases', 'descriptor scope')
    require(descriptor['capture_plan_sha256'] == identity(ev['raw']['plan.json'])['sha256'], 'selected plan')
    expected = json.loads((HERE/'fixture.json').read_bytes())
    require(descriptor['paths'] == expected['paths'], 'launch/configuration class differs')
    require(descriptor['phase_options_sha256'] == expected['phase_options_sha256'], 'options differ')
    p = descriptor['complete_path_bound']
    require(type(p) is int and p >= max(map(len,descriptor['paths'])), 'incomplete supplied path bound')
    lexical = native['null_source_counts'](source)
    # Restrict this new interface to the present Silver ASCII/trivia alphabet.
    # Existing scanner code additionally understands FF/VT, which are not used
    # here to silently expand the production language.
    require(all(32 <= b <= 126 or b in (9,10,13) for b in source), 'outside current source alphabet')
    table = model['native_table_backing_row']
    physical = physical_sources(source,ev['raw'],native,table)
    phases = {}
    for name, baseline in ev['vectors'].items():
        values = dict(baseline)
        # Deliberate overcount: retain all original path/name allocations, then
        # charge all varying roles and every source word as fresh. This pays
        # both changed path lengths and Name_Find collisions becoming misses.
        paths, ali_names = 32, (64 if name == 'phase2' else 0)
        entries = values['namet__name_entries__last_val'] + paths + ali_names + lexical['word_tokens']
        # Each interned spelling fits signed Short; include its NUL and the
        # explicit Namet locking reserve. This avoids relying on path-name
        # collision equivalence to subtract any observed character payload.
        chars = 32768*entries + 5000
        values['namet__name_entries__last_val'] = entries
        values['namet__name_chars__last_val'] = chars
        values['osint__file_name_chars__last_valX'] = p+1
        tables = {label:table(values[symbol],low,initial,growth,size,high)
                  for label,symbol,low,initial,growth,size,high in CORE}
        tables.update(Name_Entries=table(entries,-399999997,6000,100,16,-300000000),
            Name_Chars=table(chars,0,50000,100,1,I32),
            File_Name_Chars=table(p+1,1,10000,100,1,I32),
            File_Mapping=table(2,1,1000,1000,8,I32),
            Path_Mapping=table(2,1,1000,1000,8,I32),
            Src_Search_Directories=table(5,0,10,100,16,I32),
            Lib_Search_Directories=table(5,0,10,100,16,I32))
        map_bytes = len(ev['raw'][name+'/GNAT-TEMP-000003.TMP'])
        # Future parent-generated map remains two triples: unit and basename
        # spellings are fixed; both complete source names are charged by P.
        map_envelope = len(b'main%b\nmain.adb\n\nsystem%s\nsystem.ads\n\n')+2*p
        argv = ev['plan']['cases'][0 if name == 'phase1' else 1]['argv']
        # C argv, decoded GCC option records, reconstructed canonical entries,
        # and Ada fat String pointers are separate allocations.
        canonical = 2*len(argv)
        argument = max(p+8,24)
        objects = dict(C_argv=(len(argv)+1)*8, decoded_options=96*len(argv),
            canonical_argv=(canonical+1)*8, Ada_argv=16*canonical+16,
            one_argument=argument+16, map_buffer=map_envelope+17,
            object_path_buffer=p+2+16, option_obstack=max(4096,4*(argument+67)+116))
        checks = dict(tables=all(r['all_selected_checks_pass'] for r in tables.values()),
            individual_name_length=max(p,70) <= 32767,
            name_buffer=max(p+1,70) <= 4*32766,
            mapping_buffer=map_envelope+2 <= I32,
            mapping_writer_single_line=max(p,10)+1 <= 1500,
            selected_command_arithmetic=4*(argument+67)+116 <= I32,
            object_path_length=p+2 <= I32,
            independent_objects=all(n <= I64 for n in objects.values()))
        phases[name] = dict(logical_table_demands=values, extra_path_roles=paths,
            extra_ALI_parser_names=ali_names, extra_source_word_names=lexical['word_tokens'],
            table_backing=tables, independent_object_bytes=objects,
            selected_compiler_argv_entries=len(argv), observed_mapping_bytes=map_bytes,
            mapping_byte_bound=map_envelope, checks=checks,
            all_selected_checks_pass=all(checks.values()))
    checks = dict(physical_sources=physical['all_selected_checks_pass'],
                  **{name:row['all_selected_checks_pass'] for name,row in phases.items()})
    return dict(scope='conditional selected null light-frontend conjunction',
        source=identity(source), source_counts=lexical, supplied_complete_path_bound=p,
        managed_observation_run=ev['manifest']['run'], observations=ev['summaries'],
        physical_sources=physical, phases=phases, component_checks=checks,
        all_selected_frontend_predicates_pass=all(checks.values()),
        fixed_121_table_transfer_basis='source read projection with variable names, file-name characters and source buffers replaced',
        conditional_premises=[
            'Same selected indexed two-phase frontend options, fixed System/naming bytes and complete source/object search roles',
            'Path bound covers raw, normalized, resolved and generated names; no alternate source/ALI inputs',
            'Null token source projection, fixed System range queries and documented relevant-behavior source correspondence',
            'Existing OS/library semantics and sufficient physical stack, memory and disk'],
        separate_remaining_joins=['producer Why structures, ALI/GG/report/configuration and parent processes',
            'bundled data-representation compiler and native assembler/binder/link pipeline',
            'production native/Lean source-counter correspondence'],
        whole_toolchain_capacity_established=False, production_admission_changed=False,
        aggregate_RAM_or_address_space_admission_gate=False, native_tool_executions=0)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,default=REPO/'samples/null.adb')
    p.add_argument('--descriptor',type=Path,default=HERE/'fixture.json')
    p.add_argument('--ada-root',type=Path,required=True)
    p.add_argument('--output',type=Path)
    args = p.parse_args()
    native = runpy.run_path(str(NATIVE/'compose-null-capacity.py'))
    result = compose(args.source.read_bytes(),json.loads(args.descriptor.read_bytes()),native['load_model'](args.ada_root))
    rendered = json.dumps(result,indent=2)+'\n'
    if args.output:
        args.output.write_text(rendered)
    else:
        require(result == json.loads((HERE/'result.json').read_bytes()), 'retained result differs')
    print(json.dumps(dict(source_bytes=result['source']['bytes'],
        component_checks=result['component_checks'], whole_toolchain_capacity_established=False)))


if __name__ == '__main__':
    main()
