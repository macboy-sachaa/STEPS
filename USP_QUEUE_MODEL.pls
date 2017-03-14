create or replace PROCEDURE USP_QUEUE_MODEL (vMODEL varchar2) AS 
vROWID INTEGER;
vMODEL_ID INTEGER;
vFLAG INTEGER;
vFLAG2 INTEGER;
vNAME NVARCHAR2(50);
vLINKED INTEGER;
vCOUNT1 INTEGER;
vCOUNT2 INTEGER;
vCOUNT3 INTEGER;
BEGIN

SELECT CAST(vMODEL as INTEGER) INTO vMODEL_ID  from DUAL;

SELECT NVL(MAX(ROW_ID),0)+1 INTO vROWID
FROM SYS_MODEL_RUN_QUEUE;

SELECT COUNT(*) INTO vFLAG
FROM LOG_MODEL_STATUS
WHERE STATUS like 'Execut%';

SELECT COUNT(*) INTO vFLAG2
FROM SYS_MODEL_RUN_QUEUE
WHERE IS_ACTIVE=1;

SELECT NAME INTO vNAME
FROM IN_MODEL
WHERE ID = vMODEL_ID;

------------------------------CHECK FOR INPUTS---------------------------

SELECT CAST(C_VERSION AS INTEGER) INTO vLINKED
  FROM LOG_MODEL_CONFIG 
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE='FC_SHIPOUTS';
   
  SELECT COUNT(*) INTO vCOUNT1
  FROM IN_SNOP_FC_INPUTS
  WHERE MODEL_ID = vLINKED;
  -----------------------------------------------
  SELECT CAST(C_VERSION AS INTEGER) INTO vLINKED
  FROM LOG_MODEL_CONFIG 
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE='MFN_PICKUP_INPUTS';
  
  SELECT COUNT(*) INTO vCOUNT2
  FROM IN_MFN_PICKUPS_INPUTS
  WHERE MODEL_ID = vLINKED;
  -----------------------------------------------
  SELECT CAST(C_VERSION AS INTEGER) INTO vLINKED
  FROM LOG_MODEL_CONFIG 
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE like 'STATION CAPACITY%';
  
  SELECT COUNT(*) INTO vCOUNT3
  FROM IN_STATION_INPUTS
  WHERE MODEL_ID = vLINKED;

--------------------------------END OF CODE------------------------------

IF (vFLAG = 0 AND vFLAG2 = 0 AND vCOUNT1 > 0 AND vCOUNT2 > 0 AND vCOUNT3 > 0 )
THEN

INSERT INTO SYS_MODEL_RUN_QUEUE
(ROW_ID,MODEL_ID,LAST_UPDATED,IS_ACTIVE)
VALUES
(vROWID,vMODEL_ID,SYSDATE,1);
COMMIT;

BEGIN
  DBMS_SCHEDULER.RUN_JOB(
    JOB_NAME            => 'JOB_EXECUTE_MODEL',
    USE_CURRENT_SESSION => FALSE);
END;

apex_application.g_print_success_message:= CONCAT(CONCAT('<span class="notification">Model (', vNAME) ,') Execution Started.</span>');

ELSE IF (vCOUNT1 = 0 OR vCOUNT2 = 0 OR vCOUNT3 = 0)
THEN

apex_application.g_print_success_message:= concat(concat('<span class="notification">Data missing for ',CASE WHEN vCOUNT1 = 0 THEN 'FC Shipouts'
                                                                                                             WHEN vCOUNT2 = 0 THEN 'MFN Pickups Inputs'
                                                                                                             WHEN vCOUNT3 = 0 THEN 'Station Capacity and Returns' END),'.</span>');
ELSE 
apex_application.g_print_success_message:= '<span class="notification">Model is already running(try after sometime).</span>';
END IF;
END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    UPDATE LOG_MODEL_STATUS
    SET STATUS = 'Failed Execution',
    UPDATED_AT = SYSDATE
    WHERE MODEL_ID = vMODEL_ID
    AND STATUS like 'Execut%';
    
    UPDATE SYS_MODEL_RUN_QUEUE
    SET IS_ACTIVE = 0
    WHERE ROW_ID = vROWID;
    COMMIT;

END ;