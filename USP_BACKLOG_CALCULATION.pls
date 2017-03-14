create or replace PROCEDURE USP_Backlog_Calculation(
    vModel_Id INTEGER)
AS
  vstart_date DATE;
  vduration   INTEGER;
  vcounter    INTEGER;
BEGIN

  SELECT Start_date - 6
  INTO vstart_date --Initialize Startdate variable with start date of model
  FROM IN_Model
  WHERE Id = vModel_Id;
  
  SELECT Duration + 6
  INTO vduration --Initialize Duration variable with duration of the model
  FROM IN_Model
  WHERE Id  = vModel_Id;
  vcounter := 0;
  --Set vduration =2 --Testing scenario.
  EXECUTE IMMEDIATE 'TRUNCATE TABLE stg_backlog_calc DROP STORAGE';
  COMMIT;
  --While counter for pulling data day by day from conslidated station inputs data
  WHILE vcounter < vduration
  LOOP
    --Execute when we at the startdate
    --dbms_output.put_line(vduration);
    
    IF vcounter = 0 THEN
      INSERT INTO stg_backlog_calc
      SELECT Model_id ,
        A.Station ,
        A.EDD ,
        0 AS PreviousDay_backlog ,
        CASE WHEN (Delv_Capacity - AFN_FT - MFN_STD) < AFN_STD 
             THEN CASE WHEN (Delv_Capacity - AFN_FT-MFN_STD) > 0 
                       THEN (Delv_Capacity - AFN_FT-MFN_STD)
                       ELSE 0 END 
             ELSE AFN_STD END AS AFN_STD,
        AFN_FT ,
        AFN_STD_L,
        FT_SAME,
        FT_SAME_L,
        FT_NEXT,
        FT_NEXT_L,
        FT_EXP,
        FT_EXP_L,
        CASE WHEN (Delv_Capacity - AFN_FT) < MFN_STD 
             THEN CASE WHEN (Delv_Capacity - AFN_FT) > 0 
                       THEN (Delv_Capacity - AFN_FT)
                       ELSE 0 END 
             ELSE MFN_STD END AS MFN_STD,
        MFN_STD_L,
        MFN_Pickups ,
        C_Returns ,
        Total_STD ,
        Delv_Capacity ,
        ONTIMEDELIVERIES ,
        COMMERCIALDELV ,
        COMMERCIALDELVSUCCESS ,
        CASE
          WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
          THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
          ELSE Total_STD
        END AS Std_Delv_Lag ,
        CASE
          WHEN Delv_Capacity<(
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
              ELSE Total_STD
            END+AFN_FT)
          THEN Delv_Capacity
          ELSE (
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
              ELSE Total_STD
            END+AFN_FT)
        END AS Delv_Attempted ,
        CASE
          WHEN (Total_STD+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
            END)>0
          THEN ((Total_STD+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
            END))
          ELSE 0
        END AS EOD_Not_Attempted ,
        CASE
          WHEN Delv_Capacity<(
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
              ELSE Total_STD
            END+AFN_FT)
          THEN Delv_Capacity
          ELSE (
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
              ELSE Total_STD
            END+AFN_FT)
        END    * CASE WHEN (1-ONTIMEDELIVERIES - REJECTS) < 0 THEN (1-ONTIMEDELIVERIES) ELSE (1-ONTIMEDELIVERIES - REJECTS) END AS Delv_to_Reattempt ,
        CASE 
          WHEN Delv_Capacity<(
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
              ELSE Total_STD
            END+AFN_FT)
          THEN Delv_Capacity
          ELSE (
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
              ELSE Total_STD
            END+AFN_FT)
        END    * CASE WHEN (1-ONTIMEDELIVERIES - REJECTS) < 0 THEN (1-ONTIMEDELIVERIES) ELSE (1-ONTIMEDELIVERIES - REJECTS) END +
        CASE
          WHEN (Total_STD+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
            END)>0
          THEN ((Total_STD+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
            END))
          ELSE 0
        END AS EOD_Backlog ,
        CASE
          WHEN Delv_Capacity <= 0
          THEN 0
          ELSE (
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                  ELSE Total_STD
                END+AFN_FT)
            END    * CASE WHEN (1-ONTIMEDELIVERIES - REJECTS) < 0 THEN (1-ONTIMEDELIVERIES) ELSE (1-ONTIMEDELIVERIES - REJECTS) END +
            CASE
              WHEN (Total_STD+AFN_FT)-(
                CASE
                  WHEN Delv_Capacity<(
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                      ELSE Total_STD
                    END+AFN_FT)
                  THEN Delv_Capacity
                  ELSE (
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                      ELSE Total_STD
                    END+AFN_FT)
                END)>0
              THEN ((Total_STD+AFN_FT)-(
                CASE
                  WHEN Delv_Capacity<(
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                      ELSE Total_STD
                    END+AFN_FT)
                  THEN Delv_Capacity
                  ELSE (
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN Total_STD                   -NVL(B.Shipments*COMMERCIALDELV,0)
                      ELSE Total_STD
                    END+AFN_FT)
                END))
              ELSE 0
            END)/Delv_Capacity
        END AS EOD_Backlog_In_days
      FROM stg_StationVolume_Con A
      LEFT JOIN
        (SELECT Station ,
          TRUNC(EDD) AS EDD ,
          SUM(STD_Shipments+FT_same+FT_next+FT_exp) AS Shipments
        FROM stg_StationVolume
        GROUP BY Station ,
          TRUNC(EDD)
        ) B
      ON TRUNC(A.EDD)=B.EDD
      AND A.Station=B.Station
      WHERE A.EDD  = (vcounter + vstart_date);
    ELSE
      --Execute for days other than the startdate
      INSERT INTO stg_backlog_calc
      SELECT Model_id ,
        A.Station ,
        A.EDD ,
        NVL(C.EOD_Backlog,0) AS PreviousDay_backlog ,
        CASE WHEN (Delv_Capacity - AFN_FT - MFN_STD - C.EOD_Backlog) < AFN_STD 
             THEN CASE WHEN (Delv_Capacity - AFN_FT-MFN_STD-C.EOD_Backlog) > 0 
                       THEN (Delv_Capacity - AFN_FT-MFN_STD-C.EOD_Backlog)
                       ELSE 0 END 
             ELSE AFN_STD END AS AFN_STD,
        AFN_FT,
        AFN_STD_L,
        FT_SAME,
        FT_SAME_L,
        FT_NEXT,
        FT_NEXT_L,
        FT_EXP,
        FT_EXP_L,
        CASE WHEN (Delv_Capacity - AFN_FT - C.EOD_Backlog) < MFN_STD 
             THEN CASE WHEN (Delv_Capacity - AFN_FT-C.EOD_Backlog) > 0 
                       THEN (Delv_Capacity - AFN_FT-C.EOD_Backlog)
                       ELSE 0 END 
             ELSE MFN_STD END AS MFN_STD,
        MFN_STD_L,
        MFN_Pickups ,
        C_Returns ,
        Total_STD ,
        Delv_Capacity ,
        ONTIMEDELIVERIES ,
        COMMERCIALDELV ,
        COMMERCIALDELVSUCCESS ,
        CASE
          WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
          THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
          ELSE (Total_STD                  +C.EOD_Backlog) END AS Std_Delv_Lag ,
        CASE
          WHEN Delv_Capacity<(
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
              ELSE (Total_STD                  +C.EOD_Backlog)
            END                                +AFN_FT)
          THEN Delv_Capacity
          ELSE (
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
              ELSE (Total_STD                  +C.EOD_Backlog)
            END                                +AFN_FT)
        END AS Delv_Attempted ,
        CASE
          WHEN ((Total_STD+C.EOD_Backlog)+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
            END)>0
          THEN (((Total_STD+C.EOD_Backlog)+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
            END))
          ELSE 0
        END AS EOD_Not_Attempted ,
        CASE
          WHEN Delv_Capacity<(
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
              ELSE (Total_STD                  +C.EOD_Backlog)
            END                                +AFN_FT)
          THEN Delv_Capacity
          ELSE (
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
              ELSE (Total_STD                  +C.EOD_Backlog)
            END                                +AFN_FT)
        END * CASE WHEN (1-ONTIMEDELIVERIES - REJECTS) < 0 THEN (1-ONTIMEDELIVERIES) ELSE (1-ONTIMEDELIVERIES - REJECTS) END AS Delv_to_Reattempt ,
        CASE
          WHEN Delv_Capacity<(
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
              ELSE (Total_STD                  +C.EOD_Backlog)
            END                                +AFN_FT)
          THEN Delv_Capacity
          ELSE (
            CASE
              WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
              THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
              ELSE (Total_STD                  +C.EOD_Backlog)
            END                                +AFN_FT)
        END                                    * CASE WHEN (1-ONTIMEDELIVERIES - REJECTS) < 0 THEN (1-ONTIMEDELIVERIES) ELSE (1-ONTIMEDELIVERIES - REJECTS) END +
        CASE
          WHEN ((Total_STD+C.EOD_Backlog)+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
            END)>0
          THEN (((Total_STD+C.EOD_Backlog)+AFN_FT)-(
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
            END))
          ELSE 0
        END AS EOD_Backlog ,
        CASE
          WHEN Delv_Capacity<=0
          THEN 0
          ELSE (
            CASE
              WHEN Delv_Capacity<(
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
              THEN Delv_Capacity
              ELSE (
                CASE
                  WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                  THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                  ELSE (Total_STD                  +C.EOD_Backlog)
                END                                +AFN_FT)
            END * CASE WHEN (1-ONTIMEDELIVERIES - REJECTS) < 0 THEN (1-ONTIMEDELIVERIES) ELSE (1-ONTIMEDELIVERIES - REJECTS) END +
            CASE
              WHEN ((Total_STD+C.EOD_Backlog)+AFN_FT)-(
                CASE
                  WHEN Delv_Capacity<(
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                      ELSE (Total_STD                  +C.EOD_Backlog)
                    END                                +AFN_FT)
                  THEN Delv_Capacity
                  ELSE (
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                      ELSE (Total_STD                  +C.EOD_Backlog)
                    END                                +AFN_FT)
                END)>0
              THEN (((Total_STD+C.EOD_Backlog)+AFN_FT)-(
                CASE
                  WHEN Delv_Capacity<(
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                      ELSE (Total_STD                  +C.EOD_Backlog)
                    END                                +AFN_FT)
                  THEN Delv_Capacity
                  ELSE (
                    CASE
                      WHEN TRIM(TO_CHAR(A.EDD,'Day')) NOT IN ('Others')
                      THEN ((Total_STD+C.EOD_Backlog)-NVL((B.Shipments+C.EOD_Backlog)*COMMERCIALDELV,0))
                      ELSE (Total_STD                  +C.EOD_Backlog)
                    END                                +AFN_FT)
                END))
              ELSE 0
            END)/Delv_Capacity
        END AS EOD_Backlog_In_days
      FROM stg_StationVolume_Con A
      LEFT JOIN
        (SELECT Station ,
          TRUNC(EDD) AS EDD ,
          SUM(STD_Shipments+FT_same+FT_next+FT_exp) AS Shipments
        FROM stg_StationVolume
        GROUP BY Station ,
          TRUNC(EDD)
        ) B
      ON A.EDD     =B.EDD
      AND A.Station=B.Station
      LEFT JOIN
        (SELECT Station
          --,PreviousDay_backlog as PreviousDay_backlog
          ,Delv_Attempted as PREVSTD
          ,NVL(EOD_Backlog,0) AS EOD_Backlog
        FROM stg_backlog_calc
        WHERE EDD   = vstart_date+(vcounter-1)
        ) C
      ON A.Station=C.Station
      --LEFT JOIN SYS_STN_WEEKLY_PERF P
      --ON A.Station = P.STATION
      WHERE A.EDD = (vcounter + vstart_date) ;
    END IF;
    vcounter := vcounter+1;
  END LOOP;
  COMMIT;
END;