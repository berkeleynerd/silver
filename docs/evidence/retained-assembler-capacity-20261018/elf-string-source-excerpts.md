# Selected ELF string-table allocator source excerpts

Literal LF numbering.

## gas/as.c:1184–1188

```text
1184:         case OPTION_REDUCE_MEMORY_OVERHEADS:
1185:           break;
1186:
1187:         case OPTION_HASH_TABLE_SIZE:
1188:           break;
```

## bfd/bfd-in2.h:337–374

```text
337: struct bfd_hash_entry
338: {
339:   /* Next entry for this hash code.  */
340:   struct bfd_hash_entry *next;
341:   /* String being hashed.  */
342:   const char *string;
343:   /* Hash code.  This is the full hash code, not the index into the
344:      table.  */
345:   unsigned long hash;
346: };
347:
348: /* A hash table.  */
349:
350: struct bfd_hash_table
351: {
352:   /* The hash array.  */
353:   struct bfd_hash_entry **table;
354:   /* A function used to create new elements in the hash table.  The
355:      first entry is itself a pointer to an element.  When this
356:      function is first invoked, this pointer will be NULL.  However,
357:      having the pointer permits a hierarchy of method functions to be
358:      built each of which calls the function in the superclass.  Thus
359:      each function should be written to allocate a new block of memory
360:      only if the argument is NULL.  */
361:   struct bfd_hash_entry *(*newfunc)
362:     (struct bfd_hash_entry *, struct bfd_hash_table *, const char *);
363:   /* An objalloc for this hash table.  This is a struct objalloc *,
364:      but we use void * to avoid requiring the inclusion of objalloc.h.  */
365:   void *memory;
366:   /* The number of slots in the hash table.  */
367:   unsigned int size;
368:   /* The number of entries in the hash table.  */
369:   unsigned int count;
370:   /* The size of elements.  */
371:   unsigned int entsize;
372:   /* If non-zero, don't grow the hash table.  */
373:   unsigned int frozen:1;
374: };
```

## bfd/elf-strtab.c:29–126

```text
29: /* An entry in the strtab hash table.  */
30:
31: struct elf_strtab_hash_entry
32: {
33:   struct bfd_hash_entry root;
34:   /* Length of this entry.  This includes the zero terminator.  */
35:   int len;
36:   unsigned int refcount;
37:   union {
38:     /* Index within the merged section.  */
39:     bfd_size_type index;
40:     /* Entry this is a suffix of (if len < 0).  */
41:     struct elf_strtab_hash_entry *suffix;
42:   } u;
43: };
44:
45: /* The strtab hash table.  */
46:
47: struct elf_strtab_hash
48: {
49:   struct bfd_hash_table table;
50:   /* Next available index.  */
51:   size_t size;
52:   /* Number of array entries alloced.  */
53:   size_t alloced;
54:   /* Final strtab size.  */
55:   bfd_size_type sec_size;
56:   /* Array of pointers to strtab entries.  */
57:   struct elf_strtab_hash_entry **array;
58: };
59:
60: /* Routine to create an entry in a section merge hashtab.  */
61:
62: static struct bfd_hash_entry *
63: elf_strtab_hash_newfunc (struct bfd_hash_entry *entry,
64:                          struct bfd_hash_table *table,
65:                          const char *string)
66: {
67:   /* Allocate the structure if it has not already been allocated by a
68:      subclass.  */
69:   if (entry == NULL)
70:     entry = (struct bfd_hash_entry *)
71:         bfd_hash_allocate (table, sizeof (struct elf_strtab_hash_entry));
72:   if (entry == NULL)
73:     return NULL;
74:
75:   /* Call the allocation method of the superclass.  */
76:   entry = bfd_hash_newfunc (entry, table, string);
77:
78:   if (entry)
79:     {
80:       /* Initialize the local fields.  */
81:       struct elf_strtab_hash_entry *ret;
82:
83:       ret = (struct elf_strtab_hash_entry *) entry;
84:       ret->u.index = -1;
85:       ret->refcount = 0;
86:       ret->len = 0;
87:     }
88:
89:   return entry;
90: }
91:
92: /* Create a new hash table.  */
93:
94: struct elf_strtab_hash *
95: _bfd_elf_strtab_init (void)
96: {
97:   struct elf_strtab_hash *table;
98:   size_t amt = sizeof (struct elf_strtab_hash);
99:
100:   table = (struct elf_strtab_hash *) bfd_malloc (amt);
101:   if (table == NULL)
102:     return NULL;
103:
104:   if (!bfd_hash_table_init (&table->table, elf_strtab_hash_newfunc,
105:                             sizeof (struct elf_strtab_hash_entry)))
106:     {
107:       free (table);
108:       return NULL;
109:     }
110:
111:   table->sec_size = 0;
112:   table->size = 1;
113:   table->alloced = 64;
114:   amt = sizeof (struct elf_strtab_hasn_entry *);
115:   table->array = ((struct elf_strtab_hash_entry **)
116:                   bfd_malloc (table->alloced * amt));
117:   if (table->array == NULL)
118:     {
119:       bfd_hash_table_free (&table->table);
120:       free (table);
121:       return NULL;
122:     }
123:
124:   table->array[0] = NULL;
125:
126:   return table;
```

