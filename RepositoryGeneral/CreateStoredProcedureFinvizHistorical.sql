/*
Stored procedure to run at the end of day to archive all the data processed
*/
insert INTO dailyTradesFinvizHistorical
SELECT YEAR(insertTime) [tradeYear]
,MONTH(insertTime) [tradeMonth]
,DAY(insertTime) [tradeDay]
,*
FROM dailyTradesFinviz

select *
from tradeIndexN  (nolock)
WHERE Ticker = 'NEON'

select *
from dailyTradesFinviz  (nolock)
WHERE Ticker = 'NEON'
order by tradeIndex asc

select *
from sellWaitingRequest

EXECUTE spOrchestrateStrategies;
EXECUTE spGetFromBuyStartegyToBuyRequest;
EXECUTE spInsertIntoSellWaitingRequest;
EXECUTE sellExecutionToDegiro;

select *
from tradeAnomalies  (nolock)
WHERE Ticker = 'NEON'
order by tradeIndex asc

SELECT *
FROM sellWaitingRequest (NOLOCK)


SELECT *
FROM buyStrategy (NOLOCK)
SELECT *
FROM buyRequest (NOLOCK)

SELECT *
FROM strategyMetadata

delete from strategyMetadata where idStrategy = 5

select *
from tradingGap
order by Ticker, tradeIndexGap

update strategyMetadata
set isActive = 1
where idStrategy = 1
-- for make inactive the execution of orders to degiro
update tradingParameters
set parameterValue = 0
where parameterId = 5

SELECT *
FROM tradingParameters

INSERT INTO tradingParameters(parameterName, parameterDescription, parameterValue)
VALUES ('tradingIsActive','Indicates if the trading system is active',1)


DELETE FROM tradingParameters
WHERE parameterId = 6

SELECT * FROM sellRequest (NOLOCK)
SELECT * FROM buyRequest (NOLOCK)
SELECT * FROM portfolio (NOLOCK)

TRUNCATE TABLE sellWaitingRequest
TRUNCATE TABLE buyRequest
TRUNCATE TABLE sellRequest

-- to execute daily
TRUNCATE TABLE dailyTradesFinvizHistorical
TRUNCATE TABLE dailyTradesFinviz;
TRUNCATE TABLE dailyReversionPoints;
TRUNCATE TABLE tradeIndexN;
TRUNCATE TABLE tradeIndexN1;
TRUNCATE TABLE tradeIndexN2;
TRUNCATE TABLE tradeIndexN3;
TRUNCATE TABLE tradeIndexN4;
TRUNCATE TABLE tradeIndexN5;
TRUNCATE TABLE localMinimumPriceFinviz;
TRUNCATE TABLE tradeAnomalies;
TRUNCATE TABLE buyStrategy;
TRUNCATE TABLE tradingGap;








SELECT count(*) Qtd
,sum(tradeIndexLiquidity) Liquidity
FROM tradeAnomalies
where tradeIndexPriceVariation > 0.02

SELECT TOP 1 A.*,B.* FROM DIM_STOCKS_DEGIRO A INNER JOIN DIM_STOCKS B ON A.TICKER = B.TICKER full join tradeIndexN c on a.TICKER = c.Ticker WHERE A.Ticker <> A.SYMBOL_DEGIRO AND A.DATE_UPDATED IS NULL ORDER BY PRIMARY_EXCHANGE ASC

SELECT TOP 1 B.*,A.* FROM DIM_STOCKS_DEGIRO A INNER JOIN DIM_STOCKS B ON A.TICKER = B.TICKER full join tradeIndexN c on a.TICKER = c.Ticker WHERE A.Ticker <> A.SYMBOL_DEGIRO AND A.DATE_UPDATED IS NULL ORDER BY PRIMARY_EXCHANGE ASC


select a.*,b.TICKER from DIM_STOCKS_DEGIRO a full join tradeIndexN b on a.TICKER = b.Ticker where a.Ticker <> a.SYMBOL_DEGIRO order by EXCHANGE

SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE ID_DEGIRO = 11079921 OR PK_STOCK = 2637 OR TICKER = 'ESBA'



SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE Ticker <> SYMBOL_DEGIRO AND DATE_UPDATED IS NULL ORDER BY EXCHANGE ASC

SELECT DISTINCT Sector,Industry
FROM DIM_STOCKS_DEGIRO A
INNER JOIN FINVIZ_TICKER_INDUSTRY B
	ON A.TICKER = B.Ticker
WHERE Ticker = 'ESBA'


-- estes stocks terão de ser inseridos na DIM_STOCKS_DEGIRO
INSERT INTO DIM_STOCKS_DEGIRO(TICKER, NAME_COMPANY)
select b.Ticker TICKER, b.Company NAME_COMPANY
from DIM_STOCKS_DEGIRO a (nolock)
full outer join tradeIndexN b (nolock)
	on a.TICKER = b.Ticker
