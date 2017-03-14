create or replace PROCEDURE USP_FC_ZIPCODE_VOLUME (vMODEL_ID integer)
AS
vSTART_DATE DATE;
vDuration INTEGER;
vINFC INTEGER;
vHAZMAT NVARCHAR2(30);
vFCZIPCONTRIB NVARCHAR2(30);
vTRANSIT NVARCHAR2(30);
vSTNZIP NVARCHAR2(30);

-------------------------------------------------
/*
1. This procedure Calculates volumes at Zipcodes based on Shipouts from FC and FC to Zipcode Historical 
  contribution.
2. Data for FC shipouts is collected from SNoP forecast which is then processed using historical data 
  for contribution at zipcode and transit times to find EDD wise Shipments at Station.
*/
-------------------------------------------------
BEGIN

SELECT START_DATE INTO vSTART_DATE
FROM IN_MODEL WHERE ID = vMODEL_ID;

SELECT DURATION INTO vDuration
FROM IN_MODEL WHERE ID = vMODEL_ID;

SELECT C_VERSION INTO vHAZMAT
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'CONFIGURATION_DATA'
AND STEP_CODE = 'FC HAZMAT CONTRIBUTION';

SELECT C_VERSION INTO vSTNZIP
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'CONFIGURATION_DATA'
AND STEP_CODE = 'STATION ZIPCODE MAPPING (LARGE/SMALL)';

SELECT LINKEDMODEL INTO vINFC
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'USER_INPUT'
AND STEP_CODE = 'FC_SHIPOUTS';

SELECT C_VERSION INTO vFCZIPCONTRIB
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'CONFIGURATION_DATA'
AND STEP_CODE = 'FC ZIPCODE CONTRIBUTION';

SELECT C_VERSION INTO vTRANSIT
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'CONFIGURATION_DATA'
AND STEP_CODE = 'TRANSIT TIMES DATA';

EXECUTE IMMEDIATE 'TRUNCATE TABLE Stg_FC_Zip_Volumes DROP STORAGE'; --Truncate previous records for the same model from the table
COMMIT;

EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_FC_SHIPOUTS DROP STORAGE'; --Truncate Staging FC Shipouts after Hazmat & Injections
COMMIT;

EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_BLEEDOFFS_LEVEL1 DROP STORAGE'; --Truncate Staging Hazmat & Injections Volume
COMMIT;

EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_NONAMZL_SHIPMENTS DROP STORAGE'; --Truncate Staging table for Non Amzl Shipments
COMMIT;

EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_SNOP_FC_INPUTS DROP STORAGE'; --Truncate Staging table for Non Amzl Shipments
COMMIT;

--dbms_output.put_line(vSTART_DATE);
--dbms_output.put_line(vDuration);
INSERT INTO STG_SNOP_FC_INPUTS
SELECT SHIPOUT_DATE
        ,WAREHOUSE_ID
        ,FT_SHIPOUT
        ,STD_SHIPOUT
FROM SYS_FC_SHIPOUT_ACTUALS S
WHERE SHIPOUT_DATE BETWEEN vSTART_DATE-5 AND vSTART_DATE - 1;

INSERT INTO STG_FC_SHIPOUTS -- Insert FC Shiputs Volume after Hazmat & Injections
select S.MODEL_ID,
       S.SHIPOUT_DATE,
       UPPER(TRIM(S.WAREHOUSE_ID)) AS WAREHOUSE_ID,
       NVL(S.STD_SHIPOUT,0)-(NVL(H.HAZMATVOL,0)*NVL(S.STD_SHIPOUT,0))-(NVL(H.INJECTIONS,0)*NVL(S.STD_SHIPOUT,0)) as STD_SHIPOUT,
       NVL(S.FT_SHIPOUT,0) AS FT_SHIPOUT
       FROM   (SELECT MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,STD_SHIPOUT,FT_SHIPOUT
  FROM IN_SNOP_FC_INPUTS
  WHERE SHIPOUT_DATE NOT IN (SELECT SHIPOUT_DATE FROM STG_SNOP_FC_INPUTS)
  AND MODEL_ID = vINFC
  AND Shipout_Date between vSTART_DATE-5 AND vSTART_DATE + vDuration
  UNION ALL
  SELECT vINFC AS MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,STD_SHIPOUT,FT_SHIPOUT
  FROM STG_SNOP_FC_INPUTS) S
