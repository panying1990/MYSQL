-- 创建系统数据字典

use information_schema;
select
 information_schema.`COLUMNS`.TABLE_NAME as 表名称,
 information_schema.`COLUMNS`.COLUMN_NAME as 字段名,
 information_schema.`COLUMNS`.COLUMN_COMMENT as 字段注释,
 information_schema.`COLUMNS`.DATA_TYPE  as 数据类型,
 information_schema.`COLUMNS`.COLUMN_KEY as 主外键
FROM 
 information_schema.`COLUMNS` 
 where
   information_schema.`COLUMNS`.TABLE_SCHEMA = 'sds';
   
-- 数据上传查询
select 
				file_import_tmp.file_up_id,
				file_import_tmp.file_name,
				file_import_tmp.file_size,
				file_import_tmp.file_suffix,
				file_import_tmp.op_person,
				file_import_tmp.op_date,
				file_import_tmp.flag,
				file_import_tmp.description,
				file_import_tmp.base_type base_type_mask,
				file_import_tmp.base_type,
				file_import_tmp.del_flag
			from
			file_import_tmp
			where file_import_tmp.del_flag='0'select 
				file_import_tmp.file_up_id,
				file_import_tmp.file_name,
				file_import_tmp.file_size,
				file_import_tmp.file_suffix,
				file_import_tmp.op_person,
				file_import_tmp.op_date,
				file_import_tmp.flag,
				file_import_tmp.description,
				file_import_tmp.base_type base_type_mask,
				file_import_tmp.base_type,
				file_import_tmp.del_flag
			from
			file_import_tmp
			where file_import_tmp.del_flag='0'
			
			
-- 销售数据查询

 			SELECT
 			b.area_state area_state_cust,
 			(select func_name from sys_code_t where model_code='852' and func_code=c.zl_flag)
	 collection_type,
	 (select func_name from sys_code_t where model_code='852' and func_code=b.connection_type)
	 connection_type_cust,
	(select func_name from sys_code_t where model_code='296' and func_code=d.prod_sys_type)
	 prod_sys_type,
	d.prod_price prod_price_p ,
	b.dist_name,
	b.cust_name,
	(select func_name from sys_code_t where model_code='540' and func_code=b.dist_type)
	 dist_type,
	<!-- getOrgParentNameLst(b.org_code) -->
	(select org_name_all from auth_organization_t where org_id = b.org_code) 
	 org_code_dist,
	d.second_price,
	d.third_price,
	(SELECT
			func_name
		FROM
			sys_code_t
		WHERE
			model_code = '570'
		AND func_code = d.prod_unit )
	prod_unit_p,
<!-- 	getOrgParentNameLst(f.org_code) -->
	(select org_name_all from auth_organization_t where org_id = f.org_code) 
org_code,
	sale_template_t.id,
	sale_template_t.up_id,
	sale_template_t.cust_id,
	sale_template_t.up_cycle,
	sale_template_t.or_nbr,
	sale_template_t.or_type,
	sale_template_t.term_code,
	sale_template_t.term_name,
	sale_template_t.term_address,
	sale_template_t.prod_code,
	sale_template_t.prod_name,
	sale_template_t.prod_spec,
	sale_template_t.prod_batch,
	sale_template_t.prod_unit,
	sale_template_t.valid_date,
	sale_template_t.prod_count,
	sale_template_t.prod_price,
	sale_template_t.prod_money,
	sale_template_t.sale_date,
	sale_template_t.validate_result,
	sale_template_t.term_subside_id,
	sale_template_t.prod_subside_id,
	c.create_date,
d.prod_spec prod_spec_p,
CASE f.match_type
when '2' then g.term_name
WHEN '1'  THEN h.dist_name
 else '' end
 term_name_p,

CASE f.match_type
when '2' then (select func_name from sys_code_t where model_code='295' and func_code=g.term_type  )
WHEN '1'  THEN (select func_name from sys_code_t where model_code='540' and func_code=h.dist_type  )
 else '' end
term_type_p,
CASE f.match_type
when '2' then  g.area_state
WHEN '1'  THEN  h.area_state
 else '' end
 area_state,
CASE f.match_type
when '2' then  g.area_city
WHEN '1'  THEN  h.area_city
 else '' end
 area_city,
