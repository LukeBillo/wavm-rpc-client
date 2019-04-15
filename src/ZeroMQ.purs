module ZeroMQ where

import Prelude

import Command (Command(..), Bundle(..), Procedure(..), Commands)
import Control.Monad.Reader (class MonadAsk, ReaderT, ask, runReaderT)
import Control.Monad.State (StateT, get, put, runStateT)
import Control.Promise (Promise, toAff)
import Data.Array (null)
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Tuple (fst, snd)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import Type.Data.Boolean (kind Boolean)
import TypeConversion (JsPrimitive, convertFromWasmType, parseResult)

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

sendBundledCmds :: Endpoint -> Commands -> Aff Unit
sendBundledCmds (Endpoint e) cmds = e.async e.sockets.asyncSocket (show cmds)

-- Generic
send :: forall a. Endpoint -> Remote a -> Aff a
send e (Remote r) = do
    t <- runStateT (runReaderT r e) []
    let res = fst t
    let cmds = snd t
    when (not (null cmds)) (sendBundledCmds e cmds)
    pure res

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
    liftEffect $ log (show c)
    cmds <- get
    liftEffect $ log (show cmds)
    put (append [c] cmds)

runSyncCmd :: Procedure -> Remote JsPrimitive
runSyncCmd p = Remote $ do
    liftEffect $ log (show p)
    (Endpoint e) <- ask
    cs <- get
    r <- liftAff $ e.sync e.sockets.syncSocket (show (Bundle cs p))
    put []
    pure $ convertFromWasmType (parseResult r)

-- Command conversions

init :: String -> Boolean -> Remote JsPrimitive
init s b = runSyncCmd $ Init s b

execute :: String -> Remote JsPrimitive
execute s = runSyncCmd $ Execute s

executeAsync :: String -> Remote Unit
executeAsync s = runAsyncCmd $ ExecuteAsync s

-- Remote monad

newtype Remote a = Remote (ReaderT Endpoint (StateT (Array Command) Aff) a)
derive newtype instance bindRemote ∷ Bind Remote
derive newtype instance monadRemote :: Monad Remote
derive newtype instance applicativeRemote ∷ Applicative Remote
derive newtype instance applyRemote :: Apply Remote
derive newtype instance functorRemote :: Functor Remote
derive newtype instance monadAskRemote :: MonadAsk Endpoint Remote
derive newtype instance monadEffectRemote :: MonadEffect Remote