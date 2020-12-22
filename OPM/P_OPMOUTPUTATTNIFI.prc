CREATE OR REPLACE PROCEDURE P_OPMOUTPUTATTNIFI IS
  vStartDate      DATE;
  vEndDate        DATE;
  VAR_ERR_MSG     VARCHAR2(2000);
  sOutput         NUMBER;
  sTrndate        VARCHAR2(10);
  sSite           VARCHAR2(10);
  sPlant          VARCHAR2(10);
  sPCBPresenthrs  NUMBER;
  sPCBEarnedHrs   NUMBER;
  sFAPresenthrs   NUMBER;
  sFAEarnedHrs    NUMBER;
  sTTLPresenthrs  NUMBER;
  sTTLEarnedHrs   NUMBER;
  sPCBDefectCount NUMBER;
  sPCBFPYR        NUMBER;
  sFADefectCount  NUMBER;
  sFAFPYR         NUMBER;
  a               number;
BEGIN
  sSite  := 'WZS';
  sPlant := 'F139';
/*    a:=57;

  <<repeat_loop>>
  a:=a-1;

  if a>0 then 
  */

  vStartDate := TO_DATE(TO_CHAR(TRUNC(SYSDATE - 1), 'YYYYMMDD') ||
                        '00:00:00',
                        'YYYY/MM/DD HH24:MI:SS');
  vEndDate   := TO_DATE(TO_CHAR(TRUNC(SYSDATE - 1), 'YYYYMMDD') ||
                        '23:59:59',
                        'YYYY/MM/DD HH24:MI:SS');

  --PCB Output start--
  DELETE FROM OPMPCBOUTPUTNIFI WHERE SYNCDATE < SYSDATE - 50;

  COMMIT;

  DELETE FROM OPMPCBOUTPUTNIFI
   WHERE TRNDATE = TO_CHAR(SYSDATE - 1, 'YYYYMMDD');

  COMMIT;

  BEGIN

 
select nppdate,sum(sfcoutput)
       INTO sTrndate, sOutput
