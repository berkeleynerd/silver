#!/usr/bin/env python3
"""Independent exact-freeze identity and arithmetic audit; no author imports.

The source induction and caller review are recorded in source-review.md.
Finite arithmetic checks support that argument; they do not prove it by sampling.
All inputs are read from the author commit, so unrelated worktree state is not
silently substituted for the reviewed provider bytes.
"""
import hashlib
import io
import json
import platform
import subprocess
import tarfile
import time
from functools import lru_cache
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = 'bb61e70086339202fd167cd4990f86106e63ebe6'
PACKET = 'docs/evidence/retained-preparation-private-memos-20261023/'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
OCAML_PREFIX = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/'
CHECKS = 0


def check(value, message):
    global CHECKS
    if not value:
        raise AssertionError(message)
    CHECKS += 1


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


@lru_cache(None)
def blob(path):
    return subprocess.check_output(['git', 'show', AUTHOR + ':' + path], cwd=ROOT)


def read(path):
    return json.loads(blob(path))


@lru_cache(None)
def archive(path):
    with tarfile.open(fileobj=io.BytesIO(blob(path))) as tf:
        return {m.name: tf.extractfile(m).read() for m in tf if m.isfile()}


def native_power(n):
    p = 16
    while p < n:
        p *= 2
    return p


