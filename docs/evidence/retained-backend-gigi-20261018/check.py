#!/usr/bin/env python3
"""Check pinned inputs and structural arithmetic, without running a compiler.

The report supplies the manual branch/reachability argument. Site inventories
are coverage aids, not substitutes for that argument or transitive cost bounds.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re


PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
RANGES = {
    "gcc/ada/checks.adb": [(7688, 7730)],
    "gcc/ada/exp_ch4.adb": [(3367, 3405), (4639, 4654)],
    "gcc/ada/exp_ch6.adb": [(6180, 6209), (6224, 6290), (6734, 6745)],
    "gcc/ada/exp_ch7.adb": [(4780, 4821)],
    "gcc/ada/sem_res.adb": [(13249, 13335)],
    "gcc/ada/libgnat/s-secsta.ads": [(70, 73), (110, 113), (300, 308), (335, 341)],
    "gcc/ada/libgnat/s-imgint.ads": [(37, 76)],
    "gcc/ada/libgnat/s-imagei.ads": [(37, 58)],
    "gcc/ada/libgnat/s-conca2.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca3.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca4.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca5.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca6.ads": [(32, 43)],
    "gcc/ada/libgnat/s-conca7.ads": [(32, 45)],
    "gcc/ada/libgnat/s-conca8.ads": [(32, 45)],
    "gcc/ada/libgnat/s-conca9.ads": [(32, 45)],
    "gcc/ada/gcc-interface/trans.cc": [
        (1047, 1059), (1189, 1380), (1393, 1415), (1649, 1658),
        (1741, 1752), (2141, 2319),
        (3026, 3306), (3313, 3400), (3540, 3585), (3843, 3941), (4028, 4126),
        (4228, 4249), (4582, 4613), (4680, 5758),
        (5990, 6003), (6031, 6065), (6076, 6095),
        (6118, 6144), (6150, 6318), (6765, 6774), (6826, 6917), (7086, 7097),
        (7291, 7655), (7656, 7755), (7944, 8003), (8118, 8146),
        (8217, 8225), (8603, 8638),
        (8968, 8996), (9066, 9098), (9104, 9185), (9217, 9278), (9298, 9325),
        (9378, 9406), (9492, 9582), (9757, 9795), (9846, 9856),
        (9889, 10025), (10014, 10494), (10708, 10752)],
    "gcc/ada/gcc-interface/utils.cc": [
        (521, 568), (682, 783), (894, 1062), (1522, 1613), (1691, 1935),
        (2861, 2894), (2918, 3133), (3137, 3162), (3660, 3671), (3830, 3875),
        (4401, 4460), (4794, 4905), (5009, 5635), (5764, 5851),
        (5911, 6250), (3700, 3755)],
    "gcc/ada/gcc-interface/decl.cc": [
        (352, 445), (697, 718), (754, 787), (1164, 1205), (1278, 1291),
        (1507, 1713), (1901, 2005), (2577, 3193), (3810, 4056),
        (4480, 4495), (4530, 5026), (5538, 5691), (7116, 7128), (7169, 7228), (7532, 7688)],
    "gcc/ada/gcc-interface/utils2.cc": [
        (216, 456), (984, 1520), (1530, 1984), (2018, 2130),
        (2166, 2435), (2564, 2761), (3009, 3380)],
    "gcc/ada/gcc-interface/gigi.h": [(1299, 1307)],
    "gcc/tree.cc": [
        (1212, 1230), (1468, 1479), (4080, 4106), (4132, 4223), (4257, 4283),
        (5194, 5230), (6982, 7023),
        (11020, 11077), (11194, 11224), (13147, 13192), (13390, 13415)],
    "gcc/tree.def": [(633, 633), (973, 990)],
    "gcc/tree-iterator.cc": [(34, 105), (188, 239)],
    "gcc/passes.def": [(27, 42), (54, 122), (195, 208), (432, 461)],
    "gcc/gimple-low.cc": [(122, 214), (695, 810), (900, 982),
                           (1178, 1223), (1438, 1468)],
    "gcc/gimplify.cc": [
        (83, 124), (387, 395), (460, 488), (619, 751), (944, 973), (1097, 1101),
        (1270, 1282), (1677, 1891),
        (1971, 2008), (2124, 2157), (2198, 2225), (3221, 3235),
        (3165, 3185), (3264, 3442), (3523, 3727),
        (3830, 3939), (4651, 4656), (4886, 5013),
        (5036, 5137), (5184, 5809), (5835, 5891), (6288, 6307),
        (6887, 6920), (7002, 7048), (7315, 7510),
        (7547, 7710), (7723, 7799), (7811, 7918),
        (19462, 19467), (20411, 20429), (20483, 20500),
        (20695, 20718), (20933, 20943), (21253, 21288),
        (21295, 21348), (21502, 21558), (21584, 21836)],
    "gcc/gimplify.h": [(53, 54)],
    "gcc/gimple.cc": [(251, 263), (328, 340), (385, 405)],
    "gcc/gimple.def": [(51, 57), (135, 145)],
    "gcc/builtins.cc": [(11051, 11089)],
    "gcc/internal-fn.def": [(520, 522)],
    "gcc/calls.cc": [(590, 630), (807, 824)],
    "gcc/tree-cfg.cc": [(145, 215), (327, 345), (488, 555), (810, 840),
                        (1370, 1388), (1507, 1547), (1664, 1700),
                        (1858, 1932), (2185, 2200), (2628, 2652),
                        (10017, 10138)],
    "gcc/tree-eh.cc": [(200, 259), (702, 715), (2056, 2215),
                       (2241, 2285), (3351, 3401), (3653, 3700),
                       (4083, 4140), (5015, 5018)],
    "gcc/tree-cfgcleanup.cc": [(476, 519), (871, 898), (1413, 1485)],
    "gcc/tree-ssa-operands.cc": [(228, 278), (424, 485), (951, 995)],
    "gcc/tree-into-ssa.cc": [(648, 704), (1203, 1228), (1337, 1411),
                            (2411, 2438), (2490, 2581)],
    "gcc/tree-dfa.cc": [(353, 365)],
    "gcc/cfganal.cc": [(1639, 1668)],
    "gcc/tree-nested.cc": [(2656, 2719), (3668, 3690)],
    "gcc/tree-inline.cc": [(6667, 6720)],
    "gcc/passes.cc": [(519, 610)],
    "gcc/ipa-inline.cc": [(3009, 3059), (3215, 3360)],
    "gcc/ipa-fnsummary.cc": [(2856, 2920), (3386, 3540)],
    "gcc/tree-ssanames.cc": [(983, 1013)],
    "gcc/adjust-alignment.cc": [(60, 78)],
    "gcc/except.cc": [(852, 875), (1280, 1284), (1818, 1896), (2287, 2293)],
    "gcc/tree-stdarg.cc": [(995, 1104)],
    "gcc/tree-vect-generic.cc": [(2185, 2200), (2461, 2490)],
    "gcc/tree-complex.cc": [(215, 331), (1994, 2002)],
    "gcc/gimple-lower-bitint.cc": [(6943, 6997)],
    "gcc/tree-switch-conversion.cc": [(3045, 3092)],
    "gcc/tree-assume.cc": [(417, 430)],
    "gcc/tree-vectorizer.cc": [(1468, 1480)],
    "gcc/tree-tailcall.cc": [(2243, 2255)],
    "gcc/tree-nrv.cc": [(123, 132)],
    "gcc/gimple-isel.cc": [(63, 73), (174, 183), (1350, 1393)],
    "gcc/targhooks.cc": [(2783, 2790)],
    "gcc/gimple-ssa-nonnull-compare.cc": [(136, 143)],
    "gcc/gimple-ssa-warn-alloca.cc": [(81, 88), (149, 161), (258, 273)],
    "gcc/gimple-ssa-warn-access.cc": [(2270, 2275), (4480, 4537),
                                    (4733, 4760), (4857, 4904)],
    "gcc/gimple-range.cc": [(40, 66)],
    "gcc/gimple-range-cache.cc": [(366, 373), (540, 545), (828, 835),
                                 (940, 948), (998, 1022)],
    "gcc/gimple-range-cache.h": [(101, 149)],
    "gcc/gimple-range-gori.cc": [(96, 103), (359, 366), (479, 523), (582, 599)],
    "gcc/gimple-range-edge.cc": [(71, 76)],
    "gcc/gimple-range-infer.cc": [(331, 351)],
    "gcc/value-query.cc": [(194, 255)],
    "gcc/value-relation.cc": [(312, 330), (1064, 1073)],
    "gcc/value-range-storage.cc": [(47, 56), (82, 88)],
    "gcc/value-range-storage.h": [(27, 34)],
    "gcc/tree-outof-ssa.cc": [(433, 438), (919, 944), (985, 1088), (1382, 1405)],
    "gcc/tree-ssa-live.cc": [(84, 117), (198, 278)],
    "gcc/tree-ssa-coalesce.cc": [(262, 276), (1046, 1145), (1249, 1333),
                                 (1601, 1742), (1843, 1871)],
    "gcc/cfgexpand.cc": [(2043, 2100), (2169, 2182), (2371, 2398), (2466, 2500), (6167, 6250), (6495, 6615),
                        (6633, 6701), (6856, 6935), (7070, 7093), (7218, 7285),
                        (7286, 7455)],
    "gcc/function.cc": [(1239, 1252), (1348, 1363), (2055, 2095),
                        (2307, 2330), (2383, 2429), (3641, 3880),
                        (4904, 4907), (4941, 4957), (5026, 5041),
                        (5104, 5303), (5400, 5456), (5580, 5646)],
    "gcc/stmt.cc": [(96, 109), (157, 179)],
    "gcc/emit-rtl.cc": [(2873, 2878), (2928, 2991), (3189, 3355),
                        (4146, 4158), (5782, 5791), (5979, 6040),
                        (6692, 6697), (6940, 7058), (7075, 7100)],
    "gcc/ada/gcc-interface/misc.cc": [(402, 435)],
    "gcc/config/i386/i386.cc": [(1464, 1471), (1795, 1803), (1874, 2026),
                               (7990, 8111)],
    "gcc/config/i386/i386.h": [(778, 801), (986, 992)],
    "gcc/config/i386/i386.md": [(505, 513), (20923, 20928), (21055, 21062)],
    "gcc/config/i386/i386-options.cc": [(2273, 2286), (2654, 2685)],
    "gcc/config/elfos.h": [(212, 220)],
    "gcc/rtl.h": [(3019, 3024), (4091, 4146)],
    "gcc/rtl.cc": [(222, 244)],
    "gcc/varasm.cc": [(4149, 4168)],
    "gcc/expr.cc": [(209, 213)],
    "gcc/genemit.cc": [(175, 179), (447, 465)],
    "gcc/gensupport.cc": [(154, 164)],
    "gcc/cfgrtl.cc": [(295, 390), (783, 851), (857, 965), (1053, 1093),
                     (1317, 1332), (1444, 1471)],
    "gcc/cfgbuild.cc": [(73, 119), (200, 380), (438, 652), (738, 807)],
    "gcc/cfgcleanup.cc": [(402, 600), (725, 762), (2633, 2669),
                         (2778, 2817), (2916, 2935), (3110, 3207)],
    "gcc/jump.cc": [(70, 101)],
    "gcc/target.def": [(2140, 2155), (6268, 6278)],

}
# The next O0 shape join includes target pass insertion and lazy RTL setup.
# Empty excerpt lists still pin complete files used to exclude optimization
# gates or machine-description split patterns.
EXTRA_RANGES = {
    "gcc/passes.def": [(463, 577)],
    "gcc/passes.cc": [(622, 749)],
    "gcc/function.cc": [(1550, 1804), (1807, 2039), (4980, 5043), (7172, 7190)],
    "gcc/cfgrtl.cc": [(1854, 1963), (3741, 3815), (3893, 3958),
                     (4072, 4227), (4296, 4320), (4555, 4640), (4891, 4994)],
    "gcc/cfg.cc": [(278, 294), (1068, 1073)],
    "gcc/cfghooks.cc": [(684, 756)],
    "gcc/cfgcleanup.cc": [(3222, 3247), (3269, 3293)],
    "gcc/cse.cc": [(7073, 7120), (7662, 7680), (7736, 7754), (7812, 7831)],
    "gcc/recog.cc": [(3492, 3615), (4508, 4533), (4749, 4767)],
    "gcc/emit-rtl.cc": [(3942, 3971)],
    "gcc/df-core.cc": [(684, 714), (731, 795)],
    "gcc/stack-ptr-mod.cc": [(82, 116)],
    "gcc/reginfo.cc": [(532, 538), (934, 982)],
    "gcc/mode-switching.cc": [(795, 839), (1299, 1326)],
    "gcc/lower-subreg.cc": [(278, 301), (1793, 1810), (1835, 1855), (1880, 1898)],
    "gcc/opts.cc": [(588, 621), (1475, 1521)],
    "gcc/common.opt": [(1293, 1295), (1313, 1315), (2498, 2500),
                        (2809, 2811), (3025, 3031)],
    "gcc/config/i386/i386-passes.def": [(20, 40)],
    "gcc/config/i386/i386-features.cc": [(2913, 2931), (2946, 2962),
                                         (3182, 3188), (3212, 3220),
                                         (4319, 4325), (5012, 5018), (5200, 5206)],
    "gcc/config/i386/i386-options.cc": [(1885, 1930), (1991, 2002), (3299, 3334)],
    "gcc/config/i386/i386.cc": [(1831, 1840), (13013, 13042), (17893, 17901)],
    "gcc/config/i386/i386.h": [(2619, 2661)],
    "gcc/config/i386/i386.md": [(1413, 1435), (23762, 23766), (30807, 30809)],
    "gcc/config/i386/predicates.md": [(685, 687)],
    "gcc/toplev.cc": [(1791, 1828), (1871, 1887)],
    "gcc/ira.cc": [(1654, 1661), (1702, 1715), (5671, 5693),
                    (5745, 5753), (5814, 5847), (6205, 6228), (6250, 6269)],
    "gcc/ira-costs.cc": [(2529, 2542)],
    "gcc/lra.cc": [(684, 688), (2698, 2701)],
    "gcc/expmed.cc": [(252, 344)],
    "gcc/expr.cc": [(118, 205)],
    "gcc/cfgloopanal.cc": [(434, 492)],
    "gcc/alias.cc": [(3281, 3316)],
    "gcc/targhooks.cc": [(1334, 1338)],
    "gcc/target.def": [(5867, 5874)],
    "gcc/rtl.h": [(862, 868)],
    "gcc/params.opt": [(869, 871)],
}
RELOAD_RANGES = {
    "gcc/ira.cc": [(3630, 3657), (5447, 5510), (5564, 5610),
                    (5735, 5767), (5789, 6027), (6074, 6152)],
    "gcc/ira-build.cc": [(125, 159), (429, 440), (1839, 1958), (3478, 3564)],
    "gcc/ira-emit.cc": [(1252, 1265)],
    "gcc/lra.cc": [(775, 789), (1380, 1388), (2420, 2688)],
    "gcc/lra-constraints.cc": [(4335, 4378), (5559, 5606), (5790, 5826),
                              (5914, 5922), (7075, 7275), (7534, 7594),
                              (7666, 7871), (7880, 8065)],
    "gcc/lra-eliminations.cc": [(1504, 1563)],
    "gcc/lra-lives.cc": [(1373, 1424)],
    "gcc/lra-assigns.cc": [(1394, 1610), (1624, 1717)],
    "gcc/lra-spills.cc": [(642, 651), (770, 878)],
    "gcc/cfgrtl.cc": [(3434, 3452)],
}
FRAME_RANGES = {
    "gcc/ira.cc": [(2457, 2491)],
    "gcc/postreload.cc": [(2437, 2452)],
    "gcc/postreload-gcse.cc": [(1442, 1462)],
    "gcc/ree.cc": [(1411, 1425)],
    "gcc/compare-elim.cc": [(952, 972)],
    "gcc/recog.cc": [(4553, 4573)],
    "gcc/function.cc": [(5734, 5747), (5867, 5894), (6017, 6039),
                        (6092, 6325), (6609, 6635)],
    "gcc/config/i386/i386.cc": [(6629, 6676), (6776, 6894), (7020, 7377),
                               (7796, 7809), (8988, 9049), (9266, 9907),
                               (10309, 10744), (21251, 21262)],
    "gcc/expr.cc": [(4572, 4761)],
    "gcc/config/i386/i386-expand.cc": [(364, 590)],
    "gcc/config/i386/i386.md": [(2419, 2423), (20994, 21001),
                               (21104, 21107), (21181, 21184)],
    "gcc/common.opt": [(2996, 3004)],
    "gcc/shrink-wrap.h": [(30, 31)],
    "gcc/shrink-wrap.cc": [(647, 653), (1774, 1799)],
    "gcc/cfgrtl.cc": [(2005, 2129)],
}
CFI_RANGES = {
    "gcc/cfgcleanup.cc": [(3317, 3328)],
    "gcc/bb-reorder.cc": [(2833, 2842)],
    "gcc/sched-rgn.cc": [(3959, 3968)],
    "gcc/regrename.cc": [(2036, 2039)],
    "gcc/fold-mem-offsets.cc": [(120, 123)],
    "gcc/regcprop.cc": [(1361, 1364)],
    "gcc/function.cc": [(6464, 6469), (6725, 6748), (6820, 6825)],
    "gcc/target.def": [(4275, 4284), (4377, 4395)],
    "gcc/hooks.cc": [(38, 42), (407, 411)],
    "gcc/recog.cc": [(4652, 4685), (4710, 4739)],
    "gcc/config/i386/i386.md": [(1195, 1197), (2201, 2271), (2784, 2789)],
    "gcc/reg-stack.cc": [(3354, 3369), (3471, 3477)],
    "gcc/var-tracking.cc": [(10611, 10614)],
    "gcc/cfgrtl.cc": [(432, 459), (489, 505)],
    "gcc/config/i386/i386.cc": [(215, 223), (24740, 24761)],
    "gcc/config/i386/i386.h": [(2142, 2171)],
    "gcc/defaults.h": [(441, 454)],
    "gcc/jump.cc": [(118, 160)],
    "gcc/reorg.cc": [(3874, 3882)],
    "gcc/except.cc": [(2770, 2779)],
    "gcc/emit-rtl.cc": [(1527, 1537), (4238, 4250), (4934, 4960)],
    "gcc/final.cc": [(613, 626), (825, 925), (1365, 1376),
                     (1963, 1979), (2275, 2282)],
    "gcc/insn-addr.h": [(27, 61)],
    "gcc/dwarf2cfi.cc": [(384, 402), (424, 459), (475, 500), (535, 540),
                        (880, 1044), (1219, 1263), (1318, 1331),
                        (1513, 1541), (1830, 1878), (2063, 2097),
                        (2215, 2230), (2260, 2447), (2451, 2532),
                        (2541, 2568), (2641, 2724), (2741, 2801),
                        (2885, 2943), (2971, 3067), (3105, 3294),
                        (3302, 3331), (3696, 3733), (3805, 3817)],
    "gcc/dwarf2out.cc": [(1046, 1063)],
}
FINAL_RANGES = {
    "gcc/align.h": [(48, 82)],
    "gcc/flags.h": [(87, 103)],
    "gcc/toplev.cc": [(157, 159), (1215, 1281)],
    "gcc/opts.cc": [(684, 687)],
    "gcc/config/i386/i386-options.cc": [(108, 189), (1819, 1832),
                                       (1862, 1875), (3402, 3424)],
    "gcc/config/i386/i386.md": [(592, 802), (2307, 2322), (2594, 2765)],
    "gcc/config/i386/i386.cc": [(10750, 10817), (16543, 16558),
                               (17605, 17668), (17943, 18149)],
    "gcc/config/i386/x86-tune.def": [(297, 300)],
    "gcc/config/i386/i386.opt": [(1070, 1072), (1113, 1116), (1134, 1136)],
    "gcc/genattrtab.cc": [(1405, 1535)],
    "gcc/final.cc": [(162, 162), (225, 227), (455, 465), (1007, 1104),
                     (1110, 1170), (1290, 1311), (1679, 1786),
                     (1856, 1873), (1930, 2003), (2159, 2170),
                     (2751, 2878), (4259, 4294)],
    "gcc/dwarf2out.cc": [(180, 180), (307, 316), (1071, 1119), (1249, 1276)],
    "gcc/config/elfos.h": [(121, 131)],
    "gcc/except.cc": [(3243, 3248), (3291, 3318)],
    "gcc/expr.cc": [(14347, 14363)],
}
GATE_FILES = (
    "fwprop.cc", "cprop.cc", "gcse.cc", "store-motion.cc", "ifcvt.cc",
    "loop-init.cc", "web.cc", "dse.cc", "auto-inc-dec.cc", "init-regs.cc",
    "dce.cc", "ext-dce.cc", "combine.cc", "late-combine.cc", "bb-reorder.cc",
    "modulo-sched.cc", "sched-rgn.cc", "avoid-store-forwarding.cc",
    "early-remat.cc", "dep-fusion.cc",
)
MD_FILES = (
    "i386.md", "pentium.md", "ppro.md", "k6.md", "athlon.md", "bdver1.md",
    "bdver3.md", "btver2.md", "znver.md", "zn4zn5.md", "geode.md", "atom.md",
    "slm.md", "glm.md", "core2.md", "haswell.md", "lujiazui.md", "yongfeng.md",
    "predicates.md", "constraints.md", "mmx.md", "sse.md", "sync.md", "subst.md",
)
for _name, _ranges in EXTRA_RANGES.items():
    RANGES.setdefault(_name, []).extend(_ranges)
for _name, _ranges in RELOAD_RANGES.items():
    RANGES.setdefault(_name, []).extend(_ranges)
for _name, _ranges in FRAME_RANGES.items():
    RANGES.setdefault(_name, []).extend(_ranges)
for _name, _ranges in CFI_RANGES.items():
    RANGES.setdefault(_name, []).extend(_ranges)
for _name, _ranges in FINAL_RANGES.items():
    RANGES.setdefault(_name, []).extend(_ranges)
for _name in GATE_FILES:
    RANGES.setdefault("gcc/" + _name, [])
for _name in MD_FILES:
    RANGES.setdefault("gcc/config/i386/" + _name, [])
INTERFACE = ("trans", "utils", "utils2", "decl")
MAIN_APIS = ("src/silver_arguments.ads", "src/silver_io.ads")


def collect(ada, gcc_root):
    sources, manifest, excerpts = {}, [], [
        "# Pinned gigi structural source excerpts\n",
        "Full-file SHA256 identities are in source-manifest.json; LF numbering.\n",
        "Excerpts expand tabs to eight columns and trim trailing whitespace.\n"]
    for name, ranges in RANGES.items():
        path = (ada / name.removeprefix("gcc/ada/")
                if name.startswith("gcc/ada/") else gcc_root / name)
        data = path.read_bytes()
        manifest.append({"path": name, "bytes": len(data),
                         "sha256": hashlib.sha256(data).hexdigest()})
        source = data.decode()
        sources[name] = source
        # GCC uses form-feed characters as section separators.  splitlines()
        # would disagree with compiler/rg LF line numbers even though the
        # full-file identity stayed correct.
        lines = source.split("\n")
        for low, high in ranges:
            assert 1 <= low <= high <= len(lines)
            excerpts.append(f"\n## {name}:{low}–{high}\n\n```text\n")
            excerpts.extend((f"{n}: " + lines[n-1].expandtabs(8)).rstrip()+"\n"
                            for n in range(low, high+1))
            excerpts.append("```\n")
    # These two identities belong to this Silver tree, not the upstream pin.
    repo = Path(__file__).resolve().parents[3]
    api_manifest = []
    for name in MAIN_APIS:
        data = (repo / name).read_bytes()
        sources[name] = data.decode()
        api_manifest.append({"path": name, "bytes": len(data),
                             "sha256": hashlib.sha256(data).hexdigest()})
        excerpts.append(f"\n## {name} (selected Silver API, complete)\n\n```text\n")
        excerpts.extend((f"{n}: " + line.expandtabs(8)).rstrip()+"\n"
                        for n, line in enumerate(sources[name].splitlines(), 1))
        excerpts.append("```\n")
    patterns = {
        "binding_push": r"\bgnat_pushlevel\s*\(",
        "cleanup_shapes": r"\b(?:TARGET_EXPR|CLEANUP_POINT_EXPR|WITH_CLEANUP_EXPR|TRY_FINALLY_EXPR|TRY_CATCH_EXPR|BIND_EXPR)\b",
        "var_declaration_routes": r"\b(?:create_var_decl|create_temporary|create_init_temporary|create_tmp_var|create_tmp_var_raw|build_decl)\s*\(",
    }
    inventory = {key: [] for key in patterns}
    for stem in INTERFACE:
        name = f"gcc/ada/gcc-interface/{stem}.cc"
        source = sources[name]
        for key, pattern in patterns.items():
            for match in re.finditer(pattern, source):
                line = source.count("\n", 0, match.start()) + 1
                inventory[key].append({"path": name, "line": line,
                                       "match": match.group()})
    return sources, {"commit": PIN, "files": manifest,
                     "silver_main_api_files": api_manifest}, "".join(excerpts), inventory


def check_sources(sources, inventory):
    trans = sources["gcc/ada/gcc-interface/trans.cc"]
    exp6 = sources["gcc/ada/exp_ch6.adb"]
    exp7 = sources["gcc/ada/exp_ch7.adb"]
    passes = sources["gcc/passes.def"]
    assert passes.index("NEXT_PASS (pass_lower_cf)") < passes.index(
        "NEXT_PASS (pass_lower_eh)")
    assert "Add_Return (Spec_Id, Statements (HSS));" in exp6
    assert "Append_To (Stmts, Stmt);\n            Set_Analyzed (Stmt);" in exp6
    assert "Set_At_End_Proc (N, New_Occurrence_Of (Fin_Id, Sloc (N)))" in exp7
    begin = trans.index("\nSubprogram_Body_to_gnu (")
    end = trans.index("\n}\n", begin)
    body = trans[begin:end]
    assert body.index("add_stmt (gnat_to_gnu (Handled_Statement_Sequence") < body.index(
        "At_End_Proc_to_gnu (gnat_node)")
    assert "vec_safe_push (gnu_return_label_stack, NULL_TREE);" in body
    begin = trans.index("\ngnat_gimplify_stmt (tree *stmt_p)")
    end = trans.index("    case EXIT_STMT:", begin)
    loop = trans[begin:end]
    assert loop.index("append_to_statement_list (LOOP_STMT_BODY") < loop.index(
        "tree t = build1 (GOTO_EXPR")
    assert loop.count("create_artificial_label (") == 1
    assert loop.count("build1 (LABEL_EXPR") == 2
    assert loop.count("build1 (GOTO_EXPR") == 2
    # Five optimization-annotation COND-adjacent build3 calls are excluded by
    # the selected flags; the executable condition is one explicit COND_EXPR.
    assert loop.count("build3 (COND_EXPR") == 1
    nested = sources["gcc/tree-nested.cc"]
    assert len(re.findall(r"\bget_nl_goto_field\s*\(", nested)) == 2
    assert not any(row["match"] in {"TARGET_EXPR", "CLEANUP_POINT_EXPR",
                                    "WITH_CLEANUP_EXPR"}
                   for row in inventory["cleanup_shapes"])
    assert "if (No (gnat_cond) || Nkind (gnat_cond) != N_Op_Not)" in trans
    assert "Nkind (gnat_rcond) == N_In" in trans
    assert "|| Nkind (gnat_rcond) == N_Op_Ge" in trans
    assert "|| Nkind (gnat_rcond) == N_Op_Le" in trans
    checks = sources["gcc/ada/checks.adb"]
    assert "Force_Evaluation (N, Mode => Strict);" in checks
    assert "if Source_Base_Type = Target_Base_Type then" in checks
    assert "Left_Opnd  => Duplicate_Subexpr (N)," in checks
    assert "if (!optimize && !Has_Pragma_Inline_Always (gnat_entity))" in trans
    assert "if (fn && TREE_READONLY (fn) && DECL_SAVED_TREE (fn))" in sources["gcc/tree-inline.cc"]
    specs = [name for name in sources if name.startswith("gcc/ada/libgnat/")]
    for name in specs + list(MAIN_APIS):
        assert "inline_always" not in sources[name].lower(), name
    decl = sources["gcc/ada/gcc-interface/decl.cc"]
    start = decl.index("\nelaborate_expression (Node_Id")
    end = decl.index("\n}\n", start)
    helper = decl[start:end]
    assert helper.index("if (present_gnu_tree (gnat_expr))") < helper.index("gnat_to_gnu (gnat_expr)")
    assert "if (!CONTAINS_PLACEHOLDER_P (gnu_expr))" in helper
    assert "save_gnu_tree (gnat_expr, gnu_expr, true);" in helper
    # Source-site/order checks support the separately argued Main dependency
    # frontier. They do not prove every source reference has an association.
    assert decl.index("&& present_gnu_tree (gnat_entity))") < decl.index(
        "gnu_expr = gnat_to_gnu_external (gnat_temp);")
    external_calls = re.findall(r"\bgnat_to_gnu_external\s*\(", decl)
    assert len(external_calls) == 2
    start = trans.index("    case N_Object_Declaration:\n", trans.index("\ngnat_to_gnu (Node_Id"))
    end = trans.index("    case N_Object_Renaming_Declaration:", start)
    object_case = trans[start:end]
    assert object_case.index("gnu_expr = gnat_to_gnu (Expression (gnat_node));") < object_case.index(
        "gnat_to_gnu_entity (gnat_temp, gnu_expr, true);")
    assert "save_gnu_tree (gnat_node, gnu_result, true);" in object_case
    start = trans.index("    case N_Expression_With_Actions:", trans.index("\ngnat_to_gnu (Node_Id"))
    end = trans.index("    case N_Freeze_Entity:", start)
    ewa = trans[start:end]
    assert ewa.index("add_stmt_list (Actions (gnat_node));") < ewa.index(
        "gnu_expr = gnat_to_gnu (Expression (gnat_node));") < ewa.index(
        "gnu_result_type = get_unpadded_type (Etype (gnat_node));")
    assert "? get_gnu_tree (gnat_decl) : NULL_TREE;" in trans
    assert "TREE_CONSTANT (t)" in trans[trans.index("\nconstant_decl_with_initializer_p ("):trans.index("\nconstant_decl_with_initializer_p (")+450]
    tree = sources["gcc/tree.cc"]
    assert "else if (tree_invariant_p (TREE_OPERAND (expr, 1)))" in tree
    assert "else if (tree_invariant_p (TREE_OPERAND (expr, 0)))" in tree
    gimplify = sources["gcc/gimplify.cc"]
    assert "push_gimplify_context (true);" in gimplify
    assert "if (!SAVE_EXPR_RESOLVED_P (*expr_p))" in gimplify
    assert "SAVE_EXPR_RESOLVED_P (*expr_p) = 1;" in gimplify
    assert "t = make_ssa_name (TYPE_MAIN_VARIANT (TREE_TYPE (val)));" in gimplify
    assert "mod = build2 (INIT_EXPR, TREE_TYPE (t), t, unshare_expr (val));" in gimplify
    assert "assign = gimple_build_assign (*to_p, *from_p);" in gimplify
    start = gimplify.index("\ngimplify_type_sizes (tree type,")
    end = gimplify.index("\n}\n", start)
    types = gimplify[start:end]
    assert types.index("TYPE_SIZES_GIMPLIFIED (type) = 1;") < types.index("switch (TREE_CODE (type))")
    assert types.count("gimplify_one_sizepos (") == 7
    start = trans.index("\ngnat_gimplify_expr (")
    end = trans.index("\n}\n", start)
    assert trans[start:end].count("gimplify_one_sizepos (") == 2
    assert "bool rhs_cond_ok = false" in sources["gcc/gimplify.h"]
    start = gimplify.index("\ngimplify_cond_expr (tree *expr_p,")
    end = gimplify.index("\n}\n", start)
    cond = gimplify[start:end]
    assert cond.count("gimple_build_cond (") == 1
    assert cond.count("gimple_build_label (") == 3
    assert cond.count("gimple_build_goto (") == 1
    assert cond.count("create_artificial_label (") == 3
    assert cond.count("maybe_fold_stmt (") == 1
    assert cond.count("build2 (INIT_EXPR,") == 2
    for name in ("tree_associate_condition_with_expr", "gimple_associate_condition_with_expr"):
        start = gimplify.index("\n" + name + " (")
        end = gimplify.index("\n}\n", start)
        helper = gimplify[start:end]
        assert helper.index("if (!condition_coverage_flag)") < helper.index("new hash_map")
    for name in ("ADD_OVERFLOW", "SUB_OVERFLOW", "MUL_OVERFLOW"):
        assert f"DEF_INTERNAL_FN ({name}, ECF_CONST | ECF_LEAF | ECF_NOTHROW, NULL)" in sources["gcc/internal-fn.def"]
    start = tree.index("\nprocess_call_operands (tree t)")
    end = tree.index("\n}\n", start)
    assert "TREE_READONLY (t) = read_only;" in tree[start:end]
    assert "if (tree_invariant_p_1 (inner))\n    return expr;" in tree
    start = gimplify.index("\ngimplify_call_expr (tree *expr_p,")
    end = gimplify.index("\n}\n", start)
    call = gimplify[start:end]
    assert call.index("if (want_value)\n\t    return GS_ALL_DONE;") < call.index("gimplify_arg (")
    assert "auto_vec<tree> vargs (nargs);" in gimplify
    assert sources["gcc/gimple.cc"].count("nargs + 3))") == 2
    assert "if (!saved)\n    save_gnu_tree (gnat_entity, gnu_decl, false);" in decl
    assert "case N_Itype_Reference:\n      if (!present_gnu_tree (Itype (gnat_node)))" in trans
    start = trans.index("\nprocess_type (Entity_Id")
    end = trans.index("\n}\n", start)
    process_type = trans[start:end]
    assert process_type.count("gnat_to_gnu_entity (") == 1
    assert "&& TYPE_IS_DUMMY_P (TREE_TYPE (gnu_old))" in process_type
    utils = sources["gcc/ada/gcc-interface/utils.cc"]
    start = utils.index("\nmake_dummy_type (Entity_Id")
    end = utils.index("\n}\n", start)
    dummy = utils[start:end]
    assert dummy.index("if (PRESENT_DUMMY_NODE") < dummy.index("make_node (")
    assert dummy.count("make_node (") == 2
    assert dummy.count("create_type_stub_decl (") == 1
    start = gimplify.index("\ngimplify_compound_lval (")
    end = gimplify.index("\n}\n", start)
    refs = gimplify[start:end]
    assert refs.count("expr_stack.safe_push (") == 1
    assert refs.count("unshare_expr (") == 3
    assert refs.count("size_binop_loc (") == 2
    assert refs.count("gimplify_expr (") == 6
    assert refs.index("unshare_expr (array_ref_low_bound (t))") < refs.index(
        "if (!is_gimple_min_invariant (low))")
    assert "auto_vec<tree, 10> expr_stack;" in refs
    start = gimplify.index("\ncanonicalize_component_ref (")
    end = gimplify.index("\n}\n", start)
    canonical = gimplify[start:end]
    assert "build1 (" not in canonical
    assert canonical.count("build_qualified_type (") == 1
    start = gimplify.index("\ncanonicalize_addr_expr (")
    end = gimplify.index("\n}\n", start)
    canonical = gimplify[start:end]
    assert canonical.count("build4 (ARRAY_REF,") == 1
    assert canonical.count("build1 (ADDR_EXPR,") == 1
    assert "*expr_p = unshare_expr (DECL_VALUE_EXPR (decl));" in gimplify
    start = gimplify.index("\nprepare_gimple_addressable (")
    end = gimplify.index("\n}\n", start)
    addressable = gimplify[start:end]
    assert "if (is_gimple_reg (*expr_p))" in addressable
    assert addressable.count("internal_get_tmp_var (") == 1
    start = gimplify.index("\nmaybe_with_size_expr (")
    end = gimplify.index("\n}\n", start)
    sized = gimplify[start:end]
    assert sized.index("unshare_expr (size)") < sized.index(
        "SUBSTITUTE_PLACEHOLDER_IN_EXPR (size, expr)") < sized.index(
        "build2 (WITH_SIZE_EXPR,")
    start = gimplify.index("\ngimplify_modify_expr_to_memcpy (")
    end = gimplify.index("\n}\n", start)
    memcpy = gimplify[start:end]
    assert memcpy.count("build_fold_addr_expr_loc (") == 2
    assert memcpy.count("gimplify_arg (") == 2
    assert "gimple_build_call (t, 3, to_ptr, from_ptr, size)" in memcpy
    assert memcpy.index("if (want_value)") < memcpy.index("create_tmp_var (")
    start = gimplify.index("\ngimplify_variable_sized_compare (")
    end = gimplify.index("\n}\n", start)
    memcmp = gimplify[start:end]
    assert memcmp.index("unshare_expr (arg)") < memcmp.index("SUBSTITUTE_PLACEHOLDER_IN_EXPR (")
    assert memcmp.count("build_fold_addr_expr_loc (") == 2
    assert "build_call_expr_loc (loc, t, 3, dest, src, arg)" in memcmp
    start = gimplify.index("\ngimplify_scalar_mode_aggregate_compare (")
    end = gimplify.index("\n}\n", start)
    compare = gimplify[start:end]
    assert compare.count("fold_build1_loc (") == 2
    assert compare.count("fold_build2_loc (") == 1
    assert compare.index("if (code != EQ_EXPR && code != NE_EXPR)") < compare.index(
        "BUILT_IN_BSWAP16")
    start = trans.index("    case N_Null_Statement:\n", trans.index("\ngnat_to_gnu (Node_Id"))
    end = trans.index("\n      break;", start)
    null = trans[start:end]
    assert "if (!optimize && Comes_From_Source (gnat_node))" in null
    assert null.count("create_label_decl (") == 1
    assert null.count("build1 (GOTO_EXPR,") == 1
    assert null.count("build1 (LABEL_EXPR,") == 1
    assert null.count("add_stmt (stmt);") == 2
    for code in ("DECL_EXPR", "GOTO_EXPR", "LABEL_EXPR", "RETURN_EXPR"):
        assert re.search(r"DEFTREECODE \(" + code + r', "[^"]+", tcc_statement, 1\)',
                         sources["gcc/tree.def"])
    assert 'DEFGSCODE(GIMPLE_RETURN, "gimple_return", GSS_WITH_MEM_OPS)' in sources["gcc/gimple.def"]
    assert 'DEFGSCODE(GIMPLE_GOTO, "gimple_goto", GSS_WITH_OPS)' in sources["gcc/gimple.def"]
    assert 'DEFGSCODE(GIMPLE_LABEL, "gimple_label", GSS_WITH_OPS)' in sources["gcc/gimple.def"]
    low = sources["gcc/gimple-low.cc"]
    assert "data.return_statements.create (8);" in low
    assert "tmp_rs.label = create_artificial_label (cfun->function_end_locus);" in low
    assert "gsi_insert_after (&i, t.stmt, GSI_CONTINUE_LINKING);" in low
    assert "if (!VAR_P (var))\n\tcontinue;" in low
    eh = sources["gcc/tree-eh.cc"]
    assert "finally_tree = new hash_table<finally_tree_hasher> (31);" in eh
    assert "if (!tf)\n    return;" in eh
    assert "record_in_finally_tree (temp, region);" in eh
    cfg = sources["gcc/tree-cfg.cc"]
    assert "static const int initial_cfg_capacity = 20;" in cfg
    assert "edge e = make_edge (bb, label_bb, EDGE_FALLTHRU);" in cfg
    assert "if (!DECL_ARTIFICIAL (lab) && (!optimize || FORCED_LABEL (lab)))" in cfg
    cleanup = sources["gcc/tree-cfgcleanup.cc"]
    assert "if (single_pred_p (bb)\n      && single_succ_p (single_pred_edge (bb)->src))\n    return false;" in cleanup
    operands = sources["gcc/tree-ssa-operands.cc"]
    assert "case GIMPLE_RETURN:\n      append_vuse (gimple_vop (fn));" in operands
    assert "build_uses.safe_insert (0, gimple_vuse_ptr (stmt));" in operands
    into = sources["gcc/tree-into-ssa.cc"]
    assert "init_ssa_operands (fun);" in into
    assert "compute_dominance_frontiers (dfs);" in into
    assert "rewrite_blocks (ENTRY_BLOCK_PTR_FOR_FN (fun), REWRITE_ALL);" in into
    assert "ddef = make_ssa_name_fn (fn, var, gimple_build_nop ());" in sources["gcc/tree-dfa.cc"]
    assert "if (EDGE_COUNT (b->preds) >= 2)" in sources["gcc/cfganal.cc"]
    # Concrete O0 continuation. These pins support the manual shape argument,
    # not a claim that arbitrary options or target hooks preserve this body.
    assert "return optimize >= 1 && !optimize_debug;" in sources["gcc/passes.cc"]
    assert "vec_alloc (cfun->eh->ttype_data, 16);" in sources["gcc/except.cc"]
    assert "ehspec_hash_type ehspec (31);" in sources["gcc/except.cc"]
    assert "ttypes_hash_type ttypes (31);" in sources["gcc/except.cc"]
    for name in ("gcc/gimple-ssa-warn-alloca.cc", "gcc/gimple-ssa-warn-access.cc",
                 "gcc/cfgexpand.cc"):
        assert "enable_ranger (fun);" in sources[name]
    cache = sources["gcc/gimple-range-cache.cc"]
    assert "last_basic_block_for_fn (cfun) + 64" in cache
    assert "m_ssa_ranges.safe_grow_cleared (num_ssa_names);" in cache
    gori = sources["gcc/gimple-range-gori.cc"]
    assert "if (single_succ_p (bb))\n    return;" in gori
    assert "m_def_chain.safe_grow_cleared (num_ssa_names);" in gori
    coalesce = sources["gcc/tree-ssa-coalesce.cc"]
    begin = coalesce.index("\ncoalesce_ssa_name (")
    end = coalesce.index("\n}\n", begin)
    body = coalesce[begin:end]
    assert body.index("if (num_var_partitions (map) < 1)") < body.index(
        "liveinfo = calculate_live_ranges (map, false);")
    assert "&& !virtual_operand_p (ssa_name (tmp))" in sources["gcc/tree-ssa-live.cc"]
    out = sources["gcc/tree-outof-ssa.cc"]
    assert "nodes (30), edge_list (20), edge_locus (10), visited (map->num_partitions)," in out
    assert "stack (30), map (map), const_dests (20), const_copies (20), copy_locus (10)" in out
    expand = sources["gcc/cfgexpand.cc"]
    begin = expand.index("\nexpand_gimple_basic_block (")
    end = expand.index("\n}\n", begin)
    body = expand[begin:end]
    assert body.index("&& !gimple_return_retval (ret_stmt))") < body.index(
        "gsi_remove (&gsi, false);") < body.index("expand_gimple_stmt (stmt);")
    assert "single_succ_edge (bb)->flags |= EDGE_FALLTHRU;" in body
    assert "(e->flags & EDGE_FALLTHRU) && e->dest != bb->next_bb" in body
    assert "note = emit_note (NOTE_INSN_BASIC_BLOCK);" in body
    assert expand.index("init_block = construct_init_block ();") < expand.index(
        "enable_ranger (fun);")
    # Selected-target scaffolding and the location-preserving O0 merger.
    assert '(FIRST_PSEUDO_REG\t\t92)' in sources["gcc/config/i386/i386.md"]
    emit = sources["gcc/emit-rtl.cc"]
    assert "crtl->emit.regno_pointer_align_length = LAST_VIRTUAL_REGISTER + 101;" in emit
    assert "reg_rtx_no = LAST_VIRTUAL_REGISTER + 1;" in emit
    assert "if (VOID_TYPE_P (type))\n    return false;" in sources["gcc/function.cc"]
    i386 = sources["gcc/config/i386/i386.cc"]
    assert "ix86_cmodel == CM_SMALL_PIC" in i386
    assert "return virtual_incoming_args_rtx;" in i386
    assert "if (TARGET_64BIT)\n    return 0;" in i386
    assert "opts->x_flag_pic ? CM_SMALL_PIC : CM_SMALL" in sources["gcc/config/i386/i386-options.cc"]
    assert "if (! crtl->eh.ehr_label)\n    return;" in sources["gcc/except.cc"]
    assert "emit_nop_for_unique_locus_between (a, b);" in sources["gcc/cfgrtl.cc"]
    assert "emit_insn_after_noloc (gen_nop (), BB_END (a), a)" in sources["gcc/cfgrtl.cc"]
    assert '(define_insn "nop"\n  [(const_int 0)]' in sources["gcc/config/i386/i386.md"]
    assert '(define_insn "blockage"\n  [(unspec_volatile [(const_int 0)] UNSPECV_BLOCKAGE)]' in sources["gcc/config/i386/i386.md"]
    assert "if (GET_NUM_ELEM (vec) == 1)\n    return RTVEC_ELT (vec, 0);" in sources["gcc/gensupport.cc"]
    assert "case CONST_INT:\n      return GEN_INT (get_uint ());" in emit
    assert "if (copied && len > 0)" in emit
    assert "if (ivs == 0)\n    return;" in sources["gcc/function.cc"]
    # At O0, exiting CFG layout can split an edge solely for its location.
    rtlcfg = sources["gcc/cfgrtl.cc"]
    assert "if (!optimize && !DECL_IGNORED_P (current_function_decl))" in rtlcfg
    assert "nb = split_edge (e);" in rtlcfg
    assert "INSN_LOCATION (BB_END (nb)) = e->goto_locus;" in rtlcfg
    assert "make_single_succ_edge (bb, edge_in->dest, EDGE_FALLTHRU);" in rtlcfg
    assert "e = ggc_cleared_alloc<edge_def> ();" in sources["gcc/cfg.cc"]
    assert "bb_original = new copy_map_t (10);" in sources["gcc/cfg.cc"]
    assert "bb_copy = new copy_map_t (10);" in sources["gcc/cfg.cc"]
    assert "loop_copy = new copy_map_t (10);" in sources["gcc/cfg.cc"]
    assert "if (! n_entities)\n    return 0;" in sources["gcc/mode-switching.cc"]
    assert "f = ggc_cleared_alloc<machine_function> ();" in sources["gcc/config/i386/i386-options.cc"]
    assert "if (!crtl->has_asm_statement)\n    return 0;" in sources["gcc/function.cc"]
    assert "return ((!timode_p || TARGET_64BIT)" in sources["gcc/config/i386/i386-features.cc"]
    assert "&& TARGET_STV && TARGET_SSE2 && optimize > 1);" in sources["gcc/config/i386/i386-features.cc"]
    assert "if (!rtl_initialized)\n    ira_init_once ();" in sources["gcc/toplev.cc"]
    assert "init_dummy_function_start ();" in sources["gcc/toplev.cc"]
    assert "memset (insn_code_data, 0, sizeof (insn_code_data));" in sources["gcc/lra.cc"]
    # Pin every selected MD include; a missing included file must not silently
    # disappear from the manual no-split review.
    for name in MD_FILES:
        source = sources["gcc/config/i386/" + name]
        for include in re.findall(r'\(include "([^"]+)"\)', source):
            assert include in MD_FILES, (name, include)
    lra = sources["gcc/lra.cc"]
    start = lra.index("\nlra (FILE *f, int verbose)")
    end = lra.index("\n}\n", start)
    body = lra[start:end]
    assert body.index("lra_pmode_pseudo = gen_reg_rtx (Pmode);") < body.index(
        "emit_note (NOTE_INSN_DELETED);") < body.index("init_reg_info ();")
    assert "reg_info_size = max_reg_num () * 3 / 2 + 1;" in lra
    assert "lra_insn_recog_data_len = index * 3U / 2;" in lra
    assert "lra_insn_recog_data_len = index + 1;" in lra
    assert "if (! reloads_p && lra_constraint_iter > 1)" in body
    assert "if (! lra_need_for_spills_p ())\n\tbreak;" in body
    assert "unshare_all_rtl_again (get_insns ());" in body
    constraints = sources["gcc/lra-constraints.cc"]
    assert "if (n_operands == 0 || n_alternatives == 0)\n    return false;" in constraints
    assert "invariants.create (100);" in constraints
    assert "invariant_table = htab_create (100," in constraints
    lives = sources["gcc/lra-lives.cc"]
    start = lives.index("\nlra_create_live_ranges_1 (")
    assert lives.index("if (! have_referenced_pseudos)", start) < lives.index(
        "pseudos_live = sparseset_alloc (max_regno);", start)
    allocnos = sources["gcc/ira-build.cc"]
    assert "allocno_vec.create (max_reg_num () * 2);" in allocnos
    assert "ira_object_id_map_vec.create (max_reg_num () * 2);" in allocnos
    assert "if (! loops_p)\n    return;" in sources["gcc/ira-emit.cc"]
    function = sources["gcc/function.cc"]
    assert "emit_note (NOTE_INSN_PROLOGUE_END);" in function
    assert "emit_note (NOTE_INSN_EPILOGUE_BEG);" in function
    assert "hash_table<insn_cache_hasher>::create_ggc (17);" in function
    assert "cleanup_cfg (optimize ? CLEANUP_EXPENSIVE : 0);" in function
    assert "(flag_shrink_wrap && targetm.have_simple_return ())" in sources["gcc/shrink-wrap.h"]
    x86 = sources["gcc/config/i386/i386.cc"]
    assert "insn = emit_move_insn (hard_frame_pointer_rtx, stack_pointer_rtx);" in x86
    assert "&& m->fs.sp_offset == frame.hfp_save_offset)\n\tix86_emit_restore_reg_using_pop (hard_frame_pointer_rtx);" in x86
    assert "emit_jump_insn (gen_simple_return_internal ());" in x86
    assert "emit_barrier_after (last);" in sources["gcc/cfgrtl.cc"]
    cfi = sources["gcc/dwarf2cfi.cc"]
    assert "trace_info.create (16);" in cfi
    assert "= new hash_table<trace_info_hasher> (trace_info.length ());" in cfi
    assert "trace->end_row = copy_cfi_row (trace->beg_row);" in cfi
    assert "ti->beg_row = copy_cfi_row (cur_row);" in cfi
    assert "vec_safe_grow_cleared (row->reg_save, column + 1, true);" in cfi
    assert "vec_safe_push (fde->dw_fde_cfi, xcfi);" in cfi
    assert "emit_note_before (NOTE_INSN_CFI_LABEL, insn);" in cfi
    assert "emit_note_after (NOTE_INSN_CFI, add_cfi_insn);" in cfi
    assert "loc.offset = DEFAULT_INCOMING_FRAME_SP_OFFSET;" in cfi
    assert "initial_return_save (INCOMING_RETURN_ADDR_RTX);" in cfi
    assert "if (cfi_row_equal_p (old_row, ti->beg_row))" in cfi
    assert "INSN_ADDRESSES_NEW" not in sources["gcc/emit-rtl.cc"]
    final = sources["gcc/final.cc"]
    assert "label_align.safe_grow_cleared (max_labelno - min_labelno + 1, true);" in final
    assert "if ((unsigned) INSN_UID (insn) >= INSN_ADDRESSES_SIZE ())" in final
    assert "gcc_assert (NOTE_P (insn));\n\t      insn_current_address = -1;" in final
    assert "INSN_ADDRESSES_ALLOC (max_uid);" in final
    assert "if (!increasing)\n\tbreak;" in final
    assert "if (i > LAST_STACK_REG)\n    return false;" in sources["gcc/reg-stack.cc"]
    assert "if (cfun->eh->region_tree == NULL)\n    return false;" in sources["gcc/except.cc"]
    assert "{ OPT_LEVELS_2_PLUS_SPEED_ONLY, OPT_falign_labels, NULL, 1 }" in sources["gcc/opts.cc"]
    assert "if (write_symbols)\n    {\n      reemit_insn_block_notes ();" in final
    assert "static int insn_counter = 0;" in final
    assert "insn_counter++;" in final
    assert '"*insn_variable_length_p"' in sources["gcc/genattrtab.cc"]
    assert "= {identity_fn,identity_fn, zero_fn, zero_fn};" in sources["gcc/genattrtab.cc"]
    assert "|| GET_CODE (addr) == POST_MODIFY)\n    return 0;" in x86
    assert "Var(ix86_function_return) Init(indirect_branch_keep)" in sources["gcc/config/i386/i386.opt"]
    assert "Var(ix86_instrument_return) Init(instrument_return_none)" in sources["gcc/config/i386/i386.opt"]
    assert "Var(ix86_harden_sls) Init(harden_sls_none)" in sources["gcc/config/i386/i386.opt"]
    assert "fde->dw_fde_end = xstrdup (label);" in sources["gcc/dwarf2out.cc"]
    iterator = sources["gcc/tree-iterator.cc"]
    start = iterator.index("\ntsi_link_after (")
    end = iterator.index("\n}\n", start)
    splice = iterator[start:end]
    assert splice.index("if (TREE_CODE (t) == STATEMENT_LIST)") < splice.index(
        "free_stmt_list (t);") < splice.index("ggc_alloc<tree_statement_list_node> ()")


def arithmetic():
    # Enumerate the call state machine: optional early R, optional late R,
    # and optional CICO P. A temporary only gets made if none already exists.
    call_result_max = 0
    for early in (0, 1):
        for late in (0, 1):
            for cico in (0, 1):
                retval = early
                result_temps = early
                if late and not retval:
                    retval = 1
                    result_temps += 1
                if cico and not retval:
                    result_temps += 1
                call_result_max = max(call_result_max, result_temps)
    assert call_result_max == 1
    # These coefficients arise from the listed sites, not fit measurements.
    push = {"U": 1, "F": 2, "B": 1, "L": 2, "C": 1, "X": 1}
    bind = {"U": 1, "F": 1, "B": 1, "L": 2, "C": 1, "X": 0}
    return {
        "binding_push_coefficients": push,
        "null_o0_body_block_edge_statement_ceilings": [3, 4, 3],
        "null_o0_real_ssa_partitions": 0,
        "null_o0_ranger_instances_upper_bound": 1+2+1,
        "null_ranger_max_block_index_slots": 5+1,
        "null_ranger_update_vector_length_upper_bound": 5+1+64,
        "null_ranger_gori_bitmap_headers_upper_bound": 2*(5+1),
        "null_ranger_infer_exit_vector_length_upper_bound": 5+1+1,
        "null_ranger_range_allocators_per_instance": 3,
        "null_phi_elimination_vector_requests": [30, 20, 10, 30, 20, 20, 10],
        "null_expanded_body_rtl_label_note_ceilings": [2, 3],
        "null_expanded_body_return_expansions": 0,
        "null_pre_subdivision_ordinary_block_edge_ceilings": [3+1+1, 4+1+1],
        "null_rtl_hard_and_virtual_reg_identifiers": [92, 6],
        "null_rtl_first_dynamic_pseudo_number": 92+6,
        "null_rtl_alignment_and_pointer_array_lengths": [92+5+101]*2,
        "null_rtl_register_array_raw_bytes_lp64": (92+5+101)*(1+8),
        "null_rtl_max_block_index_slots": 5+1+1,
        "null_rtl_lifetime_label_note_insn_ceilings": [2+1, 3+1+1+1+1, 1+4],
        "null_rtl_lifetime_chain_node_ceiling": 3+7+5,
        "null_rtl_cleanup_nop_ceiling": 5-1,
        "null_rtl_blockage_nodes_and_one_element_vectors_including_unshare": [2, 2],
        "null_rtl_dynamic_pseudos_stack_slots_calls_jumps": [0, 0, 0, 0],
        "null_pre_IRA_location_edge_split_ceiling": 5,
        "null_pre_IRA_block_edge_slot_ceilings": [5+5, 6+5, 7+5],
        "null_pre_IRA_lifetime_label_note_insn_ceilings": [3, 7+5, 5+5],
        "null_pre_IRA_lifetime_chain_node_ceiling": 3+12+10,
        "null_pre_IRA_first_unused_chain_uid_ceiling": 1+3+12+10,
        "null_pre_IRA_new_dynamic_pseudos_stack_slots_calls_jumps": [0, 0, 0, 0],
        "null_pre_IRA_CFG_copy_hash_initial_requests": [10, 10, 10],
        "null_pre_IRA_trivial_dead_count_array_length": 98,
        "null_pre_IRA_hard_regs_live_count_array_length": 92,
        "null_post_reload_block_edge_slot_ceilings": [10, 11, 12],
        "null_post_reload_lifetime_label_note_insn_ceilings": [3, 12+1, 10],
        "null_post_reload_lifetime_chain_node_ceiling": 25+1,
        "null_post_reload_first_unused_chain_uid_ceiling": 1+25+1,
        "null_post_reload_new_dynamic_pseudos_stack_slots_calls_jumps": [1, 0, 0, 0],
        "null_post_reload_blockage_nodes_and_vectors_including_unshare": [3, 3],
        "null_IRA_allocno_and_object_ID_vector_requests": [98*2, 98*2],
        "null_IRA_regno_allocno_map_request": 98,
        "null_IRA_block_and_root_loop_node_requests": [12, 1],
        "null_LRA_common_register_info_request": 99*3//2+1,
        "null_LRA_constraint_vector_and_bitmap_requests": [27, 27],
        "null_LRA_recognition_pointer_resize_ceiling": max(27*3//2, 27+1),
        "null_LRA_invariant_vector_and_hash_requests": [100, 100],
        "null_LRA_inheritance_usage_array_request": 99,
        "null_LRA_assignment_main_and_preference_array_requests": [99]*5,
        "null_LRA_constraint_and_assignment_iterations": [2, 1],
        "null_post_frame_block_edge_slot_ceilings": [10, 11, 12],
        "null_post_frame_lifetime_label_note_insn_jump_barrier_ceilings": [3, 13+2, 10+3+9, 1, 1],
        "null_post_frame_lifetime_chain_node_ceiling": 26+4+2+1+9,
        "null_post_frame_first_unused_chain_uid_ceiling": 1+26+4+2+1+9,
        "null_post_frame_new_dynamic_pseudos_stack_slots_calls": [1, 0, 0],
        "null_post_frame_machine_register_save_and_local_allocation_bytes": [8, 0],
        "null_post_frame_initial_prologue_epilogue_hash_requests": [17, 17],
        "null_shortening_label_alignment_vector_request": 3+1,
        "null_shortening_UID_indexed_array_requests": [43]*5,
        "null_CFI_trace_count_and_initial_vector_request": [1+3+2, 16],
        "null_CFI_trace_hash_request": 1+3+2,
        "null_CFI_row_and_register_save_vector_ceilings": [1+6+5, 16+1],
        "null_CFI_CIE_function_and_location_advance_object_ceilings": [2, 2+1+2, 5],
        "null_CFI_total_object_ceiling": 2+5+5,
        "null_CFI_FDE_object_CIE_vector_and_FDE_vector_ceilings": [1, 2, 5+5],
        "null_CFI_queued_saves_and_pending_trace_work_ceilings": [1, 1],
        "null_post_CFI_lifetime_chain_node_ceiling": 42+5+5,
        "null_post_CFI_first_unused_chain_uid_ceiling": 1+42+5+5,
        "null_post_CFI_instruction_address_vector_length_ceiling": 43,
        "null_CFI_new_machine_instructions_dynamic_pseudos_local_slots": [0, 0, 0],
        "null_final_location_nop_ceiling": 4+5+9,
        "null_final_blockage_nop_push_move_pop_return_length_ceilings": [0, 1, 2, 3, 2, 1],
        "null_final_shortening_address_ceiling": 18+2+3+2+1,
        "null_final_instruction_scan_visits_and_global_counter_increment_ceiling": 52,
        "null_final_new_instruction_chain_nodes": 0,
        "null_final_FDE_begin_end_label_string_requests": 2,
        "null_final_FDE_label_string_request_bytes_LP64": 2+3+20+1,
        "null_CFI_label_string_request_bytes_nonnegative_int32_counter": 2+4+10+1,
        "ira_init_once_selected_dynamic_allocation_requests": 0,
        "retained_bind_coefficients": bind,
        "main_fixed_framework_push_requests": push["U"] + 2*push["F"],
        "main_fixed_framework_bind_upper_bound": bind["U"] + 2*bind["F"],
        "result_temporary_requests_per_call_upper_bound": call_result_max,
        "loop_lowering_direct_executable_node_requests": 2+2+1,
        "loop_lowering_direct_executable_operand_slots": 2+2+3,
        "loop_lowering_additional_label_declarations": 1,
        "outer_cleanup_eh_Q_upper_bound": 1,
        "outer_cleanup_eh_D_upper_bound": 1,
        "outer_cleanup_eh_may_return": False,
        "inner_cleanup_eh_Q_and_D": 0,
        "clobber_upper_bound": "sum of local VAR_DECL entries in retained BINDs",
        "bind_cleanup_statement_upper_bound": "eligible locals + at most one stack_restore",
        "checked_add_sub_constant_binary_helper_requests": 1+2,
        "checked_multiply_constant_binary_helper_requests": 1+2+2+1,
        "checked_integral_conversion_requests": 1+2+2+2,
        "checked_integral_conversion_binary_helper_requests": 2+1,
        "protect_spine_new_wrapper_nodes": "h1+h3",
        "protect_spine_new_wrapper_operand_slots": "h1+3*h3",
        "protect_spine_terminal_save_expr_requests": 1,
        "call_expression_operand_slots": "n+3",
        "two_actual_overflow_call_operand_slots": 2+3,
        "raise_call_actual_counts": [2, 3, 6],
        "string_copy_requested_bytes_lp64": "stored payload length + 21",
        "call_input_adaptation_requests_per_actual": 1+1+1+1+4,
        "call_compound_helper_requests": "2*P+C",
        "call_assignment_helper_requests": "2*P+2*C",
        "call_component_reference_requests": "P+C",
        "call_unary_helper_requests": "P+2*C",
        "call_direct_statement_append_requests": "3*P+4*C",
        "call_actual_type_resolution_requests": "4*P",
        "ordinary_object_direct_variable_declaration_requests": 4,
        "local_type_backannotation_annotate_value_requests": 2,
        "local_type_backannotation_UI_From_Int_requests": 1,
        "one_dimensional_template_constructor_elements": 2,
        "stabilization_new_nodes": "n1+n2+n3+n4+s",
        "stabilization_new_operand_slots": "n1+2*n2+3*n3+4*n4+s",
        "string_equality_size_binary_requests": 2+2,
        "string_equality_conversion_requests": 3+4+1+2,
        "string_equality_scalar_binary_requests": 2+3+1+2,
        "string_equality_fold_build2_requests": 3+1,
        "ordinary_address_pointer_type_requests": "2*h",
        "ordinary_address_conversion_requests": "2*h",
        "ordinary_address_compound_nodes": "h-1",
        "ordinary_address_terminal_fold_requests": 1,
        "unchecked_scalar_conversion_requests_including_truncation": 1+3,
        "unchecked_integral_tail_binary_requests": 2,
        "secondary_stack_allocation_call_actuals": 2,
        "secondary_stack_allocation_call_operand_slots": 2+3,
        "secondary_stack_allocation_call_size_conversions": 2,
        "secondary_stack_allocator_result_pointer_conversions": 1,
        "diagnostic_preparation_scalar_visits": "3*(D_i+J_i)",
        "diagnostic_preparation_string_or_raise_visits": 0,
        "normalized_signed_type_endpoint_syntax_nodes": 16,
        "signed_type_bound_syntax_visits_per_variable_type": 2*16,
        "String_literal_low_bound_syntax_visits_per_type": 16,
        "Main_value_call_body_copy_requests_in_size_inliner": 0,
        "compiler_generated_size_wrapper_body_copy_requests": "separate layout obligation",
        "variable_Main_lazy_constant_or_renaming_initializers": 0,
        "variable_Main_source_syntax_visits": "O_Main+32*E_Main+3*(D_i+J_i)",
        "variable_Main_source_syntax_visits_cumulative_upper_bound": "A_Main+32*E_Main+3*(D_i+J_i)",
        "unchanged_protected_arithmetic_frontier": "branching arithmetic over recursively invariant leaves; not only a spine",
        "scalar_gimplification_materializations": "N+S+M",
        "scalar_gimplification_INIT_and_raw_assign_requests": "each <= N+S+M",
        "scalar_gimplification_ordinary_copy_nodes": "<= N+S+M",
        "scalar_gimplification_raw_assignment_operand_positions": "<= 3*(N+S+M)",
        "scalar_gimplification_SSA_and_VAR_identities": "each <= N+S+M, counted separately",
        "gimplification_size_position_root_requests": "2*T+2*Ts+3*F+2*Dv+2*Ds",
        "normal_conditional_raw_control_GIMPLE_requests": 1+3+1,
        "normal_conditional_fresh_label_requests": 3,
        "shortcut_context_input": "Cprime=C+V, V<=A",
        "shortcut_normal_control_test_requests": "<= 2*Cprime+A",
        "shortcut_new_COND_EXPR_requests": "<= V+2*A+2*Cprime",
        "shortcut_new_GOTO_EXPR_requests": "<= 5*A+2*Cprime",
        "shortcut_new_LABEL_EXPR_requests": "<= 3*A",
        "shortcut_direct_statement_append_requests": "<= 9*A",
        "conditional_raw_control_GIMPLE_requests": "<= 12*Cprime+13*A",
        "conditional_fresh_control_label_requests": "<= 8*Cprime+8*A",
        "conditional_extra_VAR_requests": "<= Cprime",
        "conditional_extra_assignment_wrappers_and_raw_assignments": "each <= 2*Cprime",
        "conditional_UID_and_context_push_requests": "<= 2*Cprime+2*A",
        "overflow_saved_boundary": "SAVE may be elided for readonly invariant IFN calls",
        "overflow_materialization_input": "I actual call occurrences, retained SAVE children once",
        "overflow_call_materializations_and_INIT_and_raw_GIMPLE": "each <= I",
        "overflow_raw_call_operand_positions": "<= 5*I",
        "overflow_materialization_ordinary_copy_nodes": "sum materialized-call ordinary cut-region weights; not unconditionally linear",
        "nonbuiltin_scalar_call_helper_visits": "<= 3*X",
        "nonbuiltin_scalar_call_actual_visits": "<= 3*P",
        "nonbuiltin_scalar_call_raw_operand_positions": "<= P+3*X",
        "nonbuiltin_scalar_call_unshare_nodes_and_slots": "<= 3*X nodes, P+5*X slots",
        "Main_constructor_bearing_full_entity_conversions": "O+Ts+Ta+Tl+Tp <= E_Main, each entity once",
        "Main_direct_ordinary_object_declaration_requests": "<= 4*O",
        "Main_deferred_dummy_type_and_decl_requests": "<= 2*T type/debug nodes and T TYPE_DECL, T=Ts+Ta+Tl+Tp",
        "reference_stack_pushes": "R=A+C+V actual handled spine occurrences",
        "reference_base_lowering_requests": "<= S actual compound-helper entries",
        "reference_index_and_metadata_lowering_requests": "<= 3*A+C",
        "reference_initial_indirect_fold_requests": "<= R+S+J, J actual alias expansions",
        "reference_metadata_substitution_and_unshare_requests": "each <= 2*A+C",
        "reference_metadata_alignment_constants_and_divisions": "each <= A+C; zero on constant Character-size/fixed-field-offset premises",
        "reference_metadata_ordinary_copy_nodes": "sum actual substituted metadata cut-region weights; pre-lowered local bounds have zero weight",
        "address_gimplifier_operand_addressability_address_helper_conversion_requests": "each <= one per actual invocation",
        "pointer_array_address_canonicalization_nodes_and_slots": [2, 4+1],
        "component_canonicalization_expression_nodes": 0,
        "VLA_declaration_alias_copy_nodes_and_slots": [1, 1],
        "gigi_debug_renaming_alias_copy_nodes_and_slots": [2, 2],
        "plain_String_store_WITH_SIZE_and_size_unshare_requests": "each <= M actual normalized plain stores",
        "plain_String_store_raw_assign_plus_memcpy_statements": "<= M",
        "plain_String_store_raw_statement_operand_slots": "<= 6*M",
        "plain_String_store_address_fold_and_argument_requests": "each <= 2*M",
        "plain_String_store_addressability_preparations": "<= M",
        "plain_String_store_size_copy_nodes": "sum pre-substitution size cut-region weights",
        "scalar_mode_aggregate_equality_view_and_comparison_fold_requests": [2, 1],
        "non_scalar_mode_aggregate_equality_memcmp_call_and_compare_operand_slots": [6, 2],
        "non_scalar_mode_aggregate_equality_address_fold_requests": 2,
        "null_Main_body_direct_expression_nodes": 4+1,
        "null_Main_body_direct_expression_operand_slots": 4+3,
        "null_Main_body_label_declarations": 1,
        "null_Main_body_statement_list_header_requests": "<= 3",
        "null_Main_body_statement_list_link_requests": 4,
        "null_Main_body_binding_requests_including_unit_level": 1+2,
        "null_Main_body_ordinary_unshare_weight": 4,
        "null_Main_body_fresh_unshare_expression_nodes_and_slots": 3*4,
        "null_Main_body_lifetime_expression_nodes_and_operand_slots": [5+3*4, 7+3*4],
        "null_Main_initial_raw_GIMPLE_tuple_count": 4,
        "null_Main_initial_raw_GIMPLE_tuple_bytes_LP64": 64+64+80+72,
        "null_Main_body_symbolic_folder_entries": 0,
        "null_Main_CF_new_GIMPLE_tuples_and_label_declarations": [2, 1],
        "null_Main_CF_flat_statement_count": 2+2+1,
        "null_Main_CF_cumulative_raw_GIMPLE_tuple_bytes_LP64": 280+64+64,
        "null_Main_EH_finally_hash_entries": 2,
        "null_Main_EH_regions_landing_pads_and_rewritten_statements": [0, 0, 0],
        "null_Main_initial_CFG_ordinary_blocks_and_edges": [3, 4],
        "null_Main_CFG_cleanup_new_labels_and_statements": [0, 0],
        "null_Main_SSA_entry_block_edge_statement_upper_bounds": [3, 4, 3],
        "null_Main_SSA_new_MEM_declaration_default_name_and_NOP": [1, 1, 1],
        "null_Main_SSA_new_PHIs_and_nondefault_names": [0, 0],
        "null_Main_SSA_operand_use_entries_and_slab_bytes_LP64": [1, 1024],
        "null_Main_SSA_name_vector_length": 2,
        "scope": "source identities, local event counts and interface only; not transitive gigi allocation or compiler success",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ada", type=Path, required=True)
    parser.add_argument("--gcc-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--record", action="store_true",
                        help="Write the pinned manifest/excerpts/inventory initially")
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    sources, manifest, excerpts, inventory = collect(args.ada, args.gcc_root)
    # Anchor Ada identities against the previously retained full source inventory.
    prior = bundle.parent / "unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json"
    known_ada = {"gcc/ada/"+x["path"]: x for x in json.loads(prior.read_text())["files"]}
    for row in manifest["files"]:
        if row["path"].startswith("gcc/ada/"):
            assert row["sha256"] == known_ada[row["path"]]["sha256"]
    gcc_manifest = json.loads((args.gcc_root / "manifest.json").read_text())
    assert gcc_manifest["commit"] == PIN
    known_gcc = {row["path"]: row for row in gcc_manifest["files"]}
    for row in manifest["files"]:
        if not row["path"].startswith("gcc/ada/"):
            assert row == known_gcc[row["path"]], row["path"]
    check_sources(sources, inventory)
    records = {"source-manifest.json": manifest, "site-inventory.json": inventory}
    if args.record:
        for name, value in records.items():
            (bundle / name).write_text(json.dumps(value, indent=2)+"\n")
        (bundle / "source-excerpts.md").write_text(excerpts)
    else:
        for name, value in records.items():
            assert json.loads((bundle / name).read_text()) == value, name
        assert (bundle / "source-excerpts.md").read_text() == excerpts
    result = {"commit": PIN, "source_files_checked": len(manifest["files"]),
              "silver_main_api_files_checked": len(manifest["silver_main_api_files"]),
              "arithmetic": arithmetic(), "compiler_runs": 0,
              "solver_runs": 0, "lean_builds": 0}
    args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
