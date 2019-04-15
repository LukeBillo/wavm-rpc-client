module Main where

import Effect (Effect)
import Effect.Aff (Fiber, launchAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Process (exit)
import Prelude (Unit, bind, discard, pure, unit, ($))
import ZeroMQ (Endpoint(..), ServerSockets, createRpcServer, execute, executeAsync, init, send, sendRemoteAsync, sendRemoteSync)

createEndpoint :: ServerSockets -> Endpoint
createEndpoint s = Endpoint {
  sockets: s,
  async: sendRemoteAsync,
  sync: sendRemoteSync
}

main :: Effect (Fiber Unit)
main = launchAff do
    send endpoint (do
      _ <- init "/home/luke/Documents/c++-wasm-files/wasm/a.compiled.wasm" true
      pure unit
    )
    liftEffect $ do
      log "WAVM commands successfully ran!"
      exit 0   
  where endpoint = createEndpoint $ createRpcServer 45555 45554
  
    
