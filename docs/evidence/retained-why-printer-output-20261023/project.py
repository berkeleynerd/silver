"""New source/constant/driver census; no predecessor code is imported."""
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import tarfile
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
BASE = '8b651049e46c8800df92e9efed4832ddfcbad8ab'
HSATTR = '62f686fe7331c2faf74c3c9f66df93f2626f1fa0'
RAW_NAMES = '39afb9db41c4052a7b68c2663f2bcc72d72a27ac'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
inputs = {}


def identity(data):
    return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def frozen(path, revision=BASE):
    data = subprocess.check_output(['git','show',revision+':'+path],cwd=ROOT)
    inputs[revision+':'+path] = identity(data)
    return data


def read(path, revision=BASE):
    return json.loads(frozen(path,revision))


def quoted_tokens(source):
    # A direct scanner separates comments and quoted strings. Keeping the
    # quoted source representation is a byte upper bound for its decoding.
    i = depth = 0
    out = []
    while i < len(source):
        if source.startswith('(*)',i):
            i += 3
        elif source.startswith('(*',i):
            depth += 1; i += 2
        elif depth:
            if source.startswith('*)',i): depth -= 1; i += 2
            else: i += 1
        elif source[i] == '"':
            start = i; i += 1
            while i < len(source):
                if source[i] == '\\': i += 2
                elif source[i] == '"': i += 1; break
                else: i += 1
            else: raise ValueError('unclosed string')
            out.append(dict(line=source.count('\n',0,start)+1,text=source[start:i]))
        else: i += 1
    assert depth == 0
    return out


def sources():
    specs = {
      WHY:{
       'why3/src/printer/smtv2.ml':[(13,22),(235,358),(359,614),(615,715),(755,925),(942,1082)],
       'why3/src/core/printer.ml':[(130,228),(288,408),(411,429)],
       'why3/src/printer/cntexmp_printer.ml':[(81,138)],
       'why3/src/driver/driver.ml':[(391,404),(456,474)],
       'why3/src/driver/call_provers.ml':[(604,620)],
       'why3/src/util/constant.ml':[(45,80)],
       'why3/src/util/number.ml':[(165,196),(245,320),(375,399)],
       'why3/src/util/loc.ml':[(114,130)],
       'why3/src/util/pp.ml':[(15,120),(208,208)],
       'why3/src/transform/eliminate_literal.ml':[(23,124)],
       'why3/src/core/term.ml':[(588,590),(665,676),(1780,1807),(1830,1835)],
       'why3/src/transform/eliminate_algebraic.ml':[(334,354)],
       'why3/src/transform/split_goal.ml':[(417,431)],
      },
      OCAML:{
       '/stdlib/format.ml':[(215,319),(320,447),(448,535),(592,618),(665,717),(937,1007),(1010,1038),(1248,1256),(1268,1311),(1376,1404)],
       '/stdlib/buffer.ml':[(20,43),(64,135),(157,185),(225,226)],
       '/stdlib/camlinternalFormat.ml':[(1370,1376),(1515,1532)],
       '/stdlib/string.ml':[(116,124)],
       '/stdlib/bytes.ml':[(170,209)],
      }}
    out=[]
    for archive, files in specs.items():
        data=frozen(archive)
        with tarfile.open(fileobj=io.BytesIO(data),mode='r:gz') as arc:
            names=arc.getnames()
            for key,spans in files.items():
                name=key if key in names else next(n for n in names if n.endswith(key))
                raw=arc.extractfile(name).read(); lines=raw.decode().splitlines(keepends=True)
                for first,last in spans:
                    assert 1<=first<=last<=len(lines),(name,last,len(lines))
                    text=''.join(lines[first-1:last])
                    out.append(dict(archive=archive,archive_identity=identity(data),member=name,
                        member_identity=identity(raw),first_line=first,last_line=last,
                        excerpt=text,excerpt_identity=identity(text.encode())))
    return out


