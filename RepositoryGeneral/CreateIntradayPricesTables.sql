/*

*/
-- Table for storing the intraday prices
DROP TABLE dbo.tblIntraDayPricesPrimaryBase;
CREATE TABLE dbo.tblIntraDayPricesPrimaryBase (
                                                [ticker] [nvarchar] (10) NULL,        
                                                [o]      [numeric] (10,2) NULL,                                                
                                                [c]      [numeric] (10,2) NULL,
                                                [h]      [numeric] (10,2) NULL,
                                                [l]      [numeric] (10,2) NULL,                             
                                                [n]      [int] NULL,
                                                [v]      [int] NULL,
                                                [t]      [nvarchar] (30) NULL                                                                                                           
                         );
-- Table for defining the stocks and dates to import from polygon
IF OBJECT_ID(N'dbo.tblDatesAndStocksToImportIntraDayPrices', N'U') IS NOT NULL
	DROP TABLE dbo.tblDatesAndStocksToImportIntraDayPrices
GO
CREATE TABLE dbo.tblDatesAndStocksToImportIntraDayPrices
(
	[TICKER]	 [nvarchar](10) NOT NULL,
	[START_DATE] [nvarchar](10) NOT NULL,
	[END_DATE]	 [nvarchar](10) NOT NULL,
) ON [PRIMARY]

SELECT TOP 1 TICKER,START_DATE, END_DATE FROM dbo.tblDatesAndStocksToImportIntraDayPrices

SELECT TOP 1 TICKER,START_DATE, END_DATE FROM dbo.tblDatesAndStocksToImportIntraDayPrices

SELECT * FROM tblDatesAndStocksToImportIntraDayPrices

SELECT *
,CLOSE_PRICE/OPEN_PRICE DAILY_VARIATION
FROM MARKETS.TEMP_DAILY_BARS WITH(NOLOCK)
WHERE ID_DATE = 20220810
ORDER BY 9 DESC



SELECT *,DATEADD(s,CAST(LEFT(t,10) AS INT), '1970-01-01') [Time]
FROM dbo.tblIntraDayPricesPrimaryBase

-- View for indexing the trades data points
IF OBJECT_ID(N'dbo.vwIntradayTradeIndex', N'V') IS NOT NULL
	DROP VIEW dbo.vwIntradayTradeIndex
GO
CREATE VIEW vwIntradayTradeIndex
AS
SELECT 
ticker
,o
,c
,h
,l
,n
,v
,t
,v*(o+c)/2 liquidity
,DATEADD(s,CAST(LEFT(t,10) AS INT), '1970-01-01') [tradeTime]
,ROW_NUMBER() OVER (ORDER BY t ASC) AS tradeIndex
FROM [dbo].[tblIntraDayPricesPrimaryBase]
WHERE DATEADD(s,CAST(LEFT(t,10) AS INT), '1970-01-01')  between CONCAT(LEFT(DATEADD(s,CAST(LEFT(t,10) AS INT), '1970-01-01') ,12), ' 09:30:00.000') AND CONCAT(LEFT(DATEADD(s,CAST(LEFT(t,10) AS INT), '1970-01-01') ,12), ' 16:30:00.000')

SELECT TOP 1 TICKER,START_DATE, END_DATE FROM dbo.tblDatesAndStocksToImportIntraDayPrices

SELECT DATEADD(s,CAST(LEFT('1660756920000',10) AS INT), '1970-01-01') 




-- View with only index positives
IF OBJECT_ID(N'dbo.vwIntradayTradeIndexUp', N'V') IS NOT NULL
	DROP VIEW dbo.vwIntradayTradeIndexUp
