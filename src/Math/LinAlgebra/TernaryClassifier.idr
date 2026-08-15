module Math.LinAlgebra.TernaryClassifier

import Core.BoxInt
import Math.LinAlgebra.MetricTensor
import Data.Vect

%default total

||| The foundational 3-bit alphabet of Box Arithmetic:
||| Parity (-1), Identity (0), and Presence (+1).
public export
data TernaryBit = MinusOne | ZeroBit | PlusOne

public export
Eq TernaryBit where
  MinusOne == MinusOne = True
  ZeroBit  == ZeroBit  = True
  PlusOne  == PlusOne  = True
  _        == _        = False

public export
Show TernaryBit where
  show MinusOne = "-1"
  show ZeroBit  = " 0"
  show PlusOne  = "+1"

public export
bitToInt : TernaryBit -> Integer
bitToInt MinusOne = -1
bitToInt ZeroBit  = 0
bitToInt PlusOne  = 1

public export
bitToBoxInt : TernaryBit -> BoxInt
bitToBoxInt b = intToBoxInt (bitToInt b)

||| The three geometric signatures of a discrete 2x2 metric manifold.
public export
data MetricSignature = 
    SigElliptic    -- det(g) > 0  (Euclidean / Matter canvas)
  | SigHyperbolic  -- det(g) < 0  (Minkowski / Causal / Symplectic)
  | SigParabolic   -- det(g) == 0 (Degenerate / Spread / Boolean)

public export
Eq MetricSignature where
  SigElliptic   == SigElliptic   = True
  SigHyperbolic == SigHyperbolic = True
  SigParabolic  == SigParabolic  = True
  _             == _             = False

public export
Show MetricSignature where
  show SigElliptic   = "Elliptic (det > 0)"
  show SigHyperbolic = "Hyperbolic (det < 0)"
  show SigParabolic  = "Parabolic (det == 0)"

||| Synthesizes a 2x2 Metric Tensor from three raw ternary bits.
public export
buildTernaryMetric : TernaryBit -> TernaryBit -> TernaryBit -> MetricTensor2D
buildTernaryMetric g11 g12 g22 =
  MkMetricTensor2D (bitToBoxInt g11) (bitToBoxInt g12) (bitToBoxInt g22)

||| Computes the discriminant signature of a symmetric matrix directly from its bits.
public export
classifyTernaryMetric : TernaryBit -> TernaryBit -> TernaryBit -> MetricSignature
classifyTernaryMetric g11 g12 g22 =
  let a = bitToInt g11
      b = bitToInt g12
      c = bitToInt g22
      detVal = (a * c) - (b * b)
  in if detVal > 0 
       then SigElliptic 
       else if detVal < 0 
              then SigHyperbolic 
              else SigParabolic

||| The complete vector of all 3 ternary bits.
public export
allBits : Vect 3 TernaryBit
allBits = [MinusOne, ZeroBit, PlusOne]

||| Computes all 27 ternary matrix permutations and their signatures.
public export
generateAll27States : List (TernaryBit, TernaryBit, TernaryBit, MetricTensor2D, MetricSignature)
generateAll27States =
  let bits = [MinusOne, ZeroBit, PlusOne]
  in [ (b1, b2, b3, buildTernaryMetric b1 b2 b3, classifyTernaryMetric b1 b2 b3)
     | b1 <- bits, b2 <- bits, b3 <- bits ]
