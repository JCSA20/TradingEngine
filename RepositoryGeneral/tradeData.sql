
TRUNCATE TABLE tradesDataStream
SELECT max(p),min(p) FROM tradesDataStream
WHERE symbol = 'DATS'
ORDER BY t DESC



SELECT *
FROM tradesDataStream WITH(NOLOCK)


SELECT * FROM quoteDataStream

/*
Obtenção da última transação para cada ticker
*/
CREATE VIEW VwTradeDataIndexedByTicker
AS
SELECT symbol, p, s, t, p*s liquidity,
ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY t DESC) AS RowNumber
FROM tradesDataStream
WHERE symbol = 'EOSE'

/* ///////////////////////////////////////////////////
    Stocks traded in NASDAQ, AMEX and NYSE
///////////////////////////////////////////////////*/
IF OBJECT_ID(N'dbo.VwDailyBarsNasdaqAmexNyse', N'V') IS NOT NULL
	DROP VIEW dbo.VwDailyBarsNasdaqAmexNyse
GO
CREATE VIEW VwDailyBarsNasdaqAmexNyse
AS
SELECT ID_DATE, A.TICKER, VOLUME, OPEN_PRICE, CLOSE_PRICE, HIGH_PRICE, LOW_PRICE
FROM MARKETS.TEMP_DAILY_BARS A WITH(NOLOCK)
LEFT JOIN DIM_STOCKS B
    ON A.TICKER = B.TICKER collate SQL_Latin1_General_CP1_CI_AS
WHERE PRIMARY_EXCHANGE IN('XNAS','XNGS','XNYS','XASE','ARCX')
---
SELECT a.symbol,
c.CLOSE_PRICE,
(b.p/c.CLOSE_PRICE -1) deltaClose,
a.p,a.s,a.liquidity,
(a.p/b.p -1) deltaPrice,
a.t
FROM VwTradeDataIndexedByTicker a WITH(NOLOCK)
INNER JOIN VwTradeDataIndexedByTicker b WITH(NOLOCK)
    ON a.symbol = b.symbol
INNER JOIN VwDailyBarsNasdaqAmexNyse c WITH(NOLOCK)
    ON a.symbol = c.TICKER collate SQL_Latin1_General_CP1_CI_AS
WHERE a.RowNumber = 1 AND b.RowNumber = 2 AND c.ID_DATE = 20220302 AND (a.p/c.CLOSE_PRICE -1)>0.005 AND a.liquidity>10000
ORDER BY a.liquidity DESC


SELECT *
FROM VwTradeDataIndexedByTicker
ORDER BY t DESC

SELECT *
FROM portfolio


SELECT 
CASE PRIMARY_EXCHANGE
    WHEN 'XNAS' THEN 'NASDAQ:'+TICKER
    WHEN 'XASE' THEN 'NYSEAMERICAN:'+TICKER
    WHEN 'XNYS' THEN 'NYSE:'+TICKER
    ELSE 'NA'
END AS STOCK_EXCHANGE,
TICKER,
NAME_COMPANY
FROM [dbo].[DIM_STOCKS]
WHERE TYPE = 'CS' AND PRIMARY_EXCHANGE IN('XNAS','XASE','XNYS')


/* ///////////////////////////////////////////////////
   Tabela que recebe os dados do Google Finance
///////////////////////////////////////////////////*/
IF OBJECT_ID(N'dbo.StockData', N'U') IS NOT NULL
	DROP TABLE dbo.StockData
GO
CREATE TABLE StockData
(
Exchange NVARCHAR(50),
TICKER	NVARCHAR(10),
NAME_COMPANY NVARCHAR(100),
Price NUMERIC(9,2),
CurrentTime NVARCHAR(50)
)

TRUNCATE TABLE StockData
SELECT *
FROM StockData WITH(NOLOCK)
WHERE TICKER = 'A'
ORDER BY TICKER,CurrentTime DESC


/* ///////////////////////////////////////////////////
    View que contém o fluxo intraday ordenado de preços
///////////////////////////////////////////////////*/
IF OBJECT_ID(N'dbo.VwIntraDayPrices', N'V') IS NOT NULL
	DROP VIEW dbo.VwIntraDayPrices
GO
CREATE VIEW VwIntraDayPrices
AS
SELECT Exchange, TICKER,NAME_COMPANY,Price,CurrentTime,
ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY CurrentTime DESC) AS RowNumber
FROM StockData WITH(NOLOCK)


SELECT a.Exchange, 
a.TICKER,
a.NAME_COMPANY,
b.Price InitialPrice,
a.Price CurrentPrice,
a.CurrentTime,
(a.Price/b.Price - 1) PriceVariation
FROM VwIntraDayPrices a
INNER JOIN VwIntraDayPrices b
    ON a.TICKER = b.TICKER
WHERE a.RowNumber = 1 AND b.RowNumber = 2
    AND (a.Price/b.Price - 1) > 0.01 AND a.Price > 0.7
ORDER BY 7 DESC
