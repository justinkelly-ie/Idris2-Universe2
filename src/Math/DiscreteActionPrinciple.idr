module Math.DiscreteActionPrinciple

import Core.BoxInt
import Core.VexelMaxel
import Math.LinAlgebra.MetricTensor
import Math.FourGeometries
import Data.Vect
import Data.List

%default total

------------------------------------------------------------------------
-- 1. DISCRETE LATTICE TRAJECTORY & VARIATIONAL ACTION SUM
------------------------------------------------------------------------

||| A 2D spatial coordinate on the discrete lattice.
public export
Coord2D : Type
Coord2D = (BoxInt, BoxInt)

||| Difference vector between two lattice coordinates: Δx = x_{k+1} - x_k.
public export
coordDiff : Coord2D -> Coord2D -> Coord2D
coordDiff (x2, y2) (x1, y1) = (x2 - x1, y2 - y1)

||| Computes metric kinetic quadrance: T_g(Δx) = Δx^T · g · Δx.
public export
metricKineticQuadrance : MaxelMetric -> Coord2D -> BoxInt
metricKineticQuadrance (MkMaxelMetric g11 g12 g21 g22) (dx, dy) =
  let row1 = (g11 * dx) + (g12 * dy)
      row2 = (g21 * dx) + (g22 * dy)
  in (dx * row1) + (dy * row2)

||| Discrete Lagrangian: L(x_k, x_{k+1}) = T_g(Δx) + SubstrateCoupling(x_k, x_{k+1}) - V(x_k).
public export
discreteLagrangian : FundamentalGeometry -> Coord2D -> Coord2D -> (Coord2D -> BoxInt) -> BoxInt
discreteLagrangian geom (x1, y1) (x2, y2) vPot =
  let metric = geometryToMetric geom
      diff = (x2 - x1, y2 - y1)
      tKin = metricKineticQuadrance metric diff
      vVal = vPot (x1, y1)
      -- Substrate geometry adds asymmetric causal coupling: (x_{k+1} - x_k) * y_k
      causalCoupling = case geom of
                         SubstrateGeom => (x2 - x1) * y1
                         _             => intToBoxInt 0
  in (tKin + causalCoupling) - vVal

||| Computes the Discrete Action S[γ] along an ordered sequence of coordinates.
public export
discreteAction : FundamentalGeometry -> List Coord2D -> (Coord2D -> BoxInt) -> BoxInt
discreteAction _ [] _ = intToBoxInt 0
discreteAction _ [x] _ = intToBoxInt 0
discreteAction geom (x0 :: x1 :: xs) vPot =
  discreteLagrangian geom x0 x1 vPot + discreteAction geom (x1 :: xs) vPot

------------------------------------------------------------------------
-- 2. DISCRETE EULER-LAGRANGE EQUATIONS (DEL)
--    g · (x_{k+1} - 2x_k + x_{k-1}) = -∇V(x_k)  (Discrete F = ma)
------------------------------------------------------------------------

||| Discrete second-order difference / acceleration: Δ²x = x_{k+1} - 2x_k + x_{k-1}.
public export
discreteAcceleration : Coord2D -> Coord2D -> Coord2D -> Coord2D
discreteAcceleration (xPrev, yPrev) (xCurr, yCurr) (xNext, yNext) =
  ( xNext - (intToBoxInt 2 * xCurr) + xPrev
  , yNext - (intToBoxInt 2 * yCurr) + yPrev
  )

||| Discrete Euler-Lagrange residual: g · Δ²x + ∇V(x_k).
||| For extremal physical trajectories, this residual evaluates strictly to (0, 0).
public export
discreteEulerLagrangeResidual : MaxelMetric -> Coord2D -> Coord2D -> Coord2D -> Coord2D -> Coord2D
discreteEulerLagrangeResidual (MkMaxelMetric g11 g12 g21 g22) prev curr next (gradVx, gradVy) =
  let (ax, ay) = discreteAcceleration prev curr next
      forceX = (g11 * ax) + (g12 * ay) + gradVx
      forceY = (g21 * ax) + (g22 * ay) + gradVy
  in (forceX, forceY)

------------------------------------------------------------------------
-- 3. CONSTRUCTIVE FORMAL AUDIT PROOFS
------------------------------------------------------------------------

||| Zero potential function for free particle trajectories.
public export
zeroPotential : Coord2D -> BoxInt
zeroPotential _ = intToBoxInt 0

||| Linear potential gradient: V(x, y) = x -> ∇V = (1, 0).
public export
linearPotentialGrad : Coord2D
linearPotentialGrad = (intToBoxInt 1, intToBoxInt 0)

||| Audits Discrete Euler-Lagrange (DEL) Equivalence:
||| Free particle uniform motion [(0,0), (1,1), (2,2)] satisfies DEL with zero residual:
||| g_Ell · Δ²x + ∇V = (0, 0).
public export
auditDiscreteEulerLagrangeEquivalenceProof : Bool
auditDiscreteEulerLagrangeEquivalenceProof =
  let p0 = (intToBoxInt 0, intToBoxInt 0)
      p1 = (intToBoxInt 1, intToBoxInt 1)
      p2 = (intToBoxInt 2, intToBoxInt 2)
      metric = geometryToMetric EllipticGeom
      (resX, resY) = discreteEulerLagrangeResidual metric p0 p1 p2 (intToBoxInt 0, intToBoxInt 0)
  in unwrapBox resX == 0 && unwrapBox resY == 0

