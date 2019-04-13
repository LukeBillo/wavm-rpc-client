module Command where

import Prelude

import Data.Array (head, last)
import Data.Either (fromRight)
import Data.Int (fromString) as I
import Data.Maybe (Maybe(..))
import Data.Number (fromString) as N
import Data.String (Pattern(..), split)
import Data.String.Read (class Read)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Partial.Unsafe (unsafePartial)
import Type.Data.Boolean (kind Boolean)

-- Serializables

data Command = 
    Init String Boolean |
    Execute String |
    Void String |
    Invalid

instance showCommand :: Show Command where
  show (Init file isPrecompiled)   = "Init \"" <> file <> "\" False"
  show (Execute function) = "Execute \"" <> function <> "\""
  show (Void function) = "Void \"" <> function <> "\""
  show (Invalid) = "Invalid command"

instance readCommand :: Read Command where
  read cmd | test initCmdRegex cmd = Just (constructInit cmd)
           | test voidCmdRegex cmd = Just (constructVoid cmd)
           | otherwise = Nothing

getParameter :: String -> Array String
getParameter cmd = split (Pattern " ") cmd

initCmdRegex :: Regex
initCmdRegex =  unsafePartial fromRight $ regex "[Ii]nit" noFlags

constructInit :: String -> Command
constructInit cmd = 
  let 
    maybeFile = head $ getParameter cmd
  in case maybeFile of
    Just file -> Init file true
    Nothing -> Invalid

voidCmdRegex :: Regex
voidCmdRegex = unsafePartial fromRight $ regex "[Vv]oid" noFlags

constructVoid :: String -> Command
constructVoid cmd = let maybeFunction = last $ getParameter cmd
  in case maybeFunction of 
    Just function -> Void function
    Nothing -> Invalid
  