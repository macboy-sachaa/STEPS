create or replace PROCEDURE USP_SYS_FC_STN_TRANSIT_TIMES(vSTARTDATE DATE, vENDDATE DATE) AS 
BEGIN

EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_SYS_FC_STN_TRANSIT_TIMES DROP STORAGE';
COMMIT;


/*
  INSERT INTO TEMP_SYS_FC_STN_TRANSIT_TIMES
  SELECT rownum as Col_ID,
      Warehouse_id,
      STATION,
      SP_Actual,
      FT_Same_Actual,
      FT_Next_Actual,
      FT_Exp_Actual,
      Injections_Actual,
      STD_Actual
      from
(      
Select Warehouse_id,
      STATION,
      AVG(CASE WHEN Type_CATEGORY ='3P' then NVL(ActualTransitTime,0) end) as SP_Actual,
      AVG(CASE WHEN Type_CATEGORY ='FT_Same' then NVL(ActualTransitTime,0) end) as FT_Same_Actual,
      AVG(CASE WHEN Type_CATEGORY ='FT_Next' then NVL(ActualTransitTime,0) end) as FT_Next_Actual,
      AVG(CASE WHEN Type_CATEGORY ='FT_Exp' then NVL(ActualTransitTime,0) end) as FT_Exp_Actual,
      AVG(CASE WHEN Type_CATEGORY ='Injection' then NVL(ActualTransitTime,0) end) as Injections_Actual,
      AVG(CASE WHEN Type_CATEGORY ='STD' then NVL(ActualTransitTime,0) end) as STD_Actual
      from (Select warehouse_ID,STATION,Config_Transit_Time,Type_CATEGORY,ActualTransitTime
  FROM
  ( Select AVG((trunc(dosp.ESTIMATED_ARRIVAL_DATETIME) - trunc(dosp.PROMISED_SHIP_DATETIME +5.5/24)))  AS Config_Transit_Time
          ,AVG(trunc(dosp.CLOCK_STOP_EVENT_DATETIME)-trunc(dosp.SHIP_DATETIME)) AS ActualTransitTime
          ,dosp.warehouse_ID
          ,UPPER(CASE WHEN INSTR(SUBSTR(dosp.CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(dosp.CARRIER_ZONE,-4) END) AS STATION
          ,CASE WHEN dosp.SHIP_METHOD = 'ATS_INJ_111' THEN 'FT_Same'
                WHEN dosp.SHIP_METHOD = 'ATS_INJ_111_COD' THEN 'FT_Same'
                WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME' THEN 'FT_Same'
                WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME_COD' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT_COD' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP_COD' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD_COD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD_COD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'AMX_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP_COD' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'ATS_IPS_MFN_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_SC_STD' THEN 'Injection'
    ELSE '3P' END AS Type_CATEGORY
       FROM D_OUTBOUND_SHIPMENT_PACKAGES@DW7 DOSP
       INNER JOIN INSCSPLITS_DDL.D_WAREHOUSES_SUMMARY@DW7 W 
       ON DOSP.WAREHOUSE_ID= W.WAREHOUSE_ID
       WHERE dosp.ship_day BETWEEN vSTARTDATE AND vENDDATE
  AND DOSP.REGION_ID = 4
  AND DOSP.LEGAL_ENTITY_ID = 131
  AND DOSP.SHIP_METHOD <>'MERCHANT'
  AND DOSP.SHIP_METHOD NOT LIKE '%MFN%'
  AND DOSP.SHIPMENT_SHIP_OPTION <> 'vendor-returns'
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
  AND  CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) is not null
 GROUP BY 
 dosp.warehouse_ID
,UPPER(CASE WHEN INSTR(SUBSTR(dosp.CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(dosp.CARRIER_ZONE,-4) END)
,CASE WHEN dosp.SHIP_METHOD = 'ATS_INJ_111' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_111_COD' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME_COD' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT_COD' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP_COD' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD_COD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD_COD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'AMX_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP_COD' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'ATS_IPS_MFN_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_SC_STD' THEN 'Injection'
    ELSE '3P' END) A 
  where Type_CATEGORY <> '3P') TTTable
      group by Warehouse_id,STATION)
      order by Warehouse_id,STATION;

*/
------------------------------------------Updated W.R.T DOSP Local Dump----------------------------------------------    

  INSERT INTO TEMP_SYS_FC_STN_TRANSIT_TIMES
  SELECT rownum as Col_ID,
      Warehouse_id,
      STATION,
      SP_Actual,
      FT_Same_Actual,
      FT_Next_Actual,
      FT_Exp_Actual,
      Injections_Actual,
      STD_Actual
      from
