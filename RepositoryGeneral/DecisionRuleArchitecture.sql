WITH CTE AS
(
SELECT Exchange, TICKER,OpenPrice,Price,Volume,GoogleUpdateTime,Day,[Hour],[Minute],
ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY GoogleUpdateTime DESC) AS RowNumber
FROM IntraDayStockPrices WITH(NOLOCK)
WHERE OpenPrice>0 AND Price>0
	AND [Hour] = DATEPART(HOUR,GETDATE()) + 1
	AND [Minute] > (DATEPART(MINUTE,GETDATE())-10)
)
SELECT a.Exchange, 
a.TICKER,
a.OpenPrice,
b.Price InitialPrice,
a.Price CurrentPrice,
a.Volume,
a.Volume -b.Volume VarVolume,
a.[Day],
a.[Hour],
a.[Minute],
(a.Price/a.OpenPrice - 1) PriceOpenPriceVariation,
(a.Price/b.Price - 1) PriceLastVariation,
FORMAT(a.Price * (a.Volume -b.Volume),'N') Liquidity
FROM CTE a
INNER JOIN CTE b
    ON a.TICKER = b.TICKER
WHERE a.RowNumber = 1 AND b.RowNumber = 2
	AND (a.Price/a.OpenPrice - 1) > 0.00510
	AND (a.Price/b.Price - 1) > 0.01
	AND a.Price > 0.7 
	AND  a.Price>0 
	AND b.Price>0
	AND a.Volume>100000
	AND a.Volume*a.Price > 10000
	AND (a.Volume -b.Volume) * a.Price > 10000
ORDER BY 12 DESC

-- >> Ordenação dos trades com as variações respetivas
IF OBJECT_ID(N'dbo.VwStockListOrderedTrades', N'V') IS NOT NULL
	DROP VIEW dbo.VwStockListOrderedTrades
GO
CREATE VIEW VwStockListOrderedTrades
AS
SELECT	A.RowNumber
		,A.TICKER
		,A.OpenPrice
		,A.Price LastPrice
		,A.Volume LastVolume
		,A.Volume * A.Price LastLiquidityTrade
		,B.Price PreviousPrice
		,(MARKETS.UDF_DIV(A.Price,B.Price) - 1) LastVariation
FROM 
(
SELECT Exchange, TICKER,OpenPrice,Price,Volume,GoogleUpdateTime,Day,[Hour],[Minute],
ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY GoogleUpdateTime DESC) AS RowNumber
FROM IntraDayStockPrices WITH(NOLOCK)
WHERE OpenPrice>0 AND Price>0
	AND [Hour] = DATEPART(HOUR,GETDATE()) + 1
	AND [Minute] > (DATEPART(MINUTE,GETDATE())-20)

	--AND [Hour] = 20
	--AND [Minute] > 40
) A
LEFT JOIN 
(
SELECT Exchange, TICKER,OpenPrice,Price,Volume,GoogleUpdateTime,Day,[Hour],[Minute],
ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY GoogleUpdateTime DESC) AS RowNumber
FROM IntraDayStockPrices WITH(NOLOCK)
WHERE OpenPrice>0 AND Price>0
	AND [Hour] = DATEPART(HOUR,GETDATE()) + 1
	AND [Minute] > (DATEPART(MINUTE,GETDATE())-20)

	--AND [Hour] = 20
	--AND [Minute] > 40
) B
	ON A.TICKER = B.TICKER
	AND A.RowNumber = (B.RowNumber - 1)
WHERE B.RowNumber IS NOT NULL




--> Pre-stage table
IF OBJECT_ID(N'dbo.TblStockListOrderedTrades', N'U') IS NOT NULL
	DROP TABLE dbo.TblStockListOrderedTrades
