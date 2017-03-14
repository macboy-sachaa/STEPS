create or replace PROCEDURE USP_LOAD_CONFIGURATIONS(vVERSION_ID INTEGER) AS
vC_VERSION NVARCHAR2(30);
vSTART_DATE DATE;
vEND_DATE DATE;
vERROR_TABLE NVARCHAR2(500);
vROW_COUNT INTEGER;
BEGIN

SELECT TRIM(C_VERSION) INTO vC_VERSION
FROM SYS_VERSIONS 
WHERE ROW_ID = vVERSION_ID;

SELECT V_STARTDATE INTO vSTART_DATE
FROM SYS_VERSIONS
WHERE ROW_ID = vVERSION_ID;

SELECT V_ENDDATE INTO vEND_DATE
FROM SYS_VERSIONS
WHERE ROW_ID = vVERSION_ID;

vERROR_TABLE := '';

-------------------------------DELETE DATA FOR THE SPECIFIC VERSION (If Exists)--------------------------
SELECT COUNT(*) INTO vROW_COUNT 
FROM TEMP_DATA_FC_HAZMAT_VOL;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_DATA_FC_HAZMAT_VOL,');
END IF;

SELECT COUNT(*) INTO vROW_COUNT
FROM TEMP_FC_PINCODE_TRANSIT_TIMES;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_FC_PINCODE_TRANSIT_TIMES,');
END IF;

SELECT COUNT(*) INTO vROW_COUNT
FROM TEMP_SYS_FC_STN_TRANSIT_TIMES;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_SYS_FC_STN_TRANSIT_TIMES,');
END IF;

SELECT COUNT(*) INTO vROW_COUNT
FROM TEMP_FC_ZIPCODE_CONTRIBUTION;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_FC_ZIPCODE_CONTRIBUTION,');
END IF;

SELECT COUNT(*) INTO vROW_COUNT
FROM TEMP_SYS_MFN_CONTRIB;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_SYS_MFN_CONTRIB,');
END IF;

SELECT COUNT(*) INTO vROW_COUNT
FROM TEMP_SYS_MFN_TRANSIT_TIME;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_SYS_MFN_TRANSIT_TIME,');
END IF;


SELECT COUNT(*)  INTO vROW_COUNT
FROM TEMP_SYS_STATION_PERFORMANCE;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_SYS_STATION_PERFORMANCE,');
END IF;


SELECT COUNT(*) INTO vROW_COUNT
FROM TEMP_SYS_STN_ZIP_MAPPING;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_SYS_STN_ZIP_MAPPING,');
END IF;

SELECT COUNT(*) INTO vROW_COUNT
FROM TEMP_SYS_ZIPCODE_LS_MAPPING;

IF vROW_COUNT <= 0
THEN 
vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_SYS_ZIPCODE_LS_MAPPING,');
END IF;

--SELECT COUNT(*) INTO vROW_COUNT
--FROM TEMP_SYS_STATION_ACTIVITY;

--IF vROW_COUNT <= 0
--THEN 
--vERROR_TABLE := CONCAT(NVL(vERROR_TABLE,''),'TEMP_SYS_STATION_ACTIVITY,');
--END IF;

IF (LENGTH(TRIM(NVL(vERROR_TABLE,'None'))) < 10)
THEN

dbms_output.put_line('EXECUTION STARTED');

DELETE FROM SYS_FC_HAZMAT_VOL
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_FC_PINCODE_TRANSIT_TIME
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_FC_STN_TRANSIT_TIMES
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_FC_ZIP_CONTRIBUTION
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_MFN_ZIP_CONTRIBUTION
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_MFN_ZIP_TRANSIT_TIMES
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_STATION_PERFORMANCE
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_STN_ZIP_MAPPING_ACT
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_ZIPCODE_LS_CONTRIBUTION
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;

DELETE FROM SYS_MFN_STN_CONTRIBUTION
WHERE UPPER(TRIM(C_VERSION)) = vC_VERSION;




------------------------------INSERT DATA FROM TEMP TABLES TO SYSTEM CONFIGURATION TABLE------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_HAZMAT_VOL','Loading Data');
END;

