#!/usr/bin/env python3
"""One fresh identity/operand-transport calculation; never imports providers."""
from pathlib import Path
import hashlib
import json
import re
import tarfile
import time

ROOT = Path(__file__).resolve().parents[3]
PACKET = Path(__file__).resolve().parent
START = time.perf_counter()
checks = 0


def require(value, label):
    global checks
    checks += 1
    if not value:
        raise AssertionError(label)


def read(relative):
    return json.loads((ROOT / relative).read_text())


def provider(name, leaf='result.json'):
    return read('docs/evidence/' + name + '/' + leaf)


def cases(value):
    return {row['case'].replace('-', '_'): row for row in value['cases']}


def identity(path):
    data = path.read_bytes()
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


manifest = json.loads((PACKET / 'inputs.json').read_text())
for path, expected in manifest['providers'].items():
    require(identity(ROOT / path) == expected, 'provider identity: ' + path)
receipt_files = 0
for path in manifest['acceptance_receipts']:
    value = read(path)
    require(value['status'] in ('pass', 'passed'), 'accepted receipt: ' + path)
    for frozen_path, expected in value.get('frozen_files', {}).items():
        require(identity(ROOT / frozen_path) == expected,
                'accepted component identity: ' + frozen_path)
        receipt_files += 1

ranges = json.loads((PACKET / 'source-ranges.json').read_text())
for archive, members in ranges['archives'].items():
    with tarfile.open(ROOT / archive) as tar:
        for member, info in members.items():
            data = tar.extractfile(member).read()
            require(hashlib.sha256(data).hexdigest() == info['sha256'], member)
            lines = data.decode().splitlines(keepends=True)
            for span in info['ranges']:
                selected = ''.join(lines[span['first'] - 1:span['last']]).encode()
                require(hashlib.sha256(selected).hexdigest() == span['sha256'],
                        member + ':' + str(span['first']))
                for anchor in span['anchors']:
                    require(anchor.encode() in selected, 'source anchor: ' + anchor)

names = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']
gs = [51, 42, 22, 2, 1]
ns = [153, 126, 66, 6, 3]
qs = [155, 128, 68, 8, 5]
retained_ns = [192, 159, 96, 9, 3]
c0s = [14, 12, 10, 1, 3]
As = [169, 140, 78, 9, 8]
Os = [12844, 10640, 5928, 684, 608]
taus = [43, 82, 49, 89, 49]
llocs = [352, 346, 382, 368, 376]
Fs = [775, 802, 841, 853, 829]
digits = [3, 3, 2, 1, 1]
request_constants = [1012, 1039, 1076, 1086, 1062]
Us = [7670360, 6391978, 3951491, 581155, 697270]
xmls = [588599398, 490581822, 303447466, 44645930, 53513166]
I31 = 2**31 - 1
I63 = 2**62 - 1
I64 = 2**63 - 1
U64 = 2**64 - 1

shared = cases(provider('retained-name-attribute-round65-20261023', 'composition-result.json'))
shared_receipt = cases(provider('retained-name-attribute-round65-20261023', 'integration-result.json'))
ctrl = cases(provider('retained-controller-owner-join-20261023'))
canonical = cases(provider('retained-why-canonical-json-input-20261023'))
paths = provider('retained-why-report-path-inputs-20261023', 'projection.json')['domains']
report = cases(provider('retained-reporting-path-join-20261023'))
logging = cases(provider('retained-why-logging-capacity-20261023', 'bounds.json'))
requests = provider('retained-solver-request-bytes-20261020', 'projection.json')['domains']
printer = cases(provider('retained-printer-output-round66-20261023', 'integration-result.json'))
saves = cases(provider('retained-why-save-round32-20261020')['under_named_existing_external_premises'])
stack_provider = provider('retained-why-save-round38-20261020', 'save-stack-join.json')
stack = cases(stack_provider)
require((stack_provider['global_max_saves'], stack_provider['global_max_callbacks'],
         stack_provider['direct_bridge_high_water_bytes'], stack_provider['dispatch_to_save_shell_bytes'])
        == (3, 2, 4104, 816), 'save stack global allowance and bridge operands')


