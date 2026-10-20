#!/usr/bin/env python3
"""Check retained identities and the proposed arithmetic interface, without execution.

The selected-prefix ownership argument and service contract require review;
this checker does not establish them by asserting their exported conclusions.
--audit-coverage optionally repeats the explicitly bounded historical read query.
"""
import argparse
import hashlib
import json
import time
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAPTURE = ROOT / 'docs/evidence/retained-why-save-state-capture-20261020'
LIMIT = 1 << 63


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def pipe_budget_guard(prefix, suffix):
    """Only the integer side condition, after the named semantic premises.

    These arguments are source-derived prospective byte bounds, never observed
    execution counts or C counters. A caller must supply the provenance join.
    """
    return (type(prefix) is int and type(suffix) is int
            and prefix >= 0 and suffix >= 0 and prefix + suffix <= LIMIT)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--audit-coverage', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    spec = json.loads((HERE / 'inputs.json').read_bytes())
    for name, expected in spec['imports'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    manifest_raw = (CAPTURE / 'capture-manifest.json').read_bytes()
    assert identity(manifest_raw)['sha256'] == '4404c4192a4bbfe373196185b6f8a9d7eb0ac16e9e51319e04a9dc0672603d0e'
    manifest = json.loads(manifest_raw)
    archives = {a['path']: a for a in manifest['archives']}
    for name, row in archives.items():
        assert identity((CAPTURE / name).read_bytes()) == {k: row[k] for k in ['bytes', 'sha256']}

    def member(tar, archive, name):
        raw = tar.extractfile(name).read()
        expected = next(r for r in archives[archive]['members'] if r['path'] == name)
        assert identity(raw) == {k: expected[k] for k in ['bytes', 'sha256']}
        return raw

    launchers = []
    with tarfile.open(CAPTURE / 'capture-common.tar.gz') as tar:
        for phase, first, last in [('registration', 53, 90), ('inline', 54, 91)]:
            name = phase + '/run.py'
            raw = member(tar, 'capture-common.tar.gz', name)
            body = raw.decode()
            assert 'stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True' in body
            assert 'set startup-with-shell off' in body
            assert 'inferior-tty' not in body
            launchers.append(dict(member=name, identity=identity(raw), first=first, last=last,
                                  text=''.join(body.splitlines(keepends=True)[first - 1:last])))

    sources = []
    for family, archive, prefix in [
        ('why3', 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz', 'why3/'),
        ('ocaml', 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz',
         'ocaml-8eb41f72ded84df884c3671734c947f612091f84/')]:
        with tarfile.open(ROOT / archive) as tar:
            for selected, rel, first, last in spec['source_ranges']:
                if selected != family:
                    continue
                raw = tar.extractfile(prefix + rel).read()
                sources.append(dict(archive=archive, member=prefix + rel, identity=identity(raw),
                                    first=first, last=last,
                                    text=''.join(raw.decode().splitlines(keepends=True)[first - 1:last])))
    combined_sources = '\n'.join(r['text'] for r in sources)
    for anchor in spec['required_source_anchors']:
        assert anchor in combined_sources, anchor

    native_path = 'docs/evidence/retained-why-channel-exit-bound-20261020/native-bodies.json'
    native = json.loads((ROOT / native_path).read_bytes())['camlStdlib__entry']
    for text in ['# f4c598 <camlStdlib>', '0x130(%rbx)', '0x138(%rbx)',
                 '# 9cf1a0 <caml_ml_open_descriptor_out>']:
        assert text in native, text
    native_ref = dict(provider=native_path, symbol='camlStdlib__entry', identity=identity(native.encode()),
                      global_elf_address=0xf4c598, slots={'stdout': 0x130, 'stderr': 0x138})

    profiles = json.loads((ROOT / 'docs/evidence/retained-why-standard-formatter-control-20261020/initial-inputs.json').read_bytes())
    initial = json.loads((ROOT / 'docs/evidence/retained-why-standard-initial-state-20261020/result.json').read_bytes())
    assert initial['source_composition']['constructor_dynamic_state_preserved_at_all_five_cuts']
    coverage = json.loads((HERE / 'coverage.json').read_bytes())
    assert not coverage['partial_read_stitching_checked']
    joined = []
    for (name, pid), profile, cov in zip(spec['cases'], profiles, coverage['cases'], strict=True):
        assert name == profile['case'] == cov['case'] and pid == profile['pid'] == cov['pid']
        archive = profile['archive']
        assert archive == cov['archive']
        phase = 'inline' if name == 'input_is_valid' else 'registration'
        with tarfile.open(CAPTURE / archive) as tar:
            process_name = f'{phase}/{name}/capture/process.json'
            process = json.loads(member(tar, archive, process_name))
            assert process == profile['process']
            assert '--logging' not in process['argv'] and 'GNATWHY3LOG' not in process['environment']
            assert process['initial_threads'] == 1
            probe_name = f'{phase}/{name}/capture/probe.gdb'
            probe = member(tar, archive, probe_name).decode()
            assert 'set startup-with-shell off' in probe and 'inferior-tty' not in probe
            if args.audit_coverage:
                counts = 0
                hits = {k: [] for k in ['stdout', 'stderr']}
                for row in archives[archive]['members']:
                    if not row['path'].endswith('memory-reads.jsonl'):
                        continue
                    for index, line in enumerate(tar.extractfile(row['path']), 1):
                        read = json.loads(line)
                        counts += 1
                        for channel, slot in cov['slots'].items():
                            if read['address'] <= slot['address'] and slot['address'] + 8 <= read['address'] + read['bytes']:
                                hits[channel].append(dict(member=row['path'], line=index))
                assert counts == cov['rows'] and hits == {k: [] for k in hits}
        channels = {}
        for channel, offset in [('stdout', 0x130), ('stderr', 0x138)]:
            assert cov['slots'][channel] == dict(address=profile['load_bias'] + 0xf4c598 + offset,
                                               whole_word_read_hits=[])
            channels[channel] = dict(
                slot_address=cov['slots'][channel]['address'], observed_root_pointer=None,
                observed_native_record=None, observed_P0=None, observed_O0=None,
                source_derived_P0=0, source_derived_O0='constructor lseek result q',
                actual_constructor_q=None, conditional_root_and_buffer_ownership=True,
                actual_fd_kind=None, actual_fd_live=None, actual_fd_aliases=None,
                actual_fd_binding_preserved=None, positive_write_service_attached=False,
                X_pre_source_at_this_controlled_cut=0, X_suffix=None,
                actual_offset_guard=None, usable_standard_channel_bound=None)
        joined.append(dict(case=name, pid=pid, process_member=process_name, channels=channels))

    boundary_cases = [(0, 0, True), (0, LIMIT, True), (1, LIMIT - 1, True),
                      (65536, LIMIT - 65536, True), (LIMIT, 0, True),
                      (0, LIMIT + 1, False), (1, LIMIT, False),
                      (-1, 0, False), (0, -1, False), (None, 0, False),
                      (0, None, False), (True, 0, False), (0, '1', False)]
    for prefix, suffix, expected in boundary_cases:
        assert pipe_budget_guard(prefix, suffix) is expected
    # The debt transfer implies the guard; sample only its integer boundaries.
    transfer_checks = 0
    for prefix in [0, 1, 65536, LIMIT - 1, LIMIT]:
        for pending in {0, min(prefix, 65536)}:
            committed = prefix - pending
            offset = -1 + committed
            suffix = LIMIT - prefix
            assert -(1 << 63) <= offset <= LIMIT - 1
            assert offset + pending + suffix == LIMIT - 1
            transfer_checks += 1
    result = dict(
        scope='Conditional source entry-state attachment plus proposed pre-admission launcher interface',
        cases=joined, source_prefix_argument_proved_by_checker=False,
        selected_controlled_prefix_X_pre=0,
        source_entry='P0=0; O0=q; retained distinct rooted output-channel records under named source/native relation',
        launcher_recipe_observed='GDB stdout PIPE; stderr STDOUT; target descriptor inheritance unobserved',
        raw_complete_slot_read_rows=sum(c['rows'] for c in coverage['cases']),
        raw_complete_slot_hits=0, partial_read_stitching_checked=False,
        prospective_pipe_constructor_q=-1,
        prospective_guard='X_pre + X_suffix <= 2^63 for each channel',
        actual_inherited_descriptor_service_attached=False,
        universal_pre_admission_prefix_attached=False,
        post_execution_certificate_is_pre_admission_rule=False,
        production_launcher_implemented=False, full_GDB_refinement=False,
        kernel_service_implementation_proved=False, private_save_file_premise_extended=False,
        global_budget_reset=False, maximum_suffix_save_callbacks=2, maximum_suffix_saves=3,
        maximum_suffix_escaping_save_exceptions=2, complete_R=False, complete_U=False,
        complete_exit_capacity=False, physical_capacity=False, native_stack_capacity=False,
        issue_119_complete=False, issue_153_complete=False,
        tests=dict(integer_guard_cases=len(boundary_cases), transfer_boundary_cases=transfer_checks),
        executions=dict(target=0, capture=0, debugger=0, disassembler=0, solver=0, proof_suite=0,
                        predecessor_checkers=0, source_fetch=0))
    for name, value in [('source-witnesses.json', sources), ('launcher-witnesses.json', launchers),
                        ('native-reference.json', native_ref), ('result.json', result)]:
        if args.write:
            (HERE / name).write_bytes(encode(value))
        else:
            assert json.loads((HERE / name).read_bytes()) == value, name
    print(json.dumps(dict(status='pass', seconds=time.monotonic() - start,
                          inputs=len(spec['imports']), archives=len(archives),
                          source_slices=len(sources), cases=len(joined), tests=result['tests'],
                          raw_coverage_replayed=args.audit_coverage)))


if __name__ == '__main__':
    main()
