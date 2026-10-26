# Actual Main proof-check sites

Derived from each retained complete `.spark`; locations refer to the adjacent retained original `src/main.adb`. Raw rule fields and exact messages are preserved. An info record in combined `unsafe` is not evidence that its later unsafe site was independently exposed. Static frontend errors have no `.spark` and are listed at the end.

| Input | Site | Raw rule | Severity | Exact message | Source line |
| --- | --- | --- | --- | --- | --- |
| [native/guards](native/guards/src/main.adb) | 10:30 | `VC_RANGE_CHECK` | info | range check proved | `if X = 5 then Exact := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 11:34 | `VC_RANGE_CHECK` | info | range check proved | `if X /= 0 then Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 12:30 | `VC_RANGE_CHECK` | info | range check proved | `if X < 9 then Below := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 13:31 | `VC_RANGE_CHECK` | info | range check proved | `if X <= 8 then Below := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 14:33 | `VC_RANGE_CHECK` | info | range check proved | `if X > 0 then Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 15:34 | `VC_RANGE_CHECK` | info | range check proved | `if X >= 1 then Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 16:30 | `VC_RANGE_CHECK` | info | range check proved | `if 5 = X then Exact := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 17:34 | `VC_RANGE_CHECK` | info | range check proved | `if 0 /= X then Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 18:30 | `VC_RANGE_CHECK` | info | range check proved | `if 9 > X then Below := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 19:31 | `VC_RANGE_CHECK` | info | range check proved | `if 8 >= X then Below := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 20:33 | `VC_RANGE_CHECK` | info | range check proved | `if 0 < X then Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 21:34 | `VC_RANGE_CHECK` | info | range check proved | `if 1 <= X then Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 22:44 | `VC_RANGE_CHECK` | info | range check proved | `if X = 0 then null; else Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 23:42 | `VC_RANGE_CHECK` | info | range check proved | `if X /= 5 then null; else Exact := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 24:44 | `VC_RANGE_CHECK` | info | range check proved | `if X < 1 then null; else Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 25:45 | `VC_RANGE_CHECK` | info | range check proved | `if X <= 0 then null; else Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 26:41 | `VC_RANGE_CHECK` | info | range check proved | `if X > 8 then null; else Below := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 27:42 | `VC_RANGE_CHECK` | info | range check proved | `if X >= 9 then null; else Below := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 28:44 | `VC_RANGE_CHECK` | info | range check proved | `if 0 = X then null; else Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 29:42 | `VC_RANGE_CHECK` | info | range check proved | `if 5 /= X then null; else Exact := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 30:44 | `VC_RANGE_CHECK` | info | range check proved | `if 1 > X then null; else Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 31:45 | `VC_RANGE_CHECK` | info | range check proved | `if 0 >= X then null; else Positive := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 32:41 | `VC_RANGE_CHECK` | info | range check proved | `if 8 < X then null; else Below := X; end if;` |
| [native/guards](native/guards/src/main.adb) | 33:42 | `VC_RANGE_CHECK` | info | range check proved | `if 9 <= X then null; else Below := X; end if;` |
| [native/flow](native/flow/src/main.adb) | 10:46 | `VC_RANGE_CHECK` | info | range check proved | `if Visits < 100 then Visits := (Visits + 1); end if;` |
| [native/flow](native/flow/src/main.adb) | 16:22 | `VC_RANGE_CHECK` | info | range check proved | `Small := (9 - X);` |
| [native/flow](native/flow/src/main.adb) | 22:19 | `VC_RANGE_CHECK` | info | range check proved | `Small := X;` |
| [native/flow](native/flow/src/main.adb) | 26:16 | `VC_RANGE_CHECK` | info | range check proved | `Small := X;` |
| [native/flow](native/flow/src/main.adb) | 31:22 | `VC_RANGE_CHECK` | info | range check proved | `Small := I;` |
| [native/flow](native/flow/src/main.adb) | 37:22 | `VC_RANGE_CHECK` | info | range check proved | `Small := X;` |
| [native/flow](native/flow/src/main.adb) | 42:16 | `VC_RANGE_CHECK` | info | range check proved | `Small := X;` |
| [native/edges](native/edges/src/main.adb) | 10:35 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if X > Min then Value := (X - 1); end if;` |
| [native/edges](native/edges/src/main.adb) | 11:35 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if Min < X then Value := (X - 1); end if;` |
| [native/edges](native/edges/src/main.adb) | 12:47 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if X <= Min then null; else Value := (X - 1); end if;` |
| [native/edges](native/edges/src/main.adb) | 13:35 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if X < Max then Value := (X + 1); end if;` |
| [native/edges](native/edges/src/main.adb) | 14:35 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if Max > X then Value := (X + 1); end if;` |
| [native/edges](native/edges/src/main.adb) | 15:47 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if X >= Max then null; else Value := (X + 1); end if;` |
| [native/edges](native/edges/src/main.adb) | 16:33 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if X > Min then Value := (-X); end if;` |
| [native/edges](native/edges/src/main.adb) | 22:50 | `VC_DIVISION_CHECK` | info | division check proved | `if D > 0 and then (9 / D) > 0 then Q := (9 / D); end if;` |
| [native/edges](native/edges/src/main.adb) | 22:28 | `VC_DIVISION_CHECK` | info | division check proved | `if D > 0 and then (9 / D) > 0 then Q := (9 / D); end if;` |
| [native/edges](native/edges/src/main.adb) | 23:27 | `VC_DIVISION_CHECK` | info | division check proved | `if D = 0 or else (9 / D) > 0 then null; end if;` |
| [native/edges](native/edges/src/main.adb) | 24:34 | `VC_DIVISION_CHECK` | info | division check proved | `if not (D = 0) and then (9 / D) > 0 then null; end if;` |
| [native/edges](native/edges/src/main.adb) | 25:43 | `VC_DIVISION_CHECK` | info | division check proved | `if D > 0 and then Integer'Image ((9 / D)) /= "" then null; end if;` |
| [native/conservative](native/conservative/src/main.adb) | 11:30 | `VC_DIVISION_CHECK` | info | division check proved | `if D /= 0 then Q := (9 / D); end if;` |
| [native/conservative](native/conservative/src/main.adb) | 21:36 | `VC_DIVISION_CHECK` | info | division check proved | `if I > Snapshot then Q := (9 / I); end if;` |
| [native/unsafe](native/unsafe/src/main.adb) | 11:18 | `VC_RANGE_CHECK` | high | range check might fail, cannot prove upper bound for (X + 1) | `X := (X + 1);` |
| [native/unsafe](native/unsafe/src/main.adb) | 17:15 | `VC_RANGE_CHECK` | medium | range check might fail, cannot prove upper bound for (X + 1) | `X := (X + 1);` |
| [native/unsafe](native/unsafe/src/main.adb) | 22:15 | `VC_RANGE_CHECK` | info | range check proved | `X := (X + 1);` |
| [native/unsafe](native/unsafe/src/main.adb) | 27:42 | `VC_RANGE_CHECK` | info | range check proved | `for Step in 1 .. 2 loop X := (X + 1); end loop;` |
| [native/unsafe](native/unsafe/src/main.adb) | 32:36 | `VC_OVERFLOW_CHECK` | info | overflow check proved | `if Wide < 0 then Negated := (-Wide); end if;` |
| [native/unsafe](native/unsafe/src/main.adb) | 37:12 | `VC_RANGE_CHECK` | info | range check proved | `X := Wide;` |
| [native/doors](native/doors/src/main.adb) | 10:31 | `VC_RANGE_CHECK` | info | range check proved | `Visits := (Visits + 1);` |
| [native/doors](native/doors/src/main.adb) | 9:19 | `VC_DIVISION_CHECK` | info | division check proved | `if (Door mod Pass) = 0 and then Visits < 100 then` |
| [native/doors](native/doors/src/main.adb) | 14:51 | `VC_RANGE_CHECK` | info | range check proved | `Silver_IO.Put_Line (Integer'Image (Door) & " is open");` |
| [native/doors](native/doors/src/main.adb) | 16:51 | `VC_RANGE_CHECK` | info | range check proved | `Silver_IO.Put_Line (Integer'Image (Door) & " is closed");` |
| [native/doors](native/doors/src/main.adb) | 13:18 | `VC_DIVISION_CHECK` | info | division check proved | `if (Visits mod 2) = 1 then` |
| [negative/stale_replacement](negative/stale_replacement/src/main.adb) | 9:18 | `VC_RANGE_CHECK` | high | range check might fail, cannot prove upper bound for (X + 1) | `X := (X + 1);` |
| [negative/branch_join](negative/branch_join/src/main.adb) | 8:15 | `VC_RANGE_CHECK` | high | range check might fail, cannot prove upper bound for (X + 1) | `X := (X + 1);` |
| [negative/omitted_else](negative/omitted_else/src/main.adb) | 8:15 | `VC_RANGE_CHECK` | high | range check might fail, cannot prove upper bound for (X + 1) | `X := (X + 1);` |
| [negative/loop_reentry](negative/loop_reentry/src/main.adb) | 8:42 | `VC_RANGE_CHECK` | high | range check might fail, cannot prove upper bound for (X + 1) | `for Step in 1 .. 2 loop X := (X + 1); end loop;` |
| [negative/minimum_negation](negative/minimum_negation/src/main.adb) | 8:36 | `VC_OVERFLOW_CHECK` | high | overflow check might fail, cannot prove upper bound for (-Wide) | `if Wide < 0 then Negated := (-Wide); end if;` |
| [negative/shadowed_mutable](negative/shadowed_mutable/src/main.adb) | 9:12 | `VC_RANGE_CHECK` | high | range check might fail, cannot prove upper bound for Wide | `X := Wide;` |

Both static error sites are in [native/static/src/main.adb](native/static/src/main.adb): `7:34` (`Max + 1`) and `8:30` (`-Min`), each `value not in range of type "Standard.Integer"` with `static expression fails Constraint_Check`. Full frontend output is retained in `native/static/proof.stdout`; no proof report was generated.