def receive(M):
    b = 1024
    while b < M + 1023:
        b = 2 * (b + 1024)
    return b


def reporting(row, F, R):
    S = max(467, F + 51, R + 95)
    K = 723 + 12 * S
    Y = 21 * (8 * K + 65536)
    X = 2 * (Y + 1024)
    B = row['b1'] + 6 * X
    E = row['e1'] + 2 * X
    L, I = B + E, 3 * E + 2
    T = 1000000010 + L + 1
    operands = {'sentinel': L + 79, 'scan': (3 * E + 1) * T + L + 79,
                'counts': 4 * I + 2}
    guards = [operands['sentinel'] <= 1000000010,
              operands['scan'] <= I63, operands['counts'] <= I63]
    return dict(R=R, S=S, K=K, Y=Y, X=X, B=B, E=E,
                operands=operands, guards=guards,
                Std=B + 70 * (E + 2) + 2 * Y + 371)


rows = []
for i, name in enumerate(names):
    g, n, Q, N, c0, A, O, tau, Lloc, F, digit = (
        values[i] for values in (gs, ns, qs, retained_ns, c0s, As, Os,
                                  taus, llocs, Fs, digits))
    c, s, p, r, log = ctrl[name], shared[name], paths[name], report[name], logging[name]
    require(n == 3 * g and Q == n + 2, name + ' scheduling/preparation distinction')
    require(A == c0 + Q and O == 76 * max(A, Q), name + ' weighted occurrences')
    require((s['registered_roots'], s['episodes_upper']) == (g, Q), name + ' shared counts')
    require((c['registered_roots'], c['run_entries_upper'],
             c['retained_protocol_run_entries_upper'], c['other_owner_Q_unchanged'])
            == (g, n, N, Q), name + ' controller count transport')
    require(c['initial_attempt_counter'] == c0, name + ' initial attempts')
    require(c['result_buffer']['physical_cells_upper'] == 2 * n, name + ' S/F physical cells')
    require(c['saved_data_live_call_Hpan_each']['capacity_upper'] == [128,64,64,32,32][i],
            name + ' controller backing')
    require(c['result_buffer']['capacity_upper'] == [256,128,128,32,32][i], name + ' result backing')
    require((canonical[name]['A'], canonical[name]['N'], canonical[name]['O']) == (A, Q, O),
            name + ' canonical occurrence transport')
    require((p['TMPDIR_bytes_tau'], p['location_filename_upper_L'], p['request_path_upper_F'])
            == (tau, Lloc, F), name + ' path transport')
    require(F == tau + max(5, 2 * Lloc) + 28 and r['F'] == F, name + ' alias robust filename')
    require(requests[name]['N'] == N and requests[name]['id_digits'] == digit,
            name + ' retained wire counts')
    require(max(x['profiles']['quiet']['original_wire_F_plus_d_constant']
                for x in requests[name]['provers'].values()) == 176, name + ' wire serializer')
    require(max(x['profiles']['quiet']['parser_m_excluding_executable']
                for x in requests[name]['provers'].values()) == 14, name + ' argv fields')
    require(F + 176 + 55 + 2 * digit == request_constants[i], name + ' new request constant')
    require(log['Q'] == Q and log['log_invocations_upper_H'] == Q * Q + 4 * Q,
            name + ' logger occurrences')
    require(log['channel_offered_bytes_upper_X'] == 1281 * (Q * Q + 4 * Q)
            and log['numeric_guards_pass'], name + ' logger offers')
    require(printer[name]['request_opportunities_upper'] == Q, name + ' printer requests')
    fragment = printer[name]['shared_stderr_fragment_once']
    require(fragment['process_core_events_upper'] == 8 * Q
            and fragment['process_text_bytes_upper'] == 64 * Q, name + ' stderr fragment once')
    require(saves[name]['candidate_U'] == Us[i], name + ' save U')
    require(saves[name]['format_core']['core_bounds']['offered_xml_bytes_upper'] == xmls[i],
            name + ' save offer')
    st = stack[name]
    require(st['owned_save_caller_per_save_bytes'] == sum(st[k] for k in ('S','T','G','F')),
            name + ' replacement stack composition')
    require(st['r3_e2_save_phase_projection_bytes']
            == 3 * (st['owned_save_caller_per_save_bytes'] + 4104) + 2 * 816,
            name + ' three saves once')
    require(len(s['conditional_transfers']) == 7 and shared_receipt[name]['seven_named_owner_operands_fit'],
            name + ' seven accepted owners')
    endpoints = {}
    for owner, transfer in s['conditional_transfers'].items():
        counter = transfer['counter']
        require(counter['final_upper'] == counter['initial'] + counter['increments_upper'],
                name + ' complete lifetime endpoint ' + owner)
        require(counter['final_upper'] <= I63 and transfer['native_operands_fit'],
                name + ' native owner guard ' + owner)
        endpoints[owner] = counter['final_upper']
    evaluations = []
    for label in ('lower_endpoint_arithmetic_only', 'upper_endpoint_arithmetic_only'):
        old = r[label]
        new = reporting(r, F, old['R'])
        for key in ('S','K','Y','X','B','E'):
            require(new[key] == old[key], name + ' reporting operand ' + key)
        require(new['operands'] == old['standard']['operands'], name + ' reporting core operands')
        require(new['X'] == 4032 * new['S'] + 2997488, name + ' X affine expression')
        require(all(new['guards']) and new['Std'] == old['selected_stdout_stderr_offer']
                and new['Std'] <= I64, name + ' channel/core guards')
        evaluations.append(new)
    common_endpoint = reporting(r, F, 2264)
    require(all(common_endpoint['guards']) and common_endpoint['Std'] <= I64,
            name + ' common sufficient result-directory interval')
    rows.append(dict(case=name, registered_roots=g, current_runs=n, preparation_Q=Q,
                     retained_protocol_N=N, reported_attempts=A, weighted_occurrences_O=O,
                     retained_TMPDIR_bytes=tau, F=F, request_constant=request_constants[i],
                     seven_shared_final_endpoints=endpoints,
                     reporting_provider_endpoints=evaluations,
                     common_result_directory_endpoint=common_endpoint,
                     log_offered_bytes=log['channel_offered_bytes_upper_X'],
                     save_U=Us[i], per_save_XML_offer=xmls[i],
                     save_caller_per_save_bytes=st['owned_save_caller_per_save_bytes'],
                     three_save_two_callback_caller_projection=st['r3_e2_save_phase_projection_bytes'],
                     epsilon=dict(Hls_bindings=0, Hty_bindings=1, buckets_each=16),
                     validator=dict(cgr_physical_cells_upper=2, htb_cells=0,
                                    buckets_each=16, vector_width_upper=4,
                                    variant_position_list_upper=8)))

