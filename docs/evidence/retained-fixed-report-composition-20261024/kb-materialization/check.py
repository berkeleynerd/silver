#!/usr/bin/env python3
"""Check the new KB materialization obligation only, without native execution."""
import hashlib
import json
import platform
import re
import tarfile
import time
from pathlib import Path
from xml.etree import ElementTree as ET
from xml.parsers import expat
import capacity as C

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def archive(path):
    with tarfile.open(path) as tar:
        return {m.name: tar.extractfile(m).read() for m in tar if m.isfile()}


def main():
    start = time.monotonic()
    manifest = json.loads((HERE / 'source-manifest.json').read_text())
    for path, digest in manifest['providers'].items():
        assert sha((REPO / path).read_bytes()) == digest, path
    for path, digest in manifest['packet_inputs'].items():
        assert sha((HERE / path).read_bytes()) == digest, path
    prefix = manifest['accepted_research_prefix']
    assert sha((REPO / 'docs/research/retained-fixed-report-composition.md').read_bytes()[:prefix['bytes']]) == prefix['sha256']
    archives = [
        (archive(HERE / 'sources.tar.gz'), 'source_members'),
        (archive(REPO / 'docs/evidence/retained-producer-gpr-descriptor-20261018/gprbuild-v26.0.0.tar.gz'), 'GPR_source_members'),
        (archive(HERE / 'xmlada-5e5b761eb827f458efd2043a5e9ab03e1a614720.tar.gz'), 'XMLAda_source_members'),
    ]
    all_sources = {}
    for sources, field in archives:
        for name, expected in manifest[field].items():
            data = sources[name]
            assert len(data) == expected['bytes'] and sha(data) == expected['sha256'], name
            all_sources[name] = data.decode()

    def source(suffix):
        matches = [v for k, v in all_sources.items() if k.endswith('/' + suffix)]
        assert len(matches) == 1, suffix
        return matches[0]

    # New target/fallback and external-entity inventory. We do not replay the
    # previous all-package selection or parsed-project baseline checker.
    db = archive(REPO / 'docs/evidence/retained-producer-gpr-descriptor-20261018/installed-configs.tar.gz')

    def parse(name):
        builder = ET.TreeBuilder()
        parser = expat.ParserCreate()
        parser.StartElementHandler = builder.start
        parser.EndElementHandler = builder.end
        parser.CharacterDataHandler = builder.data
        events = []

        def external(parent, context, system):
            assert '/' not in system and '\\' not in system
            path = 'db/' + system
            data = db[path]
            events.append(dict(path=path, bytes=len(data), sha256=sha(data)))
            child = parent.ExternalEntityParserCreate(context)
            child.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
            child.ExternalEntityRefHandler = lambda c, b, s, p: external(child, c, s)
            child.Parse(data, True)
            return 1

        parser.ExternalEntityRefHandler = lambda c, b, s, p: external(parser, c, s)
        parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
        parser.Parse(db[name], True)
        return builder.close(), events

    trees = {}
    external_events = {}
    targets = []
    fallbacks = []
    for name in sorted(n for n in db if n.endswith('.xml')):
        root, external_events[name] = parse(name)
        trees[name] = root
        targets.extend(dict(file=name, canonical=s.get('canonical', ''),
                            patterns=[p.text or '' for p in s.findall('target')])
                       for s in root.findall('targetset'))
        fallbacks.extend(dict(file=name, values=[p.text or '' for p in s.findall('target')])
                         for s in root.findall('fallback_targets'))
    assert dict(targetsets=targets, fallbacks=fallbacks) == json.loads((HERE / 'inputs/kb-targets.json').read_text())
    assert len(targets) == 104 and sum(len(s['patterns']) for s in targets) == 279
    assert len(fallbacks) == 3 and sum(len(s['values']) for s in fallbacks) == 6
    assert all(s['patterns'] for s in targets)
    assert all(s['values'] for s in fallbacks)
    for row in targets:
        for pattern in row['patterns']:
            pattern.encode('ascii')
            re.compile('^' + pattern + '$')  # grammar sanity, not native compilation evidence

    metadata = json.loads((HERE / 'inputs/first-directory-metadata.json').read_text())
    assert len(metadata['entries']) == 59
    assert len(set(x['name'] for x in metadata['entries'])) == 59
    gprbuild = next(x for x in metadata['entries'] if x['name'] == 'gprbuild')
    gprconfig = next(x for x in metadata['entries'] if x['name'] == 'gprconfig')
    assert gprbuild['symlink'] and gprconfig['symlink']
    gpr_prefix = str(Path(gprbuild['target']).parent.parent)
    assert Path(gprconfig['target']).parent.parent == Path(gpr_prefix)
    vendor = gpr_prefix.removesuffix('/libexec/spark')
    default_db = gpr_prefix + '/share/gprconfig'
    effective = json.loads((HERE / 'inputs/effective-path-metadata.json').read_text())['entries']
    assert effective[0]['resolved'] == gprbuild['target']
    assert effective[1]['resolved'] == gprconfig['target']
    assert effective[2]['resolved'] == default_db
    assert effective[3]['resolved'] == vendor + '/share/spark/config/frames'
    assert effective[4]['resolved'] == vendor + '/share/spark/config/gnat2why'
    phase_inputs = json.loads((HERE / 'inputs/phase-inputs.json').read_text())
    phases = {}
    for phase, extra in [('datarep', None), ('phase1', 'frames'), ('translation', 'gnat2why')]:
        names = sorted(n for n in db if n.startswith('db/') and n.endswith('.xml'))
        dirs = [default_db]
        counts = [len(names)]
        if extra:
            names.append(extra + '/config.xml')
            dirs.append(vendor + '/share/spark/config/' + extra)
            counts.append(1)
        expected = dict(
            directories=dirs, files_per_directory=counts,
            files=[dict(path=n, bytes=len(db[n]), sha256=sha(db[n]),
                        effective_path=(default_db if n.startswith('db/') else dirs[-1]) + '/' + Path(n).name)
                   for n in names],
            external_events=[dict(top_level=n, **event) for n in names for event in external_events[n]])
        assert expected == phase_inputs[phase]
        assert len(expected['external_events']) == 151
        phases[phase] = C.initialization(phase)
    assert phases['datarep']['target_vector']['backing_bytes'] == 14352
    assert phases['datarep']['target_vector']['relocated_list_node_weight'] == 324
    assert phases['datarep']['target_vector']['gross_list_node_allocation_events_upper'] == 2322
    assert phases['datarep']['fallback_vector']['backing_bytes'] == 400
    assert phases['datarep']['fallback_vector']['gross_list_node_allocation_events_upper'] == 48
    assert phases['datarep']['regexp']['Pattern_Matcher_bytes_upper'] == 3312
    assert phases['datarep']['File_Input_buffer']['individual_String_bytes_upper'] == 60298

    # The selected compiler executable patterns use the shared ASCII regexp
    # subset. This is a directory/candidate inventory, not a query-output bound
    # or proof that the batch callback succeeds before a later PATH directory.
    descriptions = {}
    for name, root in trees.items():
        for d in root.findall('compiler_description'):
            descriptions[d.findtext('name')] = (name, d)
    candidates = []
    for name, (file, d) in sorted(descriptions.items()):
        pattern = d.findtext('executable') or ''
        if not pattern:
            continue
        matches = [x['name'] for x in metadata['entries'] if re.fullmatch(pattern, x['name'])]
        if matches:
            candidates.append(dict(description=name, file=file, pattern=pattern, matches=matches,
                                   xml=ET.tostring(d, encoding='unicode')))
    assert candidates == json.loads((HERE / 'inputs/candidate-descriptions.json').read_text())
    assert len(candidates) == 10 and sum(len(r['matches']) for r in candidates) == 14

    # This fixed parser input is initialized even with schema validation off.
    text = source('schema-validators-xsd_grammar.adb')
    meta = re.search(r'Metaschema\s*:\s*aliased constant String\s*:=\s*"((?:[^"]|"")*)";', text).group(1).replace('""', '"').encode()
    assert meta == (HERE / 'inputs/metaschema.xml').read_bytes()
    root = ET.fromstring(meta)
    metaschema = dict(bytes=len(meta), sha256=sha(meta), elements=len(list(root.iter())),
                      attributes=sum(len(e.attrib) for e in root.iter()),
                      added_to_grammar_with_validation_disabled=True,
                      complete_parser_grammar_allocation_bound=None)
    assert (metaschema['bytes'], metaschema['elements'], metaschema['attributes']) == (32248, 685, 884)
    receipts = {
        'target_only_parent': 'Parse_Compiler_Info => False' in source('gpr-util-knowledge.adb'),
        'ordered_String_set': 'Ada.Containers.Indefinite_Ordered_Sets (String)' in source('gpr.ads'),
        'ordered_Name_set': 'Ada.Containers.Ordered_Sets (Name_Id)' in source('gpr.ads'),
        'attribute_reset_per_package': 'Attr_Set.Clear;' in source('gpr-attr.adb'),
        'initial_RTS_four': 'new GNAT.OS_Lib.String_List (1 .. 4)' in source('gpr-knowledge.adb'),
        'anchored_target': 'Compile ("^" & Val & "$")' in source('gpr-knowledge.adb'),
        'vector_growth': 'New_Capacity := 2 * New_Capacity;' in source('a-convec.adb'),
        'vector_copies_old_elements': 'SA (Index_Type\'First .. Before - 1)' in source('a-convec.adb'),
        'indefinite_list_copies_String': "new Element_Type'(Src.Element.all)" in source('a-cidlli.adb'),
        'regexp_32_byte_class': 'Emit_Ptr := Emit_Ptr + 32;' in source('s-regpat.adb'),
        'regexp_dummy_1000': 'Dummy : Pattern_Matcher (1000);' in source('s-regpat.adb'),
        'File_Input_exact_length': 'Input.Buffer := new String (1 .. Length);' in source('input_sources-file.adb'),
        'external_entity_opens_file': 'Parser.Inputs.Input := new File_Input;' in source('sax-readers.adb'),
        'schema_initializes_before_validation_test': 'Initialize_Grammar (Parser);\n\n      if Get_Feature (Parser, Schema_Validation_Feature)' in source('schema-readers.adb'),
        'metaschema_added': 'Add_Schema_For_Schema (Reader);' in source('schema-validators.adb'),
        'metaschema_parsed': 'Parse (Schema, Input);' in source('schema-validators-xsd_grammar.adb'),
    }
    assert all(receipts.values()), receipts
    # Reuse accepted counts without invoking its checker or parsing GPR again.
    old = json.loads((REPO / 'docs/evidence/retained-fixed-report-composition-20261024/gpr-baseline/result.json').read_text())
    assert old['predefined']['attribute_initializers'] == 216
    assert old['predefined']['package_initializers'] == 19
    result = dict(
        scope='Enumerated KB initialization objects and two predefined ordered sets',
        platform=platform.system() + ' ' + platform.machine(),
        providers=len(manifest['providers']), selected_complete_source_members=len(all_sources),
        phases=phases, source_branch_receipts=receipts, metaschema=metaschema,
        discovery=dict(first_directory_entries=59, candidate_descriptions=10,
                       candidate_description_name_pairs=14,
                       candidate_names=sorted({n for r in candidates for n in r['matches']}),
                       prospective_exact_directory_membership_required=True,
                       command_output_bound=None, runtime_traversal_bound=None,
                       stop_before_later_PATH_directories_proved=False),
        native_executions=0, successful_predecessor_checker_replays=0,
        new_native_captures=0, narrow_read_only_metadata_inventory=True,
        runtime_corpus_rescans=0, P=188, e_upper=2,
        save_entering_callbacks_upper=2, saves_upper=3, aggregate_RAM_or_stack_gate=False,
        complete_producer_configuration_capacity_closed=False,
        elapsed_seconds=round(time.monotonic() - start, 6))
    (HERE / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(json.dumps({k: result[k] for k in ['scope', 'providers', 'selected_complete_source_members',
        'complete_producer_configuration_capacity_closed', 'elapsed_seconds']}))


if __name__ == '__main__':
    main()
