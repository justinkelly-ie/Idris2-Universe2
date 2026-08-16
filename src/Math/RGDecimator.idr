module Math.RGDecimator

import Core.BoxInt
import Core.Multiset
import Core.VexelMaxel
import Core.SingFraction
import Math.FourGeometries
import Data.List

%default total

------------------------------------------------------------------------
-- 1. CATEGORICAL RG DECIMATOR INTERFACE
------------------------------------------------------------------------

||| Categorical RG Decimator Interface:
||| Defines coarse-graining projections Pi: Micro -> Macro across discrete lattice scales
||| with determining parameter (| micro) and invariant preservation audit.
public export
interface RGDecimator micro macro | micro where
  decimate : micro -> macro
  isScaleInvariant : micro -> macro -> Bool

------------------------------------------------------------------------
-- 2. 2D & 3D DEC LATTICE BLOCK DECIMATOR
------------------------------------------------------------------------

||| 2x2 Micro Plaquette of 2-Form fluxes [f00, f01, f10, f11]
public export
record Plaquette2x2 where
  constructor MkPlaquette2x2
  f00 : BoxInt
  f01 : BoxInt
  f10 : BoxInt
  f11 : BoxInt

public export
Eq Plaquette2x2 where
  (MkPlaquette2x2 a b c d) == (MkPlaquette2x2 e f g h) =
    a == e && b == f && c == g && d == h

||| Macro Plaquette aggregated from 2x2 microcells:
||| Macro flux = f00 + f01 + f10 + f11
public export
record MacroPlaquette where
  constructor MkMacroPlaquette
  totalFlux : BoxInt

public export
Eq MacroPlaquette where
  (MkMacroPlaquette f1) == (MkMacroPlaquette f2) = f1 == f2

public export
RGDecimator Plaquette2x2 MacroPlaquette where
  decimate (MkPlaquette2x2 a b c d) =
    MkMacroPlaquette (a + b + c + d)
  isScaleInvariant (MkPlaquette2x2 a b c d) (MkMacroPlaquette m) =
    unwrapBox m == (unwrapBox a + unwrapBox b + unwrapBox c + unwrapBox d)

------------------------------------------------------------------------
-- 3. SCALE-INVARIANT TOPOLOGICAL FIXED POINT PRESERVATION
------------------------------------------------------------------------

||| Evaluates discrete topological First Chern Number over a list of decimated macro-plaquettes:
||| C_1 = sum_i MacroPlaquette_i.
public export
decimatedChernNumber : List MacroPlaquette -> BoxInt
decimatedChernNumber [] = intToBoxInt 0
decimatedChernNumber (MkMacroPlaquette f :: rest) = f + decimatedChernNumber rest

------------------------------------------------------------------------
-- 4. CONSTRUCTIVE FORMAL AUDIT PROOFS
--    (Categorical RG Decimator & Invariant Fixed Points)
------------------------------------------------------------------------

||| Audits 2x2 Block Decimation Additive Invariance:
||| For microcells with fluxes [1, 3, -1, 2]:
||| Macro cell flux = 1 + 3 - 1 + 2 = 5.
public export
auditPlaquetteDecimationProof : Bool
auditPlaquetteDecimationProof =
  let micro = MkPlaquette2x2 (intToBoxInt 1) (intToBoxInt 3) (intToBoxInt (-1)) (intToBoxInt 2)
      macro = decimate micro
  in unwrapBox (totalFlux macro) == 5 && isScaleInvariant micro macro

||| Audits Multi-Block Topological Fixed Point Conservation:
||| Proves total First Chern Number across two 2x2 micro-blocks (fluxes [1, 2, 0, 1] and [2, -1, 1, 1])
||| sums identically to 4 + 3 = 7 at macroscale.
public export
auditMultiBlockTopologicalFixedPointProof : Bool
auditMultiBlockTopologicalFixedPointProof =
  let b1 = MkPlaquette2x2 (intToBoxInt 1) (intToBoxInt 2) (intToBoxInt 0) (intToBoxInt 1)
      b2 = MkPlaquette2x2 (intToBoxInt 2) (intToBoxInt (-1)) (intToBoxInt 1) (intToBoxInt 1)
      m1 = decimate b1
      m2 = decimate b2
      cMacro = decimatedChernNumber [m1, m2]
  in unwrapBox cMacro == 7
