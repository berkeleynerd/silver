# Pinned CFG cleanup, loop and initial SSA source excerpts

Full-file SHA256 identities are in source-manifest.json.
LF line numbering; tabs expanded and trailing space trimmed.

## gcc/tree-cfg.cc:326–347

```text
326:
327: static unsigned int
328: execute_build_cfg (void)
329: {
330:   gimple_seq body = gimple_body (current_function_decl);
331:
332:   build_gimple_cfg (body);
333:   gimple_set_body (current_function_decl, NULL);
334:   if (dump_file && (dump_flags & TDF_DETAILS))
335:     {
336:       fprintf (dump_file, "Scope blocks:\n");
337:       dump_scope_blocks (dump_file, dump_flags);
338:     }
339:   cleanup_tree_cfg ();
340:
341:   bb_to_omp_idx.release ();
342:
343:   loop_optimizer_init (AVOID_CFG_MODIFICATIONS);
344:   replace_loop_annotate ();
345:   return 0;
346: }
347:
```

## gcc/tree-cfg.cc:1230–1323

```text
1230: edge_to_cases_cleanup (edge const &, tree const &value, void *)
1231: {
1232:   tree t, next;
1233:
1234:   for (t = value; t; t = next)
1235:     {
1236:       next = CASE_CHAIN (t);
1237:       CASE_CHAIN (t) = NULL;
1238:     }
1239:
1240:   return true;
1241: }
1242:
1243: /* Start recording information mapping edges to case labels.  */
1244:
1245: void
1246: start_recording_case_labels (void)
1247: {
1248:   gcc_assert (edge_to_cases == NULL);
1249:   edge_to_cases = new hash_map<edge, tree>;
1250:   touched_switch_bbs = BITMAP_ALLOC (NULL);
1251: }
1252:
1253: /* Return nonzero if we are recording information for case labels.  */
1254:
1255: static bool
1256: recording_case_labels_p (void)
1257: {
1258:   return (edge_to_cases != NULL);
1259: }
1260:
1261: /* Stop recording information mapping edges to case labels and
1262:    remove any information we have recorded.  */
1263: void
1264: end_recording_case_labels (void)
1265: {
1266:   bitmap_iterator bi;
1267:   unsigned i;
1268:   edge_to_cases->traverse<void *, edge_to_cases_cleanup> (NULL);
1269:   delete edge_to_cases;
1270:   edge_to_cases = NULL;
1271:   EXECUTE_IF_SET_IN_BITMAP (touched_switch_bbs, 0, i, bi)
1272:     {
1273:       basic_block bb = BASIC_BLOCK_FOR_FN (cfun, i);
1274:       if (bb)
1275:         {
1276:           if (gswitch *stmt = safe_dyn_cast <gswitch *> (*gsi_last_bb (bb)))
1277:             group_case_labels_stmt (stmt);
1278:         }
1279:     }
1280:   BITMAP_FREE (touched_switch_bbs);
1281: }
1282:
1283: /* If we are inside a {start,end}_recording_cases block, then return
1284:    a chain of CASE_LABEL_EXPRs from T which reference E.
1285:
1286:    Otherwise return NULL.  */
1287:
1288: tree
1289: get_cases_for_edge (edge e, gswitch *t)
1290: {
1291:   tree *slot;
1292:   size_t i, n;
1293:
1294:   /* If we are not recording cases, then we do not have CASE_LABEL_EXPR
1295:      chains available.  Return NULL so the caller can detect this case.  */
1296:   if (!recording_case_labels_p ())
1297:     return NULL;
1298:
1299:   slot = edge_to_cases->get (e);
1300:   if (slot)
1301:     return *slot;
1302:
1303:   /* If we did not find E in the hash table, then this must be the first
1304:      time we have been queried for information about E & T.  Add all the
1305:      elements from T to the hash table then perform the query again.  */
1306:
1307:   n = gimple_switch_num_labels (t);
1308:   for (i = 0; i < n; i++)
1309:     {
1310:       tree elt = gimple_switch_label (t, i);
1311:       tree lab = CASE_LABEL (elt);
1312:       basic_block label_bb = label_to_block (cfun, lab);
1313:       edge this_edge = find_edge (e->src, label_bb);
1314:
1315:       /* Add it to the chain of CASE_LABEL_EXPRs referencing E, or create
1316:          a new chain.  */
1317:       tree &s = edge_to_cases->get_or_insert (this_edge);
1318:       CASE_CHAIN (elt) = s;
1319:       s = elt;
1320:     }
1321:
1322:   return *edge_to_cases->get (e);
1323: }
```

## gcc/tree-cfg.cc:1710–1852

```text
1710: group_case_labels_stmt (gswitch *stmt)
1711: {
1712:   int old_size = gimple_switch_num_labels (stmt);
1713:   int i, next_index, new_size;
1714:   basic_block default_bb = NULL;
1715:   hash_set<tree> *removed_labels = NULL;
1716:
1717:   default_bb = gimple_switch_default_bb (cfun, stmt);
1718:
1719:   /* Look for possible opportunities to merge cases.  */
1720:   new_size = i = 1;
1721:   while (i < old_size)
1722:     {
1723:       tree base_case, base_high;
1724:       basic_block base_bb;
1725:
1726:       base_case = gimple_switch_label (stmt, i);
1727:
1728:       gcc_assert (base_case);
1729:       base_bb = label_to_block (cfun, CASE_LABEL (base_case));
1730:
1731:       /* Discard cases that have the same destination as the default case or
1732:          whose destination blocks have already been removed as unreachable.  */
1733:       if (base_bb == NULL
1734:           || base_bb == default_bb
1735:           || (removed_labels
1736:               && removed_labels->contains (CASE_LABEL (base_case))))
1737:         {
1738:           i++;
1739:           continue;
1740:         }
1741:
1742:       base_high = CASE_HIGH (base_case)
1743:           ? CASE_HIGH (base_case)
1744:           : CASE_LOW (base_case);
1745:       next_index = i + 1;
1746:
1747:       /* Try to merge case labels.  Break out when we reach the end
1748:          of the label vector or when we cannot merge the next case
1749:          label with the current one.  */
1750:       while (next_index < old_size)
1751:         {
1752:           tree merge_case = gimple_switch_label (stmt, next_index);
1753:           basic_block merge_bb = label_to_block (cfun, CASE_LABEL (merge_case));
1754:           wide_int bhp1 = wi::to_wide (base_high) + 1;
1755:
1756:           /* Merge the cases if they jump to the same place,
1757:              and their ranges are consecutive.  */
1758:           if (merge_bb == base_bb
1759:               && (removed_labels == NULL
1760:                   || !removed_labels->contains (CASE_LABEL (merge_case)))
1761:               && wi::to_wide (CASE_LOW (merge_case)) == bhp1)
1762:             {
1763:               base_high
1764:                 = (CASE_HIGH (merge_case)
1765:                    ? CASE_HIGH (merge_case) : CASE_LOW (merge_case));
1766:               CASE_HIGH (base_case) = base_high;
1767:               next_index++;
1768:             }
1769:           else
1770:             break;
1771:         }
1772:
1773:       /* Discard cases that have an unreachable destination block.  */
1774:       if (EDGE_COUNT (base_bb->succs) == 0
1775:           && gimple_seq_unreachable_p (bb_seq (base_bb))
1776:           /* Don't optimize this if __builtin_unreachable () is the
1777:              implicitly added one by the C++ FE too early, before
1778:              -Wreturn-type can be diagnosed.  We'll optimize it later
1779:              during switchconv pass or any other cfg cleanup.  */
1780:           && (gimple_in_ssa_p (cfun)
1781:               || (LOCATION_LOCUS (gimple_location (last_nondebug_stmt (base_bb)))
1782:                   != BUILTINS_LOCATION)))
1783:         {
1784:           edge base_edge = find_edge (gimple_bb (stmt), base_bb);
1785:           if (base_edge != NULL)
1786:             {
1787:               for (gimple_stmt_iterator gsi = gsi_start_bb (base_bb);
1788:                    !gsi_end_p (gsi); gsi_next (&gsi))
1789:                 if (glabel *stmt = dyn_cast <glabel *> (gsi_stmt (gsi)))
1790:                   {
1791:                     if (FORCED_LABEL (gimple_label_label (stmt))
1792:                         || DECL_NONLOCAL (gimple_label_label (stmt)))
1793:                       {
1794:                         /* Forced/non-local labels aren't going to be removed,
1795:                            but they will be moved to some neighbouring basic
1796:                            block. If some later case label refers to one of
1797:                            those labels, we should throw that case away rather
1798:                            than keeping it around and referring to some random
1799:                            other basic block without an edge to it.  */
1800:                         if (removed_labels == NULL)
1801:                           removed_labels = new hash_set<tree>;
1802:                         removed_labels->add (gimple_label_label (stmt));
1803:                       }
1804:                   }
1805:                 else
1806:                   break;
1807:               remove_edge_and_dominated_blocks (base_edge);
1808:             }
1809:           i = next_index;
1810:           continue;
1811:         }
1812:
1813:       if (new_size < i)
1814:         gimple_switch_set_label (stmt, new_size,
1815:                                  gimple_switch_label (stmt, i));
1816:       i = next_index;
1817:       new_size++;
1818:     }
1819:
1820:   gcc_assert (new_size <= old_size);
1821:
1822:   if (new_size < old_size)
1823:     gimple_switch_set_num_labels (stmt, new_size);
1824:
1825:   delete removed_labels;
1826:   return new_size < old_size;
1827: }
1828:
1829: /* Look for blocks ending in a multiway branch (a GIMPLE_SWITCH),
1830:    and scan the sorted vector of cases.  Combine the ones jumping to the
1831:    same label.  */
1832:
1833: bool
1834: group_case_labels (void)
1835: {
1836:   basic_block bb;
1837:   bool changed = false;
1838:
1839:   FOR_EACH_BB_FN (bb, cfun)
1840:     {
1841:       if (gswitch *stmt = safe_dyn_cast <gswitch *> (*gsi_last_bb (bb)))
1842:         changed |= group_case_labels_stmt (stmt);
1843:     }
1844:
1845:   return changed;
1846: }
1847:
1848: /* Checks whether we can merge block B into block A.  */
1849:
1850: static bool
1851: gimple_can_merge_blocks_p (basic_block a, basic_block b)
1852: {
```

## gcc/tree-cfg.cc:1853–1935

```text
1853:   gimple *stmt;
1854:
1855:   if (!single_succ_p (a))
1856:     return false;
1857:
1858:   if (single_succ_edge (a)->flags & EDGE_COMPLEX)
1859:     return false;
1860:
1861:   if (single_succ (a) != b)
1862:     return false;
1863:
1864:   if (!single_pred_p (b))
1865:     return false;
1866:
1867:   if (a == ENTRY_BLOCK_PTR_FOR_FN (cfun)
1868:       || b == EXIT_BLOCK_PTR_FOR_FN (cfun))
1869:     return false;
1870:
1871:   /* If A ends by a statement causing exceptions or something similar, we
1872:      cannot merge the blocks.  */
1873:   stmt = *gsi_last_bb (a);
1874:   if (stmt && stmt_ends_bb_p (stmt))
1875:     return false;
1876:
1877:   /* Examine the labels at the beginning of B.  */
1878:   for (gimple_stmt_iterator gsi = gsi_start_bb (b); !gsi_end_p (gsi);
1879:        gsi_next (&gsi))
1880:     {
1881:       tree lab;
1882:       glabel *label_stmt = dyn_cast <glabel *> (gsi_stmt (gsi));
1883:       if (!label_stmt)
1884:         break;
1885:       lab = gimple_label_label (label_stmt);
1886:
1887:       /* Do not remove user forced labels or for -O0 any user labels.  */
1888:       if (!DECL_ARTIFICIAL (lab) && (!optimize || FORCED_LABEL (lab)))
1889:         return false;
1890:     }
1891:
1892:   /* Protect simple loop latches.  We only want to avoid merging
1893:      the latch with the loop header or with a block in another
1894:      loop in this case.  */
1895:   if (current_loops
1896:       && b->loop_father->latch == b
1897:       && loops_state_satisfies_p (LOOPS_HAVE_SIMPLE_LATCHES)
1898:       && (b->loop_father->header == a
1899:           || b->loop_father != a->loop_father))
1900:     return false;
1901:
1902:   /* It must be possible to eliminate all phi nodes in B.  If ssa form
1903:      is not up-to-date and a name-mapping is registered, we cannot eliminate
1904:      any phis.  Symbols marked for renaming are never a problem though.  */
1905:   for (gphi_iterator gsi = gsi_start_phis (b); !gsi_end_p (gsi);
1906:        gsi_next (&gsi))
1907:     {
1908:       gphi *phi = gsi.phi ();
1909:       /* Technically only new names matter.  */
1910:       if (name_registered_for_update_p (PHI_RESULT (phi)))
1911:         return false;
1912:     }
1913:
1914:   /* When not optimizing, don't merge if we'd lose goto_locus.  */
1915:   if (!optimize
1916:       && single_succ_edge (a)->goto_locus != UNKNOWN_LOCATION)
1917:     {
1918:       location_t goto_locus = single_succ_edge (a)->goto_locus;
1919:       gimple_stmt_iterator prev, next;
1920:       prev = gsi_last_nondebug_bb (a);
1921:       next = gsi_after_labels (b);
1922:       if (!gsi_end_p (next) && is_gimple_debug (gsi_stmt (next)))
1923:         gsi_next_nondebug (&next);
1924:       if ((gsi_end_p (prev)
1925:            || gimple_location (gsi_stmt (prev)) != goto_locus)
1926:           && (gsi_end_p (next)
1927:               || gimple_location (gsi_stmt (next)) != goto_locus))
1928:         return false;
1929:     }
1930:
1931:   return true;
1932: }
1933:
1934: /* Replaces all uses of NAME by VAL.  */
1935:
```

## gcc/tree-cfg.cc:2017–2160

```text
2017: gimple_merge_blocks (basic_block a, basic_block b)
2018: {
2019:   gimple_stmt_iterator last, gsi;
2020:   gphi_iterator psi;
2021:
2022:   if (dump_file)
2023:     fprintf (dump_file, "Merging blocks %d and %d\n", a->index, b->index);
2024:
2025:   /* Remove all single-valued PHI nodes from block B of the form
2026:      V_i = PHI <V_j> by propagating V_j to all the uses of V_i.  */
2027:   gsi = gsi_last_bb (a);
2028:   for (psi = gsi_start_phis (b); !gsi_end_p (psi); )
2029:     {
2030:       gimple *phi = gsi_stmt (psi);
2031:       tree def = gimple_phi_result (phi), use = gimple_phi_arg_def (phi, 0);
2032:       gimple *copy;
2033:       bool may_replace_uses = (virtual_operand_p (def)
2034:                                || may_propagate_copy (def, use));
2035:
2036:       /* In case we maintain loop closed ssa form, do not propagate arguments
2037:          of loop exit phi nodes.  */
2038:       if (current_loops
2039:           && loops_state_satisfies_p (LOOP_CLOSED_SSA)
2040:           && !virtual_operand_p (def)
2041:           && TREE_CODE (use) == SSA_NAME
2042:           && a->loop_father != b->loop_father)
2043:         may_replace_uses = false;
2044:
2045:       if (!may_replace_uses)
2046:         {
2047:           gcc_assert (!virtual_operand_p (def));
2048:
2049:           /* Note that just emitting the copies is fine -- there is no problem
2050:              with ordering of phi nodes.  This is because A is the single
2051:              predecessor of B, therefore results of the phi nodes cannot
2052:              appear as arguments of the phi nodes.  */
2053:           copy = gimple_build_assign (def, use);
2054:           gsi_insert_after (&gsi, copy, GSI_NEW_STMT);
2055:           remove_phi_node (&psi, false);
2056:         }
2057:       else
2058:         {
2059:           /* If we deal with a PHI for virtual operands, we can simply
2060:              propagate these without fussing with folding or updating
2061:              the stmt.  */
2062:           if (virtual_operand_p (def))
2063:             {
2064:               imm_use_iterator iter;
2065:               use_operand_p use_p;
2066:               gimple *stmt;
2067:
2068:               FOR_EACH_IMM_USE_STMT (stmt, iter, def)
2069:                 FOR_EACH_IMM_USE_ON_STMT (use_p, iter)
2070:                   SET_USE (use_p, use);
2071:
2072:               if (SSA_NAME_OCCURS_IN_ABNORMAL_PHI (def))
2073:                 SSA_NAME_OCCURS_IN_ABNORMAL_PHI (use) = 1;
2074:             }
2075:           else
2076:             replace_uses_by (def, use);
2077:
2078:           remove_phi_node (&psi, true);
2079:         }
2080:     }
2081:
2082:   /* Ensure that B follows A.  */
2083:   move_block_after (b, a);
2084:
2085:   gcc_assert (single_succ_edge (a)->flags & EDGE_FALLTHRU);
2086:   gcc_assert (!*gsi_last_bb (a)
2087:               || !stmt_ends_bb_p (*gsi_last_bb (a)));
2088:
2089:   /* Remove labels from B and set gimple_bb to A for other statements.  */
2090:   for (gsi = gsi_start_bb (b); !gsi_end_p (gsi);)
2091:     {
2092:       gimple *stmt = gsi_stmt (gsi);
2093:       if (glabel *label_stmt = dyn_cast <glabel *> (stmt))
2094:         {
2095:           tree label = gimple_label_label (label_stmt);
2096:           int lp_nr;
2097:
2098:           gsi_remove (&gsi, false);
2099:
2100:           /* Now that we can thread computed gotos, we might have
2101:              a situation where we have a forced label in block B
2102:              However, the label at the start of block B might still be
2103:              used in other ways (think about the runtime checking for
2104:              Fortran assigned gotos).  So we cannot just delete the
2105:              label.  Instead we move the label to the start of block A.  */
2106:           if (FORCED_LABEL (label))
2107:             {
2108:               gimple_stmt_iterator dest_gsi = gsi_start_bb (a);
2109:               tree first_label = NULL_TREE;
2110:               if (!gsi_end_p (dest_gsi))
2111:                 if (glabel *first_label_stmt
2112:                     = dyn_cast <glabel *> (gsi_stmt (dest_gsi)))
2113:                   first_label = gimple_label_label (first_label_stmt);
2114:               if (first_label
2115:                   && (DECL_NONLOCAL (first_label)
2116:                       || EH_LANDING_PAD_NR (first_label) != 0))
2117:                 gsi_insert_after (&dest_gsi, stmt, GSI_NEW_STMT);
2118:               else
2119:                 gsi_insert_before (&dest_gsi, stmt, GSI_NEW_STMT);
2120:             }
2121:           /* Other user labels keep around in a form of a debug stmt.  */
2122:           else if (!DECL_ARTIFICIAL (label) && MAY_HAVE_DEBUG_BIND_STMTS)
2123:             {
2124:               gimple *dbg = gimple_build_debug_bind (label,
2125:                                                      integer_zero_node,
2126:                                                      stmt);
2127:               gimple_debug_bind_reset_value (dbg);
2128:               gsi_insert_before (&gsi, dbg, GSI_SAME_STMT);
2129:             }
2130:
2131:           lp_nr = EH_LANDING_PAD_NR (label);
2132:           if (lp_nr)
2133:             {
2134:               eh_landing_pad lp = get_eh_landing_pad_from_number (lp_nr);
2135:               lp->post_landing_pad = NULL;
2136:             }
2137:         }
2138:       else
2139:         {
2140:           gimple_set_bb (stmt, a);
2141:           gsi_next (&gsi);
2142:         }
2143:     }
2144:
2145:   /* When merging two BBs, if their counts are different, the larger count
2146:      is selected as the new bb count. This is to handle inconsistent
2147:      profiles.  */
2148:   if (a->loop_father == b->loop_father)
2149:     {
2150:       a->count = a->count.merge (b->count);
2151:     }
2152:
2153:   /* Merge the sequences.  */
2154:   last = gsi_last_bb (a);
2155:   gsi_insert_seq_after (&last, bb_seq (b), GSI_NEW_STMT);
2156:   set_bb_seq (b, NULL);
2157:
2158:   if (cfgcleanup_altered_bbs)
2159:     bitmap_set_bit (cfgcleanup_altered_bbs, a->index);
2160: }
```

## gcc/tree-cfg.cc:6057–6081

```text
6057: gimple_block_label (basic_block bb)
6058: {
6059:   gimple_stmt_iterator i, s = gsi_start_bb (bb);
6060:   bool first = true;
6061:   tree label;
6062:   glabel *stmt;
6063:
6064:   for (i = s; !gsi_end_p (i); first = false, gsi_next (&i))
6065:     {
6066:       stmt = dyn_cast <glabel *> (gsi_stmt (i));
6067:       if (!stmt)
6068:         break;
6069:       label = gimple_label_label (stmt);
6070:       if (!DECL_NONLOCAL (label))
6071:         {
6072:           if (!first)
6073:             gsi_move_before (&i, &s);
6074:           return label;
6075:         }
6076:     }
6077:
6078:   label = create_artificial_label (UNKNOWN_LOCATION);
6079:   stmt = gimple_build_label (label);
6080:   gsi_insert_before (&s, stmt, GSI_NEW_STMT);
6081:   return label;
```

## gcc/tree-cfg.cc:6083–6278

```text
6083:
6084:
6085: /* Attempt to perform edge redirection by replacing a possibly complex
6086:    jump instruction by a goto or by removing the jump completely.
6087:    This can apply only if all edges now point to the same block.  The
6088:    parameters and return values are equivalent to
6089:    redirect_edge_and_branch.  */
6090:
6091: static edge
6092: gimple_try_redirect_by_replacing_jump (edge e, basic_block target)
6093: {
6094:   basic_block src = e->src;
6095:   gimple_stmt_iterator i;
6096:   gimple *stmt;
6097:
6098:   /* We can replace or remove a complex jump only when we have exactly
6099:      two edges.  */
6100:   if (EDGE_COUNT (src->succs) != 2
6101:       /* Verify that all targets will be TARGET.  Specifically, the
6102:          edge that is not E must also go to TARGET.  */
6103:       || EDGE_SUCC (src, EDGE_SUCC (src, 0) == e)->dest != target)
6104:     return NULL;
6105:
6106:   i = gsi_last_bb (src);
6107:   if (gsi_end_p (i))
6108:     return NULL;
6109:
6110:   stmt = gsi_stmt (i);
6111:
6112:   if (gimple_code (stmt) == GIMPLE_COND || gimple_code (stmt) == GIMPLE_SWITCH)
6113:     {
6114:       gsi_remove (&i, true);
6115:       e = ssa_redirect_edge (e, target);
6116:       e->flags = EDGE_FALLTHRU;
6117:       return e;
6118:     }
6119:
6120:   return NULL;
6121: }
6122:
6123:
6124: /* Redirect E to DEST.  Return NULL on failure.  Otherwise, return the
6125:    edge representing the redirected branch.  */
6126:
6127: static edge
6128: gimple_redirect_edge_and_branch (edge e, basic_block dest)
6129: {
6130:   basic_block bb = e->src;
6131:   gimple_stmt_iterator gsi;
6132:   edge ret;
6133:   gimple *stmt;
6134:
6135:   if (e->flags & EDGE_ABNORMAL)
6136:     return NULL;
6137:
6138:   if (e->dest == dest)
6139:     return NULL;
6140:
6141:   if (e->flags & EDGE_EH)
6142:     return redirect_eh_edge (e, dest);
6143:
6144:   if (e->src != ENTRY_BLOCK_PTR_FOR_FN (cfun))
6145:     {
6146:       ret = gimple_try_redirect_by_replacing_jump (e, dest);
6147:       if (ret)
6148:         return ret;
6149:     }
6150:
6151:   gsi = gsi_last_nondebug_bb (bb);
6152:   stmt = gsi_end_p (gsi) ? NULL : gsi_stmt (gsi);
6153:
6154:   switch (stmt ? gimple_code (stmt) : GIMPLE_ERROR_MARK)
6155:     {
6156:     case GIMPLE_COND:
6157:       /* For COND_EXPR, we only need to redirect the edge.  */
6158:       break;
6159:
6160:     case GIMPLE_GOTO:
6161:       /* No non-abnormal edges should lead from a non-simple goto, and
6162:          simple ones should be represented implicitly.  */
6163:       gcc_unreachable ();
6164:
6165:     case GIMPLE_SWITCH:
6166:       {
6167:         gswitch *switch_stmt = as_a <gswitch *> (stmt);
6168:         tree label = gimple_block_label (dest);
6169:         tree cases = get_cases_for_edge (e, switch_stmt);
6170:
6171:         /* If we have a list of cases associated with E, then use it
6172:            as it's a lot faster than walking the entire case vector.  */
6173:         if (cases)
6174:           {
6175:             edge e2 = find_edge (e->src, dest);
6176:             tree last, first;
6177:
6178:             first = cases;
6179:             while (cases)
6180:               {
6181:                 last = cases;
6182:                 CASE_LABEL (cases) = label;
6183:                 cases = CASE_CHAIN (cases);
6184:               }
6185:
6186:             /* If there was already an edge in the CFG, then we need
6187:                to move all the cases associated with E to E2.  */
6188:             if (e2)
6189:               {
6190:                 tree cases2 = get_cases_for_edge (e2, switch_stmt);
6191:
6192:                 CASE_CHAIN (last) = CASE_CHAIN (cases2);
6193:                 CASE_CHAIN (cases2) = first;
6194:               }
6195:             bitmap_set_bit (touched_switch_bbs, gimple_bb (stmt)->index);
6196:           }
6197:         else
6198:           {
6199:             size_t i, n = gimple_switch_num_labels (switch_stmt);
6200:
6201:             for (i = 0; i < n; i++)
6202:               {
6203:                 tree elt = gimple_switch_label (switch_stmt, i);
6204:                 if (label_to_block (cfun, CASE_LABEL (elt)) == e->dest)
6205:                   CASE_LABEL (elt) = label;
6206:               }
6207:           }
6208:       }
6209:       break;
6210:
6211:     case GIMPLE_ASM:
6212:       {
6213:         gasm *asm_stmt = as_a <gasm *> (stmt);
6214:         int i, n = gimple_asm_nlabels (asm_stmt);
6215:         tree label = NULL;
6216:
6217:         for (i = 0; i < n; ++i)
6218:           {
6219:             tree cons = gimple_asm_label_op (asm_stmt, i);
6220:             if (label_to_block (cfun, TREE_VALUE (cons)) == e->dest)
6221:               {
6222:                 if (!label)
6223:                   label = gimple_block_label (dest);
6224:                 TREE_VALUE (cons) = label;
6225:               }
6226:           }
6227:
6228:         /* If we didn't find any label matching the former edge in the
6229:            asm labels, we must be redirecting the fallthrough
6230:            edge.  */
6231:         gcc_assert (label || (e->flags & EDGE_FALLTHRU));
6232:       }
6233:       break;
6234:
6235:     case GIMPLE_RETURN:
6236:       gsi_remove (&gsi, true);
6237:       e->flags |= EDGE_FALLTHRU;
6238:       break;
6239:
6240:     case GIMPLE_OMP_RETURN:
6241:     case GIMPLE_OMP_CONTINUE:
6242:     case GIMPLE_OMP_SECTIONS_SWITCH:
6243:     case GIMPLE_OMP_FOR:
6244:       /* The edges from OMP constructs can be simply redirected.  */
6245:       break;
6246:
6247:     case GIMPLE_EH_DISPATCH:
6248:       if (!(e->flags & EDGE_FALLTHRU))
6249:         redirect_eh_dispatch_edge (as_a <geh_dispatch *> (stmt), e, dest);
6250:       break;
6251:
6252:     case GIMPLE_TRANSACTION:
6253:       if (e->flags & EDGE_TM_ABORT)
6254:         gimple_transaction_set_label_over (as_a <gtransaction *> (stmt),
6255:                                            gimple_block_label (dest));
6256:       else if (e->flags & EDGE_TM_UNINSTRUMENTED)
6257:         gimple_transaction_set_label_uninst (as_a <gtransaction *> (stmt),
6258:                                              gimple_block_label (dest));
6259:       else
6260:         gimple_transaction_set_label_norm (as_a <gtransaction *> (stmt),
6261:                                            gimple_block_label (dest));
6262:       break;
6263:
6264:     default:
6265:       /* Otherwise it must be a fallthru edge, and we don't need to
6266:          do anything besides redirecting it.  */
6267:       gcc_assert (e->flags & EDGE_FALLTHRU);
6268:       break;
6269:     }
6270:
6271:   /* Update/insert PHI nodes as necessary.  */
6272:
6273:   /* Now update the edges in the CFG.  */
6274:   e = ssa_redirect_edge (e, dest);
6275:
6276:   return e;
6277: }
6278:
```

## gcc/tree-cfg.cc:6293–6349

```text
6293: static basic_block
6294: gimple_redirect_edge_and_branch_force (edge e, basic_block dest)
6295: {
6296:   e = gimple_redirect_edge_and_branch (e, dest);
6297:   gcc_assert (e);
6298:
6299:   return NULL;
6300: }
6301:
6302:
6303: /* Splits basic block BB after statement STMT (but at least after the
6304:    labels).  If STMT is NULL, BB is split just after the labels.  */
6305:
6306: static basic_block
6307: gimple_split_block (basic_block bb, void *stmt)
6308: {
6309:   gimple_stmt_iterator gsi;
6310:   gimple_stmt_iterator gsi_tgt;
6311:   gimple_seq list;
6312:   basic_block new_bb;
6313:   edge e;
6314:   edge_iterator ei;
6315:
6316:   new_bb = create_empty_bb (bb);
6317:
6318:   /* Redirect the outgoing edges.  */
6319:   new_bb->succs = bb->succs;
6320:   bb->succs = NULL;
6321:   FOR_EACH_EDGE (e, ei, new_bb->succs)
6322:     e->src = new_bb;
6323:
6324:   /* Get a stmt iterator pointing to the first stmt to move.  */
6325:   if (!stmt || gimple_code ((gimple *) stmt) == GIMPLE_LABEL)
6326:     gsi = gsi_after_labels (bb);
6327:   else
6328:     {
6329:       gsi = gsi_for_stmt ((gimple *) stmt);
6330:       gsi_next (&gsi);
6331:     }
6332:
6333:   /* Move everything from GSI to the new basic block.  */
6334:   if (gsi_end_p (gsi))
6335:     return new_bb;
6336:
6337:   /* Split the statement list - avoid re-creating new containers as this
6338:      brings ugly quadratic memory consumption in the inliner.
6339:      (We are still quadratic since we need to update stmt BB pointers,
6340:      sadly.)  */
6341:   gsi_split_seq_before (&gsi, &list);
6342:   set_bb_seq (new_bb, list);
6343:   for (gsi_tgt = gsi_start (list);
6344:        !gsi_end_p (gsi_tgt); gsi_next (&gsi_tgt))
6345:     gimple_set_bb (gsi_stmt (gsi_tgt), new_bb);
6346:
6347:   return new_bb;
6348: }
6349:
```

## gcc/tree-cfg.cc:8983–9123

```text
8983: remove_edge_and_dominated_blocks (edge e)
8984: {
8985:   vec<basic_block> bbs_to_fix_dom = vNULL;
8986:   edge f;
8987:   edge_iterator ei;
8988:   bool none_removed = false;
8989:   unsigned i;
8990:   basic_block bb, dbb;
8991:   bitmap_iterator bi;
8992:
8993:   /* If we are removing a path inside a non-root loop that may change
8994:      loop ownership of blocks or remove loops.  Mark loops for fixup.  */
8995:   class loop *src_loop = e->src->loop_father;
8996:   if (current_loops
8997:       && loop_outer (src_loop) != NULL
8998:       && src_loop == e->dest->loop_father)
8999:     {
9000:       loops_state_set (LOOPS_NEED_FIXUP);
9001:       /* If we are removing a backedge clear the number of iterations
9002:          and estimates.  */
9003:       class loop *dest_loop = e->dest->loop_father;
9004:       if (e->dest == src_loop->header
9005:           || (e->dest == dest_loop->header
9006:               && flow_loop_nested_p (dest_loop, src_loop)))
9007:         {
9008:           free_numbers_of_iterations_estimates (dest_loop);
9009:           /* If we removed the last backedge mark the loop for removal.  */
9010:           FOR_EACH_EDGE (f, ei, dest_loop->header->preds)
9011:             if (f != e
9012:                 && (f->src->loop_father == dest_loop
9013:                     || flow_loop_nested_p (dest_loop, f->src->loop_father)))
9014:               break;
9015:           if (!f)
9016:             mark_loop_for_removal (dest_loop);
9017:         }
9018:     }
9019:
9020:   if (!dom_info_available_p (CDI_DOMINATORS))
9021:     {
9022:       remove_edge (e);
9023:       return;
9024:     }
9025:
9026:   /* No updating is needed for edges to exit.  */
9027:   if (e->dest == EXIT_BLOCK_PTR_FOR_FN (cfun))
9028:     {
9029:       if (cfgcleanup_altered_bbs)
9030:         bitmap_set_bit (cfgcleanup_altered_bbs, e->src->index);
9031:       remove_edge (e);
9032:       return;
9033:     }
9034:
9035:   /* First, we find the basic blocks to remove.  If E->dest has a predecessor
9036:      that is not dominated by E->dest, then this set is empty.  Otherwise,
9037:      all the basic blocks dominated by E->dest are removed.
9038:
9039:      Also, to DF_IDOM we store the immediate dominators of the blocks in
9040:      the dominance frontier of E (i.e., of the successors of the
9041:      removed blocks, if there are any, and of E->dest otherwise).  */
9042:   FOR_EACH_EDGE (f, ei, e->dest->preds)
9043:     {
9044:       if (f == e)
9045:         continue;
9046:
9047:       if (!dominated_by_p (CDI_DOMINATORS, f->src, e->dest))
9048:         {
9049:           none_removed = true;
9050:           break;
9051:         }
9052:     }
9053:
9054:   auto_bitmap df, df_idom;
9055:   auto_vec<basic_block> bbs_to_remove;
9056:   if (none_removed)
9057:     bitmap_set_bit (df_idom,
9058:                     get_immediate_dominator (CDI_DOMINATORS, e->dest)->index);
9059:   else
9060:     {
9061:       bbs_to_remove = get_all_dominated_blocks (CDI_DOMINATORS, e->dest);
9062:       FOR_EACH_VEC_ELT (bbs_to_remove, i, bb)
9063:         {
9064:           FOR_EACH_EDGE (f, ei, bb->succs)
9065:             {
9066:               if (f->dest != EXIT_BLOCK_PTR_FOR_FN (cfun))
9067:                 bitmap_set_bit (df, f->dest->index);
9068:             }
9069:         }
9070:       FOR_EACH_VEC_ELT (bbs_to_remove, i, bb)
9071:         bitmap_clear_bit (df, bb->index);
9072:
9073:       EXECUTE_IF_SET_IN_BITMAP (df, 0, i, bi)
9074:         {
9075:           bb = BASIC_BLOCK_FOR_FN (cfun, i);
9076:           bitmap_set_bit (df_idom,
9077:                           get_immediate_dominator (CDI_DOMINATORS, bb)->index);
9078:         }
9079:     }
9080:
9081:   if (cfgcleanup_altered_bbs)
9082:     {
9083:       /* Record the set of the altered basic blocks.  */
9084:       bitmap_set_bit (cfgcleanup_altered_bbs, e->src->index);
9085:       bitmap_ior_into (cfgcleanup_altered_bbs, df);
9086:     }
9087:
9088:   /* Remove E and the cancelled blocks.  */
9089:   if (none_removed)
9090:     remove_edge (e);
9091:   else
9092:     {
9093:       /* Walk backwards so as to get a chance to substitute all
9094:          released DEFs into debug stmts.  See
9095:          eliminate_unnecessary_stmts() in tree-ssa-dce.cc for more
9096:          details.  */
9097:       for (i = bbs_to_remove.length (); i-- > 0; )
9098:         delete_basic_block (bbs_to_remove[i]);
9099:     }
9100:
9101:   /* Update the dominance information.  The immediate dominator may change only
9102:      for blocks whose immediate dominator belongs to DF_IDOM:
9103:
9104:      Suppose that idom(X) = Y before removal of E and idom(X) != Y after the
9105:      removal.  Let Z the arbitrary block such that idom(Z) = Y and
9106:      Z dominates X after the removal.  Before removal, there exists a path P
9107:      from Y to X that avoids Z.  Let F be the last edge on P that is
9108:      removed, and let W = F->dest.  Before removal, idom(W) = Y (since Y
9109:      dominates W, and because of P, Z does not dominate W), and W belongs to
9110:      the dominance frontier of E.  Therefore, Y belongs to DF_IDOM.  */
9111:   EXECUTE_IF_SET_IN_BITMAP (df_idom, 0, i, bi)
9112:     {
9113:       bb = BASIC_BLOCK_FOR_FN (cfun, i);
9114:       for (dbb = first_dom_son (CDI_DOMINATORS, bb);
9115:            dbb;
9116:            dbb = next_dom_son (CDI_DOMINATORS, dbb))
9117:         bbs_to_fix_dom.safe_push (dbb);
9118:     }
9119:
9120:   iterate_fix_dominators (CDI_DOMINATORS, bbs_to_fix_dom, true);
9121:
9122:   bbs_to_fix_dom.release ();
9123: }
```

## gcc/tree-cfg.cc:9636–9653

```text
9636: void
9637: generate_range_test (basic_block bb, tree index, tree low, tree high,
9638:                      tree *lhs, tree *rhs)
9639: {
9640:   tree type = TREE_TYPE (index);
9641:   tree utype = range_check_type (type);
9642:
9643:   low = fold_convert (utype, low);
9644:   high = fold_convert (utype, high);
9645:
9646:   gimple_seq seq = NULL;
9647:   index = gimple_convert (&seq, utype, index);
9648:   *lhs = gimple_build (&seq, MINUS_EXPR, utype, index, low);
9649:   *rhs = const_binop (MINUS_EXPR, utype, high, low);
9650:
9651:   gimple_stmt_iterator gsi = gsi_last_bb (bb);
9652:   gsi_insert_seq_before (&gsi, seq, GSI_SAME_STMT);
9653: }
```

## gcc/tree-cfg.cc:9972–10144