INSERT INTO SYS_FC_HAZMAT_VOL
(WAREHOUSE_ID,HAZMATVOL,INJECTIONS,C_VERSION)
SELECT UPPER(TRIM(WAREHOUSE_ID)),HAZMATVOL,INJECTIONS,vC_VERSION AS C_VERSION
FROM TEMP_DATA_FC_HAZMAT_VOL
WHERE (HAZMATVOL IS NOT NULL) OR (INJECTIONS IS NOT NULL);

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_HAZMAT_VOL','Done');
END;


-------------------------------------------------------------------------------------------------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_PINCODE_TRANSIT_TIME','Loading Data');
END;

INSERT INTO SYS_FC_PINCODE_TRANSIT_TIME
(ID,WAREHOUSE_ID,ZIPCODE,TRANSIT_TIME_3P,FT_SAME_TRANSIT_TIME,FT_NEXT_TRANSIT_TIME,FT_EXP_TRANSIT_TIME,INJECTIONS,STD_TRANSIT_TIME,ACT_TRANSIT_TIME_3P,ACT_FT_SAME_TRANSIT_TIME,ACT_FT_NEXT_TRANSIT_TIME,ACT_FT_EXP_TRANSIT_TIME,ACT_INJECTIONS,ACT_STD_TRANSIT_TIME,C_VERSION)
SELECT ID,UPPER(TRIM(WAREHOUSE_ID)),POSTALCODE,SP_CONFIG,FT_SAME_CONFIG,FT_NEXT_CONFIG,FT_EXP_CONFIG,INJECTIONS_CONFIG,STD_CONFIG,SP_ACTUAL,FT_SAME_ACTUAL,FT_NEXT_ACTUAL,FT_EXP_ACTUAL,INJECTIONS_ACTUAL,STD_ACTUAL,vC_VERSION AS C_VERSION
FROM TEMP_FC_PINCODE_TRANSIT_TIMES
WHERE WAREHOUSE_ID IS NOT NULL;

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_PINCODE_TRANSIT_TIME','Done');
END;

-------------------------------------------------------------------------------------------------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_STN_TRANSIT_TIMES','Loading Data');
END;

INSERT INTO SYS_FC_STN_TRANSIT_TIMES
(ID,WAREHOUSE_ID,STATION,STD_3P,FT_EXP,FT_NEXT,FT_SAME,STD,C_VERSION)
SELECT COL_ID,UPPER(TRIM(WAREHOUSE_ID)),UPPER(TRIM(STATION)) AS STATION,SP_ACTUAL,FT_EXP_ACTUAL,FT_NEXT_ACTUAL,FT_SAME_ACTUAL,STD_ACTUAL,vC_VERSION AS C_VERSION
FROM TEMP_SYS_FC_STN_TRANSIT_TIMES
WHERE WAREHOUSE_ID IS NOT NULL
AND STATION IS NOT NULL;

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_STN_TRANSIT_TIMES','Done');
END;

-------------------------------------------------------------------------------------------------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_ZIP_CONTRIBUTION','Loading Data');
END;

INSERT INTO SYS_FC_ZIP_CONTRIBUTION
(WAREHOUSE_ID,ZIPCODE,FT_SAME,FT_NEXT,FT_EXP,STD,C_VERSION)
SELECT UPPER(TRIM(WAREHOUSE_ID)),POSTALCODE,FT_SAME,FT_NEXT,FT_EXP,STD,vC_VERSION AS C_VERSION
FROM TEMP_FC_ZIPCODE_CONTRIBUTION
WHERE WAREHOUSE_ID IS NOT NULL;

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_FC_ZIP_CONTRIBUTION','Done');
END;

-------------------------------------------------------------------------------------------------------------------
--BEGIN
--   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_MFN_ZIP_CONTRIBUTION','Loading Data');
--END;

--INSERT INTO SYS_MFN_ZIP_CONTRIBUTION
--(ID,WAREHOUSE_ID,ZIPCODE,DEMANDTYPE,STD_CONTRIBUTION,C_VERSION)
--SELECT ROWNUM AS COL_ID,UPPER(TRIM(STATION)),POSTALCODE,UPPER(TRIM(DEMANDTYPE)),CONTRIBUTION,vC_VERSION AS C_VERSION
--FROM TEMP_SYS_MFN_CONTRIB
--WHERE STATION IS NOT NULL;

--BEGIN
--   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_MFN_ZIP_CONTRIBUTION','Done');
--END;

-------------------------------------------------------------------------------------------------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_MFN_ZIP_TRANSIT_TIMES','Loading Data');
END;

