IF OBJECT_ID(N'dbo.tradeIndexN', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN
GO
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
) ON [PRIMARY]
GO
---
IF OBJECT_ID(N'dbo.tradeIndexN1', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN1
GO
CREATE TABLE [dbo].[tradeIndexN1](
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
) ON [PRIMARY]
GO
---
IF OBJECT_ID(N'dbo.tradeIndexN2', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN2
GO
CREATE TABLE [dbo].[tradeIndexN2](
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
) ON [PRIMARY]
GO
--
IF OBJECT_ID(N'dbo.tradeIndexN3', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN3
GO
CREATE TABLE [dbo].[tradeIndexN3](
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
) ON [PRIMARY]
GO
--
IF OBJECT_ID(N'dbo.tradeIndexN4', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN4
GO
CREATE TABLE [dbo].[tradeIndexN4](
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
) ON [PRIMARY]
GO
--
IF OBJECT_ID(N'dbo.tradeIndexN5', N'U') IS NOT NULL
	DROP TABLE dbo.tradeIndexN5
GO
CREATE TABLE [dbo].[tradeIndexN5](
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
) ON [PRIMARY]
GO
--
IF OBJECT_ID(N'dbo.dailyTradesFinviz', N'U') IS NOT NULL
	DROP TABLE dbo.dailyTradesFinviz
GO
CREATE TABLE [dbo].[dailyTradesFinviz](
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
) ON [PRIMARY]
GO
--
IF OBJECT_ID(N'dbo.dailyReversionPoints', N'U') IS NOT NULL
	DROP TABLE dbo.dailyReversionPoints
GO
CREATE TABLE [dbo].[dailyReversionPoints](
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
	[insertTime] [datetime] NOT NULL,
	[localExtremePoint] [nvarchar](10)
) ON [PRIMARY]
GO
-- table that will record the values of conditions and the occurence time
IF OBJECT_ID(N'dbo.dailyConditionsByStock', N'U') IS NOT NULL
	DROP TABLE dbo.dailyConditionsByStock
GO
CREATE TABLE [dbo].dailyConditionsByStock(
	[Ticker] [nvarchar](4000) NULL,
	[condition1Bit] [bit] NOT NULL,
	[condition1Value] [float] NULL,
	[condition1tradeIndex] [int] NULL,
	[condition2Bit] [bit] NOT NULL,
	[condition2Value] [float] NULL,
	[condition2tradeIndex] [int] NULL,
) ON [PRIMARY]
GO
-- table that will receive the metadata and description of all the conditions defined
IF OBJECT_ID(N'dbo.dailyConditionsMetaData', N'U') IS NOT NULL
	DROP TABLE dbo.dailyConditionsMetaData
GO
CREATE TABLE [dbo].dailyConditionsMetaData(
	[idCondition] [int] IDENTITY(1,1) NOT NULL,
	[conditionDescription] [bit] NOT NULL,
	[conditionFormula] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idCondition] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
-- table for parametrization of trading
IF OBJECT_ID(N'dbo.tradingParameters', N'U') IS NOT NULL
	DROP TABLE dbo.tradingParameters
GO
CREATE TABLE [dbo].tradingParameters(
	[parameterId] [int] IDENTITY(1,1) NOT NULL,
	[parameterName] [nvarchar](100) NULL,
	[parameterDescription] [nvarchar](200) NULL,
	[parameterValue] [float] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[parameterId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
-- table for receiving the stock to sell that verify the trigger to sell
IF OBJECT_ID(N'dbo.sellWaitingRequest', N'U') IS NOT NULL
	DROP TABLE dbo.sellWaitingRequest
GO
CREATE TABLE [dbo].sellWaitingRequest(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parameterName] [nvarchar](100) NULL,
	[parameterDescription] [nvarchar](200) NULL,
	[parameterValue] [float] NOT NULL
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
-- table that will record the values of reference gap
IF OBJECT_ID(N'dbo.tradingGap', N'U') IS NOT NULL
	DROP TABLE dbo.tradingGap
GO
CREATE TABLE [dbo].tradingGap(
	[Ticker] [nvarchar](8) NULL,
	[tradeIndex] [int] NOT NULL,
	[tradeIndexGap] [int] NOT NULL,
) ON [PRIMARY]
GO