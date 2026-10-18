#!/usr/bin/env python3
"""Compose source-counted producer bounds; no native tools or membership test."""
import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent

# The existing whole-Main shape allowance, with scanner leaves removed.
# A region is one complete top-level declaration or statement; regions include
# every nested branch/loop. Only the shell and with-clause charge is shared.
SHAPE_COEFFICIENTS = dict(O=3,O_lower=1,dots=1,Image=1,Length=11,
    calls_with_actual=1,named_actuals=1,Reject=1,flatten=6,D=1,R=7,null=1,
    I_assign=1,S_assign=1,**{'if':1},elsif=1,F=51,B_loop=4,D_s=21,U=7,V0=1,O_loop=4)


def shape_bound(counts):
    c = Counter(counts)
    local = lambda row: sum(n*row.get(k,0) for k,n in SHAPE_COEFFICIENTS.items())
    shell = 7+c['context']
    total = shell+local(c)
    regions = c.get('shape_regions')
    if regions is None:
        return total,total
    # The research fixtures supply explicit source-region counters. A future
    # recognizer must compute this partition while traversing its own source.
    for key in SHAPE_COEFFICIENTS:
        assert sum(r.get(key,0) for r in regions) == c[key],key
    return shell+max(map(local,regions),default=0),total


def add(*vectors):
    return tuple(map(sum, zip(*vectors)))


def scale(n, vector):
    return tuple(n*x for x in vector)


def graph_counts(row):
    """Expand every retained theory root, preserving shared-node multiplicity."""
    nodes = {int(k): v for k, v in row['graph']['nodes'].items()}
    lists = {int(k): v for k, v in row['graph']['lists'].items()}
    kinds = {v: int(k) for k, v in row['layout']['kinds'].items()}
    edges = {}
    for i, node in nodes.items():
        children = []
        for name, _, _, tag, optional in row['layout']['child_fields'].get(str(kinds[node['kind']]), []):
            field = node['fields'][name]
            assert field['kind'] == tag
            value = field['value']
            if tag == 'list':
                children.extend(lists[value])
            elif value or not optional:
                children.append(value)
        edges[i] = children
    memo, active = {}, set()

    def visit(i):
        if i in memo:
            return memo[i]
        assert i not in active
        active.add(i)
        result = Counter({nodes[i]['kind'].split('__')[-1].upper(): 1})
        for child in edges[i]:
            result.update(visit(child))
        active.remove(i)
        memo[i] = result
        return result

    result = Counter()
    for i in row['theory_roots']:
        v = visit(i)
        assert sum(v.values()) == row['theory_occurrences'][str(i)]
        result.update(v)
    assert sum(result.values()) == row['all_theory_occurrences']
    modules = sum(n['kind'].endswith('__w_module') for n in nodes.values())
    return result, modules


def fixed_envelope():
    rows = {}
    with tarfile.open(EVIDENCE/'retained-producer-dependencies-20261018/graphs.tar.gz') as archive:
        for member in archive.getmembers():
            row = json.load(archive.extractfile(member))
            rows[member.name] = graph_counts(row)
    base, base_modules = rows['first_or_default/graph-after_standard.json']
    result, modules = base.copy(), base_modules
    for name in ('first_or_default', 'input_is_valid', 'put', 'put_line', 'reject'):
        before, bm = rows[name+'/graph-after_standard.json']
        after, am = rows[name+'/graph-before_free.json']
        assert before == base and bm == base_modules == 238
        assert all(after[k] >= v for k, v in before.items())
        result.update(after-before)
        modules += am-bm
    assert sum(result.values()) == 22621 and modules == 741
    return result, modules


