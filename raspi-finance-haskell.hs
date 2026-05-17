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
import System.Locale (defaultTimeLocale)
import Data.Time.Format (formatTime)
import Data.Time.Clock
import Data.List
import System.Directory
import Data.Aeson.Parser
--import Data.String.Utils
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.ToField
import Database.PostgreSQL.Simple.ToRow
import GHC.Generics (Generic)
--import Data.Int.Int64
--import Servant
import Data.Ratio


newtype Money = Money
  { unMoney :: Double
  } deriving (Show, Eq, Num)

newtype ProjectId = ProjectId
  { unProjectId :: Int
  } deriving (Show, Eq, Num)

newtype DateTime = DateTime {
  dateTime :: LocalTime
} deriving (Show, Eq)

--data Transaction
--  = Sale Money
--  | Purchase Money
--  deriving (Eq, Show)

data Budget = Budget
  { budgetIncome      :: Money
  , budgetExpenditure :: Money
  } deriving (Show, Eq)

data Transaction = Transaction
    { guid :: String,
      description :: String,
      category    :: String,
      sha256 :: Maybe String,
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





-- $(deriveJSON defaultOptions ''Transaction)
--this code works
--instance FromJSON Transaction
--instance ToJSON Transaction
--
instance FromRow Transaction
instance ToRow Transaction

--instance ToJSON Transaction where
--    toJSON = genericToJSON $ aesonPrefix snakeCase
--instance FromJSON Transaction where
--    parseJSON = genericParseJSON $ aesonPrefix snakeCase

doubleIt :: Integer -> Integer
doubleIt (ts) = ts * 2

-- works lambda function
instance FromJSON Transaction where
  parseJSON = withObject "transaction" $ \o ->
    Transaction <$> o .: "guid"
           <*> o .: "description"
           <*> o .: "category"
           <*> o .:? "sha256"
           <*> o .: "accountType"
           <*> o .: "accountNameOwner"
           <*> o .: "notes"
           <*> o .: "cleared"
           <*> o .: "accountId"
           <*> o .: "transactionId"
           <*> o .: "reoccurring"




--instance FromRow Transaction where
--  fromRow = Transaction <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

--date :: IO Integer
-- date = getCurrentTime >>= return . toModifiedJulianDay . utctDay

--instance FromRow a => FromRow (Stamped a) where
--   fromRow = Stamped <$> fromRow <*> (parseTimestamp <$> field)




--instance FromRow Transaction where
--  fromRow = Transaction
--    guid <$> field
--    description  <$> field
--    category <$>  field
--    sha256 <$>  field
--    accountType <$> field
--    accountNameOwner  <$> field
--    notes <$>  field
--    cleared <$>  field
--    accountId  <$> field
--    transactionId  <$> field
--    reoccurring <$>  field

--instance FromRow Transaction where
--  fromRow = do
--    (guid, description, sha256, accountType, accountNameOwner, notes,cleared,accountId,transactionId, reoccurring ) <- fromRow
--    return $ Transaction guid, description, sha256, accountType, accountNameOwner, notes,cleared,accountId,transactionId, reoccurring
--

---- works correctly
--instance FromJSON Transaction where
--  parseJSON = withObject "transaction" $ \o -> do
--    guid <- o .: "guid"
--    description  <- o .: "description"
--    category  <- o .: "category"
--    sha256  <- o .:? "sha256"
--    accountType  <- o .: "accountType"
--    accountNameOwner  <- o .: "accountNameOwner"
--    notes  <- o .: "notes"
--    cleared  <- o .: "cleared"
--    accountId  <- o .: "accountId"
--    transactionId  <- o .: "transactionId"
--    reoccurring  <- o .: "reoccurring"
--    return Transaction{..}
-- return $ Transaction guid description sha256 accountType accountNameOwner notes cleared accountId transactionId reoccurring

--instance Data.Aeson.ToJSON Transaction
--    where
--    toJSON obj = Data.Aeson.object ((Data.Aeson..=) "id" (categoryId obj) : (Data.Aeson..=) "name" (categoryName obj) : [])
--          toEncoding obj = Data.Aeson.pairs ((Data.Aeson..=) "id" (categoryId obj) GHC.Base.<> (Data.Aeson..=) "name" (categoryName obj))
--instance Data.Aeson.Types.FromJSON.FromJSON Transaction
--    where parseJSON = Data.Aeson.Types.FromJSON.withObject "Transaction" (\obj -> (GHC.Base.pure Category GHC.Base.<*> (obj Data.Aeson.Types.FromJSON..:? "id")) GHC.Base.<*> (obj Data.Aeson.Types.FromJSON..:? "name"))

--transaction1 :: Relation () Transaction
--transaction1 = relation $ do
--  a <- query account
--  wheres $ a ! Transaction.category' `in'` values ["fuel"]
--  return a

--instance FromRow Transaction where
--  fromRow = Transaction <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

--instance FromRow Transaction where
--  fromRow = Transaction{..} = [guid,accountNameOwner,notes,description,category]

isRegularFileOrDirectory :: FilePath -> Bool
isRegularFileOrDirectory f = f /= "." && f /= ".."

printValues :: [String] -> IO ()
printValues = putStrLn . unlines

readJsonFile f = do
  singleRecord <- LB.readFile f
  print (decode singleRecord :: Maybe Transaction)

-- does not work
printValuesFile =  map readJsonFile

--transactionSumAmount :: [Transaction] -> Double
--transactionSumAmount [] = 0.0
--transactionSumAmount (x:xs) =  amount x + transactionSumAmount xs


--data App = App
--    { _sess :: Snaplet SessionManager
--    }
--
--makeLenses ''App
--
---- | The application's routes.
--routes :: [(LB.ByteString, Handler App App ())]
--routes = [ ("/",            writeText "hello")
--         ]
--https://artyom.me/aeson

main :: IO ()
main = do putStrLn "read file and load it to a structure."
--          [file] <- getArgs
          singleRecord <- LB.readFile "file.json"
          records <- LB.readFile "filelist.json"
          list <- LB.readFile "list.json"
          --all <- getDirectoryContents "../raspi-finance-convert/json_in/.processed"

--          conn <- connectPostgreSQL "host=localhost port=5432 connect_timeout=10 connectDatabase=finance_db"
          conn <- connect defaultConnectInfo { connectHost = "postgresql.bhenning.com", connectDatabase = "finance_db", connectUser = "henninb", connectPassword = "monday1"}

          --listBySuit = [ x = "one" | x <- jsonFiles]

          --let filtered = filter (endsWith "json") all
--          let toCamelCase = camelCase(jsonFiles)

--          d <- (eitherDecode <$> singleRecord) :: IO (Either String Transaction)

          print (decode singleRecord :: Maybe Transaction)
          putStrLn "--- separated ---"
          print (decode records :: Maybe [Transaction])
          putStrLn "--- separated ---"
          --print (decode list :: Maybe [Transaction])
          --printValues jsonFiles
          let listOfTransactions = decode list :: Maybe [Transaction]
          print listOfTransactions
          --print (transactionSumAmount listOfTransactions)
          putStrLn "--- separated ---"
          mapM_ print =<< (query_ conn "SELECT 1 + 1" :: IO [Only Int])
          putStrLn "--- separated ---"
          mapM_ print =<< (query conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring FROM t_transaction WHERE guid = ? and account_name_owner = ?" ("423fa3d2-d6e9-4dbf-bd39-928d284ad1a6" :: String, "chase_brian" :: String) :: IO [Transaction])
          putStrLn "--- separated ---"
--          mapM_ print =<< (query conn "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id,transaction_id,reoccurring,date_updated, date_added,transaction_date FROM t_transaction WHERE guid = ? and account_name_owner = ?" ("423fa3d2-d6e9-4dbf-bd39-928d284ad1a6" :: String, "chase_brian" :: String) :: IO [Transaction])
          putStrLn "--- separated ---"
--          print (decodeJSON singleRecord :: Transaction)
          putStrLn "--- separated ---"
--          putStrLn $ formatTime defaultTimeLocale "%Y-%m-%d (%a)" now
--          mapM_ print =<< (query_ conn q :: IO [Transaction]) where q = "SELECT guid,description,category,sha256,account_type,account_name_owner,notes,cleared,account_id, transaction_id,reoccurring,date_updated, date_added,transaction_date FROM t_transaction LIMIT 10"

--          mapM_ print =<< (query_ conn bookQuery :: IO [Book]) where bookQuery = "SELECT isbn,title,authors FROM books LIMIT 1"
--          mapM_ print =<< (query_ conn transactionQuery :: IO [Transaction]) where transactionQuery = "SELECT guid,description,account_type,account_name_owner FROM t_transaction LIMIT 1"
--          mapM_ print =<< (query_ conn q :: IO [Only LB.ByteString]) where q = "SELECT guid FROM t_transaction LIMIT 10"
--          mapM_ print =<< (query_ conn q :: IO [Transaction]) where q = "SELECT guid FROM t_transaction LIMIT 10"
--          mapM_ print =<< (query_ conn q :: IO [LB.ByteString, LB.ByteString]) where q = "SELECT guid,description FROM t_transaction LIMIT 10"
--          mapM_ print =<< (query_ conn "select guid from t_transaction" :: IO [Transaction])
--          query conn "SELECT title FROM books WHERE isbn=?" (Only "a" :: Only String)  :: IO [Only String]