LEFT JOIN SYS_FC_HAZMAT_VOL H
on UPPER(TRIM(S.WAREHOUSE_ID))=UPPER(TRIM(H.WAREHOUSE_ID))
WHERE H.C_VERSION = vHAZMAT;


INSERT INTO STG_BLEEDOFFS_LEVEL1 -- Insert Hazmat & Injections Bleedoffs from FC
select S.MODEL_ID,
       S.SHIPOUT_DATE,
       UPPER(TRIM(S.WAREHOUSE_ID)) AS WAREHOUSE_ID,
       (NVL(H.HAZMATVOL,0)*NVL(S.STD_SHIPOUT,0)) as HAZMAT,
       (NVL(H.INJECTIONS,0)*NVL(S.STD_SHIPOUT,0)) as INJECTIONS
       from   (SELECT MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,STD_SHIPOUT,FT_SHIPOUT
  FROM IN_SNOP_FC_INPUTS
  WHERE SHIPOUT_DATE NOT IN (SELECT SHIPOUT_DATE FROM STG_SNOP_FC_INPUTS)
  AND MODEL_ID = vINFC
  AND Shipout_Date between vSTART_DATE-5 AND vSTART_DATE + vDuration
  UNION ALL
  SELECT vINFC AS MODEL_ID,SHIPOUT_DATE,WAREHOUSE_ID,STD_SHIPOUT,FT_SHIPOUT
  FROM STG_SNOP_FC_INPUTS) S
inner join SYS_FC_HAZMAT_VOL H
on UPPER(TRIM(S.WAREHOUSE_ID))=UPPER(TRIM(H.WAREHOUSE_ID))
where H.C_VERSION = vHAZMAT;



Insert into Stg_FC_Zip_Volumes -- Insert Processed Data into table

/*This is only */
Select A.MODEL_ID
       ,A.Shipout_Date
       ,UPPER(TRIM(A.WAREHOUSE_ID)) AS WAREHOUSE_ID
       ,CAST(TRIM(B.Zipcode) AS INTEGER) AS ZIPCODE
       ,SUM(NVL(STD_Shipouts,0)*NVL(Std_Contribution,0)) as STD_Volume
       ,NVL(B.ACT_STD_TRANSIT_TIME,3.5) + Shipout_Date as STD_EDD
       ,SUM(NVL(FT_Shipouts,0)*NVL(FTSame_Contribution,0)) as FTSame_Volume
       ,NVL(B.ACT_FT_SAME_TRANSIT_TIME,0) + Shipout_Date as FTSame_EDD
       ,SUM(NVL(FT_Shipouts,0)*NVL(FTNext_Contribution,0)) as FTNext_Volume
       ,NVL(B.ACT_FT_NEXT_TRANSIT_TIME,1) + Shipout_Date as FTNext_EDD
       ,SUM(NVL(FT_Shipouts,0)*NVL(FTExp_Contribution,0)) as FTExp_Volume
       ,NVL(B.ACT_FT_EXP_TRANSIT_TIME,2) + Shipout_Date as FTExp_EDD
       ,Flag
FROM (SELECT MODEL_ID
            ,Shipout_Date
            ,WAREHOUSE_ID
            ,SUM(NVL(Std_shipout,0)) as STD_Shipouts
            ,SUM(NVL(FT_SHIPOUT,0)) as FT_Shipouts
      FROM STG_FC_SHIPOUTS
      --WHERE MODEL_ID = vMODEL_ID
      --AND WAREHOUSE_ID in ('BLR5','HYD7') --Testing Script
      --AND Shipout_Date between TO_DATE('20161005','YYYYMMDD') AND TO_DATE('20161015','YYYYMMDD') --Testing Script
      GROUP BY MODEL_ID
              ,Shipout_Date
              ,WAREHOUSE_ID
     ) A  -- Data from SNoP Forecast
