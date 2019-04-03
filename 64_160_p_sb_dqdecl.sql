CREATE OR REPLACE FUNCTION P_SB_DQDECL(
avc_nsrsbh  In Varchar2,
ac_pzxh     In Char,
ac_scsbpzxh in char,
ac_wdqzd_bz in char,
ac_zsxm_dm  in char,
adt_sssq_q  in date,
adt_sssq_z  in date,
ai_czlx     in integer,  --操作类型 1：insert，2：update，3：delete
ac_pzzl_dm  in char,
an_qbxse    number,       --delete操作时用
an_qbhdxse  number
) return integer
AS
  lc_sbxh         char(20);
  lc_zspm_dm      char(4);
  ldt_sbrq        date;
  ldt_tbrq        date;
  ldt_sssq_q      date;
  ldt_sssq_z      date;
  ln_xse          number(20,6);--2007-09-26zhubinc number(16,2)->number(20,6)
  ln_hdxse        number(16,2);
  ln_zsl          number(10,6);
  ln_bqynse       number(16,2);
  ln_hdynse       number(16,2);
  ln_jmse         number(16,2);
  ln_yjnse        number(16,2);
  ln_qzyjse       number(16,2);
  ln_qzdjse       number(16,2);
  ln_yzse         number(16,2);
  ln_ybtse        number(16,2);
  lc_nsr_swjg_dm  char(11);
  lc_swjg_dm      char(11);
  lc_lrr_dm       char(11);
  ldt_lrrq        date;
  lc_xgr_dm       char(11);
  ldt_xgrq        date;

  ln_qbsr         number(16,2):=0;
  ln_jmsr         number(16,2):=0;
  ln_ynse         number(16,2):=0;
  ln_ysxssr       number(16,2):=0;

  ln_qbxse_bq     number(16,2):=0;
  ln_qbhdxse_bq   number(16,2):=0;
  ln_qbynse_bq    number(16,2):=0; --本期全部应纳税额
  ln_qbhdse_bq    number(16,2):=0; --本期全部核定税额
  ln_qbjmse_bq    number(16,2):=0;
  ln_qbyjnse_bq   number(16,2):=0;
  ln_qbqzyjse_bq  number(16,2):=0;
  ln_qbqzdjse_bq  number(16,2):=0;
  ln_qbyzse_bq    number(16,2):=0;
  ln_qbybtse_bq   number(16,2):=0;

  ln_qbxse_sq     number(16,2):=0;
  ln_qbhdxse_sq   number(16,2):=0;
  ln_qbynse_sq    number(16,2):=0;
  ln_qbhdse_sq    number(16,2):=0;
  ln_qbjmse_sq    number(16,2):=0;
  ln_qbyjnse_sq   number(16,2):=0;
  ln_qbqzyjse_sq  number(16,2):=0;
  ln_qbqzdjse_sq  number(16,2):=0;
  ln_qbyzse_sq    number(16,2):=0;
  ln_qbybtse_sq   number(16,2):=0;

  li_ret          number;

  lc_lsgx_dm         char(2):=NULL;
  lc_zdsy_dm         char(2):=NULL;
  ln_sbqx            number:=NULL;
  lc_sbfs_dm         char(2):=NULL;
  lc_zsfs_dm         char(2):=NULL;
  lc_zsdlfs_dm       char(2):=NULL;
  lc_zgswgy_dm       char(11):=NULL;
  lc_ttjmlx          varchar2(2):=NULL;
  ln_jkqxpyl         number:=NULL;
  ldt_jkqx1          date:=NULL;
  lc_djzclx_dm       char(3):=NULL;
  lc_hy_dm           char(4):=NULL;
  lc_jdxz_dm         char(10):=NULL;
  lc_yskm_dm         varchar2(9):=NULL;--20061207 wuyq2 change char(6) to varchar2(9)
  lc_ysfpbl_dm       char(4):=NULL;
  ln_ysfpbl_zy       number(7,6):=NULL;
  ln_ysfpbl_ss       number(7,6):=NULL;
  ln_ysfpbl_ds       number(7,6):=NULL;
  ln_ysfpbl_xq       number(7,6):=NULL;
  ln_ysfpbl_xz       number(7,6):=NULL;
  ln_ysfpbl_xc       number(7,6):=NULL;
  lc_zsxmfl_dm       char(1):=NULL;
  lc_zjfs_dm         char(1):=NULL;
  lc_skgk_dm         char(8):=NULL;
  lc_zsjg_dm         char(11):=NULL;
  lc_skss_swjg_dm    char(11):=NULL;
  lc_jmyy           varchar2(2);
  ln_jmsl           number(10,6);
  ln_jmed           number(16,2);
  ln_jmfd           number(10,6);
  ln_jmsl_df        number(10,6);
  ln_jmed_df        number(16,2);
  ln_jmfd_df        number(10,6);
  ln_jm_sysl_qy     number(10,6);
  ln_jm_sysl_df     number(10,6);
  lc_jmjk           char(1);       --hongjun add on 2003-11-14

  ln_jmed_sq        number(16,2):= 0;
  ln_xse_sq         number(20,6):= 0;--2007-09-26zhubinc number(16,2)->number(20,6)
  ln_zsl_sq         number(10,6):= 0;
  ln_jmse_sq        number(16,2):= 0;
  ln_jmed_one       number(16,2):= 0;

  lc_wdqzdh         char(1):='N'; --未达起征点户标志
  lc_cdefd          varchar2(10);--起定额幅度 （百分比）
  ln_cdefd          number(10,6);--起定额幅度 （百分比）
  lc_bcsb           char(1);  --是否补充申报
  lc_state_de       varchar2(10):='de';  --状态说明 ：'cde'超定额；'cfd'超幅度
  li_state          number := -1001; --超定额超幅度标志 -1001未超定额，-1002超定额未超幅度，-1003超幅度
  ln_temp           number(16,2):=0;--拆分成定额和非定额时使用
  ln_ybtse1         number(16,2):=0;--拆分成定额和非定额时使用
  lc_jmlx           varchar2(5);
  lc_gtdqde         char(1); --定期定额个体工商户标志
  lc_zsxh           char(20);
  lc_zsxh_new       char(20);

  ldt_sbqx          date;
  ldt_yqsbqx        date;
  ldt_sbqx_cur      date;
  ldt_yqsbqx_cur    date;
  ldt_sbqx_hzsbqx   date;         --汇总申报期限
  ldt_yqsbqx_hzsbqx date;

  ldt_jkqx          date;
  ldt_hjjkqx        date;
  ldt_jkqx_cur      date;
  ldt_hjjkqx_cur    date;

  ln_hjjkye         number(16,2);
  ln_kssl           number(20,6) := 0;--2007-09-26zhubinc number(16,2)->number(20,6)
  ln_kssl1          number(16,2) := 0;
  ln_yssl           number(16,2) := 0;
  ln_yssl1          number(16,2) := 0;
  ldt_temp          date;
  lc_temp           char(1);
  lc_sllx          char(2); --Added By Wusl 2002-12-08 从量征收标志
                                  --'01'从价征收、'02'从量征收。
  li_czlx          integer;
  lc_pzzl_dm_sc    char(5);
  ldt_jkqx_temp    date;

  lc_pzzl_dm_1     varchar(5);  --2007-3-10 liulh
  lc_pzzl_dm_2     varchar(5);
  lc_pzxh          varchar(16);
  ln_cnt           integer;
  li_count         integer;--add yuxh on 2008-6-23
  li_return        integer:=100; --返回值
  lc_bz            char(1);     --2009-01-04 liulh
  ln_sl            number(10,6);--2009-01-04 liulh
  ln_ysxssr_bq_tmp   number(16,2):=0;--add yuxh on 2010-7-5 ZHZG_2010_004
  ln_ysxssr_sq_tmp   number(16,2):=0;--add yuxh on 2010-7-5 ZHZG_2010_004
  ln_session         number;  --add yuxh on 2011-4-6 增加控制前台死机
--  lc_yzpzmxxh      varchar(20); 暂时不能新建应征凭证明细序号，因为删除征收信息表时要用应征凭证明细序号作对应查找。

--新建游标，用于新增记录时取得征收信息，拆分定额时使用。
/*  cursor cur_zsxx is
  SELECT KSSL,XSSR,SE,YZPZMXXH,ZSXH,ZSPM_DM
  FROM SB_ZSXX
  where SE > 0 AND SKSX_DM <> '61' and (SB_TZLX_DM = '0' or SB_TZLX_DM = '3')
    and sssq_q = adt_sssq_q
    and sssq_z = adt_sssq_z
    and YZPZXH like lc_pzxh
  order by ZSXH;*/


--modify yuxh on 2011-4-7 优化性能屏蔽掉以下语句
/*
cursor cur_zsxx is
SELECT KSSL,XSSR,SE,YZPZMXXH,ZSXH,ZSPM_DM
  FROM SB_ZSXX
  where SE > 0 AND (SB_TZLX_DM = '0' or SB_TZLX_DM = '3')
    and YZPZXH like lc_pzxh
    and skcsfs_dm = '11'
    and sksx_dm = '11'
    and skzl_dm='10' --add yuxh on 2009-3-20 处理处理正税
    and zsxm_dm = ac_zsxm_dm
    and sssq_q = adt_sssq_q
    and sssq_z = adt_sssq_z
    and nsrsbh = avc_nsrsbh
  order by ZSXH;
*/

--modify yuxh on 2011-4-7 优化性能屏蔽掉以下语句
/*
--新建游标，用于更新或删除记录时，取得征收信息，拆分定额时使用。
  cursor cur_zsxx_for_update is
  SELECT KSSL,XSSR,SE,ZSXH
  FROM SB_ZSXX a
  where a.SE > 0 and (a.SB_TZLX_DM = '0' or a.SB_TZLX_DM = '3')
   and (a.yzpzzl_dm like lc_pzzl_dm_1 or a.yzpzzl_dm like lc_pzzl_dm_2)
   and skcsfs_dm = '11'
   and a.sksx_dm = '11'
   and a.skzl_dm='10'  --add yuxh on 2009-3-20 只处理正税
   and a.zsxm_dm = ac_zsxm_dm
   and a.sssq_q = adt_sssq_q
   and a.sssq_z = adt_sssq_z
   and a.NSRSBH = avc_nsrsbh
  order by ZSXH asc;
*/


--新建游标，用于取得上次申报表信息，计算减免额度时使用
  cursor cur_zzs (lc_pzxh_temp char) is
  select xse,zsl,jmse from sb_zzs_xgmnsr where pzxh = lc_pzxh_temp;

  cursor cur_xfs (lc_pzxh_temp char) is
  select yssl,sl,jmse from sb_xfs_zb where pzxh = lc_pzxh_temp;

BEGIN
  -----------------------------------------------------------------------------
  --名    称：定期定额个体工商户申报征收处理
  --功能描述：补充申报、未达起征点处理、超定额拆分征收信息处理、
  --          超定额、超幅度、或未达起征点户已达起征点时，对申报期限和缴款期限的处理
  --          分三种情况进行：增加、删除、更新申报表
  --输入参数：纳税人识别号、凭证序号、上次申报凭证序号、征收项目、未达起征点标志、
  --          所属时期起止、操作类型（1增加、2更新、3删除）、凭证种类、全部销售额、核定销售额
  --输出参数：无
  --返 回 值：100：成功，101成功（上期超定额本期超幅度，则在前台提示加收滞纳金），201：未达起征点户未达起征点不允许预缴，其它：错误
  --调用来自：前台w_sb_sb_zzs_xgmnsr,w_sb_sb_xfs,w_sb_sb_zzs_xgmnsr_2005,w_sb_sb_hzsb中的
  --          ue_beforecommit(),wf_delete_sbb()调用
  --编写时间：2007-1-25
  --编 写 人：刘理鸿
  --修 改 人：余祥和
  --修改时间：2007-2-5
  --修改原因：增加处理2005增值税小规模补充申报
  --修 改 人：刘理鸿
  --修改时间：2007-2-8
  --修改原因：增加汇总申报的处理
  --修 改 人：刘理鸿
  --修改时间：2007-3-10
  --修改原因：增加超幅度后的调帐处理
  --修 改 人：zhubinc
  --修改时间：2007-09-26
  --修改原因：sb_xfs_zb.yssl：number(16,2)->number(20,6)
  --修改人：  余祥和
  --修改时间：2008-05-19
  --修改原因: 增加处理海南附加税处理，增加征收项目
  --修 改 人：余祥和
  --修改日期：2008-6-23
  --修改原因：处理特殊征收率，纳税人只有一个增值税征收品目,因p_sb_set_seds处理类似0.005有错
  --修 改 人：余祥和
  --修改日期：2008-7-17
  --修改原因：增加skzl_dm='10'的条件，不删除滞纳金。若业务人员的确需要删除此滞纳金，可到“删除滞纳金”模块自行删除
  --修 改 人：余祥和
  --修改日期：2008-8-26
  --修改原因：对于补充申报修改时，超定额未超幅度时，缴款期限的调整要考虑上次原始申报超定额拆分部分的缴款期限调整
  --修 改 人：刘理鸿
  --修改日期：2009-01-04
  --修改原因：2009年增消营需求调整征收率，修改取征收率与征收品目的取数逻辑
  --修 改 人：余祥和
  --修改日期：2009-03-04
  --修改原因：排除税款为滞纳金的缴款期限处理(补充申报、汇总申报)
  --修 改 人：余祥和
  --修改日期：2009-03-20
  --修改原因：排除税款为滞纳金的缴款期限处理(补充申报、汇总申报)
  --修 改 人：余祥和
  --修改日期：2010-07-5
  --修改原因：一般纳税人认定需求ZHZG_2010_004 ,处理税率及倒算
  --修改次数：
  --修 改 人：余祥和
  --修改日期：2011-04-7
  --修改原因：CR2688 各地报分月汇总申报死机，调整优化性能(采用临时表方式)
  -----------------------------------------------------------------------------

ldt_sssq_q := adt_sssq_q;
ldt_sssq_z := adt_sssq_z;
lc_pzxh    := ac_pzxh;

select userenv('sessionid') into ln_session from dual ;--add yuxh on 2011-4-7 优化性能增加

