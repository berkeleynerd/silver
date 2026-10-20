/******************************************************************************
 * Top contributors (to current version):
 *   Aina Niemetz, Andres Noetzli, Mathias Preiner
 *
 * This file is part of the cvc5 project.
 *
 * Copyright (c) 2009-2025 by the authors listed in the file AUTHORS
 * in the top-level source directory and their institutional affiliations.
 * All rights reserved.  See the file COPYING in the top-level source
 * directory for licensing information.
 * ****************************************************************************
 *
 * Template for the Node kind header.
 */

#include "cvc5_public.h"

#ifndef CVC5__KIND_H
#define CVC5__KIND_H

#include <iosfwd>

#include "base/exception.h"
#include "theory/theory_id.h"

namespace cvc5::internal {
namespace kind {

enum class Kind_t
{
  UNDEFINED_KIND = -1, /**< undefined */
  NULL_EXPR,           /**< Null kind */
  // clang-format off
  /* from builtin */
  SORT_TYPE, /**< specifies types of user-declared 'uninterpreted' sorts (1) */
  INSTANTIATED_SORT_TYPE, /**< instantiated uninterpreted sort (2) */
  UNINTERPRETED_SORT_VALUE, /**< the kind of expressions representing uninterpreted sort values; payload is an instance of the cvc5::internal::AbstractValue class (used in models) (3) */
  BUILTIN, /**< the kind of expressions representing built-in operators (4) */
  EQUAL, /**< equality (two parameters only, sorts must match) (5) */
  VARIABLE, /**< a variable (not permitted in bindings) (6) */
  BOUND_VARIABLE, /**< a bound variable (permitted in bindings and the associated lambda and quantifier bodies only) (7) */
  SKOLEM, /**< a Skolem variable (8) */
  DUMMY_SKOLEM, /**< a Skolem variable (internal only) (9) */
  SEXPR, /**< a symbolic expression (any arity) (10) */
  WITNESS, /**< a witness expression; first parameter is a BOUND_VAR_LIST, second is the witness body (11) */
  TYPE_CONSTANT, /**< a representation for basic types (12) */
  RAW_SYMBOL, /**< a variable that is not quoted in the smt2 printer (internal only) (13) */
  ABSTRACT_TYPE, /**< abstract type (14) */
  APPLY_INDEXED_SYMBOLIC_OP, /**< operator for the bit-vector extract; payload is an instance of the cvc5::internal::GenericOp class (15) */
  APPLY_INDEXED_SYMBOLIC, /**< generic indexed operator, whose arguments are the list of terms corresponding to (symbolic) indices to the operator followed by its normal arguments (16) */
  SORT_TO_TERM, /**< term representing a sort; payload is an instance of the cvc5::internal::SortToTerm class (17) */
  TYPE_OF, /**< the type of an expression, used internally for RARE (18) */

  /* from booleans */
  CONST_BOOLEAN, /**< truth and falsity; payload is a (C++) bool (19) */
  NOT, /**< logical not (20) */
  AND, /**< logical and (N-ary) (21) */
  IMPLIES, /**< logical implication (exactly two parameters) (22) */
  OR, /**< logical or (N-ary) (23) */
  XOR, /**< exclusive or (exactly two parameters) (24) */
  ITE, /**< if-then-else, used for both Boolean and term ITE constructs; first parameter is (Boolean-sorted) condition, second is 'then', third is 'else' and these two parameters must have same base sort (25) */

  /* from uf */
  APPLY_UF, /**< application of an uninterpreted function; first parameter is the function, remaining ones are parameters to that function (26) */
  FUNCTION_TYPE, /**< a function type (27) */
  LAMBDA, /**< a lambda expression; first parameter is a BOUND_VAR_LIST, second is lambda body (28) */
  HO_APPLY, /**< higher-order (partial) function application (29) */
  CARDINALITY_CONSTRAINT_OP, /**< the cardinality constraint operator; payload is an instance of the cvc5::internal::CardinalityConstraint class (30) */
  CARDINALITY_CONSTRAINT, /**< a fixed upper bound on the cardinality of an uninterpreted sort (31) */
  COMBINED_CARDINALITY_CONSTRAINT_OP, /**< the combined cardinality constraint operator; payload is an instance of the cvc5::internal::CombinedCardinalityConstraint class (32) */
  COMBINED_CARDINALITY_CONSTRAINT, /**< a fixed upper bound on the sum of cardinalities of uninterpreted sorts (33) */
  FUNCTION_ARRAY_CONST, /**< the function constant; payload is an instance of the cvc5::internal::FunctionArrayConst class (34) */
  BITVECTOR_UBV_TO_INT, /**< bit-vector conversion to integer; parameter is treated as an unsigned bit-vector (35) */
  BITVECTOR_SBV_TO_INT, /**< bit-vector conversion to integer; parameter is treated as a signed bit-vector (36) */
  INT_TO_BITVECTOR_OP, /**< operator for the integer conversion to bit-vector; payload is an instance of the cvc5::internal::IntToBitVector class (37) */
  INT_TO_BITVECTOR, /**< integer conversion to bit-vector; first parameter is an INT_TO_BITVECTOR_OP, second is an integer term (38) */
  DISTINCT, /**< disequality (N-ary, sorts must match) (39) */

