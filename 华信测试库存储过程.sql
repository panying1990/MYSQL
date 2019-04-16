 -- calculate_similiar
 CREATE DEFINER=`root`@`%` FUNCTION `calculate_similiar`(term_name VARCHAR(64), distName VARCHAR(64)) RETURNS varchar(2) CHARSET utf8
BEGIN

DECLARE result VARCHAR(2);
	DECLARE lenA int;
	DECLARE lenB int;
	DECLARE lenSameA int;
	DECLARE lenSameB int;
	set lenA=len(StrA);
	set lenB=len(StrB);
  set term_name='aaa';
  set distName='aaa';


return result;
END

 -- currval
 
 CREATE DEFINER=`bsy`@`%` FUNCTION `currval`(seq_name VARCHAR(50)) RETURNS int(11)
BEGIN  
  DECLARE c_value BIGINT DEFAULT  0;  
  SET c_value = 0;  
  SELECT nextId into c_value
  FROM sys_sequence  
  WHERE name = seq_name;  
  RETURN c_value;  
END


-- getDistMoney
CREATE DEFINER=`root`@`%` FUNCTION `getDistMoney`(`v_year` varchar(20) , `v_month` varchar(20), `v_cust_code` varchar(20), `v_prod_type` varchar(20), `v_count` int) RETURNS int(11)
begin 
DECLARE rate int;
DECLARE quarter_code VARCHAR(20);
IF (v_month='01' || v_month='YF001') THEN SET quarter_code='1';
ELSEIF (v_month='02' || v_month='YF002') THEN SET quarter_code='1';
ELSEIF (v_month='03' || v_month='YF003') THEN SET quarter_code='1';
ELSEIF (v_month='04' || v_month='YF004') THEN SET quarter_code='2';
ELSEIF (v_month='05' || v_month='YF005') THEN SET quarter_code='2';
ELSEIF (v_month='06' || v_month='YF006') THEN SET quarter_code='2';
ELSEIF (v_month='07' || v_month='YF007') THEN SET quarter_code='3';
ELSEIF (v_month='08' || v_month='YF008') THEN SET quarter_code='3';
ELSEIF (v_month='09' || v_month='YF009') THEN SET quarter_code='3';
ELSEIF (v_month='10' || v_month='YF010') THEN SET quarter_code='4';
ELSEIF (v_month='11' || v_month='YF011') THEN SET quarter_code='4';
ELSEIF (v_month='12' || v_month='YF012') THEN SET quarter_code='4';
ELSE SET quarter_code='' ; end if;
SET @m_amt = 
(
select max(fee) from dist_check_t where 
  `year` = v_year
	and `quarter` = quarter_code
	and cust_code = v_cust_code
	and prod_type_p = v_prod_type
);
 SET rate = ROUND(IFNULL(v_count*@m_amt,'0'),4);

RETURN rate;

END

-- getFuncChildLst
CREATE DEFINER=`root`@`%` FUNCTION `getFuncChildLst`(rootId VARCHAR(1000)) RETURNS varchar(1000) CHARSET utf8
BEGIN

DECLARE sTemp VARCHAR(1000); 
DECLARE sTempChd VARCHAR(1000); 
     
SET sTemp = '$'; 
SET sTempChd =cast(rootId as CHAR); 

WHILE sTempChd is not null DO 
	 SET sTemp = concat(sTemp,',',sTempChd);
	 SELECT group_concat(FUNCTION_ID) INTO sTempChd 
     FROM AUTH_FUNCTION_T
	  WHERE FIND_IN_SET(SUP_FUNC_ID, sTempChd) > 0; 
END WHILE; 
RETURN sTemp; 

END

-- getFuncChildLst

CREATE DEFINER=`root`@`%` FUNCTION `getGroupChildLst`(rootId VARCHAR(1000)) RETURNS varchar(1000) CHARSET utf8
BEGIN

DECLARE sTemp VARCHAR(1000); 
DECLARE sTempChd VARCHAR(1000); 
     
SET sTemp = '$'; 
SET sTempChd =cast(rootId as CHAR); 

WHILE sTempChd is not null DO 
	 SET sTemp = concat(sTemp,',',sTempChd);
	 SELECT group_concat(GROUP_ID) INTO sTempChd 
     FROM AUTH_GROUP_T
	  WHERE FIND_IN_SET(PARENT_GROUP_ID, sTempChd) > 0; 
END WHILE; 
RETURN sTemp; 

END

-- getOrgChildLst
CREATE DEFINER=`root`@`%` FUNCTION `getOrgChildLst`(rootId VARCHAR(1000)) RETURNS varchar(4000) CHARSET utf8
BEGIN

DECLARE sTemp VARCHAR(4000); 
DECLARE sTempChd VARCHAR(4000); 
     
SET sTemp = '$'; 
SET sTempChd =cast(rootId as CHAR); 

WHILE sTempChd is not null DO 
	 SET sTemp = concat(sTemp,',',sTempChd);
	 SELECT group_concat(org_id) INTO sTempChd 
     FROM auth_organization_t
	  WHERE FIND_IN_SET(SUP_ORG_ID, sTempChd) > 0; 
END WHILE; 
RETURN sTemp; 

END


-- getOrgParentLst
CREATE DEFINER=`root`@`%` FUNCTION `getOrgParentLst`(rootId VARCHAR(1000)) RETURNS varchar(1000) CHARSET utf8
BEGIN

DECLARE sTemp VARCHAR(1000); 
DECLARE sTempChd VARCHAR(1000); 
     
SET sTemp = '$'; 
SET sTempChd =cast(rootId as CHAR); 

WHILE sTempChd is not null DO 
	 SET sTemp = concat(sTemp,',',sTempChd);
	 SELECT group_concat(SUP_ORG_ID) INTO sTempChd 
     FROM AUTH_ORGANIZATION_T 
	  WHERE FIND_IN_SET(ORG_ID, sTempChd) > 0; 
END WHILE; 
RETURN sTemp; 

END


-- getOrgParentNameLst
CREATE DEFINER=`root`@`%` FUNCTION `getOrgParentNameLst`(rootId VARCHAR(1000)) RETURNS varchar(1000) CHARSET utf8
BEGIN

DECLARE sTemp VARCHAR(1000); 
DECLARE sTempName VARCHAR(1000); 
DECLARE sTempChd VARCHAR(1000); 
     
SET sTemp = ''; 
SET sTempName = '';
SET sTempChd =cast(rootId as CHAR); 

WHILE sTempChd is not null DO 
	 SET sTemp = concat(sTempName,'-',sTemp);
	 SELECT group_concat(SUP_ORG_ID),org_name INTO sTempChd ,sTempName
     FROM auth_organization_t
	  WHERE FIND_IN_SET(ORG_ID, sTempChd) > 0; 
END WHILE; 
RETURN sTemp; 

END



-- getRoleChildLst
CREATE DEFINER=`root`@`%` FUNCTION `getRoleChildLst`(rootId VARCHAR(1000)) RETURNS varchar(1000) CHARSET utf8
BEGIN

DECLARE sTemp VARCHAR(1000); 
DECLARE sTempChd VARCHAR(1000); 
     
SET sTemp = '$'; 
SET sTempChd =cast(rootId as CHAR); 

WHILE sTempChd is not null DO frr
     FROM AUTH_ROLE_T
	  WHERE FIND_IN_SET(SUP_ROLE_ID, sTempChd) > 0; 
END WHILE; 
RETURN sTemp; 

END
 
 -- nextval
 CREATE DEFINER=`bsy`@`%` FUNCTION `nextval`(seq_name VARCHAR(50)) RETURNS int(11)
BEGIN  
   UPDATE sys_sequence 
   SET          nextId = nextId + 1  
   WHERE name = seq_name;  
   RETURN currval(seq_name);  
END


-- splitstr
CREATE DEFINER=`root`@`%` FUNCTION `splitstr`(termName VARCHAR(64)) RETURNS varchar(20) CHARSET utf8
BEGIN
DECLARE length int;
DECLARE charStr VARCHAR(8000);
DECLARE splitString VARCHAR(8000);
DECLARE index1 BIGINT;

SET splitString=ltrim((rtrim(splitString)));
SET index1=0;
SET length=LENGTH(splitString);
BEGIN
while (index1<length) DO
	 set charStr=right(left(splitString, index1),1);
	IF charStr<>'' THEN
	INSERT INTO newtable VALUES(charStr);
	SET index1= index1+1;
	END IF;
END WHILE; 
END;
return newtable ;
END  

-- zjk_getQuarterCode
CREATE DEFINER=`root`@`%` FUNCTION `zjk_getQuarterCode`(t_month VARCHAR(20)) RETURNS varchar(20) CHARSET utf8
BEGIN

DECLARE quarter_code VARCHAR(20) DEFAULT '';

IF t_month in ('01','02','03') THEN SET quarter_code='1';
ELSEIF t_month in ('04','05','06') THEN SET quarter_code='2';
ELSEIF t_month in ('07','08','09') THEN SET quarter_code='3';
ELSEIF t_month in ('10','11','12') THEN SET quarter_code='4';
ELSE SET quarter_code='';
END IF;

RETURN quarter_code;

END












-- p deal_b_flow_org
CREATE DEFINER=`root`@`%` PROCEDURE `deal_b_flow_org`()
BEGIN
truncate table b_flow_org;
INSERT b_flow_org (region_code,region_name,unit_code,unit_name,area_code,area_name,level )
SELECT

