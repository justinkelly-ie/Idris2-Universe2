module Core.Polynomial

import Core.BoxInt
import Core.Multiset
import Data.List
import Data.Nat
import Language.Reflection

%default total

||| A discrete Monomial BoxTerm in Wildberger's Box Arithmetic.
||| Represents c * x^k where:
||| - coeff: The multiset tally of empty boxes (c).
||| - degree: The nesting depth of the box (k).
public export
record BoxTerm where
  constructor MkBoxTerm
  coeff  : BoxInt
  degree : Nat

public export
Eq BoxTerm where
  (MkBoxTerm c1 d1) == (MkBoxTerm c2 d2) = c1 == c2 && d1 == d2

public export
Show BoxTerm where
  show (MkBoxTerm c d) = 
    show c ++ (if d == 0 then "" else " * x^" ++ show d)

||| A BoxPolynomial is a multiset of nested BoxTerms.
||| Stored as a coefficient list from degree 0 upwards: c0 + c1*x + c2*x^2 + ...
public export
record BoxPolynomial where
  constructor MkBoxPolynomial
  coeffs : List BoxInt -- coeffs[k] is coefficient of x^k

public export
Eq BoxPolynomial where
  (MkBoxPolynomial c1) == (MkBoxPolynomial c2) = c1 == c2

public export
Show BoxPolynomial where
  show (MkBoxPolynomial cs) = 
    "Poly(" ++ show (map unwrapBox cs) ++ ")"

||| Structurally recursive list trimmer eliminating trailing zeros without reverse/dropWhile.
public export
trimList : List BoxInt -> List BoxInt
trimList [] = []
trimList (x :: xs) = 
  let rest = trimList xs
  in case rest of
       [] => if unwrapBox x == 0 then [] else [x]
       _  => x :: rest

||| Strips trailing zero coefficients to normalize the polynomial container.
public export
trimPoly : BoxPolynomial -> BoxPolynomial
trimPoly (MkBoxPolynomial cs) = MkBoxPolynomial (trimList cs)

public export
safeLast : a -> List a -> a
safeLast def [] = def
safeLast def [x] = x
safeLast def (x :: xs) = safeLast def xs

||| Evaluates leading coefficient and leading degree.
public export
leadingTerm : BoxPolynomial -> (BoxInt, Nat)
leadingTerm (MkBoxPolynomial cs) = 
  let trimmed = trimList cs
  in case trimmed of
       [] => (intToBoxInt 0, 0)
       xs => (safeLast (intToBoxInt 0) xs, minus (length xs) 1)

||| Degree of a polynomial (nesting depth of the highest non-zero box term).
public export
polyDegree : BoxPolynomial -> Nat
polyDegree p = snd (leadingTerm p)

||| Zero polynomial: empty box container.
public export
zeroPoly : BoxPolynomial
zeroPoly = MkBoxPolynomial []

||| Creates a constant monomial polynomial: c * x^0.
public export
constantPoly : BoxInt -> BoxPolynomial
constantPoly c = trimPoly (MkBoxPolynomial [c])

||| Creates a single monomial term polynomial: c * x^deg.
public export
monomialPoly : BoxInt -> Nat -> BoxPolynomial
monomialPoly c deg = 
  trimPoly (MkBoxPolynomial (replicate deg (intToBoxInt 0) ++ [c]))

||| Addition of polynomials: pours term containers together and adds matching degrees.
public export
addPolyList : List BoxInt -> List BoxInt -> List BoxInt
addPolyList [] ys = ys
addPolyList xs [] = xs
addPolyList (x :: xs) (y :: ys) = (x + y) :: addPolyList xs ys

public export
addPoly : BoxPolynomial -> BoxPolynomial -> BoxPolynomial
addPoly (MkBoxPolynomial p1) (MkBoxPolynomial p2) = 
  trimPoly (MkBoxPolynomial (addPolyList p1 p2))

||| Subtraction of polynomials: inverts the negative box container and pours terms.
public export
subPolyList : List BoxInt -> List BoxInt -> List BoxInt
subPolyList [] ys = map negate ys
subPolyList xs [] = xs
subPolyList (x :: xs) (y :: ys) = (x - y) :: subPolyList xs ys

public export
subPoly : BoxPolynomial -> BoxPolynomial -> BoxPolynomial
subPoly (MkBoxPolynomial p1) (MkBoxPolynomial p2) = 
  trimPoly (MkBoxPolynomial (subPolyList p1 p2))

||| Scalar multiplication of a polynomial container.
public export
scalePoly : BoxInt -> BoxPolynomial -> BoxPolynomial
scalePoly s (MkBoxPolynomial cs) = 
  trimPoly (MkBoxPolynomial (map (* s) cs))

||| Shifts a polynomial by multiplying by x^k (increasing nesting depth by k).
public export
shiftPoly : Nat -> BoxPolynomial -> BoxPolynomial
shiftPoly Z p = p
shiftPoly (S k) (MkBoxPolynomial cs) = 
  trimPoly (MkBoxPolynomial (intToBoxInt 0 :: cs))

||| Monomial multiplication: (c1 * x^d1) * P(x).
public export
mulMonomial : BoxInt -> Nat -> BoxPolynomial -> BoxPolynomial
mulMonomial c deg p = 
  shiftPoly deg (scalePoly c p)