LEFT JOIN (SELECT A.Warehouse_Id
                 ,A.ZIPCODE AS Zipcode
                 ,STD as Std_Contribution
                 ,NVL(ACT_Std_Transit_time,3.5) as ACT_STD_TRANSIT_TIME
                 ,FT_Same as FTSame_Contribution
                 ,NVL(ACT_FT_Same_Transit_time,0) as ACT_FT_SAME_TRANSIT_TIME
                 ,FT_Next as FTNext_Contribution
                 ,NVL(ACT_FT_Next_Transit_time,1) as ACT_FT_NEXT_TRANSIT_TIME
                 ,FT_Exp as FTExp_Contribution
                 ,NVL(ACT_FT_Exp_Transit_time,2) as ACT_FT_EXP_TRANSIT_TIME
                 ,CASE WHEN CEIL(NVL(Std_Transit_time,0)) > CEIL(NVL(Transit_Time_3P,15)) THEN '3P' ELSE 'AMZL' END AS Flag
  FROM Sys_FC_Zip_Contribution A -- Historical Data for FC to Zipcode Shipments Contribution
  left join Sys_FC_PINCODE_Transit_time B -- Historical Data for FC to Zipcode Transit Times
  on UPPER(TRIM(A.Warehouse_Id))=UPPER(TRIM(B.WAREHOUSE_ID))
  AND A.ZIPCODE=B.ZIPCODE
  AND B.C_VERSION = vTRANSIT
  WHERE A.C_VERSION = vFCZIPCONTRIB
  ) B
  ON UPPER(TRIM(A.WAREHOUSE_ID))=UPPER(TRIM(B.Warehouse_Id))
  --AND CASE WHEN CAST(CONCAT(TO_CHAR(A.SHIPOUT_DATE-7,'YYYY'),TO_CHAR(A.SHIPOUT_DATE-7,'IW')) AS INT) > 201702 THEN 201701 
  --ELSE CAST(CONCAT(TO_CHAR(A.SHIPOUT_DATE-7,'YYYY'),TO_CHAR(A.SHIPOUT_DATE-7,'IW')) AS INT) END= B.WEEKNO
  --nEED TO BE EDITED EVERYTIME CONFIGURATION IS UPDATED (TILL AUTOMATION IS DONE.)
  GROUP BY A.MODEL_ID
          ,A.Shipout_Date
          ,UPPER(TRIM(A.WAREHOUSE_ID))
          ,B.Zipcode
          ,NVL(B.ACT_STD_TRANSIT_TIME,3.5) + Shipout_Date
          ,NVL(B.ACT_FT_SAME_TRANSIT_TIME,0) + Shipout_Date
          ,NVL(B.ACT_FT_NEXT_TRANSIT_TIME,1) + Shipout_Date
          ,NVL(B.ACT_FT_EXP_TRANSIT_TIME,2) + Shipout_Date
          ,Flag;
  
  COMMIT;
  
INSERT INTO STG_NONAMZL_SHIPMENTS -- Insert data for Non AMZL Shipments
SELECT MODEL_ID,SHIPOUT_DATE,UPPER(TRIM(WAREHOUSE_ID)) AS WAREHOUSE_ID,SUM(STD_VOLUME) AS SHIPMENTS
FROM STG_FC_ZIP_VOLUMES
WHERE ZIPCODE NOT IN (SELECT ZIPCODE FROM SYS_STN_ZIP_MAPPING_ACT
WHERE UPPER(TRIM(C_VERSION)) = vSTNZIP)
GROUP BY MODEL_ID,SHIPOUT_DATE,UPPER(TRIM(WAREHOUSE_ID));

COMMIT;

END;