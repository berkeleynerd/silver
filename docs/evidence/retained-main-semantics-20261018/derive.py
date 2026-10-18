#!/usr/bin/env python3
"""Check pinned source and reproduce Main node/query/list/auxiliary equations.

No compiler/prover invocation. This does not prove semantic caller coverage,
the equations' soundness, or source-to-installed-tool correspondence.
"""

import argparse
import hashlib
import json
import tarfile
from collections import Counter
from pathlib import Path

PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
RANGES = {
    "alloc.ads": [(118, 119)],
    "atree.adb": [(1131, 1151), (1199, 1238), (1301, 1333), (2109, 2138), (2222, 2276)],
    "checks.adb": [(2234, 2286), (3044, 3080), (3155, 3503), (3509, 3534),
                   (3810, 3920), (3978, 4048), (4620, 4913), (5071, 5654),
                   (6112, 6127), (6283, 6455), (6595, 6620),
                   (8044, 8054), (8118, 8165), (10930, 11190)],
    "cstand.adb": [(916, 937), (1396, 1407)],
    "exp_ch4.adb": [(10217, 10256)],
    "exp_spark.adb": [(120, 204), (601, 766), (772, 881), (896, 946), (1008, 1023),
                      (1138, 1254)],
    "exp_util.adb": [(5873, 6012), (7984, 8450),
                     (10664, 10711), (12619, 12723),
                     (12761, 12824), (13102, 13111)],
    "expander.adb": [(105, 127)],
    "freeze.adb": [(750, 912), (2418, 2491), (2803, 2893), (2974, 2977),
                   (3641, 4276), (4282, 4605), (4748, 5094), (5178, 5204),
                   (6445, 6550), (6803, 6810), (7054, 7067), (7360, 7400),
                   (8143, 8146), (8265, 8285),
                   (10223, 10390), (10402, 10771)],
    "layout.adb": [(72, 82), (225, 664), (900, 1050)],
    "nlists.adb": [(125, 132), (189, 275), (777, 864)],
    "sem.adb": [(107, 116), (634, 640)],
    "sem.ads": [(499, 596)],
    "sem_attr.adb": [(8308, 8405), (9717, 9751), (9898, 9970), (13600, 13618)],
    "sem_ch3.adb": [(4820, 4855), (5138, 5184), (5436, 5453), (6340, 6390),
                    (14339, 14484), (15317, 15500), (15790, 15807), (19121, 19198),
                    (20478, 20761), (22588, 22734), (23676, 23707)],
    "sem_ch5.adb": [(1020, 1035), (3295, 3311), (3430, 3625),
                    (3962, 3979), (4050, 4117), (4523, 4595),
                    (4169, 4171), (4315, 4317), (4868, 4886)],
    "sem_ch4.adb": [(2720, 2780)],
    "sem_ch6.adb": [(3738, 3764), (4217, 4219), (5440, 5623), (7503, 7540), (8934, 8946)],
    "sem_ch8.adb": [(4362, 4400), (7107, 7130), (7656, 7668), (7781, 7805), (9863, 9962)],
    "sem_ch10.adb": [(989, 1042)],
    "sem_ch11.adb": [(388, 465)],
    "sem_eval.adb": [(660, 700), (995, 1769), (1971, 2110), (2342, 2443), (2454, 2532),
                     (3365, 3380), (4052, 4167), (6571, 6584),
                     (3425, 3840), (3914, 3998), (4178, 4343), (4351, 4451),
                     (4589, 4684), (5118, 5222), (5323, 5479), (6090, 6136),
                     (7085, 7158), (7354, 7496)],
    "sem_mech.adb": [(107, 128)],
    "sem_prag.adb": [(26242, 26325), (26500, 26512)],
    "sem_res.adb": [(1462, 1498), (2545, 2551), (4247, 4276), (4861, 4911),
                    (6285, 6448), (7121, 7135), (7337, 7345),
                    (11200, 11214),
                    (11260, 11291), (11668, 11698), (12039, 12322), (12337, 12476),
                    (12729, 12934), (13205, 13337)],
    "sem_elab.adb": [(1032, 1038), (2654, 2672), (3035, 3039), (3069, 3073),
                     (3563, 3776), (3782, 3851), (3913, 3982), (4084, 4102),
                     (5350, 5460), (7651, 7654), (7811, 8061), (8586, 8589),
                     (8943, 9112), (9307, 9360), (9499, 9616),
                     (10196, 10208), (10248, 10390), (10607, 10639),
                     (10874, 10949), (11216, 11220), (11295, 11324),
                     (11427, 11465), (12217, 12248), (13901, 14126),
                     (14185, 14225), (14320, 14358), (14969, 15005)],
    "sem_util.adb": [(8450, 8510), (10821, 10915), (23907, 24033), (29103, 29119)],
    "sem_warn.adb": [(3548, 3650)],
    "sinfo-cn.adb": [(140, 155)],
    "uintp.adb": [(1683, 1696)],
}

