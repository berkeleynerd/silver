#!/usr/bin/env python3
"""Independent frozen-packet checks; no target or predecessor checker runs."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import struct
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = 'docs/evidence/retained-fixed-failure-composition-20261023/'


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def scan(text):
    """Return uncommented text and raw string contents, with nested comments."""
    result, strings = [], []
    i = 0
    while i < len(text):
        if text.startswith('(*)', i):
            result.append('(*)'); i += 3
        elif text.startswith('(*', i):
            depth = 1; result.append('  '); i += 2
            while depth:
                if text.startswith('(*', i):
                    depth += 1; result.append('  '); i += 2
                elif text.startswith('*)', i):
                    depth -= 1; result.append('  '); i += 2
                else:
                    result.append('\n' if text[i] == '\n' else ' '); i += 1
        elif text[i] == '"':
            start = i; i += 1
            while text[i] != '"':
                i += 2 if text[i] == '\\' else 1
            i += 1; result.append(text[start:i]); strings.append(text[start+1:i-1])
        else:
            result.append(text[i]); i += 1
    return ''.join(result), strings


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('target')
    args = parser.parse_args()
    start = time.monotonic()
    checked = []
    inputs, cache, archives = {}, {}, {}

    def require(ok, label):
        if not ok:
            raise AssertionError(label)
        checked.append(label)

    def read(path, commit=None):
        commit = commit or args.target
        key = f'{commit}:{path}'
        if key not in cache:
            cache[key] = subprocess.check_output(['git', 'show', key], cwd=ROOT)
            inputs[key] = identity(cache[key])
        return cache[key]

    def obj(name):
        return json.loads(read(PACKET+name))

    def member(archive, name):
        if archive not in archives:
            archives[archive] = tarfile.open(fileobj=io.BytesIO(read(archive)))
        return archives[archive].extractfile(name).read()

    # All newly retained source spans must correspond to their whole members.
    for row in obj('source-witnesses.json'):
        raw = member(row['archive'], row['member'])
        require(identity(raw) == row['member_identity'], f"whole member {row['member']}")
        span = ''.join(raw.decode().splitlines(keepends=True)[row['start']-1:row['end']]).encode()
        require(span == row['text'].encode() and identity(span) == row['identity'],
                f"source span {row['member']}:{row['start']}-{row['end']}")

    # The repair changes only three base driver values and three import strings.
    repair = obj('configuration-repair.json')
    oldbase = read('docs/evidence/retained-adapter-config-composition-20261020/candidate-base-why3.conf')
    base = read(PACKET+'configuration/why3.conf')
    expected = oldbase
    for row in repair['base_driver_edits']:
        require(expected.count(row['before'].encode()) == 1, 'unique base replacement '+row['before'])
        expected = expected.replace(row['before'].encode(), row['after'].encode())
    require(base == expected and len(base) == len(oldbase), 'exact equal-width base recipe')
    require(identity(base) == repair['base_after'] and identity(oldbase) == repair['base_before'], 'base identities')
    changed_imports = 0
    for name, row in repair['files'].items():
        old = read(row['source']); new = read(PACKET+'configuration/overlay/'+name)
        expected = old.replace(b'import "smt-libv2.gen"', b'import "slv-libv2.gen"')
        require(new == expected and len(new) == len(old), 'exact overlay recipe '+name)
        require(len(name) == len(row['old_name']), 'basename width '+name)
        require(identity(old) == row['source_identity'] and identity(new) == row['identity'], 'overlay identities '+name)
        changed_imports += old.count(b'import "smt-libv2.gen"')
    require(changed_imports == 3, 'three rewritten import occurrences')
    oldkeys = re.findall(rb'(?m)^(?:name|version|shortcut|command|command_steps) = .*$', oldbase)
    newkeys = re.findall(rb'(?m)^(?:name|version|shortcut|command|command_steps) = .*$', base)
    require(oldkeys == newkeys, 'prover identities order and commands unchanged')

    # The initial census includes all nine configured roots and the Coq aux import.
    closure = obj('initial-driver-closure.json')
    names, raw_files, max_width = set(), {}, 0
    for row in closure['files']:
        origin = row['origin']
        raw = member(origin['archive'], origin['member']) if 'archive' in origin else read(origin['path'])
        require(identity(raw) == row['identity'], 'initial-driver identity '+row['name'])
        clean, strings = scan(raw.decode())
        imports = re.findall(r'(?m)^\s*import\s+"([^"\n]+)"', clean)
        require(imports == row['imports'], 'initial-driver imports '+row['name'])
        nums = [m for s in strings for m in re.findall(r'%(?:[a-z])?(\d+)', s)]
        width = max(map(len, nums), default=0)
        max_width = max(max_width, width)
        require(width == row['maximum_numeric_placeholder_bytes'] and len(nums) == row['numeric_placeholder_occurrences'],
                'numeric-placeholder census '+row['name'])
        require(not re.search(r'(?m)^\s*plugin\b', clean), 'no driver plugin '+row['name'])
        names.add(row['name']); raw_files[row['name']] = raw
    require(len(names) == closure['file_count'] == 27, '27 initial files')
    require('coq-realizations.aux' in names, 'Coq aux included')
    require(all(set(row['imports']) <= names for row in closure['files']), 'complete initial import closure')
    require(max_width == closure['numeric_placeholder_maximum'] == 2, 'two-byte numeric maximum')
    require(closure['standard_stderr_fragment'] == {'B':64,'E':8,'attempts':1}, 'retained diagnostic allowance')
    roots = re.findall(rb'(?m)^driver = "([^"]+)"$', base)
    require(len(roots) == 9, 'nine configured roots')
    installed = set(closure['installed_driver_member_names'])
    require(not installed.intersection(repair['rename'].values()), 'unique names absent in archive namespace')
    actual_installed = set(closure['actual_installed_entry_names'])
    require(len(actual_installed) == 107 and installed <= actual_installed, 'complete 107-entry installed namespace')
    require(not actual_installed.intersection(repair['rename'].values()), 'unique names absent in full namespace')

    # Reconstruct the repaired successful import graph by complete candidate sets.
    private = {name: read(PACKET+'configuration/overlay/'+name)
               for name in repair['files'] if name.endswith(('.drv','.gen'))}
    installed_bytes = {row['name']: raw_files[row['name']] for row in closure['files']
                       if not row['role_path'].startswith('$PRIVATE')}
    visited = set()
    def visit(name, private_context):
        choices = []
        if private_context and name in private: choices.append(('private', private[name]))
        if name in installed_bytes: choices.append(('installed', installed_bytes[name]))
        require(len(choices) == 1, f'unambiguous intended import {private_context}:{name}')
        kind, raw = choices[0]
        key = kind, name
        if key in visited: return
        visited.add(key)
        clean, _ = scan(raw.decode())
        for imported in re.findall(r'(?m)^\s*import\s+"([^"\n]+)"', clean):
            visit(imported, kind == 'private')
    for root in roots:
        name = root.decode()+'.drv'
        visit(name, name in private)
    require(len(visited) == 28, 'repaired 28-file family with split common origin')

    # Paths are prospective namespace premises, not reconstructed historical cwd.
    paths = obj('paths.json')
    require(len(paths['loadpath']) == 4 and len(paths['extensions']) == 5, 'four load roots and five extensions')
    for case, row in paths['domains'].items():
        candidates = [d+'/'+b+'.'+ext for b in row['initial_libraries']
                      for d in paths['loadpath'] for ext in paths['extensions']]
        require(candidates == row['library_candidates'] and len(candidates) == 420,
                'complete initial library candidate family '+case)
        require(max(map(len, candidates)) == 180, 'initial library candidate maximum '+case)
        require(sorted(row['required_existing_library_candidates']) == row['observed_existing_library_candidates'],
                'fixed library membership '+case)
        known = {r['path']:r['identity'] for r in row['repaired_driver_files']}
        require(len(known) == 28, 'repaired full-path family '+case)
        for r in row['driver_discovery']+row['driver_imports']:
            require([p for p in r['candidates'] if p in known] == [r['required_existing_candidate']],
                    'one intended candidate '+case+':'+r.get('name',r.get('root','')))
            require(set(r['candidates']) == set(r['required_absent_candidates'])|{r['required_existing_candidate']}
                    and r['required_existing_candidate'] not in r['required_absent_candidates'],
                    'exhaustive absent alternatives '+case+':'+r.get('name',r.get('root','')))
            require(max(map(len,r['candidates'])) <= 180, 'driver candidate maximum '+case)
        for path, expected in known.items():
            name = path.rsplit('/',1)[-1]
            source = private[name] if '/overlay/' in path else installed_bytes[name]
            require(identity(source) == expected, 'resolved intended bytes '+case+':'+name)
        require(row['PrecutP'] == {'max':[180,{'client_initial_cwd_bytes':1,'constant':10}]}
                and row['client_cwd_observed'] is None and not row['actual_client_cwd_inferred'],
                'symbolic cwd remains distinguished '+case)

    # Reuse the already reviewed metrics; independently evaluate the new join.
    joined = obj('result.json')
    raw = json.loads(read('docs/evidence/retained-fixed-ptree-capture-20261023/result.json','91ad324d83'))
    raw = {r['case']:r for r in raw['cases']}
    limit = 2**62-1
    sentinel = 1_000_000_010
    def core_ok(b,e):
        return (b+e+79 <= sentinel and
                (3*e+1)*(sentinel+b+e+1)+b+e+79 <= limit and
                4*(3*e+2)+2 <= limit)
    def scalar_values(p,u):
        s = max(467,u+256,4*p+2048)
        c = 71320+96*s
        r,a,x = 31*c,341*c,4*(31*c+p+1024)
        cm = 71320+96*max(467,p+51)
        return {'S':s,'C':c,'R4':r,'A4':a,'X':x,'M_marker':15*cm+1024,'A_marker':85*cm+1024}
    for row in joined['cases']:
        case = row['case']; metrics = raw[case]
        for example in row['examples_only']:
            p = max(180,example['cwd_bytes_example']+10)
            calculated = scalar_values(p,row['raw_label_U'])
            require(all(example['scalar'][k] == v for k,v in calculated.items()), 'joined scalar arithmetic '+case+':'+str(p))
            require(core_ok(calculated['A4']+p+1024,9936)
                    and core_ok(calculated['A_marker'],4816)
                    and core_ok(6*calculated['X']+576,2*calculated['X']+522), 'joined core guards '+case+':'+str(p))
            n = metrics['expanded_blocks']+metrics['expanded_immediates']+1
            f = 2048*n+1024
            b = (f+16*metrics['expanded_direct_string_bytes']+
                 8*metrics['position_candidate_occurrences']*802+
                 8*metrics['maximum_identical_three_integer_record_occurrences']*calculated['M_marker'])
            m = example['mlw']
            require((m['N'],m['F'],m['B'],m['Q'],m['O']) == (n,f,b,b+f,b+70*(f+1)),
                    'joined Mlw arithmetic '+case+':'+str(p))
            require(4*(b+f+sentinel+128) <= limit and m['O'] <= 2**63-1, 'joined Mlw guards '+case+':'+str(p))
    upper = joined['sufficient_region']['PrecutP_upper']
    require(upper == 1927 and joined['sufficient_region']['client_cwd_bytes_upper'] == upper-10, 'reported sufficient region')
    for p, expected in [(upper,True),(upper+1,False)]:
        v=scalar_values(p,189)
        require(core_ok(6*v['X']+576,2*v['X']+522) == expected, 'scalar sentinel region boundary '+str(p))
    require(joined['global_e_upper'] == joined['save_entering_callbacks_upper'] == 2
            and joined['saves_upper'] == 3 and not joined['allowance_renewed'], 'one global allowance')
    require(joined['normal_and_terminal_prefixes_are_alternatives']
            and not joined['arbitrary_Main_covered'] and not joined['production_refinement_established'], 'scope remains explicit')

    # No target starts: inspect the six complete resolver bodies as ordinary ELF bytes.
    native = obj('resolver-native.json')
    directory = Path(native['ELF_path']).parent.parent/'share/why3/drivers'
    require({p.name for p in directory.iterdir()} == actual_installed, 'full namespace matches installed directory')
    elf = Path(native['ELF_path']).read_bytes()
    inputs[native['ELF_path']] = identity(elf)
    require(identity(elf) == native['ELF_identity'], 'resolver ELF identity')
    header = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
    require(header[0][:6] == b'\x7fELF\x02\x01' and header[2] == 62, 'ELF64 little-endian x86_64')
    phdrs = [struct.unpack_from('<IIQQQQQQ',elf,header[5]+i*header[9]) for i in range(header[10])]
    shdrs = [struct.unpack_from('<IIQQQQIIQQ',elf,header[6]+i*header[11]) for i in range(header[12])]
    symbols = {}
    for sh in shdrs:
        if sh[1] != 2: continue
        st = shdrs[sh[6]]; strings = elf[st[4]:st[4]+st[5]]
        for off in range(sh[4],sh[4]+sh[5],sh[9]):
            n,_,_,_,addr,size = struct.unpack_from('<IBBHQQ',elf,off)
            symbols[strings[n:strings.index(0,n)].decode()] = addr,size
    for row in native['functions']:
        addr,size = symbols[row['symbol']]
        require((addr,size) == (row['address'],row['size']), 'native symbol '+row['symbol'])
        segments = [p for p in phdrs if p[0] == 1 and p[3] <= addr and addr+size <= p[3]+p[5]]
        require(len(segments) == 1, 'native executable segment '+row['symbol'])
        p = segments[0]; raw = elf[p[2]+addr-p[3]:p[2]+addr-p[3]+size]
        require(raw.hex() == row['hex'] and identity(raw) == row['identity'], 'native full body '+row['symbol'])
    require(len(native['functions']) == 6 and native['inferior_runs'] == native['new_disassembler_runs'] == 0,
            'six retained native bodies without replay')
    # Entry stores this immutable closure at Sysutil+0xf0, the filter predicate.
    predicate_addr = symbols['camlWhy3__Sysutil__26'][0]
    require(predicate_addr == 0xb2e6a8, 'native predicate closure address')
    p = next(p for p in phdrs if p[0] == 1 and p[3] <= predicate_addr and predicate_addr+16 <= p[3]+p[5])
    off = p[2]+predicate_addr-p[3]
    predicate = elf[off:off+16]
    require(struct.unpack_from('<Q',predicate)[0] == symbols['camlWhy3__Sysutil__is_file_1490'][0],
            'native filter closure selects is_file')
    for row in obj('loader-native.json'):
        raw = Path(row['path']).read_bytes(); inputs[row['path']] = identity(raw)
        require(identity(raw) == row['identity'], 'plugin identity '+row['path'])
        h = struct.unpack_from('<16sHHIQQQIHHHHHH',raw)
        ph = [struct.unpack_from('<IIQQQQQQ',raw,h[5]+i*h[9]) for i in range(h[10])]
        dynamic = [p for p in ph if p[0] == 2]
        require(len(dynamic) == 1, 'one plugin dynamic segment '+row['path'])
        p = dynamic[0]; table=raw[p[2]:p[2]+p[5]]
        entries=list(struct.iter_unpack('<QQ',table))
        require(table.hex() == row['dynamic_hex'] and identity(table) == row['dynamic_identity'], 'plugin dynamic bytes '+row['path'])
        require(not any(tag in (1,15,29) for tag,_ in entries), 'no plugin NEEDED/RPATH/RUNPATH '+row['path'])
        require('/' in row['path'] and '$' not in row['path'], 'literal slash plugin path '+row['path'])

    result = {'target':args.target,'checks':len(checked),'elapsed_seconds':time.monotonic()-start,
              'passed':True,'repaired_import_nodes':sorted([list(x) for x in visited]),
              'native_target_runs':0,'predecessor_checker_runs':0,'new_disassembler_runs':0,
              'filter_predicate_closure':{'address':predicate_addr,'hex':predicate.hex(),'identity':identity(predicate)},
              'inputs':inputs,'check_labels':checked}
    (HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:result[k] for k in ['target','checks','elapsed_seconds','passed']}))


if __name__ == '__main__':
    main()
