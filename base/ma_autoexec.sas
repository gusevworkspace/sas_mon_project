%global MA_WORK_DIR; %let MA_WORK_DIR = %sysget(ENVPATH);
%global MA_SCRIPTS_DIR; %let MA_SCRIPTS_DIR = %sysget(MA_SCRIPTS_DIR);
%global MA_SERVER; %let MA_SERVER = %sysget(CONTUR);

/* SAS Helper libs */

/* option FMTSEARCH=(MAMisc) nofmterr;*/

/* MA_DEBUG флаг режима отладки. 1 Вкл. 0 Выкл. */
%global MA_DEBUG; %let %sysget(RUNDEBUG);
options mprint;
/* options sastrace=",,,d" sastraceloc=saslog nostsuffix;*/

%global MAX_LAUNCHER_SESSIONS; %let MAX_LAUNCHER_SESSIONS = 3;
%global MA_LAUNCHER_PATH; %let MA_LAUNCHER_PATH = /sas/sas/sashome/SASMarketingAutomationLauncher/6.3;
%global MA_LAUNCHER_USER; %let MA_LAUNCHER_USER = sasadm@saspw;
%global MA_LAUNCHER_PASSWORD; %let MA_LAUNCHER_PASSWORD = {SAS002}1D57933958C580064BD3DCA81A33DFB2;

%global METADATA_USR_ADM; %let METADATA_USR_ADM = sasadm@saspw;
%global METADATA_PWD_ENCODED_ADM; %let METADATA_PWD_ENCODED_ADM = {SAS002}1D57933958C580064BD3DCA81A33DFB2;
%global METADATA_SVR; %let METADATA_SVR = sasma-meta-prod.ora.mmbank.ru;
%global METADATA_PORT; %let METADATA_PORT = 8561;
%global METADATA_REPOSITORY; %let METADATA_REPOSITORY = Foundation;

/* --------------------------------------------------------------- */
/* ------------------- DDL Configuration ------------------------- */
/* --------------------------------------------------------------- */

%global CLIENT_ID_FIELD; %let CLIENT_ID_FIELD = EID;
%global CLIENT_ID_FIELD_TYPE; %let CLIENT_ID_FIELD_TYPE = Number;
%global CAMP_ID_TYPE; %let CAMP_ID_TYPE = varchar2(20);
%global OPEN_TD_DTTM_ORA; %let OPEN_TD_DTTM_ORA = to_date('01.01.2999','dd.mm.yyyy');

%global OPEN_TD_DTTM_SAS; %let OPEN_TD_DTTM_SAS = '01jan2999'd;

/*Текущее дата время*/
%global CURR_SAS_DTTM; %let CURR_SAS_DTTM = %sysfunc(datetime());	
%global CURR_FORMAT_DTTM; 
data _null_;
	call symput("CURR_FORMAT_DTTM",put(&CURR_SAS_DTTM,datetime20.));
run;

%global CURR_ORA_DTTM; %let CURR_ORA_DTTM = %str(to_date(%'&CURR_FORMAT_DTTM%', 'DDMONYYYY:HH24:MI:SS','NLS_DATE_LANGUAGE = AMERICAN'));

%global COMM_NODE_CP_NAMES; %let COMM_NODE_CP_NAMES =;


/* custom params (cp). Params names should be separated by spaces */

%global SEGMENT_CP_NAMES; %let SEGMENT_CP_NAMES = CODE SCRIPT;
%global SEGMENT_CP_TYPES; %let SEGMENT_CP_TYPES = varchar2(30) varchar2(325);

%global OFFER_VAR_CP_NAMES; %let OFFER_VAR_CP_NAMES = VAR_NUM OFFER_VAR_TYPE;
%global OFFER_VAR_CP_TYPES; %let OFFER_VAR_CP_TYPES = Number  varchar2(10);

%global OFFER_CP_NAMES; %let OFFER_CP_NAMES =;
%global OFFER_CP_TYPES; %let OFFER_CP_TYPES =;

%global OFFER_PRS_CP_NAMES; %let OFFER_PRS_CP_NAMES = EXPIRE_DATE CHECK_NEGATIVE_BKI DEPART DEPART_SELECTION FILIAL PRIORITY NEED_RECALL SAS_REQ_ID SOCIAL_GROUP SCORE_ID;
%global OFFER_PRS_CP_TYPES; %let OFFER_PRS_CP_TYPES = date char(1) number number number number number number varchar(50) number;

%global COMM_WAVE_CP_NAMES; %let COMM_WAVE_CP_NAMES =;
%global COMM_WAVE_CP_TYPES; %let COMM_WAVE_CP_TYPES =;

%global CONTACT_CP_NAMES; %let CONTACT_CP_NAMES = USER_ID DEPART M_REF_REASON MEMO;
%global CONTACT_CP_TYPES; %let CONTACT_CP_TYPES = Number Number varchar2(10) varchar2(2000);

