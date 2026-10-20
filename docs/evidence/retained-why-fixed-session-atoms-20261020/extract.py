#!/usr/bin/env python3
"""New typed atom/attribute projection; import saved occurrence certificates.

No native process, session replay, binder/alpha interpreter or solver runs.
Unsupported numeric layouts are retained explicitly and prevent a complete
numeric certificate; they are never omitted from atom coverage.
"""
import argparse
import collections
import gzip
import hashlib
import io
import json
from pathlib import Path
import runpy
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
DOMAIN = E/'retained-why-fixed-session-domain-20261020'
OUTCOMES = E/'retained-why-session-save-outcomes-20261019'
STATE = E/'retained-why-session-save-state-20261019'
BASE = runpy.run_path(str(OUTCOMES/'check.py'))['Atoms']


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(path.read_bytes())


def selected_member(archive, member, expected):
    # Only a single exact named regular file is read; never extract paths.
    with tarfile.open(archive) as stream:
        row = stream.getmember(member)
        assert row.isfile() and not row.issym() and not row.islnk()
        assert row.size == expected['bytes']
        raw = stream.extractfile(row).read()
    assert identity(raw) == expected, member
    return raw


class TypedAtoms(BASE):
    def __init__(self, blocks):
        super().__init__(blocks)
        self.attributes, self.term_attributes, self.identifier_attributes = {}, {}, {}
        self.pattern_kinds = collections.Counter()
        self.pattern_occurrences, self.case_patterns = {}, {}
        self.unsupported = []
        self.last_read = None

    def row(self, pointer):
        self.last_read = pointer
        return super().row(pointer)

    def attrs(self, pointer):
        result = []
        for attr, unit in self.mapping(pointer):
            assert unit == 1
            string, tag = self.fields(attr, 2)
            assert tag & 1
            raw = self.string(string)
            self.attributes[str(attr)] = dict(string_pointer=string, hex=raw.hex(), bytes=len(raw),
                attr_tag=tag >> 1, attr_tag_word=tag)
            result.append(attr)
        return result

    def ident(self, pointer):
        if str(pointer) in self.identifiers:
            return
        super().ident(pointer)
        _, attrs, _, _ = self.fields(pointer, 4)
        self.identifier_attributes[str(pointer)] = self.attrs(attrs)

    def number(self, value):
        if value & 1:
            number = self.integer(value)
            result = dict(representation='immediate_OCaml_int', raw_word=value)
        else:
            row, raw = self.row(value)
            result = dict(representation='heap_Zarith_custom', pointer=value,
                tag=row['tag'], words=row['words'], header=row['header'], payload_hex=raw.hex())
            # Retained Zarith 1.14 source contract: custom ops word, followed
            # by sign/used-limb header and little-endian 64-bit GMP limbs.
            # This does not claim historical installed-source identity.
            if row['tag'] != 255 or row['words'] < 3:
                result.update(representation='unsupported_heap_integer',
                    reason='not a supported Zarith custom block', decoded_value=None)
                self.unsupported.append(result)
                return result
            words = struct.unpack('<'+'Q'*row['words'], raw)
            used = words[1] & ((1 << 63)-1)
            sign = -1 if words[1] >> 63 else 1
            if not 1 <= used <= len(words)-2 or words[1+used] == 0:
                result.update(representation='unsupported_heap_integer',
                    reason='invalid used-limb size or zero most-significant limb', decoded_value=None)
                self.unsupported.append(result)
                return result
            limbs = words[2:2+used]
            number = sign*sum(limb << (64*i) for i,limb in enumerate(limbs))
            result.update(custom_ops_pointer=words[0], sign=sign, used_limbs=used,
                limbs=list(limbs), unused_payload_words=list(words[2+used:]),
                bit_length_upper=64*used, decimal_bytes_upper=64*used+1)
        result.update(value=str(number), decimal_bytes=len(str(number)),
            absolute_decimal_digits=len(str(abs(number))), bit_length=abs(number).bit_length())
        return result

    def constant(self, pointer):
        if str(pointer) in self.constants:
            return
        row, _ = self.row(pointer)
        kind = row['tag']
        value, = self.fields(pointer, 1, kind)
        if kind == 0:
            literal_kind, integer = self.fields(value, 2)
            assert literal_kind in (1,3,5,7,9)
            result = dict(kind='int', literal_kind=literal_kind >> 1, parts=[self.number(integer)])
        elif kind == 1:
            literal_kind, real = self.fields(value, 2)
            # Preserve the literal-kind tag/payload as well as complete real
            # components, rather than treating all real representations alike.
            literal = dict(immediate=bool(literal_kind & 1), raw_word=literal_kind)
            if literal_kind & 1:
                assert literal_kind == 1
                literal['kind'] = 'RLitUnk'
            else:
                r, data = self.row(literal_kind)
                assert r['tag'] in (0,1)
                payload, = self.fields(literal_kind,1,r['tag'])
                literal.update(kind=('RLitDec','RLitHex')[r['tag']],
                    parameter=self.integer(payload), tag=r['tag'],
                    words=r['words'], payload_hex=data.hex())
            result = dict(kind='real', literal_kind=literal,
                parts=[self.number(x) for x in self.fields(real, 3)])
        else:
            assert kind == 2
            raw = self.string(value)
            result = dict(kind='string', string_pointer=value, bytes=len(raw), hex=raw.hex())
        self.constants[str(pointer)] = result

    def pattern(self, pointer):
        if pointer in self.patterns:
            return
        super().pattern(pointer)
        node, _, _ = self.fields(pointer, 3)
        if node & 1:
            assert node == 1
            kind, count = 'Pwild', 1
        else:
            row, _ = self.row(node)
            tag = row['tag']
            fields = self.fields(node, (1,2,2,2)[tag], tag)
            kind = ('Pvar','Papp','Por','Pas')[tag]
            if tag == 0:
                count = 1
            elif tag == 1:
                count = 1+sum(self.pattern_occurrences[p] for p in self.seq(fields[1]))
            elif tag == 2:
                count = 1+self.pattern_occurrences[fields[0]]+self.pattern_occurrences[fields[1]]
            else:
                count = 1+self.pattern_occurrences[fields[0]]
        self.pattern_kinds[kind] += 1
        self.pattern_occurrences[pointer] = count

    def term(self, pointer):
        if pointer in self.terms:
            return
        _, _, attrs, _ = self.fields(pointer, 4)
        self.term_attributes[str(pointer)] = self.attrs(attrs)
        super().term(pointer)
        node = self.fields(pointer, 4)[0]
        if not node & 1 and self.row(node)[0]['tag'] == 5:
            _, branches = self.fields(node, 2, 5)
            patterns = [self.fields(branch, 3)[0] for branch in self.seq(branches)]
            self.case_patterns[str(pointer)] = dict(branch_patterns=patterns,
                structural_pattern_occurrences=sum(self.pattern_occurrences[p] for p in patterns))


