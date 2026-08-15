module Math.IntPolynumber

import Core.BoxInt
import Data.List

%default total

||| Bivariate/multivariate polynomial multiset (Polynumber) in Wildberger's Box Arithmetic.
||| Represents a sum of spatial coordinate tokens ((x, y), weight).
public export
data IntPolynumber : Type where
  ZeroM : IntPolynumber
  AddM  : (coord : (Nat, Nat)) -> (weight : BoxInt) -> (rest : IntPolynumber) -> IntPolynumber

public export
Eq IntPolynumber where
  ZeroM == ZeroM = True
  (AddM c1 w1 r1) == (AddM c2 w2 r2) = c1 == c2 && w1 == w2 && r1 == r2
  _ == _ = False

public export
Show IntPolynumber where
  show ZeroM = "0M"
  show (AddM (x, y) w r) = "(" ++ show x ++ "," ++ show y ++ " => " ++ show w ++ ") + " ++ show r

||| Evaluates the total mass of an IntPolynumber by summing all term weights.
public export
totalPolynumberWeight : IntPolynumber -> BoxInt
totalPolynumberWeight ZeroM = intToBoxInt 0
totalPolynumberWeight (AddM _ w r) = w + totalPolynumberWeight r

||| Extracts the weight at a specific 2D coordinate cell.
public export
lookupWeight : (Nat, Nat) -> IntPolynumber -> BoxInt
lookupWeight _ ZeroM = intToBoxInt 0
lookupWeight target (AddM coord weight rest) =
  if target == coord
    then weight + lookupWeight target rest
    else lookupWeight target rest
