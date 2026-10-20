"""Four new offline capture audits; accepted First evidence is not replayed."""
import gzip
import hashlib
import json
import os
import struct
import subprocess
import tarfile
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = ROOT / 'docs/evidence/retained-why-parallel-residual-transfer-20261020'


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def fields(blocks, pointer):
    row = blocks[pointer]
    return struct.unpack('<' + 'Q' * row['words'], bytes.fromhex(row['payload_hex']))


def read_capture(archive, prefix):
    def read(name):
        return json.load(archive.extractfile(prefix + name))
    blocks = {row['address']: row for row in map(json.loads, archive.extractfile(prefix + 'session-blocks.jsonl'))}
    symbol_file = prefix + 'session-symbols.json'
    bias = json.load(archive.extractfile(symbol_file))['load_bias'] if symbol_file in archive.getnames() else None
    return blocks, read('session-task-chains.json'), read('session-tables.json'), bias


def check_case(case):
    start = time.monotonic()
    slug = case.replace('_', '-')
    expected = json.loads((AUTHOR / (slug + '-correspondence.json')).read_text())
    with tarfile.open(AUTHOR / (slug + '-capture.tar.gz')) as archive:
        prefix = case + '/capture/'
        def read(name):
            return json.load(archive.extractfile(prefix + name))
        plan = json.load(archive.extractfile('plan.json'))
        case_plan = next(row for row in plan['inputs'] if row['name'] == case)
        for name in ('metadata.py', 'probe.py', 'run.py', 'inherited-session_observer.py'):
            assert archive.extractfile('collector/' + name).read() == (AUTHOR / 'collector' / name).read_bytes()
        summary, process, server = read('summary.json'), read('process.json'), read('server.json')
        assert summary['completed'] and summary['protected']
        assert not summary['failures'] and not summary['guard_hits'] and not summary['new_threads']
        assert summary['previous_endpoint_visits'] == 1
        assert len(summary['dispatch']['connection']) == 1
        assert len(summary['dispatch']['transform']) == len(summary['dispatch']['graft']) > 0
        assert set(summary['forbidden_calls']) == set(plan['forbidden_calls'])
        assert all(row['hits'] == 0 for row in summary['forbidden_calls'].values())
        assert process['argv'] == case_plan['argv'] and process['environment'] == case_plan['environment']
        assert server['argv'] == server['actual_argv'] == case_plan['server']['argv']
        assert server['environment'] == server['actual_environment'] == case_plan['server']['environment']
        for argv in (process['argv'], server['argv']):
            assert argv[argv.index('-j') + 1] == '12'
        assert summary['mapped_files'][process['argv'][0]] == plan['file_identities'][process['argv'][0]]
        assert server['binary'] == plan['server_identity']
        for row in summary['file_opens']:
            if row['fd'] >= 0 and row['flags'] & 3 == 0:
                assert row['identity'] == plan['file_identities'][row['resolved_path']]
        new_blocks, new_chains, new_tables, new_bias = read_capture(archive, prefix)
        meta = read('metadata.json')
        selected = [row for row in meta['drivers'] if row.get('selected')]
        assert len(selected) == 1 and selected[0]['drv_thuse'] == 1
        assert not meta['full_Hsdecl_captured'] and not meta['initial_introduction_table_captured']
        assert 'introduced_prsymbol' not in {row['name'] for row in meta['metas'].values()}
        with tempfile.TemporaryDirectory(prefix='.remaining-scratch-', dir=HERE) as temporary:
            for member in archive.getmembers():
                if member.name.startswith(prefix):
                    archive.extract(member, temporary, filter='data')
            run = subprocess.run(['python3', '-B', str(AUTHOR / 'verify-capture.py'),
                                  str(Path(temporary) / prefix)], text=True, capture_output=True,
                                 env={**os.environ, 'TMPDIR': temporary})
            (HERE / (slug + '-replay.stdout')).write_text(run.stdout)
            (HERE / (slug + '-replay.stderr')).write_text(run.stderr)
            assert run.returncode == 0, run.stderr
            replay = json.loads(run.stdout)

    with tarfile.open(ROOT / 'docs/evidence/retained-why-save-state-capture-20261020' / ('capture-' + slug + '.tar.gz')) as archive:
        prefix = ('inline/' if case == 'input_is_valid' else 'registration/') + case + '/capture/'
        old_blocks, old_chains, old_tables, old_bias = read_capture(archive, prefix)
    relation = {int(k): v for k, v in json.loads(gzip.decompress((AUTHOR / (slug + '-correspondence.map.json.gz')).read_bytes())).items()}
    assert len(relation) == len(set(relation.values())) == expected['events']['blocks']
    immediates = custom = 0
    for old_pointer, new_pointer in relation.items():
        before, after = old_blocks[old_pointer], new_blocks[new_pointer]
        assert (before['tag'], before['words']) == (after['tag'], after['words'])
        if before['tag'] < 246:
            for old, new in zip(fields(old_blocks, old_pointer), fields(new_blocks, new_pointer)):
                if old & 1:
                    assert new == old
                    immediates += 1
                else:
                    assert relation[old] == new
        elif before['tag'] == 255:
            assert old_bias is not None and new_bias is not None
            left, right = fields(old_blocks, old_pointer), fields(new_blocks, new_pointer)
            assert left[0] - old_bias == right[0] - new_bias and left[1:] == right[1:]
            custom += 1
        else:
            assert before['payload_hex'] == after['payload_hex']
    assert immediates == expected['events']['immediates']
    assert custom == expected['events'].get('custom_ops_load_bias_joins', 0)
    old_tasks = {row['key']: row['value'] for row in old_tables['raw_tasks']['entries']}
    new_tasks = {row['key']: row['value'] for row in new_tables['raw_tasks']['entries']}
    assert old_tasks.keys() == new_tasks.keys() and len(old_tasks) == expected['raw_tasks']
    pairs = set()
    for key in old_tasks:
        before, after = old_chains[str(old_tasks[key])], new_chains[str(new_tasks[key])]
        assert len(before) == len(after)
        for left, right in zip(before, after):
            old_node, old_tag = fields(old_blocks, left['tdecl'])
            new_node, new_tag = fields(new_blocks, right['tdecl'])
            assert old_tag == new_tag and old_blocks[old_node]['tag'] == new_blocks[new_node]['tag']
            if old_blocks[old_node]['tag'] == 0:
                old_decl, = fields(old_blocks, old_node)
                new_decl, = fields(new_blocks, new_node)
                assert relation[old_decl] == new_decl
                pairs.add((old_decl, new_decl))
    assert len(pairs) == expected['declaration_pairs']
    return dict(case=case, status='pass', elapsed_seconds=time.monotonic() - start,
                reader_replay=replay, raw_tasks=len(old_tasks), declaration_pairs=len(pairs),
                bijective_blocks=len(relation), equal_immediates=immediates, custom_blocks=custom,
                old_load_bias_present=old_bias is not None,
                metadata_theories=len(selected[0]['metadata']), startup_guard_observations=len(summary['startup_guard_hits']))