INSERT INTO SYS_MFN_ZIP_TRANSIT_TIMES
(COLID,WAREHOUSE_ID,ZIPCODE,MFN_CONFIG,C_VERSION)
SELECT ROWNUM AS COLID,UPPER(TRIM(WAREHOUSE_ID)),POSTALCODE,MFN_CONFIG,vC_VERSION AS C_VERSION
FROM TEMP_SYS_MFN_TRANSIT_TIME
WHERE WAREHOUSE_ID IS NOT NULL;

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_MFN_ZIP_TRANSIT_TIMES','Done');
END;

-------------------------------------------------------------------------------------------------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_STATION_PERFORMANCE','Loading Data');
END;


INSERT INTO SYS_STATION_PERFORMANCE
(STATION,ONTIMEDELIVERIES,COMMERCIALDELV,COMMERCIALDELVSUCCESS,DAYTYPE,C_VERSION,REJECTS)
SELECT ASSIGNED_STATION AS STATION,
       CASE WHEN SUM(OOR_PKGS)=0 THEN 0 ELSE SUM(Delivered)/SUM(OOR_PKGS) END AS ONTIMEDELIVERIES,
       CASE WHEN SUM(AT_STATION)=0 THEN 0 ELSE 1-(SUM(OOR_PKGS)/SUM(AT_STATION)) END AS COMMERCIALDELV,
       --CASE WHEN SUM(CASE WHEN CSO LIKE 'ATS_INJ_STD%' OR CSO LIKE 'ATS_INJ_EXP%' OR CSO LIKE 'ATS_MFN_STD%' THEN AT_STATION ELSE 0 END)=0 
       --THEN 0 ELSE 1-(SUM(CASE WHEN CSO LIKE 'ATS_INJ_STD%' OR CSO LIKE 'ATS_INJ_EXP%' OR CSO LIKE 'ATS_MFN_STD%' THEN OOR_PKGS ELSE 0 END)/SUM(CASE WHEN CSO LIKE 'ATS_INJ_STD%' OR CSO LIKE 'ATS_INJ_EXP%' OR CSO LIKE 'ATS_MFN_STD%' THEN AT_STATION ELSE 0 END)) END AS COMMERCIALDELV,
       1 AS COMMERCIALDELVSUCCESS,
       TRIM(TO_CHAR(RefDate,'Day')) AS DAYTYPE,
       vC_VERSION AS C_VERSION,
       CASE WHEN CASE WHEN SUM(OOR_PKGS)=0 THEN 0 ELSE SUM(Rejected)/SUM(OOR_PKGS) END > 0.3
            THEN 0 ELSE CASE WHEN SUM(OOR_PKGS)=0 THEN 0 ELSE SUM(Rejected)/SUM(OOR_PKGS) END END AS REJECTS
FROM TEMP_SYS_STATION_PERFORMANCE
 --(SELECT c.RefDate,
 --       e.ASSIGNED_STATION,
 --       count(distinct CASE WHEN trunc(RefDate) >= trunc(AT_STATION) then e.TRACKING_ID else null end) as AT_STATION_PKGS,
 --       COUNT(distinct CASE WHEN trunc(RefDate) = trunc(oor_dt) then e.TRACKING_ID else null end) as OOR_PKGS,
 --       COUNT(distinct CASE WHEN trunc(RefDate) = trunc(del_date) then e.TRACKING_ID else null end) as Delivered,
 --       COUNT(distinct CASE WHEN trunc(RefDate) = trunc(rej_undel) then e.TRACKING_ID else null end) as Rejects
 /*FROM (Select TRUNC(SCAN_DATE) as RefDate,
            TRIM(TO_CHAR(SCAN_DATE,'Day')) as DayType
     From TEMP_SYS_STATION_PERFORMANCE
     WHERE TRUNC(SCAN_DATE) BETWEEN vSTART_DATE AND vEND_DATE
     group by TRUNC(SCAN_DATE),
            TRIM(TO_CHAR(SCAN_DATE,'Day'))) c
 left join TEMP_SYS_STATION_PERFORMANCE e
 on c.RefDate between TRUNC(case when CSO LIKE '%111%' OR CSO LIKE '%SAME%' OR CSO LIKE '%NEXT%' OR CSO LIKE '%EXP%'  then e.scan_date + 6/24 else e.scan_date + 10/24 end) 
                      and trunc(NVL(NVL(FINAL_DEL_DONE,del_date),NVL(rej_undel,NVL(oor_dt,case when CSO LIKE '%111%' OR CSO LIKE '%SAME%' OR CSO LIKE '%NEXT%' OR CSO LIKE '%EXP%' then e.scan_date + 6/24 else e.scan_date + 10/24 end))))
 */
 --FROM (SELECT REFDATE
 --      FROM SYS_CALENDAR
 --      WHERE REFDATE BETWEEN vSTART_DATE AND vEND_DATE
 --      GROUP BY REFDATE) C
 --LEFT JOIN TEMP_SYS_STATION_PERFORMANCE E
 --on C.REFDATE BETWEEN E.MIN_DATE AND E.MAX_DATE
 --WHERE E.ASSIGNED_STATION NOT LIKE '%DEPRECATED%'
 --GROUP BY c.RefDate,
 --       e.ASSIGNED_STATION)