## bfd/elf-strtab.c:143–180

```text
143: _bfd_elf_strtab_add (struct elf_strtab_hash *tab,
144:                      const char *str,
145:                      bool copy)
146: {
147:   register struct elf_strtab_hash_entry *entry;
148:
149:   /* We handle this specially, since we don't want to do refcounting
150:      on it.  */
151:   if (*str == '\0')
152:     return 0;
153:
154:   BFD_ASSERT (tab->sec_size == 0);
155:   entry = (struct elf_strtab_hash_entry *)
156:           bfd_hash_lookup (&tab->table, str, true, copy);
157:
158:   if (entry == NULL)
159:     return (size_t) -1;
160:
161:   entry->refcount++;
162:   if (entry->len == 0)
163:     {
164:       entry->len = strlen (str) + 1;
165:       /* 2G strings lose.  */
166:       BFD_ASSERT (entry->len > 0);
167:       if (tab->size == tab->alloced)
168:         {
169:           bfd_size_type amt = sizeof (struct elf_strtab_hash_entry *);
170:           tab->alloced *= 2;
171:           tab->array = (struct elf_strtab_hash_entry **)
172:               bfd_realloc_or_free (tab->array, tab->alloced * amt);
173:           if (tab->array == NULL)
174:             return (size_t) -1;
175:         }
176:
177:       entry->u.index = tab->size++;
178:       tab->array[entry->u.index] = entry;
179:     }
180:   return entry->u.index;
```

## bfd/elf-strtab.c:387–415

```text
387: {
388:   struct elf_strtab_hash_entry **array, **a, *e;
389:   bfd_size_type amt, sec_size;
390:   size_t size, i;
391:
392:   /* Sort the strings by suffix and length.  */
393:   amt = tab->size;
394:   amt *= sizeof (struct elf_strtab_hash_entry *);
395:   array = (struct elf_strtab_hash_entry **) bfd_malloc (amt);
396:   if (array == NULL)
397:     goto alloc_failure;
398:
399:   for (i = 1, a = array; i < tab->size; ++i)
400:     {
401:       e = tab->array[i];
402:       if (e->refcount)
403:         {
404:           *a++ = e;
405:           /* Adjust the length to not include the zero terminator.  */
406:           e->len -= 1;
407:         }
408:       else
409:         e->len = 0;
410:     }
411:
412:   size = a - array;
413:   if (size != 0)
414:     {
415:       qsort (array, size, sizeof (struct elf_strtab_hash_entry *), strrevcmp);
```

## bfd/elf.c:3541–3549

