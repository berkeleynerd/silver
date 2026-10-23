"""Independent exact-input/source/native/arithmetic audit; no provider code runs."""
import hashlib
import io
import json
from pathlib import Path
import re
import struct
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = ROOT / 'docs/evidence'
PRIVATE = EV / 'retained-why-printer-private-owners-20261023'
FORMAT = EV / 'retained-why-format-accumulator-20261023'
checks = 0
members = {}
archives = {}
providers = {}


def require(condition, detail):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(detail)


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read_json(path):
    return json.loads(path.read_bytes())


def exact(path, expected):
    if re.match(r'^[0-9a-f]{40}:', path):
        raw = subprocess.check_output(['git', 'show', path], cwd=ROOT)
    else:
        raw = (ROOT / path).read_bytes()
    require(identity(raw) == expected, ['identity', path])
    return raw


def source_member(archive, name):
    key = archive + ':' + name
    if key not in members:
        if archive not in archives:
            raw = (ROOT / archive).read_bytes()
            archives[archive] = tarfile.open(fileobj=io.BytesIO(raw), mode='r:gz')
        members[key] = archives[archive].extractfile(name).read()
    return members[key]


def witnesses(path):
    count = 0
    for row in read_json(path):
        archive, name = row['archive'], row['member']
        if 'archive_identity' in row:
            exact(archive, row['archive_identity'])
        raw = source_member(archive, name)
        require(identity(raw) == row.get('member_identity', row.get('identity')),
                ['member', archive, name])
        lines = raw.decode().splitlines(keepends=True)
        sections = row.get('sections', [row])
        for part in sections:
            first, last = part['first'], part['last']
            require(1 <= first <= last <= len(lines), ['strict range', name, first, last, len(lines)])
            text = ''.join(lines[first-1:last])
            require(text == part.get('text', part.get('excerpt')), ['source excerpt', name, first, last])
            if 'excerpt_identity' in part:
                require(identity(text.encode()) == part['excerpt_identity'], ['excerpt hash', name, first])
            count += 1
    return count


def provider_manifest(path):
    data = read_json(path)
    if 'files' in data:
        data = dict(data['files'], **data.get('archives', {}))
    elif 'providers' in data:
        data = dict(data['providers'], **data.get('archives', {}))
    for name, value in data.items():
        if isinstance(value, dict) and set(value) == {'bytes', 'sha256'}:
            exact(name, value)
            require(name not in providers or providers[name] == value, ['provider collision', name])
            providers[name] = value


def native_audit():
    native = read_json(FORMAT / 'native-witnesses.json')
    binary = exact(native['executable']['path'], native['executable']['identity'])
    dis = native['existing_disassembly']
    listing = exact(dis['path'], {k: dis[k] for k in ('bytes', 'sha256')})
    require(binary[:6] == b'\x7fELF\x02\x01', 'ELF64 little endian')
    offset = struct.unpack_from('<Q', binary, 32)[0]
    stride, count = struct.unpack_from('<HH', binary, 54)
    segments = []
    for i in range(count):
        kind, flags, pos, va, _, size, _, _ = struct.unpack_from('<IIQQQQQQ', binary, offset+i*stride)
        if kind == 1:
            segments.append((va, va+size, pos))
    instruction_count = 0
    def match(address, hex_text):
        nonlocal instruction_count
        raw = bytes.fromhex(hex_text)
        hits = [pos+address-va for va, end, pos in segments if va <= address and address+len(raw) <= end]
        require(len(hits) == 1, ['native segment', address])
        require(binary[hits[0]:hits[0]+len(raw)] == raw, ['native bytes', address])
        instruction_count += 1
    for name, body in native['bodies'].items():
        raw = body['text'].encode()
        require(identity(raw) == body['identity'], ['body identity', name])
        require(raw in listing, ['retained disassembly body', name])
        for insn in body['instructions']:
            match(insn['address'], insn['hex'])
    for row in native['closure_header_witnesses']:
        match(row['address'], row['hex'])
        require(row['header'] & 255 == 247, ['closure tag', row['address']])
        require(row['header'] >> 10 == row['payload_words'], ['closure words', row['address']])
        require(row['payload_words'] <= 128, ['closure ceiling', row['symbol']])
    require(max(x['payload_words'] for x in native['closure_header_witnesses']) ==
            native['maximum_corroborating_closure_payload_words'], 'header maximum')
    require(not native['new_disassembler_or_native_execution'], 'no new native execution')
    return {'bodies': len(native['bodies']), 'closure_headers': len(native['closure_header_witnesses']),
            'instruction_byte_matches': instruction_count, 'executable': native['executable']}


