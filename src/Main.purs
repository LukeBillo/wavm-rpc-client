module Main where

import Prelude

import Control.Promise (Promise, fromAff)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import TypeConversion (JsPrimitive)
import ZeroMQ (Endpoint, createEndpoint, createRpcServer, execute, send, void, init)

main :: Effect (Promise Unit)
main = initP endpoint
        where endpoint = createEndpoint $ createRpcServer 45555 45554
  
initP ::Endpoint -> Effect (Promise Unit)
initP endpoint = fromAff $ send endpoint (do 
        _ <- init "/home/luke/Documents/c++-wasm-files/wasm/basic-functions-precomp.wasm" true
        void "addToMyNumber 15"
        void "addToMyNumber 15"
)