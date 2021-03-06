﻿CREATE OR REPLACE FUNCTION Fun_GetTARGETALL(PAR_MFGTYPE        IN VARCHAR2,
                                            PAR_SHIFT          IN VARCHAR2,
                                            PAR_LINE           IN VARCHAR2,
                                            PAR_STAGE          IN VARCHAR2,
                                            PAR_PERIODNO       IN VARCHAR2,
                                            PAR_STARTTIME      IN DATE,
                                            PAR_ENDTIME        IN DATE,
                                            PAR_BREAKTIMEPER   IN NUMBER,
                                            PAR_CYC            IN VARCHAR2,
                                            PAR_UNITPER        IN VARCHAR2,
                                            PAR_NOW            IN VARCHAR2,
                                            PAR_SMT            IN VARCHAR2,
                                            PAR_PCBLINES       VARCHAR2,
                                            PAR_SIDE           IN VARCHAR2 DEFAULT 'A',
                                            PAR_PDTGROUPID     IN VARCHAR2 DEFAULT 'ASS',
                                            PAR_NONWORKSTATION IN VARCHAR2 DEFAULT 'AA')
--version v3.0.0.0 2014/07/15 by oscar
 RETURN NUMBER IS
  V_INTT      NUMBER := 0;
  V_COUNT     NUMBER := 0;
  V_INACTUAL  NUMBER := 0;
  V_OUTACTUAL NUMBER := 0;
  V_INSTAGE   SFCLINE_MAP.INSTAGE%TYPE := 'AN';
  V_OUTSTAGE  SFCLINE_MAP.OUTSTAGE%TYPE := 'PO';
  --V_STARTTIME V_PPFPRODPERIOD.STARTTIME%TYPE;
  V_FLAG            NUMBER := 0;
  V_STATE           NUMBER := 1;
  V_STATUS          KBPERIODSTATUS.STATUS%TYPE;
  V_MANUALSTARTTIME V_PPFPRODPERIOD.STARTTIME%TYPE;
  V_MANUALENDTIME   V_PPFPRODPERIOD.ENDTIME%TYPE;
  V_STARTTIME       V_PPFPRODPERIOD.STARTTIME%TYPE;
  V_ENDTIME         V_PPFPRODPERIOD.ENDTIME%TYPE;
  V_MINPERIODNO     PPFPRODPERIOD.PERIODNO%TYPE;
  V_MAXPERIODNO     PPFPRODPERIOD.PERIODNO%TYPE;
