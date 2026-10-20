/******************************************************************************
 * Top contributors (to current version):
 *   Aina Niemetz, Andres Noetzli, Andrew Reynolds
 *
 * This file is part of the cvc5 project.
 *
 * Copyright (c) 2009-2025 by the authors listed in the file AUTHORS
 * in the top-level source directory and their institutional affiliations.
 * All rights reserved.  See the file COPYING in the top-level source
 * directory for licensing information.
 * ****************************************************************************
 *
 * [[ Add one-line brief description here ]]
 *
 * [[ Add lengthier description here ]]
 * \todo document this file
 */

#include <sstream>

#include "expr/kind.h"
#include "printer/printer.h"

namespace cvc5::internal {
namespace kind {

const char* toString(cvc5::internal::Kind k)
{
  using namespace cvc5::internal::kind;

  switch (k)
  {
    /* special cases */
    case Kind::UNDEFINED_KIND: return "UNDEFINED_KIND";
    case Kind::NULL_EXPR:
      return "NULL";
      // clang-format off
        /* from builtin */
    case Kind::SORT_TYPE: return "SORT_TYPE";
    case Kind::INSTANTIATED_SORT_TYPE: return "INSTANTIATED_SORT_TYPE";
    case Kind::UNINTERPRETED_SORT_VALUE: return "UNINTERPRETED_SORT_VALUE";
    case Kind::BUILTIN: return "BUILTIN";
    case Kind::EQUAL: return "EQUAL";
    case Kind::VARIABLE: return "VARIABLE";
    case Kind::BOUND_VARIABLE: return "BOUND_VARIABLE";
    case Kind::SKOLEM: return "SKOLEM";
    case Kind::DUMMY_SKOLEM: return "DUMMY_SKOLEM";
    case Kind::SEXPR: return "SEXPR";
    case Kind::WITNESS: return "WITNESS";
    case Kind::TYPE_CONSTANT: return "TYPE_CONSTANT";
    case Kind::RAW_SYMBOL: return "RAW_SYMBOL";
    case Kind::ABSTRACT_TYPE: return "ABSTRACT_TYPE";
    case Kind::APPLY_INDEXED_SYMBOLIC_OP: return "APPLY_INDEXED_SYMBOLIC_OP";
    case Kind::APPLY_INDEXED_SYMBOLIC: return "APPLY_INDEXED_SYMBOLIC";
    case Kind::SORT_TO_TERM: return "SORT_TO_TERM";
    case Kind::TYPE_OF: return "TYPE_OF";

    /* from booleans */
    case Kind::CONST_BOOLEAN: return "CONST_BOOLEAN";
    case Kind::NOT: return "NOT";
    case Kind::AND: return "AND";
    case Kind::IMPLIES: return "IMPLIES";
    case Kind::OR: return "OR";
    case Kind::XOR: return "XOR";
    case Kind::ITE: return "ITE";

    /* from uf */
    case Kind::APPLY_UF: return "APPLY_UF";
    case Kind::FUNCTION_TYPE: return "FUNCTION_TYPE";
    case Kind::LAMBDA: return "LAMBDA";
    case Kind::HO_APPLY: return "HO_APPLY";
    case Kind::CARDINALITY_CONSTRAINT_OP: return "CARDINALITY_CONSTRAINT_OP";
    case Kind::CARDINALITY_CONSTRAINT: return "CARDINALITY_CONSTRAINT";
    case Kind::COMBINED_CARDINALITY_CONSTRAINT_OP: return "COMBINED_CARDINALITY_CONSTRAINT_OP";
    case Kind::COMBINED_CARDINALITY_CONSTRAINT: return "COMBINED_CARDINALITY_CONSTRAINT";
    case Kind::FUNCTION_ARRAY_CONST: return "FUNCTION_ARRAY_CONST";
    case Kind::BITVECTOR_UBV_TO_INT: return "BITVECTOR_UBV_TO_INT";
    case Kind::BITVECTOR_SBV_TO_INT: return "BITVECTOR_SBV_TO_INT";
    case Kind::INT_TO_BITVECTOR_OP: return "INT_TO_BITVECTOR_OP";
    case Kind::INT_TO_BITVECTOR: return "INT_TO_BITVECTOR";
    case Kind::DISTINCT: return "DISTINCT";

    /* from arith */
    case Kind::ADD: return "ADD";
    case Kind::MULT: return "MULT";
    case Kind::NONLINEAR_MULT: return "NONLINEAR_MULT";
    case Kind::SUB: return "SUB";
    case Kind::NEG: return "NEG";
    case Kind::DIVISION: return "DIVISION";
    case Kind::DIVISION_TOTAL: return "DIVISION_TOTAL";
    case Kind::INTS_DIVISION: return "INTS_DIVISION";
    case Kind::INTS_DIVISION_TOTAL: return "INTS_DIVISION_TOTAL";
    case Kind::INTS_MODULUS: return "INTS_MODULUS";
    case Kind::INTS_MODULUS_TOTAL: return "INTS_MODULUS_TOTAL";
    case Kind::ABS: return "ABS";
    case Kind::DIVISIBLE: return "DIVISIBLE";
    case Kind::POW: return "POW";
    case Kind::POW2: return "POW2";
    case Kind::INTS_ISPOW2: return "INTS_ISPOW2";
    case Kind::INTS_LOG2: return "INTS_LOG2";
    case Kind::EXPONENTIAL: return "EXPONENTIAL";
    case Kind::SINE: return "SINE";
    case Kind::COSINE: return "COSINE";
    case Kind::TANGENT: return "TANGENT";
    case Kind::COSECANT: return "COSECANT";
    case Kind::SECANT: return "SECANT";
    case Kind::COTANGENT: return "COTANGENT";
    case Kind::ARCSINE: return "ARCSINE";
    case Kind::ARCCOSINE: return "ARCCOSINE";
    case Kind::ARCTANGENT: return "ARCTANGENT";
    case Kind::ARCCOSECANT: return "ARCCOSECANT";
    case Kind::ARCSECANT: return "ARCSECANT";
    case Kind::ARCCOTANGENT: return "ARCCOTANGENT";
    case Kind::SQRT: return "SQRT";
    case Kind::DIVISIBLE_OP: return "DIVISIBLE_OP";
    case Kind::CONST_RATIONAL: return "CONST_RATIONAL";
    case Kind::CONST_INTEGER: return "CONST_INTEGER";
    case Kind::REAL_ALGEBRAIC_NUMBER_OP: return "REAL_ALGEBRAIC_NUMBER_OP";
    case Kind::REAL_ALGEBRAIC_NUMBER: return "REAL_ALGEBRAIC_NUMBER";
    case Kind::LT: return "LT";
    case Kind::LEQ: return "LEQ";
    case Kind::GT: return "GT";
    case Kind::GEQ: return "GEQ";
    case Kind::INDEXED_ROOT_PREDICATE_OP: return "INDEXED_ROOT_PREDICATE_OP";
    case Kind::INDEXED_ROOT_PREDICATE: return "INDEXED_ROOT_PREDICATE";
    case Kind::IS_INTEGER: return "IS_INTEGER";
    case Kind::TO_INTEGER: return "TO_INTEGER";
    case Kind::TO_REAL: return "TO_REAL";
    case Kind::PI: return "PI";
    case Kind::IAND_OP: return "IAND_OP";
    case Kind::IAND: return "IAND";
    case Kind::PIAND: return "PIAND";

    /* from bv */
    case Kind::BITVECTOR_TYPE: return "BITVECTOR_TYPE";
    case Kind::CONST_BITVECTOR: return "CONST_BITVECTOR";
    case Kind::BITVECTOR_FROM_BOOLS: return "BITVECTOR_FROM_BOOLS";
    case Kind::BITVECTOR_SIZE: return "BITVECTOR_SIZE";
    case Kind::CONST_BITVECTOR_SYMBOLIC: return "CONST_BITVECTOR_SYMBOLIC";
    case Kind::BITVECTOR_CONCAT: return "BITVECTOR_CONCAT";
    case Kind::BITVECTOR_AND: return "BITVECTOR_AND";
    case Kind::BITVECTOR_COMP: return "BITVECTOR_COMP";
    case Kind::BITVECTOR_OR: return "BITVECTOR_OR";
    case Kind::BITVECTOR_XOR: return "BITVECTOR_XOR";
    case Kind::BITVECTOR_NOT: return "BITVECTOR_NOT";
    case Kind::BITVECTOR_NAND: return "BITVECTOR_NAND";
    case Kind::BITVECTOR_NOR: return "BITVECTOR_NOR";
    case Kind::BITVECTOR_XNOR: return "BITVECTOR_XNOR";
    case Kind::BITVECTOR_MULT: return "BITVECTOR_MULT";
    case Kind::BITVECTOR_NEG: return "BITVECTOR_NEG";
    case Kind::BITVECTOR_ADD: return "BITVECTOR_ADD";
    case Kind::BITVECTOR_SUB: return "BITVECTOR_SUB";
    case Kind::BITVECTOR_UDIV: return "BITVECTOR_UDIV";
    case Kind::BITVECTOR_UREM: return "BITVECTOR_UREM";
    case Kind::BITVECTOR_SDIV: return "BITVECTOR_SDIV";
    case Kind::BITVECTOR_SMOD: return "BITVECTOR_SMOD";
    case Kind::BITVECTOR_SREM: return "BITVECTOR_SREM";
    case Kind::BITVECTOR_ASHR: return "BITVECTOR_ASHR";
    case Kind::BITVECTOR_LSHR: return "BITVECTOR_LSHR";
    case Kind::BITVECTOR_SHL: return "BITVECTOR_SHL";
    case Kind::BITVECTOR_ULE: return "BITVECTOR_ULE";
    case Kind::BITVECTOR_ULT: return "BITVECTOR_ULT";
    case Kind::BITVECTOR_UGE: return "BITVECTOR_UGE";
    case Kind::BITVECTOR_UGT: return "BITVECTOR_UGT";
    case Kind::BITVECTOR_SLE: return "BITVECTOR_SLE";
    case Kind::BITVECTOR_SLT: return "BITVECTOR_SLT";
    case Kind::BITVECTOR_SGE: return "BITVECTOR_SGE";
    case Kind::BITVECTOR_SGT: return "BITVECTOR_SGT";
    case Kind::BITVECTOR_ULTBV: return "BITVECTOR_ULTBV";
    case Kind::BITVECTOR_SLTBV: return "BITVECTOR_SLTBV";
    case Kind::BITVECTOR_REDAND: return "BITVECTOR_REDAND";
    case Kind::BITVECTOR_REDOR: return "BITVECTOR_REDOR";
    case Kind::BITVECTOR_NEGO: return "BITVECTOR_NEGO";
    case Kind::BITVECTOR_UADDO: return "BITVECTOR_UADDO";
    case Kind::BITVECTOR_SADDO: return "BITVECTOR_SADDO";
    case Kind::BITVECTOR_UMULO: return "BITVECTOR_UMULO";
    case Kind::BITVECTOR_SMULO: return "BITVECTOR_SMULO";
    case Kind::BITVECTOR_USUBO: return "BITVECTOR_USUBO";
    case Kind::BITVECTOR_SSUBO: return "BITVECTOR_SSUBO";
    case Kind::BITVECTOR_SDIVO: return "BITVECTOR_SDIVO";
    case Kind::BITVECTOR_ITE: return "BITVECTOR_ITE";
    case Kind::BITVECTOR_ACKERMANNIZE_UDIV: return "BITVECTOR_ACKERMANNIZE_UDIV";
    case Kind::BITVECTOR_ACKERMANNIZE_UREM: return "BITVECTOR_ACKERMANNIZE_UREM";
    case Kind::BITVECTOR_EAGER_ATOM: return "BITVECTOR_EAGER_ATOM";
    case Kind::BITVECTOR_BIT_OP: return "BITVECTOR_BIT_OP";
    case Kind::BITVECTOR_BIT: return "BITVECTOR_BIT";
    case Kind::BITVECTOR_EXTRACT_OP: return "BITVECTOR_EXTRACT_OP";
    case Kind::BITVECTOR_EXTRACT: return "BITVECTOR_EXTRACT";
    case Kind::BITVECTOR_REPEAT_OP: return "BITVECTOR_REPEAT_OP";
    case Kind::BITVECTOR_REPEAT: return "BITVECTOR_REPEAT";
    case Kind::BITVECTOR_ROTATE_LEFT_OP: return "BITVECTOR_ROTATE_LEFT_OP";
    case Kind::BITVECTOR_ROTATE_LEFT: return "BITVECTOR_ROTATE_LEFT";
    case Kind::BITVECTOR_ROTATE_RIGHT_OP: return "BITVECTOR_ROTATE_RIGHT_OP";
    case Kind::BITVECTOR_ROTATE_RIGHT: return "BITVECTOR_ROTATE_RIGHT";
    case Kind::BITVECTOR_SIGN_EXTEND_OP: return "BITVECTOR_SIGN_EXTEND_OP";
    case Kind::BITVECTOR_SIGN_EXTEND: return "BITVECTOR_SIGN_EXTEND";
    case Kind::BITVECTOR_ZERO_EXTEND_OP: return "BITVECTOR_ZERO_EXTEND_OP";
    case Kind::BITVECTOR_ZERO_EXTEND: return "BITVECTOR_ZERO_EXTEND";

    /* from ff */
    case Kind::FINITE_FIELD_TYPE: return "FINITE_FIELD_TYPE";
    case Kind::CONST_FINITE_FIELD: return "CONST_FINITE_FIELD";
    case Kind::FINITE_FIELD_MULT: return "FINITE_FIELD_MULT";
    case Kind::FINITE_FIELD_NEG: return "FINITE_FIELD_NEG";
    case Kind::FINITE_FIELD_ADD: return "FINITE_FIELD_ADD";
    case Kind::FINITE_FIELD_BITSUM: return "FINITE_FIELD_BITSUM";

    /* from fp */
    case Kind::CONST_FLOATINGPOINT: return "CONST_FLOATINGPOINT";
    case Kind::CONST_ROUNDINGMODE: return "CONST_ROUNDINGMODE";
    case Kind::FLOATINGPOINT_TYPE: return "FLOATINGPOINT_TYPE";
    case Kind::FLOATINGPOINT_FP: return "FLOATINGPOINT_FP";
    case Kind::FLOATINGPOINT_EQ: return "FLOATINGPOINT_EQ";
    case Kind::FLOATINGPOINT_ABS: return "FLOATINGPOINT_ABS";
    case Kind::FLOATINGPOINT_NEG: return "FLOATINGPOINT_NEG";
    case Kind::FLOATINGPOINT_ADD: return "FLOATINGPOINT_ADD";
    case Kind::FLOATINGPOINT_SUB: return "FLOATINGPOINT_SUB";
    case Kind::FLOATINGPOINT_MULT: return "FLOATINGPOINT_MULT";
    case Kind::FLOATINGPOINT_DIV: return "FLOATINGPOINT_DIV";
    case Kind::FLOATINGPOINT_FMA: return "FLOATINGPOINT_FMA";
    case Kind::FLOATINGPOINT_SQRT: return "FLOATINGPOINT_SQRT";
    case Kind::FLOATINGPOINT_REM: return "FLOATINGPOINT_REM";
    case Kind::FLOATINGPOINT_RTI: return "FLOATINGPOINT_RTI";
    case Kind::FLOATINGPOINT_MIN: return "FLOATINGPOINT_MIN";
    case Kind::FLOATINGPOINT_MAX: return "FLOATINGPOINT_MAX";
    case Kind::FLOATINGPOINT_MIN_TOTAL: return "FLOATINGPOINT_MIN_TOTAL";
    case Kind::FLOATINGPOINT_MAX_TOTAL: return "FLOATINGPOINT_MAX_TOTAL";
    case Kind::FLOATINGPOINT_LEQ: return "FLOATINGPOINT_LEQ";
    case Kind::FLOATINGPOINT_LT: return "FLOATINGPOINT_LT";
    case Kind::FLOATINGPOINT_GEQ: return "FLOATINGPOINT_GEQ";
    case Kind::FLOATINGPOINT_GT: return "FLOATINGPOINT_GT";
    case Kind::FLOATINGPOINT_IS_NORMAL: return "FLOATINGPOINT_IS_NORMAL";
    case Kind::FLOATINGPOINT_IS_SUBNORMAL: return "FLOATINGPOINT_IS_SUBNORMAL";
    case Kind::FLOATINGPOINT_IS_ZERO: return "FLOATINGPOINT_IS_ZERO";
    case Kind::FLOATINGPOINT_IS_INF: return "FLOATINGPOINT_IS_INF";
    case Kind::FLOATINGPOINT_IS_NAN: return "FLOATINGPOINT_IS_NAN";
    case Kind::FLOATINGPOINT_IS_NEG: return "FLOATINGPOINT_IS_NEG";
    case Kind::FLOATINGPOINT_IS_POS: return "FLOATINGPOINT_IS_POS";
    case Kind::FLOATINGPOINT_TO_FP_FROM_IEEE_BV_OP: return "FLOATINGPOINT_TO_FP_FROM_IEEE_BV_OP";
    case Kind::FLOATINGPOINT_TO_FP_FROM_IEEE_BV: return "FLOATINGPOINT_TO_FP_FROM_IEEE_BV";
    case Kind::FLOATINGPOINT_TO_FP_FROM_FP_OP: return "FLOATINGPOINT_TO_FP_FROM_FP_OP";
    case Kind::FLOATINGPOINT_TO_FP_FROM_FP: return "FLOATINGPOINT_TO_FP_FROM_FP";
    case Kind::FLOATINGPOINT_TO_FP_FROM_REAL_OP: return "FLOATINGPOINT_TO_FP_FROM_REAL_OP";
    case Kind::FLOATINGPOINT_TO_FP_FROM_REAL: return "FLOATINGPOINT_TO_FP_FROM_REAL";
    case Kind::FLOATINGPOINT_TO_FP_FROM_SBV_OP: return "FLOATINGPOINT_TO_FP_FROM_SBV_OP";
    case Kind::FLOATINGPOINT_TO_FP_FROM_SBV: return "FLOATINGPOINT_TO_FP_FROM_SBV";
    case Kind::FLOATINGPOINT_TO_FP_FROM_UBV_OP: return "FLOATINGPOINT_TO_FP_FROM_UBV_OP";
    case Kind::FLOATINGPOINT_TO_FP_FROM_UBV: return "FLOATINGPOINT_TO_FP_FROM_UBV";
    case Kind::FLOATINGPOINT_TO_UBV_OP: return "FLOATINGPOINT_TO_UBV_OP";
    case Kind::FLOATINGPOINT_TO_UBV: return "FLOATINGPOINT_TO_UBV";
    case Kind::FLOATINGPOINT_TO_UBV_TOTAL_OP: return "FLOATINGPOINT_TO_UBV_TOTAL_OP";
    case Kind::FLOATINGPOINT_TO_UBV_TOTAL: return "FLOATINGPOINT_TO_UBV_TOTAL";
    case Kind::FLOATINGPOINT_TO_SBV_OP: return "FLOATINGPOINT_TO_SBV_OP";
    case Kind::FLOATINGPOINT_TO_SBV: return "FLOATINGPOINT_TO_SBV";
    case Kind::FLOATINGPOINT_TO_SBV_TOTAL_OP: return "FLOATINGPOINT_TO_SBV_TOTAL_OP";
    case Kind::FLOATINGPOINT_TO_SBV_TOTAL: return "FLOATINGPOINT_TO_SBV_TOTAL";
    case Kind::FLOATINGPOINT_TO_REAL: return "FLOATINGPOINT_TO_REAL";
    case Kind::FLOATINGPOINT_TO_REAL_TOTAL: return "FLOATINGPOINT_TO_REAL_TOTAL";
    case Kind::FLOATINGPOINT_COMPONENT_NAN: return "FLOATINGPOINT_COMPONENT_NAN";
    case Kind::FLOATINGPOINT_COMPONENT_INF: return "FLOATINGPOINT_COMPONENT_INF";
    case Kind::FLOATINGPOINT_COMPONENT_ZERO: return "FLOATINGPOINT_COMPONENT_ZERO";
    case Kind::FLOATINGPOINT_COMPONENT_SIGN: return "FLOATINGPOINT_COMPONENT_SIGN";
    case Kind::FLOATINGPOINT_COMPONENT_EXPONENT: return "FLOATINGPOINT_COMPONENT_EXPONENT";
    case Kind::FLOATINGPOINT_COMPONENT_SIGNIFICAND: return "FLOATINGPOINT_COMPONENT_SIGNIFICAND";
    case Kind::ROUNDINGMODE_BITBLAST: return "ROUNDINGMODE_BITBLAST";

    /* from arrays */
    case Kind::ARRAY_TYPE: return "ARRAY_TYPE";
    case Kind::SELECT: return "SELECT";
    case Kind::STORE: return "STORE";
    case Kind::EQ_RANGE: return "EQ_RANGE";
    case Kind::STORE_ALL: return "STORE_ALL";
    case Kind::ARRAY_LAMBDA: return "ARRAY_LAMBDA";

    /* from datatypes */
    case Kind::CONSTRUCTOR_TYPE: return "CONSTRUCTOR_TYPE";
    case Kind::SELECTOR_TYPE: return "SELECTOR_TYPE";
    case Kind::TESTER_TYPE: return "TESTER_TYPE";
    case Kind::UPDATER_TYPE: return "UPDATER_TYPE";
    case Kind::APPLY_CONSTRUCTOR: return "APPLY_CONSTRUCTOR";
    case Kind::APPLY_SELECTOR: return "APPLY_SELECTOR";
    case Kind::APPLY_TESTER: return "APPLY_TESTER";
    case Kind::APPLY_UPDATER: return "APPLY_UPDATER";
    case Kind::DATATYPE_TYPE: return "DATATYPE_TYPE";
    case Kind::PARAMETRIC_DATATYPE: return "PARAMETRIC_DATATYPE";
    case Kind::TUPLE_TYPE: return "TUPLE_TYPE";
    case Kind::APPLY_TYPE_ASCRIPTION: return "APPLY_TYPE_ASCRIPTION";
    case Kind::ASCRIPTION_TYPE: return "ASCRIPTION_TYPE";
    case Kind::DT_SIZE: return "DT_SIZE";
    case Kind::DT_HEIGHT_BOUND: return "DT_HEIGHT_BOUND";
    case Kind::DT_SIZE_BOUND: return "DT_SIZE_BOUND";
    case Kind::DT_SYGUS_BOUND: return "DT_SYGUS_BOUND";
    case Kind::DT_SYGUS_EVAL: return "DT_SYGUS_EVAL";
    case Kind::MATCH: return "MATCH";
    case Kind::MATCH_CASE: return "MATCH_CASE";
    case Kind::MATCH_BIND_CASE: return "MATCH_BIND_CASE";
    case Kind::TUPLE_PROJECT_OP: return "TUPLE_PROJECT_OP";
    case Kind::TUPLE_PROJECT: return "TUPLE_PROJECT";
    case Kind::CODATATYPE_BOUND_VARIABLE: return "CODATATYPE_BOUND_VARIABLE";
    case Kind::NULLABLE_TYPE: return "NULLABLE_TYPE";
    case Kind::NULLABLE_LIFT: return "NULLABLE_LIFT";

    /* from sep */
    case Kind::SEP_NIL: return "SEP_NIL";
    case Kind::SEP_EMP: return "SEP_EMP";
    case Kind::SEP_PTO: return "SEP_PTO";
    case Kind::SEP_STAR: return "SEP_STAR";
    case Kind::SEP_WAND: return "SEP_WAND";
    case Kind::SEP_LABEL: return "SEP_LABEL";

    /* from sets */
    case Kind::SET_EMPTY: return "SET_EMPTY";
    case Kind::SET_TYPE: return "SET_TYPE";
    case Kind::SET_UNION: return "SET_UNION";
    case Kind::SET_INTER: return "SET_INTER";
    case Kind::SET_MINUS: return "SET_MINUS";
    case Kind::SET_SUBSET: return "SET_SUBSET";
    case Kind::SET_MEMBER: return "SET_MEMBER";
    case Kind::SET_SINGLETON: return "SET_SINGLETON";
    case Kind::SET_INSERT: return "SET_INSERT";
    case Kind::SET_CARD: return "SET_CARD";
    case Kind::SET_COMPLEMENT: return "SET_COMPLEMENT";
    case Kind::SET_UNIVERSE: return "SET_UNIVERSE";
    case Kind::SET_COMPREHENSION: return "SET_COMPREHENSION";
    case Kind::SET_CHOOSE: return "SET_CHOOSE";
    case Kind::SET_IS_EMPTY: return "SET_IS_EMPTY";
    case Kind::SET_IS_SINGLETON: return "SET_IS_SINGLETON";
    case Kind::SET_MAP: return "SET_MAP";
    case Kind::SET_FILTER: return "SET_FILTER";
    case Kind::SET_ALL: return "SET_ALL";
    case Kind::SET_SOME: return "SET_SOME";
    case Kind::SET_FOLD: return "SET_FOLD";
    case Kind::RELATION_GROUP_OP: return "RELATION_GROUP_OP";
    case Kind::RELATION_GROUP: return "RELATION_GROUP";
    case Kind::RELATION_AGGREGATE_OP: return "RELATION_AGGREGATE_OP";
    case Kind::RELATION_AGGREGATE: return "RELATION_AGGREGATE";
    case Kind::RELATION_PROJECT_OP: return "RELATION_PROJECT_OP";
    case Kind::RELATION_PROJECT: return "RELATION_PROJECT";
    case Kind::RELATION_JOIN: return "RELATION_JOIN";
    case Kind::RELATION_PRODUCT: return "RELATION_PRODUCT";
    case Kind::RELATION_TRANSPOSE: return "RELATION_TRANSPOSE";
    case Kind::RELATION_TCLOSURE: return "RELATION_TCLOSURE";
    case Kind::RELATION_JOIN_IMAGE: return "RELATION_JOIN_IMAGE";
    case Kind::RELATION_IDEN: return "RELATION_IDEN";
    case Kind::RELATION_TABLE_JOIN_OP: return "RELATION_TABLE_JOIN_OP";
    case Kind::RELATION_TABLE_JOIN: return "RELATION_TABLE_JOIN";
    case Kind::SET_EMPTY_OF_TYPE: return "SET_EMPTY_OF_TYPE";

    /* from bags */
    case Kind::BAG_EMPTY: return "BAG_EMPTY";
    case Kind::BAG_TYPE: return "BAG_TYPE";
    case Kind::BAG_UNION_MAX: return "BAG_UNION_MAX";
    case Kind::BAG_UNION_DISJOINT: return "BAG_UNION_DISJOINT";
    case Kind::BAG_INTER_MIN: return "BAG_INTER_MIN";
    case Kind::BAG_DIFFERENCE_SUBTRACT: return "BAG_DIFFERENCE_SUBTRACT";
    case Kind::BAG_DIFFERENCE_REMOVE: return "BAG_DIFFERENCE_REMOVE";
    case Kind::BAG_SUBBAG: return "BAG_SUBBAG";
    case Kind::BAG_COUNT: return "BAG_COUNT";
    case Kind::BAG_MEMBER: return "BAG_MEMBER";
    case Kind::BAG_SETOF: return "BAG_SETOF";
    case Kind::BAG_MAKE: return "BAG_MAKE";
    case Kind::BAG_CARD: return "BAG_CARD";
    case Kind::BAG_CHOOSE: return "BAG_CHOOSE";
    case Kind::BAG_MAP: return "BAG_MAP";
    case Kind::BAG_FILTER: return "BAG_FILTER";
    case Kind::BAG_ALL: return "BAG_ALL";
    case Kind::BAG_SOME: return "BAG_SOME";
    case Kind::BAG_FOLD: return "BAG_FOLD";
    case Kind::BAG_PARTITION: return "BAG_PARTITION";
    case Kind::TABLE_PRODUCT: return "TABLE_PRODUCT";
    case Kind::TABLE_PROJECT_OP: return "TABLE_PROJECT_OP";
    case Kind::TABLE_PROJECT: return "TABLE_PROJECT";
    case Kind::TABLE_AGGREGATE_OP: return "TABLE_AGGREGATE_OP";
    case Kind::TABLE_AGGREGATE: return "TABLE_AGGREGATE";
    case Kind::TABLE_JOIN_OP: return "TABLE_JOIN_OP";
    case Kind::TABLE_JOIN: return "TABLE_JOIN";
    case Kind::TABLE_GROUP_OP: return "TABLE_GROUP_OP";
    case Kind::TABLE_GROUP: return "TABLE_GROUP";

    /* from strings */
    case Kind::STRING_CONCAT: return "STRING_CONCAT";
    case Kind::STRING_IN_REGEXP: return "STRING_IN_REGEXP";
    case Kind::STRING_LENGTH: return "STRING_LENGTH";
    case Kind::STRING_SUBSTR: return "STRING_SUBSTR";
    case Kind::STRING_UPDATE: return "STRING_UPDATE";
    case Kind::STRING_CHARAT: return "STRING_CHARAT";
    case Kind::STRING_CONTAINS: return "STRING_CONTAINS";
    case Kind::STRING_LT: return "STRING_LT";
    case Kind::STRING_LEQ: return "STRING_LEQ";
    case Kind::STRING_INDEXOF: return "STRING_INDEXOF";
    case Kind::STRING_INDEXOF_RE: return "STRING_INDEXOF_RE";
    case Kind::STRING_REPLACE: return "STRING_REPLACE";
    case Kind::STRING_REPLACE_ALL: return "STRING_REPLACE_ALL";
    case Kind::STRING_REPLACE_RE: return "STRING_REPLACE_RE";
    case Kind::STRING_REPLACE_RE_ALL: return "STRING_REPLACE_RE_ALL";
    case Kind::STRING_PREFIX: return "STRING_PREFIX";
    case Kind::STRING_SUFFIX: return "STRING_SUFFIX";
    case Kind::STRING_IS_DIGIT: return "STRING_IS_DIGIT";
    case Kind::STRING_ITOS: return "STRING_ITOS";
    case Kind::STRING_STOI: return "STRING_STOI";
    case Kind::STRING_TO_CODE: return "STRING_TO_CODE";
    case Kind::STRING_FROM_CODE: return "STRING_FROM_CODE";
    case Kind::STRING_UNIT: return "STRING_UNIT";
    case Kind::STRING_TO_LOWER: return "STRING_TO_LOWER";
    case Kind::STRING_TO_UPPER: return "STRING_TO_UPPER";
    case Kind::STRING_REV: return "STRING_REV";
    case Kind::CONST_STRING: return "CONST_STRING";
    case Kind::SEQUENCE_TYPE: return "SEQUENCE_TYPE";
    case Kind::CONST_SEQUENCE: return "CONST_SEQUENCE";
    case Kind::SEQ_UNIT: return "SEQ_UNIT";
    case Kind::SEQ_NTH: return "SEQ_NTH";
    case Kind::STRING_TO_REGEXP: return "STRING_TO_REGEXP";
    case Kind::REGEXP_CONCAT: return "REGEXP_CONCAT";
    case Kind::REGEXP_UNION: return "REGEXP_UNION";
    case Kind::REGEXP_INTER: return "REGEXP_INTER";
    case Kind::REGEXP_DIFF: return "REGEXP_DIFF";
    case Kind::REGEXP_STAR: return "REGEXP_STAR";
    case Kind::REGEXP_PLUS: return "REGEXP_PLUS";
    case Kind::REGEXP_OPT: return "REGEXP_OPT";
    case Kind::REGEXP_RANGE: return "REGEXP_RANGE";
    case Kind::REGEXP_COMPLEMENT: return "REGEXP_COMPLEMENT";
    case Kind::REGEXP_NONE: return "REGEXP_NONE";
    case Kind::REGEXP_ALL: return "REGEXP_ALL";
    case Kind::REGEXP_ALLCHAR: return "REGEXP_ALLCHAR";
    case Kind::REGEXP_REPEAT_OP: return "REGEXP_REPEAT_OP";
    case Kind::REGEXP_REPEAT: return "REGEXP_REPEAT";
    case Kind::REGEXP_LOOP_OP: return "REGEXP_LOOP_OP";
    case Kind::REGEXP_LOOP: return "REGEXP_LOOP";
    case Kind::REGEXP_RV: return "REGEXP_RV";
    case Kind::SEQ_EMPTY_OF_TYPE: return "SEQ_EMPTY_OF_TYPE";

    /* from quantifiers */
    case Kind::FORALL: return "FORALL";
    case Kind::EXISTS: return "EXISTS";
    case Kind::INST_CONSTANT: return "INST_CONSTANT";
    case Kind::ORACLE: return "ORACLE";
    case Kind::BOUND_VAR_LIST: return "BOUND_VAR_LIST";
    case Kind::INST_PATTERN: return "INST_PATTERN";
    case Kind::INST_NO_PATTERN: return "INST_NO_PATTERN";
    case Kind::INST_ATTRIBUTE: return "INST_ATTRIBUTE";
    case Kind::INST_POOL: return "INST_POOL";
    case Kind::INST_ADD_TO_POOL: return "INST_ADD_TO_POOL";
    case Kind::SKOLEM_ADD_TO_POOL: return "SKOLEM_ADD_TO_POOL";
    case Kind::ORACLE_FORMULA_GEN: return "ORACLE_FORMULA_GEN";
    case Kind::INST_PATTERN_LIST: return "INST_PATTERN_LIST";


      // clang-format on
    case Kind::LAST_KIND: return "LAST_KIND";
    default: return "?";
  }
}

std::ostream& operator<<(std::ostream& out, cvc5::internal::Kind k)
{
  Printer::getPrinter(out)->toStream(out, k);
  return out;
}

/** Returns true if the given kind is associative. This is used by ExprManager to
 * decide whether it's safe to modify big expressions by changing the grouping of
 * the arguments. */
/* TODO: This could be generated. */
bool isAssociative(cvc5::internal::Kind k)
{
  switch(k) {
    case Kind::AND:
    case Kind::OR:
    case Kind::MULT:
    case Kind::ADD: return true;

    default: return false;
  }
}

/** Return true if k is a closure kind. */
bool isClosureKind(cvc5::internal::Kind k)
{
  switch (k)
  {
    case Kind::LAMBDA:
    case Kind::EXISTS:
    case Kind::FORALL:
    case Kind::WITNESS:
    case Kind::SET_COMPREHENSION:
    case Kind::MATCH_BIND_CASE: return true;

    default: return false;
  }
}

std::string kindToString(cvc5::internal::Kind k) { return toString(k); }

}  // namespace kind

const char* toString(TypeConstant tc)
{
  switch (tc)
  {
    // clang-format off
        case BUILTIN_OPERATOR_TYPE: return "the type for built-in operators";
    case SEXPR_TYPE: return "the type of a symbolic expression";
    case BOOLEAN_TYPE: return "Boolean type";
    case REAL_TYPE: return "real type";
    case INTEGER_TYPE: return "integer type";
    case ROUNDINGMODE_TYPE: return "floating-point rounding mode";
    case STRING_TYPE: return "String type";
    case REGEXP_TYPE: return "RegExp type";
    case BOUND_VAR_LIST_TYPE: return "the type of bound variable lists";
    case INST_PATTERN_TYPE: return "instantiation pattern type";
    case INST_PATTERN_LIST_TYPE: return "the type of instantiation pattern lists";

      // clang-format on
    default: return "UNKNOWN_TYPE_CONSTANT";
  }
}
std::ostream& operator<<(std::ostream& out, TypeConstant typeConstant)
{
  return out << toString(typeConstant);
}

namespace theory {

TheoryId kindToTheoryId(cvc5::internal::Kind k)
{
  switch (k)
  {
    case Kind::UNDEFINED_KIND:
    case Kind::NULL_EXPR:
      break;
      // clang-format off
    case Kind::SORT_TYPE: return THEORY_BUILTIN;
    case Kind::INSTANTIATED_SORT_TYPE: return THEORY_BUILTIN;
    case Kind::UNINTERPRETED_SORT_VALUE: return THEORY_BUILTIN;
    case Kind::BUILTIN: return THEORY_BUILTIN;
    case Kind::EQUAL: return THEORY_BUILTIN;
    case Kind::VARIABLE: return THEORY_BUILTIN;
    case Kind::BOUND_VARIABLE: return THEORY_BUILTIN;
    case Kind::SKOLEM: return THEORY_BUILTIN;
    case Kind::DUMMY_SKOLEM: return THEORY_BUILTIN;
    case Kind::SEXPR: return THEORY_BUILTIN;
    case Kind::WITNESS: return THEORY_BUILTIN;
    case Kind::TYPE_CONSTANT: return THEORY_BUILTIN;
    case Kind::RAW_SYMBOL: return THEORY_BUILTIN;
    case Kind::ABSTRACT_TYPE: return THEORY_BUILTIN;
    case Kind::APPLY_INDEXED_SYMBOLIC_OP: return THEORY_BUILTIN;
    case Kind::APPLY_INDEXED_SYMBOLIC: return THEORY_BUILTIN;
    case Kind::SORT_TO_TERM: return THEORY_BUILTIN;
    case Kind::TYPE_OF: return THEORY_BUILTIN;
    case Kind::CONST_BOOLEAN: return THEORY_BOOL;
    case Kind::NOT: return THEORY_BOOL;
    case Kind::AND: return THEORY_BOOL;
    case Kind::IMPLIES: return THEORY_BOOL;
    case Kind::OR: return THEORY_BOOL;
    case Kind::XOR: return THEORY_BOOL;
    case Kind::ITE: return THEORY_BOOL;
    case Kind::APPLY_UF: return THEORY_UF;
    case Kind::FUNCTION_TYPE: return THEORY_UF;
    case Kind::LAMBDA: return THEORY_UF;
    case Kind::HO_APPLY: return THEORY_UF;
    case Kind::CARDINALITY_CONSTRAINT_OP: return THEORY_UF;
    case Kind::CARDINALITY_CONSTRAINT: return THEORY_UF;
    case Kind::COMBINED_CARDINALITY_CONSTRAINT_OP: return THEORY_UF;
    case Kind::COMBINED_CARDINALITY_CONSTRAINT: return THEORY_UF;
    case Kind::FUNCTION_ARRAY_CONST: return THEORY_UF;
    case Kind::BITVECTOR_UBV_TO_INT: return THEORY_UF;
    case Kind::BITVECTOR_SBV_TO_INT: return THEORY_UF;
    case Kind::INT_TO_BITVECTOR_OP: return THEORY_UF;
    case Kind::INT_TO_BITVECTOR: return THEORY_UF;
    case Kind::DISTINCT: return THEORY_UF;
    case Kind::ADD: return THEORY_ARITH;
    case Kind::MULT: return THEORY_ARITH;
    case Kind::NONLINEAR_MULT: return THEORY_ARITH;
    case Kind::SUB: return THEORY_ARITH;
    case Kind::NEG: return THEORY_ARITH;
    case Kind::DIVISION: return THEORY_ARITH;
    case Kind::DIVISION_TOTAL: return THEORY_ARITH;
    case Kind::INTS_DIVISION: return THEORY_ARITH;
    case Kind::INTS_DIVISION_TOTAL: return THEORY_ARITH;
    case Kind::INTS_MODULUS: return THEORY_ARITH;
    case Kind::INTS_MODULUS_TOTAL: return THEORY_ARITH;
    case Kind::ABS: return THEORY_ARITH;
    case Kind::DIVISIBLE: return THEORY_ARITH;
    case Kind::POW: return THEORY_ARITH;
    case Kind::POW2: return THEORY_ARITH;
    case Kind::INTS_ISPOW2: return THEORY_ARITH;
    case Kind::INTS_LOG2: return THEORY_ARITH;
    case Kind::EXPONENTIAL: return THEORY_ARITH;
    case Kind::SINE: return THEORY_ARITH;
    case Kind::COSINE: return THEORY_ARITH;
    case Kind::TANGENT: return THEORY_ARITH;
    case Kind::COSECANT: return THEORY_ARITH;
    case Kind::SECANT: return THEORY_ARITH;
    case Kind::COTANGENT: return THEORY_ARITH;
    case Kind::ARCSINE: return THEORY_ARITH;
    case Kind::ARCCOSINE: return THEORY_ARITH;
    case Kind::ARCTANGENT: return THEORY_ARITH;
    case Kind::ARCCOSECANT: return THEORY_ARITH;
    case Kind::ARCSECANT: return THEORY_ARITH;
    case Kind::ARCCOTANGENT: return THEORY_ARITH;
    case Kind::SQRT: return THEORY_ARITH;
    case Kind::DIVISIBLE_OP: return THEORY_ARITH;
    case Kind::CONST_RATIONAL: return THEORY_ARITH;
    case Kind::CONST_INTEGER: return THEORY_ARITH;
    case Kind::REAL_ALGEBRAIC_NUMBER_OP: return THEORY_ARITH;
    case Kind::REAL_ALGEBRAIC_NUMBER: return THEORY_ARITH;
    case Kind::LT: return THEORY_ARITH;
    case Kind::LEQ: return THEORY_ARITH;
    case Kind::GT: return THEORY_ARITH;
    case Kind::GEQ: return THEORY_ARITH;
    case Kind::INDEXED_ROOT_PREDICATE_OP: return THEORY_ARITH;
    case Kind::INDEXED_ROOT_PREDICATE: return THEORY_ARITH;
    case Kind::IS_INTEGER: return THEORY_ARITH;
    case Kind::TO_INTEGER: return THEORY_ARITH;
    case Kind::TO_REAL: return THEORY_ARITH;
    case Kind::PI: return THEORY_ARITH;
    case Kind::IAND_OP: return THEORY_ARITH;
    case Kind::IAND: return THEORY_ARITH;
    case Kind::PIAND: return THEORY_ARITH;
    case Kind::BITVECTOR_TYPE: return THEORY_BV;
    case Kind::CONST_BITVECTOR: return THEORY_BV;
    case Kind::BITVECTOR_FROM_BOOLS: return THEORY_BV;
    case Kind::BITVECTOR_SIZE: return THEORY_BV;
    case Kind::CONST_BITVECTOR_SYMBOLIC: return THEORY_BV;
    case Kind::BITVECTOR_CONCAT: return THEORY_BV;
    case Kind::BITVECTOR_AND: return THEORY_BV;
    case Kind::BITVECTOR_COMP: return THEORY_BV;
    case Kind::BITVECTOR_OR: return THEORY_BV;
    case Kind::BITVECTOR_XOR: return THEORY_BV;
    case Kind::BITVECTOR_NOT: return THEORY_BV;
    case Kind::BITVECTOR_NAND: return THEORY_BV;
    case Kind::BITVECTOR_NOR: return THEORY_BV;
    case Kind::BITVECTOR_XNOR: return THEORY_BV;
    case Kind::BITVECTOR_MULT: return THEORY_BV;
    case Kind::BITVECTOR_NEG: return THEORY_BV;
    case Kind::BITVECTOR_ADD: return THEORY_BV;
    case Kind::BITVECTOR_SUB: return THEORY_BV;
    case Kind::BITVECTOR_UDIV: return THEORY_BV;
    case Kind::BITVECTOR_UREM: return THEORY_BV;
    case Kind::BITVECTOR_SDIV: return THEORY_BV;
    case Kind::BITVECTOR_SMOD: return THEORY_BV;
    case Kind::BITVECTOR_SREM: return THEORY_BV;
    case Kind::BITVECTOR_ASHR: return THEORY_BV;
    case Kind::BITVECTOR_LSHR: return THEORY_BV;
    case Kind::BITVECTOR_SHL: return THEORY_BV;
    case Kind::BITVECTOR_ULE: return THEORY_BV;
    case Kind::BITVECTOR_ULT: return THEORY_BV;
    case Kind::BITVECTOR_UGE: return THEORY_BV;
    case Kind::BITVECTOR_UGT: return THEORY_BV;
    case Kind::BITVECTOR_SLE: return THEORY_BV;
    case Kind::BITVECTOR_SLT: return THEORY_BV;
    case Kind::BITVECTOR_SGE: return THEORY_BV;
    case Kind::BITVECTOR_SGT: return THEORY_BV;
    case Kind::BITVECTOR_ULTBV: return THEORY_BV;
    case Kind::BITVECTOR_SLTBV: return THEORY_BV;
    case Kind::BITVECTOR_REDAND: return THEORY_BV;
    case Kind::BITVECTOR_REDOR: return THEORY_BV;
    case Kind::BITVECTOR_NEGO: return THEORY_BV;
    case Kind::BITVECTOR_UADDO: return THEORY_BV;
    case Kind::BITVECTOR_SADDO: return THEORY_BV;
    case Kind::BITVECTOR_UMULO: return THEORY_BV;
    case Kind::BITVECTOR_SMULO: return THEORY_BV;
    case Kind::BITVECTOR_USUBO: return THEORY_BV;
    case Kind::BITVECTOR_SSUBO: return THEORY_BV;
    case Kind::BITVECTOR_SDIVO: return THEORY_BV;
    case Kind::BITVECTOR_ITE: return THEORY_BV;
    case Kind::BITVECTOR_ACKERMANNIZE_UDIV: return THEORY_BV;
    case Kind::BITVECTOR_ACKERMANNIZE_UREM: return THEORY_BV;
    case Kind::BITVECTOR_EAGER_ATOM: return THEORY_BV;
    case Kind::BITVECTOR_BIT_OP: return THEORY_BV;
    case Kind::BITVECTOR_BIT: return THEORY_BV;
    case Kind::BITVECTOR_EXTRACT_OP: return THEORY_BV;
    case Kind::BITVECTOR_EXTRACT: return THEORY_BV;
    case Kind::BITVECTOR_REPEAT_OP: return THEORY_BV;
    case Kind::BITVECTOR_REPEAT: return THEORY_BV;
    case Kind::BITVECTOR_ROTATE_LEFT_OP: return THEORY_BV;
    case Kind::BITVECTOR_ROTATE_LEFT: return THEORY_BV;
    case Kind::BITVECTOR_ROTATE_RIGHT_OP: return THEORY_BV;
    case Kind::BITVECTOR_ROTATE_RIGHT: return THEORY_BV;
    case Kind::BITVECTOR_SIGN_EXTEND_OP: return THEORY_BV;
    case Kind::BITVECTOR_SIGN_EXTEND: return THEORY_BV;
    case Kind::BITVECTOR_ZERO_EXTEND_OP: return THEORY_BV;
    case Kind::BITVECTOR_ZERO_EXTEND: return THEORY_BV;
    case Kind::FINITE_FIELD_TYPE: return THEORY_FF;
    case Kind::CONST_FINITE_FIELD: return THEORY_FF;
    case Kind::FINITE_FIELD_MULT: return THEORY_FF;
    case Kind::FINITE_FIELD_NEG: return THEORY_FF;
    case Kind::FINITE_FIELD_ADD: return THEORY_FF;
    case Kind::FINITE_FIELD_BITSUM: return THEORY_FF;
    case Kind::CONST_FLOATINGPOINT: return THEORY_FP;
    case Kind::CONST_ROUNDINGMODE: return THEORY_FP;
    case Kind::FLOATINGPOINT_TYPE: return THEORY_FP;
    case Kind::FLOATINGPOINT_FP: return THEORY_FP;
    case Kind::FLOATINGPOINT_EQ: return THEORY_FP;
    case Kind::FLOATINGPOINT_ABS: return THEORY_FP;
    case Kind::FLOATINGPOINT_NEG: return THEORY_FP;
    case Kind::FLOATINGPOINT_ADD: return THEORY_FP;
    case Kind::FLOATINGPOINT_SUB: return THEORY_FP;
    case Kind::FLOATINGPOINT_MULT: return THEORY_FP;
    case Kind::FLOATINGPOINT_DIV: return THEORY_FP;
    case Kind::FLOATINGPOINT_FMA: return THEORY_FP;
    case Kind::FLOATINGPOINT_SQRT: return THEORY_FP;
    case Kind::FLOATINGPOINT_REM: return THEORY_FP;
    case Kind::FLOATINGPOINT_RTI: return THEORY_FP;
    case Kind::FLOATINGPOINT_MIN: return THEORY_FP;
    case Kind::FLOATINGPOINT_MAX: return THEORY_FP;
    case Kind::FLOATINGPOINT_MIN_TOTAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_MAX_TOTAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_LEQ: return THEORY_FP;
    case Kind::FLOATINGPOINT_LT: return THEORY_FP;
    case Kind::FLOATINGPOINT_GEQ: return THEORY_FP;
    case Kind::FLOATINGPOINT_GT: return THEORY_FP;
    case Kind::FLOATINGPOINT_IS_NORMAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_IS_SUBNORMAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_IS_ZERO: return THEORY_FP;
    case Kind::FLOATINGPOINT_IS_INF: return THEORY_FP;
    case Kind::FLOATINGPOINT_IS_NAN: return THEORY_FP;
    case Kind::FLOATINGPOINT_IS_NEG: return THEORY_FP;
    case Kind::FLOATINGPOINT_IS_POS: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_IEEE_BV_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_IEEE_BV: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_FP_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_FP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_REAL_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_REAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_SBV_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_SBV: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_UBV_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_FP_FROM_UBV: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_UBV_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_UBV: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_UBV_TOTAL_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_UBV_TOTAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_SBV_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_SBV: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_SBV_TOTAL_OP: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_SBV_TOTAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_REAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_TO_REAL_TOTAL: return THEORY_FP;
    case Kind::FLOATINGPOINT_COMPONENT_NAN: return THEORY_FP;
    case Kind::FLOATINGPOINT_COMPONENT_INF: return THEORY_FP;
    case Kind::FLOATINGPOINT_COMPONENT_ZERO: return THEORY_FP;
    case Kind::FLOATINGPOINT_COMPONENT_SIGN: return THEORY_FP;
    case Kind::FLOATINGPOINT_COMPONENT_EXPONENT: return THEORY_FP;
    case Kind::FLOATINGPOINT_COMPONENT_SIGNIFICAND: return THEORY_FP;
    case Kind::ROUNDINGMODE_BITBLAST: return THEORY_FP;
    case Kind::ARRAY_TYPE: return THEORY_ARRAYS;
    case Kind::SELECT: return THEORY_ARRAYS;
    case Kind::STORE: return THEORY_ARRAYS;
    case Kind::EQ_RANGE: return THEORY_ARRAYS;
    case Kind::STORE_ALL: return THEORY_ARRAYS;
    case Kind::ARRAY_LAMBDA: return THEORY_ARRAYS;
    case Kind::CONSTRUCTOR_TYPE: return THEORY_DATATYPES;
    case Kind::SELECTOR_TYPE: return THEORY_DATATYPES;
    case Kind::TESTER_TYPE: return THEORY_DATATYPES;
    case Kind::UPDATER_TYPE: return THEORY_DATATYPES;
    case Kind::APPLY_CONSTRUCTOR: return THEORY_DATATYPES;
    case Kind::APPLY_SELECTOR: return THEORY_DATATYPES;
    case Kind::APPLY_TESTER: return THEORY_DATATYPES;
    case Kind::APPLY_UPDATER: return THEORY_DATATYPES;
    case Kind::DATATYPE_TYPE: return THEORY_DATATYPES;
    case Kind::PARAMETRIC_DATATYPE: return THEORY_DATATYPES;
    case Kind::TUPLE_TYPE: return THEORY_DATATYPES;
    case Kind::APPLY_TYPE_ASCRIPTION: return THEORY_DATATYPES;
    case Kind::ASCRIPTION_TYPE: return THEORY_DATATYPES;
    case Kind::DT_SIZE: return THEORY_DATATYPES;
    case Kind::DT_HEIGHT_BOUND: return THEORY_DATATYPES;
    case Kind::DT_SIZE_BOUND: return THEORY_DATATYPES;
    case Kind::DT_SYGUS_BOUND: return THEORY_DATATYPES;
    case Kind::DT_SYGUS_EVAL: return THEORY_DATATYPES;
    case Kind::MATCH: return THEORY_DATATYPES;
    case Kind::MATCH_CASE: return THEORY_DATATYPES;
    case Kind::MATCH_BIND_CASE: return THEORY_DATATYPES;
    case Kind::TUPLE_PROJECT_OP: return THEORY_DATATYPES;
    case Kind::TUPLE_PROJECT: return THEORY_DATATYPES;
    case Kind::CODATATYPE_BOUND_VARIABLE: return THEORY_DATATYPES;
    case Kind::NULLABLE_TYPE: return THEORY_DATATYPES;
    case Kind::NULLABLE_LIFT: return THEORY_DATATYPES;
    case Kind::SEP_NIL: return THEORY_SEP;
    case Kind::SEP_EMP: return THEORY_SEP;
    case Kind::SEP_PTO: return THEORY_SEP;
    case Kind::SEP_STAR: return THEORY_SEP;
    case Kind::SEP_WAND: return THEORY_SEP;
    case Kind::SEP_LABEL: return THEORY_SEP;
    case Kind::SET_EMPTY: return THEORY_SETS;
    case Kind::SET_TYPE: return THEORY_SETS;
    case Kind::SET_UNION: return THEORY_SETS;
    case Kind::SET_INTER: return THEORY_SETS;
    case Kind::SET_MINUS: return THEORY_SETS;
    case Kind::SET_SUBSET: return THEORY_SETS;
    case Kind::SET_MEMBER: return THEORY_SETS;
    case Kind::SET_SINGLETON: return THEORY_SETS;
    case Kind::SET_INSERT: return THEORY_SETS;
    case Kind::SET_CARD: return THEORY_SETS;
    case Kind::SET_COMPLEMENT: return THEORY_SETS;
    case Kind::SET_UNIVERSE: return THEORY_SETS;
    case Kind::SET_COMPREHENSION: return THEORY_SETS;
    case Kind::SET_CHOOSE: return THEORY_SETS;
    case Kind::SET_IS_EMPTY: return THEORY_SETS;
    case Kind::SET_IS_SINGLETON: return THEORY_SETS;
    case Kind::SET_MAP: return THEORY_SETS;
    case Kind::SET_FILTER: return THEORY_SETS;
    case Kind::SET_ALL: return THEORY_SETS;
    case Kind::SET_SOME: return THEORY_SETS;
    case Kind::SET_FOLD: return THEORY_SETS;
    case Kind::RELATION_GROUP_OP: return THEORY_SETS;
    case Kind::RELATION_GROUP: return THEORY_SETS;
    case Kind::RELATION_AGGREGATE_OP: return THEORY_SETS;
    case Kind::RELATION_AGGREGATE: return THEORY_SETS;
    case Kind::RELATION_PROJECT_OP: return THEORY_SETS;
    case Kind::RELATION_PROJECT: return THEORY_SETS;
    case Kind::RELATION_JOIN: return THEORY_SETS;
    case Kind::RELATION_PRODUCT: return THEORY_SETS;
    case Kind::RELATION_TRANSPOSE: return THEORY_SETS;
    case Kind::RELATION_TCLOSURE: return THEORY_SETS;
    case Kind::RELATION_JOIN_IMAGE: return THEORY_SETS;
    case Kind::RELATION_IDEN: return THEORY_SETS;
    case Kind::RELATION_TABLE_JOIN_OP: return THEORY_SETS;
    case Kind::RELATION_TABLE_JOIN: return THEORY_SETS;
    case Kind::SET_EMPTY_OF_TYPE: return THEORY_SETS;
    case Kind::BAG_EMPTY: return THEORY_BAGS;
    case Kind::BAG_TYPE: return THEORY_BAGS;
    case Kind::BAG_UNION_MAX: return THEORY_BAGS;
    case Kind::BAG_UNION_DISJOINT: return THEORY_BAGS;
    case Kind::BAG_INTER_MIN: return THEORY_BAGS;
    case Kind::BAG_DIFFERENCE_SUBTRACT: return THEORY_BAGS;
    case Kind::BAG_DIFFERENCE_REMOVE: return THEORY_BAGS;
    case Kind::BAG_SUBBAG: return THEORY_BAGS;
    case Kind::BAG_COUNT: return THEORY_BAGS;
    case Kind::BAG_MEMBER: return THEORY_BAGS;
    case Kind::BAG_SETOF: return THEORY_BAGS;
    case Kind::BAG_MAKE: return THEORY_BAGS;
    case Kind::BAG_CARD: return THEORY_BAGS;
    case Kind::BAG_CHOOSE: return THEORY_BAGS;
    case Kind::BAG_MAP: return THEORY_BAGS;
    case Kind::BAG_FILTER: return THEORY_BAGS;
    case Kind::BAG_ALL: return THEORY_BAGS;
    case Kind::BAG_SOME: return THEORY_BAGS;
    case Kind::BAG_FOLD: return THEORY_BAGS;
    case Kind::BAG_PARTITION: return THEORY_BAGS;
    case Kind::TABLE_PRODUCT: return THEORY_BAGS;
    case Kind::TABLE_PROJECT_OP: return THEORY_BAGS;
    case Kind::TABLE_PROJECT: return THEORY_BAGS;
    case Kind::TABLE_AGGREGATE_OP: return THEORY_BAGS;
    case Kind::TABLE_AGGREGATE: return THEORY_BAGS;
    case Kind::TABLE_JOIN_OP: return THEORY_BAGS;
    case Kind::TABLE_JOIN: return THEORY_BAGS;
    case Kind::TABLE_GROUP_OP: return THEORY_BAGS;
    case Kind::TABLE_GROUP: return THEORY_BAGS;
    case Kind::STRING_CONCAT: return THEORY_STRINGS;
    case Kind::STRING_IN_REGEXP: return THEORY_STRINGS;
    case Kind::STRING_LENGTH: return THEORY_STRINGS;
    case Kind::STRING_SUBSTR: return THEORY_STRINGS;
    case Kind::STRING_UPDATE: return THEORY_STRINGS;
    case Kind::STRING_CHARAT: return THEORY_STRINGS;
    case Kind::STRING_CONTAINS: return THEORY_STRINGS;
    case Kind::STRING_LT: return THEORY_STRINGS;
    case Kind::STRING_LEQ: return THEORY_STRINGS;
    case Kind::STRING_INDEXOF: return THEORY_STRINGS;
    case Kind::STRING_INDEXOF_RE: return THEORY_STRINGS;
    case Kind::STRING_REPLACE: return THEORY_STRINGS;
    case Kind::STRING_REPLACE_ALL: return THEORY_STRINGS;
    case Kind::STRING_REPLACE_RE: return THEORY_STRINGS;
    case Kind::STRING_REPLACE_RE_ALL: return THEORY_STRINGS;
    case Kind::STRING_PREFIX: return THEORY_STRINGS;
    case Kind::STRING_SUFFIX: return THEORY_STRINGS;
    case Kind::STRING_IS_DIGIT: return THEORY_STRINGS;
    case Kind::STRING_ITOS: return THEORY_STRINGS;
    case Kind::STRING_STOI: return THEORY_STRINGS;
    case Kind::STRING_TO_CODE: return THEORY_STRINGS;
    case Kind::STRING_FROM_CODE: return THEORY_STRINGS;
    case Kind::STRING_UNIT: return THEORY_STRINGS;
    case Kind::STRING_TO_LOWER: return THEORY_STRINGS;
    case Kind::STRING_TO_UPPER: return THEORY_STRINGS;
    case Kind::STRING_REV: return THEORY_STRINGS;
    case Kind::CONST_STRING: return THEORY_STRINGS;
    case Kind::SEQUENCE_TYPE: return THEORY_STRINGS;
    case Kind::CONST_SEQUENCE: return THEORY_STRINGS;
    case Kind::SEQ_UNIT: return THEORY_STRINGS;
    case Kind::SEQ_NTH: return THEORY_STRINGS;
    case Kind::STRING_TO_REGEXP: return THEORY_STRINGS;
    case Kind::REGEXP_CONCAT: return THEORY_STRINGS;
    case Kind::REGEXP_UNION: return THEORY_STRINGS;
    case Kind::REGEXP_INTER: return THEORY_STRINGS;
    case Kind::REGEXP_DIFF: return THEORY_STRINGS;
    case Kind::REGEXP_STAR: return THEORY_STRINGS;
    case Kind::REGEXP_PLUS: return THEORY_STRINGS;
    case Kind::REGEXP_OPT: return THEORY_STRINGS;
    case Kind::REGEXP_RANGE: return THEORY_STRINGS;
    case Kind::REGEXP_COMPLEMENT: return THEORY_STRINGS;
    case Kind::REGEXP_NONE: return THEORY_STRINGS;
    case Kind::REGEXP_ALL: return THEORY_STRINGS;
    case Kind::REGEXP_ALLCHAR: return THEORY_STRINGS;
    case Kind::REGEXP_REPEAT_OP: return THEORY_STRINGS;
    case Kind::REGEXP_REPEAT: return THEORY_STRINGS;
    case Kind::REGEXP_LOOP_OP: return THEORY_STRINGS;
    case Kind::REGEXP_LOOP: return THEORY_STRINGS;
    case Kind::REGEXP_RV: return THEORY_STRINGS;
    case Kind::SEQ_EMPTY_OF_TYPE: return THEORY_STRINGS;
    case Kind::FORALL: return THEORY_QUANTIFIERS;
    case Kind::EXISTS: return THEORY_QUANTIFIERS;
    case Kind::INST_CONSTANT: return THEORY_QUANTIFIERS;
    case Kind::ORACLE: return THEORY_QUANTIFIERS;
    case Kind::BOUND_VAR_LIST: return THEORY_QUANTIFIERS;
    case Kind::INST_PATTERN: return THEORY_QUANTIFIERS;
    case Kind::INST_NO_PATTERN: return THEORY_QUANTIFIERS;
    case Kind::INST_ATTRIBUTE: return THEORY_QUANTIFIERS;
    case Kind::INST_POOL: return THEORY_QUANTIFIERS;
    case Kind::INST_ADD_TO_POOL: return THEORY_QUANTIFIERS;
    case Kind::SKOLEM_ADD_TO_POOL: return THEORY_QUANTIFIERS;
    case Kind::ORACLE_FORMULA_GEN: return THEORY_QUANTIFIERS;
    case Kind::INST_PATTERN_LIST: return THEORY_QUANTIFIERS;

      // clang-format on
    case Kind::LAST_KIND: break;
  }
  throw IllegalArgumentException("", "k", __PRETTY_FUNCTION__, "bad kind");
}

TheoryId typeConstantToTheoryId(cvc5::internal::TypeConstant typeConstant)
{
  switch (typeConstant)
  {
    // clang-format off
    case BUILTIN_OPERATOR_TYPE: return THEORY_BUILTIN;
    case SEXPR_TYPE: return THEORY_BUILTIN;
    case BOOLEAN_TYPE: return THEORY_BOOL;
    case REAL_TYPE: return THEORY_ARITH;
    case INTEGER_TYPE: return THEORY_ARITH;
    case ROUNDINGMODE_TYPE: return THEORY_FP;
    case STRING_TYPE: return THEORY_STRINGS;
    case REGEXP_TYPE: return THEORY_STRINGS;
    case BOUND_VAR_LIST_TYPE: return THEORY_QUANTIFIERS;
    case INST_PATTERN_TYPE: return THEORY_QUANTIFIERS;
    case INST_PATTERN_LIST_TYPE: return THEORY_QUANTIFIERS;

      // clang-format on
    case LAST_TYPE: break;
  }
  throw IllegalArgumentException(
      "", "k", __PRETTY_FUNCTION__, "bad type constant");
}

}  // namespace theory
}  // namespace cvc5::internal