||| Polynomial Multiplication: Cartesian combination of nested monomial terms.
public export
mulPoly : BoxPolynomial -> BoxPolynomial -> BoxPolynomial
mulPoly (MkBoxPolynomial []) _ = zeroPoly
mulPoly (MkBoxPolynomial (c :: cs)) q = 
  addPoly (scalePoly c q) (shiftPoly 1 (mulPoly (MkBoxPolynomial cs) q))

||| Exact discrete polynomial evaluation at an integer scalar x = a (Horner's rule).
public export
evalPolyList : List BoxInt -> BoxInt -> BoxInt
evalPolyList [] _ = intToBoxInt 0
evalPolyList (c :: cs) a = c + (a * evalPolyList cs a)

public export
evalPoly : BoxPolynomial -> BoxInt -> BoxInt
evalPoly (MkBoxPolynomial cs) a = evalPolyList cs a

------------------------------------------------------------------------
-- CYCLOTOMIC DIVISION & REMAINDER FOLDING ALGORITHM
------------------------------------------------------------------------

||| Discrete polynomial division fuel-bounded algorithm.
||| Computes (Quotient, Remainder) where Dividend = Quotient * Divisor + Remainder.
public export
divModPolyHelper : (fuel : Nat) -> BoxPolynomial -> BoxPolynomial -> BoxPolynomial -> (BoxPolynomial, BoxPolynomial)
divModPolyHelper Z quotient remainder _ = (quotient, remainder)
divModPolyHelper (S fuel) quotient remainder divisor =
  let (remLeadCoeff, remLeadDeg) = leadingTerm remainder
      (divLeadCoeff, divLeadDeg) = leadingTerm divisor
  in if remLeadDeg < divLeadDeg || unwrapBox remLeadCoeff == 0 || unwrapBox divLeadCoeff == 0
       then (quotient, remainder)
       else
         let qCoeff = remLeadCoeff `div` divLeadCoeff
             qDeg   = minus remLeadDeg divLeadDeg
             stepTerm = monomialPoly qCoeff qDeg
             newQuotient = addPoly quotient stepTerm
             subtrahend  = mulPoly stepTerm divisor
             newRemainder = subPoly remainder subtrahend
         in divModPolyHelper fuel newQuotient newRemainder divisor

||| Exact discrete polynomial long division with remainder:
||| divModPoly P D = (Q, R) such that P = Q * D + R with deg(R) < deg(D).
public export
divModPoly : BoxPolynomial -> BoxPolynomial -> (BoxPolynomial, BoxPolynomial)
divModPoly dividend divisor = 
  let fuel = 1 + polyDegree dividend + polyDegree divisor
  in divModPolyHelper fuel zeroPoly (trimPoly dividend) (trimPoly divisor)

------------------------------------------------------------------------
-- GOH FACTORIZATION & LINEAR REDUCTION IN BOX ARITHMETIC
------------------------------------------------------------------------

||| Goh Linear Factor Step (Synthetic Box Division):
||| Divides P(x) by the linear box factor (x - r), producing quotient Q(x) and remainder P(r).
||| In Box Arithmetic, Goh factorization decomposes nested polynumbers into
||| elementary transfer factors without irrational approximations:
||| P(x) = Q(x)(x - r) + P(r)
public export
gohLinearFactor : BoxPolynomial -> BoxInt -> (BoxPolynomial, BoxInt)
gohLinearFactor poly root = 
  let divisor = MkBoxPolynomial [negate root, intToBoxInt 1] -- (x - r)
      (q, r) = divModPoly poly divisor
      remVal = evalPoly poly root
  in (q, remVal)

||| The 137th Cyclotomic Polynomial: Φ₁₃₇(x) = 1 + x + x² + ... + x¹³⁶ (137 unit stages).
public export
cyclotomic137 : BoxPolynomial
cyclotomic137 = 
  MkBoxPolynomial (replicate 137 (intToBoxInt 1))

||| Folds an active epoch polynomial state by dividing by the cyclotomic period.
||| Returns (DarkEnergyQuotient, DarkMatterRemainder).
public export
foldEpochPolynomial : BoxPolynomial -> BoxPolynomial -> (BoxPolynomial, BoxPolynomial)
foldEpochPolynomial epochPoly divisorPoly = 
  divModPoly epochPoly divisorPoly

------------------------------------------------------------------------
-- ELABORATOR REFLECTION MACROS FOR POLYNOMIALS
------------------------------------------------------------------------

||| Generates the AST for a BoxPolynomial literal from a list of integer coefficients.
public export
genPolyAST : List Integer -> TTImp
genPolyAST cs = 
  let mkBox = IVar emptyFC (UN $ Basic "intToBoxInt")
      boxInts = map (\c => IApp emptyFC mkBox (IPrimVal emptyFC (BI c))) cs
      boxList = foldr (\x, acc => IApp emptyFC (IApp emptyFC (IVar emptyFC (UN $ Basic "::")) x) acc)
                      (IVar emptyFC (UN $ Basic "Nil")) boxInts
      mkPoly = IVar emptyFC (UN $ Basic "MkBoxPolynomial")
  in IApp emptyFC mkPoly boxList

||| Compile-time macro to generate a BoxPolynomial AST directly from an integer list.
export
%macro
makePolynomial : List Integer -> Elab TTImp
makePolynomial cs = pure (genPolyAST cs)