if ai_czlx is null or (ai_czlx <> 1 and ai_czlx <> 2 and ai_czlx <> 3) then
   return li_return;
end if;

  --判断是否补充申报 liulh 2007-1-17
if ac_scsbpzxh is not null and length(rtrim(ac_scsbpzxh)) > 0 then
   lc_bcsb    := 'Y'; --补充申报
else
   lc_bcsb    := 'N'; --非补充申报
end if;

--如果删除的是原始申报表，则直接返回，如果为汇总申报表，则继续处理
if ai_czlx = 3 and lc_bcsb = 'N' and ac_pzzl_dm <> '10148' and ac_pzzl_dm <> '10149' then
   return li_return;
end if;

--判断是否为定期定额个体工商户 liulh 2007-1-17
li_ret := p_sb_get_nsr_gtdqde(avc_nsrsbh,ac_zsxm_dm,ldt_sssq_q,ldt_sssq_z);
if li_ret = 100 then
   lc_gtdqde := 'Y';
else
   lc_gtdqde := 'N';
end if;

--只有个体定期定额或补充申报，才进入以下处理，否则退出。
if lc_gtdqde = 'N' and lc_bcsb = 'N' then
   return li_return;
end if;

if ac_pzzl_dm = '10102' or ac_pzzl_dm = '10110' then    --旧版小规模纳税人
   lc_pzzl_dm_1 := '10102';
   lc_pzzl_dm_2 := '10110';
elsif ac_pzzl_dm = '10106' or ac_pzzl_dm = '10117' then --消费税
   lc_pzzl_dm_1 := '10106';
   lc_pzzl_dm_2 := '10117';
   --add by wangxbd 2008.1.14 增加消费税申报烟类10177,10178
elsif ac_pzzl_dm = '10177' or ac_pzzl_dm = '10178' then --消费税
   lc_pzzl_dm_1 := '10177';
   lc_pzzl_dm_2 := '10178';
   --end by wangxbd
elsif ac_pzzl_dm = '10105' or ac_pzzl_dm = '10147' then --2005版小规模纳税人
   lc_pzzl_dm_1 := '10105';
   lc_pzzl_dm_2 := '10147';
elsif ac_pzzl_dm = '10148' or ac_pzzl_dm = '10149' then --2005版小规模纳税人
   lc_pzzl_dm_1 := '%';
   lc_pzzl_dm_2 := '%';
   lc_pzxh := '%';
end if;

if ac_pzzl_dm = '10102' or ac_pzzl_dm = '10110' then
   if ai_czlx <> 3 then --对于删除操作，无法取得本期总销售额，可通过参数an_qbxse获得。
--取本期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-1-17
      SELECT NVL(SUM(XSE),0),NVL(SUM(HDXSE),0),NVL(SUM(BQYNSE),0),NVL(SUM(HDYNSE),0),
             NVL(SUM(JMSE),0),NVL(SUM(YJNSE),0),NVL(SUM(QZYJSE),0),NVL(SUM(QZDJSE),0),
             NVL(SUM(YZSE),0),NVL(SUM(YBTSE),0)
      INTO ln_qbxse_bq,ln_qbhdxse_bq,ln_qbynse_bq,ln_qbhdse_bq,
         ln_qbjmse_bq,ln_qbyjnse_bq,ln_qbqzyjse_bq,ln_qbqzdjse_bq,
         ln_qbyzse_bq,ln_qbybtse_bq
      FROM SB_ZZS_XGMNSR   where PZXH = ac_pzxh   group by PZXH;
   else
      ln_qbxse_bq := an_qbxse;
      ln_qbhdxse_bq := an_qbhdxse;
   end if;
   if ac_pzzl_dm = '10110' then
    --取上期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-1-17
      SELECT NVL(SUM(XSE),0),NVL(SUM(HDXSE),0),NVL(SUM(BQYNSE),0),NVL(SUM(HDYNSE),0),
             NVL(SUM(JMSE),0),NVL(SUM(YJNSE),0),NVL(SUM(QZYJSE),0),NVL(SUM(QZDJSE),0),
             NVL(SUM(YZSE),0),NVL(SUM(YBTSE),0)
      INTO ln_qbxse_sq,ln_qbhdxse_sq,ln_qbynse_sq,ln_qbhdse_sq,
           ln_qbjmse_sq,ln_qbyjnse_sq,ln_qbqzyjse_sq,ln_qbqzdjse_sq,
           ln_qbyzse_sq,ln_qbybtse_sq
      FROM SB_ZZS_XGMNSR
      where PZXH = ac_scsbpzxh  group by PZXH;
   end if;
elsif ac_pzzl_dm = '10106' or ac_pzzl_dm = '10117' then
   if ai_czlx <> 3 then --对于删除操作，无法取得本期总销售额，可通过参数an_qbxse获得。
      --取本期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-1-17
      SELECT NVL(SUM(YSSL),0),NVL(SUM(BQ_YJNSE),0),NVL(SUM(BQ_YBTSE),0),
             NVL(SUM(JMSE),0),NVL(SUM(QZYJSE),0),NVL(SUM(QZDJSE),0),NVL(SUM(YZSE),0)
      INTO ln_qbxse_bq ,ln_qbyjnse_bq,ln_qbybtse_bq,
           ln_qbjmse_bq,ln_qbqzyjse_bq ,ln_qbqzdjse_bq,ln_qbyzse_bq
      FROM SB_XFS_ZB
      where PZXH = ac_pzxh group by PZXH;
   else
      ln_qbxse_bq := an_qbxse;
      ln_qbhdxse_bq := an_qbhdxse;
   end if;
    ln_qbyjnse_bq := ln_qbqzyjse_bq;
    ln_qbynse_bq := ln_qbybtse_bq + ln_qbqzyjse_bq + ln_qbjmse_bq;

    if  ac_pzzl_dm = '10117' then
        --取上期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-1-17
      SELECT NVL(SUM(YSSL),0),NVL(SUM(BQ_YJNSE),0),NVL(SUM(BQ_YBTSE),0),
             NVL(SUM(JMSE),0),NVL(SUM(QZYJSE),0),NVL(SUM(QZDJSE),0),NVL(SUM(YZSE),0)
        INTO ln_qbxse_sq ,ln_qbyjnse_sq,ln_qbybtse_sq,
             ln_qbjmse_sq,ln_qbqzyjse_sq ,ln_qbqzdjse_sq,ln_qbyzse_sq
        FROM SB_XFS_ZB
        where PZXH = ac_scsbpzxh group by PZXH;
        ln_qbyjnse_sq := ln_qbqzyjse_sq;
        ln_qbynse_sq := ln_qbybtse_sq + ln_qbqzyjse_sq + ln_qbjmse_sq;
        ln_qbhdxse_sq := an_qbhdxse;
    end if;
   --add by wangxbd 2008.1.14
elsif ac_pzzl_dm = '10177' or ac_pzzl_dm = '10178' then
   if ai_czlx <> 3 then --对于删除操作，无法取得本期总销售额，可通过参数an_qbxse获得。
      --取本期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-1-17
      SELECT NVL(SUM(BQ_YBTSE/decode(SL,0,desl,SL)),0),NVL(SUM(BQ_YBTSE),0),
             NVL(SUM(BQ_JMSE),0),NVL(SUM(BQ_YJSE),0)
      INTO ln_qbxse_bq ,ln_qbybtse_bq,
           ln_qbjmse_bq,ln_qbqzyjse_bq
      FROM SB_XFS_2008_ZB
      where PZXH = ac_pzxh group by PZXH;
   else
      ln_qbxse_bq := an_qbxse;
      ln_qbhdxse_bq := an_qbhdxse;
   end if;
    ln_qbyjnse_bq := ln_qbqzyjse_bq;
    ln_qbynse_bq := ln_qbybtse_bq + ln_qbqzyjse_bq + ln_qbjmse_bq;

    if  ac_pzzl_dm = '10178' then
        --取上期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-1-17
      SELECT NVL(SUM(BQ_YBTSE/decode(SL,0,desl,SL)),0),NVL(SUM(BQ_YBTSE),0),
             NVL(SUM(BQ_JMSE),0),NVL(SUM(BQ_YJSE),0)
        INTO ln_qbxse_sq ,ln_qbybtse_sq,
             ln_qbjmse_sq,ln_qbqzyjse_sq
        FROM SB_XFS_2008_ZB
        where PZXH = ac_scsbpzxh group by PZXH;
        ln_qbyjnse_sq := ln_qbqzyjse_sq;
        ln_qbynse_sq := ln_qbybtse_sq + ln_qbqzyjse_sq + ln_qbjmse_sq;
        ln_qbhdxse_sq := an_qbhdxse;
    end if;
   --end by wangxbd 2008.1.14
elsif ac_pzzl_dm = '10105' or ac_pzzl_dm = '10147' then  --增值税小规模纳税人申报表
   if ai_czlx <> 3 then --对于删除操作，无法取得本期总销售额，可通过参数an_qbxse获得。
      --取本期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-1-17
      --modify yuxh on 2010-7-5 处理销售收入增加t.mshwlwxse + t.ckmshwxse ,增加应税销售收入
      SELECT NVL(SUM(t.yzhwlwbhsxse + t.xsgdzcbhsxse + t.mshwlwxse + t.ckmshwxse),0),NVL(SUM(t.hdxse),0),
             NVL(SUM(t.ynse),0),NVL(SUM(t.HDYNSE),0),
             NVL(SUM(t.ynsejze),0),NVL(SUM(t.yjse),0),NVL(SUM(t.yjse),0),0,
             NVL(SUM(t.ynse),0),NVL(SUM(t.YBTSE),0),
             NVL(SUM(t.yzhwlwbhsxse + t.xsgdzcbhsxse),0)
      INTO ln_qbxse_bq,ln_qbhdxse_bq,ln_qbynse_bq,ln_qbhdse_bq,
         ln_qbjmse_bq,ln_qbyjnse_bq,ln_qbqzyjse_bq,ln_qbqzdjse_bq,
         ln_qbyzse_bq,ln_qbybtse_bq,ln_ysxssr_bq_tmp
      FROM SB_ZZS_XGMNSR_2005 t   where t.SBBL = 1 AND t.PZXH = ac_pzxh   group by t.PZXH;
   else
      ln_qbxse_bq := an_qbxse;
      ln_qbhdxse_bq := an_qbhdxse;
   end if;

   if  ac_pzzl_dm = '10147' then
      --modify yuxh on 2010-7-5 销售收入增加t.mshwlwxse + t.ckmshwxse ,增加应税销售收入
      SELECT NVL(SUM(t.yzhwlwbhsxse + t.xsgdzcbhsxse + t.mshwlwxse + t.ckmshwxse),0),NVL(SUM(t.hdxse),0),
             NVL(SUM(t.ynse),0),NVL(SUM(t.HDYNSE),0),
             NVL(SUM(t.ynsejze),0),NVL(SUM(t.yjse),0),NVL(SUM(t.yjse),0),0,
             NVL(SUM(t.ynse),0),NVL(SUM(t.YBTSE),0),
             NVL(SUM(t.yzhwlwbhsxse + t.xsgdzcbhsxse),0)
      INTO ln_qbxse_sq,ln_qbhdxse_sq,ln_qbynse_sq,ln_qbhdse_sq,
         ln_qbjmse_sq,ln_qbyjnse_sq,ln_qbqzyjse_sq,ln_qbqzdjse_sq,
         ln_qbyzse_sq,ln_qbybtse_sq,ln_ysxssr_sq_tmp
      FROM SB_ZZS_XGMNSR_2005 t   where t.SBBL = 1 AND t.PZXH = ac_scsbpzxh   group by t.PZXH;
    end if;
elsif ac_pzzl_dm = '10148' or ac_pzzl_dm = '10149' then  --分月汇总申报表
   if ai_czlx <> 3 then --对于删除操作，无法取得本期总销售额，可通过参数an_qbxse获得。
      --取本期总应纳税额、总核定税额、上次申报凭证序号 liulh 2007-2-8
      SELECT NVL(SUM(t.xse),0),NVL(SUM(t.hdxse),0),NVL(SUM(t.ybtse),0),0,
             0,0,0,0,
             NVL(SUM(t.ybtse),0),NVL(SUM(t.ybtse),0)
      INTO ln_qbxse_bq,ln_qbhdxse_bq,ln_qbynse_bq,ln_qbhdse_bq,
         ln_qbjmse_bq,ln_qbyjnse_bq,ln_qbqzyjse_bq,ln_qbqzdjse_bq,
         ln_qbyzse_bq,ln_qbybtse_bq
      FROM SB_GTDQDE_HZSB t
      where t.sssq_q = adt_sssq_q and t.sssq_z = adt_sssq_z and t.PZXH = ac_pzxh ;
   else
      ln_qbxse_bq := an_qbxse;
      ln_qbhdxse_bq := an_qbhdxse;
   end if;

   SELECT nvl(sum(t.QBXSSR),0),0,nvl(sum(t.YNSE),0),0,nvl(sum(t.JMSE),0),nvl(sum(t.YJSE),0),
          nvl(sum(t.YJSE),0),0,nvl(sum(t.YBTSE),0),nvl(sum(t.YBTSE),0)
   INTO ln_qbxse_sq,ln_qbhdxse_sq,ln_qbynse_sq,ln_qbhdse_sq,
        ln_qbjmse_sq,ln_qbyjnse_sq,ln_qbqzyjse_sq,ln_qbqzdjse_sq,
        ln_qbyzse_sq,ln_qbybtse_sq
   FROM SB_SBXX t
   where t.yxbz = 'Y' and t.pzxh <> ac_pzxh and t.zsxm_dm = ac_zsxm_dm
     and t.sssq_q = adt_sssq_q and t.sssq_z = adt_sssq_z and t.nsrsbh = avc_nsrsbh;

   ln_qbyjnse_bq := ln_qbyjnse_sq;--added by liulh on 2007-3-2因汇总申报无预缴和减免，故将本期正常申报的预缴和减免赋给本期
   ln_qbjmse_bq := ln_qbjmse_sq;
end if;

if ln_qbxse_bq < ln_qbhdxse_bq then --取两者较大值作为本期销售额
   ln_qbxse_bq := ln_qbhdxse_bq;