(SELECT SUP_ORG_ID from auth_organization_t 
where org_id=(SELECT sup_org_id from auth_organization_t where org_id=b.org_id))as '南北中国编码',
(SELECT org_name from auth_organization_t where
 org_id=(SELECT SUP_ORG_ID from auth_organization_t 
where org_id=(SELECT sup_org_id from auth_organization_t where org_id=b.org_id))) as '南北中国名称',


(SELECT sup_org_id from auth_organization_t where org_id=b.org_id) as '事业部编码',
(SELECT org_name from auth_organization_t where 
org_id=(SELECT sup_org_id from auth_organization_t where org_id=b.org_id)) as '事业部名称',


	b.org_id AS '地区编码',
	(SELECT org_name from auth_organization_t where 
org_id=b.org_id) AS '地区名称',
case (select 1 from dual) 
when  (SELECT sup_org_id from auth_organization_t where org_id=b.org_id) ='1' then 1
when  (SELECT sup_org_id from auth_organization_t where org_id=b.org_id) in ('10','20') then 2
when'碧生源'=b.ORG_NAME
 then '****'
 else 3 END

 from auth_organization_t b where b.org_id not in ('10','20','100','0') and b.SUP_ORG_ID not in ('10','20')
union
SELECT

(SELECT sup_org_id from auth_organization_t where org_id=b.org_id)  as '南北中国编码',
(SELECT org_name from auth_organization_t where 
org_id=(SELECT sup_org_id from auth_organization_t where org_id=b.org_id))as '南北中国名称',


b.org_id as '事业部编码',
	(SELECT org_name from auth_organization_t where 
org_id=b.org_id) as '事业部名称',


	null AS '地区编码',
	null AS '地区名称',
case (select 1 from dual) 
when  (SELECT sup_org_id from auth_organization_t where org_id=b.org_id) ='1' then 1
when  (SELECT sup_org_id from auth_organization_t where org_id=b.org_id) in ('10','20') then 2
when'碧生源'=b.ORG_NAME
 then '****'
 else 3 END

 from auth_organization_t b where b.org_id not in ('10','20','100','0') and b.SUP_ORG_ID  in ('10','20')
union
SELECT

b.org_id  as '南北中国编码',
	(SELECT org_name from auth_organization_t where 
org_id=b.org_id) as '南北中国名称',


null as '事业部编码',
null as '事业部名称',


	null AS '地区编码',
	null AS '地区名称',
case (select 1 from dual) 
when  (SELECT sup_org_id from auth_organization_t where org_id=b.org_id) ='1' then 1
when  (SELECT sup_org_id from auth_organization_t where org_id=b.org_id) in ('10','20') then 2
when'碧生源'=b.ORG_NAME
 then '****'
 else 3 END

 from auth_organization_t b where b.org_id  in ('10','20') ;

END


