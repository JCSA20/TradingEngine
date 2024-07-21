/*
Algorithm to calculate the refernce gap for each tradeIndex
*/
DECLARE @NumberOfTrade INT
DECLARE @Trade INT
SET @Trade = 3
SET @NumberOfTrade = 30 -- to analyse the first 30 minutes of trade
WHILE @Trade < @NumberOfTrade
BEGIN
	INSERT INTO tradeIndexReference(Ticker,tradeIndex,tradeIndexRef,insertTime)
	SELECT AB.Ticker
	,AB.tradeIndex
	,ISNULL(AB1.tradeIndexRef, -1000) tradeIndexRef
	,GETDATE() insertTime
	FROM dailyTradesFinviz AB (NOLOCK)
	LEFT JOIN (
			SELECT 
			Ticker
			,tradeIndex
			,MAX(tradeIndexRef) tradeIndexRef
			FROM
			(
			SELECT 
			A.Ticker
			,A.tradeIndex
			,B.tradeIndex tradeIndexRef
			FROM
			(
			SELECT Ticker, tradeIndex,lastPrice
			FROM dailyTradesFinviz (NOLOCK)
			WHERE tradeIndex = @Trade
			) A
			INNER JOIN 
			(
			SELECT Ticker,tradeIndex,lastPrice
			FROM dailyTradesFinviz (NOLOCK)
			WHERE tradeIndex < @Trade
			) B
				ON A.Ticker = B.Ticker
			WHERE B.lastPrice < A.lastPrice
			) BB
			GROUP BY Ticker
					,tradeIndex
			) AB1
		ON AB.Ticker = AB1.Ticker
	WHERE AB.tradeIndex = @Trade

	SET @Trade = @Trade + 1
