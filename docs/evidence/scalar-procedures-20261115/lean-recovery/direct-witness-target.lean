module

public import Silver.FunctionDeclarationSource
public import Silver.ReviewedOutputShape
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem declaration_loop_function_locals :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.loops.get ⟨1, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  kernel_exact (Eq.refl (some
    (Silver.Compose.FunctionDeclarationNative.SourceChecks.loops.get ⟨1, by decide⟩).2))

end Silver.FunctionSourceCandidate.Parts
