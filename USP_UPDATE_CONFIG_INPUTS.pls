create or replace PROCEDURE USP_UPDATE_CONFIG_INPUTS(vMODEL_ID INTEGER
                                                    ,vFC_ZIP NVARCHAR2
                                                    ,vFC_HAZMAT NVARCHAR2
                                                    ,vTRANSIT_TIMES NVARCHAR2
                                                    ,vMFN_ZIP NVARCHAR2
                                                    ,vSTATION_PERF NVARCHAR2
                                                    ,vESMM_ROUTES NVARCHAR2
                                                    ,vSTATION_ZIP NVARCHAR2
                                                    ,vZIP_LS NVARCHAR2) AS 
BEGIN
  
  
  ---------------------------------Update FC Zipcode Contribution Version----------------------------------
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vFC_ZIP,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vFC_ZIP,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'FC ZIPCODE CONTRIBUTION';
  
  ---------------------------------Update FC Hazmat Ratio Version-----------------------------------
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vFC_HAZMAT,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vFC_HAZMAT,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'FC HAZMAT CONTRIBUTION';
  
  ---------------------------------Update Transit Times Version-------------------------------
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vTRANSIT_TIMES,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vTRANSIT_TIMES,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'TRANSIT TIMES DATA';
  
  ---------------------------------Update MFN Zipcode Ratio Version-------------------------------
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vMFN_ZIP,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vMFN_ZIP,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'ZIPCODE MFN CONTRIBUTION';
  
  ---------------------------------Update Station Performance Version--------------------------------- 
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vSTATION_PERF,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vSTATION_PERF,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'STATION PERFORMANCE';
  
    ---------------------------------Update ESMM Routes Version--------------------------------- 
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vESMM_ROUTES,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vESMM_ROUTES,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'ESMM ROUTES DATA';
  
    ---------------------------------Update Station Zipcode Mapping Version--------------------------------- 
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vSTATION_ZIP,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vSTATION_ZIP,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'STATION ZIPCODE MAPPING (LARGE/SMALL)';
  
    ---------------------------------Update Zipcode Large/Small Ratio Version--------------------------------- 
  UPDATE LOG_MODEL_CONFIG
  SET C_VERSION = UPPER(TRIM(NVL(vZIP_LS,C_VERSION))),
      --LINKEDMODEL = CAST(NVL(vZIP_LS,LINKEDMODEL) AS INTEGER),
      UPDATED_AT = SYSDATE
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_CODE = 'ZIPCODE LARGE/SMALL CONTRIBUTION';
  
  COMMIT;
  
  apex_application.g_print_success_message:= '<span class="notification">Configurations Updated</span>';
  
END USP_UPDATE_CONFIG_INPUTS;