CASE f.match_type
when '2' then  g.trem_address
WHEN '1'  THEN   h.dist_address
 else '' end
  term_address_p,
  format(	sale_template_t.prod_count*d.prod_price,2) as prod_money_p,
(select func_name from sys_code_t where model_code='600' and func_code=f.match_type) as match_type_p,
b.eas,
f.term_type term_type_manual
FROM
	sale_template_t LEFT JOIN prod_subside_t e ON sale_template_t.prod_subside_id = e.prod_subside_id
									LEFT JOIN term_subside_t f ON sale_template_t.term_subside_id = f.term_subside_id
									LEFT JOIN product_info_t d ON d.id = e.prod_template_id
									LEFT JOIN term_info_t g on g.id=f.term_template_id
										LEFT JOIN cust_info_t h on h.id=f.term_template_id,

	cust_info_t b,
	up_load_main c

WHERE
	b.id = sale_template_t.cust_id
AND c.up_id = sale_template_t.up_id
AND c.deal_flag = '0'



-- 终端匹配购进
	select aa.term_subside_id,
					cc.dist_name,
					cc.dist_type,
						aa.match_type ,
						(SELECT
							func_name
						FROM
							sys_code_t
						WHERE
							model_code = '600'
						AND func_code = aa.match_type)  match_type_mask,
					(select func_name from sys_code_t where model_code =  '540' and func_code =cc.dist_type ) dist_type_mask,
					aa.term_subside_name,
					aa.term_template_id,
					CASE aa.match_type 
					   WHEN '2'  THEN (
							SELECT
								term_info_t.term_name
							FROM
								term_info_t
							WHERE
								term_info_t.id = aa.term_template_id 
						)
					  WHEN '1'  THEN (
							SELECT
								cust_info_t.dist_name
							FROM
								cust_info_t
							WHERE
								cust_info_t.id = aa.term_template_id 
						)
					  else '' end 
					  term_name,
					    CASE aa.match_type 
					   WHEN '2'  THEN (
					   SELECT
 			( select func_name from sys_code_t where model_code =  '295' 
 				and func_code =term_info_t.term_type)
							FROM
								term_info_t
							WHERE
								term_info_t.id = aa.term_template_id 
						)
					  WHEN '1'  THEN (
					 SELECT 
		(
			SELECT
				func_name
			FROM
				sys_code_t
			WHERE
				model_code = '540'
			AND func_code = cust_info_t.dist_type
		)
from cust_info_t
		WHERE
			cust_info_t.id = aa.term_template_id
						)
					  else '' end 
					  term_type_p,
					aa.city_id,
					getOrgParentNameLst(aa.org_code)  org_code_mask,
					(select org_name from auth_organization_t where org_id=aa.org_code) org_code,
					aa.match_state,
					(SELECT
					func_name
						FROM
							sys_code_t
						WHERE
							model_code = '692'
						AND func_code = aa.match_state) match_state_mask,
					aa.buy_count prod_count,
					aa.create_date,
			 		round(((ABS(aa.buy_count) / (select sum(ABS(a.buy_count) )
			 		from term_subside_t a ,cust_info_t c  where	 a.cust_id =c.id  and a.buy_count is not null
					 <include refid="term_subside_tCondition1"/> )))*100,2) sale_scale
					 from term_subside_t aa ,cust_info_t cc  where	 aa.cust_id =cc.id  and aa.buy_count is not null
					 <include refid="term_subside_tCondition"/>
					ORDER BY ABS(aa.buy_count) desc
					
