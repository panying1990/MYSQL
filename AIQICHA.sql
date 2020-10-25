-- 找好查询条件与返回信息之间的匹配关系
SELECT 
 SHOP_NAME,
 LEFT(SHOP_AQCID,14) AS AQCID,
 MID(SHOP_AQCID,15,LENGTH(SHOP_AQCID)-14) AS CHECK_SHOPNAME
FROM
(SELECT 
REPLACE(REPLACE(FULLPATH,"https://aiqicha.baidu.com/s?q=",''),"&t=0","") AS SHOP_NAME,
REPLACE(SUBSTRING_INDEX(门店基本信息,"/detail/compinfo?pid",2),"/detail/compinfo?pid=",'') AS SHOP_AQCID,
门店基本信息
FROM xml_shop_check)T1


-- 找到详细信息与门店之间的匹配关系
SELECT
 T2.AQCID,
 trim(T1.电话) AS 电话,
 REPLACE(trim(T1.邮箱)," 邮箱：","") AS 邮箱,
 TRIM(T1.法人代表) AS 法人代表,
 trim(T1.经营状态) AS 经营状态,
 trim(T1.所属行业) AS 所属行业,
 trim(T1.统一社会信用代码) AS 统一社会信用代码,
 trim(T1.成立时间) AS 成立时间,
 trim(T1.营业期限) AS 营业期限,
 trim(T1.行政区划) AS 行政区划,
 trim(T1.注册地址) AS 注册地址,
 trim(T1.经营范围) AS 经营范围
FROM 
 xml_shop_detail T1
LEFT JOIN 
(SELECT REPLACE(FULLPATH,"https://aiqicha.baidu.com/company_detail_","") AS AQCID,ROOT_FILE FROM XML_SHOP_DETAIL_MAP)T2 ON T1.匹配字段 = T2.ROOT_FILE
