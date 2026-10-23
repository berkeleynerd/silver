"""Independent R69 finite audit; imports no author/predecessor programs."""
from pathlib import Path
import hashlib
import json
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CHECKS = 0
ARCHIVES = {}
MEMBERS = {}
C = 'docs/evidence/retained-why-report-construction-20261023/'
P = 'docs/evidence/retained-why-report-path-inputs-20261023/'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'


def check(value, label):
    global CHECKS
    CHECKS += 1
    if not value:
        raise AssertionError(label)


def read(path):
    return json.loads((ROOT / path).read_bytes())


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def member(archive, name):
    key = (archive, name)
    if key not in MEMBERS:
        if archive not in ARCHIVES:
            ARCHIVES[archive] = tarfile.open(ROOT / archive)
        MEMBERS[key] = ARCHIVES[archive].extractfile(name).read()
    return MEMBERS[key]


def source_audit():
    spans = 0
    names = set()
    for row in read(C + 'source-witnesses.json'):
        raw = member(row['archive'], row['member'])
        check(identity(raw) == row['member_identity'], 'construction member')
        lines = raw.decode().splitlines(keepends=True)
        a, b = row['first'], row['last']
        check(1 <= a <= b <= len(lines), 'construction strict span')
        check(''.join(lines[a-1:b]) == row['text'], 'construction source text')
        names.add((row['archive'], row['member']))
        spans += 1
    rendered = []
    for row in read(P + 'source-ranges.json'):
        raw = member(row['archive'], row['member'])
        check(identity(raw) == row['identity'], 'path member')
        lines = raw.decode().splitlines(keepends=True)
        rendered.append(f"## {row['archive']} :: {row['member']}\n")
        for span in row['ranges']:
            a, b = span['start'], span['end']
            check(1 <= a <= b <= len(lines), 'path strict span')
            text = ''.join(lines[a-1:b])
            check(identity(text.encode()) == span['identity'], 'path source text')
            rendered.append(f'### Lines {a}–{b}\n\n```text\n{text}```\n')
            spans += 1
        names.add((row['archive'], row['member']))
    check((ROOT / (P + 'source-witnesses.md')).read_text() ==
          '# Retained pathname source witnesses\n\n' + '\n'.join(rendered),
          'rendered pathname witnesses')
    return {'strict_source_ranges': spans, 'complete_source_members': len(names)}


