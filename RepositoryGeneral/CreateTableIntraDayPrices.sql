/*
Tabelas de Histórico de preços intraday
*/
IF OBJECT_ID(N'dbo.MinuteIntraDayStockPrices', N'U') IS NOT NULL
	DROP TABLE dbo.MinuteIntraDayStockPrices
GO
CREATE TABLE MinuteIntraDayStockPrices
(
Volume INT,
VW FLOAT,
a FLOAT,
OpenPrice NUMERIC(6,2),
ClosePrice NUMERIC(6,2),
HighPrice NUMERIC(6,2),
LowPrice NUMERIC(6,2),
t BIGINT,
N int
)

/*
Tabelas que guarda o StartingPoint e o EndPoint do intervalo do trading
*/
IF OBJECT_ID(N'dbo.ExtremePointsMinuteIntraDayStockPrices', N'U') IS NOT NULL
	DROP TABLE dbo.ExtremePointsMinuteIntraDayStockPrices
GO
CREATE TABLE ExtremePointsMinuteIntraDayStockPrices
(
Ticker NVARCHAR(5) NOT NULL,
StartingPoint INT,
EndingPoint INT
)

TRUNCATE TABLE ExtremePointsMinuteIntraDayStockPrices
SELECT * FROM ExtremePointsMinuteIntraDayStockPrices




--TRUNCATE TABLE MinuteIntraDayStockPrices


-- Criação dos Trades Ordenados
-- > view 
CREATE VIEW VwIntraDayMinuteTrades
AS
SELECT '2022-05-19' TradeDay,
'DPSI' Ticker,
ROW_NUMBER() OVER (ORDER BY t ASC) AS RowNumber,
OpenPrice,
LowPrice,
HighPrice,
ClosePrice,
Volume,
t,
N TransactionsNumber,
Volume * (OpenPrice+ClosePrice)/2 Liquidity,
Volume/N AvgQuantityOrder,
CONVERT(TIME, DATEADD(SECOND, t/1000 + 86400000, 0), 114) TradingTime
FROM SQL_DATABASE..MinuteIntraDayStockPrices
WHERE CONVERT(TIME, DATEADD(SECOND, t/1000 + 86400000, 0), 114) > '09:30:00'
	AND CONVERT(TIME, DATEADD(SECOND, t/1000 + 86400000, 0), 114) < '16:00:00'


-- Criação da view para os trades positivos
IF OBJECT_ID(N'dbo.VwIntraDayMinuteTradesUp', N'V') IS NOT NULL
	DROP VIEW dbo.VwIntraDayMinuteTradesUp
GO
CREATE VIEW VwIntraDayMinuteTradesUp
AS
SELECT a.TradeDay,
a.Ticker,
a.RowNumber StartingPoint,
b.RowNumber EndingPoint,
a.Volume Volume,
a.OpenPrice StartingPrice,
b.ClosePrice EndingPrice,
a.t StartISOTime,
b.t EndISOTime,
MARKETS.UDF_DIV(b.ClosePrice,a.OpenPrice) - 1 VariationPrice,
a.TransactionsNumber,
a.Liquidity,
a.AvgQuantityOrder,
a.TradingTime StartingTime,
b.TradingTime EndingTime,
(b.t-a.t)/1000 TimeIntervalInSeconds
FROM VwIntraDayMinuteTrades a
LEFT JOIN VwIntraDayMinuteTrades b
	ON a.Ticker = b.Ticker AND a.RowNumber = (b.RowNumber - 1)
WHERE b.ClosePrice >= a.OpenPrice



-- Criação do vector dos trades positivos
DECLARE @ExtremePoints VARCHAR(1000)
DECLARE @ExtremePointsVector VARCHAR(1000)
SET @ExtremePoints = 
(
SELECT STRING_AGG(StartingPoint,'-') StartingPoints
FROM
(
SELECT TradeDay
	  ,Ticker
	  ,StartingPoint
	  ,EndingPoint
	  ,Volume
	  ,StartingPrice
	  ,EndingPrice
	  ,StartISOTime
	  ,EndISOTime
	  ,VariationPrice
	  ,TransactionsNumber
	  ,Liquidity
	  ,AvgQuantityOrder
	  ,StartingTime
	  ,EndingTime
	  ,TimeIntervalInSeconds
FROM VwIntraDayMinuteTradesUp
) A
)
SET @ExtremePointsVector = (SELECT dbo.FxGetExtremePoint2(@ExtremePoints))
EXEC dbo.SP_InsertExtremePoints @ExtremePointsVector