GO
CREATE VIEW vwIntradayTradeIndexUp
AS
SELECT       
a.ticker
,a.o
,a.c
,a.h
,a.l
,a.n
,a.v
,a.tradeTime tradeTimeStart
,a.liquidity liquidityStart
,a.tradeIndex tradeIndexStart
,b.tradeTime tradeTimeEnd
,b.liquidity liquidityEnd
,b.tradeIndex tradeIndexEnd
-----
,MARKETS.UDF_DIV(b.c, a.o) variationPrice
,a.liquidity+b.liquidity totalLiquidity
,a.n + b.n totalTransactions
FROM dbo.vwIntradayTradeIndex a
LEFT OUTER JOIN dbo.vwIntradayTradeIndex b
	ON a.ticker = b.ticker and a.tradeIndex = b.TradeIndex -1
WHERE a.c>a.o


IF OBJECT_ID(N'dbo.[ExtremePointsMinuteIntraDayStockPrices]', N'U') IS NOT NULL
	DROP TABLE dbo.[ExtremePointsMinuteIntraDayStockPrices]
CREATE TABLE [dbo].[ExtremePointsMinuteIntraDayStockPrices](
															[Ticker] [nvarchar](5) NOT NULL,
															[TradeDate] [datetime] NOT NULL,
															[StartingPoint] [int] NULL,
															[EndingPoint] [int] NULL
															) ON [PRIMARY]


-- Criação do vector dos trades positivos
-- criação da view com os pontos
IF OBJECT_ID(N'dbo.VwIndexedPointsUp', N'V') IS NOT NULL
	DROP VIEW dbo.VwIndexedPointsUp
GO
CREATE VIEW VwIndexedPointsUp
AS
SELECT 
MAX(TICKER) ticker
,MAX(tradeTimeStart) tradeDate -- we need just the day
,STRING_AGG(tradeIndexStart,'-') indexedPointsUp
FROM
(
SELECT 
*
FROM SQL_DATABASE.dbo.vwIntradayTradeIndexUp
) A



-- running the sp for obtain the extreme points
-- 1º step) define the day and stock to import
TRUNCATE TABLE tblDatesAndStocksToImportIntraDayPrices
INSERT INTO tblDatesAndStocksToImportIntraDayPrices(TICKER,START_DATE,END_DATE)
VALUES('NERV','2022-08-22','2022-08-22')
-- 2º step) run the 2 webjobs:
							-- 1º) ExtractIntradayPrices
							-- 2º) LoadIntraDayPrices
-- 3º step) run the sp
EXEC dbo.SP_InsertExtremePoints
SELECT * FROM ExtremePointsMinuteIntraDayStockPrices
-- 4º record to historical
	-- tabela para registo do histórico das estatísticas intraday
	--TRUNCATE TABLE tblIntradayPricesPercentRankHistorical
	INSERT INTO tblIntradayPricesPercentRankHistorical(Ticker,TradeDate,StartingPoint,EndingPoint,startTime,startPrice,endTime,endtPrice,priceVariation,timeDuration,numberPeriods,totalLiquidity,PercentRank)
	SELECT Ticker,CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT) TradeDate,StartingPoint,EndingPoint,startTime,startPrice,endTime,endtPrice,priceVariation,timeDuration,numberPeriods,totalLiquidity,PercentRank 
	FROM VwIntradayPricesPercentRank
	WHERE CONCAT(Ticker,CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT)) NOT IN(SELECT CONCAT(Ticker,CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT)) FROM tblIntradayPricesPercentRankHistorical)
	ORDER BY StartingPoint ASC
	-- table for recording historical statistical
	INSERT INTO tblIntradayPricesStatisticalVariablesHistorical
	SELECT 
	Ticker
	,MAX(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT) ) TradeDate
	,AVG(pricevariation) AvgPriceVariation
	,MAX(priceVariation) MaxPriceVariation
	,AVG(timeDuration) AvgTimeDuration
	,MAX(timeDuration) MaxTimeDuration
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.10) Percent10
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.20) Percent20
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.30) Percent30
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.40) Percent40
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.50) Percent50
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.60) Percent60
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.70) Percent70
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.80) Percent80
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.90) Percent90
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.95) Percent95
	,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.98) Percent98
	FROM VwIntradayPricesPercentRank
	WHERE CONCAT(Ticker,TradeDate) NOT IN(SELECT CONCAT(Ticker,TradeDate) FROM tblIntradayPricesStatisticalVariablesHistorical)
	GROUP BY Ticker,TradeDate




	-- tabela para os histórico dos trade index 
	INSERT INTO tblIntradayTradeIndexHistorical
	SELECT * 
	FROM vwIntradayTradeIndex
	WHERE CONCAT(ticker,t) NOT IN(SELECT CONCAT(ticker,t) FROM tblIntradayTradeIndexHistorical)



