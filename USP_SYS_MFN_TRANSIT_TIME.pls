create or replace PROCEDURE USP_SYS_MFN_TRANSIT_TIME (vSTARTDATE DATE,vENDDATE DATE) AS
BEGIN

EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_SYS_MFN_TRANSIT_TIME DROP STORAGE';
COMMIT;


/*INSERT INTO TEMP_SYS_MFN_TRANSIT_TIME
Select Warehouse_id,
      Postalcode,
      AVG(CASE WHEN Type_CATEGORY ='MFN_STD' then NVL(Config_Transit_Time,0) end) as MFN_Config
      from (Select warehouse_ID,Postalcode,Config_Transit_Time,Type_CATEGORY,ActualTransitTime
  FROM
  (Select AVG((dosp.ESTIMATED_ARRIVAL_DATETIME) - (dosp.EXPECTED_SHIP_DATETIME ))  AS Config_Transit_Time
         ,AVG(dosp.CLOCK_STOP_EVENT_DATETIME-(dosp.EXPECTED_SHIP_DATETIME + 5.5/24)) AS ActualTransitTime
         ,dosp.warehouse_ID
         ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) as Postalcode
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
       LEFT JOIN INSCSPLITS_DDL.D_WAREHOUSES_SUMMARY@DW7 W 
       ON DOSP.WAREHOUSE_ID= W.WAREHOUSE_ID
       WHERE dosp.ship_day BETWEEN vSTARTDATE AND vENDDATE
  AND DOSP.REGION_ID = 4
  AND DOSP.LEGAL_ENTITY_ID = 131
  AND DOSP.SHIP_METHOD <>'MERCHANT'
  AND DOSP.SHIP_METHOD LIKE '%MFN%'
  AND DOSP.SHIPMENT_SHIP_OPTION <> 'vendor-returns'
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
  AND W.WAREHOUSE_ID IS NULL
  AND  CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) is not null
 GROUP BY 
 dosp.warehouse_ID
,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT)
--,CAST(CONCAT(TO_CHAR(dosp.ship_day,'YYYY'),TO_CHAR(dosp.ship_day,'WW')) as INT)
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
    ELSE '3P' END) A ) TTTable
      group by Warehouse_id,Postalcode;
 */
 ---------------------------------------------------Updated W.R.T DOSP Local Dump ----------------------------------------------

INSERT INTO TEMP_SYS_MFN_TRANSIT_TIME
Select Warehouse_id,
      Postalcode,
      AVG(CASE WHEN Type_CATEGORY ='MFN_STD' then NVL(Config_Transit_Time,0) end) as MFN_Config
      from (Select warehouse_ID,Postalcode,Config_Transit_Time,Type_CATEGORY,ActualTransitTime
  FROM
  (Select AVG((dosp.ESTIMATED_ARRIVAL_DATETIME) - (dosp.EXPECTED_SHIP_DATETIME ))  AS Config_Transit_Time
         ,AVG(dosp.CLOCK_STOP_EVENT_DATETIME-(dosp.EXPECTED_SHIP_DATETIME + 5.5/24)) AS ActualTransitTime
         ,dosp.warehouse_ID
         ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) as Postalcode
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
       LEFT JOIN INSCSPLITS_DDL.D_WAREHOUSES_SUMMARY@DW7 W 
       ON DOSP.WAREHOUSE_ID= W.WAREHOUSE_ID
       WHERE dosp.ship_day BETWEEN vSTARTDATE AND vENDDATE
  AND DOSP.REGION_ID = 4
  AND DOSP.SHIP_METHOD <>'MERCHANT'
  AND DOSP.SHIP_METHOD LIKE '%MFN%'
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
  AND W.WAREHOUSE_ID IS NULL
  AND  CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) is not null
 GROUP BY 
 dosp.warehouse_ID
,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT)
--,CAST(CONCAT(TO_CHAR(dosp.ship_day,'YYYY'),TO_CHAR(dosp.ship_day,'WW')) as INT)
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
    ELSE '3P' END) A ) TTTable
      group by Warehouse_id,Postalcode;
 
 
 COMMIT;
 
 END;