def private_census():
    archive = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
    text = source_member(archive, 'why3/src/printer/smtv2.ml').decode()
    body = text.split('type info = {', 1)[1].split('}', 1)[0]
    fields = re.findall(r'^\s*(?:mutable\s+)?(\w+)\s*:', body, re.M)
    census = read_json(PRIVATE / 'census.json')
    require(set(fields) == set(census['complete_info_fields']), 'complete info fields')
    require(len(fields) == census['field_count'] == 25, '25 info fields')
    calls = sorted(set(re.findall(r'\b(?:Mid|Mls|Mstr|Mts|Mty|Mvs|S|Sattr|Sid|Sls|Stv)\.[A-Za-z_][A-Za-z_0-9]*', text)))
    require(calls == census['SMTv2_container_calls_lexical_inventory'], 'complete container token inventory')
    prelude = source_member(archive, 'why3/src/core/printer.ml').decode()
    require('let ht = Hid.create 5 in' in prelude and 'Hid.add ht id ()' in prelude, 'extra prelude table')
    return {'fields': len(fields), 'lexical_calls': len(calls)}


def max_balanced_height(nodes):
    # Minimum nodes for AVL tolerance two, independently using its recurrence.
    minima = [0, 1, 2]
    while minima[-1] <= nodes:
        minima.append(1 + minima[-1] + minima[-3])
    return next(i for i, n in enumerate(minima) if n > nodes)-1


def literal_tokens(source):
    """Lex quoted strings outside nested comments and character literals."""
    found = []
    pos, line = 0, 1
    while pos < len(source):
        start = pos
        if source.startswith('(*)', pos):
            pos += 3
        elif source.startswith('(*', pos):
            depth = 1
            pos += 2
            while depth:
                if pos >= len(source):
                    raise AssertionError('unclosed source comment')
                if source.startswith('(*)', pos):
                    pos += 3
                elif source.startswith('(*', pos):
                    depth += 1
                    pos += 2
                elif source.startswith('*)', pos):
                    depth -= 1
                    pos += 2
                else:
                    pos += 1
        elif source[pos] == "'" and (char := re.match(r"'(?:\\(?:\d{3}|x[\da-fA-F]{2}|.)|[^'\\\n])'", source[pos:])):
            pos += len(char[0])
        elif source[pos] == '"':
            pos += 1
            while pos < len(source) and source[pos] != '"':
                pos += 2 if source[pos] == '\\' else 1
            require(pos < len(source), 'closed source string')
            pos += 1
            token = source[start:pos]
            found.append({'line':line, 'source':token, 'bytes':len(token.encode())})
        else:
            pos += 1
        line += source[start:pos].count('\n')
    return found


def format_census():
    census = read_json(FORMAT / 'census.json')
    ranges = {}
    for row in read_json(FORMAT / 'source-witnesses.json'):
        if row['member'].startswith('why3/'):
            key = row['archive'], row['member']
            ranges.setdefault(key, []).append((row['first'], row['last']))
    actual = []
    for (archive, member), spans in ranges.items():
        for token in literal_tokens(source_member(archive, member).decode()):
            if any(a <= token['line'] <= b for a, b in spans):
                actual.append(dict(member=member, **token))
    require(actual == census['source_literals'], 'complete quoted-literal census of scoped source regions')
    maximum = max(t['bytes'] for t in actual)
    require(maximum == census['literal_source_byte_maximum'] == 90, 'literal maximum')
    require(census['conservative_format_tree_and_accumulator_nodes'] == 4*(maximum+1) == 364, 'format tree bound')
    require(census['annotation_error_bytes_upper'] == len('invalid box description ') + 4*5+2 == 46,
            'annotation error literal and escape arithmetic')
    require(census['fixed_nonstring_object_payload_words_upper'] == 128, 'local fixed object ceiling')
    return {'literals':len(actual), 'maximum_source_token_bytes':maximum,
            'format_and_accumulator_nodes':364, 'annotation_error_bytes':46}


