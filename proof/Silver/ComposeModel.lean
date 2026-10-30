module

public import Silver.ComposeModelEquations
public import Silver.ComposeModelRanges
public import Silver.ComposeModelLegal

@[expose] public section

/-! Independent mathematical model equations, range contracts and lexical-call
legality. Predicate.InheritedReady assembles the actual-source interpretation
on the native ready domain. The wider basic-domain model makes no claim about
native Boolean initializer calls outside their verified preconditions. -/
