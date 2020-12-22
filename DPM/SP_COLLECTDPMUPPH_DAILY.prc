CREATE OR REPLACE PROCEDURE SP_COLLECTDPMUPPH_DAILY(PROCESSDATE IN DATE DEFAULT SYSDATE-1, AUTOFLAG IN BOOLEAN DEFAULT TRUE)
IS
   V_DATE DATE;
   V_PLANT VARCHAR2(5):='F139';
   V_SITE VARCHAR2(5):='WZS';
   V_SYNCACTION VARCHAR2(1):='C';
   var_err_msg long;
   CURSOR CUR_FIELDLIST(V_DATE DATE)
   IS
     select period,LINE,mfgtype,output,presenthour,round((output/presenthour),2)UPPH from (Select
 TO_CHAR(Y.shiftdate, 'YYYYMMDD') period,
 --Y.shiftid,
 Y.LINE,
 DECODE(Y.PROCESSTYPE,'FA','FA','SMT','PCB','DIP','PCB',Y.PROCESSTYPE) mfgtype,
 sum(Y.sfcoutput) output,
 SUM(Y.EQUIVALENT_output)EQUIVALENT_output,
 sum(DECODE(sfcoutput,null,Round(DECODE((U.PRESENTHOURS-U.PRHOURS),NULL,0,0,0,NVL((U.PRESENTHOURS-U.PRHOURS),0)/60),2),
        0,Round(DECODE((U.PRESENTHOURS-U.PRHOURS),NULL,0,0,0,NVL((U.PRESENTHOURS-U.PRHOURS),0)/60),2),
        Round(DECODE((U.PRESENTHOURS-U.PRHOURS),NULL,0,0,0,(NVL((U.PRESENTHOURS-U.PRHOURS),0)+NVL(P.ZUZHANG_PSH_AVG,0))/60),2)
        ))  presenthour,
 sum(ROUND(DECODE((U.PRESENTHOURS-U.PRHOURS),NULL,0,0,0,
       Y.EQUIVALENT_output/DECODE(sfcoutput,null,Round(DECODE((U.PRESENTHOURS-U.PRHOURS),NULL,0,0,0,NVL((U.PRESENTHOURS-U.PRHOURS),0)/60),2),
        0,Round(DECODE((U.PRESENTHOURS-U.PRHOURS),NULL,0,0,0,NVL((U.PRESENTHOURS-U.PRHOURS),0)/60),2),
        Round(DECODE((U.PRESENTHOURS-U.PRHOURS),NULL,0,0,0,(NVL((U.PRESENTHOURS-U.PRHOURS),0)+NVL(P.ZUZHANG_PSH_AVG,0))/60),2)
        )),2)) UPPH
FROM
 (
   SELECT W.shiftdate,
       W.shiftid,
       w.line,
       W.SHIFTTYPE,
       W.PROCESSTYPE,
       SUM(W.sfcoutput) sfcoutput,
       ROUND(SUM(W.sfcoutput * SFCPP139.Fun_Get_UPPHADDLINE(W.UPN,W.line,PROCESSTYPE)),0) EQUIVALENT_output
   FROM
     ( select  t.shiftdate,
               t.shiftid,
               T.Line,
               t.SHIFTTYPE,
               decode(A.PROCESS, 0, 'AI', 1, 'SMT', 2, 'DIP', 3, 'FA', 'N/A') PROCESSTYPE,
               t.upn,
               SUM(t.sfcoutput) sfcoutput
          FROM NPPGENLOG t, (select MFGTYPE,LINE,PROCESS from CIMSFC139.sfcline) a
         where t.line = a.line and a.process<>1
         group by t.shiftdate,
                  t.shiftid,
                  t.line,
                  t.SHIFTTYPE,
                  decode(A.PROCESS, 0, 'AI', 1, 'SMT', 2, 'DIP', 3, 'FA', 'N/A'),
                  T.upn
       ) W
      GROUP BY W.shiftdate,W.shiftid,W.line,w.SHIFTTYPE,W.PROCESSTYPE
    ) Y,
    (select T1.*,nvl(T2.PRHOURS,0) PRHOURS
     from SFCPP139.NPPLABORHOUR T1, UPPHPILOTRUN T2
      WHERE T1.SHIFTID = T2.SHIFTID(+)
     AND T1.SHIFTDATE = T2.SHIFTDATE(+)) U,
    SFCPP139.UPPH_ZUZHANG_PSH_AVG P
WHERE
   Y.SHIFTDATE = U.SHIFTDATE(+)
   AND Y.SHIFTID = U.SHIFTID(+)
   AND Y.SHIFTDATE = P.SHIFTDATE(+)
   AND Y.PROCESSTYPE = P.PROCESSTYPE(+)
   AND Y.SHIFTTYPE = P.SHIFTTYPE(+)
   and y.shiftdate=trunc(v_date)
 group by Y.shiftdate ,y.line,Y.PROCESSTYPE)
 where output>0 and presenthour>0;

