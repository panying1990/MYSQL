-- 消费者行为研究 
-- 用于进行增量数据的分析。
-- 全景扫描-外部市场-品牌======================================基础数据准备：
-- base:全景扫描-地域分布-基础数据
USE data_check;
SET @sys_customer_index = ROUND((SELECT MAX(sys_customer_id) FROM crm_kd.kd_customer),0);
DROP TABLE 
IF EXISTS customer_data_city;
CREATE TABLE customer_data_city AS
-- SELECT
-- sum(tt.pay_amount)
-- FROM
SELECT
 tt.sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 tt.develop_time,
 tt.first_pay_time,
 tt.last_pay_time,
 tt.pay_times,
 tt.pay_amount,
 tt.item_unit
FROM
(
(SELECT
 tt.sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 tt.develop_time,
 tt.first_pay_time,
 tt.last_pay_time,
 tt.pay_times,
 tt.pay_amount,
 tt.item_unit
FROM
 crm_kd.kd_customer tt
WHERE
 DATE_FORMAT(tt.last_order_time,"%Y-%m-%d") BETWEEN "2016-01-01" AND "2017-10-31" -- 从2016年01月01日到2017年·10月15日的用户数据
AND
 sys_customer_id NOT IN(SELECT tt.sys_customer_id FROM crm_kd.kd_customer tt WHERE tt.pay_amount<20 AND tt.pay_times>0) -- 排除非主力客户
AND
 sys_customer_id NOT IN(SELECT tt.sys_customer_id FROM data_check.unnorm_customer_id tt) -- 排除部分囤货用户
AND
 tt.plat_from_type <> 40 -- 排除来自呼叫中心的用户
ORDER BY
 tt.develop_time DESC)
UNION
(SELECT
 @sys_customer_index:= @sys_customer_index+1 AS sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 MIN(tt.develop_time) AS develop_time,
 MIN(tt.order_pay_time) AS first_pay_time,
 MAX(tt.order_pay_time) AS last_pay_time,
 COUNT(DISTINCT order_id) AS pay_times,
 SUM(tt.order_pay_amount) AS pay_amount,
 COUNT(tt.items) AS item_unit
FROM
(SELECT
 tt.`用户名` AS out_nick,
 tt.`订单ID辅助列` AS order_id,
 tt.`收货人` AS customer_name,
 tt.`收货人电话` AS mobile,
 tt.`收货省份` AS province,
 tt.`收货城市` AS city,
 DATE_FORMAT(tt.`下单时间`,"%Y-%m-%d %h:%m:%s") AS develop_time,
 DATE_FORMAT(tt.`付款时间`,"%Y-%m-%d %h:%m:%s") AS order_pay_time,
 ROUND(tt.GMV,1) AS order_pay_amount,
 tt.`销量` AS items,
 "46" AS plat_from_type
FROM
 master_data.mas_fristdrug_data2 tt
WHERE 
 tt.`用户名`<> 'N')tt
GROUP BY
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type
ORDER BY
 pay_times DESC))tt
 WHERE
 DATE_FORMAT(tt.last_pay_time,"%Y-%m-%d") BETWEEN "2017-01-01" AND "2017-10-15"
ORDER BY
 tt.last_pay_time;


-- 1.9万低价值及价格敏感用户
 SELECT
 sum(tt.pay_amount)
 FROM
(SELECT
 tt.sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 tt.develop_time,
 tt.first_pay_time,
 tt.last_pay_time,
 tt.pay_times,
 tt.pay_amount
FROM
 crm_kd.kd_customer tt
WHERE
 DATE_FORMAT(tt.last_order_time,"%Y-%m-%d") BETWEEN "2017-01-01" AND "2017-10-15" -- 从2016年01月01日到2017年·10月15日的用户数据
AND
 (sys_customer_id IN(SELECT tt.sys_customer_id FROM crm_kd.kd_customer tt WHERE tt.pay_amount<20 AND tt.pay_times>0) -- 排除非主力客户
OR
 tt.plat_from_type = 40)-- 排除来自呼叫中心的用户
ORDER BY
 tt.pay_amount DESC)tt