  /* from arith */
  ADD, /**< arithmetic addition (N-ary) (40) */
  MULT, /**< arithmetic multiplication (N-ary) (41) */
  NONLINEAR_MULT, /**< synonym for MULT (42) */
  SUB, /**< arithmetic binary subtraction operator (43) */
  NEG, /**< arithmetic unary negation (44) */
  DIVISION, /**< real division, division by 0 undefined (user symbol) (45) */
  DIVISION_TOTAL, /**< real division with interpreted division by 0 (internal symbol) (46) */
  INTS_DIVISION, /**< integer division, division by 0 undefined (user symbol) (47) */
  INTS_DIVISION_TOTAL, /**< integer division with interpreted division by 0 (internal symbol) (48) */
  INTS_MODULUS, /**< integer modulus, division by 0 undefined (user symbol) (49) */
  INTS_MODULUS_TOTAL, /**< integer modulus with interpreted division by 0 (internal symbol) (50) */
  ABS, /**< absolute value (51) */
  DIVISIBLE, /**< divisibility-by-k predicate; first parameter is a DIVISIBLE_OP, second is integer term (52) */
  POW, /**< arithmetic power (53) */
  POW2, /**< arithmetic power of 2 (54) */
  INTS_ISPOW2, /**< test if an integer is a power of 2 (55) */
  INTS_LOG2, /**< integer logarithm base 2 (round down to power of 2) (56) */
  EXPONENTIAL, /**< exponential (57) */
  SINE, /**< sine (58) */
  COSINE, /**< consine (59) */
  TANGENT, /**< tangent (60) */
  COSECANT, /**< cosecant (61) */
  SECANT, /**< secant (62) */
  COTANGENT, /**< cotangent (63) */
  ARCSINE, /**< arc sine (64) */
  ARCCOSINE, /**< arc consine (65) */
  ARCTANGENT, /**< arc tangent (66) */
  ARCCOSECANT, /**< arc cosecant (67) */
  ARCSECANT, /**< arc secant (68) */
  ARCCOTANGENT, /**< arc cotangent (69) */
  SQRT, /**< square root (70) */
  DIVISIBLE_OP, /**< operator for the divisibility-by-k predicate; payload is an instance of the cvc5::internal::Divisible class (71) */
  CONST_RATIONAL, /**< a multiple-precision rational constant; payload is an instance of the cvc5::internal::Rational class (72) */
  CONST_INTEGER, /**< a multiple-precision integer constant; payload is an instance of the cvc5::internal::Rational class (73) */
  REAL_ALGEBRAIC_NUMBER_OP, /**< a real algebraic number constant; payload is an instance of the cvc5::internal::RealAlgebraicNumber class (74) */
  REAL_ALGEBRAIC_NUMBER, /**< a real algebraic number constant; payload is an instance of the cvc5::internal::RealAlgebraicNumber class (75) */
  LT, /**< less than, x < y (76) */
  LEQ, /**< less than or equal, x <= y (77) */
  GT, /**< greater than, x > y (78) */
  GEQ, /**< greater than or equal, x >= y (79) */
  INDEXED_ROOT_PREDICATE_OP, /**< operator for the indexed root predicate; payload is an instance of the cvc5::internal::IndexedRootPredicate class (80) */
  INDEXED_ROOT_PREDICATE, /**< indexed root predicate; first parameter is a INDEXED_ROOT_PREDICATE_OP, second is a real variable compared to zero, third is a polynomial (81) */
  IS_INTEGER, /**< term-is-integer predicate (parameter is a real-sorted term) (82) */
  TO_INTEGER, /**< convert term to integer by the floor function (parameter is a real-sorted term) (83) */
  TO_REAL, /**< cast term to real (parameter is an integer-sorted term) (84) */
  PI, /**< pi (85) */
  IAND_OP, /**< operator for integer AND; payload is an instance of the cvc5::internal::IntAnd class (86) */
  IAND, /**< integer version of AND operator; first parameter is an IAND_OP, second and third are integer terms (87) */
  PIAND, /**< parametric integer version of AND operator (88) */