SELECT * 
FROM tblIntradayTradeIndexHistorical
WHERE ticker = 'NERV'
ORDER BY tradeIndex ASC

-- 5º) Analize data
SELECT * FROM tblIntradayPricesStatisticalVariablesHistorical

SELECT * 
FROM SQL_DATABASE..tblIntradayPricesPercentRankHistorical
WHERE Ticker = 'NERV'
ORDER BY StartingPoint

SELECT * 
FROM SQL_DATABASE..tblIntradayPricesPercentRankHistorical
WHERE Ticker = 'BWV'
ORDER BY timeDuration


SELECT * 
FROM tblIntradayTradeIndexHistorical


SELECT *
,DATEADD(s,CAST(LEFT(t,10) AS INT), '1970-01-01') [tradeTime]
FROM tblIntraDayPricesPrimaryBase
ORDER BY t ASC


-- sp for obtaining the extrme points
DROP PROCEDURE dbo.[SP_InsertExtremePoints]
CREATE PROCEDURE [dbo].[SP_InsertExtremePoints]
AS
BEGIN
DECLARE @Indice INT
DECLARE @StartingPoint INT
DECLARE @EndingPoint INT
DECLARE @PointsVector VARCHAR(1000)
DECLARE @Ticker [nvarchar] (5)
DECLARE @TradeDate [datetime]
DECLARE @ExtremePointsVector [varchar](1000)

TRUNCATE TABLE ExtremePointsMinuteIntraDayStockPrices

SET @Ticker = (SELECT TOP 1 ticker FROM VwIndexedPointsUp)
SET @TradeDate = (SELECT TOP 1 tradeDate FROM VwIndexedPointsUp)
SET @PointsVector = (SELECT TOP 1 dbo.FxGetExtremePoint(indexedPointsUp) FROM VwIndexedPointsUp)

WHILE CHARINDEX(',', @PointsVector) > 0
BEGIN
	SET @StartingPoint = CAST(LEFT(@PointsVector,CHARINDEX('/',@PointsVector)-1) AS INT)
	IF CHARINDEX(',',@PointsVector) > 0 
	BEGIN
		SET @EndingPoint = CAST(SUBSTRING(@PointsVector, CHARINDEX('/',@PointsVector) + 1, CHARINDEX(',',@PointsVector) - CHARINDEX('/',@PointsVector) - 1) AS INT)
	END
	ELSE
	BEGIN
		SET @EndingPoint = SUBSTRING(@PointsVector, CHARINDEX('/',@PointsVector) + 1,LEN(@PointsVector))
	END
	INSERT INTO ExtremePointsMinuteIntraDayStockPrices(Ticker, TradeDate, StartingPoint, EndingPoint)
	VALUES (@Ticker,@TradeDate, @StartingPoint, @EndingPoint)
	SET @PointsVector = SUBSTRING(@PointsVector, CHARINDEX(',',@PointsVector) + 1, LEN(@PointsVector) - CHARINDEX(',',@PointsVector))
END
END

-- View com os o cálculo dos percentis
IF OBJECT_ID(N'dbo.VwIntradayPricesPercentRank', N'V') IS NOT NULL
	DROP VIEW dbo.VwIntradayPricesPercentRank
