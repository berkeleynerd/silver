set pagination off
set confirm off
set language c
set print frame-arguments none
set print elements 0
set disable-randomization off
break silver_output_profile__read_condition_into
run
printf "FIRST_SP %lu\n", $sp
set $first_sp = $sp
ignore 1 9
continue
printf "ELEVENTH_SP %lu\n", $sp
printf "TEN_GROUP_DELTA %lu\n", $first_sp - $sp
backtrace 12
disable 1
continue
