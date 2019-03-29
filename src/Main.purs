module Main where

import Command (Command)
import Data.Maybe (Maybe(..))
import Data.String.Read (read)
import Effect (Effect)
import Effect.Console (log)
import Node.Process (exit)
import Node.ReadLine (prompt, close, setLineHandler, setPrompt, noCompletion, createConsoleInterface)
import Prelude (Unit, bind, discard, show, ($), (<>), (==))
import ZeroMQ (SyncSocket, createRpcServer, send)

handleCmd :: String -> SyncSocket -> Effect Unit
handleCmd s sock = let cmd = (read s :: Maybe Command) in
    case cmd of
      Just c  -> do
        log $ "Sending " <> show c
        send sock c
      Nothing -> log "Invalid command."

main :: Effect Unit
main = do
  let socket = createRpcServer 45555
  interface <- createConsoleInterface noCompletion
  setPrompt "> " 2 interface
  prompt interface
  setLineHandler interface $ \s ->
    if s == "quit"
       then do
        close interface
        exit 0
       else do
        log $ "Command received: " <> s
        handleCmd s socket
        prompt interface