  /* from bv */
  BITVECTOR_TYPE, /**< bit-vector type (89) */
  CONST_BITVECTOR, /**< a fixed-width bit-vector constant; payload is an instance of the cvc5::internal::BitVector class (90) */
  BITVECTOR_FROM_BOOLS, /**< create bit-vector from vector of Booleans (91) */
  BITVECTOR_SIZE, /**< Size of bitvector (92) */
  CONST_BITVECTOR_SYMBOLIC, /**< A symbolic bitvector constant. The first argument is its value (an integer), and the second value is its size (also an integer). (93) */
  BITVECTOR_CONCAT, /**< concatenation of two or more bit-vectors (94) */
  BITVECTOR_AND, /**< bitwise and of two or more bit-vectors (95) */
  BITVECTOR_COMP, /**< equality comparison of two bit-vectors (returns one bit) (96) */
  BITVECTOR_OR, /**< bitwise or of two or more bit-vectors (97) */
  BITVECTOR_XOR, /**< bitwise xor of two or more bit-vectors (98) */
  BITVECTOR_NOT, /**< bitwise not of a bit-vector (99) */
  BITVECTOR_NAND, /**< bitwise nand of two bit-vectors (100) */
  BITVECTOR_NOR, /**< bitwise nor of two bit-vectors (101) */
  BITVECTOR_XNOR, /**< bitwise xnor of two bit-vectors (102) */
  BITVECTOR_MULT, /**< multiplication of two or more bit-vectors (103) */
  BITVECTOR_NEG, /**< unary negation of a bit-vector (104) */
  BITVECTOR_ADD, /**< addition of two or more bit-vectors (105) */
  BITVECTOR_SUB, /**< subtraction of two bit-vectors (106) */
  BITVECTOR_UDIV, /**< unsigned division of two bit-vectors, truncating towards 0 (defined to be the all-ones bit pattern, if divisor is 0) (107) */
  BITVECTOR_UREM, /**< unsigned remainder from truncating division of two bit-vectors (defined to be equal to the dividend, if divisor is 0) (108) */
  BITVECTOR_SDIV, /**< 2's complement signed division (109) */
  BITVECTOR_SMOD, /**< 2's complement signed remainder (sign follows divisor) (110) */
  BITVECTOR_SREM, /**< 2's complement signed remainder (sign follows dividend) (111) */
  BITVECTOR_ASHR, /**< bit-vector arithmetic shift right (the two bit-vector parameters must have same width) (112) */
  BITVECTOR_LSHR, /**< bit-vector logical shift right (the two bit-vector parameters must have same width) (113) */
  BITVECTOR_SHL, /**< bit-vector shift left (the two bit-vector parameters must have same width) (114) */
  BITVECTOR_ULE, /**< bit-vector unsigned less than or equal (the two bit-vector parameters must have same width) (115) */
  BITVECTOR_ULT, /**< bit-vector unsigned less than (the two bit-vector parameters must have same width) (116) */
  BITVECTOR_UGE, /**< bit-vector unsigned greater than or equal (the two bit-vector parameters must have same width) (117) */
  BITVECTOR_UGT, /**< bit-vector unsigned greater than (the two bit-vector parameters must have same width) (118) */
  BITVECTOR_SLE, /**< bit-vector signed less than or equal (the two bit-vector parameters must have same width) (119) */
  BITVECTOR_SLT, /**< bit-vector signed less than (the two bit-vector parameters must have same width) (120) */
  BITVECTOR_SGE, /**< bit-vector signed greater than or equal (the two bit-vector parameters must have same width) (121) */
  BITVECTOR_SGT, /**< bit-vector signed greater than (the two bit-vector parameters must have same width) (122) */
  BITVECTOR_ULTBV, /**< bit-vector unsigned less than but returns bv of size 1 instead of boolean (123) */
  BITVECTOR_SLTBV, /**< bit-vector signed less than but returns bv of size 1 instead of boolean (124) */
  BITVECTOR_REDAND, /**< bit-vector redand (125) */
  BITVECTOR_REDOR, /**< bit-vector redor (126) */
  BITVECTOR_NEGO, /**< bit-vector negation overflow predicate (127) */
  BITVECTOR_UADDO, /**< bit-vector unsigned addition overflow predicate (128) */
  BITVECTOR_SADDO, /**< bit-vector signed addition overflow predicate (129) */
  BITVECTOR_UMULO, /**< bit-vector unsigned multiplication overflow predicate (130) */
  BITVECTOR_SMULO, /**< bit-vector signed multiplication overflow predicate (131) */
  BITVECTOR_USUBO, /**< bit-vector unsigned subtraction overflow predicate (132) */
  BITVECTOR_SSUBO, /**< bit-vector signed subtraction overflow predicate (133) */
  BITVECTOR_SDIVO, /**< bit-vector signed division overflow predicate (134) */
  BITVECTOR_ITE, /**< same semantics as regular ITE, but condition is bv of size 1 instead of Boolean (135) */
  BITVECTOR_ACKERMANNIZE_UDIV, /**< term to be treated as a variable; used for eager bit-blasting Ackermann expansion of bvudiv (internal-only symbol) (136) */
  BITVECTOR_ACKERMANNIZE_UREM, /**< term to be treated as a variable; used for eager bit-blasting Ackermann expansion of bvurem (internal-only symbol) (137) */
  BITVECTOR_EAGER_ATOM, /**< formula to be treated as a bv atom via eager bit-blasting (internal-only symbol) (138) */
  BITVECTOR_BIT_OP, /**< operator for the bit-vector boolean bit extract; payload is an instance of the cvc5::internal::BitVectorBit class (139) */
  BITVECTOR_BIT, /**< bit-vector boolean bit extract; first parameter is a BITVECTOR_BIT_OP, second is a bit-vector term (140) */
  BITVECTOR_EXTRACT_OP, /**< operator for the bit-vector extract; payload is an instance of the cvc5::internal::BitVectorExtract class (141) */
  BITVECTOR_EXTRACT, /**< bit-vector extract; first parameter is a BITVECTOR_EXTRACT_OP, second is a bit-vector term (142) */
  BITVECTOR_REPEAT_OP, /**< operator for the bit-vector repeat; payload is an instance of the cvc5::internal::BitVectorRepeat class (143) */
  BITVECTOR_REPEAT, /**< bit-vector repeat; first parameter is a BITVECTOR_REPEAT_OP, second is a bit-vector term (144) */
  BITVECTOR_ROTATE_LEFT_OP, /**< operator for the bit-vector rotate left; payload is an instance of the cvc5::internal::BitVectorRotateLeft class (145) */
  BITVECTOR_ROTATE_LEFT, /**< bit-vector rotate left; first parameter is a BITVECTOR_ROTATE_LEFT_OP, second is a bit-vector term (146) */
  BITVECTOR_ROTATE_RIGHT_OP, /**< operator for the bit-vector rotate right; payload is an instance of the cvc5::internal::BitVectorRotateRight class (147) */
  BITVECTOR_ROTATE_RIGHT, /**< bit-vector rotate right; first parameter is a BITVECTOR_ROTATE_RIGHT_OP, second is a bit-vector term (148) */
  BITVECTOR_SIGN_EXTEND_OP, /**< operator for the bit-vector sign-extend; payload is an instance of the cvc5::internal::BitVectorSignExtend class (149) */
  BITVECTOR_SIGN_EXTEND, /**< bit-vector sign-extend; first parameter is a BITVECTOR_SIGN_EXTEND_OP, second is a bit-vector term (150) */
  BITVECTOR_ZERO_EXTEND_OP, /**< operator for the bit-vector zero-extend; payload is an instance of the cvc5::internal::BitVectorZeroExtend class (151) */
  BITVECTOR_ZERO_EXTEND, /**< bit-vector zero-extend; first parameter is a BITVECTOR_ZERO_EXTEND_OP, second is a bit-vector term (152) */