GO
CREATE TABLE TblStockListOrderedTrades
(
Exchange NVARCHAR(50),
TICKER	NVARCHAR(10),
OpenPrice NUMERIC(9,2),
Price NUMERIC(9,2),
Volume INT,
GoogleUpdateTime NVARCHAR(50),
[Day] INT,
[Hour] INT,
[Minute] INT,
RowNumber INT
)
-- >> para inserir os stocks ordenados numa tabela
TRUNCATE TABLE TblStockListOrderedTrades
INSERT INTO TblStockListOrderedTrades
SELECT Exchange, TICKER,OpenPrice,Price,Volume,GoogleUpdateTime,Day,[Hour],[Minute],
ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY GoogleUpdateTime DESC) AS RowNumber
FROM IntraDayStockPrices WITH(NOLOCK)
WHERE OpenPrice>0 AND Price>0
	AND [Hour] = DATEPART(HOUR,GETDATE()) + 1
	AND [Minute] > (DATEPART(MINUTE,GETDATE())-20)

SELECT A.*,B.LastNegativeTradePosition,B.LocalMinimunPrice,MARKETS.UDF_DIV(A.LastPrice,B.LocalMinimunPrice) - 1 VariationToLocalMinimun,B.LocalMinimunPrice
FROM VwStockListOrderedTrades A
LEFT JOIN VwStockLastNegativeTrade B
	ON A.TICKER = B.TICKER
WHERE A.RowNumber = 1 AND A.LastVariation >= 0 AND A.LastPrice > 0.7
ORDER BY MARKETS.UDF_DIV(A.LastPrice,B.LocalMinimunPrice) DESC




SELECT *
FROM TblStockListOrderedTrades
-- >> Construção da view a partir da tabela ordenada
IF OBJECT_ID(N'dbo.VwStockListOrderedTrades', N'V') IS NOT NULL
	DROP VIEW dbo.VwStockListOrderedTrades
GO
CREATE VIEW VwStockListOrderedTrades
AS
SELECT	A.RowNumber
		,A.TICKER
		,A.OpenPrice
		,A.Price LastPrice
		,A.Volume LastVolume
		,A.Volume * A.Price LastLiquidityTrade
		,B.Price PreviousPrice
		,(MARKETS.UDF_DIV(A.Price,B.Price) - 1) LastVariation
FROM TblStockListOrderedTrades A
LEFT JOIN TblStockListOrderedTrades B
	ON A.TICKER = B.TICKER
	AND A.RowNumber = (B.RowNumber - 1)
WHERE B.RowNumber IS NOT NULL


SELECT *
FROM TblStockListOrderedTrades
WHERE RowNumber = 1 AND OpenPrice > 0.5 AND OpenPrice < 100



-- >> Isto dá-nos os Stocks que estão a subir à mais de 4 minutos consecutivos
IF OBJECT_ID(N'dbo.VwStockLastNegativeTrade', N'V') IS NOT NULL
	DROP VIEW dbo.VwStockLastNegativeTrade
GO
CREATE VIEW VwStockLastNegativeTrade
AS
SELECT A.TICKER
		,A.LastNegativeTradePosition
		,B.PreviousPrice LocalMinimunPrice 
FROM
(
SELECT TICKER
		,MIN(RowNumber) LastNegativeTradePosition
FROM VwStockListOrderedTrades
WHERE LastVariation <= 0
GROUP BY TICKER
) A
LEFT JOIN VwStockListOrderedTrades B
	ON A.TICKER = B.TICKER
	AND A.LastNegativeTradePosition = B.RowNumber




SELECT A.*,B.LastNegativeTradePosition,B.LocalMinimunPrice,MARKETS.UDF_DIV(A.LastPrice,B.LocalMinimunPrice) - 1 VariationToLocalMinimun,B.LocalMinimunPrice
FROM VwStockListOrderedTrades A
LEFT JOIN VwStockLastNegativeTrade B
	ON A.TICKER = B.TICKER
WHERE A.RowNumber = 1 AND A.LastVariation >= 0 AND A.LastPrice > 0.7
ORDER BY MARKETS.UDF_DIV(A.LastPrice,B.LocalMinimunPrice) DESC