def private_arithmetic():
    result = read_json(PRIVATE / 'result.json')
    accepted = {}
    for packet in ['printer-entry-20261020', 'printer-demand-20261023', 'printer-name-tables-20261023',
                   'raw-name-length-20261023', 'hsattr-demand-20261023']:
        accepted[packet] = {r['case']: r for r in read_json(EV / ('retained-why-'+packet) / 'result.json')['cases']}
    summaries = []
    for case in result['cases']:
        name = case['case']
        d = accepted['printer-demand-20261023'][name]['dimensions']
        S, P, H, A, T = [d[x] for x in ('S', 'P', 'H', 'A', 'T')]
        E = accepted['printer-demand-20261023'][name]['episodes_upper']
        entry = accepted['printer-entry-20261020'][name]['dimensions']
        K, V = entry['K'], entry['V']
        C = H*((2*S+P)*(T+1)+2*(A+1)*(T+2)+8)
        J, Z, X, Y = 2*H*S, 2*H*S+H, 2*C+H, 3*C
        ko = K+2*P*P
        ro = S*(1+ko*V)
        u = S+(P+1)*ro
        ua = accepted['hsattr-demand-20261023'][name]['lifetime_requests_and_increments_upper']
        w = accepted['raw-name-length-20261023'][name]['candidate_or_printed_unique_name_bytes_upper']
        bs = (T+1)*(ro+2*P+2*S+A+2)
        helper = 16*H*(3*S+2*P+4*A+16)*(S+1)*u
        expected = dict(d, E=E, K=K, V=V, K_open=ko, R_open=ro, U=u, C=C, Uattr=ua, W=w)
        require(case['dimensions'] == expected, ['dimensions', name])
        require(u == entry['validator_U'], ['accepted opened input', name])
        pairs = {
          'info_syn (including sm0)': (4*H,4*H), 'info_rliteral': (H,H),
          'meta_model_projection':(H,H), 'meta_record_def':(H,H), 'info_model':(Z,Z),
          'type_coercions':(H,H), 'type_coercions inner Sls':(H,H), 'type_fields':(H,H),
          'type_fields inner list':(H,H), 'type_sorts':(X,X), 'ty_tysymbol':(Y,Y),
          'final filtered type_sorts':(X,X), 'constructors':(2*H,2*H),
          'constr_proj_id':(2*H,2*H), 'record_fields':(2*H,2*H),
          'constructor field_names/reverse/maps':(2*H*A,A), 'projection attribute filter':(2*H*A*ua,ua),
          'info_labels':(J,J), 'info_labels inner Sattr and temporary union':(J*ua,ua),
          'read-only attribute tests':(5*J+2*H,ua),
          'incr_list_axioms':(H,H), 'incr_list_ldecls':(H,H), 'queried_terms/model_map':(0,0),
          'vc_info/scalar info fields':(2*J+4*H,3), 'prelude th_used':(H,H),
          'prelude dedup ht':(H,H), 'syntax args arrays':(C,max(A,T)),
          'syntax precedence arrays':(C,0), 'syntax scanners/substrings':(16*C,347),
          'unused lazy type-argument maps/arrays':(0,0), 'Stv type-free-variable sets':(0,0),
          'V26Par used-symbol Sid':(H*bs,bs),
          'opening/substitution Mvs maps and enumeration spines':(helper,2*ko),
          'opening/copy Sattr maps':(helper,ua), 'general nonboolean branch Mvs/combine':(0,0),
          'opening argument/trigger/binder/pattern lists':(helper,max(S,P,A,T)),
          'Number.print_in_base scalar state':(65*J,0)}
        rows = {r['owner']:r for r in case['owners']}
        require(set(rows) == set(pairs), ['37 owner families', name])
        for owner, (attempts, size) in pairs.items():
            row = rows[owner]
            require(row['update_or_entry_calls_per_request_upper'] == attempts and
                    row['cardinality_or_length_upper'] == size and row['process_calls_upper'] == E*attempts,
                    ['owner arithmetic', name, owner])
            if 'height_and_temporary_height_operand_upper' in row:
                bound = row['height_and_temporary_height_operand_upper']
                require(bound == 3*(2*size+2).bit_length()+4, ['height formula', name, owner])
                require(bound >= max_balanced_height(2*size+1)+3, ['exact height recurrence', name, owner])
                require(row['single_point_operation_comparison_calls_upper'] == bound and
                        row['single_point_operation_node_steps_upper'] == 8*bound and
                        row['single_binary_tree_operation_node_visits_upper'] == 16*(size+1)**2,
                        ['tree work arithmetic', name, owner])
        cap = 16
        while cap < H:
            cap *= 2
        ht = rows['prelude dedup ht']
        require(ht['capacity_upper'] == cap and ht['largest_threshold_or_growth_operand'] == 2*cap and
                ht['largest_array_block_bytes'] == 8*(cap+1) and ht['scalar_size_interval'] == [0,H] and
                ht['partial_resize_reachable_cells_upper'] == 2*H, ['prelude native arithmetic', name])
        require(max(H,2*cap,8*(cap+1),max(S,V)**2,ko,A+1) <= 2**62-1 and cap <= 2**54-1,
                ['native operands', name])
        require(all(case['native_operand_guards'].values()) and case['all_guards_pass'], ['guards', name])
        summaries.append({'case':name, 'owner_families':len(rows), 'J':J, 'Y':Y,
                          'height_operand':case['largest_tree_height_operand_upper'], 'prelude_capacity':cap})
    require(result['one_global_escape_budget'] == 2 and result['save_entering_callbacks'] == 2 and
            result['saves_upper'] == 3 and not result['full_printer_claim'] and not result['full_119_claim'] and
            not result['aggregate_RAM_gate'], 'private limits')
    return summaries


