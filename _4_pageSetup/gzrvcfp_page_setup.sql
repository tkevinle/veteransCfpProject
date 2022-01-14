-- Create Veteran's College Financing Plan Validation Table

create table general.gzrvcfp
( gzrvcfp_AIDY_CODE VARCHAR2(4) NOT NULL
, gzrvcfp_MIL_STATUS VARCHAR2(1) NOT NULL 
, gzrvcfp_MIL_BENEFIT VARCHAR2(6) NOT NULL
, gzrvcfp_MIL_SERVICE VARCHAR2(6)
, gzrvcfp_SPOUSE_ACT_DUTY VARCHAR2(1)
, gzrvcfp_BEN_PRIOR_20180101 VARCHAR2(1)
, gzrvcfp_COMPL_ENLIST_YRS NUMBER
, gzrvcfp_POST_911_ELIG VARCHAR2(1)
, gzrvcfp_NBR_DEPENDENTS NUMBER
, gzrvcfp_TUITION_ANNUAL NUMBER NOT NULL
, gzrvcfp_HOUSING_MONTHLY NUMBER NOT NULL
, gzrvcfp_BOOK_ANNUAL NUMBER NOT NULL
, gzrvcfp_ACTIVITY_DATE DATE DEFAULT SYSDATE NOT NULL 
, gzrvcfp_USER_ID VARCHAR2(30) 
, gzrvcfp_SURROGATE_ID NUMBER 
, gzrvcfp_VERSION NUMBER 
, gzrvcfp_DATA_ORIGIN VARCHAR2(30) 
, gzrvcfp_VPDI_CODE VARCHAR2(20) 
);

CREATE OR REPLACE PUBLIC SYNONYM gzrvcfp FOR GENERAL.gzrvcfp;


COMMENT ON TABLE gzrvcfp IS 'Veteran College Financing Plan Validation Table';


COMMENT ON COLUMN gzrvcfp.gzrvcfp_AIDY_CODE IS 'Aid Year';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_MIL_STATUS IS 'Military Status (Ex: Veteran)';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_MIL_BENEFIT IS 'Military Benefit Used (Ex: Ch 33)';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_MIL_SERVICE IS 'Cumulative Post-9/11 active-duty service';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_SPOUSE_ACT_DUTY IS 'Spouse on Active Duty';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_BEN_PRIOR_20180101 IS 'Used Ch33 benefits for a term that started before January 1, 2018';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_COMPL_ENLIST_YRS IS 'Years of Enlistment Completed';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_POST_911_ELIG IS 'Post-9/11 GI Bill Eligible';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_NBR_DEPENDENTS IS 'Number of Dependents';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_TUITION_ANNUAL IS 'Annual Tuition and Fees Benefit';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_HOUSING_MONTHLY  IS 'Monthly Housing Allowance'; 

COMMENT ON COLUMN gzrvcfp.gzrvcfp_BOOK_ANNUAL IS 'Annual Book Stipend';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_ACTIVITY_DATE IS 'Last Update Date';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_USER_ID IS 'Last Update User';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_SURROGATE_ID IS 'Surrogate ID';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_VERSION IS 'Version';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_DATA_ORIGIN IS 'Data Origin';

COMMENT ON COLUMN gzrvcfp.gzrvcfp_VPDI_CODE IS 'VPDI Code';



-- Grants

GRANT SELECT, UPDATE, INSERT, DELETE ON gzrvcfp TO BAN_DEFAULT_PAGEBUILDER_M;