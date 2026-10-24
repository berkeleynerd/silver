#!/usr/bin/env python3
"""Independent offline identity, lexical/source seams and C-to-T projection.

This is supporting evidence for a human source closure argument, not an
OCaml call-graph proof. No author checker/extractor or native service runs.
"""
from collections import Counter
import hashlib
import importlib.util
import inspect
import json
from pathlib import Path
import platform
import re
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT/'docs/evidence/retained-main-construction-demand-20261024/source-prefix'
AUTHOR = 'a75ca51a31e2b50357032b5d7fe0155eeda434b0'
GROUPS = Counter()


def check(ok, group):
    if not ok:
        raise AssertionError(group)
    GROUPS[group] += 1


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def read(name):
    return json.loads((PACKET/name).read_text())


def lexical_code(text):
    """Mask OCaml comments, strings and character literals; preserve offsets.

    Used only on these inspected sources; no raw-string or extension parser
    claim. Unlike the author inventory, character literals are also masked.
    """
    out = list(text)
    i = 0
    depth = 0
    quoted = False
    while i < len(text):
        start = i
        if depth:
            if text.startswith('(*', i):
                depth += 1
                i += 2
            elif text.startswith('*)', i):
                depth -= 1
                i += 2
            else:
                i += 1
        elif quoted:
            if text[i] == '\\':
                i += 2
            elif text[i] == '"':
                quoted = False
                i += 1
            else:
                i += 1
        elif text.startswith('(*', i):
            depth = 1
            i += 2
        elif text[i] == '"':
            quoted = True
            i += 1
        elif text[i] == "'" and (m := re.match(r"'(?:\\.|[^'\\\n])'", text[i:])):
            i += len(m[0])
        else:
            i += 1
            continue
        for j in range(start, min(i,len(text))):
            if text[j] != '\n':
                out[j] = ' '
    check(not depth and not quoted, 'independent lexical scan terminated')
    return ''.join(out)