(      
Select Warehouse_id,
      STATION,
      AVG(CASE WHEN Type_CATEGORY ='3P' then NVL(ActualTransitTime,0) end) as SP_Actual,
      AVG(CASE WHEN Type_CATEGORY ='FT_Same' then NVL(ActualTransitTime,0) end) as FT_Same_Actual,
      AVG(CASE WHEN Type_CATEGORY ='FT_Next' then NVL(ActualTransitTime,0) end) as FT_Next_Actual,
      AVG(CASE WHEN Type_CATEGORY ='FT_Exp' then NVL(ActualTransitTime,0) end) as FT_Exp_Actual,
      AVG(CASE WHEN Type_CATEGORY ='Injection' then NVL(ActualTransitTime,0) end) as Injections_Actual,
      AVG(CASE WHEN Type_CATEGORY ='STD' then NVL(ActualTransitTime,0) end) as STD_Actual
      from (Select warehouse_ID,STATION,Config_Transit_Time,Type_CATEGORY,ActualTransitTime
  FROM
  ( Select AVG((trunc(dosp.ESTIMATED_ARRIVAL_DATETIME) - trunc(dosp.PROMISED_SHIP_DATETIME +5.5/24)))  AS Config_Transit_Time
          ,AVG(trunc(dosp.CLOCK_STOP_EVENT_DATETIME)-trunc(dosp.SHIP_DATETIME)) AS ActualTransitTime
          ,dosp.warehouse_ID
          ,UPPER(CASE WHEN INSTR(SUBSTR(dosp.CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(dosp.CARRIER_ZONE,-4) END) AS STATION
          ,CASE WHEN dosp.SHIP_METHOD = 'ATS_INJ_111' THEN 'FT_Same'
                WHEN dosp.SHIP_METHOD = 'ATS_INJ_111_COD' THEN 'FT_Same'
                WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME' THEN 'FT_Same'
                WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME_COD' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT_COD' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP_COD' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD_COD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD_COD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'AMX_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP_COD' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'ATS_IPS_MFN_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_SC_STD' THEN 'Injection'
    ELSE '3P' END AS Type_CATEGORY
       FROM DUMP_DW_DOSP_DATA DOSP
       INNER JOIN INSCSPLITS_DDL.D_WAREHOUSES_SUMMARY@DW7 W 
       ON DOSP.WAREHOUSE_ID= W.WAREHOUSE_ID
       WHERE dosp.ship_day BETWEEN vSTARTDATE AND vENDDATE
  AND DOSP.REGION_ID = 4
  AND DOSP.SHIP_METHOD <>'MERCHANT'
  AND DOSP.SHIP_METHOD NOT LIKE '%MFN%'
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
  AND  CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) is not null
 GROUP BY 
 dosp.warehouse_ID
,UPPER(CASE WHEN INSTR(SUBSTR(dosp.CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(dosp.CARRIER_ZONE,-4) END)
,CASE WHEN dosp.SHIP_METHOD = 'ATS_INJ_111' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_111_COD' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_SAME_COD' THEN 'FT_Same'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_NEXT_COD' THEN 'FT_Next'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_EXP_COD' THEN 'FT_Exp'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD_COD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_INJ_STD' THEN 'STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'ATS_MFN_STD_COD' THEN 'MFN_STD'
    WHEN dosp.SHIP_METHOD = 'AMX_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_ATS_EXP_COD' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'ATS_IPS_MFN_EXP' THEN 'Injection'
    WHEN dosp.SHIP_METHOD = 'IPS_SC_STD' THEN 'Injection'
    ELSE '3P' END) A 
  where Type_CATEGORY <> '3P') TTTable
      group by Warehouse_id,STATION)
      order by Warehouse_id,STATION;


COMMIT;

END USP_SYS_FC_STN_TRANSIT_TIMES;