CREATE OR REPLACE FUNCTION FUN_GETTARGET(PAR_MFGTYPE        IN VARCHAR2,
                                         PAR_SHIFT          IN VARCHAR2,
                                         PAR_LINE           IN VARCHAR2,
                                         PAR_STAGE          IN VARCHAR2,
                                         PAR_PERIODNO       IN VARCHAR2,
                                         PAR_STARTTIME      IN DATE,
                                         PAR_ENDTIME        IN DATE,
                                         PAR_BREAKTIMEPER   IN NUMBER,
                                         PAR_CYC            IN VARCHAR2,
                                         PAR_NOW            IN VARCHAR2,
                                         PAR_PCBSMT         IN VARCHAR2,
                                         PAR_UNITPER        IN VARCHAR2,
                                         PAR_STATUS         IN VARCHAR2 DEFAULT '1',
                                         PAR_PDTGROUPID     IN VARCHAR2 DEFAULT 'ASS',
                                         PAR_PCBMAINLINE    IN VARCHAR2 DEFAULT '',
                                         PAR_NONWORKSTATION IN VARCHAR2 DEFAULT 'A')
--version v3.0.0.0 2014/07/15 by oscar
  --version v3.0.0.1 2019/01/14 by oscar, modify for get different target for in and out from PPFSTANDARDPROD
 RETURN NUMBER IS
  VAR_TARGET          NUMBER := 0;
  VAR_PERIODSTARTTIME V_PPFPRODPERIOD.STARTTIME%TYPE;
  VAR_PERIODENDTIME   V_PPFPRODPERIOD.ENDTIME%TYPE;
