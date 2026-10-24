#!/usr/bin/env python3
"""New offline identity/restriction arithmetic only; no predecessor replay."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import platform
import re
import tarfile
import time

from transfer import (ARRAY_MAX, CONFIGURATION, IMAGE_WORDS, MAX_INT, OWNERS,
                      WEAK_MAX, all_envelopes, entry_envelope, projection)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
COUNTS = Counter()


def check(ok, family):
    if not ok:
        raise AssertionError(family)
    COUNTS[family] += 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads((ROOT/path).read_text())


def rejects(fn, family):
    try:
        fn()
    except ValueError:
        check(True, family)
    else:
        raise AssertionError(family)


def identities():
    manifest = json.loads((HERE/'identity.json').read_text())
    sources = {}
    counts = Counter()
    for row in manifest['archives']:
        data = (ROOT/row['path']).read_bytes()
        check(len(data) == row['bytes'] and sha(data) == row['sha256'], 'retained archive identity')
        counts['archives'] += 1
        with tarfile.open(ROOT/row['path']) as a:
            for item in row['members']:
                data = a.extractfile(item['path']).read()
                check(len(data) == item['bytes'] and sha(data) == item['sha256'], 'complete retained member identity')
                counts['members'] += 1
                sources[item['path']] = data.decode()
                lines = data.decode().splitlines()
                for span in item['spans']:
                    data = ('\n'.join(lines[span['first']-1:span['last']])+'\n').encode()
                    check(len(data) == span['bytes'] and sha(data) == span['sha256'], 'retained source native span identity')
                    counts['spans'] += 1
    for row in manifest['providers']:
        data = (ROOT/row['path']).read_bytes()
        check(len(data) == row['bytes'] and sha(data) == row['sha256'], 'accepted provider identity')
        counts['providers'] += 1
    return sources, dict(counts)


def native_charges(sources):
    # Inspect only retained text; no decoder, debugger, target or observer runs.
    text = '\n'.join(sources[n] for n in sources if n.startswith('success/'))
    symbols = {
        'Ident': [('camlWhy3__Ident__fun_6183', 40)],
        'Ident.Hsattr': [('camlWhy3__Ident__tag_1336', 24)],
        'Ty.Hsty': [('camlWhy3__Ty__tag_2290', 24)],
        'Ity.Hsity': [('camlWhy3__Ity__tag_3788', 32)],
        'Decl.Hsdecl': [('camlWhy3__Decl__tag_3022', 32)],
        'Theory.Hstdecl': [('camlWhy3__Theory__tag_3136', 24)],
        'Task.Hstask': [('camlWhy3__Task__tag_2028', 56)],
        'Task.Stdecl.Hcpt': [('camlWhy3__Hcpt__leaf_658',32), ('camlWhy3__Hcpt__branch_663',48)],
    }
    for owner, rows in symbols.items():
        for symbol, size in rows:
            match = re.search(r'Dump of assembler code for function '+re.escape(symbol)+r':(.*?)End of assembler dump\.', text, re.S)
            check(match is not None, 'named native allocation body')
            amounts = [int(x,16) for x in re.findall(r'sub\s+\$0x([0-9a-f]+),%r15', match[1])]
            check(amounts == [size], 'positive native per-call minor charge')
        check(min(size//8 for _,size in rows) == OWNERS[owner]['minimum_minor_words'], 'minimum owner charge correspondence')
    ident = re.search(r'Dump of assembler code for function camlWhy3__Ident__fun_6183:(.*?)End of assembler dump\.', text,re.S)[1]
    check(ident.index('addq') < ident.index('$0x28,%r15'), 'Ident increment precedes its allocation')
    check('let tag _ d = d' in sources['src/transform/introduction.ml'], 'allocation-free Introduction owner distinguished')
    return {owner:[{'symbol':symbol,'bytes':size} for symbol,size in rows] for owner,rows in symbols.items()}


def source_seams(sources):
    checks = {
        'controller cut source': ('src/gnat/gnat_checks.ml', ['let c = Controller_itp.create_controller', 'Controller_itp.add_file']),
        'all configured drivers before return': ('src/session/controller_itp.ml', ['Whyconf.Mprover.iter', 'load_drivers c;']),
        'filename classification only before C': ('src/gnat/gnat_config.ml', ['Sys.file_exists fname', 'Sys.is_directory fname', 'if !opt_limit_lines = "" then init']),
        'save handler installed after controller initialization': ('src/gnat/gnat_main.ml', ['Gnat_checks.init_cont in', 'Sys.set_signal Sys.sigint']),
        'JSON reader after add_file': ('plugins/gnat_json/gnat_ast_to_ptree.ml', ['Yojson.Safe.from_channel c', 'Typing.type_mlw_file']),
        'six pool common initialization': ('src/util/hashcons.ml', ['let next_tag = ref 0', 'WH.create 5003', 'let d = H.tag !next_tag d', 'WH.merge htable d']),
        'Hcpt initialization and fresh callers': ('src/util/hcpt.ml', ['let table = H.create 8192', 'let nextid = ref 1', 'hashcons (Leaf', 'hashcons (Branch']),
        'weak populated state fields': ('ocaml/stdlib/weak.ml', ['mutable table', 'mutable hashes', 'mutable limit', 'mutable oversize', 'mutable rover']),
        'weak max sentinel only at exhausted growth': ('ocaml/stdlib/weak.ml', ['if newlen > oldlen then begin', 't.limit <- max_int']),
    }
    for family,(name,needles) in checks.items():
        check(all(n in sources[name] for n in needles), family)
    # Complete implementation-archive inventory supports the reviewed source
    # partition; it is not itself a reachability proof.
    path = ROOT/'docs/evidence/retained-producer-prefix-composition-20261018/sources.tar.gz'
    hashcons_sites = []
    with tarfile.open(path) as archive:
        for member in archive.getmembers():
            if not member.isfile() or not member.name.endswith('.ml'):
                continue
            lines = archive.extractfile(member).read().decode().splitlines()
            for n,line in enumerate(lines,1):
                if re.search(r'module\s+\w+\s*=\s*Hashcons\.Make',line):
                    hashcons_sites.append({'file':member.name,'line':n,'source':line.strip()})
    expected = {'src/core/ident.ml','src/core/ty.ml','src/mlw/ity.ml','src/core/decl.ml',
                'src/core/theory.ml','src/core/task.ml','src/transform/introduction.ml'}
    check(len(hashcons_sites) == 7 and {r['file'] for r in hashcons_sites} == expected,
          'complete archive Hashcons owner inventory')
    return hashcons_sites


def arithmetic():
    original = read('docs/evidence/retained-producer-prefix-gc-20261018/result.json')
    dims = read('docs/evidence/retained-producer-prefix-gc-20261018/dimensions-result.json')
    check(max(row['minor_delta_words']+row['major_delta_words'] for row in original['cases']) == 86632681,
          'historical W is sum of charged allocation deltas')
    check(dims['combined_managed_and_static_word_budget'] == 86632681+43164+IMAGE_WORDS,
          'historical carrier kept in its original scope')
    check(dims['loaded_image_word_overcount'] == IMAGE_WORDS and (dims['loaded_image_memory_bytes']+7)//8 == IMAGE_WORDS,
          'unchanged loaded image memory allowance')
    repaired = read('docs/evidence/retained-fixed-failure-composition-20261023/configuration-repair.json')
    check(repaired['base_after']['sha256'] == sha((ROOT/'docs/evidence/retained-fixed-failure-composition-20261023/configuration/why3.conf').read_bytes()),
          'current repaired configuration selected')
    check(repaired['common_extra_FileTags_names_upper'] == 1 and repaired['production_files_changed'] is False,
          'current repair credit and prospective scope')
    combined = projection()
    check(combined['credits'] == {'minor_words':7582192,'major_words':7578096,'remembered_entries':18924760},
          'accepted current recipe credits unchanged')
    rows = all_envelopes()
    for role,row in rows.items():
        b = combined['domains'][role]['bounds']
        check(all(row['guards'].values()), 'cut owner and native capacity guards')
        check(row['all_major_history_words_upper'] == b['current_major_words']+combined['domains'][role]['original_startup_major_words'],
              'all-major history includes its own startup promotion')
        check(row['managed_static_carrier_words_upper'] == b['minor_words']+b['all_major_words']+IMAGE_WORDS,
              'current carrier no endpoint subtraction')
        for owner,state in row['owners'].items():
            q=state['completed_requests_upper'];w=state['minimum_minor_words'];m=b['minor_words']
            check(w*q <= m < w*(q+1), 'exact charge quotient')
            check(state['counter_value_upper'] == state['initial']+q, 'owner initialized counter transport')
            check(not state['exact_populated_counter_known'], 'upper envelope not an invented exact state')
        check(row['Introduction.Hsdecl']['calls_before_C'] == 0, 'extra allocation-free pool separately scoped')
        check(row['process_budget'] == {'escaping_save_exceptions':2,'save_entering_callbacks':2,'saves':3},
              'one unchanged process budget')
        check(not row['full_Main_storage_closed'] and not row['configuration_206_extension_available'],
              'remaining Main and config work explicit')
    greatest = rows['put_line']
    check(greatest['minor_history_words_upper'] == 135521724 and greatest['all_major_history_words_upper'] == 8526217,
          'new maximal current history operands')
    check(greatest['protected_managed_history_words_upper'] == 144047941 and greatest['managed_static_carrier_words_upper'] == 146200712,
          'new maximal current history and carrier')
    check(greatest['owners']['Ident']['counter_value_upper'] == 27104344,
          'useful explicit Ident headroom')
    check(greatest['owners']['Ity.Hsity']['counter_value_upper'] == 33880431,
          'program type owner included')
    check(greatest['owners']['Task.Stdecl.Hcpt']['counter_value_upper'] == 33880432,
          'Hcpt initial one retained')
    for field in ['minor_history_words_upper','all_major_history_words_upper','managed_static_carrier_words_upper']:
        check(max(r[field] for r in rows.values()) == greatest[field], 'maximal role dominates five rows')
    rejects(lambda:entry_envelope('put_line','configuration_206'), 'unadopted delta not silently enabled')
    rejects(lambda:entry_envelope('arbitrary_new_layout'), 'unattached launch layout not enabled')
    # Algebraic witnesses for the restriction, including zero-allocation steps.
    # These corroborate the finite arithmetic; the source argument identifies
    # which real trace/cut and allocations satisfy the nonnegative premise.
    trace=[0,5,3,4,7,0,6,3,4,5]
    total=sum(trace)
    for cut in range(len(trace)+1):
        prefix=sum(trace[:cut])
        check(0 <= prefix <= total, 'nonnegative cumulative prefix restriction')
        for w in {s['minimum_minor_words'] for s in OWNERS.values()}:
            check(prefix//w <= total//w, 'positive-charge restriction monotonicity')
    return rows


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--write',action='store_true')
    args=parser.parse_args()
    start=time.monotonic()
    sources,counts=identities()
    native=native_charges(sources)
    inventory=source_seams(sources)
    rows=arithmetic()
    result={'status':'pass','platform':platform.platform(),
            'configuration':CONFIGURATION,'assertions':sum(COUNTS.values()),
            'families':dict(sorted(COUNTS.items())),'identities':counts,
            'native_charge_witnesses':native,'Hashcons_owner_inventory':inventory,
            'entry_envelopes':rows,'elapsed_seconds':time.monotonic()-start,
            'native_capture_compiler_prover_Lean_runs':0,'predecessor_checker_replays':0,
            'source_argument_machine_proved':False,'full_Main_storage_closed':False}
    if args.write:
        (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({x:result[x] for x in ['status','assertions','identities','elapsed_seconds']},sort_keys=True))


if __name__ == '__main__':
    main()
