/*
Work on algorithm construction
*/



DECLARE @triggerVariation FLOAT
SET @triggerVariation = 0.05
--INSERT INTO tradeAnomaliesStatistical
SELECT 
@triggerVariation 'triggerVariation'
,COUNT(*) numberStocks
,MIN(returnToClose) returnToCloseMin
,MIN(returnToMaximum) returnToMaximumMin
,AVG(returnToClose) returnToCloseAvg
,AVG(returnToMaximum) returnToMaximumAvg
,MAX(returnToClose) returnToCloseMax
,MAX(returnToMaximum) returnToMaximumMax
FROM
(
SELECT A.*
, B.OPEN_PRICE
,B.LOW_PRICE
,B.HIGH_PRICE
,B.CLOSE_PRICE
,B.VOLUME
,A.lastPrice triggerPrice
,MARKETS.UDF_DIV(B.CLOSE_PRICE,A.lastPrice) returnToClose
,MARKETS.UDF_DIV(B.HIGH_PRICE,A.lastPrice) returnToMaximum
FROM
(
SELECT *
, ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY tradeIndex ASC) AS rowNumber
FROM tradeAnomalies (NOLOCK)
WHERE priceVariation > @triggerVariation
) A
LEFT JOIN MARKETS.TEMP_DAILY_BARS B WITH(NOLOCK)
	ON A.TICKER COLLATE SQL_Latin1_General_CP1_CI_AS = B.Ticker COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE rowNumber = 1
	AND B.ID_DATE = 20221007
	AND A.lastPrice> 1
	AND instantaneousLiquidity >10000
) A1



SELECT *
FROM tradeAnomaliesStatistical

