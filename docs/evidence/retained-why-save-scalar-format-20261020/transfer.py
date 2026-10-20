"""Selected scalar conversion interface, not a complete Format capacity rule."""

PREMISES = (
    "selected_typed_scalar_formats_and_source_native_relation",
    "effective_c_numeric_locale_and_preserved_locale_object",
    "gnu_libc_numeric_conversion_contract",
    "successful_numeric_service_and_runtime_allocation",
)


def scalar_bounds(premises):
    for key, value in premises.items():
        if key not in PREMISES or type(value) is not bool:
            raise ValueError((key, value))
    joined = all(premises.get(key) is True for key in PREMISES)
    return {
        "conditional_integer_bytes_upper": 20,
        "conditional_float_bytes_upper": 13,
        "conditional_boolean_bytes_upper": 5,
        "conditional_scalar_bytes_upper": 20,
        "scalar_bytes_upper": 20 if joined else None,
        "normal_scalar_conversion_contract_joined": joined,
        "complete_formatter_capacity_established": False,
        "complete_save_capacity_established": False,
        "whole_pipeline_capacity_established": False,
    }
