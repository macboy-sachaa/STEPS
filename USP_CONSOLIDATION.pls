create or replace PROCEDURE USP_Consolidation (vModel_Id INTEGER)
AS
vSTNPERF NVARCHAR2(30);
vSTNINPT NVARCHAR2(30);
vMFNINPT NVARCHAR2(30);
BEGIN

/*
This Procedure collects All inputs at Station level and created a consolidated view at Station level.
Data for AFN Shipments/MFN Shipments/C-Returns/Pickups/Capacity etc for Station are collected together.
*/

SELECT C_VERSION INTO vSTNPERF
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'CONFIGURATION_DATA'
AND STEP_CODE = 'STATION PERFORMANCE';

SELECT C_VERSION INTO vSTNINPT
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'USER_INPUT'
AND STEP_CODE = 'STATION CAPACITY & RETURNS';

SELECT C_VERSION INTO vMFNINPT
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'USER_INPUT'
AND STEP_CODE = 'MFN_PICKUP_INPUTS';


EXECUTE IMMEDIATE 'TRUNCATE TABLE stg_StationVolume_Con DROP STORAGE';
COMMIT;

INSERT INTO stg_StationVolume_Con
Select vModel_Id as Model_id
      ,A.Station
	    ,A.EDD
	    ,A.AFN_STD AS AFN_STD
	    ,A.AFN_FT
      ,CASE WHEN A.AFN_STD=0 THEN 0 ELSE A.AFN_STD_L/A.AFN_STD END AS AFN_STD_L
      ,A.FT_Same
      ,A.FT_Same_L
      ,A.FT_Next
      ,A.FT_Next_L
      ,A.FT_Exp
      ,A.FT_Exp_L
	    ,NVL(M.MFN_STD,0) as MFN_STD
      ,NVL(M.MFN_STD_L,0) AS MFN_STD_L
	    ,NVL(P.MFN_Pickups,0) as MFN_Pickups
	    ,NVL(C.C_Returns_Pickups,0) as C_Returns
	    ,A.AFN_STD+NVL(M.MFN_STD,0) as Total_STD
	  --,CASE WHEN NVL(C.STN_Capacity,0)-NVL(P.MFN_Pickups,0)-NVL(C.C_Returns_Pickups,0) > 0 THEN NVL(C.STN_Capacity,0)-NVL(P.MFN_Pickups,0)-NVL(C.C_Returns_Pickups,0) ELSE 0 END as Delv_Capacity
      ,CASE WHEN NVL(C.STN_Capacity,0)>0 THEN NVL(C.STN_Capacity,2000) ELSE 2000 END as Delv_Capacity
	    ,case when TRIM(TO_CHAR(A.EDD,'Day')) in ('Saturday','Sunday') then P2.ONTIMEDELIVERIES else P1.ONTIMEDELIVERIES end as ONTIMEDELIVERIES
	    ,case when TRIM(TO_CHAR(A.EDD,'Day')) in ('Saturday','Sunday') then P2.COMMERCIALDELV else P1.COMMERCIALDELV end as COMMERCIALDELV
	    ,case when TRIM(TO_CHAR(A.EDD,'Day')) in ('Saturday','Sunday') then P2.COMMERCIALDELVSUCCESS else P1.COMMERCIALDELVSUCCESS end as COMMERCIALDELVSUCCESS
      ,case when TRIM(TO_CHAR(A.EDD,'Day')) in ('Saturday','Sunday') then P2.REJECTS else P1.REJECTS end as REJECTS
FROM (Select Model_Id,
        UPPER(TRIM(Station)) AS Station,
        TRUNC(EDD) AS EDD,
		SUM(STD_Shipments) as AFN_STD,
		SUM(FT_same+FT_next+FT_exp) as AFN_FT,
    SUM(STD_Shipments_L) as AFN_STD_L,
    SUM(FT_same) as FT_Same,
    SUM(FT_Same_L) as FT_Same_L,
    SUM(FT_Next) as FT_Next,
    SUM(FT_Next_L) as FT_Next_L,
    SUM(FT_Exp) as FT_Exp,
    SUM(FT_Exp_L) as FT_Exp_L    
		FROM stg_StationVolume
		where Station IS NOT NULL
    and ROUTEINFO = 'Yes'
		GROUP BY Model_Id,
		UPPER(TRIM(Station)),
        TRUNC(EDD)) A --AFN Data
