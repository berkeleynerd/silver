"""One offline identity/shape/arithmetic check; no target or prior checker run."""
from pathlib import Path
import collections
import hashlib
import json
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
START = time.perf_counter()
checks = 0


def require(test, why):
    global checks
    checks += 1
    if not test:
        raise AssertionError(why)


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


for name, expected in json.loads((HERE / 'inputs.json').read_text()).items():
    require(identity((ROOT / name).read_bytes()) == expected, name)

manifest = json.loads((HERE / 'source-manifest.json').read_text())
with tarfile.open(HERE / 'sources.tar.gz') as tar:
    sources = {m.name: tar.extractfile(m).read() for m in tar.getmembers()}
require(set(sources) == set(manifest['members']), 'source inventory')
for name, expected in manifest['members'].items():
    require(identity(sources[name]) == expected, name)

native = json.loads((HERE / 'native-witnesses.json').read_text())
elf = Path(native['executable']).read_bytes()
require(identity(elf) == native['identity'], 'native executable')
phoff = struct.unpack_from('<Q', elf, 32)[0]
phsize, phnum = struct.unpack_from('<HH', elf, 54)


def elf_bytes(addr, size):
    for i in range(phnum):
        typ, _, off, va, _, sz, _, _ = struct.unpack_from(
            '<IIQQQQQQ', elf, phoff + i * phsize)
        if typ == 1 and va <= addr and addr + size <= va + sz:
            return elf[off + addr - va:off + addr - va + size]
    raise AssertionError('unmapped static span')


for span in native['spans']:
    expected = bytes.fromhex(span['hex'])
    require(elf_bytes(span['vaddr'], len(expected)) == expected, span['symbol'])
for item in native['strings']:
    expected = item['text'].encode() + b'\0'
    require(elf_bytes(item['vaddr'], len(expected)) == expected, item)
static = (HERE / 'native-static.txt').read_text()
for fragment in ('mov    0x10(%rbx),%rax', 'mov    0x8(%rbx),%rax',
                 'mov    (%rbx),%rbx', 'pp_opt_inner_7831',
                 'test   $0x1,%cl', 'module %a%a@ %a'):
    require(fragment in static, 'native reader witness ' + fragment)


def string_tokens(source):
    """Conservative complete Mlw literal census, skipping nested comments."""
    i, depth = 0, 0
    out = []
    while i < len(source):
        if source.startswith('(*', i):
            depth += 1
            i += 2
        elif depth and source.startswith('*)', i):
            depth -= 1
            i += 2
        elif depth:
            i += 1
        elif source[i] == '"':
            begin = i
            i += 1
            while i < len(source) and source[i] != '"':
                i += 2 if source[i] == '\\' else 1
            require(i < len(source), 'terminated source string')
            i += 1
            out.append(source[begin:i])
        elif source[i] == "'" and i + 2 < len(source):
            # Character literals are irrelevant here, but may contain quotes.
            end = i + (3 if source[i + 1] == '\\' else 2)
            i = end + 1 if end < len(source) and source[end] == "'" else i + 1
        else:
            i += 1
    require(depth == 0, 'balanced comments')
    return out


mlw = sources['mlw_printer.ml'].decode()
tokens = string_tokens(mlw)
largest_token = max(map(len, tokens))
boxes = sorted(set(re.findall(r'@\[<([^>]*)>', ''.join(tokens))))
require(largest_token <= 90, 'inherited 364-node fixed-format cap')
require(set(boxes) <= {'h', 'hv', 'hv 1', 'hv 2', 'hv 3', 'hv2',
                       'v', 'v 2', 'v0', 'v2'}, 'fixed box forms')
require(not any(s in ''.join(tokens) for s in ('@;', '@<', '@{', '@}', '%(', '%{')),
        'no custom breaks, magic-size, tags, or dynamic-format substitution')
require(mlw.count('id_loc ()') == 1 and len(re.findall(r'\bnext_pos\b', mlw)) == 1,
        'synthetic position helpers have definitions only')
for fragment in ('let pp_module fmt (id, decls)', 'List.rev spec.sp_pre',
                 'combine ptys (combine ps ms)', 'with Exit ->',
                 'pp_maybe_marker id.id_loc pp.closed x (pp_qualid ~attr) qid',
                 '| (_, (pat, _) :: _) :: _ -> pat',
                 'let pat = if pat.pat_desc <> Pwild then pat else'):
    require(fragment in mlw, 'charged source form ' + fragment)
converter = sources['gnat_ast_to_ptree.ml'].decode()
for fragment in ('Mlw_printer.pp_mlw_file ~attr:true', 'let out = open_out mlw_filename',
                 'Format.fprintf (Format.formatter_of_out_channel out) "%a@." pp mlw_file;',
                 'close_out out in'):
    require(fragment in converter, 'private caller ' + fragment)
require('let equal = Stdlib.(=)' in sources['loc.ml'].decode(), 'structural Loc equality')

