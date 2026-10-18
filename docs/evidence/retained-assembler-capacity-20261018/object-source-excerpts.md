# Selected ELF object writer excerpts

Literal LF numbering.

## gas/output-file.c:34–54

```text
34: output_file_create (const char *name)
35: {
36:   if (name[0] == '-' && name[1] == '\0')
37:     as_fatal (_("can't open a bfd on stdout %s"), name);
38: 
39:   else if (!(stdoutput = bfd_openw (name, TARGET_FORMAT)))
40:     {
41:       bfd_error_type err = bfd_get_error ();
42: 
43:       if (err == bfd_error_invalid_target)
44:         as_fatal (_("selected target format '%s' unknown"), TARGET_FORMAT);
45:       else
46:         as_fatal (_("can't create %s: %s"), name, bfd_errmsg (err));
47:     }
48: 
49:   bfd_set_format (stdoutput, bfd_object);
50:   bfd_set_arch_mach (stdoutput, TARGET_ARCH, TARGET_MACH);
51:   if (flag_traditional_format)
52:     stdoutput->flags |= BFD_TRADITIONAL_FORMAT;
53: }
54: 
```

## gas/output-file.c:70–107

```text
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
96: 
97:   /* Close the bfd.  */
98:   if (!flag_always_generate_output && had_errors ())
99:     res = bfd_close_all_done (obfd);
100:   else
101:     res = bfd_close (obfd);
102:   now_seg = NULL;
103:   now_subseg = 0;
104: 
105:   filename = out_file_name;
106:   out_file_name = NULL;
107:   if (!keep_it && filename)
```

## bfd/elf.c:3535–3593

```text
3535: static bool
3536: _bfd_elf_set_reloc_sh_name (bfd *abfd,
3537:                             Elf_Internal_Shdr *rel_hdr,
3538:                             const char *sec_name,
3539:                             bool use_rela_p)
3540: {
3541:   char *name = (char *) bfd_alloc (abfd,
3542:                                    sizeof ".rela" + strlen (sec_name));
3543:   if (name == NULL)
3544:     return false;
3545: 
3546:   sprintf (name, "%s%s", use_rela_p ? ".rela" : ".rel", sec_name);
3547:   rel_hdr->sh_name =
3548:     (unsigned int) _bfd_elf_strtab_add (elf_shstrtab (abfd), name,
3549:                                         false);
3550:   if (rel_hdr->sh_name == (unsigned int) -1)
3551:     return false;
3552: 
3553:   return true;
3554: }
3555: 
3556: /* Allocate and initialize a section-header for a new reloc section,
3557:    containing relocations against ASECT.  It is stored in RELDATA.  If
3558:    USE_RELA_P is TRUE, we use RELA relocations; otherwise, we use REL
3559:    relocations.  */
3560: 
3561: static bool
3562: _bfd_elf_init_reloc_shdr (bfd *abfd,
3563:                           struct bfd_elf_section_reloc_data *reldata,
3564:                           const char *sec_name,
3565:                           bool use_rela_p,
3566:                           bool delay_sh_name_p)
3567: {
3568:   Elf_Internal_Shdr *rel_hdr;
3569:   elf_backend_data *bed = get_elf_backend_data (abfd);
3570: 
3571:   BFD_ASSERT (reldata->hdr == NULL);
3572:   rel_hdr = bfd_zalloc (abfd, sizeof (*rel_hdr));
3573:   if (rel_hdr == NULL)
3574:     return false;
3575:   reldata->hdr = rel_hdr;
3576: 
3577:   if (delay_sh_name_p)
3578:     rel_hdr->sh_name = (unsigned int) -1;
3579:   else if (!_bfd_elf_set_reloc_sh_name (abfd, rel_hdr, sec_name,
3580:                                         use_rela_p))
3581:     return false;
3582:   rel_hdr->sh_type = use_rela_p ? SHT_RELA : SHT_REL;
3583:   rel_hdr->sh_entsize = (use_rela_p
3584:                          ? bed->s->sizeof_rela
3585:                          : bed->s->sizeof_rel);
3586:   rel_hdr->sh_addralign = (bfd_vma) 1 << bed->s->log_file_align;
3587:   rel_hdr->sh_flags = 0;
3588:   rel_hdr->sh_addr = 0;
3589:   rel_hdr->sh_size = 0;
3590:   rel_hdr->sh_offset = 0;
3591: 
3592:   return true;
3593: }
```

## bfd/elf.c:3836–3884

```text
3836:   /* If the section has relocs, set up a section header for the
3837:      SHT_REL[A] section.  If two relocation sections are required for
3838:      this section, it is up to the processor-specific back-end to
3839:      create the other.  */
3840:   if ((asect->flags & SEC_RELOC) != 0)
3841:     {
3842:       /* When doing a relocatable link, create both REL and RELA sections if
3843:          needed.  */
3844:       if (arg->link_info
3845:           /* Do the normal setup if we wouldn't create any sections here.  */
3846:           && esd->rel.count + esd->rela.count > 0
3847:           && (bfd_link_relocatable (arg->link_info)
3848:               || arg->link_info->emitrelocations))
3849:         {
3850:           if (esd->rel.count && esd->rel.hdr == NULL
3851:               && !_bfd_elf_init_reloc_shdr (abfd, &esd->rel, name,
3852:                                             false, delay_sh_name_p))
3853:             {
3854:               arg->failed = true;
3855:               return;
3856:             }
3857:           if (esd->rela.count && esd->rela.hdr == NULL
3858:               && !_bfd_elf_init_reloc_shdr (abfd, &esd->rela, name,
3859:                                             true, delay_sh_name_p))
3860:             {
3861:               arg->failed = true;
3862:               return;
3863:             }
3864:         }
3865:       else if (!_bfd_elf_init_reloc_shdr (abfd,
3866:                                           (asect->use_rela_p
3867:                                            ? &esd->rela : &esd->rel),
3868:                                           name,
3869:                                           asect->use_rela_p,
3870:                                           delay_sh_name_p))
3871:         {
3872:           arg->failed = true;
3873:           return;
3874:         }
3875:     }
3876: 
3877:   /* Check for processor-specific section types.  */
3878:   sh_type = this_hdr->sh_type;
3879:   if (bed->elf_backend_fake_sections
3880:       && !(*bed->elf_backend_fake_sections) (abfd, this_hdr, asect))
3881:     {
3882:       arg->failed = true;
3883:       return;
3884:     }
```

## bfd/elf.c:4117–4260

