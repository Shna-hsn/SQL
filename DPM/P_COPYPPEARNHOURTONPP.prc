create or replace procedure P_COPYPPEARNHOURTONPP IS
BEGIN

    -- 2015/12/3  把報工獲得工時的班別塞到NPPGENLOG(ppfproductivity)
  insert into nppgenlog
    (id,
     shiftdate,
     shiftid,
     line,
     stage,
     modelfamily,
     upn,
     processtype,
     sfcoutput,
     totalstandardtime,
     earnhour,
     trndate,
     gentype,
     shifttype,
     totalstandardtime1,
     onlineflag,
     department)
    (select b.id,
            a.shiftdate SHIFTDATE,
            D.SHIFTID shiftid,
            a.line line,
            b.stage stage,
            b.modelfamily modelfamily,
            b.upn upn,
            decode(a.process, 0, 'AI', 1, 'SMT', 2, 'DIP', 3, 'FA') processtype,
            b.output output,
            round(b.standardtime / b.output, 2) totalstandardtime,
            b.standardtime earnhour,
            sysdate trndate,
            0 gentype,
            a.shifttype shifttype,
            '' totalstandardtime1,
            1 onlineflag,
            D.DEPARTMENT department
       from PPFSHIFTID A, PPFPRODUCTIVITY B,NPPBASEDATA D
      WHERE A.ID = B.ID
        AND A.SHIFT = D.SHIFTID
        AND D.SPECIFICSHIFT=0
        and A.SHIFTDATE >= sysdate - 5
        and not exists (select null
               from nppgenlog d
              where d.id <> '0'
                AND d.id = b.id
                and d.stage = b.stage
                and d.upn = b.upn)

     );
  COMMIT;

      -- 2018/2/1  把報工獲得工時的班別塞到NPPGENLOG(ppfotherproduction)
   insert into nppgenlog
    (id,
     shiftdate,
     shiftid,
     line,
     stage,
     modelfamily,
     upn,
     processtype,
     sfcoutput,
     totalstandardtime,
     earnhour,
     trndate,
     gentype,
     shifttype,
     totalstandardtime1,
     onlineflag,
     department)
    (select b.id,
            a.shiftdate SHIFTDATE,
            D.SHIFTID shiftid,
            a.line line,
            b.stage stage,
            e.modelfamily modelfamily,
            b.upn upn,
            decode(a.process, 0, 'AI', 1, 'SMT', 2, 'DIP', 3, 'FA') processtype,
            b.output output,
            round(b.standardtime / b.output, 2) totalstandardtime,
            b.standardtime earnhour,
            sysdate trndate,
            0 gentype,
            a.shifttype shifttype,
            '' totalstandardtime1,
            1 onlineflag,
            D.DEPARTMENT department
       from PPFSHIFTID A, ppfotherproduction B,NPPBASEDATA D ,sfcmodel e
      WHERE A.ID = B.ID
        AND A.SHIFT = D.SHIFTID
        AND D.SPECIFICSHIFT=0
        and b.upn=e.upn
        and A.SHIFTDATE >= sysdate - 5
        and not exists (select null
               from nppgenlog d
              where d.id <> '0'
                AND d.id = b.id
                and d.stage = b.stage
                and d.upn = b.upn)

     );
  COMMIT;

  -- 2015/12/3  把off line的數據從SFCMI137.nppgenlog Copy 到 SFCPP137
  insert into nppgenlog
  (id,
   shiftdate,
   shiftid,
   line,
   stage,
   modelfamily,
   upn,
   processtype,
   sfcoutput,
   totalstandardtime,
   earnhour,
   trndate,
   gentype,
   shifttype,
   totalstandardtime1,
   onlineflag,
   department)
  (select 0 id,
          shiftdate,
          shiftid,
          line,
          stage,
          modelfamily,
          upn,
          decode(processtype,'PCB','DIP',processtype) processtype,
          sfcoutput,
          totalstandardtime,
          earnhour,
          trndate,
          gentype,
          shifttype,
          totalstandardtime1,
          onlineflag,
          department
     from sfcmi139.nppgenlog a
    where a.onlineflag = 0
      and a.modelfamily = '00.00000.000'
      and not exists (select null
             from nppgenlog b
            where b.modelfamily = '00.00000.000'
              and a.onlineflag = 0
              and b.shiftdate = a.shiftdate
              and b.shiftid = a.shiftid
              and b.shifttype = a.shifttype
              and b.line = a.line)
      and shiftdate >= sysdate - 2
      );
      Commit;
END;
/