capture = ROOT / 'docs/evidence/retained-fixed-ptree-capture-20261023'
prior = {r['case']: r for r in json.loads((capture / 'result.json').read_text())['cases']}
cases = []
with tarfile.open(capture / 'capture.tar.gz') as tar:
    for name in ('put_line', 'put', 'first_or_default', 'input_is_valid', 'is_message'):
        graph = json.load(tar.extractfile(name + '/capture/graph.json'))
        objects = {int(k): v for k, v in graph['objects'].items()}
        memo, active, order = {}, set(), []

        def measure(v):
            if v & 1:
                n = (v if v < 2**63 else v - 2**64) >> 1
                return (0, 1, 0, 0, 1, abs(n))
            if v in memo:
                return memo[v]
            require(v not in active, 'acyclic graph')
            active.add(v)
            r = objects[v]
            require((r['header'] & 255, r['header'] >> 10) == (r['tag'], r['words']),
                    'native object header')
            if r['tag'] == 252:
                require(len(bytes.fromhex(r['data_hex'])) == r['length'], 'string payload')
                result = (1, 0, 1, r['length'], 1, 0)
            else:
                require(r['tag'] < 246 and len(r['fields']) == r['words'], 'data block')
                children = [measure(c) for c in r['fields']]
                result = (1 + sum(x[0] for x in children), sum(x[1] for x in children),
                          sum(x[2] for x in children), sum(x[3] for x in children),
                          1 + max([x[4] for x in children] + [0]),
                          max([x[5] for x in children] + [0]))
            active.remove(v)
            memo[v] = result
            order.append(v)
            return result

        b, i, strings, sb, depth, imax = measure(graph['root'])
        require(len(order) == len(objects), 'complete reachable graph')
        old = prior[name]
        require((b, i, sb, depth, imax) == tuple(old[k] for k in (
            'expanded_blocks', 'expanded_immediates', 'expanded_direct_string_bytes',
            'expanded_depth', 'maximum_absolute_immediate')), 'input measure reconciliation')
        weights = collections.Counter({graph['root']: 1})
        positions = collections.Counter()

        def is_loc(v):
            return not v & 1 and objects[v]['tag'] == 0 and objects[v]['words'] == 3 and all(
                x & 1 for x in objects[v]['fields'])

        for v in reversed(order):
            r = objects[v]
            for c in r.get('fields', []):
                if not c & 1:
                    weights[c] += weights[v]
            if is_loc(v):
                positions[tuple(r['fields'])] += weights[v]
        require(max(positions.values()) == old['maximum_identical_three_integer_record_occurrences'],
                'location multiplicity')
        eraises, constants, patterns = 0, 0, 0
        for r in objects.values():
            if r['tag'] != 0 or r['words'] != 2:
                continue
            d, loc = r['fields']
            if d & 1 or not is_loc(loc):
                continue
            desc = objects[d]
            if desc['tag'] == 24:
                require(desc['words'] == 2 and desc['fields'][1] == 1,
                        'every broad Eraise candidate has None argument')
                eraises += 1
            if desc['tag'] == 0 and desc['words'] == 1:
                payload = objects[desc['fields'][0]]
                if payload['words'] == 3:
                    require(payload['tag'] == 0 and
                            objects[payload['fields'][0]]['tag'] == 252, 'Pvar identifier alternative')
                    patterns += 1
                    continue
                require(payload['tag'] == 0 and payload['words'] == 1, 'ConstInt variant')
                integer = objects[payload['fields'][0]]
                require(integer['tag'] == 0 and integer['words'] == 2 and
                        all(v & 1 for v in integer['fields']), 'immediate integer literal')
                constants += 1
        modules, lst = 0, objects[graph['root']]['fields'][0]
        while lst != 1:
            module, lst = objects[lst]['fields']
            r = objects[module]
            require(r['tag'] == 0 and r['words'] == 3 and r['fields'][1] == 1,
                    'native module optional field None')
            modules += 1
        require(modules == old['modules'], 'module count')

        n = b + i + 1
        u = 8 * n
        locs, k = sum(positions.values()), max(positions.values())
        # This is the numerical join P<=416, M<=1743304; the note exports symbols.
        p, m = 416, 1743304
        f = 256 * u + 1024
        text = 256 * u + 16 * sb + 8 * locs * (4 * p + 82) + 8 * k * m + 1024
        q = text + f
        output = text + 70 * (f + 1)
        guard = 4 * (q + 1000000010 + 128)
        require(guard <= 2**62 - 1, 'Format signed63 arithmetic')
        require(4 * (f + 1) <= 2**62 - 1, 'queue and stack counters')
        require(output <= 2**63 - 1, 'private channel signed64 extent')
        require(max(m, 4 * p + 2, old['maximum_direct_string_payload'] + 16, 90) <= 2**57 - 9,
                'individual text and escaped-string extent')
        # Prefix algebra for both possible cached-offset initializations.
        for delta in (-1, 0):
            for offered, debt in ((0, 0), (65536, 65536), (output, 65536)):
                committed = offered - debt
                for written in (1, debt) if debt else ():
                    require(-1 <= committed + written + delta <= output and
                            committed + written + debt - written == offered,
                            'positive write prefix and fixed offset bias')
        cases.append(dict(case=name, expanded_blocks=b, expanded_immediates=i,
                          direct_string_bytes=sb, position_candidates=locs,
                          maximum_identical_location_candidates=k,
                          unique_raise_candidates=eraises, unique_integer_candidates=constants,
                          unique_pattern_alternatives=patterns, source_units=u,
                          marker_copies=8*k, B=text, F=f, Q=q, O=output,
                          native_arithmetic_guard=guard))

result = dict(status='pass', checks=checks, scope='offline source/native identity, broad fixed-graph shape, and arithmetic joins; source proof requires review',
              capture_freeze='91ad324d83', source_revision=manifest['source_revision'],
              fixed_format_source_token_max=largest_token, fixed_format_nodes=364,
              box_forms=boxes, synthetic_position_counter_increments=0,
              numerical_join=dict(P=416, M=1743304), cases=cases,
              target_runs=0, inferior_operations=0, predecessor_checker_replays=0,
              elapsed_seconds=time.perf_counter()-START)
(HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
