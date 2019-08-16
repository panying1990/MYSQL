BEGIN
TRUNCATE TABLE client_info;
INSERT INTO client_info
(
	client_id,
	client_name,
	client_type,
	client_level,
	client_province,
	client_city,
	last_dis,
	sale_manager,
	sale_allpath,
	coop_status
) SELECT
	客户编码,
	客户名称,
	客户类型,
	客户级别,
	行政省,
	市,
	getarea (销售区域全路径 ,- 1) AS last_dis,
	客户经理,
	销售区域全路径,
	合作状态
FROM
	client_data_template
WHERE
	销售区域全路径 NOT REGEXP "临时";
	-- 创建规范的员工信息表
TRUNCATE TABLE staff_info;
INSERT INTO staff_info (
	sale_manager,
	sale_post,
	sale_department,
	first_dis,
	second_dis,
	third_dis,
	sale_upmanager,
	sale_plusmanager
) SELECT
	t1.`姓名（必填）` AS sale_manager,
	t1.职务 AS sale_post,
	t1.`部门全路径` AS sale_department,
	getarea (t1.`部门全路径`, 4) AS first_dis,
	getarea (t1.`部门全路径`, 5) AS second_dis,
	getarea (t1.部门全路径 ,- 1) AS third_dis,
	t1.`上级领导` AS sale_upmanager,
	t2.`上级领导` AS sale_plusmanager
FROM
	staff_data_template t1,
	staff_data_template t2
WHERE
	t1.`上级领导` = t2.`姓名（必填）`;
	
-- 创建拜访信息记录表
TRUNCATE TABLE visit_log;
INSERT INTO visit_log (
visit_date,
sale_manager,
sale_allpath ,
client_id,
client_name,
client_type,
visit_status,
visit_minute
) SELECT
`拜访日期`,
`拜访人`,
`销售区域全路径`,
`客户编码`,
`拜访客户`,
`客户类型`,
`拜访完成`,
`拜访用时(分钟)` 
FROM
	visit_data_template 
WHERE
	拜访完成 = '已完成';
	
-- 创建南战区终端任务表记录
TRUNCATE TABLE southtask_log;
INSERT INTO southtask_log (
visit_date,
sale_manager,
sale_allpath,
client_id,
client_name,
client_type,
display_duitou,
display_huojia,
display_ph_pt,
display_pop,
display_other,
price_run25,
price_jing25,
price_run40,
price_jing40,
price_laili,
activity_status,
activity_describe,
activity_gifts,
activity_giftsdescribe
) SELECT
`上报时间`,
`拜访人`,
`销售区域全路径`,
`客户编码`,
`拜访客户`,
`客户类型`,
tt.陈列 as 堆头,
tt.`货架`,
tt.`喷绘/PT板`,
tt.POP,
tt.`其它`,
tt.零售价 as 常润茶25袋,
tt.`常菁25袋（元）`,
tt.`常润40袋（元）`,
tt.`常菁40袋（元）`,
tt.`来利（元）`,
tt.活动,
tt.`活动描述`,
tt.`是否有赠品`,
tt.`赠品描述`
FROM
	termtask_data_template tt 
WHERE
	拜访完成 = '已完成' ;
	
-- 创建库存明细表
TRUNCATE TABLE store_log;

INSERT INTO store_log (
	report_date,
	sale_manager,
	client_id,
	client_name,
	client_type,
	product_name,
	prodstore_volume
) SELECT
	a.`上报日期` AS report_date,
	a.上报人 AS sale_manager,
	a.`客户编码` AS client_id,
	a.`客户` AS client_name,
	a.客户类型 AS client_type,
	a.`商品名称` AS product_name,
	a.`库存数量` * 1 AS prodstore_volume
FROM
	store_data_template a;

-- 创建日报明细表
TRUNCATE TABLE blog_log;
-- CREATE TABLE blog_log (
-- report_date DATETIME COMMENT '日报上报日期',
-- sale_manager VARCHAR ( 50 ) COMMENT '上报人 即拜访人',
-- sale_department varchar(50) comment '上报人所在部门',
-- sale_upmanager varchar(50) comment '上报人所在部门上级',
-- sale_plusmanager varchar(50) comment '上报人所在部门上上级',
-- bolg_type varchar(50) comment '发布报告类型',
-- up_manager VARCHAR ( 50 ) COMMENT '日报可见上级',
-- up_comment varchar(50) comment '上级评论，有则显示上级名称',
-- blog_comment VARCHAR ( 50 ) COMMENT '日报评论数',
-- blog_starcnt VARCHAR ( 50 ) COMMENT '日报评星数'
-- ) COMMENT = '日报明细表';

INSERT INTO blog_log (
	report_date,
	sale_manager,
	sale_department,
	sale_upmanager,
	sale_plusmanager,
	bolg_type,
	up_manager,
	up_comment,
	blog_comment,
	blog_starcnt
) SELECT
	a.*
FROM
	(
		SELECT
			a.`发布时间` AS report_date,
			a.`发布人` AS sale_manager,
			b.sale_department AS sale_department,
			b.sale_upmanager AS sale_upmanager,
			b.sale_plusmanager AS sale_plusmanager,
			a.`微博类型` AS bolg_type,
			trim(
				REPLACE (
					MID(
						a.`内容`,
						POSITION("@" IN a.`内容`) + 1,
						3
					),
					' ',
					''
				)
			) AS up_manager,
			trim(
				REPLACE (
					MID(
						a.`评论`,
						position(
							b.sale_upmanager IN a.`评论`
						),
						3
					),
					',',
					''
				)
			) AS up_comment,
			a.`评论次数` AS blog_comment,
			a.`评星数` AS blog_starcnt
		FROM
			blog_data_template a,
			staff_info b
		WHERE
			a.`发布人` = b.sale_manager
	) a
WHERE
	a.bolg_type = '日报';
END