SELECT *
FROM MinuteIntraDayStockPrices


CREATE VIEW VwIntraDayMinuteTradesUpInterval
AS
SELECT a.Ticker
	  ,a.StartingPoint
	  ,a.EndingPoint
	  ,b.t StartingTime
	  ,c.t EndingTime
	  ,b.OpenPrice StartingPrice
	  ,c.ClosePrice EndingPrice
	  ,(c.t-b.t)/1000/60 TimeInMinutes
	  ,(c.ClosePrice/b.OpenPrice) - 1 PriceVariation
	  ,b.TradingTime StartingTradingTime
	  ,c.TradingTime EndingTradingTime
FROM ExtremePointsMinuteIntraDayStockPrices a
LEFT JOIN VwIntraDayMinuteTrades b
	ON a.Ticker = b.Ticker AND a.StartingPoint = b.RowNumber
LEFT JOIN VwIntraDayMinuteTrades c
	ON a.Ticker = c.Ticker AND a.EndingPoint = c.RowNumber

SELECT Ticker
	  ,StartingPoint
	  ,EndingPoint
	  ,StartingTime
	  ,EndingTime
	  ,StartingPrice
	  ,EndingPrice
	  ,TimeInMinutes
	  ,PriceVariation
	  ,StartingTradingTime
	  ,EndingTradingTime
	  ,PERCENTILE_CONT(0.25) 
        WITHIN GROUP (ORDER BY TimeInMinutes ASC) 
        OVER (PARTITION BY 1)
        AS FirstQuartilTime
	  ,PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY TimeInMinutes ASC) 
        OVER (PARTITION BY 1)
        AS MedianTime
	  ,PERCENTILE_CONT(0.75) 
        WITHIN GROUP (ORDER BY TimeInMinutes ASC) 
        OVER (PARTITION BY 1)
        AS ThirdQuartilTime
	  ,PERCENTILE_CONT(0.95) 
        WITHIN GROUP (ORDER BY TimeInMinutes ASC) 
        OVER (PARTITION BY 1)
        AS Quartil095Time
FROM VwIntraDayMinuteTradesUpInterval
ORDER BY TimeInMinutes



SELECT dbo.FxGetExtremePoint('2-3-6-12-13-15-16-17-18-21')

EXEC dbo.SP_InsertExtremePoints '2-3-6-12-13-15-16-17-18-21'







SELECT *
FROM SQL_DATABASE..IntraDayStockPrices

-- step 1) ordenação do timing dos trades
SELECT STRING_AGG(RowNumber,'-') StartingPoints
FROM 
(
SELECT 
ROW_NUMBER() OVER (ORDER BY t ASC) AS RowNumber,
t,
Volume,
N,
OpenPrice StartingPrice,
ClosePrice EndingPrice
FROM SQL_DATABASE..MinuteIntraDayStockPrices
) A
WHERE EndingPrice >= StartingPrice



