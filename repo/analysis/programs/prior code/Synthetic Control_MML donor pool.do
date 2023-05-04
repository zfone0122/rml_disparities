**********************************************************
*name: Synthetic Control_MML donor pool.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Synthetic Control Estimates
*created: december 9, 2022
*updated: NA
**********************************************************
clear 

cd "$path\analysis\figures\synth\mml-donor\"

*******************************************************************
**# Marijuana
*******************************************************************
******************************************
**# Colorado [ trperiod(2013) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

MML adopting non-RML states

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==8)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=8 & mml_year==.) 

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

**********************
*White 
**********************
preserve 

keep if race==3
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_mj_white.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -136.6013           0  -136.6013  -136.6013
       p_val |         42    .0869565           0   .0869565   .0869565

*/
save "CO_mj_white.dta", replace 

restore 

**********************
*Black 
**********************
preserve 

keep if race==2
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "CO_mj_black.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(8) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==8 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=8
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=8
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -361.2961           0  -361.2961  -361.2961
       p_val |         42    .6086956           0   .6086956   .6086956
*/
save "CO_mj_black.dta", replace 

restore 

**********************
*Combine figures 
**********************
use "CO_mj_white.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="white"
tempfile white
save `white'
use "CO_mj_black.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="black"
append using `white'

twoway (line treat year if race=="white", lcolor(navy)) (line synth year if race=="white", lcolor(navy) lpattern(dash)) (line treat year if race=="black", lcolor(maroon)) ///
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2012.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(label(1 "CO-White") label(2 "Synth CO-White") label(3 "CO-Black") label(4 "Synth CO-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "CO_mj.png", replace 


******************************************
**# Washington [ trperiod(2013) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

MML adopting non-RML states

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==53)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=53 & mml_year==.) 

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

**********************
*White 
**********************
preserve 

keep if race==3
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_mj_white.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -95.99596           0  -95.99596  -95.99596
       p_val |         42    .4347826           0   .4347826   .4347826
*/
save "WA_mj_white.dta", replace 

restore 

**********************
*Black 
**********************
preserve 

keep if race==2
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) resultsperiod(2000(1)2019) nest fig 
graph save "WA_mj_black.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012), trunit(53) trperiod(2013) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==53 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2013-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=53
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=53
}

gen temp=effect if year>=2013
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -245.4397           0  -245.4397  -245.4397
       p_val |         42    .3913043           0   .3913043   .3913043
*/
save "WA_mj_black.dta", replace 

restore 

**********************
*Combine figures 
**********************
use "WA_mj_white.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="white"
tempfile white
save `white'
use "WA_mj_black.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="black"
append using `white'

twoway (line treat year if race=="white", lcolor(navy)) (line synth year if race=="white", lcolor(navy) lpattern(dash)) (line treat year if race=="black", lcolor(maroon)) ///
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2012.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(label(1 "WA-White") label(2 "Synth WA-White") label(3 "WA-Black") label(4 "Synth WA-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "WA_mj.png", replace 


******************************************
**# Alaska [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

MML adopting non-RML states

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==2)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=2 & mml_year==.) 

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

**********************
*White 
**********************
preserve 

keep if race==3
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_mj_white.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         22   -38.93266           0  -38.93266  -38.93266
       p_val |         22    .6956522           0   .6956522   .6956522
*/
save "AK_mj_white.dta", replace 

restore 

**********************
*Black 
**********************
preserve 

keep if race==2
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "AK_mj_black.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(2) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==2 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=2
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=2
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         22   -196.1349           0  -196.1349  -196.1349
       p_val |         22    .2608696           0   .2608696   .2608696

*/
save "AK_mj_black.dta", replace 

restore 

**********************
*Combine figures 
**********************
use "AK_mj_white.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="white"
tempfile white
save `white'
use "AK_mj_black.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="black"
append using `white'

twoway (line treat year if race=="white", lcolor(navy)) (line synth year if race=="white", lcolor(navy) lpattern(dash)) (line treat year if race=="black", lcolor(maroon)) ///
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2014.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(label(1 "AK-White") label(2 "Synth AK-White") label(3 "AK-Black") label(4 "Synth AK-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "AK_mj.png", replace 


******************************************
**# Oregon [ trperiod(2015) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

MML adopting non-RML states

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==41)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=41 & mml_year==.) 

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

**********************
*White 
**********************
preserve 

keep if race==3
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_mj_white.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -190.4676           0  -190.4676  -190.4676
       p_val |         42    .0869565           0   .0869565   .0869565
*/
save "OR_mj_white.dta", replace 

restore 

**********************
*Black 
**********************
preserve 

keep if race==2
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) resultsperiod(2000(1)2019) nest fig 
graph save "OR_mj_black.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014), trunit(41) trperiod(2015) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==41 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2015-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=41
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=41
}

gen temp=effect if year>=2015
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -245.7365           0  -245.7365  -245.7365
       p_val |         42    .4347826           0   .4347826   .4347826
*/
save "OR_mj_black.dta", replace 

restore 

**********************
*Combine figures 
**********************
use "OR_mj_white.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="white"
tempfile white
save `white'
use "OR_mj_black.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="black"
append using `white'

