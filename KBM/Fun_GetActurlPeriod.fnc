CREATE OR REPLACE FUNCTION Fun_GetActurlPeriod(PAR_MFGTYPE        IN VARCHAR2,
                                               PAR_LINE           IN VARCHAR2,
                                               PAR_STAGE          IN VARCHAR2,
                                               PAR_STARTTIME      IN DATE,
                                               PAR_ENDTIME        IN DATE,
                                               PAR_NONWORKSTATION IN VARCHAR2 DEFAULT 'A')
/*
================================================================================================
version         author             date                           description
1.0.0.0         oscar               2014/07/15
================================================================================================
*/
 RETURN NUMBER IS
  VAR_ACTURL NUMBER := 0;
BEGIN
  IF PAR_MFGTYPE = 'FA' THEN
    SELECT COUNT(*)
      INTO VAR_ACTURL
      FROM SFCMIFA139.SFCTRANSACTIONCACHE A
     WHERE INSTR(PAR_STAGE, A.STAGE) > 0
       AND PASSCOUNT = 1
       /*AND UPN NOT LIKE '90%'
       AND UPN NOT LIKE '70%'*/
       AND TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
       AND LINE = PAR_LINE
       AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0;
  end if;
  IF PAR_MFGTYPE = 'PCB' THEN
    --如果为PCB后端线，则PAR_LINE为dipline
    SELECT SUM(COUNT)
      INTO VAR_ACTURL
      FROM (SELECT COUNT(*) COUNT
              FROM SFCMIPCB139.SFCTRANSACTIONCACHE A
             WHERE INSTR(PAR_STAGE, A.STAGE) > 0
               AND PASSCOUNT = 1
               AND TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
               AND INSTR(PAR_LINE, LINE) > 0
               AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
               AND (MO NOT IN (SELECT MO FROM SFCPCB139.SFCMOUSNVICE) OR
                    (MO, USN) IN
                    (SELECT MO, VICEUSN FROM SFCPCB139.SFCMOUSNVICE))
            UNION
            SELECT COUNT(*) * MAX(UNITPERPCB) COUNT
              FROM SFCMIPCB139.SFCTRANSACTIONCACHE A, SFCPCB139.SFCUPNINFO B
             WHERE INSTR(PAR_STAGE, A.STAGE) > 0
               AND PASSCOUNT = 1
               AND TRNDATE BETWEEN PAR_STARTTIME AND PAR_ENDTIME
               AND INSTR(PAR_LINE, LINE) > 0
               AND INSTR(PAR_NONWORKSTATION, A.WORKSTATION) <= 0
               AND A.UPN = B.UPN
               AND MO IN (SELECT MO FROM SFCPCB139.SFCMOUSNVICE)
               AND (MO, USN) NOT IN
                   (SELECT MO, VICEUSN FROM SFCPCB139.SFCMOUSNVICE)
             GROUP BY B.UPN);
  END IF;
  RETURN VAR_ACTURL;
EXCEPTION
  WHEN OTHERS THEN
    RETURN VAR_ACTURL;
END;
/
