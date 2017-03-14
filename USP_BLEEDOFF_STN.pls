create or replace PROCEDURE USP_BLEEDOFF_STN(
    vmodel_id INT)
AS
  vstartdate  DATE;
  vduration   INT;
  vcounter    INT;
  vbleedoff   INT;
  voffset     INT;
  voffsetloop INT;
  vBACKLOG NVARCHAR2(30);
  
BEGIN

  SELECT C_VERSION INTO vBACKLOG
  FROM LOG_MODEL_CONFIG
  WHERE MODEL_ID = vMODEL_ID
  AND STEP_TYPE = 'USER_INPUT'
  AND STEP_CODE = 'STATION_BACKLOG_TARGET';

  EXECUTE IMMEDIATE 'TRUNCATE TABLE stg_bleedoff_calc';
  COMMIT;
  
  voffset := 4;
  
  SELECT Duration INTO vduration FROM IN_Model WHERE Id = vmodel_id;
  SELECT Start_date INTO vstartdate FROM IN_Model WHERE Id = vmodel_id;
  
  vcounter    := 0;
  voffsetloop := 1;
  --vduration := 1; --testing purpose
  
  WHILE vcounter < vduration
  LOOP
  
    INSERT INTO stg_bleedoff_calc
    SELECT S.Model_id ,
      S.Station ,
      S.EDD ,
      PreviousDay_backlog ,
      CASE
        WHEN S.EOD_Backlog_In_days > NVL(T.TargetBacklog,0)
        THEN
          CASE
            WHEN S.AFN_STD >= (S.EOD_Backlog_In_days-NVL(T.TargetBacklog,0))*S.Delv_Capacity
            THEN S.AFN_STD - (S.EOD_Backlog_In_days-NVL(T.TargetBacklog,0))*S.Delv_Capacity
            ELSE 0
          END
        ELSE S.AFN_STD
      END AS AFN_STD,
      AFN_FT ,
      AFN_STD_L,
      FT_SAME,
      FT_SAME_L,
      FT_NEXT,
      FT_NEXT_L,
      FT_EXP,
      FT_EXP_L,
      MFN_STD,
      MFN_STD_L,
      MFN_Pickups ,
      C_Returns ,
      Total_STD ,
      Delv_Capacity ,
      ONTIMEDELIVERIES ,
      COMMERCIALDELV ,
      COMMERCIALDELVSUCCESS ,
      Std_Delv_Lag ,
      Delv_Attempted ,
      EOD_Not_Attempted ,
      Delv_to_Reattempt ,
      (
      CASE
        WHEN S.EOD_Backlog_In_days > NVL(T.TargetBacklog,0)
        THEN NVL(T.TargetBacklog,0)*S.Delv_Capacity
        ELSE S.EOD_Backlog
      END) AS EOD_Backlog ,
      CASE
        WHEN S.EOD_Backlog_In_days > NVL(T.TargetBacklog,0)
        THEN NVL(T.TargetBacklog,0)
        ELSE S.EOD_Backlog_In_days
      END AS EOD_Backlog_In_days ,
      NVL(T.TargetBacklog,0) AS TargetBacklog,
      CASE
        WHEN S.EOD_Backlog_In_days > NVL(T.TargetBacklog,0)
        THEN
          CASE
            WHEN S.AFN_STD >= (S.EOD_Backlog_In_days-NVL(T.TargetBacklog,0))*S.Delv_Capacity
            THEN (S.EOD_Backlog_In_days - NVL(T.TargetBacklog,0))*S.Delv_Capacity
            ELSE S.AFN_STD
          END
        ELSE 0
      END AS Bleedoff ,
      CASE
        WHEN S.EOD_Backlog_In_days > NVL(T.TargetBacklog,0)
        THEN
          CASE
            WHEN S.AFN_STD >= (S.EOD_Backlog_In_days-NVL(T.TargetBacklog,0))*S.Delv_Capacity
            THEN 0
            ELSE ((S.EOD_Backlog_In_days-NVL(T.TargetBacklog,0))*S.Delv_Capacity) - S.AFN_STD
          END
        ELSE 0
      END AS LeftOver
    FROM stg_backlog_calc S
    LEFT JOIN IN_Station_Backlog_target T
    ON UPPER(TRIM(S.Station ))   =UPPER(TRIM(T.Station))
    AND T.MODEL_ID = CAST(vBACKLOG AS INT)
    WHERE EDD         = vstartdate + vcounter;
    
    SELECT COUNT(                *)
    INTO vbleedoff
    FROM stg_backlog_calc S
    LEFT JOIN IN_Station_Backlog_target T
    ON UPPER(TRIM(S.Station ))             =UPPER(TRIM(T.Station))
    WHERE T.MODEL_ID = CAST(vBACKLOG AS INT)
    AND S.EDD = vstartdate + vcounter
    AND S.EOD_Backlog_In_days > NVL(T.TargetBacklog,0)
    AND S.AFN_STD            >= (S.EOD_Backlog_In_days-NVL(T.TargetBacklog,0))*S.Delv_Capacity;
    
    WHILE vbleedoff           > 0 AND voffsetloop < voffset
    LOOP
      IF vcounter > 0 AND ((vcounter - voffsetloop) <= 0 OR voffsetloop = voffset) THEN
        UPDATE stg_bleedoff_calc A
        SET
          (
            AFN_STD,
            EOD_Backlog,
            EOD_Backlog_In_days,
            Bleedoff,
            LeftOver
          )
          =
          (SELECT
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN A.AFN_STD - B.LeftOver
              ELSE 0
            END AS AFN_STD,
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN A.EOD_Backlog - B.LeftOver
              ELSE A.EOD_Backlog - A.AFN_STD
            END AS EOD_Backlog,
            (
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN A.EOD_Backlog - B.LeftOver
              ELSE A.EOD_Backlog - A.AFN_STD
            END)                 /A.Delv_Capacity AS EOD_Backlog_In_days,
            Bleedoff             + B.LeftOver     AS Bleedoff,
            0                                     AS LeftOver
          FROM stg_bleedoff_calc B
          WHERE A.Station=B.Station
          AND A.EDD      =B.EDD       -1
          AND A.EDD      = vstartdate + (vcounter-voffsetloop)
          AND B.LeftOver >0
          )
        WHERE EXISTS
          (SELECT 1
          FROM stg_bleedoff_calc B
          WHERE A.Station=B.Station
          AND A.EDD      =B.EDD       -1
          AND A.EDD      = vstartdate + (vcounter-voffsetloop)
          AND B.LeftOver >0
          );
      ELSE
        UPDATE stg_bleedoff_calc A
        SET
          (
            AFN_STD,
            EOD_Backlog,
            EOD_Backlog_In_days,
            Bleedoff,
            LeftOver
          )
          =
          (SELECT
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN A.AFN_STD - B.LeftOver
              ELSE 0
            END AS AFN_STD,
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN A.EOD_Backlog - B.LeftOver
              ELSE A.EOD_Backlog -A.AFN_STD
            END AS EOD_Backlog,
            (
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN A.EOD_Backlog - B.LeftOver
              ELSE A.EOD_Backlog - A.AFN_STD
            END)                 /A.Delv_Capacity AS EOD_Backlog_In_days,
            A.Bleedoff           + (
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN B.LeftOver
              ELSE A.AFN_STD
            END) AS Bleedoff,
            A.LeftOver + (
            CASE
              WHEN A.AFN_STD >= B.LeftOver
              THEN 0
              ELSE B.LeftOver-A.AFN_STD
            END) AS LeftOver
          FROM stg_bleedoff_calc B
          WHERE A.Station=B.Station
          AND A.EDD      =B.EDD      - 1
          AND A.EDD      =vstartdate + (vcounter-voffsetloop)
          AND B.LeftOver >0
          )
        WHERE EXISTS
          (SELECT 1
          FROM stg_bleedoff_calc B
          WHERE A.Station=B.Station
          AND A.EDD      =B.EDD      - 1
          AND A.EDD      =vstartdate + (vcounter-voffsetloop)
          AND B.LeftOver >0
          );
      END IF;
      SELECT COUNT(*)
      INTO vbleedoff
      FROM stg_bleedoff_calc S
      WHERE EDD    = vstartdate + (vcounter-voffsetloop)
      AND LeftOver >0;
      voffsetloop := voffsetloop + 1;
    END LOOP;
    vcounter    := vcounter+1;
    voffsetloop := 1;
  END LOOP;
END;