module Math.LinAlgebra.MetricTensor

import Core.BoxInt

%default total

||| Rational Metric Tensor g = [[g11, g12], [g12, g22]] using BoxInt fields.
public export
record MetricTensor2D where
  constructor MkMetricTensor2D
  g11 : BoxInt
  g12 : BoxInt
  g22 : BoxInt

public export
Eq MetricTensor2D where
  (MkMetricTensor2D a1 b1 c1) == (MkMetricTensor2D a2 b2 c2) =
    a1 == a2 && b1 == b2 && c1 == c2

public export
Show MetricTensor2D where
  show (MkMetricTensor2D a b c) = 
    "g = [[" ++ show (unwrapBox a) ++ ", " ++ show (unwrapBox b) ++ "], [" 
             ++ show (unwrapBox b) ++ ", " ++ show (unwrapBox c) ++ "]]"

||| Metric Determinant (Discriminant): det(g) = g11 * g22 - g12^2
public export
detMetric : MetricTensor2D -> BoxInt
detMetric (MkMetricTensor2D a b c) = (a * c) - (b * b)

||| Metric Trace: tr(g) = g11 + g22
public export
traceMetric : MetricTensor2D -> BoxInt
traceMetric (MkMetricTensor2D a b c) = a + c

||| Primary Euclidean Blue Metric: g = [[1, 0], [0, 1]]
public export
gBlue : MetricTensor2D
gBlue = MkMetricTensor2D (intToBoxInt 1) (intToBoxInt 0) (intToBoxInt 1)

||| Primary Relativistic Red Metric: g = [[1, 0], [0, -1]]
public export
gRed : MetricTensor2D
gRed = MkMetricTensor2D (intToBoxInt 1) (intToBoxInt 0) (intToBoxInt (-1))

||| Primary Split-Complex Green Metric: g = [[0, 1], [1, 0]]
public export
gGreen : MetricTensor2D
gGreen = MkMetricTensor2D (intToBoxInt 0) (intToBoxInt 1) (intToBoxInt 0)

||| Causal Poset Substrate Metric: g = [[1, 1], [1, 0]]
public export
gSubstrate : MetricTensor2D
gSubstrate = MkMetricTensor2D (intToBoxInt 1) (intToBoxInt 1) (intToBoxInt 0)

||| Electromagnetism Spacetime Metric: g = [[1, 0], [0, -1]]
public export
gEM : MetricTensor2D
gEM = gRed

||| Symplectic Phase Space Metric: g = [[0, 1], [1, 0]]
public export
gToroidal : MetricTensor2D
gToroidal = gGreen

||| Rational Spread Trigonometric Metric: g = [[1, -1], [-1, 1]]
public export
gTrigonometry : MetricTensor2D
gTrigonometry = MkMetricTensor2D (intToBoxInt 1) (intToBoxInt (-1)) (intToBoxInt 1)

||| Boolean Bit Projection Metric: g = [[1, 0], [0, 0]]
public export
gBoole : MetricTensor2D
gBoole = MkMetricTensor2D (intToBoxInt 1) (intToBoxInt 0) (intToBoxInt 0)
