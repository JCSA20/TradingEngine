-- Buy Order Execution tables
IF OBJECT_ID(N'dbo.buyRequest', N'U') IS NOT NULL
	DROP TABLE dbo.buyRequest
GO
CREATE TABLE buyRequest
(
PK_BUY_ORDER INT  IDENTITY(1,1) PRIMARY KEY,
ID_DEGIRO INT,
ISIN NVARCHAR(15),
TICKER NVARCHAR(6),
BuyQuantity INT,
BuyPrice NUMERIC(6,3),
BuyDateTime DATETIME,
BuyActive BIT
)
---
IF OBJECT_ID(N'dbo.buyResponse', N'U') IS NOT NULL
	DROP TABLE dbo.buyResponse
GO
CREATE TABLE buyResponse
(
PK_BUY_ORDER INT,
ID_DEGIRO INT,
ISIN NVARCHAR(15),
TICKER NVARCHAR(6),
BuyQuantity INT,
BuyPrice NUMERIC(6,3),
BuyDateTime DATETIME,
BuyOrderIdDegiro NVARCHAR(50)
)
-- Buying Orders not executed, still waiting
IF OBJECT_ID(N'dbo.vwWaitingBuy', N'V') IS NOT NULL
	DROP VIEW dbo.vwWaitingBuy
GO
SELECT 
a.PK_ORDER BuyOrderIdRequest,
a.ID_DEGIRO,
a.BuyQuantity BuyQuantityRequest,
a.BuyPrice BuyPriceRequest,
a.BuyDateTime BuyDateTimeRequest,
a.BuyActive BuyActiveRequest,
b.BuyDateTime BuyDateTimeResponse,
b.BuyQuantity BuyQuantityResponse,
b.BuyPrice BuyPriceResponse,
b.BuyOrderIdDegiro,
(a.BuyQuantity - b.BuyQuantity) OrdersNotExecuted,
(a.BuyPrice - b.BuyPrice)/b.BuyPrice ExecutedPriceGap
FROM buyRequest a
LEFT JOIN buyResponse b ON a.PK_ORDER = b.PK_ORDER
------------------------------------------------------------------------------------------------------------------------
-- Portfolio Table
------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.portfolio', N'U') IS NOT NULL
	DROP TABLE dbo.portfolio
GO
CREATE TABLE portfolio
(
id INT NOT NULL PRIMARY KEY,
size INT NOT NULL,
price NUMERIC(6,3),
breakEvenPrice NUMERIC(6,3),
insertDateTime DATETIME DEFAULT CURRENT_TIMESTAMP
)
------------------------------------------------------------------------------------------------------------------------
-- Day Gainers Stock List
------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.dayGainers', N'U') IS NOT NULL
	DROP TABLE dbo.portfolio
GO
CREATE TABLE dayGainers
(
symbol NVARCHAR(6),
insertDateTime DATETIME DEFAULT CURRENT_TIMESTAMP
)
------------------------------------------------------------------------------------------------------------------------
-- Sell Order Execution tables
------------------------------------------------------------------------------------------------------------------------
-- Buy Order Execution tables
IF OBJECT_ID(N'dbo.sellRequest', N'U') IS NOT NULL
	DROP TABLE dbo.sellRequest
GO
CREATE TABLE sellRequest
(
PK_ORDER INT  IDENTITY(1,1) PRIMARY KEY,
ID_DEGIRO INT,
SellQuantity INT,
SellPrice NUMERIC(6,3),
SellDateTime DATETIME,
SellOrderId INT,
SellActive BIT
)
---
IF OBJECT_ID(N'dbo.sellResponse', N'U') IS NOT NULL
	DROP TABLE dbo.sellResponse
GO
CREATE TABLE sellResponse
(
PK_ORDER INT,
ID_DEGIRO INT,
SellQuantity INT,
SellPrice NUMERIC(6,3),
SellDateTime DATETIME,
SellOrderIdDegiro  NVARCHAR(50)
)
-- Selling Orders not executed, still waiting
IF OBJECT_ID(N'dbo.vwWaitingSell', N'V') IS NOT NULL
	DROP VIEW dbo.vwWaitingSell
GO
SELECT 
a.PK_ORDER BuyOrderIdRequest,
a.ID_DEGIRO,
a.SellQuantity BuyQuantityRequest,
a.SellPrice BuyPriceRequest,
a.SellDateTime BuyDateTimeRequest,
a.SellActive BuyActiveRequest,
b.SellDateTime BuyDateTimeResponse,
b.SellQuantity BuyQuantityResponse,
b.SellPrice BuyPriceResponse,
b.SellOrderIdDegiro,
(a.SellQuantity - b.SellQuantity) OrdersNotExecuted,
(a.SellPrice - b.SellPrice)/b.SellPrice ExecutedPriceGap
FROM sellRequest a
LEFT JOIN sellResponse b ON a.PK_ORDER = b.PK_ORDER
-------------------------------------------------------------------------------------------------------------------------------------
-- Insert buy orders
-------------------------------------------------------------------------------------------------------------------------------------
TRUNCATE TABLE buyRequest;
SELECT TOP 1 PK_BUY_ORDER, ID_DEGIRO, ISIN, BuyQuantity, BuyPrice, BuyDateTime, BuyActive FROM buyRequest ORDER BY PK_BUY_ORDER ASC