from (SELECT TO_CHAR (shiftdate, 'yyyymmdd') NPPDATE, sfcoutput
    FROM  sfcmi139.nppgenlog
    WHERE  processtype='PCB' and onlineflag='1'
     and (line like '%TB___FT%' or 
          line like '%TB___FS%' or
          line like '%TB___FM%' or
          line like '%OB0_3FAP%' OR
          line LIKE '%TB3-4FAP-D%') 
      AND SHIFTID NOT LIKE '%OPT-S%'
      AND SHIFTID NOT LIKE '%OPT-X%'
      AND shiftdate = TRUNC(SYSDATE - 1)
) group by nppdate;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      sTrndate := TO_CHAR(vStartDate, 'YYYYMMDD');
      sOutput  := 0;
  END;

  INSERT INTO OPMPCBOUTPUTNIFI
    (SYNCID, SYNCDATE, SITE, PLANT, TRNDATE, OUTPUTQTY)
  VALUES
    (SEQ_OPMPCBOUTPUTNIFI.NEXTVAL,
     SYSDATE,
     sSite,
     sPlant,
     sTrndate,
     sOutput);

  COMMIT;

  --PCB Output end--
  
    sFAPresenthrs  := 0;
  sFAEarnedHrs   := 0;
  sPCBPresenthrs := 0;
  sPCBEarnedHrs  := 0;
  sTTLPresenthrs := 0;
  sTTLEarnedHrs  := 0;


  FOR T1 IN (SELECT *
               FROM (WITH DEPTRATIO AS (SELECT TP.DEPARTMENT,
                                               TR.BASICDEPARTMENT,
                                               TR.RATIO,
                                               decode(TP.PROCESSTYPE,
                                                      'PCB',
                                                      'PCB',
                                                      'SMT',
                                                      'PCB',
                                                      TP.PROCESSTYPE) PROCESSTYPE,
                                               TP.HEADCOUNT,
                                               TP.WORKINGHOURS,
                                               TP.OVERTIMEHOURS,
                                               TP.PRESENTHOURS,
                                               TP.TURNIN_HRS,
                                               TP.TURNOUT_HRS,
                                               SUM(TP.REALTOTALEARN) REALTOTALEARN,
                                               TP.PRODUCTIVITY,
                                               TP.EFFICIENCY,
                                               TP.PDEFFICIENCY,
                                               TP.LOSSHOURS,
                                               TP.CHARGEHOURS
                                          FROM (SELECT DEPARTMENT,
                                                       PROCESSTYPE,
                                                       SUM(HEADCOUNT) AS HEADCOUNT,
                                                       SUM(WORKINGHOURS) / 60 AS WORKINGHOURS,
                                                       SUM(OVERTIMEHOURS) / 60 AS OVERTIMEHOURS,
                                                       SUM(PRESENTHOURS) / 60 AS PRESENTHOURS,
                                                       SUM(TURNIN_HRS) / 60 AS TURNIN_HRS,
                                                       SUM(TURNOUT_HRS) / 60 AS TURNOUT_HRS,
                                                       SUM(REALTOTALEARN) / 60 AS REALTOTALEARN,
                                                       ROUND(DECODE(SUM(PRESENTHOURS),
                                                                    0,
                                                                    0,
                                                                    SUM(REALTOTALEARN) /
                                                                    SUM(PRESENTHOURS) * 100),
                                                             0) AS PRODUCTIVITY,
                                                       ROUND(DECODE((SUM(PRESENTHOURS) -
                                                                    SUM(CHARGEHOURS)),
                                                                    0,
                                                                    0,
                                                                    SUM(REALTOTALEARN) /
                                                                    (SUM(PRESENTHOURS) -
                                                                     SUM(CHARGEHOURS)) * 100),
                                                             0) AS EFFICIENCY,
                                                       ROUND(DECODE((SUM(PRESENTHOURS) -
                                                                    SUM(CHARGEHOURS) -
                                                                    SUM(LOSSHOURS)),
                                                                    0,
                                                                    0,
                                                                    SUM(REALTOTALEARN) /
                                                                    (SUM(PRESENTHOURS) -
                                                                     SUM(CHARGEHOURS) -
                                                                     SUM(LOSSHOURS)) * 100),
                                                             0) AS PDEFFICIENCY,
                                                       SUM(LOSSHOURS) / 60 AS LOSSHOURS,
                                                       SUM(CHARGEHOURS) / 60 AS CHARGEHOURS
                                                  FROM (SELECT DISTINCT A.SHIFTID,
                                                                        TO_CHAR(A.SHIFTDATE,
                                                                                'YYYY-MM-DD') SHIFTDATE,
                                                                        A.DEPARTMENT,
                                                                        A.PROCESSTYPE,
                                                                        B.HEADCOUNT,
                                                                        B.WORKINGHOURS AS WORKINGHOURS,
                                                                        B.OVERTIMEHOURS AS OVERTIMEHOURS,
                                                                        B.PRESENTHOURS AS PRESENTHOURS,
                                                                        B.TURNIN_HRS AS TURNIN_HRS,
                                                                        B.TURNOUT_HRS AS TURNOUT_HRS,
                                                                        A.REALTOTALEARN AS REALTOTALEARN,
                                                                        ROUND(DECODE(B.PRESENTHOURS,
                                                                                     0,
                                                                                     0,
                                                                                     (A.REALTOTALEARN /
                                                                                     B.PRESENTHOURS) * 100),
                                                                              0) AS PRODUCTIVITY,
                                                                        ROUND(DECODE((B.PRESENTHOURS -
                                                                                     NVL(CHARGEHOURS,
                                                                                          0)),
                                                                                     0,
                                                                                     0,
                                                                                     (A.REALTOTALEARN /
                                                                                     (B.PRESENTHOURS -
                                                                                     NVL(CHARGEHOURS,
                                                                                           0))) * 100),
                                                                              0) AS EFFICIENCY,
                                                                        ROUND(DECODE((B.PRESENTHOURS -
                                                                                     NVL(CHARGEHOURS,
                                                                                          0) -
                                                                                     NVL(LOSSHOURS,
                                                                                          0)),
                                                                                     0,
                                                                                     0,
                                                                                     A.REALTOTALEARN /
                                                                                     (B.PRESENTHOURS -
                                                                                     NVL(CHARGEHOURS,
                                                                                          0) -
                                                                                     NVL(LOSSHOURS,
                                                                                          0)) * 100),
                                                                              0) AS PDEFFICIENCY,
                                                                        DECODE(TL.LOSSHOURS,
                                                                               NULL,
                                                                               0,
                                                                               TL.LOSSHOURS) LOSSHOURS,
                                                                        DECODE(TC.CHARGEHOURS,
                                                                               NULL,
                                                                               0,
                                                                               TC.CHARGEHOURS) CHARGEHOURS
                                                          FROM (SELECT SHIFTID,
                                                                       SHIFTDATE,
                                                                       PROCESSTYPE,
                                                                       DEPARTMENT,
                                                                       SUM(TOTALEARN) AS REALTOTALEARN
                                                                  FROM (SELECT TA.SHIFTID SHIFTID,
                                                                               TA.SHIFTDATE SHIFTDATE,
                                                                               TA.LINE,
                                                                               TA.EARNHOUR,
                                                                               TA.ONLINEFLAG,
                                                                               TA.PROCESSTYPE,
                                                                               TA.DEPARTMENT,
                                                                               DECODE(TA.SHIFTID,
                                                                                      TB.SHIFTID,
                                                                                      TA.EARNHOUR,
                                                                                      TA.EARNHOUR -
                                                                                      NVL(TB.EARNHOUR,
                                                                                          0)) AS TOTALEARN
                                                                          FROM (SELECT SHIFTID,
                                                                                       SHIFTDATE,
                                                                                       LINE,
                                                                                       SUM(EARNHOUR) EARNHOUR,
                                                                                       SHIFTTYPE,
                                                                                       ONLINEFLAG,
                                                                                       DEPARTMENT,
                                                                                       PROCESSTYPE
                                                                                  FROM sfcmi139.NPPGENLOG
                                                                                  WHERE PROCESSTYPE in ('PCB','FA')
                                                                                  and onlineflag=1
                                                                                  and (line like '%TB___FT%' or 
                                                                                       line like '%TB___FS%' or
                                                                                       line like '%TB___FM%' or
                                                                                       line like '%OB0_3FAP%' OR
                                                                                       line LIKE '%TB3-4FAP-D%')
                                                                                  AND SHIFTID NOT LIKE '%OPT-S%'
                                                                                  AND SHIFTID NOT LIKE '%OPT-X%'
                                                                                 GROUP BY SHIFTID,
                                                                                          SHIFTDATE,
                                                                                          LINE,
                                                                                          SHIFTTYPE,
                                                                                          ONLINEFLAG,
                                                                                          DEPARTMENT,
                                                                                          PROCESSTYPE) TA,
                                                                               (SELECT SHIFTID,
                                                                                       SHIFTDATE,
                                                                                       LINE,
                                                                                       SUM(EARNHOUR) EARNHOUR,
                                                                                       SHIFTTYPE,
                                                                                       ONLINEFLAG
                                                                                  FROM sfcmi139.NPPGENLOG
                                                                                 WHERE GENTYPE = 1
                                                                                 GROUP BY SHIFTID,
                                                                                          SHIFTDATE,
                                                                                          LINE,
                                                                                          SHIFTTYPE,
                                                                                          ONLINEFLAG) TB
                                                                         WHERE TA.SHIFTDATE =
                                                                               TB.SHIFTDATE(+)
                                                                           AND TA.LINE =
                                                                               TB.LINE(+)
                                                                           AND TA.SHIFTTYPE =
                                                                               TB.SHIFTTYPE(+))
                                                                 WHERE SHIFTDATE =
                                                                       TRUNC(vStartDate)
                                                                 GROUP BY SHIFTID,
                                                                          SHIFTDATE,
                                                                          PROCESSTYPE,
                                                                          DEPARTMENT) A,
                                                               NPPLABORHOUR B,
                                                               (SELECT SHIFTID,
                                                                       SHIFTDATE,
                                                                       SUM(TOTALLOSE) AS LOSSHOURS
                                                                  FROM NPPCHARGEHOUR
                                                                 WHERE LOSSORCHARG = 'L'
                                                                 GROUP BY SHIFTID,
                                                                          SHIFTDATE) TL,
                                                               (SELECT SHIFTID,
                                                                       SHIFTDATE,
                                                                       SUM(TOTALLOSE) AS CHARGEHOURS
                                                                  FROM NPPCHARGEHOUR
                                                                 WHERE LOSSORCHARG = 'C'
                                                                 GROUP BY SHIFTID,
                                                                          SHIFTDATE) TC
                                                         WHERE A.SHIFTID =
                                                               B.SHIFTID
                                                           AND A.SHIFTDATE =
                                                               B.SHIFTDATE
                                                           AND A.SHIFTID =
                                                               TL.SHIFTID(+)
                                                           AND A.SHIFTDATE =
                                                               TL.SHIFTDATE(+)
                                                           AND A.SHIFTID =
                                                               TC.SHIFTID(+)
                                                           AND A.SHIFTDATE =
                                                               TC.SHIFTDATE(+)
                                                          
                                                         ORDER BY SHIFTDATE,
                                                                  A.SHIFTID) TD
                                                 WHERE 1 = 1
                                                 GROUP BY DEPARTMENT,
                                                          PROCESSTYPE) TP,
                                               NPPOFFLINERATIO TR
                                         WHERE TP.DEPARTMENT =
                                               TR.DEPARTMENT(+)
                                           AND TP.PROCESSTYPE =
                                               TR.PROCESSTYPE(+)
                                         GROUP BY TP.DEPARTMENT,
                                                  TR.BASICDEPARTMENT,
                                                  TR.RATIO,
                                                  TP.PROCESSTYPE,
                                                  TP.HEADCOUNT,
                                                  TP.WORKINGHOURS,
                                                  TP.OVERTIMEHOURS,
                                                  TP.PRESENTHOURS,
                                                  TP.TURNIN_HRS,
                                                  TP.TURNOUT_HRS,
                                                  TP.PRODUCTIVITY,
                                                  TP.EFFICIENCY,
                                                  TP.PDEFFICIENCY,
                                                  TP.LOSSHOURS,
                                                  TP.CHARGEHOURS)
                      SELECT PROCESSTYPE,
                             DECODE(DEPARTMENT,
                                    NULL,
                                    DECODE(PROCESSTYPE,
                                           NULL,
                                           '',
                                           PROCESSTYPE || '-') || 'Total',
                                    DEPARTMENT) AS DEPARTMENT,
                             SUM(HEADCOUNT) AS HEADCOUNT,
                             ROUND(SUM(WORKINGHOURS), 2) AS WORKINGHOURS,
                             ROUND(SUM(OVERTIMEHOURS), 2) AS OVERTIMEHOURS,
                             ROUND(SUM(PRESENTHOURS), 2) AS PRESENTHOURS,
                             ROUND(SUM(TURNIN_HRS), 2) AS TURNIN_HRS,
                             ROUND(SUM(TURNOUT_HRS), 2) AS TURNOUT_HRS,
                             ROUND(SUM(REALTOTALEARN), 2) AS REALTOTALEARN,
                             ROUND(DECODE(SUM(PRESENTHOURS),
                                          0,
                                          0,
                                          SUM(REALTOTALEARN) /
                                          SUM(PRESENTHOURS) * 100),
                                   0) || '%' AS PRODUCTIVITY,
                             ROUND(DECODE((SUM(PRESENTHOURS) -
                                          SUM(CHARGEHOURS)),
                                          0,
                                          0,
                                          SUM(REALTOTALEARN) /
                                          (SUM(PRESENTHOURS) -
                                           SUM(CHARGEHOURS)) * 100),
                                   0) || '%' AS EFFICIENCY,
                             ROUND(DECODE((SUM(PRESENTHOURS) -
                                          SUM(CHARGEHOURS) - SUM(LOSSHOURS)),
                                          0,
                                          0,
                                          SUM(REALTOTALEARN) /
                                          (SUM(PRESENTHOURS) -
                                           SUM(CHARGEHOURS) - SUM(LOSSHOURS)) * 100),
                                   0) || '%' AS PDEFFICIENCY,
                             ROUND(SUM(LOSSHOURS), 2) AS LOSSHOURS,
                             ROUND(SUM(CHARGEHOURS), 2) AS CHARGEHOURS
                        FROM (SELECT PROCESSTYPE,
                                     DEPARTMENT,
                                     SUM(REALTOTALEARN) AS REALTOTALEARN,
                                     SUM(HEADCOUNT) AS HEADCOUNT,
                                     SUM(WORKINGHOURS) AS WORKINGHOURS,
                                     SUM(OVERTIMEHOURS) AS OVERTIMEHOURS,
                                     PRESENTHOURS,
                                     TURNIN_HRS,
                                     TURNOUT_HRS,
                                     ROUND(DECODE(SUM(PRESENTHOURS),
                                                  0,
                                                  0,
                                                  SUM(REALTOTALEARN) /
                                                  SUM(PRESENTHOURS) * 100),
                                           0) AS PRODUCTIVITY,
                                     ROUND(DECODE((SUM(PRESENTHOURS) -
                                                  SUM(CHARGEHOURS)),
                                                  0,
                                                  0,
                                                  SUM(REALTOTALEARN) /
                                                  (SUM(PRESENTHOURS) -
                                                   SUM(CHARGEHOURS)) * 100),
                                           0) AS EFFICIENCY,
                                     ROUND(DECODE((SUM(PRESENTHOURS) -
                                                  SUM(CHARGEHOURS) -
                                                  SUM(LOSSHOURS)),
                                                  0,
                                                  0,
                                                  SUM(REALTOTALEARN) /
                                                  (SUM(PRESENTHOURS) -
                                                   SUM(CHARGEHOURS) -
                                                   SUM(LOSSHOURS)) * 100),
                                           0) AS PDEFFICIENCY,
                                     LOSSHOURS,
                                     CHARGEHOURS
                                FROM (SELECT (SELECT DECODE(SUM(T21.RATIO * 0.01 *
                                                                T31.REALTOTALEARN),
                                                            NULL,
                                                            T1.REALTOTALEARN,
                                                            SUM(T21.RATIO * 0.01 *
                                                                T31.REALTOTALEARN)) TOTAL
                                                FROM DEPTRATIO T21,
                                                     DEPTRATIO T31
                                               WHERE (T21.BASICDEPARTMENT =
                                                     T31.DEPARTMENT AND
                                                     T21.DEPARTMENT =
                                                     T1.DEPARTMENT AND
                                                     T21.PROCESSTYPE =
                                                     T1.PROCESSTYPE)) REALTOTALEARN,
                                             T1.DEPARTMENT,
                                             T1.PROCESSTYPE,
                                             HEADCOUNT,
                                             WORKINGHOURS,
                                             OVERTIMEHOURS,
                                             T1.PRESENTHOURS,
                                             T1.TURNIN_HRS,
                                             T1.TURNOUT_HRS,
                                             T1.PRODUCTIVITY,
                                             T1.EFFICIENCY,
                                             T1.PDEFFICIENCY,
                                             T1.LOSSHOURS,
                                             T1.CHARGEHOURS
                                        FROM DEPTRATIO T1) TT
                               WHERE 1 = 1
                               GROUP BY PROCESSTYPE,
                                        DEPARTMENT,
                                        PRESENTHOURS,
                                        TURNIN_HRS,
                                        TURNOUT_HRS,
                                        PRODUCTIVITY,
                                        EFFICIENCY,
                                        PDEFFICIENCY,
                                        LOSSHOURS,
                                        CHARGEHOURS)
                       WHERE 1 = 1
                       GROUP BY ROLLUP(PROCESSTYPE, DEPARTMENT))
             ) LOOP
    IF UPPER(T1.DEPARTMENT) = 'FA-TOTAL' THEN
      sFAPresenthrs := ROUND(T1.PRESENTHOURS, 2);

      sFAEarnedHrs := ROUND(T1.REALTOTALEARN, 2);
    END IF;

    IF UPPER(T1.DEPARTMENT) = 'PCB-TOTAL' THEN
      sPCBPresenthrs := ROUND(T1.PRESENTHOURS, 2);

      sPCBEarnedHrs := ROUND(T1.REALTOTALEARN, 2);
    END IF;

    IF UPPER(T1.DEPARTMENT) = 'TOTAL' THEN
      sTTLPresenthrs := ROUND(T1.PRESENTHOURS, 2);

      sTTLEarnedHrs := ROUND(T1.REALTOTALEARN, 2);
    END IF;
  END LOOP;

  sTrndate := TO_CHAR(vStartDate, 'YYYYMMDD');

  --PCB Attendance start--
  DELETE FROM OPMPCBATTENDANCENIFI WHERE SYNCDATE < SYSDATE - 50;

  COMMIT;

  DELETE FROM OPMPCBATTENDANCENIFI
   WHERE TRNDATE = TO_CHAR(SYSDATE - 1, 'YYYYMMDD');

  COMMIT;

  INSERT INTO OPMPCBATTENDANCENIFI
    (SYNCID, SYNCDATE, SITE, PLANT, TRNDATE, PRESENTHOURS)
  VALUES
    (SEQ_OPMPCBATTENDANCENIFI.NEXTVAL,
     SYSDATE,
     sSite,
     sPlant,
     sTrndate,
     sPCBPresenthrs);

  COMMIT;

  --PCB Attendance end--

  --FA Attendance start--
  DELETE FROM OPMFAATTENDANCENIFI WHERE SYNCDATE < SYSDATE - 50;

  COMMIT;

  DELETE FROM OPMFAATTENDANCENIFI
   WHERE TRNDATE = TO_CHAR(SYSDATE - 1, 'YYYYMMDD');

  COMMIT;

  INSERT INTO OPMFAATTENDANCENIFI
    (SYNCID, SYNCDATE, SITE, PLANT, TRNDATE, PRESENTHOURS)
  VALUES
    (SEQ_OPMFAATTENDANCENIFI.NEXTVAL,
     SYSDATE,
     sSite,
     sPlant,
     sTrndate,
     sFAPresenthrs);

  COMMIT;

  --FA Attendance end--

  --Productivity start--
  DELETE FROM OPMPRODUCTIVITYNIFI WHERE SYNCDATE < SYSDATE - 50;

  COMMIT;

  DELETE FROM OPMPRODUCTIVITYNIFI
   WHERE TRNDATE = TO_CHAR(SYSDATE - 1, 'YYYYMMDD');

  COMMIT;

  INSERT INTO OPMPRODUCTIVITYNIFI
    (SYNCID,
     SYNCDATE,
     SITE,
     PLANT,
     TRNDATE,
     FAEHRS,
     FAPHRS,
     PCBEHRS,
     PCBPHRS,
     TTLEHRS,
     TTLPHRS)
  VALUES
    (SEQ_OPMPRODUCTIVITYNIFI.NEXTVAL,
     SYSDATE,
     sSite,
     sPlant,
     sTrndate,
     sFAEarnedHrs,
     sFAPresenthrs,
     sPCBEarnedHrs,
     sPCBPresenthrs,
     sTTLEarnedHrs,
     sTTLPresenthrs);

  COMMIT;
  --Productivity end--

  --PCB/FA FPYR Start--
  sPCBDefectCount := 0;
  sPCBFPYR        := 0;
 

  sFADefectCount := 0;
  sFAFPYR        := 0;


  
  for t4 in(select  sum( distinct a3.yr*a2.sss) hr ,defectqty from   ( SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY
                    
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                        FROM sfcmipcb139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('TK', 'TN', 'TC', 'TF','TB','IO','TD') 
          ) a1,
          
--▆瞯眔审销▆瞯
(select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) sss,model from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                       FROM sfcmipcb139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('TK', 'TN', 'TC', 'TF','TB','IO','TD','PA')
          GROUP BY STAGE,model) group by model) a2,
          
          

  
 --?审销PAinput?
