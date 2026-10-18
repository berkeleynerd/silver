#!/usr/bin/env python3
"""Offline source identities and six fixed VC shape calculations; no tool runs."""
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


@dataclass(frozen=True)
class K:
    kind: str
    children: tuple = ()
    terms: tuple = ()

    def nodes(self):
        return 1 + sum(c.nodes() for c in self.children)

    def attached(self):
        return sum(self.terms) + sum(c.attached() for c in self.children)


def seq(a, b):
    return K('seq', (a, b))


def function(body, post):
    return seq(K('val', terms=(1,)), seq(body, K('stop', terms=(post,))))


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    source = {}
    for row in identity['archives']:
        path = PROJECT / row['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
        with tarfile.open(path) as archive:
            for entry in row['files']:
                data = archive.extractfile(entry['member']).read()
                assert hashlib.sha256(data).hexdigest() == entry['sha256']
                assert len(data) == entry['bytes']
                source[entry['name']] = data.decode()

    def has(name, fragment):
        assert ' '.join(fragment.split()) in ' '.join(source[name].split()), name

    has('typing', 'let ity = Ity.ity_tuple @@ List.map (fun (_,v) -> v.pv_ity) fl in')
    has('typing', 'Etuple wit')
    has('dexpr', 'let ld, v = mk_proxy_decl ~ghost:(ghost || gh) e in')
    has('ity', 'let post = create_post vs (t_equ (t_var vs) (t_tuple tl)) in')
    has('ity', 'let frg = if priv || (nfr && not mut) then false else')
    has('typeinv', 'if Mls.for_all chk css then V else C css')
    has('typeinv', 'let its_solid s = not s.its_fragile &&')
    has('expr', 'let term_of_post ~prop v h = try Some (pure_of_post prop v h) with Exit -> None')
    has('vc', '| None -> Kval ([v], List.fold_right sp_and rinv sp)')
    has('vc', 'Kseq(k v,0,Klet(vv, t_var v.pv_vs, t_true))')
    has('vc', 'let e = e_match wit [pattern,e] Mxs.empty in')
    has('vc', 'let k = Kseq (k, 0, add_qinv res q) in')
    has('pmodule', 'let e = try e_exec (c_app rs\' cty.cty_args [] cty.cty_result) with')
    has('term', 'if n = 1 || small e then')
    has('matcher', 'let mk_case = t_case_close and mk_let = t_let_close_simp in')
    has('set', 'val empty () : set ensures { result.to_fset = empty } ensures { cardinal result = 0 }')
    assert source['set'].count('initial = empty ();') == 2
    assert source['set'].count('visited = empty ();') == 2
    assert source['set'].count('val eq = Int.(=), axiom .') == 2
    assert source['set'].count('val eq = Str.(=), axiom .') == 1
    has('int', 'val (=) (x y : int) : bool ensures { result <-> x = y }')
    has('string', 'val (=) (x y: string) : bool ensures { result <-> x = y }')
    has('string', 'type char = abstract { contents: string; } invariant { length contents = 1 }')

    context_path = PROJECT / identity['context_result']['path']
    assert hashlib.sha256(context_path.read_bytes()).hexdigest() == identity['context_result']['sha256']
    context = json.loads(context_path.read_text())
    frontier = context['additional_library_vc_frontier']
    assert len(frontier['type_invariant_modules']) == 3
    assert [r['line'] for r in frontier['program_value_refinements']] == [607, 663, 781]
    assert all(context['source_clone_dependency_coefficients'][m] == 1
               for m in frontier['type_invariant_modules'])

    # Unit constructors and two-field tuple constructor; all calls are fully applied.
    unit = K('let', terms=(1, 1))
    trace = K('let', terms=(1, 1))
    empty = seq(unit, seq(K('val', terms=(10,)), trace))
    tuple_witness = seq(empty, seq(empty, K('let', terms=(3, 1))))
    assertion = seq(seq(K('cut', terms=(5,)), K('val', terms=(1,))), unit)
    match = seq(tuple_witness, K('SP', (K('case', (assertion,)),)))
    witness = function(match, 1)
    refinement = function(seq(K('let', terms=(6, 1)), trace), 7)
    assert [empty.nodes(), tuple_witness.nodes(), assertion.nodes(), match.nodes(), witness.nodes()] == [5, 13, 5, 21, 25]
    assert witness.attached() == 42
    assert refinement.nodes() == 7 and refinement.attached() == 17

    # Lexical templates retain every possible trace/unused-definition binding.
    witness_formula = 2*(1+1+10) + 2*(1+1) + (1+3) + (1+3+5)
    equality_definition = 1 + 3 + 1 + 1  # if (x=y) then True else False
    checked_post = 1 + (1+equality_definition+1) + 3
    trace_body = 1 + equality_definition + checked_post
    refinement_formula = 1 + (1 + equality_definition + trace_body)
    char_formula = 1 + (1 + (1+1) + 1)
    assert (witness_formula, refinement_formula, char_formula) == (41, 27, 5)
    result = {
        'native_or_proof_executions': 0,
        'per_construction': {
            'set_witness': {'copies': 2, 'kode_nodes': witness.nodes(), 'attached_terms': witness.attached(), 'formula_E0': witness_formula, 'direct_vcgen_program_variables': 7},
            'eq_refinement': {'copies': 3, 'kode_nodes': refinement.nodes(), 'attached_terms': refinement.attached(), 'formula_E0': refinement_formula, 'direct_vcgen_program_variables': 2},
            'char_existence': {'copies': 1, 'kode_nodes': 0, 'attached_terms': char_formula, 'formula_E0': char_formula, 'direct_vcgen_program_variables': 0},
        },
        'per_backend_process': {
            'kode_nodes': 2*witness.nodes()+3*refinement.nodes(),
            'kode_nodes_after_general_reflow_bound': 2*(3*witness.nodes()+2)+3*(3*refinement.nodes()+2),
            'attached_terms_including_char_formula': 2*witness.attached()+3*refinement.attached()+char_formula,
            'sum_formula_E0': 2*witness_formula+3*refinement_formula+char_formula,
            'direct_vcgen_program_variables': 2*7+3*2,
            'exception_counter_increments': 0,
            'type_invariant_pin_counter_increments': 0,
        },
        'scope': 'Retained kode/formula shapes and direct VCgen program-variable births only; not whole-context typing or all temporary logical identifier/hashcons events.'
    }
    assert result['per_backend_process'] == {
        'kode_nodes': 71, 'kode_nodes_after_general_reflow_bound': 223,
        'attached_terms_including_char_formula': 140, 'sum_formula_E0': 168,
        'direct_vcgen_program_variables': 20, 'exception_counter_increments': 0,
        'type_invariant_pin_counter_increments': 0,
    }
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result['per_backend_process']))


if __name__ == '__main__':
    main()
