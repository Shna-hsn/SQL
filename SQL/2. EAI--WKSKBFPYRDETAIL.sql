select * from WKSKBFPYRDETAIL;
-- Create table
create table WKSKBFPYRDETAIL
(
  plant      VARCHAR2(50 BYTE) not null,
  mfgtype    VARCHAR2(3 BYTE) not null,
  line       VARCHAR2(5 BYTE) not null,
  stage      VARCHAR2(50 BYTE) not null,
  count      NUMBER default 0,
  ngcount    NUMBER default 0,
  updatedate DATE
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table WKSKBFPYRDETAIL
  add constraint WKSKBFPYRDETAIL_PK primary key (PLANT, MFGTYPE, LINE, STAGE)
  using index 
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
grant select on WKSKBFPYRDETAIL to Public;
