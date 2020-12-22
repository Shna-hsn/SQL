CREATE OR REPLACE PROCEDURE sp_dpmfpyr_hourly (processdate in date default sysdate, autoflag in boolean default true) is
   v_date date;
   v_plant varchar2(5):='F139';
   v_site varchar2(5):='WZS';
   v_syncaction varchar2(1):='C';

   v_err_msg long :='';

   cursor cur_fieldlist(v_date date) is
         with a as
          (
           select 'FA' mfgtype,line,period,'hourly' periodtype,begintime,endtime,
                           (case when s1input=0 then 1 else s1passqty/s1input end)*
                           (case when s2input=0 then 1 else s2passqty/s2input end)*
                           (case when s3input=0 then 1 else s3passqty/s3input end)*
                           (case when s4input=0 then 1 else s4passqty/s4input end)*
                           (case when s5input=0 then 1 else s5passqty/s5input end)*
                           (case when s6input=0 then 1 else s6passqty/s6input end)*
                           (case when s7input=0 then 1 else s7passqty/s7input end)*
                           (case when s8input=0 then 1 else s8passqty/s8input end)*
                           (case when s9input=0 then 1 else s9passqty/s9input end)*
                           (case when s10input=0 then 1 else s10passqty/s10input end)*
                           (case when s11input=0 then 1 else s11passqty/s11input end)*
                           (case when s12input=0 then 1 else s12passqty/s12input end)*
                           (case when s13input=0 then 1 else s13passqty/s13input end)*
                           (case when s14input=0 then 1 else s14passqty/s14input end)*
                           (case when s15input=0 then 1 else s15passqty/s15input end)*
                           (case when s16input=0 then 1 else s16passqty/s16input end)*
                           (case when s17input=0 then 1 else s17passqty/s17input end)*
                           (case when s18input=0 then 1 else s18passqty/s18input end)*
                           (case when s19input=0 then 1 else s19passqty/s19input end)*
                           (case when s20input=0 then 1 else s20passqty/s20input end)*
                           (case when s21input=0 then 1 else s21passqty/s21input end)*
                           (case when s22input=0 then 1 else s22passqty/s22input end)*
                           (case when s23input=0 then 1 else s23passqty/s23input end)*
                           (case when s24input=0 then 1 else s24passqty/s24input end)*
                           (case when s25input=0 then 1 else s25passqty/s25input end)*
                           (case when s26input=0 then 1 else s26passqty/s26input end)*
                           (case when s27input=0 then 1 else s27passqty/s27input end)*
                           (case when s28input=0 then 1 else s28passqty/s28input end)*
                           (case when s29input=0 then 1 else s29passqty/s29input end)fpyr,
                            s1input,
                            s1passqty,
                            s2input,
                            s2passqty,
                            s3input,
                            s3passqty,
                            s4input,
                            s4passqty,
                            s5input,
                            s5passqty,
                            s6input,
                            s6passqty,
                            s7input,
                            s7passqty,
                            s8input,
                            s8passqty,
                            s9input,
                            s9passqty,
                            s10input,
                            s10passqty,
                            s11input,
                            s11passqty,
                            s12input,
                            s12passqty,
                            s13input,
                            s13passqty,
                            s14input,
                            s14passqty,
                            s15input,
                            s15passqty,
                            s16input,
                            s16passqty,
                            s17input,
                            s17passqty,
                            s18input,
                            s18passqty,
                            s19input,
                            s19passqty,
                            s20input,
                            s20passqty,
                            s21input,
                            s21passqty,
                            s22input,
                            s22passqty,
                            s23input,
                            s23passqty,
                            s24input,
                            s24passqty,
                            s25input,
                            s25passqty,
                            s26input,
                            s26passqty,
                            s27input,
                            s27passqty,
                            s28input,
                            s28passqty,
                            s29input,
                            s29passqty
                    from (
                            select line,
                                   period,
                                   begintime,
                                   endtime,
                                   sum(s1input) s1input,
                                   sum(s1passqty) s1passqty,
                                   sum(s2input) s2input,
                                   sum(s2passqty) s2passqty,
                                   sum(s3input) s3input,
                                   sum(s3input) s3passqty,
                                   sum(s4input) s4input,
                                   sum(s4passqty) s4passqty,
                                   sum(s5input) s5input,
                                   sum(s5passqty) s5passqty,
                                   sum(s6input) s6input,
                                   sum(s6passqty) s6passqty,
                                   sum(s7input) s7input,
                                   sum(s7passqty) s7passqty,
                                   sum(s8input) s8input,
                                   sum(s8passqty) s8passqty,
                                   sum(s9input) s9input,
                                   sum(s9passqty) s9passqty,
                                   sum(s10input) s10input,
                                   sum(s10passqty) s10passqty,
                                   sum(s11input) s11input,
                                   sum(s11passqty) s11passqty,
                                   sum(s12input) s12input,
                                   sum(s12passqty) s12passqty,
                                   sum(s13input) s13input,
                                   sum(s13passqty) s13passqty,
                                   sum(s14input) s14input,
                                   sum(s14passqty) s14passqty,
                                   sum(s15input) s15input,
                                   sum(s15passqty) s15passqty,
                                   sum(s16input) s16input,
                                   sum(s16passqty) s16passqty,
                                   sum(s17input) s17input,
                                   sum(s17passqty) s17passqty,
                                   sum(s18input) s18input,
                                   sum(s18passqty) s18passqty,
                                   sum(s19input) s19input,
                                   sum(s19passqty) s19passqty,
                                   sum(s20input) s20input,
                                   sum(s20passqty) s20passqty,
                                   sum(s21input) s21input,
                                   sum(s21passqty) s21passqty,
                                   sum(s22input) s22input,
                                   sum(s22passqty) s22passqty,
                                   sum(s23input) s23input,
                                   sum(s23passqty) s23passqty,
                                   sum(s24input) s24input,
                                   sum(s24passqty) s24passqty,
                                   sum(s25input) s25input,
                                   sum(s25passqty) s25passqty,
                                   sum(s26input) s26input,
                                   sum(s26passqty) s26passqty,
                                   sum(s27input) s27input,
                                   sum(s27passqty) s27passqty,
                                   sum(s28input) s28input,
                                   sum(s28passqty) s28passqty,
                                   sum(s29input) s29input,
                                   sum(s29passqty) s29passqty
                            from (select a.line,a.period,a.begintime,a.endtime,
                                   case when b.rnum=1 then sum(totalcount) else 0 end s1input,
                                   case when b.rnum=1 then sum(passcount) else 0  end s1passqty,
                                   case when b.rnum=2 then sum(totalcount) else 0  end s2input,
                                   case when b.rnum=2 then sum(passcount) else 0  end s2passqty,
                                   case when b.rnum=3 then sum(totalcount) else 0  end s3input,
                                   case when b.rnum=3 then sum(passcount) else 0  end s3passqty,
                                   case when b.rnum=4 then sum(totalcount) else 0  end s4input,
                                   case when b.rnum=4 then sum(passcount) else 0  end s4passqty,
                                   case when b.rnum=5 then sum(totalcount) else 0  end s5input,
                                   case when b.rnum=5 then sum(passcount) else 0  end s5passqty,
                                   case when b.rnum=6 then sum(totalcount) else 0  end s6input,
                                   case when b.rnum=6 then sum(passcount) else 0  end s6passqty,
                                   case when b.rnum=7 then sum(totalcount) else 0  end s7input,
                                   case when b.rnum=7 then sum(passcount) else 0  end s7passqty,
                                   case when b.rnum=8 then sum(totalcount) else 0  end s8input,
                                   case when b.rnum=8 then sum(passcount) else 0  end s8passqty,
                                   case when b.rnum=9 then sum(totalcount) else 0  end s9input,
                                   case when b.rnum=9 then sum(passcount) else 0  end s9passqty,
                                   case when b.rnum=10 then sum(totalcount) else 0  end s10input,
                                   case when b.rnum=10 then sum(passcount) else 0  end s10passqty,
                                   case when b.rnum=11 then sum(totalcount) else 0  end s11input,
                                   case when b.rnum=11 then sum(passcount) else 0  end s11passqty,
                                   case when b.rnum=12 then sum(totalcount) else 0  end s12input,
                                   case when b.rnum=12 then sum(passcount) else 0  end s12passqty,
                                   case when b.rnum=13 then sum(totalcount) else 0  end s13input,
                                   case when b.rnum=13 then sum(passcount) else 0  end s13passqty,
                                   case when b.rnum=14 then sum(totalcount) else 0  end s14input,
                                   case when b.rnum=14 then sum(passcount) else 0  end s14passqty,
                                   case when b.rnum=15 then sum(totalcount) else 0  end s15input,
                                   case when b.rnum=15 then sum(passcount) else 0  end s15passqty,
                                   case when b.rnum=16 then sum(totalcount) else 0  end s16input,
                                   case when b.rnum=16 then sum(passcount) else 0  end s16passqty,
                                   case when b.rnum=17 then sum(totalcount) else 0  end s17input,
                                   case when b.rnum=17 then sum(passcount) else 0  end s17passqty,
                                   case when b.rnum=18 then sum(totalcount) else 0  end s18input,
                                   case when b.rnum=18 then sum(passcount) else 0  end s18passqty,
                                   case when b.rnum=19 then sum(totalcount) else 0  end s19input,
                                   case when b.rnum=19 then sum(passcount) else 0  end s19passqty,
                                   case when b.rnum=20 then sum(totalcount) else 0  end s20input,
                                   case when b.rnum=20 then sum(passcount) else 0  end s20passqty,
                                   case when b.rnum=21 then sum(totalcount) else 0  end s21input,
                                   case when b.rnum=21 then sum(passcount) else 0  end s21passqty,
                                   case when b.rnum=22 then sum(totalcount) else 0  end s22input,
                                   case when b.rnum=22 then sum(passcount) else 0  end s22passqty,
                                   case when b.rnum=23 then sum(totalcount) else 0  end s23input,
                                   case when b.rnum=23 then sum(passcount) else 0  end s23passqty,
                                   case when b.rnum=24 then sum(totalcount) else 0  end s24input,
                                   case when b.rnum=24 then sum(passcount) else 0  end s24passqty,
                                   case when b.rnum=25 then sum(totalcount) else 0  end s25input,
                                   case when b.rnum=25 then sum(passcount) else 0  end s25passqty,
                                   case when b.rnum=26 then sum(totalcount) else 0  end s26input,
                                   case when b.rnum=26 then sum(passcount) else 0  end s26passqty,
                                   case when b.rnum=27 then sum(totalcount) else 0  end s27input,
                                   case when b.rnum=27 then sum(passcount) else 0  end s27passqty,
                                   case when b.rnum=28 then sum(totalcount) else 0  end s28input,
                                   case when b.rnum=28 then sum(passcount) else 0  end s28passqty,
                                   case when b.rnum=29 then sum(totalcount) else 0  end s29input,
                                   case when b.rnum=29 then sum(passcount) else 0  end s29passqty
                                 from (
                                        select a.line,
                                               a.stage,
                                               count(case when a.resultflag=1 then 1
                                                          else null
                                                          end) passcount,
                                               count(1) totalcount,
                                               b.period,
                                               b.begintime,
                                               b.endtime
                                        from    sfcmifa139.sfctransactioncache a,
                                                (select period,
                                                    begintime,
                                                    endtime
                                                 from (select    case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='FA' and period='01')
                                                                          then to_char(v_date-1,'yyyymmdd')
                                                                       else
                                                                          to_char(v_date,'yyyymmdd') end ||period  period,
                                                                  case when period>=(select period dayshiftlastperiod from (select * from dpmfpyrperiodbase where endtime>='00:00'and mfgtype='FA' order by endtime) where rownum=1)+1
                                                                          then to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='FA' and period='01')
                                                                                                        then v_date-1
                                                                                                     else
                                                                                                        v_date end +1,'yyyymmdd ')||begintime,'yyyymmdd hh24:mi')
                                                                       else to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='FA' and period='01')
                                                                                                    then v_date-1
                                                                                                 else
                                                                                                    v_date end,'yyyymmdd ')||begintime,'yyyymmdd hh24:mi') end begintime,
                                                                  case when period>=(select period dayshiftlastperiod from (select * from dpmfpyrperiodbase where endtime>='00:00' and mfgtype='FA' order by endtime ) where rownum=1)
                                                                         then to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='FA' and period='01')
                                                                                                    then v_date-1
                                                                                                 else
                                                                                                    v_date end +1,'yyyymmdd ')||endtime,'yyyymmdd hh24:mi')
                                                                       else to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='FA' and period='01')
                                                                                                   then v_date-1
                                                                                                 else
                                                                                                    v_date end,'yyyymmdd ')||endtime,'yyyymmdd hh24:mi') end endtime
                                                          from dpmfpyrperiodbase where mfgtype='FA')
                                                        where begintime<=v_date and v_date<endtime
                                                 ) b,
                                                sfcline_map c
                                                where b.begintime<=a.trndate and a.trndate<b.endtime
                                                and   a.passcount=1
                                                and   a.line=c.line
                                                and   c.mfgtype='FA'
                                                and   instr(c.fpyrstage,a.stage)>0
                                                group by a.line,a.stage,b.period,b.begintime,b.endtime
                                      ) a,
                                      (select rownum rnum, stage
                                       from (select distinct b.stage
                                              from table(cast(fun_str_split((select listagg (fpyrstage, ',')within group (order by line) from sfcline_map where mfgtype = 'FA'),',') as ty_str_split)) a,
                                                   sfcstage b
                                              where b.stage = a.column_value
                                              order by case when stage='AD' then 1
                                                            when stage='FB' then 2
                                                            when stage='FT' then 3
                                                            when stage='FF' then 4
                                                            when stage='FG' then 5
                                                            when stage='FD' then 6
                                                            when stage='FK' then 7
                                                            when stage='FA' then 8
                                                            when stage='FQ' then 9
                                                            when stage='FO' then 10
                                                            when stage='FY' then 11
                                                            when stage='FR' then 12
                                                            when stage='MN' then 13
                                                            when stage='UK' then 14
                                                            when stage='MJ' then 15
                                                            when stage='PR' then 16
                                                            when stage='KB' then 17
                                                            when stage='PK' then 18
                                                            when stage='PT' then 19
                                                            when stage='PB' then 20
                                                            when stage='PC' then 21
                                                            when stage='LL' then 22
                                                            when stage='YD' then 23
                                                            when stage='PL' then 24
                                                            when stage='QX' then 25
                                                            when stage='WF' then 26
                                                            when stage='UT' then 27
                                                            when stage='BT' then 28
                                                            else 29
                                                            end)
                                       where rownum<=29) b
                                      where a.stage=b.stage
                                      and a.stage in ('AD','FB','FT','FF','FG','FD','FK','FA','FQ','FO','FY','FR','MN','UK','MJ','PR','KB','PK','PT','PB','PC','LL','YD','PL','QX','WF','UT','BT')
                                      group by a.line,b.rnum,a.period,a.begintime,a.endtime
                            )
                            group by line,period,begintime,endtime
                            order by line
                    )
                    union
                    select 'PCB' mfgtype,line,period,'hourly' periodtype,begintime,endtime,
                           (case when s1input=0 then 1 else s1passqty/s1input end)*
                           (case when s2input=0 then 1 else s2passqty/s2input end)*
                           (case when s3input=0 then 1 else s3passqty/s3input end)*
                           (case when s4input=0 then 1 else s4passqty/s4input end)*
                           (case when s5input=0 then 1 else s5passqty/s5input end)*
                           (case when s6input=0 then 1 else s6passqty/s6input end)*
                           (case when s7input=0 then 1 else s7passqty/s7input end)*
                           (case when s8input=0 then 1 else s8passqty/s8input end)*
                           (case when s9input=0 then 1 else s9passqty/s9input end)*
                           (case when s10input=0 then 1 else s10passqty/s10input end)*
                           (case when s11input=0 then 1 else s11passqty/s11input end)*
                           (case when s12input=0 then 1 else s12passqty/s12input end)*
                           (case when s13input=0 then 1 else s13passqty/s13input end)*
                           (case when s14input=0 then 1 else s14passqty/s14input end)*
                           (case when s15input=0 then 1 else s15passqty/s15input end)*
                           (case when s16input=0 then 1 else s16passqty/s16input end)*
                           (case when s17input=0 then 1 else s17passqty/s17input end)*
                           (case when s18input=0 then 1 else s18passqty/s18input end)*
                           (case when s19input=0 then 1 else s19passqty/s19input end)*
                           (case when s20input=0 then 1 else s20passqty/s20input end)*
                           (case when s21input=0 then 1 else s21passqty/s21input end)*
                           (case when s22input=0 then 1 else s22passqty/s22input end)*
                           (case when s23input=0 then 1 else s23passqty/s23input end)*
                           (case when s24input=0 then 1 else s24passqty/s24input end)*
                           (case when s25input=0 then 1 else s25passqty/s25input end)*
                           (case when s26input=0 then 1 else s26passqty/s26input end)*
                           (case when s27input=0 then 1 else s27passqty/s27input end)*
                           (case when s28input=0 then 1 else s28passqty/s28input end)*
                           (case when s29input=0 then 1 else s29passqty/s29input end)fpyr,
                            s1input,
                            s1passqty,
                            s2input,
                            s2passqty,
                            s3input,
                            s3passqty,
                            s4input,
                            s4passqty,
                            s5input,
                            s5passqty,
                            s6input,
                            s6passqty,
                            s7input,
                            s7passqty,
                            s8input,
                            s8passqty,
                            s9input,
                            s9passqty,
                            s10input,
                            s10passqty,
                            s11input,
                            s11passqty,
                            s12input,
                            s12passqty,
                            s13input,
                            s13passqty,
                            s14input,
                            s14passqty,
                            s15input,
                            s15passqty,
                            s16input,
                            s16passqty,
                            s17input,
                            s17passqty,
                            s18input,
                            s18passqty,
                            s19input,
                            s19passqty,
                            s20input,
                            s20passqty,
                            s21input,
                            s21passqty,
                            s22input,
                            s22passqty,
                            s23input,
                            s23passqty,
                            s24input,
                            s24passqty,
                            s25input,
                            s25passqty,
                            s26input,
                            s26passqty,
                            s27input,
                            s27passqty,
                            s28input,
                            s28passqty,
                            s29input,
                            s29passqty
                    from (
                            select line,
                                   period,
                                   begintime,
                                   endtime,
                                   sum(s1input) s1input,
                                   sum(s1passqty) s1passqty,
                                   sum(s2input) s2input,
                                   sum(s2passqty) s2passqty,
                                   sum(s3input) s3input,
                                   sum(s3passqty) s3passqty,
                                   sum(s4input) s4input,
                                   sum(s4passqty) s4passqty,
                                   sum(s5input) s5input,
                                   sum(s5passqty) s5passqty,
                                   sum(s6input) s6input,
                                   sum(s6passqty) s6passqty,
                                   sum(s7input) s7input,
                                   sum(s7passqty) s7passqty,
                                   sum(s8input) s8input,
                                   sum(s8passqty) s8passqty,
                                   sum(s9input) s9input,
                                   sum(s9passqty) s9passqty,
                                   sum(s10input) s10input,
                                   sum(s10passqty) s10passqty,
                                   sum(s11input) s11input,
                                   sum(s11passqty) s11passqty,
                                   sum(s12input) s12input,
                                   sum(s12passqty) s12passqty,
                                   sum(s13input) s13input,
                                   sum(s13passqty) s13passqty,
                                   sum(s14input) s14input,
                                   sum(s14passqty) s14passqty,
                                   sum(s15input) s15input,
                                   sum(s15passqty) s15passqty,
                                   sum(s16input) s16input,
                                   sum(s16passqty) s16passqty,
                                   sum(s17input) s17input,
                                   sum(s17passqty) s17passqty,
                                   sum(s18input) s18input,
                                   sum(s18passqty) s18passqty,
                                   sum(s19input) s19input,
                                   sum(s19passqty) s19passqty,
                                   sum(s20input) s20input,
                                   sum(s20passqty) s20passqty,
                                   sum(s21input) s21input,
                                   sum(s21passqty) s21passqty,
                                   sum(s22input) s22input,
                                   sum(s22passqty) s22passqty,
                                   sum(s23input) s23input,
                                   sum(s23passqty) s23passqty,
                                   sum(s24input) s24input,
                                   sum(s24passqty) s24passqty,
                                   sum(s25input) s25input,
                                   sum(s25passqty) s25passqty,
                                   sum(s26input) s26input,
                                   sum(s26passqty) s26passqty,
                                   sum(s27input) s27input,
                                   sum(s27passqty) s27passqty,
                                   sum(s28input) s28input,
                                   sum(s28passqty) s28passqty,
                                   sum(s29input) s29input,
                                   sum(s29passqty) s29passqty
                            from (select a.line,a.period,a.begintime,a.endtime,
                                   case when b.rnum=1 then sum(totalcount) else 0 end s1input,
                                   case when b.rnum=1 then sum(passcount) else 0  end s1passqty,
                                   case when b.rnum=2 then sum(totalcount) else 0  end s2input,
                                   case when b.rnum=2 then sum(passcount) else 0  end s2passqty,
                                   case when b.rnum=3 then sum(totalcount) else 0  end s3input,
                                   case when b.rnum=3 then sum(passcount) else 0  end s3passqty,
                                   case when b.rnum=4 then sum(totalcount) else 0  end s4input,
                                   case when b.rnum=4 then sum(passcount) else 0  end s4passqty,
                                   case when b.rnum=5 then sum(totalcount) else 0  end s5input,
                                   case when b.rnum=5 then sum(passcount) else 0  end s5passqty,
                                   case when b.rnum=6 then sum(totalcount) else 0  end s6input,
                                   case when b.rnum=6 then sum(passcount) else 0  end s6passqty,
                                   case when b.rnum=7 then sum(totalcount) else 0  end s7input,
                                   case when b.rnum=7 then sum(passcount) else 0  end s7passqty,
                                   case when b.rnum=8 then sum(totalcount) else 0  end s8input,
                                   case when b.rnum=8 then sum(passcount) else 0  end s8passqty,
                                   case when b.rnum=9 then sum(totalcount) else 0  end s9input,
                                   case when b.rnum=9 then sum(passcount) else 0  end s9passqty,
                                   case when b.rnum=10 then sum(totalcount) else 0  end s10input,
                                   case when b.rnum=10 then sum(passcount) else 0  end s10passqty,
                                   case when b.rnum=11 then sum(totalcount) else 0  end s11input,
                                   case when b.rnum=11 then sum(passcount) else 0  end s11passqty,
                                   case when b.rnum=12 then sum(totalcount) else 0  end s12input,
                                   case when b.rnum=12 then sum(passcount) else 0  end s12passqty,
                                   case when b.rnum=13 then sum(totalcount) else 0  end s13input,
                                   case when b.rnum=13 then sum(passcount) else 0  end s13passqty,
                                   case when b.rnum=14 then sum(totalcount) else 0  end s14input,
                                   case when b.rnum=14 then sum(passcount) else 0  end s14passqty,
                                   case when b.rnum=15 then sum(totalcount) else 0  end s15input,
                                   case when b.rnum=15 then sum(passcount) else 0  end s15passqty,
                                   case when b.rnum=16 then sum(totalcount) else 0  end s16input,
                                   case when b.rnum=16 then sum(passcount) else 0  end s16passqty,
                                   case when b.rnum=17 then sum(totalcount) else 0  end s17input,
                                   case when b.rnum=17 then sum(passcount) else 0  end s17passqty,
                                   case when b.rnum=18 then sum(totalcount) else 0  end s18input,
                                   case when b.rnum=18 then sum(passcount) else 0  end s18passqty,
                                   case when b.rnum=19 then sum(totalcount) else 0  end s19input,
                                   case when b.rnum=19 then sum(passcount) else 0  end s19passqty,
                                   case when b.rnum=20 then sum(totalcount) else 0  end s20input,
                                   case when b.rnum=20 then sum(passcount) else 0  end s20passqty,
                                   case when b.rnum=21 then sum(totalcount) else 0  end s21input,
                                   case when b.rnum=21 then sum(passcount) else 0  end s21passqty,
                                   case when b.rnum=22 then sum(totalcount) else 0  end s22input,
                                   case when b.rnum=22 then sum(passcount) else 0  end s22passqty,
                                   case when b.rnum=23 then sum(totalcount) else 0  end s23input,
                                   case when b.rnum=23 then sum(passcount) else 0  end s23passqty,
                                   case when b.rnum=24 then sum(totalcount) else 0  end s24input,
                                   case when b.rnum=24 then sum(passcount) else 0  end s24passqty,
                                   case when b.rnum=25 then sum(totalcount) else 0  end s25input,
                                   case when b.rnum=25 then sum(passcount) else 0  end s25passqty,
                                   case when b.rnum=26 then sum(totalcount) else 0  end s26input,
                                   case when b.rnum=26 then sum(passcount) else 0  end s26passqty,
                                   case when b.rnum=27 then sum(totalcount) else 0  end s27input,
                                   case when b.rnum=27 then sum(passcount) else 0  end s27passqty,
                                   case when b.rnum=28 then sum(totalcount) else 0  end s28input,
                                   case when b.rnum=28 then sum(passcount) else 0  end s28passqty,
                                   case when b.rnum=29 then sum(totalcount) else 0  end s29input,
                                   case when b.rnum=29 then sum(passcount) else 0  end s29passqty
                                 from (
                                        select case when instr(c.smtlines,a.line)>0 then c.line
                                                    else a.line
                                                    end line,
                                               a.stage,
                                               count(case when a.resultflag=1 then 1
                                                          else null
                                                          end) passcount,
                                               count(1) totalcount,
                                               b.period,
                                               b.begintime,
                                               b.endtime
                                        from    sfcmipcb139.sfctransactioncache a,
                                                (select period,
                                                    begintime,
                                                    endtime
                                                 from (select    case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='PCB' and period='01')
                                                                          then to_char(v_date-1,'yyyymmdd')
                                                                       else
                                                                          to_char(v_date,'yyyymmdd') end ||period  period,
                                                                  case when period>=(select period dayshiftlastperiod from (select * from dpmfpyrperiodbase where endtime>='00:00'and mfgtype='PCB' order by endtime) where rownum=1)+1
                                                                          then to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='PCB' and period='01')
                                                                                                        then v_date-1
                                                                                                     else
                                                                                                        v_date end +1,'yyyymmdd ')||begintime,'yyyymmdd hh24:mi')
                                                                       else to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='PCB' and period='01')
                                                                                                    then v_date-1
                                                                                                 else
                                                                                                    v_date end,'yyyymmdd ')||begintime,'yyyymmdd hh24:mi') end begintime,
                                                                  case when period>=(select period dayshiftlastperiod from (select * from dpmfpyrperiodbase where endtime>='00:00' and mfgtype='PCB' order by endtime ) where rownum=1)
                                                                       then to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='PCB' and period='01')
                                                                                                    then v_date-1
                                                                                                 else
                                                                                                    v_date end +1,'yyyymmdd ')||endtime,'yyyymmdd hh24:mi')
                                                                      else to_date(to_char(case when to_char(v_date,'hh24:mi')<(select begintime from dpmfpyrperiodbase where mfgtype='PCB' and period='01')
                                                                                                   then v_date-1
                                                                                                 else
                                                                                                    v_date end,'yyyymmdd ')||endtime,'yyyymmdd hh24:mi') end endtime
                                                          from dpmfpyrperiodbase where mfgtype='PCB')
                                                        where begintime<=v_date and v_date<endtime
                                                 ) b,
                                                sfcline_map c
                                                where b.begintime<=a.trndate and a.trndate<b.endtime
                                                and   a.passcount=1
                                                and   (a.line=c.line or instr(c.smtlines,a.line)>0)
                                                and   c.mfgtype='PCB'
                                                and   instr(c.fpyrstage,a.stage)>0
                                                group by a.line,a.stage,b.period,b.begintime,b.endtime,c.smtlines,c.line
                                      ) a,
                                      (select rownum rnum, stage
                                       from (select distinct b.stage
                                              from table(cast(fun_str_split((select listagg (fpyrstage, ',')within group (order by line) from sfcline_map where mfgtype = 'PCB'),',') as ty_str_split)) a,
                                                   sfcstage b
                                              where b.stage = a.column_value
                                              order by case when stage='TK' then 1
                                                            when stage='TN' then 2
                                                            when stage='TC' then 3
                                                            when stage='TF' then 4
                                                            when stage='TH' then 5
                                                            when stage='TA' then 6
                                                            when stage='TB' then 7
                                                            when stage='IO' then 8
                                                            else 29
                                                            end)
                                       where rownum<=29) b
                                      where a.stage=b.stage
                                      and a.stage in ('TK','TN','TC','TF','TH','TA','TB','IO')
                                      group by a.line,b.rnum,a.period,a.begintime,a.endtime
                            )
                            group by line,period,begintime,endtime
                            order by line
                    )
          )
          select * from a
          /*union
          select mfgtype,'*',period,periodtype,begintime,endtime,
               (case when sum(s1input)=0 then 1 else sum(s1passqty)/sum(s1input) end)*
               (case when sum(s2input)=0 then 1 else sum(s2passqty)/sum(s2input) end)*
               (case when sum(s3input)=0 then 1 else sum(s3passqty)/sum(s3input) end)*
               (case when sum(s4input)=0 then 1 else sum(s4passqty)/sum(s4input) end)*
               (case when sum(s5input)=0 then 1 else sum(s5passqty)/sum(s5input) end)*
               (case when sum(s6input)=0 then 1 else sum(s6passqty)/sum(s6input) end)*
               (case when sum(s7input)=0 then 1 else sum(s7passqty)/sum(s7input) end)*
               (case when sum(s8input)=0 then 1 else sum(s8passqty)/sum(s8input) end)*
               (case when sum(s9input)=0 then 1 else sum(s9passqty)/sum(s9input) end)*
               (case when sum(s10input)=0 then 1 else sum(s10passqty)/sum(s10input) end)*
               (case when sum(s11input)=0 then 1 else sum(s11passqty)/sum(s11input) end)*
               (case when sum(s12input)=0 then 1 else sum(s12passqty)/sum(s12input) end)*
               (case when sum(s13input)=0 then 1 else sum(s13passqty)/sum(s13input) end)*
               (case when sum(s14input)=0 then 1 else sum(s14passqty)/sum(s14input) end)*
               (case when sum(s15input)=0 then 1 else sum(s15passqty)/sum(s15input) end)*
               (case when sum(s16input)=0 then 1 else sum(s16passqty)/sum(s16input) end)*
               (case when sum(s17input)=0 then 1 else sum(s17passqty)/sum(s17input) end)*
               (case when sum(s18input)=0 then 1 else sum(s18passqty)/sum(s18input) end)*
               (case when sum(s19input)=0 then 1 else sum(s19passqty)/sum(s19input) end)*
               (case when sum(s20input)=0 then 1 else sum(s20passqty)/sum(s20input) end)*
               (case when sum(s21input)=0 then 1 else sum(s21passqty)/sum(s21input) end)*
               (case when sum(s22input)=0 then 1 else sum(s22passqty)/sum(s22input) end)*
               (case when sum(s23input)=0 then 1 else sum(s23passqty)/sum(s23input) end) fpyr,
               sum(s1input),
                sum(s1passqty),
                sum(s2input),
                sum(s2passqty),
                sum(s3input),
                sum(s3passqty),
                sum(s4input),
                sum(s4passqty),
                sum(s5input),
                sum(s5passqty),
                sum(s6input),
                sum(s6passqty),
                sum(s7input),
                sum(s7passqty),
                sum(s8input),
                sum(s8passqty),
                sum(s9input),
                sum(s9passqty),
                sum(s10input),
                sum(s10passqty),
                sum(s11input),
                sum(s11passqty),
                sum(s12input),
                sum(s12passqty),
                sum(s13input),
                sum(s13passqty),
                sum(s14input),
                sum(s14passqty),
                sum(s15input),
                sum(s15passqty),
                sum(s16input),
                sum(s16passqty),
                sum(s17input),
                sum(s17passqty),
                sum(s18input),
                sum(s18passqty),
                sum(s19input),
                sum(s19passqty),
                sum(s20input),
                sum(s20passqty),
                sum(s21input),
                sum(s21passqty),
                sum(s22input),
                sum(s22passqty),
                sum(s23input),
                sum(s23passqty)
          from a
          group by mfgtype,period,periodtype,begintime,endtime*/;


