{-# LANGUAGE OverloadedStrings #-}

-----------------------------------------------------------------------------
-- |
-- Module      : Graphics.Hoodle.Render.Highlight
-- Copyright   : (c) 2011-2013 Ian-Woo Kim
--
-- License     : BSD3
-- Maintainer  : Ian-Woo Kim <ianwookim@gmail.com>
-- Stability   : experimental
-- Portability : GHC
--
-- collection of rendering routine that draws bounding box only
--
-----------------------------------------------------------------------------

module Graphics.Hoodle.Render.Highlight where

-- from others
import qualified Data.Map as M
import           Graphics.Rendering.Cairo
-- from hoodle-platform 
import Data.Hoodle.Simple
import Data.Hoodle.BBox
import Data.Hoodle.Predefined 
-- from this package
import Graphics.Hoodle.Render.Primitive 
import Graphics.Hoodle.Render.Type.Item 
-- 
import Prelude hiding (fst,snd,curry,uncurry,mapM_,concatMap)

-- | 
renderStrkHltd :: BBoxed Stroke -> Render ()
renderStrkHltd sbbox = do 
    let s = bbxed_content sbbox 
    case M.lookup (stroke_color s) predefined_pencolor of 
      Just (r,g,b,a) -> setSourceRGBA r g b a
      Nothing -> setSourceRGBA 0 0 0 1 
    case s of
      Stroke _ _ w d -> do  
        setLineWidth (w * 4.0) 
        setLineCap LineCapRound
        setLineJoin LineJoinRound
        drawStrokeCurve d
        stroke
        setSourceRGBA 1 1 1 1
        setLineWidth w
        drawStrokeCurve . stroke_data $ s 
        stroke
      VWStroke _ _ d -> do  
        setFillRule FillRuleWinding
        drawVWStrokeCurve $ map (\(x,y,z)->(x,y,4*z)) d
        fill  
        setSourceRGBA 1 1 1 1
        drawVWStrokeCurve d     
        fill
    

-- | render items highlighted 
renderRItemHltd :: RItem -> Render ()
renderRItemHltd (RItemStroke strk) = renderStrkHltd strk
renderRItemHltd (RItemImage img _) = renderBBoxHltd img
renderRItemHltd (RItemSVG svg _) = renderBBoxHltd svg 
renderRItemHltd (RItemLink lnk _) = renderBBoxHltd lnk

-- |
renderBBoxHltd :: (GetBBoxable a) => a -> Render () 
renderBBoxHltd x = do 
  setSourceRGBA 0 0 0 1
  setLineWidth 10 
  let BBox (x1,y1) (x2,y2) = getBBox x
  rectangle x1 y1 (x2-x1) (y2-y1)
  stroke

