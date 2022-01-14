## PROJECT: Veteran's College Financing Plan
## REQUESTOR: Brian Vargas, Veteran's Office
## AUTHOR: Kevin Le, ITS

## Request:
Allow Veterans Students to see a generated Veteran's College Financing Plan with personalized Financial Aid Data (if applicable) and Veteran's benefit data.

## TEST CASES:
* 93734794  @00318661
* 22516232  @00308043


## PROJECT COMPONENTS:
* GZRVCFP table in Banner
* Veterans Benefits Validation Page in Pagebuilder
    * Page will query data from GZRVCFP where the configuration for all the different Veterans Benefits and values live.  User with access to this page and update this validation table's values.  Page also includes functionality to copy setup from aid year to aid year.
* Veterans College Financing Plan Display Page in Pagebuilder
    * Page will allow students to select which GI Benefits they would use, then a Veteran's Financing Page will generate with student's personal FA data and estimated Veteran's benefits.


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
    * veCfpEnlistment.json
    * veCfpGIBill.json
    * veCfpMilitaryService.json
    * veCfpMilitaryStatus.json
    * veCfpStudentData.json
    * veCfpValidation.json
    * veCfpYesNo.json

(Information on Virtual Domain Definitions and Usage in Appendix A Below.)

* Step 3: Import Pagebuilder Visual Pages:
    * veCfpDisplay.json
    * veCfpBenefitsValidationPage.json

(Information on Virtual Domain Definitions and Usage in Appendix B Below.)

* Step 4: Import CSS:
    * css.ccsf_ve_cfpCss.json

(Information on Virtual Domain Definitions and Usage in Appendix C Below.)

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
    * Usage: Copy Script to Data on GZRVCFP from one aid year to another.
    * Query Statement: 
            SELECT *
            FROM GZRVCFP;
    * POst/Create/Save Statement: 
            BEGIN
            INSERT INTO GENERAL.GZRVCFP B (B.GZRVCFP_AIDY_CODE, B.GZRVCFP_MIL_STATUS, B.GZRVCFP_MIL_BENEFIT, B.GZRVCFP_MIL_SERVICE, B.GZRVCFP_SPOUSE_ACT_DUTY, B.GZRVCFP_BEN_PRIOR_20180101, B.GZRVCFP_COMPL_ENLIST_YRS, B.GZRVCFP_POST_911_ELIG, B.GZRVCFP_NBR_DEPENDENTS, B.GZRVCFP_TUITION_ANNUAL, B.GZRVCFP_HOUSING_MONTHLY, B.GZRVCFP_BOOK_ANNUAL, B.GZRVCFP_USER_ID, B.GZRVCFP_DATA_ORIGIN, B.GZRVCFP_ACTIVITY_DATE) 
            (SELECT :parm_toAidy, A.GZRVCFP_MIL_STATUS, A.GZRVCFP_MIL_BENEFIT, A.GZRVCFP_MIL_SERVICE, A.GZRVCFP_SPOUSE_ACT_DUTY, A.GZRVCFP_BEN_PRIOR_20180101, A.GZRVCFP_COMPL_ENLIST_YRS, A.GZRVCFP_POST_911_ELIG, A.GZRVCFP_NBR_DEPENDENTS, A.GZRVCFP_TUITION_ANNUAL, A.GZRVCFP_HOUSING_MONTHLY, A.GZRVCFP_BOOK_ANNUAL, USER, A.GZRVCFP_DATA_ORIGIN, SYSDATE
                    FROM  GZRVCFP A
                    WHERE A.GZRVCFP_AIDY_CODE = :parm_fromAidy); 
            COMMIT;
            END;
* veCfpDependents.json
    * Usage: Select Number of Dependents.  End user should be able to select from 0-5. These values are then looked up on GZVRCFP to determine benefit amounts.
    * Query Statement:
            select rownum dependents
            from dual
            connect by rownum <= 5
            union
            select 0
            from dual
            order by 1
* veCfpEnlistment.json
    * Usage: Select Number of Enlistment Years.  End user should only be able to select values 2 or 3. These values are then looked up on GZVRCFP to determine benefit amounts.
    * Query Statement:
            select 2 enlistment, '2 or more years' enlistment_desc
            from dual
            union
            select 3, '3 or more years'
            from dual
* veCfpGIBill.json
    * Usage: Select GI Bill Program.  User should be able to select any of the 5 unless they are a spouse or dependent, for which they should not be able to select VRE. These values are then looked up on GZVRCFP to determine benefit amounts.
    * Query Statement:
            select 'CH30' vet_code, 'Montgomery GI Bill® (Ch30)' vet_code_desc
            from dual
            union
            select 'CH33', 'Post-9/11 GI Bill® (Ch33)'
            from dual
            union
            select 'CH1606', 'Chapter 1606 (Reservists)'
            from dual
            union
            select 'VRE', 'Veteran Readiness and Employment (VR&E) (Ch31)'
            from dual
            where nvl(:parm_mil_stat, 'X') not in ('D','E')
            union
            select 'DEA', 'Dependents Educational Assistance (DEA) (Ch35)'
            from dual
* veCfpMilitaryService.json
    * Usage: Select Military Service.  User should be able to select one of the many lengths of military service or programs.  These values are then looked up on GZVRCFP to determine benefit amounts.
    * Query Statement:
            select *
            from (
            select 
                'CH33' mil_ben,
                '36M' service_code,
                '36+ months: 100%' service_desc,
                1 pct
            from dual
            union
            select 
                'CH33',
                '30M',
                '30 months: 90%',
                .9 pct
            from dual
            union
            select 
                'CH33' mil_ben,
                '24M',
                '24 months: 80%',
                .8 pct
            from dual
            union
            select 
                'CH33',
                '18M',
                '18 months: 70%',
                .7 pct
            from dual
            union
            select 
                'CH33',
                '6M',
                '6 months: 60%',
                .6 pct
            from dual
            union
            select 
                'CH33' mil_ben,
                '90D',
                '90 days: 50%',
                .5 pct
            from dual
            union
            select 
                'CH33',
                'GYSGT',
                'GYSGT Fry Scholarship: 100%',
                1 pct
            from dual
            union
            select 
                'CH33',
                'SCD',
                'Service-Connected Discharge: 100%',
                1 pct
            from dual
            union
            select
                'CH33',
                'PHS',
                'Purple Heart Service: 100%',
                1 pct
            from dual
            union
            select
                null,
                null,
                ' ',
                0 pct
            from dual)
* veCfpMilitaryStatus.json
    * Usage: Select Military Status.  User should be able to select that they are either Veteran, Active Duty, National Guard/Reserves, Spouse or Child. These values are then looked up on GZVRCFP to determine benefit amounts.
    * Query Statement:
            select *
            from (
            select 
                'A' mil_status_code, 
                'Veteran' mil_status_desc
            from dual
            union
            select 
                'B', 
                'Active Duty' 
            from dual
            union
            select 
                'C', 
                'National Guard/Reserves' 
            from dual
            union
            select 
                'D' , 
                'Spouse' 
            from dual
            union
            select 
                'E' , 
                'Child' 
            from dual
            )