```text
4117: assign_section_numbers (bfd *abfd, struct bfd_link_info *link_info)
4118: {
4119:   struct elf_obj_tdata *t = elf_tdata (abfd);
4120:   asection *sec;
4121:   unsigned int section_number;
4122:   Elf_Internal_Shdr **i_shdrp;
4123:   struct bfd_elf_section_data *d;
4124:   bool need_symtab;
4125:   size_t amt;
4126: 
4127:   section_number = 1;
4128: 
4129:   _bfd_elf_strtab_clear_all_refs (elf_shstrtab (abfd));
4130: 
4131:   /* SHT_GROUP sections are in relocatable files only.  */
4132:   if (link_info == NULL || !link_info->resolve_section_groups)
4133:     {
4134:       size_t reloc_count = 0;
4135: 
4136:       /* Put SHT_GROUP sections first.  */
4137:       for (sec = abfd->sections; sec != NULL; sec = sec->next)
4138:         {
4139:           d = elf_section_data (sec);
4140: 
4141:           if (d->this_hdr.sh_type == SHT_GROUP)
4142:             {
4143:               if (sec->flags & SEC_LINKER_CREATED)
4144:                 {
4145:                   /* Remove the linker created SHT_GROUP sections.  */
4146:                   bfd_section_list_remove (abfd, sec);
4147:                   abfd->section_count--;
4148:                 }
4149:               else
4150:                 d->this_idx = section_number++;
4151:             }
4152: 
4153:           /* Count relocations.  */
4154:           reloc_count += sec->reloc_count;
4155:         }
4156: 
4157:       /* Set/clear HAS_RELOC depending on whether there are relocations.  */
4158:       if (reloc_count == 0)
4159:         abfd->flags &= ~HAS_RELOC;
4160:       else
4161:         abfd->flags |= HAS_RELOC;
4162:     }
4163: 
4164:   for (sec = abfd->sections; sec; sec = sec->next)
4165:     {
4166:       d = elf_section_data (sec);
4167: 
4168:       if (d->this_hdr.sh_type != SHT_GROUP)
4169:         d->this_idx = section_number++;
4170:       if (d->this_hdr.sh_name != (unsigned int) -1)
4171:         _bfd_elf_strtab_addref (elf_shstrtab (abfd), d->this_hdr.sh_name);
4172:       if (d->rel.hdr)
4173:         {
4174:           d->rel.idx = section_number++;
4175:           if (d->rel.hdr->sh_name != (unsigned int) -1)
4176:             _bfd_elf_strtab_addref (elf_shstrtab (abfd), d->rel.hdr->sh_name);
4177:         }
4178:       else
4179:         d->rel.idx = 0;
4180: 
4181:       if (d->rela.hdr)
4182:         {
4183:           d->rela.idx = section_number++;
4184:           if (d->rela.hdr->sh_name != (unsigned int) -1)
4185:             _bfd_elf_strtab_addref (elf_shstrtab (abfd), d->rela.hdr->sh_name);
4186:         }
4187:       else
4188:         d->rela.idx = 0;
4189:     }
4190: 
4191:   need_symtab = (bfd_get_symcount (abfd) > 0
4192:                  || (link_info == NULL
4193:                      && ((abfd->flags & (EXEC_P | DYNAMIC | HAS_RELOC))
4194:                          == HAS_RELOC)));
4195:   if (need_symtab)
4196:     {
4197:       elf_onesymtab (abfd) = section_number++;
4198:       _bfd_elf_strtab_addref (elf_shstrtab (abfd), t->symtab_hdr.sh_name);
4199:       if (section_number > ((SHN_LORESERVE - 2) & 0xFFFF))
4200:         {
4201:           elf_section_list *entry;
4202: 
4203:           BFD_ASSERT (elf_symtab_shndx_list (abfd) == NULL);
4204: 
4205:           entry = bfd_zalloc (abfd, sizeof (*entry));
4206:           entry->ndx = section_number++;
4207:           elf_symtab_shndx_list (abfd) = entry;
4208:           entry->hdr.sh_name
4209:             = (unsigned int) _bfd_elf_strtab_add (elf_shstrtab (abfd),
4210:                                                   ".symtab_shndx", false);
4211:           if (entry->hdr.sh_name == (unsigned int) -1)
4212:             return false;
4213:         }
4214:       elf_strtab_sec (abfd) = section_number++;
4215:       _bfd_elf_strtab_addref (elf_shstrtab (abfd), t->strtab_hdr.sh_name);
4216:     }
4217: 
4218:   elf_shstrtab_sec (abfd) = section_number++;
4219:   _bfd_elf_strtab_addref (elf_shstrtab (abfd), t->shstrtab_hdr.sh_name);
4220:   elf_elfheader (abfd)->e_shstrndx = elf_shstrtab_sec (abfd);
4221: 
4222:   if (section_number >= SHN_LORESERVE)
4223:     {
4224:       /* xgettext:c-format */
4225:       _bfd_error_handler (_("%pB: too many sections: %u"),
4226:                           abfd, section_number);
4227:       return false;
4228:     }
4229: 
4230:   elf_numsections (abfd) = section_number;
4231:   elf_elfheader (abfd)->e_shnum = section_number;
4232: 
4233:   /* Set up the list of section header pointers, in agreement with the
4234:      indices.  */
4235:   amt = section_number * sizeof (Elf_Internal_Shdr *);
4236:   i_shdrp = (Elf_Internal_Shdr **) bfd_zalloc (abfd, amt);
4237:   if (i_shdrp == NULL)
4238:     return false;
4239: 
4240:   i_shdrp[0] = (Elf_Internal_Shdr *) bfd_zalloc (abfd,
4241:                                                  sizeof (Elf_Internal_Shdr));
4242:   if (i_shdrp[0] == NULL)
4243:     {
4244:       bfd_release (abfd, i_shdrp);
4245:       return false;
4246:     }
4247: 
4248:   elf_elfsections (abfd) = i_shdrp;
4249: 
4250:   i_shdrp[elf_shstrtab_sec (abfd)] = &t->shstrtab_hdr;
4251:   if (need_symtab)
4252:     {
4253:       i_shdrp[elf_onesymtab (abfd)] = &t->symtab_hdr;
4254:       if (elf_numsections (abfd) > (SHN_LORESERVE & 0xFFFF))
4255:         {
4256:           elf_section_list * entry = elf_symtab_shndx_list (abfd);
4257:           BFD_ASSERT (entry != NULL);
4258:           i_shdrp[entry->ndx] = & entry->hdr;
4259:           entry->hdr.sh_link = elf_onesymtab (abfd);
4260:         }
```

## bfd/elf.c:4527–4659

```text
4527: elf_map_symbols (bfd *abfd, unsigned int *pnum_locals)
4528: {
4529:   unsigned int symcount = bfd_get_symcount (abfd);
4530:   asymbol **syms = bfd_get_outsymbols (abfd);
4531:   asymbol **sect_syms;
4532:   unsigned int num_locals = 0;
4533:   unsigned int num_globals = 0;
4534:   unsigned int max_index = 0;
4535:   unsigned int idx;
4536:   asection *asect;
4537:   asymbol **new_syms;
4538:   size_t amt;
4539: 
4540: #ifdef DEBUG
4541:   fprintf (stderr, "elf_map_symbols\n");
4542:   fflush (stderr);
4543: #endif
4544: 
4545:   for (asect = abfd->sections; asect; asect = asect->next)
4546:     {
4547:       if (max_index < asect->index)
4548:         max_index = asect->index;
4549:     }
4550: 
4551:   max_index++;
4552:   amt = max_index * sizeof (asymbol *);
4553:   sect_syms = (asymbol **) bfd_zalloc (abfd, amt);
4554:   if (sect_syms == NULL)
4555:     return false;
4556:   elf_section_syms (abfd) = sect_syms;
4557:   elf_num_section_syms (abfd) = max_index;
4558: 
4559:   /* Init sect_syms entries for any section symbols we have already
4560:      decided to output.  */
4561:   for (idx = 0; idx < symcount; idx++)
4562:     {
4563:       asymbol *sym = syms[idx];
4564: 
4565:       if ((sym->flags & BSF_SECTION_SYM) != 0
4566:           && sym->value == 0
4567:           && !ignore_sym (sym)
4568:           && !bfd_is_abs_section (sym->section))
4569:         {
4570:           asection *sec = sym->section;
4571: 
4572:           if (sec->owner != abfd)
4573:             {
4574:               sec = sec->output_section;
4575:               if (sec == NULL)
4576:                 return false;
4577:             }
4578: 
4579:           sect_syms[sec->index] = syms[idx];
4580:         }
4581:     }
4582: 
4583:   /* Classify all of the symbols.  */
4584:   for (idx = 0; idx < symcount; idx++)
4585:     {
4586:       if (ignore_sym (syms[idx]))
4587:         continue;
4588:       if (sym_is_global (abfd, syms[idx]))
4589:         num_globals++;
4590:       else
4591:         num_locals++;
4592:     }
4593: 
4594:   /* We will be adding a section symbol for each normal BFD section.  Most
4595:      sections will already have a section symbol in outsymbols, but
4596:      eg. SHT_GROUP sections will not, and we need the section symbol mapped
4597:      at least in that case.  */
4598:   for (asect = abfd->sections; asect; asect = asect->next)
4599:     {
4600:       asymbol *sym = asect->symbol;
4601:       /* Don't include ignored section symbols.  */
4602:       if (!ignore_sym (sym)
4603:           && sect_syms[asect->index] == NULL)
4604:         {
4605:           if (sym_is_global (abfd, asect->symbol))
4606:             num_globals++;
4607:           else
4608:             num_locals++;
4609:         }
4610:     }
4611: 
4612:   /* Now sort the symbols so the local symbols are first.  */
4613:   amt = (num_locals + num_globals) * sizeof (asymbol *);
4614:   new_syms = (asymbol **) bfd_alloc (abfd, amt);
4615:   if (new_syms == NULL)
4616:     return false;
4617: 
4618:   unsigned int num_globals2 = 0;
4619:   unsigned int num_locals2 = 0;
4620:   for (idx = 0; idx < symcount; idx++)
4621:     {
4622:       asymbol *sym = syms[idx];
4623:       unsigned int i;
4624: 
4625:       if (ignore_sym (sym))
4626:         continue;
4627: 
4628:       if (sym_is_global (abfd, sym))
4629:         i = num_locals + num_globals2++;
4630:       else
4631:         i = num_locals2++;
4632:       new_syms[i] = sym;
4633:       sym->udata.i = i + 1;
4634:     }
4635:   for (asect = abfd->sections; asect; asect = asect->next)
4636:     {
4637:       asymbol *sym = asect->symbol;
4638:       if (!ignore_sym (sym)
4639:           && sect_syms[asect->index] == NULL)
4640:         {
4641:           unsigned int i;
4642: 
4643:           sect_syms[asect->index] = sym;
4644:           if (sym_is_global (abfd, sym))
4645:             i = num_locals + num_globals2++;
4646:           else
4647:             i = num_locals2++;
4648:           new_syms[i] = sym;
4649:           sym->udata.i = i + 1;
4650:         }
4651:     }
4652: 
4653:   bfd_set_symtab (abfd, new_syms, num_locals + num_globals);
4654: 
4655:   *pnum_locals = num_locals;
4656:   return true;
4657: }
4658: 
4659: /* Assign a file position to a section, optionally aligning to the
```

