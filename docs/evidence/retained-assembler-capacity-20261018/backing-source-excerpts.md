# Selected GAS shared-backing source excerpts

Literal LF numbering.

## gas/as.c:630–640

```text
630: 
631:   /* Make a local copy of the old argv.  */
632:   old_argc = *pargc;
633:   old_argv = *pargv;
634: 
635:   /* Initialize a new argv that contains no options.  */
636:   new_argv = notes_alloc (sizeof (char *) * (old_argc + 1));
637:   new_argv[0] = old_argv[0];
638:   new_argc = 1;
639:   new_argv[new_argc] = NULL;
640: 
```

## gas/as.c:1160–1176

```text
1160: 
1161:         case 'f':
1162:           flag_no_comments = 1;
1163:           break;
1164: 
1165:         case 'I':
1166:           {                     /* Include file directory.  */
1167:             char *temp = notes_strdup (optarg);
1168: 
1169:             add_include_dir (temp);
1170:             break;
1171:           }
1172: 
1173:         case 'o':
1174:           out_file_name = notes_strdup (optarg);
1175:           break;
1176: 
```

## gas/as.c:1325–1335

```text
1325: 
1326:   out_file_name = OBJ_DEFAULT_OUTPUT_FILE_NAME;
1327: 
1328:   hex_init ();
1329:   if (bfd_init () != BFD_INIT_MAGIC)
1330:     as_fatal (_("libbfd ABI mismatch"));
1331: 
1332:   obstack_begin (&notes, chunksize);
1333:   xatexit (free_notes);
1334: 
1335:   myname = **argvp;
```

## gas/subsegs.h:45–111

```text
45: struct frchain                  /* control building of a frag chain */
46: {                               /* FRCH = FRagment CHain control */
47:   struct frag *frch_root;       /* 1st struct frag in chain, or NULL */
48:   struct frag *frch_last;       /* last struct frag in chain, or NULL */
49:   struct frchain *frch_next;    /* next in chain of struct frchain-s */
50:   subsegT frch_subseg;          /* subsegment number of this chain */
51:   fixS *fix_root;               /* Root of fixups for this subsegment.  */
52:   fixS *fix_tail;               /* Last fixup for this subsegment.  */
53:   struct obstack frch_obstack;  /* for objects in this frag chain */
54:   fragS *frch_frag_now;         /* frag_now for this subsegment */
55:   struct frch_cfi_data *frch_cfi_data;
56:   struct frch_ginsn_data *frch_ginsn_data;
57: };
58: 
59: typedef struct frchain frchainS;
60: 
61: /* Frchain we are assembling into now.  That is, the current segment's
62:    frag chain, even if it contains no (complete) frags.  */
63: extern frchainS *frchain_now;
64: 
65: typedef struct segment_info_struct
66: {
67:   frchainS *frchainP;
68: 
69:   /* Fixups for this segment.  This is only valid after the frchains
70:      are run together.  */
71:   fixS *fix_root;
72:   fixS *fix_tail;
73: 
74:   /* NULL, or pointer to the gas symbol that is the section symbol for
75:      this section.  */
76:   symbolS *sym;
77: 
78:   /* Used by dwarf2dbg.c for this section's line table entries.  */
79:   void *dwarf2_line_seg;
80: 
81:   /* This field is set if this is a .bss section which does not really
82:      have any contents.  Once upon a time a .bss section did not have
83:      any frags, but that is no longer true.  This field prevent the
84:      SEC_HAS_CONTENTS flag from being set for the section even if
85:      there are frags.  */
86:   unsigned int bss : 1;
87: 
88:   /* Set whenever dwarf2_emit_insn is called, and used to disable
89:      .eh_frame and .debug_frame optimisation.  This is an anti-fuzzer
90:      measure.  */
91:   unsigned int insn_seen : 1;
92: 
93:   /* Used by the stabs code.  */
94:   unsigned int stab_seen : 1;
95: 
96:   union
97:   {
98:     /* Current size of section holding stabs strings.  */
99:     unsigned long stab_string_size;
100:     /* Initial frag for ELF.  */
101:     char *p;
102:   } stabu;
103: 
104: #ifdef NEED_LITERAL_POOL
105:   unsigned long literal_pool_size;
106: #endif
107: 
108: #ifdef TC_SEGMENT_INFO_TYPE
109:   TC_SEGMENT_INFO_TYPE tc_segment_info_data;
110: #endif
111: } segment_info_type;
```

## gas/subsegs.c:35–40

```text
35: void
36: subsegs_begin (void)
37: {
38:   obstack_begin (&frchains, chunksize);
39: #if __GNUC__ >= 2
40:   obstack_alignment_mask (&frchains) = __alignof__ (frchainS) - 1;
```

## gas/subsegs.c:70–97

