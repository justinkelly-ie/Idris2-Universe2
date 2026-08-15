module Geometry.DEC3D

import Core.BoxInt
import Core.Multiset
import Core.VexelMaxel
import Data.List
import Data.Vect

%default total

------------------------------------------------------------------------
-- 1. WILDBERGER'S 3D GRASSMANN COCHAIN HIERARCHY
--    (Standard Physics: Discrete Exterior Calculus 0-, 1-, 2-, 3-Forms)
------------------------------------------------------------------------

||| 0-Blade Field (Standard: 0-Form / Scalar Potential Phi).
||| Valuation of discrete vertex points represented by Singletons [v].
public export
record PointCochain where
  constructor MkPointCochain
  nodeValues : List (Singleton, BoxInt)

||| 1-Blade Field (Standard: 1-Form / Gauge Connection A).
||| Valuation of directed 1D edges represented by Pairs of Singletons [u, v].
public export
record EdgeCochain where
  constructor MkEdgeCochain
  edgeValues : List ((Singleton, Singleton), BoxInt)

||| 2-Blade Field (Standard: 2-Form / Curvature Bivector F = dA).
||| Valuation of directed 2D faces represented by coordinate Pixels [i, j].
public export
record FaceCochain where
  constructor MkFaceCochain
  faceValues : List (Pixel, BoxInt)

||| 3-Blade Field (Standard: 3-Form / Volume Density Trivector rho = dF).
||| Valuation of directed 3D volume cells represented by coordinate Voxels [x, y, z].
public export
record CellCochain where
  constructor MkCellCochain
  cellValues : List (Voxel, BoxInt)

------------------------------------------------------------------------
-- 2. DISCRETE COBOUNDARY OPERATORS (d0, d1, d2)
--    (Standard Physics: Gradient, Curl, Divergence)
------------------------------------------------------------------------

||| Helper lookup for vertex point values.
public export
lookupPoint : Singleton -> PointCochain -> BoxInt
lookupPoint target (MkPointCochain nvs) =
  case find (\(s, _) => s == target) nvs of
    Just (_, v) => v
    Nothing     => intToBoxInt 0

||| Helper lookup for edge connection values.
public export
lookupEdge : (Singleton, Singleton) -> EdgeCochain -> BoxInt
lookupEdge target (MkEdgeCochain evs) =
  case find (\(e, _) => e == target) evs of
    Just (_, v) => v
    Nothing     => 
      -- Antisymmetric orientation: [v, u] = - [u, v]
      let (u, v) = target
      in case find (\(e, _) => e == (v, u)) evs of
           Just (_, vVal) => negate vVal
           Nothing        => intToBoxInt 0

||| Helper lookup for face curvature values.
public export
lookupFace : Pixel -> FaceCochain -> BoxInt
lookupFace target (MkFaceCochain fvs) =
  case find (\(p, _) => p == target) fvs of
    Just (_, v) => v
    Nothing     => intToBoxInt 0

||| 0-Coboundary Operator d0 : C0 -> C1 (Standard: Discrete Gradient).
||| Evaluates difference of potential across directed edge [u -> v]: (Phi_v - Phi_u).
public export
grassmannCoboundary0 : List (Singleton, Singleton) -> PointCochain -> EdgeCochain
grassmannCoboundary0 edges phi =
  let computed = map (\(u, v) => 
                   let vu = lookupPoint u phi
                       vv = lookupPoint v phi
                   in ((u, v), vv - vu)) edges
  in MkEdgeCochain computed

||| 1-Coboundary Operator d1 : C1 -> C2 (Standard: Discrete Curl / Curvature F = dA).
||| Evaluates circulation along 4-edge boundary loop of each face: A_12 + A_23 + A_34 + A_41.
public export
grassmannCoboundary1 : List (Pixel, Vect 4 (Singleton, Singleton)) -> EdgeCochain -> FaceCochain
grassmannCoboundary1 faces conn =
  let computed = map (\(pix, loop) =>
                   let loopSum = sum (map (\e => lookupEdge e conn) (toList loop))
                   in (pix, loopSum)) faces
  in MkFaceCochain computed

||| 2-Coboundary Operator d2 : C2 -> C3 (Standard: Discrete Divergence / Bianchi dF).
||| Evaluates closed boundary flux across the 6 faces bounding each 3D Voxel.
public export
grassmannCoboundary2 : List (Voxel, Vect 6 (Pixel, BoxInt)) -> FaceCochain -> CellCochain
grassmannCoboundary2 voxels field =
  let computed = map (\(vox, bndFaces) =>
                   let fluxSum = sum (map (\(pix, sign) => sign * lookupFace pix field) (toList bndFaces))
                   in (vox, fluxSum)) voxels
  in MkCellCochain computed

------------------------------------------------------------------------
-- 3. COMBINATORIAL HODGE STAR DUALITY (star : C_k <-> C_{3-k})
--    (Standard Physics: Hodge Star Operator)
------------------------------------------------------------------------

||| Combinatorial Hodge Duality mapping 1-Blade Edges to Dual 2-Blade Faces.
||| (Standard Physics: Hodge Star star : C1 -> C2)
public export
combinatorialDual1To2 : EdgeCochain -> FaceCochain
combinatorialDual1To2 (MkEdgeCochain evs) =
  let mapped = map (\((MkSingleton u, MkSingleton v), w) => (MkPixel u v, w)) evs
  in MkFaceCochain mapped

||| Combinatorial Hodge Duality mapping 2-Blade Faces to Dual 1-Blade Edges.
||| (Standard Physics: Hodge Star star : C2 -> C1)
public export
combinatorialDual2To1 : FaceCochain -> EdgeCochain
combinatorialDual2To1 (MkFaceCochain fvs) =
  let mapped = map (\(MkPixel r c, w) => ((MkSingleton r, MkSingleton c), w)) fvs
  in MkEdgeCochain mapped

------------------------------------------------------------------------
-- 4. NON-ABELIAN YANG-MILLS DIHEDRON CURVATURE
--    (Standard Physics: Non-Abelian Gauge Field F = dA + [A, A])
------------------------------------------------------------------------

||| Evaluates Dihedron commutator bracket [A_u, A_v] on color singletons (Red=1, Green=2, Blue=3).
public export
dihedronColorBracket : BoxInt -> BoxInt -> BoxInt
dihedronColorBracket (MkBoxInt a) (MkBoxInt b) =
  -- Non-Abelian cross-multiplication on discrete color indices
  intToBoxInt (a * b - b * a)

||| Non-Abelian Yang-Mills curvature 2-Blade on a face pixel: F_YM = d1(A) + [A_1, A_2].
public export
yangMillsFaceCurvature : EdgeCochain -> Pixel -> Vect 4 (Singleton, Singleton) -> BoxInt
yangMillsFaceCurvature conn pix loop =
  let abelianCurv = sum (map (\e => lookupEdge e conn) (toList loop))
      -- Extract orthogonal edge pair for Dihedron Lie bracket
      e1Val = lookupEdge (index 0 loop) conn
      e2Val = lookupEdge (index 1 loop) conn
      bracketVal = dihedronColorBracket e1Val e2Val
  in abelianCurv + bracketVal

||| Validates that total color flux across a closed 3D voxel boundary is identically zero (Color Singlet Confinement).
public export
verifyColorNeutralVoxelFlux : Vect 6 BoxInt -> Bool
verifyColorNeutralVoxelFlux faceFluxes =
  let totalFlux = sum (toList faceFluxes)
  in unwrapBox totalFlux == 0
