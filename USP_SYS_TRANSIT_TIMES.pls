create or replace PROCEDURE USP_SYS_TRANSIT_TIMES(vSTART_DATE DATE,vEND_DATE DATE) AS 
BEGIN

EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_FC_PINCODE_TRANSIT_TIMES DROP STORAGE';
COMMIT;

/*
Insert Into TEMP_FC_PINCODE_TRANSIT_TIMES
(ID,Warehouse_id,
      Postalcode,
      SP_Config,
      FT_Same_Config,
      FT_Next_Config,
      FT_Exp_Config,
      Injections_Config,
      STD_Config,
      SP_Actual,
      FT_Same_Actual,
      FT_Next_Actual,
      FT_Exp_Actual,
      Injections_Actual,
      STD_Actual)
SELECT ROWNUM AS ID,Warehouse_id,
      Postalcode,
      NVL(SP_Config,15) AS SP_Config,
      NVL(FT_Same_Config,0) AS FT_Same_Config,
      NVL(FT_Next_Config,1) AS FT_Next_Config,
      NVL(FT_Exp_Config,2) AS FT_Exp_Config,
      NVL(Injections_Config,15) AS Injections_Config,
      NVL(STD_Config,4) AS STD_Config,
      NVL(SP_Actual,15) AS SP_Actual,
      --Changed as per SLA on 23-Feb
      CASE WHEN FT_Same_Actual > 1 THEN 1 ELSE NVL(FT_Same_Actual,0) END AS FT_Same_Actual,
      CASE WHEN FT_Next_Actual > 2 THEN 2 ELSE NVL(FT_Next_Actual,1) END AS FT_Next_Actual,
      CASE WHEN FT_Exp_Actual > 3 THEN 3 ELSE NVL(FT_Exp_Actual,2) END AS FT_Exp_Actual,
      NVL(Injections_Actual,15) AS Injections_Actual,
      NVL(STD_Actual,3.6) AS STD_Actual
      FROM 
        (Select 
              Warehouse_id,
              Postalcode,
              AVG(CASE WHEN Type_CATEGORY ='3P' then NVL(Config_Transit_Time,15) end) as SP_Config,
              AVG(CASE WHEN Type_CATEGORY ='FT_Same' then NVL(Config_Transit_Time,0) end) as FT_Same_Config,
              AVG(CASE WHEN Type_CATEGORY ='FT_Next' then NVL(Config_Transit_Time,1) end) as FT_Next_Config,
              AVG(CASE WHEN Type_CATEGORY ='FT_Exp' then NVL(Config_Transit_Time,2) end) as FT_Exp_Config,
              AVG(CASE WHEN Type_CATEGORY ='Injection' then NVL(Config_Transit_Time,10) end) as Injections_Config,
              AVG(CASE WHEN Type_CATEGORY ='STD' then NVL(Config_Transit_Time,3.5) end) as STD_Config,
              AVG(CASE WHEN Type_CATEGORY ='3P' then NVL(ActualTransitTime,15) end) as SP_Actual,
              AVG(CASE WHEN Type_CATEGORY ='FT_Same' then NVL(ActualTransitTime,0) end) as FT_Same_Actual,
              AVG(CASE WHEN Type_CATEGORY ='FT_Next' then NVL(ActualTransitTime,1) end) as FT_Next_Actual,
              AVG(CASE WHEN Type_CATEGORY ='FT_Exp' then NVL(ActualTransitTime,2) end) as FT_Exp_Actual,
              AVG(CASE WHEN Type_CATEGORY ='Injection' then NVL(ActualTransitTime,10) end) as Injections_Actual,
              AVG(CASE WHEN Type_CATEGORY ='STD' then NVL(ActualTransitTime,3.5) end) as STD_Actual
              from (Select warehouse_ID,Postalcode,Config_Transit_Time,Type_CATEGORY,ActualTransitTime
          FROM
          
          --  Taking difference of ESTIMATED_ARRIVAL_DATETIME AND EXPECTED_SHIP_DATETIME AS CONFIGURED TT
          --  and difference of CLOCK_STOP_EVENT_DATETIME AND EXPECTED_SHIP_DATETIME AS ACTUAL TT
          --  ALSO ADDED 5.5/24 TO EXPECTED_SHIP_DATETIME FOR CONVERTING TO IST AS  CLOCK_STOP_EVENT_DATETIME IS IN IST
          --  REFER:- https://w.amazon.com/index.php/Transportation/BITS/D%20OUTBOUND%20SHIPMENT%20ITEMS/D%20OUTBOUND%20SHIP%20ITEMS%20Columns 
          
          ( Select AVG(CASE WHEN (dosp.ESTIMATED_ARRIVAL_DATETIME - dosp.EXPECTED_SHIP_DATETIME) < 0 THEN NULL ELSE CASE WHEN (dosp.ESTIMATED_ARRIVAL_DATETIME - dosp.EXPECTED_SHIP_DATETIME) > 10 THEN 10 ELSE (dosp.ESTIMATED_ARRIVAL_DATETIME - dosp.EXPECTED_SHIP_DATETIME) END END)  AS Config_Transit_Time
                  ,AVG(CASE WHEN (dosp.CLOCK_STOP_EVENT_DATETIME - (dosp.EXPECTED_SHIP_DATETIME + 5.5/24)) < 0 THEN NULL ELSE CASE WHEN dosp.CLOCK_STOP_EVENT_DATETIME - (dosp.EXPECTED_SHIP_DATETIME + 5.5/24) > 10 THEN 10 ELSE dosp.CLOCK_STOP_EVENT_DATETIME-(dosp.EXPECTED_SHIP_DATETIME + 5.5/24) END END) AS ActualTransitTime
                  ,dosp.warehouse_ID
                  ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) as Postalcode
                  --,CAST(CONCAT(TO_CHAR(dosp.ship_day,'YYYY'),TO_CHAR(dosp.ship_day,'WW')) as INT) as Weekno
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
               WHERE dosp.ship_day BETWEEN vSTART_DATE AND vEND_DATE
          AND DOSP.REGION_ID = 4
          AND DOSP.LEGAL_ENTITY_ID = 131
          AND DOSP.SHIP_METHOD <>'MERCHANT'
          AND DOSP.SHIP_METHOD NOT LIKE '%MFN%'
          AND DOSP.SHIPMENT_SHIP_OPTION <> 'vendor-returns'
          AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
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
      group by Warehouse_id,Postalcode
      order by Warehouse_id,Postalcode) Q;    
*/

