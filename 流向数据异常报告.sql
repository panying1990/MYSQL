-- 流向异常分析报告-项目一
drop table if exists lx_abnormal_report_liansuo;
create table lx_abnormal_report_liansuo(
dist_first varchar(50) comment '一级战区',
dist_second varchar(50) comment '二级战区',
dist_name varchar(255) comment '客户名称',
term_name varchar(255) comment '终端名称',
prod_type_spec varchar(50) comment '产品品规',
prod_count int comment '产品数量(盒)',
product_amount int comment '产品数量(盒)'
)comment = '连锁门店异常报告';
insert into lx_abnormal_report_liansuo(
dist_first,
dist_second,
dist_name,
term_name,
prod_type_spec,
prod_count,
product_amount
)
SELECT 
 s1.dist_first,
 s1.dist_second,
 s1.dist_name,
 s1.term_name,
 s1.prod_type_spec,
 s1.prod_count,
 s2.product_amount
FROM
	lx_sale_summary AS s1,
	(
SELECT
	tt.dist_first,
	tt.dist_second,
	tt.dist_name,
	tt.term_name,
	sum( tt.prod_count ) AS product_amount 
FROM
	(
SELECT
	tt.dist_first,
	tt.dist_second,
	tt.dist_name,
	tt.term_name,
	tt.term_type_std,
	tt.prod_count 
FROM
	lx_sale_summary tt 
WHERE
	tt.dist_type = '连锁总部' 
	AND tt.term_type_std = '连锁药店' 
	AND tt.term_name NOT REGEXP '叮当智慧' 
	) tt 
GROUP BY
	tt.dist_first,
	tt.dist_second,
	tt.dist_name,
	tt.term_name 
HAVING
	product_amount > 20
	) AS s2
where s1.term_name = s2.term_name;
	

	
-- 项目二：异常增加的客户数量
drop table if exists lx_abnormal_report_cust;
create table lx_abnormal_report_cust(
dist_first varchar(255) comment '一级战区',
dist_second varchar(255) comment '二级战区',
dist_name varchar(255) comment '客户名称',
dist_type varchar(255) comment '客户类型',
up_cycle varchar(50) comment "上传周期",
prod_sys_type varchar(50) comment "标准品类名", 
prod_count int comment '产品数量(盒)'
)comment "异常流向-客户";
insert into lx_abnormal_report_cust
(
dist_first,
dist_second,
dist_name,
dist_type,
up_cycle,
prod_sys_type,
prod_count
)
SELECT
 get_first(t.org_code_dist) as first_dis,
 get_second(t.org_code_dist) as second_dis,
 t.dist_name as dist_name,
 t.dist_type as dist_type,
 t.up_cycle as up_cycle,
 t.prod_sys_type as prod_sys_type,
 sum(t.prod_count) as prod_count
