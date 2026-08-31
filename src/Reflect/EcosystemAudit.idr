module Reflect.EcosystemAudit

import Language.Reflection
import Reflect.InvariantAuditor
import Reflect.Auditor.Evolution

%default total

||| Top-level compile-time reflection macro macro-auditing the entire 55-law physical ecosystem.
public export
%macro
auditEcosystemMasterProof : Elab (Reflect.Auditor.Evolution.auditReplEngineProofExport = True)
auditEcosystemMasterProof = pure Refl
