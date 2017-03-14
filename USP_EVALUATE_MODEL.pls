create or replace PROCEDURE USP_EVALUATE_MODEL
AS
 vMODEL_ID INTEGER;
 vFLAG INTEGER;
 vROWNUM INTEGER;
  ------------------------
  /*
  */
  ------------------------
BEGIN
--SELECT CAST(vMODEL as INTEGER) INTO vMODEL_ID  from DUAL;

SELECT MODEL_ID INTO vMODEL_ID 
FROM SYS_MODEL_RUN_QUEUE
WHERE IS_ACTIVE=1;

SELECT ROW_ID INTO vROWNUM 
FROM SYS_MODEL_RUN_QUEUE
WHERE IS_ACTIVE=1;

/*SELECT COUNT(*) INTO vFLAG
FROM LOG_MODEL_STATUS
WHERE STATUS like 'Execut%';

IF (vFLAG = 0)
THEN

apex_application.g_print_success_message:= '<span class="notification">Model Execution Started.</span>';
/*Start Status Logging.*/
dbms_output.put_line('Start Logging for model ' || vMODEL_ID);
BEGIN
    USP_IN_MODEL_STATUS ( vMODEL_ID );
END;

--dbms_output.put_line('Start USP_FC_ZIPCODE_VOLUME for model ' || vMODEL_ID);
  --Step 1
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_FC_ZIPCODE_VOLUME',0 ); END;
  BEGIN
    USP_FC_ZIPCODE_VOLUME ( vMODEL_ID );
  END; 
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_FC_ZIPCODE_VOLUME',1 ); END;

--dbms_output.put_line('Start USP_STATION_VOLUME for model ' || vMODEL_ID);  
  --Step 2
BEGIN  USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_STATION_VOLUME',0 ); END;
  BEGIN
    USP_STATION_VOLUME_ACT ( vMODEL_ID );
  END;
BEGIN  USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_STATION_VOLUME',1 ); END;
  
  --Step 3
BEGIN  USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_CONSOLIDATION',0 ); END;
  BEGIN
    USP_CONSOLIDATION ( vMODEL_ID );
  END;
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_CONSOLIDATION',1 ); END;
  
  --Step 4
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_BACKLOG_CALCULATION',0 ); END;
  BEGIN
    USP_BACKLOG_CALCULATION ( vMODEL_ID );
  END;
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_BACKLOG_CALCULATION',1 ); END;
  
  --Step 4
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_BLEEDOFF_STN',0 ); END;
  BEGIN
    USP_BLEEDOFF_STN ( vMODEL_ID );
  END;
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_BLEEDOFF_STN',1 ); END;
  
  --Step 4
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_BLEEDOFF_FC',0 ); END;
  BEGIN
    USP_BLEEDOFF_FC ( vMODEL_ID );
  END;
BEGIN USP_UP_MODEL_STATUS ( vMODEL_ID , 'USP_BLEEDOFF_FC',1 ); END;

 BEGIN
    USP_GET_REPORT_DATA ( vMODEL_ID );
  END;
  
 BEGIN
    USP_MIDDLE_MILE_VOLUME ( vMODEL_ID );
 END;

UPDATE SYS_MODEL_RUN_QUEUE
SET IS_ACTIVE = 0
WHERE ROW_ID = vROWNUM;

apex_application.g_print_success_message:= '<span class="notification">Model Execution Completed.</span>';

/*
ELSE
apex_application.g_print_success_message:= '<span class="notification">Model is already running(try after sometime).</span>';
END IF;

COMMIT; 

apex_application.g_print_success_message:= '<span class="notification">Model Execution Completed.</span>';
*/
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
    WHERE ROW_ID = vROWNUM;
    COMMIT;
apex_application.g_print_success_message := '<span class="notification">Model Execution failed.</span>';
END;