## bfd/elf.c:4667–4793

```text
4667: {
4668:   if (i_shdrp->sh_addralign > 1)
4669:     {
4670:       file_ptr salign = i_shdrp->sh_addralign & -i_shdrp->sh_addralign;
4671: 
4672:       if (align)
4673:         offset = BFD_ALIGN (offset, salign);
4674:       else if (log_file_align)
4675:         {
4676:           /* Heuristic: Cap alignment at log_file_align.  */
4677:           file_ptr falign = 1u << log_file_align;
4678: 
4679:           offset = BFD_ALIGN (offset, salign < falign ? salign : falign);
4680:         }
4681:     }
4682:   i_shdrp->sh_offset = offset;
4683:   if (i_shdrp->bfd_section != NULL)
4684:     i_shdrp->bfd_section->filepos = offset;
4685:   if (i_shdrp->sh_type != SHT_NOBITS)
4686:     offset += i_shdrp->sh_size;
4687:   return offset;
4688: }
4689: 
4690: /* Compute the file positions we are going to put the sections at, and
4691:    otherwise prepare to begin writing out the ELF file.  If LINK_INFO
4692:    is not NULL, this is being called by the ELF backend linker.  */
4693: 
4694: bool
4695: _bfd_elf_compute_section_file_positions (bfd *abfd,
4696:                                          struct bfd_link_info *link_info)
4697: {
4698:   elf_backend_data *bed = get_elf_backend_data (abfd);
4699:   struct fake_section_arg fsargs;
4700:   bool failed;
4701:   struct elf_strtab_hash *strtab = NULL;
4702:   Elf_Internal_Shdr *shstrtab_hdr;
4703:   bool need_symtab;
4704: 
4705:   if (abfd->output_has_begun)
4706:     return true;
4707: 
4708:   /* Do any elf backend specific processing first.  */
4709:   if (bed->elf_backend_begin_write_processing)
4710:     (*bed->elf_backend_begin_write_processing) (abfd, link_info);
4711: 
4712:   if (!(*bed->elf_backend_init_file_header) (abfd, link_info))
4713:     return false;
4714: 
4715:   fsargs.failed = false;
4716:   fsargs.link_info = link_info;
4717:   bfd_map_over_sections (abfd, elf_fake_sections, &fsargs);
4718:   if (fsargs.failed)
4719:     return false;
4720: 
4721:   if (!assign_section_numbers (abfd, link_info))
4722:     return false;
4723: 
4724:   /* The backend linker builds symbol table information itself.  */
4725:   need_symtab = (link_info == NULL
4726:                  && (bfd_get_symcount (abfd) > 0
4727:                      || ((abfd->flags & (EXEC_P | DYNAMIC | HAS_RELOC))
4728:                          == HAS_RELOC)));
4729:   if (need_symtab)
4730:     {
4731:       /* Non-zero if doing a relocatable link.  */
4732:       int relocatable_p = ! (abfd->flags & (EXEC_P | DYNAMIC));
4733: 
4734:       if (! swap_out_syms (abfd, &strtab, relocatable_p, link_info))
4735:         return false;
4736:     }
4737: 
4738:   failed = false;
4739:   if (link_info == NULL)
4740:     {
4741:       bfd_map_over_sections (abfd, bfd_elf_set_group_contents, &failed);
4742:       if (failed)
4743:         goto err_free_strtab;
4744:     }
4745: 
4746:   shstrtab_hdr = &elf_tdata (abfd)->shstrtab_hdr;
4747:   /* sh_name was set in init_file_header.  */
4748:   shstrtab_hdr->sh_type = SHT_STRTAB;
4749:   /* sh_flags, sh_addr, sh_entsize, sh_link, sh_info are all zeroed
4750:      when tdata is allocated.  */
4751:   /* sh_size is set in _bfd_elf_assign_file_positions_for_non_load.  */
4752:   /* sh_offset is set in _bfd_elf_assign_file_positions_for_non_load.  */
4753:   shstrtab_hdr->sh_addralign = 1;
4754: 
4755:   if (!assign_file_positions_except_relocs (abfd, link_info))
4756:     goto err_free_strtab;
4757: 
4758:   if (strtab != NULL)
4759:     {
4760:       file_ptr off;
4761:       Elf_Internal_Shdr *hdr;
4762: 
4763:       off = elf_next_file_pos (abfd);
4764: 
4765:       hdr = & elf_symtab_hdr (abfd);
4766:       off = _bfd_elf_assign_file_position_for_section (hdr, off, true, 0);
4767: 
4768:       if (elf_symtab_shndx_list (abfd) != NULL)
4769:         {
4770:           hdr = & elf_symtab_shndx_list (abfd)->hdr;
4771:           if (hdr->sh_size != 0)
4772:             off = _bfd_elf_assign_file_position_for_section (hdr, off, true, 0);
4773:           /* FIXME: What about other symtab_shndx sections in the list ?  */
4774:         }
4775: 
4776:       hdr = &elf_tdata (abfd)->strtab_hdr;
4777:       off = _bfd_elf_assign_file_position_for_section (hdr, off, true, 0);
4778: 
4779:       elf_next_file_pos (abfd) = off;
4780: 
4781:       /* Now that we know where the .strtab section goes, write it
4782:          out.  */
4783:       if (bfd_seek (abfd, hdr->sh_offset, SEEK_SET) != 0
4784:           || ! _bfd_elf_strtab_emit (abfd, strtab))
4785:         goto err_free_strtab;
4786:       _bfd_elf_strtab_free (strtab);
4787:     }
4788: 
4789:   abfd->output_has_begun = true;
4790:   return true;
4791: 
4792:  err_free_strtab:
4793:   if (strtab != NULL)
```

## bfd/elf.c:6857–6920

```text
6857:    sections and CTF sections which nothing else in the file can rely
6858:    upon) will be handled later by assign_file_positions_for_relocs.
6859: 
6860:    We also don't set the positions of the .symtab and .strtab here.  */
6861: 
6862: static bool
6863: assign_file_positions_except_relocs (bfd *abfd,
6864:                                      struct bfd_link_info *link_info)
6865: {
6866:   struct elf_obj_tdata *tdata = elf_tdata (abfd);
6867:   Elf_Internal_Ehdr *i_ehdrp = elf_elfheader (abfd);
6868:   elf_backend_data *bed = get_elf_backend_data (abfd);
6869:   unsigned int alloc;
6870: 
6871:   if ((abfd->flags & (EXEC_P | DYNAMIC)) == 0
6872:       && bfd_get_format (abfd) != bfd_core)
6873:     {
6874:       Elf_Internal_Shdr ** const i_shdrpp = elf_elfsections (abfd);
6875:       unsigned int num_sec = elf_numsections (abfd);
6876:       Elf_Internal_Shdr **hdrpp;
6877:       unsigned int i;
6878:       file_ptr off;
6879: 
6880:       /* Start after the ELF header.  */
6881:       off = i_ehdrp->e_ehsize;
6882: 
6883:       /* We are not creating an executable, which means that we are
6884:          not creating a program header, and that the actual order of
6885:          the sections in the file is unimportant.  */
6886:       for (i = 1, hdrpp = i_shdrpp + 1; i < num_sec; i++, hdrpp++)
6887:         {
6888:           Elf_Internal_Shdr *hdr;
6889: 
6890:           hdr = *hdrpp;
6891:           if (((hdr->sh_type == SHT_REL || hdr->sh_type == SHT_RELA)
6892:                && hdr->bfd_section == NULL)
6893:               /* Do not assign offsets for these sections yet: we don't know
6894:                  their sizes.  */
6895:               || (abfd->is_linker_output
6896:                   && hdr->bfd_section != NULL
6897:                   && (hdr->sh_name == -1u
6898:                       || bfd_section_is_ctf (hdr->bfd_section)))
6899:               || i == elf_onesymtab (abfd)
6900:               || (elf_symtab_shndx_list (abfd) != NULL
6901:                   && hdr == i_shdrpp[elf_symtab_shndx_list (abfd)->ndx])
6902:               || i == elf_strtab_sec (abfd)
6903:               || i == elf_shstrtab_sec (abfd))
6904:             {
6905:               hdr->sh_offset = -1;
6906:             }
6907:           else
6908:             /* There shouldn't be a need to effect "capped" file alignment here,
6909:                yet at least the Linux kernel's modpost utility was found to be
6910:                unhappy without.  While the issue was addressed there, let's be
6911:                kind for at least the foreseeable future ...  */
6912:             off = _bfd_elf_assign_file_position_for_section (hdr, off, false,
6913:                                                              bed->s->log_file_align);
6914:         }
6915: 
6916:       elf_next_file_pos (abfd) = off;
6917:       elf_program_header_size (abfd) = 0;
6918:     }
6919:   else
6920:     {
```