```text
3541:   char *name = (char *) bfd_alloc (abfd,
3542:                                    sizeof ".rela" + strlen (sec_name));
3543:   if (name == NULL)
3544:     return false;
3545:
3546:   sprintf (name, "%s%s", use_rela_p ? ".rela" : ".rel", sec_name);
3547:   rel_hdr->sh_name =
3548:     (unsigned int) _bfd_elf_strtab_add (elf_shstrtab (abfd), name,
3549:                                         false);
```

## bfd/elf.c:3635–3662

```text
3635:   /* ld: compress DWARF debug sections with names: .debug_*.  */
3636:   if (arg->link_info
3637:       && (abfd->flags & BFD_COMPRESS) != 0
3638:       && (asect->flags & SEC_DEBUGGING) != 0
3639:       && (asect->flags & SEC_ALLOC) == 0
3640:       && (asect->flags & SEC_HAS_CONTENTS) != 0
3641:       && name[1] == 'd'
3642:       && name[6] == '_')
3643:     {
3644:       /* If this section will be compressed, delay adding section
3645:          name to section name section after it is compressed in
3646:          _bfd_elf_assign_file_positions_for_non_load.  */
3647:       delay_sh_name_p = true;
3648:     }
3649:
3650:   if (delay_sh_name_p)
3651:     this_hdr->sh_name = (unsigned int) -1;
3652:   else
3653:     {
3654:       this_hdr->sh_name
3655:         = (unsigned int) _bfd_elf_strtab_add (elf_shstrtab (abfd),
3656:                                               name, false);
3657:       if (this_hdr->sh_name == (unsigned int) -1)
3658:         {
3659:           arg->failed = true;
3660:           return;
3661:         }
3662:     }
```

## bfd/elf.c:7015–7021

```text
7015:   i_ehdrp = elf_elfheader (abfd);
7016:
7017:   shstrtab = _bfd_elf_strtab_init ();
7018:   if (shstrtab == NULL)
7019:     return false;
7020:
7021:   elf_shstrtab (abfd) = shstrtab;
```

## bfd/elf.c:7072–7077

```text
7072:   elf_tdata (abfd)->symtab_hdr.sh_name =
7073:     (unsigned int) _bfd_elf_strtab_add (shstrtab, ".symtab", false);
7074:   elf_tdata (abfd)->strtab_hdr.sh_name =
7075:     (unsigned int) _bfd_elf_strtab_add (shstrtab, ".strtab", false);
7076:   elf_tdata (abfd)->shstrtab_hdr.sh_name =
7077:     (unsigned int) _bfd_elf_strtab_add (shstrtab, ".shstrtab", false);
```

## bfd/elf.c:8744–8750

```text
8744:   if (!elf_map_symbols (abfd, &num_locals))
8745:     return false;
8746:
8747:   /* Dump out the symtabs.  */
8748:   stt = _bfd_elf_strtab_init ();
8749:   if (stt == NULL)
8750:     return false;
```

## bfd/elf.c:8837–8849

```text
8837:         {
8838:           /* Local section symbols have no name.  */
8839:           sym.st_name = 0;
8840:         }
8841:       else
8842:         {
8843:           /* Call _bfd_elf_strtab_offset after _bfd_elf_strtab_finalize
8844:              to get the final offset for st_name.  */
8845:           size_t stridx = _bfd_elf_strtab_add (stt, syms[idx]->name, false);
8846:           if (stridx == (size_t) -1)
8847:             goto error_return;
8848:           sym.st_name = stridx;
8849:         }
```

## bfd/hash.c:344–345

```text
344: /* The default number of entries to use when creating a hash table.  */
345: #define DEFAULT_SIZE 4051
```

## bfd/hash.c:406–487