  /* from ff */
  FINITE_FIELD_TYPE, /**< finite field type (153) */
  CONST_FINITE_FIELD, /**< a finite-field constant; payload is an instance of the cvc5::internal::FiniteFieldValue class (154) */
  FINITE_FIELD_MULT, /**< multiplication of two or more field elements (155) */
  FINITE_FIELD_NEG, /**< unary negation of a field element (156) */
  FINITE_FIELD_ADD, /**< addition of two or more field elements (157) */
  FINITE_FIELD_BITSUM, /**< bitsum of field elements (158) */

  /* from fp */
  CONST_FLOATINGPOINT, /**< a floating-point literal (159) */
  CONST_ROUNDINGMODE, /**< a floating-point rounding mode (160) */
  FLOATINGPOINT_TYPE, /**< floating-point type (161) */
  FLOATINGPOINT_FP, /**< construct a floating-point literal from bit vectors (162) */
  FLOATINGPOINT_EQ, /**< floating-point equality (163) */
  FLOATINGPOINT_ABS, /**< floating-point absolute value (164) */
  FLOATINGPOINT_NEG, /**< floating-point negation (165) */
  FLOATINGPOINT_ADD, /**< floating-point addition (166) */
  FLOATINGPOINT_SUB, /**< floating-point sutraction (167) */
  FLOATINGPOINT_MULT, /**< floating-point multiply (168) */
  FLOATINGPOINT_DIV, /**< floating-point division (169) */
  FLOATINGPOINT_FMA, /**< floating-point fused multiply and add (170) */
  FLOATINGPOINT_SQRT, /**< floating-point square root (171) */
  FLOATINGPOINT_REM, /**< floating-point remainder (172) */
  FLOATINGPOINT_RTI, /**< floating-point round to integral (173) */
  FLOATINGPOINT_MIN, /**< floating-point minimum (174) */
  FLOATINGPOINT_MAX, /**< floating-point maximum (175) */
  FLOATINGPOINT_MIN_TOTAL, /**< floating-point minimum (defined for all inputs) (176) */
  FLOATINGPOINT_MAX_TOTAL, /**< floating-point maximum (defined for all inputs) (177) */
  FLOATINGPOINT_LEQ, /**< floating-point less than or equal (178) */
  FLOATINGPOINT_LT, /**< floating-point less than (179) */
  FLOATINGPOINT_GEQ, /**< floating-point greater than or equal (180) */
  FLOATINGPOINT_GT, /**< floating-point greater than (181) */
  FLOATINGPOINT_IS_NORMAL, /**< floating-point is normal (182) */
  FLOATINGPOINT_IS_SUBNORMAL, /**< floating-point is sub-normal (183) */
  FLOATINGPOINT_IS_ZERO, /**< floating-point is zero (184) */
  FLOATINGPOINT_IS_INF, /**< floating-point is infinite (185) */
  FLOATINGPOINT_IS_NAN, /**< floating-point is NaN (186) */
  FLOATINGPOINT_IS_NEG, /**< floating-point is negative (187) */
  FLOATINGPOINT_IS_POS, /**< floating-point is positive (188) */
  FLOATINGPOINT_TO_FP_FROM_IEEE_BV_OP, /**< operator for to_fp from bit vector (189) */
  FLOATINGPOINT_TO_FP_FROM_IEEE_BV, /**< convert an IEEE-754 bit vector to floating-point (190) */
  FLOATINGPOINT_TO_FP_FROM_FP_OP, /**< operator for to_fp from floating point (191) */
  FLOATINGPOINT_TO_FP_FROM_FP, /**< convert between floating-point sorts (192) */
  FLOATINGPOINT_TO_FP_FROM_REAL_OP, /**< operator for to_fp from real (193) */
  FLOATINGPOINT_TO_FP_FROM_REAL, /**< convert a real to floating-point (194) */
  FLOATINGPOINT_TO_FP_FROM_SBV_OP, /**< operator for to_fp from signed bit vector (195) */
  FLOATINGPOINT_TO_FP_FROM_SBV, /**< convert a signed bit vector to floating-point (196) */
  FLOATINGPOINT_TO_FP_FROM_UBV_OP, /**< operator for to_fp from unsigned bit vector (197) */
  FLOATINGPOINT_TO_FP_FROM_UBV, /**< convert an unsigned bit vector to floating-point (198) */
  FLOATINGPOINT_TO_UBV_OP, /**< operator for to_ubv (199) */
  FLOATINGPOINT_TO_UBV, /**< convert a floating-point value to an unsigned bit vector (200) */
  FLOATINGPOINT_TO_UBV_TOTAL_OP, /**< operator for to_ubv_total (201) */
  FLOATINGPOINT_TO_UBV_TOTAL, /**< convert a floating-point value to an unsigned bit vector (defined for all inputs) (202) */
  FLOATINGPOINT_TO_SBV_OP, /**< operator for to_sbv (203) */
  FLOATINGPOINT_TO_SBV, /**< convert a floating-point value to a signed bit vector (204) */
  FLOATINGPOINT_TO_SBV_TOTAL_OP, /**< operator for to_sbv_total (205) */
  FLOATINGPOINT_TO_SBV_TOTAL, /**< convert a floating-point value to a signed bit vector (defined for all inputs) (206) */
  FLOATINGPOINT_TO_REAL, /**< floating-point to real (207) */
  FLOATINGPOINT_TO_REAL_TOTAL, /**< floating-point to real (defined for all inputs) (208) */
  FLOATINGPOINT_COMPONENT_NAN, /**< NaN component of a word-blasted floating-point number (209) */
  FLOATINGPOINT_COMPONENT_INF, /**< Inf component of a word-blasted floating-point number (210) */
  FLOATINGPOINT_COMPONENT_ZERO, /**< Zero component of a word-blasted floating-point number (211) */
  FLOATINGPOINT_COMPONENT_SIGN, /**< Sign component of a word-blasted floating-point number (212) */
  FLOATINGPOINT_COMPONENT_EXPONENT, /**< Exponent component of a word-blasted floating-point number (213) */
  FLOATINGPOINT_COMPONENT_SIGNIFICAND, /**< Significand component of a word-blasted floating-point number (214) */
  ROUNDINGMODE_BITBLAST, /**< The bit-vector for a non-deterministic rounding mode (215) */

