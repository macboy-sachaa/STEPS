create or replace PROCEDURE USP_SYS_STN_ZIP_MAPPING(vSTARTDATE DATE,vENDDATE DATE) AS 
BEGIN

EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_SYS_STN_ZIP_MAPPING DROP STORAGE';
COMMIT;
  
/*INSERT INTO TEMP_SYS_STN_ZIP_MAPPING 
SELECT Station,Postalcode,Ship_method,Package_type,shipments,shipments/sum(shipments) over (partition by Postalcode,Ship_method,Package_type) as contrib
from
(SELECT  Station,Postalcode,Ship_method,Package_type,shipments,shipments/sum(shipments) over (partition by Postalcode,Ship_method,Package_type) as contr
FROM
(Select UPPER(CASE WHEN INSTR(SUBSTR(CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(CARRIER_ZONE,-4) END) as Station
      ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) as Postalcode
      ,CASE WHEN SHIP_METHOD LIKE '%SAME%' OR SHIP_METHOD LIKE '%_111%' THEN 'SAME'
            WHEN SHIP_METHOD LIKE '%NEXT%' THEN 'NEXT'
            WHEN SHIP_METHOD LIKE '%EXP%' THEN 'EXP'
            WHEN SHIP_METHOD LIKE '%STD%' THEN 'STD'
            ELSE 'OTHERS' END AS SHIP_METHOD
      ,CASE when SCALE_WEIGHT>2 or (PKG_LENGTH*PKG_WIDTH*PKG_HEIGHT)>9000 THEN '3' ELSE '2' END as Package_Type
      ,count(distinct fulfillment_shipment_id) AS SHIPMENTS
       FROM D_OUTBOUND_SHIPMENT_PACKAGES@DW7 dosp
       WHERE dosp.ship_day BETWEEN vSTARTDATE AND vENDDATE
  AND DOSP.REGION_ID = 4
  AND DOSP.LEGAL_ENTITY_ID = 131
  AND SHIP_METHOD  not in ('MERCHANT','DP_PAKET')
  AND SHIP_METHOD LIKE ('ATS_INJ%')
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL  
 GROUP BY UPPER(CASE WHEN INSTR(SUBSTR(CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(CARRIER_ZONE,-4) END)
         ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT)
         ,CASE when SCALE_WEIGHT>2 or (PKG_LENGTH*PKG_WIDTH*PKG_HEIGHT)>9000 THEN '3' ELSE '2' END
         ,CASE WHEN SHIP_METHOD LIKE '%SAME%' OR SHIP_METHOD LIKE '%_111%' THEN 'SAME'
            WHEN SHIP_METHOD LIKE '%NEXT%' THEN 'NEXT'
            WHEN SHIP_METHOD LIKE '%EXP%' THEN 'EXP'
            WHEN SHIP_METHOD LIKE '%STD%' THEN 'STD'
            ELSE 'OTHERS' END))
where contr > 0.05;
*/

------------------------------Updated W.R.T. DOSP Local Dump----------------------------

INSERT INTO TEMP_SYS_STN_ZIP_MAPPING 
SELECT Station,Postalcode,Ship_method,Package_type,shipments,shipments/sum(shipments) over (partition by Postalcode,Ship_method,Package_type) as contrib
from
(SELECT  Station,Postalcode,Ship_method,Package_type,shipments,shipments/sum(shipments) over (partition by Postalcode,Ship_method,Package_type) as contr
FROM
(Select UPPER(CASE WHEN INSTR(SUBSTR(CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(CARRIER_ZONE,-4) END) as Station
      ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) as Postalcode
      ,CASE WHEN SHIP_METHOD LIKE '%SAME%' OR SHIP_METHOD LIKE '%_111%' THEN 'SAME'
            WHEN SHIP_METHOD LIKE '%NEXT%' THEN 'NEXT'
            WHEN SHIP_METHOD LIKE '%EXP%' THEN 'EXP'
            WHEN SHIP_METHOD LIKE '%STD%' THEN 'STD'
            ELSE 'OTHERS' END AS SHIP_METHOD
      ,CASE when SCALE_WEIGHT>2 or (PKG_LENGTH*PKG_WIDTH*PKG_HEIGHT)>9000 THEN '3' ELSE '2' END as Package_Type
      ,count(distinct fulfillment_shipment_id) AS SHIPMENTS
       FROM DUMP_DW_DOSP_DATA dosp
       WHERE dosp.ship_day BETWEEN vSTARTDATE AND vENDDATE
  AND DOSP.REGION_ID = 4
  AND SHIP_METHOD  not in ('MERCHANT','DP_PAKET')
  AND SHIP_METHOD LIKE ('ATS_INJ%')
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL  
 GROUP BY UPPER(CASE WHEN INSTR(SUBSTR(CARRIER_ZONE,-4),'_')>0 THEN '3P' ELSE SUBSTR(CARRIER_ZONE,-4) END)
         ,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT)
         ,CASE when SCALE_WEIGHT>2 or (PKG_LENGTH*PKG_WIDTH*PKG_HEIGHT)>9000 THEN '3' ELSE '2' END
         ,CASE WHEN SHIP_METHOD LIKE '%SAME%' OR SHIP_METHOD LIKE '%_111%' THEN 'SAME'
            WHEN SHIP_METHOD LIKE '%NEXT%' THEN 'NEXT'
            WHEN SHIP_METHOD LIKE '%EXP%' THEN 'EXP'
            WHEN SHIP_METHOD LIKE '%STD%' THEN 'STD'
            ELSE 'OTHERS' END))
where contr > 0.05;



COMMIT;

END USP_SYS_STN_ZIP_MAPPING;