def load_case(name):
    if name == 'input_is_valid':
        certificate_path = STATE/'binder-certificate.json'
        cert = read(certificate_path)
        prior = read(OUTCOMES/'atom-certificate.json')
        assert identity(certificate_path.read_bytes()) == prior['binder_certificate_identity']
        raw = selected_member(STATE/'capture.tar.gz', prior['capture_member'], prior['capture_member_identity'])
        provenance = dict(phase='prior first Input_Is_Valid/cvc5 inline entry', pid=97103,
            archive=str((STATE/'capture.tar.gz').relative_to(REPO)), member=prior['capture_member'],
            member_identity=prior['capture_member_identity'],
            occurrence_certificate=str(certificate_path.relative_to(REPO)),
            occurrence_certificate_identity=identity(certificate_path.read_bytes()),
            accepted_prior_atom_certificate=str((OUTCOMES/'atom-certificate.json').relative_to(REPO)))
    else:
        manifest = read(DOMAIN/'capture-manifest.json')
        archive, = [a for a in manifest['archives'] if a['path']=='capture-'+name.replace('_','-')+'.tar.gz']
        member = name+'/capture/session-blocks.jsonl'
        row, = [r for r in archive['members'] if r['path']==member]
        expected = {k:row[k] for k in ('bytes','sha256')}
        raw = selected_member(DOMAIN/archive['path'], member, expected)
        certificate_path = DOMAIN/(name.replace('_','-')+'-analysis.json')
        analysis = read(certificate_path)
        cert = analysis['full_certificate']
        provenance = dict(phase='pre-scheduling registration', pid=analysis['pid'],
            archive=str((DOMAIN/archive['path']).relative_to(REPO)), member=member, member_identity=expected,
            occurrence_certificate=str(certificate_path.relative_to(REPO)),
            occurrence_certificate_identity=identity(certificate_path.read_bytes()))
        prior = None
    blocks = {}
    for line in io.BytesIO(raw):
        row = json.loads(line)
        assert row['address'] not in blocks
        blocks[row['address']] = row
    return cert, blocks, provenance, prior


