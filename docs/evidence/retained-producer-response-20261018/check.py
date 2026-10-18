#!/usr/bin/env python3
"""Check retained response source identities and scalar boundary arithmetic.

No native tool is executed. This is not an admission predicate or an adapter
implementation; the source dependency argument is in retained-producer-tail.md.
"""
import hashlib
import json
from pathlib import Path
import re
import tarfile


HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    assert digest == identity['source_archive_sha256']
    with tarfile.open(archive) as source:
        files = {m.name: source.extractfile(m).read()
                 for m in source.getmembers() if m.isfile()}
    assert len(files) == len(identity['files'])
    for item in identity['files']:
        data = files[item['path']]
        assert len(data) == item['bytes']
        assert hashlib.sha256(data).hexdigest() == item['sha256']

    def text(path):
        return files[path].decode()

    def has(path, fragment):
        assert ' '.join(fragment.split()) in ' '.join(text(path).split()), path

    config = json.loads(text('installed/share/spark/config/gnatprove.conf'))
    selected = {p['shortcut']: p for p in config['provers']
                if p['shortcut'] in ('cvc5', 'z3', 'altergo')}
    assert '--stats-internal' in selected['cvc5']['args']
    assert '-st' in selected['z3']['args']
    assert selected['altergo']['driver'] == 'alt_ergo_gnatprove_smt2'
    projection = json.loads((HERE / 'driver-projection.json').read_text())
    prefix = 'installed/libexec/spark/share/why3/drivers/'
    removed = []
    for name in projection['import_closure']:
        original = text(prefix + name)
        lines = original.splitlines(keepends=True)
        dropped = [(i, line.rstrip('\n')) for i, line in enumerate(lines, 1)
                   if re.match(r'^steps\s', line)]
        projected = ''.join(line for line in lines
                            if not re.match(r'^steps\s', line))
        if dropped:
            assert (HERE / 'proposed-driver-overlay' / name).read_text() == projected
            removed.extend(dict(file=name, line=i, text=line) for i, line in dropped)
        else:
            assert projected == original
        assert not re.search(r'^steps\s', projected, re.M)
        assert all(imported in projection['import_closure'] for imported in
                   re.findall(r'^import "([^"]+)"', original, re.M))
    assert sorted(removed, key=str) == sorted(projection['removed'], key=str)
    assert len(removed) == 6
    assert (HERE / 'proposed-driver-overlay/why3.conf').read_text() == '[main]\nmagic = 14\n'
    has('why3/src/gnat/gnat_util.ml',
        'let fn = Filename.concat dir fn in if Sys.file_exists fn then fn else raise Exit')
    has('why3/src/driver/driver_lexer.mll', '[ current_dirname ; drivers_path ]')
    has('why3/src/driver/call_provers.ml',
        'let steps = Option.value ~default:(-1) (grep_steps out res_parser.prp_stepregexps)')
    has('why3/src/driver/call_provers.ml', 'if stepslimit > 0 && steps >= stepslimit then')
    has('why3/src/gnat/gnat_config.ml',
        '(max 0 (c - conv.add)) / conv.mult + 1')
    has('why3/src/driver/call_provers.ml', 'Some(int_of_string v)')
    has('solvers/Z3Prover-z3/src/util/rlimit.h', 'uint64_t m_count = 0;')
    has('solvers/Z3Prover-z3/src/util/statistics.cpp',
        'std::fixed << std::setprecision(2) << d_val')
    has('solvers/cvc5-cvc5/src/util/resource_manager.cpp',
        'ReferenceStat<uint64_t> d_resourceUnitsUsed;')
    has('solvers/OCamlPro-alt-ergo/src/lib/util/steps.ml', 'let steps = ref 0')
    has('solvers/OCamlPro-alt-ergo/src/lib/util/steps.ml',
        'let get_steps () = max !naive_steps !steps')

    natural_last = 2**31 - 1
    cases = {}
    for name, add, mult in [('altergo', 0, 1), ('cvc5', 15000, 35),
                            ('z3', 450000, 800)]:
        raw = add + mult * natural_last
        convert = lambda x: max(0, x - add) // mult + 1
        assert convert(raw - 1) == natural_last
        assert convert(raw) == natural_last + 1
        assert raw < 2**53 and raw < 2**62
        assert convert(-1) == 1
        cases[name] = dict(first_raw_above_natural=raw,
                           previous_normalized=convert(raw - 1),
                           normalized=convert(raw))

    kinds = text('why3/src/gnat/gnat_expl.ml').split('let is_warning_kind')[0]
    kinds = re.findall(r'\| (VC_\w+)', kinds)
    assert len(kinds) == len(set(kinds))
    has('why3/src/gnat/gnat_expl.ml',
        'Stdlib.(=) a.id b.id && Stdlib.(=) a.check_kind b.check_kind')
    has('why3/src/gnat/gnat_report.ml',
        'if (Gnat_expl.HCheck.mem msg_set check) then assert false')
    has('why3/src/gnat/gnat_report.ml',
        'Some (stats, stats_checker), [], None, Gnat_expl.Unknown')

    spark_archive = EVIDENCE / ('unbounded-programs/'
        'frontend-representation-20261017/toolchain/raw-evidence.tar.gz')
    spark_digest = hashlib.sha256(spark_archive.read_bytes()).hexdigest()
    assert spark_digest == 'f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952'
    with tarfile.open(spark_archive) as source:
        def spark(path):
            return ' '.join(source.extractfile('spark-source/src/' + path)
                            .read().decode().split())
        assert 'Max_Steps : Natural;' in spark('common/vc_kinds.ads')
        assert 'else Prover_Stat_Maps.Empty_Map)' in spark('why/gnat2why-error_messages.adb')
        assert 'if not Obj.Stats.Is_Empty then' in spark('utils/errout_wrapper.adb')
        assert 'if Stats.Is_Empty then return "";' in spark('flow/flow_error_messages.adb')
        assert 'if Has_Field (Result, "stats") then' in spark('gnatprove/spark_report.adb')

    result = dict(source_files=len(files), source_archive_sha256=digest,
        spark_source_archive_sha256=spark_digest,
        selected_ordinary_commands={name:p['args'] for name,p in selected.items()},
        statistics_boundaries=cases,
        check_kind_domain=len(kinds),
        summary_percentage_last_safe_part=natural_last // 100,
        driver_projection=dict(removed_step_regexps=len(removed),
            import_files=len(projection['import_closure']),
            unknown_raw_steps=-1, normalized_solver_steps=1,
            status='proposed private configuration; not installed or executed'),
        proposed_statistics_projection='fallback only; not implemented or verified',
        native_executions=0,
        scope='source identities and arithmetic; whole response capacity remains conditional')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