FROM
(SELECT
  (SELECT org_name_all FROM auth_organization_t WHERE org_id = b.org_code AND org_name_all not REGEXP '不合作')   AS org_code_dist,
  t.up_cycle, 
	t.cust_id,
	b.dist_name,
	( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = b.dist_type ) AS dist_type,
	( SELECT func_name FROM sys_code_t WHERE model_code = '296' AND func_code = d.prod_sys_type ) AS prod_sys_type,
	t.prod_count
FROM
	sale_template_t t
LEFT JOIN prod_subside_t e ON t.prod_subside_id = e.prod_subside_id	
LEFT JOIN product_info_t d ON d.id = e.prod_template_id,
cust_info_t b,
up_load_main c
WHERE
b.id = t.cust_id
AND c.up_id = t.up_id
AND c.deal_flag = '0'
AND
	DATE_FORMAT( CONCAT( t.up_cycle, '-01' ), "%Y-%m" ) BETWEEN DATE_FORMAT( DATE_SUB( CURRENT_DATE, INTERVAL 7 MONTH ), '%Y-%m' ) AND DATE_FORMAT(DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), '%Y-%m'))t
	INNER JOIN(
	SELECT
	 t.dist_name,
	 sum(case when t.up_cycle = DATE_FORMAT(DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), '%Y-%m') then t.prod_count else 0 end) as current_count,
	 round(avg(case when t.up_cycle = DATE_FORMAT(DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), '%Y-%m') then 0 else t.prod_count end),1) as before_count,
	 abs(round(sum(case when t.up_cycle = DATE_FORMAT(DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), '%Y-%m') then t.prod_count else 0 end)-avg(case when t.up_cycle = DATE_FORMAT(DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), '%Y-%m') then 0 else t.prod_count end),1))as interval_count
	FROM
	(SELECT
  (SELECT org_name_all FROM auth_organization_t WHERE org_id = b.org_code AND org_name_all not REGEXP '不合作')   AS org_code_dist,
  t.up_cycle, 
	t.cust_id,
	b.dist_name,
	( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = b.dist_type ) AS dist_type,
	( SELECT func_name FROM sys_code_t WHERE model_code = '296' AND func_code = d.prod_sys_type ) AS prod_sys_type,
	t.prod_count
FROM
	sale_template_t t
LEFT JOIN prod_subside_t e ON t.prod_subside_id = e.prod_subside_id	
LEFT JOIN product_info_t d ON d.id = e.prod_template_id,
cust_info_t b,
up_load_main c
WHERE
b.id = t.cust_id
AND c.up_id = t.up_id
AND c.deal_flag = '0'
AND
	DATE_FORMAT( CONCAT( t.up_cycle, '-01' ), "%Y-%m" ) BETWEEN DATE_FORMAT( DATE_SUB( CURRENT_DATE, INTERVAL 7 MONTH ), '%Y-%m' ) AND   DATE_FORMAT(DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), '%Y-%m'))t
	GROUP BY
	t.dist_name
	ORDER BY 
	 interval_count desc
	 LIMIT 50
	)aa on aa.dist_name = t.dist_name
	GROUP BY
	first_dis,
	second_dis,
  dist_name,
	dist_type,
  up_cycle,
 prod_sys_type
 HAVING
  first_dis regexp '[东北南全]';

	

		
	-- 流向异常分析报告-项目三
drop table if exists lx_abnormal_report_validity;
create table lx_abnormal_report_validity
(
first_dis varchar(50) comment "东南北部战区",
second_dis varchar(50) comment "二级战区,如山东战区等",
third_dis varchar(50) comment "三级战区,如鲁东战区,目前作为最小组织单位",
dist_name varchar(255) comment "客户名称",
dist_type varchar(50) comment "客户类型",
prod_sys_type varchar(50) comment "产品品类",
prod_spec_p varchar(50) comment "产品规格的类型",
prod_batch varchar(50) comment "产品批号",
prod_validity varchar(50) comment "产品效期相关信息",
prod_count int comment "产品产量"
)comment="库存效期表";
INSERT INTO lx_abnormal_report_validity
(
first_dis,
second_dis,
third_dis,
dist_name,
dist_type,
prod_sys_type,
prod_spec_p,
prod_batch,
prod_validity,
prod_count
)SELECT
 get_first(t.org_code_dist) as first_dis,
 get_second(t.org_code_dist) as second_dis,
 get_third(t.org_code_dist) as third_dis,
 t.dist_name,
 t.dist_type,
 t.prod_sys_type,
 t.prod_spec_p,
 t.prod_batch,
 get_prod_validity(t.prod_sys_type,get_lefttime(t.prod_sys_type,t.prod_batch)) as prod_validity,
 t.prod_count
