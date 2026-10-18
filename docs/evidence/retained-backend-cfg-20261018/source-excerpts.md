# Pinned CFG cleanup and loop source excerpts

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

## gcc/tree-cfgcleanup.cc:850–896

```text
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

## gcc/cfghooks.cc:842–937

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

## gcc/et-forest.cc:463–620

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

## gcc/graphds.cc:407–478

```text
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