* veCfpStudentData.json
    * Usage: This is the important query that is used to grab all the necessary FA data and combine it with the users' military benefit selections to output the values necessary to print on the gnerated College Financing Plan.  
    * Query Statement:
            select
            rowidtochar(spriden.rowid) "id",
            to_char(sysdate,'MM/DD/YYYY') today,
            robinst_aidy_code,
            robinst_aidy_desc,
            spriden_first_name first_name,
            spriden_last_name last_name,
            spriden_id student_id,
            start_year,
            end_year,
            to_char(floor(nvl(tuition,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') tuition,
            to_char(floor(nvl(room_board,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') room_board,
            to_char(floor(nvl(books_supplies,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') books_supplies,
            to_char(floor(nvl(transportation,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') transportation,
            to_char(floor(nvl(other,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') other,
            to_char(floor(nvl(est_coa,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') est_coa,
            to_char(floor(nvl(inst_sch,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') inst_sch,
            to_char(floor(nvl(state_sch,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') state_sch,
            to_char(floor(nvl(other_sch,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') other_sch,
            to_char(floor(nvl(total_sch,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') total_sch,
            to_char(floor(nvl(pell,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') pell,
            to_char(floor(nvl(inst_grnt,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') inst_grnt,
            to_char(floor(nvl(state_grnt,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') state_grnt,
            to_char(floor(nvl(other_grnt,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') other_grnt,
            to_char(floor(nvl(total_grnt,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') total_grnt,
            rcrapp3_yr_in_coll_2,
            to_char(floor(nvl(case when est_coa-nvl(total_grnt, 0)-nvl(total_sch,0) < 0 then 0 else est_coa-nvl(total_grnt, 0)-nvl(total_sch,0) end,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') net_price,
            to_char(floor(nvl(case when isir.rcrapp1_infc_code = 'EDE' and rcrapp3_yr_in_coll_2 in ('0','1') then 3500 when isir.rcrapp1_infc_code = 'EDE' and rcrapp3_yr_in_coll_2 >= 2 then 4500 else 0 end,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') sub_loan,
            to_char(floor(nvl(case when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'I' and rcrapp3_yr_in_coll_2 >= 2 then 10500  when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'I' and rcrapp3_yr_in_coll_2 in ('0','1') then 9500 when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'D' and rcrapp3_yr_in_coll_2 >= 2 then 6500 when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'D' and rcrapp3_yr_in_coll_2 in ('0','1') then 5500 end - case when isir.rcrapp1_infc_code = 'EDE' and rcrapp3_yr_in_coll_2 in ('0','1') then 3500 when isir.rcrapp1_infc_code = 'EDE' and rcrapp3_yr_in_coll_2 >= 2 then 4500 else 0 end,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') unsub_loan,
            to_char(floor(nvl(case when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'I' and rcrapp3_yr_in_coll_2 >= 2 then 10500 when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'I' and rcrapp3_yr_in_coll_2 in ('0','1') then 9500 when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'D' and rcrapp3_yr_in_coll_2 >= 2 then 6500 when isir.rcrapp1_infc_code = 'EDE' and rcrapp2_model_cde = 'D' and rcrapp3_yr_in_coll_2 in ('0','1') then 5500 end,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') total_loan,
            to_char(floor(nvl(case when isir.rcrapp1_infc_code = 'EDE' then 4000 else 0 end,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') work_study,
            to_char(floor(nvl(floor(((case when isir.rcrapp1_infc_code = 'EDE' then 4000 else 0 end)/rjbjobt_default_pay)/30),0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') work_study_hours_wk,
            to_char(floor(nvl(gzrvcfp_tuition_annual,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') tuition_benefit,
            to_char(floor(nvl(gzrvcfp_housing_monthly,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') housing_allowance,
            to_char(floor(nvl(gzrvcfp_book_annual,0)), '99G999G999G999', 'NLS_NUMERIC_CHARACTERS=",."') book_stipend
            from spriden
                join robinst on robinst_aidy_code = :parm_aidy
                left join (select rcrapp1_pidm, rcrapp1_aidy_code, rcrapp1_infc_code, rcrapp2_model_cde, rcrapp3_yr_in_coll_2
                            from rcrapp1, rcrapp2, rcrapp3
                            where rcrapp1_pidm = rcrapp2_pidm
                                and rcrapp1_pidm = rcrapp3_pidm
                                and rcrapp1_aidy_code = rcrapp2_aidy_code
                                and rcrapp1_aidy_code = rcrapp3_aidy_code
                                and rcrapp1_infc_code = rcrapp2_infc_code
                                and rcrapp1_infc_code = rcrapp3_infc_code
                                and rcrapp1_seq_no = rcrapp2_seq_no
                                and rcrapp1_seq_no = rcrapp3_seq_no
                                and rcrapp1_curr_rec_ind = 'Y') isir on isir.rcrapp1_pidm = spriden_pidm
                    and isir.rcrapp1_aidy_code = robinst_aidy_code  
                left join (select 
                                rprawrd_pidm,
                                rprawrd_aidy_code,
                                sum(case when rfrbase_fsrc_code = 'INST' and rfrbase_ftyp_code = 'SCH' then rprawrd_offer_amt end) inst_sch,
                                sum(case when rfrbase_fsrc_code = 'STAT' and rfrbase_ftyp_code = 'SCH' then rprawrd_offer_amt end) state_sch,
                                sum(case when rfrbase_fsrc_code not in ('INST','STAT') and rfrbase_ftyp_code = 'SCH' then rprawrd_offer_amt end) other_sch,
                                sum(case when rfrbase_ftyp_code = 'GP' then rprawrd_offer_amt end) pell,
                                sum(case when rfrbase_fsrc_code = 'INST' and rfrbase_ftyp_code = 'GRNT' then rprawrd_offer_amt end) inst_grnt,
                                sum(case when rfrbase_fsrc_code = 'STAT' and rfrbase_ftyp_code in ('GRNT','BOG','GB','GD','GC') then rprawrd_offer_amt end) state_grnt,
                                sum(case when rfrbase_fsrc_code not in ('INST','STAT') and rfrbase_ftyp_code in ('GRNT','GS') then rprawrd_offer_amt end) other_grnt,
                                sum(case when rfrbase_fsrc_code = 'INST' and rfrbase_ftyp_code = 'SCH' then rprawrd_offer_amt when rfrbase_fsrc_code = 'STAT' and rfrbase_ftyp_code = 'SCH' then rprawrd_offer_amt when rfrbase_fsrc_code not in ('INST','STAT') and rfrbase_ftyp_code = 'SCH' then rprawrd_offer_amt end) total_sch,
                                sum(case when rfrbase_ftyp_code = 'GP' then rprawrd_offer_amt when rfrbase_fsrc_code = 'INST' and rfrbase_ftyp_code = 'GRNT' then rprawrd_offer_amt when rfrbase_fsrc_code = 'STAT' and rfrbase_ftyp_code in ('GRNT','BOG','GB','GD','GC') then rprawrd_offer_amt when rfrbase_fsrc_code not in ('INST','STAT') and rfrbase_ftyp_code in ('GRNT','GS') then rprawrd_offer_amt end) total_grnt
                            from rprawrd
                                join rfrbase on rfrbase_fund_code = rprawrd_fund_code
                            where rprawrd_offer_amt > 0
                                and rprawrd_pidm = :parm_user_pidm
                            group by rprawrd_pidm, rprawrd_aidy_code) awd on awd.rprawrd_aidy_code = robinst_aidy_code
                left join (select 
                                robinst_aidy_code aidy, 
                                robinst_aidy_start_year start_year, 
                                robinst_aidy_end_year end_year,
                                nvl(stdnt.books_supplies, gen.books_supplies) books_supplies,
                                nvl(stdnt.other, gen.personal_expenses) other,
                                nvl(stdnt.room_board, gen.room_board) room_board,
                                nvl(stdnt.transportation, gen.transportation) transportation,
                                nvl(stdnt.tuition, gen.tuition) tuition,
                                case when stdnt.estimated_coa is null then (gen.books_supplies+gen.personal_expenses+gen.room_board+gen.transportation+gen.tuition) else stdnt.estimated_coa end est_coa 
                            from robinst
                                left join (select 
                                                rbracmp_aidy_code,
                                                sum(case when rbracmp_comp_code = 'B+S' then rbracmp_amt end) books_supplies,
                                                sum(case when rbracmp_comp_code = 'FEES' then rbracmp_amt end) tuition,
                                                sum(case when rbracmp_comp_code not in ('B+S','FEES','R+B','TRAN') then rbracmp_amt end) other,
                                                sum(case when rbracmp_comp_code = 'R+B' then rbracmp_amt end) room_board,
                                                sum(case when rbracmp_comp_code = 'TRAN' then rbracmp_amt end) transportation,
                                                sum(rbracmp_amt) estimated_coa
                                            from rbracmp
                                            where rbracmp_pidm = :parm_user_pidm
                                                and rbracmp_btyp_code = 'CAMP'
                                            group by rbracmp_aidy_code) stdnt on stdnt.rbracmp_aidy_code = robinst_aidy_code
                                left join (select *
                                            from (
                                            select rbrcomp_aidy_code aidy_code, rbrcomp_comp_code, rbrcomp_amt
                                            from rbrcomp
                                            where rbrcomp_aprd_code = 'FASPR'
                                                and rbrcomp_btyp_code = 'CAMP'
                                                and rbrcomp_bgrp_code = 'RAWH')
                                            pivot (sum(rbrcomp_amt)
                                                for rbrcomp_comp_code
                                                in ('B+S' books_supplies,
                                                    'PERS' personal_expenses,
                                                    'R+B' room_board,
                                                    'TRAN' transportation,
                                                    'FEES' tuition)
                                                    )) gen on gen.aidy_code = robinst_aidy_code
                            ) bdgt on bdgt.aidy = :parm_aidy
                left join rjbjobt on rjbjobt_code = '3591'
                left join (select *
                            from gzrvcfp
                            where nvl(gzrvcfp_aidy_code, 'X') = nvl(:parm_aidy, 'X')
                                and nvl(gzrvcfp_mil_status, 'X') = nvl(:parm_mil_status, 'X')
                                and nvl(gzrvcfp_mil_benefit, 'X') = nvl(:parm_mil_ben, 'X')
                                and nvl(gzrvcfp_mil_service, 'X') = nvl(:parm_mil_service, 'X')
                                and nvl(gzrvcfp_spouse_act_duty, 'X') = nvl(:parm_spouse_act_duty, 'X')
                                and nvl(gzrvcfp_ben_prior_20180101, 'X') = nvl(:parm_ben_prior, 'X')
                                and nvl(gzrvcfp_compl_enlist_yrs, 0) = nvl(:parm_enlist_yrs, 0)
                                and nvl(gzrvcfp_post_911_elig, 'X') = nvl(:parm_post_911_elig, 'X')
                                and nvl(gzrvcfp_nbr_dependents, 0) = nvl(:parm_nbr_dependents, 0)
                                ) ben_amts on ben_amts.gzrvcfp_aidy_code = :parm_aidy
            where spriden_change_ind is null
                and spriden_pidm = :parm_user_pidm
            order by robinst_aidy_code desc
* veCfpValidation.json
    * Usage: To View/Add/Update values on the Veteran's College Financing Plan Validation Table (GZRVCFP)
    * Query Statement:
            select
            rowidtochar(rowid) "id",
            GZRVCFP_AIDY_CODE,         
            GZRVCFP_MIL_STATUS,        
            GZRVCFP_MIL_BENEFIT,       
            GZRVCFP_MIL_SERVICE,       
            GZRVCFP_SPOUSE_ACT_DUTY,   
            GZRVCFP_BEN_PRIOR_20180101,
            GZRVCFP_COMPL_ENLIST_YRS,  
            GZRVCFP_POST_911_ELIG,     
            GZRVCFP_NBR_DEPENDENTS,
            GZRVCFP_TUITION_ANNUAL,
            GZRVCFP_HOUSING_MONTHLY,
            GZRVCFP_BOOK_ANNUAL,
            GZRVCFP_ACTIVITY_DATE,
            GZRVCFP_USER_ID,
            GZRVCFP_SURROGATE_ID,
            GZRVCFP_VERSION,
            GZRVCFP_DATA_ORIGIN,
            GZRVCFP_VPDI_CODE         
            from GZRVCFP
            where GZRVCFP_AIDY_CODE = :parm_aidy
            order by 2,3,4
    * Post/Create/Save Statement:
            BEGIN 
            INSERT INTO gzrvcfp
            (GZRVCFP_AIDY_CODE,
            GZRVCFP_MIL_STATUS,
            GZRVCFP_MIL_BENEFIT,
            GZRVCFP_MIL_SERVICE,
            GZRVCFP_SPOUSE_ACT_DUTY,
            GZRVCFP_BEN_PRIOR_20180101,
            GZRVCFP_COMPL_ENLIST_YRS,
            GZRVCFP_POST_911_ELIG,
            GZRVCFP_NBR_DEPENDENTS,
            GZRVCFP_TUITION_ANNUAL,
            GZRVCFP_HOUSING_MONTHLY,
            GZRVCFP_BOOK_ANNUAL,
            GZRVCFP_ACTIVITY_DATE,
            GZRVCFP_USER_ID,
            GZRVCFP_SURROGATE_ID,
            GZRVCFP_VERSION,
            GZRVCFP_DATA_ORIGIN,
            GZRVCFP_VPDI_CODE) 
            VALUES (:parm_aidy, 
            :GZRVCFP_MIL_STATUS,
            :GZRVCFP_MIL_BENEFIT,
            :GZRVCFP_MIL_SERVICE,
            :GZRVCFP_SPOUSE_ACT_DUTY,
            :GZRVCFP_BEN_PRIOR_20180101,
            :GZRVCFP_COMPL_ENLIST_YRS,
            :GZRVCFP_POST_911_ELIG,
            :GZRVCFP_NBR_DEPENDENTS,
            :GZRVCFP_TUITION_ANNUAL,
            :GZRVCFP_HOUSING_MONTHLY,
            :GZRVCFP_BOOK_ANNUAL,
            SYSDATE,
            USER,
            :GZRVCFP_SURROGATE_ID,
            :GZRVCFP_VERSION,
            :GZRVCFP_DATA_ORIGIN,
            :GZRVCFP_VPDI_CODE); 
            commit; 
            END;
    * Delete Statement: 
            declare lv_rowid varchar2(100) := :id;
            begin if lv_rowid is null then raise_application_error (-20001,'No ROWID'); 
            end if; 
            delete from gzrvcfp 
            where rowid = chartorowid(lv_rowid); 
            commit; 
            end;
    * Put/Update Statement:
            declare lv_rowid varchar2(100) := :id; 
            begin if lv_rowid is null then raise_application_error (-20001,'No ROWID'); 
            end if; 
            update gzrvcfp 
            set gzrvcfp_aidy_code = :GZRVCFP_AIDY_CODE,
            gzrvcfp_mil_status = :GZRVCFP_MIL_STATUS,
            gzrvcfp_mil_benefit = :GZRVCFP_MIL_BENEFIT,
            gzrvcfp_mil_service = :GZRVCFP_MIL_SERVICE,
            gzrvcfp_spouse_act_duty = :GZRVCFP_SPOUSE_ACT_DUTY,
            gzrvcfp_ben_prior_20180101 = :GZRVCFP_BEN_PRIOR_20180101,
            gzrvcfp_compl_enlist_yrs = :GZRVCFP_COMPL_ENLIST_YRS,
            gzrvcfp_post_911_elig = :GZRVCFP_POST_911_ELIG,
            gzrvcfp_nbr_dependents = :GZRVCFP_NBR_DEPENDENTS,
            gzrvcfp_tuition_annual = :GZRVCFP_TUITION_ANNUAL,
            gzrvcfp_housing_monthly = :GZRVCFP_HOUSING_MONTHLY,
            gzrvcfp_book_annual = :GZRVCFP_BOOK_ANNUAL,
            gzrvcfp_activity_date = SYSDATE,
            gzrvcfp_user_id = USER,
            gzrvcfp_data_origin = 'PAGEBUILDER' 
            where rowid = chartorowid(lv_rowid); 
            commit; 
            end;
* veCfpYesNo.json
    * Usage: Select Yes or No.  Used for a determining a condition on whether or not user received Veterans benefits before a certain date. These values are then looked up on GZVRCFP to determine benefit amounts.
    * Query Statement:
            select 'Y' yes_no, 'Yes' yes_no_desc
            from dual
            union
            select 'N', 'No'
            from dual
            order by 1 desc


## APPENDIX B: VISUAL PAGES 

* Name: veCfpDisplay
* Title: Veterans College Financing Plan
* HOME URL:
    * PPRD:
    * PROD: 

* URL:
    * PPRD: 
    * PROD: 
* Spring Security Attributes: 
    ROLE_GPBADMN_BAN_DEFAULT_PAGEBUILDER_M,ROLE_SELFSERVICE-ALLROLES_BAN_DEFAULT_M

1. Resources
    * veCfpAidYearDomain - virtualDomains.veCfpAidYearDomain
    * veCfpStudentData - virtualDomains.veCfpStudentData
    * veCfpMilitaryStatus - virtualDomains.veCfpMilitaryStatus
    * veCfpGIBill - virtualDomains.veCfpGIBill
    * veCfpMilitaryService - virtualDomains.veCfpMilitaryService
    * veCfpEnlistment - virtualDomains.veCfpEnlistment
    * veCfpYesNo - virtualDomains.veCfpYesNo
    * veCfpDependents - virtualDomains.veCfpDependents

2. Block Component
    * Name: selectAllBlock
    * Show Initially: Checked
    * Literal Component
        * Name: pageIntro
        * Value: 
                <html>  <h1>CCSF Veteran's College Financing Plan </h1> <div> This is an estimated aid award letter designed to simplify the information that prospective students receive about costs and  financial aid so they can easily compare institutions and make informed decisions about where to attend school.  To retrieve your personalized Veteran's College Financing Plan, follow the selection prompts then click on the "Generate College Financing Plan" button. </div></br> <div>If you have not applied for Financial Aid yet you may not see any amounts awarded in the Scholarship and Grants section.   For students interested in applying for Financial Aid, you can visit the <a href="https://www.ccsf.edu/paying-college/financial-aid-office" style="color:blue" target="_blank">Financial Aid Office</a> for more information  or apply directly at <a href="https://studentaid.gov/h/apply-for-aid/fafsa" style="color:blue" target="_blank">https://studentaid.gov/h/apply-for-aid/fafsa</a> </div></br> <div>For all Veterans related questions, please see the <a href="https://www.ccsf.edu/student-services/support-programs/veterans-services-city-college-san-francisco" style="color:blue" target="_blank"> Veterans Services office website</a> or contact the Veterans Services at:</p></div> <div>Veterans Educational Transition Services (V.E.T.S) Office</div> <div>&nbsp;</div> <div><strong>Location:</strong>Ocean Campus, Cloud Hall 333 & 332</div> <div><strong>Phone:</strong> 415-239-3486</div> <div><strong>Email:</strong> <a href="mailto:veterans@ccsf.edu" style="color:blue">veterans@ccsf.edu</a></div> <div><strong>Virtual Help Counter (VHC):</strong></div> 	<div>- Zoom Meeting Link: <a href="https://ccsf-edu.zoom.us/j/99053196123" style="color:blue" target="_blank">https://ccsf-edu.zoom.us/j/99053196123</a></div> 	<div>- Zoom Meeting ID: <a href="https://ccsf-edu.zoom.us/j/99053196123" style="color:blue" target="_blank">900 5319 6123</a></div> </br></br> </html>

3. Block Component
    * Name: selectAidYearBlock
    * Show Initially: Checked
    * Select Component
        * Type: Select
        * Name: aidYearDD
        * Source Model: veCfpAidYearDomain
        * Label Key: ROBINST_AIDY_DESC
        * Value Key: ROBINST_AIDY_CODE
        * Label: Aid Year
        * Required: Checked
        * On Update: 
                    $militaryStatusDD = null;
                    $giBillDD = null;
                    $spouseActiveDutyDD= null;
                    $militaryServiceDD= null;
                    $benefitsPriorDD= null;
                    $enlistmentYearsDD= null;
                    $post911GiBillEligibleDD= null;
                    $dependentsDD = null;
                    $militaryStatusDD.$load();
                    $selectMilitaryStatusBlock.$visible=true;
                    $spouseActiveDutyDDBlock.$visible=false;
                    $selectMilitaryBenefitBlock.$visible=false;
                    $militaryServiceDDBlock.$visible=false;
                    $selectBenefitsPriorBlock.$visible=false;
                    $selectEnlistmentYearsBlock.$visible=false;
                    $selectPost911GiBillEligibleBlock.$visible=false;
                    $selectDependents.$visible=false;
        * Load Initially: Checked
4. Block Component
    * Name: selectMilitaryStatusBlock
    * Show Initially: Unchecked
    * Select Component
        * Type: Select
        * Name: militaryStatusDD
        * Source Model: veCfpMilitaryStatus
        * Label Key: MIL_STATUS_DESC
        * Value Key: MIL_STATUS_CODE
        * Label: What is your military status?
        * Required: Checked
        * On Update: 
                    $giBillDD = null;
                    $spouseActiveDutyDD= null;
                    $militaryServiceDD= null;
                    $benefitsPriorDD= null;
                    $enlistmentYearsDD= null;
                    $post911GiBillEligibleDD= null;
                    $dependentsDD = null;
                    $selectMilitaryBenefitBlock.$visible=true;
                    $giBillDD.$load();
                    if ($militaryStatusDD == 'D') {
                    $spouseActiveDutyDDBlock.$visible=true;
                    $selectMilitaryBenefitBlock.$visible=true;
                    $militaryServiceDDBlock.$visible=false;
                    $selectBenefitsPriorBlock.$visible=false;
                    $selectEnlistmentYearsBlock.$visible=false;
                    $selectPost911GiBillEligibleBlock.$visible=false;
                    $selectDependents.$visible=false;
                    } else {
                    $selectMilitaryBenefitBlock.$visible=true;
                    $spouseActiveDutyDDBlock.$visible=false;
                    $militaryServiceDDBlock.$visible=false;
                    $selectBenefitsPriorBlock.$visible=false;
                    $selectEnlistmentYearsBlock.$visible=false;
                    $selectPost911GiBillEligibleBlock.$visible=false;
                    $selectDependents.$visible=false;
                    }
        * Load Initially: Checked
5. Block Component
    * Name: spouseActiveDutyDDBlock
    * Show Initially: Unchecked
    * Select Component     
        * Type: Select
        * Name: spouseActiveDutyDD
        * Source Model: veCfpYesNo
        * Label Key: YES_NO_DESC
        * Value Key: YES_NO
        * Label: Is your spouse on active duty?
        * Required: Checked
        * On Update: 
                    $selectMilitaryBenefitBlock.$visible=true;
                    $giBillDD.$load()
        * Load Initially: Checked   
6. Block Component
    * Name: selectMilitaryBenefitBlock
    * Show Initially: Unchecked
    * Select Component     
        * Type: Select
        * Name: giBillDD
        * Source Model: veCfpGIBill
        * Label Key: VET_CODE_DESC
        * Value Key: VET_CODE
        * Label: Which GI Bill benefit do you want to use?
        * Source Parameters: parm_mil_stat = $militaryStatusDD
        * Required: Checked
        * On Update: 
                    $spouseActiveDutyDD= null;
                    $militaryServiceDD= null;
                    $benefitsPriorDD= null;
                    $enlistmentYearsDD= null;
                    $post911GiBillEligibleDD= null;
                    $dependentsDD = null;
                    if ($giBillDD == 'CH30') {
                    $selectEnlistmentYearsBlock.$visible=true;
                    $generateFormButtonBlock.$visible=false;
                    $militaryServiceDDBlock.$visible=false;
                    $selectBenefitsPriorBlock.$visible=false;
                    $selectPost911GiBillEligibleBlock.$visible=false;
                    $selectDependents.$visible=false;
                    $generateFormButtonBlock.$visible=false;
                    } else if ($giBillDD == 'CH33') {
                    $militaryServiceDDBlock.$visible=true;
                    $selectBenefitsPriorBlock.$visible=false;
                    $selectEnlistmentYearsBlock.$visible=false;
                    $selectPost911GiBillEligibleBlock.$visible=false;
                    $selectDependents.$visible=false;
                    $generateFormButtonBlock.$visible=false;
                    } else if ($giBillDD == 'VRE') {
                    $selectPost911GiBillEligibleBlock.$visible=true;
                    $selectEnlistmentYearsBlock.$visible=false;
                    $militaryServiceDDBlock.$visible=false;
                    $selectBenefitsPriorBlock.$visible=false;
                    $generateFormButtonBlock.$visible=false;
                    } else {
                    $generateFormButtonBlock.$visible=true;
                    $selectEnlistmentYearsBlock.$visible=false;
                    $militaryServiceDDBlock.$visible=false;
                    $selectBenefitsPriorBlock.$visible=false;
                    $selectPost911GiBillEligibleBlock.$visible=false;
                    $selectDependents.$visible=false;
                    $studentDataHtmlTable.$load();
                    }
        * Load Initially: Checked   
7. Block Component
    * Name: militaryServiceDDBlock
    * Show Initially: Unchecked
    * Select Component     
        * Type: Select
        * Name: militaryServiceDD
        * Source Model: veCfpMilitaryService
        * Label Key: SERVICE_DESC
        * Value Key: SERVICE_CODE
        * Label: Cumulative Post-9/11 active-duty service
        * Required: Unchecked
        * On Update: 
                    $spouseActiveDutyDD= null;
                    $benefitsPriorDD= null;
                    $enlistmentYearsDD= null;
                    $post911GiBillEligibleDD= null;
                    $dependentsDD = null;
                    $selectBenefitsPriorBlock.$visible=true;
                    $serviceSelect.$load();
        * Load Initially: Checked               
8. Block Component
    * Name: selectBenefitsPriorBlock
    * Show Initially: Unchecked
    * Select Component     
        * Type: Select
        * Name: benefitsPriorDD
        * Source Model: veCfpYesNo
        * Label Key: YES_NO_DESC
        * Value Key: YES_NO
        * Label: Did you use your Post-9/11 GI Bill benefits for tuition, housing, or books for a term that started before January 1, 2018?
        * Required: Checked
        * On Update: 
                    $generateFormButtonBlock.$visible=true;
                    $studentDataHtmlTable.$load();
        * Load Initially: Checked
9. Block Component
    * Name: selectEnlistmentYearsBlock
    * Show Initially: Unchecked
    * Select Component     
        * Type: Select
        * Name: enlistmentYearsDD
        * Source Model: veCfpEnlistment
        * Label Key: ENLISTMENT_DESC
        * Value Key: ENLISTMENT
        * Label: Completed an enlistment of:
        * Required: Unchecked
        * On Update: 
                    $generateFormButtonBlock.$visible=true;
                    $studentDataHtmlTable.$load();
        * Load Initially: Checked
10. Block Component
    * Name: selectPost911GiBillEligibleBlock
    * Show Initially: Unchecked
    * Select Component     
        * Type: Select
        * Name: post911GiBillEligibleDD
        * Source Model: veCfpYesNo
        * Label Key: YES_NO_DESC
        * Value Key: YES_NO
        * Label: Are you eligible for the Post-9/11 GI Bill?
        * Required: Checked
        * On Update: 
                    $militaryServiceDD= null;
                    $benefitsPriorDD= null;
                    $enlistmentYearsDD= null;
                    $dependentsDD = null;
                    if ($post911GiBillEligibleDD == 'Y') {
                    $selectDependents.$visible=false;
                    $generateFormButtonBlock.$visible=true;
                    $studentDataHtmlTable.$load();
                    } else  {
                    $selectDependents.$visible=true;
                    $generateFormButtonBlock.$visible=false;
                    }
        * Load Initially: Checked        
11. Block Component
    * Name: selectDependents
    * Show Initially: Unchecked
    * Select Component     
        * Type: Select
        * Name: dependentsDD
        * Source Model: veCfpDependents
        * Label Key: DEPENDENTS
        * Value Key: DEPENDENTS
        * Label: How many dependents do you have?
        * Required: Checked
        * On Update: 
                    $generateFormButtonBlock.$visible=true;
                    $studentDataHtmlTable.$load();
        * Load Initially: Checked
12. Block Component
    * Name: studentDataBlock
    * Show Initially: Unchecked
    * HTML Table Component   
        * Type: Html Table
        * Name: studentDataHtmlTable
        * Model: veCfpStudentData
        * Parameters: 
                    parm_aidy	= $aidYearDD
                    parm_mil_status	= $militaryStatusDD
                    parm_mil_ben = $giBillDD
                    parm_mil_service = $militaryServiceDD
                    parm_nbr_dependents = $dependentsDD
                    parm_spouse_act_duty = $spouseActiveDutyDD
                    parm_post_911_elig = $post911GiBillEligibleDD
                    parm_enlist_yrs = $enlistmentYearsDD
                    parm_ben_prior = $benefitsPriorDD
        * Page Size: 5
        * Required: Checked
        * On Load: 
                    $displayToday=$studentDataHtmlTable.$selected.TODAY; $displayFirstName=$studentDataHtmlTable.$selected.FIRST_NAME; $displayLastName=$studentDataHtmlTable.$selected.LAST_NAME; $displayStudentID=$studentDataHtmlTable.$selected.STUDENT_ID; $displayStartYear=$studentDataHtmlTable.$selected.START_YEAR; $displayEndYear=$studentDataHtmlTable.$selected.END_YEAR; $displayTuition=$studentDataHtmlTable.$selected.TUITION; $displayRoomBoard=$studentDataHtmlTable.$selected.ROOM_BOARD; $displayBooksSupplies=$studentDataHtmlTable.$selected.BOOKS_SUPPLIES; $displayTransportation=$studentDataHtmlTable.$selected.TRANSPORTATION; $displayOther=$studentDataHtmlTable.$selected.OTHER; $displayEstCoa=$studentDataHtmlTable.$selected.EST_COA; $displayInstSch=$studentDataHtmlTable.$selected.INST_SCH; $displayStateSch=$studentDataHtmlTable.$selected.STATE_SCH; $displayOtherSch=$studentDataHtmlTable.$selected.OTHER_SCH; $displayTotalSch=$studentDataHtmlTable.$selected.TOTAL_SCH; $displayPell=$studentDataHtmlTable.$selected.PELL; $displayInstGrnt=$studentDataHtmlTable.$selected.INST_GRNT; $displayStateGrnt=$studentDataHtmlTable.$selected.STATE_GRNT; $displayOtherGrnt=$studentDataHtmlTable.$selected.OTHER_GRNT; $displayTotalGrnt=$studentDataHtmlTable.$selected.TOTAL_GRNT; $displayNetPrice=$studentDataHtmlTable.$selected.NET_PRICE; $displaySubLoan=$studentDataHtmlTable.$selected.SUB_LOAN; $displayUnsubLoan=$studentDataHtmlTable.$selected.UNSUB_LOAN; $displayTotalLoan=$studentDataHtmlTable.$selected.TOTAL_LOAN; $displayWorkStudy=$studentDataHtmlTable.$selected.WORK_STUDY; $displayWorkStudyHoursWk=$studentDataHtmlTable.$selected.WORK_STUDY_HOURS_WK; $displayVetBenTuition=$studentDataHtmlTable.$selected.TUITION_BENEFIT; $displayVetHousingAllowance=$studentDataHtmlTable.$selected.HOUSING_ALLOWANCE; 
                    $displayVetBookStipend=$studentDataHtmlTable.$selected.BOOK_STIPEND;
        * Load Initially: Checked
        * Display Component
            Type: Display  
            Name: firstNameValue
            Label: First Name
            Model: FIRST_NAME
            Load Initially: Checked
        * Display Component
            Type: Display  
            Name: tuitionValue
            Label: Tuition
            Model: TUITION_BENEFIT
            Load Initially: Checked
        * Display Component
            Type: Display  
            Name: housingValue
            Label: Housing
            Model: HOUSING_ALLOWANCE
            Load Initially: Checked
        * Display Component
            Type: Display  
            Name: bookValue
            Label: Book
            Model: BOOK_STIPEND
            Load Initially: Checked
    * Literal Component
        Type: Literal
        Name: firstNameDisplay
        Value: $studentDataHtmlTable.$selected.FIRST_NAME

13. Block Component
    * Name: generateFormButtonBlock
    * Show Initially: Unchecked
    * Button Component   
        * Type: Button
        * Name: generateCfpButton
        * Label: Generate College Financing Plan
        * On Click: 
                    $studentDataHtmlTable.$load();
                    $veCfpDocumentBlock.$visible=true;
                    $selectAllBlock.$visible=false;

14. Block Component
    * Name: veCfpDocumentBlock
    * Show Initially: Unchecked
    * Button Component
        * Type: Button
        * Name: vetBenInfoBackButton
        * Label: Back
        * On Click: 
                    $selectAllBlock.$visible=true;
                    $veCfpDocumentBlock.$visible=false;       
    * Literal Component
        * Type: Literal
        * Name: veCfpDocumentHtml
        * Value:     
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="utf-8">
                    <meta http-equiv="X-UA-Compatible" content="IE=edge">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <title>College Financing Plan</title>
                    <link rel="stylesheet" type="text/css" href="https://rawcdn.githack.com/tkevinle/css/d75f670c855250226b43c3cd2faf56c5c6f83fc5/reset.css" />
                    <link rel="stylesheet" type="text/css" href="https://rawcdn.githack.com/tkevinle/css/ac0cdf8c18e5e9fc8cb25903535042c8807841b8/styles.css" />
                    <link rel="stylesheet" type="text/css" href="https://rawcdn.githack.com/tkevinle/css/d75f670c855250226b43c3cd2faf56c5c6f83fc5/custom.css" />
                    <script defer type="text/javascript" src="https://rawcdn.githack.com/tkevinle/css/d75f670c855250226b43c3cd2faf56c5c6f83fc5/scripts.js"></script>
                </head>

                <body>
                    <div id="sheet" class="container">
                        <div class="panel main-header-panel">
                            <header class="main-header panel-header">
                                <div class='pull-right'>
                                    <div id="date-stamp">$displayToday</div>     
                                </div>
                                <div class="school-heading">
                                    <h1 id="school-name">City College of San Francisco</h1>
                                    <h2>Veterans College Financing Plan</h2>
                                    <h3 id="student-name">$displayFirstName $displayLastName, $displayStudentID</h3>
                                </div>
                            </header>
                        </div>

                        <table id="costs-table" class="table numbers" cellspacing="0">
                            <thead>
                                <tr>
                                    <th colspan="3">Total Cost of Attendance $displayStartYear - $displayEndYear</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><span class="line-text">Tuition and fees</span></td>
                                    <td class="line-value text-center" colspan="2"><span class="dollar">$</span><span
                                            id="costs-tuition-and-fees" class="amount">$displayTuition</span></td>
                                </tr>
                                <tr>
                                    <td><span class="line-text">Housing and meals</span></td>
                                    <td class="line-value text-center" colspan="2"><span class="dollar">$</span><span
                                            id="costs-housing-and-meals-off-campus" class="amount">$displayRoomBoard</span></td>
                                </tr>
                                <tr>
                                    <td><span class="line-text">Books and supplies</span></td>
                                    <td class="line-value text-center" colspan="2"><span class="dollar">$</span><span
                                            id="costs-books-and-supplies" class="amount">$displayBooksSupplies</span></td>
                                </tr>
                                <tr>
                                    <td><span class="line-text">Transportation</span></td>
                                    <td class="line-value text-center" colspan="2"><span class="dollar">$</span><span
                                            id="costs-transportation" class="amount">$displayTransportation</span></td>
                                </tr>
                                <tr>
                                    <td><span class="line-text">Other education costs</span></td>
                                    <td class="line-value text-center" colspan="2"><span class="dollar">$</span><span
                                            id="costs-other-education-costs" class="amount">$displayOther</span></td>
                                </tr>
                                <tr>
                                    <td><span class="line-text"><span id="costs-total-estimated-cost-explain"
                                                class="line-text strong">Estimated Cost of Attendance</span></span></td>
                                    <td class="line-value text-center" colspan="2"><span class="dollar strong">$</span><span
                                            id="costs-total-estimated-cost-off-campus" class="amount strong">$displayEstCoa</span> <span
                                            class="per-year">/ yr</span></td>
                                </tr>
                            </tbody>
                        </table>
                        <h2>Scholarship and Grant Options</h2>
                        <p>Scholarships and Grants are considered "Gift" aid - no repayment is needed.</p>
                        <section class="content numbers">
                            <table id="scholarships-table" class="table numbers" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th colspan="2">Scholarships</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="2"><span class="line-text">Merit-Based Scholarships</span></td>
                                    </tr>
                                    <tr>
                                        <td><span>Scholarships from your school</span></td>
                                        <td><span class="dollar">$</span><span id="aid-scholarships-school" class="amount">$displayInstSch</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="indent">Scholarships from your state</span></td>
                                        <td><span class="dollar">$</span><span id="aid-scholarships-state" class="amount">$displayStateSch</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text indent">Other scholarships</span></td>
                                        <td><span class="dollar">$</span><span id="aid-scholarships-other" class="amount">$displayOtherSch</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text">Employer Paid Tuition Benefits</span></td>
                                        <td><span class="dollar">$</span><span id="employer-paid-tuition-benefits"
                                                class="amount">0</span></td>
                                    </tr>
                                    <tr>
                                        <td><span class='strong'>Total Scholarships</span></td>
                                        <td><span class="dollar strong">$</span><span id="aid-total-scholarships"
                                                class='strong'>$displayTotalSch</span> <span class="per-year">/ yr</span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </section>

                        <aside class="aside">
                            <table id="grants-table" class="table numbers" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th colspan="2">Grants</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td colspan="2"><span class="line-text">Need-Based Grant Aid</span></td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text indent">Federal Pell Grants</span></td>
                                        <td><span class="dollar">$</span><span id="aid-grants-federal-pell" class="amount">$displayPell</span>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><span class="line-text indent">Institutional Grants</span></td>
                                        <td><span class="dollar">$</span><span id="aid-grants-institution" class="amount">$displayInstGrnt</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text indent">State Grants</span></td>
                                        <td><span class="dollar">$</span><span id="aid-grants-state" class="amount">$displayStateGrnt</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text">Other forms of grant aid</span></td>
                                        <td><span class="dollar">$</span><span id="aid-grants-other" class="amount">$displayOtherGrnt</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text strong">Total Grants</span></td>
                                        <td><span class="dollar strong">$</span><span id="aid-total-grants"
                                                class="amount strong">$displayTotalGrnt</span> <span class="per-year">/ yr</span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </aside>

                        <table id="net-price-table" class="table numbers accent" cellspacing="0">
                            <thead>
                                <tr>
                                    <th colspan="2">College Costs You Will Be Required to Pay</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <span class="line-text strong">Net Price <br /><span class='no-margin-note'>(Cost of attendance
                                                minus
                                                total grants and scholarships)</span></span>
                                    </td>
                                    <td><span class="dollar strong">$</span><span id="net-price-total"
                                            class="amount strong">$displayNetPrice</span> <span class="per-year">/ yr</span></td>
                                </tr>
                            </tbody>
                        </table>
                        
                        <table id="costs-table" class="table numbers" cellspacing="0">
                            <thead>
                                <tr>
                                    <th colspan="2">Veterans Benefits</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td colspan="2">You may be eligible for up to:</td>
                                </tr>
                                <tr>
                                    <td>
                                        <span class="line-text strong">Tuition </span> (annually)
                                    </td>
                                    <td><span class="dollar strong">$</span><span id="net-price-total"
                                            class="amount strong">$displayVetBenTuition</span></td>
                                </tr>
                                <tr>
                                    <td>
                                        <span class="line-text strong">Housing </span>(monthly)
                                    </td>
                                    <td><span class="dollar strong">$</span><span id="net-price-total"
                                            class="amount strong">$displayVetHousingAllowance</span></td>
                                </tr>
                                <tr>
                                    <td>
                                        <span class="line-text strong">Books </span>(annually)
                                    </td>
                                    <td><span class="dollar strong">$</span><span id="net-price-total"
                                            class="amount strong">$displayVetBookStipend</span></td>
                                </tr>
                            </tbody>
                        </table>

                        <h2>Loan and Work Options to Pay the Net Price to You</h2>
                        <p>You must repay loans, plus interest and fees.  </p>
                        <section class='content numbers'>
                            <table id="loan-options-table" class="table numbers" cellspacing="0">
                                <thead>
                                    <tr>
                                        <th colspan="2">Loan Options<sup>*</sup></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><span class="line-text">Federal Direct Subsidized Loan
                                        </span></td>
                                        <td><span class="dollar">$</span><span id="loan-options-federal-direct-subsidized"
                                                class="amount">$displaySubLoan</span> <span class="per-year">/ yr</span></td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text">Federal Direct Unsubsidized Loan
                                        </span></td>
                                        <td><span class="dollar">$</span><span id="loan-options-federal-direct-unsubsidized"
                                                class="amount">$displayUnsubLoan</span> <span class="per-year">/ yr</span></td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text strong">Total Loan Options</span></td>
                                        <td><span class="dollar strong">$</span><span id="loan-options-total"
                                                class="amount strong">$displayTotalLoan</span> <span class="per-year">/ yr</span></td>
                                    </tr>
                                </tbody>
                            </table>
                                
                            <div class="aside-group panel simple loans" style='min-height: 144px;'>
                                <header class="header info-header">
                                    <h2 class="default-font">* Loan Amounts</h2>
                                </header>
                                <p>Note that the amounts listed
                                    are the maximum available to you - you are allowed and encouraged to borrow only what you need.To learn about loan repayment choices and calculate your Federal Loan monthly payment, go
                                    to:
                                    <a target="_blank"
                                        href="https://studentaid.gov/h/manage-loans">https://studentaid.gov/h/manage-loans</a>.
                                </p>
                            </div>
                            <div class="aside-group panel simple loans" style='min-height: 116px;'>
                                <header class="header info-header">
                                    <h2 class="default-font">Other Important Information</h2>
                                </header>
                                <p> To view campus Graduation Rates, click <a href="https://ccsf.edu" target="_blank">HERE</a>.</p>
                                <p> To view campus Transfer Credit, click <a href="https://ccsf.edu" target="_blank">HERE</a>.</p>
                                <p> To view campus Military Credit, click <a href="https://ccsf.edu" target="_blank">HERE</a>.</p>
                            </div>
                            <div class="aside-group panel simple loans" style='min-height: 116px;'>
                                <header class="header info-header">
                                    <h2 class="default-font">Customized Information from CCSF</h2>
                                </header>
                                <p>The estimated figures on this Veterans College Financing Plan are meant to help you easily compare veteran and financial aid packages offered by different institutions and ultimately make an informed decision on where 
                                    to invest in your higher education.  Although we've done our best to accurately calculate these figures, please remember these are only estimates.  Should you choose to attend our institution, your final figures could differ.
                                    For more information please visit our website <a href="https://ccsf.edu" target="_blank">HERE</a>.
                                </p>
                            </div>
                        
                        </section>
                        <aside class='aside'>
                            <table id="work-options-table" class="table numbers"
                                cellspacing="0">
                                <thead>
                                    <tr>
                                        <th colspan="2">Work Options</th>
                                    </tr>
                                </thead>
                                <tbody>
                                        <tr>
                                        <td><span class="line-text">Work-study </span><span class="inline-note">Hours Per Week (estimated)</span></td>
                                        <td><span class="dollar">$</span><span id="work-options-work-study" class="amount">$displayWorkStudy</span>
                                            <span class="per-year">/ yr</span><span class="inline-note"></span><span id="work-options-hours-per-week" class="amount">$displayWorkStudyHoursWk</span>
                                            <span class="per-year">/ wk</span></td>
                                    </tr>
                                    <tr>
                                        <td><span class="line-text strong">Total Work </span></td>
                                        <td><span class="dollar strong">$</span><span id="work-options-total"
                                                class="amount strong">$displayWorkStudy</span> <span class="per-year">/ yr</span></td>
                                    </tr>
                                </tbody>
                            </table>
                            <div class="aside-group panel simple loans" style='min-height: 147px;'>
                                <header class="header info-header">
                                    <h2 class="default-font">For More Information</h2>
                                </header>
                                <div class="address-container">
                                
                                    <span id="info-school-name" class="address-name">City College of San Francisco</span>
                                    <br>
                                    <span id="info-financial-aid-office" class="address-name">Veterans Educational Transition Services (VETS) Office</span>
                                    <div class="address">
                                        <div id="info-address-line-1" class="address-line">50 Frida Kahlo Way</div>
                                        <div id="info-address-line-2" class="address-line">Cloud Hall 333 & 332</div>
                                        <div id="info-address-city-state-zip" class="address-line">San Francisco, CA 94112</div>
                                        <div id="info-address-phone" class="address-line">Telephone: (415) 239-3486</div>
                                        <div id="info-address-email" class="address-line">E-mail: veterans@ccsf.edu</div>
                                    </div>
                                </div>
                            </div>
                        </aside>
                        <aside class="aside">
                            <div class="aside-group panel simple loans" style='min-height: 200px;'>
                                <header class="header info-header">
                                    <h2 class="default-font"> Education Tax Benefits</h2>
                                </header>
                                <ul id="other-options-list">
                                    <li><strong>American Opportunity Tax Credit (AOTC):</strong> Parents or students may qualify to
                                        receive up to $2,500 by claiming the American Opportunity Tax Credit on their tax return
                                        during the following calendar year.</li>
                                    <li><strong>529 Savings Plan:</strong> 529 Savings Plan is a college savings plan that offers tax and financial aid benefits. </li>
                                    <li><strong>Prepaid Tuition Plans:</strong> Prepaid Tuition Plans let you pre-pay all or part of the costs of an in-state public college education. They may also be converted for use at private and out-of-state colleges. The Private College 529 Plan is a separate prepaid plan for private colleges, sponsored by more than 250 private colleges.</li>
                                    <li><strong>Lifetime Learning Credit (LLC):</strong> Parents or students many qualify to receive up to $2,000 by claiming the LLC on their tax return. This credit may be taken for an unlimited account of tax years, is non-refundable and cannot be combined with the AOTC in a tax year.</li>
                                    <li><strong>Student Loan Interest Deduction:</strong> Student loan borrowers may qualify to receive up to $2,500 by claiming the deduction on their tax return if they repay interest on a student loan in a taxable year. This is an above-the-line deduction, meaning it can be taken even if the taxpayer takes the standard deduction. Parents who take out Parent PLUS loans are also eligible to take this deduction.</li>
                                    <li><strong>Military and/or National Service Benefits:</strong> For information please visit:<a target="_blank"
                                        href="https://studentaid.gov/understand-aid/types/military"> https://studentaid.gov/understand-aid/types/military </a></li>
                                </ul>
                            </div>
                        
                        </aside>
                        <div class="clearfix page-break"></div>

                    
                        <div class="clearfix"></div>

                        <table id="glossary" cellspacing="0">
                            <thead>
                                <tr>
                                    <th>Glossary</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <ul id="glossary-list">
                                        <li id="term-coa">
                                                <strong>Cost of Attendance (COA):</strong> The total amount (not including grants and
                                                scholarships) that it will cost you to go to school during the 2021–22 school year. COA
                                                includes tuition and fees; housing and meals;
                                                and allowances for books, supplies, transportation, loan fees, and dependent care. It
                                                also includes miscellaneous and personal expenses, such as an allowance for the rental
                                                or purchase of a personal computer; costs related
                                                to a disability; and reasonable costs for eligible study-abroad programs. For students
                                                attending less than half-time, the COA includes tuition and fees; an allowance for
                                                books, supplies, and transportation; and dependent
                                                care expenses.
                                            </li>
                                                    <li><strong>Direct Subsidized Loan:</strong> Loans that the U.S. Department of
                                                        Education pays the interest on
                                                        while you’re in school at least half-time, for the first six months after you
                                                        leave school (referred to as a grace period*), and during a period of deferment
                                                        (a postponement of loan payments).</li>
                                                    <li><strong>Direct Unsubsidized Loan:</strong> Loans that the borrower is
                                                        responsible for paying the interest on during all periods. If you choose not to
                                                        pay the interest while you are in school and during grace periods and deferment
                                                        or forbearance periods, your interest will accrue (accumulate) and be
                                                        capitalized (that is, your interest will be added to the principal amount of
                                                        your loan).</li>
                                                <li id="term-expected-family-contribution">
                                                <strong>Expected Family Contribution:</strong> A number used by your school to
                                                calculate the amount of federal student aid you are eligible to receive. It is based on
                                                the financial information provided in your Free Application for Federal student Aid
                                                (FAFSA). This is not the amount of money your family will have to pay for college, nor
                                                is it the amount of federal student aid you will receive.
                                            </li> 
                                                <li id="term-federal-work-study">
                                                <strong>Federal Work-Study:</strong> A federal student aid program that provides
                                                part-time employment while the student is enrolled in school to help pay his or her
                                                education expenses. The student must seek out and apply for work-study jobs at his or
                                                her school. The student will be paid directly for the hours he or she works may not automatically be credited to pay for institutional tuition or fees. The
                                                amount you earn cannot exceed the total amount awarded by the school for the
                                                award year. The availability of work-study jobs varies by school. Please note that Federal Work-Study earnings may be taxed in certain scenarios; however the income you earn will not be counted against you when calculating your Expected Family Contribution on the FASFA.
                                            </li>
                                        
                                            <li id="term-grants-and-scholarships">
                                                <strong>Grants and Scholarships:</strong> Student aid funds that do not have to be
                                                repaid. Grants are often need-based, while scholarships are usually merit-based.
                                                Occasionally you might have to pay back part or all
                                                of a grant if, for example, you withdraw from school before finishing a semester.
                                                If you use a grant or scholarship to cover your living expenses, the amount of your scholarship may be counted as taxable income on your tax return.
                                            </li> 
                                            <li id="term-option-loans">
                                                <strong>Loans:</strong> Borrowed money that must be repaid with interest. Loans from the
                                                federal government typically have a lower interest rate than loans from private lenders.
                                                Federal loans, listed from most advantageous
                                                to least advantageous, are called Direct Subsidized Loans, Direct Unsubsidized Loans,
                                                and Parent PLUS Loans. You can find more information about federal loans at
                                                StudentAid.gov.
                                            </li>       
                                            <li id="term-net-price">
                                                <strong>Net Price:</strong> An estimate of the actual cost that a student and his or her family
                                                need to pay in a given year to cover education expenses for the student to attend a
                                                particular school. Net price is determined by taking the institution's cost of
                                                attendance and subtracting any grants and scholarships for which the student may be
                                                eligible.
                                            </li>
                                            <li class='strong'>For more information visit <a href="https://studentaid.gov" target="_blank">https://studentaid.gov</a>.</li>
                                        </ul>
                                    </td>
                                </tr>
                            </tbody>
                        </table>       
                    </div>
                </body>
                </html>               

                         



* Name: veCfpBenefitsValidationPage
* Title: Veterans Benefits Validation Page
* Import Custom Style Sheets: ccsf_ve_cfpCss
* HOME URL:
    * PPRD:
    * PROD: 

* URL:
    * PPRD: 
    * PROD: 
* Spring Security Attributes: 
    ROLE_GPBADMN_BAN_DEFAULT_PAGEBUILDER_M,ROLE_SELFSERVICE-ALLROLES_BAN_DEFAULT_M

1. Resources
    * veCfpValidation - virtualDomains.veCfpValidation
    * veCfpMilitaryStatus - virtualDomains.veCfpMilitaryStatus
    * veCfpGIBill - virtualDomains.veCfpGIBill
    * veCfpMilitaryService - virtualDomains.veCfpMilitaryService
    * veCfpValidationCopy - virtualDomains.veCfpCopyValidation
    * veCfpAidYearDomain - virtualDomains.veCfpAidYearDomain
    * veCfpAidYearToSelect - virtualDomains.veCfpAidYearToSelect

2. Literal Component
    * Name: dateFormatChange
    * Value: 
            <script>
            $(document).ready( function () {
            delete  $.datepicker.regional[dateTimeLocale].dateFormat ; });</script>

3. Block Component
    * Name: selectAidYearBlock
    * Label: Configure Veterans Financing Plan Amounts
    * Show Initially: Checked
    * Literal Component
        * Name: configureDataDescription
        * Value: Select Aid Year and update Book/Housing/Tuition amounts for all Veterans Benefits Programs.
    * Select Component
        * Type: Select
        * Name: aidYearDD
        * Source Model: veCfpAidYearDomain
        * Label Key: ROBINST_AIDY_DESC
        * Value Key: ROBINST_AIDY_CODE
        * Label: Select Aid Year:
        * Required: Checked
        * On Update :$benefitsValidationTable.$load();
        * Load Initially: Checked

4. Block Component
    * Name: benefitsValidationBlock
    * Show Initially: Checked
    * Grid Component
        * Type: Grid
        * Name: benefitsValidationTable
        * Model: veCfpValidation
        * Parameters: parm_aidy = $aidYearDD
        * Allow New: Checked
        * Allow Modify: Checked
        * Allow Delete: Checked
        * Allow Reload: Checked
        * Page Size: 30
        * On Save Success: alert('Saved Successfully');
        * On Error: alert(response.data.errors.errorMessage,{type:"error"});
        * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_AIDY_CODE
            * Model: GZRVCFP_AIDY_CODE
            * Load Initially: Checked
        * Select Component
            * Type: Select
            * Name: militaryStatusDD
            * Source Model: veCfpMilitaryStatus
            * Label Key: MIL_STATUS_DESC
            * Value Key: MIL_STATUS_CODE
            * Label: Military Status
            * Model: GZRVCFP_MIL_STATUS
            * On Update: 
                        $militaryStatus=$benefitsValidationTable.$selected.GZRVCFP_MIL_STATUS;$militaryBenefitDD.$load();
            * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_MIL_STATUS
            * Model: GZRVCFP_MIL_STATUS
            * Load Initially: Checked
        * Select Component
            * Type: Select
            * Name: militaryBenefitDD
            * Source Model: veCfpGIBill
            * Label Key: VET_CODE_DESC
            * Value Key: VET_CODE
            * Label: Military Benefit
            * Model: GZRVCFP_MIL_BENEFIT
            * Required: Checked
            * On Update: 
                        $veCfpMilitaryServiceDD.$load();
            * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_MIL_BENEFIT
            * Model: GZRVCFP_MIL_BENEFIT
            * Load Initially: Checked
        * Select Component
            * Type: Select
            * Name: selectMilitaryServiceDD
            * Source Model: veCfpMilitaryService
            * Label Key: SERVICE_DESC
            * Value Key: SERVICE_CODE
            * Label: Military Service
            * Parameters: 
                        parm_mil_ben = $selectMilitaryBenefit
                        GZRVCFP_MIL_BENEFIT = $selectMilitaryBenefit
            * Model: GZRVCFP_MIL_SERVICE
            * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_MIL_SERVICE
            * Model: GZRVCFP_MIL_SERVICE
            * Load Initially: Checked
        * Boolean Component
            * Type: Boolean
            * Name: GZRVCFP_SPOUSE_ACT_DUTY
            * Label: Spouse Active Duty
            * Model: GZRVCFP_SPOUSE_ACT_DUTY
            * Boolean True Value: Y
            * Load Initially: Checked
        * Boolean Component
            * Type: Boolean
            * Name: GZRVCFP_BEN_PRIOR_20180101
            * Label: Recd Ben Prior 20180101
            * Model: GZRVCFP_BEN_PRIOR_20180101
            * Boolean True Value: Y
            * Boolean False Value: N
            * Load Initially: Checked
        * Number Component
            * Type: Number
            * Name: GZRVCFP_COMPL_ENLIST_YRS
            * Label: Years of Enlist Completed
            * Value Style: data-amount
            * Model: GZRVCFP_COMPL_ENLIST_YRS
            * Fraction Digits: 0
            * Load Initially: Checked 
        * Boolean Component
            * Type: Boolean
            * Name: GZRVCFP_POST_911_ELIG
            * Label: Post 911 Elig
            * Model: GZRVCFP_POST_911_ELIG
            * Boolean True Value: Y
            * Boolean False Value: N
            * Load Initially: Checked
        * Number Component
            * Type: Number
            * Name: GZRVCFP_NBR_DEPENDENTS
            * Label: Nbr of Dependents
            * Value Style: data-amount
            * Model: GZRVCFP_NBR_DEPENDENTS
            * Fraction Digits: 0
            * Load Initially: Checked 
        * Number Component
            * Type: Number
            * Name: GZRVCFP_TUITION_ANNUAL
            * Label: Annual Tuition Amt
            * Style: align: right;
            * Value Style: data-amount
            * Model: GZRVCFP_TUITION_ANNUAL
            * Fraction Digits: 2
            * Required: Checked
            * Load Initially: Checked 
        * Number Component
            * Type: Number
            * Name: GZRVCFP_HOUSING_MONTHLY
            * Label: Monthly Housing Amt
            * Style: align: right;
            * Value Style: data-amount
            * Model: GZRVCFP_HOUSING_MONTHLY
            * Fraction Digits: 2
            * Required: Checked
            * Load Initially: Checked
        * Number Component
            * Type: Number
            * Name: GZRVCFP_BOOK_ANNUAL
            * Label: Annual Book Amt
            * Style: align: right;
            * Value Style: data-amount
            * Model: GZRVCFP_BOOK_ANNUAL
            * Fraction Digits: 2
            * Required: Checked
            * Load Initially: Checked
        * Text Component
            * Type: Text
            * Name: GZRVCFP_ACTIVITY_DATE
            * Label: Activity Date
            * Model: GZRVCFP_ACTIVITY_DATE
            * Read Only: Checked
            * Load Initially: Checked
        * Text Component
            * Type: Text
            * Name: GZRVCFP_USER_ID
            * Label: User
            * Model: GZRVCFP_USER_ID
            * Read Only: Checked
            * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_SURROGATE_ID
            * Model: GZRVCFP_SURROGATE_ID
            * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_VERSION
            * Model: GZRVCFP_VERSION
            * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_DATA_ORIGIN
            * Model: GZRVCFP_DATA_ORIGIN
            * Load Initially: Checked
        * Hidden Component
            * Type: Hidden
            * Name: GZRVCFP_VPDI_CODE
            * Model: GZRVCFP_VPDI_CODE
            * Load Initially: Checked

5. Form Component
    * Type: Form
    * Name: copyAidYearDataForm
    * Label: Roll Veterans CFP Data
    * Submit: 
            $veCfpValidationCopy.$post( { parm_fromAidy: $fromAidYearDD, parm_toAidy: $toAidYearDD}, null, function (response){$copyAidYearDataForm.$visible=false; alert('Aid Year Data Successfully Copied');}, function (response) { var msg = "Request Error.\n"; if (response.data.errors.errorMessage) { msg += response.data.errors.errorMessage; } else if (response.data.errors[0].errorMessage) { msg += response.data.errors[0].errorMessage; } else { msg += response.statusText; } if (msg) { alert(msg,{type:"error"}); } });
    * Submit Label: Copy
    * Show Initially: Checked
    * Select Component
        * Type: Select
        * Name: fromAidYearDD
        * Source Model: veCfpAidYearDomain
        * Label Key: ROBINST_AIDY_DESC
        * Value Key: ROBINST_AIDY_CODE
        * Label: From Aid Year:
        * Required: Checked
        * Load Initially: Checked
    * Select Component
        * Type: Select
        * Name: toAidYearDD
        * Source Model: veCfpAidYearToSelect
        * Label Key: ROBINST_AIDY_DESC
        * Value Key: ROBINST_AIDY_CODE
        * Label: To Aid Year:
        * Required: Checked
        * Load Initially: Checked



## APPENDIX C: CSS PAGES

Name: ccsf_ve_cfpCss
Description: Veterans College Financing Plan CSS
Stylesheet Source: 
                .data-amount {
                text-align: right;
                }



## APPENDIX D: DEPARTMENT OF EDUCATION/VETERANS RESOURCES

    * GI Comparison Tool: https://www.va.gov/education/gi-bill-comparison-tool/institution/14907105
    * Department of Education College Financing Plan Template: https://www2.ed.gov/policy/highered/guid/aid-offer/2022-23-anncollfinanplanugrad.pdf