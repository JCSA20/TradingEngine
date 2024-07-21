-- Create Trading schema
-- This schema will support all the objects used in the trading time after being calculated
-- Is the place where is loaded the final outputs on which we will base our decision engine

USE [DW_NP2P]
GO
 
IF NOT EXISTS ( SELECT  *
                FROM    sys.schemas
                WHERE   name = N'TRADING' )
BEGIN
    EXEC('CREATE SCHEMA [TRADING]');
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Schema for Trading Model' , @level0type=N'SCHEMA',@level0name=N'TRADING'

END;
DROP TABLE FACT_TRADING;

-- Creation of factual table for trading purpose
DROP TABLE MARKETS.FACT_TRADING;
CREATE TABLE MARKETS.FACT_TRADING (
                                    [BI_LAST_UPD_DATE]       [datetime] NULL,
                                    [COD_TICKER]             [nvarchar] (10) NULL,
                                    [COD_ISIN_TICKER]        [nvarchar] (20) NULL,
                                    [SK_YEAR_DATE_MINIMUM]   [int] NULL,
                                    [SK_YEAR_DATE_MAXIMUM]   [int] NULL,                                    
                                    [MTR_YEAR_MINIMUM]       [numeric] (18,2) NULL,
                                    [MTR_YEAR_MAXIMUM]       [numeric] (18,2) NULL,
                                    [MTR_LAST_OPEN]          [numeric] (18,2) NULL, 
                                    [MTR_LAST_HIGH]          [numeric] (18,2) NULL,
                                    [MTR_LAST_LOW]           [numeric] (18,2) NULL,
                                    [MTR_LAST_CLOSE]         [numeric] (18,2) NULL,
                                    [MTR_LAST_VOLUME]        [numeric] (18) NULL                  
                         );
SELECT *
FROM MARKETS.FACT_TRADING WITH(NOLOCK)
-- Creation of Dimension table for Stocks vs Tickers
DROP TABLE DIM_STOCK;
CREATE TABLE DIM_STOCK (
											[BI_INS_DATE]			[datetime] NULL,
											[BI_LAST_UPD_DATE]		[datetime] NULL,
											[BI_BEGIN_DATE]			[int] NULL,
											[BI_END_DATE]			[int] NULL,                                         
											[SK_TICKER]	            [int] IDENTITY(1,1) NOT NULL,
                                            [COD_TICKER]            [nvarchar] (10) NULL,
                                            [COD_ISIN_TICKER]       [nvarchar] (20) NULL                                           
                        );
SELECT *
FROM DIM_STOCK WITH(NOLOCK)


-- Insertion of all tickers in the dimenion table
INSERT INTO DIM_STOCK (BI_INS_DATE, BI_LAST_UPD_DATE, BI_BEGIN_DATE, BI_END_DATE, COD_TICKER)
SELECT DISTINCT 
GETDATE() AS BI_INS_DATE,
GETDATE() AS BI_LAST_UPD_DATE,
CAST(CAST(YEAR(GETDATE()) AS VARCHAR) + RIGHT('00'+CAST(MONTH(GETDATE()) AS VARCHAR),2) + RIGHT('00'+CAST(YEAR(GETDATE()) AS VARCHAR),2) AS INT) AS BI_BEGIN_DATE,
99991231 AS BI_END_DATE,
TICKER
FROM TEMP_DAILY_BARS WITH(NOLOCK)
WHERE TICKER NOT IN(SELECT TICKER FROM DIM_STOCK)


-- Data preparation for loading the Factual table
