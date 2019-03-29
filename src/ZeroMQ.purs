module ZeroMQ (
    send, 
    createRpcServer,
    SyncSocket
) where

-- Module for ZeroMQ FFI - see ZeroMQ.js
  
import Command (Command)
import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Effect (Effect)
import Prelude (Unit, show)

-- Handling foreign imports

foreign import data SyncSocket :: Type

foreign import createZeroMqServer :: Fn1 Int SyncSocket
foreign import sendRemote :: Fn2 SyncSocket String (Effect Unit)

-- Wrappers for sending via socket, sync only   

createZeroMqServerCurried :: Int -> SyncSocket
createZeroMqServerCurried = runFn1 createZeroMqServer

createRpcServer :: Int -> SyncSocket
createRpcServer = createZeroMqServerCurried

sendRemoteCurried :: SyncSocket -> String -> Effect Unit
sendRemoteCurried = runFn2 sendRemote

send :: SyncSocket -> Command -> Effect Unit
send sock cmd = sendRemoteCurried sock (show cmd)

