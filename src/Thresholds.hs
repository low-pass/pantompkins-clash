module Thresholds where

import CLaSH.Prelude

localMax :: (Ord a, Num a) => a -> a -> a -> a
localMax pre mid post =
    case compare post mid of
        LT -> 
            case compare mid pre of
                LT -> 0
                _ -> mid
        _ -> 0

peaks :: (Num a, Ord a) => Vec 65 (Signal a) -> Signal a
peaks s = (liftA3 localMax) pre mid post
    where
        mid = s !! 32
        pre = maxVec (take d32 s)
        post = maxVec (drop d33 s)
        maxVec sig = fold (liftA2 max) sig

keepMax :: (Num a, Ord a) => a -> (a, Bool) -> (a,a)
keepMax x (_,True) = (0,x)
keepMax x (y,False) = (z,z)
    where z = max x y
    
timer2sec :: (Int,Bool) -> Int -> ((Int,Bool),Bool)
timer2sec (_,True) _  = ((0,True),True)
timer2sec (ctr,False) _ = ((ctr + 1,halt),halt)
    where halt = ctr >= 400

threshold :: (Num a, Ord a, Bits a) 
          => (a,a,Bool)
          -> (a,Maybe a)
          -> ((a,a,Bool),Unsigned 1)
threshold (_,_,_) (_,Nothing)       = ((0,0,False),0)
threshold (_,_,False) (_,Just x)    = ((x,0,True),0)
threshold (signal,noise,True) (0,_) = ((signal,noise,True),0)
threshold (signal,noise,True) (input,_)
    | input < level = ((signal,updated noise,True), 0)
    | otherwise     = ((updated signal,noise,True), 1)
        where
           level = noise + (shiftR signal 2) - (shiftR noise 2)
           updated x = (shiftR input 3) + x - (shiftR x 3)

trainControl :: a -> (a,Bool) -> (a,(Maybe a,Bool))
trainControl x (_,False) = (x,(Nothing,False))
trainControl _ (y,True)  = (y,(Just y,True))

peakSelector :: (Ord a, Num a, Bits a, Default a) => Signal a -> Signal (Unsigned 1)
peakSelector x = mealy threshold (0,0,False) $ bundle (sigPeaks,initLvl)
    where
        sigPeaks = peaks $ window x
        (initLvl,stopMax) = mealyB trainControl 0 (firstMax,timeout)
        firstMax = mealy keepMax 0 $ bundle (x,stopMax)
        timeout = mealy timer2sec (0,False) 0