```text
70: static void
71: alloc_seginfo (segT seg)
72: {
73:   segment_info_type *seginfo;
74: 
75:   seginfo = obstack_alloc (&notes, sizeof (*seginfo));
76:   memset (seginfo, 0, sizeof (*seginfo));
77:   bfd_set_section_userdata (seg, seginfo);
78: }
79: /*
80:  *                      subseg_change()
81:  *
82:  * Change the subsegment we are in, BUT DO NOT MAKE A NEW FRAG for the
83:  * subsegment. If we are already in the correct subsegment, change nothing.
84:  * This is used eg as a worker for subseg_set [which does make a new frag_now]
85:  * and for changing segments after we have read the source. We construct eg
86:  * fixSs even after the source file is read, so we do have to keep the
87:  * segment context correct.
88:  */
89: void
90: subseg_change (segT seg, int subseg)
91: {
92:   now_seg = seg;
93:   now_subseg = subseg;
94: 
95:   if (!seg_info (seg))
96:     alloc_seginfo (seg);
97: }
```

## gas/subsegs.c:131–145

```text
131:   if (frcP == NULL || frcP->frch_subseg != subseg)
132:     {
133:       /* This should be the only code that creates a frchainS.  */
134: 
135:       newP = obstack_alloc (&frchains, sizeof (frchainS));
136:       newP->frch_subseg = subseg;
137:       newP->fix_root = NULL;
138:       newP->fix_tail = NULL;
139:       obstack_begin (&newP->frch_obstack, chunksize);
140: #if __GNUC__ >= 2
141:       obstack_alignment_mask (&newP->frch_obstack) = __alignof__ (fragS) - 1;
142: #endif
143:       newP->frch_frag_now = frag_alloc (&newP->frch_obstack, 0);
144:       newP->frch_frag_now->fr_type = rs_fill;
145:       newP->frch_cfi_data = NULL;
```

## gas/dw2gencfi.h:77–94

```text
77: #if defined (TE_PE) || defined (TE_PEP)
78: #define SUPPORT_FRAME_LINKONCE 1
79: #else
80: #define SUPPORT_FRAME_LINKONCE 0
81: #endif
82: 
83: #ifdef tc_cfi_reloc_for_encoding
84: #define SUPPORT_COMPACT_EH 1
85: #else
86: #define SUPPORT_COMPACT_EH 0
87: #endif
88: 
89: #ifndef TARGET_MULTIPLE_EH_FRAME_SECTIONS
90: #define TARGET_MULTIPLE_EH_FRAME_SECTIONS 0
91: #endif
92: 
93: #define MULTIPLE_FRAME_SECTIONS (SUPPORT_FRAME_LINKONCE || SUPPORT_COMPACT_EH \
94:                                  || TARGET_MULTIPLE_EH_FRAME_SECTIONS)
```

## gas/dw2gencfi.h:115–235

```text
115: struct cfi_insn_data
116: {
117:   struct cfi_insn_data *next;
118: #if MULTIPLE_FRAME_SECTIONS
119:   segT cur_seg;
120: #endif
121: #ifndef NO_LISTING
122:   struct list_info_struct *listing_ctxt;
123: #endif
124:   int insn;
125:   union
126:   {
127:     struct
128:     {
129:       unsigned reg;
130:       offsetT offset;
131:     } ri;
132: 
133:     struct
134:     {
135:       unsigned reg1;
136:       unsigned reg2;
137:     } rr;
138: 
139:     unsigned r;
140:     offsetT i;
141: 
142:     struct
143:     {
144:       symbolS *lab1;
145:       symbolS *lab2;
146:     } ll;
147: 
148:     struct cfi_escape_data *esc;
149: 
150:     struct
151:     {
152:       unsigned reg, encoding;
153:       expressionS exp;
154:     } ea;
155: 
156:     const char *sym_name;
157:   } u;
158: };
159: 
160: /* An enumeration describing the Compact EH header format.  The least
161:    significant bit is used to distinguish the entries.
162: 
163:    Inline Compact:                      Function offset [0]
164:                                         Four chars of unwind data.
165:    Out-of-line Compact:                 Function offset [1]
166:                                         Compact unwind data offset [0]
167:    Legacy:                              Function offset [1]
168:                                         Unwind data offset [1]
169: 
170:    The header type is initialized to EH_COMPACT_UNKNOWN until the
171:    format is discovered by encountering a .fde_data entry.
172:    Failure to find a .fde_data entry will cause an EH_COMPACT_LEGACY
173:    header to be generated.  */
174: 
175: enum {
176:   EH_COMPACT_UNKNOWN,
177:   EH_COMPACT_LEGACY,
178:   EH_COMPACT_INLINE,
179:   EH_COMPACT_OUTLINE,
180:   EH_COMPACT_OUTLINE_DONE,
181:   /* Outline if .cfi_inline_lsda used, otherwise legacy FDE.  */
182:   EH_COMPACT_HAS_LSDA
183: };
184: 
185: /* Stack of old CFI data, for save/restore.  */
186: struct cfa_save_data
187: {
188:   struct cfa_save_data *next;
189:   offsetT cfa_offset;
190: };
191: 
192: /* Current open FDE entry.  */
193: struct frch_cfi_data
194: {
195:   struct fde_entry *cur_fde_data;
196:   symbolS *last_address;
197:   offsetT cur_cfa_offset;
198:   struct cfa_save_data *cfa_save_stack;
199: };
200: 
201: struct fde_entry
202: {
203:   struct fde_entry *next;
204: #if MULTIPLE_FRAME_SECTIONS
205:   segT cur_seg;
206: #endif
207:   symbolS *start_address;
208:   symbolS *end_address;
209:   struct cfi_insn_data *data;
210:   struct cfi_insn_data **last;
211: #ifndef NO_LISTING
212:   struct list_info_struct *listing_ctxt;
213:   struct list_info_struct *listing_end;
214: #endif
215:   unsigned char per_encoding;
216:   unsigned char lsda_encoding;
217:   int personality_id;
218:   expressionS personality;
219:   expressionS lsda;
220:   unsigned int return_column;
221:   unsigned int signal_frame;
222: #if MULTIPLE_FRAME_SECTIONS
223:   int handled;
224: #endif
225:   int eh_header_type;
226:   /* Compact unwinding opcodes, not including the PR byte or LSDA.  */
227:   int eh_data_size;
228:   bfd_byte *eh_data;
229:   /* For out of line tables and FDEs.  */
230:   symbolS *eh_loc;
231:   int sections;
232: #ifdef tc_fde_entry_extras
233:   tc_fde_entry_extras
234: #endif
235: };
```

