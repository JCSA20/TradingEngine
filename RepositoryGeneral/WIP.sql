


DROP VIEW VwCurrentPortfolio

CREATE VIEW VwCurrentPortfolio
AS
SELECT 
CAST(id AS NVARCHAR(50)) idDegiro,
CAST(c.Ticker AS NVARCHAR(5)) Ticker,
a.size,
cast(c.lastPrice as float) currentPrice,
cast(a.breakEvenPrice as float) breakEvenPrice,
a.insertDateTime lastUpdate,
cast(MARKETS.UDF_DIV(c.lastPrice,a.breakEvenPrice) as float) currentReturn,
cast(a.size * (c.lastPrice - a.breakEvenPrice) as float)PL
FROM portfolio a (NOLOCK)
left join DIM_STOCKS_DEGIRO b (nolock)
	on a.Id = b.ID_DEGIRO
left join tradeIndexN c (nolock)
	on b.Ticker = c.Ticker
where id not in(18711551)


SELECT * FROM VwCurrentPortfolio ORDER BY currentReturn DESC

SELECT * FROM VwStrategyPerformance WHERE idStrategy = 12 ORDER BY buyReturn DESC

DROP TABLE cashDegiro

CREATE TABLE cashDegiro
(
id INT,
currencyCode NVARCHAR(5),
valueCash FLOAT,
handling NVARCHAR(5),
lastUpdate DATETIME DEFAULT getdate() NOT NULL
)


select *
from cashDegiro

select *
from sellRequest


SELECT TOP 1 ID_DEGIRO,SellQuantity,SellPrice,SellDatetime FROM sellRequest

select len('c8b44c03-db45-4829-b6b3-27593bdd6a5a')

DROP TABLE openOrdersDegiro
CREATE TABLE openOrdersDegiro
(
id NVARCHAR(50),
[date] NVARCHAR(50),
productId INT,
product nvarchar(100),
contractType INT,
contractSize INT,
currency NVARCHAR(5),
buysell NVARCHAR(3),
size INT,
quantity INT,
price FLOAT,
stopPrice FLOAT,
totalOrderValue FLOAT,
orderTypeId INT,
orderTimeTypeId INT,
orderType NVARCHAR(50),
orderTimeType NVARCHAR(50),
isModifiable BIT,
isDeletable BIT
)


SELECT A.*
FROM openOrdersDegiro A (NOLOCK)
LEFT JOIN portfolio B (NOLOCK)
	ON A.productId = B.id

SELECT *
FROM portfolio

SELECT *
FROM cashDegiro

SELECT TOP 3 *
FROM tradeIndexN


select distinct Ticker
from tradeAnomalies
where priceVariation > 0.05 and durationRising > 15 and tradeIndexPriceVariation > 0.03


select *
from tradeAnomalies
where tradeIndexPriceVariation > 0.03 and tradeIndexLiquidity > 100000
order by tradeIndex


select *
from buyStrategy
where idStrategy = 12


select *
from tradingParameters

update tradingParameters
set parameterValue = 0.05
where parameterId = 4

SELECT * FROM sellRequest


SELECT A.*,
B.lastPrice
FROM VwCurrentPortfolio A (NOLOCK)
INNER JOIN tradeIndexN B (NOLOCK)
	ON A.Ticker = B.Ticker

/*
Strategy to execute the stop-loss after buying the stock
*/

DECLARE @deltaStopLoss FLOAT
SET @deltaStopLoss = (select parameterValue from tradingParameters where parameterId = 10)
--
TRUNCATE TABLE sellRequest
INSERT INTO sellRequest(ID_DEGIRO,Symbol,SellQuantity,SellPrice,SellDateTime,SellOrderType)
SELECT TOP 1 idDegiro ID_DEGIRO, Ticker Symbol, size SellQuantity, dbo.fxGetMinFrom2Values(currentPrice,breakEvenPrice) * (1 + @deltaStopLoss) SellPrice, GETDATE() SellDateTime, 3 SellOrderType FROM VwCurrentPortfolio ORDER BY currentReturn ASC





------------------END-----------------------
SELECT parameterValue FROM tradingParameters (NOLOCK) WHERE parameterId = 10


SELECT TOP 1 idDegiro ID_DEGIRO, Ticker Symbol, size SellQuantity, dbo.fxGetMinFrom2Values(currentPrice,breakEvenPrice) * (1 + -0.10) SellPrice, GETDATE() SellDateTime, 3 SellOrderType FROM VwCurrentPortfolio ORDER BY currentReturn ASC



