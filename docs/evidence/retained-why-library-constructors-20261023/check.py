"""Focused binding/arithmetic checks; not a semantic parser/clone proof."""
import json
import platform
import time
from compose import HERE, calculate, complete_lookup, lookup_vector, REMAINING, OWNERS, INT_MAX
from freeze import sources, inputs, restore_census
from family_shapes import project, uncomment


def main():
    start = time.monotonic()
    checks = 0

    def require(condition):
        nonlocal checks
        assert condition
        checks += 1

    require(json.loads((HERE / 'source-witnesses.json').read_text()) == sources())
    require(json.loads((HERE / 'inputs.json').read_text()) == inputs())
    census = restore_census()
    require(json.loads((HERE / 'restore-census.json').read_text()) == census)
    require(not census['private_helper_exports'])
    require(not any(census['mutable_record_fields'].values()))
    shapes = project()
    require(json.loads((HERE / 'family-shapes.json').read_text()) == shapes)
    require(shapes['maximum_declaration_lexical_units'] == 128)
    require(shapes['clone_ancestry_maximum'] == 10)
    require(len(shapes['declarations']) == 499)
    require(not shapes['explicit_program_declarations_in_cloned_targets'])
    require(uncomment('(* a (*) b (* c *) d *) x').strip() == 'x')
    adapters = [r for r in census['references'] if 'rs_of_ls' in r['text']]
    require([(r['member'], r['line']) for r in adapters] == [
        ('why3/src/mlw/expr.ml', 213), ('why3/src/mlw/expr.ml', 524),
        ('why3/src/mlw/expr.ml', 525), ('why3/src/mlw/expr.ml', 942),
        ('why3/src/mlw/expr.ml', 957)])
    result = calculate()
    require(json.loads((HERE / 'result.json').read_text()) == result)
    expected = [1140132452, 936760628, 491571640, 74637148, 54698812]
    require([r['decl_constructor_entries_upper'] for r in result['cases']] == expected)
    for row in result['cases']:
        require(row['native_operands']['decl_counter_fits'])
        require(row['native_operands']['tuple_for_loop_index_fits'])
        require(row['lookup_vector_complete'])
        require(row['complete_owners'] == list(OWNERS))
        require(not row['incomplete_owners'])
        require(row['decl_unique_requests_upper'] <= row['decl_constructor_entries_upper'])
        v = row['covered_sites_vector']
        require(v['Task.Hstask'] == v['Task.Stdecl.Hcpt'] == dict(increments=0, requests=0))
        require(v['Ident']['requests'] == 0)
        for invalid in [None, {}, {'Ident': dict(increments=0, requests=0)}]:
            try:
                complete_lookup(row['case'], invalid)
            except ValueError:
                checks += 1
            else:
                raise AssertionError('missing owner accepted')
        # API arithmetic test only: these synthetic zeros are not supplied
        # as evidence and never exported as a completed residual.
        synthetic = {o: dict(increments=0, requests=0) for o in REMAINING}
        require(complete_lookup(row['case'], synthetic) == v)
        full = lookup_vector(row['case'])
        require(complete_lookup(row['case'], row['remaining_sites_vector']) == full)
        require(set(full) == set(OWNERS))
        require(full['Ident']['requests'] == 0)
        require(all(d['increments'] < INT_MAX for d in full.values()))
        # The publication child count is a CALL-tree bound; no hit/loss
        # parameter and no independent escape budget is provided.
        a = row['nonnegative_tuple_arity_upper']
        j = row['whole_process_publication_memo_callbacks']['each_table_total']
        require(row['publication_lower_children'] == dict(ident=(10*a+10)*j, ty=(6*a+3)*j))
        require(full['Decl.Hsdecl'] == v['Decl.Hsdecl'])
    for e in [True, -1, 3, 1.5]:
        try:
            calculate(e)
        except ValueError:
            checks += 1
        else:
            raise AssertionError('invalid escape accepted')
    no_escape = calculate(0)
    for earlier, later in zip(no_escape['cases'], result['cases']):
        require(earlier['decl_constructor_entries_upper'] <= later['decl_constructor_entries_upper'])
        require(earlier['whole_process_publication_memo_callbacks']['signal'] == 0)
        require(all(earlier['lookup_vector'][o][f] <= later['lookup_vector'][o][f]
                    for o in OWNERS for f in ('increments', 'requests')))
    require(result['complete_lookup_vector'])
    require(result['lower_tuple_memo_replay_discharged'])
    require(not result['independent_review_accepted'])
    require(result['association_prefix_required'])
    require(not result['whole_process_headroom'])
    out = dict(passed=True, focused_checks=checks,
        elapsed_seconds=round(time.monotonic()-start, 6),
        native_platform=f'{platform.system()} {platform.machine()}',
        native_execution=False, predecessor_checkers_run=False,
        source_transfer_machine_checked=False)
    (HERE / 'check-result.json').write_text(json.dumps(out, indent=2, sort_keys=True) + '\n')
    print(json.dumps(out, sort_keys=True))


if __name__ == '__main__':
    main()