WHERE a.TICKER is null AND b.Ticker not like '%-%'
-- stocks a eliminar da DIM_STOCKS_DEGIRO
select a.* 
from DIM_STOCKS_DEGIRO a (nolock)
full outer join tradeIndexN b (nolock)
	on a.TICKER = b.Ticker
WHERE b.TICKER is null




SELECT *
FROM tradeIndexN A (NOLOCK)
WHERE Ticker NOT IN(SELECT TICKER FROM DIM_STOCKS_DEGIRO)


SELECT *
FROM tradeAnomalies (NOLOCK)
WHERE Ticker = 'RLX'
ORDER BY tradeIndex

SELECT top 1 *
FROM tradeIndexN A (NOLOCK)
WHERE Ticker = 'RLX'

SELECT Ticker
,tradeIndex
,lastPrice
,currentVolume
FROM dailyTradesFinviz (NOLOCK)
WHERE Ticker = 'RLX'
ORDER BY tradeIndex ASC


SELECT top 1 *
FROM buyStrategy (NOLOCK)


select TOP 1 * from DIM_STOCKS_DEGIRO a inner join tradeIndexN b	on a.Ticker = b.Ticker where a.TICKER = 'BXRX'

16689117
US07160F1075

select TOP 10 *
from DIM_STOCKS_DEGIRO
where TICKER = 'BXRX'

-- # 1172
select *,charindex(',',NAME_COMPANY),left(NAME_COMPANY,charindex(',',NAME_COMPANY)-1)
from DIM_STOCKS_DEGIRO a (nolock)
where ID_DEGIRO is null and charindex(',',NAME_COMPANY) > 0


update DIM_STOCKS_DEGIRO
set ID_DEGIRO = 16689117, ISIN = 'US07160F1075'
where TICKER = 'BXRX'

select *
from DIM_STOCKS_DEGIRO a (nolock)
where SYMBOL_DEGIRO in(select Ticker from DIM_STOCKS_DEGIRO where Ticker <> SYMBOL_DEGIRO and ID_DEGIRO > 0)


select *
from tradeIndexN
where lastPrice between 1 and 100




-- stocks that needs to be updated
select left(DATE_UPDATED,15) Data1
,*
from DIM_STOCKS_DEGIRO a (nolock)
left join tradeIndexN b (nolock)
	on a.Ticker = b.Ticker
where a.Ticker <> SYMBOL_DEGIRO 
	and lastPrice between 1 and 10


-- stocks that need to get the id from degiro
select TOP 1 * from DIM_STOCKS_DEGIRO a inner join tradeIndexN b	on a.Ticker = b.Ticker where a.Ticker = SYMBOL_DEGIRO and ID_DEGIRO = 0





update a
set ID_UPDATED = 1
from DIM_STOCKS_DEGIRO a
inner join tradeIndexN b
	on a.Ticker = b.Ticker
where a.Ticker <> SYMBOL_DEGIRO
	and Industry = 'Biotechnology'










select * 
from DIM_STOCKS_DEGIRO 
where Ticker <> SYMBOL_DEGIRO and Ticker in(select SYMBOL_DEGIRO from DIM_STOCKS_DEGIRO a (nolock) where Ticker <> SYMBOL_DEGIRO and SYMBOL_DEGIRO <>'NA' and SYMBOL_DEGIRO <>'0')


update strategyMetadata
set isActive = 1



SELECT * 
FROM strategyMetadata (NOLOCK)

delete from strategyMetadata where idStrategy in(2,3)


INSERT INTO strategyMetadata(strategyDescription,strategyCode,isActive)
VALUES ('Buy a specific stock','INSERT INTO buyStrategy(Ticker,tradeIndex,decisionTime,lastPrice,currentVolume,idStrategy) SELECT A.Ticker,  A.tradeIndex,  GETDATE() decisionTime,  A.lastPrice,  A.currentVolume,  1 idStrategy FROM tradeIndexN A (NOLOCK) WHERE Ticker = ''RLX'' ',0)


INSERT INTO buyStrategy(Ticker,tradeIndex,decisionTime,lastPrice,currentVolume,idStrategy) 
SELECT A.Ticker,  A.tradeIndex,  GETDATE() decisionTime,  A.lastPrice,  A.currentVolume,  1 idStrategy 
FROM tradeIndexN A (NOLOCK) 
WHERE Ticker = 'RLX'

SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE ID_UPDATED = 0



INSERT INTO buyStrategy(Ticker,tradeIndex,decisionTime,lastPrice,currentVolume,idStrategy)  
SELECT A.Ticker,  A.tradeIndex,  GETDATE() decisionTime,  A.lastPrice,  A.currentVolume,  2 idStrategy  
FROM tradeIndexN A (NOLOCK)  
INNER JOIN tradeAnomalies B (NOLOCK)   
	ON A.Ticker  = B.Ticker   
	AND A.tradeIndex = B.tradeIndex  
