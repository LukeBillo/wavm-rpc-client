module Main where

import ZeroMQ

import Effect (Effect)
import Effect.Aff (Fiber, launchAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Process (exit)
import Prelude (Unit, bind, discard, ($))

createEndpoint :: ServerSockets -> Endpoint
createEndpoint s = Endpoint {
  sockets: s,
  async: sendRemoteAsync,
  sync: sendRemoteSync
}

main :: Effect (Fiber Unit)
main = launchAff do
    send endpoint (do
      _ <- init "/home/luke/Documents/c++-wasm-files/wasm/basic-functions-2.wasm" false
      _ <- execute "_getMyNumber"
      _ <- execute "potatoes"
      _ <- execute "_addNumbers"
      void "bar")
    liftEffect $ do
      log "WAVM commands successfully ran!"
      exit 0   
  where endpoint = createEndpoint $ createRpcServer 45555 45554
  
    
