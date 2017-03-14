create or replace PROCEDURE USP_SYS_STATION_PERFORMANCE (vSTART_DATE DATE,vEND_DATE DATE) AS
BEGIN

EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_SYS_STATION_PERFORMANCE DROP STORAGE';
COMMIT;


/*INSERT INTO TEMP_SYS_STATION_PERFORMANCE 
SELECT CS.TRACKING_ID ,
      STATION.STATION_CODE as assigned_station,
          (
    CASE
      WHEN STATION.CITY LIKE '%SP%'
      OR STATION.DESCRIPTION LIKE '%SP%'
      THEN 'SP'
      ELSE 'STATION'
    END) as IS_SP,
    CASE WHEN CSP.SHIP_METHOD LIKE 'ATS_MFN%' THEN 'MFN' ELSE 'AFN' END AS CSO,
trunc(cs.promised_delivery_date) edd,
trunc(cs.ship_date) ship_date,
trunc(cssh.change_date) as scan_date,
cs.delivery_done_date as final_del_done,
MIN(CASE WHEN cssh.shipment_status_id = 21 THEN cssh.change_date ELSE NULL END) AS AT_STATION,
min(case when cssh.shipment_status_id in (51,80) then cssh.change_date else null end) as del_date,
min(case when cssh.shipment_status_id in (52,59,99)  then cssh.change_date else null end) as rej_undel,
min( 
      CASE
        WHEN cssh.shipment_status_id IN (26,28,34,42,51,52,59,80,99,211)
        OR (cssh.shipment_status_id   = 24
       
AND cssh.SHIPMENT_REASON_ID   = 35)
        OR (cssh.shipment_status_id   = 161
       
AND cssh.SHIPMENT_REASON_ID   = 135)
        OR (cssh.shipment_status_id   = 161
       
AND cssh.SHIPMENT_REASON_ID   = 134)
        OR (cssh.shipment_status_id   = 161
       
AND cssh.SHIPMENT_REASON_ID   = 139)
        THEN cssh.change_date
      END
     ) as attmpt_date,
    max(case when cssh.shipment_status_id = 32 then cssh.change_date else null end) as oor_dt
 
FROM TBALMBA_DDL.comp_shipments@DW7 CS
    LEFT JOIN TBALMBA_DDL.comp_shipment_packages@DW7 CSP
    ON CSP.SHIPMENT_ID = CS.SHIPMENT_ID
    LEFT JOIN TBALMBA_DDL.comp_STATIONS@DW7 STATION
    ON CS.ASSIGNED_STATION_ID = STATION.STATION_ID
    left join TBALMBA_DDL.comp_shipment_status_history@DW7 cssh on cs.shipment_id = cssh.shipment_id
   
WHERE 
    cs.creation_date >= vSTART_DATE - 30
    and cs.creation_date <= vEND_DATE
    and cs.region_id = 4
    and cssh.creation_date >= vSTART_DATE - 30
    and cssh.creation_date <= vEND_DATE
    and cssh.region_id=4
    and csp.creation_date >= vSTART_DATE - 30
    and csp.creation_date <= vEND_DATE
    and csp.region_id = 4
    and cssh.partition_key >= vSTART_DATE -30
    and cssh.is_valid = 'Y'
    and CSP.partition_key >= vSTART_DATE - 30
    and cs.partition_key >= vSTART_DATE - 30
 
AND CS.shipment_type = 'Delivery'
   
AND STATION.country_code = 'IN' 
and csp.ship_method like '%ATS%' 
and csp.ship_method not like '%IPS%'
and csp.ship_method not like '%BD%' 
and csp.ship_method not like '%AMX%'
and  (
    (cs.ship_option in
(
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
'std-sns-in',
'std-in-buyback',
'std-in-buyback-cod-eligible',
'same-in-am',
'exp-in-cod-eligible',
'next-in-cod-eligible',
'same-in-cod-eligible'
) and csp.ship_method in
(
'ATS_INJ_STD',
'ATS_INJ_STD_COD',
'ATS_INJ_111_COD',
'ATS_INJ_111',
'ATS_INJ_NEXT_COD',
'ATS_INJ_NEXT',
'ATS_INJ_SAME_COD',
'ATS_INJ_SAME',
'ATS_INJ_EXP_COD',
'ATS_INJ_EXP'
)

       ) or (cs.ship_option in
(
'1DD IN EZ COD',
'1DD IN EZ COD',
'2DD IN EZ COD',
'2DD IN EZ COD',
'IN Exp Dom 2',
'IN Exp Dom 2',
'in-easyship-std',
'in-easyship-std',
'Std IN EZ Local',
'Std IN EZ Local',
'Std IN EZ Local COD',
'Std IN EZ Local COD',
'Std IN EZ Metro',
'Std IN EZ Metro',
'Std IN EZ Metro COD',
'Std IN EZ Metro COD',
'Std IN EZ National',
'Std IN EZ National',
'Std IN EZ National COD',
'Std IN EZ National COD',
'Std IN EZ Remote',
'Std IN EZ Remote',
'1DD IN EZ COD',
'1DD IN EZ COD',
'2DD IN EZ COD',
'2DD IN EZ COD',
'SDD IN EZ COD',
'SDD IN EZ COD'
)
and csp.ship_method in
(
'ATS_INJ_NEXT_COD',
'ATS_INJ_NEXT',
'ATS_INJ_EXP',
'ATS_INJ_EXP_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD',
'ATS_MFN_STD',
'ATS_MFN_STD_COD'
)
)
  )  
   
AND CS.promised_delivery_date between vSTART_DATE - 30
and vEND_DATE + 20
   
AND CS.ship_date >= vSTART_DATE
and CS.ship_date < vEND_DATE + 1
   
and trunc(cssh.change_date) < vEND_DATE + 1
  group by
    CS.TRACKING_ID ,
      STATION.STATION_CODE,
          (
    CASE
      WHEN STATION.CITY LIKE '%SP%'
      OR STATION.DESCRIPTION LIKE '%SP%'
      THEN 'SP'
      ELSE 'STATION'
    END),
    CASE WHEN CSP.SHIP_METHOD LIKE 'ATS_MFN%' THEN 'MFN' ELSE 'AFN' END,
trunc(cs.promised_delivery_date),
trunc(cs.ship_date),
    trunc(cssh.change_date),
    cs.delivery_done_date;
*/
-----------------------------------------------------------------------Updated W.R.T. COMP Local dump------------------------------------------