RANGES.update({
    "itypes.adb": [(38, 81)],
    "lib-writ.adb": [(1059, 1065), (1618, 1619)],
    "lib-xref.adb": [(67, 158), (188, 267), (956, 1162), (1678, 1840)],
    "lib-xref-spark_specific.adb": [(61, 169), (175, 310), (315, 358)],
    "opt.ads": [(1725, 1730)],
    "sem_type.adb": [(77, 109), (197, 525), (613, 745), (3134, 3142), (3324, 3346)],
    "sem_type.ads": [(65, 77)],
    "sem_aggr.adb": [(747, 748)],
})
RANGES["alloc.ads"] += [(40, 41), (61, 62), (148, 149), (157, 161)]
RANGES["cstand.adb"] += [(306, 415)]
RANGES["sem.adb"] += [(1431, 1491), (1650, 1673)]
RANGES["sem.adb"] += [(912, 950), (1387, 1421)]
RANGES["sem_ch5.adb"] += [(1190, 1220)]
RANGES["sem_ch3.adb"] += [(6033, 6041), (6150, 6178), (23125, 23161)]
RANGES["sem_ch4.adb"] += [(930, 984), (1047, 1110), (1917, 2064),
                          (2073, 2115), (2211, 2230), (6268, 6300),
                          (6546, 6588), (6770, 6881), (7505, 7571),
                          (7580, 7612), (7724, 7754)]
RANGES["sem_ch6.adb"] += [(1555, 1591), (3154, 3195), (4930, 4983),
                          (13380, 13513)]
RANGES["sem_ch8.adb"] += [(6643, 6652), (7705, 7748), (10270, 10324),
                          (10772, 10784), (10861, 10875), (10906, 10918),
                          (11128, 11174)]
RANGES["sem_ch8.adb"] += [(325, 352), (877, 900), (6160, 6238)]
RANGES["sem_res.adb"] += [(3572, 3576), (9148, 9178), (10187, 10215),
                          (10328, 10335)]
RANGES["sem_util.adb"] += [(2774, 2856), (2920, 2954), (5799, 5831),
                           (26130, 26150), (27745, 27783)]
RANGES["sem_util.adb"] += [(24070, 24124), (24322, 24364)]
RANGES["sem_prag.adb"] += [(11945, 12000), (12060, 12101)]
RANGES["sem_warn.adb"] += [(63, 88), (1179, 1201), (1241, 1271),
                           (1450, 1492), (1807, 1860)]
RANGES["sem_warn.adb"] += [(4117, 4246)]
RANGES.update({
    "gnat1drv.adb": [(517, 529)],
    "errout.adb": [(80, 93), (312, 334), (381, 397), (455, 506),
                   (550, 697), (1377, 1525), (1665, 1698)],
    "erroutc.ads": [(125, 135), (184, 377)],
    "erroutc.adb": [(1359, 1367), (1919, 1939), (1982, 2020),
                    (2134, 2156)],
    "scng.adb": [(333, 356)],
    "scn.adb": [(111, 198)],
    "par-load.adb": [(169, 202)],
})
RANGES["sem_ch5.adb"] += [(1066, 1096), (2083, 2092), (2113, 2152),
                          (3480, 3571), (3582, 3645), (4172, 4228),
                          (4318, 4335), (4604, 4820)]
RANGES["sem_ch10.adb"] += [(1108, 1116), (2615, 2635), (2794, 2806),
                           (3249, 3254), (3980, 4117), (4148, 4157)]
RANGES["sem_prag.adb"] += [(28630, 28647), (28781, 28801)]
RANGES["sem_warn.adb"] += [(620, 661), (1272, 1331), (1333, 1376),
                           (1383, 1410), (1570, 1670), (3596, 3647),
                           (3789, 3815), (4436, 4464)]
RANGES["sem_ch8.adb"] += [(10490, 10513), (6992, 7073), (7685, 7771)]
RANGES["sem_res.adb"] += [(9190, 9227), (10980, 11001), (12800, 12934),
                          (4240, 4327), (5197, 5222), (7209, 7224)]
RANGES["sem_util.adb"] += [(4657, 4680), (26235, 26306), (27492, 27525)]
RANGES["lib-xref.adb"] += [(275, 316), (684, 690), (849, 938), (976, 1132)]
RANGES["sem_ch4.adb"] += [(1525, 1533)]
RANGES["sem_ch6.adb"] += [(4198, 4202), (4745, 4748)]

RANGES.update({
    "checks.ads": [(126, 138), (970, 986)],
    "sem_aux.ads": [(56, 62)],
    "sem_warn.ads": [(56, 62)],
    "sem_ch7.adb": [(198, 223), (244, 686)],
    "sem_dim.adb": [(125, 190), (850, 862), (1115, 1124), (1131, 1223),
                    (1377, 1625), (2086, 2164), (2202, 2278), (2367, 2405),
                    (2461, 2480), (2507, 2521), (2665, 2668),
                    (3583, 3592), (3623, 3633), (3677, 3683), (3722, 3751)],
    "sem_ch13.adb": [(396, 451), (6987, 7003), (7028, 7046),
                     (14171, 14313), (16638, 16647), (19821, 19831)],
    "exp_ch3.adb": [(7447, 7458)],
    "exp_ch13.adb": [(425, 441)],
})
RANGES["alloc.ads"] += [(106, 107), (151, 152)]
RANGES["checks.adb"] += [(145, 197), (579, 750), (796, 867), (4921, 4973),
                         (6432, 6454), (6599, 6620), (6687, 6705),
                         (7118, 7138), (8106, 8110), (10215, 10222),
                         (10304, 10387)]