( select (a.outputqty/(b.total)) yr,model from ( select sum(outputqty) outputqty,model 
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                      FROM sfcmipcb139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('PA')
          GROUP BY model) a,(SELECT sum(outputqty) total
                       FROM sfcmipcb139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 and
                      A.STAGE IN ('PA')) b ) a3 where a3.model=a2.model   group by defectqty)
                      
                      
LOOP
    sPCBDefectCount := sPCBDefectCount + t4.DEFECTQTY;
    sPCBFPYR        := t4.hr;
  END LOOP;
 


                     
for t5 in (
 select  n.model,n.y,a0.yr, defectqty from   ( SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY
                    
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                       FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FO','FY','FR','UK','MJ','MW','IK','KB','PK','PT','PB','FD','YD','PL','QX','BT','FQ',
             'FO','FY','FR','UK','MJ','MW','IK','KB','PK','PT','PB','FD','YD','PL','BT','FQ',
             'FB','FT','FF','FG','FD','FK','FA',
             'FO','FY','FR','MN','KB','PK','PT','PB','FD','PC','PL','QX','UT','BT','FQ',
             'FO','FY','FR','KB','PK','PT','PB','FD','PC','PL','QX','UT','BT','FQ',
             'FO','FY','FR','MN','KB','PK','PT','PB','FD','PC','LL','QX','WF','UT','BT')   
          ) a1 ,
          