end if;
if ln_qbxse_sq < ln_qbhdxse_sq then --取两者较大值作为上期销售额
   ln_qbxse_sq := ln_qbhdxse_sq;
end if;

if lc_gtdqde = 'Y' then
   if ac_pzzl_dm = '10106' or ac_pzzl_dm = '10117' or ai_czlx = 3
   or ac_pzzl_dm = '10148' or ac_pzzl_dm = '10149' then
   --若为消费税或分月汇总申报，因为申报表无法取得核定销售额与核定税额，所以在这里重新取一次
           li_ret := P_HD_GET_DQDEXX(an_bz => 3,
              ac_nsrsbh => avc_nsrsbh,
              ac_zsxm => ac_zsxm_dm,
              adt_sqq => adt_sssq_q,
              adt_sqz => adt_sssq_z,
              adt_zxq_q => ldt_temp,
              adt_zxq_z => ldt_temp,
              ac_ok => lc_temp,
              adt_jbzq_q => ldt_temp,
              adt_jbzq_z => ldt_temp,
              an_jbzq_qx => lc_temp,
              an_hdxssr => ln_qbhdxse_bq,
              an_hdse => ln_qbhdse_bq
              );
        ln_qbhdxse_sq := ln_qbhdxse_bq;
        ln_qbhdse_sq := ln_qbhdse_bq;
   end if;
   --取超定额幅度  liulh 2007-1-17
   li_ret := P_GET_XTCS('31064',lc_cdefd);
   if li_ret <> 100 then
      raise_application_error(-20551,'取超定额销售幅度出错!P_SB_DQDECL');
   end if;
   ln_cdefd := to_number(lc_cdefd)/100;
   --判断税款是否超定额或超幅度 liulh 2007-1-17

   --判断未达起征点 开始 liulh 2007-1-16 判断是否未达起征点户，若是，判断是否未达起征点，若已达起征点，改为当月缴款期限
   li_ret := p_hd_qzd_bz(avc_nsrsbh => avc_nsrsbh,
                         AVC_ZSXM => ac_zsxm_dm ,
                         ADT_YXQ_Q => adt_sssq_q,
                         ADT_YXQ_Z => adt_sssq_z,
                         AVC_QZD_BZ => lc_wdqzdh );
   if li_ret <> 100 then
      raise_application_error(-20552,'取未达起征点户标志出错!P_SB_DQDECL');
   end if;

   if  (ac_wdqzd_bz = 'Y' and lc_wdqzdh = 'Y')
        and (ln_qbyjnse_bq - ln_qbyjnse_sq )> 0 then
--      raise_application_error(-20571,'该户为未达起征点户，且本月未达起征点，不允许预缴！P_SB_DQDECL');
        li_return := 201;
        return li_return ;--为保持美观，不抛出异常
   end if;
   --判断未达起征点 结束 liulh 2007-1-16

   --对于未达起征点户则不考虑是否超定额或超幅度
--   if  ac_wdqzd_bz = 'Y' and lc_wdqzdh = 'Y' then
   if  lc_wdqzdh = 'Y' then
       lc_state_de := 'cc';
   elsif (ln_qbxse_bq > ln_qbhdxse_bq )and
       (ln_qbxse_bq < (ln_qbhdxse_bq * (1 + ln_cdefd)))  then
       lc_state_de := 'cde';
   elsif ln_qbxse_bq >= (ln_qbhdxse_bq * (1 + ln_cdefd)) then--若超幅度
       lc_state_de := 'cfd';
       if ai_czlx <> 3 and ln_qbxse_sq < (ln_qbhdxse_sq * (1 + ln_cdefd)) then
--          li_return := 101; --如果上期超定额未超幅度本期超幅度，则返回值为101，在前台提示加收滞纳金
--在过渡期内暂时不做提示，避免提示有误。
            li_return := 100;
       end if;
   end if;

end if;

--开始 取申报期限、缴款期限 2007-3-10
   --取分月汇总申报纳税期限  liulh 2007-1-17
   li_ret := p_sb_get_sbqx_hzsb(avc_nsrsbh => avc_nsrsbh,
                   ac_zsxm_dm => ac_zsxm_dm,
                   ac_pzzl_dm => ac_pzzl_dm,
                   adt_sssq_q => ldt_sssq_q,
                   adt_sssq_z => ldt_sssq_z,
                   an_sbqxpyl => li_state,
                   adt_sbqx => ldt_sbqx_hzsbqx,
                   adt_yqsbqx => ldt_yqsbqx_hzsbqx);
   if li_ret <> 100 and li_ret <> 200 then
      raise_application_error(-20553,'取汇总申报纳税期限出错!P_SB_DQDECL');
   end if;

   --取正常申报缴款期限
   li_state := null;
   if Instr('10148,10149',ac_pzzl_dm,1) > 0 then  --汇总申报定额部分仍为正常的缴款期限而非汇总申报期限
      if ac_pzzl_dm = '10148' then
         lc_pzzl_dm_1 := '10102';
      else
         lc_pzzl_dm_1 := '10106';
      end if;
      li_ret := p_sb_get_jkqx(avc_nsrsbh => avc_nsrsbh,
                   ac_zsxm_dm => ac_zsxm_dm,
                   ac_pzzl_dm => lc_pzzl_dm_1,
                   adt_sssq_q => adt_sssq_q,
                   adt_sssq_z => adt_sssq_z,
                   an_jkqxpyl => li_state,
                   adt_jkqx => ldt_jkqx,
                   adt_hjjkqx => ldt_hjjkqx,
                   an_hjjkye => ln_hjjkye);
      lc_pzzl_dm_1 := '%';
   else
      li_ret := p_sb_get_jkqx(avc_nsrsbh => avc_nsrsbh,
                   ac_zsxm_dm => ac_zsxm_dm,
                   ac_pzzl_dm => ac_pzzl_dm,
                   adt_sssq_q => adt_sssq_q,
                   adt_sssq_z => adt_sssq_z,
                   an_jkqxpyl => li_state,
                   adt_jkqx => ldt_jkqx,
                   adt_hjjkqx => ldt_hjjkqx,
                   an_hjjkye => ln_hjjkye);
   end if;
   if li_ret <> 100 then
      raise_application_error(-20554,'取正常缴款期限出错!P_SB_DQDECL');
   end if;

   --取本属期规定的申报缴款期限
   li_state := -1003;
   li_ret := p_sb_get_sbqx(avc_nsrsbh => avc_nsrsbh,
                   ac_zsxm_dm => ac_zsxm_dm,
                   ac_pzzl_dm => ac_pzzl_dm,
                   adt_sssq_q => adt_sssq_q,
                   adt_sssq_z => adt_sssq_z,
                   an_sbqxpyl => li_state,
                   adt_sbqx => ldt_sbqx_cur,
                   adt_yqsbqx => ldt_yqsbqx_cur);
   li_state := -1003;
   li_ret := p_sb_get_jkqx(avc_nsrsbh => avc_nsrsbh,
                   ac_zsxm_dm => ac_zsxm_dm,
                   ac_pzzl_dm => ac_pzzl_dm,
                   adt_sssq_q => adt_sssq_q,
                   adt_sssq_z => adt_sssq_z,
                   an_jkqxpyl => li_state,
                   adt_jkqx => ldt_jkqx_cur,
                   adt_hjjkqx => ldt_hjjkqx_cur,
                   an_hjjkye => ln_hjjkye);
--结束 取申报期限、缴款期限 2007-3-10

--************************************************************************
--开始 删除操作处理
if ai_czlx = 3 and lc_gtdqde = 'Y' then
   lc_state_de := 'de';
   --如果未达起征点户且未达起征点，则不考虑是否超定额或超幅度，不作处理
   if ac_wdqzd_bz = 'Y' and lc_wdqzdh = 'Y' then
      return li_return;
   end if;
   --判断本期是否超定额或超幅度,若未超幅度，则不作任何处理liulh 2007-1-17
   if ln_qbxse_bq < (ln_qbhdxse_bq * (1 + ln_cdefd)) then
      return li_return;
   end if;
   --判断上期是否超定额或超幅度,若超幅度，则不作处理 liulh 2007-1-17
   if ln_qbxse_sq >= (ln_qbhdxse_sq * (1 + ln_cdefd)) then
      return li_return;
   end if;
   --如果没有执行期，返回汇总申报期限为空，则不做定额拆分和修改缴款期限处理。
   if ldt_sbqx_hzsbqx is null then
      return li_return ;
   end if;

/*      --取正常申报缴款期限
   li_state := null;
   li_ret := p_sb_get_jkqx(avc_nsrsbh => avc_nsrsbh,
                   ac_zsxm_dm => ac_zsxm_dm,
                   ac_pzzl_dm => '10105',
                   adt_sssq_q => adt_sssq_q,
                   adt_sssq_z => adt_sssq_z,
                   an_jkqxpyl => li_state,
                   adt_jkqx => ldt_jkqx,
                   adt_hjjkqx => ldt_hjjkqx,
                   an_hjjkye => ln_hjjkye);
   if li_ret <> 100 then
      raise_application_error(-20554,'取正常缴款期限出错!P_SB_DQDECL');
   end if;*/

   ln_temp := ln_qbhdse_sq - ln_qbyjnse_sq - ln_qbjmse_sq;
   if ln_temp < 0 then
      ln_temp := 0;
   end if;
   --2007-3-11调帐处理
   li_Ret := p_sb_tzcl(avc_nsrsbh,ac_zsxm_dm,adt_sssq_q,adt_sssq_z,ac_pzzl_dm,ln_temp,ldt_jkqx,ldt_sbqx_hzsbqx,ac_pzxh);
   
   --modify yuxh on 2011-4-7 调整优化性能屏蔽以下语句
   /*
   open cur_zsxx_for_update ;
   fetch cur_zsxx_for_update into ln_kssl,ln_yssl,ln_ybtse,lc_zsxh;
   while cur_zsxx_for_update%found loop
      ln_temp := ln_temp - ln_ybtse;
      if ln_temp >= 0 then
         update sb_zsxx
          set jkqx =  decode(jkqx,null,null,ldt_jkqx),
          jkqx_znj = decode(jkqx_hj,null,ldt_jkqx,ldt_hjjkqx)
         where jkqx is not null and zsxh = lc_zsxh ;
      elsif ln_temp < 0 then
         ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
         ln_kssl1 := ln_kssl * (ln_ybtse1/ln_ybtse);
         ln_yssl1 := ln_yssl * (ln_ybtse1/ln_ybtse);

         ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
         ln_yssl := ln_yssl - ln_yssl1;
         ln_kssl := ln_kssl - ln_kssl1;
         ln_temp := 0;
         if ln_ybtse1 > 0 then
            li_ret:=P_GET_ZSXH(lc_zsxh_new);
            IF li_ret != 100 THEN
               raise_application_error(-20555, '生成征收序号出错。P_SB_DQDECL' );
            END IF;
            insert into SB_ZSXX
              (ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X )
               SELECT
               lc_zsxh_new,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,ln_kssl,ln_yssl,SL,ln_ybtse,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,decode(jkqx,null,null,ldt_sbqx_hzsbqx),JKQX_HJ,decode(jkqx,null,null,ldt_sbqx_hzsbqx),JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X
               FROM SB_ZSXX
               WHERE ZSXH = lc_zsxh;

               update sb_zsxx a
               set a.kssl = ln_kssl1,
                   a.xssr = ln_yssl1,
                   a.se   = ln_ybtse1,
                   a.jkqx =     decode(jkqx,null,null,ldt_jkqx),
                   a.jkqx_znj = decode(jkqx_hj,null,ldt_jkqx,ldt_hjjkqx)
               where jkqx is not null and ZSXH = lc_zsxh;
         else
            li_state := -1002;
         end if;
      end if;
      if li_state = -1002 then    --针对超定额未超幅度部分，将缴款期限为分月汇总缴款期限
         update sb_zsxx
          set jkqx = ldt_sbqx_hzsbqx,
          jkqx_znj = ldt_sbqx_hzsbqx
         where jkqx is not null and zsxh = lc_zsxh ;
      end if;
      li_state := -1000;
      fetch cur_zsxx_for_update into ln_kssl,ln_yssl,ln_ybtse,lc_zsxh;
   end loop;
   close cur_zsxx_for_update;
  --结束 计算超定额部分 liulh 2007-1-17
  */
  ------------------------------------------------------------------------------------------
  --add yuxh on 2011-4-6 上面语句调整为下面语句
  delete from  tmp_sb_zsxx_new 
               where  session_id=ln_session
                      and nsrsbh=avc_nsrsbh
                      and sssq_q=ldt_sssq_q
                      and sssq_z=ldt_sssq_z;
                      
  insert into tmp_sb_zsxx_new 
               (XH,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,YJKBZ,new_add,session_id)
               SELECT
               1,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,'0','0',ln_session
               FROM SB_ZSXX  a
             where a.SE > 0 and (a.SB_TZLX_DM = '0' or a.SB_TZLX_DM = '3')
                   and (a.yzpzzl_dm like lc_pzzl_dm_1 or a.yzpzzl_dm like lc_pzzl_dm_2)
                   and skcsfs_dm = '11'
                   and a.sksx_dm = '11'
                   and a.skzl_dm='10'  
                   and a.zsxm_dm = ac_zsxm_dm
                   and a.sssq_q = adt_sssq_q
                   and a.sssq_z = adt_sssq_z
                   and a.NSRSBH = avc_nsrsbh;
                   
    select nvl(min(zsxh),'0')  into lc_zsxh  from  tmp_sb_zsxx_new
               where  session_id=ln_session
                      and nsrsbh=avc_nsrsbh
                      and sssq_q=ldt_sssq_q
                      and sssq_z=ldt_sssq_z ; 
 
   while lc_zsxh >'0'
   loop
      select KSSL,XSSR,SE into ln_kssl,ln_yssl,ln_ybtse 
              from  tmp_sb_zsxx_new
              where zsxh=lc_zsxh; 
              
      ln_temp := ln_temp - ln_ybtse;
      if ln_temp >= 0 then
         update sb_zsxx
          set jkqx =  decode(jkqx,null,null,ldt_jkqx),
          jkqx_znj = decode(jkqx_hj,null,ldt_jkqx,ldt_hjjkqx)
         where jkqx is not null and zsxh = lc_zsxh ;
      elsif ln_temp < 0 then
         ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
         ln_kssl1 := ln_kssl * (ln_ybtse1/ln_ybtse);
         ln_yssl1 := ln_yssl * (ln_ybtse1/ln_ybtse);

         ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
         ln_yssl := ln_yssl - ln_yssl1;
         ln_kssl := ln_kssl - ln_kssl1;
         ln_temp := 0;
         if ln_ybtse1 > 0 then
            li_ret:=P_GET_ZSXH(lc_zsxh_new);
            IF li_ret != 100 THEN
               raise_application_error(-20555, '生成征收序号出错。P_SB_DQDECL' );
            END IF;
            
            insert into tmp_sb_zsxx_new
              (XH,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,yjkbz,new_add,session_id )
               SELECT
               1,lc_zsxh_new,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,ln_kssl,ln_yssl,SL,ln_ybtse,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,decode(jkqx,null,null,ldt_sbqx_hzsbqx),JKQX_HJ,decode(jkqx,null,null,ldt_sbqx_hzsbqx),JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,'0','1',ln_session
               FROM tmp_sb_zsxx_new
               WHERE ZSXH = lc_zsxh;

               update sb_zsxx a
               set a.kssl = ln_kssl1,
                   a.xssr = ln_yssl1,
                   a.se   = ln_ybtse1,
                   a.jkqx =     decode(jkqx,null,null,ldt_jkqx),
                   a.jkqx_znj = decode(jkqx_hj,null,ldt_jkqx,ldt_hjjkqx)
               where jkqx is not null and ZSXH = lc_zsxh;
                              
         else
            li_state := -1002;
         end if;
      end if;
      if li_state = -1002 then    --针对超定额未超幅度部分，将缴款期限为分月汇总缴款期限
         update sb_zsxx
          set jkqx = ldt_sbqx_hzsbqx,
          jkqx_znj = ldt_sbqx_hzsbqx
         where jkqx is not null and zsxh = lc_zsxh ;
      end if;
      li_state := -1000;
      
       select  nvl(min(zsxh),'0') into lc_zsxh  from  tmp_sb_zsxx_new 
        where session_id=ln_session
              and nsrsbh=avc_nsrsbh
              and sssq_q=ldt_sssq_q
              and sssq_z=ldt_sssq_z
              and zsxh > lc_zsxh ; 
   end loop;
   
   insert into  sb_zsxx
              (ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X)
   select      ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X  
               from   tmp_sb_zsxx_new 
               where  session_id=ln_session
                      and nsrsbh=avc_nsrsbh
                      and sssq_q=ldt_sssq_q
                      and sssq_z=ldt_sssq_z
                      and new_add='1' ;
   --end add yuxh on 2011-4-6 调整优化性能结束
   -------------------------------------------------------------------------
