module Command where

import Prelude
import Type.Data.Boolean (kind Boolean)

-- Serializables

data Command = 
    Void String |
    InvalidCmd

type Commands = Array Command

instance showCommand :: Show Command where
  show (Void function) = "Void \"" <> function <> "\""
  show (InvalidCmd) = "Invalid command"

data Procedure = Init String Boolean |
                 Execute String |
                 InvalidProc

instance showProcedure :: Show Procedure where
  show (Init file isPrecompiled)   = "Init \"" <> file <> "\" False"
  show (Execute function) = "Execute \"" <> function <> "\""
  show (InvalidProc) = "Invalid procedure"

data Bundle = Bundle Commands Procedure

instance showBundle :: Show Bundle where
  show (Bundle cs p) = "Bundle " <> show cs <> " (" <> show p <> ")"