CREATE OR REPLACE TRIGGER TRI_PPFPRODPERIODTOEAI
/*
   ===========================================================================================================================================================
   version                     author                date                            description
   1.0                         oscar
   1.1                         brant                 2015/8/28                       添加備注信息,將IE定義的生產節點資料寫入EAI表中
   1.2                         brant                 2016/5/18                       增加Chart看板,保存每個節點歷史記錄,將數據保存在kb_ppfprodperiod_history表中
   1.3                         brant                 2016//11/24                     解決開始時間為空的問題，工業4.0所用
  ===========================================================================================================================================================
   */
  AFTER INSERT OR UPDATE OR DELETE ON SFCPP139.PPFPRODPERIOD
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
DECLARE
  V_PLANT          LINEKBDETAIL.PLANT%TYPE := 'P8-F139';
  Incount          NUMBER := 0;
  v_query_result   number := 0;
  v_dateid         varchar(10);
  v_starttime      DATE;
  v_starttime_temp date;
  v_endtime        DATE;
  v_endtime_temp   date;
  v_hour_start     varchar(2);
  v_hour_now       varchar(2);
  v_InFPYR         KB_PPFPRODPERIOD_HISTORY.INFPYR%TYPE := 1;
  v_OutFPYR        KB_PPFPRODPERIOD_HISTORY.OUTFPYR%TYPE := 1;
  v_smtline        SFCLINE_MAP.SMTLINES%TYPE;
  v_dipline        SFCLINE_MAP.DIPLINES%TYPE;