## bfd/elf.c:7008–7084

```text
7008: _bfd_elf_init_file_header (bfd *abfd,
7009:                            struct bfd_link_info *info ATTRIBUTE_UNUSED)
7010: {
7011:   Elf_Internal_Ehdr *i_ehdrp;   /* Elf file header, internal form.  */
7012:   struct elf_strtab_hash *shstrtab;
7013:   elf_backend_data *bed = get_elf_backend_data (abfd);
7014: 
7015:   i_ehdrp = elf_elfheader (abfd);
7016: 
7017:   shstrtab = _bfd_elf_strtab_init ();
7018:   if (shstrtab == NULL)
7019:     return false;
7020: 
7021:   elf_shstrtab (abfd) = shstrtab;
7022: 
7023:   i_ehdrp->e_ident[EI_MAG0] = ELFMAG0;
7024:   i_ehdrp->e_ident[EI_MAG1] = ELFMAG1;
7025:   i_ehdrp->e_ident[EI_MAG2] = ELFMAG2;
7026:   i_ehdrp->e_ident[EI_MAG3] = ELFMAG3;
7027: 
7028:   i_ehdrp->e_ident[EI_CLASS] = bed->s->elfclass;
7029:   i_ehdrp->e_ident[EI_DATA] =
7030:     bfd_big_endian (abfd) ? ELFDATA2MSB : ELFDATA2LSB;
7031:   i_ehdrp->e_ident[EI_VERSION] = bed->s->ev_current;
7032: 
7033:   if ((abfd->flags & DYNAMIC) != 0)
7034:     i_ehdrp->e_type = ET_DYN;
7035:   else if ((abfd->flags & EXEC_P) != 0)
7036:     i_ehdrp->e_type = ET_EXEC;
7037:   else if (bfd_get_format (abfd) == bfd_core)
7038:     i_ehdrp->e_type = ET_CORE;
7039:   else
7040:     i_ehdrp->e_type = ET_REL;
7041: 
7042:   switch (bfd_get_arch (abfd))
7043:     {
7044:     case bfd_arch_unknown:
7045:       i_ehdrp->e_machine = EM_NONE;
7046:       break;
7047: 
7048:       /* There used to be a long list of cases here, each one setting
7049:          e_machine to the same EM_* macro #defined as ELF_MACHINE_CODE
7050:          in the corresponding bfd definition.  To avoid duplication,
7051:          the switch was removed.  Machines that need special handling
7052:          can generally do it in elf_backend_final_write_processing(),
7053:          unless they need the information earlier than the final write.
7054:          Such need can generally be supplied by replacing the tests for
7055:          e_machine with the conditions used to determine it.  */
7056:     default:
7057:       i_ehdrp->e_machine = bed->elf_machine_code;
7058:     }
7059: 
7060:   i_ehdrp->e_version = bed->s->ev_current;
7061:   i_ehdrp->e_ehsize = bed->s->sizeof_ehdr;
7062: 
7063:   /* No program header, for now.  */
7064:   i_ehdrp->e_phoff = 0;
7065:   i_ehdrp->e_phentsize = 0;
7066:   i_ehdrp->e_phnum = 0;
7067: 
7068:   /* Each bfd section is section header entry.  */
7069:   i_ehdrp->e_entry = bfd_get_start_address (abfd);
7070:   i_ehdrp->e_shentsize = bed->s->sizeof_shdr;
7071: 
7072:   elf_tdata (abfd)->symtab_hdr.sh_name =
7073:     (unsigned int) _bfd_elf_strtab_add (shstrtab, ".symtab", false);
7074:   elf_tdata (abfd)->strtab_hdr.sh_name =
7075:     (unsigned int) _bfd_elf_strtab_add (shstrtab, ".strtab", false);
7076:   elf_tdata (abfd)->shstrtab_hdr.sh_name =
7077:     (unsigned int) _bfd_elf_strtab_add (shstrtab, ".shstrtab", false);
7078:   if (elf_tdata (abfd)->symtab_hdr.sh_name == (unsigned int) -1
7079:       || elf_tdata (abfd)->strtab_hdr.sh_name == (unsigned int) -1
7080:       || elf_tdata (abfd)->shstrtab_hdr.sh_name == (unsigned int) -1)
7081:     return false;
7082: 
7083:   return true;
7084: }
```

## bfd/elf.c:7122–7298

```text
7122: _bfd_elf_assign_file_positions_for_non_load (bfd *abfd)
7123: {
7124:   file_ptr off;
7125:   Elf_Internal_Shdr **shdrpp, **end_shdrpp;
7126:   Elf_Internal_Shdr *shdrp;
7127:   Elf_Internal_Ehdr *i_ehdrp;
7128:   elf_backend_data *bed = get_elf_backend_data (abfd);
7129: 
7130:   /* Skip non-load sections without section header.  */
7131:   if ((abfd->flags & BFD_NO_SECTION_HEADER) != 0)
7132:     return true;
7133: 
7134:   off = elf_next_file_pos (abfd);
7135: 
7136:   shdrpp = elf_elfsections (abfd);
7137:   end_shdrpp = shdrpp + elf_numsections (abfd);
7138:   for (shdrpp++; shdrpp < end_shdrpp; shdrpp++)
7139:     {
7140:       shdrp = *shdrpp;
7141:       if (shdrp->sh_offset == -1)
7142:         {
7143:           asection *sec = shdrp->bfd_section;
7144:           if (sec == NULL
7145:               || shdrp->sh_type == SHT_REL
7146:               || shdrp->sh_type == SHT_RELA)
7147:             ;
7148:           else if (bfd_section_is_ctf (sec))
7149:             {
7150:               /* Update section size and contents.      */
7151:               shdrp->sh_size = sec->size;
7152:               shdrp->contents = sec->contents;
7153:             }
7154:           else if (shdrp->sh_name == -1u)
7155:             {
7156:               const char *name = sec->name;
7157:               struct bfd_elf_section_data *d;
7158: 
7159:               /* Compress DWARF debug sections.  */
7160:               if (!bfd_compress_section (abfd, sec, shdrp->contents))
7161:                 return false;
7162: 
7163:               if (sec->compress_status == COMPRESS_SECTION_DONE
7164:                   && (abfd->flags & BFD_COMPRESS_GABI) == 0
7165:                   && name[1] == 'd')
7166:                 {
7167:                   /* If section is compressed with zlib-gnu, convert
7168:                      section name from .debug_* to .zdebug_*.  */
7169:                   char *new_name = bfd_debug_name_to_zdebug (abfd, name);
7170:                   if (new_name == NULL)
7171:                     return false;
7172:                   name = new_name;
7173:                 }
7174:               /* Add section name to section name section.  */
7175:               shdrp->sh_name
7176:                 = (unsigned int) _bfd_elf_strtab_add (elf_shstrtab (abfd),
7177:                                                       name, false);
7178:               d = elf_section_data (sec);
7179: 
7180:               /* Add reloc section name to section name section.  */
7181:               if (d->rel.hdr
7182:                   && !_bfd_elf_set_reloc_sh_name (abfd, d->rel.hdr,
7183:                                                   name, false))
7184:                 return false;
7185:               if (d->rela.hdr
7186:                   && !_bfd_elf_set_reloc_sh_name (abfd, d->rela.hdr,
7187:                                                   name, true))
7188:                 return false;
7189: 
7190:               /* Update section size and contents.  */
7191:               shdrp->sh_size = sec->size;
7192:               shdrp->contents = sec->contents;
7193:               sec->contents = NULL;
7194:             }
7195: 
7196:           off = _bfd_elf_assign_file_position_for_section (shdrp, off,
7197:                   (abfd->flags & (EXEC_P | DYNAMIC))
7198:                   || bfd_get_format (abfd) == bfd_core,
7199:                   bed->s->log_file_align);
7200:         }
7201:     }
7202: 
7203:   /* Place section name section after DWARF debug sections have been
7204:      compressed.  */
7205:   _bfd_elf_strtab_finalize (elf_shstrtab (abfd));
7206:   shdrp = &elf_tdata (abfd)->shstrtab_hdr;
7207:   shdrp->sh_size = _bfd_elf_strtab_size (elf_shstrtab (abfd));
7208:   off = _bfd_elf_assign_file_position_for_section (shdrp, off, true, 0);
7209: 
7210:   /* Place the section headers.  */
7211:   i_ehdrp = elf_elfheader (abfd);
7212:   off = BFD_ALIGN (off, 1u << bed->s->log_file_align);
7213:   i_ehdrp->e_shoff = off;
7214:   off += i_ehdrp->e_shnum * i_ehdrp->e_shentsize;
7215:   elf_next_file_pos (abfd) = off;
7216: 
7217:   return true;
7218: }
7219: 
7220: bool
7221: _bfd_elf_write_object_contents (bfd *abfd)
7222: {
7223:   elf_backend_data *bed = get_elf_backend_data (abfd);
7224:   Elf_Internal_Shdr **i_shdrp;
7225:   bool failed;
7226:   unsigned int count, num_sec;
7227:   struct elf_obj_tdata *t;
7228: 
7229:   if (! abfd->output_has_begun
7230:       && ! _bfd_elf_compute_section_file_positions (abfd, NULL))
7231:     return false;
7232:   /* Do not rewrite ELF data when the BFD has been opened for update.
7233:      abfd->output_has_begun was set to TRUE on opening, so creation of
7234:      new sections, and modification of existing section sizes was
7235:      restricted.  This means the ELF header, program headers and
7236:      section headers can't have changed.  If the contents of any
7237:      sections has been modified, then those changes have already been
7238:      written to the BFD.  */
7239:   else if (abfd->direction == both_direction)
7240:     {
7241:       BFD_ASSERT (abfd->output_has_begun);
7242:       return true;
7243:     }
7244: 
7245:   i_shdrp = elf_elfsections (abfd);
7246: 
7247:   failed = false;
7248:   bfd_map_over_sections (abfd, bed->s->write_relocs, &failed);
7249:   if (failed)
7250:     return false;
7251: 
7252:   if (!_bfd_elf_assign_file_positions_for_non_load (abfd))
7253:     return false;
7254: 
7255:   /* After writing the headers, we need to write the sections too...  */
7256:   num_sec = elf_numsections (abfd);
7257:   for (count = 1; count < num_sec; count++)
7258:     {
7259:       /* Don't set the sh_name field without section header.  */
7260:       if ((abfd->flags & BFD_NO_SECTION_HEADER) == 0)
7261:         i_shdrp[count]->sh_name
7262:           = _bfd_elf_strtab_offset (elf_shstrtab (abfd),
7263:                                     i_shdrp[count]->sh_name);
7264:       if (bed->elf_backend_section_processing)
7265:         if (!(*bed->elf_backend_section_processing) (abfd, i_shdrp[count]))
7266:           return false;
7267:       if (i_shdrp[count]->contents)
7268:         {
7269:           bfd_size_type amt = i_shdrp[count]->sh_size;
7270: 
7271:           if (bfd_seek (abfd, i_shdrp[count]->sh_offset, SEEK_SET) != 0
7272:               || bfd_write (i_shdrp[count]->contents, amt, abfd) != amt)
7273:             return false;
7274:         }
7275:     }
7276: 
7277:   /* Write out the section header names.  */
7278:   t = elf_tdata (abfd);
7279:   if (elf_shstrtab (abfd) != NULL
7280:       && t->shstrtab_hdr.sh_offset != -1
7281:       && (bfd_seek (abfd, t->shstrtab_hdr.sh_offset, SEEK_SET) != 0
7282:           || !_bfd_elf_strtab_emit (abfd, elf_shstrtab (abfd))))
7283:     return false;
7284: 
7285:   if (!(*bed->elf_backend_final_write_processing) (abfd))
7286:     return false;
7287: 
7288:   if (!bed->s->write_shdrs_and_ehdr (abfd))
7289:     return false;
7290: 
7291:   /* This is last since write_shdrs_and_ehdr can touch i_shdrp[0].  */
7292:   if (t->o->build_id.after_write_object_contents != NULL
7293:       && !(*t->o->build_id.after_write_object_contents) (abfd))
7294:     return false;
7295:   if (t->o->package_metadata.after_write_object_contents != NULL
7296:       && !(*t->o->package_metadata.after_write_object_contents) (abfd))
7297:     return false;
7298: 
```

