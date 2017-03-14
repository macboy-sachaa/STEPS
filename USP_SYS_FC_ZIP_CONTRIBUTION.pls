create or replace PROCEDURE USP_SYS_FC_ZIP_CONTRIBUTION(vSTART_DATE DATE,vEND_DATE DATE) AS 
BEGIN

  EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_FC_ZIPCODE_CONTRIBUTION DROP STORAGE';
  COMMIT;


/* INSERT INTO TEMP_FC_ZIPCODE_CONTRIBUTION
 SELECT ROWNUM AS ROW_ID,warehouse_id,Postalcode,FT_Same,FT_Next,FT_Exp,STD
  FROM
  ( SELECT warehouse_id,
       Postalcode,
       SUM(case when Shipper = 'FT_Same' then Contrib else 0 end) as FT_Same,
       SUM(case when Shipper = 'FT_Next' then Contrib else 0 end) as FT_Next,
       SUM(case when Shipper = 'FT_Exp' then Contrib else 0 end) as FT_Exp,
       SUM(case when Shipper = 'STD' then Contrib else 0 end) as STD
from
(Select warehouse_id,Postalcode,Shipper,Shipped,shipped/SUM(shipped) over (partition by warehouse_id,CASE WHEN Shipper = 'STD' THEN 'STD' ELSE 'FT' END ) as Contrib 
from 
(Select dosp.warehouse_ID
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
    WHEN dosp.SHIP_METHOD like '%_MFN%' THEN 'STD'
    else 'STD' END as Shipper
,count(distinct Fulfillment_shipment_id) as Shipped
       FROM D_OUTBOUND_SHIPMENT_PACKAGES@DW8 DOSP 
       WHERE dosp.ship_day BETWEEN vSTART_DATE and vEND_DATE
	AND DOSP.REGION_ID = 4
  AND dosp.SHIP_METHOD NOT like '%_MFN%'
	AND SHIP_METHOD  not in ('MERCHANT','DP_PAKET')
 AND SHIPMENT_SHIP_OPTION IN ('bulky-standard-in',
'exp-in-cod-eligible',
'next-in-cod-eligible',
'next-in-pantry',
'same-in-am',
'same-in-cod-eligible',
'scheduled-delivery-in',
'std-in',
'std-in-10k',
'std-in-50k',
'std-in-cod-eligible',
'std-in-cod-eligible-priority',
'std-in-remote',
'std-in-remote-cod-eligible',
'std-in-remote-cod-eligible-10k',
'std-in-remote-cod-priority',
'std-in-remote-ips-only',
'std-in-store',
'std-in-store-cod-eligible',
'std-in-ws',
'std-in-ws2',
'std-sns-in',
'std-in-military')
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
 GROUP BY 
 dosp.warehouse_ID
,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT)
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
     WHEN dosp.SHIP_METHOD like '%_MFN%' THEN 'STD'
    else 'STD' END) A)
Group by 
warehouse_id,
Postalcode);
*/

--------------------------------------------------Updated W.R.T DOSP DUMP--------------------------------------------------------

 INSERT INTO TEMP_FC_ZIPCODE_CONTRIBUTION
 SELECT ROWNUM AS ROW_ID,warehouse_id,Postalcode,FT_Same,FT_Next,FT_Exp,STD
  FROM
  ( SELECT warehouse_id,
       Postalcode,
       SUM(case when Shipper = 'FT_Same' then Contrib else 0 end) as FT_Same,
       SUM(case when Shipper = 'FT_Next' then Contrib else 0 end) as FT_Next,
       SUM(case when Shipper = 'FT_Exp' then Contrib else 0 end) as FT_Exp,
       SUM(case when Shipper = 'STD' then Contrib else 0 end) as STD
from
(Select warehouse_id,Postalcode,Shipper,Shipped,shipped/SUM(shipped) over (partition by warehouse_id,CASE WHEN Shipper = 'STD' THEN 'STD' ELSE 'FT' END ) as Contrib 
from 
(Select dosp.warehouse_ID
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
    WHEN dosp.SHIP_METHOD like '%_MFN%' THEN 'STD'
    else 'STD' END as Shipper
,count(distinct Fulfillment_shipment_id) as Shipped
       FROM DUMP_DW_DOSP_DATA DOSP 
       WHERE dosp.ship_day BETWEEN vSTART_DATE and vEND_DATE
	AND DOSP.REGION_ID = 4
  AND dosp.SHIP_METHOD NOT like '%_MFN%'
	AND SHIP_METHOD  not in ('MERCHANT','DP_PAKET','ATS_INJ_GRD_STD','ATS_SWA_1')
  AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
 GROUP BY 
 dosp.warehouse_ID
,CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT)
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
     WHEN dosp.SHIP_METHOD like '%_MFN%' THEN 'STD'
    else 'STD' END) A)
Group by 
warehouse_id,
Postalcode);


COMMIT;
  
END USP_SYS_FC_ZIP_CONTRIBUTION;