```text
9972: static bool
9973: maybe_remove_writeonly_store (gimple_stmt_iterator &gsi, gimple *stmt,
9974:                               bitmap dce_ssa_names)
9975: {
9976:   /* Keep access when store has side effect, i.e. in case when source
9977:      is volatile.  */
9978:   if (!gimple_store_p (stmt)
9979:       || gimple_has_side_effects (stmt)
9980:       || optimize_debug)
9981:     return false;
9982:
9983:   tree lhs = get_base_address (gimple_get_lhs (stmt));
9984:
9985:   if (!VAR_P (lhs)
9986:       || (!TREE_STATIC (lhs) && !DECL_EXTERNAL (lhs))
9987:       || !varpool_node::get (lhs)->writeonly)
9988:     return false;
9989:
9990:   if (dump_file && (dump_flags & TDF_DETAILS))
9991:     {
9992:       fprintf (dump_file, "Removing statement, writes"
9993:                " to write only var:\n");
9994:       print_gimple_stmt (dump_file, stmt, 0,
9995:                          TDF_VOPS|TDF_MEMSYMS);
9996:     }
9997:
9998:   /* Mark ssa name defining to be checked for simple dce. */
9999:   if (gimple_assign_single_p (stmt))
10000:     {
10001:       tree rhs = gimple_assign_rhs1 (stmt);
10002:       if (TREE_CODE (rhs) == SSA_NAME
10003:           && !SSA_NAME_IS_DEFAULT_DEF (rhs))
10004:         bitmap_set_bit (dce_ssa_names, SSA_NAME_VERSION (rhs));
10005:     }
10006:   unlink_stmt_vdef (stmt);
10007:   gsi_remove (&gsi, true);
10008:   release_defs (stmt);
10009:   return true;
10010: }
10011:
10012: /* IPA passes, compilation of earlier functions or inlining
10013:    might have changed some properties, such as marked functions nothrow,
10014:    pure, const or noreturn.
10015:    Remove redundant edges and basic blocks, and create new ones if necessary. */
10016:
10017: unsigned int
10018: execute_fixup_cfg (void)
10019: {
10020:   basic_block bb;
10021:   gimple_stmt_iterator gsi;
10022:   int todo = 0;
10023:   cgraph_node *node = cgraph_node::get (current_function_decl);
10024:   /* Same scaling is also done by ipa_merge_profiles.  */
10025:   profile_count num = node->count;
10026:   profile_count den = ENTRY_BLOCK_PTR_FOR_FN (cfun)->count;
10027:   bool scale = num.initialized_p () && !(num == den);
10028:   auto_bitmap dce_ssa_names;
10029:
10030:   if (scale)
10031:     {
10032:       profile_count::adjust_for_ipa_scaling (&num, &den);
10033:       ENTRY_BLOCK_PTR_FOR_FN (cfun)->count = node->count;
10034:       EXIT_BLOCK_PTR_FOR_FN (cfun)->count
10035:         = EXIT_BLOCK_PTR_FOR_FN (cfun)->count.apply_scale (num, den);
10036:     }
10037:
10038:   FOR_EACH_BB_FN (bb, cfun)
10039:     {
10040:       if (scale)
10041:         bb->count = bb->count.apply_scale (num, den);
10042:       for (gsi = gsi_start_bb (bb); !gsi_end_p (gsi);)
10043:         {
10044:           gimple *stmt = gsi_stmt (gsi);
10045:           tree decl = is_gimple_call (stmt)
10046:                       ? gimple_call_fndecl (stmt)
10047:                       : NULL;
10048:           if (decl)
10049:             {
10050:               int flags = gimple_call_flags (stmt);
10051:               if (flags & (ECF_CONST | ECF_PURE | ECF_LOOPING_CONST_OR_PURE))
10052:                 {
10053:                   if (gimple_in_ssa_p (cfun))
10054:                     {
10055:                       todo |= TODO_update_ssa | TODO_cleanup_cfg;
10056:                       update_stmt (stmt);
10057:                     }
10058:                 }
10059:               if (flags & ECF_NORETURN
10060:                   && fixup_noreturn_call (stmt))
10061:                 todo |= TODO_cleanup_cfg;
10062:              }
10063:
10064:           /* Remove stores to variables we marked write-only. */
10065:           if (maybe_remove_writeonly_store (gsi, stmt, dce_ssa_names))
10066:             {
10067:               todo |= TODO_update_ssa | TODO_cleanup_cfg;
10068:               continue;
10069:             }
10070:
10071:           /* For calls we can simply remove LHS when it is known
10072:              to be write-only.  */
10073:           if (is_gimple_call (stmt)
10074:               && gimple_get_lhs (stmt))
10075:             {
10076:               tree lhs = get_base_address (gimple_get_lhs (stmt));
10077:
10078:               if (VAR_P (lhs)
10079:                   && (TREE_STATIC (lhs) || DECL_EXTERNAL (lhs))
10080:                   && varpool_node::get (lhs)->writeonly)
10081:                 {
10082:                   gimple_call_set_lhs (stmt, NULL);
10083:                   update_stmt (stmt);
10084:                   todo |= TODO_update_ssa | TODO_cleanup_cfg;
10085:                 }
10086:             }
10087:
10088:           gsi_next (&gsi);
10089:         }
10090:       if (gimple *last = *gsi_last_bb (bb))
10091:         {
10092:           if (maybe_clean_eh_stmt (last)
10093:               && gimple_purge_dead_eh_edges (bb))
10094:             todo |= TODO_cleanup_cfg;
10095:           if (gimple_purge_dead_abnormal_call_edges (bb))
10096:             todo |= TODO_cleanup_cfg;
10097:         }
10098:
10099:       /* If we have a basic block with no successors that does not
10100:          end with a control statement or a noreturn call end it with
10101:          a call to __builtin_unreachable.  This situation can occur
10102:          when inlining a noreturn call that does in fact return.  */
10103:       if (EDGE_COUNT (bb->succs) == 0)
10104:         {
10105:           gimple *stmt = last_nondebug_stmt (bb);
10106:           if (!stmt
10107:               || (!is_ctrl_stmt (stmt)
10108:                   && (!is_gimple_call (stmt)
10109:                       || !gimple_call_noreturn_p (stmt))))
10110:             {
10111:               if (stmt && is_gimple_call (stmt))
10112:                 gimple_call_set_ctrl_altering (stmt, false);
10113:               stmt = gimple_build_builtin_unreachable (UNKNOWN_LOCATION);
10114:               gimple_stmt_iterator gsi = gsi_last_bb (bb);
10115:               gsi_insert_after (&gsi, stmt, GSI_NEW_STMT);
10116:               if (!cfun->after_inlining)
10117:                 if (tree fndecl = gimple_call_fndecl (stmt))
10118:                   {
10119:                     gcall *call_stmt = dyn_cast <gcall *> (stmt);
10120:                     node->create_edge (cgraph_node::get_create (fndecl),
10121:                                        call_stmt, bb->count);
10122:                   }
10123:             }
10124:         }
10125:     }
10126:   if (scale)
10127:     {
10128:       update_max_bb_count ();
10129:       compute_function_frequency ();
10130:     }
10131:
10132:   if (current_loops
10133:       && (todo & TODO_cleanup_cfg))
10134:     loops_state_set (LOOPS_NEED_FIXUP);
10135:
10136:   simple_dce_from_worklist (dce_ssa_names);
10137:
10138:   return todo;
10139: }
10140:
10141: namespace {
10142:
10143: const pass_data pass_data_fixup_cfg =
10144: {
```

## gcc/tree-cfgcleanup.cc:85–254

```text
85: static bool
86: convert_single_case_switch (gswitch *swtch, gimple_stmt_iterator &gsi)
87: {
88:   if (gimple_switch_num_labels (swtch) != 2)
89:     return false;
90:
91:   tree index = gimple_switch_index (swtch);
92:   tree label = gimple_switch_label (swtch, 1);
93:   tree low = CASE_LOW (label);
94:   tree high = CASE_HIGH (label);
95:
96:   basic_block default_bb = gimple_switch_default_bb (cfun, swtch);
97:   basic_block case_bb = label_to_block (cfun, CASE_LABEL (label));
98:
99:   basic_block bb = gimple_bb (swtch);
100:   gcond *cond;
101:
102:   /* Replace switch statement with condition statement.  */
103:   if (high)
104:     {
105:       tree lhs, rhs;
106:       if (range_check_type (TREE_TYPE (index)) == NULL_TREE)
107:         return false;
108:       generate_range_test (bb, index, low, high, &lhs, &rhs);
109:       cond = gimple_build_cond (LE_EXPR, lhs, rhs, NULL_TREE, NULL_TREE);
110:     }
111:   else
112:     cond = gimple_build_cond (EQ_EXPR, index,
113:                               fold_convert (TREE_TYPE (index), low),
114:                               NULL_TREE, NULL_TREE);
115:
116:   gsi_replace (&gsi, cond, true);
117:
118:   /* Update edges.  */
119:   edge case_edge = find_edge (bb, case_bb);
120:   edge default_edge = find_edge (bb, default_bb);
121:
122:   case_edge->flags |= EDGE_TRUE_VALUE;
123:   default_edge->flags |= EDGE_FALSE_VALUE;
124:   return true;
125: }
126:
127: /* Canonicalize _Bool == 0 and _Bool != 1 to _Bool != 0 of STMT in BB by
128:    swapping edges of the BB.  */
129: bool
130: canonicalize_bool_cond (gcond *stmt, basic_block bb)
131: {
132:   tree rhs1 = gimple_cond_lhs (stmt);
133:   tree rhs2 = gimple_cond_rhs (stmt);
134:   enum tree_code code = gimple_cond_code (stmt);
135:   if (code != EQ_EXPR && code != NE_EXPR)
136:     return false;
137:   if (TREE_CODE (TREE_TYPE (rhs1)) != BOOLEAN_TYPE
138:       && (!INTEGRAL_TYPE_P (TREE_TYPE (rhs1))
139:            || TYPE_PRECISION (TREE_TYPE (rhs1)) != 1))
140:     return false;
141:
142:   /* Canonicalize _Bool == 0 and _Bool != 1 to _Bool != 0 by swapping edges.  */
143:   if (code == EQ_EXPR && !integer_zerop (rhs2))
144:     return false;
145:   if (code == NE_EXPR && !integer_onep (rhs2))
146:     return false;
147:
148:   gimple_cond_set_code (stmt, NE_EXPR);
149:   gimple_cond_set_rhs (stmt, build_zero_cst (TREE_TYPE (rhs1)));
150:   EDGE_SUCC (bb, 0)->flags ^= (EDGE_TRUE_VALUE|EDGE_FALSE_VALUE);
151:   EDGE_SUCC (bb, 1)->flags ^= (EDGE_TRUE_VALUE|EDGE_FALSE_VALUE);
152:
153:   if (dump_file)
154:     {
155:       fprintf (dump_file, "  Swapped '");
156:       print_gimple_expr (dump_file, stmt, 0);
157:       fprintf (dump_file, "'\n");
158:     }
159:   return true;
160: }
161:
162: /* Disconnect an unreachable block in the control expression starting
163:    at block BB.  */
164:
165: static bool
166: cleanup_control_expr_graph (basic_block bb, gimple_stmt_iterator gsi)
167: {
168:   edge taken_edge;
169:   bool retval = false;
170:   gimple *stmt = gsi_stmt (gsi);
171:
172:   if (!single_succ_p (bb))
173:     {
174:       edge e;
175:       edge_iterator ei;
176:       bool warned;
177:       tree val = NULL_TREE;
178:
179:       /* Try to convert a switch with just a single non-default case to
180:          GIMPLE condition.  */
181:       if (gimple_code (stmt) == GIMPLE_SWITCH
182:           && convert_single_case_switch (as_a<gswitch *> (stmt), gsi))
183:         stmt = gsi_stmt (gsi);
184:
185:       if (gimple_code (stmt) == GIMPLE_COND)
186:         canonicalize_bool_cond (as_a<gcond*> (stmt), bb);
187:
188:       fold_defer_overflow_warnings ();
189:       switch (gimple_code (stmt))
190:         {
191:         case GIMPLE_COND:
192:           {
193:             gimple_match_op res_op;
194:             if (gimple_simplify (stmt, &res_op, NULL, no_follow_ssa_edges,
195:                                  no_follow_ssa_edges)
196:                 && res_op.code == INTEGER_CST)
197:               val = res_op.ops[0];
198:           }
199:           break;
200:
201:         case GIMPLE_SWITCH:
202:           val = gimple_switch_index (as_a <gswitch *> (stmt));
203:           break;
204:
205:         default:
206:           ;
207:         }
208:       taken_edge = find_taken_edge (bb, val);
209:       if (!taken_edge)
210:         {
211:           fold_undefer_and_ignore_overflow_warnings ();
212:           return false;
213:         }
214:
215:       /* Remove all the edges except the one that is always executed.  */
216:       warned = false;
217:       for (ei = ei_start (bb->succs); (e = ei_safe_edge (ei)); )
218:         {
219:           if (e != taken_edge)
220:             {
221:               if (!warned)
222:                 {
223:                   fold_undefer_overflow_warnings
224:                     (true, stmt, WARN_STRICT_OVERFLOW_CONDITIONAL);
225:                   warned = true;
226:                 }
227:
228:               taken_edge->probability += e->probability;
229:               remove_edge_and_dominated_blocks (e);
230:               retval = true;
231:             }
232:           else
233:             ei_next (&ei);
234:         }
235:       if (!warned)
236:         fold_undefer_and_ignore_overflow_warnings ();
237:     }
238:   else
239:     taken_edge = single_succ_edge (bb);
240:
241:   bitmap_set_bit (cfgcleanup_altered_bbs, bb->index);
242:   gsi_remove (&gsi, true);
243:   taken_edge->flags = EDGE_FALLTHRU;
244:
245:   return retval;
246: }
247:
248: /* Cleanup the GF_CALL_CTRL_ALTERING flag according to
249:    to updated gimple_call_flags.  */
250:
251: static void
252: cleanup_call_ctrl_altering_flag (basic_block bb, gimple *bb_end)
253: {
254:   if (!is_gimple_call (bb_end)
```

## gcc/tree-cfgcleanup.cc:292–387

```text
292: cleanup_control_flow_bb (basic_block bb)
293: {
294:   gimple_stmt_iterator gsi;
295:   bool retval = false;
296:   gimple *stmt;
297:
298:   /* If the last statement of the block could throw and now cannot,
299:      we need to prune cfg.  */
300:   retval |= gimple_purge_dead_eh_edges (bb);
301:
302:   gsi = gsi_last_nondebug_bb (bb);
303:   if (gsi_end_p (gsi))
304:     return retval;
305:
306:   stmt = gsi_stmt (gsi);
307:
308:   /* Try to cleanup ctrl altering flag for call which ends bb.  */
309:   cleanup_call_ctrl_altering_flag (bb, stmt);
310:
311:   if (gimple_code (stmt) == GIMPLE_COND
312:       || gimple_code (stmt) == GIMPLE_SWITCH)
313:     {
314:       gcc_checking_assert (gsi_stmt (gsi_last_bb (bb)) == stmt);
315:       retval |= cleanup_control_expr_graph (bb, gsi);
316:     }
317:   else if (gimple_code (stmt) == GIMPLE_GOTO
318:            && TREE_CODE (gimple_goto_dest (stmt)) == ADDR_EXPR
319:            && (TREE_CODE (TREE_OPERAND (gimple_goto_dest (stmt), 0))
320:                == LABEL_DECL))
321:     {
322:       /* If we had a computed goto which has a compile-time determinable
323:          destination, then we can eliminate the goto.  */
324:       edge e;
325:       tree label;
326:       edge_iterator ei;
327:       basic_block target_block;
328:
329:       gcc_checking_assert (gsi_stmt (gsi_last_bb (bb)) == stmt);
330:       /* First look at all the outgoing edges.  Delete any outgoing
331:          edges which do not go to the right block.  For the one
332:          edge which goes to the right block, fix up its flags.  */
333:       label = TREE_OPERAND (gimple_goto_dest (stmt), 0);
334:       if (DECL_CONTEXT (label) != cfun->decl)
335:         return retval;
336:       target_block = label_to_block (cfun, label);
337:       for (ei = ei_start (bb->succs); (e = ei_safe_edge (ei)); )
338:         {
339:           if (e->dest != target_block)
340:             remove_edge_and_dominated_blocks (e);
341:           else
342:             {
343:               /* Turn off the EDGE_ABNORMAL flag.  */
344:               e->flags &= ~EDGE_ABNORMAL;
345:
346:               /* And set EDGE_FALLTHRU.  */
347:               e->flags |= EDGE_FALLTHRU;
348:               ei_next (&ei);
349:             }
350:         }
351:
352:       bitmap_set_bit (cfgcleanup_altered_bbs, bb->index);
353:       bitmap_set_bit (cfgcleanup_altered_bbs, target_block->index);
354:
355:       /* Remove the GOTO_EXPR as it is not needed.  The CFG has all the
356:          relevant information we need.  */
357:       gsi_remove (&gsi, true);
358:       retval = true;
359:     }
360:
361:   /* Check for indirect calls that have been turned into
362:      noreturn calls.  */
363:   else if (is_gimple_call (stmt)
364:            && gimple_call_noreturn_p (stmt))
365:     {
366:       /* If there are debug stmts after the noreturn call, remove them
367:          now, they should be all unreachable anyway.  */
368:       for (gsi_next (&gsi); !gsi_end_p (gsi); )
369:         gsi_remove (&gsi, true);
370:       if (remove_fallthru_edge (bb->succs))
371:         retval = true;
372:       tree lhs = gimple_call_lhs (stmt);
373:       if (!lhs
374:           || !should_remove_lhs_p (lhs))
375:         gimple_call_set_ctrl_altering (stmt, true);
376:     }
377:
378:   return retval;
379: }
380:
381: /* If all the PHI nodes in DEST have alternatives for E1 and E2 and
382:    those alternatives are equal in each of the PHI nodes, then return
383:    true, else return false.  */
384:
385: bool
386: phi_alternatives_equal (basic_block dest, edge e1, edge e2)
387: {
```

## gcc/tree-cfgcleanup.cc:476–780

```text
476: maybe_remove_forwarder_block (basic_block bb, bool can_split = false)
477: {
478:   gimple_stmt_iterator gsi;
479:   location_t locus;
480:
481:   /* BB must have a single outgoing edge.  */
482:   if (!single_succ_p (bb)
483:       /* BB may not be a predecessor of the exit block.  */
484:       || single_succ (bb) == EXIT_BLOCK_PTR_FOR_FN (cfun)
485:       /* Nor should this be an infinite loop.  */
486:       || single_succ (bb) == bb
487:       /* BB may not have an abnormal outgoing edge.  */
488:       || (single_succ_edge (bb)->flags & EDGE_ABNORMAL))
489:     return false;
490:
491:   gcc_checking_assert (bb != ENTRY_BLOCK_PTR_FOR_FN (cfun));
492:
493:   locus = single_succ_edge (bb)->goto_locus;
494:
495:   /* There should not be an edge coming from entry, or an EH edge.  */
496:   {
497:     edge_iterator ei;
498:     edge e;
499:
500:     FOR_EACH_EDGE (e, ei, bb->preds)
501:       if (e->src == ENTRY_BLOCK_PTR_FOR_FN (cfun) || (e->flags & EDGE_EH))
502:         return false;
503:       /* If goto_locus of any of the edges differs, prevent removing
504:          the forwarder block when not optimizing.  */
505:       else if (!optimize
506:                && (LOCATION_LOCUS (e->goto_locus) != UNKNOWN_LOCATION
507:                    || LOCATION_LOCUS (locus) != UNKNOWN_LOCATION)
508:                && e->goto_locus != locus)
509:         return false;
510:   }
511:
512:   /* If this bb has a single predecessor and that predecssor
513:      has a single successor, this bb will be merged with the
514:      predecessor so ignore it for removing of the forwarder block. */
515:   if (single_pred_p (bb)
516:       && single_succ_p (single_pred_edge (bb)->src))
517:     return false;
518:
519:   bool has_phi = !gimple_seq_empty_p (phi_nodes (bb));
520:   basic_block dest = single_succ_edge (bb)->dest;
521:
522:   /* If the destination block consists of a nonlocal label or is a
523:      EH landing pad, do not merge it.  */
524:   if (glabel *label_stmt = safe_dyn_cast <glabel *> (first_stmt (dest)))
525:     if (DECL_NONLOCAL (gimple_label_label (label_stmt))
526:         || EH_LANDING_PAD_NR (gimple_label_label (label_stmt)))
527:     return false;
528:
529:   /* If there is an abnormal edge to basic block BB, but not into
530:      dest, problems might occur during removal of the phi node at out
531:      of ssa due to overlapping live ranges of registers.
532:
533:      If there is an abnormal edge in DEST, the problems would occur
534:      anyway since cleanup_dead_labels would then merge the labels for
535:      two different eh regions, and rest of exception handling code
536:      does not like it.
537:
538:      So if there is an abnormal edge to BB, proceed only if there is
539:      no abnormal edge to DEST and there are no phi nodes in DEST.
540:      If the BB has phi, we don't want to deal with abnormal edges either. */
541:   if (bb_has_abnormal_pred (bb)
542:       && (bb_has_abnormal_pred (dest)
543:           || !gimple_seq_empty_p (phi_nodes (dest))
544:           || has_phi))
545:     return false;
546:
547:   /* When we have a phi, we have to feed into another
548:      basic block with PHI nodes.  */
549:   if (has_phi && gimple_seq_empty_p (phi_nodes (dest)))
550:     return false;
551:
552:   /* Now walk through the statements backward.  We can ignore labels,
553:      anything else means this is not a forwarder block.  */
554:   for (gsi = gsi_last_bb (bb); !gsi_end_p (gsi); gsi_prev (&gsi))
555:     {
556:       gimple *stmt = gsi_stmt (gsi);
557:
558:       switch (gimple_code (stmt))
559:         {
560:         case GIMPLE_LABEL:
561:           if (DECL_NONLOCAL (gimple_label_label (as_a <glabel *> (stmt)))
562:               || EH_LANDING_PAD_NR (gimple_label_label (as_a <glabel *> (stmt))))
563:             return false;
564:           if (!optimize
565:               && (gimple_has_location (stmt)
566:                   || LOCATION_LOCUS (locus) != UNKNOWN_LOCATION)
567:               && gimple_location (stmt) != locus)
568:             return false;
569:           break;
570:
571:           /* ??? For now, hope there's a corresponding debug
572:              assignment at the destination.  */
573:         case GIMPLE_DEBUG:
574:           break;
575:
576:         default:
577:           return false;
578:         }
579:     }
580:   /* If BB has PHIs and does not dominate DEST,
581:      then the PHI nodes at DEST must be the only
582:      users of the results of the PHI nodes at BB.
583:      So only check when BB dominates dest.  */
584:   if (has_phi
585:       && dominated_by_p (CDI_DOMINATORS, dest, bb))
586:     {
587:       gphi_iterator gsi;
588:       unsigned int dest_idx = single_succ_edge (bb)->dest_idx;
589:
590:       /* BB dominates DEST.  There may be many users of the PHI
591:          nodes in BB.  However, there is still a trivial case we
592:          can handle.  If the result of every PHI in BB is used
593:          only by a PHI in DEST, then we can trivially merge the
594:          PHI nodes from BB into DEST.  */
595:       for (gsi = gsi_start_phis (bb); !gsi_end_p (gsi);
596:            gsi_next (&gsi))
597:         {
598:           gphi *phi = gsi.phi ();
599:           tree result = gimple_phi_result (phi);
600:           use_operand_p imm_use;
601:           gimple *use_stmt;
602:
603:           /* If the PHI's result is never used, then we can just
604:              ignore it an.  */
605:           if (has_zero_uses (result))
606:             continue;
607:
608:           /* Get the single use of the result of this PHI node.  */
609:           if (!single_imm_use (result, &imm_use, &use_stmt)
610:               || gimple_code (use_stmt) != GIMPLE_PHI
611:               || gimple_bb (use_stmt) != dest
612:               || gimple_phi_arg_def (use_stmt, dest_idx) != result)
613:             return false;
614:         }
615:     }
616:
617:   if (current_loops)
618:     {
619:       /* Protect loop headers.  */
620:       if (bb_loop_header_p (bb))
621:         return false;
622:
623:       /* Protect loop preheaders and latches if requested.  */
624:       if (dest->loop_father->header == dest)
625:         {
626:           if (bb->loop_father == dest->loop_father)
627:             {
628:               if (loops_state_satisfies_p (LOOPS_HAVE_SIMPLE_LATCHES))
629:                 return false;
630:               /* If bb doesn't have a single predecessor we'd make this
631:                  loop have multiple latches.  Don't do that if that
632:                  would in turn require disambiguating them over again.  */
633:               if (!single_pred_p (bb))
634:                 return false;
635:             }
636:           /* cleanup_tree_cfg_noloop just created the loop preheader, don't
637:              remove it if it has phis.  */
638:           else if (bb->loop_father == loop_outer (dest->loop_father)
639:                    && !has_phi
640:                    && !loops_state_satisfies_p (LOOPS_HAVE_PREHEADERS))
641:             ;
642:           else
643:             /* Always preserve other edges into loop headers that are
644:                not simple latches or preheaders.  */
645:             return false;
646:         }
647:     }
648:
649:   edge succ = single_succ_edge (bb), e, s;
650:   gimple *stmt;
651:   gimple_stmt_iterator gsi_to;
652:
653:   /* If there are phi nodes in DEST, and some of the blocks that are
654:      predecessors of BB are also predecessors of DEST, check that the
655:      phi node arguments match.
656:      Otherwise we have to split the edge and that becomes
657:      a "forwarder" again.  */
658:   if ((!can_split || !has_phi)
659:       && !gimple_seq_empty_p (phi_nodes (dest)))
660:     {
661:       edge_iterator ei;
662:       FOR_EACH_EDGE (e, ei, bb->preds)
663:         {
664:           s = find_edge (e->src, dest);
665:           if (!s)
666:             continue;
667:
668:           if (!phi_alternatives_equal (dest, succ, s))
669:             return false;
670:         }
671:     }
672:
673:   basic_block pred = NULL;
674:   if (single_pred_p (bb))
675:     pred = single_pred (bb);
676:   bool dest_single_pred_p = single_pred_p (dest);
677:
678:   /* Redirect the edges.  */
679:   for (edge_iterator ei = ei_start (bb->preds); (e = ei_safe_edge (ei)); )
680:     {
681:       if (cfgcleanup_altered_bbs)
682:         bitmap_set_bit (cfgcleanup_altered_bbs, e->src->index);
683:       s = find_edge (e->src, dest);
684:
685:       /* See if we can split the edge if we already have an edge from src to dest.  */
686:       if (can_split && has_phi)
687:         /* PHI arguments are different.  Create a forwarder block by
688:            splitting E so that we can merge PHI arguments on E to
689:            DEST.  */
690:         if (s && !phi_alternatives_equal (dest, s, succ))
691:           e = single_succ_edge (split_edge (e));
692:
693:       if (e->flags & EDGE_ABNORMAL)
694:         {
695:           /* If there is an abnormal edge, redirect it anyway, and
696:              move the labels to the new block to make it legal.  */
697:           s = redirect_edge_succ_nodup (e, dest);
698:         }
699:       else
700:         s = redirect_edge_and_branch (e, dest);
701:
702:       if (s == e)
703:         {
704:           /* If we merge the forwarder with phis into a loop header
705:              verify if we are creating another loop latch edge.
706:              If so, reset number of iteration information of the loop.  */
707:           if (has_phi
708:               && dest->loop_father
709:               && dest->loop_father->header == dest
710:               && dominated_by_p (CDI_DOMINATORS, e->src, dest))
711:             {
712:               dest->loop_father->any_upper_bound = false;
713:               dest->loop_father->any_likely_upper_bound = false;
714:               free_numbers_of_iterations_estimates (dest->loop_father);
715:             }
716:           /* Copy arguments for the phi nodes, since the edge was not
717:              here before.  */
718:           copy_phi_arg_into_existing_phi (succ, s, has_phi);
719:         }
720:       else
721:         redirect_edge_var_map_clear (s);
722:     }
723:
724:   /* Move nonlocal labels and computed goto targets as well as user
725:      defined labels and labels with an EH landing pad number to the
726:      new block, so that the redirection of the abnormal edges works,
727:      jump targets end up in a sane place and debug information for
728:      labels is retained.  */
729:   gsi_to = gsi_start_bb (dest);
730:   for (gsi = gsi_start_bb (bb); !gsi_end_p (gsi); )
731:     {
732:       stmt = gsi_stmt (gsi);
733:       if (is_gimple_debug (stmt))
734:         break;
735:
736:       /* Forwarder blocks can only contain labels and debug stmts, and
737:          labels must come first, so if we get to this point, we know
738:          we're looking at a label.  */
739:       tree decl = gimple_label_label (as_a <glabel *> (stmt));
740:       if (EH_LANDING_PAD_NR (decl) != 0
741:           || DECL_NONLOCAL (decl)
742:           || FORCED_LABEL (decl)
743:           || !DECL_ARTIFICIAL (decl))
744:         gsi_move_before (&gsi, &gsi_to);
745:       else
746:         gsi_next (&gsi);
747:     }
748:
749:   /* Move debug statements.  Reset them if the destination does not
750:      have a single predecessor.  */
751:   move_debug_stmts_from_forwarder (bb, dest, dest_single_pred_p,
752:                                    pred, pred && single_succ_p (pred));
753:
754:   if (cfgcleanup_altered_bbs)
755:     bitmap_set_bit (cfgcleanup_altered_bbs, dest->index);
756:
757:   /* Update the dominators.  */
758:   basic_block dom, dombb, domdest;
759:
760:   dombb = get_immediate_dominator (CDI_DOMINATORS, bb);
761:   domdest = get_immediate_dominator (CDI_DOMINATORS, dest);
762:   if (domdest == bb)
763:     {
764:       /* Shortcut to avoid calling (relatively expensive)
765:          nearest_common_dominator unless necessary.  */
766:       dom = dombb;
767:     }
768:   else
769:     dom = nearest_common_dominator (CDI_DOMINATORS, domdest, dombb);
770:
771:   set_immediate_dominator (CDI_DOMINATORS, dest, dom);
772:
773:   /* Adjust latch infomation of BB's parent loop as otherwise
774:      the cfg hook has a hard time not to kill the loop.  */
775:   if (current_loops && bb->loop_father->latch == bb)
776:     bb->loop_father->latch = pred;
777:
778:   /* And kill the forwarder block.  */
779:   delete_basic_block (bb);
780:
```

## gcc/tree-cfgcleanup.cc:788–896

```text
788: bool
789: fixup_noreturn_call (gimple *stmt)
790: {
791:   basic_block bb = gimple_bb (stmt);
792:   bool changed = false;
793:
794:   if (gimple_call_builtin_p (stmt, BUILT_IN_RETURN))
795:     return false;
796:
797:   /* First split basic block if stmt is not last.  */
798:   if (stmt != gsi_stmt (gsi_last_bb (bb)))
799:     {
800:       if (stmt == gsi_stmt (gsi_last_nondebug_bb (bb)))
801:         {
802:           /* Don't split if there are only debug stmts
803:              after stmt, that can result in -fcompare-debug
804:              failures.  Remove the debug stmts instead,
805:              they should be all unreachable anyway.  */
806:           gimple_stmt_iterator gsi = gsi_for_stmt (stmt);
807:           for (gsi_next (&gsi); !gsi_end_p (gsi); )
808:             gsi_remove (&gsi, true);
809:         }
810:       else
811:         {
812:           split_block (bb, stmt);
813:           changed = true;
814:         }
815:     }
816:
817:   /* If there is an LHS, remove it, but only if its type has fixed size.
818:      The LHS will need to be recreated during RTL expansion and creating
819:      temporaries of variable-sized types is not supported.  Also don't
820:      do this with TREE_ADDRESSABLE types, as assign_temp will abort.
821:      Drop LHS regardless of TREE_ADDRESSABLE, if the function call
822:      has been changed into a call that does not return a value, like
823:      __builtin_unreachable or __cxa_pure_virtual.  */
824:   tree lhs = gimple_call_lhs (stmt);
825:   if (lhs
826:       && (should_remove_lhs_p (lhs)
827:           || VOID_TYPE_P (TREE_TYPE (gimple_call_fntype (stmt)))))
828:     {
829:       gimple_call_set_lhs (stmt, NULL_TREE);
830:
831:       /* We need to fix up the SSA name to avoid checking errors.  */
832:       if (TREE_CODE (lhs) == SSA_NAME)
833:         {
834:           tree new_var = create_tmp_reg (TREE_TYPE (lhs));
835:           SET_SSA_NAME_VAR_OR_IDENTIFIER (lhs, new_var);
836:           SSA_NAME_DEF_STMT (lhs) = gimple_build_nop ();
837:           set_ssa_default_def (cfun, new_var, lhs);
838:         }
839:
840:       update_stmt (stmt);
841:     }
842:
843:   /* Mark the call as altering control flow.  */
844:   if (!gimple_call_ctrl_altering_p (stmt))
845:     {
846:       gimple_call_set_ctrl_altering (stmt, true);
847:       changed = true;
848:     }
849:
850:   return changed;
851: }
852:
853: /* Return true if we want to merge BB1 and BB2 into a single block.  */
854:
855: static bool
856: want_merge_blocks_p (basic_block bb1, basic_block bb2)
857: {
858:   if (!can_merge_blocks_p (bb1, bb2))
859:     return false;
860:   gimple_stmt_iterator gsi = gsi_last_nondebug_bb (bb1);
861:   if (gsi_end_p (gsi) || !stmt_can_terminate_bb_p (gsi_stmt (gsi)))
862:     return true;
863:   return bb1->count.ok_for_merging (bb2->count);
864: }
865:
866:
867: /* Tries to cleanup cfg in basic block BB by merging blocks.  Returns
868:    true if anything changes.  */
869:
870: static bool
871: cleanup_tree_cfg_bb (basic_block bb)
872: {
873:   if (maybe_remove_forwarder_block (bb))
874:     return true;
875:
876:   /* If there is a merge opportunity with the predecessor
877:      do nothing now but wait until we process the predecessor.
878:      This happens when we visit BBs in a non-optimal order and
879:      avoids quadratic behavior with adjusting stmts BB pointer.  */
880:   if (single_pred_p (bb)
881:       && want_merge_blocks_p (single_pred (bb), bb))
882:     /* But make sure we _do_ visit it.  When we remove unreachable paths
883:        ending in a backedge we fail to mark the destinations predecessors
884:        as changed.  */
885:     bitmap_set_bit (cfgcleanup_altered_bbs, single_pred (bb)->index);
886:
887:   /* Merging the blocks may create new opportunities for folding
888:      conditional branches (due to the elimination of single-valued PHI
889:      nodes).  */
890:   else if (single_succ_p (bb)
891:            && want_merge_blocks_p (bb, single_succ (bb)))
892:     {
893:       merge_blocks (bb, single_succ (bb));
894:       return true;
895:     }
896:
```

## gcc/tree-cfgcleanup.cc:994–1103

```text
994: cleanup_control_flow_pre ()
995: {
996:   bool retval = false;
997:
998:   /* We want remove_edge_and_dominated_blocks to only remove edges,
999:      not dominated blocks which it does when dom info isn't available.
1000:      Pretend so.  */
1001:   dom_state saved_state = dom_info_state (CDI_DOMINATORS);
1002:   set_dom_info_availability (CDI_DOMINATORS, DOM_NONE);
1003:
1004:   auto_vec<edge_iterator, 20> stack (n_basic_blocks_for_fn (cfun) + 2);
1005:   auto_sbitmap visited (last_basic_block_for_fn (cfun));
1006:   bitmap_clear (visited);
1007:
1008:   vec<edge, va_gc> *setjmp_vec = NULL;
1009:   auto_vec<basic_block, 4> abnormal_dispatchers;
1010:
1011:   stack.quick_push (ei_start (ENTRY_BLOCK_PTR_FOR_FN (cfun)->succs));
1012:
1013:   while (! stack.is_empty ())
1014:     {
1015:       /* Look at the edge on the top of the stack.  */
1016:       edge_iterator ei = stack.last ();
1017:       basic_block dest = ei_edge (ei)->dest;
1018:
1019:       if (dest != EXIT_BLOCK_PTR_FOR_FN (cfun)
1020:           && !bitmap_bit_p (visited, dest->index)
1021:           && (ei_container (ei) == setjmp_vec
1022:               || !maybe_dead_abnormal_edge_p (ei_edge (ei))))
1023:         {
1024:           bitmap_set_bit (visited, dest->index);
1025:           /* We only possibly remove edges from DEST here, leaving
1026:              possibly unreachable code in the IL.  */
1027:           retval |= cleanup_control_flow_bb (dest);
1028:
1029:           /* Check for __builtin_setjmp_setup.  Edges from .ABNORMAL_DISPATCH
1030:              to __builtin_setjmp_receiver will be normally ignored by
1031:              maybe_dead_abnormal_edge_p.  If DEST is a visited
1032:              __builtin_setjmp_setup, queue edge from .ABNORMAL_DISPATCH
1033:              to __builtin_setjmp_receiver, so that it will be visited too.  */
1034:           if (edge e = builtin_setjmp_setup_bb (dest))
1035:             {
1036:               vec_safe_push (setjmp_vec, e);
1037:               if (vec_safe_length (setjmp_vec) == 1)
1038:                 stack.quick_push (ei_start (setjmp_vec));
1039:             }
1040:
1041:           if ((ei_edge (ei)->flags
1042:                & (EDGE_ABNORMAL | EDGE_EH)) == EDGE_ABNORMAL)
1043:             {
1044:               gimple_stmt_iterator gsi
1045:                 = gsi_start_nondebug_after_labels_bb (dest);
1046:               gimple *g = gsi_stmt (gsi);
1047:               if (g && gimple_call_internal_p (g, IFN_ABNORMAL_DISPATCHER))
1048:                 abnormal_dispatchers.safe_push (dest);
1049:             }
1050:
1051:           if (EDGE_COUNT (dest->succs) > 0)
1052:             stack.quick_push (ei_start (dest->succs));
1053:         }
1054:       else
1055:         {
1056:           if (!ei_one_before_end_p (ei))
1057:             ei_next (&stack.last ());
1058:           else
1059:             {
1060:               if (ei_container (ei) == setjmp_vec)
1061:                 vec_safe_truncate (setjmp_vec, 0);
1062:               stack.pop ();
1063:             }
1064:         }
1065:     }
1066:
1067:   vec_free (setjmp_vec);
1068:
1069:   /* If we've marked .ABNORMAL_DISPATCHER basic block(s) as visited
1070:      above, but haven't marked any of their successors as visited,
1071:      unmark them now, so that they can be removed as useless.  */
1072:   for (basic_block dispatcher_bb : abnormal_dispatchers)
1073:     {
1074:       edge e;
1075:       edge_iterator ei;
1076:       FOR_EACH_EDGE (e, ei, dispatcher_bb->succs)
1077:         if (bitmap_bit_p (visited, e->dest->index))
1078:           break;
1079:       if (e == NULL)
1080:         bitmap_clear_bit (visited, dispatcher_bb->index);
1081:     }
1082:
1083:   set_dom_info_availability (CDI_DOMINATORS, saved_state);
1084:
1085:   /* We are deleting BBs in non-reverse dominator order, make sure
1086:      insert_debug_temps_for_defs is prepared for that.  */
1087:   if (retval)
1088:     free_dominance_info (CDI_DOMINATORS);
1089:
1090:   /* Remove all now (and previously) unreachable blocks.  */
1091:   for (int i = NUM_FIXED_BLOCKS; i < last_basic_block_for_fn (cfun); ++i)
1092:     {
1093:       basic_block bb = BASIC_BLOCK_FOR_FN (cfun, i);
1094:       if (bb && !bitmap_bit_p (visited, bb->index))
1095:         {
1096:           if (!retval)
1097:             free_dominance_info (CDI_DOMINATORS);
1098:           delete_basic_block (bb);
1099:           retval = true;
1100:         }
1101:     }
1102:
1103:   return retval;
```

## gcc/tree-cfgcleanup.cc:1118–1267

