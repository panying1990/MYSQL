-- 流向异常分析报告-项目一
drop table if exists lx_abnormal_report_liansuo;
create table lx_abnormal_report_liansuo(
first_dis varchar(255) comment '一级战区',
second_dis varchar(255) comment '二级战区',
client_name varchar(255) comment '客户名称',
term_name varchar(255) comment '终端名称',
product_amount int comment '产品数量(盒)'
)comment = '连锁门店异常报告';
insert into lx_abnormal_report_liansuo(
first_dis,
second_dis,
client_name,
term_name,
product_amount
)
SELECT
	tt.一级战区,
	tt.二级战区,
	tt.客户名称,
	tt.终端名称,
	sum( tt.产品数量 ) AS 数量 
FROM
( SELECT tt.一级战区, tt.二级战区, tt.客户名称, tt.终端名称, tt.产品数量 FROM `DB00_销售原始表处理_19年3月` tt WHERE tt.客户类型 = '连锁总部' and tt.`终端类型人工`='连锁药店' and tt.`客户名称`not REGEXP '叮当智慧') tt
GROUP BY
	一级战区,
	二级战区,
	客户名称,
	终端名称
HAVING
  数量>60
ORDER BY
	一级战区,
	二级战区,
	客户名称,
	终端名称,
	数量 DESC;
	
	
	-- 流向异常分析报告-项目三
drop table if exists lx_abnormal_report_zhenliao;
create table lx_abnormal_report_zhenliao(
first_dis varchar(255) comment '一级战区',
second_dis varchar(255) comment '二级战区',
client_name varchar(255) comment '客户名称',
term_name varchar(255) comment '终端名称',
product_amount int comment '产品数量(盒)'
)comment = '诊疗异常报告';
insert into lx_abnormal_report_zhenliao(
first_dis,
second_dis,
client_name,
term_name,
product_amount
)
SELECT
	tt.一级战区,
	tt.二级战区,
	tt.客户名称,
	tt.终端名称,
	sum( tt.产品数量 ) AS 数量 
FROM
( SELECT tt.一级战区, tt.二级战区, tt.客户名称, tt.终端名称, tt.产品数量 FROM `DB00_销售原始表处理_19年3月` tt WHERE tt.终端类型人工 = '诊疗' ) tt
GROUP BY
	一级战区,
	二级战区,
	客户名称,
	终端名称
HAVING
  数量>30
ORDER BY
	一级战区,
	二级战区,
	客户名称,
	终端名称,
	数量 DESC;
	
	
	-----
	DROP TABLE