def weights(schema, lengths, h=3, d=40):
    result = {}
    for kind, fields in schema.items():
        total = len(kind)+19
        for field in fields:
            typ, mod, name = field['type'], field['modifier'], field['name']
            if typ.startswith('W_'):
                primitive = {'Id_One': 0, 'Id_Lone': 4, 'Id_Some': 2, 'Id_Set': 4}[mod]
            elif typ.startswith('EW_'):
                primitive = 2
            elif typ == 'Symbol':
                family = ('module_file' if kind == 'W_MODULE' and name == 'File' else
                          'comments' if name == 'Comment' else
                          'labels' if name == 'Marker' else 'names')
                primitive = 2*lengths[family]+2
            elif typ in ('Symbol_Set', 'String_Sets.Set'):
                family = 'labels' if typ == 'Symbol_Set' else 'string_attributes'
                characters = (lengths['symbol_set_characters'] if typ == 'Symbol_Set'
                              else h*lengths[family])
                primitive = 2+2*characters+3*h
            else:
                primitive = {'Boolean': 5, 'Source_Ptr': 2*lengths['filenames']+16,
                             'Uint': d+2, 'Ureal': 2*d+25}[typ]
            total += 1+primitive
        result[kind] = total
    return result


def string_bounds(identifier, loops, main_nodes, path_bytes):
    # Same per-family formulas as retained-producer-strings/check.py:bounds.
    h = max(identifier+5, 18)
    q = h+26*loops+30
    main = dict(names=h+q+41, comments=2*max(q, 760)+2*path_bytes+248,
                labels=max(9+main_nodes*(2*h+8), path_bytes+78, h+5, 44),
                string_attributes=33, filenames=path_bytes,module_file=19)
    small_label = max(path_bytes+78,h+5,44)
    main['symbol_set_characters'] = max(3*small_label,
        9+main_nodes*(2*h+8)+path_bytes+78+44)
    fixed = dict(names=1702, comments=1690+2*path_bytes,
                 labels=1690+2*path_bytes, string_attributes=33, filenames=path_bytes,
                 symbol_set_characters=3*(1690+2*path_bytes),module_file=19)
    return {k: max(main[k], fixed[k]) for k in main}, fixed


def check_module_files():
    path = EVIDENCE/'retained-producer-strings-20261018/check.py'
    spec = importlib.util.spec_from_file_location('producer_string_inventory',path)
    strings = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(strings)
    counts, positional = Counter(), []
    source_path = EVIDENCE/'unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    source_digest = hashlib.sha256(source_path.read_bytes()).hexdigest()
    assert source_digest == 'f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952'
    with tarfile.open(source_path) as archive:
        files = {m.name: archive.extractfile(m).read().decode()
                 for m in archive.getmembers()
                 if m.isfile() and m.name.startswith('spark-source/src/')
                 and m.name.endswith(('.adb','.ads'))}
    assert len(files) == 279
    for name,source in files.items():
        for _,_,expression in strings.scan_calls(source,('New_Module',)):
            masked = strings.clean(expression)
            match = re.search(r'\bFile\s*=>',masked,re.I)
            if match:
                value = strings.actual(expression+')',masked+')',match.end())
                counts[' '.join(value.split())] += 1
            else:
                positional.append((name,' '.join(expression.split())))
    assert counts == dict(Gnatprove_Standard_File=57,Ada_Model_File=55,
                         No_Symbol=37,Int_File=1,Real_File=1,Ref_File=1,
                         **{'GNATCOLL.Symbols.No_Symbol':2})
    assert positional == [('spark-source/src/why/why-gen-names.adb','Ada_Node, File, S')]
    initializer = files['spark-source/src/why/why-atree-modules.adb']
    values = dict(re.findall(r'\b(\w+_File)\s*:=\s*NID\s*\("([^"]*)"\)',initializer))
    assert values == dict(Int_File='int',Real_File='real',Ref_File='ref',
                         Gnatprove_Standard_File='_gnatprove_standard',Ada_Model_File='ada__model')
    assert max(map(len,values.values())) == 19
    return dict(source_archive_sha256=source_digest,source_files=len(files),named_calls=dict(counts),
                positional_forwarders=len(positional),file_symbols=values,maximum=19)