```text
1118: cleanup_tree_cfg_noloop (unsigned ssa_update_flags)
1119: {
1120:   timevar_push (TV_TREE_CLEANUP_CFG);
1121:
1122:   /* Ensure that we have single entries into loop headers.  Otherwise
1123:      if one of the entries is becoming a latch due to CFG cleanup
1124:      (from formerly being part of an irreducible region) then we mess
1125:      up loop fixup and associate the old loop with a different region
1126:      which makes niter upper bounds invalid.  See for example PR80549.
1127:      This needs to be done before we remove trivially dead edges as
1128:      we need to capture the dominance state before the pending transform.  */
1129:   if (current_loops)
1130:     {
1131:       /* This needs backedges or dominators.  */
1132:       if (!dom_info_available_p (CDI_DOMINATORS))
1133:         mark_dfs_back_edges ();
1134:
1135:       for (loop_p loop : *get_loops (cfun))
1136:         if (loop && loop->header)
1137:           {
1138:             basic_block bb = loop->header;
1139:             edge_iterator ei;
1140:             edge e;
1141:             bool found_latch = false;
1142:             bool any_abnormal = false;
1143:             unsigned n = 0;
1144:             /* We are only interested in preserving existing loops, but
1145:                we need to check whether they are still real and of course
1146:                if we need to add a preheader at all.  */
1147:             FOR_EACH_EDGE (e, ei, bb->preds)
1148:               {
1149:                 if (e->flags & EDGE_ABNORMAL)
1150:                   {
1151:                     any_abnormal = true;
1152:                     break;
1153:                   }
1154:                 if ((dom_info_available_p (CDI_DOMINATORS)
1155:                      && dominated_by_p (CDI_DOMINATORS, e->src, bb))
1156:                     || (e->flags & EDGE_DFS_BACK))
1157:                   {
1158:                     found_latch = true;
1159:                     continue;
1160:                   }
1161:                 n++;
1162:               }
1163:             /* If we have more than one entry to the loop header
1164:                create a forwarder.  */
1165:             if (found_latch && ! any_abnormal && n > 1)
1166:               {
1167:                 edge fallthru = make_forwarder_block (bb, mfb_keep_latches,
1168:                                                       NULL);
1169:                 loop->header = fallthru->dest;
1170:                 if (! loops_state_satisfies_p (LOOPS_NEED_FIXUP))
1171:                   {
1172:                     /* The loop updating from the CFG hook is incomplete
1173:                        when we have multiple latches, fixup manually.  */
1174:                     remove_bb_from_loops (fallthru->src);
1175:                     loop_p cloop = loop;
1176:                     FOR_EACH_EDGE (e, ei, fallthru->src->preds)
1177:                       cloop = find_common_loop (cloop, e->src->loop_father);
1178:                     add_bb_to_loop (fallthru->src, cloop);
1179:                   }
1180:               }
1181:           }
1182:     }
1183:
1184:   /* Prepare the worklists of altered blocks.  */
1185:   cfgcleanup_altered_bbs = BITMAP_ALLOC (NULL);
1186:
1187:   /* Start by iterating over all basic blocks in PRE order looking for
1188:      edge removal opportunities.  Do this first because incoming SSA form
1189:      may be invalid and we want to avoid performing SSA related tasks such
1190:      as propgating out a PHI node during BB merging in that state.  This
1191:      also gets rid of unreachable blocks.  */
1192:   bool changed = cleanup_control_flow_pre ();
1193:
1194:   /* After doing the above SSA form should be valid (or an update SSA
1195:      should be required).  */
1196:   if (ssa_update_flags)
1197:     {
1198:       timevar_pop (TV_TREE_CLEANUP_CFG);
1199:       update_ssa (ssa_update_flags);
1200:       timevar_push (TV_TREE_CLEANUP_CFG);
1201:     }
1202:
1203:   /* Compute dominator info which we need for the iterative process below.
1204:      Avoid computing the fast query DFS numbers since any block merging
1205:      done will invalidate them anyway.  */
1206:   if (!dom_info_available_p (CDI_DOMINATORS))
1207:     calculate_dominance_info (CDI_DOMINATORS, false);
1208:   else
1209:     checking_verify_dominators (CDI_DOMINATORS);
1210:
1211:   /* During forwarder block cleanup, we may redirect edges out of
1212:      SWITCH_EXPRs, which can get expensive.  So we want to enable
1213:      recording of edge to CASE_LABEL_EXPR.  */
1214:   start_recording_case_labels ();
1215:
1216:   /* Continue by iterating over all basic blocks looking for BB merging
1217:      opportunities.  We cannot use FOR_EACH_BB_FN for the BB iteration
1218:      since the basic blocks may get removed.  */
1219:   unsigned n = last_basic_block_for_fn (cfun);
1220:   for (unsigned i = NUM_FIXED_BLOCKS; i < n; i++)
1221:     {
1222:       basic_block bb = BASIC_BLOCK_FOR_FN (cfun, i);
1223:       if (bb)
1224:         changed |= cleanup_tree_cfg_bb (bb);
1225:     }
1226:
1227:   /* Now process the altered blocks, as long as any are available.  */
1228:   while (!bitmap_empty_p (cfgcleanup_altered_bbs))
1229:     {
1230:       unsigned i = bitmap_clear_first_set_bit (cfgcleanup_altered_bbs);
1231:       if (i < NUM_FIXED_BLOCKS)
1232:         continue;
1233:
1234:       basic_block bb = BASIC_BLOCK_FOR_FN (cfun, i);
1235:       if (!bb)
1236:         continue;
1237:
1238:       /* BB merging done by cleanup_tree_cfg_bb can end up propagating
1239:          out single-argument PHIs which in turn can expose
1240:          cleanup_control_flow_bb opportunities so we have to repeat
1241:          that here.  */
1242:       changed |= cleanup_control_flow_bb (bb);
1243:       changed |= cleanup_tree_cfg_bb (bb);
1244:     }
1245:
1246:   end_recording_case_labels ();
1247:   BITMAP_FREE (cfgcleanup_altered_bbs);
1248:
1249:   gcc_assert (dom_info_available_p (CDI_DOMINATORS));
1250:
1251:   /* Do not renumber blocks if the SCEV cache is active, it is indexed by
1252:      basic-block numbers.  */
1253:   if (! scev_initialized_p ())
1254:     compact_blocks ();
1255:
1256:   checking_verify_flow_info ();
1257:
1258:   timevar_pop (TV_TREE_CLEANUP_CFG);
1259:
1260:   if (changed && current_loops)
1261:     {
1262:       /* Removing edges and/or blocks may make recorded bounds refer
1263:          to stale GIMPLE stmts now, so clear them.  */
1264:       free_numbers_of_iterations_estimates (cfun);
1265:       loops_state_set (LOOPS_NEED_FIXUP);
1266:     }
1267:
```

## gcc/tree-cfgcleanup.h:20–28

```text
20: #ifndef GCC_TREE_CFGCLEANUP_H
21: #define GCC_TREE_CFGCLEANUP_H
22:
23: /* In tree-cfgcleanup.cc  */
24: extern bitmap cfgcleanup_altered_bbs;
25: extern bool cleanup_tree_cfg (unsigned = 0);
26: extern bool fixup_noreturn_call (gimple *stmt);
27: extern bool delete_unreachable_blocks_update_callgraph (cgraph_node *dst_node,
28:                                                         bool update_clones);
```

## gcc/tree-ssa.cc:45–168

```text
45: #include "attribs.h"
46: #include "asan.h"
47:
48: /* Pointer map of variable mappings, keyed by edge.  */
49: static hash_map<edge, auto_vec<edge_var_map> > *edge_var_maps;
50:
51:
52: /* Add a mapping with PHI RESULT and PHI DEF associated with edge E.  */
53:
54: void
55: redirect_edge_var_map_add (edge e, tree result, tree def, location_t locus)
56: {
57:   edge_var_map new_node;
58:
59:   if (edge_var_maps == NULL)
60:     edge_var_maps = new hash_map<edge, auto_vec<edge_var_map> >;
61:
62:   auto_vec<edge_var_map> &slot = edge_var_maps->get_or_insert (e);
63:   new_node.def = def;
64:   new_node.result = result;
65:   new_node.locus = locus;
66:
67:   slot.safe_push (new_node);
68: }
69:
70:
71: /* Clear the var mappings in edge E.  */
72:
73: void
74: redirect_edge_var_map_clear (edge e)
75: {
76:   if (!edge_var_maps)
77:     return;
78:
79:   auto_vec<edge_var_map> *head = edge_var_maps->get (e);
80:
81:   if (head)
82:     head->release ();
83: }
84:
85:
86: /* Duplicate the redirected var mappings in OLDE in NEWE.
87:
88:    This assumes a hash_map can have multiple edges mapping to the same
89:    var_map (many to one mapping), since we don't remove the previous mappings.
90:    */
91:
92: void
93: redirect_edge_var_map_dup (edge newe, edge olde)
94: {
95:   if (!edge_var_maps)
96:     return;
97:
98:   auto_vec<edge_var_map> *new_head = &edge_var_maps->get_or_insert (newe);
99:   auto_vec<edge_var_map> *old_head = edge_var_maps->get (olde);
100:   if (!old_head)
101:     return;
102:
103:   new_head->safe_splice (*old_head);
104: }
105:
106:
107: /* Return the variable mappings for a given edge.  If there is none, return
108:    NULL.  */
109:
110: vec<edge_var_map> *
111: redirect_edge_var_map_vector (edge e)
112: {
113:   /* Hey, what kind of idiot would... you'd be surprised.  */
114:   if (!edge_var_maps)
115:     return NULL;
116:
117:   auto_vec<edge_var_map> *slot = edge_var_maps->get (e);
118:   if (!slot)
119:     return NULL;
120:
121:   return slot;
122: }
123:
124: /* Clear the edge variable mappings.  */
125:
126: void
127: redirect_edge_var_map_empty (void)
128: {
129:   if (edge_var_maps)
130:     edge_var_maps->empty ();
131: }
132:
133:
134: /* Remove the corresponding arguments from the PHI nodes in E's
135:    destination block and redirect it to DEST.  Return redirected edge.
136:    The list of removed arguments is stored in a vector accessed
137:    through edge_var_maps.  */
138:
139: edge
140: ssa_redirect_edge (edge e, basic_block dest)
141: {
142:   gphi_iterator gsi;
143:   gphi *phi;
144:
145:   redirect_edge_var_map_clear (e);
146:
147:   /* Remove the appropriate PHI arguments in E's destination block.
148:      If we are redirecting a copied edge the destination has not
149:      got PHI argument space reserved nor an interesting argument.  */
150:   if (! (e->dest->flags & BB_DUPLICATED))
151:     for (gsi = gsi_start_phis (e->dest); !gsi_end_p (gsi); gsi_next (&gsi))
152:       {
153:         tree def;
154:         location_t locus;
155:
156:         phi = gsi.phi ();
157:         def = gimple_phi_arg_def (phi, e->dest_idx);
158:         locus = gimple_phi_arg_location (phi, e->dest_idx);
159:
160:         if (def == NULL_TREE)
161:           continue;
162:
163:         redirect_edge_var_map_add (e, gimple_phi_result (phi), def, locus);
164:       }
165:
166:   e = redirect_edge_succ_nodup (e, dest);
167:
168:   return e;
```

## gcc/tree-ssa.cc:243–270

```text
243: target_for_debug_bind (tree var)
244: {
245:   if (!MAY_HAVE_DEBUG_BIND_STMTS)
246:     return NULL_TREE;
247:
248:   if (TREE_CODE (var) == SSA_NAME)
249:     {
250:       var = SSA_NAME_VAR (var);
251:       if (var == NULL_TREE)
252:         return NULL_TREE;
253:     }
254:
255:   if ((!VAR_P (var) || VAR_DECL_IS_VIRTUAL_OPERAND (var))
256:       && TREE_CODE (var) != PARM_DECL)
257:     return NULL_TREE;
258:
259:   if (DECL_HAS_VALUE_EXPR_P (var))
260:     return target_for_debug_bind (DECL_VALUE_EXPR (var));
261:
262:   if (DECL_IGNORED_P (var))
263:     return NULL_TREE;
264:
265:   /* var-tracking only tracks registers.  */
266:   if (!is_gimple_reg_type (TREE_TYPE (var)))
267:     return NULL_TREE;
268:
269:   return var;
270: }
```

## gcc/cfghooks.cc:502–520

```text
502: redirect_edge_succ_nodup (edge e, basic_block new_succ)
503: {
504:   edge s;
505:
506:   s = find_edge (e->src, new_succ);
507:   if (s && s != e)
508:     {
509:       s->flags |= e->flags;
510:       s->probability += e->probability;
511:       /* FIXME: This should be called via a hook and only for IR_GIMPLE.  */
512:       redirect_edge_var_map_dup (s, e);
513:       remove_edge (e);
514:       e = s;
515:     }
516:   else
517:     redirect_edge_succ (e, new_succ);
518:
519:   return e;
520: }
```

## gcc/cfghooks.cc:562–602

```text
562:
563: static edge
564: split_block_1 (basic_block bb, void *i)
565: {
566:   basic_block new_bb;
567:   edge res;
568:
569:   if (!cfg_hooks->split_block)
570:     internal_error ("%s does not support split_block", cfg_hooks->name);
571:
572:   new_bb = cfg_hooks->split_block (bb, i);
573:   if (!new_bb)
574:     return NULL;
575:
576:   new_bb->count = bb->count;
577:
578:   if (dom_info_available_p (CDI_DOMINATORS))
579:     {
580:       redirect_immediate_dominators (CDI_DOMINATORS, bb, new_bb);
581:       set_immediate_dominator (CDI_DOMINATORS, new_bb, bb);
582:     }
583:
584:   if (current_loops != NULL)
585:     {
586:       edge_iterator ei;
587:       edge e;
588:       add_bb_to_loop (new_bb, bb->loop_father);
589:       /* Identify all loops bb may have been the latch of and adjust them.  */
590:       FOR_EACH_EDGE (e, ei, new_bb->succs)
591:         if (e->dest->loop_father->latch == bb)
592:           e->dest->loop_father->latch = new_bb;
593:     }
594:
595:   res = make_single_succ_edge (bb, new_bb, EDGE_FALLTHRU);
596:
597:   if (bb->flags & BB_IRREDUCIBLE_LOOP)
598:     {
599:       new_bb->flags |= BB_IRREDUCIBLE_LOOP;
600:       res->flags |= EDGE_IRREDUCIBLE_LOOP;
601:     }
602:
```

## gcc/cfghooks.cc:842–1020

```text
842: merge_blocks (basic_block a, basic_block b)
843: {
844:   edge e;
845:   edge_iterator ei;
846:
847:   if (!cfg_hooks->merge_blocks)
848:     internal_error ("%s does not support merge_blocks", cfg_hooks->name);
849:
850:   /* Pick the more reliable count.  If both qualities agrees, pick the larger
851:      one since turning mistakely hot code to cold is more harmful.  */
852:   if (!a->count.initialized_p ())
853:     a->count = b->count;
854:   else if (a->count.quality () < b->count.quality ())
855:     a->count = b->count;
856:   else if (a->count.quality () == b->count.quality ())
857:     a->count = profile_count::max_prefer_initialized (a->count, b->count);
858:
859:   cfg_hooks->merge_blocks (a, b);
860:
861:   if (current_loops != NULL)
862:     {
863:       /* If the block we merge into is a loop header do nothing unless ... */
864:       if (a->loop_father->header == a)
865:         {
866:           /* ... we merge two loop headers, in which case we kill
867:              the inner loop.  */
868:           if (b->loop_father->header == b)
869:             mark_loop_for_removal (b->loop_father);
870:         }
871:       /* If we merge a loop header into its predecessor, update the loop
872:          structure.  */
873:       else if (b->loop_father->header == b)
874:         {
875:           remove_bb_from_loops (a);
876:           add_bb_to_loop  (a, b->loop_father);
877:           a->loop_father->header = a;
878:         }
879:       /* If we merge a loop latch into its predecessor, update the loop
880:          structure.  */
881:       if (b->loop_father->latch
882:           && b->loop_father->latch == b)
883:         b->loop_father->latch = a;
884:       remove_bb_from_loops (b);
885:     }
886:
887:   /* Normally there should only be one successor of A and that is B, but
888:      partway though the merge of blocks for conditional_execution we'll
889:      be merging a TEST block with THEN and ELSE successors.  Free the
890:      whole lot of them and hope the caller knows what they're doing.  */
891:
892:   while (EDGE_COUNT (a->succs) != 0)
893:     remove_edge (EDGE_SUCC (a, 0));
894:
895:   /* Adjust the edges out of B for the new owner.  */
896:   FOR_EACH_EDGE (e, ei, b->succs)
897:     {
898:       e->src = a;
899:       if (current_loops != NULL)
900:         {
901:           /* If b was a latch, a now is.  */
902:           if (e->dest->loop_father->latch == b)
903:             e->dest->loop_father->latch = a;
904:           rescan_loop_exit (e, true, false);
905:         }
906:     }
907:   a->succs = b->succs;
908:   a->flags |= b->flags;
909:
910:   /* B hasn't quite yet ceased to exist.  Attempt to prevent mishap.  */
911:   b->preds = b->succs = NULL;
912:
913:   if (dom_info_available_p (CDI_DOMINATORS))
914:     redirect_immediate_dominators (CDI_DOMINATORS, b, a);
915:
916:   if (dom_info_available_p (CDI_DOMINATORS))
917:     delete_from_dominance_info (CDI_DOMINATORS, b);
918:   if (dom_info_available_p (CDI_POST_DOMINATORS))
919:     delete_from_dominance_info (CDI_POST_DOMINATORS, b);
920:
921:   expunge_block (b);
922: }
923:
924: /* Split BB into entry part and the rest (the rest is the newly created block).
925:    Redirect those edges for that REDIRECT_EDGE_P returns true to the entry
926:    part.  Returns the edge connecting the entry part to the rest.  */
927:
928: edge
929: make_forwarder_block (basic_block bb, bool (*redirect_edge_p) (edge),
930:                       void (*new_bb_cbk) (basic_block))
931: {
932:   edge e, fallthru;
933:   edge_iterator ei;
934:   basic_block dummy, jump;
935:   class loop *loop, *ploop, *cloop;
936:
937:   if (!cfg_hooks->make_forwarder_block)
938:     internal_error ("%s does not support make_forwarder_block",
939:                     cfg_hooks->name);
940:
941:   fallthru = split_block_after_labels (bb);
942:   dummy = fallthru->src;
943:   dummy->count = profile_count::zero ();
944:   bb = fallthru->dest;
945:
946:   /* Redirect back edges we want to keep.  */
947:   for (ei = ei_start (dummy->preds); (e = ei_safe_edge (ei)); )
948:     {
949:       basic_block e_src;
950:
951:       if (redirect_edge_p (e))
952:         {
953:           dummy->count += e->count ();
954:           ei_next (&ei);
955:           continue;
956:         }
957:
958:       e_src = e->src;
959:       jump = redirect_edge_and_branch_force (e, bb);
960:       if (jump != NULL)
961:         {
962:           /* If we redirected the loop latch edge, the JUMP block now acts like
963:              the new latch of the loop.  */
964:           if (current_loops != NULL
965:               && dummy->loop_father != NULL
966:               && dummy->loop_father->header == dummy
967:               && dummy->loop_father->latch == e_src)
968:             dummy->loop_father->latch = jump;
969:
970:           if (new_bb_cbk != NULL)
971:             new_bb_cbk (jump);
972:         }
973:     }
974:
975:   if (dom_info_available_p (CDI_DOMINATORS))
976:     {
977:       vec<basic_block> doms_to_fix;
978:       doms_to_fix.create (2);
979:       doms_to_fix.quick_push (dummy);
980:       doms_to_fix.quick_push (bb);
981:       iterate_fix_dominators (CDI_DOMINATORS, doms_to_fix, false);
982:       doms_to_fix.release ();
983:     }
984:
985:   if (current_loops != NULL)
986:     {
987:       /* If we do not split a loop header, then both blocks belong to the
988:          same loop.  In case we split loop header and do not redirect the
989:          latch edge to DUMMY, then DUMMY belongs to the outer loop, and
990:          BB becomes the new header.  If latch is not recorded for the loop,
991:          we leave this updating on the caller (this may only happen during
992:          loop analysis).  */
993:       loop = dummy->loop_father;
994:       if (loop->header == dummy
995:           && loop->latch != NULL
996:           && find_edge (loop->latch, dummy) == NULL)
997:         {
998:           remove_bb_from_loops (dummy);
999:           loop->header = bb;
1000:
1001:           cloop = loop;
1002:           FOR_EACH_EDGE (e, ei, dummy->preds)
1003:             {
1004:               cloop = find_common_loop (cloop, e->src->loop_father);
1005:             }
1006:           add_bb_to_loop (dummy, cloop);
1007:         }
1008:
1009:       /* In case we split loop latch, update it.  */
1010:       for (ploop = loop; ploop; ploop = loop_outer (ploop))
1011:         if (ploop->latch == dummy)
1012:           ploop->latch = bb;
1013:     }
1014:
1015:   cfg_hooks->make_forwarder_block (fallthru);
1016:
1017:   return fallthru;
1018: }
1019:
1020: /* Try to make the edge fallthru.  */
```

## gcc/gimple-fold.cc:11005–11058

```text
11005:    indicating they belong to the currently building sequence.  */
11006:
11007: tree
11008: gimple_build (gimple_stmt_iterator *gsi,
11009:               bool before, gsi_iterator_update update,
11010:               location_t loc, enum tree_code code, tree type, tree op0)
11011: {
11012:   gimple_seq seq = NULL;
11013:   tree res
11014:     = gimple_simplify (code, type, op0, &seq,
11015:                        gsi->bb ? follow_all_ssa_edges : gimple_build_valueize);
11016:   if (!res)
11017:     {
11018:       res = make_ssa_name (type);
11019:       gimple *stmt;
11020:       if (code == REALPART_EXPR
11021:           || code == IMAGPART_EXPR
11022:           || code == VIEW_CONVERT_EXPR)
11023:         stmt = gimple_build_assign (res, code, build1 (code, type, op0));
11024:       else
11025:         stmt = gimple_build_assign (res, code, op0);
11026:       gimple_set_location (stmt, loc);
11027:       gimple_seq_add_stmt_without_update (&seq, stmt);
11028:     }
11029:   gimple_build_insert_seq (gsi, before, update, seq);
11030:   return res;
11031: }
11032:
11033: /* Build the expression OP0 CODE OP1 of type TYPE with location LOC,
11034:    simplifying it first if possible.  Returns the built
11035:    expression value inserting any new statements at GSI honoring BEFORE
11036:    and UPDATE.  */
11037:
11038: tree
11039: gimple_build (gimple_stmt_iterator *gsi,
11040:               bool before, gsi_iterator_update update,
11041:               location_t loc, enum tree_code code, tree type,
11042:               tree op0, tree op1)
11043: {
11044:   gimple_seq seq = NULL;
11045:   tree res
11046:     = gimple_simplify (code, type, op0, op1, &seq,
11047:                        gsi->bb ? follow_all_ssa_edges : gimple_build_valueize);
11048:   if (!res)
11049:     {
11050:       res = make_ssa_name (type);
11051:       gimple *stmt = gimple_build_assign (res, code, op0, op1);
11052:       gimple_set_location (stmt, loc);
11053:       gimple_seq_add_stmt_without_update (&seq, stmt);
11054:     }
11055:   gimple_build_insert_seq (gsi, before, update, seq);
11056:   return res;
11057: }
11058:
```

## gcc/gimple-fold.cc:11287–11296

```text
11287:    at GSI honoring BEFORE and UPDATE.  */
11288:
11289: tree
11290: gimple_convert (gimple_stmt_iterator *gsi,
11291:                 bool before, gsi_iterator_update update,
11292:                 location_t loc, tree type, tree op)
11293: {
11294:   if (useless_type_conversion_p (type, TREE_TYPE (op)))
11295:     return op;
11296:   return gimple_build (gsi, before, update, loc, NOP_EXPR, type, op);
```

## gcc/gimple-fold.h:85–103

```text
85: gimple_build (gimple_seq *seq, location_t loc,
86:               enum tree_code code, tree type, Args ...ops)
87: {
88:   static_assert (sizeof...(ops) > 0 && sizeof...(ops) <= 3,
89:                  "Number of operands must be from one to three");
90:   gimple_stmt_iterator gsi = gsi_last (*seq);
91:   return gimple_build (&gsi, false, GSI_CONTINUE_LINKING,
92:                        loc, code, type, ops...);
93: }
94: template<class ...Args>
95: inline tree
96: gimple_build (gimple_seq *seq, enum tree_code code, tree type, Args ...ops)
97: {
98:   static_assert (sizeof...(ops) > 0 && sizeof...(ops) <= 3,
99:                  "Number of operands must be from one to three");
100:   gimple_stmt_iterator gsi = gsi_last (*seq);
101:   return gimple_build (&gsi, false, GSI_CONTINUE_LINKING,
102:                        UNKNOWN_LOCATION, code, type, ops...);
103: }
```

## gcc/gimple-fold.h:176–186

```text
176: gimple_convert (gimple_seq *seq, location_t loc, tree type, tree op)
177: {
178:   gimple_stmt_iterator gsi = gsi_last (*seq);
179:   return gimple_convert (&gsi, false, GSI_CONTINUE_LINKING, loc, type, op);
180: }
181: inline tree
182: gimple_convert (gimple_seq *seq, tree type, tree op)
183: {
184:   gimple_stmt_iterator gsi = gsi_last (*seq);
185:   return gimple_convert (&gsi, false, GSI_CONTINUE_LINKING,
186:                          UNKNOWN_LOCATION, type, op);
```

## gcc/basic-block.h:353–365

```text
353:
354: inline basic_block
355: single_pred (const_basic_block bb)
356: {
357:   return single_pred_edge (bb)->src;
358: }
359:
360: /* Iterator object for edges.  */
361:
362: struct edge_iterator {
363:   unsigned index;
364:   vec<edge, va_gc> **container;
365: };
```

## gcc/dominance.cc:48–55

```text
48:    artificial ENTRY_BLOCK (or EXIT_BLOCK in the post-dom case) in our lists to
49:    support multiple entry points.  Its dfs number is of course 1.  */
50:
51: /* Type of Basic Block aka. TBB */
52: typedef unsigned int TBB;
53:
54: namespace {
55:
```

## gcc/dominance.cc:148–219

