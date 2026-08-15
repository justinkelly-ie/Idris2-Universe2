module Math.LinAlgebra.BilinearProduct

import Core.BoxInt
import Core.VexelMaxel
import Math.LinAlgebra.MetricTensor
import Math.Infinitesimal

%default total

||| An infinitesimal 2D displacement vector (dx, dy) where each component
||| tracks position and velocity simultaneously using dual number algebra.
public export
record InfinitesimalStep2D where
  constructor MkStep2D
  dx : DualComplex
  dy : DualComplex

public export
Eq InfinitesimalStep2D where
  (MkStep2D x1 y1) == (MkStep2D x2 y2) = x1 == x2 && y1 == y2

public export
Show InfinitesimalStep2D where
  show (MkStep2D x y) = "Step2D(dx=" ++ show x ++ ", dy=" ++ show y ++ ")"

||| Helper to scale a dual number by a BoxInt scalar coefficient.
public export
scaleDual : BoxInt -> DualComplex -> DualComplex
scaleDual (MkBoxInt s) (MkDual r i) = 
  MkDual (MkBoxInt (s * unwrapBox r)) (MkBoxInt (s * unwrapBox i))

||| Computes the infinitesimal bilinear inner product (ds^2) under a metric Maxel.
||| ds^2 = g11 * dx^2 + 2 * g12 * dx * dy + g22 * dy^2
public export
bilinearInnerProduct : Maxel -> InfinitesimalStep2D -> DualComplex
bilinearInnerProduct g (MkStep2D dx dy) =
  let g11Val = g11 g
      g12Val = g12 g
      g22Val = g22 g
      dx2  = dx * dx
      dy2  = dy * dy
      dxdy = dx * dy
      term1 = scaleDual g11Val dx2
      term2 = scaleDual (intToBoxInt 2 * g12Val) dxdy
      term3 = scaleDual g22Val dy2
  in term1 + term2 + term3