/*
INSERT INTO TEMP_SYS_STATION_PERFORMANCE 
SELECT TRACKING_ID,
  ASSIGNED_STATION,
  IS_SP,
  CSO,
  EDD,
  SHIP_DATE,
  SCAN_DATE,
  FINAL_DEL_DONE,
  AT_STATION,
  DEL_DATE,
  REJ_UNDEL,
  ATTMPT_DATE,
  OOR_DT,
  --if shipments arrive before 6PM for premium and before 2PM for standard then we consider in the same day else we consider it from next day
  TRUNC(CASE WHEN CSO LIKE '%111%' OR CSO LIKE '%SAME%' OR CSO LIKE '%NEXT%' OR CSO LIKE '%EXP%'  THEN NVL(AT_STATION,SCAN_DATE) + 6/24 ELSE NVL(AT_STATION,SCAN_DATE) + 10/24 END) AS MIN_DATE,
  TRUNC(COALESCE(FINAL_DEL_DONE,del_date,rej_undel,oor_dt,AT_STATION,SCAN_DATE)) AS MAX_DATE
FROM DUMP_DW_COMP_DATA 
where TRUNC(SCAN_DATE) between vSTART_DATE-5 AND vEND_DATE+2;
*/

---------------------------------------------------------------------Updated W.R.T New Dump---------------------------------------------------

INSERT INTO TEMP_SYS_STATION_PERFORMANCE
SELECT REFDATE
       ,ASSIGNED_STATION
       ,CSO
       ,AT_STATION
       ,OOR_PKGS
       ,REJECTED
       ,DELIVERED
 FROM DUMP_DW_COMP_DATA
 WHERE REFDATE BETWEEN vSTART_DATE AND vEND_DATE;


COMMIT;
 
END;