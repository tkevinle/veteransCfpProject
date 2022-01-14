## PROJECT: Veteran's College Financing Plan
## REQUESTOR: Brian Vargas, Veteran's Office
## AUTHOR: Kevin Le, ITS

## Request:
Allow Veterans Students to see a generated Veteran's College Financing Plan with personalized Financial Aid Data (if applicable) and Veteran's benefit data.

## TEST CASES:
* 93734794  @00318661
* 22516232  @00308043


## Project Components:
* GZRVCFP table in Banner
* Veterans Benefits Validation Page in Pagebuilder
    * Page will query data from GZRVCFP where the configuration for all the different Veterans Benefits and values live.  User with access to this page and update this validation table's values.  Page also includes functionality to copy setup from aid year to aid year.
* Veterans College Financing Plan Display Page in Pagebuilder
    * Page will allow students to enter 


## INSTALLATION:
* Step 1: Create Table in Banner using user BANINST1
    * Execute Script /_4_pageSetup/gzrvcfp_page_setup.sql to create GZRVCFP table in Banner
    * Table consists of following fields:
        GZRVCFP_AIDY_CODE VARCHAR2(4) NOT NULL
        GZRVCFP_MIL_STATUS VARCHAR2(1) NOT NULL 
        GZRVCFP_MIL_BENEFIT VARCHAR2(6) NOT NULL
        GZRVCFP_MIL_SERVICE VARCHAR2(6)
        GZRVCFP_SPOUSE_ACT_DUTY VARCHAR2(1)
        GZRVCFP_BEN_PRIOR_20180101 VARCHAR2(1)
        GZRVCFP_COMPL_ENLIST_YRS NUMBER
        GZRVCFP_POST_911_ELIG VARCHAR2(1)
        GZRVCFP_NBR_DEPENDENTS NUMBER
        GZRVCFP_TUITION_ANNUAL NUMBER NOT NULL
        GZRVCFP_HOUSING_MONTHLY NUMBER NOT NULL
        GZRVCFP_BOOK_ANNUAL NUMBER NOT NULL
        GZRVCFP_ACTIVITY_DATE DATE DEFAULT SYSDATE NOT NULL 
        GZRVCFP_USER_ID VARCHAR2(30) 
        GZRVCFP_SURROGATE_ID NUMBER 
        GZRVCFP_VERSION NUMBER 
        GZRVCFP_DATA_ORIGIN VARCHAR2(30) 
        GZRVCFP_VPDI_CODE VARCHAR2(20) 
    * Table uses public synonym gzrvcfp for GENERAL.GZRVCFP
    * Grant Security:
        * GRANT SELECT, UPDATE, INSERT, DELETE ON gzrvcfp to BAN_DEFAULT_PAGEBUILDER_M

* Step 2: Import Pagebuilder Virtual Domains:
    * veCfpAidYearDomain.json
    * veCfpAidyToSelect.json
    * veCfpCopyValidation.json
    * veCfpDependents.json
    * veCfpDomain.json
    * veCfpEnlistment.json
    * veCfpGIBill.json
    * veCfpMilitaryService.json
    * veCfpMilitaryStatus.json
    * veCfpSelectAidYear.json
    * veCfpSelectVetCode.json
    * veCfpStudentData.json
    * veCfpValidation.json
    * veCfpYesNo.json

(Information on Virtual Domain Definitions and Usage in Appendix A Below.)

## APPENDIX A: VIRTUAL DOMAINS
* veCfpAidYearDomain.json
    * Usage: Select Aid Years for which there's data setup in Veteran's College Financing Plan Validation Table (GZRVCFP)
    * Query Statement: 
        select robinst_aidy_code, robinst_aidy_desc
        from robinst 
        where robinst_aidy_start_date >= (sysdate-(5*365))
            and exists (select 'x'
                        from gzrvcfp
                        where gzrvcfp_aidy_code = robinst_aidy_code)
        order by 1 desc
* veCfpAidyToSelect.json
    * Usage: Select Aid Years for which there's no data setup in Veteran's College Financing Plan Validation Table (GZRVCFP).  Used for when doing the Aid Year Copy.
    * Query Statement:
        select robinst_aidy_code, robinst_aidy_desc
        from robinst
        where robinst_aidy_start_date > sysdate-(365*5)
            and not exists (select 'x'
                            from gzrvcfp
                            where gzrvcfp_aidy_code = robinst_aidy_code)

* veCfpCopyValidation.json
    * Usage:
    * Query Statement:
* veCfpDependents.json
    * Usage:
    * Query Statement:
* veCfpDomain.json
    * Usage:
    * Query Statement:
* veCfpEnlistment.json
    * Usage:
    * Query Statement:
* veCfpGIBill.json
    * Usage:
    * Query Statement:
* veCfpMilitaryService.json
    * Usage:
    * Query Statement:
* veCfpMilitaryStatus.json
    * Usage:
    * Query Statement:
* veCfpSelectAidYear.json
    * Usage:
    * Query Statement:
* veCfpSelectVetCode.json
    * Usage:
    * Query Statement:
* veCfpStudentData.json
    * Usage:
    * Query Statement:
* veCfpValidation.json
    * Usage:
    * Query Statement:
* veCfpYesNo.json
    * Usage:
    * Query Statement:
