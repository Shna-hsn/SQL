CREATE OR REPLACE PROCEDURE P_STOPLINETIMEDETAILLOG IS
  v_sysdate date;
  VAR_ERR_MSG VARCHAR2(1000);

BEGIN

  select sysdate - 1 / 24 into v_sysdate from dual;

  delete from STOPLINETIMEDETAILLOG where starttime >= v_sysdate;
  commit;

  insert into STOPLINETIMEDETAILLOG
    (line, stage, Starttime, endtime, gap)
    select line,
           stage,
           starttime,
           endtime,
           (endtime - starttime) * 24 * 60 as gap
      from (select a.line,
                   a.stage,
                   a.trndate as starttime,
                   (select DECODE(min(trndate),'',SYSDATE,min(trndate))
                      from SFCMIFA139.SFCTRANSACTIONCACHE
                     where line = a.line
                       and stage = a.stage
                       and passcount = 1
                       and trndate > v_sysdate
                       and trndate > a.trndate) as endtime
              from SFCMIFA139.SFCTRANSACTIONCACHE A, SFCPP139.sfcline_map B
             where A.LINE = B.LINE
               AND (A.STAGE = B.INSTAGE OR A.STAGE = B.OUTSTAGE)
               and trndate >= v_sysdate
               and passcount = 1
             group by a.line, a.stage, a.trndate
             order by a.trndate);

  commit;

  delete from STOPLINETIMEDETAIL where starttime >= v_sysdate;
  commit;

  insert into STOPLINETIMEDETAIL
    select a.line,
           a.stage,
           a.starttime,
           a.endtime,
           a.gap,
           case
             when (a.starttime between b.downtimefrom and b.downtimeto or
                  a.endtime between b.downtimefrom and b.downtimeto or
                  (a.starttime <= b.downtimefrom and
                  a.endtime >= b.downtimefrom)) then
              to_char(b.downtimefrom, 'yyyy/mm/dd hh24:mi:ss') || '到' ||
              to_char(b.downtimeto, 'yyyy/mm/dd hh24:mi:ss') || ',' ||
              b.symption
             else
              ''
           end as remark
      from STOPLINETIMEDETAILLOG                  a,
           tibcoeai.KBLINESTOPSHOW b
     where a.line = b.line(+)
       and a.starttime >= v_sysdate
       and a.gap > 5
       AND (a.line,a.stage,a.starttime,a.endtime)
        NOT IN 
        (SELECT line,stage,starttime,endtime FROM STOPLINETIMEDETAIL 
        WHERE line = a.line 
        AND stage = a.stage 
        AND starttime = a.starttime 
        AND endtime = a.endtime);

  commit;

  delete from STOPLINETIMEDETAILLOG where starttime<sysdate-3;

  commit;

  delete from STOPLINETIMEDETAIL where starttime<sysdate-30;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    VAR_ERR_MSG :='??行?:' || dbms_utility.format_error_backtrace() ||
                  '??代?:' || sqlcode || '??提示:' || sqlerrm(sqlcode);
    INSERT INTO KBNERRORLOG VALUES (SYSDATE, 'P_STOPLINETIMEDETAILLOG', VAR_ERR_MSG);
    COMMIT;
END P_STOPLINETIMEDETAILLOG;
/