  /* from arrays */
  ARRAY_TYPE, /**< array type (216) */
  SELECT, /**< array select; first parameter is an array term, second is the selection index (217) */
  STORE, /**< array store; first parameter is an array term, second is the store index, third is the term to store at the index (218) */
  EQ_RANGE, /**< equality of two arrays over an index range lower/upper (219) */
  STORE_ALL, /**< array store-all; payload is an instance of the cvc5::internal::ArrayStoreAll class (this is not supported by arrays decision procedure yet, but it is used for returned array models) (220) */
  ARRAY_LAMBDA, /**< array lambda (internal-only symbol) (221) */

  /* from datatypes */
  CONSTRUCTOR_TYPE, /**< constructor (222) */
  SELECTOR_TYPE, /**< selector (223) */
  TESTER_TYPE, /**< tester (224) */
  UPDATER_TYPE, /**< datatype update (225) */
  APPLY_CONSTRUCTOR, /**< constructor application; first parameter is the constructor, remaining parameters (if any) are parameters to the constructor (226) */
  APPLY_SELECTOR, /**< selector application; parameter is a datatype term (undefined if mis-applied) (227) */
  APPLY_TESTER, /**< tester application; first parameter is a tester, second is a datatype term (228) */
  APPLY_UPDATER, /**< datatype updater application; first parameter is an update, second is a datatype term to update, third is the value to update with (229) */
  DATATYPE_TYPE, /**<  (230) */
  PARAMETRIC_DATATYPE, /**< parametric datatype (231) */
  TUPLE_TYPE, /**< tuple type (232) */
  APPLY_TYPE_ASCRIPTION, /**< type ascription, for datatype constructor applications; first parameter is an ASCRIPTION_TYPE, second is the datatype constructor application being ascribed (233) */
  ASCRIPTION_TYPE, /**< a type parameter for type ascription; payload is an instance of the cvc5::internal::AscriptionType class (234) */
  DT_SIZE, /**< datatypes size (235) */
  DT_HEIGHT_BOUND, /**< datatypes height bound (236) */
  DT_SIZE_BOUND, /**< datatypes height bound (237) */
  DT_SYGUS_BOUND, /**< datatypes sygus bound (238) */
  DT_SYGUS_EVAL, /**< datatypes sygus evaluation function (239) */
  MATCH, /**< match construct (240) */
  MATCH_CASE, /**< a match case (241) */
  MATCH_BIND_CASE, /**< a match case with bound variables (242) */
  TUPLE_PROJECT_OP, /**< operator for TUPLE_PROJECT; payload is an instance of the cvc5::internal::ProjectOp class (243) */
  TUPLE_PROJECT, /**< projects a tuple from an existing tuple using indices passed in TupleProjectOp (244) */
  CODATATYPE_BOUND_VARIABLE, /**< the kind of expressions representing bound variables in codatatype constants, which are de Bruijn indexed variables; payload is an instance of the cvc5::internal::CodatatypeBoundVariable class (used in models) (245) */
  NULLABLE_TYPE, /**< nullable type (246) */
  NULLABLE_LIFT, /**< application of lift operator; first parameter is the lift operator, remaining ones are its arguments (247) */

