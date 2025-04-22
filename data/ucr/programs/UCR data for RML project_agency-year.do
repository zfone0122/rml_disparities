**********************************************************
*name: UCR data for RML project_agency-year.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Cleaning UCR data to be used in the RML 
*             project
**********************************************************
clear all

/* Data downloaded from: 
	https://www.openicpsr.org/openicpsr/project/102263/version/V14/view?path=/openicpsr/102263/fcr:versions/V14/ucr_arrests_yearly_data_1974_2020_dta.zip&type=file

File Citation: 

Kaplan, Jacob. Jacob Kaplan's Concatenated Files: Uniform Crime Reporting (UCR) Program Data: Arrests by Age, Sex, and Race, 1974-2020: ucr_arrests_yearly_data_1974_2020_dta.zip. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2021-09-27. https://doi.org/10.3886/E102263V14-107920
To view the citation for the overall project, see http://doi.org/10.3886/E102263V14.

*/   

/* Data to gather

Sample restrictions:
	populations of at least 50,000 during the sample period (and at no point less than 25,000)
	balanced panel of agencies
	agencies reporting >= 6 months each year across sample period OR only report in december

Panel:
	Agency-level 
	2000-2019

Arrest categories:
	Drug (total, sale, possession)
	Marijuana (total, sale, posession)
	Cocaine/Heroin/Crack/Other Opioids (total, sale, posession)
	"Truly addicting synthetic narcotics" (total, sale, posession)
	"Other dangerous non-narcotic drugs" (total, sale, posession)
	Property (total, larceny, burglary, MVT, arson) 
	Violent (total, murder, assault, rape, robbery)
	Vandalism
	Liquor law 
	Drunkenness 
	Disorderly Conduct

Demographic groups: 
	18+ white and black

*/

*******
**# Data cleaning 
*******
use "$path\data\ucr\data\ucr\raw\ucr_arrests_yearly_all_crimes_race_sex_1974_2020.dta", clear

keep if inrange(year, 2000, 2019)

**need to remove multiple ORI-year obs first 
		*for example: br if ori=="CO03001" & year==2019
duplicates tag ori year, gen(dup)
gen dropper=dup==1 & population==0
replace dropper=0 if dup==1 & inlist(agency_name, "austin community college", "state fire marshal", "park security")	
replace dropper=1 if (ori=="FL01701" & agency_name=="state attorney's office") | (ori=="KS08904" & agency_name=="dol special investigatio")
replace dropper=1 if (ori=="LA01711" & agency_name=="dept pub sfty st cap dtl") | (ori=="MS02502" & agency_name=="gaming commission, vicks")
replace dropper=1 if (ori=="LA01711" & agency_name=="dept pub sfty st cap dtl") | (ori=="MS02502" & agency_name=="gaming commission, vicks")
drop if dropper==1 
drop dropper dup
duplicates tag ori year, gen(dup)
sort ori year
bysort ori year: gen counter=_n 
drop if counter==2 & dup==1
duplicates report ori year
drop dup counter

/* Chu (2015) sample restrictions 

Limit to city ORIs 

Keep cities with population of 50,000 or more 
at any point in the sample and always have a population 
of at least 25,000

Restrict to city-years with at least 6 months of arrest 
reporting and those that only report in December (a common
practice of ORIs that only report annually)

*/
*city sample restriction
keep if strpos(population_group, "city")

*population sample restriction
egen min_pop=min(population), by(ori)
egen max_pop=max(population), by(ori)
keep if min_pop>=25000 & max_pop>=50000

**merge in whether ORIs only reporting arrests in december
preserve 