-- p deal_file_upload_f
CREATE DEFINER=`bsy`@`%` PROCEDURE `deal_file_upload_f`()
BEGIN
 DECLARE file_up_id_v VARCHAR(16);
 DECLARE base_type_v VARCHAR(4);
 DECLARE done INT DEFAULT 0; 
 
 
 -- 查询文件上传待处理的file_up_id
 DECLARE curl_file_up_ids CURSOR FOR select a.file_up_id,a.base_type from file_import_tmp a where a.flag = '0';
 -- 定义循环跳出
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 



 -- 开启遍历
 OPEN curl_file_up_ids;


    -- 循环取值
		REPEAT FETCH curl_file_up_ids INTO file_up_id_v,base_type_v;
    IF NOT done THEN
	 -- 捕获异常
     	BEGIN
					DECLARE result_code INT DEFAULT 0; -- 定义返回结果并赋初值0
					DECLARE CONTINUE  HANDLER FOR SQLEXCEPTION  SET result_code=1; -- 在执行过程中出任何异常设置result_code为1
					set autocommit=0;  -- 控制回滚
				  START TRANSACTION; -- 开始事务
					SET result_code=0;
   
					 
					if base_type_v ="1" then 
		  

						update cust_info_t a,cust_info_t_file_tmp b set
						a.dist_name=b.dist_name,
						a.dist_alias=b.dist_alias,
						a.dist_type=b.dist_type,
						a.dist_code=b.dist_code,
						a.dist_address=b.dist_address,
						a.dist_phone=b.dist_phone,
						a.dist_zip=b.dist_zip,
						a.cust_name=b.cust_name,
						a.cust_code=b.cust_code,
						a.resp_name=b.resp_name,
						a.resp_phone=b.resp_phone,
						a.contact_name=b.contact_name,
						a.contact_phone=b.contact_phone,
						a.org_code=b.org_code,
						a.area_state_id=b.area_state_id,
						a.area_state=b.area_state,
						a.area_city_id=b.area_city_id,
						a.area_city=b.area_city,
						a.area_district_id=b.area_district_id,
						a.area_district=b.area_district,
						a.area_town_id=b.area_town_id,
						a.area_town=b.area_town,
						a.sts=b.sts,
						a.start_date=NOW(),
						a.end_date=b.end_date,
						a.remark=b.remark,
					 	a.old_org_name=b.old_org_name,
						a.type_org_code=b.type_org_code,
						a.buy_channel=b.buy_channel,
						a.user_id=b.user_id,
						a.upload_type=b.upload_type,
						a.area_code=b.area_code,
						a.area_name=b.area_name,
						a.link_type=b.link_type,
						a.link_time=b.link_time,
						a.cust_flag=b.cust_flag,
						a.connection_type=b.connection_type,
						a.eas=b.eas

						where a.dist_code = b.dist_code and b.file_up_id = file_up_id_v;
						
						INSERT into cust_info_t (
						cust_info_t.id,
						cust_info_t.dist_name,
						cust_info_t.dist_alias,
						cust_info_t.dist_type,
						cust_info_t.dist_code,
						cust_info_t.dist_address,
						cust_info_t.dist_phone,
						cust_info_t.dist_zip,
						cust_info_t.cust_name,
						cust_info_t.cust_code,
						cust_info_t.resp_name,
						cust_info_t.resp_phone,
						cust_info_t.contact_name,
						cust_info_t.contact_phone,
						cust_info_t.org_code,
						cust_info_t.area_state_id,
						cust_info_t.area_state,
						cust_info_t.area_city_id,
						cust_info_t.area_city,
						cust_info_t.area_district_id,
						cust_info_t.area_district,
						cust_info_t.area_town_id,
						cust_info_t.area_town,
						cust_info_t.sts,
						cust_info_t.start_date,
						cust_info_t.end_date,
						cust_info_t.remark,
						cust_info_t.kc_up,
						cust_info_t.xs_up,
						cust_info_t.gj_up,
						cust_info_t.ps_up,
						cust_info_t.all_up,
						cust_info_t.user_id,
						cust_info_t.upload_type,
						cust_info_t.area_code,
						cust_info_t.area_name,
						cust_info_t.link_type,
						cust_info_t.link_time,
						 cust_info_t.old_org_name,
						cust_info_t.type_org_code,
						cust_info_t.buy_channel,
						cust_info_t.cust_flag,
						cust_info_t.connection_type,
						cust_info_t.eas
					)select
					nextval('cust_info_t_pk_id'),
					cust_info_t_file_tmp.dist_name,
					cust_info_t_file_tmp.dist_alias,
					cust_info_t_file_tmp.dist_type,
					cust_info_t_file_tmp.dist_code,
					cust_info_t_file_tmp.dist_address,
					cust_info_t_file_tmp.dist_phone,
					cust_info_t_file_tmp.dist_zip,
					cust_info_t_file_tmp.cust_name,
					cust_info_t_file_tmp.cust_code,
					cust_info_t_file_tmp.resp_name,
					cust_info_t_file_tmp.resp_phone,
					cust_info_t_file_tmp.contact_name,
					cust_info_t_file_tmp.contact_phone,
					cust_info_t_file_tmp.org_code,
					cust_info_t_file_tmp.area_state_id,
					cust_info_t_file_tmp.area_state,
					cust_info_t_file_tmp.area_city_id,
					cust_info_t_file_tmp.area_city,
					cust_info_t_file_tmp.area_district_id,
					cust_info_t_file_tmp.area_district,
					cust_info_t_file_tmp.area_town_id,
					cust_info_t_file_tmp.area_town,
					cust_info_t_file_tmp.sts,
					cust_info_t_file_tmp.start_date,
					cust_info_t_file_tmp.end_date,
					cust_info_t_file_tmp.remark,
					'1',-- 	cust_info_t_file_tmp.kc_up,
					'1',-- cust_info_t_file_tmp.xs_up,
					'0',-- cust_info_t_file_tmp.gj_up,
					'0',-- cust_info_t_file_tmp.ps_up,
					'0',-- cust_info_t_file_tmp.all_up,
					cust_info_t_file_tmp.user_id,
					cust_info_t_file_tmp.upload_type,
					cust_info_t_file_tmp.area_code,
					cust_info_t_file_tmp.area_name,
					cust_info_t_file_tmp.link_type,
					cust_info_t_file_tmp.link_time,

						 cust_info_t_file_tmp.old_org_name, 
						cust_info_t_file_tmp.type_org_code,
						cust_info_t_file_tmp.buy_channel,
					cust_info_t_file_tmp.cust_flag,
					cust_info_t_file_tmp.connection_type,
					cust_info_t_file_tmp.eas
					from cust_info_t_file_tmp where cust_info_t_file_tmp.file_up_id = file_up_id_v 
					and not EXISTS 
					(select dist_code from cust_info_t where cust_info_t.dist_code =cust_info_t_file_tmp.dist_code );
			
				
		ELSEIF base_type_v = "2" THEN
		 
					update term_info_t a,term_info_t_file_tmp b set
					a.term_name =b.term_name,
					a.term_code=b.term_code,
					a.org_code=b.org_code,
					a.area_code=b.area_code,
					a.area_name=b.area_name,
					a.term_type=b.term_type,
					a.term_channel=b.term_channel,
					a.trem_address=b.trem_address,
					a.contacts=b.contacts,
					a.phone=b.phone,
					a.level_name=b.level_name,
					a.resp_man=b.resp_man,
					 a.seller=b.seller,
					 a.city_code=b.city_code,
					 a.city_name=b.city_name,
					 a.link_system=b.link_system,
					a.area_state=b.area_state,
					a.area_state_id=b.area_state_id,
					a.area_city=b.area_city,
					a.area_city_id=b.area_city_id,
					a.area_district=b.area_district,
					a.area_district_id=b.area_district_id,
					a.area_town=b.area_town,
					a.area_town_id=b.area_town_id,
					a.sts=b.sts,	
					a.remark_2=b.remark_2,		 
					a.update_date=NOW(),
					a.create_way=b.create_way
					where a.term_code = b.term_code and b.file_up_id = file_up_id_v;

					insert into  term_info_t(	
					term_info_t.id,
					term_info_t.TERM_NAME,
					term_info_t.TERM_ALIAS,
					term_info_t.TERM_CODE,
					term_info_t.OUT_CODE,
					term_info_t.ORG_CODE,
					term_info_t.AREA_CODE,
					term_info_t.AREA_NAME,
					term_info_t.TERM_TYPE,
					term_info_t.TERM_PROPERTY,
					term_info_t.OTHER_NAME,
					term_info_t.TERM_CHANNEL,
					term_info_t.TREM_ADDRESS,
					term_info_t.CONTACTS,
					term_info_t.PHONE,
					term_info_t.LEVEL_NAME,
					term_info_t.MATCH_STS,
					term_info_t.REMARK_1,
					term_info_t.REMARK_2,
					term_info_t.REMARK_3,
					term_info_t.REMARK_4,
					term_info_t.RESP_MAN,
					term_info_t.POST,
					term_info_t.KIND,
					term_info_t.STS,
					term_info_t.CREATE_BY,
					term_info_t.CREATE_DATE,
					term_info_t.UPDATE_BY,
					term_info_t.UPDATE_DATE,
					term_info_t.CREATE_WAY)
					SELECT 
					  nextval('term_info_t_id'),
					term_info_t_file_tmp.TERM_NAME,
					term_info_t_file_tmp.TERM_ALIAS,
					term_info_t_file_tmp.TERM_CODE,
					term_info_t_file_tmp.OUT_CODE,
					term_info_t_file_tmp.ORG_CODE,
					term_info_t_file_tmp.AREA_CODE,
					term_info_t_file_tmp.AREA_NAME,
					term_info_t_file_tmp.TERM_TYPE,
					term_info_t_file_tmp.TERM_PROPERTY,
					term_info_t_file_tmp.OTHER_NAME,
					term_info_t_file_tmp.TERM_CHANNEL,
					term_info_t_file_tmp.TREM_ADDRESS,
					term_info_t_file_tmp.CONTACTS,
					term_info_t_file_tmp.PHONE,
					term_info_t_file_tmp.LEVEL_NAME,
					term_info_t_file_tmp.MATCH_STS,
					term_info_t_file_tmp.REMARK_1,
					term_info_t_file_tmp.REMARK_2,
					term_info_t_file_tmp.REMARK_3,
					term_info_t_file_tmp.REMARK_4,
					term_info_t_file_tmp.RESP_MAN,
					term_info_t_file_tmp.POST,
					term_info_t_file_tmp.KIND,
					term_info_t_file_tmp.STS,
					term_info_t_file_tmp.CREATE_BY,
					NOW(),-- term_info_t_file_tmp.CREATE_DATE,
					term_info_t_file_tmp.UPDATE_BY,
					NOW(),-- term_info_t_file_tmp.UPDATE_DATE,
					term_info_t_file_tmp.CREATE_WAY
					from term_info_t_file_tmp  where term_info_t_file_tmp.file_up_id = file_up_id_v 
					and not EXISTS 
					(select term_code from term_info_t where term_info_t.term_code =term_info_t_file_tmp.term_code );

									 

			ELSEIF base_type_v = '3' THEN
		      drop table   IF EXISTS sale_delete_id_temporary ;
					create temporary table sale_delete_id_temporary  select id from sale_template_t a  where EXISTS (
					SELECT 1 from sale_template_t_file_tmp b where
					a.cust_id=b.cust_id and a.up_cycle=b.up_cycle and b.file_up_id = file_up_id_v );
	        delete from sale_template_t where id in ( select id from sale_delete_id_temporary);
					 
						INSERT into sale_template_t (
								sale_template_t.UP_ID,
								sale_template_t.CUST_ID,
								sale_template_t.UP_CYCLE,
								sale_template_t.OR_NBR,
								sale_template_t.OR_TYPE,
								sale_template_t.TERM_CODE,
								sale_template_t.TERM_NAME,
								sale_template_t.TERM_ADDRESS,
								sale_template_t.PROD_CODE,
								sale_template_t.PROD_NAME,
								sale_template_t.PROD_SPEC,
								sale_template_t.PROD_BATCH,
								sale_template_t.PROD_UNIT,
								sale_template_t.VALID_DATE,
								sale_template_t.PROD_COUNT,
								sale_template_t.PROD_PRICE,
								sale_template_t.PROD_MONEY,
								sale_template_t.SALE_DATE,
								sale_template_t.validate_result
				) SELECT 
								(0-sale_template_t_file_tmp.file_up_id),
							  sale_template_t_file_tmp.CUST_ID,

							  sale_template_t_file_tmp.UP_CYCLE,
								sale_template_t_file_tmp.OR_NBR,
								sale_template_t_file_tmp.OR_TYPE,
								sale_template_t_file_tmp.TERM_CODE,
								sale_template_t_file_tmp.TERM_NAME,
								sale_template_t_file_tmp.TERM_ADDRESS,
								sale_template_t_file_tmp.PROD_CODE,
								sale_template_t_file_tmp.PROD_NAME,
								sale_template_t_file_tmp.PROD_SPEC,
								sale_template_t_file_tmp.PROD_BATCH,
								sale_template_t_file_tmp.PROD_UNIT,
								sale_template_t_file_tmp.VALID_DATE,
								sale_template_t_file_tmp.PROD_COUNT,
								sale_template_t_file_tmp.PROD_PRICE,
								sale_template_t_file_tmp.PROD_MONEY,
								sale_template_t_file_tmp.SALE_DATE,
								'0'
				from sale_template_t_file_tmp
				where sale_template_t_file_tmp.file_up_id = file_up_id_v 
				and not EXISTS 
				(select up_cycle,cust_id from sale_template_t where sale_template_t.cust_id =sale_template_t_file_tmp.cust_id
				and sale_template_t.up_cycle = sale_template_t_file_tmp.up_cycle);

					-- 增加主表信息
						INSERT into up_load_main 
						(up_id,
						 or_type,
             or_sts,
						 deal_flag,
						 create_date)
						 VALUES (
							(0-file_up_id_v),
							'1',
							'0',
							'3',
							NOW()
             );						

				 

				ELSEIF base_type_v = '4' THEN
					drop table  IF EXISTS stock_delete_id_temp ;
					create temporary table stock_delete_id_temp  select id from stock_template_t a  where EXISTS (
					SELECT 1 from stock_template_t_file_tmp b where
					a.cust_id=b.cust_id and a.up_cycle=b.up_cycle and b.file_up_id = file_up_id_v );
	        delete from stock_template_t where id in ( select id from stock_delete_id_temp);
 
						INSERT into stock_template_t (
								stock_template_t.UP_ID,
								stock_template_t.CUST_ID,
								stock_template_t.UP_CYCLE,
								stock_template_t.stock_TYPE,
								stock_template_t.TERM_CODE,
								stock_template_t.TERM_NAME,
								stock_template_t.PROD_CODE,
								stock_template_t.PROD_NAME,
								stock_template_t.PROD_SPEC,
								stock_template_t.PROD_BATCH,
								stock_template_t.PROD_UNIT,
								stock_template_t.VALID_DATE,
								stock_template_t.PROD_COUNT,
								stock_template_t.PROD_PRICE,
								stock_template_t.PROD_MONEY,
								stock_template_t.STOCK_DATE,
								stock_template_t.validate_result
				) SELECT 
								(0-stock_template_t_file_tmp.file_up_id),
							  stock_template_t_file_tmp.CUST_ID,
								stock_template_t_file_tmp.UP_CYCLE,
								stock_template_t_file_tmp.Stock_TYPE,
								stock_template_t_file_tmp.TERM_CODE,
								stock_template_t_file_tmp.TERM_NAME,						 
								stock_template_t_file_tmp.PROD_CODE,
								stock_template_t_file_tmp.PROD_NAME,
								stock_template_t_file_tmp.PROD_SPEC,
								stock_template_t_file_tmp.PROD_BATCH,
								stock_template_t_file_tmp.PROD_UNIT,
								stock_template_t_file_tmp.VALID_DATE,
								stock_template_t_file_tmp.PROD_COUNT,
								stock_template_t_file_tmp.PROD_PRICE,
								stock_template_t_file_tmp.PROD_MONEY,
								stock_template_t_file_tmp.stock_date,
								'0'
				from stock_template_t_file_tmp
				where stock_template_t_file_tmp.file_up_id = file_up_id_v 
				and not EXISTS 
				(select up_cycle,cust_id from stock_template_t where stock_template_t.cust_id =stock_template_t_file_tmp.cust_id
				and stock_template_t.up_cycle = stock_template_t_file_tmp.up_cycle);
        
					 	-- 增加主表信息
						INSERT into up_load_main 
						(up_id,
						 or_type,
             or_sts,
						 deal_flag,
						 create_date)
						 VALUES (
							(0-file_up_id_v),
							'2',
							'0',
							'3' ,
							NOW()
             );	
				
			ELSEIF base_type_v = '5' THEN
		     DELETE a from buy_template_t a , (select DISTINCT file_up_id,cust_id,up_cycle from buy_template_t_file_tmp ) b where
					a.cust_id=b.cust_id and a.up_cycle=b.up_cycle and b.file_up_id = file_up_id_v ;
					 
						INSERT into buy_template_t (
								buy_template_t.UP_ID,
								buy_template_t.CUST_ID,
								buy_template_t.UP_CYCLE,
								buy_template_t.OR_NBR,
								buy_template_t.OR_TYPE,
								buy_template_t.BUYER_CODE,
								buy_template_t.BUYER_NAME,
								buy_template_t.BUYER_ADDRESS,
								buy_template_t.PROD_CODE,
								buy_template_t.PROD_NAME,
								buy_template_t.PROD_SPEC,
								buy_template_t.PROD_BATCH,
								buy_template_t.PROD_UNIT,
								buy_template_t.VALID_DATE,
								buy_template_t.PROD_COUNT,
								buy_template_t.PROD_PRICE,
								buy_template_t.PROD_MONEY,
								buy_template_t.SALE_DATE,
								buy_template_t.validate_result
				) SELECT 
								CONCAT("-",file_up_id_v),
							  buy_template_t_file_tmp.CUST_ID,

							  buy_template_t_file_tmp.UP_CYCLE,
								buy_template_t_file_tmp.OR_NBR,
								buy_template_t_file_tmp.OR_TYPE,
								buy_template_t_file_tmp.BUYER_CODE,
								buy_template_t_file_tmp.BUYER_NAME,
								buy_template_t_file_tmp.BUYER_ADDRESS,
								buy_template_t_file_tmp.PROD_CODE,
								buy_template_t_file_tmp.PROD_NAME,
								buy_template_t_file_tmp.PROD_SPEC,
								buy_template_t_file_tmp.PROD_BATCH,
								buy_template_t_file_tmp.PROD_UNIT,
								buy_template_t_file_tmp.VALID_DATE,
								buy_template_t_file_tmp.PROD_COUNT,
								buy_template_t_file_tmp.PROD_PRICE,
								buy_template_t_file_tmp.PROD_MONEY,
								buy_template_t_file_tmp.SALE_DATE,
								'0'
				from buy_template_t_file_tmp
				where buy_template_t_file_tmp.file_up_id = file_up_id_v ;
				