  /* from sep */
  SEP_NIL, /**< separation nil (248) */
  SEP_EMP, /**< separation logic empty heap constraint (249) */
  SEP_PTO, /**< points to relation (250) */
  SEP_STAR, /**< separation star (251) */
  SEP_WAND, /**< separation magic wand (252) */
  SEP_LABEL, /**< separation label (internal use only) (253) */

  /* from sets */
  SET_EMPTY, /**< the empty set constant; payload is an instance of the cvc5::internal::EmptySet class (254) */
  SET_TYPE, /**< set type, takes as parameter the type of the elements (255) */
  SET_UNION, /**< set union (256) */
  SET_INTER, /**< set intersection (257) */
  SET_MINUS, /**< set subtraction (258) */
  SET_SUBSET, /**< subset predicate; first parameter a subset of second (259) */
  SET_MEMBER, /**< set membership predicate; first parameter a member of second (260) */
  SET_SINGLETON, /**< constructs a set of a single element. First parameter is a term (261) */
  SET_INSERT, /**< set obtained by inserting elements (first N-1 parameters) into a set (the last parameter) (262) */
  SET_CARD, /**< set cardinality operator (263) */
  SET_COMPLEMENT, /**< set complement (with respect to finite universe) (264) */
  SET_UNIVERSE, /**< (finite) universe set, all set variables must be interpreted as subsets of it. (265) */
  SET_COMPREHENSION, /**< set comprehension specified by a bound variable list, a predicate, and a term. (266) */
  SET_CHOOSE, /**< return an element in the set given as a parameter (267) */
  SET_IS_EMPTY, /**< return whether the given set is empty (268) */
  SET_IS_SINGLETON, /**< return whether the given set is a singleton (269) */
  SET_MAP, /**< set map function (270) */
  SET_FILTER, /**< set filter operator (271) */
  SET_ALL, /**< set all operator (272) */
  SET_SOME, /**< set some operator (273) */
  SET_FOLD, /**< set fold operator (274) */
  RELATION_GROUP_OP, /**< operator for RELATION_GROUP; payload is an instance of the cvc5::internal::ProjectOp class (275) */
  RELATION_GROUP, /**< relation group (276) */
  RELATION_AGGREGATE_OP, /**< operator for RELATION_AGGREGATE; payload is an instance of the cvc5::internal::ProjectOp class (277) */
  RELATION_AGGREGATE, /**< relation aggregate (278) */
  RELATION_PROJECT_OP, /**< operator for RELATION_PROJECT; payload is an instance of the cvc5::internal::ProjectOp class (279) */
  RELATION_PROJECT, /**< relation projection (280) */
  RELATION_JOIN, /**< relation join (281) */
  RELATION_PRODUCT, /**< relation cartesian product (282) */
  RELATION_TRANSPOSE, /**< relation transpose (283) */
  RELATION_TCLOSURE, /**< relation transitive closure (284) */
  RELATION_JOIN_IMAGE, /**< relation join image (285) */
  RELATION_IDEN, /**< relation identity (286) */
  RELATION_TABLE_JOIN_OP, /**< operator for RELATION_TABLE_JOIN; payload is an instance of the cvc5::internal::ProjectOp class (287) */
  RELATION_TABLE_JOIN, /**< relation table join (288) */
  SET_EMPTY_OF_TYPE, /**< the empty set whose argument represents its type (289) */

