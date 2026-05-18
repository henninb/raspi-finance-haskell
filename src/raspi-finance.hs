{-# LANGUAGE OverloadedStrings,TemplateHaskell #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE RecordWildCards #-}

import Data.Aeson
import Data.Aeson.TH
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.Time
import Data.Typeable
import qualified Data.Time as Time
import qualified Data.ByteString as SB
import qualified Data.ByteString.Lazy as LB
--import System.Locale (defaultTimeLocale)
import Data.Time.Format (formatTime)
import Data.Time.Clock
import Data.List
import System.Directory
import Data.Aeson.Parser
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.ToField
import Database.PostgreSQL.Simple.ToRow
-- import Database.PostgreSQL.Simple.Statement
import GHC.Generics (Generic)
--import Control.Lens
import Data.Ratio
import Control.Lens

data Transaction = Transaction
    { guid :: String,
      description :: String,
      category    :: String,
      sha256 :: String,
      accountType    :: String,
      accountNameOwner    :: String,
      notes    :: String,
      cleared   :: Integer,
      accountId      :: Integer,
      transactionId     :: Integer,
      reoccurring      :: Bool
--      dateUpdated    ::  LocalTime -- NominalDiffTime,  LocalTime, UTCTime Integer
    } deriving (Show, Eq, Generic, Ord)

makeLenses ''Transaction

--instance FromRow Transaction
instance ToRow Transaction

doubleIt :: Integer -> Integer
doubleIt ts = ts * 2

instance FromRow Transaction where
  fromRow = Transaction <$>
    field <*>
    field <*>
    field <*>
    field <*>
    field <*>
    field <*>
    field <*>
    field <*>
    field <*>
    field <*>
    field

-- (Book <$> field)
-- works lambda function
instance FromJSON Transaction where
  parseJSON = withObject "transaction" $ \o ->
    Transaction <$> o .: "guid"
           <*> o .: "description"
           <*> o .: "category"
           <*> o .: "sha256"
           <*> o .: "accountType"
           <*> o .: "accountNameOwner"
           <*> o .: "notes"
           <*> o .: "cleared"
           <*> o .: "accountId"
           <*> o .: "transactionId"
           <*> o .: "reoccurring"


main :: IO ()
main = do putStrLn "--- start ---"
          singleRecord <- LB.readFile "file.json"
          records <- LB.readFile "filelist.json"
          list <- LB.readFile "list.json"
          conn <- connect defaultConnectInfo { connectHost = "postgresql.bhenning.com", connectDatabase = "finance_db", connectUser = "henninb", connectPassword = "monday1"}
          print (decode singleRecord :: Maybe Transaction)
          putStrLn "--- separated ---"
          print (decode records :: Maybe [Transaction])
          putStrLn "--- separated ---"
          mapM_ print =<< (query_ conn "SELECT 1 + 1" :: IO [Only Int])
          putStrLn "--- separated ---"

          mapM_ print =<< (query conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction WHERE guid = ? and account_name_owner = ?" ("423fa3d2-d6e9-4dbf-bd39-928d284ad1a6" :: String, "chase_brian" :: String) :: IO [Transaction])
          putStrLn "--- separated ---"
--          test { c = "Goodbye" }
          epoch_int <- (read . formatTime defaultTimeLocale "%s" <$> getCurrentTime) :: IO Int
          putStrLn (show epoch_int)
          putStrLn "--- separated ---"
--          round `fmap` getPOSIXTime
          -- let query = unlines $ ["SELECT guid from t_transaction"]
          -- print =<< ( query_ conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction LIMIT 10" :: IO [Transaction] )
          let resultSet = query_ conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction LIMIT 10" :: IO [Transaction]
          print =<< resultSet
          let z = typeOf resultSet
          print z
          putStrLn "--- separated ---"
          -- query conn "select guid,description from t_transaction where account_name_owner in ?" $ In ["Anna", "Boris", "Carla"]
