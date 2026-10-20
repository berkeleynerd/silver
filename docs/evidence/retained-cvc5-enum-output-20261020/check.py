#!/usr/bin/env python3
"""Offline generated-enum spelling inventory; no compiler or solver execution."""
import argparse
import gzip
import hashlib
import io
import json
import pathlib
import re
import tarfile
import tomllib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ARCHIVE = ROOT / 'docs/evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz'
REVISION = '86cecd83b685f59e884094693b9a4c5c90a62e03'
ARCHIVE_SHA256 = '19d7bbe18166fa175ff537f226e8df5e229b6a28497cb823f82eb734ceed684c'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def clean(text):
    """Remove C++ comments while preserving quoted string tokens."""
    return re.sub(r'"(?:\\.|[^"\\])*"|/\*.*?\*/|//[^\n]*',
                  lambda m: m[0] if m[0].startswith('"') else ' ', text,
                  flags=re.S)


def body(text, signature):
    text = clean(text)
    start = text.index('{', text.index(signature))
    depth = 0
    for token in re.finditer(r'"(?:\\.|[^"\\])*"|[{}]', text[start:]):
        if token[0] == '{':
            depth += 1
        elif token[0] == '}':
            depth -= 1
            if depth == 0:
                return text[start + 1:start + token.start()]
    raise AssertionError(signature)


def literal_cases(text, prefix):
    """All case -> literal routes, including labels sharing one return."""
    result = {}
    pattern = r'((?:case\s+' + re.escape(prefix) + r'(\w+)\s*:\s*)+)return\s+("(?:\\.|[^"\\])*")\s*;'
    for match in re.finditer(pattern, text):
        spelling = json.loads(match[3])
        for name in re.findall(r'case\s+' + re.escape(prefix) + r'(\w+)\s*:', match[1]):
            assert name not in result
            result[name] = spelling
    return result


def domain(mapping, fallback=None):
    spellings = set(mapping.values())
    if fallback is not None:
        spellings.add(fallback)
    spellings = sorted(spellings)
    lengths = [len(s.encode('utf-8')) for s in spellings]
    k, total = len(spellings), sum(lengths)
    return dict(mapped_routes=len(mapping), fallback=fallback, distinct_spellings=k,
                spelling_bytes=total, maximum_spelling_bytes=max(lengths),
                ordinary_histogram_allowance=4 + total + 24*k,
                mapped_route_spelling_bytes=sum(len(s.encode('utf-8')) for s in mapping.values()),
                spellings=spellings)


def sexpr_headers(text):
    """Lex balanced DSL forms, respecting strings and ; line comments.

    This deliberately does not type-check DSL expressions. Each top-level form
    must have one of Parser.parse_rules' three tags and a valid symbol name.
    The header is all mkrewrites' printer spelling depends on.
    """
    tokens = re.finditer(r';[^\n]*|"(?:\\.|[^"\\])*"|[()]|[^\s();"]+', text)
    depth, head, forms, start_line = 0, [], [], 0
    for token in tokens:
        val = token[0]
        if val.startswith(';'):
            continue
        if val == '(':
            depth += 1
            if depth == 1:
                head = []
                start_line = text.count('\n', 0, token.start()) + 1
        elif val == ')':
            depth -= 1
            assert depth >= 0
            if depth == 0:
                assert len(head) == 2
                tag, name = head
                assert tag in ('define-rule', 'define-rule*', 'define-cond-rule')
                assert re.fullmatch(r'[A-Za-z=_+\-<>*.@/^][A-Za-z0-9=_+\-<>*.@/^]*', name)
                forms.append(dict(tag=tag, name=name, enum=name.replace('-', '_').upper(),
                                  line=start_line))
        elif depth == 1:
            if len(head) < 2:
                head.append(val)
        else:
            assert depth > 0
    assert depth == 0 and forms
    return forms


