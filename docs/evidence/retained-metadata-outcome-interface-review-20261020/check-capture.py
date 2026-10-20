"""Independent archive/control and raw graph correspondence audit; no target."""
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


def digest(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def fields(blocks, pointer):
    row = blocks[pointer]
    return struct.unpack('<' + 'Q' * row['words'], bytes.fromhex(row['payload_hex']))


start = time.monotonic()
manifest = json.loads((AUTHOR / 'first-domain-manifest.json').read_text())
member_count = 0
for name, record in manifest.items():
    assert digest((AUTHOR / name).read_bytes()) == record['identity'], name
    with tarfile.open(AUTHOR / name) as archive:
        assert set(archive.getnames()) == set(record['members']), name
        for member, identity in record['members'].items():
            assert digest(archive.extractfile(member).read()) == identity, member
            member_count += 1

prefix = 'first_or_default/capture/'
with tarfile.open(AUTHOR / 'first-or-default-capture.tar.gz') as archive:
    def read(name):
        return json.load(archive.extractfile(prefix + name))
    summary = read('summary.json')
    plan = json.load(archive.extractfile('plan.json'))
    assert archive.extractfile('plan.json').read() == (AUTHOR / 'attempt-3-plan.json').read_bytes()
    for name in ('metadata.py', 'probe.py', 'run.py', 'inherited-session_observer.py'):
        assert archive.extractfile('collector/' + name).read() == (AUTHOR / 'collector' / name).read_bytes()
    assert summary['completed'] and summary['protected']
    assert not summary['failures'] and not summary['guard_hits'] and not summary['new_threads']
    assert summary['previous_endpoint_visits'] == 1
    assert len(summary['dispatch']['connection']) == 1
    assert len(summary['dispatch']['transform']) == len(summary['dispatch']['graft']) > 0
    assert set(summary['forbidden_calls']) == set(plan['forbidden_calls'])
    assert all(row['hits'] == 0 for row in summary['forbidden_calls'].values())
    process, server = read('process.json'), read('server.json')
    assert process['argv'] == plan['inputs'][0]['argv']
    assert server['argv'] == server['actual_argv'] == plan['inputs'][0]['server']['argv']
    assert server['environment'] == server['actual_environment']
    for argv in (process['argv'], server['argv']):
        assert argv[argv.index('-j') + 1] == '12'
    executable = process['argv'][0]
    specification = json.loads((AUTHOR / 'acquisition-spec.json').read_text())
    assert executable == specification['executable']
    assert summary['mapped_files'][executable] == plan['file_identities'][executable] == specification['executable_identity']
    assert server['binary'] == plan['server_identity']
    for row in summary['file_opens']:
        if row['fd'] >= 0 and row['flags'] & 3 == 0:
            assert row['identity'] == plan['file_identities'][row['resolved_path']]
    new_blocks = {row['address']: row for row in map(json.loads, archive.extractfile(prefix + 'session-blocks.jsonl'))}
    new_chains, new_tables = read('session-task-chains.json'), read('session-tables.json')
    new_bias = read('session-symbols.json')['load_bias']
    meta = read('metadata.json')
    selected = [row for row in meta['drivers'] if row.get('selected')]
    assert len(selected) == 1 and selected[0]['drv_thuse'] == 1
    assert len(selected[0]['metadata']) == 66
    assert len(meta['raw_task_histories']) == len(new_chains) == 33
    assert 'introduced_prsymbol' not in {row['name'] for row in meta['metas'].values()}
    assert not meta['initial_introduction_table_captured'] and not meta['full_Hsdecl_captured']
    with tempfile.TemporaryDirectory(prefix='.capture-scratch-', dir=HERE) as temporary:
        for member in archive.getmembers():
            if member.name.startswith(prefix):
                archive.extract(member, temporary, filter='data')
        replay_start = time.monotonic()
        replay = subprocess.run(['python3', '-B', str(AUTHOR / 'verify-capture.py'),
                                 str(Path(temporary) / prefix)], text=True, capture_output=True,
                                env={**os.environ, 'TMPDIR': temporary})
        (HERE / 'capture-replay.stdout').write_text(replay.stdout)
        (HERE / 'capture-replay.stderr').write_text(replay.stderr)
        assert replay.returncode == 0, replay.stderr
        replay_seconds = time.monotonic() - replay_start

old_archive = ROOT / 'docs/evidence/retained-why-save-state-capture-20261020/capture-first-or-default.tar.gz'
with tarfile.open(old_archive) as archive:
    prefix = 'registration/first_or_default/capture/'
    old_blocks = {row['address']: row for row in map(json.loads, archive.extractfile(prefix + 'session-blocks.jsonl'))}
    old_chains = json.load(archive.extractfile(prefix + 'session-task-chains.json'))
    old_tables = json.load(archive.extractfile(prefix + 'session-tables.json'))
    old_bias = json.load(archive.extractfile(prefix + 'session-symbols.json'))['load_bias']

# Check the frozen bijection as a relation, rather than regenerate it with the
# author's stack walk. Every field edge must commute with that relation.
relation = {int(k): v for k, v in json.loads(gzip.decompress((AUTHOR / 'first-domain-address-map.json.gz').read_bytes())).items()}
assert len(relation) == len(set(relation.values())) == 42481
immediate_edges = 0
for old_pointer, new_pointer in relation.items():
    before, after = old_blocks[old_pointer], new_blocks[new_pointer]
    assert (before['tag'], before['words']) == (after['tag'], after['words'])
    if before['tag'] < 246:
        for old, new in zip(fields(old_blocks, old_pointer), fields(new_blocks, new_pointer)):
            if old & 1:
                assert new == old
                immediate_edges += 1
            else:
                assert relation[old] == new
    elif before['tag'] == 255:
        left, right = fields(old_blocks, old_pointer), fields(new_blocks, new_pointer)
        assert left[0] - old_bias == right[0] - new_bias and left[1:] == right[1:]
    else:
        assert before['payload_hex'] == after['payload_hex']

old_tasks = {row['key']: row['value'] for row in old_tables['raw_tasks']['entries']}
new_tasks = {row['key']: row['value'] for row in new_tables['raw_tasks']['entries']}
assert old_tasks.keys() == new_tasks.keys()
declaration_pairs = set()
for key in old_tasks:
    old_chain, new_chain = old_chains[str(old_tasks[key])], new_chains[str(new_tasks[key])]
    assert len(old_chain) == len(new_chain)
    for before, after in zip(old_chain, new_chain):
        old_node, old_tag = fields(old_blocks, before['tdecl'])
        new_node, new_tag = fields(new_blocks, after['tdecl'])
        assert old_tag == new_tag
        assert old_blocks[old_node]['tag'] == new_blocks[new_node]['tag']
        if old_blocks[old_node]['tag'] == 0:
            old_decl, = fields(old_blocks, old_node)
            new_decl, = fields(new_blocks, new_node)
            assert relation[old_decl] == new_decl
            declaration_pairs.add((old_decl, new_decl))
assert len(declaration_pairs) == 334
assert immediate_edges == 48769

result = dict(status='pass', archive_members=member_count,
              source_byte_replay_seconds=replay_seconds,
              elapsed_seconds=time.monotonic() - start,
              raw_tasks=len(old_tasks), declaration_pairs=len(declaration_pairs),
              bijective_blocks=len(relation), equal_immediate_edges=immediate_edges,
              selected_driver_metadata_theories=66, decoded_meta_records=len(meta['metas']),
              protected_guard_hits=0, startup_guard_observations=len(summary['startup_guard_hits']),
              reviewer_native_runs=0, predecessor_checker_replays=0)
(HERE / 'capture-check-result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