require(sum(ns) == 354 and sum(retained_ns) == 459 and sum(Os) == 30704, 'aggregate mathematical sums')
constant = sum(N * k for N, k in zip(retained_ns, request_constants)) + 250578
symbolic_tau_constant = sum(N * (k-tau) for N, k, tau in zip(retained_ns, request_constants, taus)) + 250578
require(constant == 726339 and symbolic_tau_constant == 699393, 'substituted server constants')
# Check branch boundaries of the new receive operand transport, not provider code.
receive_cases = []
for a in (1, 64, 1024, 4096, I31 - 1023 - max(request_constants)):
    Ms = [a + k for k in request_constants]
    require(all(M + 1023 <= I31 for M in Ms), 'request signed guard')
    caps = [receive(M) for M in Ms]
    require(all(b >= M + 1023 and 2*(b+1024) <= U64 for b,M in zip(caps,Ms)), 'receive guard')
    for c_dir in (1, 4096, I31 - 45):
        expanded = sum(N*M for N,M in zip(retained_ns,Ms)) + sum(2*b for b in caps) + 918*c_dir + 250578
        affine = 459*a + sum(2*b for b in caps) + 918*c_dir + 726339
        tau_affine = 459*a + sum(N*t for N,t in zip(retained_ns,taus)) + sum(2*b for b in caps) + 918*c_dir + 699393
        require(expanded == affine == tau_affine, 'server expression identity')
    receive_cases.append(dict(adapter_bytes=a, request_lengths=Ms, receive_capacities=caps))