DROP FUNCTION FxGetExtremePoint
CREATE FUNCTION FxGetExtremePoint(@PointsVector varchar(1000))
RETURNS VARCHAR(500)
AS
BEGIN
DECLARE @Indice INT
DECLARE @StartingPoint INT
DECLARE @EndPoint INT
DECLARE @RecordsNumber INT
DECLARE @CheckDigit INT
DECLARE @ExtremePointsVector VARCHAR(500)
SET @CheckDigit = (SELECT LEN(@PointsVector) - LEN(REPLACE(@PointsVector,'-',''))) + 1
SET @ExtremePointsVector = ''
SET @Indice = 1
WHILE @Indice <= LEN(@PointsVector) - LEN(REPLACE(@PointsVector,'-','')) + 1
BEGIN
	SET @StartingPoint = dbo.FxExtractIndiceValue(@PointsVector,@Indice);
	SET @EndPoint = @StartingPoint + 1
	IF @Indice < (@CheckDigit -1)
	BEGIN
		WHILE (CHARINDEX(CONCAT('-',CAST(dbo.FxExtractIndiceValue(@PointsVector,@Indice) + 1 AS VARCHAR(5)),'-'),@PointsVector) > 0)
		BEGIN
			SET @EndPoint = dbo.FxExtractIndiceValue(@PointsVector,@Indice) + 2
			SET @Indice = @Indice + 1
		END
	END
	ELSE
	BEGIN
		WHILE (CHARINDEX(CONCAT('-',CAST(dbo.FxExtractIndiceValue(@PointsVector,@Indice) + 1 AS VARCHAR(5))),@PointsVector) > 0)
		BEGIN
			SET @EndPoint = dbo.FxExtractIndiceValue(@PointsVector,@Indice) + 2
			SET @Indice = @Indice + 1
		END
	END
	IF @Indice < (@CheckDigit - 1)
	BEGIN
		IF (CHARINDEX(CONCAT('-',@EndPoint,'-'),@PointsVector)) = 0 
		BEGIN
			IF LEN(@ExtremePointsVector) < 2
			BEGIN
				SET @ExtremePointsVector = CAST(@StartingPoint AS VARCHAR(5)) + '/' + CAST(@EndPoint AS VARCHAR(5))
			END
			ELSE
			BEGIN
				SET @ExtremePointsVector = @ExtremePointsVector + ',' + CAST(@StartingPoint AS VARCHAR(5)) + '/' + CAST(@EndPoint AS VARCHAR(5))
			END
		END
	END
	ELSE
	BEGIN
		IF (CHARINDEX(CONCAT('-',@EndPoint),@PointsVector)) = 0 
		BEGIN
			IF LEN(@ExtremePointsVector) < 2
			BEGIN
				SET @ExtremePointsVector = CAST(@StartingPoint AS VARCHAR(5)) + '/' + CAST(@EndPoint AS VARCHAR(5))
			END
			ELSE
			BEGIN
				SET @ExtremePointsVector = @ExtremePointsVector + ',' + CAST(@StartingPoint AS VARCHAR(5)) + '/' + CAST(@EndPoint AS VARCHAR(5))
			END
		END
	END
	SET @Indice = @Indice + 1
END
RETURN @ExtremePointsVector
END


DROP FUNCTION FxGetExtremePoint2
CREATE FUNCTION FxGetExtremePoint2(@PointsVector varchar(1000))
RETURNS VARCHAR(500)
AS
BEGIN
DECLARE @Indice INT
DECLARE @StartingPoint INT
DECLARE @EndingPoint INT
DECLARE @MainPosition INT
DECLARE @ExtremePointsVector VARCHAR(1000)
DECLARE @PointsNumber INT
SET @ExtremePointsVector = ''
SET @PointsNumber = (SELECT LEN(@PointsVector) - LEN(REPLACE(@PointsVector,'-',''))) + 1
SET @MainPosition = 1
WHILE @MainPosition <= @PointsNumber
BEGIN
	SET @Indice = @MainPosition
	SET @StartingPoint = dbo.FxExtractIndiceValue(@PointsVector,@Indice)
	SET @EndingPoint = @StartingPoint + 1


	WHILE  (CHARINDEX(dbo.FxExtractIndiceValueCompare(@PointsVector,@Indice),@PointsVector) > 0)
	BEGIN
		SET @EndingPoint = dbo.FxExtractIndiceValue(@PointsVector,@Indice) + 2
		SET @Indice = @Indice + 1
	END


	IF LEN(@ExtremePointsVector) < 2
	BEGIN
		SET @ExtremePointsVector = CAST(@StartingPoint AS VARCHAR(5)) + '/' + CAST(@EndingPoint AS VARCHAR(5))
	END
	ELSE
	BEGIN
		SET @ExtremePointsVector = @ExtremePointsVector + ',' + CAST(@StartingPoint AS VARCHAR(5)) + '/' + CAST(@EndingPoint AS VARCHAR(5))
	END
	SET @MainPosition = @Indice + 1
END
RETURN @ExtremePointsVector
END


SELECT dbo.FxGetExtremePoint2('1-2-3-6-8-9-10')


SELECT dbo.FxGetExtremePoint2('2-3-6-12-13-15-16-17-18-21')

