CREATE OR REPLACE TRIGGER TRI_FRYRTOEAI
AFTER INSERT OR UPDATE OR DELETE ON SFCPP139.FPYRDETAIL
REFERENCING OLD AS OLD NEW AS NEW
   FOR EACH ROW
DECLARE
    Incount NUMBER :=0;
    InSumCount NUMBER :=0;
    InSumCountNG NUMBER :=0;
BEGIN
   IF INSERTING THEN
      SELECT COUNT(*) INTO Incount FROM TIBCOEAI.WKSKBFPYRDETAIL WHERE PLANT =:NEW.PLANT AND MFGTYPE = :NEW.MFGTYPE AND LINE = :NEW.LINE AND STAGE=:NEW.STAGE;
         IF Incount <=0 THEN
          INSERT INTO TIBCOEAI.WKSKBFPYRDETAIL
            (PLANT,MFGTYPE,LINE,STAGE,COUNT,NGCOUNT,UPDATEDATE)
             VALUES(:NEW.PLANT,:NEW.MFGTYPE,:NEW.LINE,:NEW.STAGE,:NEW.COUNT,:NEW.NGCOUNT,SYSDATE);
        END IF;
   END IF;
   IF UPDATING THEN
     SELECT COUNT(*) INTO Incount FROM TIBCOEAI.WKSKBFPYRDETAIL WHERE PLANT =:NEW.PLANT AND MFGTYPE = :NEW.MFGTYPE AND LINE = :NEW.LINE AND STAGE=:NEW.STAGE;
        IF Incount <=0 THEN
          INSERT INTO TIBCOEAI.WKSKBFPYRDETAIL
            (PLANT,MFGTYPE,LINE,STAGE,COUNT,NGCOUNT,UPDATEDATE)
             VALUES(:NEW.PLANT,:NEW.MFGTYPE,:NEW.LINE,:NEW.STAGE,:NEW.COUNT,:NEW.NGCOUNT,SYSDATE);
        ELSE
           UPDATE TIBCOEAI.WKSKBFPYRDETAIL
           SET PLANT=:NEW.PLANT,MFGTYPE=:NEW.MFGTYPE,LINE=:NEW.LINE,STAGE=:NEW.STAGE,COUNT=:NEW.COUNT,NGCOUNT=:NEW.NGCOUNT,UPDATEDATE=SYSDATE
           WHERE PLANT =:NEW.PLANT AND MFGTYPE = :NEW.MFGTYPE AND LINE = :NEW.LINE AND STAGE=:NEW.STAGE;
        END IF;
   END IF;
      --DELETE
   IF DELETING THEN
       DELETE FROM TIBCOEAI.WKSKBFPYRDETAIL WHERE PLANT =:OLD.PLANT AND MFGTYPE = :OLD.MFGTYPE AND LINE = :OLD.LINE AND STAGE=:OLD.STAGE;
   END IF;
  COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
/