WHERE ASSIGNED_STATION IS NOT NULL
GROUP BY ASSIGNED_STATION,TRIM(TO_CHAR(RefDate,'Day')),1,vC_VERSION;


BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_STATION_PERFORMANCE','Done');
END;

-------------------------------------------------------------------------------------------------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_STN_ZIP_MAPPING_ACT','Loading Data');
END;

INSERT INTO SYS_STN_ZIP_MAPPING_ACT
(COL_ID,ZIPCODE,STATION,SHIP_METHOD,PACKAGE_TYPE,RATIO,C_VERSION)
SELECT ROWNUM AS COL_ID,POSTALCODE,UPPER(TRIM(STATION)),UPPER(TRIM(SHIP_METHOD)),PACKAGE_TYPE,CONTRIB,vC_VERSION AS C_VERSION
FROM TEMP_SYS_STN_ZIP_MAPPING
WHERE STATION IS NOT NULL;

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_STN_ZIP_MAPPING_ACT','Done');
END;

-------------------------------------------------------------------------------------------------------------------
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_ZIPCODE_LS_CONTRIBUTION','Loading Data');
END;

INSERT INTO SYS_ZIPCODE_LS_CONTRIBUTION
(ID,ZIPCODE,SHIP_METHOD,PACKAGE_TYPE,CONTRIBUTION,C_VERSION)
SELECT ROWNUM AS ID
       ,POSTALCODE
       ,UPPER(TRIM(SHIP_METHOD)) AS SHIP_METHOD
       ,M.ID AS PACKAGE_TYPE
       ,SHIPMENTS/SUM(SHIPMENTS) OVER (PARTITION BY POSTALCODE,UPPER(TRIM(SHIP_METHOD))) AS CONTRIBUTION
       ,vC_VERSION AS C_VERSION
FROM TEMP_SYS_ZIPCODE_LS_MAPPING T
LEFT JOIN SYS_MAPPING_TYPE_MASTER M
ON UPPER(TRIM(T.PACKAGE_TYPE)) = UPPER(TRIM(M.NAME))
WHERE POSTALCODE IS NOT NULL;

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_ZIPCODE_LS_CONTRIBUTION','Done');
END;

/*Added for Station Performance and MFN Contribution*/
BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_MFN_ZIP_CONTRIBUTION','Loading Data');
END;