## bfd/elf.c:7349–7402

```text
7349: _bfd_elf_symbol_from_bfd_symbol (bfd *abfd, asymbol **asym_ptr_ptr)
7350: {
7351:   asymbol *asym_ptr = *asym_ptr_ptr;
7352:   int idx;
7353:   flagword flags = asym_ptr->flags;
7354: 
7355:   /* When gas creates relocations against local labels, it creates its
7356:      own symbol for the section, but does put the symbol into the
7357:      symbol chain, so udata is 0.  When the linker is generating
7358:      relocatable output, this section symbol may be for one of the
7359:      input sections rather than the output section.  */
7360:   if (asym_ptr->udata.i == 0
7361:       && (flags & BSF_SECTION_SYM)
7362:       && asym_ptr->section)
7363:     {
7364:       asection *sec;
7365: 
7366:       sec = asym_ptr->section;
7367:       if (sec->owner != abfd && sec->output_section != NULL)
7368:         sec = sec->output_section;
7369:       if (sec->owner == abfd
7370:           && sec->index < elf_num_section_syms (abfd)
7371:           && elf_section_syms (abfd)[sec->index] != NULL)
7372:         asym_ptr->udata.i = elf_section_syms (abfd)[sec->index]->udata.i;
7373:     }
7374: 
7375:   idx = asym_ptr->udata.i;
7376: 
7377:   if (idx == 0)
7378:     {
7379:       /* This case can occur when using --strip-symbol on a symbol
7380:          which is used in a relocation entry.  */
7381:       _bfd_error_handler
7382:         /* xgettext:c-format */
7383:         (_("%pB: symbol `%s' required but not present"),
7384:          abfd, bfd_asymbol_name (asym_ptr));
7385:       bfd_set_error (bfd_error_no_symbols);
7386:       return -1;
7387:     }
7388: 
7389: #if DEBUG & 4
7390:   {
7391:     fprintf (stderr,
7392:              "elf_symbol_from_bfd_symbol 0x%.8lx, name = %s, sym num = %d,"
7393:              " flags = 0x%.8x\n",
7394:              (long) asym_ptr, asym_ptr->name, idx, flags);
7395:     fflush (stderr);
7396:   }
7397: #endif
7398: 
7399:   return idx;
7400: }
7401: 
7402: static inline bfd_vma
```

## bfd/elf.c:8723–8784

```text
8723: swap_out_syms (bfd *abfd,
8724:                struct elf_strtab_hash **sttp,
8725:                int relocatable_p,
8726:                struct bfd_link_info *info)
8727: {
8728:   elf_backend_data *bed;
8729:   unsigned int symcount;
8730:   asymbol **syms;
8731:   struct elf_strtab_hash *stt;
8732:   Elf_Internal_Shdr *symtab_hdr;
8733:   Elf_Internal_Shdr *symtab_shndx_hdr;
8734:   Elf_Internal_Shdr *symstrtab_hdr;
8735:   struct elf_sym_strtab *symstrtab;
8736:   bfd_byte *outbound_syms;
8737:   bfd_byte *outbound_shndx;
8738:   unsigned long outbound_syms_index;
8739:   unsigned int idx;
8740:   unsigned int num_locals;
8741:   size_t amt;
8742:   bool name_local_sections;
8743: 
8744:   if (!elf_map_symbols (abfd, &num_locals))
8745:     return false;
8746: 
8747:   /* Dump out the symtabs.  */
8748:   stt = _bfd_elf_strtab_init ();
8749:   if (stt == NULL)
8750:     return false;
8751: 
8752:   bed = get_elf_backend_data (abfd);
8753:   symcount = bfd_get_symcount (abfd);
8754:   symtab_hdr = &elf_tdata (abfd)->symtab_hdr;
8755:   symtab_hdr->sh_type = SHT_SYMTAB;
8756:   symtab_hdr->sh_entsize = bed->s->sizeof_sym;
8757:   symtab_hdr->sh_size = symtab_hdr->sh_entsize * (symcount + 1);
8758:   symtab_hdr->sh_info = num_locals + 1;
8759:   symtab_hdr->sh_addralign = (bfd_vma) 1 << bed->s->log_file_align;
8760: 
8761:   symstrtab_hdr = &elf_tdata (abfd)->strtab_hdr;
8762:   symstrtab_hdr->sh_type = SHT_STRTAB;
8763: 
8764:   /* Allocate buffer to swap out the .strtab section.  */
8765:   if (_bfd_mul_overflow (symcount + 1, sizeof (*symstrtab), &amt)
8766:       || (symstrtab = (struct elf_sym_strtab *) bfd_malloc (amt)) == NULL)
8767:     {
8768:       bfd_set_error (bfd_error_no_memory);
8769:       _bfd_elf_strtab_free (stt);
8770:       return false;
8771:     }
8772: 
8773:   if (_bfd_mul_overflow (symcount + 1, bed->s->sizeof_sym, &amt)
8774:       || (outbound_syms = bfd_malloc (amt)) == NULL)
8775:     {
8776:     error_no_mem:
8777:       bfd_set_error (bfd_error_no_memory);
8778:     error_return:
8779:       free (symstrtab);
8780:       _bfd_elf_strtab_free (stt);
8781:       return false;
8782:     }
8783:   symtab_hdr->contents = outbound_syms;
8784:   outbound_syms_index = 0;
```

## bfd/elf.c:8804–8850

```text
8804:           symtab_shndx_hdr->sh_entsize = sizeof (Elf_External_Sym_Shndx);
8805:         }
8806:       /* FIXME: What about any other headers in the list ?  */
8807:     }
8808: 
8809:   /* Now generate the data (for "contents").  */
8810:   {
8811:     /* Fill in zeroth symbol and swap it out.  */
8812:     Elf_Internal_Sym sym;
8813:     sym.st_name = 0;
8814:     sym.st_value = 0;
8815:     sym.st_size = 0;
8816:     sym.st_info = 0;
8817:     sym.st_other = 0;
8818:     sym.st_shndx = SHN_UNDEF;
8819:     sym.st_target_internal = 0;
8820:     symstrtab[outbound_syms_index].sym = sym;
8821:     symstrtab[outbound_syms_index].dest_index = outbound_syms_index;
8822:     outbound_syms_index++;
8823:   }
8824: 
8825:   name_local_sections
8826:     = (bed->elf_backend_name_local_section_symbols
8827:        && bed->elf_backend_name_local_section_symbols (abfd));
8828: 
8829:   syms = bfd_get_outsymbols (abfd);
8830:   for (idx = 0; idx < symcount; idx++)
8831:     {
8832:       Elf_Internal_Sym sym;
8833: 
8834:       flagword flags = syms[idx]->flags;
8835:       if (!name_local_sections
8836:           && (flags & (BSF_SECTION_SYM | BSF_GLOBAL)) == BSF_SECTION_SYM)
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
8850: 
```

## bfd/elf.c:9052–9083

```text
9052:   /* Finalize the .strtab section.  */
9053:   _bfd_elf_strtab_finalize (stt);
9054: 
9055:   /* Swap out the .strtab section.  */
9056:   for (idx = 0; idx < outbound_syms_index; idx++)
9057:     {
9058:       struct elf_sym_strtab *elfsym = &symstrtab[idx];
9059:       if (elfsym->sym.st_name != 0)
9060:         elfsym->sym.st_name = _bfd_elf_strtab_offset (stt,
9061:                                                       elfsym->sym.st_name);
9062:       if (info && info->callbacks->ctf_new_symbol)
9063:         info->callbacks->ctf_new_symbol (elfsym->dest_index,
9064:                                          &elfsym->sym);
9065: 
9066:       /* Inform the linker of the addition of this symbol.  */
9067: 
9068:       bed->s->swap_symbol_out (abfd, &elfsym->sym,
9069:                                (outbound_syms
9070:                                 + (elfsym->dest_index
9071:                                    * bed->s->sizeof_sym)),
9072:                                NPTR_ADD (outbound_shndx,
9073:                                          (elfsym->dest_index
9074:                                           * sizeof (Elf_External_Sym_Shndx))));
9075:     }
9076:   free (symstrtab);
9077: 
9078:   *sttp = stt;
9079:   symstrtab_hdr->sh_size = _bfd_elf_strtab_size (stt);
9080:   symstrtab_hdr->sh_type = SHT_STRTAB;
9081:   symstrtab_hdr->sh_addralign = 1;
9082: 
9083:   return true;
```

## bfd/elf.c:13485–13527

```text
13485: _bfd_elf_final_write_processing (bfd *abfd)
13486: {
13487:   Elf_Internal_Ehdr *i_ehdrp = elf_elfheader (abfd);
13488:   elf_backend_data *bed = get_elf_backend_data (abfd);
13489: 
13490:   if (bed->osabi_exact && i_ehdrp->e_ident[EI_OSABI] == ELFOSABI_NONE)
13491:     i_ehdrp->e_ident[EI_OSABI] = bed->elf_osabi;
13492: 
13493:   if (i_ehdrp->e_ident[EI_OSABI] == ELFOSABI_SOLARIS
13494:       || bed->target_os == is_solaris)
13495:     {
13496:       elf_tdata (abfd)->strtab_hdr.sh_flags = SHF_STRINGS;
13497:       elf_tdata (abfd)->shstrtab_hdr.sh_flags = SHF_STRINGS;
13498:     }
13499: 
13500:   /* Set the osabi field to ELFOSABI_GNU if the binary contains
13501:      SHF_GNU_MBIND or SHF_GNU_RETAIN sections or symbols of STT_GNU_IFUNC type
13502:      or STB_GNU_UNIQUE binding.  */
13503:   if (elf_tdata (abfd)->has_gnu_osabi != 0)
13504:     {
13505:       if (i_ehdrp->e_ident[EI_OSABI] == ELFOSABI_NONE)
13506:         i_ehdrp->e_ident[EI_OSABI] = ELFOSABI_GNU;
13507:       else if (i_ehdrp->e_ident[EI_OSABI] != ELFOSABI_GNU
13508:                && i_ehdrp->e_ident[EI_OSABI] != ELFOSABI_FREEBSD)
13509:         {
13510:           if (elf_tdata (abfd)->has_gnu_osabi & elf_gnu_osabi_mbind)
13511:             _bfd_error_handler (_("GNU_MBIND section is supported only by GNU "
13512:                                   "and FreeBSD targets"));
13513:           if (elf_tdata (abfd)->has_gnu_osabi & elf_gnu_osabi_ifunc)
13514:             _bfd_error_handler (_("symbol type STT_GNU_IFUNC is supported "
13515:                                   "only by GNU and FreeBSD targets"));
13516:           if (elf_tdata (abfd)->has_gnu_osabi & elf_gnu_osabi_unique)
13517:             _bfd_error_handler (_("symbol binding STB_GNU_UNIQUE is supported "
13518:                                   "only by GNU and FreeBSD targets"));
13519:           if (elf_tdata (abfd)->has_gnu_osabi & elf_gnu_osabi_retain)
13520:             _bfd_error_handler (_("GNU_RETAIN section is supported "
13521:                                   "only by GNU and FreeBSD targets"));
13522:           bfd_set_error (bfd_error_sorry);
13523:           return false;
13524:         }
13525:     }
13526:   return true;
13527: }
```

## bfd/elfcode.h:129–136

```text
129: #if ARCH_SIZE == 64
130: #define ELF_R_INFO(X,Y) ELF64_R_INFO(X,Y)
131: #define ELF_R_SYM(X)    ELF64_R_SYM(X)
132: #define ELF_R_TYPE(X)   ELF64_R_TYPE(X)
133: #define ELFCLASS        ELFCLASS64
134: #define FILE_ALIGN      8
135: #define LOG_FILE_ALIGN  3
136: #endif
```

## bfd/elfcode.h:930–1083

```text
930: elf_write_relocs (bfd *abfd, asection *sec, void *data)
931: {
932:   elf_backend_data *bed = get_elf_backend_data (abfd);
933:   bool *failedp = (bool *) data;
934:   Elf_Internal_Shdr *rela_hdr;
935:   bfd_vma addr_offset;
936:   void (*swap_out) (bfd *, const Elf_Internal_Rela *, bfd_byte *);
937:   size_t extsize;
938:   bfd_byte *dst_rela;
939:   unsigned int idx;
940:   asymbol *last_sym;
941:   int last_sym_idx;
942:   size_t amt;
943: 
944:   /* If we have already failed, don't do anything.  */
945:   if (*failedp)
946:     return;
947: 
948:   if ((sec->flags & SEC_RELOC) == 0)
949:     return;
950: 
951:   /* The linker backend writes the relocs out itself, and sets the
952:      reloc_count field to zero to inhibit writing them here.  Also,
953:      sometimes the SEC_RELOC flag gets set even when there aren't any
954:      relocs.  */
955:   if (sec->reloc_count == 0)
956:     return;
957: 
958:   /* If we have opened an existing file for update, reloc_count may be
959:      set even though we are not linking.  In that case we have nothing
960:      to do.  */
961:   if (sec->orelocation == NULL)
962:     return;
963: 
964:   rela_hdr = elf_section_data (sec)->rela.hdr;
965:   if (rela_hdr == NULL)
966:     rela_hdr = elf_section_data (sec)->rel.hdr;
967: 
968:   rela_hdr->sh_size = rela_hdr->sh_entsize * sec->reloc_count;
969:   if (_bfd_mul_overflow (sec->reloc_count, rela_hdr->sh_entsize, &amt)
970:       || (rela_hdr->contents = bfd_alloc (abfd, amt)) == NULL)
971:     {
972:       bfd_set_error (bfd_error_no_memory);
973:       *failedp = true;
974:       return;
975:     }
976: 
977:   /* Figure out whether the relocations are RELA or REL relocations.  */
978:   if (rela_hdr->sh_type == SHT_RELA)
979:     {
980:       swap_out = elf_swap_reloca_out;
981:       extsize = sizeof (Elf_External_Rela);
982:     }
983:   else if (rela_hdr->sh_type == SHT_REL)
984:     {
985:       swap_out = elf_swap_reloc_out;
986:       extsize = sizeof (Elf_External_Rel);
987:     }
988:   else
989:     /* Every relocation section should be either an SHT_RELA or an
990:        SHT_REL section.  */
991:     abort ();
992: 
993:   /* The address of an ELF reloc is section relative for an object
994:      file, and absolute for an executable file or shared library.
995:      The address of a BFD reloc is always section relative.  */
996:   addr_offset = 0;
997:   if ((abfd->flags & (EXEC_P | DYNAMIC)) != 0)
998:     addr_offset = sec->vma;
999: 
1000:   /* orelocation has the data, reloc_count has the count...  */
1001:   last_sym = 0;
1002:   last_sym_idx = 0;
1003:   dst_rela = rela_hdr->contents;
1004: 
1005:   for (idx = 0; idx < sec->reloc_count; idx++, dst_rela += extsize)
1006:     {
1007:       Elf_Internal_Rela src_rela;
1008:       arelent *ptr;
1009:       asymbol *sym;
1010:       int n;
1011: 
1012:       ptr = sec->orelocation[idx];
1013:       sym = *ptr->sym_ptr_ptr;
1014:       if (sym == last_sym)
1015:         n = last_sym_idx;
1016:       /* If the relocation is against an absolute symbol whoes value is
1017:          zero, then the symbol can be dropped, simplifying the reloc.
1018:          PR 31106: Except for complex relocations where the symbols
1019:          itself might be significant.  */
1020:       else if (bfd_is_abs_section (sym->section)
1021:                && sym->value == 0
1022:                && (sym->flags & BSF_RELC) == 0)
1023:         n = STN_UNDEF;
1024:       else
1025:         {
1026:           last_sym = sym;
1027:           n = _bfd_elf_symbol_from_bfd_symbol (abfd, &sym);
1028:           if (n < 0)
1029:             {
1030:               *failedp = true;
1031:               return;
1032:             }
1033:           last_sym_idx = n;
1034:         }
1035: 
1036:       if ((*ptr->sym_ptr_ptr)->the_bfd != NULL
1037:           && (*ptr->sym_ptr_ptr)->the_bfd->xvec != abfd->xvec
1038:           && ! _bfd_elf_validate_reloc (abfd, ptr))
1039:         {
1040:           *failedp = true;
1041:           return;
1042:         }
1043: 
1044:       if (ptr->howto == NULL)
1045:         {
1046:           *failedp = true;
1047:           return;
1048:         }
1049: 
1050: #if defined(BFD64) && ARCH_SIZE == 32
1051:       if (rela_hdr->sh_type == SHT_RELA
1052:           && ptr->howto->bitsize > 32
1053:           && ptr->addend - INT32_MIN > UINT32_MAX)
1054:         {
1055:           _bfd_error_handler (_("%pB: %pA+%" PRIx64 ": "
1056:                                 "relocation addend %" PRIx64 " too large"),
1057:                               abfd, sec, (uint64_t) ptr->address,
1058:                               (uint64_t) ptr->addend);
1059:           *failedp = true;
1060:           bfd_set_error (bfd_error_bad_value);
1061:         }
1062: #endif
1063: 
1064:       src_rela.r_offset = ptr->address + addr_offset;
1065:       src_rela.r_info = ELF_R_INFO (n, ptr->howto->type);
1066:       src_rela.r_addend = ptr->addend;
1067:       (*swap_out) (abfd, &src_rela, dst_rela);
1068:     }
1069: 
1070:   if (elf_section_data (sec)->has_secondary_relocs
1071:       && !bed->write_secondary_relocs (abfd, sec))
1072:     {
1073:       *failedp = true;
1074:       return;
1075:     }
1076: }
1077: 
1078: /* Write out the program headers.  */
1079: 
1080: int
1081: elf_write_out_phdrs (bfd *abfd,
1082:                      const Elf_Internal_Phdr *phdr,
1083:                      unsigned int count)
```

## bfd/elfcode.h:1101–1167

```text
1101: elf_write_shdrs_and_ehdr (bfd *abfd)
1102: {
1103:   Elf_External_Ehdr x_ehdr;     /* Elf file header, external form */
1104:   Elf_Internal_Ehdr *i_ehdrp;   /* Elf file header, internal form */
1105:   Elf_External_Shdr *x_shdrp;   /* Section header table, external form */
1106:   Elf_Internal_Shdr **i_shdrp;  /* Section header table, internal form */
1107:   unsigned int count;
1108:   size_t amt;
1109: 
1110:   i_ehdrp = elf_elfheader (abfd);
1111:   i_shdrp = elf_elfsections (abfd);
1112: 
1113:   /* swap the header before spitting it out...  */
1114: 
1115: #if DEBUG & 1
1116:   elf_debug_file (i_ehdrp);
1117: #endif
1118:   elf_swap_ehdr_out (abfd, i_ehdrp, &x_ehdr);
1119:   amt = sizeof (x_ehdr);
1120:   if (bfd_seek (abfd, 0, SEEK_SET) != 0
1121:       || bfd_write (&x_ehdr, amt, abfd) != amt)
1122:     return false;
1123: 
1124:   if ((abfd->flags & BFD_NO_SECTION_HEADER) != 0)
1125:     return true;
1126: 
1127:   /* Some fields in the first section header handle overflow of ehdr
1128:      fields.  */
1129:   if (i_ehdrp->e_phnum >= PN_XNUM)
1130:     i_shdrp[0]->sh_info = i_ehdrp->e_phnum;
1131:   if (i_ehdrp->e_shnum >= (SHN_LORESERVE & 0xffff))
1132:     i_shdrp[0]->sh_size = i_ehdrp->e_shnum;
1133:   if (i_ehdrp->e_shstrndx >= (SHN_LORESERVE & 0xffff))
1134:     i_shdrp[0]->sh_link = i_ehdrp->e_shstrndx;
1135: 
1136:   /* at this point we've concocted all the ELF sections...  */
1137:   if (_bfd_mul_overflow (i_ehdrp->e_shnum, sizeof (*x_shdrp), &amt))
1138:     {
1139:       bfd_set_error (bfd_error_no_memory);
1140:       return false;
1141:     }
1142:   x_shdrp = (Elf_External_Shdr *) bfd_alloc (abfd, amt);
1143:   if (!x_shdrp)
1144:     return false;
1145: 
1146:   for (count = 0; count < i_ehdrp->e_shnum; i_shdrp++, count++)
1147:     {
1148: #if DEBUG & 2
1149:       elf_debug_section (count, *i_shdrp);
1150: #endif
1151:       elf_swap_shdr_out (abfd, *i_shdrp, x_shdrp + count);
1152:     }
1153:   amt = (bfd_size_type) i_ehdrp->e_shnum * sizeof (*x_shdrp);
1154:   if (bfd_seek (abfd, i_ehdrp->e_shoff, SEEK_SET) != 0
1155:       || bfd_write (x_shdrp, amt, abfd) != amt)
1156:     return false;
1157: 
1158:   /* need to dump the string table too...  */
1159: 
1160:   return true;
1161: }
1162: 
1163: bool
1164: elf_checksum_contents (bfd *abfd,
1165:                        void (*process) (const void *, size_t, void *),
1166:                        void *arg)
1167: {
```

## bfd/elfcode.h:2053–2070

```text
2053: const struct elf_size_info NAME(_bfd_elf,size_info) = {
2054:   sizeof (Elf_External_Ehdr),
2055:   sizeof (Elf_External_Phdr),
2056:   sizeof (Elf_External_Shdr),
2057:   sizeof (Elf_External_Rel),
2058:   sizeof (Elf_External_Rela),
2059:   sizeof (Elf_External_Sym),
2060:   sizeof (Elf_External_Dyn),
2061:   sizeof (Elf_External_Note),
2062:   4,
2063:   1,
2064:   ARCH_SIZE, LOG_FILE_ALIGN,
2065:   ELFCLASS, EV_CURRENT,
2066:   elf_write_out_phdrs,
2067:   elf_write_shdrs_and_ehdr,
2068:   elf_checksum_contents,
2069:   elf_write_relocs,
2070:   elf_swap_symbol_in,
```

## bfd/elf64-x86-64.c:6154–6163

```text
6154: static bool
6155: elf_x86_64_fake_sections (bfd *abfd ATTRIBUTE_UNUSED,
6156:                           Elf_Internal_Shdr *hdr, asection *sec)
6157: {
6158:   if (sec->flags & SEC_ELF_LARGE)
6159:     hdr->sh_flags |= SHF_X86_64_LARGE;
6160: 
6161:   return true;
6162: }
6163: 
```

## bfd/elf64-x86-64.c:6348–6420

```text
6348: #define elf_backend_want_got_plt            1
6349: #define elf_backend_plt_readonly            1
6350: #define elf_backend_want_plt_sym            0
6351: #define elf_backend_got_header_size         (GOT_ENTRY_SIZE*3)
6352: #define elf_backend_rela_normal             1
6353: #define elf_backend_plt_alignment           4
6354: #define elf_backend_caches_rawsize          1
6355: #define elf_backend_dtrel_excludes_plt      1
6356: #define elf_backend_want_dynrelro           1
6357: 
6358: #define elf_info_to_howto                   elf_x86_64_info_to_howto
6359: 
6360: #define bfd_elf64_bfd_copy_private_section_data \
6361:   elf_x86_64_copy_private_section_data
6362: #define bfd_elf64_bfd_reloc_type_lookup     elf_x86_64_reloc_type_lookup
6363: #define bfd_elf64_bfd_reloc_name_lookup \
6364:   elf_x86_64_reloc_name_lookup
6365: 
6366: #define elf_backend_relocs_compatible       elf_x86_64_relocs_compatible
6367: #define elf_backend_early_size_sections     elf_x86_64_early_size_sections
6368: #define elf_backend_create_dynamic_sections _bfd_elf_create_dynamic_sections
6369: #define elf_backend_finish_dynamic_sections elf_x86_64_finish_dynamic_sections
6370: #define elf_backend_finish_dynamic_symbol   elf_x86_64_finish_dynamic_symbol
6371: #define elf_backend_output_arch_local_syms  elf_x86_64_output_arch_local_syms
6372: #define elf_backend_grok_prstatus           elf_x86_64_grok_prstatus
6373: #define elf_backend_grok_psinfo             elf_x86_64_grok_psinfo
6374: #ifdef CORE_HEADER
6375: #define elf_backend_write_core_note         elf_x86_64_write_core_note
6376: #endif
6377: #define elf_backend_reloc_type_class        elf_x86_64_reloc_type_class
6378: #define elf_backend_relocate_section        elf_x86_64_relocate_section
6379: #define elf_backend_init_index_section      _bfd_elf_init_1_index_section
6380: #define elf_backend_object_p                elf64_x86_64_elf_object_p
6381: #define bfd_elf64_get_synthetic_symtab      elf_x86_64_get_synthetic_symtab
6382: 
6383: #define elf_backend_section_from_shdr \
6384:         elf_x86_64_section_from_shdr
6385: 
6386: #define elf_backend_section_from_bfd_section \
6387:   elf_x86_64_elf_section_from_bfd_section
6388: #define elf_backend_add_symbol_hook \
6389:   elf_x86_64_add_symbol_hook
6390: #define elf_backend_symbol_processing \
6391:   elf_x86_64_symbol_processing
6392: #define elf_backend_common_section_index \
6393:   elf_x86_64_common_section_index
6394: #define elf_backend_common_section \
6395:   elf_x86_64_common_section
6396: #define elf_backend_common_definition \
6397:   elf_x86_64_common_definition
6398: #define elf_backend_merge_symbol \
6399:   elf_x86_64_merge_symbol
6400: #define elf_backend_special_sections \
6401:   elf_x86_64_special_sections
6402: #define elf_backend_section_flags           elf_x86_64_section_flags
6403: #define elf_backend_fake_sections           elf_x86_64_fake_sections
6404: #define elf_backend_additional_program_headers \
6405:   elf_x86_64_additional_program_headers
6406: #define elf_backend_setup_gnu_properties \
6407:   elf_x86_64_link_setup_gnu_properties
6408: #define elf_backend_hide_symbol \
6409:   _bfd_x86_elf_hide_symbol
6410: #define elf_backend_add_glibc_version_dependency \
6411:   elf_x86_64_add_glibc_version_dependency
6412: 
6413: #undef  elf64_bed
6414: #define elf64_bed elf64_x86_64_bed
6415: 
6416: #include "elf64-target.h"
6417: 
6418: #undef elf_backend_add_glibc_version_dependency
6419: 
6420: /* FreeBSD support.  */
```

## bfd/elfxx-target.h:431–437

```text
431: #ifndef elf_backend_name_local_section_symbols
432: #define elf_backend_name_local_section_symbols  0
433: #endif
434: #ifndef elf_backend_section_processing
435: #define elf_backend_section_processing  0
436: #endif
437: #ifndef elf_backend_section_from_shdr
```

## bfd/elfxx-target.h:509–514

```text
509: #ifndef elf_backend_begin_write_processing
510: #define elf_backend_begin_write_processing      0
511: #endif
512: #ifndef elf_backend_final_write_processing
513: #define elf_backend_final_write_processing      _bfd_elf_final_write_processing
514: #endif
```

## bfd/elf-bfd.h:598–602

```text
598: struct elf_sym_strtab
599: {
600:   Elf_Internal_Sym sym;
601:   unsigned long dest_index;
602: };
```

## include/elf/external.h:69–84

```text
69: typedef struct {
70:   unsigned char e_ident[16];            /* ELF "magic number" */
71:   unsigned char e_type[2];              /* Identifies object file type */
72:   unsigned char e_machine[2];           /* Specifies required architecture */
73:   unsigned char e_version[4];           /* Identifies object file version */
74:   unsigned char e_entry[8];             /* Entry point virtual address */
75:   unsigned char e_phoff[8];             /* Program header table file offset */
76:   unsigned char e_shoff[8];             /* Section header table file offset */
77:   unsigned char e_flags[4];             /* Processor-specific flags */
78:   unsigned char e_ehsize[2];            /* ELF header size in bytes */
79:   unsigned char e_phentsize[2];         /* Program header table entry size */
80:   unsigned char e_phnum[2];             /* Program header table entry count */
81:   unsigned char e_shentsize[2];         /* Section header table entry size */
82:   unsigned char e_shnum[2];             /* Section header table entry count */
83:   unsigned char e_shstrndx[2];          /* Section header string table index */
84: } Elf64_External_Ehdr;
```

## include/elf/external.h:124–136

```text
124: 
125: typedef struct {
126:   unsigned char sh_name[4];             /* Section name, index in string tbl */
127:   unsigned char sh_type[4];             /* Type of section */
128:   unsigned char sh_flags[8];            /* Miscellaneous section attributes */
129:   unsigned char sh_addr[8];             /* Section virtual addr at execution */
130:   unsigned char sh_offset[8];           /* Section file offset */
131:   unsigned char sh_size[8];             /* Size of section in bytes */
132:   unsigned char sh_link[4];             /* Index of another section */
133:   unsigned char sh_info[4];             /* Additional section information */
134:   unsigned char sh_addralign[8];        /* Section alignment */
135:   unsigned char sh_entsize[8];          /* Entry size if section holds table */
136: } Elf64_External_Shdr;
```

## include/elf/external.h:163–171

```text
163: 
164: typedef struct {
165:   unsigned char st_name[4];             /* Symbol name, index in string tbl */
166:   unsigned char st_info[1];             /* Type and binding attributes */
167:   unsigned char st_other[1];            /* No defined meaning, 0 */
168:   unsigned char st_shndx[2];            /* Associated section index */
169:   unsigned char st_value[8];            /* Value of the symbol */
170:   unsigned char st_size[8];             /* Associated symbol size */
171: } Elf64_External_Sym;
```

## include/elf/external.h:222–227

```text
222: 
223: typedef struct {
224:   unsigned char r_offset[8];    /* Location at which to apply the action */
225:   unsigned char r_info[8];      /* index and type of relocation */
226:   unsigned char r_addend[8];    /* Constant addend used to compute value */
227: } Elf64_External_Rela;
```

## include/elf/internal.h:100–120

```text
100: /* Section header */
101: 
102: typedef struct elf_internal_shdr {
103:   unsigned int  sh_name;                /* Section name, index in string tbl */
104:   unsigned int  sh_type;                /* Type of section */
105:   bfd_vma       sh_flags;               /* Miscellaneous section attributes */
106:   bfd_vma       sh_addr;                /* Section virtual addr at execution in
107:                                            octets.  */
108:   file_ptr      sh_offset;              /* Section file offset in octets.  */
109:   bfd_size_type sh_size;                /* Size of section in octets.  */
110:   unsigned int  sh_link;                /* Index of another section */
111:   unsigned int  sh_info;                /* Additional section information */
112:   bfd_vma       sh_addralign;           /* Section alignment */
113:   bfd_size_type sh_entsize;             /* Entry size if section holds table */
114: 
115:   /* The internal rep also has some cached info associated with it. */
116:   asection *    bfd_section;            /* Associated BFD section.  */
117:   unsigned char *contents;              /* Section contents.  */
118: } Elf_Internal_Shdr;
119: 
120: /* Compression header */
```
