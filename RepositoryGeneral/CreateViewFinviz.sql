/****** Object:  View [dbo].[VwFinvizLastPrice]    Script Date: 04-10-2022 23:51:42 ******/
DROP VIEW [dbo].[VwFinvizLastPrice]
GO

/****** Object:  View [dbo].[VwFinvizLastPrice]    Script Date: 04-10-2022 23:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VwFinvizLastPrice]
AS
SELECT 
A.Ticker
,B.Company
,B.Sector
,B.Industry
,B.Country
,A.Price AS lastPrice
,CAST(LEFT(REPLACE(REPLACE(A.Volume, '"',''),',',''),LEN(REPLACE(REPLACE(A.Volume, '"',''),',',''))-1) AS BIGINT) AS currentVolume
,CAST(REPLACE(A.Change, '%', '') AS FLOAT) * 0.01 AS dailyChange
,CAST(REPLACE(REPLACE(A.PerfWeek, '%', ''),'-','') AS FLOAT) * 0.01 AS deltaWeek
,CAST(REPLACE(REPLACE(A.PerfMonth, '%', ''),'-','') AS FLOAT) * 0.01 AS deltaMonth
,CAST(REPLACE(REPLACE(A.PerfQuarter, '%', ''),'-','') AS FLOAT) * 0.01 AS deltaQuarter
,CAST(REPLACE(REPLACE(A.PerfHalf, '%', ''),'-','') AS FLOAT) * 0.01 AS deltaHalf
,CAST(REPLACE(REPLACE(A.PerfYear, '%', ''),'-','') AS FLOAT) * 0.01 AS deltaYear
,CAST(REPLACE(REPLACE(A.PerfYTD, '%', ''),'-','') AS FLOAT) * 0.01 AS deltaYTD
,CAST(REPLACE(REPLACE(A.VolatilityWeek, '%', ''),'-','') AS FLOAT) * 0.01 AS weekVolatility
,CAST(REPLACE(REPLACE(A.VolatilityMonth, '%', ''),'-','') AS FLOAT) * 0.01 AS monthVolatility
,CAST(REPLACE(A.Recom,'-','') AS FLOAT) AS Recomendation
,dbo.FxConvertKM(A.AvgVolume) AS AvgVolume
,CAST(REPLACE(A.RelVolume,'-','') AS FLOAT) AS RelativeVolume
--,LEN(REPLACE(REPLACE(A.Volume, '"',''),',',''))
FROM            dbo.FINVIZ_REAL_TIME_PRICES AS A WITH (NOLOCK) INNER JOIN
                         dbo.FINVIZ_TICKER_INDUSTRY AS B WITH (NOLOCK) ON A.Ticker = B.Ticker
WHERE        (A.Price > 0.05) AND (B.Industry NOT IN ('Exchange Traded Fund', 'Closed-End Fund - Debt', 'Asset Management', 'Closed-End Fund - Foreign', 'Closed-End Fund - Equity'))


DROP FUNCTION FxConvertKM
CREATE FUNCTION FxConvertKM(@Volume NVARCHAR(10))
RETURNS INT
AS
BEGIN
DECLARE @AvgVolume INT
DECLARE @VolumeString NVARCHAR(10)
DECLARE @VolumeUnity NVARCHAR(1)
SET @VolumeString = LEFT(@Volume,LEN(@Volume)-1)
SET @VolumeUnity = RIGHT(@Volume,1)

IF @VolumeUnity = 'M' 
BEGIN
	SET @AvgVolume = CAST(@VolumeString AS FLOAT) * 1000000
END
ELSE
BEGIN
	SET @AvgVolume = CAST(@VolumeString AS FLOAT) * 1000
END
RETURN @AvgVolume
END


SELECT dbo.FxConvertKM('111.07K')