def construction_audit():
    bounds = read(C + 'bounds.json')
    canon = {r['case']: r for r in read('docs/evidence/retained-why-canonical-json-input-20261023/result.json')['cases']}
    warn = {r['case']: r for r in read('docs/evidence/retained-why-diagnostic-warnings-20261023/bounds.json')['cases']}
    for row in bounds['cases']:
        c = canon[row['case']]
        r, g, a, n, o = (c[k] for k in ['R', 'G', 'A', 'N', 'O'])
        w = warn[row['case']]['W_o'] + o + n + 1
        s, k = 5*r, 26
        cnt = 4 + 6*r + s + 3*g + a
        fields = 4 + 14*r + 4*s + 2*g + 4*a + k
        values = cnt + 9*r + 3*s + 3*a + k + w + 1
        for name, value in {'R':r,'G':g,'A':a,'N':n,'O':o,'W':w,'S':s,'K':k,'C':cnt,'F':fields,'V':values}.items():
            check(row[name] == value, 'construction ' + row['case'] + ' ' + name)
        check(r <= 22 < 64 and 5 < 32, 'no table resize threshold')
        check(max(w, values, fields, g, a) < 2**62, 'finite list/count integers')
        check(row['stats_steps_domain'] == [-1,0,1], 'raw steps')
        check(row['reported_converted_steps_domain'] == [1,2], 'converted steps')
    for row in bounds['steps_conversions']:
        c, add, mult = (row[k] for k in ['c','add','mult'])
        check(c in [-1,0,1] and 0 <= add <= 450000 and 1 <= mult <= 800, 'steps inputs')
        check(-450001 <= c-add <= 1, 'steps subtraction')
        check(row['result'] == max(0,c-add)//mult+1 and 1 <= row['result'] <= 2, 'steps result')
    private_expected = {'answer':(368,32,512,512),'located_warning':(436,32,512,512),'abort_annotation':(6,2,16,16),'annotation_error':(46,0,256,256)}
    for row in bounds['private_default_margin']:
        check(tuple(row[k] for k in ['B','E','initial_buffer','buffer_capacity_upper']) == private_expected[row['owner']], 'exact private owner envelope')
        check(row['B'] + row['E'] + 79 <= 1000000010, 'small private default guard')
        check(row['B'] <= row['buffer_capacity_upper'] < 2**57, 'small private buffer')
    loc = bounds['Loc_margin_specialization']
    p, m = loc['sentinel'], loc['margin']
    check((p,m) == (1000000010,1000000000), 'Loc sentinel and margin')
    check(m-loc['max_indent'] == 999999932, 'Loc setter minimum-space arithmetic')
    check(loc['segment_input_bytes_upper'] == 1024 < m, 'Loc initial no-drain segment')
    check(p-1-m == loc['initial_pending_minus_margin'] == 9, 'Loc first flush drain')
    # Independent finite arithmetic illustrations; the report checks the source
    # invariant and symbolic cancellation for every q, not merely these samples.
    for q in [0,1,1023,1024]:
        check(p-(1+q)-(m-q) == 9, 'Loc later final-break cancellation')
    check(100*2**4 == loc['buffer_capacity_upper'] == 1600 >= 1024, 'Loc Buffer growth')
    for row in bounds['string_layouts']:
        n = row['bytes']
        words = n//8 + 1
        check(row['payload_words'] == words and row['header_and_payload_bytes'] == 8*(words+1), 'string word rounding')
        check(0 <= 8*words-1-n <= 7 and words < 2**54, 'string padding and header')
    check(bounds['fixed_object_payload_words_upper'] == 128, 'fixed object envelope')
    check((bounds['shared_e'],bounds['save_entering_callbacks'],bounds['saves']) == (2,2,3), 'shared budget')
    check(not bounds['aggregate_RAM_or_stack_quota'] and not bounds['production_refinement_established'], 'construction limits')
    # Independent quote-start traversal, including deliberately spurious starts.
    census = read(C + 'format-census.json')
    regions = [(r['member'],r['first'],r['text']) for r in read(C + 'source-witnesses.json') if r['archive'] == WHY]
    regions += [(r['member'],r['start'],r['text']) for r in read('docs/evidence/retained-why-terminal-diagnostic-bytes-20261023/source-witnesses.json')]
    warning_members = sorted({r['member'] for r in read('docs/evidence/retained-why-diagnostic-warnings-20261023/warning-census.json')['references'] if r['member'].endswith(('.ml','.mly','.mll'))})
    check(census['warning_members'] == warning_members, 'census complete warning-member join')
    regions += [(name,1,member(WHY,name).decode()) for name in warning_members]
    count, largest = 0, None
    for name, first, text in regions:
        for start, char in enumerate(text):
            if char != '"':
                continue
            pos = start+1
            while pos < len(text) and text[pos] != '"':
                pos += 2 if text[pos] == '\\' else 1
            if pos >= len(text):
                continue
            token = text[start:pos+1]
            record = {'member':name,'line':first+text.count('\n',0,start),'source_bytes':len(token.encode()),'candidate':token}
            count += 1
            if largest is None or record['source_bytes'] > largest['source_bytes']:
                largest = record
    check(count == census['candidate_count'], 'independent quote-candidate count')
    check(largest == census['largest'], 'independent maximum quote candidate')
    check(census['fixed_format_nodes_upper'] == 4*(largest['source_bytes']+1) < 2**20, 'fixed format nodes')
    return {'construction_cases': len(bounds['cases']), 'format_candidates':count,'format_node_upper':census['fixed_format_nodes_upper']}


def json_strings(tree):
    pending = [tree]
    while pending:
        node = pending.pop()
        if isinstance(node,str):
            yield node
        elif isinstance(node,list):
            pending.extend(node)
        elif isinstance(node,dict):
            pending.extend(node.keys())
            pending.extend(node.values())


def path_audit():
    projection = read(P + 'projection.json')
    roles = read('docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json')
    combined = read('docs/evidence/retained-combined-parallel-startup-20261020/projection.json')['domains']
    endpoints = {r['domain']:r for r in read('docs/evidence/retained-shared-server-prefix-20261020/endpoints.json')}
    expected = {'put_line':(174,43,775),'put':(171,82,802),'first_or_default':(189,49,841),'is_message':(182,89,853),'input_is_valid':(186,49,829)}
    libraries = read(P + 'library-projection.json')
    library_archive = 'docs/evidence/retained-producer-import-context-20261018/sources.tar.gz'
    lookup = {}
    for row in libraries:
        raw = member(library_archive,row['member'])
        check(identity(raw) == row['identity'], 'library exact complete member')
        counts = {token:raw.count(token.encode()) for token in ['[#','vc:written:','call_result:']}
        check(counts == row['raw_origin_token_counts'] and not any(counts.values()), 'library no extra location origins')
        suffix = row['member'].removeprefix('installed/')
        check(suffix not in lookup, 'unique full library suffix')
        lookup[suffix] = row['identity']
    check(len(lookup) == 21, '21 initial complete libraries')
    for case,row in projection['domains'].items():
        cap = roles[case]['captures'][1]
        archive = row['capture_archive']
        check(archive == cap['archive'] == endpoints[case]['capture_archive'], 'current capture join')
        for name, digest in cap['members_sha256'].items():
            check(identity(member(archive,name))['sha256'] == digest, 'capture member identity')
        raw = member(archive,row['input_member'])
        check(identity(raw) == row['input_identity'], 'actual JSON identity')
        tree = json.loads(raw)
        strings = list(json_strings(tree))
        origin_tokens = {token:sum(token in text for text in strings) for token in ['vc:written:','call_result:','[#']}
        check(origin_tokens == row['decoded_raw_location_token_counts'] and not any(origin_tokens.values()), 'no raw native virtual location origin')
        pending = [tree]
        file_max, marker_max = 0, 0
        while pending:
            value = pending.pop()
            if isinstance(value,dict):
                pending.extend(value.values())
            elif isinstance(value,list):
                if len(value) == 2 and isinstance(value[0],str) and type(value[1]) is int:
                    file_max = max(file_max,len(value[0].encode()))
                if value and value[0] == 'W_LOC_LABEL':
                    check(isinstance(value[-1],str), 'actual marker field')
                    marker_max = max(marker_max,len(value[-1].encode()))
                pending.extend(value)
        prior = read('docs/evidence/retained-why-diagnostic-warnings-20261023/native-projection.json')[case]
        check(prior['identity'] == identity(raw), 'current and accepted native JSON identical')
        check(file_max == row['native_source_filename_upper'] == prior['max_source_filename_bytes'], 'native source field maximum')
        check(marker_max == row['native_marker_upper'] == prior['max_marker_bytes'], 'native marker field maximum')
        check(file_max+marker_max+4 == row['native_crossed_filename_marker_upper'] <= 27, 'crossed raw converter pair')
        u = max(len(s.encode()) for s in strings)
        check(all(s.isascii() for s in strings), 'actual JSON decoded ASCII')
        check(len(strings) == row['decoded_string_count_including_keys'], 'decoded string population')
        proc = json.loads(member(archive,row['process_member']))
        env = proc['environment']
        tau = len(env['TMPDIR'].encode())
        length = 2*u+4
        f = tau+max(5,2*length)+28
        check((u,tau,f) == expected[case], 'actual U tau F')
        check((row['decoded_string_max_bytes_U'],row['location_filename_upper_L'],row['TMPDIR_bytes_tau'],row['request_path_upper_F']) == (u,length,tau,f), 'path formula exports')
        check(set(env) == {'PATH','LC_ALL','TMPDIR','OCAMLRUNPARAM'} and env['LC_ALL'] == 'C', 'complete controlled environment')
        check(env == {k:v.replace('$PRIVATE',cap['private_root']) for k,v in cap['normalized_environment'].items()}, 'environment role transport')
        check(proc['argv'] == cap['argv'], 'captured argv')
        argv = combined[case]['candidate_argv']
        check(argv == endpoints[case]['prospective_argv'] and argv[-1] == proc['argv'][-1], 'prospective argv/input preservation')
        opens = cap['ordered_opens']
        spellings = [r[k].replace('$PRIVATE',cap['private_root']) for r in opens for k in ['path','resolved_path']]
        check(len(opens) == 81 and max(map(len,spellings)) == row['initial_path_maximum'] == 180, '81 opens actual spellings')
        matches = []
        for op in opens:
            for suffix,ident in lookup.items():
                if op['path'].endswith('/'+suffix):
                    check(op['identity'] == ident, 'library actual open identity')
                    matches.append(op['path'])
        check(len(set(matches)) == len(matches) == 21 and matches == row['matched_library_paths'], 'complete library association')
        check(max(map(len,matches)) == 166, 'library path maximum')
        names = row['configured_names']
        check(names['input'] == argv[-1] and names['session_directory'] == argv[-1].rsplit('.',1)[0], 'configured input/session names')
        stem = names['session_directory']
        check(names['log'] == stem+'.why3log' and names['profiling_value'] == stem+'_gnatwhy3_gmon.out', 'configured generated names')
        check(names['profiling_error_argument'] == 'GMON_OUT_PREFIX', 'putenv error operand')
        check(names['endpoint'] == endpoints[case]['socket'], 'frontend socket provider')
        lengths = {k:len(v.encode()) for k,v in names.items()}
        lengths['save_backup_upper'] = len(stem)+20
        check(lengths == row['configured_name_bytes'] and max(lengths.values()) <= f, 'configured path bytes dominated')
        check(row['P_diag'] == {'maximum':[f,{'R':1,'constant':24}]} and row['M'] == {'R':1,'constant':72}, 'symbolic P/M exports')
    refinement = read(P + 'warning-refinement.json')
    check(projection['all_FileTags_filename_upper'] == projection['alias_robust_warning_filename_upper'] == refinement['filename_upper'] == 180, 'all-origin filename refinement')
    check(projection['alias_robust_warning_entry_upper'] == refinement['entry_upper'] == 180+256 == 436, 'alias-robust entry refinement')
    old_warnings = {r['case']:r for r in read('docs/evidence/retained-why-diagnostic-warnings-20261023/bounds.json')['cases']}
    for row in refinement['cases']:
        old = old_warnings[row['case']]
        w = old['W_o']
        check(row['W_o'] == w and row['historical_L_o'] == old['L_o'] == 422*w, 'warning opportunity/history join')
        check(row['L_o'] == 436*w and row['L_o_increase'] == 14*w, 'new warning length')
        check(row['warning_B'] == 3*w+6*436*w and row['warning_E'] == 3*w+2*436*w, 'refined warning coefficients')
    check(refinement['opportunity_counts_unchanged'] and not refinement['counter_or_table_persistence_theorem_added'], 'refinement exact proof scope')
    check(projection['actual_R'] is None and projection['P_stat_actual'] is None, 'unattached actual config remains null')
    check(projection['actual_standard_guards'] is None and projection['actual_channel_guards'] is None, 'no claimed actual guard')
    check(not projection['all_path_storage_capacity_established'] and not projection['whole_process_capacity_established'], 'residual path storage')
    check((projection['global_e_upper'],projection['save_entering_callbacks_upper'],projection['saves_upper']) == (2,2,3), 'path shared budgets')
    check(len(str(2**62-1)) == 19 and 24+19+29 == 72, 'positive id complete frame coefficients')
    return {'path_cases':len(projection['domains']),'complete_libraries':len(libraries)}


def join_audit():
    packet = 'docs/evidence/retained-reporting-path-join-20261023/'
    result = read(packet + 'result.json')
    previous = {r['case']:r for r in read('docs/evidence/retained-reporting-composition-20261023/result.json')['cases']}
    paths = read(P + 'projection.json')['domains']
    warnings = {r['case']:r for r in read(P + 'warning-refinement.json')['cases']}
    threshold, max_int = 1000000010, 2**62-1

    def original_core(b,e):
        length = b+e
        operands = {'sentinel':length+79,
                    'scan':(3*e+1)*(threshold+length+1)+length+79,
                    'counts':12*e+10}
        return {'operands':operands,'guards':{
            key:value <= (threshold if key == 'sentinel' else max_int)
            for key,value in operands.items()}}

    def independent_eval(f,b0,e0,r):
        pp, mm = max(f,r+24), r+72
        scale = max(467,pp+51,mm+23,256)
        # Expand the scalar recurrence independently rather than importing the
        # root's evaluate function or taking its displayed X as an input.
        k = 467+12*scale+256
        y = 21*(8*k+65536)
        each = y+1024
        total = each+each
        check(total == 4032*scale+2997488, 'terminal recurrence simplification')
        b,e = b0+6*total,e0+2*total
        standard = original_core(b,e)
        private = original_core(each,2256)
        buffer_limit = 2*max(512,each)
        private['guards']['buffer_double_and_string'] = buffer_limit <= 2**57-9
        private['guards']['rounded_string_payload'] = (buffer_limit+8)//8 <= 2**54-1
        offer = b+70*(e+2)+2*y+371
        channel = offer <= 2**63-1
        return {'R':r,'P_diag':pp,'M':mm,'S':scale,'K':k,'Y':y,
                'x_abort':each,'X':total,'B':b,'E':e,
                'standard':standard,'terminal_private':private,
                'selected_stdout_stderr_offer':offer,
                'zero_initial_offset_guard':channel,
                'sentinel_margin':threshold-standard['operands']['sentinel'],
                'all_guards':all(standard['guards'].values()) and all(private['guards'].values()) and channel,
                'actual_configuration_instantiated':False}

    endpoints = {}
    for row in result['cases']:
        case = row['case']
        prior, path, warning = previous[case], paths[case], warnings[case]
        fixed = path['request_path_upper_F']
        delta = 14*warning['W_o']
        b1 = prior['B']['constant']+6*delta
        e1 = prior['E']['constant']+2*delta
        check(prior['B']['summed_abort_X'] == 6 and prior['E']['summed_abort_X'] == 2, 'accepted terminal multiplicities')
        for key,value in {'F':fixed,'W_o':warning['W_o'],'L_o':436*warning['W_o'],'L_o_increase':delta,'b1':b1,'e1':e1}.items():
            check(row[key] == value, case+' corrected join '+key)
        # L+79 = b1+e1+8*2997488+79+32256*S.
        constant = b1+e1+8*2997488+79
        max_scale,remainder = divmod(threshold-constant,32256)
        check(0 <= remainder < 32256, 'exact integer threshold remainder')
        check(max_scale >= max(467,fixed+51), 'nonempty configuration interval')
        limit = max_scale-95
        check((row['S_limit'],row['R_limit']) == (max_scale,limit), 'derived integer R endpoint')
        for key,r in [('lower_endpoint_arithmetic_only',0),('illustrative_R64_only',64),('upper_endpoint_arithmetic_only',limit)]:
            expected = independent_eval(fixed,b1,e1,r)
            check(row[key] == expected, case+' exact '+key)
            check(expected['all_guards'], case+' endpoint all core/private/channel guards')
        next_value = independent_eval(fixed,b1,e1,limit+1)
        check(row['next_R_sentinel_margin'] == next_value['sentinel_margin'] < 0, 'next byte fails sufficient sentinel')
        check(row['actual_R'] is None and row['actual_runtime_guard_claim'] is None, 'no actual deployment substitution')
        check(row['noncore_representation_provider_attached'], 'construction guard join')
        endpoints[case] = limit
        # The source proof establishes positive-affine/max/product monotonicity;
        # this independent endpoint check validates the displayed common region.
        check(independent_eval(fixed,b1,e1,2264)['all_guards'], 'common-region endpoint')
    check(endpoints == {'put_line':2264,'put':5273,'first_or_default':8731,'is_message':24388,'input_is_valid':22329}, 'five derived configuration endpoints')
    check(result['common_sufficient_R_envelope'] == min(endpoints.values()) == 2264, 'common interval intersection')
    check(result['minimum_illustrative_R64_sentinel_margin'] == 49457733, 'illustrative margin')
    check(result['universal_interval_requires_source_and_monotonicity_argument'] and result['derived_envelope_is_not_an_adopted_admission_cap'], 'conditional universal interval scope')
    check(result['actual_R'] is None and result['actual_runtime_guard_claim'] is None, 'actual join remains null')
    for key in ['raw_stat_path_storage_closed','whole_process_capacity','whole_capacity_rule_complete','production_implemented','budget_renewed','aggregate_RAM_or_stack_gate']:
        check(not result[key], 'join remaining boundary '+key)
    check((result['global_escape_budget'],result['save_entering_callbacks'],result['saves_upper']) == (2,2,3), 'join unchanged budgets')
    return {'join_cases':len(endpoints),'R_endpoints':endpoints,'common_sufficient_R_upper':2264,'actual_R':None,'actual_runtime_guards':None}


def main():
    started = time.monotonic()
    targets = read(str(HERE.relative_to(ROOT) / 'targets.json'))
    files, providers = {}, {}
    for component in targets['components'].values():
        for path, expected in component['files'].items():
            check(identity((ROOT/path).read_bytes()) == expected, 'frozen author file '+path)
            files[path] = expected
        for path, expected in component['providers'].items():
            check(path not in providers or providers[path] == expected, 'provider agreement '+path)
            providers[path] = expected
    for path, expected in targets['accepted_R68']['files'].items():
        check(path not in providers or providers[path] == expected, 'accepted evidence provider agreement')
        providers[path] = expected
    for path, expected in providers.items():
        check(identity((ROOT/path).read_bytes()) == expected, 'provider identity '+path)
    join_inputs = read('docs/evidence/retained-reporting-path-join-20261023/inputs.json')
    check(join_inputs['author_freezes'] == {k:targets['components'][k]['commit'] for k in ['paths','construction']}, 'join exact author freezes')
    construction_provider = read(C+'path-provider.json')
    check(construction_provider['commit'] == targets['components']['paths']['commit'], 'construction exact path freeze')
    check(not read(C+'bounds.json')['located_warning_source']['FileTags_counter_and_storage_owners_closed'], 'FileTags counter/storage retained')
    result = {'status':'pass','author_freezes':{k:v['commit'] for k,v in targets['components'].items()},'exact_inputs':files,'providers':providers,'audit_code_identity':identity(Path(__file__).read_bytes())}
    result.update(source_audit())
    result.update(construction_audit())
    result.update(path_audit())
    result.update(join_audit())
    result.update({'checks':CHECKS,'author_files':len(files),'provider_files':len(providers),'elapsed_seconds':time.monotonic()-started,'author_or_predecessor_checker_runs':0,'native_runs':0,'compiler_runs':0,'solver_runs':0,'proof_runs':0,'captures':0,'disassembler_runs':0,'source_fetches':0,'installed_ELF_rescans':0})
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ['exact_inputs','providers']},sort_keys=True))


if __name__ == '__main__':
    try:
        main()
    finally:
        for archive in ARCHIVES.values():
            archive.close()
