module Math.RationalTrig

import Core.BoxInt
import Math.LinAlgebra.MetricTensor

%default total

||| Wildberger's Archimedes Function over exact BoxInt quadrances:
||| A(Q1, Q2, Q3) = (Q1 + Q2 + Q3)^2 - 2(Q1^2 + Q2^2 + Q3^2)
|||              = 4*Q1*Q2 - (Q1 + Q2 - Q3)^2
public export
archimedesFunction : BoxInt -> BoxInt -> BoxInt -> BoxInt
archimedesFunction q1 q2 q3 =
  let sumQ   = q1 + q2 + q3
      sumSqQ = (q1 * q1) + (q2 * q2) + (q3 * q3)
  in (sumQ * sumQ) - (intToBoxInt 2 * sumSqQ)

||| Computes the Quadrea of a triangle with side quadrances Q1, Q2, Q3.
||| Quadrea = 16 * (Classical Area)^2, completely exact in BoxInt arithmetic.
public export
quadrea : BoxInt -> BoxInt -> BoxInt -> BoxInt
quadrea q1 q2 q3 = archimedesFunction q1 q2 q3

||| Collinearity predicate: three points are collinear (lie on a geodesic)
||| if and only if Archimedes' function on their side quadrances vanishes.
public export
isCollinearQuadrance : BoxInt -> BoxInt -> BoxInt -> Bool
isCollinearQuadrance q1 q2 q3 =
  archimedesFunction q1 q2 q3 == intToBoxInt 0

||| Emergence theorem from 2x2 maxels:
||| Evaluates the Gram determinant Archimedes formula: 4 * det(g) * (x1*y2 - x2*y1)^2
public export
archimedesFromMaxels : MetricTensor2D -> BoxInt -> BoxInt -> BoxInt -> BoxInt -> BoxInt
archimedesFromMaxels metric x1 y1 x2 y2 =
  let crossDet = (x1 * y2) - (x2 * y1)
      detG     = detMetric metric
  in intToBoxInt 4 * detG * (crossDet * crossDet)
