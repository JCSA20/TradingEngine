IF OBJECT_ID(N'dbo.localMinimumPriceFinviz', N'U') IS NOT NULL
	DROP TABLE dbo.localMinimumPriceFinviz;
CREATE TABLE [dbo].[localMinimumPriceFinviz](
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