BEGIN
  P_MANUALTIME(PAR_MFGTYPE,
               PAR_SHIFT,
               PAR_LINE,
               PAR_STAGE,
               PAR_PERIODNO,
               PAR_STARTTIME,
               PAR_ENDTIME,
               PAR_SIDE);
  --眔–竊翴ネ玻篈
  SELECT COUNT(STATUS)
    INTO V_COUNT
    FROM KBPERIODSTATUS
   WHERE MFGTYPE = PAR_MFGTYPE
     AND LINE = PAR_LINE
     AND PERIODNO = PAR_PERIODNO
     AND SIDE = PAR_SIDE
     AND SHIFT = PAR_SHIFT;
  IF V_COUNT <= 0 THEN
    V_INTT := Fun_GetTARGET(PAR_MFGTYPE,
                            PAR_SHIFT,
                            PAR_PCBLINES,
                            PAR_STAGE,
                            PAR_PERIODNO,
                            PAR_STARTTIME,
                            PAR_ENDTIME,
                            PAR_BREAKTIMEPER,
                            PAR_CYC,
                            PAR_NOW,
                            PAR_SMT,
                            PAR_UNITPER,
                            '1',
                            PAR_PDTGROUPID,
                            PAR_LINE,
                            PAR_NONWORKSTATION);
    IF V_INTT = 0 THEN
      V_INTT := Fun_GetTarget_Default(PAR_MFGTYPE,
                                      PAR_SHIFT,
                                      PAR_LINE,
                                      PAR_STAGE,
                                      PAR_PERIODNO,
                                      PAR_STARTTIME,
                                      PAR_ENDTIME,
                                      PAR_BREAKTIMEPER);
    END IF;
  ELSE
    --V_COUNT := Fun_ManualTime(PAR_MFGTYPE,PAR_SHIFT,PAR_LINE,PAR_STAGE,PAR_PERIODNO,PAR_STARTTIME,PAR_ENDTIME,PAR_SIDE);
    --P_MANUALTIME(PAR_MFGTYPE,PAR_SHIFT,PAR_LINE,PAR_STAGE,PAR_PERIODNO,PAR_STARTTIME,PAR_ENDTIME,PAR_SIDE);
    SELECT TRIM(STATUS),
           NVL(MANUALSTARTTIME, SYSDATE + 1),
           NVL(MANUALENDTIME, SYSDATE + 1),
           OPENSTATE
      INTO V_STATUS, V_MANUALSTARTTIME, V_MANUALENDTIME, V_STATE
      FROM KBPERIODSTATUS
     WHERE MFGTYPE = PAR_MFGTYPE
       AND LINE = PAR_LINE
       AND PERIODNO = PAR_PERIODNO
       AND SIDE = PAR_SIDE
       AND SHIFT = PAR_SHIFT;
    SELECT MIN(PERIODNO), MAX(PERIODNO)
      INTO V_MINPERIODNO, V_MAXPERIODNO
      FROM V_PPFPRODPERIOD A
     RIGHT JOIN SFCLINE_MAP B
     USING (PROCESS, LINE)
     WHERE MFGTYPE = PAR_MFGTYPE
       AND LINE = PAR_LINE
       AND SHIFT = PAR_SHIFT;
    IF PAR_PERIODNO - 1 >= V_MINPERIODNO THEN
      SELECT INTARGET, OUTTARGET, INSTAGE, OUTSTAGE
        INTO V_INACTUAL, V_OUTACTUAL, V_INSTAGE, V_OUTSTAGE
        FROM V_PPFPRODPERIOD A
       RIGHT JOIN SFCLINE_MAP B
       USING (PROCESS, LINE)
       WHERE MFGTYPE = PAR_MFGTYPE
         AND LINE = PAR_LINE
         AND SHIFT = PAR_SHIFT
         AND PERIODNO = PAR_PERIODNO - 1;
    ELSIF PAR_PERIODNO - 1 < V_MINPERIODNO AND PAR_SHIFT = '0' THEN
      SELECT INTARGET, OUTTARGET, INSTAGE, OUTSTAGE
        INTO V_INACTUAL, V_OUTACTUAL, V_INSTAGE, V_OUTSTAGE
        FROM V_PPFPRODPERIOD A
       RIGHT JOIN SFCLINE_MAP B
       USING (PROCESS, LINE)
       WHERE MFGTYPE = PAR_MFGTYPE
         AND LINE = PAR_LINE
         AND SHIFT = '1'
         AND PERIODNO = (SELECT MAX(PERIODNO)
                           FROM V_PPFPRODPERIOD
                          WHERE LINE = PAR_LINE
                            AND SHIFT = '1');
    ELSIF PAR_PERIODNO - 1 < V_MINPERIODNO AND PAR_SHIFT = '1' THEN
      SELECT INTARGET, OUTTARGET, INSTAGE, OUTSTAGE
        INTO V_INACTUAL, V_OUTACTUAL, V_INSTAGE, V_OUTSTAGE
        FROM V_PPFPRODPERIOD A
       RIGHT JOIN SFCLINE_MAP B
       USING (PROCESS, LINE)
       WHERE MFGTYPE = PAR_MFGTYPE
         AND LINE = PAR_LINE
         AND SHIFT = '0'
         AND PERIODNO = (SELECT MAX(PERIODNO)
                           FROM V_PPFPRODPERIOD
                          WHERE LINE = PAR_LINE
                            AND SHIFT = '0');
    END IF;
    IF PAR_STAGE = V_INSTAGE THEN
      IF V_MANUALSTARTTIME < PAR_ENDTIME AND
         V_MANUALSTARTTIME > PAR_STARTTIME AND V_INACTUAL = 0 AND
         PAR_PERIODNO <> V_MINPERIODNO THEN
        V_STARTTIME := V_MANUALSTARTTIME;
      ELSE
        V_STARTTIME := PAR_STARTTIME;
      END IF;
      IF V_MANUALENDTIME < SYSDATE AND V_MANUALENDTIME < PAR_ENDTIME AND
         V_INACTUAL = 0 AND PAR_PERIODNO <> V_MINPERIODNO THEN
        V_ENDTIME := V_MANUALENDTIME;
      ELSE
        V_ENDTIME := PAR_ENDTIME;
      END IF;
    ELSIF PAR_STAGE = V_OUTSTAGE THEN
      IF V_MANUALSTARTTIME < PAR_ENDTIME AND
         V_MANUALSTARTTIME > PAR_STARTTIME AND V_OUTACTUAL = 0 AND
         PAR_PERIODNO <> V_MINPERIODNO THEN
        V_STARTTIME := V_MANUALSTARTTIME;
      ELSE
        V_STARTTIME := PAR_STARTTIME;
      END IF;
      IF V_MANUALENDTIME < SYSDATE AND V_MANUALENDTIME < PAR_ENDTIME AND
         V_OUTACTUAL = 0 AND PAR_PERIODNO <> V_MINPERIODNO THEN
        V_ENDTIME := V_MANUALENDTIME;
      ELSE
        V_ENDTIME := PAR_ENDTIME;
      END IF;
    END IF;
    IF V_STATE = 1 THEN
      V_INTT := 0;
      CASE
        WHEN V_STATUS = 1 THEN
          V_INTT := Fun_GetTARGET(PAR_MFGTYPE,
                                  PAR_SHIFT,
                                  PAR_PCBLINES,
                                  PAR_STAGE,
                                  PAR_PERIODNO,
                                  V_STARTTIME,
                                  V_ENDTIME,
                                  PAR_BREAKTIMEPER,
                                  PAR_CYC,
                                  PAR_NOW,
                                  PAR_SMT,
                                  PAR_UNITPER,
                                  '1',
                                  PAR_PDTGROUPID,
                                  PAR_LINE,
                                  PAR_NONWORKSTATION);
          IF V_INTT = 0 THEN
            V_INTT := Fun_GetTarget_Default(PAR_MFGTYPE,
                                            PAR_SHIFT,
                                            PAR_LINE,
                                            PAR_STAGE,
                                            PAR_PERIODNO,
                                            V_STARTTIME,
                                            V_ENDTIME,
                                            PAR_BREAKTIMEPER);
          END IF;
        WHEN V_STATUS = 2 THEN
          V_INTT := Fun_GetTARGET(PAR_MFGTYPE,
                                  PAR_SHIFT,
                                  PAR_PCBLINES,
                                  PAR_STAGE,
                                  PAR_PERIODNO,
                                  V_STARTTIME,
                                  V_ENDTIME,
                                  PAR_BREAKTIMEPER,
                                  PAR_CYC,
                                  PAR_NOW,
                                  PAR_SMT,
                                  PAR_UNITPER,
                                  '2',
                                  PAR_PDTGROUPID,
                                  PAR_LINE,
                                  PAR_NONWORKSTATION);
          IF V_INTT = 0 THEN
            V_INTT := Fun_GetTarget_Default(PAR_MFGTYPE,
                                            PAR_SHIFT,
                                            PAR_LINE,
                                            PAR_STAGE,
                                            PAR_PERIODNO,
                                            V_STARTTIME,
                                            V_ENDTIME,
                                            PAR_BREAKTIMEPER);
          END IF;
          IF V_INTT > 0 THEN
            V_INTT := ROUND(V_INTT / 2);
          END IF;
        WHEN V_STATUS = 3 THEN
          SELECT HEADCOUNT
            INTO V_COUNT
            FROM KBPERIODSTATUS
           WHERE MFGTYPE = PAR_MFGTYPE
             AND LINE = PAR_LINE
             AND PERIODNO = PAR_PERIODNO
             AND SIDE = PAR_SIDE
             AND SHIFT = PAR_SHIFT;
          V_INTT := Fun_GetTARGET(PAR_MFGTYPE,
                                  PAR_SHIFT,
                                  PAR_PCBLINES,
                                  PAR_STAGE,
                                  PAR_PERIODNO,
                                  V_STARTTIME,
                                  V_ENDTIME,
                                  PAR_BREAKTIMEPER,
                                  PAR_CYC,
                                  PAR_NOW,
                                  PAR_SMT,
                                  PAR_UNITPER,
                                  '3',
                                  PAR_PDTGROUPID,
                                  PAR_LINE,
                                  PAR_NONWORKSTATION);
          IF V_INTT = 0 THEN
            V_INTT := Fun_GetTarget_Default(PAR_MFGTYPE,
                                            PAR_SHIFT,
                                            PAR_LINE,
                                            PAR_STAGE,
                                            PAR_PERIODNO,
                                            V_STARTTIME,
                                            V_ENDTIME,
                                            PAR_BREAKTIMEPER);
          END IF;
          IF V_COUNT > 0 THEN
            V_INTT := ROUND(V_INTT * V_COUNT);
          ELSE
            V_INTT := Fun_GetTARGET(PAR_MFGTYPE,
                                    PAR_SHIFT,
                                    PAR_PCBLINES,
                                    PAR_STAGE,
                                    PAR_PERIODNO,
                                    V_STARTTIME,
                                    V_ENDTIME,
                                    PAR_BREAKTIMEPER,
                                    PAR_CYC,
                                    PAR_NOW,
                                    PAR_SMT,
                                    PAR_UNITPER,
                                    '1',
                                    PAR_PDTGROUPID,
                                    PAR_LINE,
                                    PAR_NONWORKSTATION);
          END IF;
      END CASE;
    END IF;
  END IF;
  RETURN V_INTT;
EXCEPTION
  WHEN OTHERS THEN
    RETURN V_INTT;
END;
/
