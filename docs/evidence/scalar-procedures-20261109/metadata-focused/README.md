# Procedure metadata complete-unit verification

Native Linux x86-64 run `20261109T231338-41a791dd3773`, task #370, verifies the
entire `silver_procedure_bindings.adb` unit and its specification. All 62 checks
passed over the declared domains, including empty metadata and failed lookup
inputs. The exact implementation is commit `0d1dd00c34`.

`complete-unit.tar.gz` contains both source files, full reports and managed
events/native log. The command selects `-u silver_procedure_bindings.adb` with
all flow/proof reporting, warnings/checks as errors, level 2 and the pinned
CVC5/Z3/Alt-Ergo provers. It reserved all 22 available workers and used the
separate `explore/procedure-bindings` output. It is a successful focused helper
contract check, not the complete compiler audit.

The unit mirrors established function lookup/append contracts. It introduces
separate procedure and formal tables, modes Input/Output/Input_Output, and no
procedure result oracle or assumed output initialization. Parser admission,
call composition, source correspondence and final complete validation remain
separate requirements.
