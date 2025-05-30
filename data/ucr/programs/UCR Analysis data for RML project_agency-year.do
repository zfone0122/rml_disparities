**********************************************************
*name: UCR Analysis data for RML project_agency-year.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Creates the data file used for the UCR analysis 
*             of the RML project (agency-year level)
**********************************************************
clear all

******
*Combine data (UCR, SEER, Policy variables, Covariates) | LONG format (separate obs for all/black/white)
******
***
*UCR 
***
use "$path\data\ucr\data\ucr\cleaned\ucr_agency-year_2000-2019_cleaned.dta", clear

order ori_num, after(ori)

keep year ori ori_num ori9 state state_abb fips county *all *black *white num* pop*

*vars to merge back in 
preserve 
keep year ori ori_num ori9 state state_abb fips county num* population
tempfile vars 
save `vars'
restore

*reshape long
drop num* state*
reshape long agg_assault_1899 murder_1899 rape_1899 robbery_1899 arson_1899 burglary_1899 mtr_veh_theft_1899 theft_1899 liquor_1899 drunkenness_1899 vandalism_1899 disorder_cond_1899 total_drug_1899 poss_drug_total_1899 sale_drug_total_1899 sale_cannabis_1899 poss_cannabis_1899 sale_heroin_coke_1899 poss_heroin_coke_1899 sale_synth_narc_1899 poss_synth_narc_1899 sale_other_drug_1899 poss_other_drug_1899 total_cannabis_1899 total_heroin_coke_1899 total_synth_narc_1899 total_other_drug_1899 property_1899 violent_1899 dui_1899 pop_r, i(year fips county ori ori_num ori9) j(race) string

replace race=subinstr(race, "_", "", .)
encode race, gen(race2)
order race2, after(race)
drop race 
ren race2 race

*merge vars back in 
merge m:1 ori_num fips county year using `vars'
drop _merge 
order ori ori_num ori9 state state_abb fips county, before(year)

ren pop_r pop_1899

**create arrest rates (per 100k agency population)
foreach i in total_drug poss_drug_total sale_drug_total poss_cannabis sale_cannabis total_cannabis poss_heroin_coke sale_heroin_coke total_heroin_coke poss_synth_narc sale_synth_narc total_synth_narc poss_other_drug sale_other_drug total_other_drug property theft burglary mtr_veh_theft arson violent agg_assault rape robbery murder liquor drunkenness dui vandalism disorder_cond {

	cap gen rate_`i'_1899=(`i'_1899/pop_1899)*100000
	
}

*** 
*Policy variables 
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
*Covariates 
***
merge m:1 state_fips year using "$path\data\ucr\data\policy\covariates_2000-2019.dta" 
drop if _merge==2
drop _merge 

sort ori year race

**save 
save "$path\data\ucr\data\analysis_files\ucr_agency-year-race_2000-2019_analysis data.dta", replace



clear 


