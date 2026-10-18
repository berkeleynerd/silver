#!/usr/bin/env python3
"""Focused offline exercises for the literal native frontend attachment."""
import argparse
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('literal_frontend', HERE/'compose.py')
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
PREFIX = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin '
SUFFIX = b' end Main;'


def run(model):
    passed = []
    base = PREFIX+b'Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("");'+SUFFIX
    result = adapter.compose(base, model)
    selected, counts = result['selected_source'], result['Main_counts']
    assert selected['decoded_literal_lengths'] == [3, 0]
    assert (counts['word_tokens'], counts['source_literals'], counts['source_calls']) == (16, 2, 2)
    assert result['lexemes']['scanner_node_allowance'] == 36
    assert (counts['parser_nodes'], counts['parser_entities'], counts['parser_slots'],
            counts['parser_lists']) == (49, 1, 520, 6)
    assert result['scanner_pools'] == dict(Name_entries=16,
        Name_characters=result['lexemes']['word_characters']+16,
        Uint_entries=0, Uint_digits=0, String_descriptors=4, String_characters=6)
    assert counts['String_bound_descriptors'] == [dict(low_D=1, high_D=1)]*2
    assert result['Main_constructor']['source_query_envelope']['A'] == 19
    passed.append('actual word, dot, decoded-quote, empty literal and parser/pool projection')

    recognizer = adapter.runpy.run_path(str(adapter.PRIOR/'derive-literal-output.py'))
    lexemes = []
    for match in recognizer['TOKEN'].finditer(base):
        token = match[0]
        if token.isspace() or token.startswith(b'--'):
            continue
        lexemes.append(token.upper() if not token.startswith(b'"') else token)
    decorated = b'-- "ignored" Put null 999\r\n'+b'\t-- trivia\r'.join(lexemes)+b'-- EOF "'
    same = adapter.compose(decorated, model)
    for key in ('Main_counts', 'scanner_pools', 'Main_constructor', 'gigi_source_interface', 'lexemes'):
        assert same[key] == result[key], key
    assert same['selected_source']['source_sha256'] != selected['source_sha256']
    for end in (b'\r', b'\n', b'\r\n'):
        assert adapter.compose(b'-- quote " null 123'+end+base, model)['Main_counts'] == counts
    passed.append('case, HT/CR/LF, CRLF, quoted comment text and EOF comment equality')

    def monotone(a, b):
        for key, value in a['Main_constructor']['total'].items():
            assert b['Main_constructor']['total'][key] >= value, key
        for key, value in a['scanner_pools'].items():
            assert b['scanner_pools'][key] >= value, key
        assert b['gigi_source_interface']['Main_source_syntax_visit_bound'] >= a['gigi_source_interface']['Main_source_syntax_visit_bound']
    shorter = adapter.compose(PREFIX+b'Silver_IO.Put ("a");'+SUFFIX, model)
    for body in (b'Silver_IO.Put ("abc");',
                 b'Silver_IO.Put ("a"); null;',
                 b'Silver_IO.Put ("a"); Silver_IO.Put ("");'):
        monotone(shorter, adapter.compose(PREFIX+body+SUFFIX, model))
    # Literal content may resemble source syntax; it contributes only bytes.
    syntax_text = adapter.compose(PREFIX+b'Silver_IO.Put ("null & 0E999 -- Put ""x""");'+SUFFIX, model)
    assert syntax_text['Main_counts']['word_tokens'] == shorter['Main_counts']['word_tokens']
    assert syntax_text['scanner_pools']['Uint_entries'] == 0
    passed.append('monotone call/null/literal growth and syntax-looking literal content')

    for c in range(1, 13):
        for n in range(7):
            raw = PREFIX+b'Silver_IO.Put ("x");'*c+b'null;'*n+SUFFIX
            actual = adapter.compose(raw, model)
            w = 11+2*c+n
            ordinary = 2*(w+c)+2*c+n+8
            cnt = actual['Main_counts']
            assert (cnt['word_tokens'], cnt['parser_nodes'], cnt['parser_slots'],
                    cnt['parser_lists']) == (w, ordinary, 9*(ordinary+c)+61, 4+c)
            total = actual['Main_constructor']['total']
            assert (total['node_identities'], total['entity_identities'],
                    total['dynamic_slots'], total['syntax_list_headers']) == (
                        41+19*c+4*n, 1+2*c, 430+329*c+36*n, 15+8*c+n)
            assert actual['gigi_source_interface']['Main_source_syntax_visit_bound'] == 73+81*c+4*n
            assert actual['gigi_source_interface']['separate_fixed_frontend_allowance'] == dict(node_identities=None, entity_identities=None)
    passed.append('84 finite call/null combinations and visibly unattached fixed fields')

    sample = (adapter.REPO/'samples/hello_world.adb').read_bytes()
    attached = adapter.compose(sample, model)
    example = next(item for item in model['representative_current_programs']()['programs']
                   if item['source'] == 'samples/hello_world.adb')
    assert attached['Main_counts'] == example['source_counts']
    assert attached['scanner_pools'] == example['scanner_pools']
    assert attached['Main_constructor'] == example['logical_join']['Main_constructor']
    # Only fixed fields differ: the old sample's fixture is never attached here.
    for key, value in attached['gigi_source_interface'].items():
        if key != 'separate_fixed_frontend_allowance':
            assert value == example['gigi_source_interface'][key], key
    passed.append('byte-identical current hello sample equals predecessor Main projection')

    many = adapter.compose(PREFIX+b'Silver_IO.Put ("x");'*5000+SUFFIX, model)
    assert many['selected_source']['source_bytes'] > 4096
    assert many['Main_counts']['output_calls'] == 5000
    assert many['attachment_status']['production_admission_changed'] is False
    passed.append('5000-call offline input exceeds current cap without changing admission')

    rejected = [b'', PREFIX+b'null;'+SUFFIX,
        PREFIX+b'Silver_IO.Put ("a" & "b");'+SUFFIX,
        PREFIX+b'Silver_IO.Put (X);'+SUFFIX,
        PREFIX+b'Put ("a");'+SUFFIX,
        PREFIX+b'Silver_IO.Put ("a", "b");'+SUFFIX,
        PREFIX+b'for I in 1..2 loop Silver_IO.Put ("a"); end loop;'+SUFFIX,
        PREFIX+b'if True then Silver_IO.Put ("a"); end if;'+SUFFIX,
        base.replace(b'begin', b'X : Integer := 0; begin'),
        base.replace(b'with Silver_IO;', b'with Silver_IO, Silver_Arguments;'),
        base.replace(b'pragma SPARK_Mode (On);', b'pragma SPARK_Mode (On); pragma Assert (True);'),
        base.replace(b'end Main', b'end Main2'), base+b'null;',
        base.replace(b'procedure Main', b'procedureMain'),
        base.replace(b'"a""b"', b'"a\nb"'),
        base.replace(b'"a""b"', b'"unterminated'),
        base+b'\v', base+b'\f', b'-- hidden\v'+base, b'-- hidden\f'+base,
        base+b'\x00', base+b'\x80', base+b'\xef\xbb\xbf']
    for raw in rejected:
        try:
            adapter.compose(raw, model)
        except ValueError:
            pass
        else:
            raise AssertionError('unsupported source accepted: '+repr(raw))
    passed.append(str(len(rejected))+' negative shell, grammar, whole-token, quote and alphabet cases')
    return dict(passed=True, focused_checks=passed,
        source_files_checked=len(model['hashes']),
        complete_Ada_macro_inventory_files=model['macro_flag_searched_files'],
        native_tool_executions=0, universal_proof_claimed=False,
        production_admission_changed=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(adapter.load_model(args.ada_root))
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