```text
406: static unsigned int bfd_default_hash_table_size = DEFAULT_SIZE;
407:
408: /*
409: FUNCTION
410:         bfd_hash_table_init_n
411:
412: SYNOPSIS
413:         bool bfd_hash_table_init_n
414:           (struct bfd_hash_table *,
415:            struct bfd_hash_entry *(* {*newfunc*})
416:              (struct bfd_hash_entry *, struct bfd_hash_table *, const char *),
417:            unsigned int {*entsize*}, unsigned int {*size*});
418:
419: DESCRIPTION
420:         Create a new hash table, given a number of entries.
421: */
422:
423: bool
424: bfd_hash_table_init_n (struct bfd_hash_table *table,
425:                        struct bfd_hash_entry *(*newfunc) (struct bfd_hash_entry *,
426:                                                           struct bfd_hash_table *,
427:                                                           const char *),
428:                        unsigned int entsize,
429:                        unsigned int size)
430: {
431:   unsigned long alloc;
432:
433:   alloc = size;
434:   alloc *= sizeof (struct bfd_hash_entry *);
435:   if (alloc / sizeof (struct bfd_hash_entry *) != size)
436:     {
437:       bfd_set_error (bfd_error_no_memory);
438:       return false;
439:     }
440:
441:   table->memory = (void *) objalloc_create ();
442:   if (table->memory == NULL)
443:     {
444:       bfd_set_error (bfd_error_no_memory);
445:       return false;
446:     }
447:   table->table = (struct bfd_hash_entry **)
448:       objalloc_alloc ((struct objalloc *) table->memory, alloc);
449:   if (table->table == NULL)
450:     {
451:       bfd_hash_table_free (table);
452:       bfd_set_error (bfd_error_no_memory);
453:       return false;
454:     }
455:   memset ((void *) table->table, 0, alloc);
456:   table->size = size;
457:   table->entsize = entsize;
458:   table->count = 0;
459:   table->frozen = 0;
460:   table->newfunc = newfunc;
461:   return true;
462: }
463:
464: /*
465: FUNCTION
466:         bfd_hash_table_init
467:
468: SYNOPSIS
469:         bool bfd_hash_table_init
470:           (struct bfd_hash_table *,
471:            struct bfd_hash_entry *(* {*newfunc*})
472:              (struct bfd_hash_entry *, struct bfd_hash_table *, const char *),
473:            unsigned int {*entsize*});
474:
475: DESCRIPTION
476:         Create a new hash table with the default number of entries.
477: */
478:
479: bool
480: bfd_hash_table_init (struct bfd_hash_table *table,
481:                      struct bfd_hash_entry *(*newfunc) (struct bfd_hash_entry *,
482:                                                         struct bfd_hash_table *,
483:                                                         const char *),
484:                      unsigned int entsize)
485: {
486:   return bfd_hash_table_init_n (table, newfunc, entsize,
487:                                 bfd_default_hash_table_size);
```

## bfd/hash.c:548–586

```text
548:                  const char *string,
549:                  bool create,
550:                  bool copy)
551: {
552:   unsigned long hash;
553:   struct bfd_hash_entry *hashp;
554:   unsigned int len;
555:   unsigned int _index;
556:
557:   hash = bfd_hash_hash (string, &len);
558:   _index = hash % table->size;
559:   for (hashp = table->table[_index];
560:        hashp != NULL;
561:        hashp = hashp->next)
562:     {
563:       if (hashp->hash == hash
564:           && strcmp (hashp->string, string) == 0)
565:         return hashp;
566:     }
567:
568:   if (! create)
569:     return NULL;
570:
571:   if (copy)
572:     {
573:       char *new_string;
574:
575:       new_string = (char *) objalloc_alloc ((struct objalloc *) table->memory,
576:                                             len + 1);
577:       if (!new_string)
578:         {
579:           bfd_set_error (bfd_error_no_memory);
580:           return NULL;
581:         }
582:       memcpy (new_string, string, len + 1);
583:       string = new_string;
584:     }
585:
586:   return bfd_hash_insert (table, string, hash);
```

## bfd/hash.c:611–661