||| Audits Substrate Action Asymmetry (The Causal Arrow of Time in Hamilton's Principle):
||| Proves that under SubstrateGeom, S[forward] ≠ S[reverse] for path [(0,0) -> (1,2)]:
||| S[(0,0) -> (1,2)] = 5, whereas S[(1,2) -> (0,0)] = 3.
public export
auditSubstrateActionAsymmetryProof : Bool
auditSubstrateActionAsymmetryProof =
  let p0 = (intToBoxInt 0, intToBoxInt 0)
      p1 = (intToBoxInt 1, intToBoxInt 2)
      sForward = discreteAction SubstrateGeom [p0, p1] zeroPotential
      sReverse = discreteAction SubstrateGeom [p1, p0] zeroPotential
  in unwrapBox sForward == 5 &&
     unwrapBox sReverse == 3 &&
     unwrapBox (sForward - sReverse) == 2

||| Computes discrete canonical momentum token: p_k = g · (x_{k+1} - x_k).
public export
discreteCanonicalMomentum : MaxelMetric -> Coord2D -> Coord2D -> Coord2D
discreteCanonicalMomentum (MkMaxelMetric g11 g12 g21 g22) (x1, y1) (x2, y2) =
  let dx = x2 - x1
      dy = y2 - y1
      px = (g11 * dx) + (g12 * dy)
      py = (g21 * dx) + (g22 * dy)
  in (px, py)

||| Audits Geodesic Least Action Optimality:
||| Proves that the straight geodesic path [(0,0), (1,1), (2,2)] strictly minimizes
||| Action over the deflected path [(0,0), (0,2), (2,2)]: S_straight (4) < S_perturbed (8).
public export
auditGeodesicLeastActionOptimalityProof : Bool
auditGeodesicLeastActionOptimalityProof =
  let straightPath = [ (intToBoxInt 0, intToBoxInt 0)
                     , (intToBoxInt 1, intToBoxInt 1)
                     , (intToBoxInt 2, intToBoxInt 2)
                     ]
      perturbedPath = [ (intToBoxInt 0, intToBoxInt 0)
                      , (intToBoxInt 0, intToBoxInt 2)
                      , (intToBoxInt 2, intToBoxInt 2)
                      ]
      sStraight = discreteAction EllipticGeom straightPath zeroPotential
      sPerturbed = discreteAction EllipticGeom perturbedPath zeroPotential
  in unwrapBox sStraight == 4 &&
     unwrapBox sPerturbed == 8 &&
     unwrapBox sStraight < unwrapBox sPerturbed

||| Audits Discrete Noether Momentum Conservation:
||| Proves that for free motion along a geodesic, discrete momentum p_k = g · Δx
||| is strictly identical across consecutive steps: p_0 = (1, 1) == p_1 = (1, 1).
public export
auditDiscreteMomentumConservationProof : Bool
auditDiscreteMomentumConservationProof =
  let p0 = (intToBoxInt 0, intToBoxInt 0)
      p1 = (intToBoxInt 1, intToBoxInt 1)
      p2 = (intToBoxInt 2, intToBoxInt 2)
      metric = geometryToMetric EllipticGeom
      (p0x, p0y) = discreteCanonicalMomentum metric p0 p1
      (p1x, p1y) = discreteCanonicalMomentum metric p1 p2
  in unwrapBox p0x == 1 && unwrapBox p0y == 1 &&
     unwrapBox p1x == 1 && unwrapBox p1y == 1 &&
     unwrapBox p0x == unwrapBox p1x &&
     unwrapBox p0y == unwrapBox p1y

||| Audits Parabolic Null Momentum Zero Invariant:
||| Proves that in Parabolic geometry (det g = 0), momentum along the degenerate
||| null direction (0, 1) evaluates to exactly (0, 0), allowing frictionless remainder
||| drainage into Dark Matter without back-reaction or drag.
public export
auditParabolicNullMomentumZeroProof : Bool
auditParabolicNullMomentumZeroProof =
  let metric = geometryToMetric ParabolicGeom
      p0 = (intToBoxInt 0, intToBoxInt 0)
      pNull = (intToBoxInt 0, intToBoxInt 1)
      (px, py) = discreteCanonicalMomentum metric p0 pNull
  in unwrapBox px == 0 && unwrapBox py == 0

||| Audits Sector-Specific Action Signatures across the 4 Geometries:
||| For displacement Δx = (1, 1):
||| - Elliptic: Q_Ell = 1² + 1² = 2 > 0 (Positive Bound State)
||| - Hyperbolic: Q_Hyp = 1² - 1² = 0 (Null Lightcone Phase)
||| - Parabolic: Q_Par = 1² + 0 = 1 (Dissipative Drain)
||| - Substrate: Q_Sub = 1² + 2(1)(1) + 0 = 3 (Asymmetric Causal Drive)
public export
auditSectorSpecificActionSignaturesProof : Bool
auditSectorSpecificActionSignaturesProof =
  let diff = (intToBoxInt 1, intToBoxInt 1)
      qEll = metricKineticQuadrance (geometryToMetric EllipticGeom) diff
      qHyp = metricKineticQuadrance (geometryToMetric HyperbolicGeom) diff
      qPar = metricKineticQuadrance (geometryToMetric ParabolicGeom) diff
      qSub = metricKineticQuadrance (geometryToMetric SubstrateGeom) diff
  in unwrapBox qEll == 2 &&
     unwrapBox qHyp == 0 &&
     unwrapBox qPar == 1 &&
     unwrapBox qSub == 3