## gas/dw2gencfi.c:366–400

```text
366: struct cie_entry
367: {
368:   struct cie_entry *next;
369: #if MULTIPLE_FRAME_SECTIONS
370:   segT cur_seg;
371: #endif
372:   symbolS *start_address;
373:   unsigned int return_column;
374:   unsigned int signal_frame;
375:   unsigned char fde_encoding;
376:   unsigned char per_encoding;
377:   unsigned char lsda_encoding;
378:   expressionS personality;
379: #ifdef tc_cie_entry_extras
380:   tc_cie_entry_extras
381: #endif
382:   struct cfi_insn_data *first, *last;
383: };
384: 
385: /* List of FDE entries.  */
386: 
387: struct fde_entry *all_fde_data;
388: static struct fde_entry **last_fde_data = &all_fde_data;
389: 
390: /* List of CIEs so that they could be reused.  */
391: static struct cie_entry *cie_root;
392: 
393: /* Construct a new FDE structure and add it to the end of the fde list.  */
394: 
395: static struct fde_entry *
396: alloc_fde_entry (void)
397: {
398:   struct fde_entry *fde = notes_calloc (1, sizeof (*fde));
399: 
400:   frchain_now->frch_cfi_data = notes_calloc (1, sizeof (struct frch_cfi_data));
```

## gas/dw2gencfi.c:430–434

```text
430: alloc_cfi_insn_data (void)
431: {
432:   struct cfi_insn_data *insn = notes_calloc (1, sizeof (*insn));
433:   struct fde_entry *cur_fde_data = frchain_now->frch_cfi_data->cur_fde_data;
434: 
```

## gas/dw2gencfi.c:2256–2275

```text
2256:       if (i == cie->last)
2257:         {
2258:           *pfirst = j;
2259:           return cie;
2260:         }
2261:     }
2262: 
2263:   cie = XNEW (struct cie_entry);
2264:   cie->next = cie_root;
2265:   cie_root = cie;
2266:   SET_CUR_SEG (cie, CUR_SEG (fde));
2267:   cie->return_column = fde->return_column;
2268:   cie->signal_frame = fde->signal_frame;
2269:   cie->per_encoding = fde->per_encoding;
2270:   cie->lsda_encoding = fde->lsda_encoding;
2271:   cie->personality = fde->personality;
2272:   cie->first = fde->data;
2273: #ifdef tc_cie_entry_init_extra
2274:   tc_cie_entry_init_extra (cie, fde);
2275: #endif
```

## gas/gen-sframe.h:59–153

