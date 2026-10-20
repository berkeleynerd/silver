#!/usr/bin/env python3
"""Offline source/name arithmetic only. No compiler, solver, network or task run."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time

START = time.monotonic()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PREV = ROOT / 'docs/evidence/retained-cvc5-output-capacity-20261020'
ARCHIVE = PREV / 'cvc5-source.tar.gz'
assert hashlib.sha256(ARCHIVE.read_bytes()).hexdigest() == '19d7bbe18166fa175ff537f226e8df5e229b6a28497cb823f82eb734ceed684c'
with tarfile.open(ARCHIVE) as tf:
    src = {m.name.split('/', 1)[1]: tf.extractfile(m).read()
           for m in tf.getmembers() if m.isfile() and '/' in m.name}
used = set()


def read(name):
    used.add(name)
    return src[name].decode()


def require(name, *snippets):
    text = read(name)
    for snippet in snippets:
        assert snippet in text, (name, snippet)


# Recreate the predecessor's lexical sites over all source suffixes, with a
# separate bare-token check for alternate/forwarded registration spellings.
pattern = re.compile(r'(?:\.|->)\s*(register(?:Int|Average|Timer|Histogram|Value|Reference|Size))(?:<([^<>]+)>)?\s*\(')
token = re.compile(r'\bregister(?:Int|Average|Timer|Histogram|Value|Reference|Size)\b')
rows = []
scanned = collections.Counter()
for name, raw in sorted(src.items()):
    if not name.startswith('src/'):
        continue
    text = raw.decode(errors='replace')
    matches = list(pattern.finditer(text))
    if matches or token.search(text):
        used.add(name)
    scanned[Path(name).suffix] += 1
    covered = set()
    for m in matches:
        covered.add(m.start(1))
        depth, quote, escaped, end = 0, False, False, m.end()
        for end in range(m.end(), len(text)):
            c = text[end]
            if quote:
                if escaped:
                    escaped = False
                elif c == '\\':
                    escaped = True
                elif c == '"':
                    quote = False
            elif c == '"':
                quote = True
            elif c == '(':
                depth += 1
            elif c == ')':
                if depth == 0:
                    break
                depth -= 1
            elif c == ',' and depth == 0:
                break
        arg = ' '.join(text[m.end():end].split())
        rows.append({'file': name, 'line': text.count('\n', 0, m.start()) + 1,
                     'method': m[1], 'type': m[2], 'name_expression': arg,
                     'literal_name': bool(re.fullmatch(r'"[^"\\]*"', arg))})
    if name not in ('src/util/statistics_registry.h', 'src/util/statistics_registry.cpp'):
        assert all(m.start() in covered for m in token.finditer(text)), name
assert rows == json.loads((PREV / 'registration-sites.json').read_text())
assert len(rows) == 354

# Finite constructor domains. Every direct expression site below receives one
# domain. Source review, rather than this lexical script, justifies inclusion.
theory_file = read('src/theory/theory_id.cpp')
prefix_body = theory_file.split('std::string getStatsPrefix')[1].split('TheoryId TheoryIdSetUtil')[0]
theory = re.findall(r'case (THEORY_\w+): return "([^"]+)";', prefix_body)
assert len(theory) == 14
theory_prefixes = [v for _, v in theory]
theory_enum = read('src/theory/theory_id.h').split('enum TheoryId')[1].split('THEORY_LAST')[0]
assert re.findall(r'\bTHEORY_[A-Z_]+\b', theory_enum) == [k for k, _ in theory]
pp = []
for name in src:
    if name.startswith('src/preprocessing/passes/') and name.endswith('.cpp'):
        found = re.findall(r'PreprocessingPass\(preprocContext, "([^"]+)"\)', src[name].decode())
        if found:
            used.add(name)
            pp.extend(found)
require('src/preprocessing/passes/bv_gauss.h', 'const std::string& name = "bv-gauss"')
require('src/preprocessing/passes/bv_gauss.cpp', 'PreprocessingPass(preprocContext, name)')
pp.append('bv-gauss')
registry_passes = re.findall(r'registerPassInfo\("([^"]+)"', read('src/preprocessing/preprocessing_pass_registry.cpp'))
assert set(pp) - set(registry_passes) == {'normalize'}
assert set(registry_passes) <= set(pp) and len(pp) == 36
require('src/preprocessing/preprocessing_pass_registry.cpp', 'return new T(ppCtx);')

ee_names = [
    'arith::ee', 'central::ee', 'master::ee', 'theory::master', 'shared::ee',
    'DefaultModel::ee', 'ConjectureGenerator::ee', 'theory::arrays::pp',
    'theory::arrays::mayEqual', 'theory::arrays::ee', 'theory::bv::ee',
    'theory::datatypes::ee', 'theory::fp::ee', 'theory::sep::ee',
    'theory::ff::ee', 'theory::sets::ee', 'theory::uf::ee',
    'theory::strings::ee', 'theory::bags::ee',
]
assert len(set(ee_names)) == 19
sat_prefixes = ['', 'theory::bv::BVSolverBitblast::']
domains = {
    'src/preprocessing/preprocessing_pass.cpp': ['preprocessing::' + x for x in pp],
    # The same two-prefix superset is deliberately allowed to all three
    # backends, even where a backend has fewer/no ordinary caller sites.
    'src/prop/cadical/cadical.cpp': sat_prefixes,
    'src/prop/cryptominisat.cpp': sat_prefixes,
    'src/prop/kissat.cpp': sat_prefixes,
    'src/prop/cnf_stream.cpp': ['prop', 'theory::bv::BVSolverBitblast'],
    'src/smt/solver_engine_stats.cpp': ['smt::SolverEngine::'],
    'src/theory/arith/linear/fc_simplex.cpp': ['theory::arith::FC::'],
    'src/theory/arith/linear/soi_simplex.cpp': ['theory::arith::SOI'],
    'src/theory/arith/linear/theory_arith_private.cpp': ['theory::arith::'],
    'src/theory/arrays/array_info.cpp': ['theory::arrays::'],
    'src/theory/arrays/theory_arrays.cpp': ['theory::arrays::'],
    'src/theory/bv/theory_bv.cpp': ['theory::bv::'],
    'src/theory/ff/stats.cpp': ['theory::ff::'],
    'src/theory/output_channel.cpp': theory_prefixes + ['RelevanceManager::', 'PartitionGenerator::'],
    # TheoryArrays supplies its explicit default instance name; the other
    # ordinary factory constructors pass the empty instance name.
    'src/theory/theory.cpp': [p + ('theory::arrays::' if k == 'THEORY_ARRAYS' else '') for k, p in theory],
    'src/theory/theory_inference_manager.cpp': theory_prefixes,
    'src/theory/uf/equality_engine.cpp': [x + '::' for x in ee_names],
    'src/theory/uf/symmetry_breaker.cpp': ['theory::uf::symmetry_breaker::'],
    'src/util/statistics_public.cpp': theory_prefixes,
}

# Exact source anchors, paired with the written constructor/caller argument.
anchors = {
 'src/util/statistics_registry.h': ['std::map<std::string, std::unique_ptr<StatisticBaseValue>> d_stats;', 'auto it = d_stats.find(name);', 'd_stats.emplace(name,', 'registerPublic = true'],
 'src/util/statistics_registry.cpp': ['registerPublicStatistics(*this);'],
 'src/api/cpp/cvc5.cpp': ['d_statsReg.reset(new internal::StatisticsRegistry());', 'return Statistics(*d_statsReg);', 'return Statistics(d_slv->getStatisticsRegistry());'],
 'include/cvc5/cvc5.h': ['std::unique_ptr<internal::StatisticsRegistry> d_statsReg;'],
 'src/main/command_executor.cpp': ['d_solver->getStatistics()', 'd_solver->getTermManager().getStatistics()', 'stats-all'],
 'src/smt/env.cpp': ['d_statisticsRegistry.reset(new StatisticsRegistry(', 'd_statisticsRegistry->registerTimer("global::totalTime").start();', 'd_plugins.push_back(p);'],
 'src/smt/env.h': ['std::vector<Plugin*> d_plugins;'],
 'src/smt/solver_engine_stats.h': ['const std::string& name = "smt::SolverEngine::"'],
 'src/smt/solver_engine.cpp': ['new SolverEngineStatistics(d_env->getStatisticsRegistry())', 'if (key == "filename")', '"driver::filename", value);', 'd_env->addPlugin(p);'],
 'src/main/driver_unified.cpp': ['solver->setInfo("filename", filenameStr);'],
 'src/prop/sat_solver_factory.cpp': ['new CadicalSolver(env, registry, name)', 'new CryptoMinisatSolver(registry, name)', 'new KissatSolver(registry, name)'],
 'src/prop/prop_engine.cpp': ['d_env, statisticsRegistry(), env.getResourceManager(), ""', '"prop");'],
 'src/theory/bv/bv_solver_bitblast.cpp': ['"theory::bv::BVSolverBitblast::"', '"theory::bv::BVSolverBitblast"'],
 'src/theory/arith/linear/fc_simplex.cpp': ['d_statistics(statisticsRegistry(), "theory::arith::FC::", d_pivots)'],
 'src/theory/arith/linear/soi_simplex.cpp': ['d_statistics(statisticsRegistry(), "theory::arith::SOI", d_pivots)'],
 'src/theory/arith/linear/theory_arith_private.cpp': ['d_statistics(statisticsRegistry(), "theory::arith::")'],
 'src/theory/arrays/theory_arrays.h': ['std::string name = "theory::arrays::"'],
 'src/theory/arrays/theory_arrays.cpp': ['d_infoMap(statisticsRegistry(), context(), name)', 'name + "pp"', 'name + "mayEqual"', 'esi.d_name = d_instanceName + "ee";'],
 'src/theory/bv/theory_bv.cpp': ['d_stats(statisticsRegistry(), "theory::bv::")', 'esi.d_name = "theory::bv::ee";'],
 'src/theory/ff/theory_ff.cpp': ['std::make_unique<FfStatistics>(statisticsRegistry(), "theory::ff::")'],
 'src/theory/theory.h': ['std::string instance = ""'],
 'src/theory/uf/theory_uf.h': ['std::string instanceName = ""'],
 'src/theory/bv/theory_bv.h': ['std::string name = ""'],
 'src/theory/theory_engine.h': ['new TheoryClass(d_env, *d_theoryOut[theoryId], theory::Valuation(this))'],
 'src/theory/theory_engine_module.cpp': ['d_out(statisticsRegistry(), engine, name, d_idCounter)'],
 'src/theory/relevance_manager.cpp': ['TheoryEngineModule(env, engine, "RelevanceManager")'],
 'src/theory/partition_generator.cpp': ['TheoryEngineModule(env, theoryEngine, "PartitionGenerator")'],
 'src/theory/plugin_module.cpp': ['TheoryEngineModule(env, theoryEngine, "Plugin::" + p->getName())'],
 'src/theory/uf/theory_uf.cpp': ['d_symb(env, instanceName)', '"theory::uf::" + instanceName', 'esi.d_name = d_instanceName + "theory::uf::ee";'],
 'src/theory/uf/symmetry_breaker.cpp': ['d_stats(statisticsRegistry(), d_name + "theory::uf::symmetry_breaker::")'],
 'src/theory/uf/equality_engine.cpp': ['d_stats(statisticsRegistry(), name + "::")'],
 'src/theory/ee_manager.cpp': ['esi.d_name'],
 'src/theory/ee_manager_central.cpp': ['"central::ee"', '"master::ee"'],
 'src/theory/ee_manager_distributed.cpp': ['"theory::master"'],
 'src/theory/shared_terms_database.cpp': ['esi.d_name = "shared::ee";'],
 'src/theory/arith/equality_solver.cpp': ['esi.d_name = "arith::ee";'],
 'src/theory/model_manager.cpp': ['env, "DefaultModel",'],
 'src/theory/model_manager_distributed.cpp': ['esim.d_name = d_model->getName() + "::ee";'],
 'src/theory/quantifiers/conjecture_generator.cpp': ['"ConjectureGenerator::ee"'],
 'src/theory/quantifiers/dynamic_rewrite.cpp': ['"DynamicRewriter::" + name'],
 'src/theory/quantifiers/candidate_rewrite_filter.cpp': ['static thread_local unsigned drewrite_counter = 0;', 'ssn << "_dyn_rewriter_" << drewrite_counter;', 'drewrite_counter++;', 'std::make_unique<DynamicRewriter>(d_env, &d_fakeContext, ssn.str())'],
 'src/theory/quantifiers/candidate_rewrite_database.cpp': ['if (d_filterPairs)', 'd_crewrite_filter.initialize(ss, nullptr, false);', 'd_crewrite_filter.initialize(ss, d_tds, d_using_sygus);'],
 'src/theory/quantifiers/sygus/rcons_type_info.cpp': ['new CandidateRewriteDatabase(env, true, false, false)'],
 'src/theory/quantifiers/sygus/synth_finder.cpp': ['new CandidateRewriteDatabase'],
 'src/smt/find_synth_solver.cpp': ['d_sfinders.emplace_back(new theory::quantifiers::SynthFinder(d_env));', 'd_sfinders.back()->initialize(fst, gtn);'],
 'src/parser/commands.cpp': ['d_result = solver->findSynth(d_fst, *d_grammar);', 'd_result = solver->findSynth(d_fst);'],
 'src/preprocessing/passes/synth_rew_rules.cpp': ['return PreprocessingPassResult::NO_CONFLICT;'],
 'src/util/statistics_value.h': ['bool isDefault() const override { return d_value == T(); }'],
}
for theory_name in ['bags', 'datatypes', 'fp', 'sep', 'ff', 'sets', 'strings']:
    anchors.setdefault(f'src/theory/{theory_name}/theory_{theory_name}.cpp', []).append(f'esi.d_name = "theory::{theory_name}::ee";')
for name, snippets in anchors.items():
    require(name, *snippets)

def kind(row):
    method, typ = row['method'], row['type']
    if method in ('registerInt', 'registerReference', 'registerSize'):
        assert method != 'registerReference' or typ in ('int64_t', 'uint32_t', 'uint64_t')
        return 'I'
    if method == 'registerAverage': return 'D'
    if method == 'registerTimer': return 'T'
    if method == 'registerValue':
        assert typ == 'std::string'
        return 'string'
    assert method == 'registerHistogram'
    if typ in ('InferenceId', 'theory::InferenceId'): typ = 'InferenceId'
    elif typ in ('TypeConstant', 'internal::TypeConstant'): typ = 'TypeConstant'
    elif typ == 'theory::TheoryId': typ = 'TheoryId'
    elif typ == 'cvc5::Kind' or (typ == 'Kind' and row['file'] == 'src/api/cpp/cvc5.cpp'): typ = 'API_Kind'
    elif typ == 'Kind': typ = 'internal_Kind'
    elif typ == 'Rewrite': typ = 'bags::Rewrite' if '/bags/' in row['file'] else 'strings::Rewrite'
    return 'histogram:' + typ


records = {'solver': {}, 'term_manager': {}}
contributions = []
for row in rows:
    f, expr = row['file'], row['name_expression']
    if row['literal_name']:
        names = [json.loads(expr)]
    else:
        assert f in domains, row
        if f == 'src/preprocessing/preprocessing_pass.cpp':
            names = domains[f]
        else:
            suffix = re.search(r'"([^"\\]*)"$', expr)[1]
            names = [p + suffix for p in domains[f]]
    regs = ['term_manager'] if f == 'src/api/cpp/cvc5.cpp' else ['solver']
    if f == 'src/util/statistics_public.cpp': regs = ['solver', 'term_manager']
    k = kind(row)
    for reg in regs:
        for n in names:
            if n in records[reg]: assert records[reg][n]['kind'] == k, (reg, n, k)
            else: records[reg][n] = {'name': n, 'kind': k, 'sites': []}
            records[reg][n]['sites'].append(f"{f}:{row['line']}")
    contributions.append({'file': f, 'line': row['line'], 'name_expression': expr,
                          'registries': regs, 'kind': k, 'names': names})

# The selected stats-all=false projection: TM modifies only its three API
# histograms; the solver does not modify these three public API histograms.
filtered = {r: dict(v) for r, v in records.items()}
api_names = {'cvc5::CONSTANT', 'cvc5::VARIABLE', 'cvc5::TERM'}
filtered['term_manager'] = {n: v for n, v in filtered['term_manager'].items() if n in api_names}
filtered['solver'] = {n: v for n, v in filtered['solver'].items() if n not in api_names}
no_uint32 = {r: {n: v for n, v in entries.items() if v['kind'] != 'histogram:uint32_t'}
             for r, entries in filtered.items()}


def summary(rs):
    counts = collections.Counter(v['kind'] for v in rs.values())
    s, names = len(rs), sum(len(n.encode()) for n in rs)
    return {'S': s, 'L_names': names, 'I': counts['I'], 'D': counts['D'], 'T': counts['T'],
            'strings': counts['string'],
            'histograms': {k[10:]: v for k, v in sorted(counts.items()) if k.startswith('histogram:')},
            'base_bytes_excluding_strings_histogram_values_dynamic': names + 4*s + 20*counts['I'] + 13*counts['D'] + 22*counts['T']}


def report(rs):
    r = {k: summary(v) for k, v in rs.items()}
    r['both'] = summary({reg + '\0' + name: value for reg, entries in rs.items() for name, value in entries.items()})
    # Registry identifiers are identity tags, not printed bytes.
    r['both']['L_names'] = sum(r[k]['L_names'] for k in rs)
    r['both']['base_bytes_excluding_strings_histogram_values_dynamic'] = sum(r[k]['base_bytes_excluding_strings_histogram_values_dynamic'] for k in rs)
    return r


ee_suffixes = [json.loads(r['name_expression'].split(' + ')[1]) for r in rows if r['file'] == 'src/theory/uf/equality_engine.cpp']
dynamic_stem = 'DynamicRewriter::_dyn_rewriter_'
fixed_per_prefix = sum(len(dynamic_stem + '::' + s) for s in ee_suffixes)
assert len(ee_suffixes) == 4
U = 2**32
digits_sum = sum((min(U, 10**d) - (0 if d == 1 else 10**(d-1))) * d for d in range(1, 11))
result = {
 'status': 'pass', 'source_revision': '86cecd83b685f59e884094693b9a4c5c90a62e03',
 'registration_sites': len(rows), 'literal_sites': sum(x['literal_name'] for x in rows),
 'expression_sites': sum(not x['literal_name'] for x in rows),
 'scanned_src_file_suffix_counts': dict(sorted(scanned.items())),
 'preprocessing_names': sorted(pp), 'theory_prefixes': theory_prefixes,
 'static_equality_engine_names': sorted(ee_names),
 'registered_superset': report(records), 'stats_all_false_superset': report(filtered),
 'stats_all_false_uint32_inactive_superset': report(no_uint32),
 'dynamic_equality_engine': {
    'name_pattern': dynamic_stem + '<unsigned decimal>::<suffix>',
    'suffixes': ee_suffixes, 'I_per_distinct_counter': 4, 'S_per_distinct_counter': 4,
    'fixed_name_bytes_per_counter': fixed_per_prefix,
    'L_names_formula': f'{fixed_per_prefix}*R + 4*L_decimal',
    'ordinary_byte_formula': f'{fixed_per_prefix + 96}*R + 4*L_decimal',
    'unsigned32_distinct_counter_ceiling': U,
    'unsigned32_all_decimal_bytes': digits_sum,
    'unsigned32_all_name_bytes': fixed_per_prefix * U + 4 * digits_sum,
    'unsigned32_all_ordinary_bytes': (fixed_per_prefix + 96)*U + 4*digits_sum,
    'premises': ['unsigned has 32 value bits', 'decimal C locale/default integer stream formatting', 'represented valid source objects'],
 },
 'q_cvc5': None, 'weighted_O': None,
}
finite_values = {'InferenceId': 18539, 'LearnedRewriteId': 253, 'Resource': 740,
                 'TheoryId': 585, 'TrustId': 3444, 'bags::Rewrite': 2410,
                 'strings::Rewrite': 7920}
predecessor_bytes = (PREV / 'result.json').read_bytes()
assert hashlib.sha256(predecessor_bytes).hexdigest() == 'f61517f37ca8912f7134263ce063519a1b9c3868d419fb1c06144e9b5e8fca28'
assert {k: v['normal_histogram_value_bound'] for k, v in
        json.loads(predecessor_bytes)['finite_histogram_tables'].items()} == finite_values
for label in ['registered_superset', 'stats_all_false_superset', 'stats_all_false_uint32_inactive_superset']:
    both = result[label]['both']
    both['base_plus_seven_accepted_finite_histogram_families'] = (
        both['base_bytes_excluding_strings_histogram_values_dynamic']
        + sum(both['histograms'].get(k, 0)*v for k, v in finite_values.items()))
out_suffixes = [json.loads(r['name_expression'].split(' + ')[1]) for r in rows
               if r['file'] == 'src/theory/output_channel.cpp']
plugin_fixed = sum(len('Plugin::' + '::' + s) for s in out_suffixes)
result['external_plugin_extension_not_selected'] = {
    'suffixes': out_suffixes, 'S_and_I_per_plugin_name': 6,
    'L_names_formula': f'{plugin_fixed}*P + 6*L_plugin_names',
    'ordinary_byte_formula': f'{plugin_fixed+144}*P + 6*L_plugin_names',
    'ordinary_main_P': 0,
}
manifest = {name: {'bytes': len(src[name]), 'sha256': hashlib.sha256(src[name]).hexdigest()} for name in sorted(used)}
outputs = {'result.json': result, 'expanded-sites.json': contributions,
           'records.json': {reg: [entries[n] for n in sorted(entries)] for reg, entries in records.items()},
           'source-identities.json': manifest, 'source-anchors.json': anchors}
parser = argparse.ArgumentParser()
parser.add_argument('--write', action='store_true', help='write retained deterministic evidence')
args = parser.parse_args()
for name, value in outputs.items():
    if args.write:
        (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')
    else:
        assert json.loads((HERE / name).read_text()) == value, name
print(json.dumps({'status': 'pass', 'source_files': len(used), 'registration_sites': len(rows),
                  'registered': result['registered_superset']['both'],
                  'stats_all_false': result['stats_all_false_superset']['both'],
                  'dynamic': result['dynamic_equality_engine'],
                  'checker_wall_seconds': round(time.monotonic() - START, 6)}, indent=2))
