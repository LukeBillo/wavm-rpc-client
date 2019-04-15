module TypeConversion where

import Data.Array (head, last)
import Data.Int (fromString) as I
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Number (fromString) as N
import Data.String (Pattern(..), split)
import Prelude (($))

foreign import data JsPrimitive :: Type

foreign import convertFromWasmType :: WasmType -> JsPrimitive

data WasmType = 
    STR String |
    I32 Int |
    F32 Number |
    ErrorType

convertToWasmType ::  Maybe String -> Maybe String -> WasmType
convertToWasmType (Just "str")       (Just r) = STR r
convertToWasmType (Just "i32.const") (Just r) = I32 $ fromMaybe 0 (I.fromString r)
convertToWasmType (Just "f32.const") (Just r) = F32 $ fromMaybe 0.0 (N.fromString r)
convertToWasmType _            _        = ErrorType

parseResult :: String -> WasmType
parseResult s =
    let 
        splits = split (Pattern " ") s
        resultType = head splits
        resultValue = last splits
    in
        convertToWasmType resultType resultValue