end if;
--结束 删除操作处理
--************************************************************************

--************************************************************************
--开始 更新操作处理
if ai_czlx = 2 then
   if lc_bcsb = 'Y' then --开始 若为补充申报，则删除原来的申报信息和征收信息，直接转入插入处理
      SELECT COUNT(*)
        into ln_cnt
        FROM SB_SBXX
       WHERE PZXH = ac_pzxh;
     if ln_cnt <= 0 then
        raise_application_error(-20558,'修改申报表时无法在SB_SBXX中找到相应的申报表信息。P_SB_DQDECL' );
     end if;
      SELECT QBXSSR,YSXSSR,YNSE,YJSE,YBTSE,JMSR,JMSE,
             NSR_SWJG_DM,SWJG_DM,LRR_DM,LRRQ,XGR_DM,XGRQ
        into ln_qbsr,ln_ysxssr,ln_ynse,ln_yjnse,ln_ybtse,ln_jmsr,ln_jmse,
             lc_nsr_swjg_dm,lc_swjg_dm,lc_lrr_dm,ldt_lrrq,lc_xgr_dm,ldt_xgrq
        FROM SB_SBXX
       WHERE PZXH = ac_pzxh and zsxm_dm =ac_zsxm_dm ;--modify yuxhfjs on 2008-05-19

      li_ret:=P_SB_MINUS_SBXX(
                    ac_delete=>'N',
                    ac_pzxh=>ac_pzxh,
                    ac_pzzl_dm=>ac_pzzl_dm,
                    ac_zsxm_dm=>ac_zsxm_dm,
                    avc_nsrsbh=>avc_nsrsbh,
                    an_qbxssr=>ln_qbsr,
                    an_ysxssr=>ln_ysxssr,
                    an_jmsr=>ln_jmsr,
                    an_ynse=>ln_ynse,
                    an_jmse=>ln_jmse,
                    an_yjse=>ln_yjnse,
                    an_ybtse=>ln_ybtse,
                    ac_nsr_swjg_dm=>lc_nsr_swjg_dm,
                    ac_swjg_dm=>lc_swjg_dm,
                    adt_lrrq=>ldt_lrrq,
                    ac_lrr_dm=>lc_lrr_dm,
                    adt_xgrq=>ldt_xgrq,
                    ac_xgr_dm=>lc_xgr_dm);

       IF li_ret<>100 THEN
          raise_application_error(-20558,'调用P_SB_MINUS_SBXX过程失败。P_SB_DQDECL' );
       END  IF ;

       delete from sb_zsxx where yzpzxh = ac_pzxh and zsxm_dm=ac_zsxm_dm and skzl_dm='10' ; --modify yuxhfjs on 2008-05-19,modify yuxh on 2008-7-17
       li_czlx := 1;
        --结束 若为补充申报，则删除原来的申报信息和征收信息，直接转入插入处理
   else  --若为非补充申报，则进行缴款期限处理
   --判断未达起征点 开始 liulh 2007-1-16
   li_ret := p_hd_qzd_bz(avc_nsrsbh => avc_nsrsbh,
                            AVC_ZSXM => ac_zsxm_dm ,
                            ADT_YXQ_Q => adt_sssq_q,
                            ADT_YXQ_Z => adt_sssq_z,
                            AVC_QZD_BZ => lc_wdqzdh );
   if li_ret <> 100 then
      raise_application_error(-20559,'取未达起征点户标志出错!P_SB_DQDECL');
   end if;
   if (ac_wdqzd_bz = 'Y' and lc_wdqzdh = 'Y') and (ln_qbyjnse_bq - ln_qbyjnse_sq )> 0 then