```text
611:   hashp = (*table->newfunc) (NULL, table, string);
612:   if (hashp == NULL)
613:     return NULL;
614:   hashp->string = string;
615:   hashp->hash = hash;
616:   _index = hash % table->size;
617:   hashp->next = table->table[_index];
618:   table->table[_index] = hashp;
619:   table->count++;
620:
621:   if (!table->frozen && table->count > table->size * 3 / 4)
622:     {
623:       unsigned long newsize = higher_prime_number (table->size);
624:       struct bfd_hash_entry **newtable;
625:       unsigned int hi;
626:       unsigned long alloc = newsize * sizeof (struct bfd_hash_entry *);
627:
628:       /* If we can't find a higher prime, or we can't possibly alloc
629:          that much memory, don't try to grow the table.  */
630:       if (newsize == 0 || alloc / sizeof (struct bfd_hash_entry *) != newsize)
631:         {
632:           table->frozen = 1;
633:           return hashp;
634:         }
635:
636:       newtable = ((struct bfd_hash_entry **)
637:                   objalloc_alloc ((struct objalloc *) table->memory, alloc));
638:       if (newtable == NULL)
639:         {
640:           table->frozen = 1;
641:           return hashp;
642:         }
643:       memset (newtable, 0, alloc);
644:
645:       for (hi = 0; hi < table->size; hi ++)
646:         while (table->table[hi])
647:           {
648:             struct bfd_hash_entry *chain = table->table[hi];
649:             struct bfd_hash_entry *chain_end = chain;
650:
651:             while (chain_end->next && chain_end->next->hash == chain->hash)
652:               chain_end = chain_end->next;
653:
654:             table->table[hi] = chain_end->next;
655:             _index = chain->hash % newsize;
656:             chain_end->next = newtable[_index];
657:             newtable[_index] = chain;
658:           }
659:       table->table = newtable;
660:       table->size = newsize;
661:     }
```

## bfd/hash.c:750–759

```text
750: void *
751: bfd_hash_allocate (struct bfd_hash_table *table,
752:                    unsigned int size)
753: {
754:   void * ret;
755:
756:   ret = objalloc_alloc ((struct objalloc *) table->memory, size);
757:   if (ret == NULL && size != 0)
758:     bfd_set_error (bfd_error_no_memory);
759:   return ret;
```

## bfd/hash.c:777–785

```text
777: bfd_hash_newfunc (struct bfd_hash_entry *entry,
778:                   struct bfd_hash_table *table,
779:                   const char *string ATTRIBUTE_UNUSED)
780: {
781:   if (entry == NULL)
782:     entry = (struct bfd_hash_entry *) bfd_hash_allocate (table,
783:                                                          sizeof (* entry));
784:   return entry;
785: }
```

## include/objalloc.h:44–63

```text
44: struct objalloc
45: {
46:   char *current_ptr;
47:   unsigned int current_space;
48:   void *chunks;
49: };
50:
51: /* Work out the required alignment.  */
52:
53: struct objalloc_align { char x; double d; };
54:
55: #if defined (__STDC__) && __STDC__
56: #ifndef offsetof
57: #include <stddef.h>
58: #endif
59: #endif
60: #ifndef offsetof
61: #define offsetof(TYPE, MEMBER) ((unsigned long) &((TYPE *)0)->MEMBER)
62: #endif
63: #define OBJALLOC_ALIGN offsetof (struct objalloc_align, d)
```

## include/objalloc.h:87–98

```text
87: #define objalloc_alloc(o, l)                                            \
88:   __extension__                                                         \
89:   ({ struct objalloc *__o = (o);                                        \
90:      unsigned long __len = (l);                                         \
91:      if (__len == 0)                                                    \
92:        __len = 1;                                                       \
93:      __len = (__len + OBJALLOC_ALIGN - 1) &~ (OBJALLOC_ALIGN - 1);      \
94:      (__len != 0 && __len <= __o->current_space                         \
95:       ? (__o->current_ptr += __len,                                     \
96:          __o->current_space -= __len,                                   \
97:          (void *) (__o->current_ptr - __len))                           \
98:       : _objalloc_alloc (__o, __len)); })
```

## libiberty/objalloc.c:55–81