DELETE from up_load_main where up_id = CONCAT("-",file_up_id_v);
					-- 增加主表信息
						INSERT into up_load_main 
						(up_id,
						 or_type,
             or_sts,
						 deal_flag,
						 create_date)
						 VALUES (
							(0-file_up_id_v),
							'3',
							'0',
							'3',
							NOW()
             );				
				end if;
    
		IF result_code = 1 THEN -- 可以根据不同的业务逻辑错误返回不同的result_code，这里只定义了1和0
						ROLLBACK; 
				ELSE 
 update file_import_tmp set flag = '2',op_date=NOW() where file_up_id = file_up_id_v; 
    
						COMMIT; 
				END IF;
		select result_code,file_up_id_v,done;
		END ;	 

		end if; 
UNTIL done END REPEAT;
		
 CLOSE curl_file_up_ids;
	
END


end



--  p deal_prod_data_check

CREATE DEFINER=`sds`@`%` PROCEDURE `deal_prod_data_check`()
BEGIN
	DECLARE prod_name_v VARCHAR(256);
  DECLARE prod_spec_v VARCHAR(256);
	DECLARE prod_id_v VARCHAR(32);
DECLARE prod_template_id_v VARCHAR(128);
  DECLARE done INT DEFAULT 0;  
  DECLARE count INT; 
	DECLARE curl_prod CURSOR FOR select a.prod_subside_name,a.prod_subside_spec,a.prod_subside_id FROM `prod_subside_t` a where a.match_state = 'C1';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;
OPEN curl_prod;
		 emp_loop: LOOP  
			 FETCH curl_prod  INTO prod_name_v,prod_spec_v,prod_id_v;
			 IF done=1 THEN  
					LEAVE emp_loop; 
			 END IF; 
				  select count(1) into count FROM `product_info_t`   where prod_name = prod_name_v and prod_spec = prod_spec_v;
					if count> 0 THEN
							update `prod_subside_t` a set a.prod_template_id = ( select id FROM `product_info_t`   where prod_name = prod_name_v and prod_spec = prod_spec_v LIMIT 1)
							,a.match_state ='A' where a.prod_subside_id =prod_id_v;
					ELSE
						 update `prod_subside_t` a set a.match_state ='C' where a.prod_subside_id =prod_id_v;
					end if;

     END LOOP emp_loop;  
CLOSE curl_prod;

END



-- p deal_t_flow_base
CREATE DEFINER=`root`@`%` PROCEDURE `deal_t_flow_base`()
BEGIN
	truncate  table `sds`.`t_flow_base`;
	INSERT INTO `sds`.`t_flow_base` (
	 
	`region_code`,
	`region_name`,
	`unit_code`,
	`unit_name`,
	`area_code`,
	`area_name`,
	`pro_code`,
	`pro_name`,
	`year`,
	`month`,
	`doc_type`,
	`cnt`,
	`amt` 
)


SELECT bbb.region_code,bbb.region_name,bbb.unit_code,bbb.unit_name,bbb.area_code,bbb.area_name,
aaa.pro_code,(
		SELECT
			func_name
		FROM
			sys_code_t
		WHERE
			model_code = '296'
		AND func_code = aaa.pro_code
	) AS pro_name,
	 substr(
		aaa.up_cycle,
		1,
		4
	) AS '年份',
	concat(
		'YF0',
		substr(
			aaa.up_cycle,
			6,
			7
		)
	) AS '月份','T1出货',aaa.count,aaa.money from (
SELECT
	case when (select sup_org_id from auth_organization_t where ORG_ID = b.org_code )
  = (select sup_org_id from auth_organization_t where ORG_ID = ac.org_code )
 and (select sup_org_id from auth_organization_t where ORG_ID = ac.org_code )not in ('109000','110000')
	then  ac.org_code
	ELSE
b.org_code
	end org_code,
	ab.prod_sys_type AS pro_code,
	a.up_cycle,
	sum(a.prod_count) AS count,
	ifnull(
		round(
			(
				sum(
					ab.prod_price * a.prod_count
				)
			),
			2
		),
		0
	) AS money
FROM
	sale_template_t a
LEFT JOIN prod_subside_t aa ON a.prod_subside_id = aa.prod_subside_id
LEFT JOIN product_info_t ab ON aa.prod_template_id = ab.id
LEFT JOIN term_subside_t ac ON a.term_subside_id = ac.term_subside_id,
 cust_info_t b,
 up_load_main c
WHERE
	a.cust_id = b.id
AND a.up_id = c.up_id
AND c.deal_flag = '0'
AND b.dist_type = '1'

GROUP BY 1,2,3 ) aaa , b_flow_org bbb 
where aaa.org_code = bbb.area_code;
INSERT INTO `sds`.`t_flow_base` (
	 
	`region_code`,
	`region_name`,
	`unit_code`,
	`unit_name`,
	`area_code`,
	`area_name`,
	`pro_code`,
	`pro_name`,
	`year`,
	`month`,
	`doc_type`,
	`cnt`,
	`amt` 
)
SELECT bbb.region_code,bbb.region_name,bbb.unit_code,bbb.unit_name,bbb.area_code,bbb.area_name,
aaa.pro_code,(
		SELECT
			func_name
		FROM
			sys_code_t
		WHERE
			model_code = '296'
		AND func_code = aaa.pro_code
	) AS pro_name,
	 substr(
		aaa.up_cycle,
		1,
		4
	) AS '年份',
	concat(
		'YF0',
		substr(
			aaa.up_cycle,
			6,
			7
		)
	) AS '月份','连锁纯销',aaa.count,aaa.money from (
SELECT
b.org_code AS org_code,
	ab.prod_sys_type AS pro_code,
	a.up_cycle,
	sum(a.prod_count) AS count,
	ifnull(
		round(
			(
				sum(
					a.prod_count * d.fee
				)
			),
			2
		),
		0
	) AS money
FROM
	sale_template_t a
LEFT JOIN prod_subside_t aa ON a.prod_subside_id = aa.prod_subside_id
LEFT JOIN product_info_t ab ON aa.prod_template_id = ab.id
LEFT JOIN term_subside_t ac ON a.term_subside_id = ac.term_subside_id,
 cust_info_t b,
 up_load_main c,
dist_check_t d
WHERE
	a.cust_id = b.id
AND a.up_id = c.up_id
AND c.deal_flag = '0'
AND b.dist_type = '3'

and b.cust_code = d.cust_code and d.prod_type_p = ab.prod_type and d.`year` = substr(
		a.up_cycle,
		1,
		4
	) and d.`quarter` = zjk_getQuarterCode(substr(a.up_cycle,6,7)) 
GROUP BY 1,2,3 ) aaa , b_flow_org bbb 
where aaa.org_code = bbb.area_code;
end

