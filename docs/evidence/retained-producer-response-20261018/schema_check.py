#!/usr/bin/env python3
"""Offline response-schema arithmetic; not a source-to-goal capacity proof."""
import hashlib
import itertools
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent


def schema_counts(r, g, a, s, k, w, answer_bytes, timing_bytes, warning_bytes):
    c = 4 + 6*r + s + 3*g + a
    return dict(containers=c, values=c + 9*r + 3*s + 3*a + k + w + 1,
                fields=4 + 14*r + 4*s + 2*g + 4*a + k,
                strings=2*r + a + w, integers=3*r + 2*s + a + 1,
                floats=s + a + k, booleans=4*r,
                string_bytes=28 + 139*r + 29*s + 29*g + 22*a
                             + answer_bytes + timing_bytes + warning_bytes)


def byte_bound(c):
    return (2*c['containers'] + c['values'] - 1 + 3*c['fields']
            + 2*c['strings'] + 6*c['string_bytes'] + 20*c['integers']
            + 317*c['floats'] + 5*c['booleans'])


def expanded(r, g, a, s, k, w, la, lt, lw):
    return 212 + 987*r + 189*g + 489*a + 549*s + 321*k + 3*w + 6*(la+lt+lw)


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['source_archive_sha256']
    with tarfile.open(archive) as t:
        sources = {m.name: t.extractfile(m).read() for m in t if m.isfile()}
    for f in identity['files']:
        assert hashlib.sha256(sources[f['path']]).hexdigest() == f['sha256']
    spark_archive = HERE.parent/'unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    assert hashlib.sha256(spark_archive.read_bytes()).hexdigest() == 'f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952'
    with tarfile.open(spark_archive) as tar:
        spark = {m.name: tar.extractfile(m).read().decode()
                 for m in tar if m.isfile() and m.name.startswith('spark-source/src/')
                 and m.name.endswith(('.adb', '.ads'))}
    assert len(spark) == 279
    assert sorted(name for name, text in spark.items() if 'GP_Check_Marker' in text) == [
        'spark-source/src/common/vc_kinds.ads',
        'spark-source/src/why/why-gen-expr.adb']
    emitter = spark['spark-source/src/why/why-gen-expr.adb']
    registry = spark['spark-source/src/why/gnat2why-error_messages.adb']
    assert 'Register_VC (N, Reason, Current_Subp, Check_Info)' in emitter
    assert 'New_Check_Label (Sloc, Reason, Id)' in emitter
    assert "VC_Table.Append (VC_Info'(N, Reason, Check_Info));" in registry
    expl = sources['why3/src/gnat/gnat_expl.ml'].decode()
    assert 'b.check_kind <- Some kind;\n            b.check_id <- Some id;' in expl
    assert 'b.check_kind <- Some VC_Loop_Invariant_Init' in expl
    assert 'b.check_kind <- Some VC_Loop_Invariant_Preserv' in expl
    project = HERE.parents[2]
    image_paths = ['src/silver_image_files.adb', 'src/silver_image_model.adb',
                   'src/silver_image_model_templates.adb']
    image_hashes = {name: hashlib.sha256((project/name).read_bytes()).hexdigest()
                    for name in image_paths}
    image_templates = (project/image_paths[-1]).read_text()
    strings = re.findall(r'"(?:[^"]|"")*"', image_templates)
    joined = ''.join(s[1:-1].replace('""', '"') for s in strings)
    assert 'GP_Check' not in joined
    assert '\\u' not in joined  # No Unicode escape can encode a hidden label.
    assert "Put_Byte (Output, Character'Val (Item), Success);" in (project/image_paths[0]).read_text()
    callsites = json.loads((HERE / 'timing-callsites.json').read_text())
    for item in callsites:
        source = sources['why3/' + item['path']]
        assert hashlib.sha256(source).hexdigest() == item['file_sha256']
        assert source.decode().split('\n')[item['line']-1].strip() == item['text']
    assert len(callsites) == 8

    closure = json.loads((HERE / 'driver-projection.json').read_text())['import_closure']
    transforms = set()
    for name in closure:
        driver = sources['installed/libexec/spark/share/why3/drivers/' + name].decode()
        # Driver comments nest. Preserve quoted literals and line boundaries.
        depth = 0
        quoted = False
        clean = []
        i = 0
        while i < len(driver):
            pair = driver[i:i+2]
            if depth == 0 and quoted:
                clean.append(driver[i])
                if driver[i] == '\\':
                    i += 1
                    clean.append(driver[i])
                elif driver[i] == '"':
                    quoted = False
                i += 1
            elif depth == 0 and driver[i] == '"':
                quoted = True
                clean.append(driver[i])
                i += 1
            elif depth == 0 and driver[i:i+3] == '(*)':
                # driver_lexer.mll recognizes the multiplication symbol
                # before the comment opener.
                clean.append('(*)')
                i += 3
            elif pair == '(*':
                depth += 1
                i += 2
            elif pair == '*)':
                assert depth > 0
                depth -= 1
                i += 2
            else:
                if depth == 0 or driver[i] == '\n':
                    clean.append(driver[i])
                i += 1
        assert depth == 0 and not quoted, (name, depth, quoted)
        driver = ''.join(clean)
        transforms.update(re.findall(r'^transformation "([^"]+)"', driver, re.M))
    phases = {'gnatwhy3.' + n for n in
              ('init', 'run_vcs', 'save_session', 'register_vcs', 'schedule_vcs')}
    keys = phases | {'gnatwhy3.transformations.' + n for n in
                     transforms | {'split_goal_wp_conj', 'introduce_premises'}}
    keys.add('rac_prover')  # Conservative even though no proved-result RAC runs.
    assert (len(keys), sum(map(len, keys)), max(map(len, keys))) == (27, 1061, 59)

    kinds = sources['why3/src/gnat/gnat_expl.ml'].decode()
    kinds = kinds.split('let check_kind_to_ada kind =')[1].split('let check_kind_to_string')[0]
    assert max(map(len, re.findall(r'"([^"]*)"', kinds))) == 35
    config = json.loads(sources['installed/share/spark/config/gnatprove.conf'])
    names = {p['name'] for p in config['provers']
             if p['shortcut'] in ('cvc5', 'z3', 'altergo')} | {'Trivial', 'Checker'}
    assert len(names) == 5 and max(map(len, names)) == 7

    # Both expressions are affine. Equality at zero and each basis vector
    # checks every coefficient; this is algebra, not an execution sample bound.
    zero = [0] * 9
    vectors = [zero] + [[int(i == j) for i in range(9)] for j in range(9)]
    for values in vectors:
        assert byte_bound(schema_counts(*values)) == expanded(*values)
    for r, g, w, la, lw in itertools.product((0, 1, 17), repeat=5):
        assert expanded(r, g, 4*g, 5*r, 27, w, la, 1061, lw) == (
            15245 + 3732*r + 2145*g + 3*w + 6*(la+lw))
        assert expanded(r, g, 4*g, 5*r, 0, w, 19*4*g, 0, lw) == (
            212 + 3732*r + 2601*g + 3*w + 6*lw)

    result = dict(
        timing_fields_max=27, timing_key_bytes_max=1061, timing_key_length_max=59,
        timing_keys=sorted(keys), kind_bytes_max=35, prover_name_bytes_max=7,
        json_container_depth_max=7, parser_stack_with_sentinel_max=8,
        registered_record_bound='R <= V + 2*V_loop <= 3*V per response; ordinary Main has V_loop=0',
        spark_source_files=279, image_label_preservation_inputs=image_hashes,
        raw_byte_bound='15245 + 3732*R + 2145*G + 3*W + 6*(L_A + L_W)',
        proposed_projected_byte_bound='212 + 3732*R + 2601*G + 3*W + 6*L_W',
        native_executions=0,
        scope='Conditional all-proved Per_Check response schema; G, warnings, answer bytes, upstream representations and final report remain to be joined')
    (HERE / 'schema-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