%global OFFER_EXT_PARAMS_NAMES; %let OFFER_EXT_PARAMS_NAMES = IS_CALCULATED RF_BASE BR_BASE RF_BR_FIL RATE SUM TERM PAYMENT MIN_SUM MAX_SUM;
%global OFFER_EXT_PARAMS_TYPES; %let  OFFER_EXT_PARAMS_TYPES = Number VARCHAR2(50) VARCHAR2(16) VARCHAR2(320) number number number number number number;
%global OFFER_EXT_DEFAULT_VALUES; %let  OFFER_EXT_DEFAULT_VALUES = 1 null null null null null null null null null;

%global DEC_DELIMITER; %let DEC_DELIMITER=.;

/* --------------------------------------------------------------- */
/* ------------------- DDL Configuration ------------------------- */
/* --------------------------------------------------------------- */


/* --------------------------------------------------------------- */
/* --------------------- Oracle libname -------------------------- */
/* --------------------------------------------------------------- */
%global MA_TEMP_PATH; %let MA_TEMP_PATH = ADB_DEV;
%global MA_TEMP_SCHEMA; %let MA_TEMP_SCHEMA = MA_TEMP;
%global MA_TEMP_METALIB; %let MA_TEMP_METALIB = MA_TEMP;

/* %global MA_TEMP_USER; %let MA_TEMP_USER = MA_TEMP;
%global MA_TEMP_PASS; %let MA_TEMP_PASS = sasuser; */

%global MA_TEMP_AUTHDOMAIN; %let MA_TEMP_AUTHDOMAIN = OraAuth;
%global MA_TEMP_CONNECT_STATEMENT; %let MA_TEMP_CONNECT_STATEMENT = %str(connect to oracle as ora (path=&MA_TEMP_PATH AUTHDOMAIN=&MA_TEMP_AUTHDOMAIN););

/* %global MA_TEMP_LIBNAME_STATEMENT; %let MA_TEMP_LIBNAME_STATEMENT = %str(LIBNAME MA_TEMP ORACLE PATH=&MA_TEMP_PATH SCHEMA=&MA_TEMP_SCHEMA USER=&MA_TEMP_USER PASSWORD=&MA_TEMP_PASS DBMAX_TEXT=32767 READBUFF=2500 INSERTBUFF=250); */

%global MA_TEMP_LIBNAME_STATEMENT; %let MA_TEMP_LIBNAME_STATEMENT = %str(LIBNAME MA_TEMP META library=&MA_TEMP_METALIB metaout=data);

%global CMDM_PATH; %let CMDM_PATH = ADB_DEV;
%global CMDM_SCHEMA; %let CMDM_SCHEMA = CMDM;

%global CMDM_METALIB; %let CMDM_METALIB = CMDM;
/*global CMDM_USER; %let CMDM_USER = MA_TEMP;
%global CMDM_PASS; %let CMDM_PASS = sasuser;*/

%global CMDM_AUTHDOMAIN; %let CMDM_AUTHDOMAIN = OraAuth;
%global CMDM_CONNECT_STATEMENT; %let CMDM_CONNECT_STATEMENT = %str(connect to oracle as ora (path=&CMDM_PATH AUTHDOMAIN=&CMDM_AUTHDOMAIN););

/*%global CMDM_LIBNAME_STATEMENT; %let CMDM_LIBNAME_STATEMENT = %str(LIBNAME CMDM ORACLE PATH=&CMDM_PATH SCHEMA=&CMDM_SCHEMA USER=&MA_TEMP_USER PASSWORD=&MA_TEMP_PASS DBMAX_TEXT=32767 READBUFF=2500 INSERTBUFF=250);*/

%global CMDM_LIBNAME_STATEMENT; %let CMDM_LIBNAME_STATEMENT = %str(LIBNAME CMDM META library=&CMDM_METALIB metaout=data);

%global MAREPORT_PATH; %let MAREPORT_PATH = ADB_DEV;
%global MAREPORT_SCHEMA; %let MAREPORT_SCHEMA = MA_Report;
%global MAREPORT_METALIB; %let MAREPORT_METALIB = MAREPORT;

/*%global MAREPORT_USER; %let MAREPORT_USER = MA_TEMP;
%global MAREPORT_PASS; %let MAREPORT_PASS = sasuser;*/

%global MAREPORT_AUTHDOMAIN; %let MAREPORT_AUTHDOMAIN = OraAuth;
%global MAREPORT_CONNECT_STATEMENT; %let MAREPORT_CONNECT_STATEMENT = %str(connect to oracle as ora (path=&MAREPORT_PATH AUTHDOMAIN=&MAREPORT_AUTHDOMAIN););

