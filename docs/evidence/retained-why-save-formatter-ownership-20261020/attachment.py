"""Source-derived attachments, conditional on inherited external premises."""

EXTERNAL_PREMISES = (
    "selected_source_native_and_faithful_pending_behavior",
    "functioning_locale_numeric_and_allocation_services",
    "selected_gnu_numeric_conversion_contract",
)


def attach(premises=None):
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(EXTERNAL_PREMISES):
        raise ValueError("unknown external premise")
    if any(type(v) is not bool for v in premises.values()):
        raise ValueError("external premises must be explicit booleans")
    frame = premises.get(EXTERNAL_PREMISES[0]) is True
    scalar = frame and all(premises.get(p) is True for p in EXTERNAL_PREMISES[1:])
    return {
        "selected_source_private_ownership_argument_attached": True,
        "selected_source_locale_lifecycle_argument_attached": True,
        "fresh_default_and_private_frame_under_supplied_external_premises": True if frame else None,
        "normal_scalar_bytes_upper_under_supplied_external_premises": 20 if scalar else None,
        "formatter_input_bounds_attached": False,
        "failed_conversion_capacity_established": False,
        "complete_formatter_capacity_established": False,
        "complete_save_capacity_established": False,
        "whole_pipeline_capacity_established": False,
        "runtime_service_success_observed": False,
    }
