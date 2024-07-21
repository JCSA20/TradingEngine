/*
Procedure to update the flow of prices
*/
---
DROP PROCEDURE spUpdateFinvizFlow;
CREATE PROCEDURE spUpdateFinvizFlow
AS
IF OBJECT_ID(N'dbo.tradeIndexN5', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN5;
EXEC sp_rename tradeIndexN4, tradeIndexN5;
EXEC sp_rename tradeIndexN3, tradeIndexN4;
EXEC sp_rename tradeIndexN2, tradeIndexN3;
EXEC sp_rename tradeIndexN1, tradeIndexN2;
EXEC sp_rename tradeIndexN, tradeIndexN1;
IF OBJECT_ID(N'dbo.tradeIndexN', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN;
CREATE TABLE [dbo].[tradeIndexN](
	[Ticker] [nvarchar](4000) NULL,
	[Company] [nvarchar](200) NULL,
	[Sector] [nvarchar](100) NULL,
	[Industry] [nvarchar](100) NULL,
	[Country] [nvarchar](100) NULL,
	[lastPrice] [float] NULL,
	[currentVolume] [bigint] NULL,
	[dailyChange] [float] NULL,
	[deltaWeek] [float] NULL,
	[deltaMonth] [float] NULL,
	[deltaQuarter] [float] NULL,
	[deltaHalf] [float] NULL,
	[deltaYear] [float] NULL,
	[deltaYTD] [float] NULL,
	[weekVolatility] [float] NULL,
	[monthVolatility] [float] NULL,
	[Recomendation] [float] NULL,
	[AvgVolume] [float] NULL,
	[RelativeVolume] [float] NULL,
	[tradeIndex] [int] NOT NULL,
	[insertTime] [datetime] NOT NULL
) ON [PRIMARY];
--
INSERT INTO tradeIndexN
SELECT 
Ticker
,Company
,Sector
,Industry
,Country
,lastPrice
,currentVolume
,dailyChange
,deltaWeek
,deltaMonth
,deltaQuarter
,deltaHalf
,deltaYear
,deltaYTD
,weekVolatility
,monthVolatility
,Recomendation
,AvgVolume
,RelativeVolume
,dbo.FxTradeIndexfINVIZ() tradeIndex
,GETDATE() insertTime
FROM VwFinvizLastPrice (NOLOCK);
GO
--- end of procedure
CREATE PROCEDURE spInsertHistoricalFinviz
AS
INSERT INTO dailyTradesFinviz
SELECT *
FROM tradeIndexN;
/*
Código que falta para inserir os extremos locais
*/
-- Insert reversion points > local maximum
INSERT INTO dailyReversionPoints
SELECT 
B.*
, 'Max' localExtremePoint
FROM tradeIndexN A (NOLOCK)
INNER JOIN tradeIndexN1 B (NOLOCK)
	ON A.Ticker = B.Ticker
INNER JOIN tradeIndexN2 C (NOLOCK)
	ON A.Ticker = C.Ticker
WHERE A.lastPrice < B.lastPrice
	AND B.lastPrice > C.lastPrice;
-- Insert reversion points > local minimum
INSERT INTO dailyReversionPoints
SELECT 
B.*
, 'Min' localExtremePoint
FROM tradeIndexN A (NOLOCK)
INNER JOIN tradeIndexN1 B (NOLOCK)
	ON A.Ticker = B.Ticker
INNER JOIN tradeIndexN2 C (NOLOCK)
	ON A.Ticker = C.Ticker
WHERE A.lastPrice > B.lastPrice
	AND B.lastPrice < C.lastPrice;
GO


---//////////////////////////////////////////////////////////////////////////
--------------- daily procedure to run before the market opens --------------
---//////////////////////////////////////////////////////////////////////////
TRUNCATE TABLE dailyTradesFinviz;
TRUNCATE TABLE dailyReversionPoints;
TRUNCATE TABLE tradeIndexN;
TRUNCATE TABLE tradeIndexN1;
TRUNCATE TABLE tradeIndexN2;
TRUNCATE TABLE tradeIndexN3;
TRUNCATE TABLE tradeIndexN4;
TRUNCATE TABLE tradeIndexN5;
TRUNCATE TABLE localMinimumPriceFinviz;
TRUNCATE TABLE tradeAnomalies;








/*
Algorithm to calculate the refernce gap for each tradeIndex
*/



SELECT
Ticker
,tradeIndex
,MIN(tradeIndexRef) tradeIndexRef
FROM
(
SELECT A.Ticker
,A.tradeIndex
,A.lastPrice
,B1.tradeIndex tradeIndexRef
FROM dailyTradesFinviz A (NOLOCK)
INNER JOIN 
(
SELECT *
FROM dailyTradesFinviz B (NOLOCK)
WHERE tradeIndex < 10
) B1
	ON A.Ticker = B1.Ticker
WHERE A.tradeIndex = 10
	AND B1.lastPrice < A.lastPrice
	--AND A.Ticker = 'AAPL'
) K
GROUP BY Ticker
		,tradeIndex




SELECT *
FROM dailyReversionPoints


SELECT *
FROM FINVIZ_REAL_TIME_PRICES
WHERE Ticker = 'AMV'
ORDER BY TICKER

SELECT *
FROM VwFinvizLastPrice (NOLOCK)
WHERE Ticker = 'AMV';

SELECT *
FROM FINVIZ_TICKER_INDUSTRY
WHERE Ticker = 'AMV'


SELECT *
FROM tradeIndexN
WHERE Ticker = 'GOOG'



UPDATE tradeIndexN
SET lastPrice = 3000
WHERE Ticker = 'AA'


UPDATE tradeIndexN2
SET lastPrice = 3000
WHERE Ticker = 'AA'


EXEC spUpdateFinvizFlow;
EXEC spInsertHistoricalFinviz;

EXEC dbo.spUpdateFinvizFlow

SELECT *
FROM tradeIndexN
WHERE Ticker = 'AMV'
SELECT *
FROM tradeIndexN1
WHERE Ticker = 'CING'
SELECT *
FROM tradeIndexN2
WHERE Ticker = 'CING'
SELECT *
FROM tradeIndexN3
SELECT *
FROM tradeIndexN4
SELECT *
FROM tradeIndexN5
SELECT *
FROM dailyTradesFinviz
WHERE Ticker = 'NVIV'
ORDER BY tradeIndex DESC
SELECT *
FROM dailyReversionPoints
WHERE Ticker = 'CING'

SELECT COUNT(*)
FROM dailyReversionPoints





-- Selection  of stocks that are at maximum values
INSERT INTO tradeAnomalies
SELECT 
A.Ticker
,A.Company
,A.Industry
,B.lastPrice startPrice
,A.lastPrice
,A.currentVolume
,MARKETS.UDF_DIV(A.lastPrice,B.lastPrice) priceVariation
,(A.currentVolume - B.currentVolume) * A.lastPrice instantaneousLiquidity
,DATEDIFF(minute,B.insertTime,A.insertTime) durationRising
,A.dailyChange
,A.deltaWeek
,A.deltaMonth
,A.deltaQuarter
,A.deltaYTD
,A.weekVolatility
,A.monthVolatility
,A.Recomendation
,A.AvgVolume
,A.RelativeVolume
,A.tradeIndex
FROM tradeIndexN A (NOLOCK)
INNER JOIN localMinimumPriceFinviz B (NOLOCK)
	ON A.Ticker = B.Ticker
WHERE MARKETS.UDF_DIV(A.lastPrice,B.lastPrice) > 0.01
	AND A.lastPrice > 1
ORDER BY MARKETS.UDF_DIV(A.lastPrice,B.lastPrice) DESC






SELECT TOP 1000 *
FROM tradeAnomalies (NOLOCK)
WHERE currentVolume>100000
	AND dailyChange > 0.03
ORDER BY priceVariation DESC



-- Create View VwAnomaliesByTicker
DROP VIEW VwAnomaliesByTicker;
CREATE VIEW VwAnomaliesByTicker
AS
SELECT 
Ticker
,count(*) Qty
,MIN(priceVariationMin) priceVariationMin
,AVG(priceVariationAvg) priceVariationAvg
,MAX(priceVariationMax) priceVariationMax
,MAX(tradeIndexMax - tradeIndexMin) durationRisingMax
FROM
(
SELECT 
Ticker
,startPrice
,count(*) Qty
,MIN(priceVariation) priceVariationMin
,AVG(priceVariation) priceVariationAvg
,MAX(priceVariation) priceVariationMax
,MIN(tradeIndex) tradeIndexMin
,MAX(tradeIndex) tradeIndexMax
,MAX(durationRising) durationRisingMax
FROM tradeAnomalies (NOLOCK)
WHERE priceVariation > 0.015
	AND lastPrice > 1
	AND dailyChange > 0.02
	AND currentVolume > 10000
GROUP BY Ticker
, startPrice
) A
WHERE Ticker IN(
				SELECT Ticker
				FROM tradeAnomalies (NOLOCK)
				WHERE priceVariation > 0.02
				)
	AND startPrice > 1
GROUP BY Ticker
ORDER BY 2 DESC


SELECT *
FROM
(
SELECT  Ticker
,MIN(lastPrice) PriceMin
,MAX(lastPrice) PriceMax
,MARKETS.UDF_DIV(MAX(lastPrice),MIN(lastPrice)) priceVolatility
FROM dailyTradesFinviz (NOLOCK)
GROUP BY Ticker
) A
WHERE priceVolatility > 0.05
	AND PriceMin > 1


 
SELECT *
,MARKETS.UDF_DIV(CLOSE_PRICE,OPEN_PRICE) priceVariation
FROM MARKETS.TEMP_DAILY_BARS A WITH(NOLOCK)
LEFT JOIN VwAnomaliesByTicker B
	ON A.TICKER COLLATE SQL_Latin1_General_CP1_CI_AS = B.Ticker COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE A.ID_DATE = 20221007
	AND MARKETS.UDF_DIV(A.CLOSE_PRICE,A.OPEN_PRICE) > 0.2
	AND A.OPEN_PRICE > 1

SELECT *
FROM VwAnomaliesByTicker A (NOLOCK)
LEFT JOIN FINVIZ_REAL_TIME_PRICES B (NOLOCK)
	ON A.Ticker = B.Ticker
WHERE CAST(LEFT(Change,LEN(Change)-1) AS FLOAT) > 5
ORDER BY CAST(LEFT(Change,LEN(Change)-1) AS FLOAT) DESC


SELECT *
FROM tradeAnomalies






























SELECT B1.*
FROM 
(
SELECT *
,ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY tradeIndex DESC) AS RowNumber
FROM
		(
		SELECT Ticker
		,lastPrice
		,MIN(tradeIndex) tradeIndex
		FROM dailyTradesFinviz
		GROUP BY Ticker
		,lastPrice
		) A
) A1
INNER JOIN 
(
SELECT *
,ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY tradeIndex DESC) AS RowNumber
FROM
		(
		SELECT Ticker
		,lastPrice
		,MIN(tradeIndex) tradeIndex
		FROM dailyTradesFinviz
		GROUP BY Ticker
		,lastPrice
) B
) B1
	ON A1.Ticker = B1.Ticker AND A1.RowNumber = B1.RowNumber - 1
INNER JOIN 
(
SELECT *
,ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY tradeIndex DESC) AS RowNumber
FROM
(
SELECT Ticker
,lastPrice
,MIN(tradeIndex) tradeIndex
FROM dailyTradesFinviz
GROUP BY Ticker
,lastPrice
) C
) C1
	ON A1.Ticker = C1.Ticker AND A1.RowNumber = C1.RowNumber - 2
WHERE A1.RowNumber = 1 AND B1.RowNumber = 2 AND C1.RowNumber = 3
	AND A1.lastPrice > B1.lastPrice AND B1.lastPrice < C1.lastPrice
	--- Conditions extra, not considered to insert into the reversion points
	AND A1.lastPrice > 1.01 * B1.lastPrice
	AND A1.lastPrice > 1
ORDER BY A1.lastPrice / B1.lastPrice




SELECT *
FROM dailyTradesFinviz
WHERE Ticker = 'AA'
ORDER BY tradeIndex DESC






SELECT *
FROM VwFinvizLastPrice
WHERE Ticker IN('FWBI','PRTA')


SELECT *
FROM FINVIZ_REAL_TIME_PRICES (NOLOCK)

SELECT *
FROM FINVIZ_TICKER_INDUSTRY
ORDER BY Ticker