def compose(c, schema, fixed_counts, fixed_modules, path_bytes=256):
    """Counters have exactly the source meanings in the linked derivations."""
    c = Counter(c)
    d, r, ds, f, s, a, p = (c[k] for k in ('D','R','D_s','F','S','concat','flatten'))
    g = 2*f
    kl = s+3*a+5*p
    entities = 1+d+r+2*ds+5*f+kl
    parse = (2*(c['W']+s+c['N']+c['N_colon'])+c['O']+c['O_lower']+c['dots']
             +c['Image']+c['Length']+c['calls_with_actual']+c['named_actuals']
             +c['Reject']+4*p+d+3*r+c['null']+c['I_assign']+c['S_assign']
             +c['if']+c['elsif']+7*f+7+c['context'])
    main_nodes = (parse+4*c['B_loop']+53*f+6*r+25*ds+d+2*s+6*a
                  +7*c['U']+10*c['Length']+c['V0']+2*c['O']+12*p
                  +4*c['O_loop']+c['C_lib']+c['W']+1)
    # Parent paths stay within one top-level source region and its shared shell.
    shape_nodes,shape_total = shape_bound(c)
    assert 0 <= shape_nodes <= shape_total <= main_nodes
    visits = 2*(c['X']+c['U']+3*p)+2*g
    assert 0 <= c['X_integer'] <= c['X']
    numeric_visits = 2*c['X_integer']+2*g
    literals = s+a+3*p+ds
    # D_lit=D_s and D_alias=0 dominates every declaration classification.
    object_part = add(scale(d+f+g, (33,9,6,33)), scale(f,(6,4,2,6)))
    type_part = add(scale(r,(137,53,48,305)), scale(ds,(209,82,78,348)),
                    scale(kl,(37,14,11,57)), scale(f,(97,39,33,205)))
    expr = add(scale(numeric_visits,(11,3,4,35)),
               scale(visits-numeric_visits,(110,54,80,943)),
               scale(literals,(23,13,10,75)),
               scale(c['H_chars'],(7,3,6,40)))
    skeleton = add(scale(d-ds+g,(13,3,9,55)), scale(ds,(55,24,36,188)),
                   scale(r+ds,(1,0,0,5)), scale(c['I_assign'],(6,0,0,8)),
                   scale(c['S_assign'],(148,61,86,1247)), scale(c['output'],(9,6,4,9)),
                   scale(c['Reject'],(4,6,4,13)), scale(c['if']+c['elsif'],(8,2,2,26)),
                   scale(2*c['if']+c['elsif'],(9,1,3,27)), scale(f,(69,23,43,267)),
                   scale(f*(d+4),(49,19,27,126)))
    list_part = (4*main_nodes+2,2*main_nodes+2,4*main_nodes+2,16*main_nodes+10)
    main = add(object_part,type_part,expr,skeleton,list_part,
               scale(ds+kl,(17,0,0,0)),(148,44,76,711))
    wrapper = (746,341,522,1039)
    caches = (83*entities+4,0,0,0)  # 56E+4 symbol allowance, 27E module misses.
    variable = add(main,wrapper,caches)
    preimport = add((15349,3310,4729,22621),variable)
    closes = 2*d+8*f+4*r+6*ds+2*kl+3*f+literals+2+4
    # Character predicates and list/location wrappers allocate no module.
    modules = fixed_modules+variable[0]-7*c['H_chars']-list_part[0]
    module_parts = dict(fixed=fixed_modules,wrapper=746,memoized=27*entities,
        string_objects=2*ds,string_completion=3*ds,string_cache=2*(ds+kl),
        array_attempts_and_miss=ds+kl+3,literal_definitions=literals,
        other_expressions=110*(visits-numeric_visits),string_declarations=55*ds,
        string_assignments=148*c['S_assign'],outputs=9*c['output'],rejects=4*c['Reject'],
        loop_frames=5*f*(ds+1))
    coarse_modules = modules
    modules = min(modules,sum(module_parts.values()))
    all_module_imports = closes*(2+2*modules)
    # Each theory's own module-set insertions are occurrence-charged. Only
    # Main's single VC close additionally walks the global module closure.
    structural_imports = 2*closes+variable[3]+modules
    imports = min(all_module_imports,structural_imports)
    totals = add(preimport,(imports,0,imports,2*imports))
    lengths, fixed_lengths = string_bounds(c['I'],f,shape_nodes,path_bytes)
    weight = weights(schema,lengths)
    fixed_weight = weights(schema,fixed_lengths)
    # Character expansion has only these kinds; it contains no labels/comments.
    char_kinds = ('W_CALL','W_IDENTIFIER','W_NAME','W_MODULE','W_TYPE',
                  'W_INTEGER_CONSTANT','W_CONNECTION')
    char_weight = max(weight[k] for k in char_kinds)
    character_occurrences = 40*c['H_chars']
    body_occurrences = variable[3]-character_occurrences
    fixed_bytes = sum(n*(fixed_weight[k]+1) for k,n in fixed_counts.items())
    body_bytes = body_occurrences*(max(weight.values())+1)
    char_bytes = character_occurrences*(char_weight+1)
    import_bytes = imports*(weight['W_INCLUDE_DECLARATION']+weight['W_MODULE']+2)
    json_bytes = 29+fixed_bytes+body_bytes+char_bytes+import_bytes
    why_calls = 6097+13*preimport[0]
    # Fixed light-frontend bound supplied by the separate source/cache record.
    all_nodes, all_entities = 12784+main_nodes, 12784+entities
    common_calls = 71831+all_entities+13*entities
    scoped_keys = 36*all_entities+7*common_calls+1
    undo = 204*(all_nodes+1)+2*preimport[0]+30*scoped_keys
    auxiliary = dict(A_total=all_nodes,E_total=all_entities,
                     common_calls=common_calls,why_calls=why_calls,
                     why_symbol_map=160*all_entities,undo_peak=undo,
                     registered_vcs=preimport[0],vc_entity_map=all_entities,
                     claim_domain=5*all_entities,subprocess_map=1)
    return dict(A_parse=parse,A_Main=main_nodes,A_shape=shape_nodes,A_shape_total=shape_total,
                E_Main=entities,V=visits,V_Integer=numeric_visits,K=literals,
                K_literal=kl,preimport=preimport,unpaid_closes=closes,modules=modules,
                coarse_modules=coarse_modules,module_parts=module_parts,
                imports=imports,all_module_imports=all_module_imports,
                structural_imports=structural_imports,totals=totals,string_lengths=lengths,
                json_bytes=json_bytes,json_parts=dict(fixed=fixed_bytes,body=body_bytes,
                    characters=char_bytes,imports=import_bytes),auxiliary=auxiliary,
                producer_core_fits=(totals[0]<=2**30-1 and totals[1]<=2**30
                    and totals[2]<=2**31-1 and totals[3]<=2**31-1
                    and why_calls<=1610612741
                    and max(v for k,v in lengths.items() if k!='symbol_set_characters')<=1073741822
                    and common_calls<=1610612741 and 160*all_entities<=1610612741
                    and all_nodes<=1610612741 and undo<=2**31-1
                    and json_bytes<=2147483646))