begin

   v_date:=processdate;

   if autoflag=true then
       for r_t1 in cur_fieldlist(v_date) loop
        delete from dpmfpyr where periodtype=r_t1.periodtype and period=r_t1.period and mfgtype=r_t1.mfgtype and line=r_t1.line;
        insert into dpmfpyr
          (syncid, syncdate, syncaction, period, periodtype,begintime,endtime, site, plant, customer, mfgtype, line, fpyr, s1input, s1passqty, s2input, s2passqty, s3input, s3passqty, s4input, s4passqty, s5input, s5passqty, s6input, s6passqty, s7input, s7passqty,s8input, s8passqty, s9input, s9passqty, s10input, s10passqty, s11input, s11passqty, s12input, s12passqty, s13input, s13passqty, s14input, s14passqty, s15input, s15passqty, s16input, s16passqty, s17input, s17passqty, s18input, s18passqty, s19input, s19passqty, s20input, s20passqty, s21input, s21passqty, s22input, s22passqty, s23input, s23passqty, s24input, s24passqty, s25input, s25passqty, s26input, s26passqty, s27input, s27passqty, s28input, s28passqty, s29input, s29passqty)
        values
          (SYNIDFPYR.nextval, sysdate, v_syncaction, r_t1.period, r_t1.periodtype,r_t1.begintime,r_t1.endtime, v_site, v_plant, '*', r_t1.mfgtype, r_t1.line, r_t1.fpyr, r_t1.s1input, r_t1.s1passqty,r_t1.s2input, r_t1.s2passqty, r_t1.s3input, r_t1.s3passqty, r_t1.s4input, r_t1.s4passqty, r_t1.s5input, r_t1.s5passqty, r_t1.s6input, r_t1.s6passqty, r_t1.s7input, r_t1.s7passqty, r_t1.s8input, r_t1.s8passqty, r_t1.s9input, r_t1.s9passqty, r_t1.s10input, r_t1.s10passqty, r_t1.s11input, r_t1.s11passqty, r_t1.s12input, r_t1.s12passqty, r_t1.s13input, r_t1.s13passqty, r_t1.s14input, r_t1.s14passqty, r_t1.s15input, r_t1.s15passqty, r_t1.s16input, r_t1.s16passqty, r_t1.s17input, r_t1.s17passqty, r_t1.s18input, r_t1.s18passqty, r_t1.s19input, r_t1.s19passqty, r_t1.s20input, r_t1.s20passqty, r_t1.s21input, r_t1.s21passqty, r_t1.s22input, r_t1.s22passqty, r_t1.s23input, r_t1.s23passqty, r_t1.s24input, r_t1.s24passqty, r_t1.s25input, r_t1.s25passqty, r_t1.s26input, r_t1.s26passqty, r_t1.s27input, r_t1.s27passqty, r_t1.s28input, r_t1.s28passqty, r_t1.s29input, r_t1.s29passqty);
       end loop;
   end if;

   --Resend data
   if autoflag=false then
     v_syncaction:='U';

      for r_t1 in cur_fieldlist(v_date) loop
        delete from dpmfpyr where periodtype=r_t1.periodtype and period=r_t1.period and mfgtype=r_t1.mfgtype and line=r_t1.line;
        insert into dpmfpyr
          (syncid, syncdate, syncaction, period, periodtype,begintime,endtime, site, plant, customer, mfgtype, line, fpyr, s1input, s1passqty, s2input, s2passqty, s3input, s3passqty, s4input, s4passqty, s5input, s5passqty, s6input, s6passqty, s7input, s7passqty, s8input, s8passqty, s9input, s9passqty, s10input, s10passqty, s11input, s11passqty, s12input, s12passqty, s13input, s13passqty, s14input, s14passqty, s15input, s15passqty, s16input, s16passqty, s17input, s17passqty, s18input, s18passqty, s19input, s19passqty, s20input, s20passqty, s21input, s21passqty, s22input, s22passqty, s23input, s23passqty, s24input, s24passqty, s25input, s25passqty, s26input, s26passqty, s27input, s27passqty, s28input, s28passqty, s29input, s29passqty)
        values
          (SYNIDFPYR.nextval, sysdate, v_syncaction, r_t1.period, r_t1.periodtype,r_t1.begintime,r_t1.endtime, v_site, v_plant, '*', r_t1.mfgtype, r_t1.line, r_t1.fpyr, r_t1.s1input, r_t1.s1passqty,r_t1.s2input, r_t1.s2passqty, r_t1.s3input, r_t1.s3passqty, r_t1.s4input, r_t1.s4passqty, r_t1.s5input, r_t1.s5passqty, r_t1.s6input, r_t1.s6passqty, r_t1.s7input, r_t1.s7passqty, r_t1.s8input, r_t1.s8passqty, r_t1.s9input, r_t1.s9passqty, r_t1.s10input, r_t1.s10passqty, r_t1.s11input, r_t1.s11passqty, r_t1.s12input, r_t1.s12passqty, r_t1.s13input, r_t1.s13passqty, r_t1.s14input, r_t1.s14passqty, r_t1.s15input, r_t1.s15passqty, r_t1.s16input, r_t1.s16passqty, r_t1.s17input, r_t1.s17passqty, r_t1.s18input, r_t1.s18passqty, r_t1.s19input, r_t1.s19passqty, r_t1.s20input, r_t1.s20passqty, r_t1.s21input, r_t1.s21passqty, r_t1.s22input, r_t1.s22passqty, r_t1.s23input, r_t1.s23passqty, r_t1.s24input, r_t1.s24passqty, r_t1.s25input, r_t1.s25passqty, r_t1.s26input, r_t1.s26passqty, r_t1.s27input, r_t1.s27passqty, r_t1.s28input, r_t1.s28passqty, r_t1.s29input, r_t1.s29passqty);
       end loop;
   end if;

   commit;

   if cur_fieldlist%isopen then
       close cur_fieldlist;
   end if;
exception
   when others then
     rollback;
     v_err_msg := '錯誤行號:' || dbms_utility.format_error_backtrace () || '錯誤代碼:'|| sqlcode|| '錯誤提示:'|| sqlerrm(sqlcode);
     insert into dpmerrlog values(sysdate, 'sp_dpmfpyr_hourly', v_err_msg);
     commit;
end;
/