def main():
    started = time.perf_counter()
    frozen = json.loads((HERE / 'inputs.json').read_text())
    check(frozen['author_commit'] == AUTHOR, 'review target')
    for name, expected in frozen['author_files'].items():
        check(identity(blob(name)) == expected, 'author file ' + name)
        check((ROOT / name).read_bytes() == blob(name), 'imported author file ' + name)
    authored = read(PACKET + 'inputs.json')
    for name, expected in authored['providers'].items():
        check(identity(blob(name)) == expected, 'provider ' + name)
    spans = 0
    for name, row in authored['source_members'].items():
        data = archive(row['archive'])[name]
        check(identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, 'full source ' + name)
        lines = data.splitlines(keepends=True)
        for part in row['spans']:
            a, b = part['first'], part['last']
            check(1 <= a <= b <= len(lines), 'strict source endpoints')
            check(identity(b''.join(lines[a-1:b])) == {k: part[k] for k in ('bytes', 'sha256')}, 'source span ' + name)
            spans += 1
    for row in frozen['supplementary_sources']:
        data = archive(row['archive'])[row['member']]
        check(identity(data) == row['identity'], 'supplementary full source')
        lines = data.splitlines(keepends=True)
        for part in row['spans']:
            a, b = part['first'], part['last']
            check(1 <= a <= b <= len(lines), 'supplementary strict endpoints')
            check(identity(b''.join(lines[a-1:b])) == part['identity'], 'supplementary source span')
    # These excerpts are not semantic proofs. They bind the manually reviewed
    # control/caller statements to their precise complete source providers.
    for row in frozen['source_claim_anchors']:
        txt = archive(row['archive'])[row['member']].decode()
        check(row['text'] in txt, 'reviewed source anchor ' + row['label'])

    result = read(PACKET + 'result.json')
    shared = read('docs/evidence/retained-name-attribute-round65-20261023/composition-result.json')
    entry = read('docs/evidence/retained-why-printer-entry-20261020/result.json')
    shared_cases = {c['case']: c for c in shared['cases']}
    entry_cases = {c['case']: c for c in entry['cases']}
    check(set(shared_cases) == set(entry_cases) == {r['case'] for r in result['cases']}, 'same five domains')
    check(len(result['cases']) == 5, 'five domain rows')
    check(entry['process_global_e_upper'] == entry['save_callbacks_upper'] == 2, 'existing escape/callback allowance')
    check(entry['saves_upper'] == 3 and not entry['new_stage_escape_allowance'], 'existing save allowance')
    limit = read('docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json')
    amax, imax = 2**54-1, 2**62-1
    cap = 2**(amax.bit_length()-1)
    check(limit['max_wosize'] == amax, 'retained ordinary-array limit')
    check(cap == 2**53 and cap < amax < 2*cap <= imax, 'strict growth power-of-two stop')
    owners = {'Wtask': 'Task.Hstask', 'Wdecl': 'Decl.Hsdecl',
              'Wtds': 'Task.Stdecl.Hcpt', 'Wty': 'Ty.Hsty', 'Wid': 'Ident'}
    initials = {'Wtask': 63, 'Wdecl': 63, 'Wtds': 17, 'Wty': 17, 'Wid': 7}
    saturated = []
    maxima = dict(backing=0, transient=0, introduction_content=0,
                  introduction_queue=0, local_Hvs_backing=0, map_keys=0)
    for r in result['cases']:
        name = r['case']
        old = shared_cases[name]
        check(set(r['memo_families']) == set(owners), 'five named memo families')
        for family, owner in owners.items():
            row = r['memo_families'][family]
            predecessor = old['conditional_transfers'][owner]
            endpoint = predecessor['counter']['final_upper']
            check(predecessor['native_operands_fit'], 'accepted counter representation')
            m = endpoint + 1
            b = min(cap, max(64, 4*m))
            complete, transient = max(2*b, m), max(2*b+1, m+1)
            expected = dict(key_universe_upper=m, initial_array_upper=64,
                            individual_array_length_upper=b,
                            completed_stored_cells_upper=complete,
                            one_add_transient_cells_upper=transient,
                            resize_multiply_and_load_operand_upper=2*b,
                            single_array_bytes_including_header_upper=8*(b+1),
                            working_old_plus_new_array_slots_upper=2*b,
                            native_array_and_size_operands_fit=True,
                            key_counter_owner=owner, counter_endpoint_upper=endpoint)
            check(row == expected, 'independent memo arithmetic ' + name + '/' + family)
            check(native_power(initials[family]) <= 64 <= b, 'actual initial backing included')
            check(b <= amax and max(2*b, transient, 8*(b+1)) <= imax, 'all published native operands')
            check(m <= complete < transient, 'dead-cell/reset counter envelope')
            if b == cap:
                saturated.append([name, family])
            maxima['backing'] = max(maxima['backing'], b)
            maxima['transient'] = max(maxima['transient'], transient)
        predecessor = entry_cases[name]
        m, p = predecessor['dimensions']['M'], predecessor['dimensions']['P']
        episodes = predecessor['episodes_upper']
        check(episodes == old['episodes_upper'], 'one episode allowance')
        ax, queue = 8*m*episodes, (8*m+p)*episodes
        check(ax == predecessor['process_demands']['introduction_axiom_requests'], 'retained content requests')
        check(queue == predecessor['process_demands']['introduction_ls_queue_requests'], 'retained queue/Hvs requests')
        intro = r['introduction']
        check((intro['M'], intro['P'], intro['episodes_already_globally_charged']) == (m, p, episodes), 'Introduction source dimensions')
        for field, value in [('private_content_requests', ax), ('axiom_queue_length_upper', ax),
                             ('ls_queue_requests', queue), ('ls_queue_length_upper', queue),
                             ('local_Hvs_cells_upper', queue), ('local_Hvs_array_upper', native_power(queue))]:
            check(intro[field] == value, 'Introduction row ' + field)
        # Independent specialization of the already accepted transfer to NEW
        # (5003,0,0,ax) inputs. No provider module is imported or executed.
        wa = max(5003, (3*5003)//2 + 3, 3*ax+3)
        wb = (3*ax)//2 + 3
        weak = intro['private_content_weak_backing']
        for field, value in [('live_entries_upper', ax), ('individual_outer_array_length_upper', wa),
                             ('individual_bucket_length_upper', wb), ('outer_growth_multiply_upper', 3*wa),
                             ('bucket_growth_multiply_upper', 3*wb), ('shrink_multiply_plus_two_absolute_upper', 2*wb+6),
                             ('oversize_and_rover_upper', wa), ('find_or_equality_calls_per_request_upper', wb)]:
            check(weak[field] == value, 'new weak-table transfer ' + field)
        check(3*max(wa, wb)+6 <= imax and wa <= amax and wb+2 <= 2**54-3, 'new weak-table operands')
        check(queue+1 <= imax and native_power(queue) <= amax and 2*native_power(queue) <= imax, 'strong-table/queue operands')
        check(r['driver_Hint'] == dict(keys_and_cells_upper=3, array_length=16, native_operands_fit=True), 'three-driver table')
        check(3 <= 2*native_power(5), 'driver table never reaches growth trigger')
        keys = old['conditional_transfers']['Ident']['counter']['final_upper']+1
        tree = r['R58_tagged_dependency_maps']
        expected = dict(keys_per_map_or_set_upper=keys, two_input_nodes_upper=2*keys,
                        height_and_rotation_operand_upper=3*(2*keys+1).bit_length()+4,
                        cardinal_and_list_length_upper=keys, native_operands_fit=True)
        check(tree == expected, 'tag-key map cardinality and two-input height')
        check(keys <= imax and tree['height_and_rotation_operand_upper']+2 <= imax, 'map native operands')
        for field, value in [('introduction_content', ax), ('introduction_queue', queue),
                             ('local_Hvs_backing', native_power(queue)), ('map_keys', keys)]:
            maxima[field] = max(maxima[field], value)
    check(saturated == result['saturation_used'], 'exact saturated family inventory')
    check(len(saturated) == 5, 'five saturated applications')
    for field in ['global_allowance_renewed', 'aggregate_RAM_or_stack_gate',
                  'cumulative_allocation_or_runtime_bound_claimed', 'whole_fixed_domain_complete',
                  'whole_capacity_rule_complete', 'source_theorem_machine_checked',
                  'successful_predecessor_checker_replays', 'native_target_runs']:
        check(not result[field], 'scope guard ' + field)
    # Arithmetic edge checks at the actual thresholds, independently of the
    # five applications. These illustrate the induction's guarded-growth step.
    edges = 0
    for old in [16, 32, 64, 2**52, 2**53]:
        for live in [0, max(0, old//2-1), old//2, old//2+1, 2*old+1]:
            new = 2*old if 2*old < amax and live >= old//2 else old
            check(new <= min(cap, max(old, 4*live)), 'growth threshold edge')
            check(2*old <= imax, 'attempted native multiplication edge')
            edges += 1
    report = dict(status='pass', author_commit=AUTHOR, checks=CHECKS,
                  author_files=len(frozen['author_files']), providers=len(authored['providers']),
                  authored_full_sources=len(authored['source_members']), authored_strict_spans=spans,
                  supplementary_source_entries=len(frozen['supplementary_sources']),
                  supplementary_strict_spans=sum(len(s['spans']) for s in frozen['supplementary_sources']),
                  source_anchors=len(frozen['source_claim_anchors']), memo_applications=25,
                  additional_container_rows=5, saturation_applications=len(saturated),
                  growth_threshold_edges=edges, maxima=maxima,
                  elapsed_seconds=time.perf_counter()-started, platform=platform.platform(),
                  author_or_predecessor_module_imports=0, native_runs=0,
                  whole_fixed_domain_complete=False, whole_capacity_rule_complete=False)
    (HERE / 'audit-result.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
