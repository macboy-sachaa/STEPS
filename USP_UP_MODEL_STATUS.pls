create or replace PROCEDURE USP_UP_MODEL_STATUS (vMODEL_ID IN INTEGER, vSTATUS IN NVARCHAR2,vISDONE INTEGER) AS 
vROW_ID INTEGER;
vMODELSTATUS INTEGER;
BEGIN
 
SELECT MIN(ROW_ID) INTO vROW_ID
FROM LOG_MODEL_STATUS
WHERE MODEL_ID = vMODEL_ID
AND STATUS like 'Execut%';
 
UPDATE LOG_MODEL_STATUS
 SET STATUS = CONCAT(CASE WHEN vISDONE = 1 THEN 'Executed ' ELSE 'Executing ' END,vSTATUS),
     UPDATED_AT = SYSDATE
 WHERE ROW_ID = vROW_ID;
 
COMMIT;

UPDATE LOG_MODEL_STATUS_LINE
SET EXECUTIONSTATUS = CASE WHEN vISDONE=1 THEN 'Done' ELSE 'Execution Started' END,
    UPDATED_AT = SYSDATE
WHERE LOG_MODEL_STATUS_ID = vROW_ID
AND EXECUTIONSTEP = vSTATUS ;

SELECT COUNT(*) INTO vMODELSTATUS
FROM LOG_MODEL_STATUS_LINE 
WHERE LOG_MODEL_STATUS_ID = vROW_ID AND EXECUTIONSTATUS not in ('Done');

IF vMODELSTATUS = 0
THEN

UPDATE LOG_MODEL_STATUS
 SET STATUS = 'Completed',
     UPDATED_AT = SYSDATE
 WHERE ROW_ID = vROW_ID;

END IF;

COMMIT;

END;