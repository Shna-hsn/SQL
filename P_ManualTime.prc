CREATE OR REPLACE PROCEDURE P_ManualTime
(PAR_MFGTYPE IN VARCHAR2,PAR_SHIFT IN VARCHAR2,PAR_LINE IN VARCHAR2,PAR_STAGE IN VARCHAR2,
PAR_PERIODNO IN VARCHAR2,PAR_STARTTIME IN DATE,PAR_ENDTIME IN DATE,PAR_SIDE IN VARCHAR2 )
--version v3.0.0.0 2014/07/15 by oscar
 IS
    VAR_Flag  NUMBER :=0;
    VAR_MANUALSTARTTIME KBPERIODSTATUS.MANUALSTARTTIME%TYPE;
    VAR_MINSTARTTIME KBPERIODSTATUS.MANUALSTARTTIME%TYPE;
    VAR_MANUALENDTIME KBPERIODSTATUS.MANUALENDTIME%TYPE;
    VAR_ERR_MSG  VARCHAR(2000);
BEGIN
     SELECT NVL(MIN(ACTIONDATE),SYSDATE + 1) INTO VAR_MANUALSTARTTIME  FROM CIMSFC139.CIMAPLOG JOIN KBLINEAPMAP
      USING(APID,LINE,WORKSTATION,STAGE)
      WHERE MAINLINE=PAR_LINE  AND STAGE=PAR_STAGE AND ACTIONDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME AND ACTION=1;
       IF VAR_MANUALSTARTTIME <= SYSDATE THEN
         SELECT COUNT(*) INTO VAR_Flag FROM KBPERIODSTATUS
          WHERE MFGTYPE=PAR_MFGTYPE AND LINE=PAR_LINE AND SIDE=PAR_SIDE AND SHIFT=PAR_SHIFT AND PERIODNO=PAR_PERIODNO;
           IF VAR_Flag <=0 THEN
              INSERT INTO KBPERIODSTATUS (MFGTYPE,LINE,SIDE,SHIFT,PERIODNO,STATUS,USERID,TRNDATE,MANUALSTARTTIME,OPENSTATE,CALSTATUS)
                VALUES (PAR_MFGTYPE,PAR_LINE,PAR_SIDE,PAR_SHIFT,PAR_PERIODNO,1,'SYSTEM',SYSDATE,VAR_MANUALSTARTTIME,1,0);
           ELSE
             SELECT NVL(MANUALSTARTTIME,SYSDATE+1) INTO VAR_MINSTARTTIME FROM KBPERIODSTATUS
             WHERE MFGTYPE=PAR_MFGTYPE AND LINE=PAR_LINE AND SIDE=PAR_SIDE AND SHIFT=PAR_SHIFT AND PERIODNO=PAR_PERIODNO;
              IF VAR_MANUALSTARTTIME < VAR_MINSTARTTIME THEN
                UPDATE KBPERIODSTATUS SET MANUALSTARTTIME=VAR_MANUALSTARTTIME,OPENSTATE=1,CALSTATUS=0
                WHERE MFGTYPE=PAR_MFGTYPE AND LINE=PAR_LINE AND SIDE=PAR_SIDE AND SHIFT=PAR_SHIFT AND PERIODNO=PAR_PERIODNO;
              END IF;
           END IF;
       END IF;
     SELECT NVL(MAX(ACTIONDATE),SYSDATE + 1) INTO VAR_MANUALENDTIME  FROM CIMSFC139.CIMAPLOG JOIN KBLINEAPMAP
      USING(APID,LINE,WORKSTATION,STAGE)
      WHERE MAINLINE=PAR_LINE  AND STAGE=PAR_STAGE AND ACTIONDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME AND ACTION=0;
       IF VAR_MANUALENDTIME <= SYSDATE THEN
         SELECT COUNT(*) INTO VAR_Flag FROM KBPERIODSTATUS
          WHERE MFGTYPE=PAR_MFGTYPE AND LINE=PAR_LINE AND SIDE=PAR_SIDE AND SHIFT=PAR_SHIFT AND PERIODNO=PAR_PERIODNO;
           IF VAR_Flag <=0 THEN
              INSERT INTO KBPERIODSTATUS (MFGTYPE,LINE,SIDE,SHIFT,PERIODNO,STATUS,USERID,TRNDATE,MANUALENDTIME)
                VALUES (PAR_MFGTYPE,PAR_LINE,PAR_SIDE,PAR_SHIFT,PAR_PERIODNO,1,'SYSTEM',SYSDATE,VAR_MANUALENDTIME);
           ELSE
              UPDATE KBPERIODSTATUS SET MANUALENDTIME=VAR_MANUALENDTIME
              WHERE MFGTYPE=PAR_MFGTYPE AND LINE=PAR_LINE AND SIDE=PAR_SIDE AND SHIFT=PAR_SHIFT AND PERIODNO=PAR_PERIODNO;
           END IF;
       END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      VAR_ERR_MSG := SQLERRM(SQLCODE);
             INSERT INTO KBNERRORLOG
                    VALUES(SYSDATE, 'P_ManualTime',VAR_ERR_MSG);
   ROLLBACK;
END P_ManualTime;
/
