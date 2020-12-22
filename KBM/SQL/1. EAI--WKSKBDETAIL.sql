select * from WKSKBDETAIL;
-- Create table
create table WKSKBDETAIL
(
  plant      VARCHAR2(50 BYTE) not null,
  mfgtype    VARCHAR2(3 BYTE) not null,
  line       VARCHAR2(5 BYTE) not null,
  process    VARCHAR2(1 BYTE),
  shift      VARCHAR2(5 BYTE) default 0,
  inmodel    VARCHAR2(30 BYTE),
  intarget   NUMBER default 0,
  inacturl   NUMBER default 0,
  outmodel   VARCHAR2(30 BYTE),
  outtarget  NUMBER default 0,
  outacturl  NUMBER default 0,
  fpyr       NUMBER(13,4) default 1.00,
  updatedate DATE default SYSDATE,
  pdplant    VARCHAR2(50)
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
-- Add comments to the table 
comment on table WKSKBDETAIL
  is '玻狾щ㎝玻(狾WKSKB003.1)';
-- Create/Recreate indexes 
create unique index WKSKBDETAIL_PK on WKSKBDETAIL (PLANT, MFGTYPE, LINE)
  tablespace TIBCOEAID
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Grant/Revoke object privileges 
grant select on WKSKBDETAIL to Public;