CREATE PROCEDURE [dbo].[sellStopLossExecution]
AS
BEGIN
	DECLARE @deltaStopLoss FLOAT
	SET @deltaStopLoss = (select parameterValue from tradingParameters where parameterId = 10)
	--
	TRUNCATE TABLE sellRequest
	INSERT INTO sellRequest(ID_DEGIRO,Symbol,SellQuantity,SellPrice,SellDateTime,SellOrderType)
	SELECT TOP 1 idDegiro ID_DEGIRO, Ticker Symbol, size SellQuantity, dbo.fxGetMinFrom2Values(currentPrice,breakEvenPrice) * (1 + @deltaStopLoss) SellPrice, GETDATE() SellDateTime, 3 SellOrderType FROM VwCurrentPortfolio ORDER BY currentReturn ASC
END


exec sellStopLossExecution

/*
Buy execution order
*/
ALTER PROCEDURE [dbo].[buyExecution]
(
@CapitalAmount numeric(6,2),
@Ticker varchar(8),
@BuyPrice numeric(6,2)
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    -- Insert statements for procedure here
	TRUNCATE TABLE buyRequest;
	INSERT INTO buyRequest (ID_DEGIRO,ISIN,Ticker,BuyQuantity,BuyPrice,BuyDateTime,BuyActive) 
	SELECT ID_DEGIRO, ISIN, TICKER,FLOOR(@CapitalAmount/@buyPrice) BuyQuantity,@BuyPrice BuyPrice,GETDATE() BuyDateTime,1 BuyActive 
	FROM dbo.DIM_STOCKS_DEGIRO a WITH(NOLOCK) 
	WHERE TICKER = @Ticker
END

exec dbo.buyExecution 13,'DRMA',1.52

DECLARE @CashDegiro FLOAT
DECLARE @InvestByStock FLOAT

SET @InvestByStock = (SELECT parameterValue FROM tradingParameters WHERE parameterId = 7)
SET @CashDegiro = (SELECT valueCash FROM cashDegiro WHERE id = 2)


EXEC dbo.buyExecution 14, 'TBIO', 2.15


SELECT TOP 1 idDegiro ID_DEGIRO, Ticker Symbol, size SellQuantity, dbo.fxGetMinFrom2Values(currentPrice,breakEvenPrice) * (1 + -0.05) SellPrice, GETDATE() SellDateTime, 3 SellOrderType FROM VwCurrentPortfolio ORDER BY currentReturn ASC

SELECT TOP 10 *
FROM tradeAnomalies A (NOLOCK)
INNER JOIN tradeIndexN B (NOLOCK)
	ON A.Ticker = B.Ticker AND A.tradeIndex = B.tradeIndex
WHERE A.tradeIndexPriceVariation > 0.01 and tradeIndexLiquidity > 100000

SELECT * FROM VwCurrentPortfolio

SELECT * FROM sellRequest (NOLOCK)
SELECT * FROM buyRequest (NOLOCK)
SELECT * FROM portfolio (NOLOCK)





TRUNCATE TABLE sellRequest
INSERT INTO sellRequest(ID_DEGIRO,Symbol,SellQuantity,SellPrice,SellDateTime,SellOrderType)
SELECT a.id ID_DEGIRO,b.TICKER Symbol,a.size SellQuantity,cast(round((1 +  0.1) * breakEvenPrice,2) as numeric(36,2)) SellPrice,GETDATE() SellDateTime, 2 SellOrderType
FROM portfolio a (NOLOCK)
inner join DIM_STOCKS_DEGIRO b (nolock)
	on a.Id = b.ID_DEGIRO


SELECT TOP 1 id FROM openOrdersDegiro




TRUNCATE TABLE buyRequest;
INSERT INTO buyRequest (ID_DEGIRO,ISIN,Ticker,BuyQuantity,BuyPrice,BuyDateTime,BuyActive) 
SELECT ID_DEGIRO, ISIN, TICKER,FLOOR(@CapitalAmount/@buyPrice) BuyQuantity,@BuyPrice BuyPrice,GETDATE() BuyDateTime,1 BuyActive 
FROM dbo.DIM_STOCKS_DEGIRO a WITH(NOLOCK) 
WHERE TICKER = 'TBIO'


US2498453065 

19851643

select *
FROM dbo.DIM_STOCKS_DEGIRO a WITH(NOLOCK)
WHERE TICKER = 'DRMA'

UPDATE DIM_STOCKS_DEGIRO
SET ISIN = 'US2498453065', ID_DEGIRO = 25728852
WHERE TICKER = 'DRMA'
