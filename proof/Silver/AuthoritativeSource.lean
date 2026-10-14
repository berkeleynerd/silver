module

public import Silver.PathFactsSpecSource

public import Silver.IntegerLiteralSpecSource
public import Silver.IntegerLiteralBodySource

public import Silver.OutputLexicalBodySource
public import Silver.OutputLexicalSpecSource
public import Silver.ProfileSpecSource
public import Silver.ProfileBodySource
public import Silver.OutputProfileSpecSource
public import Silver.OutputProfileBodySource
public import Silver.IoSpecSource
public import Silver.IoBodySource
public import Silver.OutputLibcSpecSource
public import Silver.ArgumentsSpecSource
public import Silver.ArgumentsBodySource
public import Silver.RuntimeSpecSource

@[expose] public section

/-! Handwritten facade for the independently bound authoritative source files.
Each generated certificate imports only its own binding. This facade remains
part of the complete source bridge and fresh module/axiom audit. -/
