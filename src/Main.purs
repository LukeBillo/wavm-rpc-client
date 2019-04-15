module Main where

import ZeroMQ

import Effect (Effect)
import Effect.Aff (Fiber, launchAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Process (exit)
import Prelude (Unit, bind, discard, pure, unit, ($))

createEndpoint :: ServerSockets -> Endpoint
createEndpoint s = Endpoint {
  sockets: s,
  async: sendRemoteAsync,
  sync: sendRemoteSync
}

main :: Effect (Fiber Unit)
main = launchAff do
    send endpoint (do
      _ <- init "/home/luke/Documents/c++-wasm-files/wasm/struct-test.wasm" false
      _ <- execute "_getMyNumber"
      _ <- execute "_addToMyNumber 5"
      _ <- execute "_getMyNumber"
      pure unit
    )
    liftEffect $ do
      log "WAVM commands successfully ran!"
      exit 0   
  where endpoint = createEndpoint $ createRpcServer 45555 45554
  
    
