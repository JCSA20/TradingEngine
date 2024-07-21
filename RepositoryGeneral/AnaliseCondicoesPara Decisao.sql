

select *
from tradeIndexN
where Ticker = 'PGRE'
order by tradeIndex asc

select *
from dailyTradesFinviz
where Ticker = 'RLX'
order by tradeIndex asc






select distinct Ticker
from dailyTradesFinviz
where currentVolume * lastPrice > 1000000

with cte as (
select 
ROW_NUMBER() OVER (PARTITION BY TICKER ORDER BY tradeIndex ASC) AS RowNumber
,*
from tradeAnomalies
where tradeIndexPriceVariation >0.025
	and Ticker in(
					select distinct Ticker
					from dailyTradesFinviz
					where currentVolume * lastPrice > 1000000

				)
	and tradeIndex < 120
	and dailyChange between 0 and 0.15
	and tradeIndexLiquidity > 100000
	)
select 
b.lastPrice
,MARKETS.UDF_DIV(b.lastPrice,a.lastPrice) strategyReturn
,(b.currentVolume - a.currentVolume) *(a.lastPrice+b.lastPrice)/2 liquidityAfterBuy
,a.*
from cte a
inner join tradeIndexN b
	on a.Ticker = b.Ticker
where RowNumber = 1
	and tradeIndexLiquidity > 50000
	and priceVariation> 0.05
order by 2 desc








select top 10 *
from tradeAnomalies
