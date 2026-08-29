module Reflect.Auditor.Observation

import Core.BoxInt
import Core.Multiset
import Core.UnixelFraction
import Language.Reflection
import Observation.Algebraic
import Observation.Dataset
import Observation.Scientific
import Observation.Triad

%default total

------------------------------------------------------------------------
-- COMPILE-TIME REFLECTION AUDITS: OBSERVATION DOMAIN
------------------------------------------------------------------------

-- Witness 12: Multiset Born Rule & Hehner Triad
public export
auditMultisetHehnerTriadProofExport : Bool
auditMultisetHehnerTriadProofExport = Core.UnixelFraction.auditMultisetHehnerTriadProof

public export
%macro
auditMultisetHehnerTriad : Elab (Reflect.Auditor.Observation.auditMultisetHehnerTriadProofExport = True)
auditMultisetHehnerTriad = pure Refl

-- Witness 159: Empirical Scientific Observation Dataset Consistency
public export
auditScientificObservationDatasetProofExport : Bool
auditScientificObservationDatasetProofExport = Observation.Dataset.auditScientificObservationDatasetProof

public export
%macro
auditScientificObservationDataset : Elab (Reflect.Auditor.Observation.auditScientificObservationDatasetProofExport = True)
auditScientificObservationDataset = pure Refl

-- Witness 160: Algebraic Observation Catalog Completeness
public export
auditAlgebraicObservationCatalogProofExport : Bool
auditAlgebraicObservationCatalogProofExport = Observation.Algebraic.auditAlgebraicObservationCatalogProof

public export
%macro
auditAlgebraicObservationCatalog : Elab (Reflect.Auditor.Observation.auditAlgebraicObservationCatalogProofExport = True)
auditAlgebraicObservationCatalog = pure Refl

-- Witness 161: Cosmological Observation Triad 3-Way Soundness
public export
auditCosmologicalTriadProofExport : Bool
auditCosmologicalTriadProofExport = Observation.Triad.auditCosmologicalTriadProof

public export
%macro
auditCosmologicalTriad : Elab (Reflect.Auditor.Observation.auditCosmologicalTriadProofExport = True)
auditCosmologicalTriad = pure Refl
