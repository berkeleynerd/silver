#!/usr/bin/env python3
"""New focused first-fill reduction; no target execution or predecessor replay."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

from strict import Comparison, stored

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
R51 = ROOT / 'docs/evidence/retained-why-preinline-prefix-20261020'
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(path.read_bytes())


def encoded(value):
    return (json.dumps(value, indent=2, sort_keys=True) + '\n').encode()


class Names:
    """Decode only the retained prsymbol -> identifier -> UTF-8 name chain."""
    def __init__(self, data):
        self.blocks = {r['address']: r for r in map(json.loads, data.splitlines())}

    def fields(self, p, length):
        r = self.blocks[p]
        assert r['tag'] == 0 and r['words'] == length
        b = bytes.fromhex(r['payload_hex'])
        assert len(b) == 8 * length
        return struct.unpack('<' + 'Q' * length, b)

    def name(self, pr):
        identifier, = self.fields(pr, 1)
        string, _, _, tag = self.fields(identifier, 4)
        assert tag & 1
        r = self.blocks[string]
        assert r['tag'] == 252
        b = bytes.fromhex(r['payload_hex'])
        assert b[len(b) - b[-1] - 1] == 0
        return b[:len(b) - b[-1] - 1].decode('utf-8')


def mutations(graph, protected, residual):
    """Controls for distinctions that alpha/opened-coordinate tests lose."""
    checks = {}
    root = protected[0]['raw_root_index']
    for field, value in (('attrs', ['R52:synthetic-attribute']),
                         ('location', 'R52:distinct-location'),
                         ('type', 'R52:distinct-type')):
        g = copy.deepcopy(graph)
        new = copy.deepcopy(g['terms'][root]); new[field] = value
        g['terms'].append(new)
        checks[field + '_difference_rejected'] = not Comparison(g).equal(root, len(g['terms']) - 1)
    quant = next(r['raw_root_index'] for r in protected
                 if graph['terms'][r['raw_root_index']]['kind'] == 'quant'
                 and graph['bindings'][graph['terms'][r['raw_root_index']]['args'][1]]['triggers'])
    g = copy.deepcopy(graph)
    t = copy.deepcopy(g['terms'][quant])
    b = copy.deepcopy(g['bindings'][t['args'][1]])
    b['triggers'] = []
    g['bindings'].append(b); t['args'][1] = len(g['bindings']) - 1
    g['terms'].append(t)
    checks['trigger_difference_rejected'] = not Comparison(g).equal(quant, len(g['terms']) - 1)
    constant = next(i for i, t in enumerate(graph['terms']) if t['kind'] == 'const')
    g = copy.deepcopy(graph)
    t = copy.deepcopy(g['terms'][constant]); t['args'][0] = (t['args'][0] + 1) % 5
    g['terms'].append(t)
    checks['integer_literal_kind_difference_rejected'] = not Comparison(g).equal(constant, len(g['terms']) - 1)
    assert all(checks.values())
    # This is deliberately a representation countermodel, not a reachable
    # Z3 execution or a claim that an arbitrary forged graph is admissible.
    candidate = residual[0]['candidate_root_index']
    g = copy.deepcopy(graph); t = copy.deepcopy(g['terms'][candidate])
    assert t['kind'] == 'quant'
    b = copy.deepcopy(g['bindings'][t['args'][1]])
    unused = min(map(int, g['variables'])) - 100
    for offset in range(3):
        key = str(unused - offset)
        b['saved'][key] = constant
        g['variables'][key] = dict(type=g['terms'][constant]['type'],
                                  name='R52_unused_' + str(offset), attrs=[])
    g['bindings'].append(b); t['args'][1] = len(g['bindings']) - 1
    g['terms'].append(t); new = len(g['terms']) - 1
    assert Comparison(g).equal(candidate, new)
    before, after = stored(g, [candidate]), stored(g, [new])
    assert after['saved_entries'] == before['saved_entries'] + 3
    return dict(negative_controls=checks,
                synthetic_unused_map_countermodel=dict(strict_equal=True,
                    before=before, after=after, producer_reachability_claimed=False))


def calculate():
    inputs = read(HERE / 'inputs.json')
    for name, expected in inputs['files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    members = {}
    for archive in sorted({r['archive'] for r in inputs['members']}):
        with tarfile.open(ROOT / archive) as tar:
            for r in inputs['members']:
                if r['archive'] != archive: continue
                data = tar.extractfile(r['member']).read()
                assert identity(data) == r['identity'], r['member']
                members[archive, r['member']] = data
    for row in read(HERE / 'source-witnesses.json'):
        lines = members[row['archive'], row['member']].decode().splitlines(keepends=True)
        assert ''.join(lines[row['first_line'] - 1:row['last_line']]) == row['text']

    old = read(R51 / 'result.json')
    assert old['retained_serial_seed_closure_under_named_premises']
    assert not old['intended_parallel_seed_closure']
    drivers = read(ROOT / 'docs/evidence/retained-producer-driver-envelope-20261018/result.json')
    dispatch = drivers['selected_driver_dispatch']['z3']['transformations']
    inventory = read(HERE / 'producer-inventory.json')
    assert [r['name'] for r in inventory['stages']] == [r['name'] for r in dispatch]
    common = 'docs/evidence/retained-why-save-state-capture-20261020/capture-common.tar.gz'
    for group in ('registration', 'inline'):
        lines = members[common, group + '/overlay/z3_gnatprove.drv'].decode().splitlines()
        for row in dispatch:
            assert lines[row['line'] - 1].strip() == 'transformation "' + row['name'] + '"'

    certificates, rows = {}, []
    for case in CASES:
        slug = case.replace('_', '-')
        graph = json.loads(gzip.decompress((R51 / (slug + '-graph.json.gz')).read_bytes()))
        oldcert = read(R51 / (slug + '-certificate.json'))
        common_declarations = set(oldcert['common_context_declarations'])
        archive = 'docs/evidence/retained-why-save-state-capture-20261020/capture-' + slug + '.tar.gz'
        group = 'inline' if case == 'input_is_valid' else 'registration'
        names = Names(members[archive, group + '/' + case + '/capture/session-blocks.jsonl'])
        comparison = Comparison(graph)
        protected, true_rows, unresolved = [], [], []
        for d in graph['declarations']:
            if d['kind'] != 5 or d['declaration'] not in common_declarations: continue
            raw, = d['raw_root_indexes']; candidate, = d['candidate_root_indexes']
            equal = comparison.equal(raw, candidate)
            matches = oldcert['same_key_projection'][str(d['declaration'])]
            row = dict(declaration=d['declaration'], prsymbol=d['symbol'],
                       name=names.name(d['symbol']), raw_root_index=raw,
                       candidate_root_index=candidate, strict_equal_sufficient_test=equal,
                       comparison_events=dict(comparison.events),
                       raw_coordinates=d['raw_mapped_roots'][0]['coordinates'],
                       candidate_coordinates=d['candidate_mapped_roots'][0]['coordinates'],
                       raw_stored=stored(graph, [raw]), candidate_stored=stored(graph, [candidate]),
                       raw_root_metadata={k:graph['terms'][raw][k] for k in ('type','attrs','location')},
                       candidate_root_metadata={k:graph['terms'][candidate][k] for k in ('type','attrs','location')},
                       initial_same_key_objects=matches)
            if equal:
                # Initial table contains exactly this raw representative.
                assert len(matches) == 1 and matches[0]['declaration'] == d['declaration']
                assert matches[0]['raw_declaration'] and matches[0]['compatible']
                assert row['raw_stored']['saved_entries'] == row['candidate_stored']['saved_entries'] == 0
                row['protection'] = 'Live raw declaration; independent of first CE memo fill'
                protected.append(row)
            elif graph['terms'][candidate]['kind'] == 'true':
                t = graph['terms'][candidate]
                assert t['args'] == [] and t['type'] is None
                assert row['candidate_stored'] == dict(terms=1,bindings=0,
                    nonempty_saved_maps=0,saved_entries=0,largest_saved_map=0)
                row['protection'] = 'Any strict-equal Ttrue has no term children, binders or maps'
                true_rows.append(row)
            else:
                assert row['raw_coordinates'] != row['candidate_coordinates']
                row['protection'] = None
                unresolved.append(row)
        summary = next(x for x in old['cases'] if x['case'] == case)
        assert len(protected) + len(true_rows) + len(unresolved) == summary['context_Paxiom_keys']
        controls = mutations(graph, protected, unresolved)
        prospective = 2 * summary['selected_ce_direct_Ident_sum'] + summary['selected_ce_goal_binder_sum']
        row = dict(case=case,retained_pid=summary['pid'],raw_Paxiom_keys=summary['context_Paxiom_keys'],
                   live_raw_protected_keys=len(protected),true_shape_protected_keys=len(true_rows),
                   physically_identical_raw_candidates=sum(r['raw_root_index']==r['candidate_root_index'] for r in protected),
                   protected_raw_and_candidate_saved_entries=0,
                   unresolved_keys=len(unresolved),unresolved_names=[r['name'] for r in unresolved],
                   prospective_fixed_input_prefix_Ident_upper=prospective,
                   input_current_postfill_seed_already_observed=(case=='input_is_valid'))
        rows.append(row)
        certificates[slug + '-certificate.json'] = encoded(dict(case=case,
            graph_input='docs/evidence/retained-why-preinline-prefix-20261020/' + slug + '-graph.json.gz',
            live_raw_protected=protected, true_shape_protected=true_rows,
            unresolved=unresolved, controls=controls))
    launch = read(ROOT / 'docs/evidence/retained-solver-launch-profile-20261020/result.json')
    for case, oldrow, newrow in zip(rows, old['cases'], launch['cases']):
        assert case['case'] == oldrow['case'] == newrow['case']
        assert oldrow['selected_goals'] == newrow['G']
        assert newrow['run_offers_upper'] == 3 * newrow['G']
    result = dict(scope='Fixed retained raw graphs; order-independent protected subset and precise parallel first-fill remainder',
        cases=rows,raw_keys=sum(r['raw_Paxiom_keys'] for r in rows),
        live_raw_protected_keys=sum(r['live_raw_protected_keys'] for r in rows),
        physically_identical_raw_candidates=sum(r['physically_identical_raw_candidates'] for r in rows),
        true_shape_protected_keys=sum(r['true_shape_protected_keys'] for r in rows),
        unresolved_keys=sum(r['unresolved_keys'] for r in rows),
        unresolved_formula_families=sorted({name for r in rows for name in r['unresolved_names']}),
        source_producer_inventory_complete_execution_or_shape_transfer=False,
        intended_parallel_stored_family_closed=False,
        prospective_parallel_episode_theorem_reused=True,
        intended_parallel_fixed_raw_input_and_initial_state_attachment_established=False,
        prospective_direct_component_under_same_three_driver_raw_input_attachment=sum(r['prospective_fixed_input_prefix_Ident_upper'] for r in rows),
        prospective_component_is_retained_postcut_charge=False,
        added_signal_escape_allowance=0,global_signal_escape_budget_per_process=2,
        global_save_callbacks_per_process=2,global_saves_per_process=3,
        complete_Ident_no_wrap=False,complete_pipeline_capacity=False,
        native_runs=0,predecessor_checker_replays=0,source_theorem_machine_checked=False)
    assert result['raw_keys'] == 675 and result['live_raw_protected_keys'] == 660
    assert result['true_shape_protected_keys'] == 2 and result['unresolved_keys'] == 13
    assert len(result['unresolved_formula_families']) == 4
    certificates['result.json'] = encoded(result)
    return certificates


def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--write', action='store_true')
    args = parser.parse_args(); start = time.monotonic()
    for name, data in calculate().items():
        if args.write: (HERE / name).write_bytes(data)
        else: assert (HERE / name).read_bytes() == data, name
    print(json.dumps(dict(status='pass',cases=5,elapsed_seconds=time.monotonic()-start,
                         native_runs=0,predecessor_checker_replays=0),indent=2))


if __name__ == '__main__': main()