RANGES["exp_util.adb"] += [(7610, 7631)]
RANGES["sem_ch3.adb"] += [(4354, 4402), (5374, 5387)]
RANGES["sem_ch5.adb"] += [(2010, 2081), (4278, 4294), (4523, 4598)]
RANGES["sem_ch11.adb"] += [(388, 445)]
RANGES["sem_util.adb"] += [(10598, 10662), (23173, 23282), (23612, 23711),
                           (29275, 29362)]
RANGES["sem_res.adb"] += [(725, 767)]
RANGES["freeze.adb"] += [(9573, 9614), (10147, 10165)]
RANGES["sem_prag.adb"] += [(142, 148), (282, 288), (509, 515),
                           (2190, 2201), (2221, 2232), (3506, 3515),
                           (6866, 6874), (15732, 15738), (22890, 22905),
                           (26430, 26530), (28928, 28942),
                           (29405, 29415), (30467, 30485), (33452, 33780),
                           (34516, 34583), (36002, 36008)]

RANGES.update({
    "sem_ch2.adb": [(55, 68)],
    "sem_aux.adb": [(147, 166)],
    "snames.ads-tmpl": [(1222, 1245)],
    "sem_ch12.adb": [(999, 1042), (1075, 1128), (11220, 11234),
                     (18695, 18709), (18719, 18731)],
    "sem_ch9.ads": [(71, 90)],
    "sem_ch9.adb": [(608, 620), (694, 703)],
    "sem_elim.adb": [(110, 117), (202, 250), (812, 820), (1000, 1016)],
    "uintp.ads": [(469, 487)],
    "sem_case.adb": [(1971, 1988), (2440, 2465), (2601, 2622), (3377, 3390)],
})
RANGES["sem_eval.adb"] += [(112, 136), (1812, 1884), (2000, 2022),
                           (2948, 3028), (5314, 5317), (6143, 6153)]
RANGES["checks.adb"] += [(5049, 5069), (5625, 5629), (8102, 8104),
                         (3690, 3702), (11468, 11488)]
RANGES["sem_util.adb"] += [(87, 100), (288, 301), (6314, 6319),
                           (11532, 11854), (15295, 15360), (18383, 18396),
                           (18498, 18519), (24443, 24471), (29450, 29485)]
RANGES["exp_util.adb"] += [(106, 117), (1945, 1947), (3325, 3328),
                           (7756, 7779), (11159, 11183), (11328, 11332),
                           (11748, 11775)]
RANGES["sem_ch3.adb"] += [(15099, 15115)]
RANGES["sem_ch4.adb"] += [(10528, 10554)]
RANGES["sem_ch6.adb"] += [(3894, 3920), (8737, 8790)]
RANGES["sem_ch8.adb"] += [(4587, 4617)]
RANGES["sem_res.adb"] += [(7740, 7749)]
RANGES["sem_attr.adb"] += [(9333, 9345)]
RANGES["sem_ch13.adb"] += [(19035, 19049), (19151, 19165)]
RANGES["sem_elab.adb"] += [(16065, 16149)]
RANGES["freeze.adb"] += [(3310, 3317)]

