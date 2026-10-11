import Silver
import Silver.AxiomAudit

-- Audit every declaration in the complete project, including private and
-- generated declarations. Focused checks invoke the same command after
-- importing only their selected modules and this reusable audit helper.
#silver_audit