--    raise_application_error(-20571,'该户为未达起征点户，且本月未达起征点，不允许预缴！P_SB_DQDECL');
      li_return := 201 ;
      return li_return ;--为保持美观，不抛出异常
   end if;
   --判断未达起征点 结束 liulh 2007-1-16

   if --((lc_state_de = 'cde' and ldt_sbqx_hzsbqx is not null) or
      lc_state_de = 'cfd' and lc_gtdqde = 'Y' then
      --2007-3-11调帐处理
     ln_temp := ln_qbhdse_bq - ln_qbyjnse_bq - ln_qbjmse_bq;
     if ln_temp < 0 then
        ln_temp := 0;
     end if;
     li_Ret := p_sb_tzcl(avc_nsrsbh,ac_zsxm_dm,adt_sssq_q,adt_sssq_z,ac_pzzl_dm,ln_temp,ldt_jkqx,ldt_jkqx_cur,ac_pzxh);
   end if;

   --开始 未达起征户已达起征点，缴款期限为当前属期规定的缴款期限 liulh 2007-1-17
   if ac_wdqzd_bz = 'Y' and lc_wdqzdh = 'Y' then
      update sb_sbxx
        set sbqx = ldt_sbqx,
            yqsbqx = ldt_yqsbqx
        where (sbqx is null or sbqx <> ldt_sbqx) and pzxh = ac_pzxh and zsxm_dm=ac_zsxm_dm; --modify yuxhfjs on 2008-05-19
   elsif ((ac_wdqzd_bz is null or ac_wdqzd_bz = 'N') and lc_wdqzdh = 'Y') then
    if (ac_pzzl_dm = '10148' or ac_pzzl_dm = '10149') then
        update sb_sbxx
        set sbqx = ldt_sbqx_hzsbqx,
            yqsbqx = ldt_yqsbqx_hzsbqx
        where (sbqx is null or sbqx <> ldt_sbqx_hzsbqx) and pzxh = ac_pzxh and zsxm_dm=ac_zsxm_dm; --modify yuxhfjs on 2008-05-19
    else
        update sb_sbxx
        set sbqx = ldt_sbqx_cur,
            yqsbqx = ldt_yqsbqx_cur
        where (sbqx is null or sbqx <> ldt_sbqx_cur) and pzxh = ac_pzxh and zsxm_dm=ac_zsxm_dm;  --modify yuxhfjs on 2008-05-19;
    end if;

    update sb_zsxx a
       set jkqx =  decode(jkqx,null,null,ldt_jkqx_cur),
       jkqx_znj = decode(jkqx_hj,null,ldt_jkqx_cur,ldt_hjjkqx_cur)
     where jkqx is not null
       and a.sssq_q = adt_sssq_q
       and a.sssq_z = adt_sssq_z
       and a.yzpzxh = ac_pzxh
       and a.zsxm_dm =ac_zsxm_dm ; --modify yuxhfjs on 2008-05-19

--    li_ret := p_sb_tzcl(lc_zsxh,'',ldt_jkqx_cur,ldt_hjjkqx_cur,0,0,0,adt_sssq_q,adt_sssq_z,ac_pzxh,'','','','');
   --结束 未达起征户已达起征点，缴款期限为当前属期规定的缴款期限 liulh 2007-1-17
   elsif lc_state_de = 'cfd' and lc_gtdqde = 'Y' then
   --批量处理缴款期限 开始 liulh 2007-1-17
       --针对超幅度，缴款期限为当前属期规定的缴款期限
      update sb_zsxx a
           set a.jkqx = ldt_jkqx_cur,a.jkqx_znj = decode(ldt_hjjkqx_cur,null,ldt_jkqx_cur,ldt_hjjkqx_cur),a.jkqx_hj = ldt_hjjkqx_cur
           where -- a.jkqx is not null
            a.jkqx = ldt_sbqx_hzsbqx
            and (a.SB_TZLX_DM = '0' or a.SB_TZLX_DM = '3')
            and (a.yzpzzl_dm like lc_pzzl_dm_1 or a.yzpzzl_dm like lc_pzzl_dm_2)
            and a.skcsfs_dm = '11'
            and a.sksx_dm = '11'
            and a.zsxm_dm = ac_zsxm_dm
            and a.sssq_q = adt_sssq_q
            and a.sssq_z = adt_sssq_z
            and a.nsrsbh = avc_nsrsbh;
   end if;
   --批量处理缴款期限 结束 liulh 2007-1-17

--开始 如果没有执行期，返回汇总申报期限为空，则不做定额拆分和修改缴款期限处理。
   if ((lc_state_de = 'cde' and ldt_sbqx_hzsbqx is not null) or lc_state_de = 'cfd')
      and lc_gtdqde = 'Y' then

      --begin liulh add on 2007-3-7
      if lc_state_de = 'cde' then
         ldt_jkqx_temp := ldt_sbqx_hzsbqx;
      elsif lc_state_de = 'cfd' then
         ldt_jkqx_temp := ldt_jkqx_cur;
      end if;
      --end liulh add on 2007-3-7

      ln_temp := ln_qbhdse_bq - ln_qbyjnse_bq - ln_qbjmse_bq;
      if ln_temp < 0 then
         ln_temp := 0;
      end if;
      
      /* modify yuxh on 2011-4-6 屏蔽掉改用后面语句方式
      open cur_zsxx_for_update;
      fetch cur_zsxx_for_update into ln_kssl,ln_yssl,ln_ybtse,lc_zsxh;
      while cur_zsxx_for_update%found loop
         ln_temp := ln_temp - ln_ybtse;
         if ln_temp >= 0 then
            update sb_zsxx
            set jkqx = ldt_jkqx,
            jkqx_znj = ldt_jkqx
            where jkqx is not null and ZSXH = lc_zsxh;
         elsif ln_temp < 0 then
            ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
            ln_yssl1 := ln_yssl * (ln_ybtse1/ln_ybtse);
            ln_kssl1 := ln_kssl * (ln_ybtse1/ln_ybtse);

            ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
            ln_yssl := ln_yssl - ln_yssl1;
            ln_kssl := ln_kssl - ln_kssl1;

            ln_temp := 0;
            if ln_ybtse1 > 0 then
               li_ret:=P_GET_ZSXH(lc_zsxh_new);
               IF li_ret != 100 THEN
                  raise_application_error(-20562, '生成征收序号出错。P_SB_DQDECL' );
               END IF;
              insert into SB_ZSXX
              (ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X )
               SELECT
               lc_zsxh_new,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,ln_kssl,ln_yssl,SL,ln_ybtse,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,decode(jkqx,null,null,ldt_jkqx_temp),JKQX_HJ,decode(jkqx,null,null,ldt_jkqx_temp),JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X
               FROM SB_ZSXX
               WHERE ZSXH = lc_zsxh;
               update sb_zsxx
                set kssl = ln_kssl1,
                    xssr = ln_yssl1,
                      se = ln_ybtse1,
                    jkqx = decode(jkqx,null,null,ldt_jkqx),
                jkqx_znj = decode(jkqx,null,null,ldt_jkqx)
                where ZSXH = lc_zsxh;
             else
               li_state := -1002;
             end if;
         end if;
         if li_state = -1002 then    --针对超幅度或超定额未超幅度部分，修改缴款期限
               update sb_zsxx
                  set jkqx     = ldt_jkqx_temp,
                      jkqx_znj = ldt_jkqx_temp
               where jkqx is not null
                 and ZSXH = lc_zsxh;
         end if;
         li_state := -1000;
         fetch cur_zsxx_for_update into ln_kssl,ln_yssl,ln_ybtse,lc_zsxh;
         end loop;
         close cur_zsxx_for_update;
         */
         -----------------------------------------------------------------------------
         --add yuxh on 2011-4-7 优化汇总申报性能
          delete from  tmp_sb_zsxx_new 
               where  session_id=ln_session
                      and nsrsbh=avc_nsrsbh
                      and sssq_q=ldt_sssq_q
                      and sssq_z=ldt_sssq_z;
         
         insert into tmp_sb_zsxx_new 
               (XH,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,YJKBZ,new_add,session_id)
               SELECT
               1,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,'0','0',ln_session
               FROM SB_ZSXX  a
             where a.SE > 0 and (a.SB_TZLX_DM = '0' or a.SB_TZLX_DM = '3')
                   and (a.yzpzzl_dm like lc_pzzl_dm_1 or a.yzpzzl_dm like lc_pzzl_dm_2)
                   and skcsfs_dm = '11'
                   and a.sksx_dm = '11'
                   and a.skzl_dm='10'  
                   and a.zsxm_dm = ac_zsxm_dm
                   and a.sssq_q = adt_sssq_q
                   and a.sssq_z = adt_sssq_z
                   and a.NSRSBH = avc_nsrsbh;
                   
         select  nvl(min(zsxh),'0') into lc_zsxh from tmp_sb_zsxx_new 
                              where  session_id=ln_session
                                    and nsrsbh=avc_nsrsbh
                                    and sssq_q=ldt_sssq_q
                                    and sssq_z=ldt_sssq_z;   
         while lc_zsxh >'0'
         loop
         
         select KSSL,XSSR,SE into ln_kssl,ln_yssl,ln_ybtse 
              from  tmp_sb_zsxx_new
              where zsxh=lc_zsxh;  
         ln_temp := ln_temp - ln_ybtse;
         if ln_temp >= 0 then
            update sb_zsxx
            set jkqx = ldt_jkqx,
            jkqx_znj = ldt_jkqx
            where jkqx is not null and ZSXH = lc_zsxh;
         elsif ln_temp < 0 then
            ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
            ln_yssl1 := ln_yssl * (ln_ybtse1/ln_ybtse);
            ln_kssl1 := ln_kssl * (ln_ybtse1/ln_ybtse);

            ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
            ln_yssl := ln_yssl - ln_yssl1;
            ln_kssl := ln_kssl - ln_kssl1;

            ln_temp := 0;
            if ln_ybtse1 > 0 then
               li_ret:=P_GET_ZSXH(lc_zsxh_new);
               IF li_ret != 100 THEN
                  raise_application_error(-20562, '生成征收序号出错。P_SB_DQDECL' );
               END IF;
              insert into tmp_sb_zsxx_new
              (XH,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,yjkbz,new_add,session_id )
               SELECT
               1,lc_zsxh_new,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,ln_kssl,ln_yssl,SL,ln_ybtse,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,decode(jkqx,null,null,ldt_jkqx_temp),JKQX_HJ,decode(jkqx,null,null,ldt_jkqx_temp),JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,'0','1',ln_session
               FROM tmp_sb_zsxx_new
               WHERE ZSXH = lc_zsxh;
               
               update sb_zsxx
                set kssl = ln_kssl1,
                    xssr = ln_yssl1,
                      se = ln_ybtse1,
                    jkqx = decode(jkqx,null,null,ldt_jkqx),
                jkqx_znj = decode(jkqx,null,null,ldt_jkqx)
                where ZSXH = lc_zsxh;
             else
               li_state := -1002;
             end if;
         end if;
         if li_state = -1002 then    --针对超幅度或超定额未超幅度部分，修改缴款期限
               update sb_zsxx
                  set jkqx     = ldt_jkqx_temp,
                      jkqx_znj = ldt_jkqx_temp
               where jkqx is not null
                 and ZSXH = lc_zsxh;
         end if;
         li_state := -1000;
         
         select nvl(min(zsxh),'0') into lc_zsxh  from  tmp_sb_zsxx_new 
                     where session_id=ln_session
                        and nsrsbh=avc_nsrsbh
                        and sssq_q=ldt_sssq_q
                        and sssq_z=ldt_sssq_z             
                        and zsxh > lc_zsxh ;    
      end loop;
         
         insert into  sb_zsxx
              (ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X)
       select  ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X  
               from  tmp_sb_zsxx_new 
               where  session_id=ln_session
                      and nsrsbh=avc_nsrsbh
                      and sssq_q=ldt_sssq_q
                      and sssq_z=ldt_sssq_z
                      and new_add='1' ;
     --end add yuxh on 2011-4-7 调整优化性能
     ---------------------------------------------------------------------   
     end if;
      --结束 计算超定额部分 liulh 2007-1-17
   end if;
end if;
--结束 更新操作处理
--************************************************************************

--************************************************************************
--开始 插入操作处理
if ai_czlx = 1 or li_czlx = 1 then
   --判断未达起征点 开始 liulh 2007-1-16
   li_ret := p_hd_qzd_bz(avc_nsrsbh => avc_nsrsbh,
                            AVC_ZSXM => ac_zsxm_dm ,
                            ADT_YXQ_Q => adt_sssq_q,
                            ADT_YXQ_Z => adt_sssq_z,
                            AVC_QZD_BZ => lc_wdqzdh );
   if li_ret <> 100 then
      raise_application_error(-20566,'取未达起征点户标志出错!P_SB_DQDECL');
   end if;
   if  (ac_wdqzd_bz = 'Y' and lc_wdqzdh = 'Y') and (ln_qbyjnse_bq - ln_qbyjnse_sq )> 0 then
--     raise_application_error(-20571,'该户为未达起征点户，且本月未达起征点，不允许预缴！P_SB_DQDECL');
       li_return := 201 ;
       return li_return ;--为保持美观，不抛出异常
   end if;
   --判断未达起征点 结束 liulh 2007-1-16

   --若为补充申报或超定额，都需要取本次申报信息，为插入新记录作准备
   if lc_bcsb = 'Y' or lc_state_de = 'cde' then
      if ac_pzzl_dm = '10102' or ac_pzzl_dm = '10110' then
         SELECT SBXH,ZSPM_DM,SBRQ,TBRQ,XSE,HDXSE,ZSL,
         BQYNSE,HDYNSE,JMSE,YJNSE,QZYJSE,QZDJSE,YZSE,YBTSE,NSR_SWJG_DM,
         SWJG_DM,LRR_DM,LRRQ,XGR_DM,XGRQ
         into lc_sbxh,lc_zspm_dm,ldt_sbrq,ldt_tbrq,
         ln_xse,ln_hdxse,ln_zsl,ln_bqynse,ln_hdynse,ln_jmse,ln_yjnse,ln_qzyjse,
         ln_qzdjse,ln_yzse,ln_ybtse,lc_nsr_swjg_dm,lc_swjg_dm,lc_lrr_dm,ldt_lrrq,
         lc_xgr_dm,ldt_xgrq
         FROM SB_ZZS_XGMNSR WHERE PZXH = ac_pzxh and rownum = 1;
      elsif ac_pzzl_dm = '10106' or ac_pzzl_dm = '10117'  then
         SELECT SBXH,ZSPM_DM,SBRQ,TBRQ,YSSL,SL,
         BQ_YJNSE,BQ_YBTSE,JMSE,QZYJSE,QZDJSE,YZSE,NSR_SWJG_DM,
         SWJG_DM,LRR_DM,LRRQ,XGR_DM,XGRQ
         into lc_sbxh,lc_zspm_dm,ldt_sbrq,ldt_tbrq,
         ln_xse,ln_zsl,ln_yjnse,ln_ybtse,ln_jmse,ln_qzyjse,
         ln_qzdjse,ln_yzse,lc_nsr_swjg_dm,lc_swjg_dm,lc_lrr_dm,ldt_lrrq,
         lc_xgr_dm,ldt_xgrq
         FROM SB_XFS_ZB WHERE PZXH = ac_pzxh and rownum = 1;
      elsif ac_pzzl_dm = '10177' or ac_pzzl_dm = '10178'  then --ADD BY WANGXBD 增加10177,10178
         SELECT SBXH,ZSPM_DM,SBRQ,TBRQ,XSE,SL,
         BQ_YBTSE,BQ_JMSE,BQ_YJSE,NSR_SWJG_DM,
         SWJG_DM,LRR_DM,LRRQ,XGR_DM,XGRQ
         into lc_sbxh,lc_zspm_dm,ldt_sbrq,ldt_tbrq,ln_xse,ln_zsl,
         ln_ybtse,ln_jmse,ln_qzyjse,lc_nsr_swjg_dm,
         lc_swjg_dm,lc_lrr_dm,ldt_lrrq,lc_xgr_dm,ldt_xgrq
         FROM SB_XFS_2008_ZB WHERE PZXH = ac_pzxh and rownum = 1;
         --end by wangxbd 2008.1.14
      elsif ac_pzzl_dm = '10105' or ac_pzzl_dm = '10147' then
         --modify yuxh on 2010-7-5 ZHZG_2010_004 处理销售收入
         SELECT t.SBXH,'',t.SBRQ,t.TBRQ,(NVL(t.yzhwlwbhsxse,0) + NVL(t.xsgdzcbhsxse,0) + nvl(t.mshwlwxse,0) + nvl(t.ckmshwxse,0)) YSSL,0,
         t.yjse BQ_YJNSE,t.ybtse BQ_YBTSE,t.ynsejze JMSE,t.yjse QZYJSE,0,t.ynse,NSR_SWJG_DM,
         SWJG_DM,LRR_DM,LRRQ,XGR_DM,XGRQ
         into lc_sbxh,lc_zspm_dm,ldt_sbrq,ldt_tbrq,
         ln_xse,ln_zsl,ln_yjnse,ln_ybtse,ln_jmse,ln_qzyjse,
         ln_qzdjse,ln_yzse,lc_nsr_swjg_dm,lc_swjg_dm,lc_lrr_dm,ldt_lrrq,
         lc_xgr_dm,ldt_xgrq
         FROM SB_ZZS_XGMNSR_2005 t WHERE t.PZXH = ac_pzxh and t.sbbl = 1;

         begin
           if lc_gtdqde = 'Y' then
	             SELECT SL,ZSPM_DM INTO ln_zsl ,lc_zspm_dm
               FROM  HD_DSQC_LS
               WHERE ZSXM_DM = ac_zsxm_dm
	              AND  NSRSBH = avc_nsrsbh
                AND (YXQ_Q <= adt_sssq_z)
                AND ((YXQ_Z IS NULL) OR (YXQ_Z >= adt_sssq_z))
                and ((YXQ_Z IS NULL) OR (YXQ_Z > YXQ_Q))
	              and rownum = 1;
           else
/*              SELECT ZSL,ZSPM_DM  INTO ln_zsl ,lc_zspm_dm
                FROM DJ_SZ_ZB
               WHERE ZSXM_DM = ac_zsxm_dm
                 AND NSRSBH = avc_nsrsbh
                 and WTDZ_BZ = 'N'
                 and rownum = 1;*/

               -- liulh 2009-01-04
               li_ret := P_DJ_GET_NSR_SL_SSSQ(avc_nsrsbh,ac_zsxm_dm,lc_zspm_dm,
                   adt_sssq_q,adt_sssq_z,'N',ln_sl,ln_zsl,lc_bz);
               if li_ret <> 100 then
                  raise_application_error(-20568,'2005版小规模补充申报无法取得正确的增值税征收率和征收品目！');
               end if;
               -- end by liulh 2009-01-04
           end if;
         exception
--           when no_data_found then --comment by liulh 2009-01-04
           when others then --liulh 2009-01-04
               raise_application_error(-20568,'2005版小规模补充申报无法取得正确的增值税核定征收率和征收品目！');
         end ;
/*         begin
	         SELECT SL,ZSPM_DM INTO ln_zsl ,lc_zspm_dm
               FROM  HD_DSQC_LS
               WHERE ZSXM_DM = ac_zsxm_dm
	         AND  NSRSBH = avc_nsrsbh
               AND (YXQ_Q <= adt_sssq_z)
               AND ((YXQ_Z IS NULL) OR (YXQ_Z >= adt_sssq_z))
               and ((YXQ_Z IS NULL) OR (YXQ_Z > YXQ_Q))
	             and rownum = 1;
         exception
             when no_data_found then
               raise_application_error(-20568,'2005版小规模补充申报无法取得正确的增值税核定征收率和征收品目！');
         end ;
*/
      elsif ac_pzzl_dm = '10148' or ac_pzzl_dm = '10149' then
         SELECT t.SBXH,'',t.SBRQ,t.TBRQ,XSE,SL,0 BQ_YJNSE,t.ybtse BQ_YBTSE,
         0 JMSE,0 QZYJSE,0,t.ybtse,NSR_SWJG_DM,SWJG_DM,LRR_DM,LRRQ,XGR_DM,XGRQ
         into lc_sbxh,lc_zspm_dm,ldt_sbrq,ldt_tbrq,ln_xse,ln_zsl,ln_yjnse,ln_ybtse,
         ln_jmse,ln_qzyjse,ln_qzdjse,ln_yzse,lc_nsr_swjg_dm,lc_swjg_dm,lc_lrr_dm,ldt_lrrq,lc_xgr_dm,ldt_xgrq
         FROM SB_GTDQDE_HZSB t
         WHERE t.sssq_q = adt_sssq_q and t.sssq_z = adt_sssq_z and t.PZXH = ac_pzxh and rownum = 1;

         begin
            /*SELECT   ZSPM_DM INTO lc_zspm_dm
            FROM    DJ_SZ_ZB
            WHERE   ZSXM_DM = ac_zsxm_dm  AND     NSRSBH = avc_nsrsbh
              and   WTDZ_BZ = 'N'        and     rownum = 1;*/
            -- liulh 2009-01-04
            li_ret := P_DJ_GET_NSR_SL_SSSQ(avc_nsrsbh,ac_zsxm_dm,lc_zspm_dm,
                   adt_sssq_q,adt_sssq_z,'N',ln_sl,ln_zsl,lc_bz);
            if li_ret <> 100 then
                  raise_application_error(-20568,'分月汇总申报无法取得正确的增值税征收品目！');
            end if;-- end by liulh 2008-12-18
         exception
--           when no_data_found then --comment by liulh 2009-01-04
            when others then --liulh 2009-01-04
              raise_application_error(-20568,'分月汇总申报无法取得正确的增值税征收品目！');
         end;
      end if;
   end if;

   ----若为补充申报,计算差额 并插入sbxx和zsxx 开始 liulh 2007-1-17
   if lc_bcsb = 'Y' then
      ln_xse   := ln_qbxse_bq - ln_qbxse_sq;
      ln_ynse  := ln_qbynse_bq - ln_qbynse_sq;
      ln_jmse  := ln_qbjmse_bq - ln_qbjmse_sq;
      ln_yjnse := ln_qbyjnse_bq - ln_qbyjnse_sq;
      ln_ybtse := ln_qbybtse_bq - ln_qbybtse_sq;
      ln_hdynse := ln_qbhdse_bq;
      ln_hdxse := ln_qbhdxse_bq;
      ln_qzyjse := ln_qbqzyjse_bq - ln_qbqzyjse_sq;
--    ln_qzdjse := ln_qbqzdjse_bq - ln_qbqzdjse_sq;

      --add yuxh on 2010-7-5 ZHZG_2010_004  一般纳税人认定需求
      if ac_pzzl_dm='10147' then
         ln_ysxssr_bq_tmp:=ln_ysxssr_bq_tmp - ln_ysxssr_sq_tmp ;
      end if;
      --end yuxh on 2010-7-5

      if ac_pzzl_dm = '10106' or ac_pzzl_dm = '10117'  then
         ln_bqynse := ln_ybtse + ln_qzyjse + ln_jmse;
      end if;

      if ac_zsxm_dm = '03' then --若为消费税
        --Added By Wusl 2002-12-08
         begin
           select SLLX_DM into lc_sllx from DJ_ZSXM_SL
           where ZSXM_DM = '03' and ZSPM_DM = lc_zspm_dm and SL = ln_zsl;
         exception
           when no_data_found then
               raise_application_error(-20568,'消费税申报表录入的税率'||to_char(ln_zsl)||'未通过校验,请先通过税率维护进行税率设置。');
         end ;

         if lc_sllx = '01' then  --从价征收
            ln_kssl := 0;
            ln_ysxssr := ln_xse;
         end if ;
         if lc_sllx = '02' then  --从量征收
            ln_kssl := ln_xse;
            ln_ysxssr := 0;
         end if ;
         ln_qbsr := ln_ysxssr + ln_kssl;
         --end By Wusl 2002-12-08
         ----------------------------------------------
      else
        -- liulh 2009-01-04
        li_ret := P_DJ_GET_NSR_SL_SSSQ(avc_nsrsbh,ac_zsxm_dm,lc_zspm_dm,
                   adt_sssq_q,adt_sssq_z,'N',ln_sl,ln_zsl,lc_bz);
        if li_ret <> 100 then
           raise_application_error(-20568,'补充申报无法取得正确的征收品目！');
        end if;-- end by liulh 2009-01-04

        /* modify yuxh on 2010-7-5 ZHZG_2010_004 屏蔽税率处理
		    ----------------modify yuxh on 2008-6-23
				--处理特殊征收率，纳税人只有一个增值税征收品目
				select count(*) into li_count
				       FROM    DJ_SZ_ZB
				       WHERE   ZSXM_DM='01'
				       AND     NSRSBH = avc_nsrsbh
				       and     WTDZ_BZ = 'N';
				--------------------
				if li_count=1 then

				   SELECT  ZSL
				       INTO    ln_zsl
				       FROM    DJ_SZ_ZB
				       WHERE   ZSXM_DM='01'
				       AND     NSRSBH = avc_nsrsbh
				       and     WTDZ_BZ = 'N'
				       and     rownum = 1;
				else --comment by liulh 2009-01-04
                if li_count<> 1 then
		   ln_zsl:=0;
		end if ;
		------------------end modify yuxh on 2008-6-23
         */

        --add yuxh on 2010-7-5  ZHZG_2010_004 处理税率
        Select  count(1) into li_ret from   rd_nsrzg_lsxx  --rd_yqwsqrdcl
        where nsrsbh=avc_nsrsbh and  YXQ_Q <= adt_sssq_q AND (YXQ_Z IS NULL OR YXQ_Z >=adt_sssq_z) and NSRZG_DM='04';
        If  li_ret  >0 then
            Ln_zsl:=Ln_sl;
        End if;
        If ln_zsl is null or ln_zsl=0 then
           if  ldt_sssq_z<= to_date('2008-12-31', 'yyyy-mm-dd') then
               ln_zsl := 0.06;
           else
               ln_zsl := 0.03;
           end if;
        end if;
        --end yuxh on 2010-7-5

        li_ret := p_sb_set_seds(an_xse => ln_xse,
                               an_hdxse => ln_hdxse,
                               an_zsl => ln_zsl,
                               an_hdynse => ln_hdynse,
                               an_bqynse => ln_bqynse,
                               an_jmse => ln_jmse,
                               an_yjnse =>ln_yjnse,
                               an_ybtse => ln_ybtse,
                               an_qbsr => ln_qbsr,
                               an_ysxssr => ln_ysxssr,
                               an_jmsr => ln_jmsr,
                               an_ynse => ln_ynse );
          IF  li_ret<>100  THEN
              raise_application_error(-20569,'税额倒算销售收入出错！P_SB_DQDECL' );
          END  IF ;
          ln_kssl := 0;
       end if;

      --add yuxh on 2010-7-5 ZHZG_2010_004 处理销售收入及应税销售收入
      if ac_pzzl_dm='10147' then
         ln_ysxssr:=ln_ysxssr_bq_tmp ;
         ln_qbsr:=ln_xse;
      end if;
      --end yuxh on 2010-7-5

      -- [开始]： 向SB_SBXX插入记录
      li_ret:=P_SB_INSERT_SBXX(
                ac_pzxh       => ac_pzxh,
                ac_zsxm_dm    => ac_zsxm_dm,
                avc_nsrsbh    => avc_nsrsbh,
                ac_pzzl_dm    => ac_pzzl_dm,
                adt_sbrq      => ldt_sbrq,
                adt_tbrq      => ldt_tbrq,
                adt_sssq_q    => ldt_sssq_q ,
                adt_sssq_z    => ldt_sssq_z ,
                an_qbxssr     => ln_qbsr,
                an_ysxssr     => ln_ysxssr,
                an_ynse       => ln_ynse,
                an_yjse       => ln_qzyjse,
                an_ybtse      => ln_ybtse,
                an_jmsr       => ln_jmsr,
                an_jmse       => ln_jmse,
                ac_djzclx_dm  => lc_djzclx_dm,
                ac_hy_dm      => lc_hy_dm    ,
                ac_lsgx_dm    => lc_lsgx_dm  ,
                ac_zdsy_dm    => lc_zdsy_dm  ,
                an_sbqx       => ln_sbqx     ,
                ac_zsxmfl_dm  => lc_zsxmfl_dm,
                ac_sbfs_dm    => lc_sbfs_dm  ,
                ac_zsfs_dm    => lc_zsfs_dm  ,
                ac_zsdlfs_dm  => lc_zsdlfs_dm,
                ac_jdxz_dm    => lc_jdxz_dm  ,
                ac_zgswgy_dm  => lc_zgswgy_dm,
                ac_nsr_swjg_dm=> lc_nsr_swjg_dm,
                ac_swjg_dm    => lc_swjg_dm,
                ac_lrr_dm     => lc_lrr_dm,
                adt_lrrq      => ldt_lrrq  );
      IF   li_ret<>100  THEN
           raise_application_error(-20570, '调用P_SB_INSERT_SBXX过程错。P_SB_DQDECL' );
      END  IF ;
      -- [结束]： 向SB_SBXX插入记录
      /*****************************************************************/

      -- [开始]： 向SB_ZSXX插入数据

      li_ret :=P_SB_INSERT_ZSXX(
           ac_pzxh         =>ac_pzxh,
           ac_pzmxxh       =>lc_sbxh,
           ac_pzzl_dm      => ac_pzzl_dm,
           ac_yzbz         => 'Y',
           ac_pzlrr_dm     =>lc_lrr_dm,
           adt_pzfsrq      => ldt_sbrq,
           avc_nsrsbh      => avc_nsrsbh,
           adt_sssq_q      => ldt_sssq_q,
           adt_sssq_z      => ldt_sssq_z,
           ac_zsxm_dm      => ac_zsxm_dm,
           ac_zspm_dm      => lc_zspm_dm,
           ac_sksx_dm      => '11',
           ac_skzl_dm      => '10',
           an_kssl         => ln_kssl,
           an_xssr         => ln_ysxssr,
           an_jmsr         => ln_jmsr,
           an_sl           => ln_zsl,
           an_se           => ln_ybtse,
           an_jmse         => ln_jmse,
           an_ttse         => 0,
           an_ttfsrq       => null,
           ac_ttjmlx       =>lc_ttjmlx,
           an_jkqxpyl      =>ln_jkqxpyl,
           adt_jkqx        =>ldt_jkqx1,
           ac_djzclx_dm    =>lc_djzclx_dm,
           ac_hy_dm        =>lc_hy_dm,
           ac_lsgx_dm      =>lc_lsgx_dm,
           ac_jdxz_dm      =>lc_jdxz_dm,
           ac_zgswgy_dm    =>lc_zgswgy_dm,
           ac_zdsy_dm      =>lc_zdsy_dm,
           ac_yskm_dm      =>lc_yskm_dm,
           ac_ysfpbl_dm    =>lc_ysfpbl_dm,
           an_ysfpbl_zy    =>ln_ysfpbl_zy,
           an_ysfpbl_ss    =>ln_ysfpbl_ss,
           an_ysfpbl_ds    =>ln_ysfpbl_ds,
           an_ysfpbl_xq    =>ln_ysfpbl_xq,
           an_ysfpbl_xz    =>ln_ysfpbl_xz,
           an_ysfpbl_xc    =>ln_ysfpbl_xc,
           ac_zsxmfl_dm    =>lc_zsxmfl_dm,
           ac_sbfs_dm      =>lc_sbfs_dm,
           ac_zjfs_dm      =>lc_zjfs_dm,
           ac_zsfs_dm      =>lc_zsfs_dm,
           ac_zsdlfs_dm    =>lc_zsdlfs_dm,
           ac_skgk_dm      =>lc_skgk_dm,
           ac_nsr_swjg_dm  =>lc_nsr_swjg_dm,
           ac_zsjg_dm      =>lc_zsjg_dm,
           ac_skss_swjg_dm =>lc_skss_swjg_dm,
           ac_swjg_dm      => lc_swjg_dm,
           ac_lrr_dm       => lc_lrr_dm,
           adt_lrrq        => ldt_lrrq );
      IF  li_ret<>100  THEN
          raise_application_error(-20571, '调用P_SB_INSERT_ZSXX过程错。P_SB_DQDECL' );
      END  IF ;

      --针对超定额未超幅度部分，将缴款期限为分月汇总缴款期限
       if  lc_state_de  = 'cde' and  (ldt_sbqx_hzsbqx is  not null)  then
      update  sb_zsxx set jkqx =ldt_sbqx_hzsbqx, jkqx_znj  = ldt_sbqx_hzsbqx
       where jkqx  is not  null  and  yzpzxh =  ac_pzxh
                                 and  zsxm_dm=ac_zsxm_dm  --yuxhfjs  on 2008-05-19
                                 and   skzl_dm<>'20';  --modify  yuxh   on  2009-3-4  排除滞纳金
       --开始  2007-3-11若修改前为超幅度，修改后为超定额，则作以下处理。

         select count(*) into ln_cnt from sb_zsxx where yzpzxh = ac_scsbpzxh;
         if ln_cnt > 0 then
            select jkqx,yzpzzl_dm into ldt_jkqx_temp,lc_pzzl_dm_sc from sb_zsxx where yzpzxh = ac_scsbpzxh and zsxm_dm=ac_zsxm_dm and rownum =1; --add yuxhfjs on 2008-05-19
         end if;

         --modify yuxh on 2008-8-26 修改屏蔽下面语句放开条件，考虑原始申报增加10102、10105、10106
         --if Instr('10110,10117,10147',lc_pzzl_dm_sc,1) > 0 and ldt_jkqx_temp <> ldt_sbqx_hzsbqx then
         if Instr('10102,10105,10106,10110,10117,10147',lc_pzzl_dm_sc,1) > 0 and ldt_jkqx_temp <> ldt_sbqx_hzsbqx then
            ln_temp := ln_qbhdse_bq - ln_qbyjnse_bq - ln_qbjmse_bq;
            if ln_temp < 0 then
               ln_temp := 0;
            end if;
            li_Ret := p_sb_tzcl(avc_nsrsbh,ac_zsxm_dm,adt_sssq_q,adt_sssq_z,ac_pzzl_dm,ln_temp,ldt_jkqx,ldt_sbqx_hzsbqx,ac_pzxh);

           /* modify yuxh on 2011-4-6 屏蔽以下代码，采用后面代码
            open cur_zsxx_for_update;
            fetch cur_zsxx_for_update into ln_kssl,ln_yssl,ln_ybtse,lc_zsxh;
            while cur_zsxx_for_update%found loop
               ln_temp := ln_temp - ln_ybtse;
               if ln_temp >= 0 then
                  update sb_zsxx
                     set jkqx = ldt_jkqx,
                     jkqx_znj = ldt_jkqx
                   where jkqx is not null and ZSXH = lc_zsxh;
               elsif ln_temp < 0 then
                   ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
                   ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
                   ln_temp := 0;
                   if ln_ybtse1 <= 0 then
                      li_state := -1002;
                   end if;
               end if;
               if li_state = -1002 then    --针对超幅度或超定额未超幅度部分，修改缴款期限
                   update sb_zsxx
                      set jkqx     = ldt_sbqx_hzsbqx,
                          jkqx_znj = ldt_sbqx_hzsbqx
                   where jkqx is not null
                     and ZSXH = lc_zsxh;
              end if;
              li_state := -1000;
              fetch cur_zsxx_for_update into ln_kssl,ln_yssl,ln_ybtse,lc_zsxh;
         end loop;
         close cur_zsxx_for_update;
         */
         ------------------------------------------------------------------------------
         --add yuxh on 2011-4-6  调整优化效率
         delete from  tmp_sb_zsxx_new 
               where  session_id=ln_session
                      and nsrsbh=avc_nsrsbh
                      and sssq_q=ldt_sssq_q
                      and sssq_z=ldt_sssq_z;
         
         insert into tmp_sb_zsxx_new 
               (XH,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,YJKBZ,new_add,session_id)
               SELECT
               1,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,'0','0',ln_session
               FROM SB_ZSXX  a
             where a.SE > 0 and (a.SB_TZLX_DM = '0' or a.SB_TZLX_DM = '3')
                   and (a.yzpzzl_dm like lc_pzzl_dm_1 or a.yzpzzl_dm like lc_pzzl_dm_2)
                   and skcsfs_dm = '11'
                   and a.sksx_dm = '11'
                   and a.skzl_dm='10'  
                   and a.zsxm_dm = ac_zsxm_dm
                   and a.sssq_q = adt_sssq_q
                   and a.sssq_z = adt_sssq_z
                   and a.NSRSBH = avc_nsrsbh;
         
         select  nvl(min(zsxh),'0')  into lc_zsxh from  tmp_sb_zsxx_new 
                  where  session_id=ln_session
                         and nsrsbh=avc_nsrsbh
                         and sssq_q=ldt_sssq_q
                         and sssq_z=ldt_sssq_z;
         while lc_zsxh >'0'
         loop
         
           select KSSL,XSSR,SE into ln_kssl,ln_yssl,ln_ybtse 
              from  tmp_sb_zsxx_new
              where zsxh=lc_zsxh; 
           
               ln_temp := ln_temp - ln_ybtse;
               if ln_temp >= 0 then
                  update sb_zsxx
                     set jkqx = ldt_jkqx,
                     jkqx_znj = ldt_jkqx
                   where jkqx is not null and ZSXH = lc_zsxh;
               elsif ln_temp < 0 then
                   ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
                   ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
                   ln_temp := 0;
                   if ln_ybtse1 <= 0 then
                      li_state := -1002;
                   end if;
               end if;
               if li_state = -1002 then    --针对超幅度或超定额未超幅度部分，修改缴款期限
                   update sb_zsxx
                      set jkqx     = ldt_sbqx_hzsbqx,
                          jkqx_znj = ldt_sbqx_hzsbqx
                   where jkqx is not null
                     and ZSXH = lc_zsxh;
              end if;
              li_state := -1000;
              
             select nvl(min(zsxh),'0')  into lc_zsxh  from  tmp_sb_zsxx_new 
                     where  session_id=ln_session
                        and nsrsbh=avc_nsrsbh
                        and sssq_q=ldt_sssq_q
                        and sssq_z=ldt_sssq_z           
                        and zsxh > lc_zsxh ;     
         end loop;
         --end yuxh on 2011-4-6 调整优化效率
         ------------------------------------------------------------------------------
      --结束 计算超定额部分 liulh 2007-1-17

/*            update sb_zsxx a
                  set a.jkqx = ldt_sbqx_hzsbqx,a.jkqx_znj = ldt_sbqx_hzsbqx
                where (a.SB_TZLX_DM = '0' or a.SB_TZLX_DM = '3')
                  and (a.yzpzzl_dm like lc_pzzl_dm_1 or a.yzpzzl_dm like lc_pzzl_dm_2)
                  and a.skcsfs_dm = '11'
                  and a.sksx_dm = '11'
                  and a.yzpzzl_dm = lc_pzzl_dm_sc
                  and a.zsxm_dm = ac_zsxm_dm
                  and a.sssq_q = adt_sssq_q
                  and a.sssq_z = adt_sssq_z
                  and a.nsrsbh = avc_nsrsbh;
*/         end if;
         --结束 2007-3-11若修改前为超幅度，修改后为超定额，则作以下处理。
      elsif lc_state_de = 'cfd' then
         update sb_zsxx
         set jkqx = ldt_jkqx_cur,
         jkqx_znj = decode(jkqx_hj,null,ldt_jkqx_cur,ldt_hjjkqx_cur)
         where jkqx is not null and yzpzxh = ac_pzxh
               and zsxm_dm=ac_zsxm_dm  --modify yuxhfjs on 2008-05-19;
               and skzl_dm<>'20'; --modify yuxh on 2009-3-4 排除滞纳金
      end if;

     if li_czlx <> 1 or li_czlx is null then --如果为更新后转入的插入，不执行此段减免处理

       --hongjun add on 2003-11-14
       li_ret := P_GET_XTCS(
                  ac_csxh  => '31147',
                  avc_csnr => lc_jmjk);
       if li_ret <>  100 then
           raise_application_error(-20572,'取减免监控方式出错，P_SB_DQDECL');
       end if;

       if lc_jmjk = 'Y' then
          li_ret := P_WS_GET_NSR_JMXX(
                      avc_nsrsbh=> avc_nsrsbh,
                      ac_zsxm_dm=> ac_zsxm_dm,
                      ac_pzzl_dm=> ac_pzzl_dm,
                      adt_sssq_q=> adt_sssq_q,
                      adt_sssq_z=> adt_sssq_z,
                      ac_jmyy   => lc_jmyy,
                      an_sysl   => ln_jm_sysl_qy,
                      an_jmsl   => ln_jmsl,             --2003-08
                      an_jmed   => ln_jmed,
                      an_jmfd   => ln_jmfd,
                      an_sysl_df   => ln_jm_sysl_df,    --2003-08
                      an_jmsl_df   => ln_jmsl_df,
--                    an_jmed_df   => ln_jmed_df,       --2003-08
                      an_jmfd_df   => ln_jmfd_df);
          IF   li_ret  <> 100 and li_ret <> 200 THEN
               RAISE_APPLICATION_ERROR(-20573,'取得纳税人减免信息出错！P_SB_DQDECL');
          END  IF;

          if li_ret = 100 then
             lc_jmlx := 'edjm';--享受额度减免
          end if;
         ln_jmed := 0;
          --开始 计算本次申报的减免额度
          if lc_jmlx = 'edjm' then
             if ac_pzzl_dm = '10102' or ac_pzzl_dm = '10110'  then
                open cur_zzs (ac_pzxh);
                fetch cur_zzs into ln_xse,ln_zsl,ln_jmse;
                while cur_zzs%found loop
                   if ln_jmfd is null then
                      ln_jmfd := 0;
                   end if;
                 /*if ln_jmsl is null then
                      ln_jmsl := ln_zsl;
                   end if;*/
                   if ln_xse < 0 then
                      ln_xse := 0;
                   end if; --2003-08
                   if ln_jmsl is null then
                      ln_jmed_one := (ln_jmse - round(ln_xse * ln_zsl - ln_xse * (1 - ln_jmfd) * ln_zsl,2));
                   else
                      ln_jmed_one := (ln_jmse - round(ln_xse * ln_zsl - ln_xse * (1 - ln_jmfd) * ln_jmsl,2));
                   end if;
                   if ln_jmed_one < 0 then
                      ln_jmed_one := 0 ;
                   end if;
                   ln_jmed := ln_jmed + ln_jmed_one ;
                   ln_jmed_df := 0;
                   fetch cur_zzs into ln_xse,ln_zsl,ln_jmse;
                end loop;
                close cur_zzs;
             elsif ac_pzzl_dm = '10106' or ac_pzzl_dm = '10117'  then
                open cur_xfs(ac_pzxh);
                fetch cur_xfs into ln_xse,ln_zsl,ln_jmse;
                while cur_xfs%found loop
                   if ln_jmfd is null then
                      ln_jmfd := 0;
                   end if;
                   /*if ln_jmsl is null then
                     ln_jmsl := ln_zsl;
                     end if;*/
                   if ln_xse < 0 then
                      ln_xse := 0;
                   end if; --2003-08
                   if ln_jmsl is null then
                      ln_jmed_one := (ln_jmse - round(ln_xse * ln_zsl - ln_xse * (1 - ln_jmfd) * ln_zsl,2));
                   else
                      ln_jmed_one := (ln_jmse - round(ln_xse * ln_zsl - ln_xse * (1 - ln_jmfd) * ln_jmsl,2));
                   end if;
                   if ln_jmed_one < 0 then
                      ln_jmed_one := 0 ;
                   end if;
                   ln_jmed := ln_jmed + ln_jmed_one ;
                   ln_jmed_df := 0;
                   fetch cur_xfs into ln_xse,ln_zsl,ln_jmse;
                end loop;
                close cur_xfs;
             end if;
          end if;
      --结束 计算本次申报的减免额度

          --开始 只有补充申报才计算上次申报的减免额度  liulh 2007-1-17
          if lc_jmlx = 'edjm' and lc_bcsb = 'Y' then
             select pzzl_dm into lc_pzzl_dm_sc from sb_sbxx where pzxh = ac_scsbpzxh and zsxm_dm=ac_zsxm_dm and rownum = 1; --modify yuxhfjs on 2008-05-19
             if lc_pzzl_dm_sc is null then
                lc_pzzl_dm_sc := ac_pzzl_dm;
             end if;

             if ac_pzzl_dm = '10102' or ac_pzzl_dm = '10110'  then
                open cur_zzs (ac_scsbpzxh);
                fetch cur_zzs into ln_xse_sq,ln_zsl_sq,ln_jmse_sq;
               while cur_zzs%found loop
                     if ln_jmfd is null then
                        ln_jmfd := 0;
                     end if;
/*                     if ln_jmsl is null then --liulh2007-1-24屏蔽，避免因为循环将值冲掉
                        ln_jmsl := ln_zsl;
                     end if;
*/                   if ln_xse_sq < 0 then
                        ln_xse_sq := 0;
                     end if; --2003-08
                     if ln_jmsl is null then
                        ln_jmed_one := (ln_jmse_sq - round(ln_xse_sq * ln_zsl_sq - ln_xse_sq * (1 - ln_jmfd) * ln_zsl_sq,2));--liulh add原因同上
                     else
                        ln_jmed_one := (ln_jmse_sq - round(ln_xse_sq * ln_zsl_sq - ln_xse_sq * (1 - ln_jmfd) * ln_jmsl,2));
                     end if;
                     if ln_jmed_one < 0 then
                        ln_jmed_one := 0 ;
                     end if;
                     ln_jmed_sq := ln_jmed_sq + ln_jmed_one;
                     ln_jmed_df := 0;
                     fetch cur_zzs into ln_xse_sq,ln_zsl_sq,ln_jmse_sq;
                end loop;
                close cur_zzs;
             elsif ac_pzzl_dm = '10106' or ac_pzzl_dm = '10117'  then
                   open cur_xfs(ac_scsbpzxh);
                   fetch cur_xfs
                   into ln_xse_sq,ln_zsl_sq,ln_jmse_sq;
                   while cur_xfs%found loop
                     if ln_jmfd is null then
                        ln_jmfd := 0;
                     end if;
/*                     if ln_jmsl is null then  --liulh2007-1-24屏蔽，避免因为循环将值冲掉
                        ln_jmsl := ln_zsl_sq;
                     end if;
*/                     if ln_xse_sq < 0 then
                        ln_xse_sq := 0;
                     end if; --2003-08
                     if ln_jmsl is null then
                        ln_jmed_one := (ln_jmse_sq - round(ln_xse_sq * ln_zsl_sq - ln_xse_sq * (1 - ln_jmfd) * ln_zsl_sq,2));--liulh add原因同上
                     else
                        ln_jmed_one := (ln_jmse_sq - round(ln_xse_sq * ln_zsl_sq - ln_xse_sq * (1 - ln_jmfd) * ln_jmsl,2));
                     end if;
                     if ln_jmed_one < 0 then
                        ln_jmed_one := 0 ;
                     end if;
                     ln_jmed_sq := ln_jmed_sq + ln_jmed_one;
                     ln_jmed_df := 0;
                     fetch cur_xfs into ln_xse_sq,ln_zsl_sq,ln_jmse_sq;
                   end loop;
                   close cur_xfs;
             end if;
          end if;
       end if;
      --[结束]只有补充申报才计算上次申报的减免额度  liulh 2007-1-17

      --[开始] 写减免文书反馈结果      Lijiahui 2003-07
      --如果消费税品目为各种油品或汽车轮胎，则不需要写减免文书反馈结果。
      if  not ( ac_zsxm_dm = '03' and lc_zspm_dm in ('0702','0804','0805','0806','0807','0808')) then
          if lc_bcsb = 'Y' then
            --将上期减免加回去
             li_ret:=P_WS_ADD_NSR_JMYE(
             avc_nsrsbh,
             ac_zsxm_dm,
             lc_pzzl_dm_sc,
             adt_sssq_q,
             adt_sssq_z,
             ln_jmed_sq
                );
             IF   li_ret  <> 100  THEN
                  RAISE_APPLICATION_ERROR(-20574,'维护纳税人减免信息出错！');
             END  IF ;
          end if;

            --再减去本期减免
            li_ret:=P_WS_MINUS_NSR_JMYE(
                  avc_nsrsbh,
                  ac_zsxm_dm,
                  ac_pzzl_dm,
                  adt_sssq_q,
                  adt_sssq_z,
                  ln_jmed
--                ln_jmed_df    --2003-08
                  );
            IF li_ret  <> 100  THEN
               RAISE_APPLICATION_ERROR(-20575,'维护纳税人减免信息出错！P_SB_DQDECL');
            END  IF;

      end if;
      --[结束] 写减免文书反馈结果      Lijiahui 2003-07

      --[结束]计算减免额度      Lijiahui 2003-07
      end if;--结束 如果为更新后转入的插入，不执行此段减免处理

   end if;
   ----结束 若为补充申报,计算差额,并插入sbxx和zsxx liulh 2007-1-17

  --开始 拆分出定额部分， liulh 2007-1-17
  --只有非补充申报、为定期定额个体工商户才进行拆分处理
  --如果没有执行期，返回汇总申报期限为空，则不做定额拆分和修改缴款期限处理。
  --开始 只有定期定额个体工商户才进行以下处理 liulh 2007-1-17
   if --((lc_state_de = 'cde' and ldt_sbqx_hzsbqx is not null) or
      lc_state_de = 'cfd' and lc_gtdqde = 'Y' then
      --2007-3-11调帐处理
     ln_temp := ln_qbhdse_bq - ln_qbyjnse_bq - ln_qbjmse_bq;
     if ln_temp < 0 then
        ln_temp := 0;
     end if;
     li_Ret := p_sb_tzcl(avc_nsrsbh,ac_zsxm_dm,adt_sssq_q,adt_sssq_z,ac_pzzl_dm,ln_temp,ldt_jkqx,ldt_jkqx_cur,ac_pzxh);
   end if;

  if ((lc_state_de = 'cde' and ldt_sbqx_hzsbqx is not null) or lc_state_de = 'cfd') and lc_bcsb = 'N' and  lc_gtdqde = 'Y' then

--begin liulh add on 2007-3-7
     if lc_state_de = 'cde' then
        ldt_jkqx_temp := ldt_sbqx_hzsbqx;
     elsif lc_state_de = 'cfd' then
        ldt_jkqx_temp := ldt_jkqx_cur;
     end if;
--end liulh add on 2007-3-7

     ln_temp := ln_qbhdse_bq - ln_qbyjnse_bq - ln_qbjmse_bq;
     if ln_temp < 0 then
        ln_temp := 0;
     end if;
     
    /* modify yuxh on 2011-4-6  优化效率
     
     open cur_zsxx ;
     fetch cur_zsxx into ln_kssl,ln_yssl,ln_ybtse,lc_sbxh,lc_zsxh,lc_zspm_dm;
     while cur_zsxx%found  loop
       ln_temp := ln_temp - ln_ybtse;
       if ln_temp < 0 then
          ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
          ln_yssl1 := ln_yssl * (ln_ybtse1/ln_ybtse);
          ln_kssl1 := ln_kssl * (ln_ybtse1/ln_ybtse);
          ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
          ln_yssl := ln_yssl - ln_yssl1;
          ln_kssl := ln_kssl - ln_kssl1;

          ln_temp := 0;
          if ln_ybtse1 > 0 then --若可以拆分，则新插入一条，若刚好不用拆分，则更新原来记录
             li_ret:=P_GET_ZSXH(lc_zsxh_new);
             IF li_ret != 100 THEN
                raise_application_error(-20576, '生成征收序号出错。P_SB_DQDECL' );
             END IF;
             insert into SB_ZSXX
              (ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X )
               SELECT
               lc_zsxh_new,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,ln_kssl,ln_yssl,SL,ln_ybtse,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,decode(jkqx,null,null,ldt_jkqx_temp),JKQX_HJ,decode(jkqx,null,null,ldt_jkqx_temp),JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X
               FROM SB_ZSXX
               WHERE ZSXH = lc_zsxh;
             update sb_zsxx
                set kssl = ln_kssl1,
                    xssr = ln_yssl1,
                      se = ln_ybtse1
              where ZSXH = lc_zsxh;
          else
              li_state := -1002;
          end if;
       end if;
       --针对超定额未超幅度部分，将缴款期限为分月汇总缴款期限
       if li_state = -1002 then
          update sb_zsxx
            set jkqx     = ldt_jkqx_temp,
                jkqx_znj = ldt_jkqx_temp
          where jkqx is not null
            and ZSXH = lc_zsxh;
       end if;
       li_state := -1000;
       fetch cur_zsxx into ln_kssl,ln_yssl,ln_ybtse,lc_sbxh,lc_zsxh,lc_zspm_dm;
     end loop;
     close cur_zsxx;
     */
     ------------------------------------------------------------------------------
     --add yuxh on 2011-4-6 调整优化性能
     delete  from  TMP_SB_ZSXX_NEW
         where session_id=ln_session
              and sssq_q = adt_sssq_q
              and sssq_z = adt_sssq_z
              and nsrsbh = avc_nsrsbh ;
     
     insert into TMP_SB_ZSXX_NEW
              (XH,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,YJKBZ,NEW_ADD,SESSION_ID )
               SELECT
               1,zsxh,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,jkqx,JKQX_HJ,jkqx_hj,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,'0','0',ln_session
               FROM SB_ZSXX
              where SE > 0 AND (SB_TZLX_DM = '0' or SB_TZLX_DM = '3')
                and YZPZXH like lc_pzxh
                and skcsfs_dm = '11'
                and sksx_dm = '11'
                and skzl_dm='10' --add yuxh on 2009-3-20 处理处理正税
                and zsxm_dm = ac_zsxm_dm
                and sssq_q = adt_sssq_q
                and sssq_z = adt_sssq_z
                and nsrsbh = avc_nsrsbh ;
     
     select nvl(min(zsxh),'0') into lc_zsxh  from  tmp_sb_zsxx_new 
                where  SESSION_ID=ln_session
                    and nsrsbh = avc_nsrsbh
                    and sssq_q = adt_sssq_q
                    and sssq_z = adt_sssq_z;
     while  lc_zsxh >'0'
     loop
     
        select KSSL,XSSR,SE,YZPZMXXH,ZSPM_DM into ln_kssl,ln_yssl,ln_ybtse,lc_sbxh,lc_zspm_dm 
           from  tmp_sb_zsxx_new 
           where  zsxh=lc_zsxh;
           
           ln_temp := ln_temp - ln_ybtse;
       if ln_temp < 0 then
          ln_ybtse1 := ln_ybtse + ln_temp; --定额部分
          ln_yssl1 := ln_yssl * (ln_ybtse1/ln_ybtse);
          ln_kssl1 := ln_kssl * (ln_ybtse1/ln_ybtse);
          ln_ybtse := ln_ybtse - ln_ybtse1;  --超定额部分
          ln_yssl := ln_yssl - ln_yssl1;
          ln_kssl := ln_kssl - ln_kssl1;

          ln_temp := 0;
          if ln_ybtse1 > 0 then --若可以拆分，则新插入一条，若刚好不用拆分，则更新原来记录
             li_ret:=P_GET_ZSXH(lc_zsxh_new);
             IF li_ret != 100 THEN
                raise_application_error(-20576, '生成征收序号出错。P_SB_DQDECL' );
             END IF;
             insert into TMP_SB_ZSXX_NEW
              (XH,ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,YJKBZ,NEW_ADD,SESSION_ID )
               SELECT
               1,lc_zsxh_new,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,ln_kssl,ln_yssl,SL,ln_ybtse,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,decode(jkqx,null,null,ldt_jkqx_temp),JKQX_HJ,decode(jkqx,null,null,ldt_jkqx_temp),JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X,'0','1',ln_session
               FROM TMP_SB_ZSXX_NEW
               WHERE ZSXH = lc_zsxh;
               
             update sb_zsxx
                set kssl = ln_kssl1,
                    xssr = ln_yssl1,
                      se = ln_ybtse1
              where ZSXH = lc_zsxh;
          else
              li_state := -1002;
          end if;
       end if;
       --针对超定额未超幅度部分，将缴款期限为分月汇总缴款期限
       if li_state = -1002 then
          update sb_zsxx
            set jkqx     = ldt_jkqx_temp,
                jkqx_znj = ldt_jkqx_temp
          where jkqx is not null
            and ZSXH = lc_zsxh;
       end if;
       li_state := -1000;
       
       select nvl(min(zsxh),'0') into lc_zsxh  from  tmp_sb_zsxx_new 
                 where  session_id=ln_session
                        and nsrsbh = avc_nsrsbh
                        and sssq_q = adt_sssq_q
                        and sssq_z = adt_sssq_z
                        and zsxh >lc_zsxh  ;          
     end loop;
     
     insert into  sb_zsxx
              (ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X)
     select    ZSXH,NSRSBH,SSSQ_Q,SSSQ_Z,ZSXM_DM,ZSPM_DM,SKSX_DM,SKZL_DM,SKCSFS_DM,SB_TZLX_DM,
               QSSX_DM,KSSL,XSSR,SL,SE,YZSKBZ,YZPZXH,YZPZMXXH,YZPZZL_DM,YZPZLRR_DM,YZFSRQ,
               YZYJZBZ,JKQX,JKQX_HJ,JKQX_ZNJ,JKPZXH,JKPZMXXH,PZ_ZL_DM,JKPZLRR_DM,JKFSRQ,
               KPRQ,YSSPHM,HZJKSBZ,HZJKSH,SJSKBZ,SJRQ,SJXHR_DM,SJXHRQ,SJYJZBZ,RKSKBZ,RKRQ,
               RKXHR_DM,RKXHRQ,RKYJZBZ,DJZCLX_DM,HY_DM,LSGX_DM,ZDSY_DM,YSKM_DM,YSFPBL_DM,
               YSFPBL_ZY,YSFPBL_SS,YSFPBL_DS,YSFPBL_XQ,YSFPBL_XZ,YSFPBL_XC,ZSXMFL_DM,ZSDLFS_DM,
               SBFS_DM,ZJFS_DM,ZSFS_DM,SKZFFS_DM,SKGK_DM,JDXZ_DM,ZGSWGY_DM,SKSS_SWJG_DM,
               ZSJG_DM,NSR_SWJG_DM,SWJG_DM,LRRQ,LRR_DM,XGRQ,XGR_DM,CSBZ_S,CSBZ_X  
               from  tmp_sb_zsxx_new  
               where session_id=ln_session
                     and nsrsbh = avc_nsrsbh
                     and sssq_q = adt_sssq_q
                     and sssq_z = adt_sssq_z 
                     and new_add='1' ;
     
   --end add yuxh on 2011-4-6 调整优化性能  
   --------------------------------------------------------------------------
  end if;      --结束 拆分出定额部分 liulh 2007-1-17

/*移至拆分前
   if --((lc_state_de = 'cde' and ldt_sbqx_hzsbqx is not null) or
      lc_state_de = 'cfd' and lc_gtdqde = 'Y' then
      --2007-3-11调帐处理
     ln_temp := ln_qbhdse_bq - ln_qbyjnse_bq - ln_qbjmse_bq;
     if ln_temp < 0 then
        ln_temp := 0;
     end if;
     li_Ret := p_sb_tzcl(avc_nsrsbh,ac_zsxm_dm,adt_sssq_q,adt_sssq_z,ac_pzzl_dm,ln_temp,ldt_jkqx_cur,ldt_jkqx_cur,ac_pzxh);
   end if;
*/
   --开始 未达起征户已达起征点或超幅度，修改缴款期限为当前属期规定的缴款期限 liulh 2007-1-17
   if ac_wdqzd_bz = 'Y' and lc_wdqzdh = 'Y' then
      update sb_sbxx
        set sbqx = ldt_sbqx,
            yqsbqx = ldt_yqsbqx
        where (sbqx is null or sbqx <> ldt_sbqx) and pzxh = ac_pzxh and zsxm_dm=ac_zsxm_dm ;--modify yuxhfjs on 2008-05-19
   elsif ((ac_wdqzd_bz is null or ac_wdqzd_bz = 'N') and lc_wdqzdh = 'Y') then
      --若为分月汇总申报，则申报期限为汇总申报期限，否则为本属期规定的申报期限
      if (ac_pzzl_dm = '10148' or ac_pzzl_dm = '10149') then
        update sb_sbxx
        set sbqx = ldt_sbqx_hzsbqx,
            yqsbqx = ldt_yqsbqx_hzsbqx
        where (sbqx is null or sbqx <> ldt_sbqx_hzsbqx) and pzxh = ac_pzxh
              and zsxm_dm=ac_zsxm_dm ;--modify yuxhfjs on 2008-05-19
      else
        update sb_sbxx
        set sbqx = ldt_sbqx_cur,
            yqsbqx = ldt_yqsbqx_cur
        where (sbqx is null or sbqx <> ldt_sbqx_cur) and pzxh = ac_pzxh and zsxm_dm=ac_zsxm_dm;--modify yuxhfjs on 2008-05-19
      end if;

      update sb_zsxx a
           set a.jkqx = ldt_jkqx_cur,a.jkqx_znj = decode(ldt_hjjkqx_cur,null,ldt_jkqx_cur,ldt_hjjkqx_cur),a.jkqx_hj = ldt_hjjkqx_cur
         where a.jkqx is not null
           and a.sssq_q = adt_sssq_q
           and a.sssq_z = adt_sssq_z
           and a.yzpzxh = ac_pzxh
           and a.zsxm_dm=ac_zsxm_dm --modify yuxhfjs on 2008-05-19
           and a.skzl_dm<>'20'; --modify yuxh on 2009-3-4 排除滞纳金
   --结束 未达起征户已达起征点，缴款期限为当前属期规定的缴款期限 liulh 2007-1-17
   elsif lc_state_de = 'cfd' and (lc_bcsb = 'Y' or ac_pzzl_dm = '10148' or  ac_pzzl_dm = '10149') and lc_gtdqde = 'Y' then
     --批量处理缴款期限 开始 liulh 2007-1-17
      --针对超幅度缴款期限为当前属期规定的缴款期限
      update sb_zsxx a
         set a.jkqx = ldt_jkqx_cur,a.jkqx_znj = decode(ldt_hjjkqx_cur,null,ldt_jkqx_cur,ldt_hjjkqx_cur),a.jkqx_hj = ldt_hjjkqx_cur
       where --a.jkqx is not null
         a.jkqx = ldt_sbqx_hzsbqx
        and (a.SB_TZLX_DM = '0' or a.SB_TZLX_DM = '3')
        and (a.yzpzzl_dm like lc_pzzl_dm_1 or a.yzpzzl_dm like lc_pzzl_dm_2)
        and a.skcsfs_dm = '11'
        and a.sksx_dm = '11'
        and a.zsxm_dm = ac_zsxm_dm
        and a.sssq_q = adt_sssq_q
        and a.sssq_z = adt_sssq_z
        and a.nsrsbh = avc_nsrsbh;
   end if;
  --批量处理缴款期限 结束 liulh 2007-1-17
  --结束未达起征户已达起征点或超幅度，修改缴款期限为当前属期规定的缴款期限 liulh 2007-1-17
end if;
--结束 插入操作处理
--************************************************************************
return li_return;
EXCEPTION
  WHEN OTHERS THEN
  begin
    raise_application_error(-20580, '调用过程P_SB_DQDECL出错，'||sqlerrm);
  end;
END;
/