SELECT dbo.FxExtractIndiceValueCompare('1-2-3-6-8-9-10',6)




DROP FUNCTION FxExtractIndiceValueCompare
CREATE FUNCTION FxExtractIndiceValueCompare(@PointsVector VARCHAR(1000), @Indice INT)
RETURNS VARCHAR(6)
AS
BEGIN
DECLARE @CountIterations INT
DECLARE @RemainingVector VARCHAR(1000)
DECLARE @StartingPoint INT
DECLARE @EndingPoint INT
DECLARE @ElementsNumber INT
DECLARE @ElementCompare VARCHAR(6)
SET @CountIterations = 0
SET @ElementsNumber = (SELECT LEN(@PointsVector) - LEN(REPLACE(@PointsVector,'-',''))) + 1
SET @RemainingVector = @PointsVector
WHILE @CountIterations < @Indice
BEGIN
	IF CHARINDEX('-',@RemainingVector) > 0
	BEGIN
		SET @StartingPoint = CAST(LEFT(@RemainingVector,CHARINDEX('-',@RemainingVector) - 1) AS INT)
		END
	ELSE
	BEGIN
		SET @StartingPoint = CAST(@RemainingVector AS INt)
	END
	SET @RemainingVector = CAST(RIGHT(@RemainingVector,LEN(@RemainingVector)-CHARINDEX('-',@RemainingVector)) AS VARCHAR(1000))
	SET @CountIterations = @CountIterations + 1
END
SET @StartingPoint = @StartingPoint + 1
IF @Indice < @ElementsNumber - 1
BEGIN
SET  @ElementCompare =   CONCAT('-',CAST(@StartingPoint AS VARCHAR(5)),'-')
END
ELSE
BEGIN
SET  @ElementCompare = CONCAT('-',CAST(@StartingPoint AS VARCHAR(5)))
END
RETURN @ElementCompare
END

































SELECT CHARINDEX(CAST(dbo.FxExtractIndiceValue('1-2-3-6-8-9-10',4) + 1 AS VARCHAR(5)),'1-2-3-6-8-9-10')

SELECT CHARINDEX(CAST(dbo.FxExtractIndiceValue('1-2-3-6',1) + 1 AS VARCHAR(5)),'1-2-3-6')> 0

SELECT 3 > 0
SELECT CHARINDEX('-','1-2-3-6')

SELECT LEN('1-2-3-6') - LEN(REPLACE('1-2-3-6', '-', '')) 

SELECT CONCAT('-',7,'-')



SELECT LEN('1-2-3-6-8-9-10') - LEN(REPLACE('1-2-3-6-8-9-10','-','')) 


DROP FUNCTION FxExtractIndiceValue
CREATE FUNCTION FxExtractIndiceValue(@PointsVector VARCHAR(1000), @Indice INT)
RETURNS INT
AS
BEGIN
DECLARE @CountIterations INT
DECLARE @RemainingVector VARCHAR(1000)
DECLARE @StartingPoint INT
DECLARE @EndingPoint INT
SET @CountIterations = 0
SET @RemainingVector = @PointsVector
WHILE @CountIterations < @Indice
BEGIN
	IF CHARINDEX('-',@RemainingVector) > 0
	BEGIN
		SET @StartingPoint = CAST(LEFT(@RemainingVector,CHARINDEX('-',@RemainingVector) - 1) AS INT)
		END
	ELSE
	BEGIN
		SET @StartingPoint = CAST(@RemainingVector AS INt)
	END
	SET @RemainingVector = CAST(RIGHT(@RemainingVector,LEN(@RemainingVector)-CHARINDEX('-',@RemainingVector)) AS VARCHAR(1000))
	SET @CountIterations = @CountIterations + 1
END
RETURN  @StartingPoint
END

SELECT dbo.FxExtractIndiceValue('1-2-3-6-7-8-9-122',9)

SELECT RIGHT('1-2-3-6',LEN('1-2-3-6')-CHARINDEX('-','1-2-3-6-7-8-9-122'))
SELECT LEFT('1-2-3-6',CHARINDEX('-','1-2-3-6')-1)