def lexical(source):
    tokens = re.findall(r'"(?:""|[^"])*"|[A-Za-z][A-Za-z_0-9]*|[0-9]+',source)
    words = [t for t in tokens if t[0].isalpha()]
    strings = [t for t in tokens if t[0]=='"']
    return dict(W=len(words),S=len(strings),N=sum(t[0].isdigit() for t in tokens),
                I=max(map(len,words)),literal_chars=sum(len(t[1:-1].replace('""','"')) for t in strings))


def examples():
    shell = 'with Silver_IO;\nprocedure Main is\npragma SPARK_Mode (On);\n%sbegin\n%send Main;\n'
    cases = [
        ('null','procedure Main is\npragma SPARK_Mode (On);\nbegin\nnull;\nend Main;\n',
         dict(null=1,shape_regions=[dict(null=1)])),
        ('concat',shell%('', 'Silver_IO.Put ("a" & "b");\n'),
         dict(context=1,dots=1,calls_with_actual=1,C_lib=1,output=1,concat=1,O=1,X=3,H_chars=4,
              shape_regions=[dict(dots=1,calls_with_actual=1,O=1)])),
        ('assignment',shell%('A : Integer range 0 .. 9 := 0;\n','A := 1;\n'),
         dict(context=1,D=1,R=1,I_assign=1,X=4,X_integer=4,
              shape_regions=[dict(D=1,R=1),dict(I_assign=1)])),
        ('loop',shell%('A : Integer range 0 .. 9 := 0;\n',
                      'for I in 1 .. 9 loop\nA := I;\nend loop;\n'),
         dict(context=1,D=1,R=1,F=1,I_assign=1,X=6,X_integer=6,B_loop=3,
              shape_regions=[dict(D=1,R=1),dict(F=1,I_assign=1,B_loop=3)])),
    ]
    for name,source,counts in cases:
        yield name,source,{**counts,**lexical(source)}