BEGIN
  IF PAR_MFGTYPE = 'FA' THEN
    SELECT STARTTIME, ENDTIME
      INTO VAR_PERIODSTARTTIME, VAR_PERIODENDTIME
      FROM V_PPFPRODPERIOD
     WHERE PROCESS = '3'
       AND LINE = PAR_LINE
       AND SHIFT = PAR_SHIFT
       AND PERIODNO = PAR_PERIODNO;
    IF PAR_CYC = '0' AND PAR_STATUS <> '3' THEN
      /* SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
      INTO VAR_TARGET
      FROM (SELECT A.UPN,
                   ROUND((COUNT(*) * MAX(F.STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          PAR_ENDTIME
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                             WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) *
                         ((DECODE(PAR_PDTGROUPID,'ASS',MAX(B.TARGET),MAX(B.OUTTARGET)) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                         (COUNT(*) * MAX(F.STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          PAR_ENDTIME
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                              WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) * MAX(D.stophour) *
                         DECODE(PAR_PDTGROUPID,'ASS',MAX(B.TARGET),MAX(B.OUTTARGET))) TARGETALL
              FROM SFCFA230.SFCTRANSACTIONCACHE A,
                   PPFSTANDARDPROD B,
                   SFCMODEL C,
                   (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                  '',
                                  0,
                                  (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                           ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                            (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                           LINE
                      FROM PPFPRODPERIOD
                     WHERE PERIODNO = PAR_PERIODNO
                       AND SHIFT = PAR_SHIFT
                     GROUP BY LINE) D,
                   (SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                      FROM PPFSTDTIMEHEAD
                     WHERE LINE = PAR_LINE) F
             WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
               AND PASSCOUNT = 1
               AND A.LINE = PAR_LINE
               AND INSTR(PAR_STAGE, STAGE) > 0
               AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
               AND A.LINE = B.LINE
               AND A.MODELFAMILY = B.MODELFAMILY
               AND B.MATERIALGROUP = C.MATERIALGROUP
               AND B.MODELFAMILY = C.MODELFAMILY
               AND A.UPN = C.UPN
               AND A.LINE = D.LINE
               AND A.MODELFAMILY = F.MODELFAMILY
               AND B.MATERIALGROUP = F.MATERIALGROUP
               AND (A.UPN = F.UPN OR
                   (F.UPN = '*' AND
                   A.UPN NOT IN
                   (SELECT UPN FROM PPFSTDTIMEHEAD WHERE LINE = PAR_LINE)))
             GROUP BY A.UPN, A.LINE);*/
    
      WITH T1 AS
       (SELECT A.UPN,
               A.LINE,
               A.MODELFAMILY,
               C.MATERIALGROUP,
               COUNT(1) OUTPUT,
               (SELECT MAX(CYCLETIME) STAND
                  FROM PPFSTDTIMEHEAD A1
                 WHERE LINE = A.LINE
                   AND (A.UPN = UPN OR (NOT EXISTS (SELECT UPN
                                                      FROM PPFSTDTIMEHEAD
                                                     WHERE LINE = A1.LINE
                                                       AND UPN = A1.UPN
                                                       AND UPN <> '*') AND
                        UPN = '*'))
                   AND A.MODELFAMILY = MODELFAMILY
                   /*AND MATERIALGROUP = C.MATERIALGROUP*/
                ) STAND,
               MAX(STOPHOUR) STOPHOUR,
               (SELECT DECODE(PAR_PDTGROUPID,
                              'ASS',
                              MAX(TARGET),
                              MAX(OUTTARGET)) TARGET
                  FROM PPFSTANDARDPROD
                 WHERE A.LINE = LINE
                   /*AND A.MODELFAMILY = MODELFAMILY*/) TARGET
          FROM SFCMIFA139.SFCTRANSACTIONCACHE A,
               SFCMODEL C,
               (SELECT DECODE((SUM(BREAKTIME) / 60),
                              '',
                              0,
                              (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                       ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                        (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                       LINE
                  FROM PPFPRODPERIOD
                 WHERE PERIODNO = PAR_PERIODNO
                   AND SHIFT = PAR_SHIFT
                 GROUP BY LINE) D
         WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
           AND PASSCOUNT = 1
           AND A.LINE = PAR_LINE
           AND INSTR(PAR_STAGE, STAGE) > 0
           AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
           AND A.UPN = C.UPN
           AND A.LINE = D.LINE
         GROUP BY A.UPN, A.LINE, A.MODELFAMILY, C.MATERIALGROUP)
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL))
        INTO VAR_TARGET
        FROM (SELECT UPN,
                     ROUND(OUTPUT * STAND / ALLSTAND * TARGET *
                           (PAR_ENDTIME - PAR_STARTTIME) * 24 -
                           OUTPUT * STAND / ALLSTAND * STOPHOUR * TARGET) TARGETALL
                FROM (SELECT UPN,
                             LINE,
                             MODELFAMILY,
                             MATERIALGROUP,
                             OUTPUT,
                             TARGET,
                             STAND,
                             (SELECT SUM(OUTPUT * STAND) FROM T1) ALLSTAND,
                             STOPHOUR
                        FROM T1));
    
    ELSIF PAR_CYC = '0' AND PAR_STATUS = '3' THEN
      /*SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
      INTO VAR_TARGET
      FROM (SELECT A.UPN,
                   ROUND((COUNT(*) * MAX(STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          sysdate
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                              WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) *
                         ((DECODE(PAR_PDTGROUPID,'ASS',MAX(B.TARGET),MAX(B.OUTTARGET)) * (SYSDATE - PAR_STARTTIME) * 24)) -
                         (COUNT(*) * MAX(STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          sysdate
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                              WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) * MAX(D.stophour) *
                        DECODE(PAR_PDTGROUPID,'ASS',MAX(B.TARGET),MAX(B.OUTTARGET))) / MAX(E.HEADCOUNT) TARGETALL
              FROM SFCFA230.SFCTRANSACTIONCACHE A,
                   PPFSTANDARDPROD B,
                   SFCMODEL C,
                   (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                  '',
                                  0,
                                  (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                           ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                            (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                           LINE
                      FROM PPFPRODPERIOD
                     WHERE PERIODNO = PAR_PERIODNO
                       AND SHIFT = PAR_SHIFT
                     GROUP BY LINE) D,
                   (SELECT LINE,
                           UPN,
                           MODELFAMILY,
                           MATERIALGROUP,
                           SUM(HEADCOUNT) HEADCOUNT
                      FROM PPFSTDTIMEDETAIL
                     WHERE LINE = PAR_LINE
                     GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) E,
                   (SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                      FROM PPFSTDTIMEHEAD
                     WHERE LINE = PAR_LINE) F
             WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND SYSDATE
               AND PASSCOUNT = 1
               AND A.LINE = PAR_LINE
               AND INSTR(PAR_STAGE, STAGE) > 0
               AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
               AND A.LINE = B.LINE
               AND A.MODELFAMILY = B.MODELFAMILY
               AND B.MATERIALGROUP = C.MATERIALGROUP
               AND B.MODELFAMILY = C.MODELFAMILY
               AND A.UPN = C.UPN
               AND A.LINE = D.LINE
               AND A.LINE = E.LINE
               AND (A.UPN = E.UPN OR
                   (A.UPN NOT IN (SELECT UPN FROM PPFSTDTIMEDETAIL) AND
                   E.UPN = '*'))
               AND A.MODELFAMILY = E.MODELFAMILY
               AND E.MATERIALGROUP = C.MATERIALGROUP
               AND E.MODELFAMILY = C.MODELFAMILY
               AND A.MODELFAMILY = F.MODELFAMILY
               AND B.MATERIALGROUP = F.MATERIALGROUP
               AND (A.UPN = F.UPN OR
                   (F.UPN = '*' AND
                   A.UPN NOT IN
                   (SELECT UPN FROM PPFSTDTIMEHEAD WHERE LINE = PAR_LINE)))
             GROUP BY A.UPN, A.LINE);*/
    
      WITH T1 AS
       (SELECT A.UPN,
               A.LINE,
               A.MODELFAMILY,
               C.MATERIALGROUP,
               COUNT(1) OUTPUT,
               (SELECT MAX(CYCLETIME) STAND
                  FROM PPFSTDTIMEHEAD A1
                 WHERE LINE = A.LINE
                   AND (A.UPN = UPN OR (NOT EXISTS (SELECT UPN
                                                      FROM PPFSTDTIMEHEAD
                                                     WHERE LINE = A1.LINE
                                                       AND UPN = A1.UPN
                                                       AND UPN <> '*') AND
                        UPN = '*'))
                   AND A.MODELFAMILY = MODELFAMILY
                   /*AND MATERIALGROUP = C.MATERIALGROUP*/) STAND,
               MAX(STOPHOUR) STOPHOUR,
               (SELECT SUM(HEADCOUNT) HEADCOUNT
                  FROM PPFSTDTIMEDETAIL A2
                 WHERE LINE = A.LINE
                   AND INSTR(PDTGROUPID, PAR_PDTGROUPID) > 0
                   AND (A.UPN = UPN OR (NOT EXISTS (SELECT UPN
                                                      FROM PPFSTDTIMEDETAIL
                                                     WHERE LINE = A2.LINE
                                                       AND UPN = A2.UPN
                                                       AND UPN <> '*') AND
                        UPN = '*') AND
                       A.MODELFAMILY = MODELFAMILY AND
                       MATERIALGROUP = C.MATERIALGROUP)) HEADCOUNT,
               (SELECT DECODE(PAR_PDTGROUPID,
                              'ASS',
                              MAX(TARGET),
                              MAX(OUTTARGET)) TARGET
                  FROM PPFSTANDARDPROD
                 WHERE A.LINE = LINE
                   /*AND A.MODELFAMILY = MODELFAMILY*/) TARGET
          FROM SFCMIFA139.SFCTRANSACTIONCACHE A,
               SFCMODEL C,
               (SELECT DECODE((SUM(BREAKTIME) / 60),
                              '',
                              0,
                              (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                       ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                        (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                       LINE
                  FROM PPFPRODPERIOD
                 WHERE PERIODNO = PAR_PERIODNO
                   AND SHIFT = PAR_SHIFT
                 GROUP BY LINE) D
         WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
           AND PASSCOUNT = 1
           AND A.LINE = PAR_LINE
           AND INSTR(PAR_STAGE, STAGE) > 0
           AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
           AND A.UPN = C.UPN
           AND A.LINE = D.LINE
         GROUP BY A.UPN, A.LINE, A.MODELFAMILY, C.MATERIALGROUP)
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL))
        INTO VAR_TARGET
        FROM (SELECT UPN,
                     ROUND((OUTPUT * STAND / ALLSTAND * TARGET *
                           (TO_DATE('2019041909:30:00',
                                     'YYYYMMDDHH24:MI:SS') -
                           TO_DATE('2019041908:30:00',
                                     'YYYYMMDDHH24:MI:SS')) * 24 -
                           OUTPUT * STAND / ALLSTAND * STOPHOUR * TARGET) /
                           HEADCOUNT) TARGETALL
                FROM (SELECT UPN,
                             LINE,
                             MODELFAMILY,
                             MATERIALGROUP,
                             OUTPUT,
                             TARGET,
                             STAND,
                             (SELECT SUM(OUTPUT * STAND) FROM T1) ALLSTAND,
                             STOPHOUR,
                             HEADCOUNT
                        FROM T1));
    
    ELSIF PAR_CYC = '1' AND PAR_STATUS <> '3' THEN
      /* SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
      INTO VAR_TARGET
      --OUTPUT* CT/cO|3CT*RE?!*TARGET - OUTPUT* CT/cO|3CT*RE?!*TARGET*STOPHOUR
      FROM (SELECT A.UPN,
                   ROUND((COUNT(*) * MAX(STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          PAR_ENDTIME
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                              WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) *
                         ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                         (COUNT(*) * MAX(STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          PAR_ENDTIME
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                              WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) * MAX(D.stophour) *
                         MAX(B.TARGET)) TARGETALL
              FROM SFCFA230.SFCTRANSACTIONCACHE A,
                   (select round((60 * 60) / MAX(CYCLETIME)) TARGET, MAX(CYCLETIME) STAND,
                           LINE,
                           MODELFAMILY,
                           MATERIALGROUP,
                           UPN
                      from PPFSTDTIMEHEAD
                     where LINE = PAR_LINE
                     GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) B,
                   SFCMODEL C,
                   (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                  '',
                                  0,
                                  (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                           ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                            (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) stophour,
                           LINE
                      FROM PPFPRODPERIOD
                     WHERE PERIODNO = PAR_PERIODNO
                       AND SHIFT = PAR_SHIFT
                     GROUP BY LINE) D--,
                  -- (SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                   --   FROM PPFSTDTIMEHEAD
                   --  WHERE LINE = PAR_LINE) F
             WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
               AND PASSCOUNT = 1
               AND A.LINE = PAR_LINE
               AND INSTR(PAR_STAGE, STAGE) > 0
               AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
               AND A.LINE = B.LINE
               AND (A.UPN = B.UPN OR
                   (A.UPN NOT IN
                   (SELECT UPN FROM PPFSTDTIMEHEAD WHERE LINE = PAR_LINE) AND
                   B.UPN = '*'))
               AND A.MODELFAMILY = B.MODELFAMILY
               AND B.MATERIALGROUP = C.MATERIALGROUP
               AND B.MODELFAMILY = C.MODELFAMILY
               AND A.UPN = C.UPN
               AND A.LINE = D.LINE
              -- AND A.MODELFAMILY = F.MODELFAMILY
               --AND B.MATERIALGROUP = F.MATERIALGROUP
              -- AND (A.UPN = F.UPN OR
               --    (F.UPN = '*' AND
               --    A.UPN NOT IN
                --   (SELECT UPN FROM PPFSTDTIMEHEAD WHERE LINE = PAR_LINE)))
             GROUP BY A.UPN, A.LINE)*/
    
      WITH T1 AS
       (SELECT UPN,
               LINE,
               MODELFAMILY,
               MATERIALGROUP,
               OUTPUT,
               SUBSTR(TAR, 1, INSTR(TAR, ',') - 1) TARGET,
               SUBSTR(TAR, INSTR(TAR, ',') + 1) STAND,
               STOPHOUR
          FROM (SELECT A.UPN,
                       A.LINE,
                       A.MODELFAMILY,
                       C.MATERIALGROUP,
                       COUNT(1) OUTPUT,
                       (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) || ',' ||
                               MAX(CYCLETIME) STAND
                          FROM PPFSTDTIMEHEAD A1
                         WHERE LINE = A.LINE
                           AND (A.UPN = UPN OR
                               (NOT EXISTS
                                (SELECT UPN
                                    FROM PPFSTDTIMEHEAD
                                   WHERE LINE = A1.LINE
                                     AND UPN = A1.UPN
                                     AND UPN <> '*') AND UPN = '*'))
                           AND A.MODELFAMILY = MODELFAMILY
                           /*AND MATERIALGROUP = C.MATERIALGROUP*/) TAR,
                       MAX(STOPHOUR) STOPHOUR
                  FROM SFCMIFA139.SFCTRANSACTIONCACHE A,
                       SFCMODEL C,
                       (SELECT DECODE((SUM(BREAKTIME) / 60),
                                      '',
                                      0,
                                      (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                               ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                                (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                               LINE
                          FROM PPFPRODPERIOD
                         WHERE PERIODNO = PAR_PERIODNO
                           AND SHIFT = PAR_SHIFT
                         GROUP BY LINE) D
                 WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                   AND PASSCOUNT = 1
                   AND A.LINE = PAR_LINE
                   AND INSTR(PAR_STAGE, STAGE) > 0
                   AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                   AND A.UPN = C.UPN
                   AND A.LINE = D.LINE
                 GROUP BY A.UPN, A.LINE, A.MODELFAMILY, C.MATERIALGROUP))
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL))
        INTO VAR_TARGET
        FROM (SELECT UPN,
                     ROUND(OUTPUT * STAND / ALLSTAND * TARGET *
                           (PAR_ENDTIME - PAR_STARTTIME) * 24 -
                           OUTPUT * STAND / ALLSTAND * STOPHOUR * TARGET) TARGETALL
                FROM (SELECT UPN,
                             LINE,
                             MODELFAMILY,
                             MATERIALGROUP,
                             OUTPUT,
                             TARGET,
                             STAND,
                             (SELECT SUM(OUTPUT * STAND) FROM T1) ALLSTAND,
                             STOPHOUR
                        FROM T1));
    
    ELSIF PAR_CYC = '1' AND PAR_STATUS = '3' THEN
      /* SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
      INTO VAR_TARGET
      FROM (SELECT A.UPN,
                   ROUND((COUNT(*) * MAX(STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          PAR_ENDTIME
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                              WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) *
                         ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                         (COUNT(*) * MAX(STAND) /
                         (SELECT SUM(ALLSTAND)
                             FROM (SELECT A.UPN,
                                          COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                     FROM SFCFA230.SFCTRANSACTIONCACHE A,
                                          PPFSTDTIMEHEAD               B,
                                          SFCMODEL                     C
                                    WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                          PAR_ENDTIME
                                      AND PASSCOUNT = 1
                                      AND A.LINE = PAR_LINE
                                      AND INSTR(PAR_STAGE, STAGE) > 0
                                      AND INSTR(PAR_NONWORKSTATION,
                                                A.WORKSTATION) <= 0
                                      AND A.MODELFAMILY = B.MODELFAMILY
                                      AND (A.UPN = B.UPN OR
                                          (B.UPN = '*' AND
                                          A.UPN NOT IN
                                          (SELECT UPN
                                               FROM PPFSTDTIMEHEAD
                                              WHERE LINE = PAR_LINE)))
                                      AND A.LINE = B.LINE
                                      AND A.MODELFAMILY = C.MODELFAMILY
                                      AND A.UPN = C.UPN
                                      AND B.MATERIALGROUP = C.MATERIALGROUP
                                    GROUP BY A.UPN))) * MAX(D.stophour) *
                         MAX(B.TARGET)) / MAX(E.HEADCOUNT) TARGETALL
              FROM SFCFA230.SFCTRANSACTIONCACHE A,
                   (select round((60 * 60) / MAX(CYCLETIME)) TARGET,MAX(CYCLETIME) STAND,
                           LINE,
                           MODELFAMILY,
                           MATERIALGROUP,
                           UPN
                      from PPFSTDTIMEHEAD
                     where LINE = PAR_LINE
                     GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) B,
                   SFCMODEL C,
                   (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                  '',
                                  0,
                                  (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                           ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                            (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) stophour,
                           LINE
                      FROM PPFPRODPERIOD
                     WHERE PERIODNO = PAR_PERIODNO
                       AND SHIFT = PAR_SHIFT
                     GROUP BY LINE) D,
                   (SELECT LINE,
                           UPN,
                           MODELFAMILY,
                           MATERIALGROUP,
                           SUM(HEADCOUNT) HEADCOUNT
                      FROM PPFSTDTIMEDETAIL
                     WHERE LINE = PAR_LINE
                       AND INSTR(PDTGROUPID, PAR_PDTGROUPID) > 0
                     GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) E--,
                   --(SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                     -- FROM PPFSTDTIMEHEAD
                    -- WHERE LINE = PAR_LINE) F
             WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
               AND PASSCOUNT = 1
               AND A.LINE = PAR_LINE
               AND INSTR(PAR_STAGE, STAGE) > 0
              AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
               AND A.LINE = B.LINE
               AND (A.UPN = B.UPN OR
                   (A.UPN NOT IN (SELECT UPN FROM PPFSTDTIMEHEAD) AND
                   B.UPN = '*'))
               AND A.MODELFAMILY = B.MODELFAMILY
               AND B.MATERIALGROUP = C.MATERIALGROUP
               AND B.MODELFAMILY = C.MODELFAMILY
               AND A.UPN = C.UPN
               AND A.LINE = D.LINE
               AND A.LINE = E.LINE
               AND (A.UPN = E.UPN OR
                   (A.UPN NOT IN (SELECT UPN FROM PPFSTDTIMEDETAIL) AND
                   E.UPN = '*'))
               AND A.MODELFAMILY = E.MODELFAMILY
               AND E.MATERIALGROUP = C.MATERIALGROUP
               AND E.MODELFAMILY = C.MODELFAMILY
             --  AND A.MODELFAMILY = F.MODELFAMILY
               --AND B.MATERIALGROUP = F.MATERIALGROUP
             --  AND (A.UPN = F.UPN OR
               --    (F.UPN = '*' AND
               --    A.UPN NOT IN
               --    (SELECT UPN FROM PPFSTDTIMEHEAD WHERE LINE = PAR_LINE)))
             GROUP BY A.UPN, A.LINE);*/
    
      WITH T1 AS
       (SELECT UPN,
               LINE,
               MODELFAMILY,
               MATERIALGROUP,
               OUTPUT,
               SUBSTR(TAR, 1, INSTR(TAR, ',') - 1) TARGET,
               SUBSTR(TAR, INSTR(TAR, ',') + 1) STAND,
               STOPHOUR,
               HEADCOUNT
          FROM (SELECT A.UPN,
                       A.LINE,
                       A.MODELFAMILY,
                       C.MATERIALGROUP,
                       COUNT(1) OUTPUT,
                       (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) || ',' ||
                               MAX(CYCLETIME) STAND
                          FROM PPFSTDTIMEHEAD A1
                         WHERE LINE = A.LINE
                           AND (A.UPN = UPN OR
                               (NOT EXISTS
                                (SELECT UPN
                                    FROM PPFSTDTIMEHEAD
                                   WHERE LINE = A1.LINE
                                     AND UPN = A1.UPN
                                     AND UPN <> '*') AND UPN = '*'))
                           AND A.MODELFAMILY = MODELFAMILY
                           /*AND MATERIALGROUP = C.MATERIALGROUP*/) TAR,
                       MAX(STOPHOUR) STOPHOUR,
                       (SELECT SUM(HEADCOUNT) HEADCOUNT
                          FROM PPFSTDTIMEDETAIL A2
                         WHERE LINE = A.LINE
                           AND INSTR(PDTGROUPID, PAR_PDTGROUPID) > 0
                           AND (A.UPN = UPN OR
                               (NOT EXISTS
                                (SELECT UPN
                                    FROM PPFSTDTIMEDETAIL
                                   WHERE LINE = A2.LINE
                                     AND UPN = A2.UPN
                                     AND UPN <> '*') AND UPN = '*') AND
                               A.MODELFAMILY = MODELFAMILY AND
                               MATERIALGROUP = C.MATERIALGROUP)) HEADCOUNT
                  FROM SFCMIFA139.SFCTRANSACTIONCACHE A,
                       SFCMODEL C,
                       (SELECT DECODE((SUM(BREAKTIME) / 60),
                                      '',
                                      0,
                                      (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                               ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                                (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                               LINE
                          FROM PPFPRODPERIOD
                         WHERE PERIODNO = PAR_PERIODNO
                           AND SHIFT = PAR_SHIFT
                         GROUP BY LINE) D
                 WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                   AND PASSCOUNT = 1
                   AND A.LINE = PAR_LINE
                   AND INSTR(PAR_STAGE, STAGE) > 0
                   AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                   AND A.UPN = C.UPN
                   AND A.LINE = D.LINE
                 GROUP BY A.UPN, A.LINE, A.MODELFAMILY, C.MATERIALGROUP))
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL))
        INTO VAR_TARGET
        FROM (SELECT UPN,
                     ROUND((OUTPUT * STAND / ALLSTAND * TARGET *
                           (TO_DATE('2019041909:30:00',
                                     'YYYYMMDDHH24:MI:SS') -
                           TO_DATE('2019041908:30:00',
                                     'YYYYMMDDHH24:MI:SS')) * 24 -
                           OUTPUT * STAND / ALLSTAND * STOPHOUR * TARGET) /
                           HEADCOUNT) TARGETALL
                FROM (SELECT UPN,
                             LINE,
                             MODELFAMILY,
                             MATERIALGROUP,
                             OUTPUT,
                             TARGET,
                             STAND,
                             (SELECT SUM(OUTPUT * STAND) FROM T1) ALLSTAND,
                             STOPHOUR,
                             HEADCOUNT
                        FROM T1));
    
    END IF;
  END IF;
  IF PAR_MFGTYPE = 'PCB' THEN
    SELECT STARTTIME, ENDTIME
      INTO VAR_PERIODSTARTTIME, VAR_PERIODENDTIME
      FROM V_PPFPRODPERIOD
     WHERE /*PROCESS = '2'
           AND*/
     LINE = PAR_PCBMAINLINE --cancel process by grey on 20190704
     AND SHIFT = PAR_SHIFT
     AND PERIODNO = PAR_PERIODNO;
    IF PAR_CYC = '0' AND PAR_STATUS <> '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND((COUNT(*) * MAX(STAND) /
                           (SELECT SUM(ALLSTAND)
                               FROM (SELECT A.UPN,
                                            COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            PPFSTDTIMEHEAD                  B,
                                            SFCMODEL                        C
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND A.MODELFAMILY = B.MODELFAMILY
                                        AND (A.UPN = B.UPN OR
                                            (B.UPN = '*' AND
                                            A.UPN NOT IN
                                            (SELECT UPN
                                                 FROM PPFSTDTIMEHEAD
                                                WHERE LINE = PAR_PCBMAINLINE)))
                                        AND B.LINE = PAR_PCBMAINLINE
                                        AND A.MODELFAMILY = C.MODELFAMILY
                                        AND A.UPN = C.UPN
                                        /*AND B.MATERIALGROUP = C.MATERIALGROUP*/
                                      GROUP BY A.UPN))) *
                           ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                           NVL((COUNT(*) * MAX(STAND) /
                               (SELECT SUM(ALLSTAND)
                                   FROM (SELECT A.UPN,
                                                COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                           FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                                PPFSTDTIMEHEAD                  B,
                                                SFCMODEL                        C
                                          WHERE A.TRNDATE BETWEEN
                                                PAR_STARTTIME AND PAR_ENDTIME
                                            AND PASSCOUNT = 1
                                            AND INSTR(PAR_LINE, A.LINE) > 0
                                            AND INSTR(PAR_STAGE, STAGE) > 0
                                            AND INSTR(PAR_NONWORKSTATION,
                                                      A.WORKSTATION) <= 0
                                            AND A.MODELFAMILY = B.MODELFAMILY
                                            AND (A.UPN = B.UPN OR
                                                (B.UPN = '*' AND
                                                A.UPN NOT IN
                                                (SELECT UPN
                                                     FROM PPFSTDTIMEHEAD
                                                    WHERE LINE =
                                                          PAR_PCBMAINLINE)))
                                            AND B.LINE = PAR_PCBMAINLINE
                                            AND A.MODELFAMILY = C.MODELFAMILY
                                            AND A.UPN = C.UPN
                                            /*AND B.MATERIALGROUP =
                                                C.MATERIALGROUP*/
                                          GROUP BY A.UPN))),
                               0) * MAX(D.STOPHOUR) * MAX(B.TARGET)) TARGETALL
                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                     PPFSTANDARDPROD B,
                     SFCMODEL C,
                     (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                    '',
                                    0,
                                    (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                             ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                              (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                             LINE
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D,
                     (SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                        FROM PPFSTDTIMEHEAD
                       WHERE LINE = PAR_PCBMAINLINE) G
               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                 AND PASSCOUNT = 1
                 AND INSTR(PAR_LINE, A.LINE) > 0
                 AND INSTR(PAR_STAGE, STAGE) > 0
                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                 AND A.LINE = B.LINE
                 AND A.MODELFAMILY = B.MODELFAMILY
                 AND B.MATERIALGROUP = C.MATERIALGROUP
                 AND B.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND A.LINE = D.LINE
                 AND A.MODELFAMILY = G.MODELFAMILY
                 /*AND B.MATERIALGROUP = G.MATERIALGROUP*/
                 AND (A.UPN = G.UPN OR
                     (G.UPN = '*' AND
                     A.UPN NOT IN
                     (SELECT UPN
                          FROM PPFSTDTIMEHEAD
                         WHERE LINE = PAR_PCBMAINLINE)))
               GROUP BY A.UPN, A.LINE);
    ELSIF PAR_CYC = '0' AND PAR_STATUS = '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND((COUNT(*) * MAX(STAND) /
                           (SELECT SUM(ALLSTAND)
                               FROM (SELECT A.UPN,
                                            COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            PPFSTDTIMEHEAD                  B,
                                            SFCMODEL                        C
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND A.MODELFAMILY = B.MODELFAMILY
                                        AND (A.UPN = B.UPN OR
                                            (B.UPN = '*' AND
                                            A.UPN NOT IN
                                            (SELECT UPN
                                                 FROM PPFSTDTIMEHEAD
                                                WHERE LINE = PAR_PCBMAINLINE)))
                                        AND B.LINE = PAR_PCBMAINLINE
                                        AND A.MODELFAMILY = C.MODELFAMILY
                                        AND A.UPN = C.UPN
                                        /*AND B.MATERIALGROUP = C.MATERIALGROUP*/
                                      GROUP BY A.UPN))) *
                           ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                           NVL((COUNT(*) * MAX(STAND) /
                               (SELECT SUM(ALLSTAND)
                                   FROM (SELECT A.UPN,
                                                COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                           FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                                PPFSTDTIMEHEAD                  B,
                                                SFCMODEL                        C
                                          WHERE A.TRNDATE BETWEEN
                                                PAR_STARTTIME AND PAR_ENDTIME
                                            AND PASSCOUNT = 1
                                            AND INSTR(PAR_LINE, A.LINE) > 0
                                            AND INSTR(PAR_STAGE, STAGE) > 0
                                            AND INSTR(PAR_NONWORKSTATION,
                                                      A.WORKSTATION) <= 0
                                            AND A.MODELFAMILY = B.MODELFAMILY
                                            AND (A.UPN = B.UPN OR
                                                (B.UPN = '*' AND
                                                A.UPN NOT IN
                                                (SELECT UPN
                                                     FROM PPFSTDTIMEHEAD
                                                    WHERE LINE =
                                                          PAR_PCBMAINLINE)))
                                            AND B.LINE = PAR_PCBMAINLINE
                                            AND A.MODELFAMILY = C.MODELFAMILY
                                            AND A.UPN = C.UPN
                                            /*AND B.MATERIALGROUP =
                                                C.MATERIALGROUP*/
                                          GROUP BY A.UPN))),
                               0) * MAX(D.STOPHOUR) * MAX(B.TARGET)) /
                     MAX(E.HEADCOUNT) TARGETALL
                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                     PPFSTANDARDPROD B,
                     SFCMODEL C,
                     (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                    '',
                                    0,
                                    (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                             ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                              (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                             LINE
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D,
                     (SELECT LINE,
                             UPN,
                             MODELFAMILY,
                             MATERIALGROUP,
                             SUM(HEADCOUNT) HEADCOUNT
                        FROM PPFSTDTIMEDETAIL
                       WHERE INSTR(PAR_LINE, LINE) > 0
                       GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) E,
                     (SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                        FROM PPFSTDTIMEHEAD
                       WHERE LINE = PAR_PCBMAINLINE) G
               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                 AND PASSCOUNT = 1
                 AND INSTR(PAR_LINE, A.LINE) > 0
                 AND INSTR(PAR_STAGE, STAGE) > 0
                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                 AND A.LINE = B.LINE
                 AND A.MODELFAMILY = B.MODELFAMILY
                 AND B.MATERIALGROUP = C.MATERIALGROUP
                 AND B.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND A.LINE = D.LINE
                 AND A.LINE = E.LINE
                 AND (A.UPN = E.UPN OR
                     (A.UPN NOT IN (SELECT UPN FROM PPFSTDTIMEDETAIL) AND
                     E.UPN = '*'))
                 AND A.MODELFAMILY = E.MODELFAMILY
                 AND E.MATERIALGROUP = C.MATERIALGROUP
                 AND E.MODELFAMILY = C.MODELFAMILY
                 AND A.MODELFAMILY = G.MODELFAMILY
                 /*AND B.MATERIALGROUP = G.MATERIALGROUP*/
                 AND (A.UPN = G.UPN OR
                     (G.UPN = '*' AND
                     A.UPN NOT IN
                     (SELECT UPN
                          FROM PPFSTDTIMEHEAD
                         WHERE LINE = PAR_PCBMAINLINE)))
               GROUP BY A.UPN, A.LINE);
    ELSIF PAR_CYC = '1' AND PAR_UNITPER = '0' AND PAR_PCBSMT = '1' AND
          PAR_STATUS <> '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND((COUNT(*) * MAX(B.CYC) /
                           (SELECT SUM(ALLSTAND)
                               FROM (SELECT A.UPN,
                                            COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            (SELECT B.UPN,
                                                    A.LINE,
                                                    MAX(CYCLETIME) CYCLETIME
                                               FROM PPFSMTSTDTIMEHEAD A,
                                                    PPFPARENTCHILDSET B
                                              WHERE A.CHILDPN = B.CHILDPN
                                                AND INSTR(PAR_LINE, A.LINE) > 0
                                              GROUP BY A.LINE, B.UPN) B,
                                            SFCMODEL C
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND (A.UPN = B.UPN OR
                                            (B.UPN = '*' AND
                                            (A.UPN, A.LINE) NOT IN
                                            (SELECT B.UPN, A.LINE
                                                 FROM PPFSMTSTDTIMEHEAD A,
                                                      PPFPARENTCHILDSET B
                                                WHERE A.CHILDPN = B.CHILDPN
                                                  AND INSTR(PAR_LINE, A.LINE) > 0
                                                GROUP BY A.LINE, B.UPN)))
                                        AND B.LINE = A.LINE
                                        AND A.MODELFAMILY = C.MODELFAMILY
                                        AND A.UPN = C.UPN
                                      GROUP BY A.UPN))) *
                           ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                           NVL((COUNT(*) * MAX(B.CYC) /
                               (SELECT SUM(ALLSTAND)
                                   FROM (SELECT A.UPN,
                                                COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                           FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                                PPFSTDTIMEHEAD                  B,
                                                SFCMODEL                        C
                                          WHERE A.TRNDATE BETWEEN
                                                PAR_STARTTIME AND PAR_ENDTIME
                                            AND PASSCOUNT = 1
                                            AND INSTR(PAR_LINE, A.LINE) > 0
                                            AND INSTR(PAR_STAGE, STAGE) > 0
                                            AND INSTR(PAR_NONWORKSTATION,
                                                      A.WORKSTATION) <= 0
                                            AND A.MODELFAMILY = B.MODELFAMILY
                                            AND (A.UPN = B.UPN OR
                                                (B.UPN = '*' AND
                                                A.UPN NOT IN
                                                (SELECT UPN
                                                     FROM PPFSTDTIMEHEAD
                                                    WHERE LINE =
                                                          PAR_PCBMAINLINE)))
                                            AND B.LINE = PAR_PCBMAINLINE
                                            AND A.MODELFAMILY = C.MODELFAMILY
                                            AND A.UPN = C.UPN
                                            /*AND B.MATERIALGROUP =
                                                C.MATERIALGROUP*/
                                          GROUP BY A.UPN))),
                               0) * MAX(D.STOPHOUR) * MAX(B.TARGET)) TARGETALL
                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                     (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) TARGET,
                             B.UPN,
                             A.LINE,
                             MAX(CYCLETIME) CYC
                        FROM PPFSMTSTDTIMEHEAD A, PPFPARENTCHILDSET B
                       WHERE A.CHILDPN = B.CHILDPN
                         AND INSTR(PAR_LINE, A.LINE) > 0
                       GROUP BY A.LINE, B.UPN) B,
                     SFCMODEL C,
                     (SELECT MIN(DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                        '',
                                        0,
                                        (SUM(BREAKTIME) / PAR_BREAKTIMEPER))) *
                             ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                              (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D
               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                 AND PASSCOUNT = 1
                 AND INSTR(PAR_LINE, A.LINE) > 0
                 AND INSTR(PAR_STAGE, STAGE) > 0
                 AND A.LINE = B.LINE
                 AND A.UPN = B.UPN
                 AND A.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
               GROUP BY A.UPN, A.LINE);
    ELSIF PAR_CYC = '1' AND PAR_UNITPER = '0' AND PAR_PCBSMT = '1' AND
          PAR_STATUS = '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND((COUNT(*) * MAX(B.CYC) /
                           (SELECT SUM(ALLSTAND)
                               FROM (SELECT A.UPN,
                                            COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            (SELECT B.UPN,
                                                    A.LINE,
                                                    MAX(CYCLETIME) CYCLETIME
                                               FROM PPFSMTSTDTIMEHEAD A,
                                                    PPFPARENTCHILDSET B
                                              WHERE A.CHILDPN = B.CHILDPN
                                                AND INSTR(PAR_LINE, A.LINE) > 0
                                              GROUP BY A.LINE, B.UPN) B,
                                            SFCMODEL C
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND (A.UPN = B.UPN OR
                                            (B.UPN = '*' AND
                                            (A.UPN, A.LINE) NOT IN
                                            (SELECT B.UPN, A.LINE
                                                 FROM PPFSMTSTDTIMEHEAD A,
                                                      PPFPARENTCHILDSET B
                                                WHERE A.CHILDPN = B.CHILDPN
                                                  AND INSTR(PAR_LINE, A.LINE) > 0
                                                GROUP BY A.LINE, B.UPN)))
                                        AND B.LINE = PAR_PCBMAINLINE
                                        AND A.MODELFAMILY = C.MODELFAMILY
                                        AND A.UPN = C.UPN
                                      GROUP BY A.UPN))) *
                           ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                           NVL((COUNT(*) * MAX(B.CYC) /
                               (SELECT SUM(ALLSTAND)
                                   FROM (SELECT A.UPN,
                                                COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                           FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                                PPFSTDTIMEHEAD                  B,
                                                SFCMODEL                        C
                                          WHERE A.TRNDATE BETWEEN
                                                PAR_STARTTIME AND PAR_ENDTIME
                                            AND PASSCOUNT = 1
                                            AND INSTR(PAR_LINE, A.LINE) > 0
                                            AND INSTR(PAR_STAGE, STAGE) > 0
                                            AND INSTR(PAR_NONWORKSTATION,
                                                      A.WORKSTATION) <= 0
                                            AND A.MODELFAMILY = B.MODELFAMILY
                                            AND (A.UPN = B.UPN OR
                                                (B.UPN = '*' AND
                                                A.UPN NOT IN
                                                (SELECT UPN
                                                     FROM PPFSTDTIMEHEAD
                                                    WHERE LINE =
                                                          PAR_PCBMAINLINE)))
                                            AND B.LINE = PAR_PCBMAINLINE
                                            AND A.MODELFAMILY = C.MODELFAMILY
                                            AND A.UPN = C.UPN
                                            /*AND B.MATERIALGROUP =
                                                C.MATERIALGROUP*/
                                          GROUP BY A.UPN))),
                               0) * MAX(D.STOPHOUR) * MAX(B.TARGET)) /
                     MAX(E.HEADCOUNT) TARGETALL
                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                     (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) TARGET,
                             B.UPN,
                             A.LINE,
                             MAX(CYCLETIME) CYC
                        FROM PPFSMTSTDTIMEHEAD A, PPFPARENTCHILDSET B
                       WHERE A.CHILDPN = B.CHILDPN
                         AND INSTR(PAR_LINE, A.LINE) > 0
                       GROUP BY A.LINE, B.UPN) B,
                     SFCMODEL C,
                     (SELECT MIN(DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                        '',
                                        0,
                                        (SUM(BREAKTIME) / PAR_BREAKTIMEPER))) *
                             ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                              (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D,
                     (SELECT LINE,
                             UPN,
                             MODELFAMILY,
                             MATERIALGROUP,
                             SUM(HEADCOUNT) HEADCOUNT
                        FROM PPFSTDTIMEDETAIL
                       WHERE INSTR(PAR_LINE, LINE) > 0
                       GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) E
               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                 AND PASSCOUNT = 1
                 AND INSTR(PAR_LINE, A.LINE) > 0
                 AND INSTR(PAR_STAGE, STAGE) > 0
                 AND A.LINE = B.LINE
                 AND A.UPN = B.UPN
                 AND A.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                 AND A.LINE = E.LINE
                 AND (A.UPN = E.UPN OR
                     (A.UPN NOT IN (SELECT UPN FROM PPFSTDTIMEDETAIL) AND
                     E.UPN = '*'))
                 AND A.MODELFAMILY = E.MODELFAMILY
                 AND E.MATERIALGROUP = C.MATERIALGROUP
                 AND E.MODELFAMILY = C.MODELFAMILY
               GROUP BY A.UPN, A.LINE);
    ELSIF PAR_CYC = '1' AND PAR_UNITPER = '1' AND PAR_PCBSMT = '1' AND
          PAR_STATUS <> '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND(((MAX(UPNCOUNT) * MAX(B.CYC)) /
                           (SELECT SUM(CON)
                               FROM (SELECT COUNT(*) * MAX(C.CYCLETIME) CON
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            SFCPCB139.SFCUPNINFO B,
                                            (SELECT B.UPN,
                                                    A.LINE,
                                                    MAX(CYCLETIME) CYCLETIME
                                               FROM PPFSMTSTDTIMEHEAD A,
                                                    PPFPARENTCHILDSET B
                                              WHERE A.CHILDPN = B.CHILDPN
                                                AND INSTR(PAR_LINE, A.LINE) > 0
                                              GROUP BY A.LINE, B.UPN) C,
                                            SFCMODEL D
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND A.UPN = B.UPN
                                        AND (A.UPN = C.UPN OR
                                            (C.UPN = '*' AND
                                            (A.UPN, A.LINE) NOT IN
                                            (SELECT B.UPN, A.LINE
                                                 FROM PPFSMTSTDTIMEHEAD A,
                                                      PPFPARENTCHILDSET B
                                                WHERE A.CHILDPN = B.CHILDPN
                                                  AND INSTR(PAR_LINE, A.LINE) > 0
                                                GROUP BY A.LINE, B.UPN)))
                                        AND C.LINE = A.LINE
                                        AND A.MODELFAMILY = D.MODELFAMILY
                                        AND A.UPN = D.UPN
                                        AND (MO NOT IN
                                            (SELECT MO
                                                FROM SFCPCB139.SFCMOUSNVICE) OR
                                            (MO, USN) IN
                                            (SELECT MO, VICEUSN
                                                FROM SFCPCB139.SFCMOUSNVICE))
                                      GROUP BY A.UPN
                                     UNION
                                     SELECT COUNT(*) * MAX(C.CYCLETIME) *
                                            MAX(B.UNITPERPCB) CON
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            SFCPCB139.SFCUPNINFO B,
                                            (SELECT B.UPN,
                                                    A.LINE,
                                                    MAX(CYCLETIME) CYCLETIME
                                               FROM PPFSMTSTDTIMEHEAD A,
                                                    PPFPARENTCHILDSET B
                                              WHERE A.CHILDPN = B.CHILDPN
                                                AND INSTR(PAR_LINE, A.LINE) > 0
                                              GROUP BY A.LINE, B.UPN) C,
                                            SFCMODEL D
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND A.UPN = B.UPN
                                        AND (A.UPN = C.UPN OR
                                            (C.UPN = '*' AND
                                            (A.UPN, A.LINE) NOT IN
                                            (SELECT B.UPN, A.LINE
                                                 FROM PPFSMTSTDTIMEHEAD A,
                                                      PPFPARENTCHILDSET B
                                                WHERE A.CHILDPN = B.CHILDPN
                                                  AND INSTR(PAR_LINE, A.LINE) > 0
                                                GROUP BY A.LINE, B.UPN)))
                                        AND C.LINE = A.LINE
                                        AND A.MODELFAMILY = D.MODELFAMILY
                                        AND A.UPN = D.UPN
                                        AND MO IN
                                            (SELECT MO
                                               FROM SFCPCB139.SFCMOUSNVICE)
                                        AND (MO, USN) NOT IN
                                            (SELECT MO, VICEUSN
                                               FROM SFCPCB139.SFCMOUSNVICE)
                                      GROUP BY A.UPN))) *
                           ((MAX(B.STAND) * MAX(E.UNITPERPCB) *
                           (SELECT (PAR_ENDTIME - PAR_STARTTIME) * 24 TARTETTIME
                                FROM DUAL))) -
                           MAX(D.STOPHOUR) * MAX(B.STAND) *
                           MAX(E.UNITPERPCB)) TARGETALL
                FROM (SELECT DISTINCT UPN,
                                      LINE,
                                      MODELFAMILY,
                                      MODEL,
                                      SUM(CON) UPNCOUNT
                        FROM (SELECT A.UPN,
                                     A.LINE,
                                     A.MODELFAMILY,
                                     A.MODEL,
                                     COUNT(*) CON
                                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A
                               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                     PAR_ENDTIME
                                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                                 AND PASSCOUNT = 1
                                 AND INSTR(PAR_LINE, A.LINE) > 0
                                 AND INSTR(PAR_STAGE, STAGE) > 0
                                 AND (MO NOT IN
                                     (SELECT MO FROM SFCPCB139.SFCMOUSNVICE) OR
                                     (MO, USN) IN
                                     (SELECT MO, VICEUSN
                                         FROM SFCPCB139.SFCMOUSNVICE))
                               GROUP BY A.UPN, A.LINE, A.MODELFAMILY, A.MODEL
                              UNION
                              SELECT A.UPN,
                                     A.LINE,
                                     A.MODELFAMILY,
                                     A.MODEL,
                                     COUNT(*) * MAX(B.UNITPERPCB) CON
                                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                     SFCPCB139.SFCUPNINFO            B
                               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                     PAR_ENDTIME
                                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                                 AND PASSCOUNT = 1
                                 AND INSTR(PAR_LINE, A.LINE) > 0
                                 AND INSTR(PAR_STAGE, STAGE) > 0
                                 AND A.UPN = B.UPN
                                 AND A.MO IN
                                     (SELECT MO FROM SFCPCB139.SFCMOUSNVICE)
                                 AND (MO, USN) NOT IN
                                     (SELECT MO, VICEUSN
                                        FROM SFCPCB139.SFCMOUSNVICE)
                               GROUP BY A.UPN, A.LINE, A.MODELFAMILY, A.MODEL)
                       GROUP BY UPN, LINE, MODELFAMILY, MODEL) A,
                     (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) STAND,
                             B.UPN,
                             A.LINE,
                             MAX(CYCLETIME) CYC
                        FROM PPFSMTSTDTIMEHEAD A, PPFPARENTCHILDSET B
                       WHERE A.CHILDPN = B.CHILDPN
                         AND INSTR(PAR_LINE, A.LINE) > 0
                       GROUP BY A.LINE, B.UPN) B,
                     SFCMODEL C,
                     (SELECT MIN(DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                        '',
                                        0,
                                        (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                                 ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                                  (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME))) STOPHOUR
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D,
                     SFCPCB139.SFCUPNINFO E
               WHERE A.LINE = B.LINE
                 AND A.UPN = B.UPN
                 AND A.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND A.UPN = E.UPN
               GROUP BY A.UPN, A.LINE);
    ELSIF PAR_CYC = '1' AND PAR_UNITPER = '1' AND PAR_PCBSMT = '1' AND
          PAR_STATUS = '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND(((MAX(UPNCOUNT) * MAX(B.CYC)) /
                           (SELECT SUM(CON)
                               FROM (SELECT COUNT(*) * MAX(C.CYCLETIME) CON
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            SFCPCB139.SFCUPNINFO B,
                                            (SELECT B.UPN,
                                                    A.LINE,
                                                    MAX(CYCLETIME) CYCLETIME
                                               FROM PPFSMTSTDTIMEHEAD A,
                                                    PPFPARENTCHILDSET B
                                              WHERE A.CHILDPN = B.CHILDPN
                                                AND INSTR(PAR_LINE, A.LINE) > 0
                                              GROUP BY A.LINE, B.UPN) C,
                                            SFCMODEL D
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND A.UPN = B.UPN
                                        AND (A.UPN = C.UPN OR
                                            (C.UPN = '*' AND
                                            (A.UPN, A.LINE) NOT IN
                                            (SELECT B.UPN, A.LINE
                                                 FROM PPFSMTSTDTIMEHEAD A,
                                                      PPFPARENTCHILDSET B
                                                WHERE A.CHILDPN = B.CHILDPN
                                                  AND INSTR(PAR_LINE, A.LINE) > 0
                                                GROUP BY A.LINE, B.UPN)))
                                        AND C.LINE = A.LINE
                                        AND A.MODELFAMILY = D.MODELFAMILY
                                        AND A.UPN = D.UPN
                                        AND (MO NOT IN
                                            (SELECT MO
                                                FROM SFCPCB139.SFCMOUSNVICE) OR
                                            (MO, USN) IN
                                            (SELECT MO, VICEUSN
                                                FROM SFCPCB139.SFCMOUSNVICE))
                                      GROUP BY A.UPN
                                     UNION
                                     SELECT COUNT(*) * MAX(C.CYCLETIME) *
                                            MAX(B.UNITPERPCB) CON
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            SFCPCB139.SFCUPNINFO B,
                                            (SELECT B.UPN,
                                                    A.LINE,
                                                    MAX(CYCLETIME) CYCLETIME
                                               FROM PPFSMTSTDTIMEHEAD A,
                                                    PPFPARENTCHILDSET B
                                              WHERE A.CHILDPN = B.CHILDPN
                                                AND INSTR(PAR_LINE, A.LINE) > 0
                                              GROUP BY A.LINE, B.UPN) C,
                                            SFCMODEL D
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND A.UPN = B.UPN
                                        AND (A.UPN = C.UPN OR
                                            (C.UPN = '*' AND
                                            (A.UPN, A.LINE) NOT IN
                                            (SELECT B.UPN, A.LINE
                                                 FROM PPFSMTSTDTIMEHEAD A,
                                                      PPFPARENTCHILDSET B
                                                WHERE A.CHILDPN = B.CHILDPN
                                                  AND INSTR(PAR_LINE, A.LINE) > 0
                                                GROUP BY A.LINE, B.UPN)))
                                        AND C.LINE = A.LINE
                                        AND A.MODELFAMILY = D.MODELFAMILY
                                        AND A.UPN = D.UPN
                                        AND MO IN
                                            (SELECT MO
                                               FROM SFCPCB139.SFCMOUSNVICE)
                                        AND (MO, USN) NOT IN
                                            (SELECT MO, VICEUSN
                                               FROM SFCPCB139.SFCMOUSNVICE)
                                      GROUP BY A.UPN))) *
                           ((MAX(B.STAND) * MAX(E.UNITPERPCB) *
                           (SELECT (PAR_ENDTIME - PAR_STARTTIME) * 24 TARTETTIME
                                FROM DUAL))) -
                           MAX(D.STOPHOUR) * MAX(B.STAND) *
                           MAX(E.UNITPERPCB)) / MAX(F.HEADCOUNT) TARGETALL
                FROM (SELECT DISTINCT UPN,
                                      LINE,
                                      MODELFAMILY,
                                      MODEL,
                                      SUM(CON) UPNCOUNT
                        FROM (SELECT A.UPN,
                                     A.LINE,
                                     A.MODELFAMILY,
                                     A.MODEL,
                                     COUNT(*) CON
                                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A
                               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                     PAR_ENDTIME
                                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                                 AND PASSCOUNT = 1
                                 AND INSTR(PAR_LINE, A.LINE) > 0
                                 AND INSTR(PAR_STAGE, STAGE) > 0
                                 AND (MO NOT IN
                                     (SELECT MO FROM SFCPCB139.SFCMOUSNVICE) OR
                                     (MO, USN) IN
                                     (SELECT MO, VICEUSN
                                         FROM SFCPCB139.SFCMOUSNVICE))
                               GROUP BY A.UPN, A.LINE, A.MODELFAMILY, A.MODEL
                              UNION
                              SELECT A.UPN,
                                     A.LINE,
                                     A.MODELFAMILY,
                                     A.MODEL,
                                     COUNT(*) * MAX(B.UNITPERPCB) CON
                                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                     SFCPCB139.SFCUPNINFO            B
                               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                     PAR_ENDTIME
                                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                                 AND PASSCOUNT = 1
                                 AND INSTR(PAR_LINE, A.LINE) > 0
                                 AND INSTR(PAR_STAGE, STAGE) > 0
                                 AND A.UPN = B.UPN
                                 AND A.MO IN
                                     (SELECT MO FROM SFCPCB139.SFCMOUSNVICE)
                                 AND (MO, USN) NOT IN
                                     (SELECT MO, VICEUSN
                                        FROM SFCPCB139.SFCMOUSNVICE)
                               GROUP BY A.UPN, A.LINE, A.MODELFAMILY, A.MODEL)
                       GROUP BY UPN, LINE, MODELFAMILY, MODEL) A,
                     (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) STAND,
                             B.UPN,
                             A.LINE,
                             MAX(CYCLETIME) CYC
                        FROM PPFSMTSTDTIMEHEAD A, PPFPARENTCHILDSET B
                       WHERE A.CHILDPN = B.CHILDPN
                         AND INSTR(PAR_LINE, A.LINE) > 0
                       GROUP BY A.LINE, B.UPN) B,
                     SFCMODEL C,
                     (SELECT MIN(DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                        '',
                                        0,
                                        (SUM(BREAKTIME) / PAR_BREAKTIMEPER))) *
                             ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                              (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D,
                     SFCPCB139.SFCUPNINFO E,
                     (SELECT LINE,
                             UPN,
                             MODELFAMILY,
                             MATERIALGROUP,
                             SUM(HEADCOUNT) HEADCOUNT
                        FROM PPFSTDTIMEDETAIL
                       WHERE LINE = PAR_PCBMAINLINE
                       GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) F
               WHERE A.LINE = B.LINE
                 AND A.UPN = B.UPN
                 AND A.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND A.UPN = E.UPN
                 AND (A.UPN = F.UPN OR
                     (A.UPN NOT IN (SELECT UPN FROM PPFSTDTIMEDETAIL) AND
                     F.UPN = '*'))
                 AND A.MODELFAMILY = F.MODELFAMILY
                 AND F.MATERIALGROUP = C.MATERIALGROUP
                 AND F.MODELFAMILY = C.MODELFAMILY
               GROUP BY A.UPN, A.LINE);
    ELSIF PAR_CYC = '1' AND PAR_PCBSMT = '0' AND PAR_STATUS <> '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND((COUNT(*) * MAX(G.STAND) /
                           (SELECT SUM(ALLSTAND)
                               FROM (SELECT A.UPN,
                                            COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            PPFSTDTIMEHEAD                  B,
                                            SFCMODEL                        C
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND A.MODELFAMILY = B.MODELFAMILY
                                        AND (A.UPN = B.UPN OR
                                            (B.UPN = '*' AND
                                            A.UPN NOT IN
                                            (SELECT UPN
                                                 FROM PPFSTDTIMEHEAD
                                                WHERE LINE = PAR_PCBMAINLINE)))
                                        AND B.LINE = PAR_PCBMAINLINE
                                        AND A.MODELFAMILY = C.MODELFAMILY
                                        AND A.UPN = C.UPN
                                        /*AND B.MATERIALGROUP = C.MATERIALGROUP*/
                                      GROUP BY A.UPN))) *
                           ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                           NVL((COUNT(*) * MAX(G.STAND) /
                               (SELECT SUM(ALLSTAND)
                                   FROM (SELECT A.UPN,
                                                COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                           FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                                PPFSTDTIMEHEAD                  B,
                                                SFCMODEL                        C
                                          WHERE A.TRNDATE BETWEEN
                                                PAR_STARTTIME AND PAR_ENDTIME
                                            AND INSTR(PAR_NONWORKSTATION,
                                                      A.WORKSTATION) <= 0
                                            AND PASSCOUNT = 1
                                            AND INSTR(PAR_LINE, A.LINE) > 0
                                            AND INSTR(PAR_STAGE, STAGE) > 0
                                            AND A.MODELFAMILY = B.MODELFAMILY
                                            AND (A.UPN = B.UPN OR
                                                (B.UPN = '*' AND
                                                A.UPN NOT IN
                                                (SELECT UPN
                                                     FROM PPFSTDTIMEHEAD
                                                    WHERE LINE =
                                                          PAR_PCBMAINLINE)))
                                            AND B.LINE = PAR_PCBMAINLINE
                                            AND A.MODELFAMILY = C.MODELFAMILY
                                            AND A.UPN = C.UPN
                                            /*AND B.MATERIALGROUP =
                                                C.MATERIALGROUP*/
                                          GROUP BY A.UPN))),
                               0) * MAX(D.STOPHOUR) * MAX(B.TARGET)) TARGETALL
                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                     (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) TARGET,
                             LINE,
                             MODELFAMILY,
                             MATERIALGROUP,
                             UPN
                        FROM PPFSTDTIMEHEAD
                       WHERE INSTR(PAR_LINE, LINE) > 0 HAVING
                       MAX(CYCLETIME) <> 0
                       GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) B,
                     SFCMODEL C,
                     (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                    '',
                                    0,
                                    (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                             ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                              (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                             LINE
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D,
                     (SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                        FROM PPFSTDTIMEHEAD
                       WHERE LINE = PAR_PCBMAINLINE) G
               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                 AND PASSCOUNT = 1
                 AND INSTR(PAR_LINE, A.LINE) > 0
                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                 AND INSTR(PAR_STAGE, STAGE) > 0
                 AND A.LINE = B.LINE
                 AND (A.UPN = B.UPN OR
                     (A.UPN NOT IN
                     (SELECT UPN FROM PPFSTDTIMEHEAD WHERE LINE = PAR_LINE) AND
                     B.UPN = '*'))
                 AND A.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND A.LINE = D.LINE
                 AND A.MODELFAMILY = B.MODELFAMILY
                 /*AND C.MATERIALGROUP = B.MATERIALGROUP*/
                 AND A.MODELFAMILY = G.MODELFAMILY
                 /*AND C.MATERIALGROUP = G.MATERIALGROUP*/
                 AND (A.UPN = G.UPN OR
                     (G.UPN = '*' AND
                     A.UPN NOT IN
                     (SELECT UPN
                          FROM PPFSTDTIMEHEAD
                         WHERE LINE = PAR_PCBMAINLINE)))
               GROUP BY A.UPN, A.LINE);
    ELSIF PAR_CYC = '1' AND PAR_PCBSMT = '0' AND PAR_STATUS = '3' THEN
      SELECT DECODE(SUM(TARGETALL), '', 0, SUM(TARGETALL)) TARGET
        INTO VAR_TARGET
        FROM (SELECT A.UPN,
                     ROUND((COUNT(*) * MAX(G.STAND) /
                           (SELECT SUM(ALLSTAND)
                               FROM (SELECT A.UPN,
                                            COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                       FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                            PPFSTDTIMEHEAD                  B,
                                            SFCMODEL                        C
                                      WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND
                                            PAR_ENDTIME
                                        AND INSTR(PAR_NONWORKSTATION,
                                                  A.WORKSTATION) <= 0
                                        AND PASSCOUNT = 1
                                        AND INSTR(PAR_LINE, A.LINE) > 0
                                        AND INSTR(PAR_STAGE, STAGE) > 0
                                        AND A.MODELFAMILY = B.MODELFAMILY
                                        AND (A.UPN = B.UPN OR
                                            (B.UPN = '*' AND
                                            A.UPN NOT IN
                                            (SELECT UPN
                                                 FROM PPFSTDTIMEHEAD
                                                WHERE LINE = PAR_PCBMAINLINE)))
                                        AND B.LINE = PAR_PCBMAINLINE
                                        AND A.MODELFAMILY = C.MODELFAMILY
                                        AND A.UPN = C.UPN
                                        /*AND B.MATERIALGROUP = C.MATERIALGROUP*/
                                      GROUP BY A.UPN))) *
                           ((MAX(B.TARGET) * (PAR_ENDTIME - PAR_STARTTIME) * 24)) -
                           NVL((COUNT(*) * MAX(G.STAND) /
                               (SELECT SUM(ALLSTAND)
                                   FROM (SELECT A.UPN,
                                                COUNT(*) * MAX(B.CYCLETIME) ALLSTAND
                                           FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                                                PPFSTDTIMEHEAD                  B,
                                                SFCMODEL                        C
                                          WHERE A.TRNDATE BETWEEN
                                                PAR_STARTTIME AND PAR_ENDTIME
                                            AND INSTR(PAR_NONWORKSTATION,
                                                      A.WORKSTATION) <= 0
                                            AND PASSCOUNT = 1
                                            AND INSTR(PAR_LINE, A.LINE) > 0
                                            AND INSTR(PAR_STAGE, STAGE) > 0
                                            AND A.MODELFAMILY = B.MODELFAMILY
                                            AND (A.UPN = B.UPN OR
                                                (B.UPN = '*' AND
                                                A.UPN NOT IN
                                                (SELECT UPN
                                                     FROM PPFSTDTIMEHEAD
                                                    WHERE LINE =
                                                          PAR_PCBMAINLINE)))
                                            AND B.LINE = PAR_PCBMAINLINE
                                            AND A.MODELFAMILY = C.MODELFAMILY
                                            AND A.UPN = C.UPN
                                            /*AND B.MATERIALGROUP =
                                                C.MATERIALGROUP*/
                                          GROUP BY A.UPN))),
                               0) * MAX(D.STOPHOUR) * MAX(B.TARGET)) /
                     MAX(E.HEADCOUNT) TARGETALL
                FROM SFCMIPCB139.SFCTRANSACTIONCACHE A,
                     (SELECT ROUND((60 * 60) / MAX(CYCLETIME)) TARGET,
                             LINE,
                             MODELFAMILY,
                             MATERIALGROUP,
                             UPN
                        FROM PPFSTDTIMEHEAD
                       WHERE INSTR(PAR_LINE, LINE) > 0 HAVING
                       MAX(CYCLETIME) <> 0
                       GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) B,
                     SFCMODEL C,
                     (SELECT DECODE((SUM(BREAKTIME) / PAR_BREAKTIMEPER),
                                    '',
                                    0,
                                    (SUM(BREAKTIME) / PAR_BREAKTIMEPER)) *
                             ((PAR_ENDTIME - VAR_PERIODSTARTTIME) /
                              (VAR_PERIODENDTIME - VAR_PERIODSTARTTIME)) STOPHOUR,
                             LINE
                        FROM PPFPRODPERIOD
                       WHERE PERIODNO = PAR_PERIODNO
                         AND SHIFT = PAR_SHIFT
                       GROUP BY LINE) D,
                     (SELECT LINE,
                             UPN,
                             MODELFAMILY,
                             MATERIALGROUP,
                             SUM(HEADCOUNT) HEADCOUNT
                        FROM PPFSTDTIMEDETAIL
                       WHERE INSTR(PAR_LINE, LINE) > 0
                       GROUP BY LINE, UPN, MODELFAMILY, MATERIALGROUP) E,
                     (SELECT UPN, MODELFAMILY, MATERIALGROUP, CYCLETIME STAND
                        FROM PPFSTDTIMEHEAD
                       WHERE LINE = PAR_PCBMAINLINE) G
               WHERE A.TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
                 AND PASSCOUNT = 1
                 AND INSTR(PAR_LINE, A.LINE) > 0
                 AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
                 AND INSTR(PAR_STAGE, STAGE) > 0
                 AND A.LINE = B.LINE
                 AND (A.UPN = B.UPN OR
                     (A.UPN NOT IN
                     (SELECT UPN FROM PPFSTDTIMEHEAD WHERE LINE = PAR_LINE) AND
                     B.UPN = '*'))
                 AND A.MODELFAMILY = C.MODELFAMILY
                 AND A.UPN = C.UPN
                 AND A.LINE = D.LINE
                 AND A.MODELFAMILY = B.MODELFAMILY
                 /*AND C.MATERIALGROUP = B.MATERIALGROUP*/
                 AND A.LINE = E.LINE
                 AND (A.UPN = E.UPN OR
                     (A.UPN NOT IN (SELECT UPN FROM PPFSTDTIMEDETAIL) AND
                     E.UPN = '*'))
                 AND A.MODELFAMILY = E.MODELFAMILY
                 AND E.MATERIALGROUP = C.MATERIALGROUP
                 AND E.MODELFAMILY = C.MODELFAMILY
                 AND A.MODELFAMILY = G.MODELFAMILY
                 /*AND C.MATERIALGROUP = G.MATERIALGROUP*/
                 AND (A.UPN = G.UPN OR
                     (G.UPN = '*' AND
                     A.UPN NOT IN
                     (SELECT UPN
                          FROM PPFSTDTIMEHEAD
                         WHERE LINE = PAR_PCBMAINLINE)))
               GROUP BY A.UPN, A.LINE);
    END IF;
  END IF;
  RETURN VAR_TARGET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN VAR_TARGET;
END;
/
