select * from OOBKBDETAILBYSITE;
-- Create table
create table OOBKBDETAILBYSITE
(
  plant            VARCHAR2(50 BYTE) not null,
  mfgtype          VARCHAR2(3 BYTE) not null,
  line             VARCHAR2(50 BYTE) not null,
  totalnum         NUMBER default 0,
  defectnum        NUMBER default 0,
  exteriordefnum   NUMBER default 0,
  nocheck_totalnum NUMBER default 0,
  updatedate       DATE default sysdate
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
comment on table OOBKBDETAILBYSITE
  is '产能良率看板WKSKB002等-OOB相关的数量';
-- Add comments to the columns 
comment on column OOBKBDETAILBYSITE.totalnum
  is '已验总数';
comment on column OOBKBDETAILBYSITE.defectnum
  is 'NG总数';
comment on column OOBKBDETAILBYSITE.exteriordefnum
  is '外觀不良數量';
comment on column OOBKBDETAILBYSITE.nocheck_totalnum
  is '未验总数';
-- Create/Recreate primary, unique and foreign key constraints 
alter table OOBKBDETAILBYSITE
  add constraint OOBKBDETAILBYSITE_PK primary key (PLANT, MFGTYPE, LINE)
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
grant select on OOBKBDETAILBYSITE to Public;
