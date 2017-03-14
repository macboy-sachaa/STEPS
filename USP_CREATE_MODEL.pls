create or replace PROCEDURE USP_CREATE_MODEL 
(MODEL_NAME nvarchar2,MODEL_DESC nvarchar2,vOWNER nvarchar2,MODEL_TYPE nvarchar2,STARTDATE DATE,vDURATION INTEGER,Version_Type nvarchar2,Config_mode nvarchar2)
AS
vmodel_id INTEGER;
vVersion_Id INTEGER;
vConfig_mode INTEGER;
vModel_type INTEGER;
BEGIN

Select NVL(MAX(IN_Model.Id),0) INTO vmodel_id from IN_Model;

Select MAX(SYS_VERSION_TYPES.ID) into vVersion_Id
from SYS_VERSION_TYPES
WHERE UPPER(TRIM(VERSION_TYPE_NAME)) = UPPER(TRIM(Version_Type));

Select MAX(SYS_CONFIG_MODE.ID) into vConfig_mode
from SYS_CONFIG_MODE
WHERE UPPER(TRIM(CONFIG_MODE)) = UPPER(TRIM(Config_mode));

Select ID into vModel_type
from SYS_MODEL_TYPE_MASTER
WHERE NAME = MODEL_TYPE;

INSERT
INTO IN_Model
  (
    ID,
  NAME,
  DESCRIPTION,
  CREATE_DATE,
  LAST_UPDATE,
  OWNER,
  TYPE_ID,
  START_DATE,
  DURATION,
  DEFAULT_VERSION_TYPE,
  CONFIGURATION_MODE
  )
  VALUES
  (
    vmodel_id+1,
    MODEL_NAME,
    MODEL_DESC,
    sysdate,
    sysdate,
    vOWNER,
    vModel_type,
    STARTDATE,
    vDURATION,
    vVersion_Id,
    vConfig_mode
  );
  
COMMIT;

BEGIN
    USP_IN_MODEL_CONFIG (vmodel_id+1);
END; 



END;