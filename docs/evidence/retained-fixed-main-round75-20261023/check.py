"""Bind accepted R75 freezes and receipts without component replay."""
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def bind(items):
    for path, expected in items.items():
        assert identity((ROOT/path).read_bytes()) == expected, path


def check():
    inputs = read(HERE/'inputs.json')
    components = inputs['components']
    frozen = {}
    for component in components.values():
        for path in component['paths']:
            data = (ROOT/path).read_bytes()
            assert data == subprocess.check_output(['git','show',component['freeze']+':'+path], cwd=ROOT), path
            frozen[path] = identity(data)

    review_rows = {}
    for name, packet in [('memo','retained-preparation-private-memos-review-20261023'),
                         ('composition','retained-fixed-domain-composition-review-20261023'),
                         ('main','retained-main-construction-review-20261023')]:
        row = read(EV/packet/'audit-result.json')
        manifest = read(EV/packet/'inputs.json')
        assert row['status'] == 'pass'
        assert row['author_commit'] == manifest['author_commit'] == components[name+'_author']['freeze']
        bind(manifest['author_files'])
        review_rows[name] = row

    bind(read(EV/'retained-preparation-private-memos-20261023/inputs.json')['providers'])
    for row in read(EV/'retained-main-construction-profile-20261023/identity.json')['providers']:
        assert hashlib.sha256((ROOT/row['path']).read_bytes()).hexdigest() == row['sha256'], row['path']
    composition_inputs = read(EV/'retained-fixed-domain-composition-20261023/inputs.json')
    # These are exact historical provider inputs. Current status records may
    # advance in this integration; their old bytes remain in the author freeze.
    for path, expected in composition_inputs['providers'].items():
        data = subprocess.check_output(['git','show',components['composition_author']['freeze']+':'+path], cwd=ROOT)
        assert identity(data) == expected, path
        if path != 'docs/research/retained-tool-capacity.md':
            assert (ROOT/path).read_bytes() == data, path
    bind(composition_inputs['preparation_private_memos']['files'])
    composition = read(EV/'retained-fixed-domain-composition-20261023/result.json')
    assert composition['guarded_fixed_Why_conjunction_established']
    assert composition['successful_controlled_startup_scope']
    for key in ('unconditional_whole_process_capacity','arbitrary_pre_cut_failure_prefixes_covered',
                'arbitrary_Main_covered','GNATCOLL_and_final_spark_consumers_covered',
                'production_launcher_adapter_refinement_established','exceptional_allowance_renewed'):
        assert not composition[key], key
    assert composition['server_retained_tau_constant'] == 726339
    assert composition['server_symbolic_tau_constant'] == 699393
    assert (composition['global_exception_allowance'],composition['global_save_callbacks'],composition['global_saves']) == (2,2,3)
    assert review_rows['memo']['memo_applications'] == 25
    assert not review_rows['memo']['whole_fixed_domain_complete']
    assert not review_rows['memo']['whole_capacity_rule_complete']
    assert review_rows['main']['signatures'] == 43 and review_rows['main']['conversion_cases'] == 84
    assert not review_rows['main']['Main_U_H_complete'] and not review_rows['main']['issue178_complete']
    comp_review = EV/'retained-fixed-domain-composition-review-20261023'
    assert identity((comp_review/'audit.py').read_bytes()) == review_rows['composition']['audit_code']
    assert identity((comp_review/'inputs.json').read_bytes()) == review_rows['composition']['inputs']

    pins = read(EV/'retained-literal-native-completion-20261019/inputs.json')
    for row in pins['repository']:
        bind({row['path']:{k:row[k] for k in ('bytes','sha256')}})
    binary = read(EV/'retained-printer-entry-collision-review-20261020/native-byte-join.json')
    assert identity(Path(binary['installed_binary']).read_bytes()) == binary['installed_identity']
    return dict(status='pass', frozen_files=frozen,
                private_memo_interfaces_attached=True, successful_startup_fixed_Why_continuation_attached=True,
                Main_restricted_construction_and_primitive_contracts_attached=True,
                arbitrary_Main_U_H_complete=False, pre_cut_failure_capacity_complete=False,
                issue153_complete=False, issue178_complete=False, whole_capacity_rule_complete=False,
                native_source_pins_unchanged=len(pins['repository']), installed_why_unchanged=True,
                component_checker_replays=0, native_runs=0, production_implemented=False,
                global_exception_allowance_renewed=False, aggregate_RAM_or_stack_gate=False)


if __name__ == '__main__':
    start = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter()-start
    (HERE/'integration-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k != 'frozen_files'}))
