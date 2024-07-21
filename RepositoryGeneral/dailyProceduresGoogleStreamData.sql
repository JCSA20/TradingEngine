/*
Procedures to run daily the stream data from google finance
*/
-- step 1: truncate the table that receives the stream data from google finance
--TRUNCATE TABLE IntraDayStockPrices
-- step 2: 
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
--
SELECT TOP 1 * 
FROM IntraDayStockPrices WITH(NOLOCK)
WHERE TICKER = 'WKHS'
ORDER BY GoogleUpdateTime DESC