def library_processes(schema,path_bytes=256):
    frontend = {r['case']:r for r in json.loads((EVIDENCE/
        'retained-main-semantics-20261018/library-capture/summary.json').read_text())['cases']}
    intern = {r['case']:r for r in json.loads((EVIDENCE/
        'retained-producer-capacity-20261017/intern-counters/summary.json').read_text())['cases']}
    producer = {r['case']:r for r in json.loads((EVIDENCE/
        'retained-producer-bodies-20261018/summary.json').read_text())['cases']}
    graphs = {}
    with tarfile.open(EVIDENCE/'retained-producer-bodies-20261018/graphs.tar.gz') as archive:
        for entry in archive.getmembers():
            if entry.name.endswith('/graph-before_free.json'):
                graphs[entry.name.split('/')[0]] = json.load(archive.extractfile(entry))
    maximum = dict(silver_io=211,silver_arguments=225,silver_output_libc=229,silver_runtime=221)
    assert set(producer) == set(frontend) == set(graphs) == set(maximum)
    assert set(producer) <= set(intern)
    result = []
    for name in sorted(producer):
        a = frontend[name]['A_total']
        e = frontend[name]['E_total_bound']
        p = producer[name]
        g = graphs[name]
        count,modules = graph_counts(g)
        assert sum(count.values()) == p['final']['all_theory_occurrences']
        assert frontend[name]['backend_calls'] == p['false_backend_calls']
        files = p['false_backend_calls']
        pools = intern[name]['final']
        calls = {k:pools[k]['calls_to_find'] for k in ('why','entity')}
        assert pools['why']['maximum_symbol_length'] == maximum[name]
        lengths = dict(names=10*maximum[name]+12,comments=10*maximum[name]+2*path_bytes,
            labels=10*maximum[name]+2*path_bytes,string_attributes=33,filenames=path_bytes,
            symbol_set_characters=3*(10*maximum[name]+2*path_bytes),module_file=19)
        weight = weights(schema,lengths)
        file_bound = 29+sum(n*(weight[k]+1) for k,n in count.items())
        n,l,j = (p['final'][k] for k in ('nodes','lists','retained_elements'))
        x = 36*e+7*calls['entity']+1
        undo = 204*(a+1)+2*n+30*x
        emitted = files*sum(count.values())
        fits = (n<=2**30-1 and l<=2**30 and j<=2**31-1 and emitted<=2**31-1
                and max(calls.values())<=1610612741 and 160*e<=1610612741
                and a<=1610612741
                and max(v for k,v in lengths.items() if k!='symbol_set_characters')<=1073741822
                and undo<=2**31-1 and (files==0 or file_bound<=2147483646))
        assert fits
        result.append(dict(case=name,A_total=a,E_total=e,nodes=n,lists=l,elements=j,
            module_nodes=modules,files=files,lifetime_emitted_bound=emitted,
            per_file_json_bound=file_bound if files else 0,all_root_json_bound=file_bound,
            why_calls=calls['why'],common_calls=calls['entity'],why_symbol_map=160*e,
            undo_peak=undo,registered_vcs=n,vc_entity_map=e,claim_domain=5*e,
            subprocess_map=files,producer_core_fits=fits))
    return result


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    schema = json.loads((EVIDENCE/'retained-producer-storage-20261018/serialization.json').read_text())['schema']
    fixed_counts,fixed_modules = fixed_envelope()
    module_files = check_module_files()
    libraries = library_processes(schema)
    cases = []
    for name,source,counts in examples():
        cases.append(dict(name=name,source=source,counts=counts,
                          bound=compose(counts,schema,fixed_counts,fixed_modules)))
    sensitivity = []
    for size in (1,64,1024,4096,8192):
        source = ('with Silver_IO; procedure Main is pragma SPARK_Mode (On); '
                  'begin Silver_IO.Put ("'+'a'*size+'"); end Main;')
        counts = dict(context=1,dots=1,calls_with_actual=1,C_lib=1,output=1,X=1,
                      H_chars=size,shape_regions=[dict(dots=1,calls_with_actual=1)],
                      **lexical(source))
        for path_bytes in (64,256,1024):
            bound = compose(counts,schema,fixed_counts,fixed_modules,path_bytes)
            sensitivity.append(dict(literal_characters=size,source_bytes=len(source),
                path_bytes=path_bytes,json_bytes=bound['json_bytes'],
                producer_core_fits=bound['producer_core_fits']))
    loop_sensitivity = []
    for count in (1,2,3,4,8,12,16):
        source = ('with Silver_IO; procedure Main is pragma SPARK_Mode (On); '
                  'A : Integer range 0 .. 9 := 0; begin '
                  +'for I in 1 .. 9 loop A := I; end loop; '*count+'end Main;')
        x = 3+3*count
        counters = dict(context=1,D=1,R=1,F=count,I_assign=count,X=x,X_integer=x,
                        B_loop=3*count,shape_regions=[dict(D=1,R=1)]
                            +[dict(F=1,I_assign=1,B_loop=3) for _ in range(count)],
                        **lexical(source))
        bound = compose(counters,schema,fixed_counts,fixed_modules)
        loop_sensitivity.append(dict(loops=count,source_bytes=len(source),counts=counters,
            A_Main=bound['A_Main'],A_shape=bound['A_shape'],A_shape_total=bound['A_shape_total'],
            modules=bound['modules'],
            json_bytes=bound['json_bytes'],json_parts=bound['json_parts'],
            producer_core_fits=bound['producer_core_fits']))
    inputs = ('retained-producer-dependencies-20261018/graphs.tar.gz',
              'retained-producer-storage-20261018/serialization.json',
              'retained-producer-bodies-20261018/graphs.tar.gz',
              'retained-producer-bodies-20261018/summary.json',
              'retained-producer-capacity-20261017/intern-counters/summary.json',
              'retained-main-semantics-20261018/library-capture/summary.json')
    input_hashes = {name: hashlib.sha256((EVIDENCE/name).read_bytes()).hexdigest() for name in inputs}
    result = dict(input_sha256=input_hashes,
                  module_file_inventory=module_files,
                  fixed_library_processes=libraries,
                  fixed_modules=fixed_modules,fixed_kind_occurrences=dict(sorted(fixed_counts.items())),
                  path_bytes=256,cases=cases,sensitivity=sensitivity,
                  loop_sensitivity=loop_sensitivity,
                  scope='producer core only; source/config inequalities, not admission or native execution')
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    for case in cases:
        b=case['bound']
        print(case['name'],b['A_Main'],b['json_bytes'],b['producer_core_fits'])


if __name__ == '__main__':
    main()
