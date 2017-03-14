create or replace PROCEDURE USP_IN_MODEL_STATUS (vModel_id INTEGER) AS 
vROW_ID INTEGER;
vVERSION INTEGER;
BEGIN

SELECT NVL(MAX(ROW_ID),0) INTO vROW_ID
FROM LOG_MODEL_STATUS;

vROW_ID := vROW_ID + 1;

SELECT COUNT(*) INTO vVERSION FROM LOG_MODEL_STATUS
WHERE MODEL_ID = vModel_id
and STATUS = 'Completed';

vVERSION := vVERSION + 1;

  
INSERT INTO LOG_MODEL_STATUS (ROW_ID,MODEL_ID,CREATED_AT,UPDATED_AT,STATUS,RUN_ID) VALUES
(vROW_ID,vModel_id,sysdate,sysdate,'Execution Started',CONCAT(TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS'),vVERSION));

vVERSION := 1;

INSERT INTO LOG_MODEL_STATUS_LINE (LOG_MODEL_STATUS_ID,EXECUTIONSTEP,EXECUTIONSTATUS,CREATED_AT,UPDATED_AT,RUN_ID) VALUES
(vROW_ID,'USP_FC_ZIPCODE_VOLUME','Pending',SYSDATE,SYSDATE,CONCAT(TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS'),vVERSION));

vVERSION := vVERSION + 1;

INSERT INTO LOG_MODEL_STATUS_LINE (LOG_MODEL_STATUS_ID,EXECUTIONSTEP,EXECUTIONSTATUS,CREATED_AT,UPDATED_AT,RUN_ID) VALUES
(vROW_ID,'USP_STATION_VOLUME','Pending',SYSDATE,SYSDATE,CONCAT(TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS'),vVERSION));

vVERSION := vVERSION + 1;

INSERT INTO LOG_MODEL_STATUS_LINE (LOG_MODEL_STATUS_ID,EXECUTIONSTEP,EXECUTIONSTATUS,CREATED_AT,UPDATED_AT,RUN_ID) VALUES
(vROW_ID,'USP_CONSOLIDATION','Pending',SYSDATE,SYSDATE,CONCAT(TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS'),vVERSION));

vVERSION := vVERSION + 1;

INSERT INTO LOG_MODEL_STATUS_LINE (LOG_MODEL_STATUS_ID,EXECUTIONSTEP,EXECUTIONSTATUS,CREATED_AT,UPDATED_AT,RUN_ID) VALUES
(vROW_ID,'USP_BACKLOG_CALCULATION','Pending',SYSDATE,SYSDATE,CONCAT(TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS'),vVERSION));

vVERSION := vVERSION + 1;

INSERT INTO LOG_MODEL_STATUS_LINE (LOG_MODEL_STATUS_ID,EXECUTIONSTEP,EXECUTIONSTATUS,CREATED_AT,UPDATED_AT,RUN_ID) VALUES
(vROW_ID,'USP_BLEEDOFF_STN','Pending',SYSDATE,SYSDATE,CONCAT(TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS'),vVERSION));

vVERSION := vVERSION + 1;

INSERT INTO LOG_MODEL_STATUS_LINE (LOG_MODEL_STATUS_ID,EXECUTIONSTEP,EXECUTIONSTATUS,CREATED_AT,UPDATED_AT,RUN_ID) VALUES
(vROW_ID,'USP_BLEEDOFF_FC','Pending',SYSDATE,SYSDATE,CONCAT(TO_CHAR(SYSDATE,'YYYYMMDDHHMMSS'),vVERSION));


END;