  /* from bags */
  BAG_EMPTY, /**< the empty bag constant; payload is an instance of the cvc5::internal::EmptyBag class (290) */
  BAG_TYPE, /**< bag type, takes as parameter the type of the elements (291) */
  BAG_UNION_MAX, /**< union for bags (max) (292) */
  BAG_UNION_DISJOINT, /**< disjoint union for bags (sum) (293) */
  BAG_INTER_MIN, /**< bag intersection (min) (294) */
  BAG_DIFFERENCE_SUBTRACT, /**< bag difference1 (subtracts multiplicities) (295) */
  BAG_DIFFERENCE_REMOVE, /**< bag difference remove (removes shared elements) (296) */
  BAG_SUBBAG, /**< inclusion predicate for bags (less than or equal multiplicities) (297) */
  BAG_COUNT, /**< multiplicity of an element in a bag (298) */
  BAG_MEMBER, /**< bag membership predicate; is first parameter a member of second? (299) */
  BAG_SETOF, /**< eliminate duplicates in a bag (also known as the delta operator,or the squash operator) (300) */
  BAG_MAKE, /**< constructs a bag from one element along with its multiplicity (301) */
  BAG_CARD, /**< bag cardinality operator (302) */
  BAG_CHOOSE, /**< return an element in the bag given as a parameter (303) */
  BAG_MAP, /**< bag map function (304) */
  BAG_FILTER, /**< bag filter operator (305) */
  BAG_ALL, /**< bag all operator (306) */
  BAG_SOME, /**< bag some operator (307) */
  BAG_FOLD, /**< bag fold operator (308) */
  BAG_PARTITION, /**< bag partition operator (309) */
  TABLE_PRODUCT, /**< table cross product (310) */
  TABLE_PROJECT_OP, /**< operator for TABLE_PROJECT; payload is an instance of the cvc5::internal::ProjectOp class (311) */
  TABLE_PROJECT, /**< table projection (312) */
  TABLE_AGGREGATE_OP, /**< operator for TABLE_AGGREGATE; payload is an instance of the cvc5::internal::ProjectOp class (313) */
  TABLE_AGGREGATE, /**< table aggregate (314) */
  TABLE_JOIN_OP, /**< operator for TABLE_JOIN; payload is an instance of the cvc5::internal::ProjectOp class (315) */
  TABLE_JOIN, /**< table join (316) */
  TABLE_GROUP_OP, /**< operator for TABLE_GROUP; payload is an instance of the cvc5::internal::ProjectOp class (317) */
  TABLE_GROUP, /**< table group (318) */

  /* from strings */
  STRING_CONCAT, /**< string concat (N-ary) (319) */
  STRING_IN_REGEXP, /**< membership (320) */
  STRING_LENGTH, /**< string length (321) */
  STRING_SUBSTR, /**< string substr (322) */
  STRING_UPDATE, /**< string update (323) */
  STRING_CHARAT, /**< string charat (324) */
  STRING_CONTAINS, /**< string contains (325) */
  STRING_LT, /**< string less than (326) */
  STRING_LEQ, /**< string less than or equal (327) */
  STRING_INDEXOF, /**< string index of substring (328) */
  STRING_INDEXOF_RE, /**< string index of regular expression match (329) */
  STRING_REPLACE, /**< string replace (330) */
  STRING_REPLACE_ALL, /**< string replace all (331) */
  STRING_REPLACE_RE, /**< string replace regular expression match (332) */
  STRING_REPLACE_RE_ALL, /**< string replace all regular expression matches (333) */
  STRING_PREFIX, /**< string prefixof (334) */
  STRING_SUFFIX, /**< string suffixof (335) */
  STRING_IS_DIGIT, /**< string isdigit, returns true if argument is a string of length one that represents a digit (336) */
  STRING_ITOS, /**< integer to string (337) */
  STRING_STOI, /**< string to integer (total function) (338) */
  STRING_TO_CODE, /**< string to code, returns the code of the first character of the string if it has length one, -1 otherwise (339) */
  STRING_FROM_CODE, /**< string from code, returns a string containing a single character whose code point matches the argument to this function, empty string if the argument is not a valid code point (340) */
  STRING_UNIT, /**< string unit, returns a string containing a single character whose code point matches the argument to this function, arbitrary string of length one if the argument is not a valid code point (341) */
  STRING_TO_LOWER, /**< string to lowercase conversion (342) */
  STRING_TO_UPPER, /**< string to uppercase conversion (343) */
  STRING_REV, /**< string reverse (344) */
  CONST_STRING, /**< a string of characters (345) */
  SEQUENCE_TYPE, /**< sequence type, takes as parameter the type of the elements (346) */
  CONST_SEQUENCE, /**< a sequence of characters (347) */
  SEQ_UNIT, /**< a sequence of length one. First parameter is a term (348) */
  SEQ_NTH, /**< The nth element of a sequence (349) */
  STRING_TO_REGEXP, /**< convert string to regexp (350) */
  REGEXP_CONCAT, /**< regexp concat (351) */
  REGEXP_UNION, /**< regexp union (352) */
  REGEXP_INTER, /**< regexp intersection (353) */
  REGEXP_DIFF, /**< regexp difference (354) */
  REGEXP_STAR, /**< regexp * (355) */
  REGEXP_PLUS, /**< regexp + (356) */
  REGEXP_OPT, /**< regexp ? (357) */
  REGEXP_RANGE, /**< regexp range (358) */
  REGEXP_COMPLEMENT, /**< regexp complement (359) */
  REGEXP_NONE, /**< regexp empty (360) */
  REGEXP_ALL, /**< regexp all (361) */
  REGEXP_ALLCHAR, /**< regexp all characters (362) */
  REGEXP_REPEAT_OP, /**< operator for regular expression repeat; payload is an instance of the cvc5::internal::RegExpRepeat class (363) */
  REGEXP_REPEAT, /**< regular expression repeat; first parameter is a REGEXP_REPEAT_OP, second is a regular expression term (364) */
  REGEXP_LOOP_OP, /**< operator for regular expression loop; payload is an instance of the cvc5::internal::RegExpLoop class (365) */
  REGEXP_LOOP, /**< regular expression loop; first parameter is a REGEXP_LOOP_OP, second is a regular expression term (366) */
  REGEXP_RV, /**< regexp rv (internal use only) (367) */
  SEQ_EMPTY_OF_TYPE, /**< the empty sequence whose argument represents its type (368) */

