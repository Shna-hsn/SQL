-- Create table
create table LINEKBDETAIL
(
  plant         VARCHAR2(50 BYTE) not null,
  mfgtype       VARCHAR2(3 BYTE) not null,
  line          VARCHAR2(5 BYTE) not null,
  process       VARCHAR2(1 BYTE),
  shift         VARCHAR2(5 BYTE) default 0,
  inmodel       VARCHAR2(30 BYTE),
  intarget      NUMBER default 0,
  inacturl      NUMBER default 0,
  outmodel      VARCHAR2(30 BYTE),
  outtarget     NUMBER default 0,
  outacturl     NUMBER default 0,
  fpyr          NUMBER(13,4) default 1.00,
  updatedate    DATE default SYSDATE,
  intacktime    NUMBER(8,3),
  outtacktime   NUMBER(8,3),
  inusn         VARCHAR2(30),
  outusn        VARCHAR2(30),
  inmo          VARCHAR2(20),
  outmo         VARCHAR2(20),
  inmolot       NUMBER,
  outmolot      NUMBER,
  inmoinputqty  NUMBER,
  outmoinputqty NUMBER,
  remark        VARCHAR2(500)
)
tablespace SFCPP139D
  pctfree 10
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
comment on table LINEKBDETAIL
  is '產能看板主要WKSKB002(INPUT,OUTPUT,TARGET,FPYR)基本數據,來源P_TARGET';
-- Add comments to the columns 
comment on column LINEKBDETAIL.shift
  is '0為白班,1為夜班';
comment on column LINEKBDETAIL.inacturl
  is '前段實際產出';
comment on column LINEKBDETAIL.outacturl
  is '后段實際產出';
comment on column LINEKBDETAIL.fpyr
  is '看板FPYR';
comment on column LINEKBDETAIL.inmo
  is '前段生產工單';
comment on column LINEKBDETAIL.outmo
  is '後段生產工單';
comment on column LINEKBDETAIL.inmolot
  is '前段生產工單的數量';
comment on column LINEKBDETAIL.outmolot
  is '后段生產工單的數量';
comment on column LINEKBDETAIL.inmoinputqty
  is '前段生產工單的已投數量';
comment on column LINEKBDETAIL.outmoinputqty
  is '后段生產工單的已投數量';
-- Create/Recreate indexes 
create unique index LINEKBDETAIL_PK on LINEKBDETAIL (PLANT, MFGTYPE, LINE)
  tablespace SFCPP139D
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
grant select on LINEKBDETAIL to SFCFA139;
grant select on LINEKBDETAIL to SFCPCB139;
