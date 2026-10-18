#!/usr/bin/env python3
"""Attach actual selected literal bytes to established native Main formulas.

Offline research only. Main constructor and source-visit counts are concrete;
fixed inputs, configuration, physical backing and later phases remain separate.
The companion source argument supplies correspondence, not these exercises.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
PRIOR = REPO / 'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
I32 = 2**31 - 1


def require(value, message):
    if not value:
        raise ValueError(message)


def verify_inputs():
    identity = json.loads((HERE / 'inputs.json').read_bytes())
    for item in identity['repository_inputs']:
        raw = (REPO / item['path']).read_bytes()
        require(len(raw) == item['bytes'] and
                hashlib.sha256(raw).hexdigest() == item['sha256'],
                'changed predecessor input: ' + item['path'])
    return identity


def load_model(ada_root):
    """Use the existing source-checked loader, preserving its predecessor defaults.

    Loading also evaluates predecessor examples with their historical fixtures.
    None of those example/fixed-process results is selected by compose().
    """
    verify_inputs()
    loader = runpy.run_path(str(PRIOR / 'compose-null-capacity.py'))
    return loader['load_model'](Path(ada_root))


def source_projection(raw, model):
    """Completely recognize the original shell, then project actual lexemes."""
    require(isinstance(raw, bytes), 'source must be bytes')
    # The retained recognizer additionally accepts VT/FF. The current author
    # alphabet excludes both, including in comments; check before reusing it.
    require(all(32 <= b <= 126 or b in (9, 10, 13) for b in raw),
            'source byte outside current ASCII/HT/CR/LF alphabet')
    recognizer = runpy.run_path(str(PRIOR / 'derive-literal-output.py'))
    selected = recognizer['source_counts'](raw)
    words, tokens, lengths = [], [], []
    at = 0
    while at < len(raw):
        match = recognizer['TOKEN'].match(raw, at)
        require(match is not None, 'unsupported token at byte ' + str(at))
        token = match[0]
        at = match.end()
        if token.isspace() or token.startswith(b'--'):
            continue
        tokens.append(token)
        if re.fullmatch(rb'[A-Za-z][A-Za-z_0-9]*', token):
            words.append(token)
        elif token.startswith(b'"'):
            lengths.append(len(token[1:-1].replace(b'""', b'"')))
    c, n = selected['output_calls'], selected['null_statements']
    require(len(words) == 11 + 2*c + n, 'word projection disagrees with selected shell')
    require(len(lengths) == c and lengths == selected['decoded_literal_lengths'],
            'literal projection disagrees with complete recognizer')
    dots = tokens.count(b'.')
    require(dots == c, 'selected-name projection disagrees with shell')
    scanner = 2*(len(words) + len(lengths))
    # Specialize representative_current_programs(): no operator/declaration/
    # loop/assignment; one with-name, C dotted calls, N nulls, seven scaffold.
    ordinary = scanner + dots + c + n + 7 + 1
    counts = dict(model['main_example_counts'])
    counts.update(parser_nodes=ordinary, parser_entities=1,
        parser_slots=9*(ordinary+c)+61, parser_lists=4+c,
        word_tokens=len(words), source_literals=c, source_calls=c,
        nonconcat_literals=c, output_calls=c,
        String_bound_descriptors=[model['native_string_bound_descriptor']('literal')
                                  for _ in lengths])
    pools = dict(Name_entries=len(words),
        Name_characters=sum(map(len, words))+len(words),
        Uint_entries=0, Uint_digits=0, String_descriptors=2*c,
        String_characters=2*sum(lengths))
    return dict(selected_source=selected, Main_counts=counts, scanner_pools=pools,
        lexemes=dict(word_tokens=len(words), word_characters=sum(map(len, words)),
            maximum_word_characters=max(map(len, words)), literal_tokens=len(lengths),
            qualified_name_dots=dots, scanner_node_allowance=scanner,
            parser_ordinary_node_allowance=ordinary))


def compose(raw, model):
    """Return finite Main counts, with unresolved fixed fields explicitly None.

    Call load_model(ada_root) once, then compose each byte string. An externally
    supplied model must be that returned source-checked model with unchanged
    formulas; the script CLI enforces repository pins before loading it.
    """
    projection = source_projection(raw, model)
    counts = projection['Main_counts']
    main = model['main_native_construct_vector'](**counts)
    # This predecessor function performs no arithmetic on the fixed fields.
    # None marks not-attached terms, never a numerical zero or absent cost.
    logical_projection = dict(Main_constructor=main,
        fixed=dict(node_identities=None, entity_identities=None))
    gigi = model['native_to_gigi_source_interface'](logical_projection, counts)
    return dict(scope='actual selected literal source: Main constructor and gigi source-visit input',
        **projection, Main_constructor=main, gigi_source_interface=gigi,
        local_representation_premises=dict(
            each_literal_length_fits_native_String_Length_and_Integer=
                projection['selected_source']['maximum_literal_length'] <= I32,
            selected_Integer_Last=I32,
            other_scalar_intermediates_table_and_caller_widths='separate obligations'),
        attachment_status=dict(Main_constructor_inputs_attached=True,
            Main_gigi_source_visit_input_attached=True,
            fixed_frontend_terms='accepted predecessor constants available; not attached here',
            configuration_and_indexed_invocation_terms='not attached here',
            complete_native_frontend=False, complete_gigi_allocation=False,
            complete_native_capacity=False, production_admission_changed=False),
        native_tool_executions=0)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    model = load_model(args.ada_root)
    result = compose(args.source.read_bytes(), model)
    result['source_identity'] = dict(path=str(args.source),
        bytes=result['selected_source']['source_bytes'],
        sha256=result['selected_source']['source_sha256'])
    result['native_source_identity'] = dict(commit=model['pin'],
        selected_files=len(model['hashes']), selected_sha256=model['hashes'],
        complete_Ada_macro_inventory_files=model['macro_flag_searched_files'])
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output_calls=result['selected_source']['output_calls'],
        Main_nodes=result['Main_constructor']['total']['node_identities'],
        Main_gigi_source_visits=result['gigi_source_interface']['Main_source_syntax_visit_bound'],
        complete_native_capacity=False)))


if __name__ == '__main__':
    main()
