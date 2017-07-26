
IF (OBJECT_ID('TEMPDB..#MT_20170504') IS NOT NULL) DROP TABLE #MT_20170504
IF (OBJECT_ID('TEMPDB..#MTXY_20170504') IS NOT NULL) DROP TABLE #MTXY_20170504
IF (OBJECT_ID('TEMPDB..#MTWechat_20170504') IS NOT NULL) DROP TABLE #MTWechat_20170504
--维修业务指数
 SELECT  A.COMPCODE,A.MTADVISORID,a.MTADVISOR,
 TCar =COUNT(A.SERVICENO) ,
 PartCostRate =ROUND(CASE WHEN SUM(B.ServeSum) > 0 THEN SUM(B.PartCost) * 100.0 / SUM(B.ServeSum) END, 2), 
 ServeSum =ISNULL(SUM(B.ServeSum), 0) , 
 CopErpOf = ISNULL(SUM(B.COPEPROF), 0), 
 NetIncome = ISNULL(SUM(B.NETINCOME), 0)
 INTO #MT_20170504
 FROM  WX_Maintain A 
 INNER JOIN wbrepair..WX_Settlement B ON A.SERVICENO = B.ServiceNO 
 WHERE   1 = 1 AND A.TenorSn = 6 
 AND A.LEAVEDATE >= '2017-05-01'
 AND A.LEAVEDATE < '2017-06-01'
  Group By A.CompCode, a.MTADVISOR,A.MTADVISORID
  
  
--换季保 和买X送Y 

SELECT  BXY=sum(case when a.ServiceNO ='01080804' and substring(a.ActItemID,1,2) ='XY' then 1 else 0 end),
BTB=sum(case when a.ServiceNO ='01080804' and substring(a.ActItemID,1,2) ='TB' then 1 else 0 end),
b.OperatorID,b.Operator,a.CompCode
INTO #MTXY_20170504
 FROM wbcrm..YXS_ActivityUse a 
INNER JOIN wbcrm..OnLine_Order b ON a.ActItemIDSub = b.ID 
WHERE a.PayDate >'2017-05-01'
group by a.CompCode,b.OperatorID,b.Operator
  

--微信点评  

SELECT ls.CompCode,ls.MTAdvisorID,CommCN =sum(ls.CommQty),GoodCommCN =sum(ls.GoodCommQty) 
INTO #MTWechat_20170504
FROM wbrepair..WX_WechatList ls WHERE ls.FYear =2017 AND ls.FMonth = 5 
GROUP BY ls.CompCode,ls.MTAdvisorID


SELECT a.*,c.BXY,c.BTB,b.CommCN,b.GoodCommCN,
 QiMoClient =(SELECT QiMoClient 
 FROM wbrepair..WX_LostClient_MTAdvisor  WHERE 
 ID = (SELECT max(ID) FROM wbrepair..WX_LostClient_MTAdvisor WHERE CompCode = a.CompCode AND MTAdvisor = a.MTAdvisor ) 
 )
   FROM
#MT_20170504 a 
LEFT  JOIN #MTWechat_20170504 b ON b.CompCode = a.COMPCODE AND a.MTADVISORID = b.MTAdvisorID 
LEFT JOIN #MTXY_20170504 c ON c.CompCode = a.CompCode AND c.OperatorID = a.MTADVISORID


IF (OBJECT_ID('TEMPDB..#MT_20170504') IS NOT NULL) DROP TABLE #MT_20170504
IF (OBJECT_ID('TEMPDB..#MTXY_20170504') IS NOT NULL) DROP TABLE #MTXY_20170504
IF (OBJECT_ID('TEMPDB..#MTWechat_20170504') IS NOT NULL) DROP TABLE #MTWechat_20170504