```text
59: struct sframe_row_entry
60: {
61:   /* A linked list.  */
62:   struct sframe_row_entry *next;
63: 
64:   /* Start and end of the frame row entry.  */
65:   symbolS *pc_begin;
66:   symbolS *pc_end;
67: 
68:   /* A frame row entry is a merge candidate if new information can be updated
69:      on it.  */
70:   bool merge_candidate;
71: 
72:   /* Whether the return address is mangled with pauth code.  */
73:   bool mangled_ra_p;
74: 
75:   /* Whether RA is undefined.  */
76:   bool ra_undefined_p;
77: 
78:   /* Track CFA base (architectural) register ID.  */
79:   unsigned int cfa_base_reg;
80:   /* Offset from the CFA base register for recovering CFA.  */
81:   offsetT cfa_offset;
82:   /* Whether CFA recovery needs dereferencing.  This is tracked for
83:      SFRAME_FDE_TYPE_FLEX FDE type.  */
84:   bool cfa_deref_p;
85: 
86:   /* Track FP location.  Specify whether it is in register or memory.  */
87:   unsigned int fp_loc;
88:   unsigned int fp_reg;
89:   /* If the FP is stashed on stack, note the offset.  */
90:   offsetT fp_offset;
91:   /* Whether FP recovery needs dereferencing.  This is tracked for
92:      SFRAME_FDE_TYPE_FLEX FDE type.  */
93:   bool fp_deref_p;
94: 
95:   /* Track RA location.  Specify whether it is in register or memory.  */
96:   unsigned int ra_loc;
97:   unsigned int ra_reg;
98:   /* If RA is stashed on stack, note the offset.  */
99:   offsetT ra_offset;
100:   /* Whether RA recovery needs dereferencing.  This is tracked for FDE type
101:      SFRAME_FDE_TYPE_FLEX.  */
102:   bool ra_deref_p;
103: };
104: 
105: /* SFrame Function Description Entry.  */
106: 
107: struct sframe_func_entry
108: {
109:   /* A linked list.  */
110:   struct sframe_func_entry *next;
111: 
112:   /* Reference to the FDE created from CFI in dw2gencfi.  Some information
113:      like the start_address and the segment is made available via this
114:      member.  */
115:   const struct fde_entry *dw_fde;
116:   /* Whether the current FDE will use SFRAME_FDE_TYPE_FLEX representation.  */
117:   bool fde_flex_p;
118: 
119:   /* Reference to the first FRE for this function.  */
120:   struct sframe_row_entry *sframe_fres;
121: 
122:   unsigned int num_fres;
123: };
124: 
125: /* SFrame Function Description Entry Translation Context.  */
126: 
127: struct sframe_xlate_ctx
128: {
129:   /* Reference to the FDE created from CFI in dw2gencfi.  Information
130:      like the FDE start_address, end_address and the cfi insns are
131:      made available via this member.  */
132:   const struct fde_entry *dw_fde;
133: 
134:   /* List of FREs in the current FDE translation context, bounded by first_fre
135:      and last_fre.  */
136: 
137:   /* Keep track of the first FRE for the purpose of restoring state if
138:      necessary (for DW_CFA_restore).  */
139:   struct sframe_row_entry *first_fre;
140:   /* The last FRE in the list.  */
141:   struct sframe_row_entry *last_fre;
142: 
143:   /* The current FRE under construction.  */
144:   struct sframe_row_entry *cur_fre;
145:   /* Remember FRE for an eventual restore.  */
146:   struct sframe_row_entry *remember_fre;
147: 
148:   /* Whether the current FRE requires a more flexible frame encoding, hence
149:      needing SFRAME_FDE_TYPE_FLEX FDE type.  */
150:   bool flex_p;
151: 
152:   unsigned num_xlate_fres;
153: };
```

## gas/gen-sframe.c:591–627

```text
591: static struct sframe_row_entry*
592: sframe_row_entry_new (void)
593: {
594:   struct sframe_row_entry *fre = XCNEW (struct sframe_row_entry);
595:   /* Reset all regs to SFRAME_FRE_REG_INVALID.  A value of 0 may imply a
596:      valid register for a supported arch.  */
597:   fre->cfa_base_reg = SFRAME_FRE_REG_INVALID;
598:   fre->fp_reg = SFRAME_FRE_REG_INVALID;
599:   fre->ra_reg = SFRAME_FRE_REG_INVALID;
600:   fre->merge_candidate = true;
601:   /* Reset the mangled RA status bit to zero by default.  We will
602:      initialize it in sframe_row_entry_initialize () with the sticky
603:      bit if set.  */
604:   fre->mangled_ra_p = false;
605:   /* Reset the RA undefined status by to zero by default.  */
606:   fre->ra_undefined_p = false;
607: 
608:   return fre;
609: }
610: 
611: static void
612: sframe_row_entry_free (struct sframe_row_entry *fre)
613: {
614:   while (fre)
615:     {
616:       struct sframe_row_entry *fre_next = fre->next;
617:       XDELETE (fre);
618:       fre = fre_next;
619:     }
620: }
621: 
622: /* Allocate an SFrame FDE.  */
623: 
624: static struct sframe_func_entry*
625: sframe_fde_alloc (void)
626: {
627:   return XCNEW (struct sframe_func_entry);
```

## gas/gen-sframe.c:1070–1075

```text
1070: static struct sframe_xlate_ctx*
1071: sframe_xlate_ctx_alloc (void)
1072: {
1073:   struct sframe_xlate_ctx* xlate_ctx = XCNEW (struct sframe_xlate_ctx);
1074:   return xlate_ctx;
1075: }
```

## gas/symbols.c:245–303