-- 终端匹配库存表
select aa.term_subside_id,
					cc.dist_name,
					cc.dist_type,
						aa.match_type ,
						(SELECT
							func_name
						FROM
							sys_code_t
						WHERE
							model_code = '600'
						AND func_code = aa.match_type)  match_type_mask,
					(select func_name from sys_code_t where model_code =  '540' and func_code =cc.dist_type ) dist_type_mask,
					aa.term_subside_name,
					aa.term_template_id,
					CASE aa.match_type 
					   WHEN '2'  THEN (
							SELECT
								term_info_t.term_name
							FROM
								term_info_t
							WHERE
								term_info_t.id = aa.term_template_id 
						)
					  WHEN '1'  THEN (
							SELECT
								cust_info_t.dist_name
							FROM
								cust_info_t
							WHERE
								cust_info_t.id = aa.term_template_id 
						)
					  else '' end 
					  term_name,
					     CASE aa.match_type 
					   WHEN '2'  THEN (
					   SELECT
 			( select func_name from sys_code_t where model_code =  '295' 
 				and func_code =term_info_t.term_type)
							FROM
								term_info_t
							WHERE
								term_info_t.id = aa.term_template_id 
						)
					  WHEN '1'  THEN (
					 SELECT 
		(
			SELECT
				func_name
			FROM
				sys_code_t
			WHERE
				model_code = '540'
			AND func_code = cust_info_t.dist_type
		)
		from cust_info_t
		WHERE
			cust_info_t.id = aa.term_template_id
						)
					  else '' end 
					  term_type_p,
					aa.city_id,
					getOrgParentNameLst(aa.org_code)  org_code_mask,
					(select org_name from auth_organization_t where org_id=aa.org_code) org_code,
					aa.match_state,
					(SELECT
					func_name
						FROM
							sys_code_t
						WHERE
							model_code = '692'
						AND func_code = aa.match_state) match_state_mask,
					aa.stock_count prod_count,
					aa.create_date,
			 		round(((ABS(aa.stock_count) / (select sum(ABS(a.stock_count))  from term_subside_t a ,cust_info_t c  where	 a.cust_id =c.id and a.stock_count is not null
					 <include refid="term_subside_tCondition1"/> )))*100,2) sale_scale
					 from term_subside_t aa ,cust_info_t cc  where	 aa.cust_id =cc.id and aa.stock_count is not null
					 <include refid="term_subside_tCondition"/>
					ORDER BY ABS(aa.stock_count) desc
					
					
-- 终端匹配销售表
select aa.term_subside_id,
					cc.dist_name,
					cc.dist_type,
						aa.match_type ,
						(SELECT
							func_name
						FROM
							sys_code_t
						WHERE
							model_code = '600'
						AND func_code = aa.match_type)  match_type_mask,
					(select func_name from sys_code_t where model_code =  '540' and func_code =cc.dist_type ) dist_type_mask,
					aa.term_subside_name,
					aa.term_template_id,
					CASE aa.match_type 
					   WHEN '2'  THEN (
							SELECT
								term_info_t.term_name
							FROM
								term_info_t
							WHERE
								term_info_t.id = aa.term_template_id 
						)
					  WHEN '1'  THEN (
							SELECT
								cust_info_t.dist_name
							FROM
								cust_info_t
							WHERE
								cust_info_t.id = aa.term_template_id 
						)
					  else '' end 
					  term_name,
					   CASE aa.match_type 
					   WHEN '2'  THEN (
					   SELECT
 			( select func_name from sys_code_t where model_code =  '295' 
 				and func_code =term_info_t.term_type)
							FROM
								term_info_t
							WHERE
								term_info_t.id = aa.term_template_id 
						)
					  WHEN '1'  THEN (
					 SELECT 
		(
			SELECT
				func_name
			FROM
				sys_code_t
			WHERE
				model_code = '540'
			AND func_code = cust_info_t.dist_type
		)
from cust_info_t
		WHERE
			cust_info_t.id = aa.term_template_id
						)
					  else '' end 
					  term_type_p,
					aa.city_id,
					getOrgParentNameLst(aa.org_code)  org_code_mask,
					(select org_name from auth_organization_t where org_id=aa.org_code) org_code,
					
					aa.match_state,
					(SELECT
					func_name
						FROM
							sys_code_t
						WHERE
							model_code = '692'
						AND func_code = aa.match_state) match_state_mask,
					aa.sale_count prod_count,
					aa.create_date,
			 		round(((ABS(aa.sale_count) / (select sum(ABS(a.sale_count))  from term_subside_t a ,cust_info_t c  
			 		 where	 a.cust_id =c.id  and a.sale_count is not null  <include refid="term_subside_tCondition1"/> )))*100,2) sale_scale
					 from term_subside_t aa ,cust_info_t cc  where	 aa.cust_id =cc.id  and aa.sale_count is not null
					 <include refid="term_subside_tCondition"/>
					ORDER BY ABS(aa.sale_count) desc
					
					
