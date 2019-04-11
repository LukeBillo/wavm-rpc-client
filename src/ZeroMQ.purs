module ZeroMQ where

import Prelude

import Command (Command(..))
import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Promise (Promise, toAff)
import Data.Function.Uncurried (Fn2, runFn2)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import TypeConversion (JsPrimitive, convertWasmType, parseResult)

-- Handling foreign imports

foreign import data AsyncSocket :: Type
foreign import data SyncSocket :: Type

type ServerSockets = { asyncSocket :: AsyncSocket, syncSocket :: SyncSocket }

foreign import createZeroMqServer :: Fn2 Int Int ServerSockets
foreign import sendAsync :: Fn2 AsyncSocket String (Effect (Promise Unit))
foreign import sendSync :: Fn2 SyncSocket String (Effect (Promise String))

{- -------------- -}
{- Server startup -}
{- -------------- -}

createZeroMqServerCurried :: Int -> Int -> ServerSockets
createZeroMqServerCurried = runFn2 createZeroMqServer

createRpcServer :: Int -> Int ->  ServerSockets
createRpcServer = createZeroMqServerCurried

{- -------------- -}
{- Send functions -}
{- -------------- -}

-- Async
sendAsyncCurried :: AsyncSocket -> String -> Effect (Promise Unit)
sendAsyncCurried = runFn2 sendAsync

sendRemoteAsync :: AsyncSocket -> String -> Aff Unit
sendRemoteAsync sock s = liftEffect (sendAsyncCurried sock s) >>= toAff

-- Sync
sendSyncCurried :: SyncSocket -> String -> Effect (Promise String)
sendSyncCurried = runFn2 sendSync

sendRemoteSync :: SyncSocket -> String ->  Aff String
sendRemoteSync sock s = liftEffect (sendSyncCurried sock s) >>= toAff

-- Generic
send :: forall a. Endpoint -> Remote a -> Aff a
send e (Remote r) = runReaderT r e

{- --------------- -}
{- Command runners -}
{- --------------- -}

data Endpoint = Endpoint {
    sockets :: ServerSockets,
    async :: AsyncSocket -> String -> Aff Unit,
    sync :: SyncSocket -> String -> Aff String
}

runAsyncCmd :: Command -> Remote Unit
runAsyncCmd c = Remote $ do 
    (Endpoint e) <- ask
    liftAff $ e.async e.sockets.asyncSocket (show c)
    pure unit

runSyncCmd :: Command -> Remote JsPrimitive
runSyncCmd c = Remote $ do
    (Endpoint e) <- ask
    r <- liftAff $ e.sync e.sockets.syncSocket (show c)
    pure $ convertWasmType (parseResult r)

-- Command conversions

init :: String -> Remote Unit
init s = runAsyncCmd $ Init s

execute :: String -> Remote JsPrimitive
execute s = runSyncCmd $ Execute s

void :: String -> Remote Unit
void s = runAsyncCmd $ Void s

-- Remote monad

newtype Remote a = Remote (ReaderT Endpoint Aff a)
derive newtype instance bindRemote ∷ Bind Remote
derive newtype instance monadRemote :: Monad Remote
derive newtype instance applicativeRemote ∷ Applicative Remote
derive newtype instance applyRemote :: Apply Remote
derive newtype instance functorRemote :: Functor Remote
derive newtype instance monadAskRemote :: MonadAsk Endpoint Remote
derive newtype instance monadEffectRemote :: MonadEffect Remote