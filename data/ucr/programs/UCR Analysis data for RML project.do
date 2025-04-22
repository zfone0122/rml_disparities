**********************************************************
*name: UCR Analysis data for RML project.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Creates the data file used for the UCR analysis 
*             of the RML project
**********************************************************
clear all

******
*Combine data (UCR, SEER, Policy variables, Covariates) | LONG format (separate obs for all/black/white)
******
***
*UCR (for prior coding, see: "path\source_date\programs\UCR data for RML project.do")
***
use "$path\data\ucr\data\ucr\cleaned\ucr_state-year_2000-2019_cleaned.dta", clear

keep year state state_abb fips *all *black *white num* tot_pop population report_share_ucr

*vars to merge back in 
preserve 
keep year state state_abb fips num* tot_pop population report_share_ucr
tempfile vars 
save `vars'
restore

*reshape long
drop num* state* tot_pop population report_share_ucr
reshape long agg_assault_1899 murder_1899 rape_1899 robbery_1899 arson_1899 burglary_1899 mtr_veh_theft_1899 theft_1899 liquor_1899 drunkenness_1899 vandalism_1899 disorder_cond_1899 total_drug_1899 poss_drug_total_1899 sale_drug_total_1899 sale_cannabis_1899 poss_cannabis_1899 sale_heroin_coke_1899 poss_heroin_coke_1899 sale_synth_narc_1899 poss_synth_narc_1899 sale_other_drug_1899 poss_other_drug_1899 total_cannabis_1899 total_heroin_coke_1899 total_synth_narc_1899 total_other_drug_1899 property_1899 violent_1899 dui_1899 total_1899 pop_r, i(year fips) j(race) string

replace race=subinstr(race, "_", "", .)
encode race, gen(race2)
order race2, after(race)
drop race 
ren race2 race

*merge vars back in 
merge m:1 fips year using `vars'
drop _merge 
order state state_abb fips, before(year)

***
*SEER (for prior coding, see: "path\source_date\programs\SEER data for RML project.do")
*** 
merge m:1 fips year using "$path\data\ucr\data\seer\cleaned\seer_state-year_2000-2019_cleaned.dta", keepusing(totalpop)
drop if _merge==2
drop _merge
ren totalpop totalpop_seer
ren pop_r pop_1899 //<-MAKE SURE THIS IS CORRECT VAR

**create arrest rates (per 100k state population)
foreach i in agg_assault_1899 murder_1899 rape_1899 robbery_1899 arson_1899 burglary_1899 mtr_veh_theft_1899 theft_1899 liquor_1899 drunkenness_1899 vandalism_1899 disorder_cond_1899 total_drug_1899 poss_drug_total_1899 sale_drug_total_1899 sale_cannabis_1899 poss_cannabis_1899 sale_heroin_coke_1899 poss_heroin_coke_1899 sale_synth_narc_1899 poss_synth_narc_1899 sale_other_drug_1899 poss_other_drug_1899 total_cannabis_1899 total_heroin_coke_1899 total_synth_narc_1899 total_other_drug_1899 property_1899 violent_1899 dui_1899 total_1899 {

	cap gen rate_`i'=(`i'/pop_1899)*100000
	
}

*** 
*Policy variables (for prior coding, see: "path\source_date\programs\Policy data for RML project.do")
***
gen state_fips=fips
merge m:1 state_fips year using "$path\data\ucr\data\policy\rml-mml_2000-2019.dta" 
drop if _merge==2
drop _merge 

**RML leads and lags 
merge m:1 state_fips year using "$path\data\ucr\data\policy\rml events_2000-2019.dta", keepusing(F* L*)
drop if _merge==2
drop _merge 

*** 
*Covariates (for prior coding, see: "path\source_date\programs\Policy data for RML project.do")
***
merge m:1 state_fips year using "$path\data\ucr\data\policy\covariates_2000-2019.dta" 
drop if _merge==2
drop _merge 

gen report_share_seer=population/totalpop_seer

**save 
save "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", replace



clear 


