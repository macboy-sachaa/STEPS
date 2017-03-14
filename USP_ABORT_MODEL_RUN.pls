create or replace PROCEDURE USP_ABORT_MODEL_RUN(vUInput NVARCHAR2) AS 
vSID NVARCHAR2(100);
vCOUNT INTEGER;
vCOUNT2 INTEGER;
vSTMT NVARCHAR2(255);
BEGIN

/*This Procedure depends on user priveledges, please ask DBA to 'GRANT SELECT ON V$SESSION TO SCHEMA_USER;'(GRANT SELECT ON V_$SESSION TO SYSTEM;) */


SELECT COUNT(*) INTO vCOUNT
FROM SYS_MODEL_RUN_QUEUE
WHERE IS_ACTIVE = 1;

SELECT COUNT(*) INTO vCOUNT2
FROM V$SESSION
WHERE SCHEMANAME = 'TRANS_APEX'
AND ACTION = 'JOB_EXECUTE_MODEL'
AND STATUS = 'ACTIVE';

IF(UPPER(TRIM(vUInput))='YES' AND vCOUNT > 0 AND vCOUNT2 > 0)
THEN

SELECT SID || ',' || SERIAL#  INTO  vSID
FROM V$SESSION
WHERE SCHEMANAME = 'TRANS_APEX'
AND ACTION = 'JOB_EXECUTE_MODEL'
AND STATUS = 'ACTIVE';

dbms_output.put_line('ALTER SYSTEM KILL SESSION '''|| vSID ||''' IMMEDIATE');

EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''|| vSID ||''' IMMEDIATE';


UPDATE SYS_MODEL_RUN_QUEUE
SET IS_ACTIVE =0
WHERE IS_ACTIVE = 1;

apex_application.g_print_success_message:= '<span class="notification">Execution Aborted</span>';

COMMIT;

ELSE

apex_application.g_print_success_message:= CASE WHEN vCOUNT = 0 OR vCOUNT2 = 0 THEN '<span class="notification">No model is running</span>' ELSE '<span class="notification">No action taken...</span>' END;

END IF;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('FAILED TO STOP......');
    apex_application.g_print_success_message:= '<span class="notification">Unable to abort execution</span>';
END USP_ABORT_MODEL_RUN;