from
(SELECT
	( SELECT func_name FROM sys_code_t WHERE model_code = '296' AND func_code = d.prod_sys_type ) prod_sys_type,
	b.dist_name,
	( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = b.dist_type ) dist_type,
	( SELECT org_name_all FROM auth_organization_t WHERE org_id = b.org_code ) AS org_code_dist,
	stock_template_t.cust_id,
	stock_template_t.up_cycle,
	stock_template_t.stock_date,
	stock_template_t.stock_type,
	stock_template_t.prod_batch,
	stock_template_t.prod_count,
	stock_template_t.prod_subside_id,
	d.prod_spec as prod_spec_p,
	c.create_date
FROM
	stock_template_t
	LEFT JOIN prod_subside_t e ON stock_template_t.prod_subside_id = e.prod_subside_id
	LEFT JOIN term_subside_t f ON stock_template_t.term_subside_id = f.term_subside_id
	LEFT JOIN product_info_t d ON d.id = e.prod_template_id
	LEFT JOIN term_info_t g ON g.id = f.term_template_id
	LEFT JOIN cust_info_t h ON h.id = f.term_template_id
	-- 获得最近一次本次上传数据中，客户最后一次上传数据
	LEFT JOIN (
	SELECT
	MAX( ss.date ) AS date,
	ss.cust_id 
FROM
	(
SELECT
	ABS( DATEDIFF( DATE_FORMAT( st.stock_date, '%Y-%m-%d' ), LAST_DAY( CONCAT( up_cycle, '-01' ) ) ) ) AS math,
	st.stock_date AS date,
	st.cust_id 
FROM
	stock_template_t st 
WHERE
	1 = 1 
	AND st.up_cycle =DATE_FORMAT(DATE_SUB(CURRENT_DATE,interval 1 month),"%Y-%m")
GROUP BY
	st.stock_date,
	st.cust_id 
	) ss
	INNER JOIN (
SELECT
	min( ABS( DATEDIFF( DATE_FORMAT( st.stock_date, '%Y-%m-%d' ), LAST_DAY( CONCAT( up_cycle, '-01' ) ) ) ) ) AS math,
	st.cust_id 
FROM
	stock_template_t st 
WHERE
	1 = 1 
	AND st.up_cycle = DATE_FORMAT(DATE_SUB(CURRENT_DATE,interval 1 month),"%Y-%m")
GROUP BY
	cust_id 
	) aabb ON aabb.cust_id = ss.cust_id 
	AND ss.math = aabb.math 
WHERE
	1 = 1 
GROUP BY
	ss.cust_id
	) bs ON bs.cust_id = stock_template_t.cust_id 
	AND bs.date = stock_template_t.stock_date
LEFT JOIN (
SELECT
	MAX( st.stock_date ) stock_date,
	cust_id 
FROM
	stock_template_t st 
WHERE
	st.up_cycle = DATE_FORMAT( DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), "%Y-%m" ) 
GROUP BY
	st.cust_id 
	) gg ON stock_template_t.cust_id = gg.cust_id,
	cust_info_t b,
	up_load_main c 
WHERE
	b.id = stock_template_t.cust_id 
	AND c.up_id = stock_template_t.up_id 
	AND c.deal_flag = '0' 
	AND (
	(
	b.connection_type = '1' 
	AND stock_template_t.stock_date = (
IF
	(DATE_FORMAT( curdate( ), '%Y-%m' ) = DATE_FORMAT( DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), "%Y-%m" ),
	DATE_FORMAT( date_sub( curdate( ), INTERVAL 2 DAY ), '%Y-%m-%d' ),( bs.date ) ) 
	) 
	) 
	OR ( b.connection_type != '1' AND stock_template_t.stock_date = gg.stock_date ) 
	) 
	AND stock_template_t.up_cycle = DATE_FORMAT( DATE_SUB(CURRENT_DATE,INTERVAL 1 MONTH), '%Y-%m' )
	AND FIND_IN_SET( b.org_code, ( SELECT org_code FROM ( SELECT getOrgChildLst ( 1 ) AS org_code FROM DUAL ) AS org ) ))t
	where t.prod_count>0
	
	
	
	
	
-- 清理产品批号的初步清理
CREATE DEFINER=`root`@`%` FUNCTION `get_lefttime`(prod_sys_type varchar(50),prod_batch VARCHAR (150)) RETURNS varchar(50) CHARSET utf8
begin
DECLARE out_char VARCHAR(20) DEFAULT '';
declare lift_time varchar(50) default null;
IF prod_batch REGEXP 'AB_n' then
 SET  out_char='批号异常';
ELSEIF prod_batch is null  then
 set out_char = '批号异常';
ELSEIF (prod_sys_type = "常润茶" and length(prod_batch)=8)THEN 
 SET out_char = prod_batch;
ELSEIF (prod_sys_type = "常菁茶" and length(prod_batch)=8)THEN 
 SET out_char = prod_batch;
ELSEIF (prod_sys_type = "纤纤茶" and length(prod_batch)=8)THEN 
 SET out_char = prod_batch;
ELSEIF (prod_sys_type = "来利奥利司他" and length(prod_batch)=8)THEN 
 SET out_char = prod_batch;
ELSEIF (prod_sys_type = "开塞露" and length(prod_batch)=6)THEN 
 SET out_char = prod_batch;