left join (Select Model_id,Station,TRUNC(EDD) AS EDD,sum(MFNVolume) as MFN_STD,sum(MFNVolume_L) as MFN_STD_L
FROM stg_StationMFNVolume
Group by Model_id,Station,TRUNC(EDD)) M -- MFN Data
On A.Station=M.Station
and A.EDD=M.EDD
left Join (SELECT Model_Id
      ,TRUNC(Pickup_Date) as EDD
      ,UPPER(TRIM(WAREHOUSE_ID)) as Station
      ,Sum(Std_shipout) as MFN_Pickups
  FROM (SELECT MODEL_ID,PICKUP_DATE,STATION AS WAREHOUSE_ID,Std_shipout
         FROM IN_MFN_PICKUPS_INPUTS
         GROUP BY MODEL_ID,PICKUP_DATE,STATION,Std_shipout)
  WHERE MODEL_ID = CAST(vMFNINPT AS INT)
  group by Model_Id
      ,TRUNC(Pickup_Date)
      ,UPPER(TRIM(WAREHOUSE_ID))) P -- MFN Pickups
ON A.Station=P.Station
and A.EDD=P.EDD
left join (SELECT MODEL_ID,PICKUP_DATE,UPPER(TRIM(STATION)) AS WAREHOUSE_ID,C_RETURNS_PICKUPS,STN_CAPACITY
FROM In_Station_Inputs 
where Model_Id = CAST(vSTNINPT AS INT)
GROUP BY MODEL_ID,PICKUP_DATE,UPPER(TRIM(STATION)),C_RETURNS_PICKUPS,STN_CAPACITY) C -- Creturns and Capacity inputs for station
on A.Station=UPPER(TRIM(C.WAREHOUSE_ID))
and TRUNC(A.EDD)=TRUNC(C.Pickup_Date)
LEFT JOIN (SELECT * FROM SYS_STATION_PERFORMANCE WHERE C_VERSION = vSTNPERF) P1
ON A.Station=UPPER(TRIM(P1.STATION))
and UPPER(TRIM(P1.DAYTYPE)) = case when UPPER(TRIM(P1.DAYTYPE)) = 'OTHERS' then case when UPPER(TRIM(TO_CHAR(A.EDD,'Day'))) in ('SATURDAY','SUNDAY') THEN 'OTHERS' ELSE 'HOLIDAY' END
                                  ELSE UPPER(TRIM(TO_CHAR(A.EDD,'Day'))) END
LEFT JOIN (SELECT * FROM SYS_STATION_PERFORMANCE WHERE C_VERSION = vSTNPERF) P2
ON A.Station=UPPER(TRIM(P2.STATION))
and UPPER(TRIM(P2.DAYTYPE)) = case when UPPER(TRIM(P2.DAYTYPE)) = 'OTHERS' then case when UPPER(TRIM(TO_CHAR(A.EDD,'Day'))) in ('SATURDAY','SUNDAY') THEN 'OTHERS' ELSE 'HOLIDAY' END
                                  ELSE UPPER(TRIM(TO_CHAR(A.EDD,'Day'))) END
Order by A.EDD;

COMMIT;

EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_BLEEDOFFS_LEVEL3 DROP STORAGE';
COMMIT;

INSERT INTO STG_BLEEDOFFS_LEVEL3
Select vModel_Id as Model_Id,
        UPPER(TRIM(WAREHOUSE_ID)) AS WAREHOUSE_ID,
        Station,
        TRUNC(EDD) AS EDD,
		    SUM(STD_Shipments+FT_same+FT_next+FT_exp) as Shipments
		FROM stg_StationVolume S
		where (ROUTEINFO <> 'Yes' OR STATION IS NULL)
    and Model_Id is not null
		GROUP BY vModel_Id,
        UPPER(TRIM(WAREHOUSE_ID)),
        Station,
        TRUNC(EDD);
        
COMMIT;

END;