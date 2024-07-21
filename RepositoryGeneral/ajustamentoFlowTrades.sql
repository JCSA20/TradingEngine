

INSERT INTO dailyTrades(ev,sym,v,av,op,vw,o,c,h,l,a,z,s,e,startTime,endTime,tradeIndex)
SELECT 
A.ev
,A.sym
,A.v
,A.av
,A.op
,A.vw
,A.o
,A.c
,A.h
,A.l
,A.a
,A.z
,A.s
,A.e
,A.startTime
,A.endTime
,dbo.FxTradeIndex(A.sym) tradeIndex
FROM 
		(
		SELECT 
		ev	
		,sym
		,v
		,av
		,op
		,vw
		,o
		,c
		,h
		,l
		,a
		,z
		,s
		,e
		, DATEADD(s,CAST(LEFT(s,10) AS INT), '1970-01-01') [startTime]
		, DATEADD(s,CAST(LEFT(e,10) AS INT), '1970-01-01') [endTime]
		, ROW_NUMBER() OVER (PARTITION BY sym ORDER BY s DESC) AS tradeIndex
		FROM tblRawIntradayPrice A WITH(NOLOCK)
		-- para cruzar só com stocks do Nasdaq, Amex e NYSE
		--LEFT JOIN DIM_STOCKS B WITH(NOLOCK)
		--	ON A.sym = B.TICKER
		--WHERE B.PRIMARY_EXCHANGE IN('ARCX','XASE','XNGS','XNYS','XNAS')
		) A
LEFT JOIN dailyTrades B WITH(NOLOCK)
	ON A.sym = B.sym AND A.s = B.s
WHERE A.tradeIndex = 1 AND B.sym IS NULL


CREATE VIEW VwMaxTradeByTicker
AS
SELECT sym,MAX(tradeIndex) MaxTradeIndex
FROM dailyTrades WITH(NOLOCK)
GROUP BY sym


SELECT sym,COUNT(*) Qtd
FROM tblRawIntradayPrice A WITH(NOLOCK)
GROUP BY sym


-- update the trade flow
TRUNCATE TABLE previous2LastTrade
TRUNCATE TABLE previousLastTrade
TRUNCATE TABLE lastTrade
INSERT INTO lastTrade
SELECT *
FROM dailyTrades A WITH(NOLOCK)
INNER JOIN VwMaxTradeByTicker B
	ON A.sym = B.sym AND A.tradeIndex = B.MaxTradeIndex

--
INSERT INTO previousLastTrade
SELECT A.*
FROM dailyTrades A WITH(NOLOCK)
INNER JOIN VwMaxTradeByTicker B
	ON A.sym = B.sym AND A.tradeIndex = B.MaxTradeIndex - 1
--
INSERT INTO previous2LastTrade
SELECT A.*
FROM dailyTrades A WITH(NOLOCK)
INNER JOIN VwMaxTradeByTicker B
	ON A.sym = B.sym AND A.tradeIndex = B.MaxTradeIndex - 2