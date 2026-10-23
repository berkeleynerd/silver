"""New private-container applications of retained bounds; no native replay."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent
INT_MAX = (1 << 62) - 1
ARRAY_MAX = (1 << 54) - 1
POWER_CAP = 1 << 53


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def memo_bound(keys, initial=64):
    assert type(keys) is int and keys >= 0
    assert 16 <= initial <= POWER_CAP and initial & (initial-1) == 0
    backing = min(POWER_CAP, max(initial, 4*keys))
    completed = max(2*backing, keys)
    transient = max(2*backing+1, keys+1)
    return {
        'key_universe_upper': keys,
        'initial_array_upper': initial,
        'individual_array_length_upper': backing,
        'completed_stored_cells_upper': completed,
        'one_add_transient_cells_upper': transient,
        'resize_multiply_and_load_operand_upper': 2*backing,
        'single_array_bytes_including_header_upper': 8*(backing+1),
        'working_old_plus_new_array_slots_upper': 2*backing,
        'native_array_and_size_operands_fit': (
            backing <= ARRAY_MAX and 2*backing <= INT_MAX and
            transient <= INT_MAX and 8*(backing+1) <= INT_MAX),
    }


def check():
    manifest = read(HERE / 'inputs.json')
    for path, expected in manifest['providers'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    ranges = 0
    for archive in sorted({s['archive'] for s in manifest['source_members'].values()}):
        with tarfile.open(ROOT / archive) as source:
            for name, row in manifest['source_members'].items():
                if row['archive'] != archive:
                    continue
                data = source.extractfile(name).read()
                assert identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, name
                lines = data.splitlines(keepends=True)
                for span in row['spans']:
                    assert identity(b''.join(lines[span['first']-1:span['last']])) == {
                        k: span[k] for k in ('bytes', 'sha256')}, name
                    ranges += 1

    # Only the accepted pure transfer is called with NEW Introduction inputs.
    path = EV / 'retained-why-inline-operations-20261018/compose.py'
    spec = importlib.util.spec_from_file_location('retained_private_memo_transfer', path)
    transfer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(transfer)
    shared = read(EV / 'retained-name-attribute-round65-20261023/composition-result.json')
    entry = read(EV / 'retained-why-printer-entry-20261020/result.json')
    intros = {row['case']: row for row in entry['cases']}
    assert entry['process_global_e_upper'] == entry['save_callbacks_upper'] == 2
    assert entry['saves_upper'] == 3 and not entry['new_stage_escape_allowance']
    rows = []
    for case in shared['cases']:
        name = case['case']
        counters = case['conditional_transfers']
        groups = {}
        for family, owner in (
            ('Wtask', 'Task.Hstask'), ('Wdecl', 'Decl.Hsdecl'),
            ('Wtds', 'Task.Stdecl.Hcpt'), ('Wty', 'Ty.Hsty'), ('Wid', 'Ident')):
            endpoint = counters[owner]['counter']['final_upper']
            assert counters[owner]['native_operands_fit']
            # Include zero/empty sentinel; do not add initial counters again.
            result = memo_bound(endpoint+1)
            result['key_counter_owner'] = owner
            result['counter_endpoint_upper'] = endpoint
            assert result['native_array_and_size_operands_fit'], (name, family)
            groups[family] = result
        intro = intros[name]
        m, p, episodes = (intro['dimensions']['M'], intro['dimensions']['P'],
                          intro['episodes_upper'])
        assert episodes == case['episodes_upper']
        ax = (8*m)*episodes
        queue = (8*m+p)*episodes
        assert ax == intro['process_demands']['introduction_axiom_requests']
        assert queue == intro['process_demands']['introduction_ls_queue_requests']
        weak = transfer.weak_transfer(5003, 0, 0, ax)
        assert 3*max(weak['individual_outer_array_length_upper'],
                     weak['individual_bucket_length_upper'])+6 <= INT_MAX
        assert weak['individual_outer_array_length_upper'] <= ARRAY_MAX
        assert weak['individual_bucket_length_upper']+2 <= (1 << 54)-3
        assert max(ax, queue)+1 <= INT_MAX
        local_strong = 1 << (max(16, queue)-1).bit_length()
        assert local_strong <= ARRAY_MAX and 2*local_strong <= INT_MAX
        ident_keys = groups['Wid']['key_universe_upper']
        tree_height = 3*(2*ident_keys+1).bit_length()+4
        assert ident_keys <= INT_MAX and tree_height+2 <= INT_MAX
        rows.append({
            'case': name, 'memo_families': groups,
            'driver_Hint': {'keys_and_cells_upper': 3, 'array_length': 16,
                            'native_operands_fit': True},
            'introduction': {
                'M': m, 'P': p, 'episodes_already_globally_charged': episodes,
                'private_content_requests': ax, 'ls_queue_requests': queue,
                'axiom_queue_length_upper': ax, 'ls_queue_length_upper': queue,
                'private_content_weak_backing': weak,
                'local_Hvs_cells_upper': queue,
                'local_Hvs_array_upper': local_strong,
                'native_operands_fit': True,
            },
            'R58_tagged_dependency_maps': {
                'keys_per_map_or_set_upper': ident_keys,
                'two_input_nodes_upper': 2*ident_keys,
                'height_and_rotation_operand_upper': tree_height,
                'cardinal_and_list_length_upper': ident_keys,
                'native_operands_fit': True,
            },
        })
    saturated = [(r['case'], f) for r in rows for f, v in r['memo_families'].items()
                 if v['individual_array_length_upper'] == POWER_CAP]
    assert ('put-line', 'Wty') in saturated and ('put-line', 'Wid') in saturated
    assert POWER_CAP <= ARRAY_MAX < 2*POWER_CAP <= INT_MAX
    assert len(rows) == 5
    return {
        'status': 'pass', 'scope': 'selected private preparation container representation',
        'provider_files': len(manifest['providers']),
        'source_members': len(manifest['source_members']), 'strict_source_ranges': ranges,
        'cases': rows, 'saturation_used': saturated,
        'global_e_upper': 2, 'save_entering_callbacks_upper': 2, 'saves_upper': 3,
        'global_allowance_renewed': False, 'aggregate_RAM_or_stack_gate': False,
        'cumulative_allocation_or_runtime_bound_claimed': False,
        'whole_fixed_domain_complete': False, 'whole_capacity_rule_complete': False,
        'source_theorem_machine_checked': False, 'independently_reviewed': False,
        'successful_predecessor_checker_replays': 0, 'native_target_runs': 0,
    }


if __name__ == '__main__':
    start = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter()-start
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k != 'cases'}))