def format_arithmetic():
    result = read_json(FORMAT / 'result.json')
    output = read_json(EV / 'retained-why-printer-output-20261023/result.json')
    embedded = read_json(FORMAT / 'providers.json')
    require(embedded['output'] == output, 'accepted R66 embedded output interface')
    actual_cases = {c['case']: c['drivers'] for c in result['cases']}
    summary = []
    for old_case in output['cases']:
        name = old_case['case']
        require(set(actual_cases[name]) == set(old_case['drivers']), ['all drivers', name])
        for driver, old in old_case['drivers'].items():
            row = actual_cases[name][driver]
            fixed = {'source_format_nodes_and_local_accumulator_nodes_upper':364,
                     'local_accumulator_descent_frames_upper':365,
                     'fixed_nonstring_payload_words_upper':128, 'fixed_nonstring_object_bytes_upper':1032,
                     'ordinary_accumulator_payload_words_upper':2, 'fixed_format_constructor_payload_words_upper':4,
                     'formatter_record_payload_words':28, 'partial_application_closure_payload_words_upper':5,
                     'dynamic_closure_group_members_upper':3, 'dynamic_closure_captured_slots_upper':16,
                     'dynamic_source_closure_group_payload_words_upper':28,
                     'scalar_padding_width_range':[0,64], 'scalar_precision_selected':False,
                     'native_integer_conversion_bytes_upper':21, 'integer_conversion_C_format_buffer_bytes':32,
                     'integer_conversion_C_output_buffer_bytes':128, 'annotation_parser_length_upper':5,
                     'annotation_integer_argument_length_upper':1, 'annotation_integer_value_range':[0,2],
                     'annotation_error_attempts_per_request_upper':1,
                     'assumes_each_formatting_call_emits_core_event':False,
                     'structural_progress_under_typed_source_premises':True,
                     'physical_stack_and_allocator_sufficiency_remain_external':True}
            for field, value in fixed.items():
                require(row[field] == value, ['format interface', name, driver, field])
            comment = old['raw_comment_name_bytes_upper']
            expected = {'main_buffer_backing':old['request_buffer']['allocated_capacity_upper'],
                        'name_helper_result':old['printed_name_bytes_upper'], 'name_helper_backing':512,
                        'raw_comment_escape':4*comment, 'quoted_comment':4*comment+2,
                        'main_single_text_payload':347, 'native_integer_conversion':21,
                        'scalar_padded_result':64, 'char_result':1, 'annotation_raw':7,
                        'annotation_description':5, 'annotation_backing':16,
                        'annotation_error_message':46, 'annotation_error_backing':256}
            require(set(row['string_objects']) == set(expected), ['string owner census', name, driver])
            for owner, length in expected.items():
                layout = row['string_objects'][owner]
                # Integer ceil((length+1)/8), independent of author rounding form.
                words = (length+1+7)//8
                require(layout['length_bytes_upper'] == length and layout['payload_words_upper'] == words and
                        layout['total_object_bytes_upper'] == 8*(words+1) and
                        layout['last_padding_byte_index_upper'] == 8*words-1, ['string layout', name, driver, owner])
                require(length <= 2**57-9 and words <= 2**54-1 and 0 <= 8*words-1-length <= 7 and
                        length+8 <= 2**62-1 and 8*(words+1) <= 2**62-1,
                        ['native string guards', name, driver, owner])
                require(all(layout['guards'].values()), ['recorded string guards', name, driver, owner])
            require(row['all_local_representation_guards'], ['local guards', name, driver])
            summary.append({'case':name, 'driver':driver, 'individual_string_classes':len(expected),
                            'main_buffer_backing':expected['main_buffer_backing'],
                            'main_string_payload_words':row['string_objects']['main_buffer_backing']['payload_words_upper']})
    for flag in ['source_argument_machine_checked', 'physical_stack_sufficiency_proved',
                 'allocator_GC_kernel_service_proved', 'total_memory_reservation_claimed',
                 'shared_stderr_whole_interval_closed', 'whole_printer_capacity', 'whole_process_capacity',
                 'budget_renewed', 'aggregate_RAM_or_stack_gate']:
        require(result[flag] is False, ['format limit', flag])
    require(result['global_escape_budget'] == result['save_entering_callbacks'] == 2 and result['saves_upper'] == 3,
            'one global format budget')
    return summary


