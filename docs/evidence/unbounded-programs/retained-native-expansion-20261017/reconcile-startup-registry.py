#!/usr/bin/env python3
"""Reconcile fixed native startup registry and coverage buffers without execution.

This is a pinned-source census and arithmetic replay, not a C++ compiler or a
reachability proof. The companion report reviews constructors, selected methods,
record layouts, disabled options and the operating-system interface boundary.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--ada-root', type=Path, required=True)
p.add_argument('--plugin-include', type=Path, required=True)
p.add_argument('--cxx-include', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
here = Path(__file__).resolve().parent
identity = json.loads((here / 'startup-registry-inputs.json').read_bytes())
sha = lambda b: hashlib.sha256(b).hexdigest()
sources = {}
for row in identity['files']:
    root = {'gcc': a.gcc_root, 'ada': a.ada_root,
            'plugin': a.plugin_include, 'cxx': a.cxx_include}[row['root']]
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
prior = {}
for row in identity['prior_results']:
    raw = (here / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    prior[row['path']] = json.loads(raw)

lexical = re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', re.S)
def mask(raw):
    return lexical.sub(lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]), raw)

def end_brace(masked, start):
    assert masked[start] == '{'
    depth, i = 1, start + 1
    while depth:
        depth += (masked[i] == '{') - (masked[i] == '}')
        i += 1
    return i

def body_at(raw, masked, start):
    opening = masked.index('{', start)
    end = end_brace(masked, opening)
    return {'line': raw[:start].count('\n') + 1,
            'text': raw[start:end],
            'body': raw[opening + 1:end - 1]}

def method(raw, masked, name):
    # All selected methods have ordinary brace bodies. Ignore declarations.
    found = []
    for m in re.finditer(name + r'\s*\([^;{}]*\)[^;{}]*\{', masked):
        found.append(body_at(raw, masked, m.start()))
    return found

def field_declarations(raw):
    # Top-level semicolon-delimited declarations only. Bodies, methods and
    # comments are ignored. Actual type classification is manually reviewed.
    masked = mask(raw)
    level, start, fields = 0, 0, []
    for i, ch in enumerate(masked):
        if ch == '{':
            level += 1
        elif ch == '}':
            level -= 1
            if level == 0:
                start = i + 1
        elif ch == ';' and level == 0:
            decl = masked[start:i].strip()
            if decl and '(' not in decl:
                decl = re.sub(r'\b(?:private|protected|public)\s*:', '', decl)
                fields.append(' '.join(decl.split()))
            start = i + 1
    return fields

header = sources['pass-instances.def']
rows = re.findall(r'\bNEXT_PASS(?:_WITH_ARGS?)?\s*\(\s*(\w+)\s*,\s*(\d+)', header)
assert len(rows) == 394 and len(set(name for name, _ in rows)) == 304
counts = Counter(name for name, _ in rows)
assert set(counts) == set(identity['factory_paths'])
base_types = {'public gimple_opt_pass', 'public rtl_opt_pass',
              'public simple_ipa_opt_pass', 'public ipa_opt_pass_d',
              'public ch_base', 'public pass_dce_base'}
census = []
for name in sorted(counts):
    path = identity['factory_paths'][name]
    raw = sources[path]
    masked = mask(raw)
    factories = method(raw, masked, r'\bmake_' + name)
    assert len(factories) == 1, name
    factory = factories[0]
    expression = mask(factory['body'])
    new = re.fullmatch(r'\s*return new ([\w:]+)(?:<[^>]+>)?\s*\([^;]+\);\s*', expression)
    assert new, name
    typename = new[1].split('::')[-1]
    classes = list(re.finditer(r'\bclass\s+' + typename + r'\s*:\s*([^{};]+)\{', masked))
    assert len(classes) == 1, name
    cl = classes[0]
    base = ' '.join(cl[1].split())
    assert base in base_types, (name, base)
    close = end_brace(masked, cl.end() - 1)
    body = raw[cl.end():close - 1]
    bm = mask(body)
    ctors = []
    for m in re.finditer(r'(?<!~)\b' + typename + r'\s*\(', bm):
        if bm[:m.start()].count('{') != bm[:m.start()].count('}'):
            continue
        opening = bm.find('{', m.end())
        semi = bm.find(';', m.end())
        if opening < 0 or 0 <= semi < opening:
            continue
        ctor = body_at(body, bm, m.start())
        ctor['line'] += raw[:cl.end()].count('\n')
        ctors.append(ctor)
    if not ctors:
        ctors = method(raw, masked, r'\b' + typename + '::' + typename)
    assert len(ctors) == 1, name
    assert not mask(ctors[0]['body']).strip(), name
    clones = method(body, bm, r'\bclone')
    params = method(body, bm, r'\bset_pass_param')
    for item in clones + params:
        item['line'] += raw[:cl.end()].count('\n')
    if not clones:
        clones = method(raw, masked, r'\b' + typename + r'::clone')
    if not params:
        params = method(raw, masked, r'\b' + typename + r'::set_pass_param')
    if counts[name] > 1:
        assert len(clones) == 1, name
        assert re.fullmatch(r'\s*return new ' + typename + r'(?:<[^>]+>)?\s*\([^;]+\);\s*',
                            mask(clones[0]['body'])), name
    for param in params:
        assert not re.search(r'\b(?:new|XNEW|malloc|calloc|alloc|push|reserve)\b',
                             mask(param['body'])), name
    census.append({'factory': name, 'instances': counts[name], 'path': path,
                   'factory_definition': factory, 'class_name': typename,
                   'class_line': raw[:cl.start()].count('\n') + 1,
                   'base': base, 'constructor': ctors[0],
                   'fields': field_declarations(body),
                   'clones': clones, 'parameter_setters': params,
                   'class_sha256': sha(raw[cl.start():close].encode())})

# Names of pass_data definitions in selected files, including definitions of
# uninstantiated companion passes: that is conservative for the string bound.
names = []
for path in sorted(set(identity['factory_paths'].values())):
    raw = sources[path]
    masked = mask(raw)
    for m in re.finditer(r'\bconst\s+pass_data\s+[^=;{]*=\s*\{', masked):
        end = end_brace(masked, m.end() - 1)
        block = raw[m.end():end - 1]
        spellings = [t[1:-1] for t in lexical.findall(block) if t.startswith('"')]
        assert spellings and all('\\' not in t for t in spellings), path
        names.append({'path': path, 'line': raw[:m.start()].count('\n') + 1,
                      'spellings': spellings})
maximum_name = max(len(n) for row in names for n in row['spellings'])
assert maximum_name == 27

anchors = {
    'auto-host.h': ['#define CHECKING_P 0', '#define GATHER_STATISTICS 0'],
    'gcc/passes.cc': ['m_name_to_pass_map = new hash_map<free_string_hash, opt_pass *> (256);',
        'passes_by_id = XRESIZEVEC (opt_pass *, passes_by_id, id + 1);',
        'const char *unique_name = xstrdup (name);', 'if (!flag_dump_passes)'],
    'gcc/hash-map.h': ['const size_t default_hash_map_size = 13;', 'bool ggc = false,'],
    'gcc/hash-table.h': ['if (insert == INSERT && m_size * 3 <= m_n_elements * 4)',
        'nindex = hash_table_higher_prime_index (elts * 2);',
        'Allocator <value_type> ::data_alloc (n);'],
    'gcc/dumpfile.cc': ['m_extra_dump_files_alloced = 512;', 'return count + TDI_end;'],
    'gcc/statistics.cc': ['dump_register (".statistics", "statistics",'],
    'gcc/cgraphunit.cc': ['dump_register (".debug", "debug",',
        'dump_register (".earlydebug", "earlydebug",'],
    'gcc/langhooks-def.h': ['#define LANG_HOOKS_REGISTER_DUMPS\tlhd_register_dumps'],
    'gcc/context.cc': ['m_dumps (new gcc::dump_manager ())',
        'm_channels (new gcc::compiler_channels ())'],
    'gcc/vec.h': ['auto_vec () { this->m_vec = NULL; }'],
    'gcc/coverage.cc': ['int original_len = strlen (original_filename);',
        'int len = strlen (filename);', 'profile_data_prefix = getpwd ();',
        'da_file_name = XNEWVEC (char, len + strlen (GCOV_DATA_SUFFIX)',
        'if (flag_branch_probabilities && !flag_auto_profile)',
        'if (flag_test_coverage && !flag_compare_debug)'],
    'gcc/gcov-io.h': ['#define GCOV_DATA_SUFFIX ".gcda"'],
    'libiberty/getpwd.c': ['#define GUESSPATHLEN (MAXPATHLEN + 1)',
        '#define GUESSPATHLEN 100',
        'for (s = GUESSPATHLEN;  !getcwd (p = XNEWVEC (char, s), s);  s *= 2)'],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)
assert '#define LANG_HOOKS_REGISTER_DUMPS' not in sources['gcc-interface/misc.cc']
assert 'PWD' not in prior['fixed-gcc-prefix-witness/frontend-exec.json']['environment']
assert counts['pass_store_merging'] == 1 and counts['pass_warn_access'] == 3

primes = [int(x) for x in re.findall(r'\{\s*(\d+),\s*0x', sources['gcc/hash-table.cc'])]
size, growth = next(n for n in primes if n >= 256), []
for entries in range(len(rows)):
    if size * 3 <= entries * 4:
        size = next(n for n in primes if n >= entries * 2)
    if not growth or growth[-1] != size:
        growth.append(size)
assert growth == [509, 1021]
fixed_requests = {
    'each_pass_record_upper': 512,
    'pass_manager_upper': (394 + 16) * 8,
    'context_control_upper': 32,
    'dump_manager_control_upper': 64,
    'compiler_channels_control_upper': 64,
    'name_map_control_upper': 96,
    'each_default_pass_member_map_backing': 13 * 16,
    'name_map_largest_backing': size * 16,
    'dump_file_array_upper': 512 * 128,
    'pass_ID_array_upper': (13 + 394 + 3) * 8,
    'each_constructed_pass_name_including_NUL': 5 + maximum_name + 10 + 1,
}
assert max(fixed_requests.values()) == 65536

def paths(path_chars, guesspathlen=4097):
    # GUESSPATHLEN is a platform/header constant, not a program-dependent count.
    # The Linux MAXPATHLEN=4096 interface supplies4097; the no-macro case uses100.
    assert path_chars >= 0 and guesspathlen in (100, 4097)
    requests = {'coverage_data_filename': 2 * path_chars + 7,
                'working_directory_buffer': max(guesspathlen, 2 * (path_chars + 1))}
    return {'pathname_chars': path_chars, 'guesspathlen': guesspathlen,
            'individual_requests': requests,
            'signed_int_filename_index_arithmetic_fits': 2 * path_chars + 7 <= 2**31 - 1,
            'pointer_differences_and_size_t_doubling_fit': max(requests.values()) <= 2**63 - 1}

result = {
    'scope': 'Fixed GCC startup pass registry, context controls and selected coverage path buffers',
    'verified_source_files': len(identity['files']),
    'pass_instances_upper': len(rows), 'distinct_factory_count': len(census),
    'pass_factory_census': census, 'pass_name_inventory': names,
    'maximum_pass_name_characters': maximum_name,
    'default_member_map_instances': 4,
    'pass_name_map_capacity_sequence': growth,
    'additional_GGC_events_from_this_component': 0,
    'individual_fixed_ordinary_requests': fixed_requests,
    'path_cases': [paths(n) for n in (127, 4096, 2**29)],
    'path_formula': {'coverage_data_filename': '2*P+7',
                     'getpwd_owned_buffer': 'max(G,2*(P+1)); G<=4097 on selected Linux interface',
                     'condition': '2*P+7<=INT_MAX; individual request<=PTRDIFF_MAX'},
    'no_aggregate_memory_limit': True,
    'fixed_pass_startup_component_complete': True,
    'all_GCC_startup_and_static_exit_complete': False,
    'whole_invocation_event_count_complete': False,
    'boundary': 'Stop at allocator, getcwd, standard-library and OS interfaces; no host-internal capacity gate',
}
a.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'sources': len(identity['files']), 'factories': len(census),
                  'instances': len(rows), 'largest_fixed_request': 65536}))