def main():
    start = time.perf_counter()
    manifest = read('inputs.json')
    changed = git('diff','--name-only',manifest['base_commit'],AUTHOR).decode().splitlines()
    note = 'docs/research/retained-main-construction-demand.md'
    check(all(n == note or n.startswith(str(PACKET.relative_to(ROOT))+'/') for n in changed), 'exact author scope')
    inputs = []
    for p in sorted(PACKET.iterdir()):
        if p.is_file():
            rel = str(p.relative_to(ROOT))
            raw = p.read_bytes()
            check(raw == git('show',AUTHOR+':'+rel), 'exact author packet input')
            inputs.append({'path':rel,'sha256':sha(raw)})
    research = (ROOT/note).read_bytes()
    check(research == git('show',AUTHOR+':'+note), 'exact author research input')
    check(research.startswith(git('show',manifest['base_commit']+':'+note)), 'accepted research prefix retained')
    inputs.append({'path':note,'sha256':sha(research)})
    for row in [manifest['archive']]+manifest['providers']+manifest['immutable_earlier_packet']:
        raw = (ROOT/row['path']).read_bytes()
        check((len(raw),sha(raw)) == (row['bytes'],row['sha256']), 'provider and immutable packet identity')
    sources = {}
    supplemental = []
    with tarfile.open(ROOT/manifest['archive']['path']) as tf:
        for row in read('source-witnesses.json'):
            raw = tf.extractfile(row['path']).read()
            check((len(raw),sha(raw)) == (row['bytes'],row['sha256']), 'complete archived source identity')
            sources[row['path']] = raw.decode()
            lines = raw.splitlines(keepends=True)
            for span in row['spans']:
                selected = b''.join(lines[span['first']-1:span['last']])
                check(selected.decode() == span['text'] and sha(selected) == span['sha256'], 'exact source excerpt')
        for name,lo,hi in [('src/mlw/pmodule.ml',1646,1671),('src/util/debug.ml',44,51),
                           ('src/util/extmap.ml',163,179),('src/util/extmap.ml',509,517),
                           ('src/gnat/gnat_main.ml',316,335)]:
            raw = tf.extractfile(name).read()
            selected = b''.join(raw.splitlines(keepends=True)[lo-1:hi])
            supplemental.append({'archive':manifest['archive']['path'],'path':name,
                                 'complete_sha256':sha(raw),'first':lo,'last':hi,
                                 'sha256':sha(selected),'source':selected.decode()})
    core = {'plugins/gnat_json/gnat_ast.ml':2511,
            'plugins/gnat_json/gnat_ast_to_ptree.ml':1333,
            'plugins/gnat_json/ptree_constructors.ml':258}
    inventory = {}
    for path,last in core.items():
        code = lexical_code(''.join(sources[path].splitlines(keepends=True)[:last]))
        refs = {}
        pattern = r"\b[A-Z][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_']*)+|\b[A-Z][A-Za-z0-9_]*\.(?=\()"
        for m in re.finditer(pattern,code):
            refs.setdefault(m[0],[]).append(code.count('\n',0,m.start())+1)
        opens = [{'module':m[1],'line':code.count('\n',0,m.start())+1}
                 for m in re.finditer(r'\bopen\s+([A-Z][A-Za-z0-9_]*)',code)]
        inventory[path] = {'qualified_references':refs,'opens':opens}
        check(inventory[path] == read('reference-inventory.json')[path], 'independent namespace inventory agrees')
        check(not re.search(r'\b(?:id_register|hashcons|ty_app|ity_app|unique|Dynlink|Marshal|Obj|external)\b',code), 'no direct logical owner or dynamic-code escape in converter core')
    decoder = inventory['plugins/gnat_json/gnat_ast.ml']
    check(set(decoder['qualified_references']) == {'List.assoc','List.length','List.map','List.mem_assoc'} and not decoder['opens'], 'decoder external references are data helpers')
    converter = sources['plugins/gnat_json/gnat_ast_to_ptree.ml']
    constructors = sources['plugins/gnat_json/ptree_constructors.ml']
    convcode = lexical_code(converter)
    direct_modules = re.findall(r'\(module\s+([A-Z][A-Za-z0-9_]*)\)',convcode)
    check(direct_modules == ['T','E','T'], 'three concrete first-class module expressions are local E/T')
    check(converter.startswith('open Why3\nopen Ptree\nopen Gnat_ast\nopen Ptree_constructors\n'), 'Ptree constructors shadow Why3 namespace')
    check(re.findall(r'^module (\w+) =',constructors,re.M) == ['Ty','P','E','T','D'], 'all five selected syntax modules bound')
    check('mk_of_expr (module E_or_T: E_or_T with type t = t) node' in converter and
          'process_call (module E_or_T: E_or_T with type t = t) node r.name args' in converter,
          'recursive higher-order forwarding preserves chosen module')
    check('process_call (module T) v r.cmp_op [new_var_term;old]' in converter, 'direct loop-variant term callback included')
    check('let ident_compare a b = Stdlib.compare a.id_str b.id_str' in converter and
          'module Include_type_set = Set.Make (Include_Decl)' in converter, 'include comparator uses strings')
    check('let loc_counter = ref 0' in constructors and constructors.count('incr loc_counter') == 1 and
          'let result_ident = mk_ident [] "result"' in constructors, 'synthetic location initializer and sole increment site')
    check('let next_call_id =\n  let counter = ref 0 in\n  fun () -> incr counter; !counter' in converter and
          convcode.count('next_call_id') == 2, 'call-ID closure is not called by initialization')
    env = sources['src/core/env.ml']
    check('let fp env path fn ch = store lang env path (fp env path fn ch) in' in env and
          'regf = (fun inf fp -> register_format parent inf fp)' in env,
          'parser value completes before store and parent conversion')
    session = sources['src/session/session_itp.ml']
    reader = session[session.index('let read_file env ?format fn ='):session.index('let merge_file_gen',session.index('let read_file env ?format fn ='))]
    check(reader.index('Env.read_file') < reader.index('| theories, format ->') < reader.index('Ident.id_register'), 'Session identifier registration is after parser return')
    plugin = converter[converter.index('let read_channel env path filename c ='):]
    check(plugin.index('From_json.file_from_json') < plugin.index('let mlw_file = mlw_file') <
          plugin.index('let print_mlw_file ?mark () =') < plugin.index('match Typing.type_mlw_file') <
          plugin.index('print_mlw_file ();'), 'typing entry is before deferred printer calls')
    check('Pmodule.mlw_language gnat_json_format [gnat_json_file_ext] read_channel' in converter, 'selected parser registration is attached')
    check('let equal a1 a2 = a1.attr_string = a2.attr_string' in sources['src/core/ident.ml'] and
          'let create_attribute s = Hsattr.hashcons' in sources['src/core/ident.ml'], 'attribute owner is distinct string Hashcons')
    check('Loc.user_position r.filename r.line 0 r.line 0' in converter and
          'Loc.user_position "<dummy>" line 0 line 0' in constructors, 'selected location columns exclude warning hooks')
    check('Option.value ~default:(mk_ident [] "???") id' in converter and
          'ld_loc = get_pos (); ld_def = None' in converter, 'discarded and eager syntax attempts remain visible')
    # Import only the new pure projection API; no source or checker helper.
    spec = importlib.util.spec_from_file_location('review_prefix_projection',PACKET/'prefix.py')
    api = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(api)
    check(list(inspect.signature(api.typing_entry).parameters) == ['role','configuration'], 'API has no arbitrary numeric operand')
    cpath = ROOT/'docs/evidence/retained-main-entry-capacity-20261024/result.json'
    c = json.loads(cpath.read_text())
    check(cpath.read_bytes() == git('show',manifest['populated_C_author']+':'+str(cpath.relative_to(ROOT))), 'populated C result is exact accepted provider')
    expected = {
        'first_or_default':(19103990,31839984,23879988,106017567),
        'input_is_valid':(17268805,28781342,21586006,96707853),
        'is_message':(17071707,28452845,21339634,95715532),
        'put':(24848687,41414478,31060859,134867029),
        'put_line':(27104344,45173908,33880431,146200712),
    }
    check(set(c['entry_envelopes']) == set(expected), 'five-role input domain')
    exports = {role:api.typing_entry(role) for role in expected}
    check(exports == read('exports.json'), 'entire recorded export agrees with new projection')
    for role,out in exports.items():
        numbers = expected[role]
        incoming = c['entry_envelopes'][role]
        for index,(name,provider) in enumerate([('Ident','Ident'),('Hsty','Ty.Hsty'),('Hsity','Ity.Hsity')]):
            row = out['owners'][name]
            check(row['counter_upper_at_T'] == row['counter_upper_at_C'] == numbers[index] == incoming['owners'][provider]['counter_value_upper'], 'distinct populated owner bound preserved')
            check(row['actual_counter_equal_at_C_and_T'] and row['new_constructor_requests'] == row['new_counter_increments'] == 0 and not row['exact_actual_counter_known'], 'zero requests does not invent exact counter')
            if name != 'Ident':
                check(set(row['same_backing_geometry_upper_at_C_and_T'].values()) == {numbers[3]} and
                      row['weak_clearing_allowed'] and not row['live_contents_or_occupancy_claimed_unchanged'], 'populated geometry preserved independently of weak contents')
        check(out['actual_populated_three_owner_transport_to_T_established'] and not any(out[n] for n in
              ['complete_parser_converter_representation_closed','actual_selected_builder_entry_attachment_established',
               'complete_Main_source_candidate_multiplicities','complete_source_to_initial_vc_storage']), 'only bounded C-to-T result closed')
        aux = out['auxiliary_prefix_interfaces']
        check(aux['Ident.Hsattr']['new_external_hashcons_attempts_upper'] is None and
              aux['Loc.FileTags']['current_counter_upper_at_C'] is None and
              aux['Ptree_constructors.loc_counter']['new_increments_upper'] is None and
              aux['Gnat_ast_to_ptree.next_call_id']['new_increments_upper'] is None, 'auxiliary demands remain unresolved')
        check(aux['Ptree_constructors.loc_counter']['counter_at_C'] == 1 and
              aux['Gnat_ast_to_ptree.next_call_id']['counter_at_C'] == 0, 'source initial synthetic state is scoped to C')
        check(out['process_budget'] == {'escaping_save_exceptions':2,'save_entering_callbacks':2,'saves':3} and
              out['new_callback_or_save_allowance'] == 0, 'single global budget preserved')
    for bad in ('arbitrary_main',0,True,None,[],{}):
        try:
            api.typing_entry(bad)
        except ValueError:
            check(True,'invalid role rejected')
        else:
            raise AssertionError('invalid role accepted')
    for bad in ('r90_206','',None):
        try:
            api.typing_entry('put',bad)
        except ValueError:
            check(True,'unattached configuration rejected')
        else:
            raise AssertionError('unattached configuration accepted')
    try:
        api.typing_entry('put',counter_upper=0)
    except TypeError:
        check(True,'numeric state injection rejected')
    else:
        raise AssertionError('numeric state injection accepted')
    result = {'status':'passed','reviewed_author':AUTHOR,'assertions':sum(GROUPS.values()),
              'groups':dict(GROUPS),'elapsed_seconds':time.perf_counter()-start,
              'host':platform.platform(),'script_sha256':sha(Path(__file__).read_bytes()),
              'inputs':inputs,'independent_namespace_inventory':inventory,
              'source_files':len(sources),'source_excerpts':sum(len(x['spans']) for x in read('source-witnesses.json')),
              'supplemental_source':supplemental,'role_reference_numbers':expected,
              'source_argument_machine_proved':False,'whole_Main_capacity_closed':False,
              'author_predecessor_checkers_or_extractors_run':0,
              'native_target_capture_compiler_prover_Lean_disassembler_service_runs':0}
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('inputs','independent_namespace_inventory','supplemental_source')},indent=2))


if __name__ == '__main__':
    main()
