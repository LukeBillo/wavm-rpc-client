module Main where

import ZeroMQ

import Effect (Effect)
import Node.Process (exit)
import Prelude (Unit, discard, ($))

createEndpoint :: Socket -> Endpoint
createEndpoint s = Endpoint {
  socket: s,
  async: sendRemoteAsync
}

main :: Effect Unit
main = do
    send endpoint (do
      init "module.wasm"
      void "bar")
  where endpoint = createEndpoint $ createRpcServer 45555
  
    