```text
245: struct obstack notes;
246: 
247: /* Utility functions to allocate and duplicate memory on the notes
248:    obstack, each like the corresponding function without "notes_"
249:    prefix.  All of these exit on an allocation failure.  */
250: 
251: void *
252: notes_alloc (size_t size)
253: {
254:   return obstack_alloc (&notes, size);
255: }
256: 
257: void *
258: notes_calloc (size_t n, size_t size)
259: {
260:   size_t amt;
261:   void *ret;
262:   if (gas_mul_overflow (n, size, &amt))
263:     {
264:       obstack_alloc_failed_handler ();
265:       abort ();
266:     }
267:   ret = notes_alloc (amt);
268:   memset (ret, 0, amt);
269:   return ret;
270: }
271: 
272: void *
273: notes_memdup (const void *src, size_t copy_size, size_t alloc_size)
274: {
275:   void *ret = obstack_alloc (&notes, alloc_size);
276:   memcpy (ret, src, copy_size);
277:   if (alloc_size > copy_size)
278:     memset ((char *) ret + copy_size, 0, alloc_size - copy_size);
279:   return ret;
280: }
281: 
282: char *
283: notes_strdup (const char *str)
284: {
285:   size_t len = strlen (str) + 1;
286:   return notes_memdup (str, len, len);
287: }
288: 
289: char *
290: notes_concat (const char *first, ...)
291: {
292:   va_list args;
293:   const char *str;
294: 
295:   va_start (args, first);
296:   for (str = first; str; str = va_arg (args, const char *))
297:     {
298:       size_t size = strlen (str);
299:       obstack_grow (&notes, str, size);
300:     }
301:   va_end (args);
302:   obstack_1grow (&notes, 0);
303:   return obstack_finish (&notes);
```

## gas/read.c:252–260

```text
252: void
253: read_begin (void)
254: {
255:   const char *p;
256: 
257:   pobegin ();
258:   obj_read_begin_hook ();
259: 
260:   obstack_begin (&cond_obstack, chunksize);
```

## gas/read.c:6341–6371

```text
6341: char *
6342: demand_copy_string (int *lenP)
6343: {
6344:   unsigned int c;
6345:   int len;
6346:   char *retval;
6347: 
6348:   len = 0;
6349:   SKIP_WHITESPACE ();
6350:   if (*input_line_pointer == '\"')
6351:     {
6352:       input_line_pointer++;     /* Skip opening quote.  */
6353: 
6354:       while (is_a_char (c = next_char_of_string ()))
6355:         {
6356:           obstack_1grow (&notes, c);
6357:           len++;
6358:         }
6359:       /* JF this next line is so demand_copy_C_string will return a
6360:          null terminated string.  */
6361:       obstack_1grow (&notes, '\0');
6362:       retval = obstack_finish (&notes);
6363:     }
6364:   else
6365:     {
6366:       as_bad (_("missing string"));
6367:       retval = NULL;
6368:       ignore_rest_of_line ();
6369:     }
6370:   *lenP = len;
6371:   return retval;
```

## gas/config/obj-elf.c:203–215

```text
203: elf_file_symbol (const char *s)
204: {
205:   asymbol *bsym;
206:   symbolS *sym = symbol_new (s, absolute_section, &zero_address_frag, 0);
207:   size_t name_length = strlen (s);
208: 
209:   if (name_length > strlen (S_GET_NAME (sym)))
210:     {
211:       obstack_grow (&notes, s, name_length + 1);
212:       S_SET_NAME (sym, obstack_finish (&notes));
213:     }
214:   else
215:     strcpy ((char *) S_GET_NAME (sym), s);
```

## gas/config/obj-elf.c:503–516

```text
503: static asection *
504: group_section_find (const struct elf_section_match *match,
505:                     const char *sec_name,
506:                     unsigned int *group_idx)
507: {
508:   if (!groups.indexes)
509:     {
510:       groups.num_group = 0;
511:       groups.head = NULL;
512:       groups.indexes = htab_create_alloc (16, hash_string_tuple, eq_string_tuple,
513:                                           NULL, notes_calloc, NULL);
514:       *group_idx = ~0u;
515:       return NULL;
516:     }
```

## gas/config/obj-elf.c:575–639

```text
575: static void
576: change_section (const char *name,
577:                 unsigned int type,
578:                 bfd_vma attr,
579:                 int entsize,
580:                 struct elf_section_match *match_p,
581:                 bool linkonce,
582:                 bool push,
583:                 subsegT new_subsection)
584: {
585:   asection *old_sec;
586:   segT sec;
587:   flagword flags;
588:   const struct bfd_elf_special_section *ssect;
589: 
590:   if (match_p == NULL)
591:     {
592:       static struct elf_section_match unused_match;
593:       match_p = &unused_match;
594:     }
595: 
596: #ifdef md_flush_pending_output
597:   md_flush_pending_output ();
598: #endif
599: 
600:   /* Switch to the section, creating it if necessary.  */
601:   if (push)
602:     {
603:       struct section_stack *elt;
604:       elt = XNEW (struct section_stack);
605:       elt->next = section_stack;
606:       elt->seg = now_seg;
607:       elt->prev_seg = previous_section;
608:       elt->subseg = now_subseg;
609:       elt->prev_subseg = previous_subsection;
610:       section_stack = elt;
611:     }
612: 
613:   obj_elf_section_change_hook ();
614: 
615:   unsigned int group_idx = ~0u;
616:   if (match_p->group_name)
617:     old_sec = group_section_find (match_p, name, &group_idx);
618:   else
619:     old_sec = bfd_get_section_by_name_if (stdoutput, name, get_section_by_match,
620:                                           match_p);
621:   if (old_sec)
622:     {
623:       sec = old_sec;
624:       subseg_set (sec, new_subsection);
625:     }
626:   else
627:     {
628:       sec = subseg_force_new (name, new_subsection);
629:       if (match_p->group_name)
630:         group_section_insert (match_p, sec, &group_idx);
631:     }
632: 
633:   elf_backend_data *bed = get_elf_backend_data (stdoutput);
634:   ssect = (*bed->get_sec_type_attr) (stdoutput, sec);
635: 
636:   if (ssect != NULL)
637:     {
638:       bool override = false;
639: 
```

