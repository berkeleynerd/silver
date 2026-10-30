# Array declaration grouping repair

The ordinary `Array_Declaration_At` implementation writes
`Result : constant Parser_State := (declare ...);`. The expression renderer
previously reused the unparenthesized initializer appropriate to the old
expression-function extractor. The ordinary-function extractor retains the
outer parentheses, so the full source check correctly rejected the mismatch.

Repair `116ab344423a26faf1a8ddf656fa9bbea719f331`, integrated as `4538f7adc6`,
adds only the opening and closing tokens to `Body.render`. The first omission
was body token 5, immediately after `:=`; its closing partner was token 771.
`Checked`, evaluation, initializer, contracts, domains, reviewed pin and Ada
source are unchanged. The original review's exact-rendering conclusion missed
this grouping pair and has an explicit correction linked below.

On Linux, with one worker/thread and an 8 GiB threshold:

- Focused run `20261030T184845-99120085415c` passed in 33.403 s, including
  build 13.690 s and fresh audit 4.890 s of 11,182 declarations with the usual
  three foundations.
- Isolated kernel token check `20261030T184922-9ba9fdaacabb` passed in 8.609 s.
  Repaired rendering equals all 800 body tokens; unchanged `Checked` accepts
  the 818-token function. The two token theorems use only `propext`.
- Independent lexical inspection matches all 44,843 actual source tokens to
  the unchanged reviewed pin. The retained diagnostic and kernel probe give
  the exact source hash and token inputs. The probe's source is compressed here.

These focused checks do not replace the complete authoritative lexer/source
bridge. The selected repair subthread was GPT-6 Astra / Extra High; independent
runtime confirmation and separate token/cost measurements are unavailable.
The [independent combined repair review](../../../../reviews/review-boolean-proof-repairs-b6aeb9f978.md)
rechecked actual tokens and unchanged semantics without another proof run.
