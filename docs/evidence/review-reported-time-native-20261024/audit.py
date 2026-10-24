"""Independent identity and persistent triplet-failure audit; no target runs."""
from collections import deque
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = ROOT / 'docs/evidence/retained-reported-time-native-20261024'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_text())


def invocation(mask, spent, owners, budget, index=0):
    """Conservative grep chain: a damaged owner may fail forever for free.

    A healthy owner either succeeds, or one new external event interrupts it.
    The latter may leave it healthy or permanently damaged. This also covers
    an event after search but before the returned Some: it need not poison.
    The event budget is process-wide and persists across invocations.
    """
    if index == len(owners):
        yield mask, spent, 'fallback', index
        return
    bit = 1 << owners[index]
    if mask & bit:
        yield from invocation(mask, spent, owners, budget, index+1)
    else:
        yield mask, spent, 'zero', index+1
        if spent < budget:
            for next_mask in (mask, mask | bit):
                yield from invocation(next_mask, spent+1, owners, budget, index+1)


def check_triplets():
    seen = {(0, 0)}
    todo = deque(seen)
    transitions = 0
    maximum_attempts = 0
    while todo:
        mask, spent = todo.popleft()
        assert mask.bit_count() <= spent <= 2
        for group in ((0, 1, 2), (3, 4, 5), (6, 7, 8)):
            for new_mask, new_spent, outcome, attempts in invocation(mask, spent, group, 2):
                transitions += 1
                maximum_attempts = max(maximum_attempts, attempts)
                assert outcome == 'zero'
                assert new_mask | mask == new_mask and new_spent >= spent
                state = new_mask, new_spent
                if state not in seen:
                    seen.add(state)
                    todo.append(state)
    # Discriminating checks: neither one regexp nor a third global event has
    # the accepted guarantee. Poisoning two owners persists across calls.
    assert any(r[2] == 'fallback' for r in invocation(0, 0, (0,), 1))
    assert any(r[2] == 'fallback' for r in invocation(0, 0, (0, 1, 2), 3))
    assert all(r[2] == 'zero' and r[3] == 3
               for r in invocation(0b11, 2, (0, 1, 2), 2))
    assert maximum_attempts == 3
    return dict(persistent_process_states=len(seen), transitions=transitions,
                maximum_attempts=maximum_attempts, negative_controls=2)


def main():
    started = time.perf_counter()
    freeze = sys.argv[1]
    paths = subprocess.check_output([
        'git', 'ls-tree', '-r', '--name-only', freeze, '--',
        'docs/evidence/retained-reported-time-native-20261024',
        'docs/research/retained-reported-time-native.md'], cwd=ROOT, text=True).splitlines()
    frozen = {}
    for path in paths:
        expected = subprocess.check_output(['git', 'show', f'{freeze}:{path}'], cwd=ROOT)
        actual = (ROOT / path).read_bytes()
        assert actual == expected, path
        frozen[path] = sha(actual)
    inputs = read(AUTHOR / 'inputs.json')
    for path, row in inputs['files'].items():
        data = (ROOT / path).read_bytes()
        assert len(data) == row['bytes'] and sha(data) == row['sha256'], path

    # The generic reader is an accepted provider, not an evidence checker.
    sys.path.insert(0, str(ROOT / 'docs/evidence/retained-why-library-probe-paths-20261023'))
    from elf_reader import Elf
    new = read(AUTHOR / 'native-supplement.json')
    binary = Path(new['target']).read_bytes()
    assert len(binary) == new['target_identity']['bytes']
    assert sha(binary) == new['target_identity']['sha256']
    elf = Elf(binary)
    old_dir = ROOT / 'docs/evidence/retained-re-native-correspondence-20261023'
    old = read(old_dir / 'native.json')
    assert old['target_identity'] == new['target_identity']
    count = 0
    for packet, directory, names in (
        (old, old_dir, inputs['reused_functions']),
        (new, AUTHOR, sorted(new['functions'])),
    ):
        for name in names:
            row = packet['functions'][name]
            code = elf.function(name)
            assert code.hex() == row['hex'] and sha(code) == row['identity']['sha256'], name
            text = (directory / row['disassembly']).read_bytes()
            assert sha(text) == row['disassembly_identity']['sha256'], name
            count += 1
    triplets = check_triplets()
    placeholder = read(AUTHOR / 'placeholder/inputs.json')
    for path, row in placeholder['files'].items():
        data = (ROOT / path).read_bytes()
        assert len(data) == row['bytes'] and sha(data) == row['sha256'], path
    placeholder_bodies = 0
    for packet_path, names in placeholder['native_selections'].items():
        path = ROOT / packet_path
        packet = read(path)
        assert packet['target_identity'] == new['target_identity']
        for name in names:
            row = packet['functions'][name]
            code = elf.function(name)
            assert code.hex() == row['hex'] and sha(code) == row['identity']['sha256'], name
            assert sha((path.parent / row['disassembly']).read_bytes()) == row['disassembly_identity']['sha256'], name
            placeholder_bodies += 1
    for witness in placeholder['witnesses'] + inputs['instruction_witnesses']:
        raw = bytes.fromhex(witness['hex'])
        assert elf.at(witness['address'], len(raw)) == raw
        assert witness['line'] in (ROOT / witness['file']).read_text()
    # Independent set partition from membership signatures, rather than
    # copying the author's endpoint/flatten implementation.
    signatures = [(True, x == 37, x != 10) for x in range(256)]
    runs = []
    for byte, signature in enumerate(signatures):
        if not runs or signature != runs[-1][2]:
            runs.append([byte, byte, signature])
        else:
            runs[-1][1] = byte
    assert [(lo, hi) for lo, hi, _ in runs] == [(0,9),(10,10),(11,36),(37,37),(38,255)]
    assert all(38 <= byte <= 255 and byte != 37 for byte in bytes.fromhex('5c3d'))
    offset_chain = 5 + 5 + 3 + 2
    wrappers = 5 + 2 + 8 + 2 + offset_chain
    assert offset_chain == 15 and wrappers == 32
    assert 31 + 128 + 23 + wrappers == 214 < 256
    assert 128 + 2048 + 3*512 + 128 == 3840 < 4096
    assert 9*4096 == 36864
    assert all(sha((ROOT / p).read_bytes()) == h for p, h in frozen.items())
    result = dict(status='pass', reviewed_commit=freeze, frozen_files=frozen,
                  fixed_input_files=len(inputs['files']), native_bodies=count,
                  placeholder_input_files=len(placeholder['files']),
                  placeholder_native_bodies=placeholder_bodies,
                  instruction_witnesses=len(inputs['instruction_witnesses'])+len(placeholder['witnesses']),
                  issue208_repair_verified=True,
                  target_sha256=sha(binary), triplet_induction_model=triplets,
                  author_or_predecessor_checker_replays=0, target_executions=0,
                  audit_sha256=sha(Path(__file__).read_bytes()),
                  elapsed_seconds=time.perf_counter()-started)
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k != 'frozen_files'}, indent=2))


if __name__ == '__main__':
    main()