def generate():
    archive_bytes = ARCHIVE.read_bytes()
    assert sha(archive_bytes) == ARCHIVE_SHA256
    with tarfile.open(ARCHIVE) as tf:
        files = {m.name.split('/', 1)[1]: tf.extractfile(m).read()
                 for m in tf if m.isfile()}
    used = {}

    def read(path):
        data = files[path]
        used[path] = dict(bytes=len(data), sha256=sha(data))
        return data.decode('utf-8')

    cmake = read('src/CMakeLists.txt')

    def inputs(name):
        match = re.search(r'set\(' + name + r'\s+(.*?)\)', cmake, re.S)
        assert match
        return re.findall(r'\$\{PROJECT_SOURCE_DIR\}/([^\s)]+)', match[1])

    kind_files = inputs('KINDS_TOML_FILES')
    normal_files, expert_files = inputs('REWRITES_FILES'), inputs('REWRITES_FILES_EXPERT')
    assert len(kind_files) == 14 and len(normal_files) == 11 and len(expert_files) == 2
    kinds, sorts, toml_inputs = [], {}, []
    for path in kind_files:
        data = tomllib.loads(read(path))
        local = []
        for item in data['kinds']:
            typ = item['type']
            if typ == 'sort':
                assert item['name'] not in sorts
                sorts[item['name']] = item.get('comment', '')
            else:
                assert typ in ('variable', 'operator', 'parameterized', 'constant', 'nullaryoperator')
                name = item['K1'] if typ == 'parameterized' else item['name']
                kinds.append(name)
                local.append(dict(type=typ, name=name))
        toml_inputs.append(dict(path=path, kinds=local))
    assert len(kinds) == len(set(kinds))
    generated = {name: name for name in kinds}
    generated.update(UNDEFINED_KIND='UNDEFINED_KIND', NULL_EXPR='NULL', LAST_KIND='LAST_KIND')
    internal_ast = domain(generated, '?')
    type_constant = domain(sorts, 'UNKNOWN_TYPE_CONSTANT')

    template = read('src/expr/kind_template.cpp')
    assert '${kind_printers}' in template and '${type_constant_descriptions}' in template
    assert 'Printer::getPrinter(out)->toStream(out, k)' in template
    assert 'std::string kindToString(cvc5::internal::Kind k) { return toString(k); }' in template
    assert 'default: return "?";' in body(template, 'const char* toString(cvc5::internal::Kind k)')
    assert 'default: return "UNKNOWN_TYPE_CONSTANT";' in body(template, 'const char* toString(TypeConstant tc)')
    assert 'return out << toString(typeConstant);' in body(
        template, 'std::ostream& operator<<(std::ostream& out, TypeConstant typeConstant)')
    generator = read('src/expr/mkkind.py')
    assert 'case Kind::{kind_name}: return \\"{kind_name}\\";' in generator
    assert 'case {sort_name}: return \\"{sort_comment}\\";' in generator
    read('src/expr/kind_template.h')
    read('src/expr/theory_validator.py')
    expr_cmake = read('src/expr/CMakeLists.txt')
    assert '--kinds ${KINDS_TOML_FILES}' in expr_cmake

    smt_src = read('src/printer/smt2/smt2_printer.cpp')
    smt_body = body(smt_src, 'std::string Smt2Printer::smtKindString(Kind k)')
    assert 'out << smtKindString(k);' in body(
        smt_src, 'void Smt2Printer::toStream(std::ostream& out, Kind k)')
    smt = literal_cases(smt_body, 'Kind::')
    labels = set(re.findall(r'case Kind::(\w+):', smt_body))
    breaks = set(re.findall(r'case Kind::(\w+):\s*break;', smt_body))
    assert labels == set(smt) | breaks
    assert breaks == {'SEXPR', 'APPLY_UF'}
    assert labels <= set(generated)
    assert 'return kind::kindToString(k);' in smt_body
    internal_smt_mapping = {name: smt.get(name, val) for name, val in generated.items()}
    internal_smt = domain(internal_smt_mapping, '?')
    internal_union = domain({f'ast/{k}': v for k, v in generated.items()} |
                            {f'smt/{k}': v for k, v in internal_smt_mapping.items()}, '?')
    printer = read('src/printer/printer.cpp')
    factory = body(printer, 'unique_ptr<Printer> Printer::makePrinter(Language lang)')
    assert set(re.findall(r'case Language::(\w+):', factory)) == {
        'LANG_SMTLIB_V2_6', 'LANG_SYGUS_V2', 'LANG_AST'}
    assert 'lang = Language::LANG_SMTLIB_V2_6;' in printer
    assert 'out << kind::kindToString(k);' in body(read('src/printer/ast/ast_printer.cpp'),
                                                'void AstPrinter::toStream(std::ostream& out, Kind k)')
    read('src/printer/printer.h')
    read('src/options/language.h')

    api = read('src/api/cpp/cvc5.cpp')
    api_map_body = clean(api).split('s_kinds{', 1)[1].split('};', 1)[0]
    api_pairs = re.findall(r'KIND_ENUM\(Kind::(\w+),\s*internal::Kind::(\w+)\)', api_map_body)
    api_mapping = {name: name for name, _ in api_pairs}
    assert len(api_mapping) == len(api_pairs)
    api_header = clean(read('include/cvc5/cvc5_kind.h'))
    enum_body = api_header.split('enum ENUM(Kind)', 1)[1].split('};', 1)[0]
    api_values = re.findall(r'EVALUE\((\w+)(?:\s*=\s*-?\d+)?\)', enum_body)
    assert set(api_values) == set(api_mapping) and len(api_values) == len(api_mapping)
    assert 'std::string(#external_name).substr(6)' in api
    assert 'return out << std::to_string(k);' in body(api, 'std::ostream& operator<<(std::ostream& out, Kind k)')
    assert 'return "UNDEFINED_KIND";' in body(api, 'std::string to_string(cvc5::Kind k)')
    api_kind = domain(api_mapping, 'UNDEFINED_KIND')
    # A full source census confirms no API-Kind toString overload. Only a
    # deprecated kindToString / std::to_string exists; neither satisfies ADL.
    overload_candidates = []
    for path, data in files.items():
        if path.startswith(('src/', 'include/')) and path.endswith(('.h', '.cpp')):
            text = clean(data.decode('utf-8'))
            for m in re.finditer(r'\btoString\s*\(\s*(?:const\s+)?(?:(?:cvc5::)?Kind|(?:cvc5::)?Kind_t)\s+[a-zA-Z_]\w*\s*\)', text):
                overload_candidates.append(dict(path=path, text=m[0]))
    assert not overload_candidates

    proof_template = read('src/api/cpp/cvc5_proof_rule_template.cpp')
    proof_body = body(proof_template, 'const char* toString(ProofRule rule)')
    proof_mapping = literal_cases(proof_body, 'ProofRule::')
    assert set(proof_mapping) == set(re.findall(r'case ProofRule::(\w+):', proof_body))
    assert re.search(r'default\s*:\s*return "\?";', proof_body)
    proof_rule = domain(proof_mapping, '?')
    rewrite_body = body(proof_template, 'const char* toString(cvc5::ProofRewriteRule rule)')
    rewrite_mapping = literal_cases(rewrite_body, 'ProofRewriteRule::')
    assert '${printer}$' in rewrite_body
    assert re.search(r'default\s*:\s*return "\?";', rewrite_body)
    for typ in ('ProofRule', 'ProofRewriteRule'):
        assert 'out << toString(rule);' in body(
            proof_template, f'std::ostream& operator<<(std::ostream& out, {typ} rule)')
    rule_inputs, rare_mapping = [], {}
    for level, paths in [('normal', normal_files), ('expert', expert_files)]:
        for path in paths:
            forms = sexpr_headers(read(path))
            for form in forms:
                assert form['enum'] not in rare_mapping
                rare_mapping[form['enum']] = form['name']
            rule_inputs.append(dict(path=path, level=level, rules=forms))
    assert not set(rare_mapping) & set(rewrite_mapping)
    rewrite_mapping.update(rare_mapping)
    proof_rewrite = domain(rewrite_mapping, '?')
    proof_header = clean(read('include/cvc5/cvc5_proof_rule.h'))
    proof_enum = proof_header.split('enum ENUM(ProofRule)', 1)[1].split('};', 1)[0]
    rewrite_enum = proof_header.split('enum ENUM(ProofRewriteRule)', 1)[1].split('};', 1)[0]
    # LAST is present only in the C API preprocessor branch, absent from C++.
    assert set(re.findall(r'EVALUE\((\w+)\)', proof_enum)) - {'LAST'} == set(proof_mapping)
    assert set(re.findall(r'EVALUE\((\w+)\)', rewrite_enum)) - {'LAST'} == set(rewrite_mapping)
    rw_generator = read('src/rewriter/mkrewrites.py')
    assert '[(False, f) for f in args.rewrites_files] + [(True, f) for f in args.rewrites_files_expert]' in rw_generator
    assert 'f\'case ProofRewriteRule::{enum}: return "{rule.name}";\'' in rw_generator
    assert "return self.name.replace('-', '_').upper()" in read('src/rewriter/rule.py')
    for path in ['src/rewriter/rw_parser.py', 'src/rewriter/node.py', 'src/rewriter/util.py',
                 'src/rewriter/theory_rewrites_template.cpp', 'src/rewriter/rewrites_template.cpp',
                 'src/rewriter/CMakeLists.txt', 'src/util/safe_print.h',
                 'src/util/statistics_value.h', 'src/util/statistics_registry.h',
                 'src/util/statistics_registry.cpp', 'src/util/statistics_public.cpp']:
        read(path)
    assert '--rewrites_files_expert ${REWRITES_FILES_EXPERT}' in read('src/rewriter/CMakeLists.txt')
    safe = read('src/util/safe_print.h')
    assert 'auto toStringImpl(const T& obj, int) -> decltype(toString(obj))' in safe
    assert 'return "<unsupported>";' in safe
    hist = read('src/util/statistics_value.h')
    assert 'res.emplace(ss.str(), d_hist[i]);' in hist
    assert 'safe_print<Integral>(fd, static_cast<Integral>(i + d_offset));' in hist

    retained_header = clean((HERE / 'generated-kind.h').read_text())
    kind_enum = retained_header.split('enum class Kind_t', 1)[1].split('};', 1)[0]
    kind_names = re.findall(r'^\s*(\w+)\s*(?:=\s*-?\d+)?\s*(?:,|$)', kind_enum, re.M)
    assert set(kind_names) == set(generated)
    type_enum = retained_header.split('enum TypeConstant', 1)[1].split('};', 1)[0]
    type_names = re.findall(r'^\s*(\w+)\s*(?:,|$)', type_enum, re.M)
    assert set(type_names) == set(sorts) | {'LAST_TYPE'}
    retained_generated = (HERE / 'generated-kind.cpp').read_text()
    generated_body = body(retained_generated, 'const char* toString(cvc5::internal::Kind k)')
    assert literal_cases(generated_body, 'Kind::') == generated
    generated_sorts = body(retained_generated, 'const char* toString(TypeConstant tc)')
    assert literal_cases(generated_sorts, '') == sorts
    run_record = json.loads((HERE / 'generator-run.json').read_text())
    for name, identity in run_record['kind_generator']['outputs'].items():
        data = (HERE / name).read_bytes()
        assert dict(bytes=len(data), sha256=sha(data)) == identity

    result = dict(
        revision=REVISION, archive_sha256=ARCHIVE_SHA256,
        q_cvc5=None, weighted_O=None,
        domains=dict(internal_Kind_AST=internal_ast, internal_Kind_SMTLIB_SYGUS=internal_smt,
                     internal_Kind_any_supported_language=internal_union, API_Kind=api_kind,
                     TypeConstant=type_constant, ProofRule=proof_rule, ProofRewriteRule=proof_rewrite),
        mappings=dict(internal_Kind_AST=generated, internal_Kind_SMTLIB_SYGUS=internal_smt_mapping,
                      API_Kind=api_mapping, TypeConstant=sorts, ProofRule=proof_mapping,
                      ProofRewriteRule=rewrite_mapping),
        safe=dict(API_Kind_spelling='<unsupported>', API_Kind_spelling_bytes=13,
                  maximum_spelling_bytes=dict(
                      internal_Kind=internal_ast['maximum_spelling_bytes'], API_Kind=13,
                      TypeConstant=type_constant['maximum_spelling_bytes'],
                      ProofRule=proof_rule['maximum_spelling_bytes'],
                      ProofRewriteRule=proof_rewrite['maximum_spelling_bytes']),
                  formula='4 + sum_over_positive_buckets(len(safe_spelling) + 24)',
                  note='No string-map collapse. Named-domain counts require a separate valid-key inclusion premise; fallback spelling count alone is insufficient.'),
        inputs=dict(kinds=toml_inputs, rewrites=rule_inputs),
        generation=dict(kind='upstream generator executed separately; domain reconstructed from generator inputs',
                        rewrites='upstream generator not executed: pyparsing unavailable; structural header extraction and exact generated-header ID cross-check only'),
        used_sources=used)
    return result, files, used


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    result, files, used = generate()
    encoded = (json.dumps(result, indent=2, sort_keys=True) + '\n').encode()
    if args.write:
        (HERE / 'result.json').write_bytes(encoded)
        # Deterministic complete used files, independently inspectable offline.
        buffer = io.BytesIO()
        with tarfile.open(fileobj=buffer, mode='w') as tf:
            for path in sorted(used):
                info = tarfile.TarInfo(path)
                info.size = len(files[path])
                info.mode = 0o644
                tf.addfile(info, io.BytesIO(files[path]))
        (HERE / 'used-sources.tar.gz').write_bytes(gzip.compress(buffer.getvalue(), mtime=0))
    else:
        assert (HERE / 'result.json').read_bytes() == encoded
        with tarfile.open(HERE / 'used-sources.tar.gz') as tf:
            retained = {m.name: tf.extractfile(m).read() for m in tf if m.isfile()}
        assert set(retained) == set(used)
        assert all(retained[p] == files[p] for p in used)
    print(json.dumps({name: {k: value[k] for k in ['distinct_spellings', 'spelling_bytes',
                         'maximum_spelling_bytes', 'ordinary_histogram_allowance']}
                      for name, value in result['domains'].items()}, sort_keys=True))
    print(f'PASS: {len(used)} complete source files; generated input domains; q_cvc5/O remain null')


if __name__ == '__main__':
    main()
