create or replace PROCEDURE USP_BLEEDOFF_FC (vmodel_id INTEGER)
AS
vTRANSIT NVARCHAR2(30);
BEGIN

SELECT C_VERSION INTO vTRANSIT
FROM LOG_MODEL_CONFIG
WHERE MODEL_ID = vMODEL_ID
AND STEP_TYPE = 'CONFIGURATION_DATA'
AND STEP_CODE = 'TRANSIT TIMES DATA';

EXECUTE IMMEDIATE 'TRUNCATE TABLE STG_FC_BleedOff';
COMMIT;

INSERT INTO STG_FC_BleedOff
 SELECT T.Model_Id
      ,T.EDD-NVL(TT.STD,NVL(STD_3P,0)) AS ShipDay
      ,UPPER(TRIM(A.FC)) AS WAREHOUSE_ID
      ,SUM(T.BLEEDOFF*A.Contribution) as Bleedoff 
 FROM stg_bleedoff_calc T
 LEFT JOIN (SELECT FC,STATION,EDD,CASE WHEN SUM(SHIPMENTS) OVER (PARTITION BY FC,EDD) = 0 THEN 0
                                       ELSE SHIPMENTS/SUM(SHIPMENTS) OVER (PARTITION BY FC,EDD) END AS Contribution
FROM
(SELECT WAREHOUSE_ID AS FC,STATION,EDD,SUM(STD_SHIPMENTS) AS SHIPMENTS
FROM STG_STATIONVOLUME
WHERE ROUTEINFO='Yes'
GROUP BY WAREHOUSE_ID,STATION,EDD) ) A
ON T.STATION = A.STATION
AND T.EDD = A.EDD
LEFT JOIN SYS_FC_STN_TRANSIT_TIMES TT
ON UPPER(TRIM(T.STATION)) = UPPER(TRIM(TT.STATION))
AND UPPER(TRIM(A.FC))=UPPER(TRIM(TT.WAREHOUSE_ID))
AND TT.C_VERSION = vTRANSIT
GROUP BY T.Model_Id
      ,T.EDD-NVL(TT.STD,NVL(STD_3P,0))
      ,A.FC;
/* LEFT JOIN (SELECT Station
                 ,Zipcode
                 ,CASE WHEN SUM(Contribution) over (Partition by Station)>0 
                       THEN Contribution/SUM(Contribution) over (Partition by Station)
                       ELSE 0 END as Contribution
           FROM (Select M.Wharehouse_id as Station
                       ,M.Zipcode as Zipcode
                       ,SUM(NVL(L.Contribution,NVL(L2.Contribution,1))) as Contribution
                 FROM SYS_STN_ZIP_MAPPING M
                 LEFT JOIN Sys_Zipcode_LS_Contirbution L
                 ON M.Zipcode=L.Zipcode
                 AND M.Type_Id= L.Package_Type
                 LEFT JOIN Sys_Zipcode_LS_Contirbution L2
                 ON M.Zipcode=L2.Zipcode
                 AND L2.Package_Type = 1
                 GROUP BY M.Wharehouse_id
                         ,M.Zipcode) A
          ) C
 ON T.Station=C.Station
 LEFT JOIN (SELECT Warehouse_Id as Warehouse_Id,
                    Zipcode as Zipcode,
                    Contribution/SUM(Contribution) over (partition by Zipcode) as Contribution
              FROM (SELECT Warehouse_Id,
                           Zipcode,
                           SUM(Std_Contribution) as Contribution
                     FROM SYS_FC_ZIP_Contribution 
                     GROUP BY Warehouse_Id,
                              Zipcode
                     HAVING SUM(Std_Contribution)>0) A
             ) W
  ON C.Zipcode = W.Zipcode
  LEFT JOIN Sys_FC_Pincode_Transit_time TT
  ON C.Zipcode = TT.Pincode
  AND W.Warehouse_Id=TT.Wharehouse_Id
  WHERE Warehouse_Id IS NOT NULL
  GROUP BY T.Model_Id
          ,T.EDD+NVL(TT.Std_Tranisit_time,0)
          ,Warehouse_Id;*/

COMMIT;

END;