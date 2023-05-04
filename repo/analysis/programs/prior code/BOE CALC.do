**********************************************************
*name: BOE CALC.do
*author: Zach Fone (Montana State University)
*description: Cleaning UCR data to be used in the RML 
*             project
**********************************************************
/*
"I need to know the count (not rate) of arrests per year that our estimates imply 
are reduced due to RMLs for Blacks and Whites for marijuana arrests and narcotics arrests. 
We can do this as an average over the sample period we studied (2000-2019).  
Please add these in the Conclusion section."

the synthetic narcotic (event study) results aren't that convincing to me
*/
clear 

use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear 

drop if race==1

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.
keep if rml==0 & ever_rml==1

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

keep state state_abb fips year race total_cannabis_1899 total_synth_narc_1899 pop_1899

sum total_cannabis_1899 if race==2 [aw=pop_1899]
gen cannabis_mean=r(mean)
sum total_cannabis_1899 if race==3 [aw=pop_1899]
replace cannabis_mean=r(mean) if race==3

sum total_synth_narc_1899 if race==2 [aw=pop_1899]
gen synth_narc_mean=r(mean)
sum total_synth_narc_1899 if race==3 [aw=pop_1899]
replace synth_narc_mean=r(mean) if race==3

keep cannabis_mean synth_narc_mean race
keep in 1/2

gen cannabis_te=(-325.15/492.25) if race==2
replace cannabis_te=(-115.23/158.32) if race==3
gen synth_narc_te=(-20.11/19.99) if race==2
replace synth_narc_te=(-24.29/18.07) if race==3

gen cannabis_reduction=cannabis_te*cannabis_mean
gen synth_narc_reduction=synth_narc_te*synth_narc_mean


/*
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear 

drop if race==1

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.
keep if rml==0 & ever_rml==1

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

keep state state_abb fips year race total_cannabis_1899 total_synth_narc_1899 pop_1899

collapse (mean) total_cannabis_1899 total_synth_narc_1899 [pw=pop_1899], by(year race)
collapse (mean) total_cannabis_1899 total_synth_narc_1899 , by(race)

gen cannabis_te=(-325.15/492.25) if race==2
replace cannabis_te=(-115.23/158.32) if race==3
gen synth_narc_te=(-20.11/19.99) if race==2
replace synth_narc_te=(-24.29/18.07) if race==3

gen cannabis_reduction=cannabis_te*total_cannabis_1899
gen synth_narc_reduction=synth_narc_te*total_synth_narc_1899
*/


/*
keep state state_abb fips year race total_cannabis_1899 total_synth_narc_1899 pop_1899

drop if race==1

collapse (sum) total_cannabis_1899 total_synth_narc_1899 pop_1899, by(year race)
collapse (mean) total_cannabis_1899 total_synth_narc_1899 pop_1899, by(race)

ren (total_cannabis_1899 total_synth_narc_1899 pop_1899) (cannabis_ synth_narc_ pop_)

ren race racee 
decode racee, gen(race)
drop racee 

gen samp="2000-2019"
gen age="18+"
reshape wide cannabis_ synth_narc_ pop_, i(samp age) j(race) string

gen cannabis_black_rate=(cannabis_black/pop_black)*100000

**black pop in 100ks
gen black_pop_100ks=pop_black/100000

**arrest reduction per 100ks (325.15)
gen arrest_red_cann_black_100ks=325.15

**arrest reduction count 
gen double arrest_red_cann_black_count=black_pop_100ks*arrest_red_cann_black_100ks
*/

**try to match the count from here: https://ucr.fbi.gov/crime-in-the-u.s/2019/crime-in-the-u.s.-2019/topic-pages/tables/table-29
**and this one: https://ucr.fbi.gov/crime-in-the-u.s/2019/crime-in-the-u.s.-2019/topic-pages/tables/table-43

/*
keep state state_abb fips year race total_cannabis_1899 total_synth_narc_1899 pop_1899

drop if race==1

collapse (sum) pop_1899, by(year race)
collapse (mean) pop_1899, by(race)

ren pop_1899 pop_

ren race racee 
decode racee, gen(race)
drop racee 

gen samp="2000-2019"
gen age="18+"
reshape wide pop_, i(samp age) j(race) string

format pop_white pop_black %15.0gc

gen cann_te_black=-325.15
gen synth_narc_te_black=-20.11
gen cann_reduction_black=cann_te_black*(pop_black/100000)
gen synth_narc_reduction_black=synth_narc_te_black*(pop_black/100000)

gen cann_te_white=-115.23
gen synth_narc_te_white=-24.29
gen cann_reduction_white=cann_te_white*(pop_white/100000)
gen synth_narc_reduction_white=synth_narc_te_white*(pop_white/100000)

*/