SPARK = {
    "src/why/back_end.adb": (
        "a366cc199ce5c10ba35a7ddcfa0faf04d714deb6f53bc18903f087a845bc8775",
        [(156, 187), (199, 208)]),
    "src/gnatprove/gnatprove.adb": (
        "80becb96eeb45a6ef4cc096d1c8896c5cf53cf6f59a635483f3ced3447731590",
        [(297, 310)]),
    "src/gnatprove/configuration.adb": (
        "8ebece58c5f04d0a1cd16db5945a0acb432419235fc1564cd683e162e12f1697",
        [(2802, 2818)]),
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=Path(__file__).parent)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[3]
    prior = repo / ("docs/evidence/unbounded-programs/continuation-20261017/"
                    "frontend-lifetimes/complete-source-manifest.json")
    manifest = json.loads(prior.read_text())
    assert manifest["commit"] == PIN
    expected = {item["path"]: item for item in manifest["files"]}
    records = []
    for name, ranges in RANGES.items():
        data = (args.source / name).read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        assert digest == expected[name]["sha256"], name
        assert len(data) == expected[name]["bytes"], name
        # Compiler source references use LF line numbers; form feeds are not
        # line separators (str.splitlines would also split those).
        lines = data.decode().split('\n')
        for first, last in ranges:
            assert 1 <= first <= last <= len(lines), (name, first, last)
        records.append({"path": name, "bytes": len(data), "sha256": digest,
                        "cited_ranges": ranges})

    spark_archive = repo / (
        "docs/evidence/unbounded-programs/frontend-representation-20261017/"
        "toolchain/raw-evidence.tar.gz")
    spark_records = []
    with tarfile.open(spark_archive) as archive:
        for name, (expected_digest, ranges) in SPARK.items():
            data = archive.extractfile("spark-source/" + name).read()
            digest = hashlib.sha256(data).hexdigest()
            assert digest == expected_digest, name
            lines = data.decode().split('\n')
            for first, last in ranges:
                assert 1 <= first <= last <= len(lines), (name, first, last)
            spark_records.append({"path": name, "bytes": len(data),
                                  "sha256": digest, "cited_ranges": ranges})
    silver_inputs = []
    for name in ("src/silver.adb", "src/silver_io.ads", "src/silver_arguments.ads"):
        data = (repo / name).read_bytes()
        silver_inputs.append({"path": name, "bytes": len(data),
                              "sha256": hashlib.sha256(data).hexdigest()})

    folds = Counter(O=1, P=1, O_loop=2, F=3, R=1, D_lit=3, U=2, H_len=3)
    direct = Counter(B_loop=4, F=28, R=2, D_lit=13, D_alias=4, G=5,
                     D_copy=2, U=3, H_len=4, V0=1)
    expanded = direct.copy()
    expanded.update({key: 2 * value for key, value in folds.items()})
    assert dict(expanded) == {
        "B_loop": 4, "F": 34, "R": 4, "D_lit": 19, "D_alias": 4,
        "G": 5, "D_copy": 2, "U": 7, "H_len": 10, "V0": 1,
        "O": 2, "P": 2, "O_loop": 4,
    }
    assert 7 + 3 + 1 + 2 == 13  # literal-range + subtype + Rewrite + Find_Type
    assert (1 + 5) - (1 + 2) == 3  # semantic loop entities beyond parser
    generated_entities = Counter(R=1, D_s=2, F=3, K_literal=1)
    main_entities = Counter(one=1, D=1, R=1, D_s=2, F=5, K_literal=1)
    main = Counter(A_parse=1, F=1, C_lib=1, N_ref=1)
    main.update(generated_entities)
    main.update(expanded)
    main.update(main_entities)  # ordinary freeze nodes, not repeated entities
    simple = main.copy()
    simple["F"] += 2 * simple.pop("G")
    literal = simple.pop("D_lit")
    alias = simple.pop("D_alias")
    assert literal >= alias
    simple["D_s"] += literal + simple.pop("D_copy")
    k_literal = simple.pop("K_literal")
    simple.update(S=k_literal, A=3*k_literal, P=5*k_literal)
    assert dict(simple) == {
        "A_parse": 1, "F": 53, "C_lib": 1, "N_ref": 1, "R": 6,
        "D_s": 25, "B_loop": 4, "U": 7, "H_len": 10, "V0": 1,
        "O": 2, "P": 12, "O_loop": 4, "one": 1, "D": 1, "S": 2, "A": 6,
    }
    arithmetic = Counter(O=1, O_loop=2, F=3, R=1, D_lit=3)
    scalar_checks = Counter(D=1, G=1, N_assign=1, H_len=1)
    range_compares = Counter(F=6, R=3, D_lit=3)
    range_queries = Counter({key: 2*value for key, value in arithmetic.items()})
    range_queries.update(scalar_checks)
    comparisons = Counter(O=2, U=2, D=2, G=2, H_len=3)
    comparisons.update(range_compares)
    comparisons.update({key: 2*value for key, value in scalar_checks.items()})
    query_syntactic = {}
    for name, equation in (("Q_R", range_queries), ("Q_C", comparisons)):
        equation = equation.copy()
        equation["F"] += 2*equation.pop("G")
        equation["D_s"] = equation.pop("D_lit")
        query_syntactic[name] = dict(sorted(equation.items()))
    assert query_syntactic["Q_R"] == dict(sorted(dict(
        O=2, O_loop=4, F=8, R=2, D_s=6, D=1, N_assign=1, H_len=1).items()))
    assert query_syntactic["Q_C"] == dict(sorted(dict(
        O=2, U=2, F=14, R=3, D_s=3, D=4, N_assign=2, H_len=5).items()))
    evaluator = Counter({key: 2*value for key, value in arithmetic.items()})
    evaluator.update(O=6, U=6, H_len=4)
    literal_resolutions = Counter(S=1, A=1, P=3)
    literal_subtypes = Counter(S=1, A=3, P=5)
    literal_uint = Counter({key: 4*value for key, value in literal_resolutions.items()})
    literal_uint.update(literal_subtypes)
    assert literal_uint == Counter(S=5, A=7, P=17)
    semantic_lists = main_entities.copy()
    semantic_lists.update(R=1, D_lit=2, D_alias=1, G=1, C_lib=1, N_ref=1)
    semantic_lists_simple = semantic_lists.copy()
    semantic_lists_simple["F"] += 2*semantic_lists_simple.pop("G")
    assert semantic_lists_simple["D_lit"] >= semantic_lists_simple["D_alias"]
    semantic_lists_simple["D_s"] += semantic_lists_simple.pop("D_lit")
    semantic_lists_simple.pop("D_alias")
    assert semantic_lists_simple == Counter(one=1, D=1, R=2, D_s=4, F=7,
                                             K_literal=1, C_lib=1, N_ref=1)
    semantic_growth = folds.copy()
    semantic_growth.update(D_lit=1, D_alias=1, D_copy=1, G=1, U=1,
                           H_len=1, V0=1, C_lib=2, S=1, P=2)
    growth_simple = semantic_growth.copy()
    growth_simple["F"] += 2*growth_simple.pop("G")
    assert growth_simple["D_lit"] >= growth_simple["D_alias"]
    growth_simple["D_s"] = growth_simple.pop("D_lit") + growth_simple.pop("D_copy")
    growth_simple.pop("D_alias")
    assert growth_simple == Counter(O=1, P=3, O_loop=2, F=5, R=1, D_s=5,
                                    U=3, H_len=4, V0=1, C_lib=2, S=1)
    # The entity demand pays both scanner-name promotions and fresh entities.
    entity_slot_events = generated_entities.copy()
    entity_slot_events.update(D=1, F=2, one=1)
    assert entity_slot_events == main_entities
    diagnostic_templates = {
        "sem_ch5.adb": [
            "??loop range is null, loop will not execute",
            "??loop range may be null, loop may not execute",
            "??can only execute if invalid values are present",
            "??loop range may be null",
            "\\??bounds may be wrong way round",
        ],
        "sem_ch10.adb": ["license of withed unit & may be inconsistent??"],
    }
    for name, templates in diagnostic_templates.items():
        source = (args.source / name).read_text()
        for template in templates:
            assert '"' + template + '"' in source, (name, template)
            assert len(template) <= 64, (name, template)
    xref_kinds = "rmswblte"
    assert len(set(xref_kinds)) == 8
    assert 2 * len(xref_kinds) == 16
    xref_illustration = {
        "n": 4096, "N_word": 1024, "E_X": 5000,
        "old_ordinary_entries": 512*(4096+1)*5000,
        "refined_ordinary_entries": 16*(1024+1),
        "definition_orphan_entries": 2*5000,
        "scope": "Illustrative parameters, not a measured program or threshold",
    }
    assert xref_illustration["old_ordinary_entries"] == 10_488_320_000
    assert xref_illustration["refined_ordinary_entries"] == 16_400
    checks_source = (args.source / "checks.adb").read_text()
    assert "Saved_Checks : array (Int range 1 .. 200) of Saved_Check;" in checks_source
    assert "Saved_Checks_Stack : array (Int range 1 .. 100) of Nat;" in checks_source
    begin = checks_source.index("   procedure Conditional_Statements_Begin is")
    body = checks_source[begin:checks_source.index("end Conditional_Statements_Begin;", begin)]
    assert body.index("Saved_Checks_TOS := Saved_Checks_TOS + 1;") < body.index(
        "if Saved_Checks_TOS > Saved_Checks_Stack'Last then")
    dim_source = (args.source / "sem_dim.adb").read_text()
    assert "Table_Initial        => 5," in dim_source
    assert "Table_Increment      => 5," in dim_source
    assert "type Dimension_Table_Range is range 0 .. 510;" in dim_source
    assert "type Symbol_Table_Range is range 0 .. 510;" in dim_source
    additional_zero_tables = {
        "Obsolescent_Warnings": {"initial": 50, "growth_percent": 200},
        "Assertion_Levels": {"initial": 30, "growth_percent": 200},
        "Externals": {"initial": 100, "growth_percent": 100, "low_bound": 0},
        "Compile_Time_Warnings_Errors": {"initial": 50, "growth_percent": 200},
        "Check_Names": {"initial": 30, "growth_percent": 200,
                         "fixed_predefined_appends": "Predefined_Check_Id range"},
        "Warnings_Off_Pragmas": {"initial": 500, "growth_percent": 100},
        "Unchecked_Conversions": {"initial": 50, "growth_percent": 200},
        "Address_Clause_Checks": {"initial": 20, "growth_percent": 200},
        "Alignment_Warnings": {"initial": 10, "growth_percent": 200, "low_bound": 0},
        "Subprogram_Table": {"hash_headers": 4093},
        "Traversed_Table": {"hash_headers": 4093},
    }
    sem_eval_source = (args.source / "sem_eval.adb").read_text()
    assert "CV_Bits : constant := 5;" in sem_eval_source
    assert "subtype CV_Range is Nat range 0 .. CV_Cache_Size;" in sem_eval_source
    cv_records = 2**5 + 1
    assert cv_records == 33
    assert "Cache_Size : constant := 2 ** 10;" in checks_source
    assert "type Cache_Index is range 0 .. Cache_Size - 1;" in checks_source
    query_cache_entries = 2**10
    assert query_cache_entries == 1024
    for suffix in ("N", "O", "V", "Lo", "Hi", "Lo_R", "Hi_R"):
        assert "Determine_Range_Cache_" + suffix in checks_source
    assert 500_000 <= (32768-1)**2  # OK_Bits threshold is directly represented
    result = {
        "source_commit": PIN,
        "verified_against": str(prior.relative_to(repo)),
        "scope": "Pinned-source identity and node/query/list-equation arithmetic only",
        "files": records,
        "spark_inspected_commit": "42554fc241fcd1fdf08d3a2feccb3f86912acbc0",
        "spark_source_archive": str(spark_archive.relative_to(repo)),
        "spark_files": spark_records,
        "silver_inputs": silver_inputs,
        "equations": {
            "T_fold_coefficients": dict(sorted(folds.items())),
            "A_struct_direct_coefficients": dict(sorted(direct.items())),
            "A_struct_expanded_coefficients": dict(sorted(expanded.items())),
            "L_struct_coefficients": {"R": 1, "D_lit": 2, "D_alias": 1, "G": 1},
            "E_generated": "<= R + 2*D_s + 3*F + K_literal",
            "E_Main_coefficients": dict(sorted(main_entities.items())),
            "A_Main_decomposition":
                "<= A_parse + F + E_generated + A_struct + E_Main + C_lib + N_ref",
            "A_Main_expanded_coefficients": dict(sorted(main.items())),
            "A_Main_syntactic_coefficients": dict(sorted(simple.items())),
            "syntactic_substitutions": [
                "G <= 2*F", "D_lit+D_alias <= D_s", "D_copy <= D_s",
                "K_literal <= S+3*A+5*P",
            ],
            "query_and_shell_additional_syntax": 0,
            "syntax_zero_scope": "Manual grammar/type/phase caller argument in derivation",
            "T_ar_coefficients": dict(sorted(arithmetic.items())),
            "T_check_coefficients": dict(sorted(scalar_checks.items())),
            "Q_range_coefficients": dict(sorted(range_compares.items())),
            "Q_R_coefficients": dict(sorted(range_queries.items())),
            "Q_C_coefficients": dict(sorted(comparisons.items())),
            "query_syntactic_coefficients": query_syntactic,
            "A_q": "3*(A_Main+1)",
            "query_Uint_appends": "6*A_q*Q_R + (80*A_q+60)*Q_C",
            "query_digit_words": "k*(6*A_q*Q_R + (80*A_q+60)*Q_C)",
            "query_k": "ceil(((b+2)*A_q+2)/15), b=max(32, target_longest_integer_bits)",
            "query_max_local_digit_vector_words": "5*k+3",
            "discrete_size_calls": "<= 2*R+2*D_lit+F",
            "discrete_size_Uint_appends": "<= 95*(2*R+2*D_lit+F)",
            "U_eval_coefficients": dict(sorted(evaluator.items())),
            "evaluator_digit_words": "<= 3*U_eval",
            "literal_resolution_coefficients": dict(sorted(literal_resolutions.items())),
            "literal_Uint_coefficients": dict(sorted(literal_uint.items())),
            "literal_digit_words": "<= 3*U_literal",
            "freeze_size_Uint_appends": "<= 4*(D_lit+D_alias)+K_literal <= 4*D_s+K_literal",
            "freeze_size_digit_words": "<= 3*U_freeze_size",
            "other_ordinary_layout_table_backed_Uint_appends": 0,
            "ordinary_layout_zero_scope": "Main shapes, successful legality, byte storage target; size helper separate",
            "Main_loop_scope_depth": 1,
            "closed_Uint_subtotal": "U_query+U_discrete_size+U_eval+U_literal+U_freeze_size",
            "L_sem_coefficients": dict(sorted(semantic_lists.items())),
            "L_sem_syntactic_coefficients": dict(sorted(semantic_lists_simple.items())),
            "G_sem_coefficients": dict(sorted(semantic_growth.items())),
            "G_sem_syntactic_coefficients": dict(sorted(growth_simple.items())),
            "dynamic_slots_Main": "<= 9*(A_Main+C_lib+P+G_sem)+61*E_Main",
            "dynamic_slots_scope": "Lifetime dynamic slot demand; backing growth/header arrays separate",
            "semantic_scope_peak": "<= incoming_live_entries+2+d_loop",
            "semantic_scope_backing": {"low_bound": 0, "initial": 10, "increment_percent": 200},
            "elaboration_Main_additions": {
                "Scenario_Reps": "<= C_lib",
                "Node_To_Scenario_Map": "<= C_lib",
                "Target_Reps": "<= 5",
                "Entity_To_Target_Map": "<= 5",
                "Active_Scenario_Stack_extra_peak": 1,
                "Declaration_Scenarios": "<= C_lib",
                "other_scenario_sets": 0,
                "body_nested_scenario_map_lists": 0,
                "early_call_region_map": 0,
                "invocation_saved_constructs_relations": 0,
                "unit_attributes_map_table": 0,
            },
            "elaboration_container_Create_arguments": {
                "Nested_Scenarios_Map": 250, "Traversed_Bodies_Set": 250,
                "Early_Call_Regions_Map": 100, "Unit_To_Attributes_Map": 250,
                "Entity_To_Target_Map": 500, "Node_To_Scenario_Map": 500,
                "Saved_Constructs_Set": 100, "Saved_Relations_Set": 200,
                "Declaration_Scenarios": 1000, "Dynamic_ABE_Check_Scenarios": 500,
                "Library_Body_Scenarios": 1000, "Library_Spec_Scenarios": 1000,
                "SPARK_Scenarios": 100,
            },
            "elaboration_scope": "Main caller/entry counts; exact hash/set backing and target layouts separate",
            "All_Interp_Main_entries": "<= 4*A + 3*N_word",
            "Interp_Map_Main_bindings": "<= A + 2*N_word",
            "overload_backing": {"All_Interp_initial": 1000,
                                 "All_Interp_increment_percent": 100,
                                 "Interp_Map_fixed_headers": 3079},
            "deferred_warning_Main_appends": {"Unreferenced_Entities": "<= D",
                                               "In_Out_Warnings": 0},
            "deferred_warning_backing": {"Unreferenced_Entities_initial": 1000,
                                          "In_Out_Warnings_initial": 100,
                                          "increment_percent": 100},
            "producer_warning_modes": {"native_data_representation": "Suppress",
                                        "gnat2why_ALI": "Suppress",
                                        "gnat2why_translation_output": "Normal",
                                        "gnat2why_translation_null": "Treat_As_Error"},
            "producer_xref_modes": {"native_data_representation": "disabled",
                                     "gnat2why_ALI": "enabled, output enabled",
                                     "gnat2why_translation": "enabled, output disabled"},
            "GNATprove_warning_flags": {
                "enabled": ["Elab_Warnings", "Warn_On_Suspicious_Contract"],
                "preserved": ["Warning_Doc_Switch"],
                "others": False,
                "pragma_string_switch_changes": "ignored in GNATprove mode",
            },
            "Main_frontend_diagnostics": {
                "attempts": "J_diag <= 2*F+N_with",
                "Non_Instance_Msgs_appends": "<= J_diag",
                "Errors_appends": "<= J_diag",
                "Locations_appends": "<= J_diag",
                "Edits_Fixes_labels": 0,
                "raw_history_characters": "<= 64*J_diag",
                "M_diag": "1024+2*Int(Column_Number'Last)",
                "formatted_text_lifetime_characters": "<= (2*M_diag+2)*J_diag",
                "diagnostic_string_requests": "<= 2*J_diag",
                "continuation_local_vector_characters": "<= 2*M_diag+2",
                "Warnings_Specific_Warnings_Warnings_As_Errors_additions": 0,
                "Uint_work_beyond_counted_loop_comparisons": 0,
                "raw_templates": diagnostic_templates,
                "scope": "Frontend attempts/storage; producer diagnostics and output consumers separate",
            },
            "diagnostic_backing": {
                "Non_Instance_Msgs_initial": 100,
                "Non_Instance_Msgs_increment_percent": 100,
                "Errors_Locations_Edits_Fixes_each_initial": 200,
                "Errors_Locations_Edits_Fixes_increment_percent": 200,
            },
            "Xrefs_demand_interface": "<= X_fixed + 512*(n+1)*E_X + 2*E_X + 1",
            "Xrefs_demand_scope": "E_X=E_fixed+E_Main; fixed caller closure still required",
            "Xrefs_Main_source_binding_pairs": "<= N_word+1",
            "Xrefs_Main_reference_kinds": list(xref_kinds),
            "Xrefs_refined_demand_interface": "<= X_fixed+16*(N_word+1)+2*E_X+1",
            "Xrefs_refinement_illustration": xref_illustration,
            "Xrefs_backing": {"initial": 5000, "increment_percent": 300,
                               "fixed_hash_headers": 65536},
            "Drefs_Main_additions": 0,
            "Drefs_backing": {"initial": 5, "increment_percent": 1000},
            "ALI_xref_sort_vector_words": "Xrefs.Last+1 Nat words",
            "unit_boundary_elist_headers": "<= K_sem+1",
            "unit_boundary_elist_elements": "<= K_sem*(E_X+1)",
            "additional_zero_Main_contributions": [
                "Urefs", "NCT_New_Entities", "NCT_Pending_Itypes",
                "Suppress_Stack_Entry records", "Warn_On_Suspicious_Index Uint work",
            ],
            "additional_fixed_backing": {"Urefs_initial": 10,
                                          "Urefs_increment_percent": 100,
                                          "NCT_each_hash_headers": 511},
            "saved_checks": {
                "Main_records": 0,
                "fixed_Saved_Check_records": 200,
                "fixed_stack_Nat_words": 100,
                "Main_active_Analyze_Statements": "<= 1+d_stmt",
                "TOS_peak": "<= T_fixed+1+d_stmt",
                "TOS_scope": "T_fixed includes simultaneously active non-Main statement analyses",
                "counter_requirement": "peak <= Nat'Last; 100 is not a nesting limit",
                "Find_Check_Uint_Main": 0,
            },
            "dimension_Main": {
                "System_Table_appends": 0,
                "Dimension_Table_bindings": 0,
                "Symbol_Table_bindings": 0,
                "rational_or_Uint_work": 0,
                "diagnostics_and_symbol_strings": 0,
                "invariant": "Null_Dimension and no system for Main expressions/entities/types",
            },
            "dimension_fixed_backing": {
                "System_Table_initial": 5, "System_Table_growth_percent": 5,
                "Dimension_Table_hash_headers": 511, "Symbol_Table_hash_headers": 511,
            },
            "additional_semantic_zero_Main_tables": additional_zero_tables,
            "additional_numeric_zero_routes": [
                "Get_Current_Value_Condition in GNATprove mode",
                "Find_Check with optimization level zero",
                "Apply_Arithmetic_Overflow_Check: native expansion callers only",
                "Selected_Length_Checks with Expander_Active false",
                "Count_Tasks: no Main task-containing object",
                "Matching_Static_Array_Bounds: no caller in pinned Ada source",
                "Number_Of_Elements_In_Array: native exp_ch3 caller only",
                "Get_Enum_Lit_From_Pos Boolean arithmetic: direct/read-only values",
                "Statically_Names_Object: no Main indexed-component branch",
                "Needs_Secondary_Stack mutable-discriminant size test",
                "Dimension arithmetic under null-dimension invariant",
            ],
            "Main_semantic_numeric_transfer": {
                "Uint_appends": "<= U_query+U_discrete_size+U_eval+U_literal+U_freeze_size",
                "digit_words": "<= k*U_query+285*T_size+3*(U_eval+U_literal+U_freeze_size)",
                "Ureal_appends": 0,
                "scope": "Manual reached-caller partition; excludes scanner, fixed dependencies, producer/native phases",
            },
            "fixed_numeric_caches": {
                "CV_Cache_records": cv_records,
                "CV_Cache_record_fields": ["Node_Id'Base", "Uint"],
                "Determine_Range_array_entries_each": query_cache_entries,
                "Determine_Range_array_counts": {"Node_Id": 2, "Boolean": 1, "Uint": 2, "Ureal": 2},
                "Main_per_query_cache_record_allocation": 0,
                "invalid_scalar_arrays": {"Entity_Id": 14, "Ureal": 4, "Uint": 10},
                "scope": "Typed fixed storage, not target bytes; no cache-hit credit used",
            },
            "core_semantic_elist_completion": {
                "additional_Main_headers_beyond_unit_boundary": 0,
                "additional_Main_elements_beyond_unit_boundary": 0,
                "scope": "Inspected semantic/light pipeline; fixed dependency, driver/loader and producer lists separate",
            },
            "last_named_semantic_table_zero_Main": {
                "Type_Map": {"hash_headers": 511},
                "Generic_Renamings": {"initial": 10, "growth_percent": 100, "low_bound": 0},
                "Generic_Renamings_HTable": {"hash_headers": 37},
                "Instance_Envs": {"initial": 32, "growth_percent": 100, "low_bound": 0},
                "Generic_Flags": {"initial": 32, "growth_percent": 200, "low_bound": 0},
                "Lock_Free_Subprogram_Table": {"initial": 5, "growth_percent": 5},
                "legacy_Elab_Call": {"initial": 50, "growth_percent": 100},
                "legacy_Elab_Visited": {"initial": 200, "growth_percent": 100},
                "legacy_Delay_Check": {"initial": 1000, "growth_percent": 100},
                "local_Sem_Case_tables_sets_links": {"Main_activations": 0},
                "Elim_Hash_Table": {"hash_headers": 1024, "premise": "no active Eliminate configuration"},
                "Elim_Entities": {"initial": 50, "growth_percent": 200,
                                   "premise": "no active Eliminate configuration"},
            },
            "query_scope": "Root counts exclude helper-internal recursion already paid by transfer",
        },
        "remaining": [
            "Compose Main semantic numeric transfer with scanner/fixed and later producer/native terms",
            "Producer/fixed dependency diagnostics and output-format consumers",
            "Frontend driver/runtime loader auxiliaries outside the core semantic partition",
            "Fixed dependency internal lists and actual traversal stack storage",
            "Fixed inputs to overload/xref and unit-boundary element-list transfer",
            "Complete table/growth, numeric, name and auxiliary-resource connection",
            "Fixed dependency contributions and source-to-installed-tool relation",
        ],
        "not_run": ["compiler", "GNATprove", "Lean", "full test suite"],
    }
    args.output.mkdir(parents=True, exist_ok=True)
    target = args.output / "result.json"
    target.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(records)} GCC and {len(spark_records)} SPARK inputs and Main equations")
    print(f"result.json sha256 {hashlib.sha256(target.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    main()