GO
CREATE VIEW VwIntradayPricesPercentRank
AS
SELECT a.*
,b.tradeTime startTime
,b.o startPrice
,c.tradeTime endTime
,c.c endtPrice
,MARKETS.UDF_DIV(c.c,b.o) priceVariation
,DATEDIFF(mi,b.tradeTime,c.tradeTime) timeDuration
,a.EndingPoint - a.StartingPoint numberPeriods
,dbo.FxTotalLiquidity(a.Ticker,a.StartingPoint,a.EndingPoint) totalLiquidity
,PERCENT_RANK() OVER(PARTITION BY a.Ticker ORDER BY MARKETS.UDF_DIV(c.c,b.o) ASC) PercentRank
FROM ExtremePointsMinuteIntraDayStockPrices a
LEFT JOIN vwIntradayTradeIndex b
	ON a.StartingPoint = b.tradeIndex
LEFT JOIN vwIntradayTradeIndex c
	ON a.EndingPoint = c.tradeIndex
LEFT JOIN vwIntradayTradeIndexUp d
	ON a.StartingPoint = d.tradeIndexStart







SELECT *
FROM ExtremePointsMinuteIntraDayStockPrices 

SELECT * FROM tblIntradayPricesPercentRankHistorical

SELECT *
FROM tblIntradayPricesPercentRankHistorical

INSERT INTO tblIntradayPricesStatisticalVariablesHistorical
SELECT 
Ticker
,MAX(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT) ) TradeDate
,AVG(pricevariation) AvgPriceVariation
,MAX(priceVariation) MaxPriceVariation
,AVG(timeDuration) AvgTimeDuration
,MAX(timeDuration) MaxTimeDuration
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.10) Percent10
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.20) Percent20
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.30) Percent30
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.40) Percent40
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.50) Percent50
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.60) Percent60
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.70) Percent70
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.80) Percent80
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.90) Percent90
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.95) Percent95
,dbo.FxPercentilValue(CAST(CONVERT(VARCHAR(8),TradeDate, 112) AS INT),Ticker,0.98) Percent98
FROM VwIntradayPricesPercentRank
GROUP BY Ticker,TradeDate


DELETE FROM tblIntradayPricesStatisticalVariablesHistorical
WHERE TradeDate = 20220728

SELECT * FROM tblIntradayPricesStatisticalVariablesHistorical
SELECT * FROM tblIntradayPricesPercentRankHistorical


SELECT * FROM [dbo].[ExtremePointsMinuteIntraDayStockPrices]

SELECT TOP 3 * FROM [dbo].[tblIntraDayPricesPrimaryBase]

-- create historical data from these 2 tables
SELECT TOP 3 * FROM vwIntradayTradeIndexUp

SELECT * FROM ExtremePointsMinuteIntraDayStockPrices

-- função para obter a liquidez do período de trading
DROP FUNCTION FxTotalLiquidity
CREATE FUNCTION [FxTotalLiquidity](@Ticker VARCHAR(5),@TradeIndexStart INT, @TradeIndexEnd INT)
RETURNS FLOAT
BEGIN
DECLARE @x FLOAT
SET @x = 0
WHILE @TradeIndexStart < @TradeIndexEnd
BEGIN
	SET @x = @x + (SELECT liquidity FROM vwIntradayTradeIndex WHERE tradeIndex = @TradeIndexStart AND ticker = @Ticker)
	SET @TradeIndexStart = @TradeIndexStart + 1
END
RETURN @x
END
-- função para obter a variação do percentil
DROP FUNCTION FxPercentilValue
CREATE FUNCTION [FxPercentilValue](@TradeDate INT, @Ticker VARCHAR(5), @Percentil FLOAT)
RETURNS FLOAT
BEGIN
DECLARE @x FLOAT
SET @x = (SELECT MAX(priceVariation) FROM tblIntradayPricesPercentRankHistorical WHERE PercentRank <= @Percentil AND Ticker = @Ticker AND TradeDate = @TradeDate)
RETURN @x
END

SELECT * FROM tblIntradayPricesPercentRankHistorical WHERE PercentRank <= 0.25 AND Ticker = @Ticker



SELECT *
FROM ExtremePointsMinuteIntraDayStockPrices