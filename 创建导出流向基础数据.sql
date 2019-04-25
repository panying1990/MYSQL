-- 创建导出流向数据明细表
set @interval_day = 3;
use agilesc_report;
drop table if exists lx_basedata_sale;
create table lx_basedata_sale(
dist_name varchar(255) comment "上传客户名称",
org_code_dist varchar(255) comment "客户所属组织",
eas varchar(50) comment"EAS编码",
dist_type varchar(50) comment "客户类型",
up_cycle varchar(50) comment "上传周期",
term_name varchar(255) comment "终端名称",
org_code varchar(255) comment "终端所属组织",
match_type_p varchar(50) comment "主数据类型(标准)",
term_name_p varchar(255) comment "终端名称(标准)",
term_type_p varchar(50) comment "终端类型(标准)",
term_type_manual varchar(50) comment "终端类型(人工)",
prod_count int comment "产品数量",
prod_sys_type varchar(50) comment "产品品类(标准)",
prod_spec_p varchar(50) comment "产品规格(标准)",
prod_price_p float comment "产品单价")comment="销售流向基础表";
insert into lx_basedata_sale(
dist_name,
org_code_dist,
eas,
dist_type,
up_cycle,
term_name,
org_code,
match_type_p,
term_name_p,
term_type_p,
term_type_manual,
prod_count,
prod_sys_type,
prod_spec_p,
prod_price_p)
select
  t.dist_name,
-- 	t.cust_name,
	t.org_code_dist,
-- 	SUBSTRING_INDEX(SUBSTRING_INDEX(t.org_code_dist,'-',2),'-',-1) as org_code_dist_second,
--   SUBSTRING_INDEX(SUBSTRING_INDEX(t.org_code_dist,'-',4),'-',-1) as org_code_dist_third,
	t.eas,
	t.dist_type,
	t.up_cycle,
	t.term_name,
	t.org_code,
	t.match_type_p,
	t.term_name_p,
	t.term_type_manual,
	t.term_type_p,
	t.prod_count,
	t.prod_sys_type,
	t.prod_spec_p,
	t.prod_price_p
from
(SELECT
	b.area_state AS area_state_cust,
	( SELECT func_name FROM sys_code_t WHERE model_code = '852' AND func_code = c.zl_flag ) AS collection_type,
	( SELECT func_name FROM sys_code_t WHERE model_code = '852' AND func_code = b.connection_type ) AS connection_type_cust,
	b.dist_name,
	b.cust_name,
	( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = b.dist_type ) AS dist_type,
	( SELECT org_name_all FROM auth_organization_t WHERE org_id = b.org_code ) AS org_code_dist,
	d.second_price,
	d.third_price,
	( SELECT func_name FROM sys_code_t WHERE model_code = '570' AND func_code = d.prod_unit ) AS prod_unit_p,
	( SELECT org_name_all FROM auth_organization_t WHERE org_id = f.org_code ) AS org_code,
	a.id,
	a.up_id,
	a.cust_id,
	a.up_cycle,
	a.or_nbr,
	a.or_type,
	a.term_code,
	a.term_name,
	a.term_address,
	a.prod_code,
	a.prod_name,
	a.prod_spec,
	a.prod_batch,
	a.prod_unit,
	a.valid_date,
	a.prod_count,
	a.prod_price,
	a.prod_money,
	a.sale_date,
	a.validate_result,
	a.term_subside_id,
	a.prod_subside_id,
	c.create_date,
  d.prod_spec as prod_spec_p,
	CASE f.match_type when '2' then g.term_name WHEN '1'  THEN h.dist_name else '' end as term_name_p,
	CASE f.match_type WHEN '2' THEN ( SELECT func_name FROM sys_code_t WHERE model_code = '295' AND func_code = g.term_type)          WHEN '1' THEN ( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = h.dist_type ) ELSE '' END  as term_type_p,
  CASE f.match_type WHEN '2' THEN g.area_state WHEN '1' THEN h.area_state ELSE '' END as area_state,
  CASE f.match_type WHEN '2' THEN g.area_city  WHEN '1' THEN h.area_city ELSE '' END area_city,
  CASE f.match_type WHEN '2' THEN g.trem_address WHEN '1' THEN h.dist_address ELSE '' END term_address_p,
	( SELECT func_name FROM sys_code_t WHERE model_code = '296' AND func_code = d.prod_sys_type ) AS prod_sys_type,
	d.prod_price AS prod_price_p,
	 format(	a.prod_count*d.prod_price,2) as prod_money_p,
(select func_name from sys_code_t where model_code='600' and func_code=f.match_type) as match_type_p,
b.eas,
f.term_type as term_type_manual
FROM
	(select * from sale_template_t where sale_template_t.up_cycle = DATE_FORMAT(DATE_SUB(CURRENT_DATE,INTERVAL @interval_day DAY),'%Y-%m')) a
	LEFT JOIN prod_subside_t e ON a.prod_subside_id = e.prod_subside_id
	LEFT JOIN term_subside_t f ON a.term_subside_id = f.term_subside_id
	LEFT JOIN product_info_t d ON d.id = e.prod_template_id -- 该部分与基础查询不同
	LEFT JOIN term_info_t g on g.id=f.term_template_id
	LEFT JOIN cust_info_t h on h.id=f.term_template_id,
	cust_info_t b,
	up_load_main c
	WHERE
	b.id = a.cust_id
	AND c.up_id = a.up_id
  AND c.deal_flag = '0' )t