```text
148:    `x = new T[num] {};'.  */
149:
150: template<typename T>
151: inline T *new_zero_array (unsigned num)
152: {
153:   T *result = new T[num];
154:   memset (result, 0, sizeof (T) * num);
155:   return result;
156: }
157:
158: /* Helper function for constructors to initialize a part of class members.  */
159:
160: void
161: dom_info::dom_init (void)
162: {
163:   unsigned num = m_n_basic_blocks;
164:
165:   m_dfs_parent = new_zero_array <TBB> (num);
166:   m_dom = new_zero_array <TBB> (num);
167:
168:   m_path_min = new TBB[num];
169:   m_key = new TBB[num];
170:   m_set_size = new unsigned int[num];
171:   for (unsigned i = 0; i < num; i++)
172:     {
173:       m_path_min[i] = m_key[i] = i;
174:       m_set_size[i] = 1;
175:     }
176:
177:   m_bucket = new_zero_array <TBB> (num);
178:   m_next_bucket = new_zero_array <TBB> (num);
179:
180:   m_set_chain = new_zero_array <TBB> (num);
181:   m_set_child = new_zero_array <TBB> (num);
182:
183:   m_dfs_to_bb = new_zero_array <basic_block> (num);
184:
185:   m_dfsnum = 1;
186:   m_nodes = 0;
187: }
188:
189: /* Allocate all needed memory in a pessimistic fashion (so we round up).  */
190:
191: dom_info::dom_info (function *fn, cdi_direction dir)
192: {
193:   m_n_basic_blocks = n_basic_blocks_for_fn (fn);
194:
195:   dom_init ();
196:
197:   unsigned last_bb_index = last_basic_block_for_fn (fn);
198:   m_dfs_order = new_zero_array <TBB> (last_bb_index + 1);
199:   m_dfs_last = &m_dfs_order[last_bb_index];
200:
201:   switch (dir)
202:     {
203:       case CDI_DOMINATORS:
204:         m_reverse = false;
205:         m_fake_exit_edge = NULL;
206:         m_start_block = ENTRY_BLOCK_PTR_FOR_FN (fn);
207:         m_end_block = EXIT_BLOCK_PTR_FOR_FN (fn);
208:         break;
209:       case CDI_POST_DOMINATORS:
210:         m_reverse = true;
211:         m_fake_exit_edge = BITMAP_ALLOC (NULL);
212:         m_start_block = EXIT_BLOCK_PTR_FOR_FN (fn);
213:         m_end_block = ENTRY_BLOCK_PTR_FOR_FN (fn);
214:         break;
215:       default:
216:         gcc_unreachable ();
217:     }
218: }
219:
```

## gcc/dominance.cc:302–391

```text
302: dom_info::calc_dfs_tree_nonrec (basic_block bb)
303: {
304:   edge_iterator *stack = new edge_iterator[m_n_basic_blocks + 1];
305:   int sp = 0;
306:   unsigned d_i = dom_convert_dir_to_idx (m_reverse ? CDI_POST_DOMINATORS
307:                                          : CDI_DOMINATORS);
308:
309:   /* Initialize the first edge.  */
310:   edge_iterator ei = m_reverse ? ei_start (bb->preds)
311:                                : ei_start (bb->succs);
312:
313:   /* When the stack is empty we break out of this loop.  */
314:   while (1)
315:     {
316:       basic_block bn;
317:       edge_iterator einext;
318:
319:       /* This loop traverses edges e in depth first manner, and fills the
320:          stack.  */
321:       while (!ei_end_p (ei))
322:         {
323:           edge e = ei_edge (ei);
324:
325:           /* Deduce from E the current and the next block (BB and BN), and the
326:              next edge.  */
327:           if (m_reverse)
328:             {
329:               bn = e->src;
330:
331:               /* If the next node BN is either already visited or a border
332:                  block or out of region the current edge is useless, and simply
333:                  overwritten with the next edge out of the current node.  */
334:               if (bn == m_end_block || bn->dom[d_i] == NULL
335:                   || m_dfs_order[bn->index])
336:                 {
337:                   ei_next (&ei);
338:                   continue;
339:                 }
340:               bb = e->dest;
341:               einext = ei_start (bn->preds);
342:             }
343:           else
344:             {
345:               bn = e->dest;
346:               if (bn == m_end_block || bn->dom[d_i] == NULL
347:                   || m_dfs_order[bn->index])
348:                 {
349:                   ei_next (&ei);
350:                   continue;
351:                 }
352:               bb = e->src;
353:               einext = ei_start (bn->succs);
354:             }
355:
356:           gcc_assert (bn != m_start_block);
357:
358:           /* Fill the DFS tree info calculatable _before_ recursing.  */
359:           TBB my_i;
360:           if (bb != m_start_block)
361:             my_i = m_dfs_order[bb->index];
362:           else
363:             my_i = *m_dfs_last;
364:           TBB child_i = m_dfs_order[bn->index] = m_dfsnum++;
365:           m_dfs_to_bb[child_i] = bn;
366:           m_dfs_parent[child_i] = my_i;
367:
368:           /* Save the current point in the CFG on the stack, and recurse.  */
369:           stack[sp++] = ei;
370:           ei = einext;
371:         }
372:
373:       if (!sp)
374:         break;
375:       ei = stack[--sp];
376:
377:       /* OK.  The edge-list was exhausted, meaning normally we would
378:          end the recursion.  After returning from the recursive call,
379:          there were (may be) other statements which were run after a
380:          child node was completely considered by DFS.  Here is the
381:          point to do it in the non-recursive variant.
382:          E.g. The block just completed is in e->dest for forward DFS,
383:          the block not yet completed (the parent of the one above)
384:          in e->src.  This could be used e.g. for computing the number of
385:          descendants or the tree depth.  */
386:       ei_next (&ei);
387:     }
388:   delete[] stack;
389: }
390:
391: /* The main entry for calculating the DFS tree or forest.  m_reverse is true,
```

## gcc/dominance.cc:516–545

```text
516: dom_info::link_roots (TBB v, TBB w)
517: {
518:   TBB s = w;
519:
520:   /* Rebalance the tree.  */
521:   while (m_key[m_path_min[w]] < m_key[m_path_min[m_set_child[s]]])
522:     {
523:       if (m_set_size[s] + m_set_size[m_set_child[m_set_child[s]]]
524:           >= 2 * m_set_size[m_set_child[s]])
525:         {
526:           m_set_chain[m_set_child[s]] = s;
527:           m_set_child[s] = m_set_child[m_set_child[s]];
528:         }
529:       else
530:         {
531:           m_set_size[m_set_child[s]] = m_set_size[s];
532:           s = m_set_chain[s] = m_set_child[s];
533:         }
534:     }
535:
536:   m_path_min[s] = m_path_min[w];
537:   m_set_size[v] += m_set_size[w];
538:   if (m_set_size[v] < 2 * m_set_size[w])
539:     std::swap (m_set_child[v], s);
540:
541:   /* Merge all subtrees.  */
542:   while (s)
543:     {
544:       m_set_chain[s] = v;
545:       s = m_set_child[s];
```

## gcc/dominance.cc:637–686

```text
637: /* Assign dfs numbers starting from NUM to NODE and its sons.  */
638:
639: static void
640: assign_dfs_numbers (struct et_node *node, int *num)
641: {
642:   et_node *n = node;
643:   while (1)
644:     {
645:       n->dfs_num_in = (*num)++;
646:       if (n->son)
647:         n = n->son;
648:       else
649:         {
650:           while (!n->right || n->right == n->father->son)
651:             {
652:               n->dfs_num_out = (*num)++;
653:               if (n == node)
654:                 return;
655:               n = n->father;
656:             }
657:           n->dfs_num_out = (*num)++;
658:           n = n->right;
659:         }
660:     }
661: }
662:
663: /* Compute the data necessary for fast resolving of dominator queries in a
664:    static dominator tree.  */
665:
666: static void
667: compute_dom_fast_query (enum cdi_direction dir)
668: {
669:   int num = 0;
670:   basic_block bb;
671:   unsigned int dir_index = dom_convert_dir_to_idx (dir);
672:
673:   gcc_checking_assert (dom_info_available_p (dir));
674:
675:   if (dom_computed[dir_index] == DOM_OK)
676:     return;
677:
678:   FOR_ALL_BB_FN (bb, cfun)
679:     {
680:       if (!bb->dom[dir_index]->father)
681:         assign_dfs_numbers (bb->dom[dir_index], &num);
682:     }
683:
684:   dom_computed[dir_index] = DOM_OK;
685: }
686:
```

## gcc/dominance.cc:720–765

```text
720: calculate_dominance_info (cdi_direction dir, bool compute_fast_query)
721: {
722:   unsigned int dir_index = dom_convert_dir_to_idx (dir);
723:
724:   if (dom_computed[dir_index] == DOM_OK)
725:     {
726:       checking_verify_dominators (dir);
727:       return;
728:     }
729:
730:   timevar_push (TV_DOMINANCE);
731:   if (!dom_info_available_p (dir))
732:     {
733:       gcc_assert (!n_bbs_in_dom_tree[dir_index]);
734:
735:       basic_block b;
736:       FOR_ALL_BB_FN (b, cfun)
737:         {
738:           b->dom[dir_index] = et_new_tree (b);
739:         }
740:       n_bbs_in_dom_tree[dir_index] = n_basic_blocks_for_fn (cfun);
741:
742:       dom_info di (cfun, dir);
743:       di.calc_dfs_tree ();
744:       di.calc_idoms ();
745:
746:       FOR_EACH_BB_FN (b, cfun)
747:         {
748:           if (basic_block d = di.get_idom (b))
749:             et_set_father (b->dom[dir_index], d->dom[dir_index]);
750:         }
751:
752:       dom_computed[dir_index] = DOM_NO_FAST_QUERY;
753:     }
754:   else
755:     checking_verify_dominators (dir);
756:
757:   if (compute_fast_query)
758:     compute_dom_fast_query (dir);
759:
760:   timevar_pop (TV_DOMINANCE);
761: }
762:
763: /* Analogous to the previous function but compute dominance info for regions
764:    which are single entry, multiple exit regions for CDI_DOMINATORs and
765:    multiple entry, single exit regions for CDI_POST_DOMINATORs.  */
```

## gcc/dominance.cc:873–892

```text
873:                          basic_block dominated_by)
874: {
875:   unsigned int dir_index = dom_convert_dir_to_idx (dir);
876:   struct et_node *node = bb->dom[dir_index];
877:
878:   gcc_checking_assert (dom_computed[dir_index]);
879:
880:   if (node->father)
881:     {
882:       if (node->father->data == dominated_by)
883:         return;
884:       et_split (node);
885:     }
886:
887:   if (dominated_by)
888:     et_set_father (node, dominated_by->dom[dir_index]);
889:
890:   if (dom_computed[dir_index] == DOM_OK)
891:     dom_computed[dir_index] = DOM_NO_FAST_QUERY;
892: }
```

## gcc/dominance.cc:947–984

```text
947: get_dominated_to_depth (enum cdi_direction dir, basic_block bb, int depth)
948: {
949:   auto_vec<basic_block> bbs;
950:   unsigned i;
951:   unsigned next_level_start;
952:
953:   i = 0;
954:   bbs.safe_push (bb);
955:   next_level_start = 1; /* = bbs.length (); */
956:
957:   do
958:     {
959:       basic_block son;
960:
961:       bb = bbs[i++];
962:       for (son = first_dom_son (dir, bb);
963:            son;
964:            son = next_dom_son (dir, son))
965:         bbs.safe_push (son);
966:
967:       if (i == next_level_start && --depth)
968:         next_level_start = bbs.length ();
969:     }
970:   while (i < next_level_start);
971:
972:   return bbs;
973: }
974:
975: /* Returns the list of basic blocks including BB dominated by BB, in the
976:    direction DIR.  The vector will be sorted in preorder.  */
977:
978: auto_vec<basic_block>
979: get_all_dominated_blocks (enum cdi_direction dir, basic_block bb)
980: {
981:   return get_dominated_to_depth (dir, bb, 0);
982: }
983:
984: /* Redirect all edges pointing to BB to TO.  */
```

## gcc/dominance.cc:1165–1200

```text
1165: verify_dominators (cdi_direction dir)
1166: {
1167:   gcc_assert (dom_info_available_p (dir));
1168:
1169:   dom_info di (cfun, dir);
1170:   di.calc_dfs_tree ();
1171:   di.calc_idoms ();
1172:
1173:   bool err = false;
1174:   basic_block bb;
1175:   FOR_EACH_BB_FN (bb, cfun)
1176:     {
1177:       basic_block imm_bb = get_immediate_dominator (dir, bb);
1178:       if (!imm_bb)
1179:         {
1180:           error ("dominator of %d status unknown", bb->index);
1181:           err = true;
1182:           continue;
1183:         }
1184:
1185:       basic_block imm_bb_correct = di.get_idom (bb);
1186:       if (imm_bb != imm_bb_correct)
1187:         {
1188:           error ("dominator of %d should be %d, not %d",
1189:                  bb->index, imm_bb_correct->index, imm_bb->index);
1190:           err = true;
1191:         }
1192:     }
1193:
1194:   gcc_assert (!err);
1195: }
1196:
1197: /* Determine immediate dominator (or postdominator, according to DIR) of BB,
1198:    assuming that dominators of other blocks are correct.  We also use it to
1199:    recompute the dominators in a restricted area, by iterating it until it
1200:    reaches a fixed point.  */
```

## gcc/dominance.cc:1232–1558

```text
1232: /* Use simple heuristics (see iterate_fix_dominators) to determine dominators
1233:    of BBS.  We assume that all the immediate dominators except for those of the
1234:    blocks in BBS are correct.  If CONSERVATIVE is true, we also assume that the
1235:    currently recorded immediate dominators of blocks in BBS really dominate the
1236:    blocks.  The basic blocks for that we determine the dominator are removed
1237:    from BBS.  */
1238:
1239: static void
1240: prune_bbs_to_update_dominators (vec<basic_block> &bbs,
1241:                                 bool conservative)
1242: {
1243:   unsigned i;
1244:   bool single;
1245:   basic_block bb, dom = NULL;
1246:   edge_iterator ei;
1247:   edge e;
1248:
1249:   for (i = 0; bbs.iterate (i, &bb);)
1250:     {
1251:       if (bb == ENTRY_BLOCK_PTR_FOR_FN (cfun))
1252:         goto succeed;
1253:
1254:       if (single_pred_p (bb))
1255:         {
1256:           set_immediate_dominator (CDI_DOMINATORS, bb, single_pred (bb));
1257:           goto succeed;
1258:         }
1259:
1260:       if (!conservative)
1261:         goto fail;
1262:
1263:       single = true;
1264:       dom = NULL;
1265:       FOR_EACH_EDGE (e, ei, bb->preds)
1266:         {
1267:           if (dominated_by_p (CDI_DOMINATORS, e->src, bb))
1268:             continue;
1269:
1270:           if (!dom)
1271:             dom = e->src;
1272:           else
1273:             {
1274:               single = false;
1275:               dom = nearest_common_dominator (CDI_DOMINATORS, dom, e->src);
1276:             }
1277:         }
1278:
1279:       gcc_assert (dom != NULL);
1280:       if (single
1281:           || find_edge (dom, bb))
1282:         {
1283:           set_immediate_dominator (CDI_DOMINATORS, bb, dom);
1284:           goto succeed;
1285:         }
1286:
1287: fail:
1288:       i++;
1289:       continue;
1290:
1291: succeed:
1292:       bbs.unordered_remove (i);
1293:     }
1294: }
1295:
1296: /* Returns root of the dominance tree in the direction DIR that contains
1297:    BB.  */
1298:
1299: static basic_block
1300: root_of_dom_tree (enum cdi_direction dir, basic_block bb)
1301: {
1302:   return (basic_block) et_root (bb->dom[dom_convert_dir_to_idx (dir)])->data;
1303: }
1304:
1305: /* See the comment in iterate_fix_dominators.  Finds the immediate dominators
1306:    for the sons of Y, found using the SON and BROTHER arrays representing
1307:    the dominance tree of graph G.  BBS maps the vertices of G to the basic
1308:    blocks.  */
1309:
1310: static void
1311: determine_dominators_for_sons (struct graph *g, vec<basic_block> bbs,
1312:                                int y, int *son, int *brother)
1313: {
1314:   bitmap gprime;
1315:   int i, a, nc;
1316:   vec<int> *sccs;
1317:   basic_block bb, dom, ybb;
1318:   unsigned si;
1319:   edge e;
1320:   edge_iterator ei;
1321:
1322:   if (son[y] == -1)
1323:     return;
1324:   if (y == (int) bbs.length ())
1325:     ybb = ENTRY_BLOCK_PTR_FOR_FN (cfun);
1326:   else
1327:     ybb = bbs[y];
1328:
1329:   if (brother[son[y]] == -1)
1330:     {
1331:       /* Handle the common case Y has just one son specially.  */
1332:       bb = bbs[son[y]];
1333:       set_immediate_dominator (CDI_DOMINATORS, bb,
1334:                                recompute_dominator (CDI_DOMINATORS, bb));
1335:       identify_vertices (g, y, son[y]);
1336:       return;
1337:     }
1338:
1339:   gprime = BITMAP_ALLOC (NULL);
1340:   for (a = son[y]; a != -1; a = brother[a])
1341:     bitmap_set_bit (gprime, a);
1342:
1343:   nc = graphds_scc (g, gprime);
1344:   BITMAP_FREE (gprime);
1345:
1346:   /* ???  Needed to work around the pre-processor confusion with
1347:      using a multi-argument template type as macro argument.  */
1348:   typedef vec<int> vec_int_heap;
1349:   sccs = XCNEWVEC (vec_int_heap, nc);
1350:   for (a = son[y]; a != -1; a = brother[a])
1351:     sccs[g->vertices[a].component].safe_push (a);
1352:
1353:   for (i = nc - 1; i >= 0; i--)
1354:     {
1355:       dom = NULL;
1356:       FOR_EACH_VEC_ELT (sccs[i], si, a)
1357:         {
1358:           bb = bbs[a];
1359:           FOR_EACH_EDGE (e, ei, bb->preds)
1360:             {
1361:               if (root_of_dom_tree (CDI_DOMINATORS, e->src) != ybb)
1362:                 continue;
1363:
1364:               dom = nearest_common_dominator (CDI_DOMINATORS, dom, e->src);
1365:             }
1366:         }
1367:
1368:       gcc_assert (dom != NULL);
1369:       FOR_EACH_VEC_ELT (sccs[i], si, a)
1370:         {
1371:           bb = bbs[a];
1372:           set_immediate_dominator (CDI_DOMINATORS, bb, dom);
1373:         }
1374:     }
1375:
1376:   for (i = 0; i < nc; i++)
1377:     sccs[i].release ();
1378:   free (sccs);
1379:
1380:   for (a = son[y]; a != -1; a = brother[a])
1381:     identify_vertices (g, y, a);
1382: }
1383:
1384: /* Recompute dominance information for basic blocks in the set BBS.  The
1385:    function assumes that the immediate dominators of all the other blocks
1386:    in CFG are correct, and that there are no unreachable blocks.
1387:
1388:    If CONSERVATIVE is true, we additionally assume that all the ancestors of
1389:    a block of BBS in the current dominance tree dominate it.  */
1390:
1391: void
1392: iterate_fix_dominators (enum cdi_direction dir, vec<basic_block> &bbs,
1393:                         bool conservative)
1394: {
1395:   unsigned i;
1396:   basic_block bb, dom;
1397:   struct graph *g;
1398:   int n, y;
1399:   size_t dom_i;
1400:   edge e;
1401:   edge_iterator ei;
1402:   int *parent, *son, *brother;
1403:   unsigned int dir_index = dom_convert_dir_to_idx (dir);
1404:
1405:   /* We only support updating dominators.  There are some problems with
1406:      updating postdominators (need to add fake edges from infinite loops
1407:      and noreturn functions), and since we do not currently use
1408:      iterate_fix_dominators for postdominators, any attempt to handle these
1409:      problems would be unused, untested, and almost surely buggy.  We keep
1410:      the DIR argument for consistency with the rest of the dominator analysis
1411:      interface.  */
1412:   gcc_checking_assert (dir == CDI_DOMINATORS && dom_computed[dir_index]);
1413:
1414:   /* The algorithm we use takes inspiration from the following papers, although
1415:      the details are quite different from any of them:
1416:
1417:      [1] G. Ramalingam, T. Reps, An Incremental Algorithm for Maintaining the
1418:          Dominator Tree of a Reducible Flowgraph
1419:      [2]  V. C. Sreedhar, G. R. Gao, Y.-F. Lee: Incremental computation of
1420:           dominator trees
1421:      [3]  K. D. Cooper, T. J. Harvey and K. Kennedy: A Simple, Fast Dominance
1422:           Algorithm
1423:
1424:      First, we use the following heuristics to decrease the size of the BBS
1425:      set:
1426:        a) if BB has a single predecessor, then its immediate dominator is this
1427:           predecessor
1428:        additionally, if CONSERVATIVE is true:
1429:        b) if all the predecessors of BB except for one (X) are dominated by BB,
1430:           then X is the immediate dominator of BB
1431:        c) if the nearest common ancestor of the predecessors of BB is X and
1432:           X -> BB is an edge in CFG, then X is the immediate dominator of BB
1433:
1434:      Then, we need to establish the dominance relation among the basic blocks
1435:      in BBS.  We split the dominance tree by removing the immediate dominator
1436:      edges from BBS, creating a forest F.  We form a graph G whose vertices
1437:      are BBS and ENTRY and X -> Y is an edge of G if there exists an edge
1438:      X' -> Y in CFG such that X' belongs to the tree of the dominance forest
1439:      whose root is X.  We then determine dominance tree of G.  Note that
1440:      for X, Y in BBS, X dominates Y in CFG if and only if X dominates Y in G.
1441:      In this step, we can use arbitrary algorithm to determine dominators.
1442:      We decided to prefer the algorithm [3] to the algorithm of
1443:      Lengauer and Tarjan, since the set BBS is usually small (rarely exceeding
1444:      10 during gcc bootstrap), and [3] should perform better in this case.
1445:
1446:      Finally, we need to determine the immediate dominators for the basic
1447:      blocks of BBS.  If the immediate dominator of X in G is Y, then
1448:      the immediate dominator of X in CFG belongs to the tree of F rooted in
1449:      Y.  We process the dominator tree T of G recursively, starting from leaves.
1450:      Suppose that X_1, X_2, ..., X_k are the sons of Y in T, and that the
1451:      subtrees of the dominance tree of CFG rooted in X_i are already correct.
1452:      Let G' be the subgraph of G induced by {X_1, X_2, ..., X_k}.  We make
1453:      the following observations:
1454:        (i) the immediate dominator of all blocks in a strongly connected
1455:            component of G' is the same
1456:        (ii) if X has no predecessors in G', then the immediate dominator of X
1457:             is the nearest common ancestor of the predecessors of X in the
1458:             subtree of F rooted in Y
1459:      Therefore, it suffices to find the topological ordering of G', and
1460:      process the nodes X_i in this order using the rules (i) and (ii).
1461:      Then, we contract all the nodes X_i with Y in G, so that the further
1462:      steps work correctly.  */
1463:
1464:   if (!conservative)
1465:     {
1466:       /* Split the tree now.  If the idoms of blocks in BBS are not
1467:          conservatively correct, setting the dominators using the
1468:          heuristics in prune_bbs_to_update_dominators could
1469:          create cycles in the dominance "tree", and cause ICE.  */
1470:       FOR_EACH_VEC_ELT (bbs, i, bb)
1471:         set_immediate_dominator (CDI_DOMINATORS, bb, NULL);
1472:     }
1473:
1474:   prune_bbs_to_update_dominators (bbs, conservative);
1475:   n = bbs.length ();
1476:
1477:   if (n == 0)
1478:     return;
1479:
1480:   if (n == 1)
1481:     {
1482:       bb = bbs[0];
1483:       set_immediate_dominator (CDI_DOMINATORS, bb,
1484:                                recompute_dominator (CDI_DOMINATORS, bb));
1485:       return;
1486:     }
1487:
1488:   timevar_push (TV_DOMINANCE);
1489:
1490:   /* Construct the graph G.  */
1491:   hash_map<basic_block, int> map (251);
1492:   FOR_EACH_VEC_ELT (bbs, i, bb)
1493:     {
1494:       /* If the dominance tree is conservatively correct, split it now.  */
1495:       if (conservative)
1496:         set_immediate_dominator (CDI_DOMINATORS, bb, NULL);
1497:       map.put (bb, i);
1498:     }
1499:   map.put (ENTRY_BLOCK_PTR_FOR_FN (cfun), n);
1500:
1501:   g = new_graph (n + 1);
1502:   for (y = 0; y < g->n_vertices; y++)
1503:     g->vertices[y].data = BITMAP_ALLOC (NULL);
1504:   FOR_EACH_VEC_ELT (bbs, i, bb)
1505:     {
1506:       FOR_EACH_EDGE (e, ei, bb->preds)
1507:         {
1508:           dom = root_of_dom_tree (CDI_DOMINATORS, e->src);
1509:           if (dom == bb)
1510:             continue;
1511:
1512:           dom_i = *map.get (dom);
1513:
1514:           /* Do not include parallel edges to G.  */
1515:           if (!bitmap_set_bit ((bitmap) g->vertices[dom_i].data, i))
1516:             continue;
1517:
1518:           add_edge (g, dom_i, i);
1519:         }
1520:     }
1521:   for (y = 0; y < g->n_vertices; y++)
1522:     BITMAP_FREE (g->vertices[y].data);
1523:
1524:   /* Find the dominator tree of G.  */
1525:   son = XNEWVEC (int, n + 1);
1526:   brother = XNEWVEC (int, n + 1);
1527:   parent = XNEWVEC (int, n + 1);
1528:   graphds_domtree (g, n, parent, son, brother);
1529:
1530:   /* Finally, traverse the tree and find the immediate dominators.  */
1531:   for (y = n; son[y] != -1; y = son[y])
1532:     continue;
1533:   while (y != -1)
1534:     {
1535:       determine_dominators_for_sons (g, bbs, y, son, brother);
1536:
1537:       if (brother[y] != -1)
1538:         {
1539:           y = brother[y];
1540:           while (son[y] != -1)
1541:             y = son[y];
1542:         }
1543:       else
1544:         y = parent[y];
1545:     }
1546:
1547:   free (son);
1548:   free (brother);
1549:   free (parent);
1550:
1551:   free_graph (g);
1552:
1553:   timevar_pop (TV_DOMINANCE);
1554: }
1555:
1556: void
1557: add_to_dominance_info (enum cdi_direction dir, basic_block bb)
1558: {
```

## gcc/dominance.h:67–79

```text
67: extern void verify_dominators (enum cdi_direction);
68:
69: /* Verify invariants of computed dominance information, if internal consistency
70:    checks are enabled.  */
71:
72: inline void
73: checking_verify_dominators (cdi_direction dir)
74: {
75:   if (flag_checking)
76:     verify_dominators (dir);
77: }
78:
79: basic_block recompute_dominator (enum cdi_direction, basic_block);
```

## gcc/et-forest.cc:37–83

```text
37: #include "hard-reg-set.h"
38: #endif
39:
40: /* The occurrence of a node in the et tree.  */
41: struct et_occ
42: {
43:   struct et_node *of;           /* The node.  */
44:
45:   struct et_occ *parent;        /* Parent in the splay-tree.  */
46:   struct et_occ *prev;          /* Left son in the splay-tree.  */
47:   struct et_occ *next;          /* Right son in the splay-tree.  */
48:
49:   int depth;                    /* The depth of the node is the sum of depth
50:                                    fields on the path to the root.  */
51:   int min;                      /* The minimum value of the depth in the subtree
52:                                    is obtained by adding sum of depth fields
53:                                    on the path to the root.  */
54:   struct et_occ *min_occ;       /* The occurrence in the subtree with the minimal
55:                                    depth.  */
56: };
57:
58: static object_allocator<et_node> et_nodes ("et_nodes pool");
59: static object_allocator<et_occ> et_occurrences ("et_occ pool");
60:
61: /* Changes depth of OCC to D.  */
62:
63: static inline void
64: set_depth (struct et_occ *occ, int d)
65: {
66:   if (!occ)
67:     return;
68:
69:   occ->min += d - occ->depth;
70:   occ->depth = d;
71: }
72:
73: /* Adds D to the depth of OCC.  */
74:
75: static inline void
76: set_depth_add (struct et_occ *occ, int d)
77: {
78:   if (!occ)
79:     return;
80:
81:   occ->min += d;
82:   occ->depth += d;
83: }
```

## gcc/et-forest.cc:114–135

```text
114:
115: static inline void
116: et_recomp_min (struct et_occ *occ)
117: {
118:   struct et_occ *mson = occ->prev;
119:
120:   if (!mson
121:       || (occ->next
122:           && mson->min > occ->next->min))
123:       mson = occ->next;
124:
125:   if (mson && mson->min < 0)
126:     {
127:       occ->min = mson->min + occ->depth;
128:       occ->min_occ = mson->min_occ;
129:     }
130:   else
131:     {
132:       occ->min = occ->depth;
133:       occ->min_occ = occ;
134:     }
135: }
```

## gcc/et-forest.cc:295–445

```text
295: }
296:
297: #endif
298:
299: /* Splay the occurrence OCC to the root of the tree.  */
300:
301: static void
302: et_splay (struct et_occ *occ)
303: {
304:   struct et_occ *f, *gf, *ggf;
305:   int occ_depth, f_depth, gf_depth;
306:
307: #ifdef DEBUG_ET
308:   record_path_before (occ);
309:   et_check_tree_sanity (occ);
310: #endif
311:
312:   while (occ->parent)
313:     {
314:       occ_depth = occ->depth;
315:
316:       f = occ->parent;
317:       f_depth = f->depth;
318:
319:       gf = f->parent;
320:
321:       if (!gf)
322:         {
323:           set_depth_add (occ, f_depth);
324:           occ->min_occ = f->min_occ;
325:           occ->min = f->min;
326:
327:           if (f->prev == occ)
328:             {
329:               /* zig */
330:               set_prev (f, occ->next);
331:               set_next (occ, f);
332:               set_depth_add (f->prev, occ_depth);
333:             }
334:           else
335:             {
336:               /* zag */
337:               set_next (f, occ->prev);
338:               set_prev (occ, f);
339:               set_depth_add (f->next, occ_depth);
340:             }
341:           set_depth (f, -occ_depth);
342:           occ->parent = NULL;
343:
344:           et_recomp_min (f);
345: #ifdef DEBUG_ET
346:           et_check_tree_sanity (occ);
347:           check_path_after (occ);
348: #endif
349:           return;
350:         }
351:
352:       gf_depth = gf->depth;
353:
354:       set_depth_add (occ, f_depth + gf_depth);
355:       occ->min_occ = gf->min_occ;
356:       occ->min = gf->min;
357:
358:       ggf = gf->parent;
359:
360:       if (gf->prev == f)
361:         {
362:           if (f->prev == occ)
363:             {
364:               /* zig zig */
365:               set_prev (gf, f->next);
366:               set_prev (f, occ->next);
367:               set_next (occ, f);
368:               set_next (f, gf);
369:
370:               set_depth (f, -occ_depth);
371:               set_depth_add (f->prev, occ_depth);
372:               set_depth (gf, -f_depth);
373:               set_depth_add (gf->prev, f_depth);
374:             }
375:           else
376:             {
377:               /* zag zig */
378:               set_prev (gf, occ->next);
379:               set_next (f, occ->prev);
380:               set_prev (occ, f);
381:               set_next (occ, gf);
382:
383:               set_depth (f, -occ_depth);
384:               set_depth_add (f->next, occ_depth);
385:               set_depth (gf, -occ_depth - f_depth);
386:               set_depth_add (gf->prev, occ_depth + f_depth);
387:             }
388:         }
389:       else
390:         {
391:           if (f->prev == occ)
392:             {
393:               /* zig zag */
394:               set_next (gf, occ->prev);
395:               set_prev (f, occ->next);
396:               set_prev (occ, gf);
397:               set_next (occ, f);
398:
399:               set_depth (f, -occ_depth);
400:               set_depth_add (f->prev, occ_depth);
401:               set_depth (gf, -occ_depth - f_depth);
402:               set_depth_add (gf->next, occ_depth + f_depth);
403:             }
404:           else
405:             {
406:               /* zag zag */
407:               set_next (gf, f->prev);
408:               set_next (f, occ->prev);
409:               set_prev (occ, f);
410:               set_prev (f, gf);
411:
412:               set_depth (f, -occ_depth);
413:               set_depth_add (f->next, occ_depth);
414:               set_depth (gf, -f_depth);
415:               set_depth_add (gf->next, f_depth);
416:             }
417:         }
418:
419:       occ->parent = ggf;
420:       if (ggf)
421:         {
422:           if (ggf->prev == gf)
423:             ggf->prev = occ;
424:           else
425:             ggf->next = occ;
426:         }
427:
428:       et_recomp_min (gf);
429:       et_recomp_min (f);
430: #ifdef DEBUG_ET
431:       et_check_tree_sanity (occ);
432: #endif
433:     }
434:
435: #ifdef DEBUG_ET
436:   et_check_sanity (occ);
437:   check_path_after (occ);
438: #endif
439: }
440:
441: /* Create a new et tree occurrence of NODE.  */
442:
443: static struct et_occ *
444: et_new_occ (struct et_node *node)
445: {
```

## gcc/et-forest.cc:463–774

```text
463: et_new_tree (void *data)
464: {
465:   et_node *nw = et_nodes.allocate ();
466:
467:   nw->data = data;
468:   nw->father = NULL;
469:   nw->left = NULL;
470:   nw->right = NULL;
471:   nw->son = NULL;
472:
473:   nw->rightmost_occ = et_new_occ (nw);
474:   nw->parent_occ = NULL;
475:
476:   return nw;
477: }
478:
479: /* Releases et tree T.  */
480:
481: void
482: et_free_tree (struct et_node *t)
483: {
484:   while (t->son)
485:     et_split (t->son);
486:
487:   if (t->father)
488:     et_split (t);
489:
490:   et_occurrences.remove (t->rightmost_occ);
491:   et_nodes.remove (t);
492: }
493:
494: /* Releases et tree T without maintaining other nodes.  */
495:
496: void
497: et_free_tree_force (struct et_node *t)
498: {
499:   et_occurrences.remove (t->rightmost_occ);
500:   if (t->parent_occ)
501:     et_occurrences.remove (t->parent_occ);
502:   et_nodes.remove (t);
503: }
504:
505: /* Release the alloc pools, if they are empty.  */
506:
507: void
508: et_free_pools (void)
509: {
510:   et_occurrences.release_if_empty ();
511:   et_nodes.release_if_empty ();
512: }
513:
514: /* Sets father of et tree T to FATHER.  */
515:
516: void
517: et_set_father (struct et_node *t, struct et_node *father)
518: {
519:   struct et_node *left, *right;
520:   struct et_occ *rmost, *left_part, *new_f_occ, *p;
521:
522:   /* Update the path represented in the splay tree.  */
523:   new_f_occ = et_new_occ (father);
524:
525:   rmost = father->rightmost_occ;
526:   et_splay (rmost);
527:
528:   left_part = rmost->prev;
529:
530:   p = t->rightmost_occ;
531:   et_splay (p);
532:
533:   set_prev (new_f_occ, left_part);
534:   set_next (new_f_occ, p);
535:
536:   p->depth++;
537:   p->min++;
538:   et_recomp_min (new_f_occ);
539:
540:   set_prev (rmost, new_f_occ);
541:
542:   if (new_f_occ->min + rmost->depth < rmost->min)
543:     {
544:       rmost->min = new_f_occ->min + rmost->depth;
545:       rmost->min_occ = new_f_occ->min_occ;
546:     }
547:
548:   t->parent_occ = new_f_occ;
549:
550:   /* Update the tree.  */
551:   t->father = father;
552:   right = father->son;
553:   if (right)
554:     left = right->left;
555:   else
556:     left = right = t;
557:
558:   left->right = t;
559:   right->left = t;
560:   t->left = left;
561:   t->right = right;
562:
563:   father->son = t;
564:
565: #ifdef DEBUG_ET
566:   et_check_tree_sanity (rmost);
567:   record_path_before (rmost);
568: #endif
569: }
570:
571: /* Splits the edge from T to its father.  */
572:
573: void
574: et_split (struct et_node *t)
575: {
576:   struct et_node *father = t->father;
577:   struct et_occ *r, *l, *rmost, *p_occ;
578:
579:   /* Update the path represented by the splay tree.  */
580:   rmost = t->rightmost_occ;
581:   et_splay (rmost);
582:
583:   for (r = rmost->next; r->prev; r = r->prev)
584:     continue;
585:   et_splay (r);
586:
587:   r->prev->parent = NULL;
588:   p_occ = t->parent_occ;
589:   et_splay (p_occ);
590:   t->parent_occ = NULL;
591:
592:   l = p_occ->prev;
593:   p_occ->next->parent = NULL;
594:
595:   set_prev (r, l);
596:
597:   et_recomp_min (r);
598:
599:   et_splay (rmost);
600:   rmost->depth = 0;
601:   rmost->min = 0;
602:
603:   et_occurrences.remove (p_occ);
604:
605:   /* Update the tree.  */
606:   if (father->son == t)
607:     father->son = t->right;
608:   if (father->son == t)
609:     father->son = NULL;
610:   else
611:     {
612:       t->left->right = t->right;
613:       t->right->left = t->left;
614:     }
615:   t->left = t->right = NULL;
616:   t->father = NULL;
617:
618: #ifdef DEBUG_ET
619:   et_check_tree_sanity (rmost);
620:   record_path_before (rmost);
621:
622:   et_check_tree_sanity (r);
623:   record_path_before (r);
624: #endif
625: }
626:
627: /* Finds the nearest common ancestor of the nodes N1 and N2.  */
628:
629: struct et_node *
630: et_nca (struct et_node *n1, struct et_node *n2)
631: {
632:   struct et_occ *o1 = n1->rightmost_occ, *o2 = n2->rightmost_occ, *om;
633:   struct et_occ *l, *r, *ret;
634:   int mn;
635:
636:   if (n1 == n2)
637:     return n1;
638:
639:   et_splay (o1);
640:   l = o1->prev;
641:   r = o1->next;
642:   if (l)
643:     l->parent = NULL;
644:   if (r)
645:     r->parent = NULL;
646:   et_splay (o2);
647:
648:   if (l == o2 || (l && l->parent != NULL))
649:     {
650:       ret = o2->next;
651:
652:       set_prev (o1, o2);
653:       if (r)
654:         r->parent = o1;
655:     }
656:   else if (r == o2 || (r && r->parent != NULL))
657:     {
658:       ret = o2->prev;
659:
660:       set_next (o1, o2);
661:       if (l)
662:         l->parent = o1;
663:     }
664:   else
665:     {
666:       /* O1 and O2 are in different components of the forest.  */
667:       if (l)
668:         l->parent = o1;
669:       if (r)
670:         r->parent = o1;
671:       return NULL;
672:     }
673:
674:   if (o2->depth > 0)
675:     {
676:       om = o1;
677:       mn = o1->depth;
678:     }
679:   else
680:     {
681:       om = o2;
682:       mn = o2->depth + o1->depth;
683:     }
684:
685: #ifdef DEBUG_ET
686:   et_check_tree_sanity (o2);
687: #endif
688:
689:   if (ret && ret->min + o1->depth + o2->depth < mn)
690:     return ret->min_occ->of;
691:   else
692:     return om->of;
693: }
694:
695: /* Checks whether the node UP is an ancestor of the node DOWN.  */
696:
697: bool
698: et_below (struct et_node *down, struct et_node *up)
699: {
700:   struct et_occ *u = up->rightmost_occ, *d = down->rightmost_occ;
701:   struct et_occ *l, *r;
702:
703:   if (up == down)
704:     return true;
705:
706:   et_splay (u);
707:   l = u->prev;
708:   r = u->next;
709:
710:   if (!l)
711:     return false;
712:
713:   l->parent = NULL;
714:
715:   if (r)
716:     r->parent = NULL;
717:
718:   et_splay (d);
719:
720:   if (l == d || l->parent != NULL)
721:     {
722:       if (r)
723:         r->parent = u;
724:       set_prev (u, d);
725: #ifdef DEBUG_ET
726:       et_check_tree_sanity (u);
727: #endif
728:     }
729:   else
730:     {
731:       l->parent = u;
732:
733:       /* In case O1 and O2 are in two different trees, we must just restore the
734:          original state.  */
735:       if (r && r->parent != NULL)
736:         set_next (u, d);
737:       else
738:         set_next (u, r);
739:
740: #ifdef DEBUG_ET
741:       et_check_tree_sanity (u);
742: #endif
743:       return false;
744:     }
745:
746:   if (d->depth <= 0)
747:     return false;
748:
749:   return !d->next || d->next->min + d->depth >= 0;
750: }
751:
752: /* Returns the root of the tree that contains NODE.  */
753:
754: struct et_node *
755: et_root (struct et_node *node)
756: {
757:   struct et_occ *occ = node->rightmost_occ, *r;
758:
759:   /* The root of the tree corresponds to the rightmost occurrence in the
760:      represented path.  */
761:   et_splay (occ);
762:   for (r = occ; r->next; r = r->next)
763:     continue;
764:   et_splay (r);
765:
766:   return r->of;
767: }
768:
769: #if CHECKING_P
770:
771: namespace selftest {
772:
773: /* Selftests for et-forest.cc.  */
774:
```

## gcc/et-forest.h:62–81

```text
62:   struct et_node *father;       /* Father of the node.  */
63:   struct et_node *son;          /* The first of the sons of the node.  */
64:   struct et_node *left;
65:   struct et_node *right;        /* The brothers of the node.  */
66:
67:   struct et_occ *rightmost_occ; /* The rightmost occurrence.  */
68:   struct et_occ *parent_occ;    /* The occurrence of the parent node.  */
69: };
70:
71: struct et_node *et_new_tree (void *data);
72: void et_free_tree (struct et_node *);
73: void et_free_tree_force (struct et_node *);
74: void et_free_pools (void);
75: void et_set_father (struct et_node *, struct et_node *);
76: void et_split (struct et_node *);
77: struct et_node *et_nca (struct et_node *, struct et_node *);
78: bool et_below (struct et_node *, struct et_node *);
79: struct et_node *et_root (struct et_node *);
80:
81: #ifdef __cplusplus
```

## gcc/alloc-pool.h:160–198

```text
160:   void initialize ();
161:
162:   struct allocation_object
163:   {
164: #if CHECKING_P
165:     /* The ID of alloc pool which the object was allocated from.  */
166:     ALLOC_POOL_ID_TYPE id;
167: #endif
168:
169:     union
170:       {
171:         /* The data of the object.  */
172:         char data[1];
173:
174:         /* Because we want any type of data to be well aligned after the ID,
175:            the following elements are here.  They are never accessed so
176:            the allocated object may be even smaller than this structure.
177:            We do not care about alignment for floating-point types.  */
178:         char *align_p;
179:         int64_t align_i;
180:       } u;
181:
182: #if CHECKING_P
183:     static inline allocation_object*
184:     get_instance (void *data_ptr)
185:     {
186:       return (allocation_object *)(((char *)(data_ptr))
187:                                       - offsetof (allocation_object,
188:                                                   u.data));
189:     }
190: #endif
191:
192:     static inline void*
193:     get_data (void *instance_ptr)
194:     {
195:       return (void*)(((allocation_object *) instance_ptr)->u.data);
196:     }
197:   };
198:
```

## gcc/alloc-pool.h:261–307

```text
261:   gcc_checking_assert (m_size);
262:
263:   /* Make size large enough to store the list header.  */
264:   if (size < sizeof (allocation_pool_list*))
265:     size = sizeof (allocation_pool_list*);
266:
267:   /* Now align the size to a multiple of 8.  */
268:   size = align_eight (size);
269:
270:   /* Add the aligned size of ID.  */
271:   size += offsetof (allocation_object, u.data);
272:
273:   m_elt_size = size;
274:
275:   if (GATHER_STATISTICS)
276:     {
277:       pool_usage *u = pool_allocator_usage.register_descriptor
278:         (this, new mem_location (m_location));
279:
280:       u->m_element_size = m_elt_size;
281:       u->m_pool_name = m_name;
282:     }
283:
284:   /* List header size should be a multiple of 8.  */
285:   size_t header_size = align_eight (sizeof (allocation_pool_list));
286:
287:   m_elts_per_block = (TBlockAllocator::block_size - header_size) / size;
288:   gcc_checking_assert (m_elts_per_block != 0);
289:
290:   /* Increase the last used ID and use it for this pool.
291:      ID == 0 is used for free elements of pool so skip it.  */
292:   last_id++;
293:   if (last_id == 0)
294:     last_id++;
295:
296:   m_id = last_id;
297: }
298:
299: /* Free all memory allocated for the given memory pool.  */
300: template <typename TBlockAllocator>
301: inline void
302: base_pool_allocator <TBlockAllocator>::release ()
303: {
304:   if (!m_initialized)
305:     return;
306:
307:   allocation_pool_list *block, *next_block;
```

## gcc/alloc-pool.h:351–430

```text
351:     initialize ();
352:
353:   allocation_pool_list *header;
354: #ifdef ENABLE_VALGRIND_ANNOTATIONS
355:   int size;
356: #endif
357:
358:   if (GATHER_STATISTICS)
359:     {
360:       pool_allocator_usage.register_instance_overhead (m_elt_size, this);
361:     }
362:
363: #ifdef ENABLE_VALGRIND_ANNOTATIONS
364:   size = m_elt_size - offsetof (allocation_object, u.data);
365: #endif
366:
367:   /* If there are no more free elements, make some more!.  */
368:   if (!m_returned_free_list)
369:     {
370:       char *block;
371:       if (!m_virgin_elts_remaining)
372:         {
373:           allocation_pool_list *block_header;
374:
375:           /* Make the block.  */
376:           block = reinterpret_cast<char *> (TBlockAllocator::allocate ());
377:           block_header = new (block) allocation_pool_list;
378:           block += align_eight (sizeof (allocation_pool_list));
379:
380:           /* Throw it on the block list.  */
381:           block_header->next = m_block_list;
382:           m_block_list = block_header;
383:
384:           /* Make the block available for allocation.  */
385:           m_virgin_free_list = block;
386:           m_virgin_elts_remaining = m_elts_per_block;
387:
388:           /* Also update the number of elements we have free/allocated, and
389:              increment the allocated block count.  */
390:           m_elts_allocated += m_elts_per_block;
391:           m_elts_free += m_elts_per_block;
392:           m_blocks_allocated += 1;
393:         }
394:
395:       /* We now know that we can take the first elt off the virgin list and
396:          put it on the returned list.  */
397:       block = m_virgin_free_list;
398:       header = (allocation_pool_list*) allocation_object::get_data (block);
399:       header->next = NULL;
400:
401:       /* Mark the element to be free.  */
402: #if CHECKING_P
403:       ((allocation_object*) block)->id = 0;
404: #endif
405:       VALGRIND_DISCARD (VALGRIND_MAKE_MEM_NOACCESS (header,size));
406:       m_returned_free_list = header;
407:       m_virgin_free_list += m_elt_size;
408:       m_virgin_elts_remaining--;
409:
410:     }
411:
412:   /* Pull the first free element from the free list, and return it.  */
413:   header = m_returned_free_list;
414:   VALGRIND_DISCARD (VALGRIND_MAKE_MEM_DEFINED (header, sizeof (*header)));
415:   m_returned_free_list = header->next;
416:   m_elts_free--;
417:
418:   /* Set the ID for element.  */
419: #if CHECKING_P
420:   allocation_object::get_instance (header)->id = m_id;
421: #endif
422:   VALGRIND_DISCARD (VALGRIND_MAKE_MEM_UNDEFINED (header, size));
423:
424:   return (void *)(header);
425: }
426:
427: /* Puts PTR back on POOL's free list.  */
428: template <typename TBlockAllocator>
429: inline void
430: base_pool_allocator <TBlockAllocator>::remove (void *object)
```

## gcc/memory-block.h:25–84

```text
25:    memory blocks instead of calling free/malloc again.  */
26: class memory_block_pool
27: {
28: public:
29:   /* Blocks have fixed size.  This is necessary for sharing.  */
30:   static const size_t block_size = 64 * 1024;
31:   /* Number of blocks we keep in the freelists.  */
32:   static const size_t freelist_size = 1024 * 1024 / block_size;
33:
34:   memory_block_pool ();
35:
36:   static inline void *allocate () ATTRIBUTE_MALLOC;
37:   static inline void release (void *);
38:   static void trim (int nblocks = freelist_size);
39:   void reduce_free_list (int);
40:
41: private:
42:   /* memory_block_pool singleton instance, defined in memory-block.cc.  */
43:   static memory_block_pool instance;
44:
45:   struct block_list
46:   {
47:     block_list *m_next;
48:   };
49:
50:   /* Free list.  */
51:   block_list *m_blocks;
52: };
53:
54: /* Allocate a single block.  Reuse a previously returned block, if possible.  */
55: inline void *
56: memory_block_pool::allocate ()
57: {
58:   if (instance.m_blocks == NULL)
59:     return XNEWVEC (char, block_size);
60:
61:   void *result = instance.m_blocks;
62:   instance.m_blocks = instance.m_blocks->m_next;
63:   VALGRIND_DISCARD (VALGRIND_MAKE_MEM_UNDEFINED (result, block_size));
64:   return result;
65: }
66:
67: /* Return UNCAST_BLOCK to the pool.  */
68: inline void
69: memory_block_pool::release (void *uncast_block)
70: {
71:   block_list *block = new (uncast_block) block_list;
72:   block->m_next = instance.m_blocks;
73:   instance.m_blocks = block;
74:
75:   VALGRIND_DISCARD (VALGRIND_MAKE_MEM_NOACCESS ((char *)uncast_block
76:                                                 + sizeof (block_list),
77:                                                 block_size
78:                                                 - sizeof (block_list)));
79: }
80:
81: extern void *mempool_obstack_chunk_alloc (size_t) ATTRIBUTE_MALLOC;
82: extern void mempool_obstack_chunk_free (void *);
83:
84: #endif /* MEMORY_BLOCK_H */
```

## gcc/graphds.h:22–49

```text
22:
23: /* Structure representing edge of a graph.  */
24:
25: struct graph_edge
26: {
27:   int src, dest;        /* Source and destination.  */
28:   struct graph_edge *pred_next, *succ_next;
29:                         /* Next edge in predecessor and successor lists.  */
30:   void *data;           /* Data attached to the edge.  */
31: };
32:
33: /* Structure representing vertex of a graph.  */
34:
35: struct vertex
36: {
37:   struct graph_edge *pred, *succ;
38:                         /* Lists of predecessors and successors.  */
39:   int component;        /* Number of dfs restarts before reaching the
40:                            vertex.  */
41:   int post;             /* Postorder number.  */
42:   void *data;           /* Data attached to the vertex.  */
43: };
44:
45: /* Structure representing a graph.  */
46:
47: struct graph
48: {
49:   int n_vertices;          /* Number of vertices.  */
```

## gcc/graphds.cc:47–111

```text
47: /* Creates a new graph with N_VERTICES vertices.  */
48:
49: struct graph *
50: new_graph (int n_vertices)
51: {
52:   struct graph *g = XNEW (struct graph);
53:
54:   gcc_obstack_init (&g->ob);
55:   g->n_vertices = n_vertices;
56:   g->vertices = XOBNEWVEC (&g->ob, struct vertex, n_vertices);
57:   memset (g->vertices, 0, sizeof (struct vertex) * n_vertices);
58:
59:   return g;
60: }
61:
62: /* Adds an edge from F to T to graph G.  The new edge is returned.  */
63:
64: struct graph_edge *
65: add_edge (struct graph *g, int f, int t)
66: {
67:   struct graph_edge *e = XOBNEW (&g->ob, struct graph_edge);
68:   struct vertex *vf = &g->vertices[f], *vt = &g->vertices[t];
69:
70:   e->src = f;
71:   e->dest = t;
72:
73:   e->pred_next = vt->pred;
74:   vt->pred = e;
75:
76:   e->succ_next = vf->succ;
77:   vf->succ = e;
78:
79:   e->data = NULL;
80:   return e;
81: }
82:
83: /* Moves all the edges incident with U to V.  */
84:
85: void
86: identify_vertices (struct graph *g, int v, int u)
87: {
88:   struct vertex *vv = &g->vertices[v];
89:   struct vertex *uu = &g->vertices[u];
90:   struct graph_edge *e, *next;
91:
92:   for (e = uu->succ; e; e = next)
93:     {
94:       next = e->succ_next;
95:
96:       e->src = v;
97:       e->succ_next = vv->succ;
98:       vv->succ = e;
99:     }
100:   uu->succ = NULL;
101:
102:   for (e = uu->pred; e; e = next)
103:     {
104:       next = e->pred_next;
105:
106:       e->dest = v;
107:       e->pred_next = vv->pred;
108:       vv->pred = e;
109:     }
110:   uu->pred = NULL;
111: }
```

## gcc/graphds.cc:198–330

```text
198: int
199: graphds_dfs (struct graph *g, int *qs, int nq, vec<int> *qt,
200:              bool forward, bitmap subgraph,
201:              skip_edge_callback skip_edge_p)
202: {
203:   int i, tick = 0, v, comp = 0, top;
204:   struct graph_edge *e;
205:   struct graph_edge **stack = XNEWVEC (struct graph_edge *, g->n_vertices);
206:   bitmap_iterator bi;
207:   unsigned av;
208:
209:   if (subgraph)
210:     {
211:       EXECUTE_IF_SET_IN_BITMAP (subgraph, 0, av, bi)
212:         {
213:           g->vertices[av].component = -1;
214:           g->vertices[av].post = -1;
215:         }
216:     }
217:   else
218:     {
219:       for (i = 0; i < g->n_vertices; i++)
220:         {
221:           g->vertices[i].component = -1;
222:           g->vertices[i].post = -1;
223:         }
224:     }
225:
226:   for (i = 0; i < nq; i++)
227:     {
228:       v = qs[i];
229:       if (g->vertices[v].post != -1)
230:         continue;
231:
232:       g->vertices[v].component = comp++;
233:       e = dfs_fst_edge (g, v, forward, subgraph, skip_edge_p);
234:       top = 0;
235:
236:       while (1)
237:         {
238:           while (e)
239:             {
240:               if (g->vertices[dfs_edge_dest (e, forward)].component
241:                   == -1)
242:                 break;
243:               e = dfs_next_edge (e, forward, subgraph, skip_edge_p);
244:             }
245:
246:           if (!e)
247:             {
248:               if (qt)
249:                 qt->safe_push (v);
250:               g->vertices[v].post = tick++;
251:
252:               if (!top)
253:                 break;
254:
255:               e = stack[--top];
256:               v = dfs_edge_src (e, forward);
257:               e = dfs_next_edge (e, forward, subgraph, skip_edge_p);
258:               continue;
259:             }
260:
261:           stack[top++] = e;
262:           v = dfs_edge_dest (e, forward);
263:           e = dfs_fst_edge (g, v, forward, subgraph, skip_edge_p);
264:           g->vertices[v].component = comp - 1;
265:         }
266:     }
267:
268:   free (stack);
269:
270:   return comp;
271: }
272:
273: /* Determines the strongly connected components of G, using the algorithm of
274:    Kosaraju -- first determine the postorder dfs numbering in reversed graph,
275:    then run the dfs on the original graph in the order given by decreasing
276:    numbers assigned by the previous pass.  If SUBGRAPH is not NULL, it
277:    specifies the subgraph of G whose strongly connected components we want
278:    to determine.  If SKIP_EDGE_P is not NULL, it points to a callback function.
279:    Edge E will be skipped if callback function returns true.  If SCC_GROUPING
280:    is not null, the nodes will be added to it in the following order:
281:
282:    - If SCC A is a direct or indirect predecessor of SCC B in the SCC dag,
283:      A's nodes come before B's nodes.
284:
285:    - All of an SCC's nodes are listed consecutively, although the order
286:      of the nodes within an SCC is not really meaningful.
287:
288:    After running this function, v->component is the number of the strongly
289:    connected component for each vertex of G.  Returns the number of the
290:    sccs of G.  */
291:
292: int
293: graphds_scc (struct graph *g, bitmap subgraph,
294:              skip_edge_callback skip_edge_p, vec<int> *scc_grouping)
295: {
296:   int *queue = XNEWVEC (int, g->n_vertices);
297:   vec<int> postorder = vNULL;
298:   int nq, i, comp;
299:   unsigned v;
300:   bitmap_iterator bi;
301:
302:   if (subgraph)
303:     {
304:       nq = 0;
305:       EXECUTE_IF_SET_IN_BITMAP (subgraph, 0, v, bi)
306:         {
307:           queue[nq++] = v;
308:         }
309:     }
310:   else
311:     {
312:       for (i = 0; i < g->n_vertices; i++)
313:         queue[i] = i;
314:       nq = g->n_vertices;
315:     }
316:
317:   graphds_dfs (g, queue, nq, &postorder, false, subgraph, skip_edge_p);
318:   gcc_assert (postorder.length () == (unsigned) nq);
319:
320:   for (i = 0; i < nq; i++)
321:     queue[i] = postorder[nq - i - 1];
322:   comp = graphds_dfs (g, queue, nq, scc_grouping, true, subgraph, skip_edge_p);
323:
324:   free (queue);
325:   postorder.release ();
326:
327:   return comp;
328: }
329:
330: /* Runs CALLBACK for all edges in G.  DATA is private data for CALLBACK.  */
```

## gcc/graphds.cc:357–478

```text
357: tree_nca (int x, int y, int *parent, int *marks, int mark)
358: {
359:   if (x == -1 || x == y)
360:     return y;
361:
362:   /* We climb with X and Y up the tree, marking the visited nodes.  When
363:      we first arrive to a marked node, it is the common ancestor.  */
364:   marks[x] = mark;
365:   marks[y] = mark;
366:
367:   while (1)
368:     {
369:       x = parent[x];
370:       if (x == -1)
371:         break;
372:       if (marks[x] == mark)
373:         return x;
374:       marks[x] = mark;
375:
376:       y = parent[y];
377:       if (y == -1)
378:         break;
379:       if (marks[y] == mark)
380:         return y;
381:       marks[y] = mark;
382:     }
383:
384:   /* If we reached the root with one of the vertices, continue
385:      with the other one till we reach the marked part of the
386:      tree.  */
387:   if (x == -1)
388:     {
389:       for (y = parent[y]; marks[y] != mark; y = parent[y])
390:         continue;
391:
392:       return y;
393:     }
394:   else
395:     {
396:       for (x = parent[x]; marks[x] != mark; x = parent[x])
397:         continue;
398:
399:       return x;
400:     }
401: }
402:
403: /* Determines the dominance tree of G (stored in the PARENT, SON and BROTHER
404:    arrays), where the entry node is ENTRY.  */
405:
406: void
407: graphds_domtree (struct graph *g, int entry,
408:                  int *parent, int *son, int *brother)
409: {
410:   vec<int> postorder = vNULL;
411:   int *marks = XCNEWVEC (int, g->n_vertices);
412:   int mark = 1, i, v, idom;
413:   bool changed = true;
414:   struct graph_edge *e;
415:
416:   /* We use a slight modification of the standard iterative algorithm, as
417:      described in
418:
419:      K. D. Cooper, T. J. Harvey and K. Kennedy: A Simple, Fast Dominance
420:         Algorithm
421:
422:      sort vertices in reverse postorder
423:      foreach v
424:        dom(v) = everything
425:      dom(entry) = entry;
426:
427:      while (anything changes)
428:        foreach v
429:          dom(v) = {v} union (intersection of dom(p) over all predecessors of v)
430:
431:      The sets dom(v) are represented by the parent links in the current version
432:      of the dominance tree.  */
433:
434:   for (i = 0; i < g->n_vertices; i++)
435:     {
436:       parent[i] = -1;
437:       son[i] = -1;
438:       brother[i] = -1;
439:     }
440:   graphds_dfs (g, &entry, 1, &postorder, true, NULL);
441:   gcc_assert (postorder.length () == (unsigned) g->n_vertices);
442:   gcc_assert (postorder[g->n_vertices - 1] == entry);
443:
444:   while (changed)
445:     {
446:       changed = false;
447:
448:       for (i = g->n_vertices - 2; i >= 0; i--)
449:         {
450:           v = postorder[i];
451:           idom = -1;
452:           for (e = g->vertices[v].pred; e; e = e->pred_next)
453:             {
454:               if (e->src != entry
455:                   && parent[e->src] == -1)
456:                 continue;
457:
458:               idom = tree_nca (idom, e->src, parent, marks, mark++);
459:             }
460:
461:           if (idom != parent[v])
462:             {
463:               parent[v] = idom;
464:               changed = true;
465:             }
466:         }
467:     }
468:
469:   free (marks);
470:   postorder.release ();
471:
472:   for (i = 0; i < g->n_vertices; i++)
473:     if (parent[i] != -1)
474:       {
475:         brother[i] = son[parent[i]];
476:         son[parent[i]] = i;
477:       }
478: }
```

## gcc/cfgloop.cc:225–313

```text
225: int
226: flow_loop_nodes_find (basic_block header, class loop *loop)
227: {
228:   vec<basic_block> stack = vNULL;
229:   int num_nodes = 1;
230:   edge latch;
231:   edge_iterator latch_ei;
232:
233:   header->loop_father = loop;
234:
235:   FOR_EACH_EDGE (latch, latch_ei, loop->header->preds)
236:     {
237:       if (latch->src->loop_father == loop
238:           || !dominated_by_p (CDI_DOMINATORS, latch->src, loop->header))
239:         continue;
240:
241:       num_nodes++;
242:       stack.safe_push (latch->src);
243:       latch->src->loop_father = loop;
244:
245:       while (!stack.is_empty ())
246:         {
247:           basic_block node;
248:           edge e;
249:           edge_iterator ei;
250:
251:           node = stack.pop ();
252:
253:           FOR_EACH_EDGE (e, ei, node->preds)
254:             {
255:               basic_block ancestor = e->src;
256:
257:               if (ancestor->loop_father != loop)
258:                 {
259:                   ancestor->loop_father = loop;
260:                   num_nodes++;
261:                   stack.safe_push (ancestor);
262:                 }
263:             }
264:         }
265:     }
266:   stack.release ();
267:
268:   return num_nodes;
269: }
270:
271: /* Records the vector of superloops of the loop LOOP, whose immediate
272:    superloop is FATHER.  */
273:
274: static void
275: establish_preds (class loop *loop, class loop *father)
276: {
277:   loop_p ploop;
278:   unsigned depth = loop_depth (father) + 1;
279:   unsigned i;
280:
281:   loop->superloops = 0;
282:   vec_alloc (loop->superloops, depth);
283:   FOR_EACH_VEC_SAFE_ELT (father->superloops, i, ploop)
284:     loop->superloops->quick_push (ploop);
285:   loop->superloops->quick_push (father);
286:
287:   for (ploop = loop->inner; ploop; ploop = ploop->next)
288:     establish_preds (ploop, loop);
289: }
290:
291: /* Add LOOP to the loop hierarchy tree where FATHER is father of the
292:    added loop.  If LOOP has some children, take care of that their
293:    pred field will be initialized correctly.  If AFTER is non-null
294:    then it's expected it's a pointer into FATHERs inner sibling
295:    list and LOOP is added behind AFTER, otherwise it's added in front
296:    of FATHERs siblings.  */
297:
298: void
299: flow_loop_tree_node_add (class loop *father, class loop *loop,
300:                          class loop *after)
301: {
302:   if (after)
303:     {
304:       loop->next = after->next;
305:       after->next = loop;
306:     }
307:   else
308:     {
309:       loop->next = father->inner;
310:       father->inner = loop;
311:     }
312:
313:   establish_preds (loop, father);
```

## gcc/cfgloop.cc:338–379

```text
338: /* Allocates and returns new loop structure.  */
339:
340: class loop *
341: alloc_loop (void)
342: {
343:   class loop *loop = ggc_cleared_alloc<class loop> ();
344:
345:   loop->exits = ggc_cleared_alloc<loop_exit> ();
346:   loop->exits->next = loop->exits->prev = loop->exits;
347:   loop->can_be_parallel = false;
348:   loop->constraints = 0;
349:   loop->nb_iterations_upper_bound = 0;
350:   loop->nb_iterations_likely_upper_bound = 0;
351:   loop->nb_iterations_estimate = 0;
352:   return loop;
353: }
354:
355: /* Initializes loops structure LOOPS, reserving place for NUM_LOOPS loops
356:    (including the root of the loop tree).  */
357:
358: void
359: init_loops_structure (struct function *fn,
360:                       struct loops *loops, unsigned num_loops)
361: {
362:   class loop *root;
363:
364:   memset (loops, 0, sizeof *loops);
365:   vec_alloc (loops->larray, num_loops);
366:
367:   /* Dummy loop containing whole function.  */
368:   root = alloc_loop ();
369:   root->num_nodes = n_basic_blocks_for_fn (fn);
370:   root->latch = EXIT_BLOCK_PTR_FOR_FN (fn);
371:   root->header = ENTRY_BLOCK_PTR_FOR_FN (fn);
372:   ENTRY_BLOCK_PTR_FOR_FN (fn)->loop_father = root;
373:   EXIT_BLOCK_PTR_FOR_FN (fn)->loop_father = root;
374:
375:   loops->larray->quick_push (root);
376:   loops->tree_root = root;
377: }
378:
379: /* Returns whether HEADER is a loop header.  */
```

## gcc/cfgloop.cc:416–529

```text
416: struct loops *
417: flow_loops_find (struct loops *loops)
418: {
419:   bool from_scratch = (loops == NULL);
420:   int *rc_order;
421:   int b;
422:   unsigned i;
423:
424:   /* Ensure that the dominators are computed.  */
425:   calculate_dominance_info (CDI_DOMINATORS);
426:
427:   if (!loops)
428:     {
429:       loops = ggc_cleared_alloc<struct loops> ();
430:       init_loops_structure (cfun, loops, 1);
431:     }
432:
433:   /* Ensure that loop exits were released.  */
434:   gcc_assert (loops->exits == NULL);
435:
436:   /* Taking care of this degenerate case makes the rest of
437:      this code simpler.  */
438:   if (n_basic_blocks_for_fn (cfun) == NUM_FIXED_BLOCKS)
439:     return loops;
440:
441:   /* The root loop node contains all basic-blocks.  */
442:   loops->tree_root->num_nodes = n_basic_blocks_for_fn (cfun);
443:
444:   /* Compute depth first search order of the CFG so that outer
445:      natural loops will be found before inner natural loops.  */
446:   rc_order = XNEWVEC (int, n_basic_blocks_for_fn (cfun));
447:   pre_and_rev_post_order_compute (NULL, rc_order, false);
448:
449:   /* Gather all loop headers in reverse completion order and allocate
450:      loop structures for loops that are not already present.  */
451:   auto_vec<loop_p> larray (loops->larray->length ());
452:   for (b = 0; b < n_basic_blocks_for_fn (cfun) - NUM_FIXED_BLOCKS; b++)
453:     {
454:       basic_block header = BASIC_BLOCK_FOR_FN (cfun, rc_order[b]);
455:       if (bb_loop_header_p (header))
456:         {
457:           class loop *loop;
458:
459:           /* The current active loop tree has valid loop-fathers for
460:              header blocks.  */
461:           if (!from_scratch
462:               && header->loop_father->header == header)
463:             {
464:               loop = header->loop_father;
465:               /* If we found an existing loop remove it from the
466:                  loop tree.  It is going to be inserted again
467:                  below.  */
468:               flow_loop_tree_node_remove (loop);
469:             }
470:           else
471:             {
472:               /* Otherwise allocate a new loop structure for the loop.  */
473:               loop = alloc_loop ();
474:               /* ???  We could re-use unused loop slots here.  */
475:               loop->num = loops->larray->length ();
476:               vec_safe_push (loops->larray, loop);
477:               loop->header = header;
478:
479:               if (!from_scratch
480:                   && dump_file && (dump_flags & TDF_DETAILS))
481:                 fprintf (dump_file, "flow_loops_find: discovered new "
482:                          "loop %d with header %d\n",
483:                          loop->num, header->index);
484:             }
485:           /* Reset latch, we recompute it below.  */
486:           loop->latch = NULL;
487:           larray.safe_push (loop);
488:         }
489:
490:       /* Make blocks part of the loop root node at start.  */
491:       header->loop_father = loops->tree_root;
492:     }
493:
494:   free (rc_order);
495:
496:   /* Now iterate over the loops found, insert them into the loop tree
497:      and assign basic-block ownership.  */
498:   for (i = 0; i < larray.length (); ++i)
499:     {
500:       class loop *loop = larray[i];
501:       basic_block header = loop->header;
502:       edge_iterator ei;
503:       edge e;
504:
505:       flow_loop_tree_node_add (header->loop_father, loop);
506:       loop->num_nodes = flow_loop_nodes_find (loop->header, loop);
507:
508:       /* Look for the latch for this header block, if it has just a
509:          single one.  */
510:       FOR_EACH_EDGE (e, ei, header->preds)
511:         {
512:           basic_block latch = e->src;
513:
514:           if (flow_bb_inside_loop_p (loop, latch))
515:             {
516:               if (loop->latch != NULL)
517:                 {
518:                   /* More than one latch edge.  */
519:                   loop->latch = NULL;
520:                   break;
521:                 }
522:               loop->latch = latch;
523:             }
524:         }
525:     }
526:
527:   return loops;
528: }
529:
```

## gcc/cfgloop.cc:1392–1565

```text
1392: DEBUG_FUNCTION void
1393: verify_loop_structure (void)
1394: {
1395:   unsigned *sizes, i, j;
1396:   basic_block bb, *bbs;
1397:   int err = 0;
1398:   edge e;
1399:   unsigned num = number_of_loops (cfun);
1400:   struct loop_exit *exit, *mexit;
1401:   bool dom_available = dom_info_available_p (CDI_DOMINATORS);
1402:
1403:   if (loops_state_satisfies_p (LOOPS_NEED_FIXUP))
1404:     {
1405:       error ("loop verification on loop tree that needs fixup");
1406:       err = 1;
1407:     }
1408:
1409:   /* We need up-to-date dominators, compute or verify them.  */
1410:   if (!dom_available)
1411:     calculate_dominance_info (CDI_DOMINATORS);
1412:   else
1413:     verify_dominators (CDI_DOMINATORS);
1414:
1415:   /* Check the loop tree root.  */
1416:   if (current_loops->tree_root->header != ENTRY_BLOCK_PTR_FOR_FN (cfun)
1417:       || current_loops->tree_root->latch != EXIT_BLOCK_PTR_FOR_FN (cfun)
1418:       || (current_loops->tree_root->num_nodes
1419:           != (unsigned) n_basic_blocks_for_fn (cfun)))
1420:     {
1421:       error ("corrupt loop tree root");
1422:       err = 1;
1423:     }
1424:
1425:   /* Check the headers.  */
1426:   FOR_EACH_BB_FN (bb, cfun)
1427:     if (bb_loop_header_p (bb))
1428:       {
1429:         if (bb->loop_father->header == NULL)
1430:           {
1431:             error ("loop with header %d marked for removal", bb->index);
1432:             err = 1;
1433:           }
1434:         else if (bb->loop_father->header != bb)
1435:           {
1436:             error ("loop with header %d not in loop tree", bb->index);
1437:             err = 1;
1438:           }
1439:       }
1440:     else if (bb->loop_father->header == bb)
1441:       {
1442:         error ("non-loop with header %d not marked for removal", bb->index);
1443:         err = 1;
1444:       }
1445:
1446:   /* Check the recorded loop father and sizes of loops.  */
1447:   auto_sbitmap visited (last_basic_block_for_fn (cfun));
1448:   bitmap_clear (visited);
1449:   bbs = XNEWVEC (basic_block, n_basic_blocks_for_fn (cfun));
1450:   for (auto loop : loops_list (cfun, LI_FROM_INNERMOST))
1451:     {
1452:       unsigned n;
1453:
1454:       if (loop->header == NULL)
1455:         {
1456:           error ("removed loop %d in loop tree", loop->num);
1457:           err = 1;
1458:           continue;
1459:         }
1460:
1461:       n = get_loop_body_with_size (loop, bbs, n_basic_blocks_for_fn (cfun));
1462:       if (loop->num_nodes != n)
1463:         {
1464:           error ("size of loop %d should be %d, not %d",
1465:                  loop->num, n, loop->num_nodes);
1466:           err = 1;
1467:         }
1468:
1469:       for (j = 0; j < n; j++)
1470:         {
1471:           bb = bbs[j];
1472:
1473:           if (!flow_bb_inside_loop_p (loop, bb))
1474:             {
1475:               error ("bb %d does not belong to loop %d",
1476:                      bb->index, loop->num);
1477:               err = 1;
1478:             }
1479:
1480:           /* Ignore this block if it is in an inner loop.  */
1481:           if (bitmap_bit_p (visited, bb->index))
1482:             continue;
1483:           bitmap_set_bit (visited, bb->index);
1484:
1485:           if (bb->loop_father != loop)
1486:             {
1487:               error ("bb %d has father loop %d, should be loop %d",
1488:                      bb->index, bb->loop_father->num, loop->num);
1489:               err = 1;
1490:             }
1491:         }
1492:     }
1493:   free (bbs);
1494:
1495:   /* Check headers and latches.  */
1496:   for (auto loop : loops_list (cfun, 0))
1497:     {
1498:       i = loop->num;
1499:       if (loop->header == NULL)
1500:         continue;
1501:       if (!bb_loop_header_p (loop->header))
1502:         {
1503:           error ("loop %d%'s header is not a loop header", i);
1504:           err = 1;
1505:         }
1506:       if (loops_state_satisfies_p (LOOPS_HAVE_PREHEADERS)
1507:           && EDGE_COUNT (loop->header->preds) != 2)
1508:         {
1509:           error ("loop %d%'s header does not have exactly 2 entries", i);
1510:           err = 1;
1511:         }
1512:       if (loop->latch)
1513:         {
1514:           if (!find_edge (loop->latch, loop->header))
1515:             {
1516:               error ("loop %d%'s latch does not have an edge to its header", i);
1517:               err = 1;
1518:             }
1519:           if (!dominated_by_p (CDI_DOMINATORS, loop->latch, loop->header))
1520:             {
1521:               error ("loop %d%'s latch is not dominated by its header", i);
1522:               err = 1;
1523:             }
1524:         }
1525:       if (loops_state_satisfies_p (LOOPS_HAVE_SIMPLE_LATCHES))
1526:         {
1527:           if (!single_succ_p (loop->latch))
1528:             {
1529:               error ("loop %d%'s latch does not have exactly 1 successor", i);
1530:               err = 1;
1531:             }
1532:           if (single_succ (loop->latch) != loop->header)
1533:             {
1534:               error ("loop %d%'s latch does not have header as successor", i);
1535:               err = 1;
1536:             }
1537:           if (loop->latch->loop_father != loop)
1538:             {
1539:               error ("loop %d%'s latch does not belong directly to it", i);
1540:               err = 1;
1541:             }
1542:         }
1543:       if (loop->header->loop_father != loop)
1544:         {
1545:           error ("loop %d%'s header does not belong directly to it", i);
1546:           err = 1;
1547:         }
1548:       if (loops_state_satisfies_p (LOOPS_HAVE_MARKED_IRREDUCIBLE_REGIONS))
1549:         {
1550:           edge_iterator ei;
1551:           FOR_EACH_EDGE (e, ei, loop->header->preds)
1552:             if (dominated_by_p (CDI_DOMINATORS, e->src, loop->header)
1553:                 && e->flags & EDGE_IRREDUCIBLE_LOOP)
1554:               {
1555:                 error ("loop %d%'s latch is marked as part of irreducible"
1556:                        " region", i);
1557:                 err = 1;
1558:               }
1559:         }
1560:
1561:       /* Check cached number of iterations for released SSA names.  */
1562:       tree ref;
1563:       if (loop->nb_iterations
1564:           && (ref = walk_tree (&loop->nb_iterations,
1565:                                find_released_ssa_name, NULL, NULL)))
```

## gcc/cfgloop.cc:1630–1747

```text
1630:
1631:   /* Check the recorded loop exits.  */
1632:   for (auto loop : loops_list (cfun, 0))
1633:     {
1634:       if (!loop->exits || loop->exits->e != NULL)
1635:         {
1636:           error ("corrupted head of the exits list of loop %d",
1637:                  loop->num);
1638:           err = 1;
1639:         }
1640:       else
1641:         {
1642:           /* Check that the list forms a cycle, and all elements except
1643:              for the head are nonnull.  */
1644:           for (mexit = loop->exits, exit = mexit->next, i = 0;
1645:                exit->e && exit != mexit;
1646:                exit = exit->next)
1647:             {
1648:               if (i++ & 1)
1649:                 mexit = mexit->next;
1650:             }
1651:
1652:           if (exit != loop->exits)
1653:             {
1654:               error ("corrupted exits list of loop %d", loop->num);
1655:               err = 1;
1656:             }
1657:         }
1658:
1659:       if (!loops_state_satisfies_p (LOOPS_HAVE_RECORDED_EXITS))
1660:         {
1661:           if (loop->exits->next != loop->exits)
1662:             {
1663:               error ("nonempty exits list of loop %d, but exits are not recorded",
1664:                      loop->num);
1665:               err = 1;
1666:             }
1667:         }
1668:     }
1669:
1670:   if (loops_state_satisfies_p (LOOPS_HAVE_RECORDED_EXITS))
1671:     {
1672:       unsigned n_exits = 0, eloops;
1673:
1674:       sizes = XCNEWVEC (unsigned, num);
1675:       memset (sizes, 0, sizeof (unsigned) * num);
1676:       FOR_EACH_BB_FN (bb, cfun)
1677:         {
1678:           edge_iterator ei;
1679:           if (bb->loop_father == current_loops->tree_root)
1680:             continue;
1681:           FOR_EACH_EDGE (e, ei, bb->succs)
1682:             {
1683:               if (flow_bb_inside_loop_p (bb->loop_father, e->dest))
1684:                 continue;
1685:
1686:               n_exits++;
1687:               exit = get_exit_descriptions (e);
1688:               if (!exit)
1689:                 {
1690:                   error ("exit %d->%d not recorded",
1691:                          e->src->index, e->dest->index);
1692:                   err = 1;
1693:                 }
1694:               eloops = 0;
1695:               for (; exit; exit = exit->next_e)
1696:                 eloops++;
1697:
1698:               for (class loop *loop = bb->loop_father;
1699:                    loop != e->dest->loop_father
1700:                    /* When a loop exit is also an entry edge which
1701:                       can happen when avoiding CFG manipulations
1702:                       then the last loop exited is the outer loop
1703:                       of the loop entered.  */
1704:                    && loop != loop_outer (e->dest->loop_father);
1705:                    loop = loop_outer (loop))
1706:                 {
1707:                   eloops--;
1708:                   sizes[loop->num]++;
1709:                 }
1710:
1711:               if (eloops != 0)
1712:                 {
1713:                   error ("wrong list of exited loops for edge %d->%d",
1714:                          e->src->index, e->dest->index);
1715:                   err = 1;
1716:                 }
1717:             }
1718:         }
1719:
1720:       if (n_exits != current_loops->exits->elements ())
1721:         {
1722:           error ("too many loop exits recorded");
1723:           err = 1;
1724:         }
1725:
1726:       for (auto loop : loops_list (cfun, 0))
1727:         {
1728:           eloops = 0;
1729:           for (exit = loop->exits->next; exit->e; exit = exit->next)
1730:             eloops++;
1731:           if (eloops != sizes[loop->num])
1732:             {
1733:               error ("%d exits recorded for loop %d (having %d exits)",
1734:                      eloops, loop->num, sizes[loop->num]);
1735:               err = 1;
1736:             }
1737:         }
1738:
1739:       free (sizes);
1740:     }
1741:
1742:   gcc_assert (!err);
1743:
1744:   if (!dom_available)
1745:     free_dominance_info (CDI_DOMINATORS);
1746: }
1747:
```

## gcc/cfgloop.cc:2129–2186

```text
2129: void
2130: loops_list::walk_loop_tree (class loop *root, unsigned flags)
2131: {
2132:   bool only_innermost_p = flags & LI_ONLY_INNERMOST;
2133:   bool from_innermost_p = flags & LI_FROM_INNERMOST;
2134:   bool preorder_p = !(only_innermost_p || from_innermost_p);
2135:
2136:   /* Early handle root without any inner loops, make later
2137:      processing simpler, that is all loops processed in the
2138:      following while loop are impossible to be root.  */
2139:   if (!root->inner)
2140:     {
2141:       if (flags & LI_INCLUDE_ROOT)
2142:         this->to_visit.quick_push (root->num);
2143:       return;
2144:     }
2145:   else if (preorder_p && flags & LI_INCLUDE_ROOT)
2146:     this->to_visit.quick_push (root->num);
2147:
2148:   class loop *aloop;
2149:   for (aloop = root->inner;
2150:        aloop->inner != NULL;
2151:        aloop = aloop->inner)
2152:     {
2153:       if (preorder_p)
2154:         this->to_visit.quick_push (aloop->num);
2155:       continue;
2156:     }
2157:
2158:   while (1)
2159:     {
2160:       gcc_assert (aloop != root);
2161:       if (from_innermost_p || aloop->inner == NULL)
2162:         this->to_visit.quick_push (aloop->num);
2163:
2164:       if (aloop->next)
2165:         {
2166:           for (aloop = aloop->next;
2167:                aloop->inner != NULL;
2168:                aloop = aloop->inner)
2169:             {
2170:               if (preorder_p)
2171:                 this->to_visit.quick_push (aloop->num);
2172:               continue;
2173:             }
2174:         }
2175:       else if (loop_outer (aloop) == root)
2176:         break;
2177:       else
2178:         aloop = loop_outer (aloop);
2179:     }
2180:
2181:   /* When visiting from innermost, we need to consider root here
2182:      since the previous while loop doesn't handle it.  */
2183:   if (from_innermost_p && flags & LI_INCLUDE_ROOT)
2184:     this->to_visit.quick_push (root->num);
2185: }
2186:
```

## gcc/cfgloop.h:306–323

```text
306: /* Flags for state of loop structure.  */
307: enum
308: {
309:   LOOPS_HAVE_PREHEADERS = 1,
310:   LOOPS_HAVE_SIMPLE_LATCHES = 2,
311:   LOOPS_HAVE_MARKED_IRREDUCIBLE_REGIONS = 4,
312:   LOOPS_HAVE_RECORDED_EXITS = 8,
313:   LOOPS_MAY_HAVE_MULTIPLE_LATCHES = 16,
314:   LOOP_CLOSED_SSA = 32,
315:   LOOPS_NEED_FIXUP = 64,
316:   LOOPS_HAVE_FALLTHRU_PREHEADERS = 128
317: };
318:
319: #define LOOPS_NORMAL (LOOPS_HAVE_PREHEADERS | LOOPS_HAVE_SIMPLE_LATCHES \
320:                       | LOOPS_HAVE_MARKED_IRREDUCIBLE_REGIONS)
321: #define AVOID_CFG_MODIFICATIONS (LOOPS_MAY_HAVE_MULTIPLE_LATCHES)
322:
323: /* Structure to hold CFG information about natural loops within a function.  */
```

## gcc/cfgloop.h:639–656

```text
639: checking_verify_loop_structure (void)
640: {
641:   /* VERIFY_LOOP_STRUCTURE essentially asserts that no loops need fixups.
642:
643:      The loop optimizers should never make changes to the CFG which
644:      require loop fixups.  But the low level CFG manipulation code may
645:      set the flag conservatively.
646:
647:      Go ahead and clear the flag here.  That avoids the assert inside
648:      VERIFY_LOOP_STRUCTURE, and if there is an inconsistency in the loop
649:      structures VERIFY_LOOP_STRUCTURE will detect it.
650:
651:      This also avoid the compile time cost of excessive fixups.  */
652:   loops_state_clear (LOOPS_NEED_FIXUP);
653:   if (flag_checking)
654:     verify_loop_structure ();
655: }
656:
```

## gcc/cfgloop.h:685–843

```text
685: class loops_list
686: {
687: public:
688:   loops_list (function *fn, unsigned flags, class loop *root = nullptr);
689:
690:   template <typename T> class Iter
691:   {
692:   public:
693:     Iter (const loops_list &l, unsigned idx) : list (l), curr_idx (idx)
694:     {
695:       fill_curr_loop ();
696:     }
697:
698:     T operator* () const { return curr_loop; }
699:
700:     Iter &
701:     operator++ ()
702:     {
703:       if (curr_idx < list.to_visit.length ())
704:         {
705:           /* Bump the index and fill a new one.  */
706:           curr_idx++;
707:           fill_curr_loop ();
708:         }
709:       else
710:         gcc_assert (!curr_loop);
711:
712:       return *this;
713:     }
714:
715:     bool
716:     operator!= (const Iter &rhs) const
717:     {
718:       return this->curr_idx != rhs.curr_idx;
719:     }
720:
721:   private:
722:     /* Fill the current loop starting from the current index.  */
723:     void fill_curr_loop ();
724:
725:     /* Reference to the loop list to visit.  */
726:     const loops_list &list;
727:
728:     /* The current index in the list to visit.  */
729:     unsigned curr_idx;
730:
731:     /* The loop implied by the current index.  */
732:     class loop *curr_loop;
733:   };
734:
735:   using iterator = Iter<class loop *>;
736:   using const_iterator = Iter<const class loop *>;
737:
738:   iterator
739:   begin ()
740:   {
741:     return iterator (*this, 0);
742:   }
743:
744:   iterator
745:   end ()
746:   {
747:     return iterator (*this, to_visit.length ());
748:   }
749:
750:   const_iterator
751:   begin () const
752:   {
753:     return const_iterator (*this, 0);
754:   }
755:
756:   const_iterator
757:   end () const
758:   {
759:     return const_iterator (*this, to_visit.length ());
760:   }
761:
762: private:
763:   /* Walk loop tree starting from ROOT as the visiting order specified
764:      by FLAGS.  */
765:   void walk_loop_tree (class loop *root, unsigned flags);
766:
767:   /* The function we are visiting.  */
768:   function *fn;
769:
770:   /* The list of loops to visit.  */
771:   auto_vec<int, 16> to_visit;
772: };
773:
774: /* Starting from current index CURR_IDX (inclusive), find one index
775:    which stands for one valid loop and fill the found loop as CURR_LOOP,
776:    if we can't find one, set CURR_LOOP as null.  */
777:
778: template <typename T>
779: inline void
780: loops_list::Iter<T>::fill_curr_loop ()
781: {
782:   int anum;
783:
784:   while (this->list.to_visit.iterate (this->curr_idx, &anum))
785:     {
786:       class loop *loop = get_loop (this->list.fn, anum);
787:       if (loop)
788:         {
789:           curr_loop = loop;
790:           return;
791:         }
792:       this->curr_idx++;
793:     }
794:
795:   curr_loop = nullptr;
796: }
797:
798: /* Set up the loops list to visit according to the specified
799:    function scope FN and iterating order FLAGS.  If ROOT is
800:    not null, the visiting would start from it, otherwise it
801:    will start from tree_root of loops_for_fn (FN).  */
802:
803: inline loops_list::loops_list (function *fn, unsigned flags, class loop *root)
804: {
805:   struct loops *loops = loops_for_fn (fn);
806:   gcc_assert (!root || loops);
807:
808:   /* Check mutually exclusive flags should not co-exist.  */
809:   unsigned checked_flags = LI_ONLY_INNERMOST | LI_FROM_INNERMOST;
810:   gcc_assert ((flags & checked_flags) != checked_flags);
811:
812:   this->fn = fn;
813:   if (!loops)
814:     return;
815:
816:   class loop *tree_root = root ? root : loops->tree_root;
817:
818:   this->to_visit.reserve_exact (number_of_loops (fn));
819:
820:   /* When root is tree_root of loops_for_fn (fn) and the visiting
821:      order is LI_ONLY_INNERMOST, we would like to use linear
822:      search here since it has a more stable bound than the
823:      walk_loop_tree.  */
824:   if (flags & LI_ONLY_INNERMOST && tree_root == loops->tree_root)
825:     {
826:       gcc_assert (tree_root->num == 0);
827:       if (tree_root->inner == NULL)
828:         {
829:           if (flags & LI_INCLUDE_ROOT)
830:             this->to_visit.quick_push (0);
831:
832:           return;
833:         }
834:
835:       class loop *aloop;
836:       unsigned int i;
837:       for (i = 1; vec_safe_iterate (loops->larray, i, &aloop); i++)
838:         if (aloop != NULL && aloop->inner == NULL)
839:           this->to_visit.quick_push (aloop->num);
840:     }
841:   else
842:     walk_loop_tree (tree_root, flags);
843: }
```

## gcc/loop-init.cc:42–134

```text
42: static void
43: apply_loop_flags (unsigned flags)
44: {
45:   if (flags & LOOPS_MAY_HAVE_MULTIPLE_LATCHES)
46:     {
47:       /* If the loops may have multiple latches, we cannot canonicalize
48:          them further (and most of the loop manipulation functions will
49:          not work).  However, we avoid modifying cfg, which some
50:          passes may want.  */
51:       gcc_assert ((flags & ~(LOOPS_MAY_HAVE_MULTIPLE_LATCHES
52:                              | LOOPS_HAVE_RECORDED_EXITS
53:                              | LOOPS_HAVE_MARKED_IRREDUCIBLE_REGIONS)) == 0);
54:       loops_state_set (LOOPS_MAY_HAVE_MULTIPLE_LATCHES);
55:     }
56:   else
57:     disambiguate_loops_with_multiple_latches ();
58:
59:   /* Create pre-headers.  */
60:   if (flags & LOOPS_HAVE_PREHEADERS)
61:     {
62:       int cp_flags = CP_SIMPLE_PREHEADERS;
63:
64:       if (flags & LOOPS_HAVE_FALLTHRU_PREHEADERS)
65:         cp_flags |= CP_FALLTHRU_PREHEADERS;
66:
67:       create_preheaders (cp_flags);
68:     }
69:
70:   /* Force all latches to have only single successor.  */
71:   if (flags & LOOPS_HAVE_SIMPLE_LATCHES)
72:     force_single_succ_latches ();
73:
74:   /* Mark irreducible loops.  */
75:   if (flags & LOOPS_HAVE_MARKED_IRREDUCIBLE_REGIONS)
76:     mark_irreducible_loops ();
77:
78:   if (flags & LOOPS_HAVE_RECORDED_EXITS)
79:     record_loop_exits ();
80: }
81:
82: /* Initialize loop structures.  This is used by the tree and RTL loop
83:    optimizers.  FLAGS specify what properties to compute and/or ensure for
84:    loops.  */
85:
86: void
87: loop_optimizer_init (unsigned flags)
88: {
89:   timevar_push (TV_LOOP_INIT);
90:
91:   if (!current_loops)
92:     {
93:       gcc_assert (!(cfun->curr_properties & PROP_loops));
94:
95:       /* Find the loops.  */
96:       current_loops = flow_loops_find (NULL);
97:     }
98:   else
99:     {
100:       bool recorded_exits = loops_state_satisfies_p (LOOPS_HAVE_RECORDED_EXITS);
101:       bool needs_fixup = loops_state_satisfies_p (LOOPS_NEED_FIXUP);
102:
103:       gcc_assert (cfun->curr_properties & PROP_loops);
104:
105:       /* Ensure that the dominators are computed, like flow_loops_find does.  */
106:       calculate_dominance_info (CDI_DOMINATORS);
107:
108:       if (!needs_fixup)
109:         checking_verify_loop_structure ();
110:
111:       /* Clear all flags.  */
112:       if (recorded_exits)
113:         release_recorded_exits (cfun);
114:       loops_state_clear (~0U);
115:
116:       if (needs_fixup)
117:         {
118:           /* Apply LOOPS_MAY_HAVE_MULTIPLE_LATCHES early as fix_loop_structure
119:              re-applies flags.  */
120:           loops_state_set (flags & LOOPS_MAY_HAVE_MULTIPLE_LATCHES);
121:           fix_loop_structure (NULL);
122:         }
123:     }
124:
125:   /* Apply flags to loops.  */
126:   apply_loop_flags (flags);
127:
128:   /* Dump loops.  */
129:   flow_loops_dump (dump_file, NULL, 1);
130:
131:   checking_verify_loop_structure ();
132:
133:   timevar_pop (TV_LOOP_INIT);
134: }
```

## gcc/loop-init.cc:200–339

```text
200: unsigned
201: fix_loop_structure (bitmap changed_bbs)
202: {
203:   basic_block bb;
204:   int record_exits = 0;
205:   unsigned old_nloops, i;
206:
207:   timevar_push (TV_LOOP_INIT);
208:
209:   if (dump_file && (dump_flags & TDF_DETAILS))
210:     fprintf (dump_file, "fix_loop_structure: fixing up loops for function\n");
211:
212:   /* We need exact and fast dominance info to be available.  */
213:   gcc_assert (dom_info_state (CDI_DOMINATORS) == DOM_OK);
214:
215:   if (loops_state_satisfies_p (LOOPS_HAVE_RECORDED_EXITS))
216:     {
217:       release_recorded_exits (cfun);
218:       record_exits = LOOPS_HAVE_RECORDED_EXITS;
219:     }
220:
221:   /* Remember the depth of the blocks in the loop hierarchy, so that we can
222:      recognize blocks whose loop nesting relationship has changed.  */
223:   if (changed_bbs)
224:     FOR_EACH_BB_FN (bb, cfun)
225:       bb->aux = (void *) (size_t) loop_depth (bb->loop_father);
226:
227:   /* Remove the dead loops from structures.  We start from the innermost
228:      loops, so that when we remove the loops, we know that the loops inside
229:      are preserved, and do not waste time relinking loops that will be
230:      removed later.  */
231:   for (auto loop : loops_list (cfun, LI_FROM_INNERMOST))
232:     {
233:       /* Detect the case that the loop is no longer present even though
234:          it wasn't marked for removal.
235:          ???  If we do that we can get away with not marking loops for
236:          removal at all.  And possibly avoid some spurious removals.  */
237:       if (loop->header
238:           && bb_loop_header_p (loop->header))
239:         continue;
240:
241:       if (dump_file && (dump_flags & TDF_DETAILS))
242:         fprintf (dump_file, "fix_loop_structure: removing loop %d\n",
243:                  loop->num);
244:
245:       while (loop->inner)
246:         {
247:           class loop *ploop = loop->inner;
248:           flow_loop_tree_node_remove (ploop);
249:           flow_loop_tree_node_add (loop_outer (loop), ploop);
250:         }
251:
252:       /* Remove the loop.  */
253:       if (loop->header)
254:         loop->former_header = loop->header;
255:       else
256:         gcc_assert (loop->former_header != NULL);
257:       loop->header = NULL;
258:       flow_loop_tree_node_remove (loop);
259:     }
260:
261:   /* Remember the number of loops so we can return how many new loops
262:      flow_loops_find discovered.  */
263:   old_nloops = number_of_loops (cfun);
264:
265:   /* Re-compute loop structure in-place.  */
266:   flow_loops_find (current_loops);
267:
268:   /* Mark the blocks whose loop has changed.  */
269:   if (changed_bbs)
270:     {
271:       FOR_EACH_BB_FN (bb, cfun)
272:         {
273:           if ((void *) (size_t) loop_depth (bb->loop_father) != bb->aux)
274:             bitmap_set_bit (changed_bbs, bb->index);
275:
276:           bb->aux = NULL;
277:         }
278:     }
279:
280:   /* Finally free deleted loops.  */
281:   unsigned n_deleted = 0;
282:   class loop *loop;
283:   FOR_EACH_VEC_ELT (*get_loops (cfun), i, loop)
284:     if (loop && loop->header == NULL)
285:       {
286:         if (dump_file
287:             && ((unsigned) loop->former_header->index
288:                 < basic_block_info_for_fn (cfun)->length ()))
289:           {
290:             basic_block former_header
291:               = BASIC_BLOCK_FOR_FN (cfun, loop->former_header->index);
292:             /* If the old header still exists we want to check if the
293:                original loop is re-discovered or the old header is now
294:                part of a newly discovered loop.
295:                In both cases we should have avoided removing the loop.  */
296:             if (former_header == loop->former_header)
297:               {
298:                 if (former_header->loop_father->header == former_header)
299:                   fprintf (dump_file, "fix_loop_structure: rediscovered "
300:                            "removed loop %d as loop %d with old header %d\n",
301:                            loop->num, former_header->loop_father->num,
302:                            former_header->index);
303:                 else if ((unsigned) former_header->loop_father->num
304:                          >= old_nloops)
305:                   fprintf (dump_file, "fix_loop_structure: header %d of "
306:                            "removed loop %d is part of the newly "
307:                            "discovered loop %d with header %d\n",
308:                            former_header->index, loop->num,
309:                            former_header->loop_father->num,
310:                            former_header->loop_father->header->index);
311:               }
312:           }
313:         (*get_loops (cfun))[i] = NULL;
314:         flow_loop_free (loop);
315:         n_deleted++;
316:       }
317:
318:   /* If we deleted loops then the cached scalar evolutions referring to
319:      those loops become invalid.  */
320:   if (n_deleted > 0 && scev_initialized_p ())
321:     scev_reset_htab ();
322:
323:   loops_state_clear (LOOPS_NEED_FIXUP);
324:
325:   /* Apply flags to loops.  */
326:   apply_loop_flags (current_loops->state | record_exits);
327:
328:   checking_verify_loop_structure ();
329:
330:   timevar_pop (TV_LOOP_INIT);
331:
332:   return number_of_loops (cfun) - old_nloops + n_deleted;
333: }
334:
335:
336: /* The RTL loop superpass.  The actual passes are subpasses.  See passes.cc for
337:    more on that.  */
338:
339: namespace {
```

## gcc/cfganal.cc:979–1088

```text
979:    pre_order is a really a preorder numbering of the graph.
980:    rev_post_order is really a reverse postorder numbering of the graph.  */
981:
982: int
983: pre_and_rev_post_order_compute_fn (struct function *fn,
984:                                    int *pre_order, int *rev_post_order,
985:                                    bool include_entry_exit)
986: {
987:   int pre_order_num = 0;
988:   int rev_post_order_num = n_basic_blocks_for_fn (fn) - 1;
989:
990:   /* Allocate stack for back-tracking up CFG.  */
991:   auto_vec<edge_iterator, 20> stack (n_basic_blocks_for_fn (fn) + 1);
992:
993:   if (include_entry_exit)
994:     {
995:       if (pre_order)
996:         pre_order[pre_order_num] = ENTRY_BLOCK;
997:       pre_order_num++;
998:       if (rev_post_order)
999:         rev_post_order[rev_post_order_num--] = EXIT_BLOCK;
1000:     }
1001:   else
1002:     rev_post_order_num -= NUM_FIXED_BLOCKS;
1003:
1004:   /* BB flag to track nodes that have been visited.  */
1005:   auto_bb_flag visited (fn);
1006:
1007:   /* Push the first edge on to the stack.  */
1008:   stack.quick_push (ei_start (ENTRY_BLOCK_PTR_FOR_FN (fn)->succs));
1009:
1010:   while (!stack.is_empty ())
1011:     {
1012:       basic_block src;
1013:       basic_block dest;
1014:
1015:       /* Look at the edge on the top of the stack.  */
1016:       edge_iterator ei = stack.last ();
1017:       src = ei_edge (ei)->src;
1018:       dest = ei_edge (ei)->dest;
1019:
1020:       /* Check if the edge destination has been visited yet.  */
1021:       if (dest != EXIT_BLOCK_PTR_FOR_FN (fn)
1022:           && ! (dest->flags & visited))
1023:         {
1024:           /* Mark that we have visited the destination.  */
1025:           dest->flags |= visited;
1026:
1027:           if (pre_order)
1028:             pre_order[pre_order_num] = dest->index;
1029:
1030:           pre_order_num++;
1031:
1032:           if (EDGE_COUNT (dest->succs) > 0)
1033:             /* Since the DEST node has been visited for the first
1034:                time, check its successors.  */
1035:             stack.quick_push (ei_start (dest->succs));
1036:           else if (rev_post_order)
1037:             /* There are no successors for the DEST node so assign
1038:                its reverse completion number.  */
1039:             rev_post_order[rev_post_order_num--] = dest->index;
1040:         }
1041:       else
1042:         {
1043:           if (ei_one_before_end_p (ei)
1044:               && src != ENTRY_BLOCK_PTR_FOR_FN (fn)
1045:               && rev_post_order)
1046:             /* There are no more successors for the SRC node
1047:                so assign its reverse completion number.  */
1048:             rev_post_order[rev_post_order_num--] = src->index;
1049:
1050:           if (!ei_one_before_end_p (ei))
1051:             ei_next (&stack.last ());
1052:           else
1053:             stack.pop ();
1054:         }
1055:     }
1056:
1057:   if (include_entry_exit)
1058:     {
1059:       if (pre_order)
1060:         pre_order[pre_order_num] = EXIT_BLOCK;
1061:       pre_order_num++;
1062:       if (rev_post_order)
1063:         rev_post_order[rev_post_order_num--] = ENTRY_BLOCK;
1064:     }
1065:
1066:   /* Clear the temporarily allocated flag.  */
1067:   if (!rev_post_order)
1068:     rev_post_order = pre_order;
1069:   for (int i = 0; i < pre_order_num; ++i)
1070:     BASIC_BLOCK_FOR_FN (fn, rev_post_order[i])->flags &= ~visited;
1071:
1072:   return pre_order_num;
1073: }
1074:
1075: /* Like pre_and_rev_post_order_compute_fn but operating on the
1076:    current function and asserting that all nodes were visited.  */
1077:
1078: int
1079: pre_and_rev_post_order_compute (int *pre_order, int *rev_post_order,
1080:                                 bool include_entry_exit)
1081: {
1082:   int pre_order_num
1083:     = pre_and_rev_post_order_compute_fn (cfun, pre_order, rev_post_order,
1084:                                          include_entry_exit);
1085:   if (include_entry_exit)
1086:     /* The number of nodes visited should be the number of blocks.  */
1087:     gcc_assert (pre_order_num == n_basic_blocks_for_fn (cfun));
1088:   else
```

## gcc/cfganal.cc:1639–1731

```text
1639:    of the dominance frontiers, no more, no less.
1640: */
1641:
1642: void
1643: compute_dominance_frontiers (bitmap_head *frontiers)
1644: {
1645:   timevar_push (TV_DOM_FRONTIERS);
1646:
1647:   edge p;
1648:   edge_iterator ei;
1649:   basic_block b;
1650:   FOR_EACH_BB_FN (b, cfun)
1651:     {
1652:       if (EDGE_COUNT (b->preds) >= 2)
1653:         {
1654:           basic_block domsb = get_immediate_dominator (CDI_DOMINATORS, b);
1655:           FOR_EACH_EDGE (p, ei, b->preds)
1656:             {
1657:               basic_block runner = p->src;
1658:               if (runner == ENTRY_BLOCK_PTR_FOR_FN (cfun))
1659:                 continue;
1660:
1661:               while (runner != domsb)
1662:                 {
1663:                   if (!bitmap_set_bit (&frontiers[runner->index], b->index))
1664:                     break;
1665:                   runner = get_immediate_dominator (CDI_DOMINATORS, runner);
1666:                 }
1667:             }
1668:         }
1669:     }
1670:
1671:   timevar_pop (TV_DOM_FRONTIERS);
1672: }
1673:
1674: /* Given a set of blocks with variable definitions (DEF_BLOCKS),
1675:    return a bitmap with all the blocks in the iterated dominance
1676:    frontier of the blocks in DEF_BLOCKS.  DFS contains dominance
1677:    frontier information as returned by compute_dominance_frontiers.
1678:
1679:    The resulting set of blocks are the potential sites where PHI nodes
1680:    are needed.  The caller is responsible for freeing the memory
1681:    allocated for the return value.  */
1682:
1683: bitmap
1684: compute_idf (bitmap def_blocks, bitmap_head *dfs)
1685: {
1686:   bitmap_iterator bi, bi2;
1687:   unsigned bb_index, i;
1688:   bitmap phi_insertion_points;
1689:
1690:   phi_insertion_points = BITMAP_ALLOC (NULL);
1691:
1692:   /* The initial workset is the DEF_BLOCKs, process that first,
1693:      seeding phi_insertion_points as the start of the worklist
1694:      for the iteration which then also serves as a visited set.  */
1695:   EXECUTE_IF_SET_IN_BITMAP (def_blocks, 0, bb_index, bi2)
1696:     {
1697:       /* Since the registration of NEW -> OLD name mappings is done
1698:          separately from the call to update_ssa, when updating the SSA
1699:          form, the basic blocks where new and/or old names are defined
1700:          may have disappeared by CFG cleanup calls.  In this case,
1701:          we may pull a non-existing block from the work stack.  */
1702:       gcc_checking_assert (bb_index
1703:                            < (unsigned) last_basic_block_for_fn (cfun));
1704:
1705:       /* The population counts of the dominance frontiers is low
1706:          compared to that of phi_insertion_points which approaches
1707:          the IDF and of work_set which is at most that of the IDF
1708:          as well.  That makes iterating over the DFS bitmap preferential
1709:          to whole bitmap operations involving also phi_insertion_points.  */
1710:       EXECUTE_IF_SET_IN_BITMAP (&dfs[bb_index], 0, i, bi)
1711:         bitmap_set_bit (phi_insertion_points, i);
1712:     }
1713:
1714:   /* Seed the work set with the initial phi_insertion_points.  */
1715:   auto_vec<int, 64> work_set (n_basic_blocks_for_fn (cfun));
1716:   EXECUTE_IF_SET_IN_BITMAP (phi_insertion_points, 0, i, bi)
1717:     work_set.quick_push (i);
1718:
1719:   /* Pop a block off the workset, add every block that appears in
1720:      the original block's DF that we have not already processed to
1721:      the workset.  Iterate until the workset is empty.   Blocks
1722:      which are added to the workset are potential sites for
1723:      PHI nodes.  */
1724:   while (!work_set.is_empty ())
1725:     {
1726:       bb_index = work_set.pop ();
1727:       gcc_checking_assert (bb_index
1728:                            < (unsigned) last_basic_block_for_fn (cfun));
1729:       EXECUTE_IF_SET_IN_BITMAP (&dfs[bb_index], 0, i, bi)
1730:         if (bitmap_set_bit (phi_insertion_points, i))
1731:           work_set.quick_push (i);
```

## gcc/tree-into-ssa.cc:56–69

```text
56: struct def_blocks
57: {
58:   /* Blocks that contain definitions of VAR.  Bit I will be set if the
59:      Ith block contains a definition of VAR.  */
60:   bitmap def_blocks;
61:
62:   /* Blocks that contain a PHI node for VAR.  */
63:   bitmap phi_blocks;
64:
65:   /* Blocks where VAR is live-on-entry.  Similar semantics as
66:      DEF_BLOCKS.  */
67:   bitmap livein_blocks;
68: };
69:
```

## gcc/tree-into-ssa.cc:152–174

```text
152: struct common_info
153: {
154:   /* This field indicates whether or not the variable may need PHI nodes.
155:      See the enum's definition for more detailed information about the
156:      states.  */
157:   ENUM_BITFIELD (need_phi_state) need_phi_state : 2;
158:
159:   /* The current reaching definition replacing this var.  */
160:   tree current_def;
161:
162:   /* Definitions for this var.  */
163:   struct def_blocks def_blocks;
164: };
165:
166: /* Information stored for decls.  */
167: struct var_info
168: {
169:   /* The variable.  */
170:   tree var;
171:
172:   /* Information stored for both SSA names and decls.  */
173:   common_info info;
174: };
```

## gcc/tree-into-ssa.cc:354–375

```text
354:   var_info vi;
355:   var_info **slot;
356:   vi.var = decl;
357:   slot = var_infos->find_slot_with_hash (&vi, DECL_UID (decl), INSERT);
358:   if (*slot == NULL)
359:     {
360:       var_info *v = XCNEW (var_info);
361:       v->var = decl;
362:       *slot = v;
363:       return v;
364:     }
365:   return *slot;
366: }
367:
368:
369: /* Clears info for SSA names.  */
370:
371: static void
372: clear_ssa_name_info (void)
373: {
374:   current_info_for_ssa_name_age++;
375:
```

## gcc/tree-into-ssa.cc:450–466

```text
450:
451: /* Return the set of blocks where variable VAR is defined and the blocks
452:    where VAR is live on entry (livein).  If no entry is found in
453:    DEF_BLOCKS, a new one is created and returned.  */
454:
455: static inline def_blocks *
456: get_def_blocks_for (common_info *info)
457: {
458:   def_blocks *db_p = &info->def_blocks;
459:   if (!db_p->def_blocks)
460:     {
461:       db_p->def_blocks = BITMAP_ALLOC (&update_ssa_obstack);
462:       db_p->phi_blocks = BITMAP_ALLOC (&update_ssa_obstack);
463:       db_p->livein_blocks = BITMAP_ALLOC (&update_ssa_obstack);
464:     }
465:
466:   return db_p;
```

## gcc/tree-into-ssa.cc:629–921

```text
629:   bitmap_set_bit (new_ssa_names, SSA_NAME_VERSION (new_tree));
630: }
631:
632:
633: /* Call back for walk_dominator_tree used to collect definition sites
634:    for every variable in the function.  For every statement S in block
635:    BB:
636:
637:    1- Variables defined by S in the DEFS of S are marked in the bitmap
638:       KILLS.
639:
640:    2- If S uses a variable VAR and there is no preceding kill of VAR,
641:       then it is marked in the LIVEIN_BLOCKS bitmap associated with VAR.
642:
643:    This information is used to determine which variables are live
644:    across block boundaries to reduce the number of PHI nodes
645:    we create.  */
646:
647: static void
648: mark_def_sites (basic_block bb, gimple *stmt, bitmap kills)
649: {
650:   tree def;
651:   use_operand_p use_p;
652:   ssa_op_iter iter;
653:
654:   /* Since this is the first time that we rewrite the program into SSA
655:      form, force an operand scan on every statement.  */
656:   update_stmt (stmt);
657:
658:   gcc_checking_assert (blocks_to_update == NULL);
659:   set_register_defs (stmt, false);
660:   set_rewrite_uses (stmt, false);
661:
662:   if (is_gimple_debug (stmt))
663:     {
664:       FOR_EACH_SSA_USE_OPERAND (use_p, stmt, iter, SSA_OP_USE)
665:         {
666:           tree sym = USE_FROM_PTR (use_p);
667:           gcc_checking_assert (DECL_P (sym));
668:           set_rewrite_uses (stmt, true);
669:         }
670:       if (rewrite_uses_p (stmt))
671:         bitmap_set_bit (interesting_blocks, bb->index);
672:       return;
673:     }
674:
675:   /* If a variable is used before being set, then the variable is live
676:      across a block boundary, so mark it live-on-entry to BB.  */
677:   FOR_EACH_SSA_USE_OPERAND (use_p, stmt, iter, SSA_OP_ALL_USES)
678:     {
679:       tree sym = USE_FROM_PTR (use_p);
680:       if (TREE_CODE (sym) == SSA_NAME)
681:         continue;
682:       gcc_checking_assert (DECL_P (sym));
683:       if (!bitmap_bit_p (kills, DECL_UID (sym)))
684:         set_livein_block (sym, bb);
685:       set_rewrite_uses (stmt, true);
686:     }
687:
688:   /* Now process the defs.  Mark BB as the definition block and add
689:      each def to the set of killed symbols.  */
690:   FOR_EACH_SSA_TREE_OPERAND (def, stmt, iter, SSA_OP_ALL_DEFS)
691:     {
692:       if (TREE_CODE (def) == SSA_NAME)
693:         continue;
694:       gcc_checking_assert (DECL_P (def));
695:       set_def_block (def, bb, false);
696:       bitmap_set_bit (kills, DECL_UID (def));
697:       set_register_defs (stmt, true);
698:     }
699:
700:   /* If we found the statement interesting then also mark the block BB
701:      as interesting.  */
702:   if (rewrite_uses_p (stmt) || register_defs_p (stmt))
703:     bitmap_set_bit (interesting_blocks, bb->index);
704: }
705:
706: /* Structure used by prune_unused_phi_nodes to record bounds of the intervals
707:    in the dfs numbering of the dominance tree.  */
708:
709: struct dom_dfsnum
710: {
711:   /* Basic block whose index this entry corresponds to.  */
712:   unsigned bb_index;
713:
714:   /* The dfs number of this node.  */
715:   unsigned dfs_num;
716: };
717:
718: /* Compares two entries of type struct dom_dfsnum by dfs_num field.  Callback
719:    for qsort.  */
720:
721: static int
722: cmp_dfsnum (const void *a, const void *b)
723: {
724:   const struct dom_dfsnum *const da = (const struct dom_dfsnum *) a;
725:   const struct dom_dfsnum *const db = (const struct dom_dfsnum *) b;
726:
727:   return (int) da->dfs_num - (int) db->dfs_num;
728: }
729:
730: /* Among the intervals starting at the N points specified in DEFS, find
731:    the one that contains S, and return its bb_index.  */
732:
733: static unsigned
734: find_dfsnum_interval (struct dom_dfsnum *defs, unsigned n, unsigned s)
735: {
736:   unsigned f = 0, t = n, m;
737:
738:   while (t > f + 1)
739:     {
740:       m = (f + t) / 2;
741:       if (defs[m].dfs_num <= s)
742:         f = m;
743:       else
744:         t = m;
745:     }
746:
747:   return defs[f].bb_index;
748: }
749:
750: /* Clean bits from PHIS for phi nodes whose value cannot be used in USES.
751:    KILLS is a bitmap of blocks where the value is defined before any use.  */
752:
753: static void
754: prune_unused_phi_nodes (bitmap phis, bitmap kills, bitmap uses)
755: {
756:   bitmap_iterator bi;
757:   unsigned i, b, p, u, top;
758:   bitmap live_phis;
759:   basic_block def_bb, use_bb;
760:   edge e;
761:   edge_iterator ei;
762:   bitmap to_remove;
763:   struct dom_dfsnum *defs;
764:   unsigned n_defs, adef;
765:
766:   if (bitmap_empty_p (uses))
767:     {
768:       bitmap_clear (phis);
769:       return;
770:     }
771:
772:   /* The phi must dominate a use, or an argument of a live phi.  Also, we
773:      do not create any phi nodes in def blocks, unless they are also livein.  */
774:   to_remove = BITMAP_ALLOC (NULL);
775:   bitmap_and_compl (to_remove, kills, uses);
776:   bitmap_and_compl_into (phis, to_remove);
777:   if (bitmap_empty_p (phis))
778:     {
779:       BITMAP_FREE (to_remove);
780:       return;
781:     }
782:
783:   /* We want to remove the unnecessary phi nodes, but we do not want to compute
784:      liveness information, as that may be linear in the size of CFG, and if
785:      there are lot of different variables to rewrite, this may lead to quadratic
786:      behavior.
787:
788:      Instead, we basically emulate standard dce.  We put all uses to worklist,
789:      then for each of them find the nearest def that dominates them.  If this
790:      def is a phi node, we mark it live, and if it was not live before, we
791:      add the predecessors of its basic block to the worklist.
792:
793:      To quickly locate the nearest def that dominates use, we use dfs numbering
794:      of the dominance tree (that is already available in order to speed up
795:      queries).  For each def, we have the interval given by the dfs number on
796:      entry to and on exit from the corresponding subtree in the dominance tree.
797:      The nearest dominator for a given use is the smallest of these intervals
798:      that contains entry and exit dfs numbers for the basic block with the use.
799:      If we store the bounds for all the uses to an array and sort it, we can
800:      locate the nearest dominating def in logarithmic time by binary search.*/
801:   bitmap_ior (to_remove, kills, phis);
802:   n_defs = bitmap_count_bits (to_remove);
803:   adef = 2 * n_defs + 1;
804:   defs = XNEWVEC (struct dom_dfsnum, adef);
805:   defs[0].bb_index = 1;
806:   defs[0].dfs_num = 0;
807:   struct dom_dfsnum *head = defs + 1, *tail = defs + adef;
808:   EXECUTE_IF_SET_IN_BITMAP (to_remove, 0, i, bi)
809:     {
810:       def_bb = BASIC_BLOCK_FOR_FN (cfun, i);
811:       head->bb_index = i;
812:       head->dfs_num = bb_dom_dfs_in (CDI_DOMINATORS, def_bb);
813:       head++, tail--;
814:       tail->bb_index = i;
815:       tail->dfs_num = bb_dom_dfs_out (CDI_DOMINATORS, def_bb);
816:     }
817:   gcc_checking_assert (head == tail);
818:   BITMAP_FREE (to_remove);
819:   qsort (defs, adef, sizeof (struct dom_dfsnum), cmp_dfsnum);
820:   gcc_assert (defs[0].bb_index == 1);
821:
822:   /* Now each DEFS entry contains the number of the basic block to that the
823:      dfs number corresponds.  Change them to the number of basic block that
824:      corresponds to the interval following the dfs number.  Also, for the
825:      dfs_out numbers, increase the dfs number by one (so that it corresponds
826:      to the start of the following interval, not to the end of the current
827:      one).  We use WORKLIST as a stack.  */
828:   auto_vec<int> worklist (n_defs + 1);
829:   worklist.quick_push (1);
830:   top = 1;
831:   n_defs = 1;
832:   for (i = 1; i < adef; i++)
833:     {
834:       b = defs[i].bb_index;
835:       if (b == top)
836:         {
837:           /* This is a closing element.  Interval corresponding to the top
838:              of the stack after removing it follows.  */
839:           worklist.pop ();
840:           top = worklist[worklist.length () - 1];
841:           defs[n_defs].bb_index = top;
842:           defs[n_defs].dfs_num = defs[i].dfs_num + 1;
843:         }
844:       else
845:         {
846:           /* Opening element.  Nothing to do, just push it to the stack and move
847:              it to the correct position.  */
848:           defs[n_defs].bb_index = defs[i].bb_index;
849:           defs[n_defs].dfs_num = defs[i].dfs_num;
850:           worklist.quick_push (b);
851:           top = b;
852:         }
853:
854:       /* If this interval starts at the same point as the previous one, cancel
855:          the previous one.  */
856:       if (defs[n_defs].dfs_num == defs[n_defs - 1].dfs_num)
857:         defs[n_defs - 1].bb_index = defs[n_defs].bb_index;
858:       else
859:         n_defs++;
860:     }
861:   worklist.pop ();
862:   gcc_assert (worklist.is_empty ());
863:
864:   /* Now process the uses.  */
865:   live_phis = BITMAP_ALLOC (NULL);
866:   EXECUTE_IF_SET_IN_BITMAP (uses, 0, i, bi)
867:     {
868:       worklist.safe_push (i);
869:     }
870:
871:   while (!worklist.is_empty ())
872:     {
873:       b = worklist.pop ();
874:       if (b == ENTRY_BLOCK)
875:         continue;
876:
877:       /* If there is a phi node in USE_BB, it is made live.  Otherwise,
878:          find the def that dominates the immediate dominator of USE_BB
879:          (the kill in USE_BB does not dominate the use).  */
880:       if (bitmap_bit_p (phis, b))
881:         p = b;
882:       else
883:         {
884:           use_bb = get_immediate_dominator (CDI_DOMINATORS,
885:                                             BASIC_BLOCK_FOR_FN (cfun, b));
886:           p = find_dfsnum_interval (defs, n_defs,
887:                                     bb_dom_dfs_in (CDI_DOMINATORS, use_bb));
888:           if (!bitmap_bit_p (phis, p))
889:             continue;
890:         }
891:
892:       /* If the phi node is already live, there is nothing to do.  */
893:       if (!bitmap_set_bit (live_phis, p))
894:         continue;
895:
896:       /* Add the new uses to the worklist.  */
897:       def_bb = BASIC_BLOCK_FOR_FN (cfun, p);
898:       FOR_EACH_EDGE (e, ei, def_bb->preds)
899:         {
900:           u = e->src->index;
901:           if (bitmap_bit_p (uses, u))
902:             continue;
903:
904:           /* In case there is a kill directly in the use block, do not record
905:              the use (this is also necessary for correctness, as we assume that
906:              uses dominated by a def directly in their block have been filtered
907:              out before).  */
908:           if (bitmap_bit_p (kills, u))
909:             continue;
910:
911:           bitmap_set_bit (uses, u);
912:           worklist.safe_push (u);
913:         }
914:     }
915:
916:   bitmap_copy (phis, live_phis);
917:   BITMAP_FREE (live_phis);
918:   free (defs);
919: }
920:
921: /* Return the set of blocks where variable VAR is defined and the blocks
```

## gcc/tree-into-ssa.cc:962–1176

```text
962: insert_phi_nodes_for (tree var, bitmap phi_insertion_points, bool update_p)
963: {
964:   unsigned bb_index;
965:   edge e;
966:   gphi *phi;
967:   basic_block bb;
968:   bitmap_iterator bi;
969:   def_blocks *def_map = find_def_blocks_for (var);
970:
971:   /* Remove the blocks where we already have PHI nodes for VAR.  */
972:   bitmap_and_compl_into (phi_insertion_points, def_map->phi_blocks);
973:
974:   /* Remove obviously useless phi nodes.  */
975:   prune_unused_phi_nodes (phi_insertion_points, def_map->def_blocks,
976:                           def_map->livein_blocks);
977:
978:   /* And insert the PHI nodes.  */
979:   EXECUTE_IF_SET_IN_BITMAP (phi_insertion_points, 0, bb_index, bi)
980:     {
981:       bb = BASIC_BLOCK_FOR_FN (cfun, bb_index);
982:       if (update_p)
983:         mark_block_for_update (bb);
984:
985:       if (dump_file && (dump_flags & TDF_DETAILS))
986:         {
987:           fprintf (dump_file, "creating PHI node in block #%d for ", bb_index);
988:           print_generic_expr (dump_file, var, TDF_SLIM);
989:           fprintf (dump_file, "\n");
990:         }
991:       phi = NULL;
992:
993:       if (TREE_CODE (var) == SSA_NAME)
994:         {
995:           /* If we are rewriting SSA names, create the LHS of the PHI
996:              node by duplicating VAR.  This is useful in the case of
997:              pointers, to also duplicate pointer attributes (alias
998:              information, in particular).  */
999:           edge_iterator ei;
1000:           tree new_lhs;
1001:
1002:           gcc_checking_assert (update_p);
1003:           new_lhs = duplicate_ssa_name (var, NULL);
1004:           phi = create_phi_node (new_lhs, bb);
1005:           add_new_name_mapping (new_lhs, var);
1006:
1007:           /* Add VAR to every argument slot of PHI.  We need VAR in
1008:              every argument so that rewrite_update_phi_arguments knows
1009:              which name is this PHI node replacing.  If VAR is a
1010:              symbol marked for renaming, this is not necessary, the
1011:              renamer will use the symbol on the LHS to get its
1012:              reaching definition.  */
1013:           FOR_EACH_EDGE (e, ei, bb->preds)
1014:             add_phi_arg (phi, var, e, UNKNOWN_LOCATION);
1015:         }
1016:       else
1017:         {
1018:           tree tracked_var;
1019:
1020:           gcc_checking_assert (DECL_P (var));
1021:           phi = create_phi_node (var, bb);
1022:
1023:           tracked_var = target_for_debug_bind (var);
1024:           if (tracked_var)
1025:             {
1026:               gimple *note = gimple_build_debug_bind (tracked_var,
1027:                                                       PHI_RESULT (phi),
1028:                                                      phi);
1029:               gimple_stmt_iterator si = gsi_after_labels (bb);
1030:               gsi_insert_before (&si, note, GSI_SAME_STMT);
1031:             }
1032:         }
1033:
1034:       /* Mark this PHI node as interesting for update_ssa.  */
1035:       set_register_defs (phi, true);
1036:       mark_phi_for_rewrite (bb, phi);
1037:     }
1038: }
1039:
1040: /* Sort var_infos after DECL_UID of their var.  */
1041:
1042: static int
1043: insert_phi_nodes_compare_var_infos (const void *a, const void *b)
1044: {
1045:   const var_info *defa = *(var_info * const *)a;
1046:   const var_info *defb = *(var_info * const *)b;
1047:   if (DECL_UID (defa->var) < DECL_UID (defb->var))
1048:     return -1;
1049:   else
1050:     return 1;
1051: }
1052:
1053: /* Insert PHI nodes at the dominance frontier of blocks with variable
1054:    definitions.  DFS contains the dominance frontier information for
1055:    the flowgraph.  */
1056:
1057: static void
1058: insert_phi_nodes (bitmap_head *dfs)
1059: {
1060:   hash_table<var_info_hasher>::iterator hi;
1061:   unsigned i;
1062:   var_info *info;
1063:
1064:   /* When the gimplifier introduces SSA names it cannot easily avoid
1065:      situations where abnormal edges added by CFG construction break
1066:      the use-def dominance requirement.  For this case rewrite SSA
1067:      names with broken use-def dominance out-of-SSA and register them
1068:      for PHI insertion.  We only need to do this if abnormal edges
1069:      can appear in the function.  */
1070:   tree name;
1071:   if (cfun->calls_setjmp
1072:       || cfun->has_nonlocal_label)
1073:     FOR_EACH_SSA_NAME (i, name, cfun)
1074:       {
1075:         gimple *def_stmt = SSA_NAME_DEF_STMT (name);
1076:         if (SSA_NAME_IS_DEFAULT_DEF (name))
1077:           continue;
1078:
1079:         basic_block def_bb = gimple_bb (def_stmt);
1080:         imm_use_iterator it;
1081:         gimple *use_stmt;
1082:         bool need_phis = false;
1083:         FOR_EACH_IMM_USE_STMT (use_stmt, it, name)
1084:           {
1085:             basic_block use_bb = gimple_bb (use_stmt);
1086:             if (use_bb != def_bb
1087:                 && ! dominated_by_p (CDI_DOMINATORS, use_bb, def_bb))
1088:               need_phis = true;
1089:           }
1090:         if (need_phis)
1091:           {
1092:             tree var = create_tmp_reg (TREE_TYPE (name));
1093:             use_operand_p use_p;
1094:             FOR_EACH_IMM_USE_STMT (use_stmt, it, name)
1095:               {
1096:                 basic_block use_bb = gimple_bb (use_stmt);
1097:                 FOR_EACH_IMM_USE_ON_STMT (use_p, it)
1098:                     SET_USE (use_p, var);
1099:                 update_stmt (use_stmt);
1100:                 set_livein_block (var, use_bb);
1101:                 set_rewrite_uses (use_stmt, true);
1102:                 bitmap_set_bit (interesting_blocks, use_bb->index);
1103:               }
1104:             def_operand_p def_p;
1105:             ssa_op_iter dit;
1106:             FOR_EACH_SSA_DEF_OPERAND (def_p, def_stmt, dit, SSA_OP_DEF)
1107:               if (DEF_FROM_PTR (def_p) == name)
1108:                 SET_DEF (def_p, var);
1109:             update_stmt (def_stmt);
1110:             set_def_block (var, def_bb, false);
1111:             set_register_defs (def_stmt, true);
1112:             bitmap_set_bit (interesting_blocks, def_bb->index);
1113:             release_ssa_name (name);
1114:           }
1115:       }
1116:
1117:   auto_vec<var_info *> vars (var_infos->elements ());
1118:   FOR_EACH_HASH_TABLE_ELEMENT (*var_infos, info, var_info_p, hi)
1119:     if (info->info.need_phi_state != NEED_PHI_STATE_NO)
1120:       vars.quick_push (info);
1121:
1122:   /* Do two stages to avoid code generation differences for UID
1123:      differences but no UID ordering differences.  */
1124:   vars.qsort (insert_phi_nodes_compare_var_infos);
1125:
1126:   FOR_EACH_VEC_ELT (vars, i, info)
1127:     {
1128:       bitmap idf = compute_idf (info->info.def_blocks.def_blocks, dfs);
1129:       insert_phi_nodes_for (info->var, idf, false);
1130:       BITMAP_FREE (idf);
1131:     }
1132: }
1133:
1134:
1135: /* Push SYM's current reaching definition into BLOCK_DEFS_STACK and
1136:    register DEF (an SSA_NAME) to be a new definition for SYM.  */
1137:
1138: static void
1139: register_new_def (tree def, tree sym)
1140: {
1141:   common_info *info = get_common_info (sym);
1142:   tree currdef;
1143:
1144:   /* If this variable is set in a single basic block and all uses are
1145:      dominated by the set(s) in that single basic block, then there is
1146:      no reason to record anything for this variable in the block local
1147:      definition stacks.  Doing so just wastes time and memory.
1148:
1149:      This is the same test to prune the set of variables which may
1150:      need PHI nodes.  So we just use that information since it's already
1151:      computed and available for us to use.  */
1152:   if (info->need_phi_state == NEED_PHI_STATE_NO)
1153:     {
1154:       info->current_def = def;
1155:       return;
1156:     }
1157:
1158:   currdef = info->current_def;
1159:
1160:   /* If SYM is not a GIMPLE register, then CURRDEF may be a name whose
1161:      SSA_NAME_VAR is not necessarily SYM.  In this case, also push SYM
1162:      in the stack so that we know which symbol is being defined by
1163:      this SSA name when we unwind the stack.  */
1164:   if (currdef && !is_gimple_reg (sym))
1165:     block_defs_stack.safe_push (sym);
1166:
1167:   /* Push the current reaching definition into BLOCK_DEFS_STACK.  This
1168:      stack is later used by the dominator tree callbacks to restore
1169:      the reaching definitions for all the variables defined in the
1170:      block after a recursive visit to all its immediately dominated
1171:      blocks.  If there is no current reaching definition, then just
1172:      record the underlying _DECL node.  */
1173:   block_defs_stack.safe_push (currdef ? currdef : sym);
1174:
1175:   /* Set the current reaching definition for SYM to be DEF.  */
1176:   info->current_def = def;
```

## gcc/tree-into-ssa.cc:1208–1230

```text
1208: {
1209:   common_info *info = get_common_info (var);
1210:   tree currdef;
1211:
1212:   /* Lookup the current reaching definition for VAR.  */
1213:   currdef = info->current_def;
1214:
1215:   /* If there is no reaching definition for VAR, create and register a
1216:      default definition for it (if needed).  */
1217:   if (currdef == NULL_TREE)
1218:     {
1219:       tree sym = DECL_P (var) ? var : SSA_NAME_VAR (var);
1220:       if (! sym)
1221:         sym = create_tmp_reg (TREE_TYPE (var));
1222:       currdef = get_or_create_ssa_default_def (cfun, sym);
1223:     }
1224:
1225:   /* Return the current reaching definition for VAR, or the default
1226:      definition, if we had to create one.  */
1227:   return currdef;
1228: }
1229:
1230:
```

## gcc/tree-into-ssa.cc:1337–1544

```text
1337: rewrite_stmt (gimple_stmt_iterator *si)
1338: {
1339:   use_operand_p use_p;
1340:   def_operand_p def_p;
1341:   ssa_op_iter iter;
1342:   gimple *stmt = gsi_stmt (*si);
1343:
1344:   /* If mark_def_sites decided that we don't need to rewrite this
1345:      statement, ignore it.  */
1346:   gcc_assert (blocks_to_update == NULL);
1347:   if (!rewrite_uses_p (stmt) && !register_defs_p (stmt))
1348:     return;
1349:
1350:   if (dump_file && (dump_flags & TDF_DETAILS))
1351:     {
1352:       fprintf (dump_file, "Renaming statement ");
1353:       print_gimple_stmt (dump_file, stmt, 0, TDF_SLIM);
1354:       fprintf (dump_file, "\n");
1355:     }
1356:
1357:   /* Step 1.  Rewrite USES in the statement.  */
1358:   if (rewrite_uses_p (stmt))
1359:     {
1360:       if (is_gimple_debug (stmt))
1361:         rewrite_debug_stmt_uses (stmt);
1362:       else
1363:         FOR_EACH_SSA_USE_OPERAND (use_p, stmt, iter, SSA_OP_ALL_USES)
1364:           {
1365:             tree var = USE_FROM_PTR (use_p);
1366:             if (TREE_CODE (var) == SSA_NAME)
1367:               continue;
1368:             gcc_checking_assert (DECL_P (var));
1369:             SET_USE (use_p, get_reaching_def (var));
1370:           }
1371:     }
1372:
1373:   /* Step 2.  Register the statement's DEF operands.  */
1374:   if (register_defs_p (stmt))
1375:     FOR_EACH_SSA_DEF_OPERAND (def_p, stmt, iter, SSA_OP_ALL_DEFS)
1376:       {
1377:         tree var = DEF_FROM_PTR (def_p);
1378:         tree name;
1379:         tree tracked_var;
1380:
1381:         if (TREE_CODE (var) == SSA_NAME)
1382:           continue;
1383:         gcc_checking_assert (DECL_P (var));
1384:
1385:         if (gimple_clobber_p (stmt)
1386:             && is_gimple_reg (var))
1387:           {
1388:             /* If we rewrite a DECL into SSA form then drop its
1389:                clobber stmts and replace uses with a new default def.  */
1390:             gcc_checking_assert (VAR_P (var) && !gimple_vdef (stmt));
1391:             gsi_replace (si, gimple_build_nop (), true);
1392:             register_new_def (get_or_create_ssa_default_def (cfun, var), var);
1393:             break;
1394:           }
1395:
1396:         name = make_ssa_name (var, stmt);
1397:         SET_DEF (def_p, name);
1398:         register_new_def (DEF_FROM_PTR (def_p), var);
1399:
1400:         /* Do not insert debug stmts if the stmt ends the BB.  */
1401:         if (stmt_ends_bb_p (stmt))
1402:           continue;
1403:
1404:         tracked_var = target_for_debug_bind (var);
1405:         if (tracked_var)
1406:           {
1407:             gimple *note = gimple_build_debug_bind (tracked_var, name, stmt);
1408:             gsi_insert_after (si, note, GSI_SAME_STMT);
1409:           }
1410:       }
1411: }
1412:
1413:
1414: /* SSA Rewriting Step 3.  Visit all the successor blocks of BB looking for
1415:    PHI nodes.  For every PHI node found, add a new argument containing the
1416:    current reaching definition for the variable and the edge through which
1417:    that definition is reaching the PHI node.  */
1418:
1419: static void
1420: rewrite_add_phi_arguments (basic_block bb)
1421: {
1422:   edge e;
1423:   edge_iterator ei;
1424:
1425:   FOR_EACH_EDGE (e, ei, bb->succs)
1426:     {
1427:       gphi *phi;
1428:       gphi_iterator gsi;
1429:
1430:       for (gsi = gsi_start_phis (e->dest); !gsi_end_p (gsi);
1431:            gsi_next (&gsi))
1432:         {
1433:           tree currdef, res;
1434:           location_t loc;
1435:
1436:           phi = gsi.phi ();
1437:           res = gimple_phi_result (phi);
1438:           currdef = get_reaching_def (SSA_NAME_VAR (res));
1439:           /* Virtual operand PHI args do not need a location.  */
1440:           if (virtual_operand_p (res))
1441:             loc = UNKNOWN_LOCATION;
1442:           else
1443:             loc = gimple_location (SSA_NAME_DEF_STMT (currdef));
1444:           add_phi_arg (phi, currdef, e, loc);
1445:         }
1446:     }
1447: }
1448:
1449: class rewrite_dom_walker : public dom_walker
1450: {
1451: public:
1452:   rewrite_dom_walker (cdi_direction direction)
1453:     : dom_walker (direction, ALL_BLOCKS, NULL) {}
1454:
1455:   edge before_dom_children (basic_block) final override;
1456:   void after_dom_children (basic_block) final override;
1457: };
1458:
1459: /* SSA Rewriting Step 1.  Initialization, create a block local stack
1460:    of reaching definitions for new SSA names produced in this block
1461:    (BLOCK_DEFS).  Register new definitions for every PHI node in the
1462:    block.  */
1463:
1464: edge
1465: rewrite_dom_walker::before_dom_children (basic_block bb)
1466: {
1467:   if (dump_file && (dump_flags & TDF_DETAILS))
1468:     fprintf (dump_file, "\n\nRenaming block #%d\n\n", bb->index);
1469:
1470:   /* Mark the unwind point for this block.  */
1471:   block_defs_stack.safe_push (NULL_TREE);
1472:
1473:   /* Step 1.  Register new definitions for every PHI node in the block.
1474:      Conceptually, all the PHI nodes are executed in parallel and each PHI
1475:      node introduces a new version for the associated variable.  */
1476:   for (gphi_iterator gsi = gsi_start_phis (bb); !gsi_end_p (gsi);
1477:        gsi_next (&gsi))
1478:     {
1479:       tree result = gimple_phi_result (gsi_stmt (gsi));
1480:       register_new_def (result, SSA_NAME_VAR (result));
1481:     }
1482:
1483:   /* Step 2.  Rewrite every variable used in each statement in the block
1484:      with its immediate reaching definitions.  Update the current definition
1485:      of a variable when a new real or virtual definition is found.  */
1486:   if (bitmap_bit_p (interesting_blocks, bb->index))
1487:     for (gimple_stmt_iterator gsi = gsi_start_bb (bb); !gsi_end_p (gsi);
1488:          gsi_next (&gsi))
1489:       rewrite_stmt (&gsi);
1490:
1491:   /* Step 3.  Visit all the successor blocks of BB looking for PHI nodes.
1492:      For every PHI node found, add a new argument containing the current
1493:      reaching definition for the variable and the edge through which that
1494:      definition is reaching the PHI node.  */
1495:   rewrite_add_phi_arguments (bb);
1496:
1497:   return NULL;
1498: }
1499:
1500:
1501:
1502: /* Called after visiting all the statements in basic block BB and all
1503:    of its dominator children.  Restore CURRDEFS to its original value.  */
1504:
1505: void
1506: rewrite_dom_walker::after_dom_children (basic_block bb ATTRIBUTE_UNUSED)
1507: {
1508:   /* Restore CURRDEFS to its original state.  */
1509:   while (block_defs_stack.length () > 0)
1510:     {
1511:       tree tmp = block_defs_stack.pop ();
1512:       tree saved_def, var;
1513:
1514:       if (tmp == NULL_TREE)
1515:         break;
1516:
1517:       if (TREE_CODE (tmp) == SSA_NAME)
1518:         {
1519:           /* If we recorded an SSA_NAME, then make the SSA_NAME the
1520:              current definition of its underlying variable.  Note that
1521:              if the SSA_NAME is not for a GIMPLE register, the symbol
1522:              being defined is stored in the next slot in the stack.
1523:              This mechanism is needed because an SSA name for a
1524:              non-register symbol may be the definition for more than
1525:              one symbol (e.g., SFTs, aliased variables, etc).  */
1526:           saved_def = tmp;
1527:           var = SSA_NAME_VAR (saved_def);
1528:           if (!is_gimple_reg (var))
1529:             var = block_defs_stack.pop ();
1530:         }
1531:       else
1532:         {
1533:           /* If we recorded anything else, it must have been a _DECL
1534:              node and its current reaching definition must have been
1535:              NULL.  */
1536:           saved_def = NULL;
1537:           var = tmp;
1538:         }
1539:
1540:       get_common_info (var)->current_def = saved_def;
1541:     }
1542: }
1543:
1544:
```

## gcc/tree-into-ssa.cc:2285–2301

```text
2285: rewrite_blocks (basic_block entry, enum rewrite_mode what)
2286: {
2287:   block_defs_stack.create (10);
2288:
2289:   /* Recursively walk the dominator tree rewriting each statement in
2290:      each basic block.  */
2291:   if (what == REWRITE_ALL)
2292:     rewrite_dom_walker (CDI_DOMINATORS).walk (entry);
2293:   else if (what == REWRITE_UPDATE)
2294:     rewrite_update_dom_walker (CDI_DOMINATORS).walk (entry);
2295:   else if (what == REWRITE_UPDATE_REGION)
2296:     {
2297:       /* First mark all blocks in the SEME region dominated by
2298:          entry and exited by blocks not backwards reachable from
2299:          blocks_to_update.  Optimize for dense blocks_to_update
2300:          so instead of seeding the worklist with a copy of
2301:          blocks_to_update treat those blocks explicit.  */
```

## gcc/tree-into-ssa.cc:2370–2440

```text
2370: class mark_def_dom_walker : public dom_walker
2371: {
2372: public:
2373:   mark_def_dom_walker (cdi_direction direction);
2374:   ~mark_def_dom_walker ();
2375:
2376:   edge before_dom_children (basic_block) final override;
2377:
2378: private:
2379:   /* Notice that this bitmap is indexed using variable UIDs, so it must be
2380:      large enough to accommodate all the variables referenced in the
2381:      function, not just the ones we are renaming.  */
2382:   bitmap m_kills;
2383: };
2384:
2385: mark_def_dom_walker::mark_def_dom_walker (cdi_direction direction)
2386:   : dom_walker (direction, ALL_BLOCKS, NULL), m_kills (BITMAP_ALLOC (NULL))
2387: {
2388: }
2389:
2390: mark_def_dom_walker::~mark_def_dom_walker ()
2391: {
2392:   BITMAP_FREE (m_kills);
2393: }
2394:
2395: /* Block processing routine for mark_def_sites.  Clear the KILLS bitmap
2396:    at the start of each block, and call mark_def_sites for each statement.  */
2397:
2398: edge
2399: mark_def_dom_walker::before_dom_children (basic_block bb)
2400: {
2401:   gimple_stmt_iterator gsi;
2402:
2403:   bitmap_clear (m_kills);
2404:   for (gsi = gsi_start_bb (bb); !gsi_end_p (gsi); gsi_next (&gsi))
2405:     mark_def_sites (bb, gsi_stmt (gsi), m_kills);
2406:   return NULL;
2407: }
2408:
2409: /* Initialize internal data needed during renaming.  */
2410:
2411: static void
2412: init_ssa_renamer (void)
2413: {
2414:   cfun->gimple_df->in_ssa_p = false;
2415:
2416:   /* Allocate memory for the DEF_BLOCKS hash table.  */
2417:   gcc_assert (!var_infos);
2418:   var_infos = new hash_table<var_info_hasher>
2419:     (vec_safe_length (cfun->local_decls));
2420:
2421:   bitmap_obstack_initialize (&update_ssa_obstack);
2422: }
2423:
2424:
2425: /* Deallocate internal data structures used by the renamer.  */
2426:
2427: static void
2428: fini_ssa_renamer (void)
2429: {
2430:   delete var_infos;
2431:     var_infos = NULL;
2432:
2433:   bitmap_obstack_release (&update_ssa_obstack);
2434:
2435:   cfun->gimple_df->ssa_renaming_needed = 0;
2436:   cfun->gimple_df->rename_vops = 0;
2437:   cfun->gimple_df->in_ssa_p = true;
2438: }
2439:
2440: /* Main entry point into the SSA builder.  The renaming process
```

## gcc/tree-into-ssa.cc:2460–2584

```text
2460:   GIMPLE_PASS, /* type */
2461:   "ssa", /* name */
2462:   OPTGROUP_NONE, /* optinfo_flags */
2463:   TV_TREE_INTO_SSA, /* tv_id */
2464:   PROP_cfg, /* properties_required */
2465:   PROP_ssa, /* properties_provided */
2466:   0, /* properties_destroyed */
2467:   0, /* todo_flags_start */
2468:   TODO_remove_unused_locals, /* todo_flags_finish */
2469: };
2470:
2471: class pass_build_ssa : public gimple_opt_pass
2472: {
2473: public:
2474:   pass_build_ssa (gcc::context *ctxt)
2475:     : gimple_opt_pass (pass_data_build_ssa, ctxt)
2476:   {}
2477:
2478:   /* opt_pass methods: */
2479:   bool gate (function *fun) final override
2480:     {
2481:       /* Do nothing for functions that were produced already in SSA form.  */
2482:       return !(fun->curr_properties & PROP_ssa);
2483:     }
2484:
2485:   unsigned int execute (function *) final override;
2486:
2487: }; // class pass_build_ssa
2488:
2489: unsigned int
2490: pass_build_ssa::execute (function *fun)
2491: {
2492:   bitmap_head *dfs;
2493:   basic_block bb;
2494:
2495:   /* Increase the set of variables we can rewrite into SSA form
2496:      by clearing TREE_ADDRESSABLE and transform the IL to support this.  */
2497:   if (optimize)
2498:     execute_update_addresses_taken ();
2499:
2500:   /* Initialize operand data structures.  */
2501:   init_ssa_operands (fun);
2502:
2503:   /* Initialize internal data needed by the renamer.  */
2504:   init_ssa_renamer ();
2505:
2506:   /* Initialize the set of interesting blocks.  The callback
2507:      mark_def_sites will add to this set those blocks that the renamer
2508:      should process.  */
2509:   interesting_blocks = sbitmap_alloc (last_basic_block_for_fn (fun));
2510:   bitmap_clear (interesting_blocks);
2511:
2512:   /* Initialize dominance frontier.  */
2513:   dfs = XNEWVEC (bitmap_head, last_basic_block_for_fn (fun));
2514:   FOR_EACH_BB_FN (bb, fun)
2515:     bitmap_initialize (&dfs[bb->index], &bitmap_default_obstack);
2516:
2517:   /* 1- Compute dominance frontiers.  */
2518:   calculate_dominance_info (CDI_DOMINATORS);
2519:   compute_dominance_frontiers (dfs);
2520:
2521:   /* 2- Find and mark definition sites.  */
2522:   mark_def_dom_walker (CDI_DOMINATORS).walk (fun->cfg->x_entry_block_ptr);
2523:
2524:   /* 3- Insert PHI nodes at dominance frontiers of definition blocks.  */
2525:   insert_phi_nodes (dfs);
2526:
2527:   /* 4- Rename all the blocks.  */
2528:   rewrite_blocks (ENTRY_BLOCK_PTR_FOR_FN (fun), REWRITE_ALL);
2529:
2530:   /* Free allocated memory.  */
2531:   FOR_EACH_BB_FN (bb, fun)
2532:     bitmap_clear (&dfs[bb->index]);
2533:   free (dfs);
2534:
2535:   sbitmap_free (interesting_blocks);
2536:   interesting_blocks = NULL;
2537:
2538:   fini_ssa_renamer ();
2539:
2540:   /* Try to get rid of all gimplifier generated temporaries by making
2541:      its SSA names anonymous.  This way we can garbage collect them
2542:      all after removing unused locals which we do in our TODO.  */
2543:   unsigned i;
2544:   tree name;
2545:
2546:   FOR_EACH_SSA_NAME (i, name, cfun)
2547:     {
2548:       if (SSA_NAME_IS_DEFAULT_DEF (name))
2549:         continue;
2550:       tree decl = SSA_NAME_VAR (name);
2551:       if (decl
2552:           && VAR_P (decl)
2553:           && !VAR_DECL_IS_VIRTUAL_OPERAND (decl)
2554:           && DECL_IGNORED_P (decl))
2555:         SET_SSA_NAME_VAR_OR_IDENTIFIER (name, DECL_NAME (decl));
2556:     }
2557:
2558:   /* Initialize SSA_NAME_POINTS_TO_READONLY_MEMORY.  */
2559:   tree fnspec_tree
2560:          = lookup_attribute ("fn spec",
2561:                              TYPE_ATTRIBUTES (TREE_TYPE (fun->decl)));
2562:   if (fnspec_tree)
2563:     {
2564:       attr_fnspec fnspec (TREE_VALUE (TREE_VALUE (fnspec_tree)));
2565:       unsigned i = 0;
2566:       for (tree arg = DECL_ARGUMENTS (cfun->decl);
2567:            arg; arg = DECL_CHAIN (arg), ++i)
2568:         {
2569:           if (!fnspec.arg_specified_p (i))
2570:            break;
2571:           if (fnspec.arg_readonly_p (i))
2572:             {
2573:               tree name = ssa_default_def (fun, arg);
2574:               if (name)
2575:                 SSA_NAME_POINTS_TO_READONLY_MEMORY (name) = 1;
2576:             }
2577:         }
2578:     }
2579:
2580:   return 0;
2581: }
2582:
2583: } // anon namespace
2584:
```

## gcc/tree-into-ssa.cc:3146–3151

```text
3146: need_ssa_update_p (struct function *fn)
3147: {
3148:   gcc_assert (fn != NULL);
3149:   return (update_ssa_initialized_fn == fn
3150:           || (fn->gimple_df && fn->gimple_df->ssa_renaming_needed));
3151: }
```

## gcc/tree-into-ssa.cc:3369–3385

```text
3369: update_ssa (unsigned update_flags)
3370: {
3371:   basic_block bb, start_bb;
3372:   bitmap_iterator bi;
3373:   unsigned i = 0;
3374:   bool insert_phi_p;
3375:   sbitmap_iterator sbi;
3376:   tree sym;
3377:
3378:   /* Only one update flag should be set.  */
3379:   gcc_assert (update_flags == TODO_update_ssa
3380:               || update_flags == TODO_update_ssa_no_phi
3381:               || update_flags == TODO_update_ssa_full_phi
3382:               || update_flags == TODO_update_ssa_only_virtuals);
3383:
3384:   if (!need_ssa_update_p (cfun))
3385:     return;
```

## gcc/tree-phinodes.cc:60–215

```text
60:    might allow us to pick up a few reusable PHI nodes, it could potentially
61:    be very expensive if the program has released a bunch of large PHI nodes,
62:    but keeps asking for even larger PHI nodes.  Experiments have shown that
63:    walking the elements of the last array entry would result in finding less
64:    than .1% additional reusable PHI nodes.
65:
66:    Note that we can never have less than two PHI argument slots.  Thus,
67:    the -2 on all the calculations below.  */
68:
69: #define NUM_BUCKETS 10
70: static GTY ((deletable (""))) vec<gimple *, va_gc> *free_phinodes[NUM_BUCKETS - 2];
71: static unsigned long free_phinode_count;
72:
73: static int ideal_phi_node_len (int);
74:
75: unsigned int phi_nodes_reused;
76: unsigned int phi_nodes_created;
77:
78: /* Dump some simple statistics regarding the re-use of PHI nodes.  */
79:
80: void
81: phinodes_print_statistics (void)
82: {
83:   fprintf (stderr, "%-32s" PRsa (11) "\n", "PHI nodes allocated:",
84:            SIZE_AMOUNT (phi_nodes_created));
85:   fprintf (stderr, "%-32s" PRsa (11) "\n", "PHI nodes reused:",
86:            SIZE_AMOUNT (phi_nodes_reused));
87: }
88:
89: /* Allocate a PHI node with at least LEN arguments.  If the free list
90:    happens to contain a PHI node with LEN arguments or more, return
91:    that one.  */
92:
93: static inline gphi *
94: allocate_phi_node (size_t len)
95: {
96:   gphi *phi;
97:   size_t bucket = NUM_BUCKETS - 2;
98:   size_t size = sizeof (struct gphi)
99:                 + (len - 1) * sizeof (struct phi_arg_d);
100:
101:   if (free_phinode_count)
102:     for (bucket = len - 2; bucket < NUM_BUCKETS - 2; bucket++)
103:       if (free_phinodes[bucket])
104:         break;
105:
106:   /* If our free list has an element, then use it.  */
107:   if (bucket < NUM_BUCKETS - 2
108:       && gimple_phi_capacity ((*free_phinodes[bucket])[0]) >= len)
109:     {
110:       free_phinode_count--;
111:       phi = as_a <gphi *> (free_phinodes[bucket]->pop ());
112:       if (free_phinodes[bucket]->is_empty ())
113:         vec_free (free_phinodes[bucket]);
114:       if (GATHER_STATISTICS)
115:         phi_nodes_reused++;
116:     }
117:   else
118:     {
119:       phi = static_cast <gphi *> (ggc_internal_alloc (size));
120:       if (GATHER_STATISTICS)
121:         {
122:           enum gimple_alloc_kind kind = gimple_alloc_kind (GIMPLE_PHI);
123:           phi_nodes_created++;
124:           gimple_alloc_counts[(int) kind]++;
125:           gimple_alloc_sizes[(int) kind] += size;
126:         }
127:     }
128:
129:   return phi;
130: }
131:
132: /* Given LEN, the original number of requested PHI arguments, return
133:    a new, "ideal" length for the PHI node.  The "ideal" length rounds
134:    the total size of the PHI node up to the next power of two bytes.
135:
136:    Rounding up will not result in wasting any memory since the size request
137:    will be rounded up by the GC system anyway.  [ Note this is not entirely
138:    true since the original length might have fit on one of the special
139:    GC pages. ]  By rounding up, we may avoid the need to reallocate the
140:    PHI node later if we increase the number of arguments for the PHI.  */
141:
142: static int
143: ideal_phi_node_len (int len)
144: {
145:   size_t size, new_size;
146:   int log2, new_len;
147:
148:   /* We do not support allocations of less than two PHI argument slots.  */
149:   if (len < 2)
150:     len = 2;
151:
152:   /* Compute the number of bytes of the original request.  */
153:   size = sizeof (struct gphi)
154:          + (len - 1) * sizeof (struct phi_arg_d);
155:
156:   /* Round it up to the next power of two.  */
157:   log2 = ceil_log2 (size);
158:   new_size = 1 << log2;
159:
160:   /* Now compute and return the number of PHI argument slots given an
161:      ideal size allocation.  */
162:   new_len = len + (new_size - size) / sizeof (struct phi_arg_d);
163:   return new_len;
164: }
165:
166: /* Return a PHI node with LEN argument slots for variable VAR.  */
167:
168: static gphi *
169: make_phi_node (tree var, int len)
170: {
171:   gphi *phi;
172:   int capacity, i;
173:
174:   capacity = ideal_phi_node_len (len);
175:
176:   phi = allocate_phi_node (capacity);
177:
178:   /* We need to clear the entire PHI node, including the argument
179:      portion, because we represent a "missing PHI argument" by placing
180:      NULL_TREE in PHI_ARG_DEF.  */
181:   memset (phi, 0, (sizeof (struct gphi)
182:                    - sizeof (struct phi_arg_d)
183:                    + sizeof (struct phi_arg_d) * len));
184:   phi->code = GIMPLE_PHI;
185:   gimple_init_singleton (phi);
186:   phi->nargs = len;
187:   phi->capacity = capacity;
188:   if (!var)
189:     ;
190:   else if (TREE_CODE (var) == SSA_NAME)
191:     gimple_phi_set_result (phi, var);
192:   else
193:     gimple_phi_set_result (phi, make_ssa_name (var, phi));
194:
195:   for (i = 0; i < len; i++)
196:     {
197:       use_operand_p  imm;
198:
199:       gimple_phi_arg_set_location (phi, i, UNKNOWN_LOCATION);
200:       imm = gimple_phi_arg_imm_use_ptr (phi, i);
201:       imm->use = gimple_phi_arg_def_ptr (phi, i);
202:       imm->prev = NULL;
203:       imm->next = NULL;
204:       imm->loc.stmt = phi;
205:     }
206:
207:   return phi;
208: }
209:
210: /* We no longer need PHI, release it so that it may be reused.  */
211:
212: static void
213: release_phi_node (gimple *phi)
214: {
215:   size_t bucket;
```

## gcc/tree-ssanames.cc:143–165

```text
143:    zero use default.  */
144:
145: void
146: init_ssanames (struct function *fn, int size)
147: {
148:   if (!size)
149:     vec_alloc (SSANAMES (fn), 50);
150:   else
151:     vec_safe_reserve (SSANAMES (fn), size, true);
152:
153:   /* Version 0 is special, so reserve the first slot in the table.  Though
154:      currently unused, we may use version 0 in alias analysis as part of
155:      the heuristics used to group aliases when the alias sets are too
156:      large.
157:
158:      We use vec::quick_push here because we know that SSA_NAMES has at
159:      least 50 elements reserved in it.  */
160:   SSANAMES (fn)->quick_push (NULL_TREE);
161:   FREE_SSANAMES (fn) = NULL;
162:   FREE_SSANAMES_QUEUE (fn) = NULL;
163:
164:   fn->gimple_df->ssa_renaming_needed = 0;
165:   fn->gimple_df->rename_vops = 0;
```

## gcc/tree-ssanames.cc:351–420

```text
351: make_ssa_name_fn (struct function *fn, tree var, gimple *stmt,
352:                   unsigned int version)
353: {
354:   tree t;
355:   gcc_assert (VAR_P (var)
356:               || TREE_CODE (var) == PARM_DECL
357:               || TREE_CODE (var) == RESULT_DECL
358:               || (TYPE_P (var) && is_gimple_reg_type (var)));
359:
360:   /* Get the specified SSA name version.  */
361:   if (version != 0)
362:     {
363:       t = make_node (SSA_NAME);
364:       SSA_NAME_VERSION (t) = version;
365:       if (version >= SSANAMES (fn)->length ())
366:         vec_safe_grow_cleared (SSANAMES (fn), version + 1, true);
367:       gcc_assert ((*SSANAMES (fn))[version] == NULL);
368:       (*SSANAMES (fn))[version] = t;
369:       ssa_name_nodes_created++;
370:     }
371:   /* If our free list has an element, then use it.  */
372:   else if (!vec_safe_is_empty (FREE_SSANAMES (fn)))
373:     {
374:       t = FREE_SSANAMES (fn)->pop ();
375:       ssa_name_nodes_reused++;
376:
377:       /* The node was cleared out when we put it on the free list, so
378:          there is no need to do so again here.  */
379:       gcc_assert ((*SSANAMES (fn))[SSA_NAME_VERSION (t)] == NULL);
380:       (*SSANAMES (fn))[SSA_NAME_VERSION (t)] = t;
381:     }
382:   else
383:     {
384:       t = make_node (SSA_NAME);
385:       SSA_NAME_VERSION (t) = SSANAMES (fn)->length ();
386:       vec_safe_push (SSANAMES (fn), t);
387:       ssa_name_nodes_created++;
388:     }
389:
390:   if (TYPE_P (var))
391:     {
392:       TREE_TYPE (t) = TYPE_MAIN_VARIANT (var);
393:       SET_SSA_NAME_VAR_OR_IDENTIFIER (t, NULL_TREE);
394:     }
395:   else
396:     {
397:       TREE_TYPE (t) = TREE_TYPE (var);
398:       SET_SSA_NAME_VAR_OR_IDENTIFIER (t, var);
399:     }
400:   SSA_NAME_DEF_STMT (t) = stmt;
401:   if (POINTER_TYPE_P (TREE_TYPE (t)))
402:     SSA_NAME_PTR_INFO (t) = NULL;
403:   else
404:     SSA_NAME_RANGE_INFO (t) = NULL;
405:
406:   SSA_NAME_IN_FREE_LIST (t) = 0;
407:   SSA_NAME_IS_DEFAULT_DEF (t) = 0;
408:   init_ssa_name_imm_use (t);
409: #if defined ENABLE_GIMPLE_CHECKING
410:   t->ssa_name.active_iterated_stmt = NULL;
411:   t->ssa_name.fast_iteration_depth = 0;
412: #endif
413:
414:   return t;
415: }
416:
417: /* Update the range information for NAME, intersecting into an existing
418:    range if applicable.  Return TRUE if the range was updated.  */
419:
420: bool
```

## gcc/tree-ssanames.cc:665–731

```text
665: release_ssa_name_fn (struct function *fn, tree var)
666: {
667:   if (!var)
668:     return;
669:
670:   /* Never release the default definition for a symbol.  It's a
671:      special SSA name that should always exist once it's created.  */
672:   if (SSA_NAME_IS_DEFAULT_DEF (var))
673:     return;
674:
675:   /* If VAR has been registered for SSA updating, don't remove it.
676:      After update_ssa has run, the name will be released.  */
677:   if (name_registered_for_update_p (var))
678:     {
679:       release_ssa_name_after_update_ssa (var);
680:       return;
681:     }
682:
683:   /* release_ssa_name can be called multiple times on a single SSA_NAME.
684:      However, it should only end up on our free list one time.   We
685:      keep a status bit in the SSA_NAME node itself to indicate it has
686:      been put on the free list.
687:
688:      Note that once on the freelist you cannot reference the SSA_NAME's
689:      defining statement.  */
690:   if (! SSA_NAME_IN_FREE_LIST (var))
691:     {
692:       int saved_ssa_name_version = SSA_NAME_VERSION (var);
693:       use_operand_p imm = &(SSA_NAME_IMM_USE_NODE (var));
694:
695:       if (MAY_HAVE_DEBUG_BIND_STMTS)
696:         insert_debug_temp_for_var_def (NULL, var);
697:
698:       if (flag_checking)
699:         verify_imm_links (stderr, var);
700:       while (imm->next != imm)
701:         delink_imm_use (imm->next);
702:
703:       (*SSANAMES (fn))[SSA_NAME_VERSION (var)] = NULL_TREE;
704:       memset (var, 0, tree_size (var));
705:
706:       imm->prev = imm;
707:       imm->next = imm;
708:       imm->loc.ssa_name = var;
709:
710:       /* First put back the right tree node so that the tree checking
711:          macros do not complain.  */
712:       TREE_SET_CODE (var, SSA_NAME);
713:
714:       /* Restore the version number.  */
715:       SSA_NAME_VERSION (var) = saved_ssa_name_version;
716:
717:       /* Note this SSA_NAME is now in the first list.  */
718:       SSA_NAME_IN_FREE_LIST (var) = 1;
719:
720:       /* Put in a non-NULL TREE_TYPE so dumping code will not ICE
721:          if it happens to come along a released SSA name and tries
722:          to inspect its type.  */
723:       TREE_TYPE (var) = error_mark_node;
724:
725:       /* And finally queue it so that it will be put on the free list.  */
726:       vec_safe_push (FREE_SSANAMES_QUEUE (fn), var);
727:     }
728: }
729:
730: /* If the alignment of the pointer described by PI is known, return true and
731:    store the alignment and the deviation from it into *ALIGNP and *MISALIGNP
```

## gcc/tree-ssa-operands.cc:232–364

```text
232: create_vop_var (struct function *fn)
233: {
234:   tree global_var;
235:
236:   gcc_assert (fn->gimple_df->vop == NULL_TREE);
237:
238:   global_var = build_decl (BUILTINS_LOCATION, VAR_DECL,
239:                            get_identifier (".MEM"),
240:                            void_type_node);
241:   DECL_ARTIFICIAL (global_var) = 1;
242:   DECL_IGNORED_P (global_var) = 1;
243:   TREE_READONLY (global_var) = 0;
244:   DECL_EXTERNAL (global_var) = 1;
245:   TREE_STATIC (global_var) = 1;
246:   TREE_USED (global_var) = 1;
247:   DECL_CONTEXT (global_var) = NULL_TREE;
248:   TREE_THIS_VOLATILE (global_var) = 0;
249:   TREE_ADDRESSABLE (global_var) = 0;
250:   VAR_DECL_IS_VIRTUAL_OPERAND (global_var) = 1;
251:
252:   fn->gimple_df->vop = global_var;
253: }
254:
255: /* These are the sizes of the operand memory buffer in bytes which gets
256:    allocated each time more operands space is required.  The final value is
257:    the amount that is allocated every time after that.
258:    In 1k we can fit 25 use operands (or 63 def operands) on a host with
259:    8 byte pointers, that would be 10 statements each with 1 def and 2
260:    uses.  */
261:
262: #define OP_SIZE_INIT    0
263: #define OP_SIZE_1       (1024 - sizeof (void *))
264: #define OP_SIZE_2       (1024 * 4 - sizeof (void *))
265: #define OP_SIZE_3       (1024 * 16 - sizeof (void *))
266:
267: /* Initialize the operand cache routines.  */
268:
269: void
270: init_ssa_operands (struct function *fn)
271: {
272:   gcc_assert (gimple_ssa_operands (fn)->operand_memory == NULL);
273:   gimple_ssa_operands (fn)->operand_memory_index
274:      = gimple_ssa_operands (fn)->ssa_operand_mem_size;
275:   gimple_ssa_operands (fn)->ops_active = true;
276:   gimple_ssa_operands (fn)->ssa_operand_mem_size = OP_SIZE_INIT;
277:   create_vop_var (fn);
278: }
279:
280:
281: /* Dispose of anything required by the operand routines.  */
282:
283: void
284: fini_ssa_operands (struct function *fn)
285: {
286:   struct ssa_operand_memory_d *ptr;
287:
288:   gimple_ssa_operands (fn)->free_uses = NULL;
289:
290:   while ((ptr = gimple_ssa_operands (fn)->operand_memory) != NULL)
291:     {
292:       gimple_ssa_operands (fn)->operand_memory
293:         = gimple_ssa_operands (fn)->operand_memory->next;
294:       ggc_free (ptr);
295:     }
296:
297:   gimple_ssa_operands (fn)->ops_active = false;
298:
299:   fn->gimple_df->vop = NULL_TREE;
300: }
301:
302:
303: /* Return memory for an operand of size SIZE.  */
304:
305: static inline void *
306: ssa_operand_alloc (struct function *fn, unsigned size)
307: {
308:   char *ptr;
309:
310:   gcc_assert (size == sizeof (struct use_optype_d));
311:
312:   if (gimple_ssa_operands (fn)->operand_memory_index + size
313:       >= gimple_ssa_operands (fn)->ssa_operand_mem_size)
314:     {
315:       struct ssa_operand_memory_d *ptr;
316:
317:       switch (gimple_ssa_operands (fn)->ssa_operand_mem_size)
318:         {
319:         case OP_SIZE_INIT:
320:           gimple_ssa_operands (fn)->ssa_operand_mem_size = OP_SIZE_1;
321:           break;
322:         case OP_SIZE_1:
323:           gimple_ssa_operands (fn)->ssa_operand_mem_size = OP_SIZE_2;
324:           break;
325:         case OP_SIZE_2:
326:         case OP_SIZE_3:
327:           gimple_ssa_operands (fn)->ssa_operand_mem_size = OP_SIZE_3;
328:           break;
329:         default:
330:           gcc_unreachable ();
331:         }
332:
333:
334:       ptr = (ssa_operand_memory_d *) ggc_internal_alloc
335:         (sizeof (void *) + gimple_ssa_operands (fn)->ssa_operand_mem_size);
336:
337:       ptr->next = gimple_ssa_operands (fn)->operand_memory;
338:       gimple_ssa_operands (fn)->operand_memory = ptr;
339:       gimple_ssa_operands (fn)->operand_memory_index = 0;
340:     }
341:
342:   ptr = &(gimple_ssa_operands (fn)->operand_memory
343:           ->mem[gimple_ssa_operands (fn)->operand_memory_index]);
344:   gimple_ssa_operands (fn)->operand_memory_index += size;
345:   return ptr;
346: }
347:
348:
349: /* Allocate a USE operand.  */
350:
351: static inline struct use_optype_d *
352: alloc_use (struct function *fn)
353: {
354:   struct use_optype_d *ret;
355:   if (gimple_ssa_operands (fn)->free_uses)
356:     {
357:       ret = gimple_ssa_operands (fn)->free_uses;
358:       gimple_ssa_operands (fn)->free_uses
359:         = gimple_ssa_operands (fn)->free_uses->next;
360:     }
361:   else
362:     ret = (struct use_optype_d *)
363:           ssa_operand_alloc (fn, sizeof (struct use_optype_d));
364:   return ret;
```

## gcc/tree-ssa-operands.cc:425–485

```text
425:
426: inline void
427: operands_scanner::finalize_ssa_uses ()
428: {
429:   unsigned new_i;
430:   struct use_optype_d new_list;
431:   use_optype_p old_ops, ptr, last;
432:
433:   /* Pre-pend the VUSE we may have built.  */
434:   if (build_vuse != NULL_TREE)
435:     {
436:       tree oldvuse = gimple_vuse (stmt);
437:       if (oldvuse
438:           && TREE_CODE (oldvuse) == SSA_NAME)
439:         oldvuse = SSA_NAME_VAR (oldvuse);
440:       if (oldvuse != (build_vuse != NULL_TREE
441:                       ? build_vuse : build_vdef))
442:         gimple_set_vuse (stmt, NULL_TREE);
443:       build_uses.safe_insert (0, gimple_vuse_ptr (stmt));
444:     }
445:
446:   new_list.next = NULL;
447:   last = &new_list;
448:
449:   old_ops = gimple_use_ops (stmt);
450:
451:   /* Clear a no longer necessary VUSE.  */
452:   if (build_vuse == NULL_TREE
453:       && gimple_vuse (stmt) != NULL_TREE)
454:     gimple_set_vuse (stmt, NULL_TREE);
455:
456:   /* If there is anything in the old list, free it.  */
457:   if (old_ops)
458:     {
459:       for (ptr = old_ops; ptr->next; ptr = ptr->next)
460:         delink_imm_use (USE_OP_PTR (ptr));
461:       delink_imm_use (USE_OP_PTR (ptr));
462:       ptr->next = gimple_ssa_operands (fn)->free_uses;
463:       gimple_ssa_operands (fn)->free_uses = old_ops;
464:     }
465:
466:   /* If we added a VUSE, make sure to set the operand if it is not already
467:      present and mark it for renaming.  */
468:   if (build_vuse != NULL_TREE
469:       && gimple_vuse (stmt) == NULL_TREE)
470:     {
471:       gimple_set_vuse (stmt, gimple_vop (fn));
472:       fn->gimple_df->rename_vops = 1;
473:       fn->gimple_df->ssa_renaming_needed = 1;
474:     }
475:
476:   /* Now create nodes for all the new nodes.  */
477:   for (new_i = 0; new_i < build_uses.length (); new_i++)
478:     {
479:       tree *op = build_uses[new_i];
480:       last = add_use_op (fn, stmt, op, last);
481:     }
482:
483:   /* Now set the stmt's operands.  */
484:   gimple_set_use_ops (stmt, new_list.next);
485: }
```

## gcc/tree-ssa-operands.cc:764–999

```text
764: operands_scanner::get_expr_operands (tree *expr_p, int flags)
765: {
766:   enum tree_code code;
767:   enum tree_code_class codeclass;
768:   tree expr = *expr_p;
769:   int uflags = opf_use;
770:
771:   if (expr == NULL)
772:     return;
773:
774:   if (is_gimple_debug (stmt))
775:     uflags |= (flags & opf_no_vops);
776:
777:   code = TREE_CODE (expr);
778:   codeclass = TREE_CODE_CLASS (code);
779:
780:   switch (code)
781:     {
782:     case ADDR_EXPR:
783:       /* Taking the address of a variable does not represent a
784:          reference to it, but the fact that the statement takes its
785:          address will be of interest to some passes (e.g. alias
786:          resolution).  */
787:       if ((!(flags & opf_non_addressable)
788:            || (flags & opf_not_non_addressable))
789:           && !is_gimple_debug (stmt))
790:         mark_address_taken (TREE_OPERAND (expr, 0));
791:
792:       /* Otherwise, there may be variables referenced inside but there
793:          should be no VUSEs created, since the referenced objects are
794:          not really accessed.  The only operands that we should find
795:          here are ARRAY_REF indices which will always be real operands
796:          (GIMPLE does not allow non-registers as array indices).  */
797:       flags |= opf_no_vops;
798:       get_expr_operands (&TREE_OPERAND (expr, 0),
799:                          flags | opf_not_non_addressable | opf_address_taken);
800:       return;
801:
802:     case SSA_NAME:
803:     case VAR_DECL:
804:     case PARM_DECL:
805:     case RESULT_DECL:
806:     case STRING_CST:
807:     case CONST_DECL:
808:       if (!(flags & opf_address_taken))
809:         add_stmt_operand (expr_p, flags);
810:       return;
811:
812:     case OMP_NEXT_VARIANT:
813:     case OMP_TARGET_DEVICE_MATCHES:
814:       return;
815:
816:     case DEBUG_EXPR_DECL:
817:       gcc_assert (gimple_debug_bind_p (stmt));
818:       return;
819:
820:     case MEM_REF:
821:       get_mem_ref_operands (expr, flags);
822:       return;
823:
824:     case TARGET_MEM_REF:
825:       get_tmr_operands (expr, flags);
826:       return;
827:
828:     case ARRAY_REF:
829:     case ARRAY_RANGE_REF:
830:     case COMPONENT_REF:
831:     case REALPART_EXPR:
832:     case IMAGPART_EXPR:
833:       {
834:         if (!(flags & opf_no_vops)
835:             && TREE_THIS_VOLATILE (expr))
836:           gimple_set_has_volatile_ops (stmt, true);
837:
838:         get_expr_operands (&TREE_OPERAND (expr, 0), flags);
839:
840:         if (code == COMPONENT_REF)
841:           get_expr_operands (&TREE_OPERAND (expr, 2), uflags);
842:         else if (code == ARRAY_REF || code == ARRAY_RANGE_REF)
843:           {
844:             get_expr_operands (&TREE_OPERAND (expr, 1), uflags);
845:             get_expr_operands (&TREE_OPERAND (expr, 2), uflags);
846:             get_expr_operands (&TREE_OPERAND (expr, 3), uflags);
847:           }
848:
849:         return;
850:       }
851:
852:     case WITH_SIZE_EXPR:
853:       /* WITH_SIZE_EXPR is a pass-through reference to its first argument,
854:          and an rvalue reference to its second argument.  */
855:       get_expr_operands (&TREE_OPERAND (expr, 1), uflags);
856:       get_expr_operands (&TREE_OPERAND (expr, 0), flags);
857:       return;
858:
859:     case COND_EXPR:
860:     case VEC_COND_EXPR:
861:     case VEC_PERM_EXPR:
862:       get_expr_operands (&TREE_OPERAND (expr, 0), uflags);
863:       get_expr_operands (&TREE_OPERAND (expr, 1), uflags);
864:       get_expr_operands (&TREE_OPERAND (expr, 2), uflags);
865:       return;
866:
867:     case CONSTRUCTOR:
868:       {
869:         /* General aggregate CONSTRUCTORs have been decomposed, but they
870:            are still in use as the COMPLEX_EXPR equivalent for vectors.  */
871:         constructor_elt *ce;
872:         unsigned HOST_WIDE_INT idx;
873:
874:         /* A volatile constructor is actually TREE_CLOBBER_P, transfer
875:            the volatility to the statement, don't use TREE_CLOBBER_P for
876:            mirroring the other uses of THIS_VOLATILE in this file.  */
877:         if (!(flags & opf_no_vops)
878:             && TREE_THIS_VOLATILE (expr))
879:           gimple_set_has_volatile_ops (stmt, true);
880:
881:         for (idx = 0;
882:              vec_safe_iterate (CONSTRUCTOR_ELTS (expr), idx, &ce);
883:              idx++)
884:           get_expr_operands (&ce->value, uflags);
885:
886:         return;
887:       }
888:
889:     case BIT_FIELD_REF:
890:       if (!(flags & opf_no_vops)
891:           && TREE_THIS_VOLATILE (expr))
892:         gimple_set_has_volatile_ops (stmt, true);
893:       /* FALLTHRU */
894:
895:     case VIEW_CONVERT_EXPR:
896:     do_unary:
897:       get_expr_operands (&TREE_OPERAND (expr, 0), flags);
898:       return;
899:
900:     case BIT_INSERT_EXPR:
901:     case COMPOUND_EXPR:
902:     case OBJ_TYPE_REF:
903:     do_binary:
904:       {
905:         get_expr_operands (&TREE_OPERAND (expr, 0), flags);
906:         get_expr_operands (&TREE_OPERAND (expr, 1), flags);
907:         return;
908:       }
909:
910:     case DOT_PROD_EXPR:
911:     case SAD_EXPR:
912:     case REALIGN_LOAD_EXPR:
913:     case WIDEN_MULT_PLUS_EXPR:
914:     case WIDEN_MULT_MINUS_EXPR:
915:       {
916:         get_expr_operands (&TREE_OPERAND (expr, 0), flags);
917:         get_expr_operands (&TREE_OPERAND (expr, 1), flags);
918:         get_expr_operands (&TREE_OPERAND (expr, 2), flags);
919:         return;
920:       }
921:
922:     case FUNCTION_DECL:
923:     case LABEL_DECL:
924:     case CASE_LABEL_EXPR:
925:       /* Expressions that make no memory references.  */
926:       return;
927:
928:     default:
929:       if (codeclass == tcc_unary)
930:         goto do_unary;
931:       if (codeclass == tcc_binary || codeclass == tcc_comparison)
932:         goto do_binary;
933:       if (codeclass == tcc_constant || codeclass == tcc_type)
934:         return;
935:     }
936:
937:   /* If we get here, something has gone wrong.  */
938:   if (flag_checking)
939:     {
940:       fprintf (stderr, "unhandled expression in get_expr_operands():\n");
941:       debug_tree (expr);
942:       fputs ("\n", stderr);
943:       gcc_unreachable ();
944:     }
945: }
946:
947:
948: /* Parse STMT looking for operands.  When finished, the various
949:    build_* operand vectors will have potential operands in them.  */
950:
951: void
952: operands_scanner::parse_ssa_operands ()
953: {
954:   enum gimple_code code = gimple_code (stmt);
955:   size_t i, n, start = 0;
956:
957:   switch (code)
958:     {
959:     case GIMPLE_ASM:
960:       get_asm_stmt_operands (as_a <gasm *> (stmt));
961:       break;
962:
963:     case GIMPLE_TRANSACTION:
964:       /* The start of a transaction is a memory barrier.  */
965:       add_virtual_operand (opf_def | opf_use);
966:       break;
967:
968:     case GIMPLE_DEBUG:
969:       if (gimple_debug_bind_p (stmt)
970:           && gimple_debug_bind_has_value_p (stmt))
971:         get_expr_operands (gimple_debug_bind_get_value_ptr (stmt),
972:                            opf_use | opf_no_vops);
973:       break;
974:
975:     case GIMPLE_RETURN:
976:       append_vuse (gimple_vop (fn));
977:       goto do_default;
978:
979:     case GIMPLE_CALL:
980:       /* Add call-clobbered operands, if needed.  */
981:       maybe_add_call_vops (as_a <gcall *> (stmt));
982:       /* FALLTHRU */
983:
984:     case GIMPLE_ASSIGN:
985:       get_expr_operands (gimple_op_ptr (stmt, 0), opf_def);
986:       start = 1;
987:       /* FALLTHRU */
988:
989:     default:
990:     do_default:
991:       n = gimple_num_ops (stmt);
992:       for (i = start; i < n; i++)
993:         get_expr_operands (gimple_op_ptr (stmt, i), opf_use);
994:       break;
995:     }
996: }
997:
998:
999: /* Create an operands cache for STMT.  */
```

## gcc/tree-ssa-operands.cc:1140–1154

```text
1140: update_stmt_operands (struct function *fn, gimple *stmt)
1141: {
1142:   /* If update_stmt_operands is called before SSA is initialized, do
1143:      nothing.  */
1144:   if (!ssa_operands_active (fn))
1145:     return;
1146:
1147:   timevar_push (TV_TREE_OPS);
1148:
1149:   gcc_assert (gimple_modified_p (stmt));
1150:   operands_scanner (fn, stmt).build_ssa_operands ();
1151:   gimple_set_modified (stmt, false);
1152:
1153:   timevar_pop (TV_TREE_OPS);
1154: }
```

## gcc/tree-ssa-operands.h:37–64

```text
37: struct use_optype_d
38: {
39:   struct use_optype_d *next;
40:   struct ssa_use_operand_t use_ptr;
41: };
42: typedef struct use_optype_d *use_optype_p;
43:
44: /* This structure represents a variable sized buffer which is allocated by the
45:    operand memory manager.  Operands are suballocated out of this block.  The
46:    MEM array varies in size.  */
47:
48: struct GTY((chain_next("%h.next"))) ssa_operand_memory_d {
49:   struct ssa_operand_memory_d *next;
50:   char mem[1];
51: };
52:
53: /* Per-function operand caches.  */
54: struct GTY(()) ssa_operands {
55:    struct ssa_operand_memory_d *operand_memory;
56:    unsigned operand_memory_index;
57:    /* Current size of the operand memory buffer.  */
58:    unsigned int ssa_operand_mem_size;
59:
60:    bool ops_active;
61:
62:    struct use_optype_d * GTY ((skip (""))) free_uses;
63: };
64:
```

## gcc/tree-dfa.cc:293–366

```text
293: /* Lookup VAR UID in the default_defs hashtable and return the associated
294:    variable.  */
295:
296: tree
297: ssa_default_def (struct function *fn, tree var)
298: {
299:   struct tree_decl_minimal ind;
300:   struct tree_ssa_name in;
301:   gcc_assert (VAR_P (var)
302:               || TREE_CODE (var) == PARM_DECL
303:               || TREE_CODE (var) == RESULT_DECL);
304:
305:   /* Always NULL_TREE for rtl function dumps.  */
306:   if (!fn->gimple_df)
307:     return NULL_TREE;
308:
309:   in.var = (tree)&ind;
310:   ind.uid = DECL_UID (var);
311:   return DEFAULT_DEFS (fn)->find_with_hash ((tree)&in, DECL_UID (var));
312: }
313:
314: /* Insert the pair VAR's UID, DEF into the default_defs hashtable
315:    of function FN.  */
316:
317: void
318: set_ssa_default_def (struct function *fn, tree var, tree def)
319: {
320:   struct tree_decl_minimal ind;
321:   struct tree_ssa_name in;
322:
323:   gcc_assert (VAR_P (var)
324:               || TREE_CODE (var) == PARM_DECL
325:               || TREE_CODE (var) == RESULT_DECL);
326:   in.var = (tree)&ind;
327:   ind.uid = DECL_UID (var);
328:   if (!def)
329:     {
330:       tree *loc = DEFAULT_DEFS (fn)->find_slot_with_hash ((tree)&in,
331:                                                           DECL_UID (var),
332:                                                           NO_INSERT);
333:       if (loc)
334:         {
335:           SSA_NAME_IS_DEFAULT_DEF (*(tree *)loc) = false;
336:           DEFAULT_DEFS (fn)->clear_slot (loc);
337:         }
338:       return;
339:     }
340:   gcc_assert (TREE_CODE (def) == SSA_NAME && SSA_NAME_VAR (def) == var);
341:   tree *loc = DEFAULT_DEFS (fn)->find_slot_with_hash ((tree)&in,
342:                                                       DECL_UID (var), INSERT);
343:
344:   /* Default definition might be changed by tail call optimization.  */
345:   if (*loc)
346:     SSA_NAME_IS_DEFAULT_DEF (*loc) = false;
347:
348:    /* Mark DEF as the default definition for VAR.  */
349:   *loc = def;
350:   SSA_NAME_IS_DEFAULT_DEF (def) = true;
351: }
352:
353: /* Retrieve or create a default definition for VAR.  */
354:
355: tree
356: get_or_create_ssa_default_def (struct function *fn, tree var)
357: {
358:   tree ddef = ssa_default_def (fn, var);
359:   if (ddef == NULL_TREE)
360:     {
361:       ddef = make_ssa_name_fn (fn, var, gimple_build_nop ());
362:       set_ssa_default_def (fn, var, ddef);
363:     }
364:   return ddef;
365: }
366:
```

## gcc/tree-ssa-dce.cc:2152–2257

```text
2152: simple_dce_from_worklist (bitmap worklist, bitmap need_eh_cleanup)
2153: {
2154:   int phiremoved = 0;
2155:   int stmtremoved = 0;
2156:   while (! bitmap_empty_p (worklist))
2157:     {
2158:       /* Pop item.  */
2159:       unsigned i = bitmap_clear_first_set_bit (worklist);
2160:
2161:       tree def = ssa_name (i);
2162:       /* Removed by somebody else or still in use.
2163:          Note use in itself for a phi node is not counted as still in use.  */
2164:       if (!def)
2165:         continue;
2166:       if (!has_zero_uses (def))
2167:         {
2168:           gimple *def_stmt = SSA_NAME_DEF_STMT (def);
2169:
2170:           if (gimple_code (def_stmt) != GIMPLE_PHI)
2171:             continue;
2172:
2173:           imm_use_iterator use_iter;
2174:           use_operand_p use_p;
2175:           bool canremove = true;
2176:
2177:           FOR_EACH_IMM_USE_FAST (use_p, use_iter, def)
2178:             {
2179:               gimple *use_stmt = USE_STMT (use_p);
2180:               /* Ignore debug statements. */
2181:               if (is_gimple_debug (use_stmt))
2182:                 continue;
2183:               if (use_stmt != def_stmt)
2184:                 {
2185:                   canremove = false;
2186:                   break;
2187:                 }
2188:             }
2189:           if (!canremove)
2190:             continue;
2191:         }
2192:
2193:       gimple *t = SSA_NAME_DEF_STMT (def);
2194:       if (gimple_has_side_effects (t))
2195:         {
2196:           if (gcall *call = dyn_cast <gcall *> (t))
2197:             {
2198:               gimple_call_set_lhs (call, NULL_TREE);
2199:               update_stmt (call);
2200:               release_ssa_name (def);
2201:             }
2202:           continue;
2203:         }
2204:
2205:       /* The defining statement needs to be defining only this name.
2206:          ASM is the only statement that can define more than one
2207:          name. */
2208:       if (is_a<gasm *>(t)
2209:           && !single_ssa_def_operand (t, SSA_OP_ALL_DEFS))
2210:         continue;
2211:
2212:       /* Don't remove statements that are needed for non-call
2213:          eh to work.  */
2214:       if (stmt_unremovable_because_of_non_call_eh_p (cfun, t))
2215:         continue;
2216:
2217:       /* Tell the caller that we removed a statement that might
2218:          throw so it could cleanup the cfg for that block. */
2219:       if (need_eh_cleanup && stmt_could_throw_p (cfun, t))
2220:         bitmap_set_bit (need_eh_cleanup, gimple_bb (t)->index);
2221:
2222:       /* Add uses to the worklist.  */
2223:       ssa_op_iter iter;
2224:       use_operand_p use_p;
2225:       FOR_EACH_PHI_OR_STMT_USE (use_p, t, iter, SSA_OP_USE)
2226:         {
2227:           tree use = USE_FROM_PTR (use_p);
2228:           if (TREE_CODE (use) == SSA_NAME
2229:               && ! SSA_NAME_IS_DEFAULT_DEF (use))
2230:             bitmap_set_bit (worklist, SSA_NAME_VERSION (use));
2231:         }
2232:
2233:       /* Remove stmt.  */
2234:       if (dump_file && (dump_flags & TDF_DETAILS))
2235:         {
2236:           fprintf (dump_file, "Removing dead stmt:");
2237:           print_gimple_stmt (dump_file, t, 0);
2238:         }
2239:       gimple_stmt_iterator gsi = gsi_for_stmt (t);
2240:       if (gimple_code (t) == GIMPLE_PHI)
2241:         {
2242:           remove_phi_node (&gsi, true);
2243:           phiremoved++;
2244:         }
2245:       else
2246:         {
2247:           unlink_stmt_vdef (t);
2248:           gsi_remove (&gsi, true);
2249:           release_defs (t);
2250:           stmtremoved++;
2251:         }
2252:     }
2253:   statistics_counter_event (cfun, "PHIs removed",
2254:                             phiremoved);
2255:   statistics_counter_event (cfun, "Statements removed",
2256:                             stmtremoved);
2257: }
```

## gcc/domwalk.cc:273–364

```text
273: dom_walker::walk (basic_block bb)
274: {
275:   /* Compute the basic-block index to RPO mapping lazily.  */
276:   if (!m_user_bb_to_rpo
277:       && !m_bb_to_rpo
278:       && m_dom_direction == CDI_DOMINATORS)
279:     {
280:       int *postorder = XNEWVEC (int, n_basic_blocks_for_fn (cfun));
281:       int postorder_num = pre_and_rev_post_order_compute (NULL, postorder,
282:                                                           true);
283:       m_bb_to_rpo = XNEWVEC (int, last_basic_block_for_fn (cfun));
284:       for (int i = 0; i < postorder_num; ++i)
285:         m_bb_to_rpo[postorder[i]] = i;
286:       free (postorder);
287:     }
288:
289:   /* Set up edge flags if need be.  */
290:   if (m_reachability == REACHABLE_BLOCKS)
291:     set_all_edges_as_executable (cfun);
292:
293:   basic_block dest;
294:   basic_block *worklist = XNEWVEC (basic_block,
295:                                    n_basic_blocks_for_fn (cfun) * 2);
296:   int sp = 0;
297:
298:   while (true)
299:     {
300:       /* Don't worry about unreachable blocks.  */
301:       if (EDGE_COUNT (bb->preds) > 0
302:           || bb == ENTRY_BLOCK_PTR_FOR_FN (cfun)
303:           || bb == EXIT_BLOCK_PTR_FOR_FN (cfun))
304:         {
305:           edge taken_edge = NULL;
306:
307:           /* Callback for subclasses to do custom things before we have walked
308:              the dominator children, but before we walk statements.  */
309:           if (this->bb_reachable (cfun, bb))
310:             {
311:               taken_edge = before_dom_children (bb);
312:               if (taken_edge && taken_edge != STOP)
313:                 {
314:                   edge_iterator ei;
315:                   edge e;
316:                   FOR_EACH_EDGE (e, ei, bb->succs)
317:                     if (e != taken_edge)
318:                       e->flags &= ~EDGE_EXECUTABLE;
319:                 }
320:             }
321:           else
322:             propagate_unreachable_to_edges (bb, dump_file, dump_flags);
323:
324:           /* Mark the current BB to be popped out of the recursion stack
325:              once children are processed.  */
326:           worklist[sp++] = bb;
327:           worklist[sp++] = NULL;
328:
329:           /* If the callback returned NONE then we are supposed to
330:              stop and not even propagate EDGE_EXECUTABLE further.  */
331:           if (taken_edge != STOP)
332:             {
333:               int saved_sp = sp;
334:               for (dest = first_dom_son (m_dom_direction, bb);
335:                    dest; dest = next_dom_son (m_dom_direction, dest))
336:                 worklist[sp++] = dest;
337:               /* Sort worklist after RPO order if requested.  */
338:               if (sp - saved_sp > 1
339:                   && m_dom_direction == CDI_DOMINATORS
340:                   && m_bb_to_rpo)
341:                 sort_bbs_postorder (&worklist[saved_sp], sp - saved_sp,
342:                                     m_bb_to_rpo);
343:             }
344:         }
345:       /* NULL is used to mark pop operations in the recursion stack.  */
346:       while (sp > 0 && !worklist[sp - 1])
347:         {
348:           --sp;
349:           bb = worklist[--sp];
350:
351:           /* Callback allowing subclasses to do custom things after we have
352:              walked dominator children, but before we walk statements.  */
353:           if (bb_reachable (cfun, bb))
354:             after_dom_children (bb);
355:           else if (m_unreachable_dom == bb)
356:             m_unreachable_dom = NULL;
357:         }
358:       if (sp)
359:         bb = worklist[--sp];
360:       else
361:         break;
362:     }
363:   free (worklist);
364: }
```

## gcc/gimple.h:220–288

```text
220: struct GTY((desc ("gimple_statement_structure (&%h)"), tag ("GSS_BASE"),
221:             chain_next ("%h.next"), variable_size))
222:   gimple
223: {
224:   /* [ WORD 1 ]
225:      Main identifying code for a tuple.  */
226:   ENUM_BITFIELD(gimple_code) code : 8;
227:
228:   /* Nonzero if a warning should not be emitted on this tuple.  */
229:   unsigned int no_warning       : 1;
230:
231:   /* Nonzero if this tuple has been visited.  Passes are responsible
232:      for clearing this bit before using it.  */
233:   unsigned int visited          : 1;
234:
235:   /* Nonzero if this tuple represents a non-temporal move; currently
236:      only stores are supported.  */
237:   unsigned int nontemporal_move : 1;
238:
239:   /* Pass local flags.  These flags are free for any pass to use as
240:      they see fit.  Passes should not assume that these flags contain
241:      any useful value when the pass starts.  Any initial state that
242:      the pass requires should be set on entry to the pass.  See
243:      gimple_set_plf and gimple_plf for usage.  */
244:   unsigned int plf              : 2;
245:
246:   /* Nonzero if this statement has been modified and needs to have its
247:      operands rescanned.  */
248:   unsigned modified             : 1;
249:
250:   /* Nonzero if this statement contains volatile operands.  */
251:   unsigned has_volatile_ops     : 1;
252:
253:   /* Infrastructure local flag.  Always clear.  */
254:   unsigned ilf                  : 1;
255:
256:   /* The SUBCODE field can be used for tuple-specific flags for tuples
257:      that do not require subcodes.  Note that SUBCODE should be at
258:      least as wide as tree codes, as several tuples store tree codes
259:      in there.  */
260:   unsigned int subcode          : 16;
261:
262:   /* UID of this statement.  This is used by passes that want to assign IDs
263:      to statements.  It must be assigned and used by each pass.  By default
264:      it should be assumed to contain garbage.  */
265:   unsigned uid;
266:
267:   /* [ WORD 2 ]
268:      Number of operands in this tuple.  */
269:   unsigned num_ops;
270:
271:   /* Unused 32 bits padding on 64-bit hosts.  */
272:
273:   /* [ WORD 3 ]
274:      Locus information for debug info.  */
275:   location_t location;
276:
277:   /* [ WORD 4 ]
278:      Basic block holding this statement.  */
279:   basic_block bb;
280:
281:   /* [ WORD 5-6 ]
282:      Linked lists of gimple statements.  The next pointers form
283:      a NULL terminated list, the prev pointers are a cyclic list.
284:      A gimple statement is hence also a double-ended list of
285:      statements, with the pointer itself being the first element,
286:      and the prev pointer being the last.  */
287:   gimple *next;
288:   gimple *GTY((skip)) prev;
```

## gcc/gimple.h:472–486

```text
472:
473: struct GTY((tag("GSS_PHI")))
474:   gphi : public gimple
475: {
476:   /* [ WORD 1-6 ] : base class */
477:
478:   /* [ WORD 7 ]  */
479:   unsigned capacity;
480:   unsigned nargs;
481:
482:   /* [ WORD 8 ]  */
483:   tree result;
484:
485:   /* [ WORD 9-14 ]  */
486:   struct phi_arg_d GTY ((length ("%h.nargs"))) args[1];
```

## gcc/tree-core.h:1138–1253

```text
1138: struct GTY(()) tree_base {
1139:   ENUM_BITFIELD(tree_code) code : 16;
1140:
1141:   unsigned side_effects_flag : 1;
1142:   unsigned constant_flag : 1;
1143:   unsigned addressable_flag : 1;
1144:   unsigned volatile_flag : 1;
1145:   unsigned readonly_flag : 1;
1146:   unsigned asm_written_flag: 1;
1147:   unsigned nowarning_flag : 1;
1148:   unsigned visited : 1;
1149:
1150:   unsigned used_flag : 1;
1151:   unsigned nothrow_flag : 1;
1152:   unsigned static_flag : 1;
1153:   unsigned public_flag : 1;
1154:   unsigned private_flag : 1;
1155:   unsigned protected_flag : 1;
1156:   unsigned deprecated_flag : 1;
1157:   unsigned default_def_flag : 1;
1158:
1159:   union {
1160:     /* The bits in the following structure should only be used with
1161:        accessor macros that constrain inputs with tree checking.  */
1162:     struct {
1163:       unsigned lang_flag_0 : 1;
1164:       unsigned lang_flag_1 : 1;
1165:       unsigned lang_flag_2 : 1;
1166:       unsigned lang_flag_3 : 1;
1167:       unsigned lang_flag_4 : 1;
1168:       unsigned lang_flag_5 : 1;
1169:       unsigned lang_flag_6 : 1;
1170:       unsigned saturating_flag : 1;
1171:
1172:       unsigned unsigned_flag : 1;
1173:       unsigned packed_flag : 1;
1174:       unsigned user_align : 1;
1175:       unsigned nameless_flag : 1;
1176:       unsigned atomic_flag : 1;
1177:       unsigned unavailable_flag : 1;
1178:       unsigned spare0 : 2;
1179:
1180:       unsigned spare1 : 8;
1181:
1182:       /* For _TYPE nodes, this is TYPE_ADDR_SPACE; the reason it is
1183:          present in tree_base instead of tree_type is to save space.  The size
1184:          of the field must be large enough to hold addr_space_t values.
1185:          For CONSTRUCTOR nodes this holds the clobber_kind enum.
1186:          The C++ front-end uses this in IDENTIFIER_NODE, REFLECT_EXPR, and
1187:          NAMESPACE_DECL.  */
1188:       unsigned address_space : 8;
1189:     } bits;
1190:
1191:     /* The following fields are present in tree_base to save space.  The
1192:        nodes using them do not require any of the flags above and so can
1193:        make better use of the 4-byte sized word.  */
1194:
1195:     /* The number of HOST_WIDE_INTs in an INTEGER_CST.  */
1196:     struct {
1197:       /* The number of HOST_WIDE_INTs if the INTEGER_CST is accessed in
1198:          its native precision.  */
1199:       unsigned short unextended;
1200:
1201:       /* The number of HOST_WIDE_INTs if the INTEGER_CST is extended to
1202:          wider precisions based on its TYPE_SIGN.  */
1203:       unsigned short extended;
1204:     } int_length;
1205:
1206:     /* VEC length.  This field is only used with TREE_VEC.  */
1207:     int length;
1208:
1209:     /* This field is only used with VECTOR_CST.  */
1210:     struct {
1211:       /* The value of VECTOR_CST_LOG2_NPATTERNS.  */
1212:       unsigned int log2_npatterns : 8;
1213:
1214:       /* The value of VECTOR_CST_NELTS_PER_PATTERN.  */
1215:       unsigned int nelts_per_pattern : 8;
1216:
1217:       /* For future expansion.  */
1218:       unsigned int unused : 16;
1219:     } vector_cst;
1220:
1221:     /* SSA version number.  This field is only used with SSA_NAME.  */
1222:     unsigned int version;
1223:
1224:     /* CHREC_VARIABLE.  This field is only used with POLYNOMIAL_CHREC.  */
1225:     unsigned int chrec_var;
1226:
1227:     /* Internal function code.  */
1228:     enum internal_fn ifn;
1229:
1230:     /* OMP_ATOMIC* memory order.  */
1231:     enum omp_memory_order omp_atomic_memory_order;
1232:
1233:     /* The following two fields are used for MEM_REF and TARGET_MEM_REF
1234:        expression trees and specify known data non-dependences.  For
1235:        two memory references in a function they are known to not
1236:        alias if dependence_info.clique are equal and dependence_info.base
1237:        are distinct.  Clique number zero means there is no information,
1238:        clique number one is populated from function global information
1239:        and thus needs no remapping on transforms like loop unrolling.  */
1240:     struct {
1241:       unsigned short clique;
1242:       unsigned short base;
1243:     } dependence_info;
1244:   } GTY((skip(""))) u;
1245: };
1246:
1247: /* The following table lists the uses of each of the above flags and
1248:    for which types of nodes they are defined.
1249:
1250:    addressable_flag:
1251:
1252:        TREE_ADDRESSABLE in
1253:            VAR_DECL, PARM_DECL, RESULT_DECL, FUNCTION_DECL, LABEL_DECL
```

## gcc/tree-core.h:1565–1574

```text
1565: struct GTY(()) tree_typed {
1566:   struct tree_base base;
1567:   tree type;
1568: };
1569:
1570: struct GTY(()) tree_common {
1571:   struct tree_typed typed;
1572:   tree chain;
1573: };
1574:
```

## gcc/tree-core.h:1704–1747

```text
1704: struct GTY(()) ssa_use_operand_t {
1705:   struct ssa_use_operand_t* GTY((skip(""))) prev;
1706:   struct ssa_use_operand_t* GTY((skip(""))) next;
1707:   /* Immediate uses for a given SSA name are maintained as a cyclic
1708:      list.  To recognize the root of this list, the location field
1709:      needs to point to the original SSA name.  Since statements and
1710:      SSA names are of different data types, we need this union.  See
1711:      the explanation in struct imm_use_iterator.  */
1712:   union { gimple *stmt; tree ssa_name; } GTY((skip(""))) loc;
1713:   tree *GTY((skip(""))) use;
1714: };
1715:
1716: struct GTY(()) tree_ssa_name {
1717:   struct tree_typed typed;
1718:
1719:   /* _DECL wrapped by this SSA name.  */
1720:   tree var;
1721:
1722:   /* Statement that defines this SSA name.  */
1723:   gimple *def_stmt;
1724:
1725:   /* Value range information.  */
1726:   union ssa_name_info_type {
1727:     /* Range and aliasing info for pointers.  */
1728:     struct GTY ((tag ("0"))) ptr_info_def *ptr_info;
1729:     /* Range info for everything else.  */
1730:     struct GTY ((tag ("1"))) vrange_storage * range_info;
1731:   } GTY ((desc ("%1.typed.type ?" \
1732:                 "!POINTER_TYPE_P (TREE_TYPE ((tree)&%1)) : 2"))) info;
1733:   /* Immediate uses list for this SSA_NAME.  */
1734:   struct ssa_use_operand_t imm_uses;
1735: #if defined ENABLE_GIMPLE_CHECKING
1736:   gimple *GTY((skip(""))) active_iterated_stmt;
1737:   unsigned fast_iteration_depth;
1738: #endif
1739: };
1740:
1741: struct GTY(()) phi_arg_d {
1742:   /* imm_use MUST be the first element in struct because we do some
1743:      pointer arithmetic with it.  See phi_arg_index_from_use.  */
1744:   struct ssa_use_operand_t imm_use;
1745:   tree def;
1746:   location_t locus;
1747: };
```

## gcc/passes.def:57–70

```text
57:   PUSH_INSERT_PASSES_WITHIN (pass_build_ssa_passes)
58:       NEXT_PASS (pass_fixup_cfg);
59:       NEXT_PASS (pass_build_ssa);
60:       NEXT_PASS (pass_walloca, /*strict_mode_p=*/true);
61:       NEXT_PASS (pass_warn_printf);
62:       NEXT_PASS (pass_warn_nonnull_compare);
63:       NEXT_PASS (pass_early_warn_uninitialized);
64:       NEXT_PASS (pass_warn_access, /*early=*/true, /*check_dangling=*/true);
65:       NEXT_PASS (pass_ubsan);
66:       NEXT_PASS (pass_nothrow);
67:       NEXT_PASS (pass_rebuild_cgraph_edges);
68:   POP_INSERT_PASSES ()
69:   NEXT_PASS (pass_target_clone, true);
70:
```

## gcc/passes.cc:405–424

```text
405:
406: class pass_build_ssa_passes : public simple_ipa_opt_pass
407: {
408: public:
409:   pass_build_ssa_passes (gcc::context *ctxt)
410:     : simple_ipa_opt_pass (pass_data_build_ssa_passes, ctxt)
411:   {}
412:
413:   /* opt_pass methods: */
414:   bool gate (function *) final override
415:     {
416:       /* Don't bother doing anything if the program has errors.  */
417:       return (!seen_error () && !in_lto_p);
418:     }
419:
420:   unsigned int execute (function *) final override
421:     {
422:       return execute_build_ssa_passes ();
423:     }
424:
```

## gcc/passes.cc:2056–2110

```text
2056: /* Perform all TODO actions that ought to be done on each function.  */
2057:
2058: static void
2059: execute_function_todo (function *fn, void *data)
2060: {
2061:   bool from_ipa_pass = (cfun == NULL);
2062:   unsigned int flags = (size_t)data;
2063:   if (!flags)
2064:     return;
2065:
2066:   push_cfun (fn);
2067:
2068:   /* If we need to cleanup the CFG let it perform a needed SSA update.  */
2069:   if (flags & TODO_cleanup_cfg)
2070:     cleanup_tree_cfg (flags & TODO_update_ssa_any);
2071:   else if (flags & TODO_update_ssa_any)
2072:     update_ssa (flags & TODO_update_ssa_any);
2073:   gcc_assert (!need_ssa_update_p (fn));
2074:
2075:   if (flag_tree_pta && (flags & TODO_rebuild_alias))
2076:     compute_may_aliases ();
2077:
2078:   if (optimize && (flags & TODO_update_address_taken))
2079:     execute_update_addresses_taken ();
2080:
2081:   if (flags & TODO_remove_unused_locals)
2082:     remove_unused_locals ();
2083:
2084:   if (flags & TODO_rebuild_cgraph_edges)
2085:     cgraph_edge::rebuild_edges ();
2086:
2087:   gcc_assert (dom_info_state (fn, CDI_POST_DOMINATORS) == DOM_NONE);
2088:   /* If we've seen errors do not bother running any verifiers.  */
2089:   if (flag_checking && !seen_error ())
2090:     {
2091:       dom_state pre_verify_state = dom_info_state (fn, CDI_DOMINATORS);
2092:       dom_state pre_verify_pstate = dom_info_state (fn, CDI_POST_DOMINATORS);
2093:
2094:       if (flags & TODO_verify_il)
2095:         {
2096:           if (cfun->curr_properties & PROP_gimple)
2097:             {
2098:               if (cfun->curr_properties & PROP_cfg)
2099:                 /* IPA passes leave stmts to be fixed up, so make sure to
2100:                    not verify stmts really throw.  */
2101:                 verify_gimple_in_cfg (cfun, !from_ipa_pass);
2102:               else
2103:                 verify_gimple_in_seq (gimple_body (cfun->decl));
2104:             }
2105:           if (cfun->curr_properties & PROP_ssa)
2106:             /* IPA passes leave stmts to be fixed up, so make sure to
2107:                not verify SSA operands whose verifier will choke on that.  */
2108:             verify_ssa (true, !from_ipa_pass);
2109:           /* IPA passes leave basic-blocks unsplit, so make sure to
2110:              not trip on that.  */
```

## gcc/tree-ssa-live.cc:783–795

```text
783: remove_unused_locals (void)
784: {
785:   basic_block bb;
786:   tree var;
787:   unsigned srcidx, dstidx, num;
788:   bool have_local_clobbers = false;
789:
790:   /* Removing declarations from lexical blocks when not optimizing is
791:      not only a waste of time, it actually causes differences in stack
792:      layout.  */
793:   if (!optimize)
794:     return;
795:
```

## gcc/opts.cc:1472–1511

```text
1472:               || opts->x_flag_selective_scheduling2));
1473:
1474:   /* We know which debug output will be used so we can set flag_var_tracking
1475:      and flag_var_tracking_uninit if the user has not specified them.  */
1476:   if (opts->x_debug_info_level < DINFO_LEVEL_NORMAL
1477:       || (!dwarf_debuginfo_p (opts) && !codeview_debuginfo_p ())
1478:       /* We have not yet initialized debug hooks so match that to check
1479:          whether we're only doing DWARF2_LINENO_DEBUGGING_INFO.  */
1480: #ifndef DWARF2_DEBUGGING_INFO
1481:       || true
1482: #endif
1483:      )
1484:     {
1485:       if ((opts_set->x_flag_var_tracking && opts->x_flag_var_tracking == 1)
1486:           || (opts_set->x_flag_var_tracking_uninit
1487:               && opts->x_flag_var_tracking_uninit == 1))
1488:         {
1489:           if (opts->x_debug_info_level < DINFO_LEVEL_NORMAL)
1490:             warning_at (UNKNOWN_LOCATION, 0,
1491:                         "variable tracking requested, but useless unless "
1492:                         "producing debug info");
1493:           else
1494:             warning_at (UNKNOWN_LOCATION, 0,
1495:                         "variable tracking requested, but not supported "
1496:                         "by this debug format");
1497:         }
1498:       opts->x_flag_var_tracking = 0;
1499:       opts->x_flag_var_tracking_uninit = 0;
1500:       opts->x_flag_var_tracking_assignments = 0;
1501:     }
1502:
1503:   /* One could use EnabledBy, but it would lead to a circular dependency.  */
1504:   if (!opts_set->x_flag_var_tracking_uninit)
1505:     opts->x_flag_var_tracking_uninit = opts->x_flag_var_tracking;
1506:
1507:   if (!opts_set->x_flag_var_tracking_assignments)
1508:     opts->x_flag_var_tracking_assignments
1509:       = (opts->x_flag_var_tracking
1510:          && !(opts->x_flag_selective_scheduling
1511:               || opts->x_flag_selective_scheduling2));
```

## gcc/tree.h:1333–1345

```text
1333:
1334: /* Nonzero if gimple_debug_nonbind_marker_p() may possibly hold.  */
1335: #define MAY_HAVE_DEBUG_MARKER_STMTS debug_nonbind_markers_p
1336: /* Nonzero if gimple_debug_bind_p() (and thus
1337:    gimple_debug_source_bind_p()) may possibly hold.  */
1338: #define MAY_HAVE_DEBUG_BIND_STMTS flag_var_tracking_assignments
1339: /* Nonzero if is_gimple_debug() may possibly hold.  */
1340: #define MAY_HAVE_DEBUG_STMTS                                    \
1341:   (MAY_HAVE_DEBUG_MARKER_STMTS || MAY_HAVE_DEBUG_BIND_STMTS)
1342:
1343: /* In a LOOP_EXPR node.  */
1344: #define LOOP_EXPR_BODY(NODE) TREE_OPERAND_CHECK_CODE (NODE, LOOP_EXPR, 0)
1345:
```
