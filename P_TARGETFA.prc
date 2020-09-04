CREATE OR REPLACE PROCEDURE P_TARGETFA
/*
  =================================================================================================
  version           date         author                    description
  v3.0.0.0          2014/07/15     by oscar
  v3.0.0.0          2015/01/20     by Shining  šß          ²K¥[OOB¤£¨}²vªº­pºâ
  v3.0.0.1          2015/04/22     by Shining  šß          ²K¥[­pºâ·í«eMO INFO
  v3.0.0.2         2015/04/23     by Shining  šß           ­×§ï­pºâFPYRÅÞ¿è¡]BY YR GROUPING¡^
  v3.0.0.3         2015/5/227     brant yang               ¼W¥[§ó·s®É¶¡Äæ¦ì¡A¥Î©ó³]³Æ®Ä²v¬ÝªO¡A
                                                           ²Î­pSMT FA AUTO ¥Í²£¤u®É
  3.0.0.4          2015/6/15      brant.yang               ¸Ñ¨M¹ê»Ú²£¥X¬°¹s¡A¥Ø¼Ð²£¥X¤£¬°¹s°ÝÃD
  3.0.0.5          2015/6/18      brant.yang               ¸Ñ¨M¤W¤@¸`ÂI¤Ö­pºâ¹ê»Ú²£¥X²£¯à
  3.0.0.6          2015/7/1       brant.yang               ¼W¥[OOB¥¼ÅçÁ`¼Æ
  =================================================================================================

  */
 AS
  V_MFGTYPE         SFCLINE_MAP.MFGTYPE%TYPE;
  V_LINE            SFCLINE_MAP.LINE%TYPE;
  V_SMTLINES        SFCLINE_MAP.SMTLINES%TYPE;
  V_DIPLINES        SFCLINE_MAP.DIPLINES%TYPE;
  V_PCBFPYRLINES    SFCLINE_MAP.SMTLINES%TYPE;
  V_BYCYC           SFCLINE_MAP.BYCYC%TYPE;
  V_UNITPER         SFCLINE_MAP.UNITPER%TYPE;
  V_PROCESS         SFCLINE_MAP.PROCESS%TYPE;
  V_SHIFT           PPFPRODPERIOD.SHIFT%TYPE;
  V_PERIODNO        PPFPRODPERIOD.PERIODNO%TYPE;
  V_INSTAGE         SFCLINE_MAP.INSTAGE%TYPE;
  V_OUTSTAGE        SFCLINE_MAP.OUTSTAGE%TYPE;
  V_STARTTIME       V_PPFPRODPERIOD.STARTTIME%TYPE;
  V_ENDTIME         V_PPFPRODPERIOD.ENDTIME%TYPE;
  V_BREAKTIME       PPFPRODPERIOD.BREAKTIME%TYPE;
  V_FPYR            LINEKBDETAIL.FPYR%TYPE;
  V_BREAKTIMEPER    SFCLINE_MAP.BREAKTIMEPER%TYPE;
  V_REDO            SFCLINE_MAP.REDO%TYPE;
  V_PLANT           LINEKBDETAIL.PLANT%TYPE := 'P8-F139';
  V_HALFLINE        SFCLINE_MAP.HALFLINE%TYPE;
  V_BALANCE         SFCLINE_MAP.BALANCE%TYPE;
  V_PDPLANT         SFCLINE_MAP.PDPLANT%TYPE;
  V_STATUS          KBPERIODSTATUS.STATUS%TYPE;
  V_NONWORKSTATION  SFCLINE_MAP.NONWORKSTATION%TYPE;
  V_MANUALSTARTTIME V_PPFPRODPERIOD.STARTTIME%TYPE;
  V_MANUALENDTIME   V_PPFPRODPERIOD.ENDTIME%TYPE;
  V_INTT            NUMBER := 0;
  V_COUNT           NUMBER := 0;
  V_ACTUAL          NUMBER := 0;
  V_FLAG            NUMBER := 0;
  V_DIVTIME         VARCHAR(10);
  V_ICOUNT          NUMBER := 0;
  V_ALLINTARTET     NUMBER := 0;
  V_ALLINACT        NUMBER := 0;
  V_ALLOUTTARTET    NUMBER := 0;
  V_ALLOUTACT       NUMBER := 0;
  V_YRNGCOUNT       NUMBER := 0;
  V_YRTOTALCOUNT    NUMBER := 0;
  V_YRSTAGE         VARCHAR2(100);
  V_CALSTATUS       KBPERIODSTATUS.CALSTATUS%TYPE;
  V_PARA            VARCHAR2(80);
  V_TACK            NUMBER(8, 3) := 0;
  V_OOBDATA         VARCHAR2(50) := '0,0,0';
  VAR_ERR_MSG       VARCHAR(2000);
  CURSOR cur_LINES IS
    SELECT MFGTYPE,
           LINE,
           SMTLINES,
           DIPLINES,
           BYCYC,
           UNITPER,
           PROCESS,
           BREAKTIMEPER,
           REDO,
           HALFLINE,
           BALANCE,
           PDPLANT,
           INSTAGE,
           OUTSTAGE,
           NONWORKSTATION
      FROM SFCLINE_MAP
     WHERE MFGTYPE = 'FA';