END
-- Table to record the reference gap for each tradeIndex
IF OBJECT_ID(N'dbo.tradeIndexReference', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexReference
GO
CREATE TABLE [dbo].[tradeIndexReference](
	[Ticker] [nvarchar](4000) NULL,
	[tradeIndex] [int] NOT NULL,
	[tradeIndexRef] [int] NOT NULL,
	[insertTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
--TRUNCATE TABLE tradeIndexReference
WITH CTE
AS (
SELECT Ticker
,MAX(gapRef) gapRefMax
,AVG(gapRef) gapRefAvg
,CAST(SUM(N) AS float)/30 ratioFrequency
,AVG(ratioProximity) * CAST(SUM(N) AS float)/30 metricProximity
FROM
	(
	SELECT Ticker
	,tradeIndex
	,tradeIndexRef
	,tradeIndex - tradeIndexRef gapRef
	,CAST(tradeIndex AS FLOAT)/CAST(tradeIndexRef AS float) ratioProximity
	,1 N
	FROM tradeIndexReference --WHERE Ticker = 'AEHR'
	) A
GROUP BY Ticker
)
SELECT *
FROM CTE
ORDER BY 2 ASC



SELECT *
FROM tradeIndexReference (NOLOCK)
WHERE Ticker = 'RLX'
ORDER BY tradeIndex ASC



-- Criação das estatísticas das anomalias
SELECT Ticker
,COUNT(*) anomaliesQuantity
-- minimum values
,MIN(priceVariation) priceVariationMin
,MIN(risingLiquidity) risingLiquidityMin
,MIN(durationRising) durationRisingMin
,MIN(tradeIndex) tradeIndexMin
,MIN(dailyChange) dailyChangeMin
,MIN(tradeIndexLiquidity) tradeIndexLiquidityMin
,MIN(tradeIndexPriceVariation) tradeIndexPriceVariationMin
-- average values
,AVG(priceVariation) priceVariationAvg
,AVG(risingLiquidity) risingLiquidityAvg
,AVG(durationRising) durationRisingAvg
,AVG(tradeIndex) tradeIndexAvg
,AVG(dailyChange) dailyChangeAvg
,AVG(tradeIndexLiquidity) tradeIndexLiquidityAvg
,AVG(tradeIndexPriceVariation) tradeIndexPriceVariationAvg
-- maximum values
,MAX(priceVariation) priceVariationMax
,MAX(risingLiquidity) risingLiquidityMax
,MAX(durationRising) durationRisingMax
,MAX(tradeIndex) tradeIndexMax
,MAX(dailyChange) dailyChangeMax
,MAX(tradeIndexLiquidity) tradeIndexLiquidityMax
,MAX(tradeIndexPriceVariation) tradeIndexPriceVariationMax
FROM tradeAnomalies
WHERE dailyChange > 0.02
	AND tradeIndexLiquidity > 50000
	AND lastPrice BETWEEN 1 AND 50
GROUP BY Ticker
ORDER BY 20 DESC





SELECT *
FROM tradeAnomalies
WHERE Ticker = 'LITM'
--WHERE risingLiquidity > 50000
--		AND tradeIndexPriceVariation > 0.02
ORDER BY tradeIndex DESC
		 ,tradeIndexPriceVariation DESC
		 ,risingLiquidity DESC


DECLARE @Stock NVARCHAR(5)
SET @Stock = 'AZ'

SELECT *
FROM dailyTradesFinviz
WHERE Ticker = @Stock AND tradeIndex < 30
ORDER BY tradeIndex ASC

SELECT Ticker
,tradeIndex
,tradeIndexRef
,tradeIndex - tradeIndexRef gapRef
,(CAST(tradeIndex AS FLOAT) - CAST(tradeIndexRef AS float))/CAST(tradeIndex AS FLOAT) ratioProximity
FROM tradeIndexReference
WHERE Ticker = @Stock




DECLARE @NumberOfTrade INT
DECLARE @Trade INT
SET @Trade = 6
	SELECT
	Ticker
	,tradeIndex
	,MAX(tradeIndexRef) tradeIndexRef
	,GETDATE() insertTime
	FROM
	(
	SELECT A.Ticker
	,A.tradeIndex
	,A.lastPrice
	,ISNULL(B1.tradeIndex, 1000) tradeIndexRef
	FROM dailyTradesFinviz A (NOLOCK)
	LEFT JOIN 
	(
	SELECT *
	FROM dailyTradesFinviz B (NOLOCK)
	WHERE tradeIndex < @Trade
	) B1
		ON A.Ticker = B1.Ticker
	WHERE A.tradeIndex = @Trade
		AND B1.lastPrice < A.lastPrice
		--AND A.Ticker = 'HQI'
	) K
	WHERE Ticker ='LPLA'
	GROUP BY Ticker
			,tradeIndex




DECLARE @NumberOfTrade INT
DECLARE @Trade INT
SET @Trade = 4

	SELECT AA.Ticker
	,AA.tradeIndex
	,AA.lastPrice
	,ISNULL(C.tradeIndex, 1000) tradeIndexRef
	FROM dailyTradesFinviz AA (NOLOCK)
	LEFT JOIN (
		SELECT A.Ticker
		,A.tradeIndex
		,A.lastPrice
		,ISNULL(B1.tradeIndex, 1000) tradeIndexRef
		FROM dailyTradesFinviz A (NOLOCK)
		LEFT JOIN 
		(
		SELECT *
		FROM dailyTradesFinviz (NOLOCK)
		WHERE tradeIndex < @Trade
		) B1
			ON A.Ticker = B1.Ticker
		WHERE A.tradeIndex = @Trade
			AND B1.lastPrice < A.lastPrice
			) C
		ON AA.Ticker = C.Ticker
		AND AA.tradeIndex = C.tradeIndex
	WHERE AA.Ticker = 'A'
			AND AA.tradeIndex = @Trade






SELECT *
FROM dailyTradesFinviz
WHERE Ticker = 'A' AND tradeIndex < 30
ORDER BY tradeIndex ASC




DECLARE @NumberOfTrade INT
DECLARE @Trade INT
SET @Trade = 6
SET @NumberOfTrade = 30 -- to analyse the first 30 minutes of trade



SELECT AB.Ticker
,AB.tradeIndex
,ISNULL(AB1.tradeIndexRef, 1000) tradeIndexRef
FROM dailyTradesFinviz AB (NOLOCK)
LEFT JOIN (
			SELECT 
			Ticker
			,tradeIndex
			,MAX(tradeIndexRef) tradeIndexRef
			FROM
			(
			SELECT 
			A.Ticker
			,A.tradeIndex
			,B.tradeIndex tradeIndexRef
			FROM
			(
			SELECT Ticker, tradeIndex,lastPrice
			FROM dailyTradesFinviz (NOLOCK)
			WHERE tradeIndex = @Trade
			) A
			INNER JOIN 
			(
			SELECT Ticker,tradeIndex,lastPrice
			FROM dailyTradesFinviz (NOLOCK)
			WHERE tradeIndex < @Trade
			) B
				ON A.Ticker = B.Ticker
			WHERE B.lastPrice < A.lastPrice
			) BB
			GROUP BY Ticker
					,tradeIndex
			) AB1
	ON AB.Ticker = AB1.Ticker
WHERE AB.tradeIndex = @Trade