else set out_char = '批号异常';
END IF;
case 
when (prod_sys_type = "常润茶" and (MID(out_char,3,2)*1 between 14 and 20))then set lift_time= DATE_FORMAT(CONCAT(MID(out_char,3,2),"-",MID(out_char,5,2),"-01"),"%Y-%m-%d");
when (prod_sys_type = "常菁茶" and (MID(out_char,3,2)*1 between 14 and 20)) then set lift_time= DATE_FORMAT(CONCAT(MID(out_char,3,2),"-",MID(out_char,5,2),"-01"),"%Y-%m-%d");
when (prod_sys_type = "纤纤茶" and (MID(out_char,3,2)*1 between 14 and 20)) then set lift_time= DATE_FORMAT(CONCAT(MID(out_char,3,2),"-",MID(out_char,5,2),"-01"),"%Y-%m-%d");
when (prod_sys_type = "来利奥利司他" and (MID(out_char,2,2)*1 between 14 and 20))  then set lift_time= DATE_FORMAT(CONCAT(MID(out_char,2,2),"-",MID(out_char,4,2),"-01"),"%Y-%m-%d");
when (prod_sys_type = "开塞露" and  (MID(out_char,1,2)*1 between 14 and 20))  then set lift_time= DATE_FORMAT(CONCAT(MID(out_char,1,2),"-",MID(out_char,3,2),"-01"),"%Y-%m-%d");
else set lift_time = null;
		 set out_char = '批号异常';
end case;
IF lift_time is null then
return out_char;
else RETURN lift_time;
end if;
END


 -- 根据批号获得该批次数据大概效期
 create function get_prod_validity (prod_sys_type varchar(50),left_time varchar(50)) return int
 begin
 declare left_month varchar(50) default "";
 case 
 when left_time = "批号异常" then set left_month = "批号异常";
 when (prod_sys_type = "常润茶" and left_time <> '批号异常') then set left_month =  ROUND(18-ABS(ROUND(DATEDIFF(LAST_DAY(date_sub(current_date, interval 1 month)),left_time)/30,0)),0);
 when (prod_sys_type = "常菁茶" and left_time <> '批号异常') then set left_month =  ROUND(20-ABS(ROUND(DATEDIFF(LAST_DAY(date_sub(current_date, interval 1 month)),left_time)/30,0)),0);
 when (prod_sys_type = "纤纤茶" and left_time <> '批号异常') then set left_month =  ROUND(24-ABS(ROUND(DATEDIFF(LAST_DAY(date_sub(current_date, interval 1 month)),left_time)/30,0)),0);
 when (prod_sys_type = "来利奥利司他" and left_time <> '批号异常') then set left_month =  ROUND(36-ABS(ROUND(DATEDIFF(LAST_DAY(date_sub(current_date, interval 1 month)),left_time)/30,0)),0);
 when (prod_sys_type = "开塞露" and left_time <> '批号异常') then set left_month =  ROUND(36-ABS(ROUND(DATEDIFF(LAST_DAY(date_sub(current_date, interval 1 month)),left_time)/30,0)),0);
 ELSE left_month = "批号异常";
 END CASE;
 END;
 
 
 
 
 --- 创建库存消息基础表
 drop table if exists lx_abnormal_report_validity;
create table lx_abnormal_report_validity
(
first_dis varchar(50) comment "东南北部战区",
second_dis varchar(50) comment "二级战区,如山东战区等",
third_dis varchar(50) comment "三级战区,如鲁东战区,目前作为最小组织单位",
dist_name varchar(255) comment "客户名称",
dist_type varchar(50) comment "客户类型",
prod_sys_type varchar(50) comment "产品品类",
prod_spec_p varchar(50) comment "产品规格的类型",
prod_batch varchar(50) comment "产品批号",
prod_validity varchar(50) comment "产品效期相关信息",
prod_count int comment "产品产量"
)comment="库存效期表";
INSERT INTO lx_abnormal_report_validity
(
first_dis,
second_dis,
third_dis,
dist_name,
dist_type,
prod_sys_type,
prod_spec_p,
prod_batch,
prod_validity,
prod_count
)SELECT
 get_first(t.org_code_dist) as first_dis,
 get_second(t.org_code_dist) as second_dis,
 get_third(t.org_code_dist) as third_dis,
 t.dist_name,
 t.dist_type,
 t.prod_sys_type,
 t.prod_spec_p,
 t.prod_batch,
 get_prod_validity(t.prod_sys_type,get_lefttime(t.prod_sys_type,t.prod_batch)) as prod_validity,
 t.prod_count
