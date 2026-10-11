import Silver.OutputLexicalBodySource
import Silver.OutputLexicalSpecSource
import Silver.ProfileSpecSource
import Silver.ProfileBodySource
import Silver.OutputProfileSpecSource
import Silver.OutputProfileBodySource
import Silver.IoSpecSource
import Silver.IoBodySource
import Silver.OutputLibcSpecSource
import Silver.ArgumentsSpecSource
import Silver.ArgumentsBodySource
import Silver.RuntimeSpecSource

/-! Handwritten facade for the independently bound authoritative source files.
Each generated certificate imports only its own binding. This facade remains
part of the complete source bridge and fresh module/axiom audit. -/
