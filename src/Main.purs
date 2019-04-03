module Main where

import ZeroMQ

import Effect (Effect)
import Prelude (bind, Unit, discard, ($))

createEndpoint :: Socket -> Endpoint
createEndpoint s = Endpoint {
  socket: s,
  async: sendRemoteAsync,
  sync: sendRemoteSync
}

main :: Effect Unit
main = do
    send endpoint (do
      init "module.wasm"
      r <- execute "foo"
      void "bar")
  where endpoint = createEndpoint $ createRpcServer 45555
  
    