twoway (line treat year if race=="white", lcolor(navy)) (line synth year if race=="white", lcolor(navy) lpattern(dash)) (line treat year if race=="black", lcolor(maroon)) ///
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2014.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(label(1 "OR-White") label(2 "Synth OR-White") label(3 "OR-Black") label(4 "Synth OR-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "OR_mj.png", replace 


******************************************
**# California [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

MML adopting non-RML states

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==6)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=6 & mml_year==.) 

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

**********************
*White 
**********************
preserve 

keep if race==3
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_mj_white.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -30.70712           0  -30.70712  -30.70712
       p_val |         42    .6956522           0   .6956522   .6956522
*/
save "CA_mj_white.dta", replace 

restore 

**********************
*Black 
**********************
preserve 

keep if race==2
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "CA_mj_black.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(6) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==6 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=6
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=6
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -151.3549           0  -151.3549  -151.3549
       p_val |         42    .6086956           0   .6086956   .6086956
*/
save "CA_mj_black.dta", replace 

restore 

**********************
*Combine figures 
**********************
use "CA_mj_white.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="white"
tempfile white
save `white'
use "CA_mj_black.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="black"
append using `white'

twoway (line treat year if race=="white", lcolor(navy)) (line synth year if race=="white", lcolor(navy) lpattern(dash)) (line treat year if race=="black", lcolor(maroon)) ///
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2016.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(label(1 "CA-White") label(2 "Synth CA-White") label(3 "CA-Black") label(4 "Synth CA-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "CA_mj.png", replace 


******************************************
**# Massachusetts [ trperiod(2017) ]
******************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

drop if race==1

/**Donor pool

MML adopting non-RML states

**/
egen max_rml=max(rml), by(fips)
keep if (max_rml==0 | fips==25)
replace mml_year="" if mml_year=="NA"
destring mml_year, replace
drop if (fips!=25 & mml_year==.)

**need balanced panel 
gen one=1
egen periods=sum(one), by(fips race)
drop if periods!=20 //Wisconsin 
drop one periods

**********************
*White 
**********************
preserve 

keep if race==3
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_mj_white.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42    -29.1431           0   -29.1431   -29.1431
       p_val |         42    .7826087           0   .7826087   .7826087
*/
save "MA_mj_white.dta", replace 

restore 

**********************
*Black 
**********************
preserve 

keep if race==2
********
*using synth to produce a synthetic control figure
********
*set panel
tsset fips year

synth rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) resultsperiod(2000(1)2019) nest fig 
graph save "MA_mj_black.gph", replace
mat donor = e(W_weights)[1..22,1]
svmat int donor, name(donor_fips)
mat weight = e(W_weights)[1..22,2]
svmat double weight, name(donor_weight)
ren (donor_fips1 donor_weight1) (donor_fips donor_weight)

********
*using synth_runner to conduct a permutation test
********
synth_runner rate_total_cannabis_1899 rate_total_cannabis_1899(2000) rate_total_cannabis_1899(2001) rate_total_cannabis_1899(2002) rate_total_cannabis_1899(2003) rate_total_cannabis_1899(2004) rate_total_cannabis_1899(2005) rate_total_cannabis_1899(2006) rate_total_cannabis_1899(2007) rate_total_cannabis_1899(2008) rate_total_cannabis_1899(2009) rate_total_cannabis_1899(2010) rate_total_cannabis_1899(2011) rate_total_cannabis_1899(2012) rate_total_cannabis_1899(2013) rate_total_cannabis_1899(2014) rate_total_cannabis_1899(2015) rate_total_cannabis_1899(2016), trunit(25) trperiod(2017) gen_vars 
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random || see page 844 from the following url for a walk-through of the p-value calculation: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801700404
*single_treatment_graphs
gen p_val=(e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1)
keep if (fips==25 | donor_weight!=.)
keep state state_abb fips pre_rmspe post_rmspe lead effect rate_total_cannabis_1899_synth p_val donor_fips donor_weight
gen year=lead+2017-1
order year, before(lead)
foreach i in state state_abb {
	replace `i'="" if fips!=25
}
foreach i in fips pre_rmspe post_rmspe year lead effect rate_total_cannabis_1899_synth {
	replace `i'=. if fips!=25
}

gen temp=effect if year>=2017
egen rml_effect=mean(temp)
drop temp 
sum rml_effect p_val 
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  rml_effect |         42   -114.3962           0  -114.3962  -114.3962
       p_val |         42    .6521739           0   .6521739   .6521739
*/
save "MA_mj_black.dta", replace 

restore 

**********************
*Combine figures 
**********************
use "MA_mj_white.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="white"
tempfile white
save `white'
use "MA_mj_black.dta", clear 
gen treat=rate_total_cannabis_1899_synth+effect
gen synth= rate_total_cannabis_1899_synth
drop if year==.
keep state fips year lead effect p_val rml_effect treat synth
gen race="black"
append using `white'

twoway (line treat year if race=="white", lcolor(navy)) (line synth year if race=="white", lcolor(navy) lpattern(dash)) (line treat year if race=="black", lcolor(maroon)) ///
		(line synth year if race=="black", lcolor(maroon) lpattern(dash) xline(2016.5, lcolor(gs8)) xlabel(2000(4)2020) ylabel(0(200)1000) graphregion(color(white)) legend(label(1 "MA-White") label(2 "Synth MA-White") label(3 "MA-Black") label(4 "Synth MA-Black")) ytitle("Arrest Rate", size(small)) xtitle("Year", size(small)) )
graph export "MA_mj.png", replace 
