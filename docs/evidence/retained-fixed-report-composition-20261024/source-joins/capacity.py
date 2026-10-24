"""Fixed-report source-copy and private-string attachment, #212/#119.

Pure mathematical bounds. The source argument and inherited configuration,
frontend/source/runtime relation are required; this is not an admission test.
"""
import importlib.util
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location(
    'fixed_source_report_algebra',
    ROOT / 'docs/evidence/retained-producer-report-capacity-20261024/capacity.py')
p = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = p
spec.loader.exec_module(p)

FRONTEND = dict(Silver_IO=19837, Silver_Arguments=19921,
                Silver_Output_Libc=18575, Silver_Runtime=1510)
PROOF_ROWS = dict(Silver_IO=40, Silver_Arguments=11,
                  Silver_Output_Libc=0, Silver_Runtime=0)


def backing(length):
    """Accepted selected runtime alignment/header overbound, per object."""
    p.natural(length)
    upper = length + length // 2 + 2 * 64 + 64
    return dict(payload=length, separate_backing_bytes=upper,
                alignment_arithmetic=upper <= p.I,
                unsigned_allocation=upper <= p.SIZE)


def fixed_strings(*, unit, fixed_source_span, path_bytes):
    p.natural(fixed_source_span, path_bytes)
    e = FRONTEND[unit]
    # Process-wide proof-variable universe, not the smaller per-graph roots.
    f = 2 * (e + 6) + 1
    image = p.expression_image(decoded_name=128, string_characters=128,
        attribute_name=6, source_span=fixed_source_span, uint_image_bytes=550)
    # Raw/generated 128 plus at most26 for selected Pretty_Source_Name;
    # 160 retains six bytes of slack. Magic pretty-printing does not grow760.
    fix = p.failed_fix_strings(entities=e, flow_ids=f,
        expression_image=image['bytes'], name_image=160,
        flow_name=760, path_bytes=path_bytes)
    # Handle_Result omits Explanation, whose formal default is empty.
    # The accepted static-result caller partition excludes alternate suppliers.
    payload = max(image['bytes'], fix['fix'], fix['explanation'],
                  fixed_source_span, 160, 760)
    store = backing(payload)
    return dict(unit=unit, frontend_entities=e, proof_variable_ids=f,
        proof_rows=PROOF_ROWS[unit], expression=image, private_strings=fix,
        maximum_private_payload=payload, string_backing=store,
        private_backing_holder_upper=16,
        guards=dict(image=all(image['guards'].values()),
            plain_string_and_loop_spare=payload + 2 <= p.I,
            unbounded_alignment=store['alignment_arithmetic'],
            native_allocation=store['unsigned_allocation'],
            name_buffer=128 + 1 <= 32767,
            private_reference_count=16 < p.U),
        source_copy_length_attached=True,
        private_string_lengths_and_backing_attached=True,
        source_coordinate_provider_required=True,
        private_working_sets_and_traversal_storage_closed=False,
        native_warning_chain_and_header_lifetimes_closed=False,
        complete_fixed_report_capacity=False)