def main():
    start=time.perf_counter()
    witnesses=sources()
    for p in ['docs/reviews/review-printer-demand-20261023.md',
              'docs/reviews/review-printer-syntax-20261023.md',
              'docs/reviews/review-printer-name-tables-20261023.md',
              'docs/research/retained-why-printer-entry.md',
              'docs/research/retained-solver-request-bytes.md',
              'docs/research/retained-why-standard-initial-state.md',
              'docs/research/retained-why-save-formatter-core.md',
              'docs/research/retained-why-standard-formatter-core.md',
              'docs/research/retained-why-callback-demand.md']:
        frozen(p)
    for p in ['docs/research/retained-why-hsattr-demand.md',
              'docs/evidence/retained-why-hsattr-demand-20261023/origins.json',
              'docs/evidence/retained-why-hsattr-demand-20261023/result.json']:
        frozen(p,HSATTR)
    frozen('docs/research/retained-why-raw-name-length.md',RAW_NAMES)
    raw_names=read('docs/evidence/retained-why-raw-name-length-20261023/result.json',RAW_NAMES)
    raw_by_case={r['case']:r for r in raw_names['cases']}
    driver_root='docs/evidence/retained-solver-request-bytes-20261020/'
    manifest=read(driver_root+'driver-inputs.json')
    drivers={}
    for name,row in manifest.items():
        data=frozen(driver_root+'drivers/'+name)
        assert identity(data)==row['identity']
        tokens=quoted_tokens(data.decode())
        drivers[name]=dict(source_bytes=len(data),imports=row['imports'],quoted_tokens=tokens)
    def expanded(name,ancestors=()):
        assert name not in ancestors
        row=drivers[name]
        return row['source_bytes']+sum(expanded(n,ancestors+(name,)) for n in row['imports'])
    roots=('z3_gnatprove.drv','cvc5_gnatprove.drv','alt_ergo_gnatprove_smt2.drv')
    expanded_bytes={n:expanded(n) for n in roots}
    tokens=[t for d in drivers.values() for t in d['quoted_tokens']]
    max_token=max(len(t['text'].encode()) for t in tokens)
    parameter_counts=[len(re.findall(r'%(?:[a-z])?\d+',t['text'])) for t in tokens]
    digit_groups=[g for t in tokens for g in re.findall(r'%(?:[a-z])?(\d+)',t['text'])]
    assert max(parameter_counts)<=16
    assert max(t['text'].count('%') for t in tokens)<=16
    assert max(map(len,digit_groups))<=4
    assert max(map(int,digit_groups))<=64
    literal_tokens=[t for t in tokens if re.search(r'%\d*[bxodc]',t['text'])]
    assert len(literal_tokens)==6
    assert all(len(re.findall(r'%\d*[bxodc]',t['text']))==1 for t in literal_tokens)
    assert all(re.fullmatch(r'"#x%(?:64|32|16|8|4|2)x"',t['text']) for t in literal_tokens)
    names=read('docs/evidence/retained-why-printer-name-tables-20261023/result.json')
    cases=[]
    for row in names['cases']:
        case=row['case']
        graph=json.loads(gzip.decompress(frozen('docs/evidence/retained-why-preinline-prefix-20261020/'+case+'-graph.json.gz')))
        constants=[t['args'] for t in graph['terms'] if t['kind']=='const']
        assert all(len(c)==2 and type(c[1]) is int and 0<=c[0]<=4 for c in constants)
        assert all(group for b in graph['bindings'] for group in b['triggers'])
        inv=read('docs/evidence/retained-why-printer-entry-20261020/'+case+'-inventory.json')
        assert inv['float_types']==[]
        bounds=[n for t in inv['range_types'] for n in t['bounds']]
        magnitude=max([abs(c[1]) for c in constants]+[abs(n) for n in bounds]+[1])
        assert magnitude<=2**64
        metadata=read('docs/evidence/retained-why-parallel-symbol-exclusion-20261020/'+case+'-metadata.json')
        assert not any(e['origin']=='raw' and e['meta'] in ('syntax_logic','syntax_type','syntax_literal') for e in metadata['update_events'])
        cases.append(dict(case=case,dimensions=row['dimensions'],original_constant_records=len(constants),
                          original_and_range_integer_magnitude_upper=magnitude,
                          no_float_types=True,no_original_real_or_string_constants=True,
                          all_original_trigger_groups_nonempty=True,
                          raw_name_bytes=raw_by_case[case]['raw_name_L_at_printer_entry'],
                          raw_comment_name_bytes=max(raw_by_case[case]['raw_name_L_at_printer_entry'],
                                                     raw_by_case[case]['raw_proposition_name_L_pr']),
                          printed_name_bytes_provider=raw_by_case[case]['candidate_or_printed_unique_name_bytes_upper']))
    model=frozen('docs/evidence/retained-why-preinline-prefix-20261020/model.py').decode()
    assert 'q,=self.fields(p,1,0)' in model
    census=dict(base=BASE,hsattr_provider=HSATTR,raw_names_provider=RAW_NAMES,
        providers_independent_joint_review_pending_at_authoring=True,
        driver_expanded_source_bytes=expanded_bytes,
        maximum_quoted_source_token_bytes=max_token,maximum_parameter_slots=max(parameter_counts),
        maximum_parsed_parameter_bytes=max(map(len,digit_groups)),maximum_literal_width=64,
        driver_source_tokens=drivers,integer_literal_templates=literal_tokens,cases=cases,
        source_semantics_machine_checked=False,native_runs=0,predecessor_programs_run=0)
    for name,value in [('source-witnesses.json',witnesses),('inputs.json',inputs),('census.json',census)]:
        (HERE/name).write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')
    print(json.dumps(dict(cases=len(cases),source_witnesses=len(witnesses),inputs=len(inputs),
                         max_token=max_token,expanded=expanded_bytes,elapsed_seconds=time.perf_counter()-start)))


if __name__=='__main__': main()
