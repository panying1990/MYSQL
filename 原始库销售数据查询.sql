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
AND  sale_template_t.up_cycle IN ('2019-03')  -- 月份