--▆瞯眔审销▆瞯
(select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y , model from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                          ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY) ,
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                       FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FO','FY','FR','UK','MJ','MW','IK','KB','PK','PT','PB','FD','YD','PL','QX','BT','FQ'
) and model in ('X1098','X1098A')
          GROUP BY STAGE,model) group by model
          
            union
        

--X13审销▆瞯  
          select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y , model from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                       FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FO','FY','FR','UK','MJ','MW','IK','KB','PK','PT','PB','FD','YD','PL','BT','FQ'
) and model  in('X1359','X1359A')
          GROUP BY STAGE,model) group by model 
          union
          
--X14▆瞯    
          select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y , model from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT distinct a.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                      FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FB','FT','FF','FG','FD','FK','FA')   and model in ('R1','X1488','X1498','X209')
    GROUP BY STAGE,model) group by model
    union
          
   --X530A
         
            select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y, model from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                      FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FO','FY','FR','MN','KB','PK','PT','PB','FD','PC','PL','QX','UT','BT','FQ'


) and model in ('X530A')
          GROUP BY STAGE,model) group by model
          
          union
          
 --X3A
            select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y, model
           from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                       FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FO','FY','FR','KB','PK','PT','PB','FD','PC','PL','QX','UT','BT','FQ'



) and model in ('X396A')
          GROUP BY STAGE,model) group by model
          union