-- fill the fields for buying orders
TRUNCATE TABLE buyRequest;
INSERT INTO buyRequest (ID_DEGIRO,ISIN,Ticker,BuyQuantity,BuyPrice,BuyDateTime,BuyActive) 
SELECT ID_DEGIRO, ISIN, TICKER,8 BuyQuantity,2.76 BuyPrice,GETDATE() BuyDateTime,1 BuyActive FROM dbo.DIM_STOCKS_DEGIRO WITH(NOLOCK) WHERE TICKER = 'WKHS'
--	ON A.TICKER COLLATE SQL_Latin1_General_CP1_CI_AS = B.TICKER COLLATE SQL_Latin1_General_CP1_CI_AS


SELECT *
FROM quoteDataStream with(NOLOCK)
ORDER BY t desc



INSERT INTO quoteDataStream(S,a) SELECT 'ok' as S,2.1 AS a


TRUNCATE TABLE quoteDataStream


INSERT INTO quoteDataStream(S,bp,bs,ap,) SELECT 'OPRH' AS S,1 AS bp, 2 AS bs, 3 AS ap,4 AS [as] 

SELECT *
FROM portfolio

SELECT *
FROM VwPortfolio


---
INSERT INTO dbo.DIM_STOCKS_DEGIRO(TICKER,EXCHANGE,ID_DEGIRO,ISIN,SYMBOL_DEGIRO)
VALUES ('ORPH','XNAS',18368067,'US6873051022','ORPH')
---
SELECT *
FROM dbo.DIM_STOCKS_DEGIRO
WHERE TICKER = 'ORPH'
-------------------------------------------------------------------------------------------------------------------------------------
-- Insert the executed orders in the portfolio table
-------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT EXCHANGE
FROM dbo.DIM_STOCKS_DEGIRO


TRUNCATE TABLE portfolio
SELECT *
FROM portfolio

SELECT LEN('2021-12-25T20:46:18.264Z')

SELECT *
FROM buyResponse


SELECT TOP 1 PK_BUY_ORDER, ID_DEGIRO, ISIN,Ticker, BuyQuantity, BuyPrice, BuyDateTime, BuyActive FROM buyRequest ORDER BY PK_BUY_ORDER ASC

UPDATE buyRequest SET BuyQuantity = 10

TRUNCATE TABLE buyResponse;

SELECT * FROM buyRequest WITH(NOLOCK)
SELECT * FROM buyResponse WITH(NOLOCK)

INSERT INTO portfolio (id,[size],price,breakEvenPrice,insertDateTime)
SELECT ID_DEGIRO,BuyQuantity,2.37,2.37,BuyDateTime FROM buyResponse WITH(NOLOCK)

TRUNCATE TABLE portfolio
SELECT * FROM portfolio
update portfolio
set ID_DEGIRO = 19662798, BuyQuantity = 3, BuyPrice = 11.32


TRUNCATE TABLE sellRequest;
TRUNCATE TABLE sellResponse;
-- O insert nest tabela tem de ser efetuado por outro serviço
INSERT INTO sellRequest (ID_DEGIRO,SellQuantity,SellPrice,SellDateTime) 
SELECT id,size SellQuantity,BuyPrice SellPrice,BuyDateTime SellDateTime  FROM portfolio WITH(NOLOCK)


SELECT * FROM sellRequest WITH(NOLOCK)
SELECT * FROM sellResponse WITH(NOLOCK)








SELECT ID_DEGIRO,SellQuantity,SellPrice,SellDatetime FROM sellRequest


INSERT INTO sellRequest

UPDATE buyResponse
SET ID_DEGIRO = 19662798,ISIN = 'US2936021086', TICKER = 'ENSC',BuyPrice= 3,BuyQuantity = 5


DELETE FROM buyResponse WHERE BuyOrderIdDegiro = '6b0ca024-b5d9-4d5f-aec5-55e30a192f4d'


INSERT INTO buyResponse(PK_BUY_ORDER,ID_DEGIRO,ISIN,Ticker,BuyQuantity,BuyPrice,BuyDateTime,BuyOrderIdDegiro) 
SELECT PK_BUY_ORDER,ID_DEGIRO,ISIN,Ticker,BuyQuantity,BuyPrice,getdate() BuyDateTime,'6b0ca024-b5d9-4d5f-aec5-55e30a192f4d' BuyOrderIdDegiro 
FROM buyRequest


SELECT TOP 1 PK_BUY_ORDER, ID_DEGIRO, ISIN,Ticker, BuyQuantity, BuyPrice, BuyDateTime, BuyActive FROM buyRequest ORDER BY PK_BUY_ORDER ASC


DROP TABLE testStreamData;
CREATE TABLE testStreamData
(
	Dados NVARCHAR(MAX)
)

SELECT * FROM testStreamData