end


-- p deal_t_flow_stock
CREATE DEFINER=`root`@`%` PROCEDURE `deal_t_flow_stock`()
BEGIN
	truncate  table  `sds`.`t_flow_stock`;
	INSERT INTO `sds`.`t_flow_stock` (
	 
	`region_code`,
	`region_name`,
	`unit_code`,
	`unit_name`,
	`area_code`,
	`area_name`,
	`pro_code`,
	`pro_name`,
	`year`,
	`month`,
	`pro_num`,
	`cnt`,
	`amt`
)SELECT

(SELECT SUP_ORG_ID from auth_organization_t 
where org_id=(SELECT sup_org_id from auth_organization_t where org_id=b.org_code)) ,


(SELECT org_name from auth_organization_t where
 org_id=(SELECT SUP_ORG_ID from auth_organization_t 
where org_id=(SELECT sup_org_id from auth_organization_t where org_id=b.org_code)))  ,
 
(SELECT sup_org_id from auth_organization_t where org_id=b.org_code)  ,

(SELECT org_name from auth_organization_t where 
org_id=(SELECT sup_org_id from auth_organization_t where org_id=b.org_code))  ,

b.org_code ,

	(SELECT org_name from auth_organization_t where 
org_id=b.org_code)  , 

	d.prod_sys_type AS '产品编码',
	(select func_name from sys_code_t where model_code='296' and func_code=d.prod_sys_type) AS '产品名称',
	substr(
		stock_template_t.up_cycle,
		1,
		4
	) AS '年份',
	concat('YF0', substr(
		stock_template_t.up_cycle,
		6,
		7
	)) AS '月份',
	stock_template_t.prod_batch AS '批号',
	sum(stock_template_t.prod_count) AS '数量',

	IFNULL(sum(round(
		(
			d.prod_price * stock_template_t.prod_count
		),
		2
	)),0) AS '金额'
FROM
	stock_template_t
LEFT JOIN prod_subside_t e ON stock_template_t.prod_subside_id = e.prod_subside_id
LEFT JOIN product_info_t d ON d.id = e.prod_template_id,
 cust_info_t b,
 up_load_main c
WHERE
	b.id = stock_template_t.cust_id
AND c.up_id = stock_template_t.up_id
AND c.deal_flag = '0'

and b.dist_type='1'
 GROUP BY 
1,2,3,4,5,6,7,8,9,10,11 ;

END


-- p deal_term_data_check
CREATE DEFINER=`sds`@`%` PROCEDURE `deal_term_data_check`()
BEGIN
	DECLARE term_name_v VARCHAR(256);
	DECLARE term_id_v VARCHAR(32);
  DECLARE term_template_id_v  VARCHAR(32);
  DECLARE done INT DEFAULT 0;  
  DECLARE count INT; 
  DECLARE count1 INT; 
	DECLARE curl_main CURSOR FOR select term_subside_name,term_subside_id FROM `term_subside_t` where match_state = 'C1';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;  
  OPEN curl_main;
		REPEAT FETCH curl_main INTO term_name_v,term_id_v;
IF NOT done THEN
    select count(1) into count FROM `cust_info_t` where dist_name = term_name_v;
		if count>0  THEN
				update `term_subside_t` a set a.match_type ='1' , a.term_template_id = (select cust_info_t.id  FROM `cust_info_t` where dist_name = term_name_v LIMIT 1) 
				,a.match_state ='A',a.org_code = (select cust_info_t.org_code  FROM `cust_info_t` where dist_name = term_name_v LIMIT 1) where a.term_subside_id =term_id_v;
		ELSE
			select count(1)  into count1 from term_info_t a where a.term_name = term_name_v;
			if count1 > 0 THEN
					update `term_subside_t` a set a.match_type ='2' , a.term_template_id = (select a.id   from term_info_t a where a.term_name = term_name_v LIMIT 1 ) 
				  ,a.match_state ='A',a.org_code = (select a.org_code  from term_info_t a where a.term_name = term_name_v LIMIT 1 )  where a.term_subside_id =term_id_v;
			ELSE
					update `term_subside_t` a set a.match_state ='C' where a.term_subside_id =term_id_v;
			end if;
		end if;
end if;
    UNTIL done END REPEAT;
 CLOSE curl_main;
END


-- p deal_term_data_count
CREATE DEFINER=`root`@`%` PROCEDURE `deal_term_data_count`()
BEGIN
update `term_subside_t` a   set a.sale_count = null ,a.buy_count = null ,a.give_count = null ,a.stock_count =null;

create temporary table tmp_table_sale select  term_subside_id, SUM(prod_count) count from `sale_template_t`
where date_format(sale_date,'%Y-%m') = date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1
union 
select  term_subside_id, 0 from `sale_template_t`
where date_format(sale_date,'%Y-%m') != date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1;
update `term_subside_t` a,tmp_table_sale b  set a.sale_count =  b.count   where a.term_subside_id =b.term_subside_id;
create temporary table tmp_table_stock select  term_subside_id, SUM(prod_count) count from `stock_template_t`
where date_format(stock_date,'%Y-%m') = date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1
union
select  term_subside_id, SUM(prod_count) count from `stock_template_t`
where date_format(stock_date,'%Y-%m') != date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1;
update `term_subside_t` a  , tmp_table_stock b set a.stock_count = b.count where a.term_subside_id =b.term_subside_id;
create temporary table tmp_table_give select  term_subside_id, SUM(prod_count) count from `give_template_t`
where date_format(sale_date,'%Y-%m') = date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1
union
select  term_subside_id, SUM(prod_count) count from `give_template_t`
where date_format(sale_date,'%Y-%m') = date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1;
update `term_subside_t` a , tmp_table_give b set a.give_count = b.count  where a.term_subside_id =b.term_subside_id;
create temporary table tmp_table_buy select  term_subside_id, SUM(prod_count) count from `buy_template_t` 
where date_format(sale_date,'%Y-%m') = date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1
union
select  term_subside_id, SUM(prod_count) count from `buy_template_t` 
where date_format(sale_date,'%Y-%m') = date_format(DATE_SUB(curdate(), INTERVAL 1 MONTH),'%Y-%m')
and up_id in (select up_id from up_load_main where deal_flag = '0' )
GROUP BY 1;
update `term_subside_t` a , tmp_table_buy b set a.buy_count = b.count  where a.term_subside_id =b.term_subside_id;
END


