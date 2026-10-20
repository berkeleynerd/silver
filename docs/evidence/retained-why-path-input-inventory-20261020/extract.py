#!/usr/bin/env python3
"""Direct finite inventories of retained bytes; no observer or process replay.

The lexical/declaration census is deliberately not a WhyML parser or a proof
that generated names and namespace paths stay within these candidate maxima.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
E = ROOT / 'docs/evidence'
CAPTURE = E / 'retained-why-save-state-capture-20261020'
FIXED = E / 'retained-producer-fixed-context-20261018'
WHY = E / 'retained-why-session-helper-source-20261019'
SERIALIZER = E / 'retained-why-save-serializer-inputs-20261020/result.json'
FILES = ['int', 'real', 'algebra', 'relations']
CASES = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']
RANGES = {
    'why3/src/core/theory.ml': [(286, 355), (472, 510), (919, 946), (1020, 1075)],
    'why3/src/core/ident.ml': [(77, 84), (158, 173)],
    'why3/src/core/ty.ml': [(278, 287)],
    'why3/src/core/term.ml': [(1037, 1048)],
    'why3/src/parser/lexer.mll': [(28, 53), (76, 85), (108, 113), (168, 187)],
    'why3/src/util/lexlib.mll': [(82, 96)],
    'why3/src/parser/parser_common.mly': [(371, 399), (1504, 1526), (1543, 1585)],
    'why3/src/parser/typing.ml': [(1713, 1745), (1800, 1820), (1907, 1955)],
    'why3/src/mlw/pmodule.ml': [(410, 470)],
}
SITE_PATTERN = re.compile(r'\b(?:id_fresh|id_clone|id_derive|open_scope|store_path|store_theory)\b')


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def get(path):
    return json.loads(path.read_bytes())


class Inputs:
    def __init__(self):
        self.paths = {}
        self.members = {}
        self.opened = {}

    def file(self, path):
        raw = path.read_bytes()
        self.paths[str(path.relative_to(ROOT))] = identity(raw)
        return raw

    def member(self, archive, member, expected=None):
        if archive not in self.opened:
            # Bind the actual archive as well as every selected member.
            self.file(archive)
            self.opened[archive] = tarfile.open(archive)
        raw = self.opened[archive].extractfile(member).read()
        actual = identity(raw)
        if expected is not None:
            assert actual == {k: expected[k] for k in ('bytes', 'sha256')}, member
        self.members[str(archive.relative_to(ROOT)) + ':' + member] = actual
        return raw

    def close(self):
        for archive in self.opened.values():
            archive.close()


def mask_comments_strings(text):
    """Keep byte offsets/newlines; remove nested comments and quoted strings.

    The lexer gives '(*)' its special longest-match rule before '(*'. These
    installed files are ASCII, and their strings contain no escaped newlines.
    """
    assert text.isascii()
    out = list(text)
    comments, strings = [], []
    i = 0
    while i < len(text):
        if text.startswith('(*)', i):
            i += 3
        elif text.startswith('(*', i):
            first, depth = i, 1
            i += 2
            while depth:
                assert i < len(text), 'unterminated retained comment'
                if text.startswith('(*)', i):
                    i += 3
                elif text.startswith('(*', i):
                    depth += 1
                    i += 2
                elif text.startswith('*)', i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
            comments.append({'first_byte': first, 'past_last_byte': i})
            for j in range(first, i):
                if text[j] != '\n':
                    out[j] = ' '
        elif text[i] == '"':
            first = i
            i += 1
            while True:
                assert i < len(text), 'unterminated retained string'
                if text[i] == '\\':
                    i += 2
                elif text[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
            strings.append({'first_byte': first, 'past_last_byte': i,
                            'source_literal': text[first:i]})
            for j in range(first, i):
                if text[j] != '\n':
                    out[j] = ' '
        else:
            i += 1
    return ''.join(out), comments, strings


def line_at(text, offset):
    return text.count('\n', 0, offset) + 1


def encode_operator(name):
    # Only simple symbolic operators occur in these declared symbol heads.
    assert name.startswith('(') and name.endswith(')'), name
    op = name[1:-1].strip()
    if op.endswith('_'):
        return 'prefix ' + op[:-1]
    if op.startswith(('!', '?')):
        return 'prefix ' + op
    return 'infix ' + op


def maximum(rows, key):
    n = max((r[key] for r in rows), default=0)
    return {'bytes': n, 'witnesses': [r for r in rows if r[key] == n]}


def library_inventory(inputs):
    manifest = json.loads(inputs.file(FIXED / 'identity.json'))
    archive = FIXED / 'sources.tar.gz'
    assert identity(archive.read_bytes())['sha256'] == manifest['source_archive_sha256']
    declared_manifest = {r['path']: r for r in manifest['files']}
    output, module_names = [], set()
    for library in FILES:
        member = f'installed/libexec/spark/share/why3/theories/{library}.mlw'
        raw = inputs.member(archive, member, declared_manifest[member])
        text = raw.decode('ascii')
        masked, comments, strings = mask_comments_strings(text)
        modules, dependencies, symbols, scopes, identifiers, operators = [], [], [], [], [], []
        current = None
        block_stack = []
        module_ends = 0
        interface_keywords = []
        for number, line in enumerate(masked.splitlines(), 1):
            m = re.match(r'^\s*(module|theory)\s+([A-Za-z_][A-Za-z_0-9\']*)\s*$', line)
            if m:
                assert not block_stack, ('nested module', library, number)
                block_stack.append('module')
                current = library + '.' + m[2]
                modules.append({'line': number, 'kind': m[1], 'name': m[2], 'qualified': current,
                                'bytes': len(m[2]), 'source_head_without_comments_strings': line.strip(),
                                'plain_unqualified_module_head_without_interface_colon': True})
                assert current not in module_names
                module_names.add(current)
            for block in re.findall(r'\b(match|begin|end)\b', line):
                if block in ('match', 'begin'):
                    block_stack.append(block)
                else:
                    assert block_stack, ('unmatched end', library, number)
                    if block_stack.pop() == 'module':
                        module_ends += 1
            if re.search(r'\binterface\b', line):
                interface_keywords.append({'line': number, 'text': line})
            if re.match(r'^\s*(module|theory)\b', line):
                assert m is not None, ('unsupported module head', library, number)
            m = re.match(r'^\s*(use|clone)\s+(?:(export|import)\s+)?([A-Za-z_][A-Za-z_0-9\'.]*)(?:\s+as\s+([A-Za-z_][A-Za-z_0-9\']*))?', line)
            if m:
                assert current is not None
                target = m[3] if '.' in m[3] else library + '.' + m[3]
                dependencies.append({'line': number, 'module': current, 'kind': m[1],
                    'mode': m[2], 'source_target': m[3], 'target': target, 'alias': m[4],
                    'namespace_candidate': None if m[2] == 'export' else (m[4] or m[3].rsplit('.', 1)[-1])})
            m = re.match(r'^\s*scope\s+(?:import\s+)?([A-Za-z_][A-Za-z_0-9\']*)', line)
            if m:
                scopes.append({'line': number, 'module': current, 'name': m[1], 'bytes': len(m[1])})
            m = re.match(r'^\s*((?:let|val)\s+(?:(?:rec|ghost|function|predicate|lemma|constant)\s+)*|(?:type|constant|function|predicate|axiom|lemma|goal|inductive|coinductive)\s+)(\([^()]+\)|[A-Za-z_][A-Za-z_0-9\']*)', line)
            if m:
                encoded = encode_operator(m[2]) if m[2].startswith('(') else m[2]
                symbols.append({'line': number, 'module': current, 'kind': m[1].strip(),
                                'source_name': m[2], 'encoded_name': encoded, 'bytes': len(encoded)})
                if m[1].strip() == 'type' and '=' in line:
                    for constructor in re.finditer(r'(?:=|\|)\s*([A-Z][A-Za-z_0-9\']*)', line):
                        symbols.append({'line': number, 'module': current, 'kind': 'type_constructor',
                            'source_name': constructor[1], 'encoded_name': constructor[1], 'bytes': len(constructor[1])})
            m = re.match(r'^\s*\|\s*([A-Za-z_][A-Za-z_0-9\']*)\s*:', line)
            if m:
                symbols.append({'line': number, 'module': current, 'kind': 'inductive_case',
                    'source_name': m[1], 'encoded_name': m[1], 'bytes': len(m[1])})
        assert not block_stack and module_ends == len(modules)
        assert not interface_keywords
        assert not re.search(r'\b(scope|namespace|interface)\b', masked)
        excluded_keywords = {word: [line_at(masked, m.start()) for m in re.finditer(r'\b' + word + r'\b', masked)]
                             for word in ['invariant', 'witness', 'by', 'exception', 'mutable', 'private', 'scope', 'namespace', 'interface']}
        assert all(not rows for rows in excluded_keywords.values())
        # Capture each complete clone declaration through the next declaration
        # head, rather than checking only its often-short first line.
        declarations = list(re.finditer(r'(?m)^(?P<indent>[ \t]*)(?:module|theory|end|use|clone|type|constant|function|predicate|axiom|lemma|goal|inductive|coinductive|let|val|meta|scope)\b', masked))
        for dep in dependencies:
            if dep['kind'] != 'clone':
                continue
            head = next(m for m in declarations if line_at(masked, m.start()) == dep['line'])
            start = head.start()
            # In these exact files module-level declarations return to the
            # clone's indentation; substitution continuation heads are deeper.
            # Retain the full span so this source-specific selection is reviewable.
            following = next((m.start() for m in declarations if m.start() > start
                              and len(m['indent']) <= len(head['indent'])), len(masked))
            declaration = masked[start:following].strip()
            pieces = re.split(r'\bwith\b', declaration, maxsplit=1)
            subst = pieces[1] if len(pieces) == 2 else ''
            dep['declaration_text_without_comments_strings'] = declaration
            dep['declaration_span_first_line'] = dep['line']
            dep['declaration_span_past_last_line'] = line_at(masked, following)
            dep['declaration_span_selection'] = 'next declaration head at the same or lower indentation; complete retained span included'
            dep['substitution_kind_candidates'] = sorted(set(re.findall(r'\b(type|constant|function|predicate|axiom|lemma|goal|val|exception)\b', subst)))
            assert 'val' not in dep['substitution_kind_candidates']
            assert 'exception' not in dep['substitution_kind_candidates']
        for m in re.finditer(r'[A-Za-z_][A-Za-z_0-9\']*', masked):
            identifiers.append({'line': line_at(masked, m.start()), 'first_byte': m.start(),
                                'name': m[0], 'bytes': len(m[0])})
        # Candidate parenthesized operators, including references and selectors.
        for m in re.finditer(r'\(\s*([=<>~+*/\\%!$&?@^.:|#\-]+_?)\s*\)', masked):
            encoded = encode_operator('(' + m[1] + ')')
            operators.append({'line': line_at(masked, m.start()), 'first_byte': m.start(),
                'source_name': m[0], 'encoded_name': encoded, 'bytes': len(encoded)})
        output.append({'library': library, 'member': member, 'identity': identity(raw),
            'comments': comments, 'string_literals': strings, 'modules': modules,
            'dependencies': dependencies, 'scope_heads': scopes, 'declared_symbol_head_candidates': symbols,
            'module_end_count': module_ends, 'nested_module_head_count': 0,
            'module_interface_keyword_occurrences': interface_keywords,
            'module_head_interface_colon_count': 0,
            'clone_val_exception_substitution_candidate_count': 0,
            'typed_source_excluded_keyword_occurrence_lines': excluded_keywords,
            'type_head_candidates': [s for s in symbols if s['kind'] == 'type'],
            'identifier_candidates': identifiers, 'parenthesized_operator_candidates': operators,
            'max_identifier_candidate': maximum(identifiers, 'bytes'),
            'max_declared_symbol_head_candidate': maximum(symbols, 'bytes'),
            'max_parenthesized_operator_candidate': maximum(operators, 'bytes')})
    dependencies = [d for f in output for d in f['dependencies']]
    module_positions = {m['qualified']: (f['library'], m['line']) for f in output for m in f['modules']}
    for dep in dependencies:
        if dep['target'] in module_positions:
            source_file, source_line = module_positions[dep['module']]
            target_file, target_line = module_positions[dep['target']]
            if source_file == target_file:
                assert target_line < source_line, ('non-prior same-file dependency', dep)
    external = sorted({d['target'] for d in dependencies if d['target'] not in module_names})
    assert external == ['why3.WellFounded.WellFounded']
    namespace = [{'library': f['library'], 'line': d['line'], 'name': d['namespace_candidate'],
                  'bytes': len(d['namespace_candidate']), 'kind': d['kind'], 'module': d['module']}
                 for f in output for d in f['dependencies'] if d['namespace_candidate'] is not None]
    graph = {name: [] for name in module_names}
    for d in dependencies:
        graph[d['module']].append(d['target'])
    memo = {}

    def chain(name, active):
        assert name not in active, ('cyclic source declaration graph', name)
        if name not in memo:
            successors = [chain(n, active | {name}) for n in graph.get(name, [])]
            memo[name] = [name] + max(successors, key=len, default=[])
        return memo[name]

    longest = max((chain(n, set()) for n in sorted(graph)), key=len)
    topological = sorted(module_names | set(external), key=lambda n: (len(chain(n, set())), n))
    ranks = {name: rank for rank, name in enumerate(topological)}
    assert all(ranks[d['target']] < ranks[d['module']] for d in dependencies)
    weighted_memo = {}

    def namespace_chain(name):
        if name not in weighted_memo:
            candidates = []
            for d in dependencies:
                if d['module'] == name:
                    suffix = namespace_chain(d['target'])
                    label = [] if d['kind'] != 'clone' or d['namespace_candidate'] is None else [
                        {'module': name, 'line': d['line'], 'name': d['namespace_candidate'],
                         'bytes': len(d['namespace_candidate'])}]
                    candidates.append(label + suffix)
            weighted_memo[name] = max(candidates, key=len, default=[])
        return weighted_memo[name]

    longest_namespace = max((namespace_chain(n) for n in sorted(graph)), key=len)
    return {'requested_theories': ['int.Int', 'int.ComputerDivision', 'real.Real', 'real.Truncate'],
        'selection_policy': 'complete retained installed source files and complete-file use/clone dependency declarations',
        'why3_revision': manifest['why3_revision'], 'files': output,
        'total_source_bytes': sum(f['identity']['bytes'] for f in output),
        'module_count': len(module_names), 'dependency_declaration_count': len(dependencies),
        'external_targets': external, 'external_target_source': 'retained pmodule.ml builtin constructor; not another installed mlw file',
        'namespace_candidates': namespace, 'max_namespace_candidate': maximum(namespace, 'bytes'),
        'max_identifier_candidate': maximum([r for f in output for r in f['identifier_candidates']], 'bytes'),
        'max_declared_symbol_head_candidate': maximum([r for f in output for r in f['declared_symbol_head_candidates']], 'bytes'),
        'max_parenthesized_operator_candidate': maximum([r for f in output for r in f['parenthesized_operator_candidates']], 'bytes'),
        'explicit_scope_head_count': sum(len(f['scope_heads']) for f in output),
        'longest_source_dependency_chain': longest, 'source_dependency_chain_nodes': len(longest),
        'source_dependency_graph_acyclic': True,
        'dependency_before_importer_topological_module_order': topological,
        'same_file_dependencies_reference_prior_module_heads': True,
        'longest_clone_nonexport_namespace_candidate_ancestry': longest_namespace,
        'clone_nonexport_namespace_candidate_ancestry_edges_max': len(longest_namespace),
        'module_interface_keyword_count': 0, 'module_head_interface_colon_count': 0,
        'all_module_heads_are_plain_unqualified_names': True, 'nested_module_head_count': 0,
        'clone_val_exception_substitution_candidate_count': 0,
        'typed_source_excluded_keyword_counts': {word: sum(len(f['typed_source_excluded_keyword_occurrence_lines'][word]) for f in output)
            for word in output[0]['typed_source_excluded_keyword_occurrence_lines']},
        'semantic_generated_name_max': None, 'semantic_namespace_path_depth_max': None,
        'semantic_new_third_component_bytes_max': None,
        'candidate_census_is_semantic_bound': False}


class Unknown(Exception):
    pass


class Blocks:
    def __init__(self, raw):
        self.rows = {}
        for line in raw.splitlines():
            row = json.loads(line)
            p = row['address']
            assert p not in self.rows or self.rows[p] == row
            self.rows[p] = row

    def raw(self, p, tag=None, words=None):
        if p not in self.rows:
            raise Unknown(p)
        row = self.rows[p]
        assert tag is None or row['tag'] == tag, (p, 'tag')
        assert words is None or row['words'] == words, (p, 'words')
        raw = bytes.fromhex(row['payload_hex'])
        assert len(raw) == 8 * row['words']
        return raw

    def fields(self, p, tag=0, words=None):
        raw = self.raw(p, tag, words)
        return struct.unpack('<' + 'Q' * (len(raw) // 8), raw)

    def string(self, p):
        raw = self.raw(p, 252)
        assert raw and raw[-1] <= 7
        size = len(raw) - raw[-1] - 1
        assert raw[size] == 0
        value = raw[:size]
        return {'pointer': p, **identity(value), 'hex': value.hex(),
                'text_utf8': value.decode('utf-8')}

    def path(self, p):
        cursor, seen, parts = p, set(), []
        while cursor != 1:
            assert cursor not in seen, 'captured path cycle'
            seen.add(cursor)
            value, cursor = self.fields(cursor, words=2)
            parts.append(self.string(value))
        total = sum(r['bytes'] for r in parts)
        return {'pointer': p, 'components': parts, 'component_count': len(parts),
                'total_bytes': total, 'joined_dot_bytes': total + max(0, len(parts) - 1)}

    def payload(self, p):
        library, theory, qualified = self.fields(p, words=3)
        return {'pointer': p, 'library_path': self.path(library),
                'theory_name': self.string(theory), 'qualified_path': self.path(qualified)}

    def tag(self, p):
        value = self.fields(p, words=4)[3]
        assert value & 1
        return (value - (1 << 64) if value >= (1 << 63) else value) >> 1


def known(operation):
    try:
        return operation(), None
    except Unknown as error:
        return None, error.args[0]


def integer(value):
    assert value & 1
    return (value - (1 << 64) if value >= (1 << 63) else value) >> 1


def check_current_table(restore, blocks):
    size, array, seed, initial = blocks.fields(restore['table'], words=4)
    assert [integer(v) for v in (size, seed, initial)] == [restore[k] for k in ('size', 'seed', 'initial_size')]
    heads = blocks.fields(array)
    assert list(heads) == restore['bucket_heads']
    assert len(heads) == restore['bucket_capacity']
    rows, seen = [], set()
    for bucket, cursor in enumerate(heads):
        while cursor != 1:
            assert cursor not in seen
            seen.add(cursor)
            hashed, ephemeron, following = blocks.fields(cursor, words=3)
            _link, data, key = blocks.fields(ephemeron, tag=251, words=3)
            hashed = integer(hashed)
            assert hashed & (len(heads) - 1) == bucket
            rows.append({'bucket': bucket, 'cell': cursor, 'hash': hashed,
                         'ephemeron': ephemeron, 'key': key, 'data': data, 'next': following})
            cursor = following
    assert rows == restore['entries']
    return array


def capture_inventory(inputs):
    manifest = json.loads(inputs.file(CAPTURE / 'capture-manifest.json'))
    serializer = json.loads(inputs.file(SERIALIZER))
    by_case = {r['case']: r for r in serializer['cases']}
    results = []
    common = next(a for a in manifest['archives'] if a['path'] == 'capture-common.tar.gz')
    collector_member = next(r for r in common['members'] if r['path'] == 'registration/missing_state.py')
    collector = inputs.member(CAPTURE / common['path'], collector_member['path'], collector_member)
    assert b'def restore_paths(self)' in collector
    for case in CASES:
        group = 'inline' if case == 'input_is_valid' else 'registration'
        prefix = f'{group}/{case}/capture/'
        archive = next(a for a in manifest['archives'] if any(r['path'] == prefix + 'save-missing-state.json' for r in a['members']))
        rows = {r['path']: r for r in archive['members']}
        proj_raw = inputs.member(CAPTURE / archive['path'], prefix + 'save-missing-state.json', rows[prefix + 'save-missing-state.json'])
        block_raw = inputs.member(CAPTURE / archive['path'], prefix + 'session-blocks.jsonl', rows[prefix + 'session-blocks.jsonl'])
        projection = json.loads(proj_raw)
        assert projection['complete'] and not projection['failures']
        restore = projection['sections']['restore_paths']['value']
        assert projection['sections']['restore_paths']['known']
        assert restore['disjoint_finite_chains'] and restore['size_equals_binding_visits']
        assert len(restore['entries']) == restore['binding_visits'] == restore['size']
        blocks = Blocks(block_raw)
        array = check_current_table(restore, blocks)
        hashes = Counter(r['hash'] for r in restore['entries'])
        assert max(hashes.values()) == 1
        live_rows, dead_rows, decoded, key_tags = [], [], [], []
        for index, row in enumerate(restore['entries']):
            if row['key'] == restore['ephe_none'] or row['data'] == restore['ephe_none']:
                dead_rows.append(index)
                continue
            live_rows.append(index)
            tag, key_missing = known(lambda: blocks.tag(row['key']))
            if tag is not None:
                key_tags.append({'entry_index': index, 'cached_hash': row['hash'], 'key_tag': tag})
            payload, data_missing = known(lambda: blocks.payload(row['data']))
            if payload is not None:
                decoded.append({'entry_index': index, 'cached_hash': row['hash'], 'key_tag': tag,
                                'payload': payload})
        inv = by_case[case]['inventory']
        required = {r['ident']['pointer']: r for r in restore['required_identifiers']}
        selections = []
        for identifier in inv['identifiers']:
            if not identifier['serializer_visits']:
                continue
            tag = identifier['id_tag']
            candidates = []
            for index, row in enumerate(restore['entries']):
                if row['hash'] != tag:
                    continue
                key_tag, key_missing = known(lambda: blocks.tag(row['key']))
                payload, data_missing = known(lambda: blocks.payload(row['data']))
                candidates.append({'entry_index': index, 'entry': row, 'key_tag': key_tag,
                    'key_missing_address': key_missing, 'payload': payload,
                    'payload_missing_address': data_missing})
            assert len(candidates) <= 1
            if candidates:
                candidate, = candidates
                assert candidate['key_tag'] == tag and candidate['payload'] is not None
                captured = required[identifier['pointer']]
                assert candidate['entry'] == captured['binding']
                assert candidate['payload']['qualified_path']['joined_dot_bytes'] == identifier['captured_qualified_path']['joined_dot_bytes']
            else:
                assert not identifier['captured_binding_present']
            qualified_bytes = max((r['payload']['qualified_path']['joined_dot_bytes'] for r in candidates), default=0)
            selections.append({'identifier_pointer': identifier['pointer'], 'id_tag': tag,
                'serializer_visits': identifier['serializer_visits'], 'fallback': identifier['fallback'],
                'cached_hash_matching_row_count': len(candidates), 'candidates': candidates,
                'fallback_or_any_current_candidate_bytes_upper': max(identifier['fallback']['bytes'], qualified_bytes)})
        known_qualified = [r['payload']['qualified_path'] for r in decoded]
        all_payloads = len(decoded) == len(live_rows)
        assert len(selections) == len({r['id_tag'] for r in selections})
        selected_upper = sum(r['serializer_visits'] * r['fallback_or_any_current_candidate_bytes_upper'] for r in selections)
        assert selected_upper == inv['field_totals']['identifier_fallback_or_captured_qualified_bytes_upper']
        results.append({'case': case, 'phase': projection['phase'],
            'projection_member': prefix + 'save-missing-state.json', 'projection_identity': identity(proj_raw),
            'raw_block_member': prefix + 'session-blocks.jsonl', 'raw_block_identity': identity(block_raw),
            'current_table_root': restore['table'], 'current_bucket_array': array,
            'current_bucket_capacity': restore['bucket_capacity'],
            'current_cell_projection_matches_retained_raw_blocks': True,
            'current_entry_count': len(restore['entries']), 'current_live_key_data_pointer_pair_count': len(live_rows),
            'current_dead_entry_indices': dead_rows, 'distinct_cached_hash_count': len(hashes),
            'cached_hash_max_multiplicity': max(hashes.values()),
            'cached_hash_sorted_list_identity': identity(json.dumps(sorted(hashes), separators=(',', ':')).encode()),
            'decoded_current_key_tag_count': len(key_tags), 'decoded_current_payload_count': len(decoded),
            'all_current_key_tags_decoded': len(key_tags) == len(live_rows),
            'all_current_payloads_decoded': all_payloads,
            'current_third_component_joined_bytes_max': max((r['joined_dot_bytes'] for r in known_qualified), default=0) if all_payloads else None,
            'current_third_component_count_max': max((r['component_count'] for r in known_qualified), default=0) if all_payloads else None,
            'observed_partial_third_component_joined_bytes_max': max((r['joined_dot_bytes'] for r in known_qualified), default=0),
            'observed_partial_third_component_count_max': max((r['component_count'] for r in known_qualified), default=0),
            'decoded_current_payloads': decoded, 'serialized_identifier_selections': selections,
            'serialized_identifier_count': len(selections),
            'serialized_tags_without_current_cached_hash_match': sum(not r['candidates'] for r in selections),
            'serialized_tags_with_one_current_cached_hash_match': sum(bool(r['candidates']) for r in selections),
            'serialized_tags_with_duplicate_current_cached_hash_matches': sum(len(r['candidates']) > 1 for r in selections),
            'serialized_identifier_current_candidate_weighted_bytes_upper': selected_upper,
            'captured_current_serialized_candidate_set_complete_under_cached_hash_premise': True,
            'old_bucket_array_roots': None, 'active_resize_frame_roots': None,
            'old_bucket_array_exclusion_established_by_this_inventory': False,
            'complete_initial_selectable_payload_set_established': False,
            'whole_interval_identifier_bytes_upper': None})
    return {'cached_hash_selection_premise': 'Ident.hash uses numeric id_tag; selection requires cached_hash = queried id_tag before key comparison',
        'raw_coverage_scope': 'exact retained session-blocks.jsonl; unknown raw block addresses stay unknown',
        'old_array_coverage': 'collector starts from closure table current bucket field only; no saved old-array or active-resize-frame root is selected',
        'collector_member': collector_member['path'], 'collector_identity': identity(collector), 'cases': results}


def sources(inputs):
    manifest = json.loads(inputs.file(WHY / 'source-identities.json'))
    excerpts, sites = [], []
    for member, ranges in RANGES.items():
        raw = inputs.member(WHY / 'sources.tar.gz', member, manifest['members'][member]['identity'])
        lines = raw.decode().splitlines(keepends=True)
        excerpts.append({'member': member, 'identity': identity(raw), 'ranges': [
            {'first': first, 'last': last, 'text': ''.join(lines[first-1:last])}
            for first, last in ranges]})
    for member in ['why3/src/core/theory.ml', 'why3/src/parser/typing.ml',
                   'why3/src/mlw/pdecl.ml', 'why3/src/mlw/pmodule.ml']:
        raw = inputs.member(WHY / 'sources.tar.gz', member, manifest['members'][member]['identity'])
        for line, text in enumerate(raw.decode().splitlines(), 1):
            if SITE_PATTERN.search(text):
                sites.append({'member': member, 'line': line, 'text': text})
    census = json.loads(inputs.file(E / 'retained-why-restored-path-continuation-20261020/private-writer-census.json'))
    old_inputs = json.loads(inputs.file(E / 'retained-why-restored-path-continuation-20261020/inputs.json'))
    assert old_inputs['docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'] == inputs.paths[str((WHY / 'sources.tar.gz').relative_to(ROOT))]
    for row in census:
        raw = inputs.member(WHY / 'sources.tar.gz', row['member'], manifest['members'][row['member']]['identity'])
        assert raw.decode().splitlines()[row['line'] - 1] == row['text']
    return {'why3_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
            'excerpts': excerpts, 'generated_name_scope_and_writer_site_candidates': sites,
            'retained_complete_private_path_writer_census': census,
            'site_census_is_reachability_proof': False}


def backtrace_paths(value, prefix):
    found = []
    if isinstance(value, dict):
        for key, item in value.items():
            found += [prefix + '.' + key] if key == 'backtrace' else backtrace_paths(item, prefix + '.' + key)
    elif isinstance(value, list):
        for index, item in enumerate(value):
            found += backtrace_paths(item, prefix + f'[{index}]')
    return found


def cut_evidence(inputs):
    manifest = get(CAPTURE / 'capture-manifest.json')
    common = next(a for a in manifest['archives'] if a['path'] == 'capture-common.tar.gz')
    scripts = []
    for member, first, last in [('registration/probe.py', 32, 90), ('inline/entry-observer.py', 32, 88)]:
        row = next(r for r in common['members'] if r['path'] == member)
        raw = inputs.member(CAPTURE / common['path'], member, row)
        scripts.append({'member': member, 'identity': identity(raw), 'first': first, 'last': last,
                        'text': ''.join(raw.decode().splitlines(keepends=True)[first-1:last])})
    results = []
    for case in CASES:
        group = 'inline' if case == 'input_is_valid' else 'registration'
        prefix = f'{group}/{case}/capture/'
        archive = next(a for a in manifest['archives'] if any(r['path'] == prefix + 'summary.json' for r in a['members']))
        rows = {r['path']: r for r in archive['members']}
        raw = inputs.member(CAPTURE / archive['path'], prefix + 'summary.json', rows[prefix + 'summary.json'])
        summary = json.loads(raw)
        assert summary['completed'] and not summary['failures']
        traces = backtrace_paths(summary, 'summary')
        assert all(path.startswith('summary.startup_guard_hits[') for path in traces)
        preparation = summary.get('driver_preparation')
        results.append({'case': case, 'summary_member': prefix + 'summary.json',
            'summary_identity': identity(raw), 'completed': summary['completed'],
            'final_snapshot_label': summary['snapshots'][-1]['label'],
            'final_snapshot_pc': summary['snapshots'][-1]['pc'],
            'protected_guard_hit_count': len(summary['guard_hits']),
            'retained_summary_backtrace_paths': traces,
            'all_retained_summary_backtraces_are_startup_guard_traces': True,
            'driver_preparation_directives': None if preparation is None else [r['directives'] for r in preparation],
            'driver_preparation_visited_directives': None if preparation is None else [r['visited_directives'] for r in preparation],
            'endpoint_call_stack_frames': None, 'active_resize_frame_exclusion_established': False})
    return {'scope': 'selected stopped phase markers and summary backtrace locations; no endpoint stack inference',
            'collector_source_excerpts': scripts, 'cases': results,
            'active_resize_frame_exclusion_established': False}


def build():
    inputs = Inputs()
    try:
        library = library_inventory(inputs)
        capture = capture_inventory(inputs)
        witnesses = sources(inputs)
        cuts = cut_evidence(inputs)
        result = {'scope': 'retained bytes only; finite candidate inventory, no new captures or continuation proof',
            'library_total_source_bytes': library['total_source_bytes'],
            'library_module_count': library['module_count'],
            'library_dependency_declaration_count': library['dependency_declaration_count'],
            'library_identifier_candidate_bytes_max': library['max_identifier_candidate']['bytes'],
            'library_declared_symbol_head_candidate_bytes_max': library['max_declared_symbol_head_candidate']['bytes'],
            'library_namespace_candidate_bytes_max': library['max_namespace_candidate']['bytes'],
            'library_explicit_scope_head_count': library['explicit_scope_head_count'],
            'library_source_dependency_chain_nodes': library['source_dependency_chain_nodes'],
            'library_source_dependency_graph_acyclic': library['source_dependency_graph_acyclic'],
            'library_typed_source_excluded_keyword_counts': library['typed_source_excluded_keyword_counts'],
            'library_semantic_third_component_bytes_max': None,
            'cases': [{k: row[k] for k in ('case', 'current_entry_count', 'distinct_cached_hash_count',
                'cached_hash_max_multiplicity', 'decoded_current_payload_count',
                'serialized_identifier_count', 'serialized_tags_without_current_cached_hash_match',
                'serialized_tags_with_one_current_cached_hash_match',
                'serialized_tags_with_duplicate_current_cached_hash_matches',
                'serialized_identifier_current_candidate_weighted_bytes_upper',
                'current_third_component_joined_bytes_max', 'old_bucket_array_roots',
                'active_resize_frame_roots', 'whole_interval_identifier_bytes_upper')}
                for row in capture['cases']],
            'native_runs': 0, 'solver_requests': 0, 'source_fetches': 0, 'new_captures': 0,
            'observer_replays': 0, 'binder_recomputations': 0, 'alpha_replays': 0,
            'whole_interval_name_bound_established': False}
        return {'library-inventory.json': library, 'capture-inventory.json': capture,
                'source-witnesses.json': witnesses, 'cut-evidence.json': cuts, 'result.json': result,
                'inputs.json': {'files': inputs.paths, 'selected_archive_members': inputs.members}}
    finally:
        inputs.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    for name, data in build().items():
        raw = (json.dumps(data, indent=2) + '\n').encode()
        if args.check:
            assert (HERE / name).read_bytes() == raw, ('retained output differs', name)
        else:
            (HERE / name).write_bytes(raw)
    print('retained path-input inventory matches' if args.check else 'retained path-input inventory written')


if __name__ == '__main__':
    main()