INNER JOIN tradeIndexN1 C (NOLOCK)   
	ON A.Ticker  = C.Ticker  
INNER JOIN tradeIndexN2 D (NOLOCK)   
	ON A.Ticker  = D.Ticker  
WHERE B.currentVolume > 200000   
	AND dbo.FxRelativeVolume(B.currentVolume,B.AvgVolume,B.tradeIndex) > 2   
	AND B.tradeIndexLiquidity > 100000   
	AND B.tradeIndexPriceVariation > 0.03   
	AND B.tradeIndexPriceVariation < B.priceVariation   
	AND B.tradeIndexLiquidity > 2 * (C.currentVolume - D.currentVolume) * C.lastPrice   
	AND A.Ticker NOT IN(SELECT Ticker FROM buyStrategy (NOLOCK))




-- Execute strategies to buy
EXECUTE spOrchestrateStrategies;
EXECUTE spGetFromBuyStartegyToBuyRequest;


INSERT INTO buyStrategy(Ticker,tradeIndex,decisionTime,lastPrice,currentVolume,idStrategy) SELECT A.Ticker,  A.tradeIndex,  GETDATE() decisionTime,  A.lastPrice,  A.currentVolume,  1 idStrategy FROM tradeIndexN A (NOLOCK) WHERE Ticker = 'RLX'



SELECT * 
FROM buyStrategy

SELECT *
FROM buyRequest



truncate table buyStrategy










DROP FUNCTION MARKETS.FxGetMinGapReference

WITH CTE AS
(
select ID_DEGIRO
,COUNT(TICKER) Qtd
FROM dbo.DIM_STOCKS_DEGIRO a WITH(NOLOCK)
GROUP BY ID_DEGIRO
)
SELECT *
FROM dbo.DIM_STOCKS_DEGIRO A WITH(NOLOCK)
INNER JOIN FINVIZ_TICKER_INDUSTRY B (NOLOCK)
	ON A.TICKER = B.Ticker
WHERE ID_DEGIRO IN(SELECT ID_DEGIRO FROM CTE WHERE Qtd > 1)
	AND ID_DEGIRO > 0
ORDER BY ID_DEGIRO







WITH CTE AS
(
select ID_DEGIRO
,COUNT(TICKER) Qtd
FROM dbo.DIM_STOCKS_DEGIRO a WITH(NOLOCK)
GROUP BY ID_DEGIRO
)
SELECT *
FROM dbo.DIM_STOCKS_DEGIRO A WITH(NOLOCK)
INNER JOIN FINVIZ_TICKER_INDUSTRY B (NOLOCK)
	ON A.TICKER = B.Ticker
WHERE ID_DEGIRO IN(SELECT ID_DEGIRO FROM CTE WHERE Qtd > 1)
	AND ID_DEGIRO > 0
ORDER BY ID_DEGIRO




SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE ID_DEGIRO is null


SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE ID_DEGIRO is null





SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE Ticker <> SYMBOL_DEGIRO AND DATE_UPDATED IS NULL ORDER BY EXCHANGE ASC


select *
from DIM_STOCKS_DEGIRO
where TICKER = 'XRX'

UPDATE DIM_STOCKS_DEGIRO
SET DATE_UPDATED = GETDATE()
where TICKER = 'TIGO'



SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE Ticker <> SYMBOL_DEGIRO AND DATE_UPDATED IS NULL ORDER BY EXCHANGE ASC


alter table DIM_STOCKS_DEGIRO
add NAME_COMPANY_SEARCH NVARCHAR(150)


UPDATE A
SET NAME_COMPANY = B.Company
FROM DIM_STOCKS_DEGIRO A
INNER JOIN tradeIndexN B
	ON A.TICKER = B.TICKER


SELECT TOP 1 * FROM DIM_STOCKS_DEGIRO WHERE Ticker <> SYMBOL_DEGIRO AND DATE_UPDATED IS NULL ORDER BY EXCHANGE ASC

DECLARE @tradeIndex INT
SET @tradeIndex = (SELECT MAX(tradeIndex) FROM tradeIndexN)
IF @tradeIndex = 1
BEGIN
	TRUNCATE TABLE localMinimumPriceFinviz;
	INSERT INTO localMinimumPriceFinviz
	SELECT * FROM tradeIndexN
