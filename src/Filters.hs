module Filters where

import CLaSH.Prelude


-- [dotp] calculates the sum of products of each elements of 
-- input vectors, it's our convolution engine

dotp :: (Num a, KnownNat n)
     => Vec (n + 1) a -> Vec (n + 1) a -> a
dotp x y = fold (+) $ zipWith (*) x y


-- [tfun_w_gain] implements numerator and denominator convolution in
-- IIR direct form 1 and normalizes for the transfer function gain
-- given in the form of 2^g. Instances have to be resized with
-- margin of g bits to avoid data clipping.

tfun_w_gain :: (KnownNat n, KnownNat m, Num a, Bits a, Default a)
            => Int
            -> Vec (n + 1) a -> Vec (m + 1) a 
            -> Signal a -> Signal a
tfun_w_gain gain num den x_t = (\n -> shiftR n gain) <$> y_t
    where
        y_t = (liftA2 (+)) ff fb
        ff  = dotp num <$> bundle (window x_t)
        fb  = dotp den <$> bundle (tail (window y_t))


-- 1st order highpass filter, cutoff at 5 Hz, gain = 1 (normalized from 32)

hipass :: Signal (Signed 12) -> Signal (Signed 12)
hipass input = normalize filtered
 where
  normalize = fmap resize
  filtered = tfun_w_gain 5 num den $ normalize input :: Signal (Signed (12 + 5))
  num = ((-1):>Nil) ++ z' d15 ++ (32:>(-32):>Nil) ++ z' d14 ++ (1:>Nil)
  den = (1:>Nil)
  z' n = replicate n 0

-- 2nd order lowpass filter, cutoff at 11 Hz, gain = 1.125 (normalized from 36)

lopass :: Signal (Signed 12) -> Signal (Signed 12)
lopass input = normalize filtered
 where
  normalize = fmap resize
  filtered = tfun_w_gain 5 num den $ normalize input   :: Signal (Signed (12 + 5))
  num = (1:>0:>0:>0:>0:>0:>(-2):>0:>0:>0:>0:>0:>1:>Nil)
  den = (2:>(-1):>Nil)

-- 2nd order derivative, gain = 0.65 (normalized from 5.2)

dxdt :: Signal (Signed 12) -> Signal (Signed 12)
dxdt input = normalize filtered
 where
  normalize = fmap resize
  filtered = tfun_w_gain 2 num den $ normalize input   :: Signal (Signed (12 + 2))
  num = (1:>2:>0:>(-2):>(-1):>Nil)
  den = (0:>Nil)

-- Moving window integrator, gain = 1 (normalized from 32)

mwi :: Signal (Signed 24) -> Signal (Signed 24)
mwi input = normalize filtered
 where
  normalize = fmap resize
  filtered = tfun_w_gain 5 num den $ normalize input   :: Signal (Signed (24 + 5))
  num = (1:>Nil) ++ replicate d31 0 ++ ((-1):>Nil)
  den = (1:>Nil)

sqr :: Signal (Signed 12) -> Signal (Signed 24)
sqr x = liftA2 times x x

delay2 :: Num a => Signal a -> Signal a
delay2 = toSignal . delay (0:>0:>Nil) . fromSignal

