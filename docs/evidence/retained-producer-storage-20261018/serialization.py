#!/usr/bin/env python3
"""Derive JSON skeleton weights and check retained outputs, without a tool run."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile

from check import SPARK

SOURCES = {
    **{name: digest for name, (digest, _) in SPARK.items()},
    'src/why/xgen/xtree_sinfo.adb': '76c87d6da16443965af3754d7daae987d846aae51fb05d5b83bca4f3cf5ffb9b',
    'src/why/xgen/xtree_tables.adb': '5cfb08ec5889062b91b0aee72ad2e2b4ea041093979b4612bc141a65d803051a',
    'src/why/why-sinfo.ads': 'c283273320e7412b039d55caa7ce7d5456531fed330d7e6fa9f6783ecb7cce40',
}
HEADER = '{ "theory_declarations" : '


def strip_comments(text):
    # These three schema declarations contain no comment delimiter in strings.
    return re.sub(r'--[^\n]*', '', text)


def schema_from_sources(source):
    schema_text = strip_comments(source['src/why/xgen/xtree_sinfo.adb'])
    sinfo = strip_comments(source['src/why/why-sinfo.ads'])
    kinds = re.search(r'type Why_Node_Kind is\s*\((.*?)\);', sinfo, re.S).group(1)
    kinds = re.findall(r'\bW_\w+\b', kinds)
    fields = re.findall(
        r'New_Field\s*\(\s*(W_\w+)\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"'
        r'\s*(?:,\s*([^;]*?))?\);', schema_text, re.S)
    assert len(fields) == len(re.findall(r'\bNew_Field\s*\(', schema_text)) == 177
    assert kinds[0] == 'W_Unused_At_Start'
    kinds = kinds[1:]
    assert len(kinds) == len(set(kinds)) == 63
    schema = {kind.upper(): [] for kind in kinds}
    for kind, field, typ, modifier in fields:
        schema[kind.upper()].append(dict(name=field, type=typ, modifier=modifier.strip()))
    common = re.findall(r'New_(Common|Domain|Special)_Field\s*\(\s*"([^"]+)"\s*,\s*"([^"]+)"', schema_text)
    assert common == [('Common', 'Ada_Node', 'Node_Id'),
                      ('Domain', 'Domain', 'EW_Domain'), ('Special', 'Checked', 'Boolean')]
    # All serialized enums have implicit consecutive representations 0..9.
    enum_names = {field['type'] for fs in schema.values() for field in fs
                  if field['type'].startswith('EW_')} | {'EW_ODomain'}
    enum_sizes = {}
    for name in sorted(enum_names):
        body = re.search(r'type ' + name + r' is\s*\((.*?)\);', sinfo, re.S).group(1)
        values = [v.strip() for v in body.split(',')]
        assert all(re.fullmatch(r'EW_\w+', v) for v in values)
        assert len(values) <= 10
        assert not re.search(r'for\s+' + name + r'\s+use', sinfo, re.I)
        enum_sizes[name] = len(values)
    assert 'subtype EW_Domain is' in sinfo
    return schema, enum_sizes


def local_weight(kind, fields, u, h, d):
    # Node kind, ID (<=Natural'Last), domain, punctuation; no child bytes.
    result = len(kind) + 19
    for field in fields:
        typ, mod = field['type'], field['modifier']
        if typ.startswith('W_'):
            primitive = {'Id_One': 0, 'Id_Lone': 4, 'Id_Some': 2, 'Id_Set': 4}[mod]
        elif typ.startswith('EW_'):
            primitive = 2
        else:
            primitive = {
                'Boolean': 5, 'Symbol': 2*u+2,
                'Symbol_Set': 2+h*(2*u+3), 'String_Sets.Set': 2+h*(2*u+3),
                'Source_Ptr': 2*u+16, 'Uint': d+2, 'Ureal': 2*d+25,
            }[typ]
        result += 1 + primitive  # separator before this field
    return result


def quoted(text):
    return '"' + text.replace('"', '\\"') + '"'


def render(value):
    if value is None:
        return 'null'
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, int):
        return (' ' if value >= 0 else '') + str(value)
    if isinstance(value, str):
        return quoted(value)
    assert isinstance(value, list)
    return '[' + ','.join(render(v) for v in value) + ']'


def retained_file(data, schema):
    obj = json.loads(data)
    assert list(obj) == ['theory_declarations']
    roots = obj['theory_declarations']
    rebuilt = (HEADER + render(roots) + '}\n').encode('ascii')
    assert rebuilt == data  # Includes native spaces, quoting, final newline.
    counts, parameters = Counter(), dict(u=0, h=0, d=1)
    pending = list(roots)
    while pending:
        node = pending.pop()
        kind = node[0]
        fields = schema[kind]
        assert len(node) == len(fields)+3
        assert 1 <= node[1] <= 2**31-1 and 0 <= node[2] <= 4
        counts[kind] += 1
        for field, value in zip(fields, node[3:]):
            typ, mod = field['type'], field['modifier']
            if typ.startswith('W_'):
                if value is not None:
                    pending.extend(value if mod in ('Id_Some', 'Id_Set') else [value])
            elif typ in ('Symbol_Set', 'String_Sets.Set'):
                parameters['h'] = max(parameters['h'], len(value))
                parameters['u'] = max(parameters['u'], max(map(len, value), default=0))
            elif typ == 'Symbol':
                parameters['u'] = max(parameters['u'], len(value))
            elif typ == 'Source_Ptr' and value is not None:
                parameters['u'] = max(parameters['u'], len(value[0]))
                assert 1 <= value[1] <= 2**31-1
            elif typ in ('Uint', 'Ureal'):
                numbers = value[:2] if typ == 'Ureal' else [value]
                assert all(re.fullmatch(r'-?[0-9]+', n) for n in numbers)
                parameters['d'] = max(parameters['d'], max(map(len, numbers)))
    occurrences = sum(counts.values())
    weighted = sum(count*local_weight(kind, schema[kind], **parameters)
                   for kind, count in counts.items())
    bound = 29 + occurrences + weighted
    assert parameters['d'] <= 1019
    assert len(data)-1 <= bound  # Close's final LF is not a P character.
    return dict(bytes=len(data), p_characters=len(data)-1, occurrences=occurrences,
                primitive_maxima=parameters, kind_occurrences=dict(sorted(counts.items())),
                weighted_bound=bound, sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    source_archive = root/'docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    sources, manifest = {}, []
    with tarfile.open(source_archive) as archive:
        for name, expected in SOURCES.items():
            data = archive.extractfile('spark-source/'+name).read()
            assert hashlib.sha256(data).hexdigest() == expected
            sources[name] = data.decode()
            manifest.append(dict(path=name, bytes=len(data), sha256=expected))
    schema, enum_sizes = schema_from_sources(sources)
    retained = []
    archive_path = root/'docs/evidence/retained-producer-bodies-20261018/inputs-and-outputs.tar.gz'
    with tarfile.open(archive_path) as archive:
        for entry in archive.getmembers():
            if entry.name.endswith('.gnat-json'):
                retained.append(dict(file=entry.name, **retained_file(archive.extractfile(entry).read(), schema)))
    assert len(retained) == 5
    assert max(sum(f['type'] in ('Symbol_Set','String_Sets.Set') for f in fs)
               for fs in schema.values()) == 1
    # Integer coefficient table in (1,u,h,u*h,d), derived independently of any
    # selected admission threshold. All local costs are multilinear here.
    coefficients = {}
    for kind, fields in schema.items():
        a = local_weight(kind, fields, 0, 0, 0)
        b = local_weight(kind, fields, 1, 0, 0)-a
        c = local_weight(kind, fields, 0, 1, 0)-a
        e = local_weight(kind, fields, 1, 1, 0)-a-b-c
        f = local_weight(kind, fields, 0, 0, 1)-a
        coefficients[kind] = [a,b,c,e,f]
    # Exactly three undominated coefficient rows suffice for nonnegative inputs.
    # With h=3 the first is dominated by the function-declaration row.
    rows = {tuple(v) for v in coefficients.values()}
    frontier = {v for v in rows if not any(
        w != v and all(a <= b for a,b in zip(v,w)) for w in rows)}
    assert frontier == {(58,4,0,0,0), (62,0,0,0,2), (85,2,3,2,0)}
    result = dict(source_manifest=manifest, enum_cardinalities=enum_sizes,
                  field_count=177, kind_count=63, schema=schema,
                  local_weight_coefficient_order=['1','u','h','u*h','d'],
                  local_weight_coefficients=coefficients, retained_outputs=retained,
                  scope='schema transfer and retained-file byte equality; source bounds for u,h,d and occurrence counts remain separate')
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output/'serialization.json').write_text(json.dumps(result,indent=2)+'\n')
    print(f'Verified 63 kinds, 177 fields, and byte-for-byte reconstruction of {len(retained)} retained JSON files')


if __name__ == '__main__':
    main()