start = time.monotonic()
manifest = json.loads((AUTHOR / 'remaining-manifest.json').read_text())
members = 0
for name, record in manifest.items():
    assert identity((AUTHOR / name).read_bytes()) == record['identity']
    with tarfile.open(AUTHOR / name) as archive:
        assert set(archive.getnames()) == set(record['members'])
        for name, expected in record['members'].items():
            assert identity(archive.extractfile(name).read()) == expected
            members += 1
post = json.loads((AUTHOR / 'remaining-post-identities.json').read_text())
for workspace, records in post.items():
    plan_name = 'remaining-plan.json' if workspace.startswith('/tmp/') else 'tail-plan.json'
    plan = json.loads((AUTHOR / plan_name).read_text())
    assert records.keys() == plan['file_identities'].keys()
    for name, record in records.items():
        assert record['expected'] == record['actual'] == plan['file_identities'][name]
rows = []
for case in ('input_is_valid', 'put_line', 'put', 'is_message'):
    row = check_case(case)
    rows.append(row)
    print(json.dumps(row), flush=True)
result = dict(status='pass', archive_members=members, cases=rows,
              elapsed_seconds=time.monotonic() - start,
              reviewer_native_runs=0, predecessor_replays=0, first_domain_replayed=False)
(HERE / 'remaining-check-result.json').write_text(json.dumps(result, indent=2) + '\n')
