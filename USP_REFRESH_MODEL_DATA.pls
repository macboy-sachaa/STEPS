create or replace PROCEDURE USP_REFRESH_MODEL_DATA(vMODEL_ID NVARCHAR2) AS 
vMODEL INTEGER;
BEGIN

SELECT CAST(vMODEL_ID AS INTEGER) INTO vMODEL
FROM DUAL;

-------------------DELETE SNOP DATA INPUTS---------
DELETE FROM IN_SNOP_FC_INPUTS 
WHERE MODEL_ID = vMODEL;

-------------------DELETE MFN PICKUP INPUTS------------------
DELETE FROM IN_MFN_PICKUPS_INPUTS
WHERE MODEL_ID= vMODEL;

-------------------DELETE STATION INPUTS C-RET AND CAPACITY------------------
DELETE FROM IN_STATION_INPUTS
WHERE MODEL_ID = vMODEL;

COMMIT;

apex_application.g_print_success_message:= '<span class="notification">User inputs refershed for the respective model.</span>';

END;