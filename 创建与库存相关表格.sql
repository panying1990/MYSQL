use agilesc_report;
drop table if exists lx_stock_summary;
create table lx_stock_summary(
dist_name varchar(255) comment "上传客户名称",
org_code_dist varchar(255) comment "客户所属组织",
eas varchar(50) comment"EAS编码",
dist_type varchar(50) comment "客户类型",
up_cycle varchar(50) comment "上传周期",
stock_type varchar(255) comment "库存类型",
stock_date varchar(255) comment "库存日期",
prod_batch varchar(255) comment "产品批文",
prod_count int comment "产品数量",
prod_sys_type varchar(50) comment "产品品类(标准)",
prod_spec_p varchar(50) comment "产品规格(标准)",
prod_price_p float comment "产品单价",
dist_first varchar(150) comment "一级区域",
dist_second varchar(150) comment "二级区域",
dist_third varchar(150) comment "三级区域",
prod_type_spec varchar(150) comment "产品品类加规格"
)comment="导出库存";
insert into lx_stock_summary(
  dist_name,
	org_code_dist,
	eas,
	dist_type,
	up_cycle,
	stock_type,
	stock_date,
	prod_batch,
	prod_count,
	prod_sys_type,
	prod_spec_p,
	prod_price_p,
	dist_first,
  dist_second,
  dist_third,
	prod_type_spec)
select
 tt.dist_name,
	tt.org_code_dist,
	tt.eas,
	tt.dist_type,
	tt.up_cycle,
	tt.stock_type,
	tt.stock_date,
	tt.prod_batch,
	tt.prod_count,
	tt.prod_sys_type,
	tt.prod_spec_p,
	tt.prod_price_p,
 get_first(tt.org_code_dist) as dist_first,
get_second(tt.org_code_dist) as dist_second,
get_third(tt.org_code_dist) as dist_third,
getprod(tt.prod_sys_type,tt.prod_spec_p) as prod_type_spec
from
lx_basedata_stock tt;