## gas/config/obj-elf.c:1071–1124

```text
1071: obj_elf_section_name (void)
1072: {
1073:   char *name;
1074: 
1075:   SKIP_WHITESPACE ();
1076:   if (*input_line_pointer == '"')
1077:     {
1078:       int dummy;
1079: 
1080:       name = demand_copy_C_string (&dummy);
1081:       if (name == NULL)
1082:         {
1083:           ignore_rest_of_line ();
1084:           return NULL;
1085:         }
1086:     }
1087:   else
1088:     {
1089:       char *end = input_line_pointer;
1090: 
1091:       while (!is_whitespace (*end) && !is_end_of_stmt (*end) && *end != ',')
1092:         end++;
1093:       if (end == input_line_pointer)
1094:         {
1095:           as_bad (_("missing name"));
1096:           ignore_rest_of_line ();
1097:           return NULL;
1098:         }
1099: 
1100:       obstack_grow0 (&notes, input_line_pointer, end - input_line_pointer);
1101:       name = obstack_base (&notes);
1102: 
1103:       while (flag_sectname_subst)
1104:         {
1105:           char *subst = strchr (name, '%');
1106:           if (subst && subst[1] == 'S')
1107:             {
1108:               size_t head = subst - name;
1109:               size_t tail = strlen (subst + 2) + 1;
1110:               size_t slen = strlen (now_seg->name);
1111: 
1112:               if (slen > 2)
1113:                 {
1114:                   obstack_blank (&notes, slen - 2);
1115:                   name = obstack_base (&notes);
1116:                 }
1117:               memmove (name + head + slen, name + head + 2, tail);
1118:               memcpy (name + head, now_seg->name, slen);
1119:             }
1120:           else
1121:             break;
1122:         }
1123: 
1124:       obstack_finish (&notes);
```

## gas/config/obj-elf.c:1415–1430

```text
1415:                        && (elf_section_flags (now_seg) & SHF_LINK_ORDER) != 0)
1416:                 goto fetch_linked_to;
1417:               else
1418:                 {
1419:                   char c;
1420:                   unsigned int length;
1421: 
1422:                   c = get_symbol_name (& beg);
1423:                   (void) restore_line_pointer (c);
1424:                   length = input_line_pointer - beg;
1425:                   if (length)
1426:                     match.linked_to_symbol_name
1427:                       = notes_memdup (beg, length, length + 1);
1428:                 }
1429:             }
1430:           else if ((attr & SHF_LINK_ORDER) != 0 && inherit
```

## gas/config/tc-i386.h:289–306

```text
289: struct i386_segment_info {
290:   /* Type of previous "instruction", e.g. .byte or stand-alone prefix.  */
291:   struct last_insn {
292:     const char *file;
293:     const char *name;
294:     unsigned int line;
295:     enum last_insn_kind
296:       {
297:         last_insn_other = 0,
298:         last_insn_directive,
299:         last_insn_prefix
300:       } kind;
301:   } last_insn;
302:   subsegT subseg;
303:   struct i386_segment_info *next;
304: };
305: 
306: #define TC_SEGMENT_INFO_TYPE struct i386_segment_info
```

## gas/config/tc-i386.c:18799–18829

```text
18799: void
18800: i386_elf_section_change_hook (void)
18801: {
18802:   struct i386_segment_info *info = &seg_info(now_seg)->tc_segment_info_data;
18803:   struct i386_segment_info *curr, *prev;
18804: 
18805:   if (info->subseg == now_subseg)
18806:     return;
18807: 
18808:   /* Find the (or make a) list entry to save state into.  */
18809:   for (prev = info; (curr = prev->next) != NULL; prev = curr)
18810:     if (curr->subseg == info->subseg)
18811:       break;
18812:   if (!curr)
18813:     {
18814:       curr = notes_alloc (sizeof (*curr));
18815:       curr->subseg = info->subseg;
18816:       curr->next = NULL;
18817:       prev->next = curr;
18818:     }
18819:   curr->last_insn = info->last_insn;
18820: 
18821:   /* Find the list entry to load state from.  */
18822:   for (curr = info->next; curr; curr = curr->next)
18823:     if (curr->subseg == now_subseg)
18824:       break;
18825:   if (curr)
18826:     info->last_insn = curr->last_insn;
18827:   else
18828:     memset (&info->last_insn, 0, sizeof (info->last_insn));
18829:   info->subseg = now_subseg;
```

