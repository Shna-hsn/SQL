CREATE OR REPLACE FUNCTION Fun_GetYRQTYBYSTAGE(PAR_MFGTYPE   IN VARCHAR2,
                                               PAR_LINE      IN VARCHAR2,
                                               PAR_STAGE     IN VARCHAR2,
                                               PAR_STARTTIME IN DATE,
                                               PAR_VLINE     IN VARCHAR2)
/******************************************************************************
        NAME:       Fun_GetYRQTYBYSTAGE
        PURPOSE:

        REVISIONS:
        Ver        Date        Author           Description
        ---------  ----------  ---------------  ------------------------------------
        1.0        2015/04/23   k1312c69       1. Created this function
                                                VAR_NGCOUNT || ',' || VAR_TOTALCOUNT;
        2.0        2015/04/30   brant.yang     2. э▆瞯κだκ拜肈

  .

        NOTES:

        Automatically available Auto Replace Keywords:
           Object Name:     Fun_GetYRQTYBYSTAGE
           Sysdate:         2015/04/23
           Date and Time:   2015/04/23, 11:15:39, and 2015/04/23 11:15:39
           Username:        k1312c69 (set in TOAD Options, Procedure Editor)
           Table Name:       (set in the "New PL/SQL Object" dialog)

     ******************************************************************************/

 RETURN VARCHAR2 IS
  VAR_YR         NUMBER := 1;
  VAR_NGCOUNT    NUMBER := 0;
  VAR_TOTALCOUNT NUMBER := 0;
  PRAGMA AUTONOMOUS_TRANSACTION;
  VAR_ERR_MSG VARCHAR2(2000);
BEGIN
  VAR_YR := 1;

  IF PAR_MFGTYPE = 'FA' THEN
    SELECT COUNT(*)
      INTO VAR_NGCOUNT
      FROM SFCMIFA139.SFCTRANSACTIONCACHE A
     WHERE INSTR(PAR_STAGE, A.STAGE) > 0
       AND A.PASSCOUNT = 1
       AND A.RESULTFLAG = 0
       AND A.TRNDATE BETWEEN PAR_STARTTIME AND SYSDATE
       AND A.LINE = PAR_LINE
       AND SUBSTR(A.UPN, 1,3) NOT IN ('381','391','481','491', '181','M81');
       --2017/12/10эぃ?衡▆瞯UPN
       --AND SUBSTR(A.UPN, 1, 2) <> '81'
       --AND SUBSTR(A.UPN, 2, 2) <> '81';

    SELECT COUNT(*)
      INTO VAR_TOTALCOUNT
      FROM SFCMIFA139.SFCTRANSACTIONCACHE A
     WHERE INSTR(PAR_STAGE, STAGE) > 0
       AND PASSCOUNT = 1
       AND TRNDATE BETWEEN PAR_STARTTIME AND SYSDATE
       AND LINE = PAR_LINE
       AND SUBSTR(A.UPN, 1,3) NOT IN ('381','391','481','491', '181','M81');
       --2017/12/10эぃ?衡▆瞯UPN
       --AND SUBSTR(A.UPN, 1, 2) <> '81'
       --AND SUBSTR(A.UPN, 2, 2) <> '81';
  end if;
  IF PAR_MFGTYPE = 'PCB' THEN
    SELECT COUNT(*)
      INTO VAR_NGCOUNT
      FROM SFCMIPCB139.SFCTRANSACTIONCACHE A
     WHERE INSTR(PAR_STAGE, A.STAGE) > 0
       AND A.PASSCOUNT = 1
       AND A.RESULTFLAG = 0
       AND A.TRNDATE BETWEEN PAR_STARTTIME AND SYSDATE
       AND INSTR(PAR_LINE, A.LINE) > 0;

    SELECT COUNT(*)
      INTO VAR_TOTALCOUNT
      FROM SFCMIPCB139.SFCTRANSACTIONCACHE A
     WHERE INSTR(PAR_STAGE, STAGE) > 0
       AND PASSCOUNT = 1
       AND TRNDATE BETWEEN PAR_STARTTIME AND SYSDATE
       AND INSTR(PAR_LINE, A.LINE) > 0;
  END IF;

  UPDATE FPYRDETAIL
     SET NGCOUNT    = VAR_NGCOUNT,
         COUNT      = VAR_TOTALCOUNT,
         UPDATEDATE = SYSDATE
   WHERE 1 = 1
        --侣粂 эpar_vline硂把计
        --and LINE = PAR_LINE
     and line = par_vline
     AND MFGTYPE = PAR_MFGTYPE
     AND INSTR(PAR_STAGE, STAGE) > 0;

  COMMIT;

  RETURN VAR_NGCOUNT || ',' || VAR_TOTALCOUNT;
EXCEPTION
  WHEN OTHERS THEN
    VAR_ERR_MSG := SQLERRM(SQLCODE);

    INSERT INTO KBNERRORLOG
    VALUES
      (SYSDATE, 'Fun_GetYRQTYBYSTAGE', VAR_ERR_MSG);

    COMMIT;
    RETURN VAR_NGCOUNT || ',' || VAR_TOTALCOUNT;
END;
/