--------------------------------Updated W.R.T. DOSP Local Dump--------------------------

Insert Into TEMP_FC_PINCODE_TRANSIT_TIMES
(ID,Warehouse_id,
      Postalcode,
      SP_Config,
      FT_Same_Config,
      FT_Next_Config,
      FT_Exp_Config,
      Injections_Config,
      STD_Config,
      SP_Actual,
      FT_Same_Actual,
      FT_Next_Actual,
      FT_Exp_Actual,
      Injections_Actual,
      STD_Actual)
SELECT ROWNUM AS ID,Warehouse_id,
      Postalcode,
      NVL(SP_Config,15) AS SP_Config,
      NVL(FT_Same_Config,0) AS FT_Same_Config,
      NVL(FT_Next_Config,1) AS FT_Next_Config,
      NVL(FT_Exp_Config,2) AS FT_Exp_Config,
      NVL(Injections_Config,15) AS Injections_Config,
      NVL(STD_Config,4) AS STD_Config,
      NVL(SP_Actual,15) AS SP_Actual,
      --Changed as per SLA on 23-Feb
      CASE WHEN FT_Same_Actual > 1 THEN 1 ELSE NVL(FT_Same_Actual,0) END AS FT_Same_Actual,
      CASE WHEN FT_Next_Actual > 2 THEN 2 ELSE NVL(FT_Next_Actual,1) END AS FT_Next_Actual,
      CASE WHEN FT_Exp_Actual > 3 THEN 3 ELSE NVL(FT_Exp_Actual,2) END AS FT_Exp_Actual,
      NVL(Injections_Actual,15) AS Injections_Actual,
      NVL(STD_Actual,3.6) AS STD_Actual
      FROM 
        (Select 
              Warehouse_id,
              Postalcode,
              AVG(CASE WHEN Type_CATEGORY ='3P' then NVL(Config_Transit_Time,15) end) as SP_Config,
              AVG(CASE WHEN Type_CATEGORY ='FT_Same' then NVL(Config_Transit_Time,0) end) as FT_Same_Config,
              AVG(CASE WHEN Type_CATEGORY ='FT_Next' then NVL(Config_Transit_Time,1) end) as FT_Next_Config,
              AVG(CASE WHEN Type_CATEGORY ='FT_Exp' then NVL(Config_Transit_Time,2) end) as FT_Exp_Config,
              AVG(CASE WHEN Type_CATEGORY ='Injection' then NVL(Config_Transit_Time,10) end) as Injections_Config,
              AVG(CASE WHEN Type_CATEGORY ='STD' then NVL(Config_Transit_Time,3.5) end) as STD_Config,
              AVG(CASE WHEN Type_CATEGORY ='3P' then NVL(ActualTransitTime,15) end) as SP_Actual,
              AVG(CASE WHEN Type_CATEGORY ='FT_Same' then NVL(ActualTransitTime,0) end) as FT_Same_Actual,
              AVG(CASE WHEN Type_CATEGORY ='FT_Next' then NVL(ActualTransitTime,1) end) as FT_Next_Actual,
              AVG(CASE WHEN Type_CATEGORY ='FT_Exp' then NVL(ActualTransitTime,2) end) as FT_Exp_Actual,
              AVG(CASE WHEN Type_CATEGORY ='Injection' then NVL(ActualTransitTime,10) end) as Injections_Actual,
              AVG(CASE WHEN Type_CATEGORY ='STD' then NVL(ActualTransitTime,3.5) end) as STD_Actual
              from (Select warehouse_ID,Postalcode,Config_Transit_Time,Type_CATEGORY,ActualTransitTime
          FROM
          
          --  Taking difference of ESTIMATED_ARRIVAL_DATETIME AND EXPECTED_SHIP_DATETIME AS CONFIGURED TT
          --  and difference of CLOCK_STOP_EVENT_DATETIME AND EXPECTED_SHIP_DATETIME AS ACTUAL TT
          --  ALSO ADDED 5.5/24 TO EXPECTED_SHIP_DATETIME FOR CONVERTING TO IST AS  CLOCK_STOP_EVENT_DATETIME IS IN IST
          --  REFER:- https://w.amazon.com/index.php/Transportation/BITS/D%20OUTBOUND%20SHIPMENT%20ITEMS/D%20OUTBOUND%20SHIP%20ITEMS%20Columns 
          
          ( Select AVG(CASE WHEN (dosp.ESTIMATED_ARRIVAL_DATETIME - dosp.EXPECTED_SHIP_DATETIME) < 0 THEN NULL ELSE CASE WHEN (dosp.ESTIMATED_ARRIVAL_DATETIME - dosp.EXPECTED_SHIP_DATETIME) > 10 THEN 10 ELSE (dosp.ESTIMATED_ARRIVAL_DATETIME - dosp.EXPECTED_SHIP_DATETIME) END END)  AS Config_Transit_Time
                  ,AVG(CASE WHEN (dosp.CLOCK_STOP_EVENT_DATETIME - (dosp.EXPECTED_SHIP_DATETIME + 5.5/24)) < 0 THEN NULL ELSE CASE WHEN dosp.CLOCK_STOP_EVENT_DATETIME - (dosp.EXPECTED_SHIP_DATETIME + 5.5/24) > 10 THEN 10 ELSE dosp.CLOCK_STOP_EVENT_DATETIME-(dosp.EXPECTED_SHIP_DATETIME + 5.5/24) END END) AS ActualTransitTime
                  ,dosp.warehouse_ID
                  ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) as Postalcode
                  --,CAST(CONCAT(TO_CHAR(dosp.ship_day,'YYYY'),TO_CHAR(dosp.ship_day,'WW')) as INT) as Weekno
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
               WHERE dosp.ship_day BETWEEN vSTART_DATE AND vEND_DATE
          AND DOSP.REGION_ID = 4
          AND DOSP.SHIP_METHOD <>'MERCHANT'
          AND DOSP.SHIP_METHOD NOT LIKE '%MFN%'
          AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
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
      group by Warehouse_id,Postalcode
      order by Warehouse_id,Postalcode) Q;

COMMIT;

END;