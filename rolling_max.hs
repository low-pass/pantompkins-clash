module Rolling_max where

import CLaSH.Prelude

localMax :: Signed 12 -> Signed 12 -> Signed 12 -> Signed 12
localMax pre mid post =
    case compare post mid of
        LT -> 
            case compare mid pre of
                LT -> 0
                _ -> mid
        _ -> 0
    

maxRoll :: Vec 65 (Signal (Signed 12)) -> Signal (Signed 12)
maxRoll s =
    let maxVec sig = fold (liftA2 max) sig
        mid = s !! 32
        pre = maxVec (take d32 s)
        post = maxVec (drop d33 s)
    in (liftA3 localMax) pre mid post

topEntity :: Signal (Signed 12) -> Signal (Signed 12)
topEntity sigIn = maxRoll (window sigIn)

