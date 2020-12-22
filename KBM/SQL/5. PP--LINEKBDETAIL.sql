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
  is '����ݪO�D�nWKSKB002(INPUT,OUTPUT,TARGET,FPYR)�򥻼ƾ�,�ӷ�P_TARGET';
-- Add comments to the columns 
comment on column LINEKBDETAIL.shift
  is '0���կZ,1���]�Z';
comment on column LINEKBDETAIL.inacturl
  is '�e�q��ڲ��X';
comment on column LINEKBDETAIL.outacturl
  is '�Z�q��ڲ��X';
comment on column LINEKBDETAIL.fpyr
  is '�ݪOFPYR';
comment on column LINEKBDETAIL.inmo
  is '�e�q�Ͳ��u��';
comment on column LINEKBDETAIL.outmo
  is '��q�Ͳ��u��';
comment on column LINEKBDETAIL.inmolot
  is '�e�q�Ͳ��u�檺�ƶq';
comment on column LINEKBDETAIL.outmolot
  is '�Z�q�Ͳ��u�檺�ƶq';
comment on column LINEKBDETAIL.inmoinputqty
  is '�e�q�Ͳ��u�檺�w��ƶq';
comment on column LINEKBDETAIL.outmoinputqty
  is '�Z�q�Ͳ��u�檺�w��ƶq';
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