family = provider('retained-why-library-constructors-20261023', 'family-shapes.json')
eligible = []
for decl in family['recursive_declarations']:
    head = decl['first']
    if 'function' not in head or 'requires' in decl['source']:
        continue
    routine = re.search(r'function\s+(\w+)', head).group(1)
    self_calls = len(re.findall(r'\b' + routine + r'\b', decl['source'])) - 1
    eligible.append((decl['module'] + '.' + routine, self_calls))
require(eligible == [('int.NumOf.numof', 2), ('int.Sum.sum', 1),
                     ('int.SumParam.sum', 1), ('real.Sum.sum', 1)],
        'lexical recursive-call projection for source proof')
require(family['explicit_program_declarations_in_cloned_targets'] == [], 'no cloned recursive program body')
require(family['lexical_projection_is_not_semantic_proof'], 'source proof remains explicit')

memo = manifest['preparation_private_memos']
require(memo['independent_review_accepted'], 'preparation private memo review required for final conjunction')
for path, expected in memo['files'].items():
    require(identity(ROOT / path) == expected, 'reviewed private memo input ' + path)
memo_audit = provider('retained-preparation-private-memos-review-20261023', 'audit-result.json')
require(memo_audit['status'] == 'pass' and memo_audit['author_commit'] == memo['author_freeze'],
        'independent memo review identifies exact author')
memo_rows = cases(provider('retained-preparation-private-memos-20261023'))
for i, name in enumerate(names):
    private = memo_rows[name]
    for family, row in private['memo_families'].items():
        endpoint = shared[name]['conditional_transfers'][row['key_counter_owner']]['counter']['final_upper']
        require(row['counter_endpoint_upper'] == endpoint and row['key_universe_upper'] == endpoint + 1
                and row['native_array_and_size_operands_fit'], name + ' memo endpoint transport ' + family)
    require(private['introduction']['episodes_already_globally_charged'] == qs[i]
            and private['introduction']['native_operands_fit'], name + ' private introduction allowance')
    require(private['R58_tagged_dependency_maps']['keys_per_map_or_set_upper']
            == shared[name]['conditional_transfers']['Ident']['counter']['final_upper'] + 1,
            name + ' dependency key universe')


result = dict(status='pass', checks=checks, base_commit=manifest['base_commit'],
              provider_files=len(manifest['providers']), accepted_component_file_checks=receipt_files,
              cases=rows, server_retained_tau_constant=constant,
              server_symbolic_tau_constant=symbolic_tau_constant,
              current_runs_total=354, retained_runs_total=459,
              configuration_functions=dict(
                  F='tau_d + max(5, 2*Lloc_d) + 28',
                  L_request='a + F_d + 231 + 2*id_digits_d',
                  P_diag='max(F_d, r_dir+24)', M_response='r_dir+72',
                  q_backend='max(2*a+72, a+e_name+1296)',
                  B_stock='B_direct + max(2147483647+c_dir+1, 2*max(4096,2*c_dir)+1048624) + 2*(s_socket+1)'),
              receive_operand_evaluations=receive_cases,
              preparation_private_memo_review= memo,
              guarded_fixed_Why_conjunction_established=True,
              unconditional_whole_process_capacity=False,
              successful_controlled_startup_scope=True,
              arbitrary_pre_cut_failure_prefixes_covered=False,
              arbitrary_Main_covered=False, GNATCOLL_and_final_spark_consumers_covered=False,
              production_launcher_adapter_refinement_established=False,
              global_exception_allowance=2, global_save_callbacks=2, global_saves=3,
              exceptional_allowance_renewed=False, aggregate_RAM_or_stack_gate=False,
              provider_checker_replays=0, native_runs=0,
              elapsed_seconds=round(time.perf_counter()-START,6))
(PACKET / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k:v for k,v in result.items() if k not in ('cases','receive_operand_evaluations','preparation_private_memo_review')},indent=2))