END
ELSE
BEGIN
	-- Delete the Ticker that are making new minimuns prices
	DELETE A
	FROM localMinimumPriceFinviz A (NOLOCK)
	INNER JOIN tradeIndexN B (NOLOCK)
		ON A.Ticker = B.Ticker
	INNER JOIN tradeIndexN1 C (NOLOCK)
		ON A.Ticker = C.Ticker
	WHERE B.lastPrice < C.lastPrice
	-- Insert reversion points > local maximum
	INSERT INTO localMinimumPriceFinviz
	SELECT 
	A.*
	FROM tradeIndexN A (NOLOCK)
	INNER JOIN tradeIndexN1 B (NOLOCK)
		ON A.Ticker = B.Ticker
	WHERE A.lastPrice < B.lastPrice
END



UPDATE tradeIndexN
SET tradeIndex = 1



TRUNCATE TABLE localMinimumPriceFinviz;
INSERT INTO localMinimumPriceFinviz(Ticker,tradeIndex,insertTime)
SELECT Ticker,0,GETDATE() 
FROM  tradeIndexN2
--
UPDATE localMinimumPriceFinviz
SET lastPrice = 500000



--
DELETE A
FROM localMinimumPriceFinviz A (NOLOCK)
INNER JOIN tradeIndexN B (NOLOCK)
	ON A.Ticker = B.Ticker
WHERE B.lastPrice < A.lastPrice


SELECT *
FROM localMinimumPriceFinviz A (NOLOCK)
INNER JOIN tradeIndexN B (NOLOCK)
	ON A.Ticker = B.Ticker
WHERE B.lastPrice < A.lastPrice


SELECT *
FROM localMinimumPriceFinviz




select *
from tradeIndexN
ORDER BY lastPrice DESC


SELECT *
FROM dailyTradesFinviz
FOR XML PATH ('Trades'), ROOT('day20221108')




select distinct tradeIndex,insertTime
from dailyTradesFinviz
order by tradeIndex



select top 10 *
from dailyReversionPoints




-- code to use in the construction of decision rules
select a.*
,MARKETS.UDF_DIV(a.lastPrice,b.lastPrice) variationUpRisingTrend
,MARKETS.UDF_DIV(a.lastPrice,c.lastPrice) variationTradeIndex
,(a.currentVolume - b.currentVolume) liquidityUpRisingTrend
,(a.currentVolume - c.currentVolume) liquidityTradeIndex
,DATEDIFF(minute,B.insertTime,A.insertTime) durationRising
from tradeIndexN a (nolock)
inner join localMinimumPriceFinviz b (nolock)
	on a.Ticker = b.Ticker
inner join tradeIndexN1 c (nolock)
	on a.Ticker = c.Ticker
where a.currentVolume > 10000 
	and a.dailyChange > 0.05 
	and MARKETS.UDF_DIV(a.lastPrice,b.lastPrice) > 0.03
	and (a.currentVolume - b.currentVolume) > 50000
	and a.RelativeVolume > 1
	and a.lastPrice > 0.7
order by MARKETS.UDF_DIV(a.lastPrice,b.lastPrice) desc
-- INM


SELECT Ticker
, count(*) Qtd
, max(priceVariation) priceVariationMax
, max(tradeIndexPriceVariation) tradeIndexPriceVariationMax
, avg(priceVariation) priceVariationAvg
, avg(tradeIndexPriceVariation) tradeIndexPriceVariationAvg
FROM tradeAnomalies (NOLOCK)
WHERE tradeIndexLiquidity > 50000
	AND tradeIndexPriceVariation > 0.001
GROUP BY Ticker
ORDER BY 2 DESC



select *
from tradeAnomalies (nolock)
where Ticker = 'ARDX'
order by tradeIndex asc








SELECT TOP 10 *
FROM localMinimumPriceFinviz



-- search for money $$$$
select STRING_AGG(Ticker,',')
from
(
select *
from tradeAnomalies (nolock)
where tradeIndex =(select max(tradeIndex) from tradeIndexN)
	and tradeIndexLiquidity > 10000
	and dailyChange > 0.05
	and tradeIndexPriceVariation > 0.01
--order by tradeIndexPriceVariation desc
) a



select *
from tradeAnomalies (nolock)
where Ticker = 'RLX'
order by tradeIndex asc


select TOP 10 *
from dailyTradesFinviz (nolock)
where Ticker = 'INM'
order by tradeIndex asc







select *
FROM localMinimumPriceFinviz A (NOLOCK)
INNER JOIN tradeIndexN B (NOLOCK)
	ON A.Ticker = B.Ticker
INNER JOIN tradeIndexN1 C (NOLOCK)
	ON A.Ticker = C.Ticker
WHERE B.lastPrice < C.lastPrice

declare @ticker nvarchar(5)
set @ticker = 'NLSP'
select top 10 *
from tradeIndexN
where Ticker = @ticker
select top 10 *
from tradeIndexN1
where Ticker = @ticker
select *
from dailyTradesFinviz
where Ticker = @ticker
order by tradeIndex asc




select top 10 *
from tradeIndexN (nolocK)

select *
from tradeAnomalies
where Ticker = 'NLSP'
order by tradeIndex asc
