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
%inline
public export
auditMultisetHehnerTriadProofExport : Bool
auditMultisetHehnerTriadProofExport = Core.UnixelFraction.auditMultisetHehnerTriadProof


-- Witness 159: Empirical Scientific Observation Dataset Consistency
%inline
public export
auditScientificObservationDatasetProofExport : Bool
auditScientificObservationDatasetProofExport = Observation.Dataset.auditScientificObservationDatasetProof


-- Witness 160: Algebraic Observation Catalog Completeness
%inline
public export
auditAlgebraicObservationCatalogProofExport : Bool
auditAlgebraicObservationCatalogProofExport = Observation.Algebraic.auditAlgebraicObservationCatalogProof


-- Witness 161: Cosmological Observation Triad 3-Way Soundness
%inline
public export
auditCosmologicalTriadProofExport : Bool
auditCosmologicalTriadProofExport = Observation.Triad.auditCosmologicalTriadProof

