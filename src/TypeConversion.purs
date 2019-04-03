module TypeConversion where

import Data.Array (head, last)
import Data.Int (fromString) as I
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Number (fromString) as N
import Data.String (Pattern(..), split)
import Prelude (($))

foreign import data JsPrimitive :: Type

foreign import convertWasmType :: WasmType -> JsPrimitive

data WasmType = 
    I32 Int |
    F32 Number |
    ErrorType

convertType ::  Maybe String -> Maybe String -> WasmType
convertType (Just "i32") (Just r) = I32 $ fromMaybe 0 (I.fromString r)
convertType (Just "f32") (Just r) = F32 $ fromMaybe 0.0 (N.fromString r)
convertType _            _        = ErrorType

parseResult :: String -> WasmType
parseResult s =
    let 
        splits = split (Pattern " ") s
        resultType = head splits
        resultValue = last splits
    in
        convertType resultType resultValue