## gas/output-file.c:56–95

```text
56: stash_frchain_obs (asection *sec)
57: {
58:   segment_info_type *info = seg_info (sec);
59:   if (info)
60:     {
61:       struct frchain *frchp;
62:       for (frchp = info->frchainP; frchp; frchp = frchp->frch_next)
63:         obstack_ptr_grow (&notes, &frchp->frch_obstack);
64:       info->frchainP = NULL;
65:     }
66: }
67: 
68: void
69: output_file_close (void)
70: {
71:   bool res;
72:   bfd *obfd = stdoutput;
73:   struct obstack **obs;
74:   asection *sec;
75:   const char *filename;
76: 
77:   if (obfd == NULL)
78:     return;
79: 
80:   /* Prevent an infinite loop - if the close failed we will call as_fatal
81:      which will call xexit() which may call this function again...  */
82:   stdoutput = NULL;
83: 
84:   /* We can't free obstacks attached to the output bfd sections before
85:      closing the output bfd since data in those obstacks may need to
86:      be accessed, but we can't access anything in the output bfd after
87:      it is closed..  */
88:   for (sec = obfd->sections; sec; sec = sec->next)
89:     stash_frchain_obs (sec);
90:   stash_frchain_obs (reg_section);
91:   stash_frchain_obs (expr_section);
92:   stash_frchain_obs (bfd_abs_section_ptr);
93:   stash_frchain_obs (bfd_und_section_ptr);
94:   obstack_ptr_grow (&notes, NULL);
95:   obs = obstack_finish (&notes);
```

## include/obstack.h:156–198

```text
156: struct _obstack_chunk           /* Lives at front of each chunk. */
157: {
158:   char *limit;                  /* 1 past end of this chunk */
159:   struct _obstack_chunk *prev;  /* address of prior chunk or NULL */
160:   char contents[4];             /* objects begin here */
161: };
162: 
163: struct obstack          /* control current object in current chunk */
164: {
165:   _CHUNK_SIZE_T chunk_size;     /* preferred size to allocate chunks in */
166:   struct _obstack_chunk *chunk; /* address of current struct obstack_chunk */
167:   char *object_base;            /* address of object we are building */
168:   char *next_free;              /* where to add next char to current object */
169:   char *chunk_limit;            /* address of char after current chunk */
170:   union
171:   {
172:     _OBSTACK_SIZE_T i;
173:     void *p;
174:   } temp;                       /* Temporary for some macros.  */
175:   _OBSTACK_SIZE_T alignment_mask;  /* Mask of alignment for each object. */
176: 
177:   /* These prototypes vary based on 'use_extra_arg'.  */
178:   union
179:   {
180:     void *(*plain) (size_t);
181:     void *(*extra) (void *, size_t);
182:   } chunkfun;
183:   union
184:   {
185:     void (*plain) (void *);
186:     void (*extra) (void *, void *);
187:   } freefun;
188: 
189:   void *extra_arg;              /* first arg for chunk alloc/dealloc funcs */
190:   unsigned use_extra_arg : 1;     /* chunk alloc/dealloc funcs take extra arg */
191:   unsigned maybe_empty_object : 1; /* There is a possibility that the current
192:                                       chunk contains a zero-length object.  This
193:                                       prevents freeing the chunk if we allocate
194:                                       a bigger chunk to replace it. */
195:   unsigned alloc_failed : 1;      /* No longer used, as we now call the failed
196:                                      handler on error, but retained for binary
197:                                      compatibility.  */
198: };
```

## include/obstack.h:314–358

```text
314:   __extension__                                                               \
315:     ({ struct obstack *__o = (OBSTACK);                                       \
316:        _OBSTACK_SIZE_T __len = (length);                                      \
317:        if (obstack_room (__o) < __len)                                        \
318:          _obstack_newchunk (__o, __len);                                      \
319:        memcpy (__o->next_free, where, __len);                                 \
320:        __o->next_free += __len;                                               \
321:        (void) 0; })
322: 
323: # define obstack_grow0(OBSTACK, where, length)                                \
324:   __extension__                                                               \
325:     ({ struct obstack *__o = (OBSTACK);                                       \
326:        _OBSTACK_SIZE_T __len = (length);                                      \
327:        if (obstack_room (__o) < __len + 1)                                    \
328:          _obstack_newchunk (__o, __len + 1);                                  \
329:        memcpy (__o->next_free, where, __len);                                 \
330:        __o->next_free += __len;                                               \
331:        *(__o->next_free)++ = 0;                                               \
332:        (void) 0; })
333: 
334: # define obstack_1grow(OBSTACK, datum)                                        \
335:   __extension__                                                               \
336:     ({ struct obstack *__o = (OBSTACK);                                       \
337:        if (obstack_room (__o) < 1)                                            \
338:          _obstack_newchunk (__o, 1);                                          \
339:        obstack_1grow_fast (__o, datum); })
340: 
341: /* These assume that the obstack alignment is good enough for pointers
342:    or ints, and that the data added so far to the current object
343:    shares that much alignment.  */
344: 
345: # define obstack_ptr_grow(OBSTACK, datum)                                     \
346:   __extension__                                                               \
347:     ({ struct obstack *__o = (OBSTACK);                                       \
348:        if (obstack_room (__o) < sizeof (void *))                              \
349:          _obstack_newchunk (__o, sizeof (void *));                            \
350:        obstack_ptr_grow_fast (__o, datum); })
351: 
352: # define obstack_int_grow(OBSTACK, datum)                                     \
353:   __extension__                                                               \
354:     ({ struct obstack *__o = (OBSTACK);                                       \
355:        if (obstack_room (__o) < sizeof (int))                                 \
356:          _obstack_newchunk (__o, sizeof (int));                               \
357:        obstack_int_grow_fast (__o, datum); })
358: 
```