from
(SELECT
	( SELECT func_name FROM sys_code_t WHERE model_code = '296' AND func_code = d.prod_sys_type ) prod_sys_type,
	b.dist_name,
	( SELECT func_name FROM sys_code_t WHERE model_code = '540' AND func_code = b.dist_type ) dist_type,
	( SELECT org_name_all FROM auth_organization_t WHERE org_id = b.org_code ) AS org_code_dist,
	stock_template_t.cust_id,
	stock_template_t.up_cycle,
	stock_template_t.stock_date,
	stock_template_t.stock_type,
	stock_template_t.prod_batch,
	stock_template_t.prod_count,
	stock_template_t.prod_subside_id,
	d.prod_spec as prod_spec_p,
	c.create_date
FROM
	stock_template_t
	LEFT JOIN prod_subside_t e ON stock_template_t.prod_subside_id = e.prod_subside_id
	LEFT JOIN term_subside_t f ON stock_template_t.term_subside_id = f.term_subside_id
	LEFT JOIN product_info_t d ON d.id = e.prod_template_id
	LEFT JOIN term_info_t g ON g.id = f.term_template_id
	LEFT JOIN cust_info_t h ON h.id = f.term_template_id
	-- 获得最近一次本次上传数据中，客户最后一次上传数据
	LEFT JOIN (
	SELECT
	MAX( ss.date ) AS date,
	ss.cust_id 
FROM
	(
SELECT
	ABS( DATEDIFF( DATE_FORMAT( st.stock_date, '%Y-%m-%d' ), LAST_DAY( CONCAT( up_cycle, '-01' ) ) ) ) AS math,
	st.stock_date AS date,
	st.cust_id 
FROM
	stock_template_t st 
WHERE
	1 = 1 
	AND st.up_cycle =DATE_FORMAT(DATE_SUB(CURRENT_DATE,interval 1 month),"%Y-%m")
GROUP BY
	st.stock_date,
	st.cust_id 
	) ss
	INNER JOIN (
SELECT
	min( ABS( DATEDIFF( DATE_FORMAT( st.stock_date, '%Y-%m-%d' ), LAST_DAY( CONCAT( up_cycle, '-01' ) ) ) ) ) AS math,
	st.cust_id 
FROM
	stock_template_t st 
WHERE
	1 = 1 
	AND st.up_cycle = DATE_FORMAT(DATE_SUB(CURRENT_DATE,interval 1 month),"%Y-%m")
GROUP BY
	cust_id 
	) aabb ON aabb.cust_id = ss.cust_id 
	AND ss.math = aabb.math 
WHERE
	1 = 1 
GROUP BY
	ss.cust_id
	) bs ON bs.cust_id = stock_template_t.cust_id 
	AND bs.date = stock_template_t.stock_date
LEFT JOIN (
SELECT
	MAX( st.stock_date ) stock_date,
	cust_id 
FROM
	stock_template_t st 
WHERE
	st.up_cycle = DATE_FORMAT( DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), "%Y-%m" ) 
GROUP BY
	st.cust_id 
	) gg ON stock_template_t.cust_id = gg.cust_id,
	cust_info_t b,
	up_load_main c 
WHERE
	b.id = stock_template_t.cust_id 
	AND c.up_id = stock_template_t.up_id 
	AND c.deal_flag = '0' 
	AND (
	(
	b.connection_type = '1' 
	AND stock_template_t.stock_date = (
IF
	(DATE_FORMAT( curdate( ), '%Y-%m' ) = DATE_FORMAT( DATE_SUB( CURRENT_DATE, INTERVAL 1 MONTH ), "%Y-%m" ),
	DATE_FORMAT( date_sub( curdate( ), INTERVAL 2 DAY ), '%Y-%m-%d' ),( bs.date ) ) 
	) 
	) 
	OR ( b.connection_type != '1' AND stock_template_t.stock_date = gg.stock_date ) 
	) 
	AND stock_template_t.up_cycle = DATE_FORMAT( DATE_SUB(CURRENT_DATE,INTERVAL 1 MONTH), '%Y-%m' )
	AND FIND_IN_SET( b.org_code, ( SELECT org_code FROM ( SELECT getOrgChildLst ( 1 ) AS org_code FROM DUAL ) AS org ) ))t
	where t.prod_count>0
	
	
	
	
	
	
	
	
 
	
	
	
