create or replace PROCEDURE USP_GET_DOSP_DATA(vSTART_DATE DATE,vEND_DATE DATE) AS 
BEGIN

-------TRUNCATE TEMPORARY TABLE FOR STAGING DATA---------
EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_DW_DOSP_DATA DROP STORAGE';
COMMIT;

INSERT INTO TEMP_DW_DOSP_DATA
SELECT DOSP.REGION_ID,
       DOSP.FULFILLMENT_SHIPMENT_ID,
       DOSP.SHIP_DAY,
       DOSP.SHIP_METHOD,
       DOSP.WAREHOUSE_ID,
       DOSP.SHIP_DATETIME,
       DOSP.CARRIER_FIRST_SCAN_DATETIME,
       DOSP.CARRIER_ZONE,
       DOSP.CLOCK_STOP_EVENT_DATETIME,
       DOSP.EXPECTED_SHIP_DATETIME,
       DOSP.ACTUAL_DELIVERY_DATETIME,
       DOSP.ESTIMATED_ARRIVAL_DATETIME,
       DOSP.PROMISED_ARRIVAL_DATETIME,
       DOSP.PROMISED_SHIP_DATETIME,
       DOSP.SHIPPER_ID,
       DOSP.SHIPPING_ADDRESS_POSTAL_CODE,
       DOSP.PKG_BILL_WEIGHT,
       DOSP.PKG_BILL_WEIGHT_UOM,
       DOSP.PKG_LENGTH,
       DOSP.PKG_WIDTH,
       DOSP.PKG_HEIGHT,
       DOSP.SHIP_COST,
       DOSP.PACKAGE_ID,
       CASE WHEN SUBTABLE.PACKAGE_ID IS NULL THEN 0 ELSE 1 END AS IS_HAZMAT,
       DOSP.SCALE_WEIGHT,
       DOSP.SHIPMENT_SHIP_OPTION,
       DOSP.LEGAL_ENTITY_ID,
       DOSP.MARKETPLACE_ID
FROM D_OUTBOUND_SHIPMENT_PACKAGES@DW7 DOSP
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
                    ON DOSP.FULFILLMENT_SHIPMENT_ID=SUBTABLE.FULFILLMENT_SHIPMENT_ID
                    and DOSP.package_id = coalesce(SUBTABLE.package_id,1)
WHERE dosp.ship_day BETWEEN vSTART_DATE AND vEND_DATE
AND DOSP.REGION_ID = 4
AND DOSP.LEGAL_ENTITY_ID = 131
AND DOSP.SHIP_METHOD  not in ('MERCHANT','DP_PAKET')
AND DOSP.SHIPMENT_SHIP_OPTION <> 'vendor-returns'
AND DOSP.CLOCK_STOP_EVENT_DATETIME IS NOT NULL 
AND  CAST(REGEXP_REPLACE(dosp.SHIPPING_ADDRESS_POSTAL_CODE,'[^0-9]','') as INT) is not null;

COMMIT;

END USP_GET_DOSP_DATA;