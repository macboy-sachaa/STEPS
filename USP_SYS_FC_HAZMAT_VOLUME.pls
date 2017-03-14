create or replace PROCEDURE USP_SYS_FC_HAZMAT_VOLUME(vSTART_DATE DATE,vEND_DATE DATE) AS 
BEGIN


EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_DATA_FC_HAZMAT_VOL DROP STORAGE';
COMMIT;


/*INSERT INTO TEMP_DATA_FC_HAZMAT_VOL
SELECT Warehouse_id,
       COUNT(DISTINCT CASE WHEN SUBTABLE.FULFILLMENT_SHIPMENT_ID IS NOT NULL THEN O.FULFILLMENT_SHIPMENT_ID END)/COUNT(DISTINCT O.FULFILLMENT_SHIPMENT_ID) AS HAZMATVol,
       COUNT(DISTINCT CASE WHEN SHIP_METHOD IN ('AMX_ATS_EXP','IPS_ATS_EXP','IPS_ATS_EXP_COD') THEN O.FULFILLMENT_SHIPMENT_ID END)/COUNT(DISTINCT O.FULFILLMENT_SHIPMENT_ID) AS INJECTIONS 
       FROM D_OUTBOUND_SHIPMENT_PACKAGES@DW7 O
       LEFT JOIN (SELECT DCSM.FULFILLMENT_SHIPMENT_ID,
                          dcsi.package_id
                   FROM BOOKER.D_COMPLETED_SHIPMENT_MAP@DW7 DCSM
                   JOIN BOOKER.D_UNIFIED_CUST_SHIPMENT_ITEMS@DW7 dcsi
                        ON DCSI.shipment_id = DCSM.ordering_shipment_id
                        AND DCSI.ship_day BETWEEN vSTART_DATE-12  AND vEND_DATE
                        AND DCSI.REGION_ID=4
                        AND dcsi.legal_entity_id=131
                        AND dcsi.MARKETPLACE_ID = 44571
                    INNER JOIN D_MP_HAZMAT_ASINS@DW7 dmpha
                        ON dcsi.asin = dmpha.asin
                        AND dmpha.MARKETPLACE_ID = 44571
                        AND dmpha.region_id = 4
                        and dmpha.hazmat_exception in ('IN_GroundOnly','IN_SmallLithiumIonBatteryStandalone','IN_NonSpillableBattery','IN_SmallLithiumMetalBatteryStandalone','IN_MagnetizedMaterial','IN_NoAir')  
                        and transport_regulatory_class in ('2.1','2.2','3','4.1','5.1','6.1','8','9')
                    WHERE DCSM.ship_day BETWEEN vSTART_DATE-12  AND vEND_DATE
                          AND DCSM.region_id = 4
                          AND DCSM.order_day BETWEEN vSTART_DATE-15  AND vEND_DATE
                    GROUP BY DCSM.FULFILLMENT_SHIPMENT_ID,
                          dcsi.package_id) SUBTABLE
                    ON O.FULFILLMENT_SHIPMENT_ID=SUBTABLE.FULFILLMENT_SHIPMENT_ID
                    and O.package_id = coalesce(SUBTABLE.package_id,1)
                    WHERE REGION_ID=4 
                         AND SHIP_DAY BETWEEN vSTART_DATE AND vEND_DATE
                         AND Warehouse_id is NOT NULL
          GROUP BY Warehouse_id;
*/       
------------------------------------------- Updated W.R.T DOSP Local dump--------------------------------------

INSERT INTO TEMP_DATA_FC_HAZMAT_VOL
SELECT Warehouse_id,
       COUNT(DISTINCT CASE WHEN IS_HAZMAT = 1 THEN O.FULFILLMENT_SHIPMENT_ID END)/COUNT(DISTINCT O.FULFILLMENT_SHIPMENT_ID) AS HAZMATVol,
       COUNT(DISTINCT CASE WHEN SHIP_METHOD IN ('AMX_ATS_EXP','IPS_ATS_EXP','IPS_ATS_EXP_COD') THEN O.FULFILLMENT_SHIPMENT_ID END)/COUNT(DISTINCT O.FULFILLMENT_SHIPMENT_ID) AS INJECTIONS 
       FROM DUMP_DW_DOSP_DATA O
                    WHERE REGION_ID=4 
                         AND SHIP_DAY BETWEEN vSTART_DATE AND vEND_DATE
                         AND Warehouse_id is NOT NULL
          GROUP BY Warehouse_id;
          


COMMIT;
END;