def project(name):
    start = time.perf_counter()
    cert, blocks, provenance, prior = load_case(name)
    roots = sorted(map(int, cert['formulas']))
    assert roots == sorted({p['formula'] for task in cert['tasks'].values() for p in task['propositions']})
    atoms = TypedAtoms(blocks)
    failures = []
    try:
        for pointer in roots:
            atoms.term(pointer)
        for task in cert['tasks'].values():
            for proposition in task['propositions']:
                identifier, = atoms.fields(proposition['symbol'], 1)
                atoms.ident(identifier)
    except (AssertionError, KeyError, IndexError, ValueError) as error:
        failures.append(dict(error=repr(error), last_read_pointer=atoms.last_read,
            context='typed formula/deferred-substitution/attribute/proposition-name coverage'))
    goal_ids = {}
    proposition_ids = set()
    if not failures:
        for task_id, task in cert['tasks'].items():
            prop = task['propositions'][0]
            assert prop['kind'] == 2 and prop['formula'] == task['goal_formula']
            identifier, = atoms.fields(prop['symbol'], 1)
            goal_ids[task_id] = identifier
            for proposition in task['propositions']:
                proposition_ids.add(atoms.fields(proposition['symbol'],1)[0])
    def attr_summary(collection):
        collection = list(collection)
        byte_sums = [sum(atoms.attributes[str(a)]['bytes'] for a in v) for v in collection]
        return dict(min_count=min(map(len,collection),default=0), max_count=max(map(len,collection),default=0),
            min_sum_bytes=min(byte_sums,default=0), max_sum_bytes=max(byte_sums,default=0))
    term_attr_union = set().union(*map(set,atoms.term_attributes.values()))
    proposition_attr_union = set().union(*(set(atoms.identifier_attributes[str(p)]) for p in proposition_ids))
    shape_attr_union = term_attr_union | proposition_attr_union
    parts = [p for c in atoms.constants.values() for p in c.get('parts',[]) if 'value' in p]
    name_sizes = [r['length'] for r in atoms.identifiers.values()]
    shape_visits = {task:sum(cert['formulas'][str(p['formula'])]['opened_term_occurrences'] for p in row['propositions'])
                    for task,row in cert['tasks'].items()}
    # Preserve every APn occurrence and each proposition occurrence. These
    # sums only import accepted scalar counts; no opened traversal is rerun.
    J = sum(len(cert['tasks'][str(v['task'])]['propositions'])+1 for v in cert['visits'] if not v['detached'])
    result = dict(case=name, provenance=provenance,
        typed_graph_complete=not failures, numeric_components_complete=not atoms.unsupported and not failures,
        formula_roots=roots, covered_term_pointers=sorted(atoms.terms), read_pointers=sorted(atoms.read),
        term_constructor_counts=dict(atoms.term_kinds), pattern_constructor_counts=dict(atoms.pattern_kinds),
        pattern_pointers=sorted(atoms.patterns), structural_pattern_occurrences=atoms.pattern_occurrences,
        case_patterns=atoms.case_patterns,
        max_case_pattern_occurrences=max((r['structural_pattern_occurrences'] for r in atoms.case_patterns.values()),default=0),
        identifiers=atoms.identifiers, constants=atoms.constants, attributes=atoms.attributes,
        term_attributes=atoms.term_attributes, identifier_attributes=atoms.identifier_attributes,
        goal_identifier_by_task=goal_ids, term_attribute_summary=attr_summary(atoms.term_attributes.values()),
        goal_identifier_attribute_summary=attr_summary(atoms.identifier_attributes[str(p)] for p in goal_ids.values()),
        proposition_identifier_pointers=sorted(proposition_ids),
        term_attribute_union=sorted(term_attr_union), proposition_identifier_attribute_union=sorted(proposition_attr_union),
        shape_attribute_union=dict(pointers=sorted(shape_attr_union),count=len(shape_attr_union),
            sum_bytes=sum(atoms.attributes[str(a)]['bytes'] for a in shape_attr_union)),
        saved_occurrence_certificate=cert, imported_shape_term_visits_per_task=shape_visits,
        imported_B_binders=cert['B_binders'], imported_APn_visits=len(cert['visits']),
        proposition_and_explanation_requests_per_save=J,
        original_name_bytes_min=min(name_sizes,default=0), original_name_bytes_max=max(name_sizes,default=0),
        numeric_summary=dict(component_occurrences=len(parts),
            representations=dict(collections.Counter(p['representation'] for p in parts)),
            minimum_value=str(min((int(p['value']) for p in parts),default=0)),
            maximum_value=str(max((int(p['value']) for p in parts),default=0)),
            decimal_bytes_min=min((p['decimal_bytes'] for p in parts),default=0),
            decimal_bytes_max=max((p['decimal_bytes'] for p in parts),default=0),
            bit_length_max=max((p['bit_length'] for p in parts),default=0),
            used_limbs_max=max((p.get('used_limbs',int(p['value']!='0')) for p in parts),default=0)),
        constant_kinds=dict(collections.Counter(c['kind'] for c in atoms.constants.values())),
        unsupported_numeric_components=atoms.unsupported, coverage_failures=failures,
        explanation_prefixes=dict(values=None, count=None, reason='actual mutable configuration not established by this extractor'),
        prior_atoms_reused=prior is not None,
        scope='typed atoms/attributes plus imported occurrence metadata for one retained logical forest; not whole ending capacity',
        native_executions=0, session_replays=0, binder_recomputations=0, alpha_replays=0,
        new_universal_graph_claim=False)
    if prior is not None and not failures:
        # Reuse the accepted numeric/term atom evidence, while adding the new
        # attribute and proposition-identifier projection needed by this task.
        assert sorted(atoms.terms) == prior['term_pointers']
        for pointer, old in prior['identifiers'].items():
            assert atoms.identifiers[pointer] == old
        for pointer, old in prior['constants'].items():
            assert old['kind'] == 'int'
            assert [int(p['value']) for p in atoms.constants[pointer]['parts']] == old['parts']
        result['accepted_prior_atom_identity'] = identity((OUTCOMES/'atom-certificate.json').read_bytes())
    result['elapsed_seconds'] = time.perf_counter()-start
    return result


def write_gzip(path, value):
    raw = (json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with path.open('wb') as out, gzip.GzipFile(filename='', fileobj=out, mode='wb',mtime=0) as stream:
        stream.write(raw)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--case',required=True,choices=['put_line','put','first_or_default','is_message','input_is_valid'])
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    value = project(args.case)
    write_gzip(args.output,value)
    print(json.dumps({k:value[k] for k in ('case','typed_graph_complete','numeric_components_complete',
        'constant_kinds','original_name_bytes_max','proposition_and_explanation_requests_per_save','elapsed_seconds')}
        | dict(terms=len(value['covered_term_pointers']),patterns=len(value['pattern_pointers']),
               unsupported_numeric_components=len(value['unsupported_numeric_components']),coverage_failures=value['coverage_failures'])))