/*%global MAREPORT_LIBNAME_STATEMENT; %let MAREPORT_LIBNAME_STATEMENT = %str(LIBNAME MAREPORT ORACLE PATH=&MAREPORT_PATH SCHEMA=&MAREPORT_SCHEMA USER=&MA_TEMP_USER PASSWORD=&MA_TEMP_PASS DBMAX_TEXT=32767 READBUFF=2500 INSERTBUFF=250);*/

%global MAREPORT_LIBNAME_STATEMENT; %let MAREPORT_LIBNAME_STATEMENT = %str(LIBNAME MAREPORT META library=&MAREPORT_METALIB metaout=data);


%global SCORE_PATH; %let SCORE_PATH = ADB_DEV;
%global SCORE_SCHEMA; %let SCORE_SCHEMA = SCORE_CALC;
%global SCORE_METALIB; %let SCORE_METALIB = SCORE;
%global SCORE_USER; %let SCORE_USER = SCORE_CALC;
%global SCORE_PASS; %let SCORE_PASS = crmde12AB;
%global SCORE_AUTHDOMAIN; %let SCORE_AUTHDOMAIN = OraAuth;
%global SCORE_CONNECT_STATEMENT; %let SCORE_CONNECT_STATEMENT = %str(connect to oracle as ora (path=&SCORE_PATH USER=&SCORE_USER PASSWORD=&SCORE_PASS););
%global SCORE_LIBNAME_STATEMENT; %let SCORE_LIBNAME_STATEMENT = %str(LIBNAME SCORE ORACLE PATH=&SCORE_PATH SCHEMA=&SCORE_SCHEMA USER=&SCORE_USER PASSWORD=&SCORE_PASS DBMAX_TEXT=32767 READBUFF=2500 INSERTBUFF=250);

/*%global SCORE_LIBNAME_STATEMENT; %let SCORE_LIBNAME_STATEMENT = %str(LIBNAME SCORE META library=&SCORE_METALIB metaout=data);*/

/* Формирует строку подключения библиотеки из заданных в autoexec с нужным libref */
%macro mGenLibStatement(mvLibrary, mvLibref=, mvType=LIBNAME);
	
%mend mGenLibStatement;
/* --------------------------------------------------------------- */
/* --------------------- Oracle libname -------------------------- */
/* --------------------------------------------------------------- */


/* --------------------------------------------------------------- */
/* --------------------- Common scripts -------------------------- */
/* --------------------------------------------------------------- */
%include "&MA_SCRIPTS_DIR/common/*";
/* --------------------------------------------------------------- */
/* --------------------- Common scripts -------------------------- */
/* --------------------------------------------------------------- */
/*Почтовые адреса для рассылок уведомлений о работе коммуникаций поставленных на регламент*/
%global ADMIN_EMAIL ;
%let ADMIN_EMAIL ="bom.support@glowbyteconsulting.com";
%global USER_EMAIL;
%let USER_EMAIL =;

/*	e-mail оповещение	*/
%let EMAILHOST=skip.main.mmbank.ru; 
%let EMAILAUTHPROTOCOL=none; 
%let EMAILPORT=25; 
%let EMAILID=user_sas@mmbank.ru;
%let EMAILPW={sas002}C4A1204828D8EB3C2B0E54084FA12DE5; 

/*Библиотека для хранения таблиц с пересонолизированными параметрами шаблонов для выгрузки в email*/
%global EMAIL_PERS_LIB ;
%let EMAIL_PERS_LIB = MA_TEMP ;
%global EM_PERS_LIB_IS_PRE ;
%let EM_PERS_LIB_IS_PRE  = 0 ;
%global EM_PERS_LIBNAME_STATEMENT ;
%let EM_PERS_LIBNAME_STATEMENT = %str(LIBNAME MA_TEMP META library=&MA_TEMP_METALIB metaout=data);


/*Режим отладки для общей ф-ии отправки e-mail*/
%global PROC_DEBUG ;
%let PROC_DEBUG = 0;
/*Путь для html-шаблонов*/
%global EMAIL_HTML_PATH ;
%let EMAIL_HTML_PATH = /sas/sas/env/data/export/email ;

/*Параметры серевера рассылки email*/
%global MA_EMAILHOST;
%let MA_EMAILHOST=10.249.10.44; 
%global MA_EMAILAUTHPROTOCOL ;
%let MA_EMAILAUTHPROTOCOL=none; 
%global MA_EMAILPORT ;
%let MA_EMAILPORT=25 ;
%global MA_EMAILID; 
%let MA_EMAILID=crm-noreply@mmbank.ru;

%global ENABLE_STATUS_MACHINE; %let ENABLE_STATUS_MACHINE = NO;
%global ONW_CHECK_CUSTOM_PARAMS_TYPES; %let ONW_CHECK_CUSTOM_PARAMS_TYPES = NO;
%global ONW_CHECK_CUSTOM_PARAMS_LENGTH; %let ONW_CHECK_CUSTOM_PARAMS_LENGTH = NO;