-- 主力用户分布======================================消费者指数：
USE data_check;
DROP TABLE
IF EXISTS user_province_test;
CREATE TABLE user_province_test AS
SELECT
 pp.province as std_province,
 tt.province as tt_province,
 tt.province_counts AS province_counts,
 pp.population AS population,
 ROUND(10*tt.province_counts/pp.population,0) AS user_per_wan
FROM
(SELECT
 tt.province,
 SUM(tt.user_counts) AS province_counts
FROM
(SELECT
 TRIM(LEFT(tt.province,2)) AS province,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts
FROM
 data_check.customer_data_city tt
GROUP BY
 province
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.province)tt
LEFT JOIN data_check.province_population pp
ON LEFT(tt.province,2)=LEFT(pp.province,2)
WHERE
pp.province IS NOT NULL
ORDER BY
user_per_wan;


-- 主力用户分布-浙江省：
USE data_check;
DROP TABLE
IF EXISTS user_zhejiang_test;
CREATE TABLE user_zhejiang_test AS
SELECT
 pp.province as std_province,
 pp.city as std_city,
 tt.province_counts AS province_counts,
 pp.population AS population,
 ROUND(10*tt.province_counts/pp.population,0) AS user_per_wan
FROM
(SELECT
 tt.province,
 tt.city,
 SUM(tt.user_counts) AS province_counts
FROM
(SELECT
 TRIM(LEFT(tt.province,2)) AS province,
 TRIM(LEFT(tt.city,2)) AS city,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts
FROM
 data_check.customer_data_city tt
GROUP BY
 province,
 city
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.province,
 tt.city
HAVING
 tt.province ='浙江')tt
LEFT JOIN data_check.zhejiang pp
ON CONCAT(LEFT(tt.province,2),left(tt.city,2))=CONCAT(LEFT(pp.province,2),left(pp.city,2))
WHERE
pp.province IS NOT NULL
ORDER BY
user_per_wan;


-- 主力用户分布======================================购物频次：
USE data_check;
DROP TABLE
IF EXISTS user_province_perpay;
CREATE TABLE user_province_perpay AS
SELECT
 pp.province as std_province,
 tt.province as tt_province,
 tt.province_counts AS province_counts,
 tt.user_paytimes AS user_paytimes,
 ROUND(tt.user_paytimes/tt.province_counts,2) AS user_per_pay
FROM
(SELECT
 tt.province,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 TRIM(LEFT(tt.province,2)) AS province,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 SUM(tt.pay_times) AS user_paytimes
FROM
 data_check.customer_data_city tt
GROUP BY
 province
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.province)tt
LEFT JOIN data_check.province_population_shop pp
ON LEFT(tt.province,2)=LEFT(pp.province,2)
WHERE
pp.province IS NOT NULL
ORDER BY
user_per_pay;


-- 主力用户分布-浙江省：
USE data_check;
DROP TABLE
IF EXISTS user_zhejiang_perpay;
CREATE TABLE user_zhejiang_perpay AS
SELECT
 pp.province as std_province,
 pp.city as std_city,
 tt.province_counts AS province_counts,
 tt.user_paytimes AS user_paytimes,
 ROUND(tt.user_paytimes/tt.province_counts,2) AS user_per_pay
FROM
(SELECT
 tt.province,
 tt.city,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 TRIM(LEFT(tt.province,2)) AS province,
 TRIM(LEFT(tt.city,2)) AS city,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 SUM(tt.pay_times) AS user_paytimes
FROM
 data_check.customer_data_city tt
GROUP BY
 province,
 city
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.province,
 tt.city
HAVING
 tt.province ='浙江')tt
LEFT JOIN data_check.zhejiang pp
ON CONCAT(LEFT(tt.province,2),left(tt.city,2))=CONCAT(LEFT(pp.province,2),left(pp.city,2))
WHERE
pp.province IS NOT NULL
ORDER BY
user_per_pay;


-- 主力用户分布======================================客单价：
-- 地域分布: 客单价分布
USE data_check;
DROP TABLE
IF EXISTS user_province_price;
CREATE TABLE user_province_price AS
SELECT
 pp.province as std_province,
 tt.province as tt_province,
 tt.user_paytimes AS user_paytimes,
 tt.province_amount AS province_amount,
 ROUND(tt.province_amount/tt.user_paytimes,0) AS user_price
FROM
(SELECT
 tt.province,
 SUM(tt.user_amoiunt) AS province_amount,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 TRIM(LEFT(tt.province,2)) AS province,
 ROUND(SUM(tt.pay_amount),1) AS user_amoiunt,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 SUM(tt.pay_times) AS user_paytimes
FROM
 data_check.customer_data_city tt
GROUP BY
 province
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.province)tt
LEFT JOIN data_check.province_population_shop pp
ON LEFT(tt.province,2)=LEFT(pp.province,2)
WHERE
pp.province IS NOT NULL
AND
tt.user_paytimes>1000
ORDER BY
user_price;

-- 浙江分布: 客单价
USE data_check;
DROP TABLE
IF EXISTS user_zhejiang_price;
CREATE TABLE user_zhejiang_price AS
SELECT
 pp.province as std_province,
 pp.city as std_city,
 tt.user_paytimes AS user_paytimes,
 tt.province_amount AS province_amount,
 ROUND(tt.province_amount/tt.user_paytimes,0) AS user_price
FROM
(SELECT
 tt.province,
 tt.city,
 SUM(tt.user_amount) AS province_amount,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 TRIM(LEFT(tt.province,2)) AS province,
 TRIM(LEFT(tt.city,2)) AS city,
 ROUND(SUM(tt.pay_amount),1) AS user_amount,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 SUM(tt.pay_times) AS user_paytimes
FROM
 data_check.customer_data_city tt
GROUP BY
 province,
 city
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.province,
 tt.city
HAVING
 tt.province ='浙江')tt
LEFT JOIN data_check.zhejiang pp
ON CONCAT(LEFT(tt.province,2),left(tt.city,2))=CONCAT(LEFT(pp.province,2),left(pp.city,2))
WHERE
pp.province IS NOT NULL
ORDER BY
user_price;

-- 主力用户分布======================================销量增长：
-- 基础数据处理
-- 地域分布: 2017年较2016年的增长率
USE data_check;
DROP TABLE 
IF EXISTS trade_data_city;
CREATE TABLE trade_data_city AS
SELECT
 tt.*
FROM
 crm_kd.kd_trade tt
WHERE
 sys_customer_id IN
(SELECT
 tt.sys_customer_id
FROM
(
(SELECT
 tt.sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 tt.develop_time,
 tt.first_pay_time,
 tt.last_pay_time,
 tt.pay_times,
 tt.pay_amount,
 tt.item_unit
FROM
 crm_kd.kd_customer tt
WHERE
 DATE_FORMAT(tt.last_order_time,"%Y-%m-%d") BETWEEN "2016-01-01" AND "2017-10-31" -- 从2016年01月01日到2017年·10月15日的用户数据
AND
 sys_customer_id NOT IN(SELECT tt.sys_customer_id FROM crm_kd.kd_customer tt WHERE tt.pay_amount<20 AND tt.pay_times>0) -- 排除非主力客户
AND
 sys_customer_id NOT IN(SELECT tt.sys_customer_id FROM data_check.unnorm_customer_id tt) -- 排除部分囤货用户
AND
 tt.plat_from_type <> 40 -- 排除来自呼叫中心的用户
ORDER BY
 tt.develop_time DESC)
UNION
(SELECT
 @sys_customer_index:= @sys_customer_index+1 AS sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 MIN(tt.develop_time) AS develop_time,
 MIN(tt.order_pay_time) AS first_pay_time,
 MAX(tt.order_pay_time) AS last_pay_time,
 COUNT(DISTINCT order_id) AS pay_times,
 SUM(tt.order_pay_amount) AS pay_amount,
 COUNT(tt.items) AS item_unit
FROM
(SELECT
 tt.`用户名` AS out_nick,
 tt.`订单ID辅助列` AS order_id,
 tt.`收货人` AS customer_name,
 tt.`收货人电话` AS mobile,
 tt.`收货省份` AS province,
 tt.`收货城市` AS city,
 DATE_FORMAT(tt.`下单时间`,"%Y-%m-%d %h:%m:%s") AS develop_time,
 DATE_FORMAT(tt.`付款时间`,"%Y-%m-%d %h:%m:%s") AS order_pay_time,
 ROUND(tt.GMV,1) AS order_pay_amount,
 tt.`销量` AS items,
 "46" AS plat_from_type
FROM
 master_data.mas_fristdrug_data2 tt
WHERE 
 tt.`用户名`<> 'N')tt
GROUP BY
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type
ORDER BY
 pay_times DESC))tt
 WHERE
 DATE_FORMAT(tt.last_pay_time,"%Y-%m-%d") BETWEEN "2016-01-01" AND "2017-10-15")
AND
 DATE_FORMAT(tt.created,"%Y-%m-%d") BETWEEN "2016-01-01" AND "2017-10-15"
AND
 tt.plat_from_id=585
AND
 tt.trade_status IN('TRADE_FINISHED','TRADE_BUYER_SIGNED','WAIT_BUYER_CONFIRM_GOODS','WAIT_BUYER_PAY','WAIT_SELLER_SEND_GOODS'); -- 将进行同比分析的数据锁定在天猫旗舰店中，如此，确保前后数据的一致性



USE data_check;
DROP TABLE 
IF EXISTS trade_ratio_city;
CREATE TABLE trade_ratio_city AS
SELECT
 zz.province as std_province,
 pp.province_amount AS amount_yoy,
 tt.province_amount AS province_amount,
 pp.province_counts AS counts_yoy,
 tt.province_counts AS province_counts,
 pp.user_paytimes AS user_paytimes_yoy,
 tt.user_paytimes AS user_paytimes,
 ROUND(pp.province_amount/pp.user_paytimes) AS price_yoy,
 ROUND(tt.province_amount/tt.user_paytimes) AS price,
 ROUND(pp.user_paytimes/pp.province_counts,3) AS buynum_yoy,
 ROUND(tt.user_paytimes/tt.province_counts,3) AS buynum,
 ROUND(100*(tt.province_amount/pp.province_amount-1),1) AS amounts_ratio,
 ROUND(100*(tt.province_counts/pp.province_counts-1),1) AS counts_ratio,
 ROUND(100*(tt.user_paytimes/pp.user_paytimes-1),1) AS paytimes_ratio,
 ROUND((ROUND(tt.province_amount/tt.user_paytimes)-ROUND(pp.province_amount/pp.user_paytimes)),1) AS price_gap,
 ROUND((ROUND(tt.user_paytimes/tt.province_counts,3)-ROUND(pp.user_paytimes/pp.province_counts,3)),3) AS buyerper_gap
FROM
(SELECT
 tt.pay_year,
 tt.province,
 SUM(tt.province_amount) AS province_amount,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 DATE_FORMAT(tt.created,"%Y") AS pay_year,
 TRIM(LEFT(tt.receiver_province,2)) AS province,
 ROUND(SUM(tt.payment),1) AS province_amount,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 COUNT(tt.sys_trade_id) AS user_paytimes
FROM
 data_check.trade_data_city tt
GROUP BY
 pay_year,
 province
HAVING
 pay_year=2017
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.pay_year,
 tt.province)tt
LEFT JOIN
(SELECT
 tt.pay_year,
 tt.province,
 SUM(tt.province_amount) AS province_amount,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 DATE_FORMAT(tt.created,"%Y") AS pay_year,
 TRIM(LEFT(tt.receiver_province,2)) AS province,
 ROUND(SUM(tt.payment),1) AS province_amount,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 COUNT(tt.sys_trade_id) AS user_paytimes
FROM
 data_check.trade_data_city tt
GROUP BY
 pay_year,
 province
HAVING
 pay_year=2016
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.pay_year,
 tt.province)pp
ON LEFT(tt.province,2)=LEFT(pp.province,2)
LEFT JOIN data_check.province_population_shop zz
ON LEFT(tt.province,2)=LEFT(zz.province,2)
WHERE
pp.province IS NOT NULL
AND
tt.province_counts>500
ORDER BY
amounts_ratio;



# 对存量市场较大的7个省市区城市一级进行分析。其中，省-地级市，直辖市-城区
-- base:全景扫描-城市级别-基础数据
USE data_check;
DROP TABLE 
IF EXISTS trade_data_topten;
CREATE TABLE trade_data_topten AS
SELECT
 tt.*
FROM
 crm_kd.kd_trade tt
WHERE
 sys_customer_id IN
(SELECT
 tt.sys_customer_id
FROM
 crm_kd.kd_customer tt
WHERE
 DATE_FORMAT(tt.last_order_time,"%Y-%m-%d") BETWEEN "2016-01-01" AND "2017-10-31" -- 从2016年01月01日到2017年·10月15日的用户数据
AND
 sys_customer_id NOT IN(SELECT tt.sys_customer_id FROM crm_kd.kd_customer tt WHERE tt.pay_amount<20 AND tt.pay_times>0) -- 排除非主力客户
AND
 sys_customer_id NOT IN(SELECT tt.sys_customer_id FROM data_check.unnorm_customer_id tt) -- 排除部分囤货用户
AND
 tt.plat_from_type <> 40 -- 排除来自呼叫中心的用户
ORDER BY
 tt.develop_time DESC)
AND
 DATE_FORMAT(tt.pay_time,"%Y-%m-%d") BETWEEN "2016-01-01" AND "2017-10-15"
AND
 tt.plat_from_id=585
AND
 tt.trade_status IN('TRADE_FINISHED','TRADE_BUYER_SIGNED','WAIT_BUYER_CONFIRM_GOODS','WAIT_BUYER_PAY','WAIT_SELLER_SEND_GOODS'); -- 将进行同比分析的数据锁定在天猫旗舰店中，如此，确保前后数据的一致性

-- 计算值
USE data_check;
SET @city_num=0;
DROP TABLE 
IF EXISTS trade_ratio_citys;
CREATE TABLE trade_ratio_citys AS
SELECT
 @city_num:=@city_num+1 AS city_index,
 zz.province as std_province,
 zz.city AS std_city,
 -- pp.province_amount AS amount_yoy,
 tt.province_amount AS province_amount,
 -- pp.province_counts AS counts_yoy,
 -- ROUND(zz.population,1) AS population,
 -- ROUND(10*tt.province_counts/zz.population,1) AS user_per_wan,
 -- pp.user_paytimes AS user_paytimes_yoy,
 -- tt.user_paytimes AS user_paytimes,
 -- ROUND(pp.province_amount/pp.user_paytimes) AS price_yoy,
 -- ROUND(tt.province_amount/tt.user_paytimes) AS price,
 -- ROUND(pp.user_paytimes/pp.province_counts,3) AS buynum_yoy,
 -- ROUND(tt.user_paytimes/tt.province_counts,3) AS buynum,
 ROUND(100*(tt.province_amount/pp.province_amount-1),1) AS amounts_ratio,
 ROUND(100*(tt.province_counts/pp.province_counts-1),1) AS counts_ratio,
 ROUND(100*(tt.user_paytimes/pp.user_paytimes-1),1) AS paytimes_ratio,
 ROUND((ROUND(tt.province_amount/tt.user_paytimes)-ROUND(pp.province_amount/pp.user_paytimes)),1) AS price_gap,
 ROUND((ROUND(tt.user_paytimes/tt.province_counts,3)-ROUND(pp.user_paytimes/pp.province_counts,3)),3) AS buyerper_gap
FROM
(SELECT
 tt.pay_year,
 tt.province,
 tt.city,
 SUM(tt.province_amount) AS province_amount,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 DATE_FORMAT(tt.created,"%Y") AS pay_year,
 TRIM(LEFT(tt.receiver_province,2)) AS province,
 TRIM(LEFT(tt.receiver_city,2)) AS city,
 ROUND(SUM(tt.payment),1) AS province_amount,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 COUNT(tt.sys_trade_id) AS user_paytimes
FROM
 data_check.trade_data_topten tt
GROUP BY
 pay_year,
 province,
 city
HAVING
 pay_year=2017
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.pay_year,
 tt.province,
 tt.city)tt
LEFT JOIN
(SELECT
 tt.pay_year,
 tt.province,
 tt.city,
 SUM(tt.province_amount) AS province_amount,
 SUM(tt.user_counts) AS province_counts,
 SUM(tt.user_paytimes) AS user_paytimes
FROM
(SELECT
 DATE_FORMAT(tt.created,"%Y") AS pay_year,
 TRIM(LEFT(tt.receiver_province,2)) AS province,
 TRIM(LEFT(tt.receiver_city,2)) AS city,
 ROUND(SUM(tt.payment),1) AS province_amount,
 COUNT(DISTINCT tt.sys_customer_id) AS user_counts,
 COUNT(tt.sys_trade_id) AS user_paytimes
FROM
 data_check.trade_data_topten tt
GROUP BY
 pay_year,
 province,
 city
HAVING
 pay_year=2016
ORDER BY
 province,
 user_counts DESC) tt
GROUP BY
 tt.pay_year,
 tt.province,
 tt.city)pp
ON CONCAT(LEFT(TRIM(tt.province),2),left(tt.city,2))=CONCAT(LEFT(TRIM(pp.province),2),left(pp.city,2))
LEFT JOIN data_check.top_city zz
ON CONCAT(LEFT(tt.province,2),left(tt.city,2))=CONCAT(LEFT(zz.province,2),left(zz.city,2))
WHERE
zz.province IS NOT NULL
AND
tt.province_counts>50
ORDER BY
std_province,
amounts_ratio;

# 碧生源品牌机会-品类分析机会--------基础数据处理
-- 品类分析基础数据处理
USE data_check;
-- 参数设置
SET @start_time = "2017-01-01"; -- 分析开始时间
SET @end_time = "2017-10-31"; -- 分析结束时间
SET @seller_momery = "1药网用户";
-- SET @channel_selected = ('585','586','587','588','590' ,'591','592','593','597','598');
-- SET @sys_customer_index = ROUND((SELECT MAX(sys_customer_id) FROM crm_kd.kd_customer),0);
DROP TABLE 
IF EXISTS order_data_city;
CREATE TABLE order_data_city AS
SELECT
 DISTINCT tt.out_order_id,
 tt.plat_from_id,
 tt.sys_trade_id,
 tt.sys_customer_id,
 tt.sys_item_id,
 tt.title,
 tt.outer_id,
 cc.title AS pro_title,
 tt.number,
 tt.price,
 bb.pay_time,
 bb.payment,
 bb.buyer_message,
 bb.seller_memo,
 bb.buyer_rate,
 bb.app_entrance,
 aa.out_nick,
 aa.customer_name,
 aa.mobile,
 aa.province,
 aa.city,
 aa.plat_from_type,
 aa.develop_time,
 aa.first_pay_time,
 aa.last_pay_time,
 aa.pay_times,
 aa.pay_amount,
 aa.price_unit,
 aa.item_unit,
 dd.std_pro_name,
 dd.std_pro_sku
FROM
 crm_kd.kd_order tt
LEFT JOIN
 (SELECT -- 交易订单数据根据付款时间提取信息
  tt.sys_trade_id,
  tt.pay_time,
  tt.payment,
  tt.buyer_message,
  tt.seller_memo,
  tt.buyer_rate,
  tt.app_entrance
  FROM
  crm_kd.kd_trade tt
  WHERE
  DATE_FORMAT(tt.pay_time,"%Y-%m-%d") BETWEEN @start_time AND @end_time
  AND
  tt.trade_status IN('TRADE_FINISHED','TRADE_BUYER_SIGNED','WAIT_BUYER_CONFIRM_GOODS','WAIT_SELLER_SEND_GOODS')
  AND
  tt.plat_from_id IN ('585','586','587','588','590' ,'591','592','593','597','598')
  AND
  tt.seller_memo <> "1药网用户" -- 非1药网用户
 )bb
ON tt.sys_trade_id=bb.sys_trade_id
LEFT JOIN
(SELECT -- 用户数据根据最后付款时间提取信息
 tt.sys_customer_id,
 tt.out_nick,
 tt.customer_name,
 tt.mobile,
 tt.province,
 tt.city,
 tt.plat_from_type,
 tt.develop_time,
 tt.first_pay_time,
 tt.last_pay_time,
 tt.pay_times,
 tt.pay_amount,
 tt.price_unit,
 tt.item_unit
FROM
 crm_kd.kd_customer tt
WHERE
 DATE_FORMAT(tt.last_pay_time,"%Y-%m-%d") BETWEEN @start_time AND @end_time 
AND
 tt.price_unit>20 -- 排除非主力客户
AND
 sys_customer_id NOT IN(SELECT tt.sys_customer_id FROM data_check.unnorm_customer_id tt) -- 排除部分囤货、分销用户
AND
 tt.plat_from_type <> 40)aa
ON tt.sys_customer_id =aa.sys_customer_id
LEFT JOIN
(SELECT
 tt.sys_item_id,
 tt.outer_id,
 tt.title
 FROM
 crm_kd.kd_item tt)cc
ON tt.sys_item_id = cc.sys_item_id
LEFT JOIN
 data_check.std_product dd
ON tt.outer_id = dd.outer_id
WHERE
 bb.sys_trade_id IS NOT NULL
AND
 aa.sys_customer_id IS NOT NULL
ORDER BY
 aa.pay_amount;

# -- 数据分析中品类及产品信息===========================================================
# 设置产品名称
SET @std_pro_name1 = "减肥";
SET @std_pro_name2 = "常菁";
SET @start_time1 = "2017-10-01"; -- 分析开始时间
SET @end_time1 = "2017-10-31"; -- 分析结束时间
# -- 用户竞争力热力图
DROP TABLE 
IF EXISTS thermogram_user_price;
CREATE TABLE thermogram_user_price AS
SELECT
 DATE_FORMAT(tt.pay_time,"%Y-%m-%d") AS year_mon_date,
 ROUND(tt.payment,0) AS payment_gap
 -- COUNT(DISTINCT tt.sys_trade_id) AS order_num,
 -- COUNT(DISTINCT tt.sys_customer_id) AS user_num,
 -- ROUND(SUM(tt.payment),0) AS payamount_sum
FROM
(SELECT DISTINCT
 tt.*,
 DATE_FORMAT(aa.activity_date,"%Y-%m-%d") AS activity_date
FROM
 data_check.order_data_city tt
LEFT JOIN
 data_check.activity_date aa
ON DATE_FORMAT(tt.pay_time,"%Y-%m-%d") = DATE_FORMAT(aa.activity_date,"%Y-%m-%d")
WHERE
 (LEFT(tt.std_pro_name,2) = @std_pro_name1 
OR
 LEFT(tt.std_pro_name,2) = @std_pro_name2)
AND
 DATE_FORMAT(tt.pay_time,"%Y-%m-%d") BETWEEN @start_time1 AND @end_time1)tt
-- GROUP BY
-- payment_gap;