## libiberty/obstack.c:114–150

```text
114: _obstack_begin_worker (struct obstack *h,
115:                        _OBSTACK_SIZE_T size, _OBSTACK_SIZE_T alignment)
116: {
117:   struct _obstack_chunk *chunk; /* points to new chunk */
118: 
119:   if (alignment == 0)
120:     alignment = DEFAULT_ALIGNMENT;
121:   if (size == 0)
122:     /* Default size is what GNU malloc can fit in a 4096-byte block.  */
123:     {
124:       /* 12 is sizeof (mhead) and 4 is EXTRA from GNU malloc.
125:          Use the values for range checking, because if range checking is off,
126:          the extra bytes won't be missed terribly, but if range checking is on
127:          and we used a larger request, a whole extra 4096 bytes would be
128:          allocated.
129: 
130:          These number are irrelevant to the new GNU malloc.  I suspect it is
131:          less sensitive to the size of the request.  */
132:       int extra = ((((12 + DEFAULT_ROUNDING - 1) & ~(DEFAULT_ROUNDING - 1))
133:                     + 4 + DEFAULT_ROUNDING - 1)
134:                    & ~(DEFAULT_ROUNDING - 1));
135:       size = 4096 - extra;
136:     }
137: 
138:   h->chunk_size = size;
139:   h->alignment_mask = alignment - 1;
140: 
141:   chunk = (struct _obstack_chunk *) call_chunkfun (h, h->chunk_size);
142:   if (!chunk)
143:     (*obstack_alloc_failed_handler) ();
144:   h->chunk = chunk;
145:   h->next_free = h->object_base = __PTR_ALIGN ((char *) chunk, chunk->contents,
146:                                                alignment - 1);
147:   h->chunk_limit = chunk->limit = (char *) chunk + h->chunk_size;
148:   chunk->prev = 0;
149:   /* The initial chunk now contains no empty object.  */
150:   h->maybe_empty_object = 0;
```

## libiberty/obstack.c:187–235

```text
187: void
188: _obstack_newchunk (struct obstack *h, _OBSTACK_SIZE_T length)
189: {
190:   struct _obstack_chunk *old_chunk = h->chunk;
191:   struct _obstack_chunk *new_chunk = 0;
192:   size_t obj_size = h->next_free - h->object_base;
193:   char *object_base;
194: 
195:   /* Compute size for new chunk.  */
196:   size_t sum1 = obj_size + length;
197:   size_t sum2 = sum1 + h->alignment_mask;
198:   size_t new_size = sum2 + (obj_size >> 3) + 100;
199:   if (new_size < sum2)
200:     new_size = sum2;
201:   if (new_size < h->chunk_size)
202:     new_size = h->chunk_size;
203: 
204:   /* Allocate and initialize the new chunk.  */
205:   if (obj_size <= sum1 && sum1 <= sum2)
206:     new_chunk = (struct _obstack_chunk *) call_chunkfun (h, new_size);
207:   if (!new_chunk)
208:     (*obstack_alloc_failed_handler)();
209:   h->chunk = new_chunk;
210:   new_chunk->prev = old_chunk;
211:   new_chunk->limit = h->chunk_limit = (char *) new_chunk + new_size;
212: 
213:   /* Compute an aligned object_base in the new chunk */
214:   object_base =
215:     __PTR_ALIGN ((char *) new_chunk, new_chunk->contents, h->alignment_mask);
216: 
217:   /* Move the existing object to the new chunk.  */
218:   memcpy (object_base, h->object_base, obj_size);
219: 
220:   /* If the object just copied was the only data in OLD_CHUNK,
221:      free that chunk and remove it from the chain.
222:      But not if that chunk might contain an empty object.  */
223:   if (!h->maybe_empty_object
224:       && (h->object_base
225:           == __PTR_ALIGN ((char *) old_chunk, old_chunk->contents,
226:                           h->alignment_mask)))
227:     {
228:       new_chunk->prev = old_chunk->prev;
229:       call_freefun (h, old_chunk);
230:     }
231: 
232:   h->object_base = object_base;
233:   h->next_free = h->object_base + obj_size;
234:   /* The new chunk certainly contains no empty object yet.  */
235:   h->maybe_empty_object = 0;
```
