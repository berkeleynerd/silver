#!/usr/bin/env python3
"""Join selected literal Main Ada numeric demands; offline research only."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
PRIOR = REPO / 'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
FRONT = REPO / 'docs/evidence/retained-literal-native-frontend-20261018'
ORIGINAL = REPO / 'docs/evidence/retained-literal-original-main-storage-20261018'
I32 = 2**31 - 1
SPECS = {
    'Uints': (-699999999, 5000, 100, 8, -600000000),
    'Udigits': (0, 10000, 100, 4, I32),
    'Ureals': (-599999998, 200, 100, 16, -500000000),
    'Rep_Table': (1, 1000, 200, 32, I32),
}


def require(value, message):
    if not value:
        raise ValueError(message)


class Context:
    def __init__(self, ada_root, gcc_root):
        roots = dict(repository=REPO, ada=Path(ada_root), gcc=Path(gcc_root))
        self.identity = json.loads((HERE / 'inputs.json').read_bytes())
        for item in self.identity['files']:
            raw = (roots[item['root']] / item['path']).read_bytes()
            require(len(raw) == item['bytes'] and
                    hashlib.sha256(raw).hexdigest() == item['sha256'],
                    'changed input: ' + item['root'] + ':' + item['path'])
        self.front = runpy.run_path(str(FRONT / 'compose.py'))
        self.model = self.front['load_model'](roots['ada'])
        self.original = runpy.run_path(str(ORIGINAL / 'derive.py'))
        self.fixed = self.model['native_fixed_frontend'](0, 0)
        # Paths/names do not enter the numeric projection. No invocation with
        # zero-width paths is asserted or passed to an aggregate evaluator.
        self.float = json.loads((PRIOR / 'native-fixed-float-callbacks.json').read_bytes())['sufficient_callback_transfer']
        self.rep = self.model['fixed_native_inputs']['fixed_lifetime_table_growth']['repinfo__rep_table__last_valX']
        require(tuple(self.fixed[k] for k in ('Uint_entries', 'Uint_digits', 'Ureal_entries')) == (24324, 74958, 60), 'fixed numeric interface changed')
        require(self.rep == 504, 'fixed Rep_Table interface changed')


def backing(demands, context):
    """Reusable named-table projection; demands are lifetime upper allowances."""
    require(set(demands) == set(SPECS), 'incomplete numeric table projection')
    require(all(type(x) is int and x >= 0 for x in demands.values()), 'invalid table demand')
    return {name: context.model['native_table_backing_row'](demands[name], *spec)
            for name, spec in SPECS.items()}


def compose(raw, context):
    front = context.front['compose'](raw, context.model)
    selected = front['selected_source']
    require(front['local_representation_premises']['each_literal_length_fits_native_String_Length_and_Integer'], 'literal length outside selected Integer domain')
    lengths = selected['decoded_literal_lengths']
    distinct = int(selected['Put'] > 0) + int(selected['Put_Line'] > 0)
    main_gigi = context.original['evaluate'](lengths, N=selected['null_statements'], D=distinct)
    gigi = main_gigi['shared_demands']
    main = front['Main_constructor']['total']
    scanner = front['scanner_pools']
    f, fl = context.fixed, context.float
    rows = {
        'fixed_all_roots_lifetime_allowance': dict(Uints=f['Uint_entries'], Udigits=f['Uint_digits'], Ureals=f['Ureal_entries'], Rep_Table=context.rep),
        'selected_scanner': dict(Uints=scanner['Uint_entries'], Udigits=scanner['Uint_digits'], Ureals=0, Rep_Table=0),
        'Main_constructor': dict(Uints=main['uint'], Udigits=main['retained_digit_words'], Ureals=0, Rep_Table=0),
        'fixed_Standard_float_callbacks': dict(Uints=fl['Uint_appends'], Udigits=fl['Udigit_word_appends'], Ureals=fl['Ureal_appends'], Rep_Table=fl['Repinfo_nodes_from_float_conversion']),
        'original_Main_constant_size_callbacks': dict(Uints=gigi['Uint_entries'], Udigits=gigi['Udigits_words'], Ureals=0, Rep_Table=0),
    }
    c = selected['output_calls']
    require(main['uint'] == 7*c and main['retained_digit_words'] == 61*c, 'Main numeric specialization changed')
    require(gigi['Uint_entries'] == 2*c and gigi['Udigits_words'] == 10*c, 'original numeric interface changed')
    require('Rep_Table' in main_gigi['zero_demands'], 'original constant annotation interface changed')
    demands = {name: sum(row[name] for row in rows.values()) for name in SPECS}
    tables = backing(demands, context)
    local = context.model['native_local_numeric_and_concat_backing'](
        dict(fixed=f, scanner_pool_inputs=scanner, Main_constructor=front['Main_constructor']), [])
    # This packet, unlike the predecessor helper, joins its argument domain to
    # both selected callback transfers. Their vectors fit the retained bound.
    operand_digits = local['Uint_operand_digit_bound']
    checks = dict(
        numeric_tables=all(r['all_selected_checks_pass'] for r in tables.values()),
        selected_local_numeric_objects=local['all_selected_checks_pass'],
        float_callback_vector=fl['largest_local_numeric_vector_words'] <= local['maximum_UI_Vector_elements'],
        original_constant_callback_digits=5 <= operand_digits,
        Rep_Table_index_negation=demands['Rep_Table'] <= I32,
    )
    return dict(
        source=dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), output_calls=c, null_statements=selected['null_statements']),
        scope='selected frontend and original gigi Ada numeric table/backing projection',
        demand_rows=rows, demands=demands, tables=tables,
        local_numeric_predecessor=local,
        selected_callback_arguments_joined=True,
        UI_Ints=dict(static_bucket_array_bytes=1023*8, individual_wrapper_bytes=16,
                     original_Main_wrapper_calls=gigi['UI_Ints_wrapper_calls'],
                     fixed_float_wrapper_calls=fl['UI_Ints_cache_insertions'],
                     aggregate_heap_gate=False),
        checks=checks, all_selected_checks_pass=all(checks.values()),
        premises=['accepted fixed-root/freezing and all-miss source reduction',
                  'selected literal shell, native phase and indexed naming configuration',
                  'accepted source/installed-tool correspondence',
                  'selected cold String and original Main source paths'],
        complete_native_frontend=False, complete_original_gigi=False,
        complete_native_capacity=False, production_admission_changed=False,
        native_tool_executions=0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--gcc-root', type=Path, required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    context = Context(args.ada_root, args.gcc_root)
    result = compose(args.source.read_bytes(), context)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(demands=result['demands'], all_selected_checks_pass=result['all_selected_checks_pass'], complete_native_capacity=False)))
