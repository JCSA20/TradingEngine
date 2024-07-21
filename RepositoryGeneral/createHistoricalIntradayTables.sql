SELECT * 
INTO tblIntradayTradeIndexHistorical
FROM vwIntradayTradeIndex


TRUNCATE TABLE tblIntradayTradeIndexHistorical


/****** Object:  Table [dbo].[tblIntradayTradeIndexHistorical]    Script Date: 21-08-2022 16:07:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblIntradayTradeIndexHistorical]') AND type in (N'U'))
DROP TABLE [dbo].[tblIntradayTradeIndexHistorical]
GO

/****** Object:  Table [dbo].[tblIntradayTradeIndexHistorical]    Script Date: 21-08-2022 16:07:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblIntradayTradeIndexHistorical](
	[ticker] [nvarchar](10) NOT NULL,
	[o] [numeric](10, 2) NULL,
	[c] [numeric](10, 2) NULL,
	[h] [numeric](10, 2) NULL,
	[l] [numeric](10, 2) NULL,
	[n] [int] NULL,
	[v] [int] NULL,
	[t] [nvarchar](30) NOT NULL,
	[liquidity] [numeric](26, 6) NULL,
	[tradeTime] [datetime] NULL,
	[tradeIndex] [bigint] NULL,
	CONSTRAINT PK_TICKER_DATE PRIMARY KEY (ticker,t)
) ON [PRIMARY]
GO

SELECT *
FROM tblIntradayTradeIndexHistorical