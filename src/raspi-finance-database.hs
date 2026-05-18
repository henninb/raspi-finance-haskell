{-# LANGUAGE OverloadedStrings,TemplateHaskell #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

--import Text.JSON.Generic
--stack install aeson-casing
import Data.Aeson
import Data.Aeson.TH
--import Data.Aeson.Casing
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.Time
import qualified Data.Time as Time
import qualified Data.ByteString as SB
import qualified Data.ByteString.Lazy as LB
import Data.Time.Format (formatTime)
import Data.Time.Clock
import Data.List
import System.Directory
import System.Environment (getArgs)
--import Data.String.Utils
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.ToField
import Database.PostgreSQL.Simple.ToRow
import GHC.Generics (Generic)
--import Data.Int.Int64
--import Servant
import Data.Ratio

newtype DateTime = DateTime {
  dateTime :: LocalTime
} deriving (Show, Eq)

data Transaction = Transaction
    { guid :: String,
      description :: String,
      category    :: String,
      accountType    :: String,
      accountNameOwner    :: String,
      notes    :: String,
      transactionState :: String,
      accountId      :: Integer,
      transactionId     :: Integer,
      reoccurringType  :: String
    } deriving (Show, Eq, Generic, Ord)

instance FromRow Transaction
instance ToRow Transaction

main :: IO ()
main = do
    args <- getArgs
    case args of
        [account] -> do
            conn <- connect defaultConnectInfo { connectHost = "postgresql.bhenning.com", connectDatabase = "finance_db", connectUser = "henninb", connectPassword = "monday1"}
            transactions <- query conn "SELECT guid,description,category,account_type,account_name_owner,notes,transaction_state,account_id,transaction_id,reoccurring_type FROM t_transaction WHERE account_name_owner = ? ORDER BY transaction_id" (Only account) :: IO [Transaction]
            mapM_ print transactions
        _ -> putStrLn "usage: raspi-finance-database <account_name_owner>"
