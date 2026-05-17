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
      sha256 ::  String,
      accountType    :: String,
      accountNameOwner    :: String,
      notes    :: String,
      cleared      :: Integer,
      accountId      :: Integer,
      transactionId     :: Integer,
      reoccurring      :: Bool
--      dateUpdated    ::  LocalTime -- NominalDiffTime,  LocalTime, UTCTime Integer
--     dateAdded    ::  !Time.LocalTime, -- NominalDiffTime,  LocalTime, UTCTime
--     transactionDate    :: Day
     --amount      :: Rational, --Rational (doesn't work with aeson), Double (doesn't work with Postgresql)
--    } deriving (Show, FromRow, Generic)
--    } deriving (Show, Eq, FromRow, Generic, Ord)
    } deriving (Show, Eq, Generic, Ord)

instance FromRow Transaction
instance ToRow Transaction

main :: IO ()
main = do putStrLn "--- separated ---"
          conn <- connect defaultConnectInfo { connectHost = "localhost", connectDatabase = "finance_db", connectUser = "henninb", connectPassword = "monday1"}
          putStrLn "--- separated ---"
          mapM_ print =<< (query_ conn "SELECT 1 + 1" :: IO [Only Int])
          putStrLn "--- separated ---"
          mapM_ print =<< (query conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction WHERE guid = ? and account_name_owner = ?" ("423fa3d2-d6e9-4dbf-bd39-928d284ad1a6" :: String, "chase_brian" :: String) :: IO [Transaction])
          putStrLn "--- separated ---"
--          mapM_ print =<< (query conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring,date_updated, date_added,transaction_date FROM t_transaction WHERE guid = ? and account_name_owner = ?" ("423fa3d2-d6e9-4dbf-bd39-928d284ad1a6" :: String, "chase_brian" :: String) :: IO [Transaction])
          putStrLn "--- separated ---"
--          mapM_ print =<< (query_ conn transactionQuery :: IO [Transaction]) where transactionQuery = "SELECT guid,description,account_type,account_name_owner FROM t_transaction LIMIT 1"
          mapM_ print =<< (query_ conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction LIMIT 10" :: IO [Transaction])
          putStrLn "--- separated ---"
          mapM_ print =<< (query_ conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring from t_transaction" :: IO [Transaction])
          putStrLn "--- separated ---"
          mapM_ print =<< (query_ conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction WHERE guid='0d4d5664-bb66-4d15-951b-42ef78b4e411'" :: IO [Transaction])
          -- mapM_ print =<< (query_ conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction WHERE guid='" ++ "423fa3d2-d6e9-4dbf-bd39-928d284ad1a6" ++ "'" :: IO [Transaction])
--          putStrLn "--- separated ---"
