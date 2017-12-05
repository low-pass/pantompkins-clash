module Sampler where

import CLaSH.Prelude
import Filters
import Thresholds

peakTracker :: Num a => Vec 40 (Signal (Unsigned 1)) -> Signal (Maybe a)
peakTracker bp = lastPos 1 <$> bundle bp
    where lastPos i xs =
            case elemIndex i xs of
                Just ind -> Just (fromInteger . toInteger $ ind)
                Nothing  -> Nothing

presetCtr :: Num a => a -> (a,Bool) -> (a,a)
presetCtr mem (new,True) = (new,mem)
presetCtr mem (_,False)  = (mem+1,mem)


-- interval, slope, peaks

qrsSample :: (Ord i, Num i, Ord s, Num s, Bits s)
          => (s,i)
          -> (i,s,Unsigned 1, Maybe i)
          -> ((s,i),(i,i,Bool))
qrsSample (slop,r2r) (_,_,0,_)       = ((slop,r2r),(r2r,0,False))
qrsSample (slop,r2r) (_,_,1,Nothing) = ((slop,r2r),(r2r,0,False))
qrsSample (slop,r2r) (nr2r,nslop,1,Just bpeak)
    | nr2r > 70            = update
    | tooEarly && noTwave  = update
    | otherwise            = stay
        where 
            tooEarly = (nr2r > 39) && (nr2r < 70)
            noTwave  = nslop > (shiftR slop 1)
            update   = ((nslop,nr2r),(nr2r,bpeak,True))
            stay     = ((slop,r2r),(r2r,0,False))


r2rSampler :: Signal (Signed 12) -> Signal (Unsigned 12)
r2rSampler x = r2r
    where
        (r2r,slack,rst) = mealyB qrsSample (0,0) (counted,mslop,mwiPeaks,bpTrack)
        counted  = mealy presetCtr 0 $ bundle (slack,rst)
        mslop    = mealy keepMax 0 $ bundle (dxSig,rst)
        bpTrack  = peakTracker $ window bpPeaks
        mwiPeaks = peakSelector . mwi . sqr . dxdt $ bandpass
        bpPeaks  = peakSelector . delay2 $ bandpass
        dxSig    = dxdt $ bandpass
        bandpass = lopass $ hipass x

topEntity :: Signal (Signed 12) -> Signal (Unsigned 12)
topEntity = r2rSampler

