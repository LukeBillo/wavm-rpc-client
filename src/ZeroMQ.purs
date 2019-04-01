module ZeroMQ where

import Prelude

import Command (Command(..))
import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

-- Handling foreign imports

foreign import data Socket :: Type

foreign import createZeroMqServer :: Fn1 Int Socket
foreign import sendAsync :: Fn2 Socket String (Effect Unit)
foreign import sendSync :: Fn2 Socket String (Effect String)

{- -------------- -}
{- Server startup -}
{- -------------- -}

createZeroMqServerCurried :: Int -> Socket
createZeroMqServerCurried = runFn1 createZeroMqServer

createRpcServer :: Int -> Socket
createRpcServer = createZeroMqServerCurried

{- -------------- -}
{- Send functions -}
{- -------------- -}

-- Async
sendAsyncCurried :: Socket -> String -> Effect Unit
sendAsyncCurried = runFn2 sendAsync

sendRemoteAsync :: Socket -> String -> Effect Unit
sendRemoteAsync sock s = sendAsyncCurried sock s

-- Sync
sendSyncCurried :: Socket -> String -> Effect String
sendSyncCurried = runFn2 sendSync

sendRemoteSync :: Socket -> String -> Effect String
sendRemoteSync sock s = sendSyncCurried sock s

-- Generic
send :: forall a. Endpoint -> Remote a -> Effect a
send e (Remote r) = runReaderT r e

{- --------------- -}
{- Command runners -}
{- --------------- -}

data Endpoint = Endpoint {
    socket :: Socket,
    async :: Socket -> String -> Effect Unit,
}

runAsyncCmd :: Command -> Remote Unit
runAsyncCmd c = Remote $ do 
    (Endpoint e) <- ask
    liftEffect $ e.async e.socket (show c)
    pure unit

-- Command conversions

init :: String -> Remote Unit
init s = runAsyncCmd $ Init s

void :: String -> Remote Unit
void s = runAsyncCmd $ Void s

-- Remote monad

newtype Remote a = Remote (ReaderT Endpoint Effect a)
derive newtype instance bindRemote ∷ Bind Remote
derive newtype instance monadRemote :: Monad Remote
derive newtype instance applicativeRemote ∷ Applicative Remote
derive newtype instance monadAskRemote :: MonadAsk Endpoint Remote
derive newtype instance monadEffectRemote :: MonadEffect Remote