--X1777/78
            select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y, model
           from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                       FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('IF','MU','FG','EL','IK','KB','LV','FD','PT','PR','QX','PL','UT','BT','FQ'



) and (model LIKE 'X17%' OR MODEL LIKE 'X19%')
          GROUP BY STAGE,model) group by model
          union
          
--X8     
           select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y ,model from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                      FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FO','FY','FR','MN','KB','PK','PT','PB','FD','PC','LL','QX','WF','UT','BT'




) and model in ('X8')
          GROUP BY STAGE,model) group by model
          UNION 
                    
--X8     
           select  exp(sum(ln(decode( stageyr,0,1,stageyr )))) y ,model from   (SELECT DECODE(SUM(OUTPUTQTY), 0, 0, SUM(DEFECTQTY)) DEFECTQTY,
                    DECODE(SUM(OUTPUTQTY),
                           0,
                           0,
                           ROUND((SUM(OUTPUTQTY) - SUM(DEFECTQTY)) /
                                 SUM(OUTPUTQTY),
                                 26)) STAGEYR,model,stage
               FROM (SELECT A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                      FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('FO','FY','FR','UK','MJ','MW','IK','KB','PK','PT','PB','FD','YD','PL','BT','FQ'


) and model in ('X1524')
          GROUP BY STAGE,model) group by model 
          
          
           ) n,
         
          

  
 --?审销PAinput?
  ( select (a.outputqty/(b.total)) yr, model from ( select sum( outputqty) outputqty,  model 
               FROM (SELECT distinct A.MODEL,
                            A.UPN,
                            A.MO,
                            A.LINE,
                            A.STAGE,
                            A.DEFECTQTY,
                            A.TRNDATE,
                            A.OUTPUTQTY
                       FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440 ) A
             WHERE A.STAGE IN ('AB')
          GROUP BY model) a,(SELECT sum(  outputqty) total
                        FROM sfcmiFA139.mifpyrhourly  A
                      WHERE A.TRNDATE BETWEEN trunc(vStartDate)+5/24 AND trunc(vStartDate+1)+5/24-1/1440  and 
                      A.STAGE IN ('AB')) b )a0 where a0.model=n.model 

                      
  )


LOOP
    sFADefectCount := t5.DEFECTQTY;
    sFAFPYR        := t5.yr*t5.y + sFAFPYR;
  END LOOP;

  sPCBFPYR := ROUND(sPCBFPYR * 100, 2);
  sFAFPYR := ROUND(sFAFPYR * 100, 2);
  INSERT INTO OPMFPYRNIFI
    (SYNCID,
     SYNCDATE,
     SITE,
     PLANT,
     TRNDATE,
     FADEFECT,
     FAFPYR,
     PCBDEFECT,
     PCBFPYR)
  VALUES
    (SEQ_OPMFPYRNIFI.NEXTVAL,
     SYSDATE,
     sSite,
     sPlant,
     sTrndate,
     sFADefectCount,
     sFAFPYR,
     sPCBDefectCount,
     sPCBFPYR);

  COMMIT;
  --PCB/FA FPYR End--
/*
      goto repeat_loop;
  end if;
*/
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    VAR_ERR_MSG := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE() || SQLCODE ||
                   SQLERRM(SQLCODE);

    INSERT INTO KBNERRORLOG
    VALUES
      (SYSDATE, 'P_OPMOUTPUTATTNIFI', VAR_ERR_MSG);

    COMMIT;
    

END;
/
