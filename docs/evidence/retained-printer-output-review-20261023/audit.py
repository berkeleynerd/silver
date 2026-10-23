"""Independent finite source/identity/arithmetic audit of a frozen output packet.

No author or predecessor Python is imported/executed. The small Format model
is reviewer-written supporting evidence, not a universal source proof.
"""
import argparse
from collections import deque
import hashlib
import io
import itertools
import json
import gzip
from pathlib import Path
import platform
import re
import subprocess
import tarfile
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
PREFIX = 'docs/evidence/retained-why-printer-output-20261023/'
PINF = 1000000010
MAX_INT = 2**62-1
MAX_STRING = 2**57-9


def identity(b):
    return dict(bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


class Core:
    """Selected completed Format operations, storing lengths instead of bytes."""
    def __init__(self):
        self.reset()
        self.offered = 0

    def reset(self):
        self.left = self.right = self.depth = 1
        self.space, self.indent, self.newline = 78, 0, True
        self.queue = deque()
        self.formats = []
        sentinel = dict(kind='sentinel', size=-1, length=0)
        system = dict(kind='begin', size=-1, length=0, offset=0, box='hov')
        self.queue.append(system)
        self.scan = [(-1, sentinel), (1, system)]

    def enqueue(self, t):
        self.right += t['length']
        self.queue.append(t)

    def set_size(self, is_break):
        if not self.scan:
            return
        saved, t = self.scan[-1]
        if saved < self.left:
            self.scan = [(-1, dict(kind='sentinel', size=-1, length=0))]
        elif (t['kind'] == 'break' and is_break) or (t['kind'] == 'begin' and not is_break):
            t['size'] += self.right
            self.scan.pop()

    def line(self, width):
        self.indent = min(68, 78-width)
        assert 0 <= self.indent <= 68
        self.space = 78-self.indent
        self.offered += 1+self.indent
        self.newline = True

    def format(self, t, size):
        kind = t['kind']
        if kind == 'text':
            self.space -= size
            self.offered += t['length']
            self.newline = False
        elif kind == 'begin':
            if 78-self.space > 68 and self.formats:
                box, width = self.formats[-1]
                if width > self.space and box not in ('fits', 'h'):
                    self.line(width)
            width = self.space-t['offset']
            box = t['box'] if t['box'] == 'v' or size > self.space else 'fits'
            self.formats.append((box, width))
        elif kind == 'end':
            if self.formats:
                self.formats.pop()
        elif kind == 'newline':
            if self.formats:
                self.line(self.formats[-1][1])
            else:
                self.offered += 1
        elif kind == 'break':
            if self.formats:
                box, width = self.formats[-1]
                split = box in ('v', 'hv') or box == 'hov' and size > self.space
                if box == 'box':
                    split = not self.newline and (size > self.space or self.indent > 78-width)
                if split:
                    self.line(width)
                else:
                    self.space -= t['length']
                    self.offered += t['length']
        else:
            raise AssertionError(kind)

    def advance(self):
        while self.queue:
            t = self.queue[0]
            known = t['size'] >= 0
            if not (known or self.right-self.left >= self.space):
                return
            self.queue.popleft()
            self.format(t, t['size'] if known else PINF)
            self.left += t['length']

    def text(self, n):
        self.enqueue(dict(kind='text', size=n, length=n))
        self.advance()

    def open(self, offset=0, box='hov'):
        self.depth += 1
        t = dict(kind='begin', size=-self.right, length=0, offset=offset, box=box)
        self.enqueue(t)
        self.scan.append((self.right, t))

    def close(self):
        if self.depth > 1:
            self.enqueue(dict(kind='end', size=0, length=0))
            self.set_size(True)
            self.set_size(False)
            self.depth -= 1

    def br(self, n):
        t = dict(kind='break', size=-self.right, length=n)
        self.enqueue(t)
        self.set_size(True)
        self.scan.append((self.right, t))

    def nl(self):
        self.enqueue(dict(kind='newline', size=0, length=0))
        self.advance()

    def flush(self):
        while self.depth > 1:
            self.close()
        self.right = PINF
        self.advance()
        pending = [dict(t) for t in self.queue]
        self.reset()
        return pending

    def invariant(self):
        # A pending unknown must retain an identical scan token. Monotone
        # saved totals allow duplicates at zero-length enqueue positions.
        saved = [p for p, _ in self.scan]
        assert saved == sorted(saved)
        for t in self.queue:
            if t['size'] < 0:
                assert any(u is t and p >= self.left for p, u in self.scan)


def format_checks():
    # This is a genuine failure of the overly broad fresh-formatter claim.
    m = Core()
    m.text(PINF+1)
    m.nl()
    m.br(1)
    m.text(1)
    before = dict(left=m.left, right=m.right, space=m.space)
    dropped = m.flush()
    assert [t['kind'] for t in dropped] == ['break', 'text']
    # Same long stream with the selected Driver outer user box drains.
    m = Core()
    m.open()
    m.text(PINF+1)
    m.nl()
    m.br(1)
    m.text(1)
    assert not m.flush()
    m.close()  # Driver's redundant close after SMTv2's final flush.
    assert not m.flush() and not m.flush()
    count = 0
    alphabet = (('text', 0), ('text', 1), ('text', PINF+1), ('text', 2*PINF),
                ('break', 0), ('break', 1), ('newline', 0), ('open', 0),
                ('open', 2), ('close', 0))
    for seq in itertools.product(alphabet, repeat=4):
        m = Core()
        m.open()
        for op, n in seq:
            if op == 'text': m.text(n)
            elif op == 'break': m.br(n)
            elif op == 'newline': m.nl()
            elif op == 'open': m.open(n, ('hov', 'h', 'v', 'hv', 'box')[count % 5])
            elif m.depth > 2: m.close()  # preserve Driver box
            m.invariant()
        assert not m.flush()
        count += 1
    return dict(selected_streams_checked=count+1,
                counterexample_before_flush=before,
                counterexample_dropped_token_kinds=[t['kind'] for t in dropped],
                universal_proof_by_model_claimed=False)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--freeze', required=True)
    args = parser.parse_args()
    start = time.monotonic()
    inputs = {}
    cache = {}
    checks = 0

    def require(condition):
        nonlocal checks
        assert condition
        checks += 1

    def get(path, revision=args.freeze):
        key = revision+':'+path
        if key not in cache:
            cache[key] = subprocess.check_output(['git', 'show', key], cwd=ROOT)
        raw = cache[key]
        inputs[key] = identity(raw)
        return raw

    def read(path, revision=args.freeze):
        return json.loads(get(path, revision))

    providers = read(PREFIX+'inputs.json')
    for key, expected in providers.items():
        rev, path = key.split(':', 1)
        require(identity(get(path, rev)) == expected)
    witnesses = read(PREFIX+'source-witnesses.json')
    source_members = {}
    for w in witnesses:
        archive_key = next(k for k in providers if k.endswith(':'+w['archive']))
        rev, path = archive_key.split(':', 1)
        archive_bytes = get(path, rev)
        require(identity(archive_bytes) == w['archive_identity'])
        with tarfile.open(fileobj=io.BytesIO(archive_bytes)) as archive:
            raw = archive.extractfile(w['member']).read()
        require(identity(raw) == w['member_identity'])
        lines = raw.decode().splitlines(keepends=True)
        lo, hi = w['first_line'], w['last_line']
        require(1 <= lo <= hi <= len(lines))
        text = ''.join(lines[lo-1:hi])
        require(text == w['excerpt'] and identity(text.encode()) == w['excerpt_identity'])
        source_members[w['archive']+':'+w['member']] = identity(raw)
    census = read(PREFIX+'census.json')
    result = read(PREFIX+'result.json')
    get('docs/research/retained-why-printer-output.md')
    for name in ('project.py', 'transfer.py', 'compose.py', 'check.py', 'check-result.json', 'round.json'):
        get(PREFIX+name)
    expected_cases = {r['case']: r for r in census['cases']}
    # Independent driver DAG arithmetic over exact retained byte strings.
    driver_prefix = 'docs/evidence/retained-solver-request-bytes-20261020/'
    manifest_key = next(k for k in providers if k.endswith(':'+driver_prefix+'driver-inputs.json'))
    manifest_rev, manifest_path = manifest_key.split(':',1)
    manifest = read(manifest_path,manifest_rev)
    driver_sizes = {}
    literal_sources = []
    for name, row in manifest.items():
        raw = get(driver_prefix+'drivers/'+name,manifest_rev)
        require(identity(raw) == row['identity'])
        driver_sizes[name] = len(raw)
        # All six selected literal statements are single-line in these exact
        # sources. The semantic origin exclusion remains a reviewed premise.
        for line in raw.decode().splitlines():
            if re.match(r'\s*syntax\s+literal\s',line):
                # The BV8 statement includes a commented alternative template.
                line = re.sub(r'\(\*.*?\*\)', '', line)
                literal_sources += re.findall(r'"([^"\n]*)"',line)
    integer_literals = [s for s in literal_sources if not re.search(r'%[sem]',s)]
    float_literals = [s for s in literal_sources if re.search(r'%[sem]',s)]
    require(len(float_literals) == 3)
    require(sorted(integer_literals) == sorted(['#x%64x','#x%32x','#x%16x','#x%8x','#x%4x','#x%2x']))
    def expanded(name, ancestors=()):
        assert name not in ancestors
        return driver_sizes[name]+sum(expanded(x,ancestors+(name,)) for x in manifest[name]['imports'])
    for driver, n in census['driver_expanded_source_bytes'].items():
        require(expanded(driver) == n)
    for case, row in expected_cases.items():
        key = next(k for k in providers if k.endswith(':'+ 'docs/evidence/retained-why-preinline-prefix-20261020/'+case+'-graph.json.gz'))
        rev,path = key.split(':',1)
        graph = json.loads(gzip.decompress(get(path,rev)))
        constants = [t['args'] for t in graph['terms'] if t['kind']=='const']
        require(len(constants) == row['original_constant_records'])
        require(all(len(c)==2 and type(c[1]) is int and abs(c[1])<=2**64 for c in constants))
        require(all(group for b in graph['bindings'] for group in b['triggers']))
    require(result['fresh_drain_requires_no_system_scope_break'])
    require(not result['shared_stderr_whole_interval_closed'] and not result['whole_process_capacity'])
    recomputed = []
    for row in result['cases']:
        source = expected_cases[row['case']]
        for driver, r in row['drivers'].items():
            d = r['dimensions']
            S,P,H,A,T,E = (d[k] for k in ('S','P','H','A','T','E'))
            C = H*((2*S+P)*(T+1)+2*(A+1)*(T+2)+8)
            L = source['raw_name_bytes']
            Lc = source['raw_comment_name_bytes']
            W = max(22,5,2*(L+5))+len(str(343+C))
            driver_bytes = census['driver_expanded_source_bytes'][driver]
            prelude = (H+1)*driver_bytes
            B = (census['maximum_quoted_source_token_bytes']+256+W)*C+8*H*(Lc+1)+prelude+512
            F = 128*C+2*prelude+128
            Q = B+F
            O = B+70*(F+1)
            doubling = 1024
            while doubling < O: doubling *= 2
            require(r['name_calls_per_owner_upper'] == C and r['printed_name_bytes_upper'] == W)
            core = r['request_formatter']
            require(core['text_bytes_upper'] == B and core['direct_core_events_upper'] == F)
            require(core['scalar_absolute_upper'] == 4*(Q+PINF+100))
            require(core['offered_bytes_upper'] == O and r['one_solver_input_file_bytes_upper'] == O)
            require(core['queue_and_each_stack_length_upper'] == 4*(F+1))
            require(r['request_buffer']['temporary_doubling_upper'] == doubling)
            require(r['request_buffer']['allocated_capacity_upper'] == min(doubling,MAX_STRING))
            require(O <= MAX_STRING and doubling <= MAX_INT and 4*(Q+PINF+100) <= MAX_INT)
            require(r['cumulative_file_bytes_mathematical_upper'] == E*O and not r['cumulative_total_is_native_operand'])
            diag = r['syntax_integer_diagnostic']
            require(diag['process_text_bytes_upper'] == 64*E and diag['process_core_events_upper'] == 8*E)
            require(not diag['fresh_stderr_reset_assumed'])
            recomputed.append(dict(case=row['case'],driver=driver,text=B,events=F,offered=O,doubling=doubling))
    model = format_checks()
    result_out = dict(status='pass', freeze=args.freeze, checks=checks,
                      source_witnesses=len(witnesses), complete_source_members=len(source_members),
                      numeric_rows=recomputed, independent_format_model=model,
                      elapsed_seconds=time.monotonic()-start, host=platform.system()+' '+platform.machine(),
                      native_runs=0, author_checker_replays=0, predecessor_checker_replays=0,
                      source_semantics_machine_checked=False)
    (HERE/'inputs.json').write_text(json.dumps(inputs,indent=2,sort_keys=True)+'\n')
    (HERE/'source-identities.json').write_text(json.dumps(source_members,indent=2,sort_keys=True)+'\n')
    (HERE/'result.json').write_text(json.dumps(result_out,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:v for k,v in result_out.items() if k not in ('numeric_rows',)},indent=2))


if __name__ == '__main__':
    main()