IF EXISTS lx_abnormal_report_custbase;
CREATE TABLE lx_abnormal_report_custbase AS
SELECT
tt.*
FROM
(
SELECT
	( SELECT 
	ORG_NAME_ALL FROM auth_organization_t WHERE org_id = b.org_code ) AS 客户所属组织,--  客户所属组织
	b.eas AS `EAS编码`,    -- EAS编码
	b.dist_code AS 客户编码,--  客户编码
	b.dist_name AS 客户名称,--  客户名称
	b.area_state AS 客户所在省份,--  客户所在省份
	b.area_city AS 客户所在城市,--  客户所在城市
	( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = b.dist_type ) AS 客户类型,--  客户类型
	( SELECT func_name FROM sys_code_t WHERE model_code = '680' AND func_code = b.cust_flag ) AS 客户标志,--  客户标志
	sale_template_t.up_cycle AS 上传周期,--  上传周期
	sale_template_t.term_name AS 终端名称,--  终端名称
	( SELECT ORG_NAME_ALL FROM auth_organization_t WHERE org_id = f.org_code ) AS 终端所属组织,--  终端所属组织（标准）
	( SELECT func_name FROM sys_code_t WHERE model_code = '600' AND func_code = f.match_type ) AS 主数据类型,-- 主数据类型
	CASE
			f.match_type 
			WHEN '2' THEN
			( SELECT func_name FROM sys_code_t WHERE model_code = '295' AND func_code = g.term_type ) 
			WHEN '1' THEN
			( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = h.dist_type ) ELSE '' 
		END AS 终端类型,--  终端类型(标准)
		f.term_type AS 终端类型人工,--  终端类型(人工)
	CASE
			f.match_type 
			WHEN '2' THEN
			g.term_name 
			WHEN '1' THEN
			h.dist_name ELSE '' 
		END AS 终端标准名称,--  终端名称(标准)
	CASE
			f.match_type 
			WHEN '2' THEN
			g.area_state 
			WHEN '1' THEN
			h.area_state ELSE '' 
		END AS 终端所在省份,--  行政省（标准）
	CASE
			f.match_type 
			WHEN '2' THEN
			g.area_city 
			WHEN '1' THEN
			h.area_city ELSE '' 
		END AS 终端所在城市,--  行政市
		sale_template_t.prod_batch AS 产品批号,--  产品批号
		d.prod_code AS 产品编码,--  产品编码（标准）
		( SELECT func_name FROM sys_code_t WHERE model_code = '296' AND func_code = d.prod_sys_type ) AS 产品品类,--  产品品类（标准）
		d.prod_spec AS 产品规格,--  产品规格（标准）
		( SELECT func_name FROM sys_code_t WHERE model_code = '570' AND func_code = d.prod_unit ) AS 产品单位,--  产品单位
		sale_template_t.sale_date AS 销售日期,
		ROUND( sale_template_t.prod_count, 0 ) AS 产品数量,--  产品数量
		ROUND( sale_template_t.prod_count * d.prod_price, 0 ) AS 计算金额 --  计算金额
	FROM
		sale_template_t
		LEFT JOIN prod_subside_t e ON sale_template_t.prod_subside_id = e.prod_subside_id
		LEFT JOIN term_subside_t f ON sale_template_t.term_subside_id = f.term_subside_id
		LEFT JOIN product_info_t d ON d.id = e.prod_template_id
		LEFT JOIN term_info_t g ON g.id = f.term_template_id
		LEFT JOIN cust_info_t h ON h.id = f.term_template_id,
		cust_info_t b,
		up_load_main c 
	WHERE
		b.id = sale_template_t.cust_id 
		AND c.up_id = sale_template_t.up_id 
		AND c.deal_flag = '0' 
-- 		AND sale_template_t.up_cycle IN ( '2019-01', '2019-02' ) -- 月份
AND  sale_template_t.up_cycle IN ('2018-09','2018-10','2018-11','2018-12',
'2019-01','2019-02','2019-03')  -- 月份
)  tt;
	
-- 异常流向-项目二
drop table if exists lx_abnormal_report_cust;
create table lx_abnormal_report_cust as
	select
	t.*
	from
(select
	t.first_dis,
	t.second_dis,
	t.cust_name,
	sum(_2018_09) as _2018_09,
  sum(_2018_10) as _2018_10, 
  sum(_2018_11) as _2018_11,
	sum(_2018_12) as _2018_12,
	sum(_2019_01) as _2019_01,
	sum(_2019_02) as _2019_02,
	sum(_2019_03) as current_month,
	round(sum(_2018_09+_2018_10+_2018_11+_2018_12+_2019_01+_2019_02)/6,0) as moving_avg,
	round(sum(_2019_03)-sum(_2018_09+_2018_10+_2018_11+_2018_12+_2019_01+_2019_02)/6,0) as absolute_sales
from
(select
	t.first_dis,
	t.second_dis,
	t.cust_name,
	case when t.up_cycle = '2018-09' then t.product_count else 0 end as _2018_09,
  case when t.up_cycle = '2018-10' then t.product_count else 0 end as _2018_10, 
  case when t.up_cycle = '2018-11' then t.product_count else 0 end as _2018_11,
	case when t.up_cycle = '2018-12' then t.product_count else 0 end as _2018_12,
	case when t.up_cycle = '2019-01' then t.product_count else 0 end as _2019_01,
	case when t.up_cycle = '2019-02' then t.product_count else 0 end as _2019_02,
	case when t.up_cycle = '2019-03' then t.product_count else 0 end as _2019_03
from
(select
  SUBSTRING_INDEX(SUBSTRING_INDEX(t.`客户所属组织`, '-', 2),'-',-1) as first_dis,
	SUBSTRING_INDEX(SUBSTRING_INDEX(t.`客户所属组织`, '-', 3),'-',-1) as second_dis,
	t.`客户名称` as cust_name,
	t.上传周期 as up_cycle,
  t.产品数量 as product_count
from
 lx_abnormal_report_custbase t
 where
 t.`客户类型` IN('T1','T2','连锁总部')
)t
where 
 t.second_dis not REGEXP '不合作'
)t
GROUP BY
	t.first_dis,
	t.second_dis,
	t.cust_name)t
	where
	abs((current_month-moving_avg)/moving_avg*100)>40
	and
 current_month>200
 ORDER BY
  absolute_sales desc
	limit 30;
	
