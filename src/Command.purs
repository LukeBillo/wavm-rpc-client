module Command where

import Prelude

import Data.Array (last)
import Data.Either (fromRight)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)
import Data.String.Read (class Read)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Partial.Unsafe (unsafePartial)

-- Serializables

data Command = 
    Init String |
    -- Execute String a |
    Void String |
    Invalid

instance showCommand :: Show Command where
  show (Init file)   = "Init \"" <> file <> "\""
  -- show (Execute function _) = "Execute " <> function
  show (Void function) = "Void \"" <> function <> "\""
  show (Invalid) = "Invalid command"

getParameter :: String -> Maybe String
getParameter cmd = last $ split (Pattern " ") cmd

initCmdRegex :: Regex
initCmdRegex =  unsafePartial fromRight $ regex "[Ii]nit" noFlags

constructInit :: String -> Command
constructInit cmd = let maybeFile = getParameter cmd
  in case maybeFile of
    Just file -> Init file
    Nothing -> Invalid

voidCmdRegex :: Regex
voidCmdRegex = unsafePartial fromRight $ regex "[Vv]oid" noFlags

constructVoid :: String -> Command
constructVoid cmd = let maybeFunction = getParameter cmd
  in case maybeFunction of 
    Just function -> Void function
    Nothing -> Invalid

instance readCommand :: Read Command where
  read cmd | test initCmdRegex cmd = Just (constructInit cmd)
           | test voidCmdRegex cmd = Just (constructVoid cmd)
           | otherwise = Nothing