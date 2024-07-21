-- How to read  a json file
IF OBJECT_ID(N'dbo.stockQuotesStream', N'U') IS NOT NULL
	DROP TABLE dbo.stockQuotesStream
GO
CREATE TABLE stockQuotesStream
(
    symbol NVARCHAR(6),
    bid NUMERIC(8,2),
    bidSize INT,
    ask NUMERIC(8,2),
    askSize INT,
    UpdateTime TIMESTAMP
)
--
IF OBJECT_ID(N'dbo.tradesDataStream', N'U') IS NOT NULL
	DROP TABLE dbo.tradesDataStream
GO
CREATE TABLE tradesDataStream
(
    symbol NVARCHAR(6),
    p NUMERIC(8,2),
    s INT,
    t VARCHAR(50)
)

SELECT *
FROM tradesDataStream

SELECT len('2022-02-13T18:22:15.971Z')

TRUNCATE TABLE stockQuotesStream;
SELECT *
FROM stockQuotesStream
/*
Construction of reference values to sell stocks
*/
IF OBJECT_ID(N'dbo.VwPortfolioReference', N'V') IS NOT NULL
	DROP VIEW dbo.VwPortfolioReference
GO
CREATE VIEW VwPortfolioReference
AS
SELECT 
C.S,
B.ID_DEGIRO idDegiro,
B.ISIN isin,
-- portfólio data
[A].[size] quantityInPortfolio,
[A].[breakEvenPrice],
----------------
[A].[breakEvenPrice]*[A].[size] initialInvestment,
----------------
-- quotes data
ap askPrice,
[as] askSize,
ap*[as] askLiquidity,
bp bidPrice,
bs bidSize,
bp*bs bidLiquidity,
----------------
(bp/[A].[breakEvenPrice]-1)*100 bidReturnPercent,
(ap/[A].[breakEvenPrice]-1)*100 askReturnPercent,
----------------
[A].size * (bp/[A].[breakEvenPrice]-1) bidProfitLoss,
[A].size * (ap/[A].[breakEvenPrice]-1) baskProfitLoss,
[A].[price] lasCloseDayPrice
FROM portfolio A
INNER JOIN DIM_STOCKS_DEGIRO B
    ON A.id = B.ID_DEGIRO
INNER JOIN VwLastQuote C
    ON B.TICKER = C.S


SELECT * FROM VwLastQuote


SELECT * FROM portfolio
SELECT * FROM DIM_STOCKS_DEGIRO WHERE ID_DEGIRO = 19684290 OR TICKER = 'AGRI'
SELECT * FROM stockQuotesStream
SELECT * FROM VwPortfolioReference

INSERT INTO quoteDataStream (S,t) VALUES('AAPL','aa')
TRUNCATE TABLE quoteDataStream

SELECT TOP 10 * from quoteDataStream WITH(NOLOCK)
ORDER BY t DESC

-- Create the sell request to execute the order
TRUNCATE TABLE sellRequest;
INSERT INTO sellRequest(ID_DEGIRO,Symbol,SellQuantity,SellPrice,SellDatetime)
SELECT idDegiro ID_DEGIRO,S Symbol,quantityInPortfolio SellQuantity,askPrice SellPrice, GETDATE() SellDatetime
FROM VwPortfolioReference
WHERE (askPrice/breakEvenPrice)>1.5


select bidReturnPercent,bidProfitLoss,
*
from VwPortfolioReference


SELECT * FROM sellRequest

SELECT * FROM sellResponse

-- TRUNCATE TABLE tradesDataStream
SELECT *
FROM tradesDataStream WITH(NOLOCK)
ORDER BY cast(t AS datetime) DESC

SELECT *
FROM buyRequest

SELECT *
FROM buyResponse

SELECT *
FROM portfolio

SELECT *    
FROM VwPortfolioReference

truncate TABLE quoteDataStream

select len('2021-06-25 07:58:56.550604')

SELECT *
FROM quoteDataStream
ORDER BY t DESC
/*
Obtenção da última cotação para cada ticker
*/
CREATE VIEW VwLastQuote
AS
SELECT *
FROM
(
SELECT S,ap,[as],bp,bs,t,
ROW_NUMBER() OVER (PARTITION BY S ORDER BY t DESC) AS RowNumber
FROM quoteDataStream WITH(NOLOCK)
)  A
WHERE RowNumber = 1


--TRUNCATE TABLE barDataStream
SELECT *
FROM barDataStream with(NOLOCK)
ORDER BY t DESC



SELECT *
FROM
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY t DESC) AS RowNumber
FROM tradesDataStream WITH(NOLOCK)
WHERE DAY(t) = 24 and symbol = 'CYRN'
ORDER BY symbol,t DESC
)  A
WHERE RowNumber = 1


SELECT *
FROM portfolio

TRUNCATE TABLE stockQuotesStream;





INSERT INTO quoteDataStream (S) VALUES('AAPL')

SELECT ID_DEGIRO,SellQuantity,SellPrice,SellDatetime FROM sellRequest
 

BULK INSERT stockQuotesStream FROM 'stockQuotes.csv' 
WITH (
    DATA_SOURCE = 'storagemarkets',
    FIELDTERMINATOR=',',
    DATAFILETYPE='char',
    FIRSTROW=2,
    ROWTERMINATOR='0x0a', 
    TABLOCK
    );


SELECT *
FROM [dbo].[DIM_STOCKS_DEGIRO]
WHERE SYMBOL_DEGIRO = TICKER AND EXCHANGE = 'XNAS'

SELECT LISTA_STOCKS, STRING_AGG (CAST(TICKER AS NVARCHAR(MAX)), ',') as LISTA_STOCKS
FROM
(
    SELECT TOP 100 'STOCK' AS LISTA_STOCKS,TICKER
    FROM [dbo].[DIM_STOCKS_DEGIRO]
    WHERE SYMBOL_DEGIRO = TICKER AND EXCHANGE ='XNAS'
) A
GROUP BY LISTA_STOCKS


SELECT *
FROM sellResponse

select TOP 10 *
from DIM_STOCKS_DEGIRO

select *
from testStreamData

/* Test continuous node js */
CREATE VIEW v1testContinuousNode
AS
SELECT *
FROM 
(
SELECT Dados,
ROW_NUMBER() OVER (ORDER BY Dados DESC) AS RowNumber
FROM testStreamData WITH(NOLOCK)
) A
WHERE RowNumber > 400

SELECT * FROM v1testContinuousNode

---
IF OBJECT_ID(N'dbo.testContinuousNode', N'U') IS NOT NULL
	DROP TABLE dbo.testContinuousNode
GO
CREATE TABLE testContinuousNode
(
    Dados VARCHAR(MAX),
    DateAdded DATETIME
)

TRUNCATE TABLE testContinuousNode
INSERT INTO testContinuousNode SELECT Dados , CURRENT_TIMESTAMP DateAdded FROM v1testContinuousNode WITH(NOLOCK)

SELECT *
FROM testContinuousNode


