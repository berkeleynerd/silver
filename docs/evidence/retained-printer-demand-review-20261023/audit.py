"""One independent finite audit of the reviewed printer interface.

Reads retained inputs and source bytes. Does not import or run author or
predecessor code, execute Why3, or prove the source argument.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import time

ROOT = Path(sys.argv[1]).resolve()
FREEZE = sys.argv[2]
HERE = Path(__file__).resolve().parent
EV = Path('docs/evidence')
AUTHOR = EV / 'retained-why-printer-demand-20261023'
inputs = {}


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def frozen(path):
    path = str(path)
    data = (ROOT / path).read_bytes()
    expected = subprocess.check_output(['git', 'show', f'{FREEZE}:{path}'], cwd=ROOT)
    assert data == expected, path
    inputs[path] = identity(data)
    return data


def read(path):
    return json.loads(frozen(path))


def main():
    started = time.perf_counter()
    for path in sorted((ROOT / AUTHOR).iterdir()):
        if path.is_file():
            frozen(path.relative_to(ROOT))
    frozen('docs/research/retained-why-printer-demand.md')
    manifest = read(AUTHOR / 'inputs.json')
    for path, expected in manifest['providers'].items():
        assert identity(frozen(path)) == expected, path
    source_manifest = read(AUTHOR / 'source-witnesses.json')
    archive = source_manifest['archive']
    assert identity(frozen(archive)) == source_manifest['archive_identity']
    sources = {}
    source_identities = {}
    sections = {
        'driver/driver.ml': [(31, 33), (391, 408), (456, 474), (490, 494)],
        'core/printer.ml': [(100, 123), (288, 343), (411, 429), (518, 561)],
        'printer/smtv2.ml': [(676, 699), (786, 831), (855, 923), (962, 1082)],
        'printer/cntexmp_printer.ml': [(81, 138)],
        'transform/discriminate.ml': [(489, 499)],
        'core/ident.ml': [(187, 215), (262, 298)],
        'core/term.ml': [(36, 39), (132, 188), (739, 781), (799, 831), (1177, 1209), (1284, 1299)],
        'core/ty.ml': [(126, 135), (163, 171), (234, 254), (310, 315)],
        'core/decl.ml': [(60, 67), (442, 446), (518, 524), (610, 617)],
        'core/task.ml': [(121, 160), (225, 227), (283, 307), (337, 347)],
        'util/debug.ml': [(77, 91)],
        'util/hcpt.ml': [(153, 158), (286, 309)],
    }
    with tarfile.open(ROOT / archive) as arc:
        for path, spans in sections.items():
            member = 'why3/src/' + path
            data = arc.extractfile(member).read()
            sources[path] = data.decode()
            lines = sources[path].splitlines(keepends=True)
            source_identities[path] = dict(member=member, **identity(data), sections=[
                dict(first=a, last=b, text=''.join(lines[a-1:b])) for a, b in spans])
            if path in source_manifest['sources']:
                prior = source_manifest['sources'][path]
                assert identity(data) == {k: prior[k] for k in ('bytes', 'sha256')}
                for section in prior['sections']:
                    assert ''.join(lines[section['first']-1:section['last']]) == section['text']

    # Anchors for the newly identified registration path and its transitive
    # read-only body scan. These are correspondence checks, not OCaml proofs.
    assert 'when not (Sid.mem s.ls_name (get_used_syms_decl d))' in sources['printer/smtv2.ml']
    assert 'let _, e = open_ls_defn ld in' in sources['core/decl.ml']
    assert 'let syms_term s t = t_s_fold syms_ty syms_ls s t' in sources['core/decl.ml']
    assert 'let t_s_fold = t_gen_fold' in sources['core/term.ml']
    assert 'let tys = lazy (get_type_arguments t)' in sources['core/printer.ml']
    assert 'print_type fmt (Lazy.force tys).(i)' in sources['core/printer.ml']
    assert 'if not (ty_equal ty1 ty2) then raise (TypeMismatch (ty1, ty2))' in sources['core/ty.ml']
    assert 'let printing_info = print_task_prepared ?old:old_channel drv fmt task in' in sources['driver/driver.ml']

    prep = read(EV / 'retained-why-printer-entry-20261020/result.json')
    result = read(AUTHOR / 'result.json')
    by_case = {row['case']: row for row in result['cases']}
    rows = []
    for item in prep['cases']:
        name = item['case']
        output = by_case[name]
        inv = read(EV / f'retained-why-postinline-preparation-20261020/{name}-inventory.json')
        data = read(EV / f'retained-why-printer-entry-20261020/{name}-inventory.json')
        context = read(EV / f'retained-why-returned-storage-20261020/{name}-context.json')
        assert inv['singleton_data_declarations']
        assert inv['singleton_logic_and_inductive_heads']
        for stage in context['stages'].values():
            totals = [r['dimension'][1] + r['formal_arity'] for r in stage['context_roots']]
            assert max(totals) == stage['bound_plus_formal_slots_max'] <= 8
        d = item['dimensions']
        h, p, s = d['task_nodes'], d['P'], d['S']
        a, t = inv['signature_maxima']['arity'], inv['signature_maxima']['type_nodes']
        assert p >= 8 and a <= min(p, 7)
        assert all(len(x['constructor_arities']) <= 2 and
                   max(x['constructor_arities'], default=0) <= a for x in data['data'])
        e = 3 * item['registered_roots'] + 2
        assert item['episodes_upper'] == output['episodes_upper'] == e
        assert output['dimensions'] == dict(S=s, P=p, H=h, A=a, T=t)
        # Two definition-formal openings plus two body-slot passes fit 2P.
        # The accepted interface keeps its separate A slack and field slack.
        for formals in range(a + 1):
            body = p - formals
            assert 2*formals + 2*body <= 2*p + a
        coefficient = (2*p + a) + 2*(a + 1)
        per_call = h * coefficient
        process = e * per_call
        assert output['per_episode_vector']['Ident'] == dict(increments=per_call, requests=0)
        assert output['process_vector']['Ident'] == dict(increments=process, requests=0)
        for owner in ('Decl.Hsdecl', 'Ty.Hsty', 'Theory.Hstdecl', 'Task.Hstask', 'Task.Stdecl.Hcpt'):
            assert output['per_episode_vector'][owner] == dict(increments=0, requests=0)
            assert output['process_vector'][owner] == dict(increments=0, requests=0)
        assert process < 2**62
        assert output['ordinary_print_tree_visits_per_formula_upper'] == 2*s
        rows.append(dict(case=name, N=item['registered_roots'], E=e, H=h, P=p, A=a,
                         per_node_ident=coefficient, per_invocation_ident=per_call,
                         process_ident=process))
    assert len(rows) == 5
    assert result['same_process_global_escape_upper'] == 2
    assert result['save_entering_callbacks_upper'] == 2 and result['saves_upper'] == 3
    assert result['allowance_renewed_for_printing'] is False
    assert result['whole_process_headroom'] is False and result['whole_capacity_rule'] is False
    assert result['aggregate_RAM_gate'] is False

    witness = dict(archive=archive, archive_identity=identity((ROOT / archive).read_bytes()),
                   why3_revision=source_manifest['why3_revision'], sources=source_identities)
    (HERE / 'source-witnesses.json').write_text(json.dumps(witness, indent=2) + '\n')
    answer = dict(status='pass', reviewed_freeze=FREEZE,
                  elapsed_seconds=time.perf_counter()-started,
                  cases=rows, frozen_inputs=inputs, source_members=len(sources),
                  whole_source_argument_machine_checked=False,
                  native_runs=0, predecessor_checker_replays=0,
                  author_checker_replays=0, whole_capacity_rule=False)
    (HERE / 'audit-result.json').write_text(json.dumps(answer, indent=2) + '\n')
    print(json.dumps({k: v for k, v in answer.items() if k != 'frozen_inputs'}))


if __name__ == '__main__':
    main()