BEGIN
  OPEN cur_LINES;
  LOOP
    FETCH cur_LINES
      INTO V_MFGTYPE,
           V_LINE,
           V_SMTLINES,
           V_DIPLINES,
           V_BYCYC,
           V_UNITPER,
           V_PROCESS,
           V_BREAKTIMEPER,
           V_REDO,
           V_HALFLINE,
           V_BALANCE,
           V_PDPLANT,
           V_INSTAGE,
           V_OUTSTAGE,
           V_NONWORKSTATION;
    EXIT WHEN cur_LINES%NOTFOUND;
    SELECT COUNT(*)
      INTO V_FLAG
      FROM V_PPFPRODPERIOD
     WHERE LINE = V_LINE
       AND STARTTIME <= SYSDATE
       AND ENDTIME > SYSDATE;
    --§ä¨ì?«e??ªº??
    IF V_FLAG > 0 THEN
      --®Ú¾Ú¨t²Î·í«e®É¶¡­pºâ¯Z§O
      SELECT SHIFT
        INTO V_SHIFT
        FROM V_PPFPRODPERIOD
       WHERE LINE = V_LINE
         AND STARTTIME <= SYSDATE
         AND ENDTIME > SYSDATE;
      --®Ú¾Ú¯Z§O©M¨t²Î·í«e®É¶¡¡A­pºâ¥X¸`ÂI¼Æ
      SELECT PERIODNO
        into V_PERIODNO
        FROM V_PPFPRODPERIOD
       WHERE LINE = V_LINE
         AND SHIFT = V_SHIFT
         AND STARTTIME <= SYSDATE
         AND SYSDATE < ENDTIME;
      --delete not use line
      DELETE FROM LINEKBDETAIL
       WHERE (MFGTYPE, LINE) NOT IN (SELECT MFGTYPE, LINE FROM SFCLINE_MAP);
      COMMIT;
      DELETE FROM FPYRDETAIL
       WHERE (MFGTYPE, LINE) NOT IN (SELECT MFGTYPE, LINE FROM SFCLINE_MAP);
      COMMIT;
      DELETE FROM FPYRDETAIL
       WHERE PLANT = V_PLANT
         AND LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE
         AND STAGE NOT IN (SELECT STAGE
                             FROM SFCSTAGE
                            WHERE INSTR((SELECT FPYRSTAGE
                                          FROM SFCLINE_MAP
                                         WHERE LINE = V_LINE
                                           AND MFGTYPE = V_MFGTYPE),
                                        STAGE) > 0);
      COMMIT;
      --intial KBPERIODSTATUS
      --ªì©l¤Æ¨ä¥L¸`ÂIªº¶}½uªº°Ñ¼Æ
      UPDATE KBPERIODSTATUS
         SET MANUALSTARTTIME = '',
             MANUALENDTIME   = '',
             OPENSTATE       = 1,
             CALSTATUS       = 0
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE
         AND SHIFT <> V_SHIFT;
      COMMIT;
      V_INTT := 0;
      IF TRIM(V_NONWORKSTATION) = '' OR V_NONWORKSTATION IS NULL THEN
        V_NONWORKSTATION := 'A';
      END IF;
      FOR T IN (SELECT PERIODNO
                  FROM PPFPRODPERIOD
                 WHERE LINE = V_LINE
                   AND PERIODNO <= V_PERIODNO
                   AND SHIFT = V_SHIFT
                 ORDER BY PERIODNO ASC) LOOP


        SELECT STARTTIME, ENDTIME, BREAKTIME, SHIFT
          INTO V_STARTTIME, V_ENDTIME, V_BREAKTIME, V_SHIFT
          FROM V_PPFPRODPERIOD
         WHERE LINE = V_LINE
           AND PERIODNO = T.PERIODNO
           AND SHIFT = V_SHIFT;


        SELECT BYCYC, INSTAGE, OUTSTAGE
          INTO V_BYCYC, V_INSTAGE, V_OUTSTAGE
          FROM SFCLINE_MAP
         WHERE LINE = V_LINE
           AND MFGTYPE = V_MFGTYPE;
        SELECT STARTTIME, ENDTIME
          INTO V_MANUALSTARTTIME, V_MANUALENDTIME
          FROM (SELECT NVL(MAX(ACTIONDATE), SYSDATE - 10) STARTTIME
                  FROM CIMSFC139.CIMAPLOG
                  JOIN KBLINEAPMAP
                 USING (APID, LINE, WORKSTATION, STAGE)
                 WHERE LINE = V_LINE
                   AND INSTR(V_INSTAGE, STAGE) > 0
                   AND ACTION = 1) A,
               (SELECT NVL(MAX(ACTIONDATE), SYSDATE - 10) ENDTIME
                  FROM CIMSFC139.CIMAPLOG
                  JOIN KBLINEAPMAP
                 USING (APID, LINE, WORKSTATION, STAGE)
                 WHERE LINE = V_LINE
                   AND INSTR(V_INSTAGE, STAGE) > 0
                   AND ACTION = 0) B;
        IF V_MANUALSTARTTIME > SYSDATE - 9 AND
           V_MANUALENDTIME > SYSDATE - 9 AND
           V_MANUALENDTIME >= V_MANUALSTARTTIME THEN
          UPDATE KBPERIODSTATUS
             SET OPENSTATE = 0
           WHERE MFGTYPE = V_MFGTYPE
             AND LINE = V_LINE
             AND SIDE = 'A'
             AND SHIFT = V_SHIFT
             AND PERIODNO = T.PERIODNO;
        END IF;
        SELECT STARTTIME, ENDTIME
          INTO V_MANUALSTARTTIME, V_MANUALENDTIME
          FROM (SELECT NVL(MAX(ACTIONDATE), SYSDATE - 10) STARTTIME
                  FROM CIMSFC139.CIMAPLOG
                  JOIN KBLINEAPMAP
                 USING (APID, LINE, WORKSTATION, STAGE)
                 WHERE LINE = V_LINE
                   AND INSTR(V_OUTSTAGE, STAGE) > 0
                   AND ACTION = 1) A,
               (SELECT NVL(MAX(ACTIONDATE), SYSDATE - 10) ENDTIME
                  FROM CIMSFC139.CIMAPLOG
                  JOIN KBLINEAPMAP
                 USING (APID, LINE, WORKSTATION, STAGE)
                 WHERE LINE = V_LINE
                   AND INSTR(V_OUTSTAGE, STAGE) > 0
                   AND ACTION = 0) B;
        IF V_MANUALSTARTTIME > SYSDATE - 9 AND
           V_MANUALENDTIME > SYSDATE - 9 AND
           V_MANUALENDTIME >= V_MANUALSTARTTIME THEN
          UPDATE KBPERIODSTATUS
             SET OPENSTATE = 0
           WHERE MFGTYPE = V_MFGTYPE
             AND LINE = V_LINE
             AND SIDE = 'B'
             AND SHIFT = V_SHIFT
             AND PERIODNO = T.PERIODNO;
        END IF;
        SELECT NVL(MIN(CALSTATUS), 0)
          INTO V_CALSTATUS
          FROM KBPERIODSTATUS
         WHERE MFGTYPE = V_MFGTYPE
           AND LINE = V_LINE
           AND SHIFT = V_SHIFT
           AND PERIODNO = T.PERIODNO;
        IF T.PERIODNO = V_PERIODNO THEN
          IF V_ENDTIME > SYSDATE THEN
            V_ENDTIME := SYSDATE;
          END IF;
          --Calculate INTARGET
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_INSTAGE,
                                       T.PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '1',
                                       '0',
                                       V_LINE,
                                       'A',
                                       'ASS',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_INSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET INTARGET   = V_INTT,
                 INACTUAL   = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = T.PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          V_INTT   := 0;
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_OUTSTAGE,
                                       T.PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '1',
                                       '0',
                                       V_LINE,
                                       'B',
                                       'PACKING',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_OUTSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET OUTTARGET  = V_INTT,
                 OUTACTUAL  = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = T.PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
        ELSIF T.PERIODNO >= 1 AND T.PERIODNO = V_PERIODNO - 1 AND
              V_REDO <> 1 AND V_CALSTATUS = 0 THEN
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_INSTAGE,
                                       T.PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'A',
                                       'ASS',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_INSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET INTARGET   = V_INTT,
                 INACTUAL   = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = T.PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_OUTSTAGE,
                                       T.PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'B',
                                       'PACKING',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_OUTSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET OUTTARGET  = V_INTT,
                 OUTACTUAL  = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = T.PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          --¨C¦¸­«¶]¤W¸`ÂIªº¸ê®Æ¡A¤Ö­pºâ¤W¸`ÂI¸ê®Æ  brant yang   2015/6/18
          /*          UPDATE KBPERIODSTATUS
            SET CALSTATUS = 1
          WHERE MFGTYPE = V_MFGTYPE
            AND LINE = V_LINE
            AND SHIFT = V_SHIFT
            AND PERIODNO = T.PERIODNO;*/
          COMMIT;
        ELSIF
        --¨C¦¸­«¶]¤W¸`ÂIªº¸ê®Æ¡A¤Ö­pºâ¤W¸`ÂI¸ê®Æ  brant yang   2015/6/18
        /*T.PERIODNO > 0 AND T.PERIODNO < V_PERIODNO AND
                                                                                                              (V_REDO = 1 OR V_CALSTATUS = 0) */

         T.PERIODNO > 0 AND T.PERIODNO < V_PERIODNO AND V_REDO = 1

         THEN
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_INSTAGE,
                                       T.PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'A',
                                       'ASS',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_INSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET INTARGET   = V_INTT,
                 INACTUAL   = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = T.PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_OUTSTAGE,
                                       T.PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'B',
                                       'PACKING',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_OUTSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET OUTTARGET  = V_INTT,
                 OUTACTUAL  = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = T.PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          UPDATE KBPERIODSTATUS
             SET CALSTATUS = 1
           WHERE MFGTYPE = V_MFGTYPE
             AND LINE = V_LINE
             AND SHIFT = V_SHIFT
             AND PERIODNO = T.PERIODNO;
          COMMIT;
        END IF;
      END LOOP;
      --UPDATE INTARGET BY LINE
      --§PÂ_¬O§_´¡¤J¸ê®Æ¨ì¬ÝªO½u§Oªº©ú²Ó¸ê®ÆLINEKBDETAIL
      SELECT COUNT(*)
        INTO V_FLAG
        FROM LINEKBDETAIL
       WHERE MFGTYPE = V_MFGTYPE
         AND LINE = V_LINE;
      --§PÂ_¬O§_´¡¤J¸ê®Æ¨ì¬ÝªO½u§Oªº©ú²Ó¸ê®ÆLINEKBDETAIL
      IF V_FLAG = 1 THEN
        --¦³¤°»ò§@¥Î¡H
        SELECT COUNT(*)
          INTO V_INTT
          FROM KBPRTARGET
         WHERE LINE = V_LINE
           AND MFGTYPE = V_MFGTYPE
           AND SIDE = 'A'
           AND SHIFT = V_SHIFT;
        IF V_INTT > 0 THEN
          UPDATE LINEKBDETAIL
             SET UPDATEDATE = SYSDATE,
                 INTARGET  =
                 (SELECT TARGET
                    FROM KBPRTARGET
                   WHERE LINE = V_LINE
                     AND MFGTYPE = V_MFGTYPE
                     AND SIDE = 'A'
                     AND SHIFT = V_SHIFT),
                 INACTURL  =
                 (SELECT DECODE(SUM(INACTUAL), '', 0, SUM(INACTUAL)) TARGET
                    FROM PPFPRODPERIOD
                   WHERE LINE = V_LINE
                     AND PERIODNO <= V_PERIODNO
                     AND PROCESS = '3'
                     AND SHIFT = V_SHIFT)
           WHERE LINE = V_LINE
             AND MFGTYPE = V_MFGTYPE;
          COMMIT;
        ELSE
          UPDATE LINEKBDETAIL
             SET UPDATEDATE = SYSDATE,
                 INTARGET  =
                 (SELECT DECODE(SUM(INTARGET), '', 0, SUM(INTARGET)) TARGET
                    FROM PPFPRODPERIOD
                   WHERE LINE = V_LINE
                     AND PERIODNO <= V_PERIODNO
                     AND PROCESS = '3'
                     AND SHIFT = V_SHIFT),
                 INACTURL  =
                 (SELECT DECODE(SUM(INACTUAL), '', 0, SUM(INACTUAL)) TARGET
                    FROM PPFPRODPERIOD
                   WHERE LINE = V_LINE
                     AND PERIODNO <= V_PERIODNO
                     AND PROCESS = '3'
                     AND SHIFT = V_SHIFT)
           WHERE LINE = V_LINE
             AND MFGTYPE = V_MFGTYPE;
          COMMIT;
        END IF;
      ELSE
        --¥Í¦¨¬ÝªO©ú²Ó¸ê®Æ
        INSERT INTO LINEKBDETAIL
          (PLANT, MFGTYPE, LINE, PROCESS, SHIFT, INTARGET, INACTURL)
          SELECT V_PLANT,
                 V_MFGTYPE,
                 V_LINE,
                 '3',
                 V_SHIFT,
                 DECODE(SUM(INTARGET), '', 0, SUM(INTARGET)) TARGET,
                 DECODE(SUM(INACTUAL), '', 0, SUM(INACTUAL)) INACTUAL
            FROM PPFPRODPERIOD
           WHERE LINE = V_LINE
             AND PERIODNO <= V_PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
        COMMIT;
      END IF;
      --UPDATE OUTTARGET BY LINE
      SELECT COUNT(*)
        INTO V_INTT
        FROM KBPRTARGET
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE
         AND SIDE = 'B'
         AND SHIFT = V_SHIFT;
      IF V_INTT > 0 THEN
        UPDATE LINEKBDETAIL
           SET UPDATEDATE = SYSDATE,
               OUTTARGET =
               (SELECT TARGET
                  FROM KBPRTARGET
                 WHERE LINE = V_LINE
                   AND MFGTYPE = V_MFGTYPE
                   AND SIDE = 'B'
                   AND SHIFT = V_SHIFT),
               OUTACTURL =
               (SELECT DECODE(SUM(OUTACTUAL), '', 0, SUM(OUTACTUAL)) ACTUAL
                  FROM PPFPRODPERIOD
                 WHERE LINE = V_LINE
                   AND PERIODNO <= V_PERIODNO
                   AND PROCESS = '3'
                   AND SHIFT = V_SHIFT)
         WHERE LINE = V_LINE
           AND MFGTYPE = V_MFGTYPE;
        COMMIT;
      ELSE
        UPDATE LINEKBDETAIL
           SET UPDATEDATE = SYSDATE,
               OUTTARGET =
               (SELECT DECODE(SUM(OUTTARGET), '', 0, SUM(OUTTARGET)) TARGET
                  FROM PPFPRODPERIOD
                 WHERE LINE = V_LINE
                   AND PERIODNO <= V_PERIODNO
                   AND PROCESS = '3'
                   AND SHIFT = V_SHIFT),
               OUTACTURL =
               (SELECT DECODE(SUM(OUTACTUAL), '', 0, SUM(OUTACTUAL)) ACTUAL
                  FROM PPFPRODPERIOD
                 WHERE LINE = V_LINE
                   AND PERIODNO <= V_PERIODNO
                   AND PROCESS = '3'
                   AND SHIFT = V_SHIFT)
         WHERE LINE = V_LINE
           AND MFGTYPE = V_MFGTYPE;
        COMMIT;
      END IF;
      --=============================
      SELECT MIN(STARTTIME)
        INTO V_STARTTIME
        FROM V_PPFPRODPERIOD
       WHERE LINE = V_LINE
         AND SHIFT = V_SHIFT;
      --get acturl
      --V_INTT :=Fun_GetActurl(V_MFGTYPE,V_LINE,V_INSTAGE,V_STARTTIME);
      --UPDATE LINEKBDETAIL SET UPDATEDATE=SYSDATE,INACTURL=V_INTT WHERE LINE=V_LINE AND MFGTYPE=V_MFGTYPE;
      --COMMIT;
      --V_INTT :=Fun_GetActurl(V_MFGTYPE,V_LINE,V_OUTSTAGE,V_STARTTIME);
      --UPDATE LINEKBDETAIL SET UPDATEDATE=SYSDATE,OUTACTURL=V_INTT WHERE LINE=V_LINE AND MFGTYPE=V_MFGTYPE;
      --COMMIT;
      --GET MODEL,USN,MO,MOLOT,MOINPUTQTY
      V_PARA := Fun_GetModelUSNMO(V_MFGTYPE,
                                  V_LINE,
                                  V_INSTAGE,
                                  V_SHIFT,
                                  V_LINE);
      UPDATE LINEKBDETAIL
         SET INMODEL      = SUBSTR(V_PARA, 1, INSTR(V_PARA, ',', 1, 1) - 1),
             INUSN        = SUBSTR(V_PARA,
                                   INSTR(V_PARA, ',', 1, 1) + 1,
                                   (INSTR(V_PARA, ',', 1, 2) -
                                   INSTR(V_PARA, ',', 1, 1)) - 1),
             INMO         = SUBSTR(V_PARA,
                                   INSTR(V_PARA, ',', 1, 2) + 1,
                                   (INSTR(V_PARA, ',', 1, 3) -
                                   INSTR(V_PARA, ',', 1, 2)) - 1),
             INMOLOT      = SUBSTR(V_PARA,
                                   INSTR(V_PARA, ',', 1, 3) + 1,
                                   (INSTR(V_PARA, ',', 1, 4) -
                                   INSTR(V_PARA, ',', 1, 3)) - 1),
             INMOINPUTQTY = SUBSTR(V_PARA, INSTR(V_PARA, ',', 1, 4) + 1)
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE;
      COMMIT;
      V_PARA := Fun_GetModelUSNMO(V_MFGTYPE,
                                  V_LINE,
                                  V_OUTSTAGE,
                                  V_SHIFT,
                                  V_LINE);
      UPDATE LINEKBDETAIL
         SET OUTMODEL      = SUBSTR(V_PARA, 1, INSTR(V_PARA, ',', 1, 1) - 1),
             OUTUSN        = SUBSTR(V_PARA,
                                    INSTR(V_PARA, ',', 1, 1) + 1,
                                    (INSTR(V_PARA, ',', 1, 2) -
                                    INSTR(V_PARA, ',', 1, 1)) - 1),
             OUTMO         = SUBSTR(V_PARA,
                                    INSTR(V_PARA, ',', 1, 2) + 1,
                                    (INSTR(V_PARA, ',', 1, 3) -
                                    INSTR(V_PARA, ',', 1, 2)) - 1),
             OUTMOLOT      = SUBSTR(V_PARA,
                                    INSTR(V_PARA, ',', 1, 3) + 1,
                                    (INSTR(V_PARA, ',', 1, 4) -
                                    INSTR(V_PARA, ',', 1, 3)) - 1),
             OUTMOINPUTQTY = SUBSTR(V_PARA, INSTR(V_PARA, ',', 1, 4) + 1)
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE;
      COMMIT;
      --Get TACKTIME
      V_TACK := Fun_GetTackTime(V_MFGTYPE,
                                V_LINE,
                                V_INSTAGE,
                                V_BYCYC,
                                0,
                                V_UNITPER,
                                'A',
                                V_LINE);
      UPDATE LINEKBDETAIL
         SET INTACKTIME = V_TACK
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE;
      COMMIT;
      V_TACK := Fun_GetTackTime(V_MFGTYPE,
                                V_LINE,
                                V_OUTSTAGE,
                                V_BYCYC,
                                0,
                                V_UNITPER,
                                'B',
                                V_LINE);
      UPDATE LINEKBDETAIL
         SET OUTTACKTIME = V_TACK
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE;
      COMMIT;
      --==========================­pºâFPY==============================================================================
      --FPYR  ²K¥[YR Grouping ­pºâÅÞ¿è
      V_FPYR    := 1;
      V_YRSTAGE := '';

      FOR T1 IN (SELECT STAGEGROUP
                   FROM FPYRGROUPING
                  WHERE PLANT = V_PLANT
                    AND MFGTYPE = V_MFGTYPE) LOOP
        V_YRNGCOUNT    := 0;
        V_YRTOTALCOUNT := 0;
        FOR T2 IN (SELECT DISTINCT STAGE
                     FROM SFCSTAGE
                    WHERE INSTR((SELECT FPYRSTAGE
                                  FROM SFCLINE_MAP
                                 WHERE LINE = V_LINE
                                   AND MFGTYPE = V_MFGTYPE),
                                STAGE) > 0
                      AND INSTR(T1.STAGEGROUP, STAGE) > 0) LOOP
          --¥´¦L¥X­n­pºâFPYRªºStage Brnat Yang
          DBMS_OUTPUT.PUT_LINE('­n­pºâstage:' || T2.STAGE);
          SELECT COUNT(*)
            INTO V_FLAG
            FROM FPYRDETAIL
           WHERE PLANT = V_PLANT
             AND LINE = V_LINE
             AND MFGTYPE = V_MFGTYPE
             AND STAGE = T2.STAGE;
          IF V_FLAG <= 0 THEN
            INSERT INTO FPYRDETAIL
              (PLANT, MFGTYPE, LINE, STAGE)
            VALUES
              (V_PLANT, V_MFGTYPE, V_LINE, T2.STAGE);
            COMMIT;
          END IF;
          --­pºâ¹L¯¸¼Æ¶q©MNGªº¼Æ¶q  Brant Yang
          --v_yrstage ­n­pºâ¨}²vªº¤u¯¸
          V_YRSTAGE := V_YRSTAGE || ',' || T2.STAGE;
          V_PARA    := FUN_GETYRQTYBYSTAGE(V_MFGTYPE,
                                           V_LINE,
                                           T2.STAGE,
                                           V_STARTTIME,
                                           V_LINE);
          --­pºâNG¼Æ¶q
          V_YRNGCOUNT    := V_YRNGCOUNT +
                            SUBSTR(V_PARA, 1, INSTR(V_PARA, ',', 1, 1) - 1);
          V_YRTOTALCOUNT := V_YRTOTALCOUNT +
                            SUBSTR(V_PARA, INSTR(V_PARA, ',', 1, 1) + 1);
          -- DBMS_OUTPUT.put_line ('LINE:' || V_LINE || ',STAGE:'||T2.STAGE||',V_PARA:'|| V_PARA);
        END LOOP;
        IF V_YRNGCOUNT > 0 AND V_YRNGCOUNT <> V_YRTOTALCOUNT THEN
          V_FPYR := trunc(V_FPYR * (1 - V_YRNGCOUNT / V_YRTOTALCOUNT),4);
          -- DBMS_OUTPUT.put_line ('LINE:' || V_LINE || ',STAGEGROUP:'||T1.STAGEGROUP ||',V_FPYR:'|| V_FPYR);
        END IF;
      END LOOP;

      --¥´¦L¥X­n­pºâFPYRªºStage Brnat Yang