```text
55:
56: /* This structure appears at the start of each chunk.  */
57:
58: struct objalloc_chunk
59: {
60:   /* Next chunk.  */
61:   struct objalloc_chunk *next;
62:   /* If this chunk contains large objects, this is the value of
63:      current_ptr when this chunk was allocated.  If this chunk
64:      contains small objects, this is NULL.  */
65:   char *current_ptr;
66: };
67:
68: /* The aligned size of objalloc_chunk.  */
69:
70: #define CHUNK_HEADER_SIZE                                       \
71:   ((sizeof (struct objalloc_chunk) + OBJALLOC_ALIGN - 1)        \
72:    &~ (OBJALLOC_ALIGN - 1))
73:
74: /* We ask for this much memory each time we create a chunk which is to
75:    hold small objects.  */
76:
77: #define CHUNK_SIZE (4096 - 32)
78:
79: /* A request for this amount or more is just passed through to malloc.  */
80:
81: #define BIG_REQUEST (512)
```

## libiberty/objalloc.c:85–170

```text
85: struct objalloc *
86: objalloc_create (void)
87: {
88:   struct objalloc *ret;
89:   struct objalloc_chunk *chunk;
90:
91:   ret = (struct objalloc *) malloc (sizeof *ret);
92:   if (ret == NULL)
93:     return NULL;
94:
95:   ret->chunks = (void *) malloc (CHUNK_SIZE);
96:   if (ret->chunks == NULL)
97:     {
98:       free (ret);
99:       return NULL;
100:     }
101:
102:   chunk = (struct objalloc_chunk *) ret->chunks;
103:   chunk->next = NULL;
104:   chunk->current_ptr = NULL;
105:
106:   ret->current_ptr = (char *) chunk + CHUNK_HEADER_SIZE;
107:   ret->current_space = CHUNK_SIZE - CHUNK_HEADER_SIZE;
108:
109:   return ret;
110: }
111:
112: /* Allocate space from an objalloc structure.  */
113:
114: void *
115: _objalloc_alloc (struct objalloc *o, unsigned long original_len)
116: {
117:   unsigned long len = original_len;
118:
119:   /* We avoid confusion from zero sized objects by always allocating
120:      at least 1 byte.  */
121:   if (len == 0)
122:     len = 1;
123:
124:   len = (len + OBJALLOC_ALIGN - 1) &~ (OBJALLOC_ALIGN - 1);
125:
126:   /* Check for overflow in the alignment operation above and the
127:      malloc argument below. */
128:   if (len + CHUNK_HEADER_SIZE < original_len)
129:     return NULL;
130:
131:   if (len <= o->current_space)
132:     {
133:       o->current_ptr += len;
134:       o->current_space -= len;
135:       return (void *) (o->current_ptr - len);
136:     }
137:
138:   if (len >= BIG_REQUEST)
139:     {
140:       char *ret;
141:       struct objalloc_chunk *chunk;
142:
143:       ret = (char *) malloc (CHUNK_HEADER_SIZE + len);
144:       if (ret == NULL)
145:         return NULL;
146:
147:       chunk = (struct objalloc_chunk *) ret;
148:       chunk->next = (struct objalloc_chunk *) o->chunks;
149:       chunk->current_ptr = o->current_ptr;
150:
151:       o->chunks = (void *) chunk;
152:
153:       return (void *) (ret + CHUNK_HEADER_SIZE);
154:     }
155:   else
156:     {
157:       struct objalloc_chunk *chunk;
158:
159:       chunk = (struct objalloc_chunk *) malloc (CHUNK_SIZE);
160:       if (chunk == NULL)
161:         return NULL;
162:       chunk->next = (struct objalloc_chunk *) o->chunks;
163:       chunk->current_ptr = NULL;
164:
165:       o->current_ptr = (char *) chunk + CHUNK_HEADER_SIZE;
166:       o->current_space = CHUNK_SIZE - CHUNK_HEADER_SIZE;
167:
168:       o->chunks = (void *) chunk;
169:
170:       return objalloc_alloc (o, len);
```