BEGIN

  IF UPDATING THEN
    SELECT COUNT(*)
      INTO Incount
      FROM SFCLINE_MAP
     WHERE PROCESS = :NEW.PROCESS
       AND LINE = :NEW.LINE;
    IF Incount > 0 THEN
      Incount := 0;
      SELECT COUNT(*)
        INTO Incount
        FROM TIBCOEAI.WKSKBPPFPRODPERIOD
       WHERE PLANT = V_PLANT
         AND PROCESS = :NEW.PROCESS
         AND LINE = :NEW.LINE
         AND SHIFT = :NEW.SHIFT
         AND PERIODNO = :NEW.PERIODNO;
      IF Incount <= 0 THEN
        INSERT INTO TIBCOEAI.WKSKBPPFPRODPERIOD
          (PLANT,
           PROCESS,
           LINE,
           SHIFT,
           PERIODNO,
           STARTTIME,
           ENDTIME,
           BREAKTIME,
           USERID,
           TRNDATE,
           INTARGET,
           OUTTARGET,
           INACTUAL,
           OUTACTUAL,
           UPDATETIME)
        VALUES
          (V_PLANT,
           :NEW.PROCESS,
           :NEW.LINE,
           :NEW.SHIFT,
           :NEW.PERIODNO,
           :NEW.STARTTIME,
           :NEW.ENDTIME,
           :NEW.BREAKTIME,
           :NEW.USERID,
           :NEW.TRNDATE,
           :NEW.INTARGET,
           :NEW.OUTTARGET,
           :NEW.INACTUAL,
           :NEW.OUTACTUAL,
           SYSDATE);
      ELSE
        UPDATE TIBCOEAI.WKSKBPPFPRODPERIOD
           SET PLANT      = V_PLANT,
               PROCESS    = :NEW.PROCESS,
               LINE       = :NEW.LINE,
               SHIFT      = :NEW.SHIFT,
               PERIODNO   = :NEW.PERIODNO,
               STARTTIME  = :NEW.STARTTIME,
               ENDTIME    = :NEW.ENDTIME,
               BREAKTIME  = :NEW.BREAKTIME,
               USERID     = :NEW.USERID,
               TRNDATE    = :NEW.TRNDATE,
               INTARGET   = :NEW.INTARGET,
               OUTTARGET  = :NEW.OUTTARGET,
               INACTUAL   = :NEW.INACTUAL,
               OUTACTUAL  = :NEW.OUTACTUAL,
               UPDATETIME = SYSDATE
         WHERE PLANT = V_PLANT
           AND PROCESS = :NEW.PROCESS
           AND LINE = :NEW.LINE
           AND SHIFT = :NEW.SHIFT
           AND PERIODNO = :NEW.PERIODNO;
      END IF;
    END IF;
  END IF;
  --DELETE
  IF DELETING THEN
    DELETE FROM TIBCOEAI.WKSKBPPFPRODPERIOD
     WHERE PLANT = V_PLANT
       AND PROCESS = :NEW.PROCESS
       AND LINE = :NEW.LINE
       AND SHIFT = :NEW.SHIFT
       AND PERIODNO = :NEW.PERIODNO;
  END IF;
  --保存到歷史記錄表中
  if inserting or updating then
    if :new.shift = 1 then
      if TO_CHAR(SYSDATE, 'HH24') < '12' then
        v_dateid := TO_CHAR(SYSDATE - 1, 'YYYYMMDD');
      else
        v_dateid := TO_CHAR(SYSDATE, 'YYYYMMDD');
      end if;
    else
      v_dateid := TO_CHAR(SYSDATE, 'YYYYMMDD');
    end if;
    begin
      select starttime, endtime, 1
        into v_starttime, v_endtime, v_query_result
        from kb_ppfprodperiod_history
       where line = :new.line
         and shift = :new.shift
         and periodno = :new.periodno
         and process = :new.process
         and dateid = v_dateid;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_query_result := 0;
    END;

    /*select count(*)
     into v_query_result
     from kb_ppfprodperiod_history
    where line = :new.line
      and shift = :new.shift
      and periodno = :new.periodno
      and process = :new.process
      and dateid =v_dateid;*/

    if v_query_result = 0 then
      ----計算開始時間---------------------------------------------------------------------------------
      v_starttime_temp := TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') ||
                                  :new.starttime || ':00',
                                  'YYYYMMDDHH24:mi:ss');

      v_endtime_temp := TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') ||
                                :new.endtime || ':00',
                                'YYYYMMDDHH24:mi:ss');
      v_hour_now     := TO_CHAR(SYSDATE, 'HH24');
      v_hour_start   := SUBSTR(:new.starttime, 1, 2);
      --計算夜班
      if :new.shift = 1 THEN
        /*        IF v_starttime_temp > v_endtime_temp and v_starttime_temp > SYSDATE AND
           v_hour_now < '12' THEN
          v_starttime := TO_DATE(TO_CHAR(SYSDATE - 1, 'YYYYMMDD') ||
                                 :new.starttime || ':00',
                                 'YYYYMMDDHH24:mi:ss');
        ELSIF v_hour_now >= '12' AND v_hour_start < '12' THEN
          v_starttime := TO_DATE(TO_CHAR(SYSDATE + 1, 'YYYYMMDD') ||
                                 :new.starttime || ':00',
                                 'YYYYMMDDHH24:mi:ss');
        ELSIF v_starttime_temp < v_endtime_temp AND v_hour_start > '12' AND
              v_hour_now < '12' THEN
          v_starttime := TO_DATE(TO_CHAR(SYSDATE - 1, 'YYYYMMDD') ||
                                 :new.starttime || ':00',
                                 'YYYYMMDDHH24:mi:ss');
        END IF;*/
        --夜班23:59:59以后(第二天0:00:00~8:59:59點之間，更新數據)
        if v_hour_now < 12 then

          if v_hour_start >= 20 then
            v_starttime := TO_DATE(TO_CHAR(SYSDATE - 1, 'YYYYMMDD') ||
                                   :new.starttime || ':00',
                                   'YYYYMMDDHH24:mi:ss');
          else
            v_starttime := TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') ||
                                   :new.starttime || ':00',
                                   'YYYYMMDDHH24:mi:ss');
          end if;
        end if;
        --夜班(20:00:00至23:59:59時間之內)
        if v_hour_now >= 20 then

          if v_hour_start >= 20 then
            v_starttime := TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') ||
                                   :new.starttime || ':00',
                                   'YYYYMMDDHH24:mi:ss');
          else
            v_starttime := TO_DATE(TO_CHAR(SYSDATE + 1, 'YYYYMMDD') ||
                                   :new.starttime || ':00',
                                   'YYYYMMDDHH24:mi:ss');
          end if;

        end if;

      end if;

      --計算白班開始時間
      if :new.shift = 0 THEN
        v_starttime := TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') ||
                               :new.starttime || ':00',
                               'YYYYMMDDHH24:mi:ss');
      end if;
      ---計算結束時間---------------------------------------------------------------------------------------------------
      if :new.shift = 1 then
        if TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') || :new.starttime || ':00',
                   'YYYYMMDDHH24:mi:ss') >
           TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') || :new.endtime || ':00',
                   'YYYYMMDDHH24:mi:ss') AND
           TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') || :new.starttime || ':00',
                   'YYYYMMDDHH24:mi:ss') < SYSDATE then
          v_endtime := TO_DATE(TO_CHAR(SYSDATE + 1, 'YYYYMMDD') ||
                               :new.endtime || ':00',
                               'YYYYMMDDHH24:mi:ss');
        elsif TO_CHAR(SYSDATE, 'HH24') >= '12' AND
              SUBSTR(:new.endtime, 1, 2) < '12' then
          v_endtime := TO_DATE(TO_CHAR(SYSDATE + 1, 'YYYYMMDD') ||
                               :new.endtime || ':00',
                               'YYYYMMDDHH24:mi:ss');
        elsif TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') || :new.starttime ||
                      ':00',
                      'YYYYMMDDHH24:mi:ss') <
              TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') || :new.endtime || ':00',
                      'YYYYMMDDHH24:mi:ss') AND
              TO_CHAR(SUBSTR(:new.starttime, 1, 2)) > '12' AND
              TO_CHAR(SYSDATE, 'HH24') < '12' then
          v_endtime := TO_DATE(TO_CHAR(SYSDATE - 1, 'YYYYMMDD') ||
                               :new.endtime || ':00',
                               'YYYYMMDDHH24:mi:ss');
        else
          v_endtime := TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') || :new.endtime ||
                               ':00',
                               'YYYYMMDDHH24:mi:ss');
        end if;
      end if;
      if :new.shift = 0 then

        v_endtime := TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD') || :new.endtime ||
                             ':00',
                             'YYYYMMDDHH24:mi:ss');
      end if;
      IF :NEW.PROCESS = 3 THEN
        --FA
        --FA NO NEED
        v_InFPYR := v_InFPYR;
      ELSE
        --SMT YR=TK(AOIB),TL(AOIA),TA（ATE）三站相?
        --DIP YR=QD(FUNTION TEST),IC(DIP_FINAL）站相?
        select SMTLINES, DIPLINES
          INTO v_smtline, v_dipline
          from sfcline_map
         where mfgtype = 'PCB'
           and LINE = :NEW.LINE;
        v_InFPYR  := v_InFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                             :NEW.LINE,
                                                             'TK',
                                                             v_starttime,
                                                             v_endtime,
                                                             v_smtline),
                                      6);
        v_InFPYR  := v_InFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                             :NEW.LINE,
                                                             'TL',
                                                             v_starttime,
                                                             v_endtime,
                                                             v_smtline),
                                      6);
        v_InFPYR  := v_InFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                             :NEW.LINE,
                                                             'TA',
                                                             v_starttime,
                                                             v_endtime,
                                                             v_smtline),
                                      6);
        v_InFPYR  := round(v_InFPYR, 6);
        v_OutFPYR := v_OutFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                              :NEW.LINE,
                                                              'QD',
                                                              v_starttime,
                                                              v_endtime,
                                                              v_dipline),
                                       6);
        v_OutFPYR := v_OutFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                              :NEW.LINE,
                                                              'IC',
                                                              v_starttime,
                                                              v_endtime,
                                                              v_dipline),
                                       6);
        v_OutFPYR := round(v_OutFPYR, 6);
      END IF;

      --GET YR
      /*2016.11.24 modified by eric to solve starttime is null */
      if v_starttime is null then
        v_starttime := v_endtime - 1 / 24;
      end if;
      insert into kb_ppfprodperiod_history
        (dateid,
         process,
         line,
         shift,
         periodno,
         perioddate,
         starttime,
         endtime,
         breaktime,
         userid,
         trndate,
         intarget,
         outtarget,
         inactual,
         outactual,
         updatetime,
         remark,
         INFPYR,
         OUTFPYR)
      values
        (v_dateid,
         :new.process,
         :new.line,
         :new.shift,
         :new.periodno,
         sysdate,
         v_starttime,
         v_endtime,
         :new.breaktime,
         :new.userid,
         sysdate,
         :new.intarget,
         :new.outtarget,
         :new.inactual,
         :new.outactual,
         :new.updatetime,
         '插入記錄,' || to_char(sysdate, 'yyyy-MM-dd hh24:mi:ss'),
         v_InFPYR,
         v_OutFPYR);
    else
      IF :NEW.PROCESS = 3 THEN
        --FA
        --FA NO NEED
        v_InFPYR := v_InFPYR;
      ELSE
        --SMT YR=TK(AOIB),TL(AOIA),TA（ATE）三站相?
        --DIP YR=QD(FUNTION TEST),IC(DIP_FINAL）站相?
        select SMTLINES, DIPLINES
          INTO v_smtline, v_dipline
          from sfcline_map
         where mfgtype = 'PCB'
           and LINE = :NEW.LINE;
        v_InFPYR  := v_InFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                             :NEW.LINE,
                                                             'TK',
                                                             v_starttime,
                                                             v_endtime,
                                                             v_smtline),
                                      6);
        v_InFPYR  := v_InFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                             :NEW.LINE,
                                                             'TL',
                                                             v_starttime,
                                                             v_endtime,
                                                             v_smtline),
                                      6);
        v_InFPYR  := v_InFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                             :NEW.LINE,
                                                             'TA',
                                                             v_starttime,
                                                             v_endtime,
                                                             v_smtline),
                                      6);
        v_InFPYR  := round(v_InFPYR, 6);
        v_OutFPYR := v_OutFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                              :NEW.LINE,
                                                              'QD',
                                                              v_starttime,
                                                              v_endtime,
                                                              v_dipline),
                                       6);
        v_OutFPYR := v_OutFPYR * round(Fun_GetPeriodYRBYSTAGE('PCB',
                                                              :NEW.LINE,
                                                              'IC',
                                                              v_starttime,
                                                              v_endtime,
                                                              v_dipline),
                                       6);
        v_OutFPYR := round(v_OutFPYR, 6);
      END IF;
      update kb_ppfprodperiod_history
         set perioddate = sysdate,
             breaktime  = :new.breaktime,
             userid     = :new.userid,
             trndate    = sysdate,
             intarget   = :new.intarget,
             outtarget  = :new.outtarget,
             inactual   = :new.inactual,
             outactual  = :new.outactual,
             updatetime = :new.updatetime,
             remark     = '更新記錄' ||
                          to_char(sysdate, 'yyyy-MM-dd hh24:mi:ss'),
             infpyr     = v_InFPYR,
             outfpyr    = v_OutFPYR
       where line = :new.line
         and shift = :new.shift
         and periodno = :new.periodno
         and process = :new.process
         and dateid = v_dateid;
    end if;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
/