  /* from quantifiers */
  FORALL, /**< universally quantified formula; first parameter is an BOUND_VAR_LIST, second is quantifier body, and an optional third parameter is an INST_PATTERN_LIST (369) */
  EXISTS, /**< existentially quantified formula; first parameter is an BOUND_VAR_LIST, second is quantifier body, and an optional third parameter is an INST_PATTERN_LIST (370) */
  INST_CONSTANT, /**< instantiation constant (371) */
  ORACLE, /**< oracle (372) */
  BOUND_VAR_LIST, /**< a list of bound variables (used to bind variables under a quantifier) (373) */
  INST_PATTERN, /**< instantiation pattern (374) */
  INST_NO_PATTERN, /**< instantiation no-pattern (375) */
  INST_ATTRIBUTE, /**< instantiation attribute (376) */
  INST_POOL, /**< instantiation pool (377) */
  INST_ADD_TO_POOL, /**< instantiation add to pool (378) */
  SKOLEM_ADD_TO_POOL, /**< skolemization add to pool (379) */
  ORACLE_FORMULA_GEN, /**< oracle interface (380) */
  INST_PATTERN_LIST, /**< a list of instantiation patterns (381) */

 LAST_KIND /**< marks the upper-bound of this enumeration */
  // clang-format on

}; /* enum Kind_t */

}  // namespace kind

// import Kind into the "cvc5" namespace but keep the individual kind
// constants under kind::
typedef cvc5::internal::kind::Kind_t Kind;

namespace kind {

/**
 * Converts an kind to a string. Note: This function is also used in
 * `safe_print()`. Changing this functions name or signature will result in
 * `safe_print()` printing "<unsupported>" instead of the proper strings for
 * the enum values.
 *
 * @param k The kind
 * @return The name of the kind
 */
const char* toString(cvc5::internal::Kind k);

/**
 * Writes a kind name to a stream.
 *
 * @param out The stream to write to
 * @param k The kind to write to the stream
 * @return The stream
 */
std::ostream& operator<<(std::ostream&, cvc5::internal::Kind);

/** Returns true if the given kind is associative. This is used by ExprManager to
 * decide whether it's safe to modify big expressions by changing the grouping of
 * the arguments. */
/* TODO: This could be generated. */
bool isAssociative(cvc5::internal::Kind k);
std::string kindToString(cvc5::internal::Kind k);

/** Return true if k is a closure kind. */
bool isClosureKind(cvc5::internal::Kind k);

struct KindHashFunction
{
  inline size_t operator()(cvc5::internal::Kind k) const
  {
    return static_cast<size_t>(k);
  }
}; /* struct KindHashFunction */

}  // namespace kind

/**
 * The enumeration for the built-in atomic types.
 */
enum TypeConstant
{
  // clang-format off
    BUILTIN_OPERATOR_TYPE, /**< the type for built-in operators*/
  SEXPR_TYPE, /**< the type of a symbolic expression*/
  BOOLEAN_TYPE, /**< Boolean type*/
  REAL_TYPE, /**< real type*/
  INTEGER_TYPE, /**< integer type*/
  ROUNDINGMODE_TYPE, /**< floating-point rounding mode*/
  STRING_TYPE, /**< String type*/
  REGEXP_TYPE, /**< RegExp type*/
  BOUND_VAR_LIST_TYPE, /**< the type of bound variable lists*/
  INST_PATTERN_TYPE, /**< instantiation pattern type*/
  INST_PATTERN_LIST_TYPE, /**< the type of instantiation pattern lists*/
 LAST_TYPE
  // clang-format on
}; /* enum TypeConstant */

/**
 * We hash the constants with their values.
 */
struct TypeConstantHashFunction
{
  inline size_t operator()(TypeConstant tc) const { return tc; }
}; /* struct TypeConstantHashFunction */

const char* toString(TypeConstant tc);
std::ostream& operator<<(std::ostream& out, TypeConstant typeConstant);

namespace theory {

cvc5::internal::theory::TheoryId kindToTheoryId(cvc5::internal::Kind k);
cvc5::internal::theory::TheoryId typeConstantToTheoryId(
    cvc5::internal::TypeConstant typeConstant);

}  // namespace theory
}  // namespace cvc5::internal

#endif /* CVC5__KIND_H */