-- p deal_zl_task_cur
CREATE DEFINER=`root`@`%` PROCEDURE `deal_zl_task_cur`()
BEGIN
	-- 插入三条数据： 销售、库存、购进  
	-- 开始布置任务
  
 -- 布置销售任务
	insert into zl_task_t(
		zl_task_t.task_code, 			   -- 编码，格式YYYY_mm_dd_type
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel	
		zl_task_t.task_start_time,	 -- 数据开始时间
		zl_task_t.task_end_time,  	 -- 数据结束时间
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_num,					 -- 数据处理条数  更新的条数
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask ,				 -- 任务名
		zl_task_t.exe_num	, 				 -- 执行次数
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(
		CONCAT(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'02'),
		'02',
		'01',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 00:00:00'),
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 23:59:59'),
		'01',
		null,
		'01',
		'统计日销售数据任务',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
		

);

-- 布置购进任务
	insert into zl_task_t(
		zl_task_t.task_code, 			   -- 编码，格式YYYY_mm_dd_type
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel	
		zl_task_t.task_start_time,	 -- 数据开始时间
		zl_task_t.task_end_time,  	 -- 数据结束时间
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_num,					 -- 数据处理条数  更新的条数
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask,				 -- 任务名
		zl_task_t.exe_num, 				   -- 执行次数
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(
		CONCAT(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'02'),
		'02',
		'02',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 00:00:00'),
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 23:59:59'),
		'01',
		null,
		'01',
		'统计日购进数据任务',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
		

);
-- 布置库存任务
	insert into zl_task_t(
		zl_task_t.task_code, 			   -- 编码，格式YYYY_mm_dd_type
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel	
		zl_task_t.task_start_time,	 -- 数据开始时间
		zl_task_t.task_end_time,  	 -- 数据结束时间
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_num,					 -- 数据处理条数  更新的条数
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask,				 -- 任务名
		zl_task_t.exe_num, 				   -- 执行次数
		zl_task_t.birth_time				 -- 创建任务时间
	
	
)VALUES(
		CONCAT(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'02'),
		'02',
		'03',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 00:00:00'),
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 23:59:59'),
		'01',
		null,
		'01',
		'统计日库存数据任务',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
		

);


END


-- p deal_zl_task_mon
CREATE DEFINER=`root`@`%` PROCEDURE `deal_zl_task_mon`()
BEGIN
	-- 插入三条数据： 销售、库存、购进  
	-- 开始布置任务
  -- 处理月数据
  
 -- 布置销售任务
	insert into zl_task_t(
		zl_task_t.task_code, 			   -- 编码，格式YYYY_mm_dd_type
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel	
		zl_task_t.task_start_time,	 -- 数据开始时间
		zl_task_t.task_end_time,  	 -- 数据结束时间
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_num,					 -- 数据处理条数  更新的条数
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask, 				 -- 任务名
		zl_task_t.exe_num, 				   -- 执行次数
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(
		CONCAT(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01'),
		'01',
		'01',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 00:00:00'),
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 23:59:59'),
		'01',
		null,
		'01',
		'统计月销售数据任务',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
		

);

-- 布置购进任务
	insert into zl_task_t(
		zl_task_t.task_code, 			   -- 编码，格式YYYY_mm_dd_type
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel	
		zl_task_t.task_start_time,	 -- 数据开始时间
		zl_task_t.task_end_time,  	 -- 数据结束时间
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_num,					 -- 数据处理条数  更新的条数
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask, 				 -- 任务名
		zl_task_t.exe_num, 				   -- 执行次数
		zl_task_t.birth_time				 -- 创建任务时间
)VALUES(
		CONCAT(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01'),
		'01',
		'02',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 00:00:00'),
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 23:59:59'),
		'01',
		null,
		'01',
		'统计月购进数据任务',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
		

);
-- 布置库存任务
	insert into zl_task_t(
		zl_task_t.task_code, 			   -- 编码，格式YYYY_mm_dd_type
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel	
		zl_task_t.task_start_time,	 -- 数据开始时间
		zl_task_t.task_end_time,  	 -- 数据结束时间
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_num,					 -- 数据处理条数  更新的条数
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask, 				 -- 任务名
		zl_task_t.exe_num, 				   -- 执行次数
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(
		CONCAT(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01'),
		'01',
		'03',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 00:00:00'),
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 23:59:59'),
		'01',
		null,
		'01',
		'统计月库存数据任务',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
		

);

-- 布置excel任务
	insert into zl_task_t(
		zl_task_t.task_code, 			   -- 编码，格式YYYY_mm_dd_type
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel	
		zl_task_t.task_start_time,	 -- 数据开始时间
		zl_task_t.task_end_time,  	 -- 数据结束时间
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_num,					 -- 数据处理条数  更新的条数
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask, 				 -- 任务名
		zl_task_t.exe_num, 				   -- 执行次数
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(
		CONCAT(DATE_FORMAT(SYSDATE(),'%Y%m%d'),'01'),
		'01',
		'04',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 00:00:00'),
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d 23:59:59'),
		'01',
		null,
		'01',
		'统计月excel数据任务',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
		

);
END


-- p zl_dealproter_task
CREATE DEFINER=`root`@`%` PROCEDURE `zl_dealproter_task`()
BEGIN
	-- 开始布置任务
  
 -- 布置zl_disposed_dealer_mon任务
	insert into zl_task_t(
		
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel,05	zl_disposed_dealer_mon ，06 zl_disposed_product_mon ， 07 zl_disposed_terminal_mon
		
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask ,				 -- 任务名
		zl_task_t.exe_num,
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(		
		'01',
		'05',
		'01',
		'01',
		'同步disposed_dealer_mon',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
);

 -- 布置zl_disposed_product_mon任务
	insert into zl_task_t(
		
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel,05	zl_disposed_dealer_mon ，06 zl_disposed_product_mon ， 07 zl_disposed_terminal_mon
		
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		
		zl_task_t.task_mask ,				 -- 任务名
		zl_task_t.exe_num,
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(		
		'01',
		'06',
		'01',
		'01',
		'同步disposed_product_mon',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
);

 -- 布置zl_disposed_terminal_mon任务
	insert into zl_task_t(
		
		zl_task_t.task_sub_type,		 -- 区分是日数据还是月数据 01：月数据 02：日数据
		zl_task_t.task_type,				 -- 判断任务类型 01销售、02购进，03库存,04excel,05	zl_disposed_dealer_mon ，06 zl_disposed_product_mon ， 07 zl_disposed_terminal_mon
		
		zl_task_t.task_sts,					 -- 数据处理状态 01:未处理 02:处理中 03:处理完
		zl_task_t.task_deal_sts,     -- 抽取状态 01 未抽取 02 抽取中 03抽取完
		zl_task_t.task_mask ,				 -- 任务名
		zl_task_t.exe_num,
		zl_task_t.birth_time				 -- 创建任务时间
	
)VALUES(		
		'01',
		'07',
		'01',
		'01',
		'同步zl_disposed_terminal_mon',
		'0',
		DATE_FORMAT(SYSDATE(),'%Y-%m-%d %T')
);

END

-- zl_inv_difference_task
CREATE DEFINER=`root`@`%` PROCEDURE `zl_inv_difference_task`(inv_date VARCHAR(100))
BEGIN
	DECLARE invmon_id_v int DEFAULT 0;
	DECLARE invmon_PRODUCT_NAME_v VARCHAR(100);
	DECLARE invmon_CUSTOMER_NAME_v VARCHAR(100);
	DECLARE invmon_QUANTITY_v VARCHAR(100);
	DECLARE invcur_id_v int DEFAULT 0;
	DECLARE invcur_PRODUCT_NAME_v VARCHAR(100);
	DECLARE invcur_CUSTOMER_NAME_v VARCHAR(100);
	DECLARE invcur_QUANTITY_v VARCHAR(100);
	DECLARE done INT DEFAULT 0; 

  DECLARE curl_inv_mon_info CURSOR FOR	
				SELECT  invmon.ID,	
								invmon.PRODUCT_NAME,	
								invmon.CUSTOMER_NAME,
								invmon.QUANTITY
				FROM		zl_disposed_inv_mon invmon
				inner join zl_disposed_inv_cur zlcur on invmon.ID =zlcur.ID
				WHERE	NOT EXISTS (	
					SELECT invcur.ID FROM	zl_disposed_inv_cur invcur
					WHERE	 invmon.ID = invcur.ID 	AND invmon.PRODUCT_NAME = invcur.PRODUCT_NAME		
						AND invmon.CUSTOMER_NAME=invcur.CUSTOMER_NAME		AND invmon.QUANTITY=invcur.QUANTITY 
						)
					and DATE_FORMAT(zlcur.inv_date,'%Y%m')=inv_date;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
-- 开启游标
	OPEN curl_inv_mon_info;
  -- 循环取值
		REPEAT FETCH curl_inv_mon_info INTO invmon_id_v,							
																				invmon_PRODUCT_NAME_v,
																				invmon_CUSTOMER_NAME_v,
																				invmon_QUANTITY_v;
			IF NOT done THEN
			BEGIN
					select 
								zl_disposed_inv_cur.PRODUCT_NAME,
								zl_disposed_inv_cur.CUSTOMER_NAME,
								zl_disposed_inv_cur.QUANTITY 
					into  invcur_PRODUCT_NAME_v,
								invcur_CUSTOMER_NAME_v,
								invcur_QUANTITY_v  	
					from zl_disposed_inv_cur
					where zl_disposed_inv_cur.ID = invmon_id_v;	

			IF	invcur_PRODUCT_NAME_v != invmon_PRODUCT_NAME_v THEN
				insert into zl_disposed_inv_difference(
				zl_disposed_inv_difference.inv_id,
				zl_disposed_inv_difference.product_name,
				zl_disposed_inv_difference.CUSTOMER_NAME,
				zl_disposed_inv_difference.QUANTITY,
				zl_disposed_inv_difference.remark
				)select 
				invmon_id_v,			invmon_PRODUCT_NAME_v,
				invmon_CUSTOMER_NAME_v,
				invmon_QUANTITY_v,
				'产品名称有差异'
				from dual 
				where  not EXISTS (	
				select inv.inv_id from zl_disposed_inv_difference  inv 
				where inv.inv_id=invmon_id_v
				);
	ELSEIF	invcur_CUSTOMER_NAME_v != invmon_CUSTOMER_NAME_v THEN
				insert into zl_disposed_inv_difference(
				zl_disposed_inv_difference.inv_id,
				zl_disposed_inv_difference.product_name,
				zl_disposed_inv_difference.CUSTOMER_NAME,
				zl_disposed_inv_difference.QUANTITY,
				zl_disposed_inv_difference.remark
				)select 
				invmon_id_v,							
				invmon_PRODUCT_NAME_v,
				invmon_CUSTOMER_NAME_v,
				invmon_QUANTITY_v,
				'终端名称有差异'
				from dual 
				where  not EXISTS (	
				select inv.inv_id from zl_disposed_inv_difference  inv 
				where inv.inv_id=invmon_id_v
				);
	ELSEIF	invcur_QUANTITY_v != invmon_QUANTITY_v  THEN
				insert into zl_disposed_inv_difference(
				zl_disposed_inv_difference.inv_id,
				zl_disposed_inv_difference.product_name,
				zl_disposed_inv_difference.CUSTOMER_NAME,
				zl_disposed_inv_difference.QUANTITY,
				zl_disposed_inv_difference.remark
				)select 
				invmon_id_v,							
				invmon_PRODUCT_NAME_v,
				invmon_CUSTOMER_NAME_v,
				invmon_QUANTITY_v,
				'销售数量有差异'
				from dual 
				where  not EXISTS (	
				select inv.inv_id from zl_disposed_inv_difference  inv 
				where inv.inv_id=invmon_id_v
				);
			END IF;
			END;
			END IF;
		UNTIL done END REPEAT;
	CLOSE curl_inv_mon_info;

		insert into zl_disposed_inv_difference(
		zl_disposed_inv_difference.inv_id,
		zl_disposed_inv_difference.product_name,
		zl_disposed_inv_difference.CUSTOMER_NAME,
		zl_disposed_inv_difference.QUANTITY,
		zl_disposed_inv_difference.remark
			)SELECT invmon.ID,
				invmon.PRODUCT_NAME,
				invmon.CUSTOMER_NAME,
				invmon.QUANTITY,
				'月数据存在，日数据无' 
		FROM	zl_disposed_inv_mon invmon	
			WHERE	NOT EXISTS (
				SELECT * FROM	zl_disposed_inv_cur invcur
				WHERE	  invmon.ID = invcur.ID)
				and invmon.ID not in 
				(select dif.inv_id from zl_disposed_inv_difference dif where dif.inv_id=invmon.ID)
        and DATE_FORMAT(invmon.inv_date,'%Y%m')=inv_date;
	insert into zl_disposed_inv_difference(
		zl_disposed_inv_difference.inv_id,
		zl_disposed_inv_difference.product_name,
		zl_disposed_inv_difference.CUSTOMER_NAME,
		zl_disposed_inv_difference.QUANTITY,
		zl_disposed_inv_difference.remark
				) SELECT  invcur.ID,
					invcur.PRODUCT_NAME,	
					invcur.CUSTOMER_NAME,	
					invcur.QUANTITY,	
					'日数据存在，月数据无' 
		FROM	zl_disposed_inv_cur invcur	
		WHERE	NOT EXISTS (
			SELECT*FROM	zl_disposed_inv_mon mon
		WHERE	  invcur.ID = mon.ID ) 
		and invcur.ID not in 
			(select dif.inv_id from zl_disposed_inv_difference dif where dif.inv_id=invcur.ID)
	 	and DATE_FORMAT(invcur.inv_date,'%Y%m')=inv_date ;
END

-- zl_pur_difference_task
CREATE DEFINER=`root`@`%` PROCEDURE `zl_pur_difference_task`(pur_date VARCHAR(100))
BEGIN
	DECLARE purmon_id_v int DEFAULT 0;
	DECLARE purmon_PRODUCT_NAME_v VARCHAR(100);
	DECLARE purmon_RECEIVER_NAME_v VARCHAR(100);
	DECLARE purmon_QUANTITY_v VARCHAR(100);
	DECLARE purmon_SENDER_NAME_v VARCHAR(100);
	DECLARE purcur_id_v int DEFAULT 0;
	DECLARE purcur_PRODUCT_NAME_v VARCHAR(100);
	DECLARE purcur_RECEIVER_NAME_v VARCHAR(100);
	DECLARE purcur_QUANTITY_v VARCHAR(100);
  DECLARE purcur_SENDER_NAME_v VARCHAR(100);
  DECLARE done INT DEFAULT 0; 

  DECLARE curl_pur_mon_info CURSOR FOR	
				SELECT  purmon.ID,	
								purmon.PRODUCT_NAME,	
								purmon.RECEIVER_NAME,
								purmon.QUANTITY,	
								purmon.SENDER_NAME 	
				FROM		zl_disposed_pur_mon purmon
				inner join zl_disposed_pur_cur zlcur on purmon.ID =zlcur.ID
				WHERE	NOT EXISTS (	
					SELECT purcur.ID FROM	zl_disposed_pur_cur purcur
					WHERE	 purmon.ID = purcur.ID 	AND purmon.PRODUCT_NAME = purcur.PRODUCT_NAME		
						AND purmon.RECEIVER_NAME=purcur.RECEIVER_NAME		AND purmon.QUANTITY=purcur.QUANTITY 
						AND purmon.SENDER_NAME=purcur.SENDER_NAME	)
					and DATE_FORMAT(zlcur.pur_date,'%Y%m')=pur_date;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
-- 开启游标
	OPEN curl_pur_mon_info;
  -- 循环取值
		REPEAT FETCH curl_pur_mon_info INTO purmon_id_v,							
																				purmon_PRODUCT_NAME_v,
																				purmon_RECEIVER_NAME_v,
																				purmon_QUANTITY_v,
																				purmon_SENDER_NAME_v;
			IF NOT done THEN
			BEGIN
					select 
								zl_disposed_pur_cur.PRODUCT_NAME,
								zl_disposed_pur_cur.RECEIVER_NAME,
								zl_disposed_pur_cur.QUANTITY,
								zl_disposed_pur_cur.SENDER_NAME  
					into  purcur_PRODUCT_NAME_v,
								purcur_RECEIVER_NAME_v,
								purcur_QUANTITY_v,
								purcur_SENDER_NAME_v     	
					from zl_disposed_pur_cur
					where zl_disposed_pur_cur.ID = purmon_id_v;	

			IF	purcur_PRODUCT_NAME_v != purmon_PRODUCT_NAME_v THEN
				insert into zl_disposed_pur_difference(
				zl_disposed_pur_difference.pur_id,
				zl_disposed_pur_difference.product_name,
				zl_disposed_pur_difference.receive_name,
				zl_disposed_pur_difference.QUANTITY,
				zl_disposed_pur_difference.SENDER_NAME,
				zl_disposed_pur_difference.remark
				)select 
				purmon_id_v,			purmon_PRODUCT_NAME_v,
				purmon_RECEIVER_NAME_v,
				purmon_QUANTITY_v,
				purmon_SENDER_NAME_v,
				'产品名称有差异'
				from dual 
				where  not EXISTS (	
				select pur.pur_id from zl_disposed_pur_difference  pur 
				where pur.pur_id=purmon_id_v
				);
	ELSEIF	purcur_RECEIVER_NAME_v != purmon_RECEIVER_NAME_v THEN
				insert into zl_disposed_pur_difference(
				zl_disposed_pur_difference.pur_id,
				zl_disposed_pur_difference.product_name,
				zl_disposed_pur_difference.receive_name,
				zl_disposed_pur_difference.QUANTITY,
				zl_disposed_pur_difference.SENDER_NAME,
				zl_disposed_pur_difference.remark
				)select 
				purmon_id_v,							
				purmon_PRODUCT_NAME_v,
				purmon_RECEIVER_NAME_v,
				purmon_QUANTITY_v,
				purmon_SENDER_NAME_v,
				'购入客户名称有差异'
				from dual 
				where  not EXISTS (	
				select pur.pur_id from zl_disposed_pur_difference  pur 
				where pur.pur_id=purmon_id_v
				);
	ELSEIF	purcur_QUANTITY_v != purmon_QUANTITY_v  THEN
				insert into zl_disposed_pur_difference(
				zl_disposed_pur_difference.pur_id,
				zl_disposed_pur_difference.product_name,
				zl_disposed_pur_difference.receive_name,
				zl_disposed_pur_difference.QUANTITY,
				zl_disposed_pur_difference.SENDER_NAME,
				zl_disposed_pur_difference.remark
				)select 
				purmon_id_v,							
				purmon_PRODUCT_NAME_v,
				purmon_RECEIVER_NAME_v,
				purmon_QUANTITY_v,
				purmon_SENDER_NAME_v,
				'采购数量有差异'
				from dual 
				where  not EXISTS (	
				select pur.pur_id from zl_disposed_pur_difference  pur 
				where pur.pur_id=purmon_id_v
				);
	ELSEIF
			purcur_SENDER_NAME_v !=purmon_SENDER_NAME_v THEN
				insert into zl_disposed_pur_difference(
				zl_disposed_pur_difference.pur_id,
				zl_disposed_pur_difference.product_name,
				zl_disposed_pur_difference.receive_name,
				zl_disposed_pur_difference.QUANTITY,
				zl_disposed_pur_difference.SENDER_NAME,
				zl_disposed_pur_difference.remark
				)select 
				purmon_id_v,							
				purmon_PRODUCT_NAME_v,
				purmon_RECEIVER_NAME_v,
				purmon_QUANTITY_v,
				purmon_SENDER_NAME_v,
				'卖出客户名称有差异'
				from dual 
				where  not EXISTS (	
				select pur.pur_id from zl_disposed_pur_difference  pur 
				where pur.pur_id=purmon_id_v
				);
			END IF;
			END;
			END IF;
		UNTIL done END REPEAT;
	CLOSE curl_pur_mon_info;

		insert into zl_disposed_pur_difference(
		zl_disposed_pur_difference.pur_id,
		zl_disposed_pur_difference.product_name,
		zl_disposed_pur_difference.receive_name,
		zl_disposed_pur_difference.QUANTITY,
		zl_disposed_pur_difference.SENDER_NAME,
		zl_disposed_pur_difference.remark
			)SELECT purmon.ID,
				purmon.PRODUCT_NAME,
				purmon.RECEIVER_NAME,
				purmon.QUANTITY,
				purmon.SENDER_NAME,
				'月数据存在，日数据无' 
		FROM	zl_disposed_pur_mon purmon	
			WHERE	NOT EXISTS (
				SELECT * FROM	zl_disposed_pur_cur purcur
				WHERE	  purmon.ID = purcur.ID)
				and purmon.ID not in 
				(select dif.pur_id from zl_disposed_pur_difference dif where dif.pur_id=purmon.ID)
        and DATE_FORMAT(purmon.pur_date,'%Y%m')=pur_date;
	insert into zl_disposed_pur_difference(
		zl_disposed_pur_difference.pur_id,
		zl_disposed_pur_difference.product_name,
		zl_disposed_pur_difference.receive_name,
		zl_disposed_pur_difference.QUANTITY,
		zl_disposed_pur_difference.SENDER_NAME,
		zl_disposed_pur_difference.remark
				) SELECT  purcur.ID,
					purcur.PRODUCT_NAME,	
					purcur.RECEIVER_NAME,	
					purcur.QUANTITY,	
					purcur.SENDER_NAME,
					'日数据存在，月数据无' 
		FROM	zl_disposed_pur_cur purcur	
		WHERE	NOT EXISTS (
			SELECT*FROM	zl_disposed_pur_mon mon
		WHERE	  purcur.ID = mon.ID ) 
		and purcur.ID not in 
			(select dif.pur_id from zl_disposed_pur_difference dif where dif.pur_id=purcur.ID)
	 	and DATE_FORMAT(purcur.pur_date,'%Y%m')=pur_date ;
END


-- zl_sal_difference_task
CREATE DEFINER=`root`@`%` PROCEDURE `zl_sal_difference_task`(sale_date VARCHAR(100))
BEGIN
	DECLARE salemon_id_v int DEFAULT 0;
	DECLARE salemon_PRODUCT_NAME_v VARCHAR(100);
	DECLARE salemon_RECEIVER_NAME_v VARCHAR(100);
	DECLARE salemon_QUANTITY_v VARCHAR(100);
  DECLARE salemon_SENDER_NAME_v VARCHAR(100);
	DECLARE salecur_id_v int DEFAULT 0;
	DECLARE salecur_PRODUCT_NAME_v VARCHAR(100);
	DECLARE salecur_RECEIVER_NAME_v VARCHAR(100);
	DECLARE salecur_QUANTITY_v VARCHAR(100);
  DECLARE salecur_SENDER_NAME_v VARCHAR(100);
  DECLARE done INT DEFAULT 0; 

  DECLARE curl_sal_mon_info CURSOR FOR	
				SELECT  salemon.ID,	
								salemon.PRODUCT_NAME,	
								salemon.RECEIVER_NAME,
								salemon.QUANTITY,	
								salemon.SENDER_NAME 	
				FROM		zl_disposed_sal_mon salemon
				inner join zl_disposed_sal_cur zlcur on salemon.ID =zlcur.ID
				WHERE	NOT EXISTS (	
					SELECT salcur.ID FROM	zl_disposed_sal_cur salcur
					WHERE	 salemon.ID = salcur.ID 	AND salemon.PRODUCT_NAME = salcur.PRODUCT_NAME		
						AND salemon.RECEIVER_NAME=salcur.RECEIVER_NAME		AND salemon.QUANTITY=salcur.QUANTITY 
						AND salemon.SENDER_NAME=salcur.SENDER_NAME	)
					and DATE_FORMAT(zlcur.sale_date,'%Y%m')=sale_date;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1; 
-- 开启游标
	OPEN curl_sal_mon_info;
  -- 循环取值
		REPEAT FETCH curl_sal_mon_info INTO salemon_id_v,							
																				salemon_PRODUCT_NAME_v,
																				salemon_RECEIVER_NAME_v,
																				salemon_QUANTITY_v,
																				salemon_SENDER_NAME_v;
			IF NOT done THEN
			BEGIN
					select 
								zl_disposed_sal_cur.PRODUCT_NAME,
								zl_disposed_sal_cur.RECEIVER_NAME,
								zl_disposed_sal_cur.QUANTITY,
								zl_disposed_sal_cur.SENDER_NAME  
					into  salecur_PRODUCT_NAME_v,
								salecur_RECEIVER_NAME_v,
								salecur_QUANTITY_v,
								salecur_SENDER_NAME_v     	
					from zl_disposed_sal_cur
					where zl_disposed_sal_cur.ID = salemon_id_v;	

			IF	salecur_PRODUCT_NAME_v != salemon_PRODUCT_NAME_v THEN
				insert into zl_disposed_sal_difference(
				zl_disposed_sal_difference.sale_id,
				zl_disposed_sal_difference.product_name,
				zl_disposed_sal_difference.receive_name,
				zl_disposed_sal_difference.QUANTITY,
				zl_disposed_sal_difference.SENDER_NAME,
				zl_disposed_sal_difference.remark
				)select 
				salemon_id_v,			salemon_PRODUCT_NAME_v,
				salemon_RECEIVER_NAME_v,
				salemon_QUANTITY_v,
				salemon_SENDER_NAME_v,
				'产品名称有差异'
				from dual 
				where  not EXISTS (	
				select sal.sale_id from zl_disposed_sal_difference  sal 
				where sal.sale_id=salemon_id_v
				);
	ELSEIF	salecur_RECEIVER_NAME_v != salemon_RECEIVER_NAME_v THEN
				insert into zl_disposed_sal_difference(
				zl_disposed_sal_difference.sale_id,
				zl_disposed_sal_difference.product_name,
				zl_disposed_sal_difference.receive_name,
				zl_disposed_sal_difference.QUANTITY,
				zl_disposed_sal_difference.SENDER_NAME,
				zl_disposed_sal_difference.remark
				)select 
				salemon_id_v,							
				salemon_PRODUCT_NAME_v,
				salemon_RECEIVER_NAME_v,
				salemon_QUANTITY_v,
				salemon_SENDER_NAME_v,
				'终端名称有差异'
				from dual 
				where  not EXISTS (	
				select sal.sale_id from zl_disposed_sal_difference  sal 
				where sal.sale_id=salemon_id_v
				);
	ELSEIF	salecur_QUANTITY_v != salemon_QUANTITY_v  THEN
				insert into zl_disposed_sal_difference(
				zl_disposed_sal_difference.sale_id,
				zl_disposed_sal_difference.product_name,
				zl_disposed_sal_difference.receive_name,
				zl_disposed_sal_difference.QUANTITY,
				zl_disposed_sal_difference.SENDER_NAME,
				zl_disposed_sal_difference.remark
				)select 
				salemon_id_v,							
				salemon_PRODUCT_NAME_v,
				salemon_RECEIVER_NAME_v,
				salemon_QUANTITY_v,
				salemon_SENDER_NAME_v,
				'销售数量有差异'
				from dual 
				where  not EXISTS (	
				select sal.sale_id from zl_disposed_sal_difference  sal 
				where sal.sale_id=salemon_id_v
				);
	ELSEIF
			salecur_SENDER_NAME_v !=salemon_SENDER_NAME_v THEN
				insert into zl_disposed_sal_difference(
				zl_disposed_sal_difference.sale_id,
				zl_disposed_sal_difference.product_name,
				zl_disposed_sal_difference.receive_name,
				zl_disposed_sal_difference.QUANTITY,
				zl_disposed_sal_difference.SENDER_NAME,
				zl_disposed_sal_difference.remark
				)select 
				salemon_id_v,							
				salemon_PRODUCT_NAME_v,
				salemon_RECEIVER_NAME_v,
				salemon_QUANTITY_v,
				salemon_SENDER_NAME_v,
				'客户ID有差异'
				from dual 
				where  not EXISTS (	
				select sal.sale_id from zl_disposed_sal_difference  sal 
				where sal.sale_id=salemon_id_v
				);
			END IF;
			END;
			END IF;
		UNTIL done END REPEAT;
	CLOSE curl_sal_mon_info;

		insert into zl_disposed_sal_difference(
		zl_disposed_sal_difference.sale_id,
		zl_disposed_sal_difference.product_name,
		zl_disposed_sal_difference.receive_name,
		zl_disposed_sal_difference.QUANTITY,
		zl_disposed_sal_difference.SENDER_NAME,
		zl_disposed_sal_difference.remark
			)SELECT salemon.ID,
				salemon.PRODUCT_NAME,
				salemon.RECEIVER_NAME,
				salemon.QUANTITY,
				salemon.SENDER_NAME,
				'月数据存在，日数据无' 
		FROM	zl_disposed_sal_mon salemon	
			WHERE	NOT EXISTS (
				SELECT * FROM	zl_disposed_sal_cur salcur
				WHERE	  salemon.ID = salcur.ID)
				and salemon.ID not in 
				(select dif.sale_id from zl_disposed_sal_difference dif where dif.sale_id=salemon.ID)
        and DATE_FORMAT(salemon.sale_date,'%Y%m')=sale_date;
	insert into zl_disposed_sal_difference(
		zl_disposed_sal_difference.sale_id,
		zl_disposed_sal_difference.product_name,
		zl_disposed_sal_difference.receive_name,
		zl_disposed_sal_difference.QUANTITY,
		zl_disposed_sal_difference.SENDER_NAME,
		zl_disposed_sal_difference.remark
				) SELECT  salecur.ID,
					salecur.PRODUCT_NAME,	
					salecur.RECEIVER_NAME,	
					salecur.QUANTITY,	
					salecur.SENDER_NAME,
					'日数据存在，月数据无' 
		FROM	zl_disposed_sal_cur salecur	
		WHERE	NOT EXISTS (
			SELECT*FROM	zl_disposed_sal_mon mon
		WHERE	  salecur.ID = mon.ID ) 
		and salecur.ID not in 
			(select dif.sale_id from zl_disposed_sal_difference dif where dif.sale_id=salecur.ID)
	 	and DATE_FORMAT(salecur.sale_date,'%Y%m')=sale_date ;
END