/*      DBMS_OUTPUT.PUT_LINE('row 685 ­n­pºâfpy¥þ³¡stage:' || V_YRSTAGE);
      FOR T IN (SELECT DISTINCT STAGE
                  FROM SFCSTAGE
                 WHERE INSTR((SELECT FPYRSTAGE
                               FROM SFCLINE_MAP
                              WHERE LINE = V_LINE
                                AND MFGTYPE = V_MFGTYPE),
                             STAGE) > 0
                   \*AND INSTR(V_YRSTAGE, STAGE) = 0*\) LOOP
        V_YRNGCOUNT    := 0;
        V_YRTOTALCOUNT := 0;
        SELECT COUNT(*)
          INTO V_FLAG
          FROM FPYRDETAIL
         WHERE PLANT = V_PLANT
           AND LINE = V_LINE
           AND MFGTYPE = V_MFGTYPE
           AND STAGE = T.STAGE;
        IF V_FLAG <= 0 THEN
          INSERT INTO FPYRDETAIL
            (PLANT, MFGTYPE, LINE, STAGE)
          VALUES
            (V_PLANT, V_MFGTYPE, V_LINE, T.STAGE);
          COMMIT;
        END IF;
        V_PARA         := FUN_GETYRQTYBYSTAGE(V_MFGTYPE,
                                              V_LINE,
                                              T.STAGE,
                                              V_STARTTIME,
                                              V_LINE);
        V_YRNGCOUNT    := V_YRNGCOUNT +
                          SUBSTR(V_PARA, 1, INSTR(V_PARA, ',', 1, 1) - 1);
        V_YRTOTALCOUNT := V_YRTOTALCOUNT +
                          SUBSTR(V_PARA, INSTR(V_PARA, ',', 1, 1) + 1);
        DBMS_OUTPUT.put_line('LINE:' || V_LINE || ',STAGE:' || T.STAGE ||
                             ',V_PARA:' || V_PARA);
        IF V_YRNGCOUNT > 0 THEN
          V_FPYR := trunc(V_FPYR * (1 - V_YRNGCOUNT / V_YRTOTALCOUNT),4);
          -- DBMS_OUTPUT.put_line ('LINE:' || V_LINE || ',STAGE:'||T.STAGE ||',V_FPYR:'|| V_FPYR);
        END IF;
      END LOOP;*/
      --§ó·s­pºâªºFPYR¨}²v
      UPDATE LINEKBDETAIL
         SET FPYR = V_FPYR, SHIFT = V_SHIFT
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE;
      COMMIT;

      --§ó·sSFCLINE_MAP¤¤REDO¬°0
      UPDATE SFCLINE_MAP
         SET REDO = 0
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE
         AND PROCESS = '3';
      COMMIT;
      --IF PERIODNO > NOW PERIODNO,SET INTARGET AS 0
      UPDATE PPFPRODPERIOD
         SET INTARGET   = 0,
             OUTTARGET  = 0,
             INACTUAL   = 0,
             OUTACTUAL  = 0,
             updatetime = sysdate
       WHERE LINE = V_LINE
         AND SHIFT = V_SHIFT
         AND PROCESS = '3'
         AND PERIODNO > V_PERIODNO;
      COMMIT;
      --PERIOD SHIFT ALL
      IF V_PDPLANT = '' OR V_PDPLANT IS NULL THEN
        V_PDPLANT := V_PLANT;
      END IF;
      IF V_SHIFT = '1' THEN
        SELECT COUNT(*)
          INTO V_ICOUNT
          FROM KBUPDATEFLAG
         WHERE SHIFT = 0
           AND MFGTYPE = V_MFGTYPE
           AND LINE = V_LINE
           AND UPDATEFLAG = '0'
           AND UPDATEDATE < SYSDATE - 5 / 1440;
        IF V_ICOUNT > 0 THEN
          --Calculate INTARGET
          SELECT STARTTIME, ENDTIME, BREAKTIME, SHIFT, PERIODNO
            INTO V_STARTTIME, V_ENDTIME, V_BREAKTIME, V_SHIFT, V_PERIODNO
            FROM V_PPFPRODPERIOD
           WHERE PERIODNO IN (SELECT MAX(PERIODNO)
                                FROM V_PPFPRODPERIOD
                               WHERE SHIFT = 0
                                 AND LINE = V_LINE
                                 AND PROCESS = 3)
             AND SHIFT = 0
             AND LINE = V_LINE
             AND PROCESS = 3;
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_INSTAGE,
                                       V_PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'A',
                                       'ASS',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_INSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET INTARGET   = V_INTT,
                 INACTUAL   = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = V_PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_OUTSTAGE,
                                       V_PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'B',
                                       'PACKING',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_OUTSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET OUTTARGET  = V_INTT,
                 OUTACTUAL  = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = V_PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          SELECT SUM(INTARGET),
                 SUM(INACTUAL),
                 SUM(OUTTARGET),
                 SUM(OUTACTUAL)
            INTO V_ALLINTARTET, V_ALLINACT, V_ALLOUTTARTET, V_ALLOUTACT
            FROM V_PPFPRODPERIOD
           WHERE LINE = V_LINE
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          V_ICOUNT := 0;
          SELECT COUNT(*)
            INTO V_ICOUNT
            FROM TIBCOEAI.WKSKBDAYDETAIL
           WHERE PLANT = V_PLANT
             AND MFGTYPE = V_MFGTYPE
             AND LINE = V_LINE
             AND SHIFT = V_SHIFT
             AND SHIFTDATE = TO_CHAR(SYSDATE, 'YYYYMMDD');
          IF V_ICOUNT > 0 THEN
            UPDATE TIBCOEAI.WKSKBDAYDETAIL
               SET INTARGET  = V_ALLINTARTET,
                   INACTURL  = V_ALLINACT,
                   OUTTARGET = V_ALLOUTTARTET,
                   OUTACTURL = V_ALLOUTACT,
                   PARTPLANT = V_PDPLANT
             WHERE PLANT = V_PLANT
               AND MFGTYPE = V_MFGTYPE
               AND LINE = V_LINE
               AND SHIFT = V_SHIFT
               AND SHIFTDATE = TO_CHAR(SYSDATE, 'YYYYMMDD');
            COMMIT;
          ELSE
            INSERT INTO TIBCOEAI.WKSKBDAYDETAIL
              (PLANT,
               MFGTYPE,
               LINE,
               PROCESS,
               SHIFTDATE,
               SHIFT,
               INTARGET,
               INACTURL,
               OUTTARGET,
               OUTACTURL,
               FPYR,
               TRNDATE,
               PARTPLANT)
            VALUES
              (V_PLANT,
               V_MFGTYPE,
               V_LINE,
               '3',
               TO_CHAR(SYSDATE, 'YYYYMMDD'),
               V_SHIFT,
               V_ALLINTARTET,
               V_ALLINACT,
               V_ALLOUTTARTET,
               V_ALLOUTACT,
               '1',
               SYSDATE,
               V_PDPLANT);
            COMMIT;
          END IF;
          UPDATE KBUPDATEFLAG
             SET UPDATEFLAG = 1
           WHERE SHIFT = 0
             AND MFGTYPE = V_MFGTYPE
             AND LINE = V_LINE
             AND UPDATEFLAG = '0';
          COMMIT;
        END IF;
      ELSE
        SELECT COUNT(*)
          INTO V_ICOUNT
          FROM KBUPDATEFLAG
         WHERE SHIFT = 1
           AND MFGTYPE = V_MFGTYPE
           AND LINE = V_LINE
           AND UPDATEFLAG = '0'
           AND UPDATEDATE < SYSDATE - 5 / 1440;
        --Calculate INTARGET
        IF V_ICOUNT > 0 THEN
          SELECT STARTTIME, ENDTIME, BREAKTIME, SHIFT, PERIODNO
            INTO V_STARTTIME, V_ENDTIME, V_BREAKTIME, V_SHIFT, V_PERIODNO
            FROM V_PPFPRODPERIOD
           WHERE PERIODNO IN (SELECT MAX(PERIODNO)
                                FROM V_PPFPRODPERIOD
                               WHERE SHIFT = 1
                                 AND LINE = V_LINE
                                 AND PROCESS = 3)
             AND SHIFT = 1
             AND LINE = V_LINE
             AND PROCESS = 3;
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_INSTAGE,
                                       V_PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'A',
                                       'ASS',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_INSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET INTARGET   = V_INTT,
                 INACTUAL   = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = V_PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          V_INTT   := Fun_GetTARGETALL(V_MFGTYPE,
                                       V_SHIFT,
                                       V_LINE,
                                       V_OUTSTAGE,
                                       V_PERIODNO,
                                       V_STARTTIME,
                                       V_ENDTIME,
                                       V_BREAKTIMEPER,
                                       V_BYCYC,
                                       V_UNITPER,
                                       '0',
                                       '0',
                                       V_LINE,
                                       'B',
                                       'PACKING',
                                       V_NONWORKSTATION);
          V_ACTUAL := Fun_GetActurlPeriod(V_MFGTYPE,
                                          V_LINE,
                                          V_OUTSTAGE,
                                          V_STARTTIME,
                                          V_ENDTIME,
                                          V_NONWORKSTATION);
          UPDATE PPFPRODPERIOD
             SET OUTTARGET  = V_INTT,
                 OUTACTUAL  = V_ACTUAL,
                 updatetime = sysdate
           WHERE LINE = V_LINE
             AND PERIODNO = V_PERIODNO
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          COMMIT;
          SELECT SUM(INTARGET),
                 SUM(INACTUAL),
                 SUM(OUTTARGET),
                 SUM(OUTACTUAL)
            INTO V_ALLINTARTET, V_ALLINACT, V_ALLOUTTARTET, V_ALLOUTACT
            FROM V_PPFPRODPERIOD
           WHERE LINE = V_LINE
             AND PROCESS = '3'
             AND SHIFT = V_SHIFT;
          V_ICOUNT := 0;
          SELECT COUNT(*)
            INTO V_ICOUNT
            FROM TIBCOEAI.WKSKBDAYDETAIL
           WHERE PLANT = V_PLANT
             AND PARTPLANT = V_PDPLANT
             AND MFGTYPE = V_MFGTYPE
             AND LINE = V_LINE
             AND SHIFT = V_SHIFT
             AND SHIFTDATE = TO_CHAR(SYSDATE - 1, 'YYYYMMDD');
          IF V_ICOUNT > 0 THEN
            UPDATE TIBCOEAI.WKSKBDAYDETAIL
               SET INTARGET  = V_ALLINTARTET,
                   INACTURL  = V_ALLINACT,
                   OUTTARGET = V_ALLOUTTARTET,
                   OUTACTURL = V_ALLOUTACT,
                   TRNDATE   = SYSDATE,
                   PARTPLANT = V_PDPLANT
             WHERE PLANT = V_PLANT
               AND PARTPLANT = V_PDPLANT
               AND MFGTYPE = V_MFGTYPE
               AND LINE = V_LINE
               AND SHIFT = V_SHIFT
               AND SHIFTDATE = TO_CHAR(SYSDATE - 1, 'YYYYMMDD');
            COMMIT;
          ELSE
            INSERT INTO TIBCOEAI.WKSKBDAYDETAIL
              (PLANT,
               MFGTYPE,
               LINE,
               PROCESS,
               SHIFTDATE,
               SHIFT,
               INTARGET,
               INACTURL,
               OUTTARGET,
               OUTACTURL,
               FPYR,
               TRNDATE,
               PARTPLANT)
            VALUES
              (V_PLANT,
               V_MFGTYPE,
               V_LINE,
               '3',
               TO_CHAR(SYSDATE - 1, 'YYYYMMDD'),
               V_SHIFT,
               V_ALLINTARTET,
               V_ALLINACT,
               V_ALLOUTTARTET,
               V_ALLOUTACT,
               '1',
               SYSDATE,
               V_PDPLANT);
            COMMIT;
          END IF;
          UPDATE KBUPDATEFLAG
             SET UPDATEFLAG = 1
           WHERE SHIFT = 1
             AND MFGTYPE = V_MFGTYPE
             AND LINE = V_LINE
             AND UPDATEFLAG = '0';
          COMMIT;
        END IF;
      END IF;
      --END IF;

      --²K¥[OOB¼Ò¶ô¼Æ¾Ú, ¼W¥[OOB¥¼??¶q  brant yang 2015/7/1
      -- OOBKBDETAILBYSITE´¡¤J³ø¥DÁä¤£°ß¤@¡A§R°£¼W¥[¤@­Ó±ø¥ó mfgtype
      V_OOBDATA := FUN_GETOOBKBDATA(V_MFGTYPE, V_LINE, V_SHIFT);
      DELETE FROM TIBCOEAI.OOBKBDETAILBYSITE
       WHERE PLANT = V_PLANT
            --¼W¥[±ø¥ó¡@¡@2016/5/4
         and mfgtype = v_mfgtype
         AND LINE = V_LINE;
      COMMIT;
      INSERT INTO TIBCOEAI.OOBKBDETAILBYSITE
        (PLANT,
         MFGTYPE,
         LINE,
         TOTALNUM,
         DEFECTNUM,
         EXTERIORDEFNUM,
         nocheck_totalnum,
         UPDATEDATE)
      VALUES
        (V_PLANT,
         V_MFGTYPE,
         V_LINE,
         SUBSTR(V_OOBDATA, 1, INSTR(V_OOBDATA, ',') - 1),
         SUBSTR(V_OOBDATA,
                INSTR(V_OOBDATA, ',') + 1,
                INSTR(V_OOBDATA, ',', 1, 2) - INSTR(V_OOBDATA, ',') - 1),
         SUBSTR(V_OOBDATA,
                INSTR(V_OOBDATA, ',', 1, 2) + 1,
                INSTR(V_OOBDATA, ',', 1, 3) - INSTR(V_OOBDATA, ',', 1, 2) - 1),
         SUBSTR(V_OOBDATA, INSTR(V_OOBDATA, ',', -1) + 1),
         SYSDATE);
      COMMIT;

    ELSE
      UPDATE LINEKBDETAIL
         SET SHIFT       = 0,
             INMODEL     = '',
             INTARGET    = 0,
             INACTURL    = 0,
             OUTMODEL    = '',
             OUTTARGET   = 0,
             OUTACTURL   = 0,
             FPYR        = 1,
             UPDATEDATE  = SYSDATE,
             INUSN       = '',
             OUTUSN      = '',
             INTACKTIME  = '',
             OUTTACKTIME = ''
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE;
      COMMIT;
      DELETE FROM FPYRDETAIL
       WHERE LINE = V_LINE
         AND MFGTYPE = V_MFGTYPE;
      COMMIT;

    END IF;
  END LOOP;
  --¸Ñ¨Mby plant kb003.1 ©Mby line  kb002.1  ªºÁ`¼Æ¶q¤£¤@­Pªº°ÝÃD  brant.yang
  update linekbdetail set outtarget = 0 where outacturl = 0;
  commit;

  CLOSE cur_LINES;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    VAR_ERR_MSG :='??¦æ?:' || dbms_utility.format_error_backtrace() ||
                  '??¥N?:' || sqlcode || '??´£¥Ü:' || sqlerrm(sqlcode);
    DBMS_OUTPUT.PUT_LINE(VAR_ERR_MSG);
    INSERT INTO KBNERRORLOG VALUES (SYSDATE, 'P_TARGETFA', VAR_ERR_MSG);
    COMMIT;
END P_TARGETFA;
/
