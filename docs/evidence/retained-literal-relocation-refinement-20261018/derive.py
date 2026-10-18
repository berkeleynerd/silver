#!/usr/bin/env python3
"""Refine only the accepted fixed signed-relocation operand envelope."""
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32 = (1 << 31) - 1
K = 2019040


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def operand_domains(v, k=K):
    """Pure arithmetic; the inherited source argument supplies these domains."""
    require(type(v) is int and v >= 0 and type(k) is int and k >= 0,
            'natural endpoint and absolute addend bound')
    rows = dict(ordinary_PC_relative=v+k, mapped_merge_target=v,
                TLS_thread_endpoint_with_addend=v+15+k,
                TLS_dynamic_endpoint_with_addend=v+k,
                TLS_GD_to_IE_instruction_bias=v+13,
                optional_GOT_PC32_place_adjustment=v+k+1,
                synthetic_PLT_address_difference=v+16,
                EH_relative=v+k, Main_PC32_PLT32=v+4)
    return dict(rows=rows, common_signed32=max(rows.values()),
                simplified_common_signed32=v+max(k+15, 16),
                fits_signed32=max(rows.values()) <= I32)


class Context:
    def __init__(self):
        pins = json.loads((HERE/'inputs.json').read_bytes())
        for row in pins['files']:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {key:row[key] for key in ('bytes', 'sha256')}, row['path'])
        self.pins_verified = len(pins['files'])
        self.api = runpy.run_path(str(HERE.parent/'retained-literal-linker-20261018/compose.py'))
        self.base = self.api['Context']()
        self.census = json.loads((HERE.parent/'retained-linker-relocations-20261018/result.json').read_bytes())
        require(self.census['bounds']['original_addend_absolute'] == K,
                'retained fixed original addend bound')


def refine(base):
    """Join the new envelope to a complete, unchanged predecessor result.

    This internal arithmetic adapter cannot certify source provenance by itself;
    evaluate() supplies the source-derived predecessor result and checked context.
    """
    old = base['link']
    v = old['layout']['retained_endpoint']
    require(old['relocation_bounds']['common_signed32'] == 2*v+K+15 and
            old['checks']['fixed_signed_relocation_reach'] == (2*v+K+15 <= I32) and
            old['selected_output_link_representation_fits'] == all(old['checks'].values()),
            'exact predecessor signed-envelope interface')
    domains = operand_domains(v)
    checks = dict(old['checks'])
    checks['fixed_signed_relocation_reach'] = domains['fits_signed32']
    return dict(source_identity=base['source_identity'], counts=base['counts'],
                retained_endpoint=v, operand_domains=domains,
                predecessor_common_signed32=old['relocation_bounds']['common_signed32'],
                predecessor_failed_checks=old['failed_sufficient_checks'],
                checks=checks,
                failed_sufficient_checks=[key for key,value in checks.items() if not value],
                assembler_interface_fits=base['assembler_interface_fits'],
                assembler_storage_fits=base['assembler_storage_fits'],
                selected_literal_assembler_and_linker_representation_fits=(
                    base['assembler_storage_fits'] and all(checks.values())),
                unchanged_other_checks={key:value for key,value in checks.items()
                                        if key != 'fixed_signed_relocation_reach'},
                inherited_conditions_of_claim=base['conditions_of_claim'],
                open_joins=base['open_joins'],
                source_argument_required=True, independent_review_accepted=False,
                whole_literal_pipeline_capacity_established=False,
                production_admission_rule=False, aggregate_RAM_gate=False,
                physical_resource_guarantee=False, native_tool_executions=0)


def evaluate(raw, context, path_bytes=512, host_page_bytes=4096):
    base = context.api['evaluate'](raw, context.base,
                                 path_bytes=path_bytes, host_page_bytes=host_page_bytes)
    return refine(base)
