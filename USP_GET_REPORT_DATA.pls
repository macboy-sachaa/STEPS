create or replace PROCEDURE USP_GET_REPORT_DATA (vMODEL_ID INTEGER) AS 
BEGIN
 
DELETE FROM RPT_FIRST_MILE_VIEW
WHERE MODEL_ID = vMODEL_ID;
COMMIT;
  
INSERT INTO RPT_FIRST_MILE_VIEW
SELECT S.MODEL_ID
       ,S.WAREHOUSE_ID AS FC
       ,S.SHIPOUT_DATE
       ,CASE WHEN ROUND(NVL(S.AMZL_STD,0),0)-ROUND(NVL(BLEEDOFF_3P,0),0)-ROUND(NVL(B.HIGHTT,0),0)-ROUND(NVL(C.NOLANE,0),0)-ROUND(NVL(E.SHIPMENTS,0),0)<0 THEN 0
        ELSE ROUND(NVL(S.AMZL_STD,0),0)-ROUND(NVL(BLEEDOFF_3P,0),0)-ROUND(NVL(B.HIGHTT,0),0)-ROUND(NVL(C.NOLANE,0),0)-ROUND(NVL(E.SHIPMENTS,0),0) END AS AMZL_STD
       ,ROUND(NVL(S.AMZL_FT,0),0) AS AMZL_FT
       ,ROUND(NVL(A.HAZMAT,0),0) AS HAZMAT
       ,ROUND(NVL(A.INJECTIONS,0),0) AS INJECTIONS
       ,ROUND(NVL(B.HIGHTT,0),0) AS HIGHTT
       ,ROUND(NVL(C.NOLANE,0),0) AS NOLANE
       ,ROUND(NVL(BLEEDOFF_3P,0),0) AS BLEEDOFF_3P
       ,ROUND(NVL(E.SHIPMENTS,0),0) AS NONAMZL_3P
FROM 
(SELECT MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,SUM(STD_SHIPOUT) AS AMZL_STD,SUM(FT_SHIPOUT) AS AMZL_FT
FROM STG_FC_SHIPOUTS
GROUP BY MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID) S
LEFT JOIN
(SELECT MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,SUM(HAZMAT) AS HAZMAT,SUM(INJECTIONS) AS INJECTIONS 
FROM STG_BLEEDOFFS_LEVEL1
GROUP BY MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID) A
ON S.WAREHOUSE_ID=A.WAREHOUSE_ID
AND S.SHIPOUT_DATE = A.SHIPOUT_DATE
LEFT JOIN (SELECT MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,SUM(SHIPMENTS) AS HIGHTT 
FROM STG_BLEEDOFFS_LEVEL2
GROUP BY MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID) B
ON S.SHIPOUT_DATE=B.SHIPOUT_DATE
AND S.WAREHOUSE_ID=B.WAREHOUSE_ID
LEFT JOIN (SELECT MODEL_ID,EDD AS SHIPOUT_DATE,WAREHOUSE_ID,SUM(SHIPMENTS) AS NOLANE 
FROM STG_BLEEDOFFS_LEVEL3
GROUP BY MODEL_ID,EDD,WAREHOUSE_ID) C
ON S.WAREHOUSE_ID=C.WAREHOUSE_ID
AND S.SHIPOUT_DATE=C.SHIPOUT_DATE
LEFT JOIN (SELECT MODEL_ID,WAREHOUSE_ID AS FC,SHIPDAY,SUM(BLEEDOFF) AS BLEEDOFF_3P
FROM STG_FC_BLEEDOFF
GROUP BY MODEL_ID,WAREHOUSE_ID,SHIPDAY) D
ON S.WAREHOUSE_ID=D.FC
AND S.SHIPOUT_DATE=D.SHIPDAY
LEFT JOIN (SELECT MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,SUM(SHIPMENTS) AS SHIPMENTS
FROM STG_NONAMZL_SHIPMENTS
GROUP BY MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID) E
ON S.SHIPOUT_DATE = E.SHIPOUT_DATE
AND S.WAREHOUSE_ID = E.WAREHOUSE_ID;

COMMIT;


DELETE FROM RPT_LAST_MILE_VIEW
WHERE MODEL_ID = vMODEL_ID;
COMMIT;


INSERT INTO RPT_LAST_MILE_VIEW
SELECT MODEL_ID
      ,STATION
      ,EDD
      ,ROUND(AFN_STD,0) AS AFN_STD
      ,ROUND(AFN_STD*AFN_STD_L,0) AS AFN_STD_L
      ,ROUND(AFN_FT,0) AS AFN_FT
      ,ROUND(FT_SAME,0) AS FT_SAME
      ,ROUND(FT_SAME_L,0) AS FT_SAME_L
      ,ROUND(FT_NEXT,0) AS FT_NEXT
      ,ROUND(FT_NEXT_L,0) AS FT_NEXT_L
      ,ROUND(FT_EXP,0) AS FT_EXP
      ,ROUND(FT_EXP_L,0) AS FT_EXP_L      
      ,ROUND(MFN_STD,0) AS MFN_STD
      ,ROUND(MFN_STD_L,0) AS MFN_STD_L
      ,ROUND(MFN_PICKUPS,0) AS MFN_PICKUPS
      ,ROUND(C_RETURNS,0) AS C_RETURNS
      ,ROUND(TOTAL_STD,0) AS TOTAL_STD
      ,ROUND(AFN_STD*AFN_STD_L,0)+ROUND(MFN_STD_L,0) AS TOTAL_STD_L
      ,ROUND(DELV_CAPACITY,0) AS DELV_CAPACITY
      ,ROUND(STD_DELV_LAG,0) AS STD_DELV_LAG
      ,ROUND(DELV_ATTEMPTED,0) AS DELV_ATTEMPTED
      ,ROUND(EOD_NOT_ATTEMPTED,0) AS EOD_NOT_ATTEMPTED
      ,ROUND(DELV_TO_REATTEMPT,0) AS DELV_TO_REATTEMPT
      ,ROUND(EOD_BACKLOG,0) AS EOD_BACKLOG
      ,ROUND(EOD_BACKLOG_IN_DAYS,2) AS EOD_BACKLOG_IN_DAYS
FROM STG_BLEEDOFF_CALC;

COMMIT;
  
END;