def main():
    started = time.perf_counter()
    targets = read_json(HERE / 'targets.json')
    for path, item in targets['exact_inputs'].items():
        exact(path, item)
    for directory in (PRIVATE, FORMAT):
        provider_manifest(directory / 'inputs.json')
    private_ranges = witnesses(PRIVATE / 'source-witnesses.json')
    format_ranges = witnesses(FORMAT / 'source-witnesses.json')
    census = private_census()
    private_rows = private_arithmetic()
    format_literals = format_census()
    format_rows = format_arithmetic()
    native = native_audit()
    report = {'status':'passed', 'elapsed_seconds':time.perf_counter()-started, 'finite_checks':checks,
              'exact_inputs':targets['exact_inputs'], 'providers':providers,
              'author_freezes':targets['author_freezes'], 'audit_code_identity':identity(Path(__file__).read_bytes()),
              'private_source_ranges':private_ranges, 'format_source_ranges':format_ranges,
              'complete_source_members':len(members), 'private_census':census,
              'private_cases':private_rows, 'format_census':format_literals, 'format_cases':format_rows, 'native':native,
              'accepted_scope':'selected private printer containers and formatting accumulator/local layout/finite progress under retained premises',
              'whole_printer_capacity':False, 'whole_process_capacity':False, 'whole_119_claim':False,
              'author_or_predecessor_code_executed':False, 'native_compiler_solver_capture_disassembler_proof_run':False}
    (HERE / 'audit-result.json').write_text(json.dumps(report, indent=2, sort_keys=True)+'\n')
    print(json.dumps({k:report[k] for k in ['status','elapsed_seconds','finite_checks','private_source_ranges',
                                           'format_source_ranges','complete_source_members']}))


if __name__ == '__main__':
    main()