/*
Procedimento para inserir o StartingPoint e o EndingPoint dos movimentos de subida
*/
DROP PROCEDURE SP_InsertExtremePoints
CREATE PROCEDURE SP_InsertExtremePoints (@PointsVector VARCHAR(1000))
AS
BEGIN
DECLARE @Indice INT
DECLARE @StartingPoint INT
DECLARE @EndingPoint INT
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
	INSERT INTO ExtremePointsMinuteIntraDayStockPrices(TICKER, StartingPoint, EndingPoint)
	VALUES ('DPSI', @StartingPoint, @EndingPoint)
	SET @PointsVector = SUBSTRING(@PointsVector, CHARINDEX(',',@PointsVector) + 1, LEN(@PointsVector) - CHARINDEX(',',@PointsVector))
END
END

SELECT dbo.FxGetExtremePoint('1-2-3-6-8-9-11-13-14-16-17-19-20-23-24-25-26-29-31-32-34-35-36-38-39-40-42-45-47-48--294-297-298-302-303-306-307-308-312-313-314-317-318-322-323-325-326-327-329-331-332-333-340-342-344-347-348-350-351-352-354-355-357-360-362-363-364-365-366-374-375-376-377-379-380-381-382-383-389-390-391-394-395-397-400-402-405-406-408-409-410-413-414-417-419-421-422-424-426-427-429-431-432-433-434-435-436-437-438-439-441-442-446-447-448-449-451-454-458-462-463-464-465-466-467-470-472-474-475-477-482-485-486-488-495-496-500-501-507-508-510-512-514-515-517-518-519-520-521-522-526-530-533-538-539-540-541-542-543-544-545-547-548-550-555-556-557-558-560-561-562-565-566-567-570-571-572-573-574-577-578-579-580-581-582-583-584-585-586-587-588-589-590-591-592-593-594-595-596-597-598-599-600-601-602-603-604-606-607-608-609-610-611-612-613-614-615-616-617-618-620')


SELECT dbo.FxGetExtremePoint('1-2-3-6-8-9-11-13-14-16-17-19-20-23-24-25-26-29-31-32-34-35-36-38-39-40-42-45-47-48')

EXEC dbo.SP_InsertExtremePoints '1/10,11/12,13/15,16/18,19/21,23/27,29/30,31/33,34/37,38/41,42/43,45/46,47/49'


DECLARE @PointsVector VARCHAR(1000)
SET @PointsVector = '1/10,11/12,13/15,16/18,19/21,23/27,29/30,31/33,34/37,38/41,42/43,45/46,47/49'
SELECT SUBSTRING(@PointsVector, CHARINDEX(',',@PointsVector) + 1, LEN(@PointsVector) - CHARINDEX(',',@PointsVector))
SELECT CHARINDEX('/',@PointsVector)
SELECT CHARINDEX(',',@PointsVector)
SELECT SUBSTRING(@PointsVector, CHARINDEX('/',@PointsVector) + 1, CHARINDEX(',',@PointsVector) - CHARINDEX('/',@PointsVector) - 1)
SELECT SUBSTRING(@PointsVector, 3, CHARINDEX(',',@PointsVector) - 1)
SELECT LEFT(@PointsVector,CHARINDEX('/',@PointsVector)-1)


SELECT *
FROM ExtremePointsMinuteIntraDayStockPrices

SELECT *
FROM [dbo].[VwTradeDataIndexedByTicker]

SELECT *
FROM [dbo].[VwBarDataIndexedByTicker]


SELECT        '2022-05-19' TradeDay, 'DPSI' Ticker, ROW_NUMBER() OVER (ORDER BY t ASC) AS RowNumber, OpenPrice, LowPrice, HighPrice, ClosePrice, Volume, t, N TransactionsNumber, Volume * (OpenPrice + ClosePrice) / 2 Liquidity, 
Volume / N AvgQuantityOrder, CONVERT(TIME, DATEADD(SECOND, t / 1000 + 86400000, 0), 114) TradingTime
FROM            SQL_DATABASE..MinuteIntraDayStockPrices
WHERE        CONVERT(TIME, DATEADD(SECOND, t / 1000 + 86400000, 0), 114) > '09:30:00' AND CONVERT(TIME, DATEADD(SECOND, t / 1000 + 86400000, 0), 114) < '16:00:00'