INSERT INTO SYS_MFN_STN_CONTRIBUTION
SELECT ROWNUM AS ROW_ID,STATION,DAYTYPE,CASE WHEN AFN_VOL=0 THEN 0 ELSE MFN_VOL/AFN_VOL END AS MFN_CONTRIB,vC_VERSION AS C_VERSION
FROM
(SELECT TRIM(TO_CHAR(RefDate,'Day')) AS DAYTYPE
      ,ASSIGNED_STATION AS STATION
      ,SUM(CASE WHEN CSO='AFN' THEN OOR_PKGS ELSE 0 END) AS AFN_VOL 
      ,SUM(CASE WHEN CSO='MFN' THEN OOR_PKGS ELSE 0 END) AS MFN_VOL 
FROM (SELECT REFDATE,ASSIGNED_STATION,CASE WHEN CSO LIKE '%MFN%' THEN 'MFN' ELSE 'AFN' END AS CSO,OOR_PKGS
FROM TEMP_SYS_STATION_PERFORMANCE)
--(
-- SELECT c.RefDate,
--        CASE WHEN e.CSO LIKE '%MFN%' THEN 'MFN' ELSE 'AFN' END AS CSO,
--        e.ASSIGNED_STATION,
--        count(distinct CASE WHEN trunc(RefDate) >= trunc(AT_STATION) then e.TRACKING_ID else null end) as AT_STATION_PKGS,
--        COUNT(distinct CASE WHEN trunc(RefDate) = trunc(oor_dt) then e.TRACKING_ID else null end) as OOR_PKGS,
--        COUNT(distinct CASE WHEN trunc(RefDate) = trunc(del_date) then e.TRACKING_ID else null end) as Delivered
/*FROM        
 (Select TRUNC(SCAN_DATE) as RefDate,
            TRIM(TO_CHAR(SCAN_DATE,'Day')) as DayType
     From TEMP_SYS_STATION_PERFORMANCE
     WHERE TRUNC(SCAN_DATE) BETWEEN vSTART_DATE AND vEND_DATE
     group by TRUNC(SCAN_DATE),
            TRIM(TO_CHAR(SCAN_DATE,'Day'))) c
 left join TEMP_SYS_STATION_PERFORMANCE e
 on c.RefDate between TRUNC(case when CSO LIKE '%111%' OR CSO LIKE '%SAME%' OR CSO LIKE '%NEXT%' OR CSO LIKE '%EXP%'  then e.scan_date + 6/24 else e.scan_date + 10/24 end) 
                      and trunc(NVL(NVL(FINAL_DEL_DONE,del_date),NVL(rej_undel,NVL(oor_dt,case when CSO LIKE '%111%' OR CSO LIKE '%SAME%' OR CSO LIKE '%NEXT%' OR CSO LIKE '%EXP%' then e.scan_date + 6/24 else e.scan_date + 10/24 end))))
 WHERE E.ASSIGNED_STATION NOT LIKE '%DEPRECATED%'
 */
-- FROM (SELECT REFDATE
--       FROM SYS_CALENDAR
--       WHERE REFDATE BETWEEN vSTART_DATE AND vEND_DATE
--       GROUP BY REFDATE) C
-- LEFT JOIN TEMP_SYS_STATION_PERFORMANCE E
-- on C.REFDATE BETWEEN E.MIN_DATE AND E.MAX_DATE
-- WHERE E.ASSIGNED_STATION NOT LIKE '%DEPRECATED%'
-- GROUP BY c.RefDate,
--        CASE WHEN e.CSO LIKE '%MFN%' THEN 'MFN' ELSE 'AFN' END,
--        e.ASSIGNED_STATION)
GROUP BY TRIM(TO_CHAR(RefDate,'Day')),
ASSIGNED_STATION)
WHERE STATION NOT LIKE '%DEPRECATED%' ;

BEGIN
   USP_UP_VERSION_STATUS (vC_VERSION,'SYS_MFN_ZIP_CONTRIBUTION','Done');
END;

-----------------------Successful Status Update------------------
    UPDATE SYS_CONFIG_RUN_QUEUE
    SET IS_ACTIVE = 4
    WHERE IS_ACTIVE = 1
    AND C_VERSION = vC_VERSION;


COMMIT;

ELSE 

dbms_output.put_line('Failed');
dbms_output.put_line('for....' || vERROR_TABLE);

UPDATE LOG_VERSION_STATUS
    SET EXECUTION_STATUS = 'Data missing in staging..',
      LAST_UPDATED = SYSDATE
    WHERE C_VERSION = vC_VERSION
    AND EXECUTION_STATUS in ('Loading Data','Query Running','Staging Created');
    
    UPDATE SYS_CONFIG_RUN_QUEUE
    SET IS_ACTIVE = 3
    WHERE IS_ACTIVE = 1
    AND C_VERSION = vC_VERSION;

END IF;

--------------------------------------------------------Populate entries in the history table-------------------------------------------
BEGIN
  USP_IN_VERSION_HISTORY;
END;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    UPDATE LOG_VERSION_STATUS
    SET EXECUTION_STATUS = 'Failed',
      LAST_UPDATED = SYSDATE
    WHERE C_VERSION = vC_VERSION
    AND EXECUTION_STATUS in ('Loading Data','Query Running');
    
    UPDATE SYS_CONFIG_RUN_QUEUE
    SET IS_ACTIVE = 2
    WHERE IS_ACTIVE = 1
    AND C_VERSION = vC_VERSION;
    
    COMMIT;

END;