forval i=2000/2019 {

	use "$path\data\ucr\data\ucr\raw\ucr_arrests_monthly_all_crimes_race_sex_`i'.dta", clear

	*drop agency-month repeat observations
	sort ori year month
	bysort ori year month: gen n=_n
	drop if n!=1
	drop n
	
	*city sample restriction
	keep if strpos(population_group, "city")
	drop if population<25000

	egen total_arrests_all=rowtotal(agg_assault_tot_adult agg_assault_tot_juv all_other_tot_adult all_other_tot_juv arson_tot_adult arson_tot_juv burglary_tot_adult burglary_tot_juv curfew_loiter_tot_adult curfew_loiter_tot_juv disorder_cond_tot_adult disorder_cond_tot_juv drunkenness_tot_adult drunkenness_tot_juv dui_tot_adult dui_tot_juv embezzlement_tot_adult embezzlement_tot_juv family_off_tot_adult family_off_tot_juv forgery_tot_adult forgery_tot_juv fraud_tot_adult fraud_tot_juv gamble_total_tot_juv liquor_tot_adult liquor_tot_juv manslaught_neg_tot_adult manslaught_neg_tot_juv mtr_veh_theft_tot_adult mtr_veh_theft_tot_juv murder_tot_adult murder_tot_juv oth_assault_tot_adult oth_assault_tot_juv oth_sex_off_tot_adult oth_sex_off_tot_juv prostitution_tot_adult prostitution_tot_juv rape_tot_adult rape_tot_juv robbery_tot_adult robbery_tot_juv runaways_tot_adult runaways_tot_juv stolen_prop_tot_adult stolen_prop_tot_juv suspicion_tot_adult suspicion_tot_juv theft_tot_adult theft_tot_juv total_drug_tot_adult total_drug_tot_juv vagrancy_tot_adult vagrancy_tot_juv vandalism_tot_adult vandalism_tot_juv weapons_tot_adult weapons_tot_juv)
	egen temp=rowmax(agg_assault_adult_amer_ind-weapons_tot_white)
	keep ori year month number_of_months_reported total_arrests_all temp
	gen report=temp!=0
	drop temp

	egen tot_report=sum(report), by(ori)
	gen temp=report==1 & month=="december"
	egen december_report=max(temp), by(ori)
	gen only_december_report=tot_report==1 & december_report==1

	collapse number_of_months_reported, by(ori year only_december_report)
	drop number_of_months_reported

	tempfile y`i'
	save `y`i''

}
use `y2000'
forval i=2001/2019 {
	append using `y`i''
}
tempfile dec_report 
save `dec_report'

restore
**
merge 1:1 ori year using `dec_report'
drop if _merge==2
drop _merge

*arrest reporting sample restriction 
gen report=(number_of_months_reported>=6 | only_december_report==1)
keep if (number_of_months_reported>=6 | only_december_report==1)
egen tot=sum(report), by(ori)
gen balanced=tot==20
drop tot

**create arrest variables 
foreach i in agg_assault murder rape robbery arson burglary mtr_veh_theft theft liquor drunkenness dui vandalism disorder_cond total_drug poss_drug_total sale_drug_total sale_cannabis poss_cannabis sale_heroin_coke poss_heroin_coke sale_synth_narc poss_synth_narc sale_other_drug poss_other_drug {
	
	gen `i'_1899_all=`i'_tot_adult 
	gen `i'_1899_black=`i'_adult_black	
	gen `i'_1899_white=`i'_adult_white
	
}
foreach i in cannabis heroin_coke synth_narc other_drug {
	gen total_`i'_1899_all=sale_`i'_1899_all+poss_`i'_1899_all
	gen total_`i'_1899_black=sale_`i'_1899_black+poss_`i'_1899_black
	gen total_`i'_1899_white=sale_`i'_1899_white+poss_`i'_1899_white

}
foreach i in 1899_all 1899_black 1899_white {
	gen property_`i'=theft_`i'+burglary_`i'+mtr_veh_theft_`i'+arson_`i'
	gen violent_`i'=agg_assault_`i'+murder_`i'+rape_`i'+robbery_`i'
}
*total arrests for 18-99 YOs
gen total_1899_all=agg_assault_tot_adult+all_other_tot_adult+arson_tot_adult+burglary_tot_adult+curfew_loiter_tot_adult+disorder_cond_tot_adult+drunkenness_tot_adult+dui_tot_adult+embezzlement_tot_adult+family_off_tot_adult+forgery_tot_adult+fraud_tot_adult+gamble_total_tot_adult+liquor_tot_adult+manslaught_neg_tot_adult+mtr_veh_theft_tot_adult+murder_tot_adult+oth_assault_tot_adult+oth_sex_off_tot_adult+prostitution_tot_adult+rape_tot_adult+robbery_tot_adult+runaways_tot_adult+total_drug_tot_adult+stolen_prop_tot_adult+suspicion_tot_adult+theft_tot_adult+vagrancy_tot_adult+vandalism_tot_adult+weapons_tot_adult
gen total_1899_black=agg_assault_adult_black+all_other_adult_black+arson_adult_black+burglary_adult_black+curfew_loiter_adult_black+disorder_cond_adult_black+drunkenness_adult_black+dui_adult_black+embezzlement_adult_black+family_off_adult_black+forgery_adult_black+fraud_adult_black+gamble_total_adult_black+liquor_adult_black+manslaught_neg_adult_black+mtr_veh_theft_adult_black+murder_adult_black+oth_assault_adult_black+oth_sex_off_adult_black+prostitution_adult_black+rape_adult_black+robbery_adult_black+runaways_adult_black+total_drug_adult_black+stolen_prop_adult_black+suspicion_adult_black+theft_adult_black+vagrancy_adult_black+vandalism_adult_black+weapons_adult_black
gen total_1899_white=agg_assault_adult_white+all_other_adult_white+arson_adult_white+burglary_adult_white+curfew_loiter_adult_white+disorder_cond_adult_white+drunkenness_adult_white+dui_adult_white+embezzlement_adult_white+family_off_adult_white+forgery_adult_white+fraud_adult_white+gamble_total_adult_white+liquor_adult_white+manslaught_neg_adult_white+mtr_veh_theft_adult_white+murder_adult_white+oth_assault_adult_white+oth_sex_off_adult_white+prostitution_adult_white+rape_adult_white+robbery_adult_white+runaways_adult_white+total_drug_adult_white+stolen_prop_adult_white+suspicion_adult_white+theft_adult_white+vagrancy_adult_white+vandalism_adult_white+weapons_adult_white

drop agg_assault_adult_amer_ind-sale_drug_total_tot_white

**merge in county race shares 
ren fips_state_code fips 
destring fips, replace 
ren fips_county_code county 
destring county, replace 
merge m:1 fips county year using "$path\data\ucr\data\seer\cleaned\seer_county-year_2000-2019_cleaned.dta", keepusing(popshare*) 
drop if _merge==2
drop _merge

foreach i in all black white {
	gen pop_r_`i'=popshare_1899_`i'*population
}

**keep relevant vars
keep year state state_abb fips county ori ori9 population pop_r_all pop_r_black pop_r_white number_of_months_reported agg_assault_1899_all-total_1899_white balanced
keep if inrange(fips, 1, 56)
sort ori year

encode ori, gen(ori_num)

**save 
save "$path\data\ucr\data\ucr\cleaned\ucr_agency-year_2000-2019_cleaned.dta", replace 



clear 