--²¾°£¥þ½u­pºâµ{¦¡½X
   /*CURSOR CUR_ALLLINEFIELDLIST(V_DATE DATE) IS
        SELECT A.PERIOD,A.MFGTYPE,
        SUM(A.OUTPUT) OUTPUT,
        SUM(A.PRESENTHOUR) PRESENTHOUR,
        DECODE(SUM(A.PRESENTHOUR),NULL,0,0,0,ROUND(SUM(A.OUTPUT) /SUM(A.PRESENTHOUR),2)) as UPPH
        FROM DPMUPPH A
        WHERE A.PERIODTYPE = 'daily'
        AND A.LINE <> '*'
        AND A.PERIOD = TO_CHAR(V_DATE, 'YYYYMMDD')
        AND A.PLANT='F139'
        AND A.SITE='WZS'
        GROUP BY A.PERIOD,A.MFGTYPE;*/
BEGIN
   IF AUTOFLAG =TRUE THEN
     V_DATE:=SYSDATE-1;
   ELSE
     V_DATE:=PROCESSDATE;
   END IF;
   IF AUTOFLAG=TRUE THEN
       FOR R_T1 IN CUR_FIELDLIST(V_DATE) LOOP
           IF R_T1.PERIOD IS NOT NULL THEN
            delete from dpmupph where period=R_T1.PERIOD and  periodtype='daily' and site=v_site and plant=v_plant and mfgtype=R_T1.MFGTYPE and line=R_T1.LINE;
            INSERT INTO DPMUPPH
              (SYNCID, SYNCDATE, SYNCACTION, PERIOD, PERIODTYPE, SITE, PLANT, CUSTOMER, MFGTYPE, LINE, OUTPUT, PRESENTHOUR, UPPH)VALUES
              (SYNIDUPH.NEXTVAL, SYSDATE, V_SYNCACTION, R_T1.PERIOD, 'daily', V_SITE, V_PLANT, '*', R_T1.MFGTYPE, R_T1.LINE,  R_T1.OUTPUT, R_T1.PRESENTHOUR, R_T1.UPPH);
           END IF;
       END LOOP;

       /*FOR R_T2 IN CUR_ALLLINEFIELDLIST(V_DATE) LOOP
            delete from dpmupph where period=R_T2.PERIOD and  periodtype='daily' and site=v_site and plant=v_plant and mfgtype=R_T2.MFGTYPE and line='*';
            INSERT INTO DPMUPPH
              (SYNCID, SYNCDATE, SYNCACTION, PERIOD, PERIODTYPE, SITE, PLANT, CUSTOMER, MFGTYPE, LINE, OUTPUT, PRESENTHOUR, UPPH)VALUES
              (SYNIDUPH.NEXTVAL, SYSDATE, V_SYNCACTION, R_T2.PERIOD, 'daily', V_SITE, V_PLANT, '*', R_T2.MFGTYPE, '*',  R_T2.OUTPUT, R_T2.PRESENTHOUR, R_T2.UPPH);
       END LOOP;*/
   END IF;

   --Resend data
   IF TO_CHAR(PROCESSDATE,'YYYYMMDD') < TO_CHAR(SYSDATE,'YYYYMMDD') AND AUTOFLAG=FALSE THEN
     V_SYNCACTION:='U';

      FOR R_T1 IN CUR_FIELDLIST(V_DATE) LOOP
           IF R_T1.PERIOD IS NOT NULL THEN
            delete from dpmupph where period=R_T1.PERIOD and  periodtype='daily' and site=v_site and plant=v_plant and mfgtype=R_T1.MFGTYPE and line=R_T1.LINE;
            INSERT INTO DPMUPPH
              (SYNCID, SYNCDATE, SYNCACTION, PERIOD, PERIODTYPE, SITE, PLANT, CUSTOMER, MFGTYPE, LINE, OUTPUT, PRESENTHOUR, UPPH)VALUES
              (SYNIDUPH.NEXTVAL, SYSDATE, V_SYNCACTION, R_T1.PERIOD, 'daily', V_SITE, V_PLANT, '*', R_T1.MFGTYPE, R_T1.LINE,  R_T1.OUTPUT, R_T1.PRESENTHOUR, R_T1.UPPH);
           END IF;
       END LOOP;

--²¾°£¥þ½u­pºâµ{¦¡½X
       /*FOR R_T2 IN CUR_ALLLINEFIELDLIST(V_DATE) LOOP
            delete from dpmupph where period=R_T2.PERIOD and  periodtype='daily' and site=v_site and plant=v_plant and mfgtype=R_T2.MFGTYPE and line='*';
            INSERT INTO DPMUPPH
              (SYNCID, SYNCDATE, SYNCACTION, PERIOD, PERIODTYPE, SITE, PLANT, CUSTOMER, MFGTYPE, LINE, OUTPUT, PRESENTHOUR, UPPH)VALUES
              (SYNIDUPH.NEXTVAL, SYSDATE, V_SYNCACTION, R_T2.PERIOD, 'daily', V_SITE, V_PLANT, '*', R_T2.MFGTYPE, '*',  R_T2.OUTPUT, R_T2.PRESENTHOUR, R_T2.UPPH);
       END LOOP;*/
   END IF;

   COMMIT;

   IF CUR_FIELDLIST%ISOPEN THEN
       CLOSE CUR_FIELDLIST;
   END IF;
EXCEPTION
   when others then
           rollback;
           var_err_msg := '¿ù»~¦æ­:' || dbms_utility.format_error_backtrace () || '¿ù»~¥N½X:'|| sqlcode|| '¿ù»~´£¥Ü:'|| sqlerrm(sqlcode)|| '¿ù»~®É¶¡:'||V_DATE;

          insert into dpmerrlog
               values (sysdate, 'SP_COLLECTDPMUPPH_DAILY', var_err_msg);

          commit;
END;
/
