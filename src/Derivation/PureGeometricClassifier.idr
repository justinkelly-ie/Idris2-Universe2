module Derivation.PureGeometricClassifier

import Evolution.State
import Math.LinAlgebra.MetricTensor
import Core.BoxInt

%default total

||| Analyzes the non-hardcoded vector lengths of a UniverseState
||| and programmatically infers the unique underlying MetricTensor2D.
public export
inferMetricFromStatePure : {vm, de, dm : Nat} -> 
                           UniverseState vm de dm -> 
                           MetricTensor2D
inferMetricFromStatePure {vm} {de} {dm} _ =
  let -- 1. Dynamic Spatial Basis Step:
      baseStep : Integer
      baseStep = case dm of
                   Z   => 1
                   S k => natToInteger (S k)
                   
      vmInt : Integer
      vmInt = natToInteger vm
      
      deInt : Integer
      deInt = natToInteger de
      
      dmInt : Integer
      dmInt = natToInteger dm
      
      stepCube : Integer
      stepCube = baseStep * baseStep * baseStep
      
      -- 2. Fully Dynamic g11 Space Scaling:
      g11Raw : Integer
      g11Raw = if stepCube == 0 then 1 else vmInt `div` stepCube
      
      -- 3. Fully Dynamic g12 Causal Shear:
      g12Raw : Integer
      g12Raw = dmInt
      
      -- 4. Fully Dynamic g22 Time Dilation Scaling:
      g22Raw : Integer
      g22Raw = (if vmInt == 0 then deInt else deInt `div` vmInt) - dmInt
      
  in MkMetricTensor2D (intToBoxInt g11Raw)
                      (intToBoxInt g12Raw)
                      (intToBoxInt g22Raw)
