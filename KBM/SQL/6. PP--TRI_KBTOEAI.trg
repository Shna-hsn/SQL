create or replace trigger TRI_KBTOEAI
/*
    ============================================================================================================================
    version              author               date                 desc
    1.0                  oscar
    1.1                  brant.yang           2015/8/28            將LINEKBDETAIL的詳細資料拋到EAI當中
    1.2                  gavin                2016/9/13            修復問題: pd刪除sfcline_map裡面的線別trigger會報錯
    ============================================================================================================================
    */
  after insert or update or delete on linekbdetail
  referencing old as old new as new
  for each row
declare
  incount     number := 0;
  var_err_msg varchar2(2000);

  v_pdplantdefine varchar2(50):='P8-F139';
  v_pdplant linekbdetail.plant%type;
begin
  v_pdplant := v_pdplantdefine;

  select count(1) into incount from sfcline_map where line = :new.line and  mfgtype = :new.mfgtype;
  if incount>0 then
     select pdplant into v_pdplant from sfcline_map where line = :new.line and  mfgtype = :new.mfgtype;
     if trim(v_pdplant) is null then
       v_pdplant := :new.plant;
     else
       v_pdplant := v_pdplantdefine;
     end if;
  end if;

  if inserting then
    select count(*)
      into incount
      from tibcoeai.wkskbdetail
     where plant = :new.plant
       and mfgtype = :new.mfgtype
       and line = :new.line;
    if incount <= 0 then
      insert into tibcoeai.wkskbdetail
        (plant,
         mfgtype,
         line,
         process,
         shift,
         inmodel,
         intarget,
         inacturl,
         outmodel,
         outtarget,
         outacturl,
         fpyr,
         updatedate,
         pdplant)
      values
        (:new.plant,
         :new.mfgtype,
         :new.line,
         :new.process,
         :new.shift,
         :new.inmodel,
         :new.intarget,
         :new.inacturl,
         :new.outmodel,
         :new.outtarget,
         :new.outacturl,
         :new.fpyr,
         sysdate,
         v_pdplant);
    end if;
  end if;
  if updating then
    select count(*)
      into incount
      from tibcoeai.wkskbdetail
     where plant = :new.plant
       and mfgtype = :new.mfgtype
       and line = :new.line;
    if incount <= 0 then
      insert into tibcoeai.wkskbdetail
        (plant,
         mfgtype,
         line,
         process,
         shift,
         inmodel,
         intarget,
         inacturl,
         outmodel,
         outtarget,
         outacturl,
         fpyr,
         updatedate,
         pdplant)
      values
        (:new.plant,
         :new.mfgtype,
         :new.line,
         :new.process,
         :new.shift,
         :new.inmodel,
         :new.intarget,
         :new.inacturl,
         :new.outmodel,
         :new.outtarget,
         :new.outacturl,
         :new.fpyr,
         sysdate,
         v_pdplant);
    else
      update tibcoeai.wkskbdetail
         set plant      = :new.plant,
             mfgtype    = :new.mfgtype,
             line       = :new.line,
             process    = :new.process,
             shift      = :new.shift,
             inmodel    = :new.inmodel,
             intarget   = :new.intarget,
             inacturl   = :new.inacturl,
             outmodel   = :new.outmodel,
             outtarget  = :new.outtarget,
             outacturl  = :new.outacturl,
             fpyr       = :new.fpyr,
             updatedate = sysdate,
             pdplant    = v_pdplant
       where plant = :new.plant
         and mfgtype = :new.mfgtype
         and line = :new.line;
    end if;
  end if;
  --DELETE
  if deleting then
    delete from tibcoeai.wkskbdetail
     where plant = :old.plant
       and mfgtype = :old.mfgtype
       and line = :old.line;
  end if;

exception
  when others then
    var_err_msg := sqlerrm(sqlcode);
    insert into kbnerrorlog values (sysdate, 'TRI_KBTOEAI', var_err_msg);
    ---RETURN;
end;
