create or replace PROCEDURE USP_LOAD_SHIPOUT_ACTUALS(vSTARTDATE DATE,vENDDATE DATE) AS 
vSTART_DATE DATE;
vEND_DATE DATE;
BEGIN

DELETE FROM SYS_FC_SHIPOUT_ACTUALS
WHERE SHIPOUT_DATE BETWEEN vSTARTDATE AND vENDDATE;


INSERT INTO SYS_FC_SHIPOUT_ACTUALS
SELECT B.SHIPOUT_DATE,
       B.WAREHOUSE_ID,
       B.STD_SHIPOUT,
       B.FT_SHIPOUT
FROM 
    (
    SELECT 
           TRUNC(RefDate) as SHIPOUT_DATE,
           TRIM(UPPER(WAREHOUSE_ID)) AS WAREHOUSE_ID,
           SUM(CASE WHEN UPPER(TRIM(ShipMethod_Cat)) <> 'FT' AND UPPER(TRIM(ShipMethod_Cat)) <> 'MFN_STD' THEN Shipments ELSE 0 END) AS STD_SHIPOUT,
           SUM(CASE WHEN ShipMethod_Cat = 'FT' THEN Shipments ELSE 0 END) AS FT_SHIPOUT
    FROM
        (
        SELECT dosp.warehouse_ID
               ,dosp.SHIP_DAY as RefDate
              ,CASE WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_111' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_111_COD' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_SAME' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_SAME_COD' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_NEXT' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_NEXT_COD' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_EXP' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_EXP_COD' THEN 'FT'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_STD_COD' THEN 'FBA_STD'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_STD' THEN 'FBA_STD'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'AMX_ATS_EXP' THEN 'ARAMEX Injection'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_IPS_MFN_EXP' THEN 'IPS_MFN Injection'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'IPS_ATS_EXP' THEN 'IPS_AFN Injection'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'IPS_ATS_EXP_COD' THEN 'IPS_AFN Injection'
                    WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_MFN%' THEN 'MFN_STD'
                    ELSE 'Other_STD' END as ShipMethod_Cat
              --,CASE WHEN M.STATION IS NULL THEN 'No Coverage' ELSE UPPER(M.STATION) END AS CONFIGUREDSTATION
              --,CUSTOMER_SHIP_OPTION
              --,CASE WHEN UPPER(CASE WHEN INSTR(SUBSTR(CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(CARRIER_ZONE,-4) END)='3P' then NVL(chd.node_id,UPPER(CASE WHEN INSTR(SUBSTR(CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(CARRIER_ZONE,-4) END)) else NVL(UPPER(CASE WHEN INSTR(SUBSTR(CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(CARRIER_ZONE,-4) END),chd.node_id) end as ActualStation
              --,CASE WHEN SCALE_WEIGHT>2 or (PKG_LENGTH*PKG_WIDTH*PKG_HEIGHT)>9000 THEN 'LARGE' ELSE 'SMALL' END as Package_Type
              --,SUM(UNIT_COUNT) as Shipped_Units
              ,COUNT(DISTINCT Fulfillment_shipment_id) as Shipments
        FROM DUMP_DW_DOSP_DATA DOSP 
              inner join SYS_WAREHOUSE_MASTER w
              on UPPER(TRIM(dosp.warehouse_ID))=UPPER(TRIM(w.warehouse_ID))
        WHERE REGION_ID=4
               AND SHIP_DAY BETWEEN vSTARTDATE AND vENDDATE
               AND SHIP_METHOD  not in ('MERCHANT','DP_PAKET')
               AND W.TYPE_ID IN (1,2,6)
        GROUP BY dosp.warehouse_ID
                ,dosp.SHIP_DAY
                ,CASE WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_111' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_111_COD' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_SAME' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_SAME_COD' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_NEXT' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_NEXT_COD' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_EXP' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_EXP_COD' THEN 'FT'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_STD_COD' THEN 'FBA_STD'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_INJ_STD' THEN 'FBA_STD'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'AMX_ATS_EXP' THEN 'ARAMEX Injection'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_IPS_MFN_EXP' THEN 'IPS_MFN Injection'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'IPS_ATS_EXP' THEN 'IPS_AFN Injection'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'IPS_ATS_EXP_COD' THEN 'IPS_AFN Injection'
                      WHEN UPPER(TRIM(dosp.SHIP_METHOD)) = 'ATS_MFN%' THEN 'MFN_STD'
                      ELSE 'Other_STD' END
        ORDER BY dosp.warehouse_ID
                ,dosp.SHIP_DAY            
        ) AA
    GROUP BY 
       TRUNC(RefDate),
       TRIM(UPPER(WAREHOUSE_ID))
        )B
ORDER BY 
  B.WAREHOUSE_ID, 
  B.SHIPOUT_DATE;

COMMIT;

END USP_LOAD_SHIPOUT_ACTUALS;