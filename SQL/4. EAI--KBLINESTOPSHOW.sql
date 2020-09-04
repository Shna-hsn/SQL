select * from KBLINESTOPSHOW;
-- Create table
create table KBLINESTOPSHOW
(
  plant         VARCHAR2(50),
  mfgtype       VARCHAR2(3),
  sequenceid    VARCHAR2(50),
  symption      VARCHAR2(800),
  dutydept      VARCHAR2(80),
  dutyleader    VARCHAR2(120),
  applydatetime DATE,
  downtimefrom  DATE,
  isshutdown    CHAR(1),
  downtimeto    DATE,
  replaytime    DATE,
  status        VARCHAR2(50),
  line          VARCHAR2(50),
  isoffline     VARCHAR2(1)
)
tablespace TIBCOEAID
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the columns 
comment on column KBLINESTOPSHOW.status
  is 'O為在途的表單，C為已結束結果為同意的表單，R為被駁回的表單；';
-- Grant/Revoke object privileges 
grant select on KBLINESTOPSHOW to Public;
