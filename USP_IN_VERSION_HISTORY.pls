create or replace PROCEDURE USP_IN_VERSION_HISTORY AS 
vROW_ID INTEGER;
BEGIN

  EXECUTE IMMEDIATE 'TRUNCATE TABLE SYS_VERSION_HISTORY DROP STORAGE'; --Truncate previous records for the same model from the table
  COMMIT;
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;
  
  /*
  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+1,'SYS_CONFIG_TRANSIT_TIMES','SYS-JAN01',SYSDATE,0) ;
  
  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+2,'SYS_ESMM_ROUTES','SYS-JAN01',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+3,'SYS_FC_HAZMAT_VOL','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+4,'SYS_FC_PINCODE_TRANSIT_TIME','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+5,'SYS_FC_STN_TRANSIT_TIMES','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+6,'SYS_FC_ZIP_CONTRIBUTION','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+7,'SYS_MFN_ZIP_CONTRIBUTION','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+8,'SYS_MFN_ZIP_TRANSIT_TIMES','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+9,'SYS_STATION_PERFORMANCE','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+10,'SYS_STN_ZIP_MAPPING','SYS-JAN01',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+11,'SYS_STN_ZIP_MAPPING_ACT','G-201701',SYSDATE,0) ;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  VALUES (vROW_ID+12,'SYS_ZIPCODE_LS_CONTRIBUTION','G-201701',SYSDATE,0) ;
 */
 
 INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_CONFIG_TRANSIT_TIMES',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_CONFIG_TRANSIT_TIMES
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_CONFIG_TRANSIT_TIMES')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;
  
  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_ESMM_ROUTES',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_ESMM_ROUTES
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_ESMM_ROUTES')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_FC_HAZMAT_VOL',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_FC_HAZMAT_VOL
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_FC_HAZMAT_VOL')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_FC_PINCODE_TRANSIT_TIME',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_FC_PINCODE_TRANSIT_TIME
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_FC_PINCODE_TRANSIT_TIME')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_FC_STN_TRANSIT_TIMES',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_FC_STN_TRANSIT_TIMES
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_FC_STN_TRANSIT_TIMES')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;
  

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_FC_ZIP_CONTRIBUTION',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_FC_ZIP_CONTRIBUTION
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_FC_ZIP_CONTRIBUTION')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_MFN_ZIP_CONTRIBUTION',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_MFN_STN_CONTRIBUTION
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_MFN_ZIP_CONTRIBUTION')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_MFN_ZIP_TRANSIT_TIMES',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_MFN_ZIP_TRANSIT_TIMES
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_MFN_ZIP_TRANSIT_TIMES')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_STATION_PERFORMANCE',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_STATION_PERFORMANCE
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_STATION_PERFORMANCE')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_STN_ZIP_MAPPING',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_STN_ZIP_MAPPING
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_STN_ZIP_MAPPING')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_STN_ZIP_MAPPING_ACT',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_STN_ZIP_MAPPING_ACT
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_STN_ZIP_MAPPING_ACT')
  GROUP BY C_VERSION);
  
  SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID 
  FROM SYS_VERSION_HISTORY;

  INSERT INTO SYS_VERSION_HISTORY (ROW_ID,TABLE_NAME,C_VERSION,LAST_UPDATED,IS_DELETED)
  SELECT vROW_ID+ROWNUM,'SYS_ZIPCODE_LS_CONTRIBUTION',C_VERSION,SYSDATE,0 
  FROM (SELECT C_VERSION FROM SYS_ZIPCODE_LS_CONTRIBUTION
  WHERE C_VERSION NOT IN (SELECT C_VERSION 
                          FROM SYS_VERSION_HISTORY 
                          WHERE TABLE_NAME = 'SYS_ZIPCODE_LS_CONTRIBUTION')
  GROUP BY C_VERSION);

COMMIT;

END USP_IN_VERSION_HISTORY;