#!/usr/bin/env python3
"""Reconcile frozen R55 evidence without replaying component checks."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads((ROOT / path).read_text())


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def check():
    manifest = json.loads((HERE / "inputs.json").read_text())
    assert not manifest["review_freeze_pending"]
    assert "review" in manifest["components"]
    frozen, retained = [], {}
    for component, row in manifest["components"].items():
        for name in row["paths"]:
            expected = identity(git("show", f"{row['freeze']}:{name}"))
            assert identity((ROOT / name).read_bytes()) == expected, name
            frozen.append(dict(component=component, path=name, **expected))

    def collect(value):
        if isinstance(value, list):
            for item in value:
                collect(item)
        elif isinstance(value, dict):
            for name, item in value.items():
                if (name.startswith("docs/") and ":" not in name
                        and isinstance(item, str) and re.fullmatch(r"[0-9a-f]{64}", item)):
                    expected = identity((ROOT / name).read_bytes())
                    assert expected["sha256"] == item, name
                    assert name not in retained or retained[name] == expected, name
                    retained[name] = expected
                if (name.startswith("docs/") and ":" not in name
                        and isinstance(item, dict)
                        and "bytes" in item and "sha256" in item):
                    expected = {k: item[k] for k in ("bytes", "sha256")}
                    assert name not in retained or retained[name] == expected, name
                    retained[name] = expected
                collect(item)
            name = value.get("path", "")
            item = value.get("identity", value)
            if (name.startswith("docs/") and ":" not in name
                    and "bytes" in item and "sha256" in item):
                expected = {k: item[k] for k in ("bytes", "sha256")}
                assert name not in retained or retained[name] == expected, name
                retained[name] = expected

    for name in manifest["component_manifests"]:
        contents = read(name)
        collect(contents)
        for group in ('local_files', 'local', 'packet_files'):
            for relative, expected in contents.get(group, {}).items():
                path = Path(name).parent / relative
                actual = identity((ROOT / path).read_bytes())
                if isinstance(expected, str):
                    assert actual['sha256'] == expected, str(path)
                else:
                    assert actual == expected, str(path)
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    native = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in native["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]

    state = read("docs/evidence/retained-why-parallel-state-attachment-20261020/result.json")
    assert state['claims']['conditional_guarded_family_induction']
    assert not state['claims']['default_parallel_mutable_state_closed']
    assert not state['claims']['observed_corrupt_fixed_domain_execution']
    assert not state['claims']['unmasked_combined_cache_recovery_proved']
    assert not state['claims']['masked_launch_adopted']
    assert state['global_allowance']['save_callbacks'] == 2
    assert state['global_allowance']['saves'] == 3
    assert state['global_allowance']['e_max'] == 2
    storage = read("docs/evidence/retained-adapter-protocol-storage-20261020/result.json")
    assert storage['total_attempts_upper'] == storage['control_connections_upper'] == 459
    assert storage['response_records_upper'] == 918
    assert storage['ring_old_new_backing_bytes_J12'] == 41536
    assert storage['complete_q'] is None and not storage['full_capacity_rule']
    logging = read("docs/evidence/retained-parallel-logging-prefix-20261020/check-result.json")
    assert logging['status'] == 'pass' and logging['counted_checks'] == 1054
    review = read("docs/evidence/retained-parallel-state-storage-review-20261020/round.json")
    assert all(r['status'] == 'pass' and r['runs_by_reviewer'] == 1
               for r in review['checks'].values())
    installed = read("docs/evidence/retained-why-parallel-state-attachment-20261020/native-witnesses.json")['binary']
    assert identity(Path(installed['path']).read_bytes()) == installed['identity']
    log_native = read("docs/evidence/retained-parallel-logging-prefix-20261020/installed-byte-witnesses.json")
    assert log_native['binary_path'] == installed['path']
    assert log_native['binary_bytes'] == installed['identity']['bytes']
    assert log_native['binary_sha256'] == installed['identity']['sha256']
    parsed, links = [], []
    for name in sorted({row["path"] for row in frozen} | {str(Path(__file__).relative_to(ROOT))}):
        path = ROOT / name
        if path.suffix == ".py":
            ast.parse(path.read_text(), filename=name)
            parsed.append(name)
        if path.suffix == ".md":
            for url in re.findall(r"\]\(([^)]+)\)", path.read_text()):
                if "://" in url or url.startswith("#"):
                    continue
                target = url.split("#")[0]
                assert (path.parent / target).exists(), (name, target)
                links.append(dict(file=name, target=target))
    return dict(frozen_files=frozen, retained_inputs=retained,
        native_pins_unchanged=len(native['repository']), installed_why_binary_unchanged=True,
        conditional_guarded_parallel_family=True, default_unmasked_recovery_proved=False,
        logging_prefix_scope='original R53 J12 inputs plus one --logging flag under exact path/service/callback guards',
        quiet_timeless_parallel_logging_combination_attached=False,
        prospective_mask_design_selected=True, actual_supervisor_launch_attached=False,
        process_group_creation_race_cleanup_proved=False,
        protocol_attempts_upper=459, response_records_upper=918,
        ring_backing_bytes_at_J12=41536, whole_server_storage_bounded=False,
        complete_q=None, whole_capacity_rule_delivered=False,
        global_save_callbacks_per_process=2, global_saves_per_process=3,
        global_signal_escape_budget_per_process=2, added_signal_allowance=0,
        component_checker_replays=0, integration_native_solver_compiler_proof_capture_runs=0,
        production_configuration_changed=False, production_adapter_adopted=False,
        python_parses=parsed, local_links=links)


if __name__ == '__main__':
    start=time.monotonic();result=check();output=HERE/'integration-result.json'
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(status='pass', frozen_files=len(result['frozen_files']),
        retained_inputs=len(result['retained_inputs']),native_pins_unchanged=result['native_pins_unchanged'],
        python_parses=len(result['python_parses']),local_links=len(result['local_links']),
        elapsed_seconds=time.monotonic()-start)))
