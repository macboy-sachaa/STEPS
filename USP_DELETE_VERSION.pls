create or replace PROCEDURE USP_DELETE_VERSION(vVERSION NVARCHAR2) AS 
BEGIN
  
  UPDATE SYS_VERSIONS
  SET IS_DELETED = 1
  WHERE C_VERSION = vVERSION;

  COMMIT;
  
  apex_application.g_print_success_message:= '<span class="notification">Configuration deleted...</span>';
  
END USP_DELETE_VERSION;